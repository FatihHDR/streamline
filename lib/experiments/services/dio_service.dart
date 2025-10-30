import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/experiment_result.dart';

typedef LogCallback = void Function(String message);

class DioService {
  final Dio dio;
  final LogCallback? onLog;

  DioService({this.onLog}) : dio = Dio() {
    // Add an interceptor that reports logs to the optional callback
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        onLog?.call('➡ REQUEST: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        onLog?.call('⬅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (err, handler) {
        onLog?.call('‼ ERROR: ${err.message} ${err.requestOptions.uri}');
        handler.next(err);
      },
    ));
  }

  Future<ExperimentResult> fetchPost(int id) async {
    final sw = Stopwatch()..start();
    try {
      final base = dotenv.env['API_BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';
      final res = await dio.get('$base/posts/$id');
      sw.stop();
      return ExperimentResult(
        success: res.statusCode == 200 || res.statusCode == 201,
        statusCode: res.statusCode ?? 0,
        body: res.data.toString(),
        durationMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      sw.stop();
      return ExperimentResult(success: false, statusCode: 0, body: '', durationMs: sw.elapsedMilliseconds, error: e.toString());
    }
  }

  Future<List<ExperimentResult>> fetchPostAndComments(int postId) async {
    final results = <ExperimentResult>[];
    final postRes = await fetchPost(postId);
    results.add(postRes);
    if (!postRes.success) return results;

    final sw = Stopwatch()..start();
    try {
  final base = dotenv.env['API_BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';
  final res = await dio.get('$base/posts/$postId/comments');
      sw.stop();
      results.add(ExperimentResult(success: res.statusCode == 200 || res.statusCode == 201, statusCode: res.statusCode ?? 0, body: res.data.toString(), durationMs: sw.elapsedMilliseconds));
    } catch (e) {
      sw.stop();
      results.add(ExperimentResult(success: false, statusCode: 0, body: '', durationMs: sw.elapsedMilliseconds, error: e.toString()));
    }

    return results;
  }
}
