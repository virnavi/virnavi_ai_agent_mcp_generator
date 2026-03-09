## 0.0.1

Initial release.

- `McpModelGenerator` — generates an `ObjectSchema` from `@McpModel`-annotated classes. Respects `@McpField(description:, required:)` and `@JsonKey(name:)`.
- `McpServiceGenerator` — generates a `${ClassName}McpExtension` with a `mcpTools` getter from `@McpService`-annotated classes.
- `McpViewGenerator` — generates a `$WidgetNameMcpView` helper class with `definition` and `fromStore()` from `@McpView`-annotated widgets.
- `McpSummaryGenerator` — generates `$ClassNameMcpSummary` with `bindAll()` and `bindWithViews()` convenience statics from `@McpSummary`-annotated classes.
- Tool names follow the Spring Boot-style path convention: `packages/{package}/mcp/{servicePath}/{toolPath}`.
- `@McpTool(path:)` defaults to the snake_case method name when omitted.
- Return type handling: `@McpModel` → `.toJson()`, `List<@McpModel>` → `.map((e) => e.toJson()).toList()`, `@McpModel?` → `?.toJson()`.
- Generated files use the `.mcp.dart` extension to avoid conflicts with `json_serializable` (`.g.dart`).
- Cross-library schema access via public `$ClassNameMcpX` accessor classes with `definition` getters for use with `McpSummary`.
