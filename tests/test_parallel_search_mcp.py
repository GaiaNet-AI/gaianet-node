import http.client
import json
import os
import shutil
import subprocess
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch

from utils import parallel_search_mcp


MCP_CONFIG = '''[server]
chat_mode = "normal"

[[mcp.server.tool]]
name = "cardea-agentic-search"
transport = "stream-http"
url = "http://127.0.0.1:8009/mcp"
enable = true

[[mcp.server.tool]]
name = "cardea-web-search"
transport = "stream-http"
url = "http://127.0.0.1:8010/mcp"
enable = false
'''


class ConfigTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.config_path = self.root / "config.json"
        self.mcp_path = self.root / "mcp_config.toml"
        self.config_path.write_text('{\n    "address": "node-id"\n}\n', encoding="utf-8")
        self.mcp_path.write_text(MCP_CONFIG, encoding="utf-8")

    def test_parallel_selection_is_idempotent_and_preserves_local_rag(self):
        parallel_search_mcp.set_provider(self.config_path, self.mcp_path, "parallel")
        first = self.mcp_path.read_text(encoding="utf-8")
        parallel_search_mcp.set_provider(self.config_path, self.mcp_path, "parallel")
        second = self.mcp_path.read_text(encoding="utf-8")

        self.assertEqual(first, second)
        self.assertEqual(first.count('name = "parallel-search"'), 1)
        self.assertIn('url = "http://127.0.0.1:8012/mcp"', first)
        self.assertIn('name = "cardea-agentic-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8009/mcp"\nenable = true', first)
        self.assertIn('name = "cardea-web-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8010/mcp"\nenable = false', first)
        self.assertEqual(json.loads(self.config_path.read_text())['web_search_provider'], 'parallel')

    def test_none_disables_only_web_search_entries(self):
        parallel_search_mcp.set_provider(self.config_path, self.mcp_path, "parallel")
        parallel_search_mcp.set_provider(self.config_path, self.mcp_path, "none")
        text = self.mcp_path.read_text(encoding="utf-8")

        self.assertIn('name = "parallel-search"', text)
        parallel_block = text[text.index('name = "parallel-search"'):]
        self.assertIn('enable = false', parallel_block)
        self.assertIn('name = "cardea-agentic-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8009/mcp"\nenable = true', text)
        self.assertEqual(json.loads(self.config_path.read_text())['web_search_provider'], 'none')

    def test_default_none_adds_no_parallel_server(self):
        configured = parallel_search_mcp.configure_mcp_text(MCP_CONFIG, "none")

        self.assertNotIn('name = "parallel-search"', configured)
        self.assertIn('name = "cardea-agentic-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8009/mcp"\nenable = true', configured)
        self.assertIn('name = "cardea-web-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8010/mcp"\nenable = false', configured)

    def test_legacy_config_preserves_existing_provider_entries(self):
        existing = MCP_CONFIG.replace('enable = false\n', 'enable = true\n')
        existing += (
            '\n[[mcp.server.tool]]\n'
            f'{parallel_search_mcp.MANAGED_MARKER}\n'
            'name = "parallel-search"\n'
            'transport = "stream-http"\n'
            f'url = "{parallel_search_mcp.LOCAL_URL}"\n'
            'enable = true\n'
        )

        configured = parallel_search_mcp.configure_mcp_text(existing, "legacy")

        parallel_block = configured[configured.index('name = "parallel-search"'):]
        self.assertIn('enable = false', parallel_block)
        self.assertIn('name = "cardea-web-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8010/mcp"\nenable = true', configured)
        self.assertIn('name = "cardea-agentic-search"\ntransport = "stream-http"\nurl = "http://127.0.0.1:8009/mcp"\nenable = true', configured)

    def test_parallel_selection_refuses_unmanaged_name_collision(self):
        custom = MCP_CONFIG + (
            '\n[[mcp.server.tool]]\n'
            'name = "parallel-search"\n'
            'transport = "stream-http"\n'
            'url = "http://127.0.0.1:9000/mcp"\n'
            'enable = true\n'
        )

        with self.assertRaisesRegex(ValueError, "unmanaged"):
            parallel_search_mcp.configure_mcp_text(custom, "parallel")

    def test_none_refuses_to_leave_an_unmanaged_parallel_server_enabled(self):
        custom = MCP_CONFIG + (
            '\n[[mcp.server.tool]]\n'
            'name = "parallel-search"\n'
            'transport = "stream-http"\n'
            'url = "http://127.0.0.1:9000/mcp"\n'
            'enable = true\n'
        )

        with self.assertRaisesRegex(ValueError, "disable or rename"):
            parallel_search_mcp.configure_mcp_text(custom, "none")

    def test_gaianet_config_command_selects_parallel(self):
        home = self.root / "home"
        base = self.root / "gaianet"
        (home / ".wasmedge").mkdir(parents=True)
        (home / ".wasmedge" / "env").write_text("", encoding="utf-8")
        base.mkdir()
        self.config_path = base / "config.json"
        self.mcp_path = base / "mcp_config.toml"
        self.config_path.write_text('{\n    "address": "node-id"\n}\n', encoding="utf-8")
        self.mcp_path.write_text(MCP_CONFIG, encoding="utf-8")
        repo_root = Path(__file__).resolve().parents[1]
        environment = {"HOME": str(home), "PATH": os.environ["PATH"]}

        result = subprocess.run(
            [
                "bash",
                str(repo_root / "gaianet"),
                "config",
                "--web-search-provider",
                "parallel",
                "--base",
                str(base),
            ],
            cwd=repo_root,
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertEqual(
            json.loads(self.config_path.read_text(encoding="utf-8"))["web_search_provider"],
            "parallel",
        )
        configured = self.mcp_path.read_text(encoding="utf-8")
        self.assertIn('name = "parallel-search"', configured)
        self.assertIn('url = "http://127.0.0.1:8012/mcp"', configured)

    def test_installed_gaianet_uses_bundled_parallel_helper(self):
        home = self.root / "installed-home"
        base = home / "gaianet"
        bin_dir = base / "bin"
        bin_dir.mkdir(parents=True)
        wasmedge = home / ".wasmedge"
        wasmedge.mkdir()
        (wasmedge / "env").write_text("", encoding="utf-8")
        config_path = base / "config.json"
        mcp_path = base / "mcp_config.toml"
        config_path.write_text('{\n    "address": "node-id"\n}\n', encoding="utf-8")
        mcp_path.write_text(MCP_CONFIG, encoding="utf-8")
        repo_root = Path(__file__).resolve().parents[1]
        shutil.copyfile(repo_root / "gaianet", bin_dir / "gaianet")
        shutil.copyfile(
            repo_root / "utils" / "parallel_search_mcp.py",
            bin_dir / "parallel_search_mcp.py",
        )
        environment = {"HOME": str(home), "PATH": os.environ["PATH"]}

        result = subprocess.run(
            [
                "bash",
                str(bin_dir / "gaianet"),
                "config",
                "--web-search-provider",
                "parallel",
                "--base",
                str(base),
            ],
            cwd=home,
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertEqual(
            json.loads(config_path.read_text(encoding="utf-8"))["web_search_provider"],
            "parallel",
        )
        self.assertIn('url = "http://127.0.0.1:8012/mcp"', mcp_path.read_text())


class UpstreamHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    requests = []
    response_mode = "sse"
    redirect_target = ""

    def log_message(self, format_string, *args):
        return

    def _capture(self):
        length = int(self.headers.get("Content-Length", "0"))
        self.server.requests.append(
            {
                "method": self.command,
                "path": self.path,
                "headers": {name.lower(): value for name, value in self.headers.items()},
                "body": self.rfile.read(length) if length else b"",
            }
        )
        if self.server.response_mode == "redirect":
            self.send_response(302)
            self.send_header("Location", self.server.redirect_target)
            self.send_header("Content-Length", "0")
            self.end_headers()
        elif self.server.response_mode == "unauthorized":
            body = b"authentication required"
            self.send_response(401)
            self.send_header("WWW-Authenticate", "Bearer")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif self.server.response_mode == "initialize":
            body = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "id": 0,
                    "result": {
                        "protocolVersion": "2025-03-26",
                        "capabilities": {"tools": {}},
                        "serverInfo": {
                            "name": "Parallel Web Search MCP Server",
                            "version": "1.27.0",
                            "websiteUrl": "https://parallel.ai",
                            "icons": [
                                {
                                    "src": "https://parallel.ai/icon.png",
                                    "sizes": ["270x270", "540x540"],
                                }
                            ],
                        },
                        "instructions": "Search tools for an agent.",
                    },
                }
            ).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif self.server.response_mode == "tools/list":
            body = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "id": 1,
                    "result": {
                        "tools": [
                            {
                                "name": "web_search",
                                "inputSchema": {"type": "object"},
                                "outputSchema": {
                                    "$defs": {},
                                    "properties": {"results": {"type": "array"}},
                                    "required": ["results"],
                                    "title": "SearchOutput",
                                    "type": "object",
                                },
                                "annotations": {"readOnlyHint": True},
                                "icons": [
                                    {
                                        "src": "https://parallel.ai/search.png",
                                        "sizes": ["32x32", "64x64"],
                                    },
                                    {
                                        "src": "https://parallel.ai/search.svg",
                                        "sizes": [],
                                    },
                                ],
                            }
                        ]
                    },
                }
            ).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            parts = (b"event: message\ndata: {\"result\":", b"\"useful\"}\n\n")
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Mcp-Session-Id", "session-456")
            self.send_header("Transfer-Encoding", "chunked")
            self.end_headers()
            for part in parts:
                self.wfile.write(f"{len(part):X}\r\n".encode() + part + b"\r\n")
                self.wfile.flush()
            self.wfile.write(b"0\r\n\r\n")
            self.wfile.flush()

    do_GET = _capture
    do_POST = _capture
    do_DELETE = _capture


class SinkHandler(BaseHTTPRequestHandler):
    hits = 0

    def log_message(self, format_string, *args):
        return

    def do_GET(self):
        type(self).hits += 1
        self.send_response(200)
        self.send_header("Content-Length", "0")
        self.end_headers()


class ProxyTests(unittest.TestCase):
    def setUp(self):
        UpstreamHandler.requests = []
        UpstreamHandler.response_mode = "sse"
        SinkHandler.hits = 0
        self.upstream = ThreadingHTTPServer(("127.0.0.1", 0), UpstreamHandler)
        self.upstream.requests = UpstreamHandler.requests
        self.upstream.response_mode = UpstreamHandler.response_mode
        self.upstream.redirect_target = UpstreamHandler.redirect_target
        self.addCleanup(self.upstream.server_close)
        self.upstream_thread = threading.Thread(target=self.upstream.serve_forever, daemon=True)
        self.upstream_thread.start()
        self.addCleanup(self.upstream.shutdown)
        self.sink = ThreadingHTTPServer(("127.0.0.1", 0), SinkHandler)
        self.addCleanup(self.sink.server_close)
        self.sink_thread = threading.Thread(target=self.sink.serve_forever, daemon=True)
        self.sink_thread.start()
        self.addCleanup(self.sink.shutdown)
        upstream_host, upstream_port = self.upstream.server_address
        self.connection_factory = lambda host, timeout: http.client.HTTPConnection(
            upstream_host, upstream_port, timeout=timeout
        )
        handler = parallel_search_mcp.make_proxy_handler(
            "0.6.0", connection_factory=self.connection_factory
        )
        self.proxy = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        self.addCleanup(self.proxy.server_close)
        self.proxy_thread = threading.Thread(target=self.proxy.serve_forever, daemon=True)
        self.proxy_thread.start()
        self.addCleanup(self.proxy.shutdown)

    def _request(self, method, path="/mcp", body=None, headers=None):
        client = http.client.HTTPConnection(*self.proxy.server_address, timeout=3)
        try:
            client.request(method, path, body=body, headers=headers or {})
            return client.getresponse()
        finally:
            self.addCleanup(client.close)

    def test_streaming_preserves_protocol_and_client_identity_without_auth(self):
        tool_calls = (
            b'{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"web_search","arguments":{"query":"test query"}}}',
            b'{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"web_fetch","arguments":{"url":"https://example.com"}}}',
        )
        headers = {
            "Accept": "application/json, text/event-stream",
            "Content-Type": "application/json",
            "MCP-Protocol-Version": "2025-03-26",
            "Mcp-Session-Id": "session-123",
            "Last-Event-ID": "event-9",
            "User-Agent": "rmcp/0.1.0",
            "Authorization": "Bearer must-not-leak",
            "Cookie": "secret=must-not-leak",
            "X-API-Key": "must-not-leak",
        }
        with patch.dict(os.environ, {"PARALLEL_API_KEY": "must-not-leak"}):
            responses = []
            for body in tool_calls:
                response = self._request("POST", body=body, headers=headers)
                response_body = response.read()
                responses.append((response, response_body))

        for response, response_body in responses:
            self.assertEqual(response.status, 200)
            self.assertEqual(response.getheader("Content-Type"), "text/event-stream")
            self.assertEqual(response.getheader("Mcp-Session-Id"), "session-456")
            self.assertIn(b'"useful"', response_body)

        self.assertEqual(len(self.upstream.requests), len(tool_calls))
        for captured, body in zip(self.upstream.requests, tool_calls):
            self.assertEqual(captured["path"], "/mcp")
            self.assertEqual(captured["body"], body)
            self.assertEqual(captured["headers"]["mcp-session-id"], "session-123")
            self.assertEqual(captured["headers"]["mcp-protocol-version"], "2025-03-26")
            self.assertEqual(captured["headers"]["last-event-id"], "event-9")
            self.assertEqual(
                captured["headers"]["user-agent"], "GaiaNet-Node/0.6.0 rmcp/0.1.0"
            )
            self.assertFalse(
                {"authorization", "cookie", "x-api-key"}.intersection(captured["headers"])
            )

    def test_initialize_icon_sizes_are_normalized_for_gaia_nexus(self):
        self.upstream.response_mode = "initialize"
        request_body = json.dumps(
            {
                "jsonrpc": "2.0",
                "id": 0,
                "method": "initialize",
                "params": {"protocolVersion": "2025-03-26"},
            }
        ).encode()

        response = self._request(
            "POST",
            body=request_body,
            headers={
                "Accept": "application/json, text/event-stream",
                "Content-Type": "application/json",
            },
        )
        response_body = response.read()
        result = json.loads(response_body)["result"]

        self.assertEqual(result["serverInfo"]["icons"][0]["sizes"], "270x270 540x540")
        self.assertEqual(response.getheader("Content-Length"), str(len(response_body)))
        self.assertEqual(self.upstream.requests[0]["body"], request_body)

    def test_tools_list_icon_sizes_are_normalized_without_changing_tool_schemas(self):
        self.upstream.response_mode = "tools/list"
        request_body = json.dumps(
            {"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}
        ).encode()

        response = self._request(
            "POST",
            body=request_body,
            headers={
                "Accept": "application/json, text/event-stream",
                "Content-Type": "application/json",
            },
        )
        response_body = response.read()
        tool = json.loads(response_body)["result"]["tools"][0]

        self.assertEqual(tool["icons"][0]["sizes"], "32x32 64x64")
        self.assertNotIn("sizes", tool["icons"][1])
        self.assertEqual(
            tool["outputSchema"],
            {
                "$defs": {},
                "properties": {"results": {"type": "array"}},
                "required": ["results"],
                "title": "SearchOutput",
                "type": "object",
            },
        )
        self.assertEqual(tool["annotations"], {"readOnlyHint": True})
        self.assertEqual(response.getheader("Content-Length"), str(len(response_body)))
        self.assertEqual(self.upstream.requests[0]["body"], request_body)

    def test_streamable_http_get_and_delete_preserve_session_headers(self):
        get_response = self._request(
            "GET",
            headers={
                "Accept": "text/event-stream",
                "Mcp-Session-Id": "session-123",
                "Last-Event-ID": "event-9",
            },
        )
        self.assertEqual(get_response.status, 200)
        self.assertIn(b"event: message", get_response.read())

        delete_response = self._request(
            "DELETE", headers={"Mcp-Session-Id": "session-123"}
        )
        self.assertEqual(delete_response.status, 200)
        delete_response.read()

        self.assertEqual(
            [request["method"] for request in self.upstream.requests], ["GET", "DELETE"]
        )
        self.assertEqual(self.upstream.requests[0]["headers"]["mcp-session-id"], "session-123")
        self.assertEqual(self.upstream.requests[0]["headers"]["last-event-id"], "event-9")
        self.assertEqual(self.upstream.requests[1]["headers"]["mcp-session-id"], "session-123")

    def test_redirect_is_rejected_without_contacting_location(self):
        UpstreamHandler.response_mode = "redirect"
        sink_host, sink_port = self.sink.server_address
        self.upstream.redirect_target = f"http://{sink_host}:{sink_port}/collect"
        self.upstream.response_mode = "redirect"
        response = self._request("POST", body=b"{}")

        self.assertEqual(response.status, 502)
        self.assertEqual(SinkHandler.hits, 0)
        self.assertEqual(len(self.upstream.requests), 1)

    def test_query_string_is_rejected_before_upstream(self):
        response = self._request("GET", "/mcp?query=private")

        self.assertEqual(response.status, 400)
        self.assertEqual(self.upstream.requests, [])

    def test_upstream_authentication_error_is_not_retried_anonymously(self):
        UpstreamHandler.response_mode = "unauthorized"
        self.upstream.response_mode = "unauthorized"
        response = self._request("POST", body=b"{}")
        body = response.read()

        self.assertEqual(response.status, 401)
        self.assertEqual(response.getheader("WWW-Authenticate"), "Bearer")
        self.assertEqual(body, b"authentication required")
        self.assertEqual(len(self.upstream.requests), 1)


if __name__ == "__main__":
    unittest.main()
