// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dimensions _$DimensionsFromJson(Map<String, dynamic> json) => Dimensions(
  widthCm: (json['width_cm'] as num).toDouble(),
  heightCm: (json['height_cm'] as num).toDouble(),
  depthCm: (json['depth_cm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DimensionsToJson(Dimensions instance) =>
    <String, dynamic>{
      'width_cm': instance.widthCm,
      'height_cm': instance.heightCm,
      'depth_cm': instance.depthCm,
    };

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  stockCount: (json['stockCount'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  active: json['active'] as bool,
  subtitle: json['subtitle'] as String?,
  sku: json['sku'] as String?,
  costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
  taxRate: (json['tax_rate'] as num).toDouble(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  categoryIds: (json['categoryIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
  dimensions: json['dimensions'] == null
      ? null
      : Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
  createdAt: _dateFromMs((json['created_at'] as num).toInt()),
  expiresAt: _dateFromIso(json['expires_at'] as String?),
  metadata: json['metadata'],
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'stockCount': instance.stockCount,
  'price': instance.price,
  'active': instance.active,
  'subtitle': instance.subtitle,
  'sku': instance.sku,
  'costPrice': instance.costPrice,
  'tax_rate': instance.taxRate,
  'tags': instance.tags,
  'categoryIds': instance.categoryIds,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'priority': _$PriorityEnumMap[instance.priority],
  'dimensions': instance.dimensions,
  'created_at': _dateToMs(instance.createdAt),
  'expires_at': _dateToIso(instance.expiresAt),
  'metadata': instance.metadata,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.critical: 'critical',
};

ProductCatalog _$ProductCatalogFromJson(Map<String, dynamic> json) =>
    ProductCatalog(
      productIds: (json['productIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$ProductCatalogToJson(ProductCatalog instance) =>
    <String, dynamic>{
      'productIds': instance.productIds,
      'totalCount': instance.totalCount,
      'has_more': instance.hasMore,
    };

CreateProductInput _$CreateProductInputFromJson(Map<String, dynamic> json) =>
    CreateProductInput(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stockCount: (json['stockCount'] as num).toInt(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
      taxRate: (json['tax_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateProductInputToJson(CreateProductInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'stockCount': instance.stockCount,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'priority': _$PriorityEnumMap[instance.priority],
      'tax_rate': instance.taxRate,
    };
