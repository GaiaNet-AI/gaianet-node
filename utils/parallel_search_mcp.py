#!/usr/bin/env python3

import argparse
import http.client
import json
import os
import re
import signal
import ssl
import subprocess
import sys
import tempfile
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


UPSTREAM_HOST = "search.parallel.ai"
UPSTREAM_PATH = "/mcp"
LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 8012
LOCAL_URL = f"http://{LISTEN_HOST}:{LISTEN_PORT}{UPSTREAM_PATH}"
SERVER_NAME = "parallel-search"
MANAGED_MARKER = "# Managed by GaiaNet Node."
MAX_REQUEST_BODY_BYTES = 4 * 1024 * 1024
READ_CHUNK_BYTES = 64 * 1024
UPSTREAM_TIMEOUT_SECONDS = 120

REQUEST_HEADERS = (
    "Accept",
    "Content-Type",
    "MCP-Protocol-Version",
    "Mcp-Session-Id",
    "Last-Event-ID",
)
RESPONSE_HEADERS = {
    "allow",
    "cache-control",
    "content-encoding",
    "content-length",
    "content-type",
    "mcp-protocol-version",
    "mcp-session-id",
    "retry-after",
    "www-authenticate",
}


def atomic_write(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    original_mode = path.stat().st_mode & 0o777 if path.exists() else 0o644
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", dir=path.parent, text=True
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as temporary:
            temporary.write(content)
        os.chmod(temporary_name, original_mode)
        os.replace(temporary_name, path)
    except Exception:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass
        raise


def provider_from_config(config_path):
    config = json.loads(Path(config_path).read_text(encoding="utf-8"))
    if not isinstance(config, dict):
        raise ValueError("node config must be a JSON object")
    if "web_search_provider" not in config:
        return "legacy"
    provider = config["web_search_provider"]
    if not isinstance(provider, str) or provider not in {"none", "parallel"}:
        raise ValueError("web_search_provider must be 'none' or 'parallel'")
    return provider


def _is_table_header(line):
    stripped = line.strip()
    return stripped.startswith("[") and (
        stripped.endswith("]") or re.search(r"\]\s+#", stripped) is not None
    )


def _tool_ranges(lines):
    starts = [
        index
        for index, line in enumerate(lines)
        if line.strip() == "[[mcp.server.tool]]"
    ]
    ranges = []
    for start in starts:
        end = len(lines)
        for index in range(start + 1, len(lines)):
            if _is_table_header(lines[index]):
                end = index
                break
        ranges.append((start, end))
    return ranges


def _block_name(block):
    for line in block:
        match = re.match(r'^\s*name\s*=\s*"([^"]+)"', line)
        if match:
            return match.group(1)
    return None


def _property_value(block, key):
    pattern = re.compile(rf'^\s*{re.escape(key)}\s*=\s*(.*?)\s*(?:#.*)?$')
    matches = [pattern.match(line) for line in block]
    matches = [match for match in matches if match]
    if len(matches) > 1:
        raise ValueError(f"duplicate '{key}' setting in MCP server block")
    if not matches:
        return None
    value = matches[0].group(1).strip()
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    return value


def _set_property(block, key, value):
    pattern = re.compile(
        rf'^([ \t]*{re.escape(key)}[ \t]*=[ \t]*)(.*?)([ \t]+#.*)?(\r?\n)?$'
    )
    matches = [index for index, line in enumerate(block) if pattern.match(line)]
    if len(matches) > 1:
        raise ValueError(f"duplicate '{key}' setting in MCP server block")
    if matches:
        index = matches[0]
        match = pattern.match(block[index])
        block[index] = (
            f"{match.group(1)}{value}{match.group(3) or ''}{match.group(4) or ''}"
        )
    else:
        block.append(f"{key} = {value}\n")


def _remove_property(block, key):
    pattern = re.compile(rf"^[ \t]*{re.escape(key)}[ \t]*=")
    block[:] = [line for line in block if not pattern.match(line)]


def _is_managed_parallel_block(block):
    return any(MANAGED_MARKER in line for line in block) or _property_value(
        block, "url"
    ) == LOCAL_URL


def configure_mcp_text(text, provider):
    if not isinstance(provider, str) or provider not in {"legacy", "none", "parallel"}:
        raise ValueError("provider must be 'legacy', 'none' or 'parallel'")

    lines = text.splitlines(keepends=True)
    ranges = _tool_ranges(lines)
    matches = {SERVER_NAME: [], "cardea-web-search": []}
    for start, end in ranges:
        name = _block_name(lines[start:end])
        if name in matches:
            matches[name].append((start, end))
    for name, blocks in matches.items():
        if len(blocks) > 1:
            raise ValueError(f"multiple '{name}' MCP server entries found")

    parallel_range = matches[SERVER_NAME][0] if matches[SERVER_NAME] else None
    cardea_range = matches["cardea-web-search"][0] if matches["cardea-web-search"] else None

    if provider == "parallel":
        if parallel_range:
            start, end = parallel_range
            if not _is_managed_parallel_block(lines[start:end]):
                raise ValueError(
                    "an unmanaged 'parallel-search' MCP entry already exists; "
                    "rename it before selecting the GaiaNet provider"
                )
        targets = [
            (SERVER_NAME, parallel_range),
            ("cardea-web-search", cardea_range),
        ]
        for name, block_range in sorted(
            (item for item in targets if item[1]),
            key=lambda item: item[1][0],
            reverse=True,
        ):
            start, end = block_range
            block = lines[start:end]
            if name == SERVER_NAME:
                _remove_property(block, "oauth_url")
                _set_property(block, "transport", '"stream-http"')
                _set_property(block, "url", f'"{LOCAL_URL}"')
                _set_property(block, "enable", "true")
                if not any(MANAGED_MARKER in line for line in block):
                    block.insert(1, f"{MANAGED_MARKER}\n")
            else:
                _set_property(block, "enable", "false")
            lines[start:end] = block
        if not parallel_range:
            if lines and not lines[-1].endswith(("\n", "\r")):
                lines[-1] += "\n"
            if lines and lines[-1].strip():
                lines.append("\n")
            lines.extend(
                [
                    "[[mcp.server.tool]]\n",
                    f"{MANAGED_MARKER}\n",
                    f'name = "{SERVER_NAME}"\n',
                    'transport = "stream-http"\n',
                    f'url = "{LOCAL_URL}"\n',
                    "enable = true\n",
                ]
            )

    elif provider == "none":
        targets = [
            (SERVER_NAME, parallel_range),
            ("cardea-web-search", cardea_range),
        ]
        for name, block_range in sorted(
            (item for item in targets if item[1]),
            key=lambda item: item[1][0],
            reverse=True,
        ):
            start, end = block_range
            block = lines[start:end]
            if name == SERVER_NAME and not _is_managed_parallel_block(block):
                if _property_value(block, "enable") == "true":
                    raise ValueError(
                        "an unmanaged 'parallel-search' MCP entry is enabled; "
                        "disable or rename it before selecting 'none'"
                    )
                continue
            _set_property(block, "enable", "false")
            lines[start:end] = block

    elif parallel_range:
        start, end = parallel_range
        block = lines[start:end]
        if _is_managed_parallel_block(block):
            _set_property(block, "enable", "false")
            lines[start:end] = block

    return "".join(lines)


def configure_mcp_file(mcp_config_path, provider):
    path = Path(mcp_config_path)
    text = path.read_text(encoding="utf-8")
    updated = configure_mcp_text(text, provider)
    if updated != text:
        atomic_write(path, updated)


def set_provider(config_path, mcp_config_path, provider):
    if not isinstance(provider, str) or provider not in {"none", "parallel"}:
        raise ValueError("provider must be 'none' or 'parallel'")
    config_path = Path(config_path)
    config = json.loads(config_path.read_text(encoding="utf-8"))
    if not isinstance(config, dict):
        raise ValueError("node config must be a JSON object")
    updated = dict(config)
    updated["web_search_provider"] = provider
    configure_mcp_file(mcp_config_path, provider)
    atomic_write(config_path, json.dumps(updated, indent=4, ensure_ascii=False) + "\n")


def normalize_mcp_response(request_body, response_body):
    try:
        request = json.loads(request_body)
        response = json.loads(response_body)
    except (TypeError, ValueError, UnicodeDecodeError):
        return response_body
    if (
        not isinstance(request, dict)
        or request.get("method") not in {"initialize", "tools/list"}
        or not isinstance(response, dict)
        or response.get("jsonrpc") != "2.0"
        or response.get("id") != request.get("id")
    ):
        return response_body
    result = response.get("result")
    if not isinstance(result, dict):
        return response_body
    if request["method"] == "initialize":
        server_info = result.get("serverInfo")
        icon_groups = (
            [server_info.get("icons")] if isinstance(server_info, dict) else []
        )
    else:
        tools = result.get("tools")
        icon_groups = (
            [tool.get("icons") for tool in tools if isinstance(tool, dict)]
            if isinstance(tools, list)
            else []
        )
    changed = False
    for icons in icon_groups:
        if not isinstance(icons, list):
            continue
        for icon in icons:
            if not isinstance(icon, dict):
                continue
            sizes = icon.get("sizes")
            if isinstance(sizes, list) and all(isinstance(size, str) for size in sizes):
                if sizes:
                    icon["sizes"] = " ".join(sizes)
                else:
                    icon.pop("sizes")
                changed = True
    if not changed:
        return response_body
    return json.dumps(response, ensure_ascii=False, separators=(",", ":")).encode("utf-8")


def _read_bounded_response(response, maximum_bytes):
    body = bytearray()
    while len(body) <= maximum_bytes:
        remaining = maximum_bytes + 1 - len(body)
        chunk = response.read1(min(READ_CHUNK_BYTES, remaining))
        if not chunk:
            return bytes(body), True
        body.extend(chunk)
    return bytes(body), False


def _client_user_agent(value, node_version):
    value = value.strip()
    if len(value) > 256 or any(ord(char) < 0x20 or ord(char) > 0x7E for char in value):
        value = ""
    # Preserve this project identity across transport refactors for aggregate usage measurement.
    return f"GaiaNet-Node/{node_version}" + (f" {value}" if value else "")


def make_proxy_handler(node_version, connection_factory=None):
    if not re.fullmatch(r"[A-Za-z0-9._+-]{1,40}", node_version):
        raise ValueError("node version must be a simple version token")
    if connection_factory is None:
        connection_factory = lambda host, timeout: http.client.HTTPSConnection(
            host, timeout=timeout, context=ssl.create_default_context()
        )

    class ParallelSearchHandler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"
        server_version = "GaiaNetNode"
        sys_version = ""

        def log_message(self, format_string, *args):
            return

        def do_GET(self):
            target = urlsplit(self.path)
            if target.path == "/healthz" and not target.query:
                body = b"ok"
                self.send_response(200)
                self.send_header("Content-Type", "text/plain; charset=utf-8")
                self.send_header("Content-Length", str(len(body)))
                self.send_header("Connection", "close")
                self.end_headers()
                self.wfile.write(body)
                self.close_connection = True
                return
            self._proxy_request()

        def do_POST(self):
            self._proxy_request()

        def do_DELETE(self):
            self._proxy_request()

        def _proxy_request(self):
            self.close_connection = True
            target = urlsplit(self.path)
            if target.path != UPSTREAM_PATH or target.query or target.fragment:
                self.send_error(400, "Only the fixed MCP path is available")
                return
            if self.command not in {"GET", "POST", "DELETE"}:
                self.send_error(405, "Unsupported MCP method")
                return
            if self.headers.get("Transfer-Encoding"):
                self.send_error(501, "Chunked client requests are not supported")
                return

            raw_length = self.headers.get("Content-Length", "0")
            try:
                content_length = int(raw_length)
            except ValueError:
                self.send_error(400, "Invalid content length")
                return
            if content_length < 0:
                self.send_error(400, "Invalid content length")
                return
            if content_length > MAX_REQUEST_BODY_BYTES:
                self.send_error(413, "MCP request body is too large")
                return

            body = self.rfile.read(content_length) if content_length else None
            if body is not None and len(body) != content_length:
                self.send_error(400, "Incomplete request body")
                return

            headers = {
                name: self.headers.get(name)
                for name in REQUEST_HEADERS
                if self.headers.get(name) is not None
            }
            headers["User-Agent"] = _client_user_agent(
                self.headers.get("User-Agent", ""), node_version
            )
            connection = None
            response_started = False
            try:
                connection = connection_factory(
                    UPSTREAM_HOST, timeout=UPSTREAM_TIMEOUT_SECONDS
                )
                connection.request(
                    self.command,
                    UPSTREAM_PATH,
                    body=body,
                    headers=headers,
                )
                response = connection.getresponse()
                if 300 <= response.status < 400:
                    self.send_error(502, "Upstream redirects are not followed")
                    return

                response_headers = response.getheaders()
                buffered_body = None
                buffered_body_complete = False
                content_length_override = None
                if self.command == "POST" and body:
                    try:
                        request_method = json.loads(body).get("method")
                    except (TypeError, ValueError, AttributeError):
                        request_method = None
                    content_type = next(
                        (
                            value
                            for name, value in response_headers
                            if name.lower() == "content-type"
                        ),
                        "",
                    )
                    content_encoding = next(
                        (
                            value
                            for name, value in response_headers
                            if name.lower() == "content-encoding"
                        ),
                        "",
                    )
                    if (
                        request_method in {"initialize", "tools/list"}
                        and response.status == 200
                        and content_type.split(";", 1)[0].strip().lower()
                        == "application/json"
                        and content_encoding.lower() in {"", "identity"}
                    ):
                        buffered_body, buffered_body_complete = _read_bounded_response(
                            response, MAX_REQUEST_BODY_BYTES
                        )
                        if buffered_body_complete:
                            normalized_body = normalize_mcp_response(
                                body, buffered_body
                            )
                            if normalized_body != buffered_body:
                                buffered_body = normalized_body
                                content_length_override = len(normalized_body)

                self.send_response(response.status, response.reason)
                response_started = True
                for name, value in response_headers:
                    if (
                        content_length_override is not None
                        and name.lower() == "content-length"
                    ):
                        continue
                    if (
                        name.lower() in RESPONSE_HEADERS
                        and "\r" not in value
                        and "\n" not in value
                    ):
                        self.send_header(name, value)
                if content_length_override is not None:
                    self.send_header("Content-Length", str(content_length_override))
                self.send_header("Connection", "close")
                self.end_headers()
                if response.status not in {204, 304}:
                    if buffered_body is not None:
                        self.wfile.write(buffered_body)
                        self.wfile.flush()
                    if not buffered_body_complete:
                        while True:
                            chunk = response.read1(READ_CHUNK_BYTES)
                            if not chunk:
                                break
                            self.wfile.write(chunk)
                            self.wfile.flush()
            except (OSError, http.client.HTTPException, ssl.SSLError, ValueError):
                if not response_started:
                    self.send_error(502, "Search MCP upstream request failed")
            finally:
                if connection is not None:
                    connection.close()

    return ParallelSearchHandler


def _process_matches_helper(pid, pid_file):
    script_path = str(Path(__file__).resolve())
    pid_file_path = str(Path(pid_file).resolve())
    proc_path = Path(f"/proc/{pid}/cmdline")
    if proc_path.exists():
        try:
            arguments = [
                argument.decode(errors="replace")
                for argument in proc_path.read_bytes().split(b"\0")
                if argument
            ]
            script_matches = any(
                Path(argument).resolve() == Path(script_path)
                for argument in arguments
            )
            pid_file_matches = False
            for index, argument in enumerate(arguments[:-1]):
                if argument == "--pid-file":
                    pid_file_matches = (
                        Path(arguments[index + 1]).resolve() == Path(pid_file_path)
                    )
                    break
            return script_matches and pid_file_matches and "serve" in arguments
        except OSError:
            return False
    try:
        result = subprocess.run(
            ["ps", "-p", str(pid), "-o", "command="],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return False
    command = result.stdout.strip()
    return (
        result.returncode == 0
        and script_path in command
        and pid_file_path in command
        and re.search(r"(?:^|\s)serve(?:\s|$)", command) is not None
    )


def stop_proxy(pid_file):
    path = Path(pid_file)
    try:
        raw_pid = path.read_text(encoding="utf-8").strip()
        pid = int(raw_pid)
    except (OSError, ValueError):
        path.unlink(missing_ok=True)
        return False
    if pid <= 1 or not _process_matches_helper(pid, path):
        path.unlink(missing_ok=True)
        return False
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        path.unlink(missing_ok=True)
        return False
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline and _process_matches_helper(pid, path):
        time.sleep(0.1)
    path.unlink(missing_ok=True)
    return True


def serve_proxy(node_version, pid_file):
    handler = make_proxy_handler(node_version)
    server = ThreadingHTTPServer((LISTEN_HOST, LISTEN_PORT), handler)
    server.daemon_threads = True
    server.allow_reuse_address = True
    pid_path = Path(pid_file)
    atomic_write(pid_path, f"{os.getpid()}\n")
    try:
        server.serve_forever(poll_interval=0.25)
    finally:
        server.server_close()
        try:
            if pid_path.read_text(encoding="utf-8").strip() == str(os.getpid()):
                pid_path.unlink()
        except OSError:
            pass


def main(argv=None):
    parser = argparse.ArgumentParser(description="GaiaNet's keyless Search MCP adapter")
    commands = parser.add_subparsers(dest="command", required=True)

    configure_parser = commands.add_parser("configure")
    configure_parser.add_argument("--config-file", required=True)
    configure_parser.add_argument("--mcp-config", required=True)

    set_provider_parser = commands.add_parser("set-provider")
    set_provider_parser.add_argument("--config-file", required=True)
    set_provider_parser.add_argument("--mcp-config", required=True)
    set_provider_parser.add_argument("--provider", choices=("none", "parallel"), required=True)

    serve_parser = commands.add_parser("serve")
    serve_parser.add_argument("--node-version", required=True)
    serve_parser.add_argument("--pid-file", required=True)

    stop_parser = commands.add_parser("stop")
    stop_parser.add_argument("--pid-file", required=True)

    arguments = parser.parse_args(argv)
    try:
        if arguments.command == "configure":
            provider = provider_from_config(arguments.config_file)
            configure_mcp_file(arguments.mcp_config, provider)
            print(provider)
        elif arguments.command == "set-provider":
            set_provider(arguments.config_file, arguments.mcp_config, arguments.provider)
        elif arguments.command == "serve":
            serve_proxy(arguments.node_version, arguments.pid_file)
        else:
            stop_proxy(arguments.pid_file)
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"parallel-search-mcp: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
