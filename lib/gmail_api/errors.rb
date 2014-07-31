module GmailApi
  class AccessTokenMissing < ::RuntimeError;end
  class NoSecretsFile < ::RuntimeError;end
  class ExpiredToken < ::RuntimeError;end
end