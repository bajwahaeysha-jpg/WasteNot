int parseMealRange(String range) {
  final normalized = range.trim();
  if (normalized.isEmpty) {
    return 0;
  }

  final direct = int.tryParse(normalized);
  if (direct != null) {
    return direct;
  }

  final parts = normalized.split(RegExp(r'\s*-\s*'));
  if (parts.length != 2) {
    return 0;
  }

  final min = int.tryParse(parts[0].trim());
  final max = int.tryParse(parts[1].trim());
  if (min == null || max == null) {
    return 0;
  }

  return ((min + max) / 2).round();
}

int parseMealValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    return parseMealRange(value);
  }
  return 0;
}
