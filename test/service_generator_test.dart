import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:virnavi_ai_agent_mcp_generator/virnavi_ai_agent_mcp_generator.dart';

void main() {
  group('McpServiceGenerator', () {
    test('generates extension with mcpTools getter', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'service.mcp.dart';

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'list', description: 'List all tasks.')
  Future<List<Map<String, dynamic>>> listTasks() async => [];
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart': allOf(
            contains('extension TaskServiceMcpExtension on TaskService'),
            contains('List<ToolDefinition> get mcpTools'),
            contains('packages/pkg/mcp/tasks/list'),
            contains("description: 'List all tasks.'"),
          ),
        },
      );
    });

    test('tool path defaults to snake_case method name when not set', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'service.mcp.dart';

@McpService(path: 'items')
class ItemService {
  @McpTool(description: 'Get an item by ID.')
  Future<Map<String, dynamic>> getItemById(
    @McpParam(description: 'The item ID') String id,
  ) async => {};
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart':
              contains('packages/pkg/mcp/items/get_item_by_id'),
        },
      );
    });

    test('@McpParam description is used in inline ObjectSchema', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'service.mcp.dart';

@McpService(path: 'users')
class UserService {
  @McpTool(path: 'get', description: 'Get user.')
  Future<Map<String, dynamic>> getUser(
    @McpParam(description: 'User ID') String id,
  ) async => {};
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart':
              contains("StringSchema(description: 'User ID')"),
        },
      );
    });

    test('no-param tool gets empty ObjectSchema()', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'service.mcp.dart';

@McpService(path: 'stats')
class StatsService {
  @McpTool(path: 'summary', description: 'Return stats.')
  Future<Map<String, dynamic>> summary() async => {};
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart': contains('inputSchema: ObjectSchema()'),
        },
      );
    });

    test('handler awaits async methods', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'service.mcp.dart';

@McpService(path: 'ping')
class PingService {
  @McpTool(path: 'ping', description: 'Ping.')
  Future<bool> ping() async => true;
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart': contains('await ping()'),
        },
      );
    });

    test('@McpModel return type uses .toJson()', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class Task {
  final String id;
  Task({required this.id});
  Map<String, dynamic> toJson() => {'id': id};
  factory Task.fromJson(Map<String, dynamic> j) => Task(id: j['id'] as String);
}
''',
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';
import 'models.dart';

part 'service.mcp.dart';

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'get', description: 'Get a task.')
  Future<Task> getTask(
    @McpParam(description: 'ID') String id,
  ) async => Task(id: id);
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart': contains('result.toJson()'),
        },
      );
    });

    test('List<@McpModel> return type uses .map((e) => e.toJson())', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class Task {
  final String id;
  Task({required this.id});
  Map<String, dynamic> toJson() => {'id': id};
}
''',
          'pkg|lib/service.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';
import 'models.dart';

part 'service.mcp.dart';

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'list', description: 'List tasks.')
  Future<List<Task>> listTasks() async => [];
}
''',
        },
        outputs: {
          'pkg|lib/service.mcp.dart':
              contains('result.map((e) => e.toJson()).toList()'),
        },
      );
    });
  });
}
