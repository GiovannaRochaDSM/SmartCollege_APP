import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/data/stores/subject_store.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/widgets/modals/subject/new_subject_modal.dart';
import 'package:smart_college/app/widgets/modals/subject/view_subject_modal.dart';
import 'package:smart_college/app/widgets/modals/subject/edit_subject_modal.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final SubjectStore store = SubjectStore(
    repository: SubjectRepository(
      client: HttpClient(),
    ),
  );

  @override
  void initState() {
    super.initState();
    store.getSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Matérias',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B61C2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: const Color(0xFF4B61C2),
                  onPressed: () {
                    _showAddModal();
                  },
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([
              store.isLoading,
              store.error,
              store.state,
            ]),
            builder: (context, child) {
              if (store.isLoading.value) {
                return const CircularProgressIndicator();
              }
              if (store.error.value.isNotEmpty) {
                return Center(
                  child: Text(
                    store.error.value,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (store.state.value.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma matéria cadastrada.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: store.state.value.length,
                    itemBuilder: (_, index) {
                      final item = store.state.value[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditModal(item);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDeleteSubject(item);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () {
                                      _showViewModal(item);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.acronym,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notas: ${item.grades?.join(', ')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Faltas: ${item.abscence}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditModal(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditSubjectModal(subject: subject);
      },
    ).then((result) {
      if (result != null && result == true) {
        setState(() {
          store.getSubjects();
        });
      }
    });
  }

  void _showViewModal(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewSubjectModal(subject: subject);
      },
    );
  }

  void _showAddModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewSubjectModal();
      },
    ).then((result) {
      if (result != null && result == true) {
        store.getSubjects();
      }
    });
  }

  void _confirmDeleteSubject(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir matéria'),
        content:
            Text('Tem certeza que deseja excluir a matéria "${subject.name}?"'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSubject(subject.id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(String subjectId) {
    store.deleteSubject(subjectId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matéria excluída com sucesso.'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir matéria: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}
