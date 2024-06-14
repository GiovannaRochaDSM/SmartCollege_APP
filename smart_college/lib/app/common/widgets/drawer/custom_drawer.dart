import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_college/app/pages/user_page.dart';
import 'package:smart_college/app/services/auth_service.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/data/helpers/fetch_user.dart';
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<UserModel>(
            future: futureUser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.purple, AppColors.pink],
                    ),
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.purple, AppColors.pink],
                    ),
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
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.purple, AppColors.pink],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 50,
                        backgroundImage: imagemReal?.image,
                        child: imagemReal == null
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          displayName, // Usa o displayName em vez do user.name
                          style: AppTextStyles.smallText.copyWith(color: AppColors.white), 
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          ListTile(
            title: Text('Meu perfil',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPage(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Sair',
                style: AppTextStyles.smallText.copyWith(color: AppColors.gray)),
            onTap: () {
              AuthService.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
