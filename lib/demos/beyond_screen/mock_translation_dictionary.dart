/// A tiny lookup table standing in for a real translation API — enough to
/// reproduce the "Milk" -> "Lapte" example from the talk without needing
/// network access or an API key during a live demo. Anything not in the
/// table is passed through unchanged, so the pipeline still has something
/// to show even without a dictionary hit.
const Map<String, String> mockTranslations = {
  'milk': 'Lapte',
  'water': 'Apă',
  'bread': 'Pâine',
  'coffee': 'Cafea',
};

String translateForDemo(String recognizedText) {
  final normalized = recognizedText.trim().toLowerCase();
  return mockTranslations[normalized] ?? recognizedText;
}
