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
RUN mkdir -p /etc/chef/cache
ADD ./solo.rb /etc/chef/solo.rb
ADD ./node.json /etc/chef/node.json
ADD ./chef-solo.tar.gz /etc/chef/chef-solo.tar.gz

# Add Gemfile to install gems
ADD ./Gemfile /Gemfile
ADD ./Gemfile.lock /Gemfile.lock

# Add Berksfile to install cookbooks
ADD ./Berksfile /Berksfile
ADD ./Berksfile.lock /Berksfile.lock

# Install Berkshelf
ENV BERKSHELF_PATH /etc/chef
RUN bundle install --binstubs
RUN bundle exec berks install --debug
RUN bundle exec berks vendor -d
RUN ls -la / /etc/chef /etc/chef/cookbooks /.berkshelf /cookbooks || true

# Run cookbooks
RUN bundle exec chef-solo -c /etc/chef/solo.rb -j /etc/chef/node.json -r /etc/chef/chef-solo.tar.gz

# Add supervisord services
ADD ./supervisor /etc/supervisor

# Start the service
CMD ["/usr/bin/supervisord", "--nodaemon"]
