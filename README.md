# virnavi_ai_agent_mcp_generator

Build-time code generator for [virnavi_ai_agent_mcp](https://pub.dev/packages/virnavi_ai_agent_mcp).

Generates MCP tool definitions, JSON schemas, view helpers, and summary registries from annotations — no boilerplate needed.

## Features

- `@McpModel` → generates an `ObjectSchema` from class fields, with optional `@McpField` descriptions and `@JsonKey(name:)` support. Includes a `definition` getter for use with `McpSummary`.
- `@McpService` + `@McpTool` → generates a `${ClassName}McpExtension` with a `mcpTools` getter ready to pass to `AgentBridge`.
- `@McpView` → generates a `$WidgetNameMcpView` helper with `definition` and `fromStore()` for reactive UI binding.
- `@McpSummary` → generates a `$ClassNameMcpSummary` with `bindAll()` and `bindWithViews()` convenience statics that wire up all tools, model definitions, and view definitions in one call.
- Tool names follow the Spring Boot-style convention: `packages/{package}/mcp/{servicePath}/{toolPath}`.
- Return type handling: `@McpModel` → `.toJson()`, `List<@McpModel>` → `.map((e) => e.toJson()).toList()`, `@McpModel?` → `?.toJson()`.
- Generated files use `.mcp.dart` extension — no conflicts with `json_serializable` (`.g.dart`).

## Getting started

Add to `pubspec.yaml`:

```yaml
dependencies:
  virnavi_ai_agent_mcp: ^0.0.1

dev_dependencies:
  build_runner: ^2.4.0
  virnavi_ai_agent_mcp_generator: ^0.0.1
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

### 3. Annotate your result widget (optional)

```dart
// task_card.dart
import 'package:flutter/material.dart';
import 'package:virnavi_ai_agent_compose/virnavi_ai_agent_compose.dart';
import 'models.dart';

part 'task_card.mcp.dart';

@McpView(modelType: Task)
class TaskCard extends StatelessWidget {
  final Task result;
  const TaskCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(result.title));
  }
}
```

### 4. Create a summary class (optional)

```dart
// app_summary.dart
import 'package:virnavi_ai_agent_compose/virnavi_ai_agent_compose.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';
import 'task_card.dart';
import 'models.dart';

part 'app_summary.mcp.dart';

@McpSummary()
class AppSummary {}
```

### 5. Run the generator

```bash
dart run build_runner build
```

### 6. Register tools and wire up the summary

```dart
final service = TaskService(repo);
// Wire up all tools, model deserializers, and view builders in one call:
final summary = $AppSummaryMcpSummary.bindWithViews(service.mcpTools);
summary.tools.values.toList().registerWith(bridge, binding);
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
| `@McpModel()` | class | Generates an `ObjectSchema` and a `definition` getter for the class |
| `@McpField(description:, required:)` | field | Adds description; overrides nullability-based required inference |
| `@McpService(path:)` | class | Marks a class as an MCP service with a base path |
| `@McpTool(path:, description:)` | method | Registers the method as an MCP tool |
| `@McpParam(description:, required:)` | parameter | Describes an individual tool parameter |
| `@McpView(modelType:)` | widget class | Generates a view helper with a `definition` getter |
| `@McpSummary()` | class | Generates `bindAll()` and `bindWithViews()` for the entire package |

## License

MIT — see [LICENSE](LICENSE).
