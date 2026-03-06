# virnavi_ai_agent_mcp_generator

Build-time code generator for [virnavi_ai_agent_mcp](https://pub.dev/packages/virnavi_ai_agent_mcp).

Generates MCP tool definitions and JSON schemas from `@McpModel` and `@McpService` annotations — no boilerplate needed.

## Features

- `@McpModel` → generates an `ObjectSchema` from class fields, with optional `@McpField` descriptions and `@JsonKey(name:)` support.
- `@McpService` + `@McpTool` → generates a `${ClassName}McpExtension` with a `mcpTools` getter ready to pass to `AgentBridge`.
- Tool names follow the Spring Boot-style convention: `packages/{package}/mcp/{servicePath}/{toolPath}`.
- Return type handling: `@McpModel` → `.toJson()`, `List<@McpModel>` → `.map((e) => e.toJson()).toList()`, `@McpModel?` → `?.toJson()`.
- Generated files use `.mcp.dart` extension — no conflicts with `json_serializable` (`.g.dart`).

## Getting started

Add to `pubspec.yaml`:

```yaml
dependencies:
  virnavi_ai_agent_mcp: ^0.0.1-dev.1

dev_dependencies:
  build_runner: ^2.4.0
  virnavi_ai_agent_mcp_generator: ^0.0.1-dev.1
```

## Usage

### 1. Annotate your model

```dart
// models.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.g.dart';    // json_serializable
part 'models.mcp.dart';  // this generator

@McpModel()
@JsonSerializable()
class Task {
  final String id;

  @McpField(description: 'Short title for the task')
  final String title;

  final bool completed;

  const Task({required this.id, required this.title, required this.completed});

  factory Task.fromJson(Map<String, dynamic> j) => _$TaskFromJson(j);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
```

### 2. Annotate your service

```dart
// task_service.dart
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';
import 'models.dart';

part 'task_service.mcp.dart';

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'list', description: 'Returns all tasks.')
  Future<List<Task>> listTasks() async => repo.getAll();

  @McpTool(path: 'create', description: 'Creates a new task.')
  Future<Task> createTask(CreateTaskInput input) async => repo.add(input);

  @McpTool(path: 'complete', description: 'Marks a task as completed.')
  Future<bool> completeTask(
    @McpParam(description: 'The task ID') String id,
  ) async => repo.complete(id);
}
```

### 3. Run the generator

```bash
dart run build_runner build
```

This generates `models.mcp.dart` and `task_service.mcp.dart`.

### 4. Register tools in main()

```dart
final service = TaskService(repo);

for (final tool in service.mcpTools) {
  AgentBridge.instance.registerTool(tool);
}
```

## Generated tool name format

```
packages/{package_name}/mcp/{servicePath}/{toolPath}
```

For example, `@McpService(path: 'tasks')` + `@McpTool(path: 'list')` in `my_app` produces:

```
packages/my_app/mcp/tasks/list
```

If `@McpTool(path:)` is omitted, the method name is converted to snake_case automatically.

## Annotations

| Annotation | Target | Description |
|---|---|---|
| `@McpModel()` | class | Generates an `ObjectSchema` for the class |
| `@McpField(description:, required:)` | field | Adds description; overrides nullability-based required inference |
| `@McpService(path:)` | class | Marks a class as an MCP service with a base path |
| `@McpTool(path:, description:)` | method | Registers the method as an MCP tool |
| `@McpParam(description:, required:)` | parameter | Describes an individual tool parameter |

## License

MIT — see [LICENSE](LICENSE).
