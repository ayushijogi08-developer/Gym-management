import 'package:flutter/foundation.dart';
import '../data/models/gym_config_model.dart';
import '../data/repositories/gym_config_repository.dart';

class GymConfigProvider extends ChangeNotifier {
  final GymConfigRepository _repo = GymConfigRepository();
  GymConfigModel? _config;
  bool _isLoading = false;
  String? _error;

  GymConfigModel? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (forceRefresh) {
        print('🔄 Force refresh - fetching from API only');
        final freshConfig = await _repo.getConfigFromApi();
        if (freshConfig != null) {
          _config = freshConfig;
          print('✅ Config loaded from API: ${_config?.gymName}');
          print('✅ Branches from API: ${_config?.branches.length}');
          for (var branch in _config?.branches ?? []) {
            print('  - ${branch.name} (${branch.id})');
          }
          notifyListeners();
        }
      } else {
        _config = _repo.getConfigLocal();
        print('📂 Local config: ${_config?.gymName ?? 'null'}');
        print('📂 Local branches: ${_config?.branches.length ?? 0}');
        notifyListeners();

        final freshConfig = await _repo.getConfig();
        if (freshConfig != null) {
          _config = freshConfig;
          print('✅ Config loaded: ${_config?.gymName}');
          print('✅ Branches: ${_config?.branches.length}');
          for (var branch in _config?.branches ?? []) {
            print('  - ${branch.name} (${branch.id})');
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error loading config: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    try {
      await _repo.clearLocalCache();
      print('🗑️ Local cache cleared');
      await loadConfig(forceRefresh: true);
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  Future<void> updateConfig(GymConfigModel newConfig) async {
    try {
      _config = newConfig;
      await _repo.updateConfig(newConfig);
      // ✅ After updating, force refresh from API to confirm
      await loadConfig(forceRefresh: true);
    } catch (e) {
      _error = e.toString();
      debugPrint("Error updating config: $e");
      rethrow;
    }
  }

  Future<void> addBranch(BranchModel newBranch) async {
    try {
      // ✅ Use the repository's addBranch method which handles the full update
      await _repo.addBranch(newBranch);
      // ✅ Force refresh to get latest data from API
      await loadConfig(forceRefresh: true);
      print('✅ Branch added successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint("Error adding branch: $e");
      rethrow;
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      await _repo.deleteBranch(branchId);
      await loadConfig(forceRefresh: true);
      print('✅ Branch deleted successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint("Error deleting branch: $e");
      rethrow;
    }
  }

  Future<void> updateBranch(BranchModel updatedBranch) async {
    try {
      await _repo.updateBranch(updatedBranch);
      await loadConfig(forceRefresh: true);
      print('✅ Branch updated successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint("Error updating branch: $e");
      rethrow;
    }
  }

  int get branchCount => _config?.branches.length ?? 0;
  
  BranchModel? get mainBranch {
    try {
      return _config?.branches.firstWhere((b) => b.isMainBranch);
    } catch (e) {
      return null;
    }
  }

  BranchModel? getBranchById(String id) {
    try {
      return _config?.branches.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}