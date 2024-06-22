import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';

class SubjectStore {
  final ISubjectRepository repository;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<SubjectModel>> state = ValueNotifier<List<SubjectModel>>([]);
  final ValueNotifier<String> error = ValueNotifier<String>('');

  SubjectStore({required this.repository});

  Future<void> getSubjects() async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await repository.getSubjects();
      state.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    isLoading.value = true;
    error.value = '';
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');
      await repository.deleteSubject(subjectId, token);
      state.value = state.value.where((subject) => subject.id != subjectId).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
