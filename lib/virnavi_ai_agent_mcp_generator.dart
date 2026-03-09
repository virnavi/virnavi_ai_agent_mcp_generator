import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/model_generator.dart';
import 'src/service_generator.dart';
import 'src/summary_generator.dart';
import 'src/view_generator.dart';

/// Outputs MCP-specific generated code to a separate `.mcp.dart` part file,
/// keeping it cleanly separated from json_serializable's `.g.dart` output.
Builder mcpBuilder(BuilderOptions options) => PartBuilder(
      [
        const McpModelGenerator(),
        const McpServiceGenerator(),
        const McpViewGenerator(),
        const McpSummaryGenerator(),
      ],
      '.mcp.dart',
    );
