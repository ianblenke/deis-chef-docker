# Docker container built with chef-solo & berkshelf containing extra infrastructure for deis nodes
FROM ubuntu:14.04
MAINTAINER Ian Blenke "ian@blenke.com"

ENV LANG C.UTF-8

# Add systemd
RUN apt-get -y update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:pitti/systemd
RUN apt-get -y update

RUN apt-get -y install systemd iptables
RUN ln -nsf /proc/self/mounts /etc/mtab

# Install Chef
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bundler chef ruby gem ruby-dep-selector curl build-essential libxml2-dev libxslt-dev git && apt-get clean
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Add latest default chef-solo config files
ADD ./chef-solo.tar.gz /etc/chef
RUN mkdir -p /etc/chef/cache /etc/chef/roles /etc/chef/environments /etc/chef/data_bags /etc/chef/backup
ADD ./solo.rb /etc/chef/solo.rb
ADD ./node.json /etc/chef/node.json

# Add Gemfile to install gems
ADD ./Gemfile /Gemfile
ADD ./Gemfile.lock /Gemfile.lock

RUN bundle install --binstubs

# Run cookbooks
RUN bundle exec chef-solo -c /etc/chef/solo.rb -j /etc/chef/node.json

# Add supervisord services
ADD ./supervisor /etc/supervisor

# Start the service
CMD ["/usr/bin/supervisord", "--nodaemon"]
