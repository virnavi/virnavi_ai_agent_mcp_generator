import 'package:json_annotation/json_annotation.dart';

// ── @JsonValue on enum constants ─────────────────────────────────────────────
//
// @McpModel / @McpParam fields of this type generate:
//   StringSchema(enumValues: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'])
//
// Tool handler decodes with a const reverse-lookup map:
//   const {'pending': OrderStatus.pending, ...}[args['x'] as String]!

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

// ── No @JsonValue ─────────────────────────────────────────────────────────────
//
// Fields of this type generate:
//   StringSchema(enumValues: ['low', 'medium', 'high', 'critical'])
//
// Tool handler decodes with:
//   Priority.values.byName(args['x'] as String)

enum Priority { low, medium, high, critical }
