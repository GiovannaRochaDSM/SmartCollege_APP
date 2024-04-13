import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/exceptions.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
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
    } on NotFoundException catch (e) {
      error.value = e.message;
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
      await repository.deleteSubject(subjectId);
      await getSubjects();
    } catch (e) {
      error.value = 'Erro ao excluir matéria: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
