/// Configuration for connecting to and displaying Grist data.
class GristConfig {
  /// The Grist document ID
  final String documentId;

  /// The Grist table ID
  final String tableId;

  /// API key for authentication
  final String apiKey;

  /// Base URL of the Grist instance (defaults to docs.getgrist.com)
  final String baseUrl;

  /// List of attribute names that should be readable
  final List<String> readableAttributes;

  /// List of attribute names that should be writable
  final List<String> writableAttributes;

  const GristConfig({
    required this.documentId,
    required this.tableId,
    required this.apiKey,
    this.baseUrl = 'https://docs.getgrist.com',
    this.readableAttributes = const [],
    this.writableAttributes = const [],
  });

  /// Returns all attributes that should be displayed (readable + writable)
  List<String> get allAttributes => [
        ...readableAttributes,
        ...writableAttributes.where((attr) => !readableAttributes.contains(attr)),
      ];
}
