import 'package:json_annotation/json_annotation.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'enums.dart';

part 'models.g.dart';
part 'models.mcp.dart';

// ── DateTime converters ───────────────────────────────────────────────────────
//
// @JsonKey(toJson: fn) — the generator reads fn's RETURN TYPE to pick the schema:
//   _dateToMs   returns int    → IntegerSchema  (milliseconds since epoch UTC)
//   _dateToIso  returns String → StringSchema   (ISO-8601)

DateTime _dateFromMs(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
int _dateToMs(DateTime dt) => dt.millisecondsSinceEpoch;

DateTime? _dateFromIso(String? s) => s == null ? null : DateTime.parse(s);
String? _dateToIso(DateTime? dt) => dt?.toIso8601String();

// ─────────────────────────────────────────────────────────────────────────────
// 1. Nested @McpModel
//
// When used as a field type on another @McpModel, the generator emits:
//   'dimensions': $DimensionsMcpX.schema()
//
// @JsonKey(name:) → schema property key matches the JSON key, not the Dart name.
//   'widthCm' field → schema key 'width_cm'
// ─────────────────────────────────────────────────────────────────────────────
@McpModel()
@JsonSerializable()
class Dimensions {
  // @JsonKey(name: 'width_cm') → schema property: 'width_cm': NumberSchema()
  @JsonKey(name: 'width_cm')
  final double widthCm;

  @JsonKey(name: 'height_cm')
  final double heightCm;

  // Nullable + @JsonKey(name:) → 'depth_cm': NumberSchema(), NOT in required
  @JsonKey(name: 'depth_cm')
  final double? depthCm;

  const Dimensions({
    required this.widthCm,
    required this.heightCm,
    this.depthCm,
  });

  factory Dimensions.fromJson(Map<String, dynamic> j) => _$DimensionsFromJson(j);
  Map<String, dynamic> toJson() => _$DimensionsToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Comprehensive @McpModel — every field type and annotation combination
//
// Shows:
//  • Primitive types: String, int, double, bool → typed schemas
//  • Nullable fields    → excluded from 'required' list
//  • @McpField(description:)             → adds description to schema property
//  • @McpField(required: false) on non-nullable → excluded from 'required'
//  • @McpField(required: true)  on nullable    → forced into 'required'
//  • @JsonKey(name:)            → schema key = JSON key, not Dart field name
//  • @JsonKey(toJson: _dateToMs)  → IntegerSchema  (int return type)
//  • @JsonKey(toJson: _dateToIso) → StringSchema   (String return type)
//  • Enum with @JsonValue → StringSchema(enumValues: ['pending', ...])
//  • Nullable enum        → StringSchema, NOT in required
//  • Nested @McpModel     → $DimensionsMcpX.schema()
//  • List<String>         → ArraySchema(items: StringSchema())
//  • List<int>            → ArraySchema(items: IntegerSchema())
//  • dynamic              → ObjectSchema() (no type constraint)
// ─────────────────────────────────────────────────────────────────────────────
@McpModel()
@JsonSerializable()
class Product {
  // ── Primitives ──────────────────────────────────────────────────────────────

  // String, non-nullable → StringSchema(), in required
  final String id;

  // @McpField(description:) → StringSchema(description: 'Display name...')
  @McpField(description: 'Display name of the product')
  final String name;

  // int → IntegerSchema(), in required
  final int stockCount;

  // double → NumberSchema(), in required
  final double price;

  // bool → BooleanSchema(), in required
  final bool active;

  // ── Nullable primitives (excluded from required) ─────────────────────────────

  // String? → StringSchema(), NOT in required
  @McpField(description: 'Optional marketing subtitle')
  final String? subtitle;

  // ── @McpField required overrides ─────────────────────────────────────────────

  // nullable + @McpField(required: true) → StringSchema(), FORCED into required
  @McpField(description: 'Stock-keeping unit code', required: true)
  final String? sku;

  // non-nullable + @McpField(required: false) → NumberSchema(), EXCLUDED from required
  @McpField(description: 'Internal cost price (server-assigned if omitted)', required: false)
  final double costPrice;

  // ── @JsonKey(name:) — schema key follows JSON key ────────────────────────────

  // Dart: 'taxRate', JSON: 'tax_rate' → schema property key = 'tax_rate'
  @JsonKey(name: 'tax_rate')
  @McpField(description: 'VAT rate as a decimal, e.g. 0.2 for 20%')
  final double taxRate;

  // ── Collections ─────────────────────────────────────────────────────────────

  // List<String> → ArraySchema(items: StringSchema())
  final List<String> tags;

  // List<int> → ArraySchema(items: IntegerSchema())
  final List<int> categoryIds;

  // ── Enums ───────────────────────────────────────────────────────────────────

  // Enum with @JsonValue → StringSchema(enumValues: ['pending', ...])
  final OrderStatus status;

  // Nullable enum → StringSchema(enumValues: ['low', ...]), NOT in required
  final Priority? priority;

  // ── Nested @McpModel ─────────────────────────────────────────────────────────

  // @McpModel field → 'dimensions': $DimensionsMcpX.schema()
  final Dimensions? dimensions;

  // ── DateTime with @JsonKey converters ────────────────────────────────────────

  // @JsonKey(name: 'created_at', toJson: _dateToMs)
  //   → schema key 'created_at': IntegerSchema()  (int return type)
  //   → handler decodes: DateTime.fromMillisecondsSinceEpoch(args['created_at'] as int, isUtc: true)
  @JsonKey(name: 'created_at', fromJson: _dateFromMs, toJson: _dateToMs)
  final DateTime createdAt;

  // @JsonKey(name: 'expires_at', toJson: _dateToIso)
  //   → schema key 'expires_at': StringSchema()  (String return type), NOT in required
  @JsonKey(name: 'expires_at', fromJson: _dateFromIso, toJson: _dateToIso)
  final DateTime? expiresAt;

  // ── dynamic ─────────────────────────────────────────────────────────────────

  // dynamic → ObjectSchema() (no type constraint), NOT in required (dynamic is nullable)
  @McpField(description: 'Arbitrary extra metadata — any JSON structure')
  final dynamic metadata;

  const Product({
    required this.id,
    required this.name,
    required this.stockCount,
    required this.price,
    required this.active,
    this.subtitle,
    this.sku,
    this.costPrice = 0.0,
    required this.taxRate,
    required this.tags,
    required this.categoryIds,
    required this.status,
    this.priority,
    this.dimensions,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  factory Product.fromJson(Map<String, dynamic> j) => _$ProductFromJson(j);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. @McpModel(name: 'Catalog') — custom model ID
//
// Model ID = '{package}/Catalog'  instead of  '{package}/ProductCatalog'
// Public accessor = $ProductCatalogMcpX  (class name, not the name: value)
// ─────────────────────────────────────────────────────────────────────────────
@McpModel(name: 'Catalog')
@JsonSerializable()
class ProductCatalog {
  final List<String> productIds;
  final int totalCount;

  @JsonKey(name: 'has_more')
  final bool hasMore;

  const ProductCatalog({
    required this.productIds,
    required this.totalCount,
    required this.hasMore,
  });

  factory ProductCatalog.fromJson(Map<String, dynamic> j) =>
      _$ProductCatalogFromJson(j);
  Map<String, dynamic> toJson() => _$ProductCatalogToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Input model — single @McpModel param shorthand
//
// When a @McpTool method has exactly ONE parameter of an @McpModel type,
// the generator uses that model's schema directly as the tool's inputSchema
// and decodes with: CreateProductInput.fromJson(args)
// ─────────────────────────────────────────────────────────────────────────────
@McpModel()
@JsonSerializable()
class CreateProductInput {
  final String name;
  final double price;
  final int stockCount;
  final OrderStatus status;

  @McpField(description: 'Optional priority level')
  final Priority? priority;

  @JsonKey(name: 'tax_rate')
  @McpField(description: 'VAT rate as a decimal')
  final double taxRate;

  const CreateProductInput({
    required this.name,
    required this.price,
    required this.stockCount,
    required this.status,
    this.priority,
    required this.taxRate,
  });

  factory CreateProductInput.fromJson(Map<String, dynamic> j) =>
      _$CreateProductInputFromJson(j);
  Map<String, dynamic> toJson() => _$CreateProductInputToJson(this);
}
