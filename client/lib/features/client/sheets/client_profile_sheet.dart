import 'package:flutter/material.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/user_edit_form.dart';

void showClientProfileSheet({
  required BuildContext context,
  required VoidCallback onSave,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Editar Perfil',
    height: BottomSheetHeight.large,
    child: UserEditForm(
      onSave: () {
        Navigator.pop(context);
        onSave();
      },
    ),
  );
}
