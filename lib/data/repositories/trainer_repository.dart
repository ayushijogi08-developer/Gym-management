import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_client.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/trainer_model.dart';
import 'base_repository.dart';

class TrainerRepository extends BaseRepository<TrainerModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  TrainerRepository() : super(HiveBoxes.trainers, ApiEndpoints.trainers);

  // Helper to get local data directly from the box provided by BaseRepository
  List<TrainerModel> getAllTrainersLocal() => box.values.toList();

  // GET ALL TRAINERS (API-first with local fallback)
  Future<List<TrainerModel>> getAllTrainers({String? search}) async {
    try {
      final response = await ApiClient.get(
        endpoint,
        params: search != null && search.isNotEmpty ? {'search': search} : null,
      );
      
      final List<dynamic> data = response.data['data'];
      final trainers = data.map((json) => TrainerModel.fromJson(json)).toList();
      
      // Update local cache
      await box.clear();
      await box.addAll(trainers);
      
      return trainers;
    } catch (e) {
      print('Error fetching trainers: $e');
      return box.values.toList(); // Return local cache on failure
    }
  } 

  // ADD TRAINER: Ensure we use the super.add method
  Future<void> addTrainer(TrainerModel trainer) async {
    // This will handle both Hive and the background sync queue if BaseRepository supports it
    await super.add(trainer, id: trainer.id);
  }

  // UPDATE TRAINER: Ensure we use the super.update method
  Future<void> updateTrainer(TrainerModel trainer) async {
    // Ensure the ID exists in the box before updating
    await super.update(trainer, id: trainer.id);
  }

  // DELETE TRAINER: Ensure we use the super.delete method
  Future<void> deleteTrainer(String id) async {
    await super.delete(id);
  }

  // GET TRAINER BY ID
  Future<TrainerModel?> getTrainerById(String id) async {
    final local = box.get(id);
    if (local != null) return local;

    try {
      final response = await ApiClient.get('$endpoint/$id');
      final trainer = TrainerModel.fromJson(response.data['data']);
      await box.put(id, trainer); 
      return trainer;
    } catch (e) {
      print('Error fetching trainer: $e');
      return null;
    }
  }
}