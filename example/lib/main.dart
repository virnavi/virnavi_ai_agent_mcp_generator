import 'package:flutter/material.dart';

import 'example_summary.dart';
import 'services.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP Generator Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const SummaryPage(),
    );
  }
}

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late final _summary = $ExampleSummaryMcpSummary.bindAll(CatalogService().mcpTools);

  @override
  Widget build(BuildContext context) {
    final tools = _summary.tools.values.toList();
    final models = _summary.models.values.toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MCP Generator Example'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Tools'), Tab(text: 'Models')],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tools tab ──────────────────────────────────────────────────
            ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, i) {
                final tool = tools[i];
                return ExpansionTile(
                  title: Text(
                    tool.name.split('/mcp/').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(tool.description),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        tool.inputSchema.toJson().toString(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
            // ── Models tab ─────────────────────────────────────────────────
            ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, i) {
                final model = models[i];
                return ExpansionTile(
                  title: Text(
                    model.id.split('/').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(model.id),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        model.schemaFactory().toJson().toString(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
