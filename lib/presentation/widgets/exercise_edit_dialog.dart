import 'package:flutter/material.dart';
import 'package:gym_management_app/presentation/widgets/app_text_field.dart';
import '../../../data/models/exercise_model.dart';


class ExerciseEditDialog extends StatefulWidget {
  final ExerciseModel exercise;
  const ExerciseEditDialog({super.key, required this.exercise});

  @override
  State<ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<ExerciseEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.exerciseName);
    _setsController = TextEditingController(text: widget.exercise.sets.toString());
    _repsController = TextEditingController(text: widget.exercise.reps.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(label: 'Name', controller: _nameController),
          AppTextField(label: 'Sets', controller: _setsController, keyboardType: TextInputType.number),
          AppTextField(label: 'Reps', controller: _repsController, keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            // Create a new updated model
            final updated = ExerciseModel(
              exerciseName: _nameController.text,
              targetMuscle: widget.exercise.targetMuscle,
              sets: int.tryParse(_setsController.text) ?? widget.exercise.sets,
              reps: int.tryParse(_repsController.text) ?? widget.exercise.reps,
              restTimeSeconds: widget.exercise.restTimeSeconds,
              difficulty: widget.exercise.difficulty,
            );
            Navigator.pop(context, updated); // Send back the updated object
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}