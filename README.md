XPN Playlist in Rdio creator
============================

# Setup
`gem install nokogiri
gem install open-uri
gem install rdio`

TODO create a bundler file, dummy

`./create_access_token` and enter rdio developer info. This creates a .rdio_access_token


# Running
only fetches hardcoded playlist info right now.
`ruby -r ./xpn_fetch.rb -e "save_info"`

