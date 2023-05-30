class CrowdinAuthConfig {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String? organizationName;

  CrowdinAuthConfig({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.organizationName,
  });
}
