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
    final success = await bondRepository.acceptBond(userId, universityId, token);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.bondAcceptedSuccess);
      _updateAndReloadPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.bondAcceptedError);
    }
  }

  Future<void> rejectBond(String userId) async {
    final success = await bondRepository.rejectBond(userId, token);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.bondRejectedSuccess);
      _updateAndReloadPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.bondRejectedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: Text(
          'Vínculos',
          style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true, 
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
          ),
        ),
        backgroundColor: AppNewColors.pink,
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Aceite ou rejeite as solicitações de vínculo com a sua instituição. Em caso de dúvidas, o e-mail do solicitante está disponível para entrar em contato.',
              style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.black),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.grey),
              itemCount: bonds.length,
              itemBuilder: (context, index) {
                final bond = bonds[index];
                return Card(
                  color: AppNewColors.lightGray,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'Solicitação de ${bond.userName}',
                      style: AppNewTextStyles.poppinsMedium.copyWith(color: AppNewColors.textGray),
                    ),
                    subtitle: Text(
                      '${bond.universityName}\n${bond.userEmail}',
                      style: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.textGray),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_rounded,
                            color: Colors.green),
                            iconSize: 33,
                          onPressed: () => acceptBond(bond.userId, bond.universityId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_rounded,
                            color: Colors.red),
                            iconSize: 33,
                          onPressed: () => rejectBond(bond.userId),
                        ),
                      ],
                    ),
                  ),
                );
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
        builder: (context) => const BondPage(),
      ),
    );
  }
}
