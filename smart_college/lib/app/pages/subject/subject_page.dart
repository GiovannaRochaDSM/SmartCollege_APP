import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/stores/subject_store.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/pages/subject/detail_subject_page.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/modals/subject/new_subject_modal.dart';

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
        toolbarHeight: 78,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: Text(
          'Matérias',
          style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
          ),
        ),
        backgroundColor: AppNewColors.lightBlue,
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
                      style: AppNewTextStyles.poppinsMedium.copyWith(
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
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              'assets/images/logo.png',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Ops\nNenhuma matéria cadastrada.',
                              style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.lightGray,fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
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
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Excluir matéria',
                                  style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  'Você tem certeza que deseja excluir a matéria "${item.name}"?',
                                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text(
                                      'Cancelar',
                                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    style: TextButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppNewColors.red,
                                        width: 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Excluir',
                                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete) {
                              _deleteSubject(item.id);
                            }
                            return confirmDelete;
                          },
                          onDismissed: (_) {},
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailSubjectPage(subject: item),
                                ),
                              );
                            },
                            child: Card(
                              color: AppNewColors.lightGray,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  item.acronym,
                                  style: AppNewTextStyles.mediumPoppinsMedium
                                      .copyWith(color: AppNewColors.textGray),
                                ),
                                subtitle: Text(
                                  item.name,
                                  style: AppNewTextStyles.smallExtraLight
                                      .copyWith(color: AppNewColors.textGray),
                                ),
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
      floatingActionButton: Positioned(
        bottom: 55.0,
        right: 55.0,
        child: GestureDetector(
          onTap: () async {
            final token = await AuthService.getToken();
            showNewSubjectModal(context);
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppNewColors.lightBlue,
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 50,
              color: AppNewColors.white,
            ),
          ),
        ),
      ),
    );
  }

  void showNewSubjectModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            color: AppNewColors.white,
            constraints: const BoxConstraints(maxHeight: 600),
            child: const NewSubjectModal(),
          ),
        );
      },
    );
  }

  void _deleteSubject(String subjectId) {
    store.deleteSubject(subjectId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectDeletedSuccess);

      setState(() {
        futureSubjects = SubjectHelper.fetchSubjects();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectDeletedError);
    });
  }
}
