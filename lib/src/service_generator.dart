import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'type_utils.dart';

final _toolChecker = TypeChecker.fromRuntime(McpTool);
final _paramChecker = TypeChecker.fromRuntime(McpParam);

/// Generates a `${ClassName}McpExtension` with a `mcpTools` getter
/// for every class annotated with @McpService.
///
/// Tool names follow the pattern:
///   packages/{package}/mcp/{servicePath}/{toolPath}
class McpServiceGenerator extends GeneratorForAnnotation<McpService> {
  const McpServiceGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@McpService can only be applied to classes.',
        element: element,
      );
    }

    final packageName = buildStep.inputId.package;
    final servicePath = annotation.read('path').stringValue;

    return _generateService(element, packageName, servicePath);
  }

  String _generateService(
    ClassElement element,
    String packageName,
    String servicePath,
  ) {
    final className = element.name;
    final toolMethods =
        element.methods.where((m) => _toolChecker.hasAnnotationOfExact(m)).toList();

    final buf = StringBuffer();

    buf.writeln('extension ${className}McpExtension on $className {');
    buf.writeln('  List<ToolDefinition> get mcpTools => [');

    for (final method in toolMethods) {
      final ann = ConstantReader(_toolChecker.firstAnnotationOfExact(method)!);
      final toolPath = ann.peek('path')?.stringValue ?? toSnakeCase(method.name);
      final description = ann.read('description').stringValue;
      final toolName = 'packages/$packageName/mcp/$servicePath/$toolPath';

      buf.writeln('    ToolDefinition(');
      buf.writeln("      name: '${_esc(toolName)}',");
      buf.writeln("      description: '${_esc(description)}',");
      buf.writeln('      inputSchema: ${_inputSchema(method)},');
      buf.writeln('      handler: (args) async {');
      buf.writeln('        ${_handlerBody(method)}');
      buf.writeln('      },');
      buf.writeln('    ),');
    }

    buf.writeln('  ];');
    buf.writeln('}');

    return buf.toString();
  }

  // ── inputSchema ─────────────────────────────────────────────────────────────

  String _inputSchema(MethodElement method) {
    final params = method.parameters;

    if (params.isEmpty) return 'ObjectSchema()';

    // Single @McpModel parameter → use that model's schema.
    if (params.length == 1) {
      final param = params.first;
      if (param.type is InterfaceType) {
        final classEl = (param.type as InterfaceType).element;
        if (isMcpModel(classEl)) {
          return '${publicSchemaAccessorName(classEl.name)}.schema()';
        }
      }
    }

    // Primitive / @McpParam parameters → inline ObjectSchema.
    final requiredKeys = <String>[];
    final propLines = <String>[];

    for (final param in params) {
      String? description;
      bool isRequired = param.isRequired &&
          param.type.nullabilitySuffix != NullabilitySuffix.question;

      final ann = _paramChecker.firstAnnotationOfExact(param);
      if (ann != null) {
        final r = ConstantReader(ann);
        description = r.read('description').stringValue;
        isRequired = r.peek('required')?.boolValue ?? isRequired;
      }

      final schema = schemaExprForType(param.type, description);
      propLines.add("        '${param.name}': $schema,");
      if (isRequired) requiredKeys.add("'${param.name}'");
    }

    final buf = StringBuffer('ObjectSchema(\n      properties: {\n');
    for (final line in propLines) buf.writeln(line);
    buf.write('      },');
    if (requiredKeys.isNotEmpty) {
      buf.write('\n      required: [${requiredKeys.join(', ')}],');
    }
    buf.write('\n    )');
    return buf.toString();
  }

  // ── handler body ─────────────────────────────────────────────────────────────

  String _handlerBody(MethodElement method) {
    final params = method.parameters;

    String callExpr;
    if (params.isEmpty) {
      callExpr = '${method.name}()';
    } else if (params.length == 1) {
      final param = params.first;
      if (param.type is InterfaceType) {
        final classEl = (param.type as InterfaceType).element;
        if (isMcpModel(classEl)) {
          callExpr = '${method.name}(${classEl.name}.fromJson(args))';
        } else {
          callExpr = '${method.name}(${_castArg(param)})';
        }
      } else {
        callExpr = '${method.name}(${_castArg(param)})';
      }
    } else {
      callExpr = '${method.name}(${params.map(_castArg).join(', ')})';
    }

    final isFuture = method.returnType.isDartAsyncFuture ||
        method.returnType.isDartAsyncFutureOr;
    final awaitExpr = isFuture ? 'await $callExpr' : callExpr;

    // Unwrap Future<T> → T.
    DartType resultType = method.returnType;
    if (isFuture &&
        method.returnType is InterfaceType &&
        (method.returnType as InterfaceType).typeArguments.isNotEmpty) {
      resultType = (method.returnType as InterfaceType).typeArguments.first;
    }

    final isNullable = resultType.nullabilitySuffix == NullabilitySuffix.question;

    String resultExpr;
    if (resultType is InterfaceType && isMcpModel(resultType.element)) {
      // @McpModel → call .toJson()
      resultExpr = isNullable
          ? 'ToolResult.success(result?.toJson())'
          : 'ToolResult.success(result.toJson())';
    } else if (resultType.isDartCoreList &&
        resultType is InterfaceType &&
        resultType.typeArguments.isNotEmpty) {
      final itemType = resultType.typeArguments.first;
      if (itemType is InterfaceType && isMcpModel(itemType.element)) {
        // List<@McpModel> → map each to toJson()
        resultExpr = 'ToolResult.success(result.map((e) => e.toJson()).toList())';
      } else {
        resultExpr = 'ToolResult.success(result)';
      }
    } else {
      resultExpr = 'ToolResult.success(result)';
    }

    return 'final result = $awaitExpr;\n        return $resultExpr;';
  }

  String _castArg(ParameterElement param) {
    final nullable = param.type.nullabilitySuffix == NullabilitySuffix.question;
    final typeName = castTypeName(param.type);
    return nullable
        ? "args['${param.name}'] as $typeName?"
        : "args['${param.name}'] as $typeName";
  }

  String _esc(String s) => s.replaceAll("'", "\\'");
}
