import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'models.dart';

part 'example_summary.mcp.dart';

/// @McpSummary scans every @McpModel and @McpTool in lib/ and generates
/// a $ExampleSummaryMcpSummary class with:
///   .summary           — const catalog of all tool names and model IDs
///   .bindAll(tools)    — binds tools + model deserializers
///   .bindWithViews(tools) — same as bindAll (view resolution at runtime)
@McpSummary()
class ExampleSummary {}
