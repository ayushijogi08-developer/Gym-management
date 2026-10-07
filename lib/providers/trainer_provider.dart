import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import '../data/models/trainer_model.dart';
import '../data/repositories/trainer_repository.dart';

class TrainerProvider extends ChangeNotifier {
  final TrainerRepository _repository = TrainerRepository();

  List<TrainerModel> _allTrainers = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<TrainerModel> get trainers {
    if (_searchQuery.isEmpty) return _allTrainers;
    final q = _searchQuery.toLowerCase();
    return _allTrainers.where((t) =>
        t.fullName.toLowerCase().contains(q) ||
        t.specialization.toLowerCase().contains(q) ||
        t.workingDays.any((day) => day.toLowerCase().contains(q))).toList();
  } 

  bool get isLoading => _isLoading;
  bool get hasTrainers => _allTrainers.isNotEmpty;
 
  TrainerProvider() {
    loadTrainers();
  }

  Future<void> loadTrainers() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // First try to get from local
      _allTrainers = _repository.getAllTrainersLocal();
      
      // Then refresh from API
      await _repository.getAllTrainers();
      _allTrainers = _repository.getAllTrainersLocal();
      
      print('✅ Trainers loaded: ${_allTrainers.length}');
    } catch (e) {
      print('❌ Error loading trainers: $e');
      _allTrainers = _repository.getAllTrainersLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTrainers() async {
    _allTrainers = [];
    await loadTrainers();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTrainer(TrainerModel trainer) async {
    try {
      final response = await ApiClient.post(
        '/api/trainers',
        data: trainer.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final trainerData = response.data['data'];
        TrainerModel createdTrainer = trainer;
        if (trainerData is Map<String, dynamic>) {
          createdTrainer = TrainerModel.fromJson(trainerData);
        } else if (trainerData is Map) {
          createdTrainer = TrainerModel.fromJson(Map<String, dynamic>.from(trainerData));
        }

        await _repository.addTrainer(createdTrainer);
        
        _allTrainers.removeWhere((t) => t.id == createdTrainer.id || t.email == createdTrainer.email);
        _allTrainers.insert(0, createdTrainer);
        notifyListeners();
      } else {
        final message = response.data?['message'] ?? 'Failed to add trainer';
        throw Exception(message);
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to add trainer';
      debugPrint("Error adding trainer: $message");
      throw Exception(message);
    } catch (e) {
      debugPrint("Error adding trainer: $e");
      rethrow;
    }
  }

  Future<void> updateTrainer(TrainerModel trainer) async {
    try {
      final Map<String, dynamic> data = trainer.toJson();
      data.remove('id'); 
      data.remove('_id'); 

      final response = await ApiClient.put(
        '/api/trainers/${trainer.id}',
        data: data,
      );
      
      if (response.statusCode == 200) {
        final trainerData = response.data['data'];
        TrainerModel updatedTrainer = trainer;
        if (trainerData is Map<String, dynamic>) {
          updatedTrainer = TrainerModel.fromJson(trainerData);
        }

        await _repository.updateTrainer(updatedTrainer);
        
        final idx = _allTrainers.indexWhere((t) => t.id == updatedTrainer.id);
        if (idx != -1) {
          _allTrainers[idx] = updatedTrainer;
        } else {
          _allTrainers.add(updatedTrainer);
        }
        notifyListeners();
      } else {
        final message = response.data?['message'] ?? 'Failed to update trainer';
        throw Exception(message);
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to update trainer';
      debugPrint("Error updating trainer: $message");
      throw Exception(message);
    } catch (e) {
      debugPrint("Error updating trainer: $e");
      rethrow;
    }
  }

  Future<void> deleteTrainer(String id) async {
    try {
      final response = await ApiClient.delete('/api/trainers/$id');
      if (response.statusCode == 200) {
        await _repository.deleteTrainer(id);
        _allTrainers.removeWhere((t) => t.id == id);
        notifyListeners();
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to delete trainer';
      debugPrint("Error deleting trainer: $message");
      throw Exception(message);
    } catch (e) {
      debugPrint("Error deleting trainer: $e");
      rethrow;
    }
  }

  // Get trainer by ID
  TrainerModel? getTrainerById(String id) {
    try {
      return _allTrainers.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get trainer name by ID
  String getTrainerName(String? id) {
    if (id == null || id.isEmpty) return 'Not Assigned';
    try {
      final trainer = _allTrainers.firstWhere((t) => t.id == id);
      return trainer.fullName;
    } catch (e) {
      return 'Unknown Trainer';
    }
  }
}