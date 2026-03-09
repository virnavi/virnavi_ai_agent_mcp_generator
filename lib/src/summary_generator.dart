import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'type_utils.dart';

final _mcpModelCheckerSum = TypeChecker.typeNamed(McpModel);
final _mcpServiceCheckerSum = TypeChecker.typeNamed(McpService);
final _mcpToolCheckerSum = TypeChecker.typeNamed(McpTool);
final _mcpViewCheckerSum = TypeChecker.typeNamed(McpView);

/// Generates a `$AnnotatedClassMcpSummary` accessor class for every class
/// annotated with @McpSummary.
///
/// The class exposes:
/// - `static const McpSummary summary` — const catalog of all artifact IDs
/// - `static McpSummary bindAll(tools)` — binds tools + model definitions
/// - `static McpSummary bindWithViews(tools)` — binds tools + models + views
class McpSummaryGenerator extends GeneratorForAnnotation<McpSummary> {
  const McpSummaryGenerator();

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@McpSummary can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name!;
    final packageName = buildStep.inputId.package;

    final toolNames = <String>{};
    final modelClassNames = <String>[];   // class name → accessor name
    final viewWidgetClassNames = <String>[];  // widget class names with @McpView

    // Scan all lib/**.dart files in this package (skip generated files).
    await for (final asset in buildStep.findAssets(Glob('lib/**.dart'))) {
      if (asset.path.endsWith('.mcp.dart') ||
          asset.path.endsWith('.g.dart')) continue;

      LibraryElement lib;
      try {
        lib = await buildStep.resolver.libraryFor(asset);
      } catch (_) {
        continue;
      }

      final reader = LibraryReader(lib);
      for (final el in reader.classes) {
        // @McpModel — track class name for definition references
        if (_mcpModelCheckerSum.hasAnnotationOf(el)) {
          modelClassNames.add(el.name!);
        }

        // @McpService → collect all @McpTool names
        if (_mcpServiceCheckerSum.hasAnnotationOf(el)) {
          final serviceAnn = ConstantReader(
            _mcpServiceCheckerSum.firstAnnotationOfExact(el)!,
          );
          final servicePath = serviceAnn.read('path').stringValue;
          for (final method in el.methods) {
            if (_mcpToolCheckerSum.hasAnnotationOf(method)) {
              final toolAnn = ConstantReader(
                _mcpToolCheckerSum.firstAnnotationOfExact(method)!,
              );
              final toolPath =
                  toolAnn.peek('path')?.stringValue ?? toSnakeCase(method.name!);
              toolNames
                  .add('packages/$packageName/mcp/$servicePath/$toolPath');
            }
          }
        }

        // @McpView — track widget class name for definition references
        if (_mcpViewCheckerSum.hasAnnotationOf(el)) {
          viewWidgetClassNames.add(el.name!);
        }
      }
    }

    // Derive model IDs and view model IDs from scanned names.
    final modelIds = modelClassNames.map((n) => '$packageName/$n').toSet();
    final viewModelIds = <String>{};
    // Re-scan to get view model IDs (needed for the const summary).
    await for (final asset in buildStep.findAssets(Glob('lib/**.dart'))) {
      if (asset.path.endsWith('.mcp.dart') ||
          asset.path.endsWith('.g.dart')) continue;
      LibraryElement lib;
      try {
        lib = await buildStep.resolver.libraryFor(asset);
      } catch (_) {
        continue;
      }
      final reader = LibraryReader(lib);
      for (final el in reader.classes) {
        if (_mcpViewCheckerSum.hasAnnotationOf(el)) {
          final viewAnn = ConstantReader(
            _mcpViewCheckerSum.firstAnnotationOfExact(el)!,
          );
          final modelType = viewAnn.read('model').typeValue;
          if (modelType is InterfaceType) {
            final modelEl = modelType.element;
            final mcpAnn =
                _mcpModelCheckerSum.firstAnnotationOfExact(modelEl);
            final name = mcpAnn != null
                ? ConstantReader(mcpAnn).peek('name')?.stringValue ??
                    modelEl.name!
                : modelEl.name!;
            viewModelIds.add('$packageName/$name');
          }
        }
      }
    }

    final accessorClass = '\$${className}McpSummary';

    final buf = StringBuffer();
    buf.writeln('// ignore: camel_case_types');
    buf.writeln('class $accessorClass {');

    // const summary
    buf.writeln('  static const McpSummary summary = McpSummary(');
    buf.writeln("    id: '$packageName',");
    buf.writeln('    toolNames: {');
    for (final n in toolNames) buf.writeln("      '${_esc(n)}',");
    buf.writeln('    },');
    buf.writeln('    modelIds: {');
    for (final m in modelIds) buf.writeln("      '${_esc(m)}',");
    buf.writeln('    },');
    buf.writeln('    viewModelIds: {');
    for (final v in viewModelIds) buf.writeln("      '${_esc(v)}',");
    buf.writeln('    },');
    buf.writeln('  );');
    buf.writeln('');

    // bindAll — tools + model definitions
    buf.writeln('  static McpSummary bindAll(List<ToolDefinition> tools) =>');
    buf.writeln('      summary.bind(tools, models: [');
    for (final name in modelClassNames) {
      buf.writeln('        ${publicSchemaAccessorName(name)}.definition,');
    }
    buf.writeln('      ]);');
    buf.writeln('');

    // bindWithViews — tools + models + view definitions (requires compose imports)
    buf.writeln(
        '  static McpSummary bindWithViews(List<ToolDefinition> tools) =>');
    buf.writeln('      bindAll(tools).bindViews([');
    for (final widgetName in viewWidgetClassNames) {
      buf.writeln('        \$${widgetName}McpView.definition,');
    }
    buf.writeln('      ]);');

    buf.writeln('}');

    return buf.toString();
  }

  String _esc(String s) => s.replaceAll("'", "\\'");
}
