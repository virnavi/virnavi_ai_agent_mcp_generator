import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

final _mcpModelChecker = TypeChecker.typeNamed(McpModel);
final _jsonValueChecker = TypeChecker.typeNamed(JsonValue);

/// The private generated function name — accessible within the same library only.
/// e.g. CreateTaskInput → _$CreateTaskInputToMcpSchema
String privateSchemaFnName(String className) => '_\$${className}ToMcpSchema';

/// The public accessor class name — usable cross-library.
/// e.g. CreateTaskInput → $CreateTaskInputMcpX
String publicSchemaAccessorName(String className) => '\$${className}McpX';

/// Returns a Dart source expression that constructs the SchemaType for [type].
/// For @McpModel types, calls the public cross-library accessor.
String schemaExprForType(DartType type, String? description) {
  final escapedDesc = description?.replaceAll("'", "\\'");
  final descArg = escapedDesc != null ? "description: '$escapedDesc'" : null;

  String call(String schemaClass, [List<String?> extra = const []]) {
    final args = [descArg, ...extra].whereType<String>().join(', ');
    return '$schemaClass($args)';
  }

  // dynamic → no type constraint.
  if (type is DynamicType) return call('ObjectSchema');

  if (type.isDartCoreString) return call('StringSchema');
  if (type.isDartCoreInt) return call('IntegerSchema');
  if (type.isDartCoreDouble || type.isDartCoreNum) return call('NumberSchema');
  if (type.isDartCoreBool) return call('BooleanSchema');

  if (type.isDartCoreList && type is InterfaceType && type.typeArguments.isNotEmpty) {
    final itemExpr = schemaExprForType(type.typeArguments.first, null);
    return call('ArraySchema', ['items: $itemExpr']);
  }

  if (type.isDartCoreMap) return call('ObjectSchema');

  if (type is InterfaceType) {
    final el = type.element;

    // DateTime → integer (milliseconds since epoch UTC).
    if (el.name == 'DateTime') return call('IntegerSchema');

    // DateTimeRange → object with {start, end} milliseconds.
    if (el.name == 'DateTimeRange') {
      return "ObjectSchema(${descArg != null ? '$descArg, ' : ''}properties: {"
          "'start': IntegerSchema(description: 'Milliseconds since epoch UTC.'), "
          "'end': IntegerSchema(description: 'Milliseconds since epoch UTC.')"
          "}, required: ['start', 'end'])";
    }

    // Enum → StringSchema with enumValues (respects @JsonValue).
    if (el is EnumElement) {
      final values = el.fields
          .where((f) => f.isEnumConstant)
          .map((f) => _enumJsonValueLiteral(f))
          .join(', ');
      return call('StringSchema', ['enumValues: [$values]']);
    }

    // @McpModel class — call the public cross-library accessor.
    if (_mcpModelChecker.hasAnnotationOf(el)) {
      return '${publicSchemaAccessorName(el.name!)}.schema()';
    }
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
  if (type is InterfaceType) return type.element.name!;
  // ignore: deprecated_member_use
  return type.getDisplayString(withNullability: false);
}

/// Checks if [element] is annotated with @McpModel.
bool isMcpModel(InterfaceElement element) => _mcpModelChecker.hasAnnotationOf(element);

/// Returns the Dart string literal for the JSON value of an enum constant field.
/// Uses @JsonValue if present, otherwise falls back to the field name.
String _enumJsonValueLiteral(FieldElement field) {
  final ann = _jsonValueChecker.firstAnnotationOfExact(field);
  if (ann != null) {
    final val = ConstantReader(ann).read('value');
    if (val.isString) return "'${val.stringValue}'";
    if (val.isInt) return "'${val.intValue}'";
  }
  return "'${field.name}'";
}

/// Generates the Dart expression to decode an enum from a JSON args map.
///
/// Uses @JsonValue reverse-lookup when present, otherwise .values.byName().
/// [key] is the args map key; [nullable] wraps the result in a null-check.
String enumCastExpr(EnumElement el, String typeName, String key, bool nullable) {
  final constants = el.fields.where((f) => f.isEnumConstant).toList();
  final hasJsonValue = constants.any(
    (f) => _jsonValueChecker.hasAnnotationOfExact(f),
  );

  String decode;
  if (hasJsonValue) {
    final entries = constants.map((f) {
      final literal = _enumJsonValueLiteral(f);
      return '$literal: $typeName.${f.name}';
    }).join(', ');
    decode = "const {$entries}[args['$key'] as String]!";
  } else {
    decode = "$typeName.values.byName(args['$key'] as String)";
  }

  if (nullable) {
    return "(args['$key'] == null ? null : $decode)";
  }
  return decode;
}
