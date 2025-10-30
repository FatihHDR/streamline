import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/experiment_result.dart';

class HttpService {
  final http.Client client = http.Client();

  /// Fetch a post from JSONPlaceholder and measure duration with Stopwatch.
  Future<ExperimentResult> fetchPost(int id) async {
    final sw = Stopwatch()..start();
    try {
      final base = _getBaseUrl();
      final res = await client.get(Uri.parse('$base/posts/$id'));
      sw.stop();
      return ExperimentResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        body: res.body,
        durationMs: sw.elapsedMilliseconds,
        error: res.statusCode == 200 ? null : 'HTTP ${res.statusCode}',
      );
    } catch (e) {
      sw.stop();
      return ExperimentResult(
        success: false,
        statusCode: 0,
        body: '',
        durationMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }

  /// Chained example: fetch post then fetch comments for that post
  Future<List<ExperimentResult>> fetchPostAndComments(int postId) async {
    final results = <ExperimentResult>[];
    final postRes = await fetchPost(postId);
    results.add(postRes);
    if (!postRes.success) return results;

    final sw = Stopwatch()..start();
    try {
      final base = _getBaseUrl();
      final res = await client.get(Uri.parse('$base/posts/$postId/comments'));
      sw.stop();
      results.add(ExperimentResult(
        success: res.statusCode == 200,
        statusCode: res.statusCode,
        body: res.body,
        durationMs: sw.elapsedMilliseconds,
        error: res.statusCode == 200 ? null : 'HTTP ${res.statusCode}',
      ));
    } catch (e) {
      sw.stop();
      results.add(ExperimentResult(success: false, statusCode: 0, body: '', durationMs: sw.elapsedMilliseconds, error: e.toString()));
    }

    return results;
  }

  String _getBaseUrl() {
    const fallback = 'https://jsonplaceholder.typicode.com';
    try {
      final v = dotenv.env['API_BASE_URL'];
      if (v == null || v.isEmpty) return fallback;
      return v;
    } catch (_) {
      return fallback;
    }
  }
}
