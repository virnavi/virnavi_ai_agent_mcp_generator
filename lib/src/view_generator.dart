import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

final _mcpModelCheckerView = TypeChecker.typeNamed(McpModel);

/// Generates a `$WidgetNameMcpView` accessor class for every Widget class
/// annotated with @McpView.
///
/// The generated class exposes:
///   - `static const String mcpModelId` — the bound model's unique ID
///   - `static Widget fromStore(store, {builder, onLoading, onError})` —
///     a one-liner that wraps [McpResultBuilder] and parses the model
///     automatically, eliminating repetitive binding boilerplate in the app.
class McpViewGenerator extends GeneratorForAnnotation<McpView> {
  const McpViewGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@McpView can only be applied to classes.',
        element: element,
      );
    }

    final widgetClass = element.name!;
    final packageName = buildStep.inputId.package;

    final modelType = annotation.read('model').typeValue;
    if (modelType is! InterfaceType) {
      throw InvalidGenerationSourceError(
        '@McpView model must be a class type.',
        element: element,
      );
    }

    final modelElement = modelType.element;
    final modelClass = modelElement.name!;

    final mcpModelAnn =
        _mcpModelCheckerView.firstAnnotationOfExact(modelElement);
    final modelName = mcpModelAnn != null
        ? ConstantReader(mcpModelAnn).peek('name')?.stringValue ?? modelClass
        : modelClass;
    final modelId = '$packageName/$modelName';

    final accessorClass = '\$${widgetClass}McpView';

    return '''
// ignore: camel_case_types
class $accessorClass {
  static const String mcpModelId = '${_esc(modelId)}';

  static McpViewDefinition get definition => McpViewDefinition(
    modelId: mcpModelId,
    widgetBuilder: (data) => $widgetClass(result: data as $modelClass),
  );

  static Widget fromStore(
    McpResultStore store, {
    required Widget Function(BuildContext context, $modelClass data) builder,
    Widget Function(BuildContext context)? onLoading,
    Widget Function(BuildContext context, String message)? onError,
  }) {
    return McpResultBuilder(
      store: store,
      toolName: mcpModelId,
      builder: (context, state) => switch (state) {
        McpIdle() => const SizedBox.shrink(),
        McpLoading() => onLoading?.call(context) ?? const SizedBox.shrink(),
        McpSuccess(data: final d) => builder(
            context,
            $modelClass.fromJson((d as Map).cast<String, dynamic>()),
          ),
        McpError(message: final m) =>
          onError?.call(context, m) ?? const SizedBox.shrink(),
      },
    );
  }
}''';
  }

  String _esc(String s) => s.replaceAll("'", "\\'");
}
