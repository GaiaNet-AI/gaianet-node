# test /v1/chat/completions endpoint
POST http://localhost:8080/v1/chat/completions
Accept: application/json
Content-Type: application/json
```json
{
    "messages": [
        {
            "role": "user",
            "content": "what is the location of Paris, France along the Seine river?"
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
