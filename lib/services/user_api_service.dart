import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class UserApiService {
  static final UserApiService _instance = UserApiService._internal();
  factory UserApiService() => _instance;
  UserApiService._internal();

  final ApiService _apiService = ApiService();

  // 注册用户 - 先保存到本地存储，再发送到服务器
  Future<ApiResponse<User>> register({
    required String studentNumber,
    required String email,
    required String password,
    required String nickname,
    required String realName,
    required String major,
    required int grade,
  }) async {
    try {
      // 1. 先将注册数据保存到本地存储（作为草稿）
      final registrationData = {
        'student_number': studentNumber,
        'email': email,
        'password': password, // 注意：实际应用中不应该存储明文密码
        'nickname': nickname,
        'real_name': realName,
        'major': major,
        'grade': grade,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'draft', // 标记为草稿状态
      };
      
      // 保存到本地存储
      await StorageService.setJson(AppConstants.keyRegistrationDraft, registrationData);
      print('注册数据已保存到本地存储');

      // 2. 构建请求数据
      final requestData = {
        'student_number': studentNumber,
        'email': email,
        'password': password,
        'nickname': nickname,
        'real_name': realName,
        'major': major,
        'grade': grade,
      };

      // 3. 发送HTTP请求到后端API
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/register',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data!;
        
        if (responseData['success'] == true) {
          // 注册成功，更新本地存储状态
          registrationData['status'] = 'completed';
          registrationData['server_response'] = responseData;
          await StorageService.setJson(AppConstants.keyRegistrationDraft, registrationData);
          
          // 解析用户数据
          final userData = responseData['data'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          
          print('注册成功，用户信息已从服务器返回');
          
          // 清除注册草稿
          await StorageService.remove(AppConstants.keyRegistrationDraft);
          
          return ApiResponse.success(user);
        } else {
          // 服务器返回错误
          final errorMessage = responseData['message'] as String? ?? '注册失败';
          
          // 更新本地存储状态为失败
          registrationData['status'] = 'failed';
          registrationData['error'] = errorMessage;
          await StorageService.setJson(AppConstants.keyRegistrationDraft, registrationData);
          
          return ApiResponse.error(errorMessage);
        }
      } else {
        // HTTP状态码不是201
        final errorMessage = '服务器响应错误: ${response.statusCode}';
        
        // 更新本地存储状态为失败
        registrationData['status'] = 'failed';
        registrationData['error'] = errorMessage;
        await StorageService.setJson(AppConstants.keyRegistrationDraft, registrationData);
        
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      // 网络错误
      String errorMessage = '网络错误';
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        errorMessage = errorData['message'] as String? ?? errorMessage;
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      // 更新本地存储状态为失败
      try {
        final existingDraft = StorageService.getJson(AppConstants.keyRegistrationDraft);
        if (existingDraft != null) {
          existingDraft['status'] = 'failed';
          existingDraft['error'] = errorMessage;
          await StorageService.setJson(AppConstants.keyRegistrationDraft, existingDraft);
        }
      } catch (storageError) {
        print('更新本地存储失败: $storageError');
      }
      
      return ApiResponse.error(errorMessage);
    } catch (e) {
      // 其他错误
      final errorMessage = '注册过程中发生未知错误: $e';
      
      // 更新本地存储状态为失败
      try {
        final existingDraft = StorageService.getJson(AppConstants.keyRegistrationDraft);
        if (existingDraft != null) {
          existingDraft['status'] = 'failed';
          existingDraft['error'] = errorMessage;
          await StorageService.setJson(AppConstants.keyRegistrationDraft, existingDraft);
        }
      } catch (storageError) {
        print('更新本地存储失败: $storageError');
      }
      
      return ApiResponse.error(errorMessage);
    }
  }

  // 用户登录
  Future<ApiResponse<LoginResponse>> login({
    required String account,
    required String password,
  }) async {
    try {
      final requestData = {
        'account': account,
        'password': password,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData != null && responseData['success'] == true) {
          // 安全地获取登录数据
          final dataField = responseData['data'];
          if (dataField != null && dataField is Map<String, dynamic>) {
            try {
              // 打印原始数据结构进行调试
              print('原始数据结构: ${dataField.keys.toList()}');
              
              // 尝试各种可能的字段名
              final token = dataField['token'] as String?;
              final userField = dataField['user'] ?? dataField['User'];
              final userProfileField = dataField['userProfile'] ?? dataField['user_profile'] ?? dataField['UserProfile'];
              
              print('提取的字段: token=$token, user类型=${userField.runtimeType}, profile类型=${userProfileField.runtimeType}');
              
              // 更严格的空值检查
              if (token != null && token.isNotEmpty && 
                  userField != null && userField is Map<String, dynamic> && 
                  userProfileField != null && userProfileField is Map<String, dynamic>) {
                
                print('开始解析用户数据...');
                print('用户字段: ${userField.keys.toList()}');
                print('用户资料字段: ${userProfileField.keys.toList()}');
                
                // 在解析前验证必需字段不为null
                final requiredUserFields = ['id', 'student_number', 'email', 'nickname', 'real_name', 'major', 'grade', 'status', 'created_at', 'updated_at'];
                // 服务器返回的是驼峰命名，修正字段名
                final requiredProfileFields = ['userId', 'totalPoints', 'level', 'postsCount', 'commentsCount', 'likesReceived', 'createdAt', 'updatedAt'];
                
                for (String field in requiredUserFields) {
                  if (!userField.containsKey(field) || userField[field] == null) {
                    print('用户数据缺失必需字段: $field');
                    return ApiResponse.error('用户数据不完整：缺失字段 $field');
                  }
                }
                
                for (String field in requiredProfileFields) {
                  if (!userProfileField.containsKey(field) || userProfileField[field] == null) {
                    print('用户资料数据缺失必需字段: $field');
                    return ApiResponse.error('用户资料数据不完整：缺失字段 $field');
                  }
                }
                
                final user = User.fromJson(userField);
                final userProfile = UserProfile.fromJson(userProfileField);
                
                final loginResponse = LoginResponse(
                  token: token,
                  user: user,
                  userProfile: userProfile,
                );
                
                // 保存登录信息到本地存储
                await StorageService.setString(AppConstants.keyToken, loginResponse.token);
                await StorageService.setString(AppConstants.keyUserId, loginResponse.user.id);
                await StorageService.setJson(AppConstants.keyUserInfo, {
                  'user': loginResponse.user.toJson(),
                  'profile': loginResponse.userProfile.toJson(),
                });
                
                print('登录成功，数据已保存');
                return ApiResponse.success(loginResponse);
              } else {
                print('字段验证失败:');
                print('  - token: $token (长度: ${token?.length ?? 0})');
                print('  - userField类型: ${userField.runtimeType}, 为null: ${userField == null}');
                print('  - userProfileField类型: ${userProfileField.runtimeType}, 为null: ${userProfileField == null}');
                print('  - 完整dataField内容: $dataField');
                return ApiResponse.error('服务器返回数据格式错误');
              }
            } catch (parseError) {
              print('解析登录数据失败: $parseError');
              print('堆栈跟踪: ${StackTrace.current}');
              return ApiResponse.error('解析登录数据失败: $parseError');
            }
          } else {
            return ApiResponse.error('服务器返回数据为空');
          }
        } else {
          final errorMessage = responseData?['message'] as String? ?? '登录失败';
          return ApiResponse.error(errorMessage);
        }
      } else {
        return ApiResponse.error('服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = '网络错误';
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        errorMessage = errorData['message'] as String? ?? errorMessage;
      }
      return ApiResponse.error(errorMessage);
    } catch (e) {
      return ApiResponse.error('登录过程中发生未知错误: $e');
    }
  }

  // 检查学号是否存在
  Future<ApiResponse<bool>> checkStudentNumber(String studentNumber) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/auth/check-student-number',
        queryParameters: {'student_number': studentNumber},
      );

      if (response.statusCode == 200) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          final exists = responseData['data']['exists'] as bool;
          return ApiResponse.success(exists);
        }
      }
      
      return ApiResponse.error('检查学号失败');
    } catch (e) {
      return ApiResponse.error('网络错误: $e');
    }
  }

  // 检查邮箱是否存在
  Future<ApiResponse<bool>> checkEmail(String email) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/auth/check-email',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          final exists = responseData['data']['exists'] as bool;
          return ApiResponse.success(exists);
        }
      }
      
      return ApiResponse.error('检查邮箱失败');
    } catch (e) {
      return ApiResponse.error('网络错误: $e');
    }
  }

  // 获取注册草稿数据
  Map<String, dynamic>? getRegistrationDraft() {
    return StorageService.getJson(AppConstants.keyRegistrationDraft);
  }

  // 清除注册草稿数据
  Future<bool> clearRegistrationDraft() {
    return StorageService.remove(AppConstants.keyRegistrationDraft);
  }

  // 更新用户资料 - 调用服务器API
  Future<ApiResponse<LoginResponse>> updateProfile({
    String? nickname,
    String? phone,
    String? bio,
    String? location,
    List<String>? interests,
    Map<String, String>? socialLinks,
  }) async {
    try {
      print('开始通过API更新用户资料...');
      
      // 确保API服务已初始化
      _apiService.init();
      
      final requestData = <String, dynamic>{};
      
      // 只包含需要更新的字段
      if (nickname != null) requestData['nickname'] = nickname;
      if (phone != null) requestData['phone'] = phone;
      if (bio != null) requestData['bio'] = bio;
      if (location != null) requestData['location'] = location;
      if (interests != null) requestData['interests'] = interests;
      if (socialLinks != null) requestData['socialLinks'] = socialLinks;

      print('请求数据: $requestData');
      print('API基础URL: ${_apiService.dio.options.baseUrl}');
      
      // 检查当前token
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null || token.isEmpty) {
        return ApiResponse.error('用户未登录，请重新登录');
      }
      print('当前token: ${token.substring(0, 20)}...');

      final response = await _apiService.put<Map<String, dynamic>>(
        '/user/profile',
        data: requestData,
      );

      print('服务器响应状态码: ${response.statusCode}');
      print('服务器响应数据: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData != null && responseData['success'] == true) {
          print('服务器确认更新成功');
          
          // 安全地获取更新后的数据
          final dataField = responseData['data'];
          if (dataField != null && dataField is Map<String, dynamic>) {
            try {
              // 解析更新后的用户数据
              final token = dataField['token'] as String?;
              final userField = dataField['user'] ?? dataField['User'];
              final userProfileField = dataField['userProfile'] ?? dataField['user_profile'] ?? dataField['UserProfile'];
              
              print('解析数据字段: token=${token != null}, user=${userField != null}, profile=${userProfileField != null}');
              
              if (token != null && token.isNotEmpty && 
                  userField != null && userField is Map<String, dynamic> && 
                  userProfileField != null && userProfileField is Map<String, dynamic>) {
                
                final user = User.fromJson(userField);
                final userProfile = UserProfile.fromJson(userProfileField);
                
                final loginResponse = LoginResponse(
                  token: token,
                  user: user,
                  userProfile: userProfile,
                );
                
                // 更新本地存储
                await StorageService.setString(AppConstants.keyToken, loginResponse.token);
                await StorageService.setString(AppConstants.keyUserId, loginResponse.user.id);
                await StorageService.setJson(AppConstants.keyUserInfo, {
                  'user': loginResponse.user.toJson(),
                  'profile': loginResponse.userProfile.toJson(),
                });
                
                print('本地存储更新完成，数据已保存到服务器数据库');
                return ApiResponse.success(loginResponse);
              } else {
                print('服务器数据格式验证失败');
                return ApiResponse.error('服务器返回数据格式错误');
              }
            } catch (parseError) {
              print('解析服务器数据失败: $parseError');
              return ApiResponse.error('解析更新数据失败: $parseError');
            }
          } else {
            print('服务器未返回数据字段');
            return ApiResponse.error('服务器返回数据为空');
          }
        } else {
          final errorMessage = responseData?['message'] as String? ?? '更新失败';
          print('服务器返回错误: $errorMessage');
          return ApiResponse.error(errorMessage);
        }
      } else {
        print('HTTP状态码错误: ${response.statusCode}');
        return ApiResponse.error('服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('网络请求异常: ${e.type}');
      print('错误消息: ${e.message}');
      print('响应数据: ${e.response?.data}');
      print('状态码: ${e.response?.statusCode}');
      
      String errorMessage = '网络错误';
      
      // 更详细的错误分析
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = '请求超时，请检查网络连接';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '网络连接失败，请检查网络设置';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = '登录已过期，请重新登录';
          } else if (e.response?.statusCode == 400) {
            // 尝试从响应中获取具体错误信息
            if (e.response?.data != null && e.response!.data is Map) {
              final errorData = e.response!.data as Map<String, dynamic>;
              errorMessage = errorData['message'] as String? ?? '请求参数错误';
            } else {
              errorMessage = '请求参数错误';
            }
          } else if (e.response?.statusCode == 500) {
            errorMessage = '服务器内部错误，请稍后重试';
          } else {
            errorMessage = '服务器错误: ${e.response?.statusCode}';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        case DioExceptionType.unknown:
          errorMessage = '未知网络错误，请稍后重试';
          break;
        default:
          if (e.response?.data != null && e.response!.data is Map) {
            final errorData = e.response!.data as Map<String, dynamic>;
            errorMessage = errorData['message'] as String? ?? errorMessage;
          }
      }
      
      return ApiResponse.error(errorMessage);
    } catch (e) {
      print('更新过程中发生未知错误: $e');
      return ApiResponse.error('更新过程中发生未知错误，请稍后重试');
    }
  }

  // 用户登出
  Future<ApiResponse<void>> logout() async {
    try {
      // 发送登出请求到服务器
      await _apiService.post('/auth/logout');
      
      // 清除本地存储
      await StorageService.remove(AppConstants.keyToken);
      await StorageService.remove(AppConstants.keyUserId);
      await StorageService.remove(AppConstants.keyUserInfo);
      
      return ApiResponse.success(null);
    } catch (e) {
      // 即使服务器请求失败，也要清除本地存储
      await StorageService.remove(AppConstants.keyToken);
      await StorageService.remove(AppConstants.keyUserId);
      await StorageService.remove(AppConstants.keyUserInfo);
      
      return ApiResponse.success(null);
    }
  }
}

// API响应包装类
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : isSuccess = true, error = null;
  ApiResponse.error(this.error) : isSuccess = false, data = null;
}