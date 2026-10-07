import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import 'package:gym_management_app/providers/member_provider.dart';
import 'package:provider/provider.dart';
import '../data/models/app_user_model.dart';
import '../data/repositories/app_user_repository.dart';
import '../domain/entities/user_role.dart';
import '../utils/permissions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/trainer_model.dart'; 
import '../data/repositories/trainer_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AppUserRepository _repository = AppUserRepository();
  final TrainerRepository _trainerRepository = TrainerRepository();
  final _storage = const FlutterSecureStorage();
  AppUserModel? _currentUser;

  AppUserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  UserRole get currentRole {
    if (_currentUser == null) return UserRole.member;
    return UserRole.values.firstWhere(
      (r) => r.name == _currentUser!.role,
      orElse: () => UserRole.member,
    );
  }

  Future<TrainerModel?> get currentTrainerAsync {
    if (currentRole != UserRole.trainer || _currentUser?.linkedTrainerId == null) {
      return Future.value(null);
    }
    return _trainerRepository.getTrainerById(_currentUser!.linkedTrainerId!);
  }
  
  AuthProvider() {
    _loadPersistedUser();
  }

  String _hashPassword(String password) {
    return password;
  }

  Future<bool> login(String email, String password) async {
    try {
      print("Sending login request to: ${ApiEndpoints.login}");
      final response = await ApiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        print("=== LOGIN RESPONSE ===");
        print("User data: ${data['user']}");
        print("linkedMemberId: ${data['user']['linkedMemberId']}");
        print("======================");
        
        await _storage.write(key: 'jwt_token', value: data['token']);

        _currentUser = AppUserModel.fromJson(data['user']);
        
        print("Current User linkedMemberId: ${_currentUser?.linkedMemberId}");
        
        notifyListeners();
        print("Login SUCCESS. Current User: ${_currentUser?.name}");
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        print("DIO ERROR: ${e.response?.data}");
        print("DIO ERROR MESSAGE: ${e.message}");
        print("DIO ERROR TYPE: ${e.type}");
        print("DIO ERROR ERROR: ${e.error}");
      } else {
        print("LOGIN EXCEPTION: $e");
      }
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      print('🔑 Token exists for change password: ${token != null}');
      
      if (token == null) {
        print('❌ No token found! User may not be logged in.');
        return false;
      }

      final response = await ApiClient.put(
        ApiEndpoints.changePassword,
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );

      print('📡 Change password response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            mustChangePassword: false,
          );
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Change password error: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        
        if (e.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
          _currentUser = null;
          notifyListeners();
        }
      }
      return false;
    }
  }

  Future<String?> resetMemberPassword(String userId) async {
    return await _repository.resetPassword(userId);
  }

  Future<void> logout(BuildContext context) async {
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    
    final settingsBox = Hive.box(HiveBoxes.settings);
    await settingsBox.delete('current_user_id');
    await settingsBox.delete('remember_me');

    context.read<MemberProvider>().loadMembers(); 
    notifyListeners(); 
  }

  bool hasPermission(String permissionKey) {
    if (_currentUser == null) return false;
    return Permissions.hasPermission(_currentUser, permissionKey);
  }

  Future<void> _persistCurrentUser(String userId) async {
    final settingsBox = Hive.box(HiveBoxes.settings);
    await settingsBox.put('current_user_id', userId);
    await settingsBox.put('remember_me', true);
  }

  Future<void> _clearPersistedUser() async {
    final settingsBox = Hive.box(HiveBoxes.settings);
    await settingsBox.delete('current_user_id');
    await settingsBox.delete('remember_me');
  }

  Future<void> loadPersistedUserFromToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        final response = await ApiClient.get(ApiEndpoints.me);
        if (response.statusCode == 200) {
          _currentUser = AppUserModel.fromJson(response.data['user']);
          notifyListeners();
          print("Persisted user loaded: ${_currentUser?.name}");
        }
      } catch (e) {
        print("Failed to load persisted user: $e");
        await _storage.delete(key: 'jwt_token');
      }
    }
  }

  Future<void> _loadPersistedUser() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      print("DEBUG: Loading user from storage. ID: ${_currentUser?.id}, MemberID: ${_currentUser?.linkedMemberId}");
      await loadPersistedUserFromToken();
    }
  }

  TrainerModel? get currentTrainer {
    if (currentRole != UserRole.trainer || _currentUser?.linkedTrainerId == null) {
      return null;
    }
    return _trainerRepository.box.get(_currentUser!.linkedTrainerId!);
  }

  Future<List<AppUserModel>> getUsersByRole([String role = '']) async {
    final allUsers = await _repository.getAllUsersFromApi();
    if (role.isEmpty) {
      return allUsers;
    }
    return allUsers.where((u) => u.role == role).toList();
  }

  Future<void> deleteUser(String userId) async {
    await _repository.deleteUser(userId);
    notifyListeners();
  }

  Future<void> updateUserBasicInfo(AppUserModel user) async {
    await _repository.updateUser(user);
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
    notifyListeners();
  }

  // ✅ FIXED: Now sends assignedBranchId to the backend
  Future<void> createUser(AppUserModel user) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.register,
        data: {
          'fullName': user.name,
          'email': user.email,
          'phone': user.phone ?? '0000000000',
          'password': user.passwordHash,
          'role': user.role,
          // ✅ ADD THIS LINE BELOW
          'branchId': user.assignedBranchId, 
        },
      );

      if (response.statusCode == 201) {
        await _repository.addUser(user);
        notifyListeners();
        print("User registered in MongoDB!");
      }
    } catch (e) {
      print("REGISTRATION FAILED: $e");
    }
  }
}