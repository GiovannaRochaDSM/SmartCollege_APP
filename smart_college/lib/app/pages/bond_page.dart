import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/bond_model.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/bond_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';

class BondPage extends StatefulWidget {
  const BondPage({super.key});

  @override
  _BondPageState createState() => _BondPageState();
}

class _BondPageState extends State<BondPage> {
  final BondRepository bondRepository = BondRepository(client: HttpClient());
  List<BondModel> bonds = [];
  String? token;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadTokenAndBonds();
  }

  Future<void> _loadTokenAndBonds() async {
    token = await AuthService.getToken();
    userEmail = await AuthService.getUserEmail();
    await _loadBonds();
  }

  Future<void> _loadBonds() async {
    final fetchedBonds = await bondRepository.getBonds(token);
    setState(() {
      bonds = fetchedBonds;
    });
  }

  Future<void> acceptBond(String userId, String universityId) async {
    final success =
        await bondRepository.acceptBond(userId, universityId, token);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.bondAcceptedSuccess);
      _loadBonds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.bondAcceptedError);
    }
  }

  Future<void> rejectBond(String userId) async {
    final success = await bondRepository.rejectBond(userId, token);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.bondRejectedSuccess);
      _loadBonds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.bondRejectedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 65,
        iconTheme: const IconThemeData(color: Colors.white, size: 25),
        title: Text('VÍNCULOS',
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
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
        itemCount: bonds.length,
        itemBuilder: (context, index) {
          final bond = bonds[index];
          return ListTile(
            title: Text('Solicitação de ${bond.userName}'),
            subtitle: Text(
                '${bond.universityName}\n${bond.userEmail}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_rounded, color: Colors.green),
                  onPressed: () => acceptBond(bond.userId, bond.universityId),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.red),
                  onPressed: () => rejectBond(bond.userId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
