require 'cgi'
require 'time'
require 'hmac'
require 'hmac-sha2'
require 'base64'

module Panda
  class ApiAuthentication
    def self.authenticate(verb, request_uri, host, secret_key, params={})
      query_string = canonical_querystring(params)
      
      string_to_sign = verb + "\n" + 
          host.downcase + "\n" +
          request_uri + "\n" +
          query_string
          
      puts string_to_sign
      
      hmac = HMAC::SHA256.new( secret_key )
      hmac.update( string_to_sign )
      # chomp is important!  the base64 encoded version will have a newline at the end
      signature = Base64.encode64(hmac.digest).chomp 

      puts params.inspect
      puts signature
      return signature
		end
		
    # Insist on specific method of URL encoding, RFC3986. 
    def self.url_encode(string)
      # It's kinda like CGI.escape, except CGI.escape is encoding a tilde when
      # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
      return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end

    # param keys should be strings, not symbols please. return a string joined
    # by & in canonical order. 
    def self.canonical_querystring(params)
      # I hope this built-in sort sorts by byte order, that's what's required. 
      values = params.keys.sort.collect {|key|  [url_encode(key), url_encode(params[key].to_s)].join("=") }

      return values.join("&")
    end
    
  end
end