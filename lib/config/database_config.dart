// Database configuration for API endpoints
class DatabaseConfig {
  static const String _apiHost = '43.138.4.157';
  static const int _apiPort = 8080;
  static const String _database = 'campus_project';
  
  // API base URL
  static String get baseUrl => 'http://$_apiHost:$_apiPort/api';
  
  // Database connection info for server-side reference
  static const String databaseName = _database;
  
  // Connection timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 15);
  
  // Health check endpoint
  static String get healthCheckUrl => '$baseUrl/health';
  
  // Update API host configuration
  static void updateApiHost(String newHost, {int? port}) {
    // This would require app restart in a real implementation
    print('API host would be updated to: $newHost${port != null ? ':$port' : ''}');
  }
}