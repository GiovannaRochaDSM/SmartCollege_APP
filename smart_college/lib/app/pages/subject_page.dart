import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/widgets/modals/subject/edit_subject_modal.dart';
import 'package:smart_college/app/common/widgets/modals/subject/new_subject_modal.dart';
import 'package:smart_college/app/common/widgets/modals/subject/view_subject_modal.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/data/stores/subject_store.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/pages/task_page.dart'; // Importe o arquivo TaskPage

class SubjectPage extends StatefulWidget {
  const SubjectPage({Key? key}) : super(key: key);

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
        title: Text(
          'Matérias',
          style: AppTextStyles.normalText.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final token = await AuthService.getToken();
              if (token != null) {
                _showAddModal(token);
              }
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
          ),
          Expanded(
            child: FutureBuilder<List<SubjectModel>>(
              future: futureSubjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar matérias: ${snapshot.error}',
                      style: AppTextStyles.mediumText.copyWith(
                          color: Colors.red, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (snapshot.hasData) {
                  List<SubjectModel> subjects = snapshot.data!;
                  if (subjects.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma matéria cadastrada.',
                        style: AppTextStyles.mediumText.copyWith(
                            color: AppColors.gray, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 16),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: subjects.length,
                      itemBuilder: (_, index) {
                        final item = subjects[index];
                        return GestureDetector(
                          onTap: () {
                            _showViewModal(item);
                          },
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                color: AppColors.purple,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTextStyles.smallText.copyWith(
                                        color: AppColors.titlePurple),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          final token = await AuthService.getToken();
                                          if (token != null) {
                                            _showEditModal(item, token);
                                          }
                                        },
                                        color: AppColors.titlePurple,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          final token = await AuthService.getToken();
                                          if (token != null) {
                                            _confirmDeleteSubject(item, token);
                                          }
                                        },
                                        color: AppColors.titlePurple,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.view_list),
                                        onPressed: () {
                                          _navigateToTasksPage(item.id);
                                        },
                                        color: AppColors.titlePurple,
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
                                    style: AppTextStyles.smallerText.copyWith(
                                        color: AppColors.gray),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Notas: ${item.grades?.join(', ')}',
                                    style: AppTextStyles.smallerText,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Faltas: ${item.abscence}',
                                    style: AppTextStyles.smallerText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return Container();
                }
              },
            ),
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
        title: Text(
          'Excluir matéria',
          style: AppTextStyles.smallText.copyWith(color: AppColors.titlePurple),
        ),
        content: Text(
          'Tem certeza que deseja excluir a matéria "${subject.name}"?',
          style: AppTextStyles.smallerText.copyWith(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: AppTextStyles.smallText
                  .copyWith(color: AppColors.titlePurple),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSubject(subject.id);
            },
            child: Text(
              'Excluir',
              style: AppTextStyles.smallText
                  .copyWith(color: AppColors.titlePurple),
            ),
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

  void _navigateToTasksPage(String subjectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPage(subjectId: subjectId),
      ),
    );
  }
}
