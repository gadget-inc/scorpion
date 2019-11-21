# frozen_string_literal: true

module Infrastructure::ServiceAvailability
  def self.test_uri(uri)
    uri = URI.parse(uri)
    test(uri.host, uri.port)
  end

  def self.test(host, port)
    Socket.tcp(host, port, connect_timeout: 3) { }
    true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EADDRNOTAVAIL
    false
  end

  def self.block_until_available(uri, timeout: 15)
    Wait.new(timeout: timeout, delay: 1, attempts: timeout + 1).until { test_uri(uri) }
  end
end
