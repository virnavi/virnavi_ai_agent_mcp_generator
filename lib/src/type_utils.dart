import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

final _mcpModelChecker = TypeChecker.fromRuntime(McpModel);

/// The private generated function name — accessible within the same library only.
/// e.g. CreateTaskInput → _$CreateTaskInputToMcpSchema
String privateSchemaFnName(String className) => '_\$${className}ToMcpSchema';

/// The public accessor class name — usable cross-library.
/// e.g. CreateTaskInput → $CreateTaskInputMcpX
String publicSchemaAccessorName(String className) => '\$${className}McpX';

/// Returns a Dart source expression that constructs the SchemaType for [type].
/// For @McpModel types, calls the public cross-library accessor.
String schemaExprForType(DartType type, String? description) {
  final descArg = description != null ? "description: '$description'" : null;

  String call(String schemaClass, [List<String?> extra = const []]) {
    final args = [descArg, ...extra].whereType<String>().join(', ');
    return '$schemaClass($args)';
  }

  if (type.isDartCoreString) return call('StringSchema');
  if (type.isDartCoreInt) return call('IntegerSchema');
  if (type.isDartCoreDouble || type.isDartCoreNum) return call('NumberSchema');
  if (type.isDartCoreBool) return call('BooleanSchema');

  if (type.isDartCoreList && type is InterfaceType && type.typeArguments.isNotEmpty) {
    final itemExpr = schemaExprForType(type.typeArguments.first, null);
    return call('ArraySchema', ['items: $itemExpr']);
  }

  if (type.isDartCoreMap) return call('ObjectSchema');

  // @McpModel class — call the public cross-library accessor.
  if (type is InterfaceType && _mcpModelChecker.hasAnnotationOf(type.element)) {
    return '${publicSchemaAccessorName(type.element.name)}.schema()';
  }

  return call('ObjectSchema');
}

/// Converts camelCase / PascalCase to snake_case.
String toSnakeCase(String name) {
  return name
      .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
      .replaceFirst(RegExp(r'^_'), '');
}

/// Returns the simple type name suitable for use in cast expressions.
String castTypeName(DartType type) {
  if (type is InterfaceType) return type.element.name;
  return type.getDisplayString(withNullability: false);
}

/// Checks if [element] is annotated with @McpModel.
bool isMcpModel(InterfaceElement element) => _mcpModelChecker.hasAnnotationOf(element);
