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

  static const invalidPassword = SnackBar(
    content: Text(
      'Por favor, digite uma senha válida',
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

  static const emailResetPasswordInvalid = SnackBar(
    content: Text(
      'Por favor, digite um e-mail correto',
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
      'Tarefa excluída com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const taskDeletedError = SnackBar(
    content: Text(
      'Erro ao excluir tarefa.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const taskUpdatedSuccess = SnackBar(
    content: Text(
      'Tarefa atualizada com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const taskUpdatedError = SnackBar(
    content: Text(
      'Erro ao atualizar tarefa.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const taskAddSuccess = SnackBar(
    content: Text(
      'Tarefa adicionada com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const taskAddError = SnackBar(
    content: Text(
      'Erro ao adicionar tarefa.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const scheduleAddSuccess = SnackBar(
    content: Text(
      'Horário adicionado com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const scheduleAddError = SnackBar(
    content: Text(
      'Erro ao adicionar horário.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const scheduleUpdateSuccess = SnackBar(
    content: Text(
      'Horário atualizado com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const scheduleUpdateError = SnackBar(
    content: Text(
      'Erro ao atualizar horário.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const scheduleDeleteSuccess = SnackBar(
    content: Text(
      'Horário excluído com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const scheduleDeleteError = SnackBar(
    content: Text(
      'Erro ao excluir horário.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const requestBondSuccess = SnackBar(
    content: Text(
      'Vínculo solicitado com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const requestBondError = SnackBar(
    content: Text(
      'Erro ao solicitar vínculo.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const bondAcceptedSuccess = SnackBar(
    content: Text(
      'Vínculo aceito com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const bondAcceptedError = SnackBar(
    content: Text(
      'Erro ao aceitar o vínculo.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const bondRejectedSuccess = SnackBar(
    content: Text(
      'Vínculo rejeitado com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const bondRejectedError = SnackBar(
    content: Text(
      'Erro ao rejeitar o vínculo.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const publicationDeletedSuccess = SnackBar(
    content: Text(
      'Publicação excluída com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const publicationDeletedError = SnackBar(
    content: Text(
      'Erro ao excluir publicação.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const feedUpdatedSuccess = SnackBar(
    content: Text(
      'Publicação editada com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const feedUpdatedError = SnackBar(
    content: Text(
      'Erro ao editar publicação.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const restrictedAccess = SnackBar(
    content: Text(
      'Acesso restrito. Somente coordenadores podem ver detalhes.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const likeError = SnackBar(
    content: Text(
      'Erro ao curtir a publicação.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const dislikeError = SnackBar(
    content: Text(
      'Erro ao descurtir a publicação.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const selectedImageError = SnackBar(
    content: Text(
      'Erro ao selecionar imagem.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const addPublicationSuccess = SnackBar(
    content: Text(
      'Publicação criada com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const addPublicationError = SnackBar(
    content: Text(
      'Erro ao adicionar publicação.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const deletePublicationSuccess = SnackBar(
    content: Text(
      'Publicação excluída com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const deletePublicationError = SnackBar(
    content: Text(
      'Erro ao excluir publicação.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const generatedFileSuccess = SnackBar(
    content: Text(
      'Arquivo gerado com sucesso.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const generatedFileError = SnackBar(
    content: Text(
      'Erro ao gerar o arquivo.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const permissioGranted = SnackBar(
    content: Text(
      'Permissão concedida.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const permissioDenied = SnackBar(
    content: Text(
      'Permissão negada.',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const taskCompleted = SnackBar(
    content: Text(
      'Tarefa concluída',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );
}
