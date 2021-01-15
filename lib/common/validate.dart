class FormValidator {
  static String emptyField(String field) {
    if (field == null) return 'El campo no puede estar vacio';
    if (field.isEmpty) return 'El campo no puede estar vacio';
    return null;
  }

  static String selectField(dynamic field) {
    if (field == null) return 'Selecione un valor del desplegable';
    return null;
  }

  static String fieldMustBeNumber(String field) {
    return num.tryParse(field) ?? 'El valor tiene que ser numerico';
  }
}
