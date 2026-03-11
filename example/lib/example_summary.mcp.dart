// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'example_summary.dart';

// **************************************************************************
// McpSummaryGenerator
// **************************************************************************

// ignore: camel_case_types
class $ExampleSummaryMcpSummary {
  static const McpSummary summary = McpSummary(
    id: 'virnavi_ai_agent_mcp_generator_example',
    toolNames: {
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/list_products',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/count_products',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/clear_cache',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/create_product',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/update_product',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/get_product',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/search_products',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/find_by_barcode',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/products_in_range',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/products_by_status',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/products_by_priority',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/stock/adjust',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/find_by_name',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/product_exists',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/get_catalog',
      'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/patch_product',
    },
    modelIds: {
      'virnavi_ai_agent_mcp_generator_example/Dimensions',
      'virnavi_ai_agent_mcp_generator_example/Product',
      'virnavi_ai_agent_mcp_generator_example/Catalog',
      'virnavi_ai_agent_mcp_generator_example/CreateProductInput',
    },
    viewModelIds: {},
  );

  static McpSummary bindAll(List<ToolDefinition> tools) => summary.bind(
    tools,
    models: [
      $DimensionsMcpX.definition,
      $ProductMcpX.definition,
      $ProductCatalogMcpX.definition,
      $CreateProductInputMcpX.definition,
    ],
  );

  static McpSummary bindWithViews(List<ToolDefinition> tools) =>
      bindAll(tools).bindViews([]);
}
