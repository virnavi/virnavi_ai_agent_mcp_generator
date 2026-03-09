import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:virnavi_ai_agent_mcp_generator/virnavi_ai_agent_mcp_generator.dart';

/// Minimal annotation stubs for the test virtual package.
/// TypeChecker.typeNamed matches by class name only, so these work
/// without importing virnavi_ai_agent_mcp.
const _stubs = '''
class McpModel { const McpModel(); }
class McpField {
  final String? description;
  final bool? required;
  const McpField({this.description, this.required});
}
class McpService {
  final String path;
  const McpService({required this.path});
}
class McpTool {
  final String? path;
  final String description;
  const McpTool({this.path, required this.description});
}
class McpParam {
  final String description;
  final bool required;
  const McpParam({required this.description, this.required = true});
}
''';

void main() {
  group('McpServiceGenerator', () {
    test('generates extension with mcpTools getter', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
part 'service.mcp.dart';

$_stubs

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'list', description: 'List all tasks.')
  Future<List<Map<String, dynamic>>> listTasks() async => [];
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/service.mcp.dart': decodedMatches(allOf(
            contains('extension TaskServiceMcpExtension on TaskService'),
            contains('List<ToolDefinition> get mcpTools'),
            contains('packages/pkg/mcp/tasks/list'),
            contains("description: 'List all tasks.'"),
          )),
        },
      );
    });

    test('tool path defaults to snake_case method name when not set', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
part 'service.mcp.dart';

$_stubs

@McpService(path: 'items')
class ItemService {
  @McpTool(description: 'Get an item by ID.')
  Future<Map<String, dynamic>> getItemById(
    @McpParam(description: 'The item ID') String id,
  ) async => {};
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/service.mcp.dart': decodedMatches(
            contains('packages/pkg/mcp/items/get_item_by_id'),
          ),
        },
      );
    });

    test('@McpParam description is used in inline ObjectSchema', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
part 'service.mcp.dart';

$_stubs

@McpService(path: 'users')
class UserService {
  @McpTool(path: 'get', description: 'Get user.')
  Future<Map<String, dynamic>> getUser(
    @McpParam(description: 'User ID') String id,
  ) async => {};
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/service.mcp.dart': decodedMatches(
            contains("StringSchema(description: 'User ID')"),
          ),
        },
      );
    });

    test('no-param tool gets empty ObjectSchema()', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
part 'service.mcp.dart';

$_stubs

@McpService(path: 'stats')
class StatsService {
  @McpTool(path: 'summary', description: 'Return stats.')
  Future<Map<String, dynamic>> summary() async => {};
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/service.mcp.dart': decodedMatches(
            contains('inputSchema: ObjectSchema()'),
          ),
        },
      );
    });

    test('handler awaits async methods', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
part 'service.mcp.dart';

$_stubs

@McpService(path: 'ping')
class PingService {
  @McpTool(path: 'ping', description: 'Ping.')
  Future<bool> ping() async => true;
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/service.mcp.dart': decodedMatches(
            contains('await ping()'),
          ),
        },
      );
    });

    test('@McpModel return type uses .toJson()', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
part 'models.mcp.dart';

$_stubs

@McpModel()
class Task {
  final String id;
  Task({required this.id});
  Map<String, dynamic> toJson() => {'id': id};
  factory Task.fromJson(Map<String, dynamic> j) => Task(id: j['id'] as String);
}
''',
          'pkg|lib/models.mcp.dart': "part of 'models.dart';\n",
          'pkg|lib/service.dart': '''
import 'models.dart';

part 'service.mcp.dart';

$_stubs

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'get', description: 'Get a task.')
  Future<Task> getTask(
    @McpParam(description: 'ID') String id,
  ) async => Task(id: id);
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/models.mcp.dart': anything,
          'pkg|lib/service.mcp.dart': decodedMatches(
            contains('result.toJson()'),
          ),
        },
      );
    });

    test('List<@McpModel> return type uses .map((e) => e.toJson())', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
part 'models.mcp.dart';

$_stubs

@McpModel()
class Task {
  final String id;
  Task({required this.id});
  Map<String, dynamic> toJson() => {'id': id};
}
''',
          'pkg|lib/models.mcp.dart': "part of 'models.dart';\n",
          'pkg|lib/service.dart': '''
import 'models.dart';

part 'service.mcp.dart';

$_stubs

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'list', description: 'List tasks.')
  Future<List<Task>> listTasks() async => [];
}
''',
          'pkg|lib/service.mcp.dart': "part of 'service.dart';\n",
        },
        outputs: {
          'pkg|lib/models.mcp.dart': anything,
          'pkg|lib/service.mcp.dart': decodedMatches(
            contains('result.map((e) => e.toJson()).toList()'),
          ),
        },
      );
    });
  });
}
