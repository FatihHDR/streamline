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
      // Build resource URI similar to Dio service: support base that already includes '/products' etc.
      Uri uri;
      try {
        final baseUri = Uri.parse(base);
        final path = baseUri.path;
        final prefix = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        if (path.contains('products') || path.contains('posts')) {
          uri = Uri.parse('$prefix/$id');
        } else {
          uri = Uri.parse('$prefix/posts/$id');
        }
      } catch (_) {
        uri = Uri.parse(base.endsWith('/') ? '$base$id' : '$base/posts/$id');
      }
      final res = await client.get(uri);
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
      Uri commentsUri;
      try {
        final baseUri = Uri.parse(base);
        final path = baseUri.path;
        final prefix = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        if (path.contains('products') || path.contains('posts')) {
          commentsUri = Uri.parse('$prefix/$postId/comments');
        } else {
          commentsUri = Uri.parse('$prefix/posts/$postId/comments');
        }
      } catch (_) {
        final prefix = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        commentsUri = Uri.parse('$prefix/posts/$postId/comments');
      }
      final res = await client.get(commentsUri);
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
    const fallback = 'https://dummyjson.com/products';
    try {
      final v = dotenv.env['API_BASE_URL'] ?? dotenv.env['public_API'] ?? dotenv.env['BASE_URL'];
      if (v == null || v.isEmpty) return fallback;
      return v;
    } catch (_) {
      return fallback;
    }
  }
}
