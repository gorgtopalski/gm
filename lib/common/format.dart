class DateFormatters {
  static String dateToDMY(DateTime date) {
    if (date == DateTime.fromMillisecondsSinceEpoch(0)) {
      return "Sin datos";
    } else
      return "${date.day}/${date.month}/${date.year}";
  }

  static String dmy(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  static int dateToShift(DateTime date) {
    if (date.hour >= 6 && date.hour < 14) return 1; // Morning shift
    if (date.hour >= 14 && date.hour < 22) return 2; // Afternoon shift
    return 3;
  }
}
