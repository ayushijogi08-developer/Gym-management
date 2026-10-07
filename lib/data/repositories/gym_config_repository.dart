import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import 'package:hive/hive.dart';
import '../models/gym_config_model.dart';
import 'base_repository.dart';

class GymConfigRepository extends BaseRepository<GymConfigModel> {
  GymConfigRepository() : super(HiveBoxes.gymConfig, ApiEndpoints.gymConfig);

  // ✅ Clear local cache
  Future<void> clearLocalCache() async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await box.delete('global_config');
        print('✅ Local cache cleared');
      }
    } catch (e) {
      print('⚠️ Error clearing cache: $e');
    }
  }

  GymConfigModel? getConfigLocal() {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        return null;
      }
      return box.get('global_config');
    } catch (e) {
      print('⚠️ Error reading local config: $e');
      return null;
    }
  }

  // ✅ Get config directly from API (skip local cache)
  Future<GymConfigModel?> getConfigFromApi() async {
    try {
      print('📡 Fetching gym config from API (force refresh)...');
      final response = await ApiClient.get(endpoint);
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.data != null && response.data['data'] != null) {
        final config = GymConfigModel.fromJson(response.data['data']);
        print('✅ Config parsed: ${config.gymName}');
        print('✅ Branches: ${config.branches.length}');
        
        // Save to local cache
        try {
          if (!Hive.isBoxOpen(boxName)) {
            await Hive.openBox<GymConfigModel>(boxName);
          }
          await box.put('global_config', config);
          print('✅ Saved to local cache');
        } catch (e) {
          print('⚠️ Error saving to local cache: $e');
        }
        return config;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching gym config from API: $e');
      return null;
    }
  }

  // GET CONFIG (Fetch from API, cache locally)
  Future<GymConfigModel?> getConfig() async {
    try {
      print('📡 Fetching gym config from API...');
      final response = await ApiClient.get(endpoint);
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.data != null && response.data['data'] != null) {
        final config = GymConfigModel.fromJson(response.data['data']);
        print('✅ Config parsed: ${config.gymName}');
        print('✅ Branches: ${config.branches.length}');
        
        // Save to local cache
        try {
          if (!Hive.isBoxOpen(boxName)) {
            await Hive.openBox<GymConfigModel>(boxName);
          }
          await box.put('global_config', config);
          print('✅ Saved to local cache');
        } catch (e) {
          print('⚠️ Error saving to local cache: $e');
        }
        return config;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching gym config: $e');
      return getConfigLocal();
    }
  }

  // UPDATE CONFIG
// UPDATE CONFIG - Make sure it properly saves
Future<void> updateConfig(GymConfigModel config) async {
  try {
    print('📝 Updating gym config...');
    print('📝 Branches count: ${config.branches.length}');
    
    // Save locally first
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<GymConfigModel>(boxName);
      }
      await box.put('global_config', config);
      print('✅ Saved to local cache');
    } catch (e) {
      print('⚠️ Error saving to local: $e');
    }
    
    // ✅ Send to API - this is what saves to MongoDB
    print('📡 Sending to API: ${config.toJson()}');
    final response = await ApiClient.put(
      endpoint,
      data: config.toJson(),
    );
    
    print('✅ Config updated on server: ${response.statusCode}');
    print('✅ Server response: ${response.data}');
    
    // Refresh local cache with server response
    if (response.data != null && response.data['data'] != null) {
      final updatedConfig = GymConfigModel.fromJson(response.data['data']);
      await box.put('global_config', updatedConfig);
      print('✅ Local cache updated with server response');
      print('✅ Branches from server: ${updatedConfig.branches.length}');
    }
  } catch (e) {
    print('❌ Error updating config: $e');
    rethrow;
  }
}

  // ADD BRANCH
  Future<void> addBranch(BranchModel newBranch) async {
    try {
      final currentConfig = await getConfig();
      if (currentConfig == null) {
        throw Exception('Config not loaded');
      }
      
      final updatedBranches = List<BranchModel>.from(currentConfig.branches);
      
      if (newBranch.isMainBranch) {
        for (var branch in updatedBranches) {
          branch.isMainBranch = false;
        }
      }
      
      updatedBranches.add(newBranch);
      
      final updatedConfig = GymConfigModel(
        gymName: currentConfig.gymName,
        logoPath: currentConfig.logoPath,
        address: currentConfig.address,
        contactPhone: currentConfig.contactPhone,
        contactEmail: currentConfig.contactEmail,
        workingDays: currentConfig.workingDays,
        openingTime: currentConfig.openingTime,
        closingTime: currentConfig.closingTime,
        taxPercent: currentConfig.taxPercent,
        currencySymbol: currentConfig.currencySymbol,
        currencyCode: currentConfig.currencyCode,
        themeMode: currentConfig.themeMode,
        branches: updatedBranches,
      );
      
      await updateConfig(updatedConfig);
      print('✅ Branch "${newBranch.name}" added successfully');
    } catch (e) {
      print('❌ Error adding branch: $e');
      rethrow;
    }
  }

  // DELETE BRANCH
  Future<void> deleteBranch(String branchId) async {
    try {
      final currentConfig = await getConfig();
      if (currentConfig == null) {
        throw Exception('Config not loaded');
      }
      
      final updatedBranches = currentConfig.branches
          .where((b) => b.id != branchId)
          .toList();
      
      final updatedConfig = GymConfigModel(
        gymName: currentConfig.gymName,
        logoPath: currentConfig.logoPath,
        address: currentConfig.address,
        contactPhone: currentConfig.contactPhone,
        contactEmail: currentConfig.contactEmail,
        workingDays: currentConfig.workingDays,
        openingTime: currentConfig.openingTime,
        closingTime: currentConfig.closingTime,
        taxPercent: currentConfig.taxPercent,
        currencySymbol: currentConfig.currencySymbol,
        currencyCode: currentConfig.currencyCode,
        themeMode: currentConfig.themeMode,
        branches: updatedBranches,
      );
      
      await updateConfig(updatedConfig);
      print('✅ Branch deleted successfully');
    } catch (e) {
      print('❌ Error deleting branch: $e');
      rethrow;
    }
  }

  // UPDATE BRANCH
  Future<void> updateBranch(BranchModel updatedBranch) async {
    try {
      final currentConfig = await getConfig();
      if (currentConfig == null) {
        throw Exception('Config not loaded');
      }
      
      final updatedBranches = List<BranchModel>.from(currentConfig.branches);
      
      if (updatedBranch.isMainBranch) {
        for (var branch in updatedBranches) {
          branch.isMainBranch = false;
        }
      }
      
      final index = updatedBranches.indexWhere((b) => b.id == updatedBranch.id);
      if (index != -1) {
        updatedBranches[index] = updatedBranch;
      }
      
      final updatedConfig = GymConfigModel(
        gymName: currentConfig.gymName,
        logoPath: currentConfig.logoPath,
        address: currentConfig.address,
        contactPhone: currentConfig.contactPhone,
        contactEmail: currentConfig.contactEmail,
        workingDays: currentConfig.workingDays,
        openingTime: currentConfig.openingTime,
        closingTime: currentConfig.closingTime,
        taxPercent: currentConfig.taxPercent,
        currencySymbol: currentConfig.currencySymbol,
        currencyCode: currentConfig.currencyCode,
        themeMode: currentConfig.themeMode,
        branches: updatedBranches,
      );
      
      await updateConfig(updatedConfig);
      print('✅ Branch "${updatedBranch.name}" updated successfully');
    } catch (e) {
      print('❌ Error updating branch: $e');
      rethrow;
    }
  }
}