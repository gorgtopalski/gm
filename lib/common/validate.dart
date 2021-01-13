class FormValidator {
  static String emptyField(String field) {
    return field.isEmpty ? 'Campo no puede estar vacio' : null;
  }
}
