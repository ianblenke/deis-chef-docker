root = File.absolute_path(File.dirname(__FILE__))

verbose_logging  true
log_level        :debug
file_cache_path  '/etc/chef/cache'
data_bag_path    '/etc/chef/data_bags'
cookbook_path    '/etc/chef/cookbooks'
backup_path      '/etc/chef/backup'
environment_path 'etc/chef/environments'
role_path        '/etc/chef/roles'
json_attribs     '/etc/chef/node.json'
recipe_url       'file:///etc/chef/chef-solo.tar.gz'

