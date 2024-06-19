import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/pages/schedule_page.dart';
import 'package:smart_college/app/pages/subject_page.dart';
import 'package:smart_college/app/pages/task_page.dart';
import 'package:smart_college/app/pages/user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUser();
  }

  Future<UserModel> fetchUser() async {
    try {
      UserModel user = await UserHelper.fetchUser();
      return user;
    } catch (e) {
      throw Exception('Erro ao carregar dados do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu,
                color: AppColors.titlePurple),
            onPressed: () {
              Scaffold.of(context)
                  .openDrawer();
            },
          ),
        ),
      ),
      drawer:
          const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                                const SizedBox(height: 40),
                                Text(
                                  'Olá, ${user.nickname}.',
                                  style: AppTextStyles.biggerText,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Descubra no que você pode evoluir hoje.',
                                  style: AppTextStyles.smallText,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 147,
                            height: 157,
                            child: Image.asset(
                              'assets/images/man.png',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        'Organize-se conosco:',
                        style: AppTextStyles.normalText,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height:
                            170,
                        child: ListView(
                          scrollDirection: Axis
                              .horizontal,
                          children: [
                            HomeCard(
                              title: 'Tarefas',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const TaskPage()),
                                );
                              },
                            ),
                            HomeCard(
                              title: 'Matérias',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SubjectPage()),
                                );
                              },
                            ),
                            HomeCard(
                              title: 'Horário',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SchedulePage()),
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

class HomeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const HomeCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.purple, AppColors.pink],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: AppTextStyles.normalText.copyWith(color: AppColors.white),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward,
                  size: 50,
                  color:AppColors.lightGray,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
