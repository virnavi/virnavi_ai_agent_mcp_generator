// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'services.dart';

// **************************************************************************
// McpServiceGenerator
// **************************************************************************

extension CatalogServiceMcpExtension on CatalogService {
  List<ToolDefinition> get mcpTools => [
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/list_products',
      description: 'Returns all products in the catalog.',
      inputSchema: ObjectSchema(),
      handler: (args) async {
        final result = await listProducts();
        return ToolResult.success(result.map((e) => e.toJson()).toList());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/count_products',
      description: 'Returns the total number of products.',
      inputSchema: ObjectSchema(),
      handler: (args) async {
        final result = await countProducts();
        return ToolResult.success(result);
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/clear_cache',
      description: 'Clears all cached pricing data.',
      inputSchema: ObjectSchema(),
      handler: (args) async {
        await clearCache();
        return ToolResult.success(null);
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/create_product',
      description: 'Creates a new product from a structured input object.',
      inputSchema: $CreateProductInputMcpX.schema(),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await createProduct(CreateProductInput.fromJson(args));
        return ToolResult.success(result.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/update_product',
      description: 'Replaces an existing product with new data.',
      inputSchema: $CreateProductInputMcpX.schema(),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await updateProduct(
          input: CreateProductInput.fromJson(args),
        );
        return ToolResult.success(result.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/get_product',
      description: 'Returns a product by ID, or null if not found.',
      inputSchema: ObjectSchema(
        properties: {
          'id': StringSchema(description: 'Unique product identifier'),
        },
        required: ['id'],
      ),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await getProduct(args['id'] as String);
        return ToolResult.success(result?.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/search_products',
      description: 'Searches the catalog with optional filters.',
      inputSchema: ObjectSchema(
        properties: {
          'query': StringSchema(description: 'Full-text search query'),
          'status': StringSchema(
            description: 'Filter by order status',
            enumValues: [
              'pending',
              'processing',
              'shipped',
              'delivered',
              'cancelled',
            ],
          ),
          'priority': StringSchema(
            description: 'Filter by priority level',
            enumValues: ['low', 'medium', 'high', 'critical'],
          ),
          'minPrice': NumberSchema(description: 'Minimum price inclusive'),
          'maxPrice': NumberSchema(description: 'Maximum price inclusive'),
          'limit': IntegerSchema(description: 'Maximum number of results'),
          'inStockOnly': BooleanSchema(
            description: 'Return only in-stock items',
          ),
        },
        required: ['query'],
      ),
      handler: (args) async {
        final result = await searchProducts(
          query: args['query'] as String,
          status: (args['status'] == null
              ? null
              : const {
                  'pending': OrderStatus.pending,
                  'processing': OrderStatus.processing,
                  'shipped': OrderStatus.shipped,
                  'delivered': OrderStatus.delivered,
                  'cancelled': OrderStatus.cancelled,
                }[args['status'] as String]!),
          priority: (args['priority'] == null
              ? null
              : Priority.values.byName(args['priority'] as String)),
          minPrice: args['minPrice'] as double?,
          maxPrice: args['maxPrice'] as double?,
          limit: args['limit'] as int,
          inStockOnly: args['inStockOnly'] as bool,
        );
        return ToolResult.success(result.map((e) => e.toJson()).toList());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/find_by_barcode',
      description: 'Looks up a product by its barcode.',
      inputSchema: ObjectSchema(
        properties: {'barcode': StringSchema(description: 'Product barcode')},
        required: ['barcode'],
      ),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await findByBarcode(barcode: args['barcode'] as String?);
        return ToolResult.success(result?.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/products_in_range',
      description: 'Returns products created within a date range.',
      inputSchema: ObjectSchema(
        properties: {
          'since': IntegerSchema(
            description: 'Range start — milliseconds since epoch UTC',
          ),
          'until': IntegerSchema(
            description: 'Range end — milliseconds since epoch UTC',
          ),
        },
        required: ['since'],
      ),
      handler: (args) async {
        final result = await productsInRange(
          since: DateTime.fromMillisecondsSinceEpoch(
            args['since'] as int,
            isUtc: true,
          ),
          until: (args['until'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  args['until'] as int,
                  isUtc: true,
                )),
        );
        return ToolResult.success(result.map((e) => e.toJson()).toList());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/products_by_status',
      description: 'Returns all products matching a given status.',
      inputSchema: ObjectSchema(
        properties: {
          'status': StringSchema(
            description: 'Order status to filter by',
            enumValues: [
              'pending',
              'processing',
              'shipped',
              'delivered',
              'cancelled',
            ],
          ),
          'fallback': StringSchema(
            description: 'Optional secondary status',
            enumValues: [
              'pending',
              'processing',
              'shipped',
              'delivered',
              'cancelled',
            ],
          ),
        },
        required: ['status'],
      ),
      handler: (args) async {
        final result = await productsByStatus(
          status: const {
            'pending': OrderStatus.pending,
            'processing': OrderStatus.processing,
            'shipped': OrderStatus.shipped,
            'delivered': OrderStatus.delivered,
            'cancelled': OrderStatus.cancelled,
          }[args['status'] as String]!,
          fallback: (args['fallback'] == null
              ? null
              : const {
                  'pending': OrderStatus.pending,
                  'processing': OrderStatus.processing,
                  'shipped': OrderStatus.shipped,
                  'delivered': OrderStatus.delivered,
                  'cancelled': OrderStatus.cancelled,
                }[args['fallback'] as String]!),
        );
        return ToolResult.success(result.map((e) => e.toJson()).toList());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/products_by_priority',
      description: 'Returns all products with the given priority.',
      inputSchema: ObjectSchema(
        properties: {
          'priority': StringSchema(
            description: 'Priority level to filter by',
            enumValues: ['low', 'medium', 'high', 'critical'],
          ),
        },
        required: ['priority'],
      ),
      handler: (args) async {
        final result = await productsByPriority(
          Priority.values.byName(args['priority'] as String),
        );
        return ToolResult.success(result.map((e) => e.toJson()).toList());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/stock/adjust',
      description: 'Adjusts stock by a delta amount.',
      inputSchema: ObjectSchema(
        properties: {
          'id': StringSchema(description: 'Product ID'),
          'delta': IntegerSchema(
            description: 'Amount to add (negative to subtract)',
          ),
        },
        required: ['id', 'delta'],
      ),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await adjustStock(
          id: args['id'] as String,
          delta: args['delta'] as int,
        );
        return ToolResult.success(result.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/find_by_name',
      description: 'Finds a product by exact name, or null.',
      inputSchema: ObjectSchema(
        properties: {'name': StringSchema(description: 'Exact product name')},
        required: ['name'],
      ),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await findByName(args['name'] as String);
        return ToolResult.success(result?.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/product_exists',
      description: 'Checks whether a product ID exists.',
      inputSchema: ObjectSchema(
        properties: {'id': StringSchema(description: 'Product ID to check')},
        required: ['id'],
      ),
      handler: (args) async {
        final result = await productExists(args['id'] as String);
        return ToolResult.success(result);
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/get_catalog',
      description: 'Returns a paged list of product IDs.',
      inputSchema: ObjectSchema(
        properties: {
          'pageSize': IntegerSchema(description: 'Page size'),
          'pageToken': StringSchema(description: 'Page token for continuation'),
        },
      ),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Catalog',
      handler: (args) async {
        final result = await getCatalog(
          pageSize: args['pageSize'] as int,
          pageToken: args['pageToken'] as String?,
        );
        return ToolResult.success(result.toJson());
      },
    ),
    ToolDefinition(
      name:
          'packages/virnavi_ai_agent_mcp_generator_example/mcp/catalog/patch_product',
      description: 'Applies a raw JSON patch to a product.',
      inputSchema: ObjectSchema(
        properties: {
          'id': StringSchema(description: 'Product ID to patch'),
          'patch': ObjectSchema(
            description: 'JSON patch payload — any structure',
          ),
        },
        required: ['id', 'patch'],
      ),
      resultModelId: 'virnavi_ai_agent_mcp_generator_example/Product',
      handler: (args) async {
        final result = await patchProduct(
          id: args['id'] as String,
          patch: args['patch'],
        );
        return ToolResult.success(result.toJson());
      },
    ),
  ];
}
