import 'package:get/get.dart';
import '../models/experiment_result.dart';
import '../services/http_service.dart';
import '../services/dio_service.dart';

class ExperimentController extends GetxController {
  final HttpService httpService = HttpService();
  late final DioService dioService;

  ExperimentController() {
    dioService = DioService(onLog: (msg) {
      dioLogs.add(msg);
      update();
    });
  }

  var isRunning = false.obs;
  var iterations = 5.obs;

  // results
  final List<int> httpTimings = <int>[];
  final List<int> dioTimings = <int>[];
  final List<String> httpErrors = <String>[];
  final List<String> dioErrors = <String>[];

  final List<String> dioLogs = <String>[];

  void clear() {
    httpTimings.clear();
    dioTimings.clear();
    httpErrors.clear();
    dioErrors.clear();
    dioLogs.clear();
    update();
  }

  Future<void> runComparison({int iters = 5}) async {
    isRunning.value = true;
    clear();
    iterations.value = iters;

    for (var i = 0; i < iters; i++) {
      final id = (i % 100) + 1; // JSONPlaceholder has 100 posts

      final httpRes = await httpService.fetchPost(id);
      httpTimings.add(httpRes.durationMs);
      if (!httpRes.success) httpErrors.add(httpRes.error ?? 'unknown');

      final dioRes = await dioService.fetchPost(id);
      dioTimings.add(dioRes.durationMs);
      if (!dioRes.success) dioErrors.add(dioRes.error ?? 'unknown');

      update();
    }

    isRunning.value = false;
    update();
  }

  // Chained scenario using async/await
  Future<List<ExperimentResult>> chainedAsyncAwait(int postId) async {
    return await httpService.fetchPostAndComments(postId);
  }

  // Chained scenario implemented with callbacks (then)
  Future<List<ExperimentResult>> chainedCallbacks(int postId) async {
    final results = <ExperimentResult>[];
    return httpService.fetchPost(postId).then((postRes) {
      results.add(postRes);
      if (!postRes.success) return results;
      return httpService.fetchPostAndComments(postId).then((commentResList) {
        // fetchPostAndComments already includes post + comments, but we append for demonstration
        results.addAll(commentResList);
        return results;
      });
    }).catchError((e) {
      // wrap error as ExperimentResult
      results.add(ExperimentResult(success: false, statusCode: 0, body: '', durationMs: 0, error: e.toString()));
      return results;
    });
  }
}
