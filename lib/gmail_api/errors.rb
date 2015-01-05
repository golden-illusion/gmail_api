module GmailApi
  class AccessTokenMissing < ::RuntimeError;end
  class NoSecrets < ::RuntimeError;end
  class NotConfigured < ::RuntimeError;end
  class AccessCodeMissing < ::RuntimeError;end
end