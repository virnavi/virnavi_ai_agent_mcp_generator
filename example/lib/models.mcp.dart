// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'models.dart';

// **************************************************************************
// McpModelGenerator
// **************************************************************************

ObjectSchema _$DimensionsToMcpSchema() {
  return ObjectSchema(
    properties: {
      'width_cm': NumberSchema(),
      'height_cm': NumberSchema(),
      'depth_cm': NumberSchema(),
    },
    required: ['width_cm', 'height_cm'],
  );
}

// ignore: camel_case_types
class $DimensionsMcpX {
  static const String mcpModelId =
      'virnavi_ai_agent_mcp_generator_example/Dimensions';
  static ObjectSchema schema() => _$DimensionsToMcpSchema();
  static McpModelDefinition get definition => McpModelDefinition(
    id: mcpModelId,
    schemaFactory: $DimensionsMcpX.schema,
    fromJson: Dimensions.fromJson,
  );
}

ObjectSchema _$ProductToMcpSchema() {
  return ObjectSchema(
    properties: {
      'id': StringSchema(),
      'name': StringSchema(description: 'Display name of the product'),
      'stockCount': IntegerSchema(),
      'price': NumberSchema(),
      'active': BooleanSchema(),
      'subtitle': StringSchema(description: 'Optional marketing subtitle'),
      'sku': StringSchema(description: 'Stock-keeping unit code'),
      'costPrice': NumberSchema(
        description: 'Internal cost price (server-assigned if omitted)',
      ),
      'tax_rate': NumberSchema(
        description: 'VAT rate as a decimal, e.g. 0.2 for 20%',
      ),
      'tags': ArraySchema(items: StringSchema()),
      'categoryIds': ArraySchema(items: IntegerSchema()),
      'status': StringSchema(
        enumValues: [
          'pending',
          'processing',
          'shipped',
          'delivered',
          'cancelled',
        ],
      ),
      'priority': StringSchema(
        enumValues: ['low', 'medium', 'high', 'critical'],
      ),
      'dimensions': $DimensionsMcpX.schema(),
      'created_at': IntegerSchema(),
      'expires_at': StringSchema(),
      'metadata': ObjectSchema(
        description: 'Arbitrary extra metadata — any JSON structure',
      ),
    },
    required: [
      'id',
      'name',
      'stockCount',
      'price',
      'active',
      'sku',
      'tax_rate',
      'tags',
      'categoryIds',
      'status',
      'created_at',
      'metadata',
    ],
  );
}

// ignore: camel_case_types
class $ProductMcpX {
  static const String mcpModelId =
      'virnavi_ai_agent_mcp_generator_example/Product';
  static ObjectSchema schema() => _$ProductToMcpSchema();
  static McpModelDefinition get definition => McpModelDefinition(
    id: mcpModelId,
    schemaFactory: $ProductMcpX.schema,
    fromJson: Product.fromJson,
    nestedDefinitions: [$DimensionsMcpX.definition],
  );
}

ObjectSchema _$ProductCatalogToMcpSchema() {
  return ObjectSchema(
    properties: {
      'productIds': ArraySchema(items: StringSchema()),
      'totalCount': IntegerSchema(),
      'has_more': BooleanSchema(),
    },
    required: ['productIds', 'totalCount', 'has_more'],
  );
}

// ignore: camel_case_types
class $ProductCatalogMcpX {
  static const String mcpModelId =
      'virnavi_ai_agent_mcp_generator_example/Catalog';
  static ObjectSchema schema() => _$ProductCatalogToMcpSchema();
  static McpModelDefinition get definition => McpModelDefinition(
    id: mcpModelId,
    schemaFactory: $ProductCatalogMcpX.schema,
    fromJson: ProductCatalog.fromJson,
  );
}

ObjectSchema _$CreateProductInputToMcpSchema() {
  return ObjectSchema(
    properties: {
      'name': StringSchema(),
      'price': NumberSchema(),
      'stockCount': IntegerSchema(),
      'status': StringSchema(
        enumValues: [
          'pending',
          'processing',
          'shipped',
          'delivered',
          'cancelled',
        ],
      ),
      'priority': StringSchema(
        description: 'Optional priority level',
        enumValues: ['low', 'medium', 'high', 'critical'],
      ),
      'tax_rate': NumberSchema(description: 'VAT rate as a decimal'),
    },
    required: ['name', 'price', 'stockCount', 'status', 'tax_rate'],
  );
}

// ignore: camel_case_types
class $CreateProductInputMcpX {
  static const String mcpModelId =
      'virnavi_ai_agent_mcp_generator_example/CreateProductInput';
  static ObjectSchema schema() => _$CreateProductInputToMcpSchema();
  static McpModelDefinition get definition => McpModelDefinition(
    id: mcpModelId,
    schemaFactory: $CreateProductInputMcpX.schema,
    fromJson: CreateProductInput.fromJson,
  );
}
