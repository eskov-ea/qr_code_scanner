final Map<String, String> tables = {
  'qr_codes'  :
  'CREATE TABLE qr_codes( '
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'value TEXT NOT NULL UNIQUE, '
      'status TINYINT(1) DEFAULT 0, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'deleted_at DATETIME DEFAULT NULL'
  ');',
  'config'  :
  'CREATE TABLE config( '
      'factory_name TEXT DEFAULT NULL, '
      'auth_token TEXT DEFAULT NULL'
  ');'
};