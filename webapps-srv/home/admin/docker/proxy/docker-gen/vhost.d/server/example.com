# Doc: set here the lines to add to server section of example.com nginx config file for example.com website.
# Example:
# keepalive_timeout 300;

# Example to redirect an old domain to a new one :
return 302 $scheme://my-sub-domain.example.com$request_uri;
