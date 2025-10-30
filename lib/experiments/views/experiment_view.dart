import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/experiment_controller.dart';

class ExperimentView extends StatelessWidget {
  ExperimentView({super.key});

  final ExperimentController c = Get.put(ExperimentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP vs Dio - Experiment')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Iterations:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Slider(
                        value: c.iterations.value.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '${c.iterations.value}',
                        onChanged: (v) => c.iterations.value = v.toInt(),
                      )),
                ),
                Obx(() => Text('${c.iterations.value}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => c.runComparison(iters: c.iterations.value),
                  child: const Text('Run Comparison'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final res = await c.chainedAsyncAwait(1);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Chained (async/await)'),
                        content: Text('Results: ${res.map((r) => r.durationMs).join(', ')}'),
                      ),
                    );
                  },
                  child: const Text('Chained async/await'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final res = await c.chainedCallbacks(1);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Chained (callbacks)'),
                        content: Text('Results: ${res.map((r) => r.durationMs).join(', ')}'),
                      ),
                    );
                  },
                  child: const Text('Chained callbacks'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final httpTimings = c.httpTimings;
                final dioTimings = c.dioTimings;
                final httpAvg = httpTimings.isEmpty ? 0 : (httpTimings.reduce((a, b) => a + b) / httpTimings.length).round();
                final dioAvg = dioTimings.isEmpty ? 0 : (dioTimings.reduce((a, b) => a + b) / dioTimings.length).round();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DataTable(columns: const [
                        DataColumn(label: Text('Library')),
                        DataColumn(label: Text('Avg (ms)')),
                        DataColumn(label: Text('Calls')),
                        DataColumn(label: Text('Errors')),
                      ], rows: [
                        DataRow(cells: [
                          const DataCell(Text('http')),
                          DataCell(Text('$httpAvg')),
                          DataCell(Text('${httpTimings.length}')),
                          DataCell(Text('${c.httpErrors.length}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('dio')),
                          DataCell(Text('$dioAvg')),
                          DataCell(Text('${dioTimings.length}')),
                          DataCell(Text('${c.dioErrors.length}')),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      const Text('Dio logs (recent):', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: c.dioLogs.reversed.take(20).map((e) => Text(e, style: const TextStyle(fontSize: 12))).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Timings (ms) per call:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text('http: ${httpTimings.join(', ')}')),
                          Chip(label: Text('dio: ${dioTimings.join(', ')}')),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
