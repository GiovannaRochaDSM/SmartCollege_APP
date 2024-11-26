import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/bond_page.dart';
import 'package:smart_college/app/pages/home_page.dart';
import 'package:smart_college/app/pages/task_timeline.dart';
import 'package:smart_college/app/pages/feed/feed_page.dart';
import 'package:smart_college/app/pages/user/user_page.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
import 'package:smart_college/app/pages/subject/subject_page.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<UserModel> futureUser;
  Image? imagemReal;

  @override
  void initState() {
    super.initState();
    futureUser = UserHelper.fetchUser();
    futureUser.then((value) => readImage(value.photo));
  }

  Future<void> readImage(String? foto) async {
    if (foto != null) {
      setState(() {
        imagemReal = Image.memory(const Base64Decoder().convert(foto));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<UserModel>(
            future: futureUser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppNewColors.darkBlue,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppNewColors.darkBlue,
                  ),
                  child: Center(
                    child: Text(
                      'Erro ao carregar usuário: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final user = snapshot.data!;
                final displayName = user.nickname;
                return DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppNewColors.darkBlue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 50,
                        backgroundImage: imagemReal?.image,
                        child: imagemReal == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        displayName,
                        style: AppNewTextStyles.smallPoppinsRegular
                            .copyWith(color: AppNewColors.white),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text('Home',
                style: AppNewTextStyles.mediumPoppinsRegular
                    .copyWith(color: AppNewColors.textGray)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text('Agenda',
                style: AppNewTextStyles.mediumPoppinsRegular
                    .copyWith(color: AppNewColors.textGray)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskTimelinePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text('Matérias',
                style: AppNewTextStyles.mediumPoppinsRegular
                    .copyWith(color: AppNewColors.textGray)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubjectPage(),
                ),
              );
            },
          ),
          FutureBuilder<UserModel>(
            future: futureUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data!;

                return Column(
                  children: [
                    if (user.isCoord)
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text('Vínculos',
                            style: AppNewTextStyles.mediumPoppinsRegular
                                .copyWith(color: AppNewColors.textGray)),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BondPage(),
                            ),
                          );
                        },
                      ),
                    if (user.bond)
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text('Feed',
                            style: AppNewTextStyles.mediumPoppinsRegular
                                .copyWith(color: AppNewColors.textGray)),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedPage(),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text('Meu perfil',
                style: AppNewTextStyles.mediumPoppinsRegular
                    .copyWith(color: AppNewColors.textGray)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 200),
          const Divider(),
          ListTile(
            title: Text('Sair',
                style: AppNewTextStyles.mediumPoppinsRegular
                    .copyWith(color: AppNewColors.textGray)),
            onTap: () {
              AuthService.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
