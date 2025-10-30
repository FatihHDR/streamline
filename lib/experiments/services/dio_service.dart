import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
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
    final reqMsg = '➡ REQUEST: ${options.method} ${options.uri}';
    // print to terminal and optional callback
    debugPrint('DIO: $reqMsg');
    onLog?.call(reqMsg);
        handler.next(options);
      },
      onResponse: (response, handler) {
  final resMsg = '⬅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}';
  debugPrint('DIO: $resMsg');
  onLog?.call(resMsg);
        handler.next(response);
      },
      onError: (err, handler) {
        // Log error details. If there's a response available include status and body
        try {
          final status = err.response?.statusCode;
          final body = err.response?.data?.toString();
          if (status != null) {
            final msg = '‼ ERROR RESPONSE: $status ${err.requestOptions.uri} - ${body ?? ''}';
            debugPrint('DIO: $msg');
            onLog?.call(msg);
          } else {
            final msg = '‼ ERROR: ${err.message} ${err.requestOptions.uri}';
            debugPrint('DIO: $msg');
            onLog?.call(msg);
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
  final uri = _buildResourceUri(base, 'posts', id);
  final res = await dio.getUri(uri);
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
          final msg = '‼ EXCEPTION: ${e.type} - status:$sc - ${body.isNotEmpty ? body : e.message}';
          debugPrint('DIO: $msg');
          onLog?.call(msg);
          return ExperimentResult(success: false, statusCode: sc, body: body, durationMs: sw.elapsedMilliseconds, error: e.message);
        }
      } catch (_) {}

      final exMsg = '‼ EXCEPTION: ${e.toString()}';
      debugPrint('DIO: $exMsg');
      onLog?.call(exMsg);
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
  // Build comments URI: if base already contains resource segment (products/posts)
  // append '/{id}/comments', otherwise use '/posts/{id}/comments'.
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
  final res = await dio.getUri(commentsUri);
      sw.stop();
      results.add(ExperimentResult(success: res.statusCode == 200 || res.statusCode == 201, statusCode: res.statusCode ?? 0, body: res.data?.toString() ?? '', durationMs: sw.elapsedMilliseconds, error: (res.statusCode != 200 && res.statusCode != 201) ? 'HTTP ${res.statusCode}' : null));
    } catch (e) {
      sw.stop();
      try {
        if (e is DioError) {
          final sc = e.response?.statusCode ?? 0;
          final body = e.response?.data?.toString() ?? '';
          final msg = '‼ EXCEPTION: ${e.type} - status:$sc - ${body.isNotEmpty ? body : e.message}';
          debugPrint('DIO: $msg');
          onLog?.call(msg);
          results.add(ExperimentResult(success: false, statusCode: sc, body: body, durationMs: sw.elapsedMilliseconds, error: e.message));
          return results;
        }
      } catch (_) {}

      final exMsg = '‼ EXCEPTION: ${e.toString()}';
      debugPrint('DIO: $exMsg');
      onLog?.call(exMsg);
      results.add(ExperimentResult(success: false, statusCode: 0, body: '', durationMs: sw.elapsedMilliseconds, error: e.toString()));
    }

    return results;
  }

  String _getBaseUrl() {
    const fallback = 'https://dummyjson.com/products';
    try {
      // Support multiple env keys: prefer explicit API_BASE_URL, otherwise public_API
      final v = dotenv.env['API_BASE_URL'] ?? dotenv.env['public_API'] ?? dotenv.env['BASE_URL'];
      if (v == null || v.isEmpty) return fallback;
      return v;
    } catch (_) {
      // If dotenv wasn't initialized, return fallback instead of throwing
      return fallback;
    }
  }

  /// Build a Uri for a resource id. If the base already contains a resource
  /// segment (e.g. ends with '/products' or '/posts'), use that and append
  /// '/{id}'. Otherwise use the defaultResource (e.g. 'posts').
  Uri _buildResourceUri(String base, String defaultResource, int id) {
    try {
      final baseUri = Uri.parse(base);
      final path = baseUri.path; // may be '/products' or '/'
      if (path.contains('products') || path.contains('posts')) {
        // ensure we don't duplicate slashes
        final prefix = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        return Uri.parse('$prefix/$id');
      } else {
        final prefix = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        return Uri.parse('$prefix/$defaultResource/$id');
      }
    } catch (_) {
      // fallback: try simple concatenation
      if (base.endsWith('/')) return Uri.parse('$base$id');
      return Uri.parse('$base/$defaultResource/$id');
    }
  }
}
