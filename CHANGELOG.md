## 0.0.1-dev.1

Initial developer preview.

- `McpModelGenerator` — generates `ObjectSchema` from `@McpModel`-annotated classes. Respects `@McpField(description:, required:)` and `@JsonKey(name:)`.
- `McpServiceGenerator` — generates a `${ClassName}McpExtension` with a `mcpTools` getter from `@McpService`-annotated classes.
- Tool names follow the Spring Boot-style path convention: `packages/{package}/mcp/{servicePath}/{toolPath}`.
- `@McpTool(path:)` defaults to the snake_case method name when omitted.
- Return type handling: `@McpModel` → `.toJson()`, `List<@McpModel>` → `.map((e) => e.toJson()).toList()`, `@McpModel?` → `?.toJson()`.
- Generated files use the `.mcp.dart` extension to avoid conflicts with `json_serializable` (`.g.dart`).
- Cross-library schema access via public `$ClassNameMcpX` accessor classes.
