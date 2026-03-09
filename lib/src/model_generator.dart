import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'type_utils.dart';

final _mcpFieldChecker = TypeChecker.typeNamed(McpField);
final _jsonKeyChecker = TypeChecker.typeNamed(JsonKey);

/// Generates `ObjectSchema _$ClassNameMcpSchema()` for every class
/// annotated with @McpModel, plus a public accessor class that also exposes
/// the model's unique ID.
class McpModelGenerator extends GeneratorForAnnotation<McpModel> {
  const McpModelGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@McpModel can only be applied to classes.',
        element: element,
      );
    }
    final packageName = buildStep.inputId.package;
    final modelName =
        annotation.peek('name')?.stringValue ?? element.name!;
    final modelId = '$packageName/$modelName';
    return _generateSchema(element, modelId);
  }

  String _generateSchema(ClassElement element, String modelId) {
    final fields = element.fields
        .where((f) => !f.isStatic && f.isOriginDeclaration)
        .toList();

    final requiredKeys = <String>[];
    final propertyLines = <String>[];

    for (final field in fields) {
      String? description;
      bool? explicitRequired;

      // Read @McpField metadata.
      final mcpAnn = _mcpFieldChecker.firstAnnotationOfExact(field);
      if (mcpAnn != null) {
        final r = ConstantReader(mcpAnn);
        description = r.peek('description')?.stringValue;
        explicitRequired = r.peek('required')?.boolValue;
      }

      // Resolve the JSON key name, respecting @JsonKey(name:).
      var keyName = field.name;
      final jsonAnn = _jsonKeyChecker.firstAnnotationOfExact(field);
      if (jsonAnn != null) {
        final r = ConstantReader(jsonAnn);
        keyName = r.peek('name')?.stringValue ?? field.name;
      }

      // Determine if the field is required.
      final isNullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question;
      final isRequired = explicitRequired ?? !isNullable;
      if (isRequired) requiredKeys.add("'$keyName'");

      final schema = schemaExprForType(field.type, description);
      propertyLines.add("      '$keyName': $schema,");
    }

    final className = element.name!;
    final privateFn = privateSchemaFnName(className);
    final accessorClass = publicSchemaAccessorName(className);

    final buf = StringBuffer();

    // Private generated function — matches json_serializable naming convention.
    buf.writeln('ObjectSchema $privateFn() {');
    buf.writeln('  return ObjectSchema(');
    buf.writeln('    properties: {');
    for (final line in propertyLines) {
      buf.writeln(line);
    }
    buf.writeln('    },');
    if (requiredKeys.isNotEmpty) {
      buf.writeln('    required: [${requiredKeys.join(', ')}],');
    }
    buf.writeln('  );');
    buf.writeln('}');
    buf.writeln('');

    // Public accessor class — lets service .mcp.dart files (other libraries)
    // call $ClassNameMcpX.schema() and read mcpModelId cross-library.
    buf.writeln('// ignore: camel_case_types');
    buf.writeln('class $accessorClass {');
    buf.writeln("  static const String mcpModelId = '${_esc(modelId)}';");
    buf.writeln('  static ObjectSchema schema() => $privateFn();');
    buf.writeln('  static McpModelDefinition get definition => McpModelDefinition(');
    buf.writeln('    id: mcpModelId,');
    buf.writeln('    schemaFactory: $accessorClass.schema,');
    buf.writeln('    fromJson: $className.fromJson,');
    buf.writeln('  );');
    buf.writeln('}');

    return buf.toString();
  }

  String _esc(String s) => s.replaceAll("'", "\\'");
}
