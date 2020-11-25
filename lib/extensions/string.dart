extension StringExt on String {
  bool get isBlank => this == null || this.trim().isEmpty;
  bool get isNotBlank => this != null && this.trim().isNotEmpty;
}
