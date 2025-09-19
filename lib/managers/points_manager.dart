import '../services/points_service.dart';
import '../services/auth_service.dart';
import '../models/points_transaction.dart';
import '../core/logger.dart';
import 'dart:developer' as developer;

/// 积分管理器接口 - 定义积分操作的抽象
abstract class IPointsManager {
  Future<PointsOperationResult> getTransactionHistory(PointsFilter filter);
  Future<PointsOperationResult> getStatistics();
  Future<PointsOperationResult> getUserProfile();
  Future<PointsOperationResult> addTransaction(PointsTransactionRequest request);
}

/// 积分操作结果
class PointsOperationResult {
  final bool success;
  final String? message;
  final dynamic data;
  final String? errorCode;

  PointsOperationResult({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
  });

  factory PointsOperationResult.success(dynamic data, [String? message]) {
    return PointsOperationResult(
      success: true,
      data: data,
      message: message,
    );
  }

  factory PointsOperationResult.failure(String message, [String? errorCode]) {
    return PointsOperationResult(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

/// 积分交易请求
class PointsTransactionRequest {
  final int amount;
  final PointsSource source;
  final String? sourceId;
  final String title;
  final String? description;
  final Map<String, dynamic>? metadata;

  PointsTransactionRequest({
    required this.amount,
    required this.source,
    this.sourceId,
    required this.title,
    this.description,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': amount,
      'source_type': source.value,
      'source_id': sourceId,
      'title': title,
      'description': description,
      'metadata': metadata,
    };
  }
}

/// 积分管理器 - 遵循单一职责原则，直接服务器存储版本
class PointsManager implements IPointsManager {
  final AuthService _authService;
  static const String _tag = 'PointsManager';

  PointsManager(this._authService);

  /// 添加积分记录 - 直接调用服务器API
  Future<bool> addCheckinPoints({
    required int points,
    required String date,
    required int consecutiveDays,
  }) async {
    try {
      developer.log('开始添加签到积分: $points 分', name: 'PointsManager');

      // 直接调用积分API
      final result = await PointsService.addPointsRecord(
        points: points,
        sourceType: 'checkin',
        sourceId: date,
        title: '每日签到',
        description: '连续签到第${consecutiveDays}天',
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('积分API调用超时', name: 'PointsManager');
          return {
            'success': false,
            'message': '网络请求超时，请检查网络连接',
          };
        },
      );

      if (result['success'] == true) {
        // API成功，刷新用户信息
        try {
          await _authService.refreshUserInfo();
          developer.log('积分添加成功并刷新用户信息: $points 分', name: 'PointsManager');
          return true;
        } catch (e) {
          developer.log('积分添加成功但刷新用户信息失败: $e', name: 'PointsManager');
          return true; // 积分已成功添加，刷新失败不影响结果
        }
      } else {
        // API失败
        developer.log('积分API调用失败: ${result['message']}', name: 'PointsManager');
        return false;
      }
    } catch (e) {
      // 异常处理
      developer.log('积分添加异常: $e', name: 'PointsManager');
      return false;
    }
  }

  /// 获取积分交易历史
  @override
  Future<PointsOperationResult> getTransactionHistory(PointsFilter filter) async {
    try {
      AppLogger.info(_tag, '获取积分交易历史', {'filter': filter.toQueryParams()});

      final result = await PointsService.getPointsHistory(
        page: filter.page,
        limit: filter.limit,
        type: filter.type?.value == 1 ? 'earned' : filter.type?.value == 2 ? 'spent' : null,
      );

      if (result['success']) {
        final rawData = result['data'] ?? [];
        final transactions = (rawData is List ? rawData : rawData['records'] ?? [])
            .map<PointsTransaction>((item) => PointsTransaction.fromJson(item))
            .toList();

        AppLogger.info(_tag, '获取积分交易历史成功', {
          'count': transactions.length,
          'total': rawData is Map ? rawData['total'] : transactions.length
        });

        return PointsOperationResult.success({
          'transactions': transactions,
          'total': rawData is Map ? rawData['total'] : transactions.length,
          'page': filter.page,
          'limit': filter.limit,
        }, '获取成功');
      } else {
        AppLogger.error(_tag, '获取积分交易历史失败', result);
        return PointsOperationResult.failure(
          result['message'] ?? '获取失败',
          'API_ERROR'
        );
      }
    } catch (e) {
      AppLogger.error(_tag, '获取积分交易历史异常', {'error': e.toString()});
      return PointsOperationResult.failure('网络错误: $e', 'NETWORK_ERROR');
    }
  }

  /// 获取积分统计数据
  @override
  Future<PointsOperationResult> getStatistics() async {
    try {
      AppLogger.info(_tag, '获取积分统计数据');

      final result = await PointsService.getPointsStatistics();

      if (result['success']) {
        final statistics = PointsStatisticsData.fromJson(result['data']);

        AppLogger.info(_tag, '获取积分统计数据成功', {
          'totalIncome': statistics.totalIncome,
          'totalExpense': statistics.totalExpense,
          'currentBalance': statistics.currentBalance,
        });

        return PointsOperationResult.success(statistics, '获取成功');
      } else {
        AppLogger.error(_tag, '获取积分统计数据失败', result);
        return PointsOperationResult.failure(
          result['message'] ?? '获取失败',
          'API_ERROR'
        );
      }
    } catch (e) {
      AppLogger.error(_tag, '获取积分统计数据异常', {'error': e.toString()});
      return PointsOperationResult.failure('网络错误: $e', 'NETWORK_ERROR');
    }
  }

  /// 获取用户积分概况
  @override
  Future<PointsOperationResult> getUserProfile() async {
    try {
      AppLogger.info(_tag, '获取用户积分概况');

      final result = await PointsService.getUserPoints();

      if (result['success']) {
        AppLogger.info(_tag, '获取用户积分概况成功', result['data']);
        return PointsOperationResult.success(result['data'], '获取成功');
      } else {
        AppLogger.error(_tag, '获取用户积分概况失败', result);
        return PointsOperationResult.failure(
          result['message'] ?? '获取失败',
          'API_ERROR'
        );
      }
    } catch (e) {
      AppLogger.error(_tag, '获取用户积分概况异常', {'error': e.toString()});
      return PointsOperationResult.failure('网络错误: $e', 'NETWORK_ERROR');
    }
  }

  /// 添加积分交易记录
  @override
  Future<PointsOperationResult> addTransaction(PointsTransactionRequest request) async {
    try {
      AppLogger.info(_tag, '添加积分交易记录', request.toJson());

      final result = await PointsService.addPointsRecord(
        points: request.amount,
        sourceType: request.source.value,
        sourceId: request.sourceId,
        title: request.title,
        description: request.description,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          AppLogger.error(_tag, '积分API调用超时');
          return {
            'success': false,
            'message': '网络请求超时，请检查网络连接',
          };
        },
      );

      if (result['success'] == true) {
        try {
          await _authService.refreshUserInfo();
          AppLogger.info(_tag, '添加积分交易记录成功并刷新用户信息', result['data']);
          return PointsOperationResult.success(
            result['data'],
            result['message'] ?? '添加成功'
          );
        } catch (e) {
          AppLogger.warning(_tag, '积分添加成功但刷新用户信息失败', {'error': e.toString()});
          return PointsOperationResult.success(
            result['data'],
            result['message'] ?? '添加成功'
          );
        }
      } else {
        AppLogger.error(_tag, '添加积分交易记录失败', result);
        return PointsOperationResult.failure(
          result['message'] ?? '添加失败',
          'API_ERROR'
        );
      }
    } catch (e) {
      AppLogger.error(_tag, '添加积分交易记录异常', {'error': e.toString()});
      return PointsOperationResult.failure('网络错误: $e', 'NETWORK_ERROR');
    }
  }
}

/// 积分管理器工厂 - 支持依赖注入和测试
class PointsManagerFactory {
  static IPointsManager? _instance;

  static IPointsManager getInstance() {
    return _instance ?? PointsManager(AuthService());
  }

  static void setInstance(IPointsManager instance) {
    _instance = instance;
  }

  static void reset() {
    _instance = null;
  }
}