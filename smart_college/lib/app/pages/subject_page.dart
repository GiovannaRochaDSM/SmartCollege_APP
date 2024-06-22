import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/task_page.dart';
import 'package:smart_college/app/pages/schedule_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/stores/subject_store.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/modals/subject/new_subject_modal.dart';
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
        toolbarHeight: 65,
        iconTheme: const IconThemeData(color: Colors.white, size: 25),
        title: Text(
          'MATÉRIAS',
          style: AppTextStyles.normalText.copyWith(color: AppColors.white),
          textAlign: TextAlign.right,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.purple, AppColors.pink],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: AppColors.purple,
      ),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 20, 20, 15),
          ),
          Expanded(
            child: FutureBuilder<List<SubjectModel>>(
              future: futureSubjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Oops... Nenhuma matéria cadastrada.',
                              style: AppTextStyles.normalText.copyWith(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.asset(
                              'assets/images/wind.png',
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final item = subjects[index];
                        return Column(
                          children: [
                            const Divider(
                              color: AppColors.pink,
                              thickness: 2,
                            ),
                            Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      'Excluir matéria',
                                      style: AppTextStyles.normalTextBold
                                          .copyWith(
                                              color: AppColors.titlePurple),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      'Tem certeza que deseja excluir a matéria "${item.name}"?',
                                      style: AppTextStyles.smallText
                                          .copyWith(color: AppColors.gray),
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context,
                                              false);
                                        },
                                        child: Text(
                                          'Cancelar',
                                          style: AppTextStyles.smallerText
                                              .copyWith(color: AppColors.gray),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context,
                                              true);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(
                                          'Excluir',
                                          style: AppTextStyles.smallerText
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmDelete) {
                                  _deleteSubject(item
                                      .id);
                                }
                                return confirmDelete;
                              },
                              onDismissed: (_) {
                              },
                              child: _buildSubjectTile(
                                  item),
                            ),
                            const Divider(
                              color: AppColors.pink,
                              thickness: 2,
                            ),
                          ],
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
      floatingActionButton: Positioned(
        bottom: 55.0,
        right: 55.0,
        child: GestureDetector(
          onTap: () async {
            final token = await AuthService.getToken();
            _showAddModal(token);
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              size: 50,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectTile(SubjectModel subject) {
    return ListTile(
      title: Text(
        subject.acronym,
        style:
            AppTextStyles.normalTextBold.copyWith(color: AppColors.titlePurple),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subject.name,
            style: AppTextStyles.smallTextBold.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Notas: ',
                  style: AppTextStyles.smallerTextBold.copyWith(
                    color: AppColors.inputText,
                  ),
                ),
                TextSpan(
                  text: subject.grades?.join(', ') ?? 'N/A',
                  style: AppTextStyles.smallerText.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Faltas: ',
                  style: AppTextStyles.smallerTextBold.copyWith(
                    color: AppColors.inputText,
                  ),
                ),
                TextSpan(
                  text: '${subject.abscence}',
                  style: AppTextStyles.smallerText.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: Wrap(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.pink,
            radius: 26,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 30),
              onPressed: () {
                _showEditModal(subject);
              },
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.pink,
            radius: 26,
            child: IconButton(
              icon: const Icon(Icons.format_list_bulleted_rounded, size: 30),
              onPressed: () {
                _navigateToTasksPage(subject.id);
              },
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.pink,
            radius: 26,
            child: IconButton(
              icon: const Icon(Icons.schedule, size: 30),
              onPressed: () {
                _navigateToSchedulesPage(subject.id);
              },
              color: AppColors.white,
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

  void _showEditModal(SubjectModel subject) {
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

void _deleteSubject(String subjectId) {
  store.deleteSubject(subjectId).then((_) {
    ScaffoldMessenger.of(context)
    .showSnackBar(AppSnackBar.subjectDeletedSuccess);
    setState(() {
      futureSubjects = SubjectHelper.fetchSubjects();
    });
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

  void _navigateToSchedulesPage(String subjectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(subjectId: subjectId),
      ),
    );
  }
}
