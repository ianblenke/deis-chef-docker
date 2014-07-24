root = File.absolute_path(File.dirname(__FILE__))

verbose_logging true
log_level :debug
file_cache_path '/etc/chef/cache'
cookbook_path '/etc/chef/cookbooks'
json_attribs '/etc/chef/node.json'
