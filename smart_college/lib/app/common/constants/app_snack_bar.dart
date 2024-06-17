import 'package:flutter/material.dart';

class AppSnackBar {
  static const invalidEmailOrPassword = SnackBar(
    content: Text(
      'E-mail ou senha inválidos',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const removePhotoSuccess = SnackBar(
    content: Text(
      'Foto removida com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const removePhotoError = SnackBar(
    content: Text(
      'Erro ao remover a foto',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const userUpdatedSuccess = SnackBar(
    content: Text(
      'Informações atualizadas com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const userUpdatedError = SnackBar(
    content: Text(
      'Erro ao atualizar as informações',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const userDeletedSuccess = SnackBar(
    content: Text(
      'Usuário deletado com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const userDeletedError = SnackBar(
    content: Text(
      'Erro ao deletar usuário',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const subjectDeletedSuccess = SnackBar(
    content: Text(
      'Matéria excluída com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const subjectDeletedError = SnackBar(
    content: Text(
      'Erro ao excluir matéria',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const subjectUpdatedSuccess = SnackBar(
    content: Text(
      'Matéria atualizada com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const subjectUpdatedError = SnackBar(
    content: Text(
      'Erro ao atualizar matéria',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const subjectAddSuccess = SnackBar(
    content: Text(
      'Matéria adicionada com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const subjectAddError = SnackBar(
    content: Text(
      'Erro ao adicionar matéria',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const emailSendCodeResetPasswordSuccess = SnackBar(
    content: Text(
      'Um e-mail foi enviado para redefinir sua senha',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const emailResetPasswordError = SnackBar(
    content: Text(
      'Por favor, insira seu e-mail',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const emailSendCodeResetPasswordError = SnackBar(
    content: Text(
      'Erro ao enviar email para redefinição de senha. Por favor, tente novamente.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const userAddSuccess = SnackBar(
    content: Text(
      'Cadastro realizado com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const userAddError = SnackBar(
    content: Text(
      'Erro ao se cadastrar',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const fillFields = SnackBar(
    content: Text(
      'Por favor, preencha todos os campos',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const invalidAuthCode = SnackBar(
    content: Text(
      'Código de autenticação inválido. Tente novamente.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const error = SnackBar(
    content: Text(
      'Erro interno. Tente novamente.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const differentPasswordsFields = SnackBar(
    content: Text(
      'As senhas informadas não coincidem.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const passwordUpdatedSuccess = SnackBar(
    content: Text(
      'Senha alterada com sucesso. Entre novamente.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

    static const passwordUpdatedError = SnackBar(
    content: Text(
      'Erro ao alterar senha. Tente novamente.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const taskDeletedSuccess = SnackBar(
    content: Text(
      'Matéria excluída com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const taskDeletedError = SnackBar(
    content: Text(
      'Erro ao excluir matéria.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const taskUpdatedSuccess = SnackBar(
    content: Text(
      'Matéria atualizada com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const taskUpdatedError = SnackBar(
    content: Text(
      'Erro ao atualizar matéria.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const taskAddSuccess = SnackBar(
    content: Text(
      'Matéria adicionada com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const taskAddError = SnackBar(
    content: Text(
      'Erro ao adicionar matéria.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );
}
