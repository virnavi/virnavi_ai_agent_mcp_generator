## 0.0.3

### New features

- **Nested model auto-registration**: when an `@McpModel` class has fields of another `@McpModel` type (or `List<@McpModel>`), the generated `definition` now includes `nestedDefinitions` and `nestedExtractors`. `McpSummary.bind()` registers all nested definitions automatically; the compose layer uses `nestedExtractors` to propagate nested data into `McpResultStore`.
- **`void` return type**: `Future<void>` tool methods now generate a handler that calls the method and returns `ToolResult.success(null)` without capturing a result.

### Requires

- `virnavi_ai_agent_mcp: ^0.0.3` (adds `McpModelDefinition.nestedDefinitions`, `nestedExtractors`, and `McpSummary.bindViews` stub).

---

## 0.0.2

### Bug fixes

- **Named parameters**: handler now emits `name: value` syntax for named parameters instead of positional arguments.
- **Optional named parameters**: parameters with a default value are no longer included in the `required` list of the generated `ObjectSchema`.
- **String escaping**: apostrophes in `@McpTool`, `@McpParam`, and `@McpField` descriptions are now escaped correctly in generated single-quoted string literals.
- **`bindWithViews`**: `McpSummary` now has a `bindViews()` method; the generated `bindWithViews()` correctly chains it instead of emitting a compile error.
- **`dynamic` parameters**: `dynamic`-typed parameters pass through without a cast; `dynamic` fields map to `ObjectSchema()`.

- **`@JsonKey(toJson:/fromJson:)` type inference**: when a field uses `@JsonKey(toJson: fn)`, the schema is derived from `fn`'s return type instead of the Dart field type. When only `fromJson:` is specified, the schema is derived from its first parameter type. This correctly handles custom serializers (e.g. a `DateTime` field with an ISO-8601 `toJson` generates `StringSchema` instead of `IntegerSchema`).
- **Example app**: added `example/` covering every supported annotation option, field type, parameter combination, and return type variant.

### New type support

- **Enums**: enum parameters and fields now generate `StringSchema(enumValues: [...])` using `@JsonValue` annotation values when present, falling back to the Dart field name. Handler decoding uses a `const {...}` reverse-lookup map when `@JsonValue` is in use, or `.values.byName()` otherwise. Nullable enum parameters include a null-check guard.
- **`DateTime`**: maps to `IntegerSchema` (milliseconds since epoch UTC) in the schema; handler decodes via `DateTime.fromMillisecondsSinceEpoch(args['x'] as int, isUtc: true)`.
- **`DateTimeRange`**: maps to `ObjectSchema` with `{start: IntegerSchema, end: IntegerSchema}` properties and `required: ['start', 'end']`.
- **`void` return type**: `Future<void>` tool methods now compile correctly — the handler calls the method and returns `ToolResult.success(null)` without capturing a result.

### Nested model auto-registration

- When an `@McpModel` class contains fields of another `@McpModel` type (directly or as `List<T>`), the generated `$ClassNameMcpX.definition` now includes a `nestedDefinitions` list referencing the inner model's definition. `McpSummary.bind()` recursively registers all nested definitions automatically, so callers never need to list nested models explicitly in `bindAll`.

---

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
