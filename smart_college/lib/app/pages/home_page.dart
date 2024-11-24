import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/bond_page.dart';
import 'package:smart_college/app/pages/task_timeline.dart';
import 'package:smart_college/app/pages/feed/feed_page.dart';
import 'package:smart_college/app/pages/user/user_page.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/pages/subject/subject_page.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/widgets/modals/home/home_card.dart';
import 'package:smart_college/app/common/widgets/modals/home/task_progress_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel> _futureUser;
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUser();
    _fetchTasks();
  }

  Future<UserModel> fetchUser() async {
    try {
      UserModel user = await UserHelper.fetchUser();
      return user;
    } catch (e) {
      throw Exception('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _fetchTasks() async {
    tasks = await TaskHelper.fetchAllTasks();
    setState(() {});
  }

  int getTotalTasksCount() {
    return tasks.length;
  }

  int getPendingTasksCount() {
    return tasks.where((task) => task.status == 'Pendente').length;
  }

  int getInProgressTasksCount() {
    return tasks.where((task) => task.status == 'Em progresso').length;
  }

  int getCompletedTasksCount() {
    return tasks.where((task) => task.status == 'Concluída').length;
  }

  int getTasksCountByCategory(String category) {
    return tasks.where((task) => task.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppNewColors.white,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppNewColors.darkGray, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel>(
              future: _futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar usuário: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  UserModel user = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, ${user.nickname}.',
                                  style: AppNewTextStyles.mediumBalooTitle,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Descubra no que você pode evoluir hoje.',
                                  style: AppNewTextStyles.mediumExtraLight,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: Image.asset(
                              'assets/images/couple.png',
                            ),
                          ),
                        ],
                      ),
                      TaskProgressChart(
                        pendingTasksCount: getPendingTasksCount(),
                        inProgressTasksCount: getInProgressTasksCount(),
                        completedTasksCount: getCompletedTasksCount(),
                        totalTasksCount: getTotalTasksCount(),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Organize-se conosco:',
                        style: AppNewTextStyles.mediumPoppinsRegular,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            HomeCard(
                              title: 'Agenda',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const TaskTimelinePage()),
                                );
                              },
                            ),
                            HomeCard(
                              title: 'Matérias',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SubjectPage()),
                                );
                              },
                            ),
                            if (user.isCoord)
                              HomeCard(
                                title: 'Vínculos',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const BondPage()),
                                  );
                                },
                              ),
                            if (user.bond)
                              HomeCard(
                                title: 'Feed',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const FeedPage()),
                                  );
                                },
                              ),
                            HomeCard(
                              title: 'Meu perfil',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const UserPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
