import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/pages/user/user_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/data/models/university_model.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/bond_repository.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';

class RequestBondDialog extends StatefulWidget {
  final String userId;

  const RequestBondDialog({super.key, required this.userId});

  @override
  _RequestBondDialogState createState() => _RequestBondDialogState();
}

class _RequestBondDialogState extends State<RequestBondDialog> {
  bool isLoading = true;
  UniversityModel? selectedUniversity;
  List<UniversityModel> universities = [];
  final BondRepository bondRepository = BondRepository(client: HttpClient());
  final UserRepository userRepository = UserRepository(client: HttpClient());
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailCoordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  Future<void> _fetchUniversities() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');

      final response = await http.get(
        Uri.parse(AppRoutes.universities),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          universities = data.map((e) => UniversityModel.fromMap(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao buscar universidades: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _requestBond() async {
    String? token = await AppStrings.secureStorage.read(key: 'token');
    final emailCoord = _emailCoordController.text;
    final universityId = selectedUniversity?.id;
    final userName = _userNameController.text;

    final Map<String, dynamic> requestData = {
      'emailCoord': emailCoord,
      'name': userName,
      'universityId': universityId,
    };

    if (universityId != null && emailCoord.isNotEmpty) {
      try {
        bool success = await bondRepository.requestBond(requestData, token);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.requestBondSuccess);

          Navigator.of(context).pop();

          _updateAndReloadPage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.requestBondError);
          throw Exception('Falha ao enviar a solicitação de vínculo.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.fillFields);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppNewColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Center(
        child: Text('Solicitar Vínculo',
            style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.lightBlue)),
      ),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<UniversityModel>(
                    hint: Text(
                      'Selecione uma Universidade',
                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                    ),
                    value: selectedUniversity,
                    onChanged: (UniversityModel? newValue) {
                      setState(() {
                        selectedUniversity = newValue;
                      });
                    },
                    items: universities.map<DropdownMenuItem<UniversityModel>>(
                      (UniversityModel university) {
                        return DropdownMenuItem<UniversityModel>(
                          value: university,
                          child: Text(
                            university.name,
                            style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  TextField(
                      controller: _emailCoordController,
                      decoration: InputDecoration(
                          labelText: 'E-mail do Coordenador',
                          labelStyle: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
                  TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Usuário',
                        labelStyle: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                      ),
                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray)),
                ],
              ),
            ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancelar',
            style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          onPressed: _requestBond,
          style: TextButton.styleFrom(
            side: const BorderSide(color: AppNewColors.lightBlue, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Solicitar vínculo',
            style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.lightBlue),
          ),
        ),
      ],
    );
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UserPage(),
      ),
    );
  }
}
