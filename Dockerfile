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
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bundler chef ruby ruby-dev gem ruby-dep-selector curl build-essential libxml2-dev libxslt-dev git && apt-get clean
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Add latest default chef-solo config files
ADD ./solo.rb /etc/chef/solo.rb
ADD ./node.json /etc/chef/node.json

# Add Gemfile to install gems
ADD ./Gemfile /Gemfile
ADD ./Gemfile.lock /Gemfile.lock

# Add Berksfile to install cookbooks
ADD ./Berksfile /Berksfile
ADD ./Berksfile.lock /Berksfile.lock

# Install Berkshelf with chef's own ruby
RUN bundle install --binstubs
RUN bundle exec berks install

# Run cookbooks
RUN bundle exec chef-solo

# Add supervisord services
ADD ./supervisor /etc/supervisor

# Start the service
CMD ["/usr/bin/supervisord", "--nodaemon"]
