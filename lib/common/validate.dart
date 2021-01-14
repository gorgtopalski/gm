class FormValidator {
  static String emptyField(String field) {
    return field.isEmpty ? 'El campo no puede estar vacio' : null;
  }

  static String fieldMustBeNumber(String field) {
    return num.tryParse(field) ?? 'El valor tiene que ser numerico';
  }
}
