class ErrorTranslator {
  /// Traduit les erreurs techniques (comme ClientException ou NetworkError) 
  /// en messages compréhensibles par l'utilisateur.
  static String translate(dynamic error) {
    final String errStr = error.toString();
    
    // Vérification des erreurs de connexion courantes
    if (errStr.contains('ClientException') || 
        errStr.contains('NetworkError') || 
        errStr.contains('SocketException') ||
        errStr.contains('Connection refused') ||
        errStr.contains('Failed host lookup')) {
      return "Une erreur avec le serveur est survenue, vérifiez votre connexion.";
    }
    
    // On retire le préfixe "Exception: " si présent pour un affichage plus propre
    if (errStr.startsWith('Exception: ')) {
      return errStr.replaceFirst('Exception: ', '');
    }
    
    return errStr;
  }
}
