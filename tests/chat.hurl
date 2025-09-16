# test /v1/models endpoint
GET http://localhost:8080/v1/models
screencapability: low
HTTP 200
[Asserts]
jsonpath "$.data[0].id" matches "^(Qwen3-4B|Nomic-embed-text-v1.5)$"

# test /v1/chat/completions endpoint
POST http://localhost:8080/v1/chat/completions
Accept: application/json
Content-Type: application/json
```json
{
    "messages": [
        {
            "role": "user",
            "content": "What is the capital of France?"
        }
    ],
    "model": "Qwen3-4B",
    "stream": false
}
```
HTTP 200
[Asserts]
jsonpath "$.model" == "Qwen3-4B"
jsonpath "$.choices[0].message.content" contains "Paris"


# test /v1/chat/completions endpoint
# Test purpose: The model name is incorrect
POST http://localhost:8080/v1/chat/completions
Accept: application/json
Content-Type: application/json
```json
{
    "messages": [
        {
            "role": "user",
            "content": "What is the capital of France?"
        }
    ],
    "model": "Qwen3-4B-Instruct-invalid",
    "stream": false
}
```
HTTP 200
[Asserts]
jsonpath "$.model" == "Qwen3-4B"
jsonpath "$.choices[0].message.content" contains "Paris"