import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/data/stores/subject_store.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/modals/subject/new_subject_modal.dart';
import 'package:smart_college/app/common/widgets/modals/subject/view_subject_modal.dart';
import 'package:smart_college/app/common/widgets/modals/subject/edit_subject_modal.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late Future<List<SubjectModel>> futureSubjects;
  final SubjectStore store = SubjectStore(
    repository: SubjectRepository(
      client: HttpClient(),
    ),
  );

  @override
  void initState() {
    super.initState();
    store.getSubjects();
    futureSubjects = SubjectHelper.fetchSubjects();
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
      drawer: const CustomDrawer(),
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
                  onPressed: () async {
                    String? token = await AuthService.getToken();
                    if (token != null) {
                      AppStrings.authorizationToken += token;
                      _showAddModal(token);
                    }
                  },
                ),
              ],
            ),
          ),
          FutureBuilder<List<SubjectModel>>(
            future: futureSubjects,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar matérias: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (snapshot.hasData) {
                List<SubjectModel> subjects = snapshot.data!;
                if (subjects.isEmpty) {
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
                      itemCount: subjects.length,
                      itemBuilder: (_, index) {
                        final item = subjects[index];
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
                                      onPressed: () async {
                                        String? token =
                                            await AuthService.getToken();
                                        if (token != null) {
                                          AppStrings.authorizationToken +=
                                              token;
                                          _showEditModal(item, token);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        String? token = await AppStrings
                                            .secureStorage
                                            .read(key: 'token');
                                        if (token != null) {
                                          AppStrings.authorizationToken +=
                                              token;
                                          _confirmDeleteSubject(item, token);
                                        }
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
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubjectPage(),
      ),
    );

    setState(() {
      store.getSubjects();
    });
  }

  void _showAddModal(String? token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewSubjectModal();
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  void _showEditModal(SubjectModel subject, String? token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditSubjectModal(subject: subject);
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
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

  void _confirmDeleteSubject(SubjectModel subject, String? token) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Excluir matéria',
            style:
                AppTextStyles.smallText.copyWith(color: AppColors.titlePurple)),
        content: Text(
            'Tem certeza que deseja excluir a matéria "${subject.name}"?',
            style: AppTextStyles.smallerText.copyWith(color: AppColors.gray)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar',
                style: AppTextStyles.smallerText.copyWith(color: AppColors.titlePurple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSubject(subject.id);
            },
            child: Text('Excluir',
                style: AppTextStyles.smallerText.copyWith(color: AppColors.titlePurple)),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(String subjectId) {
    store.deleteSubject(subjectId).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectDeletedSuccess);
      _updateAndReloadPage();
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectDeletedError);
    });
  }
}
