# frozen_string_literal: true
module Infrastructure::RestClientExceptions
  EXCEPTIONS = [RestClient::RequestFailed, RestClient::SSLCertificateNotVerified, OpenSSL::SSL::SSLError, SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNRESET].freeze
end
