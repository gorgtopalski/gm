class DateFormatters {
  static String dateToDMY(DateTime date) {
    if (date == DateTime.fromMillisecondsSinceEpoch(0)) {
      return "Sin datos";
    } else
      return "${date.day}/${date.month}/${date.year}";
  }
}
