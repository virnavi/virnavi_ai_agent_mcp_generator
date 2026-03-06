import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:virnavi_ai_agent_mcp_generator/virnavi_ai_agent_mcp_generator.dart';

void main() {
  group('McpModelGenerator', () {
    test('generates private schema fn and public accessor for a simple model', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class Task {
  final String id;
  final String title;
  final bool completed;
  Task({required this.id, required this.title, required this.completed});
}
''',
        },
        outputs: {
          'pkg|lib/models.mcp.dart': allOf(
            contains('part of'),
            contains(r'_$TaskToMcpSchema'),
            contains(r'$TaskMcpX'),
            contains("'id': StringSchema()"),
            contains("'title': StringSchema()"),
            contains("'completed': BooleanSchema()"),
            contains("required: ['id', 'title', 'completed']"),
          ),
        },
      );
    });

    test('nullable fields are excluded from required list', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class CreateTaskInput {
  final String title;
  final String? description;
  CreateTaskInput({required this.title, this.description});
}
''',
        },
        outputs: {
          'pkg|lib/models.mcp.dart': allOf(
            contains("'title': StringSchema()"),
            contains("'description': StringSchema()"),
            contains("required: ['title']"),
          ),
        },
      );
    });

    test('@McpField description is included in schema', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class Profile {
  @McpField(description: 'Full display name')
  final String name;
  Profile({required this.name});
}
''',
        },
        outputs: {
          'pkg|lib/models.mcp.dart':
              contains("StringSchema(description: 'Full display name')"),
        },
      );
    });

    test('integer and boolean fields map to correct schema types', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class Stats {
  final int count;
  final double ratio;
  final bool active;
  Stats({required this.count, required this.ratio, required this.active});
}
''',
        },
        outputs: {
          'pkg|lib/models.mcp.dart': allOf(
            contains("'count': IntegerSchema()"),
            contains("'ratio': NumberSchema()"),
            contains("'active': BooleanSchema()"),
          ),
        },
      );
    });

    test('public accessor class has static schema() method', () async {
      await testBuilder(
        mcpBuilder(BuilderOptions.empty),
        {
          'pkg|lib/models.dart': '''
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.mcp.dart';

@McpModel()
class Item {
  final String id;
  Item({required this.id});
}
''',
        },
        outputs: {
          'pkg|lib/models.mcp.dart': allOf(
            contains(r'class $ItemMcpX'),
            contains(r'static ObjectSchema schema() => _$ItemToMcpSchema()'),
          ),
        },
      );
    });
  });
}
