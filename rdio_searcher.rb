require 'rubygems'
require 'rdio'

@token = Marshal.load File.new ACCESS_TOKEN_FILE
if token
    begin
        Rdio.init_with_token token
    rescue
    end
end

user = Rdio::User.current

Rdio::log_couldnt_find_symbols = false

