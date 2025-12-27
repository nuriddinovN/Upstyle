import 'dart:io';
import 'package:equatable/equatable.dart';

/// Model for a single upcycling idea
class UpcyclingIdea extends Equatable {
  final String title;
  final List<String> neededItems;
  final String whatWorkToDo;
  final List<String> stepByStepProcess;

  const UpcyclingIdea({
    required this.title,
    required this.neededItems,
    required this.whatWorkToDo,
    required this.stepByStepProcess,
  });

  factory UpcyclingIdea.fromJson(Map<String, dynamic> json) {
    return UpcyclingIdea(
      title: json['title'] as String,
      neededItems: (json['needed_items'] as List).cast<String>(),
      whatWorkToDo: json['what_work_to_do'] as String,
      stepByStepProcess: (json['step_by_step_process'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'needed_items': neededItems,
      'what_work_to_do': whatWorkToDo,
      'step_by_step_process': stepByStepProcess,
    };
  }

  @override
  List<Object?> get props =>
      [title, neededItems, whatWorkToDo, stepByStepProcess];
}

/// Complete upcycling idea with generated image
class UpcyclingIdeaWithImage extends Equatable {
  final UpcyclingIdea idea;
  final File imageFile;

  const UpcyclingIdeaWithImage({
    required this.idea,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [idea, imageFile];
}
