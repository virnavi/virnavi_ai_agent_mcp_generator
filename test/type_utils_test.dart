import 'package:test/test.dart';
import 'package:virnavi_ai_agent_mcp_generator/src/type_utils.dart';

void main() {
  group('toSnakeCase', () {
    test('camelCase to snake_case', () {
      expect(toSnakeCase('listTasks'), 'list_tasks');
      expect(toSnakeCase('createTask'), 'create_task');
      expect(toSnakeCase('getById'), 'get_by_id');
    });

    test('PascalCase to snake_case', () {
      expect(toSnakeCase('TaskService'), 'task_service');
      expect(toSnakeCase('CreateTaskInput'), 'create_task_input');
    });

    test('already snake_case is unchanged', () {
      expect(toSnakeCase('list'), 'list');
      expect(toSnakeCase('get'), 'get');
    });

    test('single word lowercase is unchanged', () {
      expect(toSnakeCase('stats'), 'stats');
    });

    test('consecutive capitals', () {
      expect(toSnakeCase('getHTTPResponse'), 'get_h_t_t_p_response');
    });
  });

  group('privateSchemaFnName', () {
    test('wraps class name with _\$ prefix and ToMcpSchema suffix', () {
      expect(privateSchemaFnName('Task'), r'_$TaskToMcpSchema');
      expect(privateSchemaFnName('CreateTaskInput'), r'_$CreateTaskInputToMcpSchema');
    });
  });

  group('publicSchemaAccessorName', () {
    test('wraps class name with \$ prefix and McpX suffix', () {
      expect(publicSchemaAccessorName('Task'), r'$TaskMcpX');
      expect(publicSchemaAccessorName('CreateTaskInput'), r'$CreateTaskInputMcpX');
    });
  });
}
