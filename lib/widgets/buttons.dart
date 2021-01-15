import 'package:flutter/material.dart';

class SaveCancelButtonBar extends StatelessWidget {
  final Function onSave;
  final Function onCancel;
  final String saveLabel;
  final String cancelLabel;
  SaveCancelButtonBar(
      {this.onSave,
      this.onCancel,
      this.saveLabel = 'Guardar',
      this.cancelLabel = 'Cancelar'});

  @override
  Widget build(BuildContext context) {
    return ButtonBarTheme(
      data: Theme.of(context).buttonBarTheme,
      child: ButtonBar(
          alignment: MainAxisAlignment.end,
          layoutBehavior: ButtonBarLayoutBehavior.constrained,
          mainAxisSize: MainAxisSize.max,
          buttonHeight: 50,
          children: [
            FlatButton.icon(
                onPressed: onSave,
                icon: Icon(Icons.save),
                label: Text(saveLabel)),
            FlatButton.icon(
                onPressed: onCancel,
                icon: Icon(Icons.cancel),
                label: Text(cancelLabel)),
          ]),
    );
  }
}
