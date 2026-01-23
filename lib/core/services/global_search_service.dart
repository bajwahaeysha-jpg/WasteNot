class GlobalSearchService {
  static final donors = ["Ahmed", "Ali", "Sara"];
  static final ngos = ["Edhi", "Saylani", "JDC"];
  static final donations = ["Food Drive", "Clothes Drive"];
  static final requests = ["Urgent Help", "Monthly Support"];

  static List<String> search(String query) {
    final q = query.toLowerCase();

    return [
      ...donors.where((e) => e.toLowerCase().contains(q)),
      ...ngos.where((e) => e.toLowerCase().contains(q)),
      ...donations.where((e) => e.toLowerCase().contains(q)),
      ...requests.where((e) => e.toLowerCase().contains(q)),
    ];
  }
}
