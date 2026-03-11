// Run `dart run build_runner build` before running this file.

import 'package:virnavi_ai_agent_mcp_generator_example/example_summary.dart';
import 'package:virnavi_ai_agent_mcp_generator_example/models.dart';
import 'package:virnavi_ai_agent_mcp_generator_example/services.dart';

void main() {
  final service = CatalogService();

  // Wire up all tools + model deserializers.
  final summary = $ExampleSummaryMcpSummary.bindAll(service.mcpTools);

  // ── Registered tools ───────────────────────────────────────────────────────
  print('=== Tools (${summary.tools.length}) ===');
  for (final tool in summary.tools.values) {
    print('  ${tool.name}');
    print('    ${tool.inputSchema.toJson()}');
  }

  // ── Registered models ──────────────────────────────────────────────────────
  print('\n=== Models (${summary.models.length}) ===');
  for (final model in summary.models.values) {
    print('  ${model.id}');
    print('    ${model.schemaFactory().toJson()}');
  }

  // ── Round-trip: JSON → Product via McpSummary.deserializeModel ────────────
  final rawJson = <String, dynamic>{
    'id': 'p1',
    'name': 'Widget',
    'stockCount': 42,
    'price': 9.99,
    'active': true,
    'sku': 'WGT-001',
    'tax_rate': 0.2,
    'tags': <String>['sale', 'new'],
    'categoryIds': <int>[1, 2],
    'status': 'pending',
    'created_at': DateTime.now().millisecondsSinceEpoch,
  };

  final product =
      summary.deserializeModel('virnavi_ai_agent_mcp_generator_example/Product', rawJson)
          as Product;

  print('\n=== Deserialized Product ===');
  print('  name:      ${product.name}');
  print('  status:    ${product.status}');
  print('  sku:       ${product.sku}');
  print('  tax_rate:  ${product.taxRate}');
  print('  costPrice: ${product.costPrice}');
}
