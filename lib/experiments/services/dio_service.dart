import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/experiment_result.dart';

typedef LogCallback = void Function(String message);

class DioService {
  final Dio dio;
  final LogCallback? onLog;

  DioService({this.onLog}) : dio = Dio() {
    // Add an interceptor that reports logs to the optional callback
    // Allow returning non-2xx responses instead of throwing, so experiments can measure status codes like 403
    dio.options.validateStatus = (status) => true;

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
        // Log error details. If there's a response available include status and body
        try {
          final status = err.response?.statusCode;
          final body = err.response?.data?.toString();
          if (status != null) {
            onLog?.call('‼ ERROR RESPONSE: $status ${err.requestOptions.uri} - ${body ?? ''}');
          } else {
            onLog?.call('‼ ERROR: ${err.message} ${err.requestOptions.uri}');
          }
        } catch (_) {
          onLog?.call('‼ ERROR (unknown) ${err.requestOptions.uri}');
        }
        handler.next(err);
      },
    ));
  }

  Future<ExperimentResult> fetchPost(int id) async {
    final sw = Stopwatch()..start();
    try {
      final base = _getBaseUrl();
      final res = await dio.get('$base/posts/$id');
      sw.stop();
      return ExperimentResult(
        success: res.statusCode == 200 || res.statusCode == 201,
        statusCode: res.statusCode ?? 0,
        body: res.data?.toString() ?? '',
        durationMs: sw.elapsedMilliseconds,
        error: (res.statusCode != 200 && res.statusCode != 201) ? 'HTTP ${res.statusCode}' : null,
      );
    } catch (e) {
      sw.stop();
      try {
        if (e is DioError) {
          final sc = e.response?.statusCode ?? 0;
          final body = e.response?.data?.toString() ?? '';
          onLog?.call('‼ EXCEPTION: ${e.type} - status:$sc - ${body.isNotEmpty ? body : e.message}');
          return ExperimentResult(success: false, statusCode: sc, body: body, durationMs: sw.elapsedMilliseconds, error: e.message);
        }
      } catch (_) {}

      onLog?.call('‼ EXCEPTION: ${e.toString()}');
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
  final base = _getBaseUrl();
  final res = await dio.get('$base/posts/$postId/comments');
      sw.stop();
      results.add(ExperimentResult(success: res.statusCode == 200 || res.statusCode == 201, statusCode: res.statusCode ?? 0, body: res.data?.toString() ?? '', durationMs: sw.elapsedMilliseconds, error: (res.statusCode != 200 && res.statusCode != 201) ? 'HTTP ${res.statusCode}' : null));
    } catch (e) {
      sw.stop();
      try {
        if (e is DioError) {
          final sc = e.response?.statusCode ?? 0;
          final body = e.response?.data?.toString() ?? '';
          onLog?.call('‼ EXCEPTION: ${e.type} - status:$sc - ${body.isNotEmpty ? body : e.message}');
          results.add(ExperimentResult(success: false, statusCode: sc, body: body, durationMs: sw.elapsedMilliseconds, error: e.message));
          return results;
        }
      } catch (_) {}

      onLog?.call('‼ EXCEPTION: ${e.toString()}');
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
      // If dotenv wasn't initialized, return fallback instead of throwing
      return fallback;
    }
  }
}
