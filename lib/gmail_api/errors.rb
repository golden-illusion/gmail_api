module GmailApi
  class AccessTokenMissing < ::RuntimeError;end
  class NoSecretsFile < ::RuntimeError;end
  class NotConfigured < ::RuntimeError;end
end