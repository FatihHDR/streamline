class ExperimentResult {
  final bool success;
  final int statusCode;
  final String body;
  final int durationMs;
  final String? error;

  ExperimentResult({
    required this.success,
    required this.statusCode,
    required this.body,
    required this.durationMs,
    this.error,
  });
}
