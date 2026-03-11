import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'enums.dart';
import 'models.dart';

part 'services.mcp.dart';

/// Demonstrates every supported @McpTool parameter and return type combination.
///
/// Run `dart run build_runner build` to generate `services.mcp.dart`.
@McpService(path: 'catalog')
class CatalogService {
  // ── No parameters ─────────────────────────────────────────────────────────
  //
  // inputSchema: ObjectSchema()

  /// Returns List<@McpModel> → result.map((e) => e.toJson()).toList()
  @McpTool(description: 'Returns all products in the catalog.')
  Future<List<Product>> listProducts() async => [];

  /// Returns a primitive int → ToolResult.success(result)
  @McpTool(description: 'Returns the total number of products.')
  Future<int> countProducts() async => 0;

  /// Returns void — handler calls method, wraps no result
  @McpTool(description: 'Clears all cached pricing data.')
  Future<void> clearCache() async {}

  // ── Single @McpModel param — positional ───────────────────────────────────
  //
  // inputSchema: $CreateProductInputMcpX.schema()
  // handler:     createProduct(CreateProductInput.fromJson(args))

  @McpTool(description: 'Creates a new product from a structured input object.')
  Future<Product> createProduct(CreateProductInput input) async =>
      throw UnimplementedError();

  // ── Single @McpModel param — named ────────────────────────────────────────
  //
  // inputSchema: $CreateProductInputMcpX.schema()
  // handler:     updateProduct(input: CreateProductInput.fromJson(args))

  @McpTool(description: 'Replaces an existing product with new data.')
  Future<Product> updateProduct({required CreateProductInput input}) async =>
      throw UnimplementedError();

  // ── Single primitive param — positional ───────────────────────────────────
  //
  // inputSchema: ObjectSchema(properties: {'id': StringSchema(description: ...)},
  //                           required: ['id'])
  // handler:     getProduct(args['id'] as String)

  @McpTool(description: 'Returns a product by ID, or null if not found.')
  Future<Product?> getProduct(
    @McpParam(description: 'Unique product identifier') String id,
  ) async =>
      null;

  // ── Multiple named params — all primitive types + defaults ─────────────────
  //
  // Each param maps to a schema property:
  //   required String query   → StringSchema(description: ...) in required
  //   OrderStatus? status     → StringSchema(enumValues: ['pending',...]), NOT in required
  //   Priority? priority      → StringSchema(enumValues: ['low',...]), NOT in required
  //   double? minPrice        → NumberSchema(), NOT in required
  //   double? maxPrice        → NumberSchema(), NOT in required
  //   int limit = 20          → IntegerSchema(), NOT in required (has default)
  //   bool inStockOnly = false→ BooleanSchema(), NOT in required (has default)
  //
  // @McpParam(required: false) forces a non-nullable param OUT of required:
  //   String? query → required: false via annotation

  @McpTool(description: 'Searches the catalog with optional filters.')
  Future<List<Product>> searchProducts({
    @McpParam(description: 'Full-text search query') required String query,
    @McpParam(description: 'Filter by order status') OrderStatus? status,
    @McpParam(description: 'Filter by priority level') Priority? priority,
    @McpParam(description: 'Minimum price inclusive') double? minPrice,
    @McpParam(description: 'Maximum price inclusive') double? maxPrice,
    @McpParam(description: 'Maximum number of results') int limit = 20,
    @McpParam(description: 'Return only in-stock items') bool inStockOnly = false,
  }) async =>
      [];

  // ── @McpParam(required:) override ─────────────────────────────────────────
  //
  // @McpParam(required: true) forces a nullable param INTO required:
  //   String? barcode → required: true override → included in required list

  @McpTool(description: 'Looks up a product by its barcode.')
  Future<Product?> findByBarcode({
    @McpParam(description: 'Product barcode', required: true) String? barcode,
  }) async =>
      null;

  // ── DateTime parameters ───────────────────────────────────────────────────
  //
  // DateTime → IntegerSchema (milliseconds since epoch UTC)
  // handler:   DateTime.fromMillisecondsSinceEpoch(args['since'] as int, isUtc: true)
  // DateTime? → IntegerSchema, NOT in required; null-check guard in handler

  @McpTool(description: 'Returns products created within a date range.')
  Future<List<Product>> productsInRange({
    @McpParam(description: 'Range start — milliseconds since epoch UTC')
    required DateTime since,
    @McpParam(description: 'Range end — milliseconds since epoch UTC')
    DateTime? until,
  }) async =>
      [];

  // ── Enum params with @JsonValue ───────────────────────────────────────────
  //
  // OrderStatus has @JsonValue → schema uses JSON values, handler uses const map:
  //   const {'pending': OrderStatus.pending, ...}[args['status'] as String]!
  //
  // Nullable OrderStatus? → same schema + null-check guard:
  //   args['status'] == null ? null : const {...}[args['status'] as String]!

  @McpTool(description: 'Returns all products matching a given status.')
  Future<List<Product>> productsByStatus({
    @McpParam(description: 'Order status to filter by') required OrderStatus status,
    @McpParam(description: 'Optional secondary status') OrderStatus? fallback,
  }) async =>
      [];

  // ── Enum params without @JsonValue ────────────────────────────────────────
  //
  // Priority has no @JsonValue → schema uses field names, handler uses .byName():
  //   Priority.values.byName(args['priority'] as String)

  @McpTool(description: 'Returns all products with the given priority.')
  Future<List<Product>> productsByPriority(
    @McpParam(description: 'Priority level to filter by') Priority priority,
  ) async =>
      [];

  // ── Explicit @McpTool(path:) ──────────────────────────────────────────────
  //
  // Overrides the default snake_case method name.
  // Tool name: packages/{package}/mcp/catalog/stock/adjust

  @McpTool(path: 'stock/adjust', description: 'Adjusts stock by a delta amount.')
  Future<Product> adjustStock({
    @McpParam(description: 'Product ID') required String id,
    @McpParam(description: 'Amount to add (negative to subtract)') required int delta,
  }) async =>
      throw UnimplementedError();

  // ── Return type variants ──────────────────────────────────────────────────

  /// @McpModel? → result?.toJson()
  @McpTool(description: 'Finds a product by exact name, or null.')
  Future<Product?> findByName(
    @McpParam(description: 'Exact product name') String name,
  ) async =>
      null;

  /// bool → ToolResult.success(result)
  @McpTool(description: 'Checks whether a product ID exists.')
  Future<bool> productExists(
    @McpParam(description: 'Product ID to check') String id,
  ) async =>
      false;

  /// Custom return model with @McpModel(name: 'Catalog')
  @McpTool(description: 'Returns a paged list of product IDs.')
  Future<ProductCatalog> getCatalog({
    @McpParam(description: 'Page size') int pageSize = 50,
    @McpParam(description: 'Page token for continuation') String? pageToken,
  }) async =>
      throw UnimplementedError();

  // ── dynamic parameter ─────────────────────────────────────────────────────
  //
  // dynamic → ObjectSchema() in schema, args['patch'] (no cast) in handler

  @McpTool(description: 'Applies a raw JSON patch to a product.')
  Future<Product> patchProduct({
    @McpParam(description: 'Product ID to patch') required String id,
    @McpParam(description: 'JSON patch payload — any structure')
    required dynamic patch,
  }) async =>
      throw UnimplementedError();
}
