# Docker container built with chef-solo & berkshelf containing extra infrastructure for deis nodes
FROM ubuntu:14.04
MAINTAINER Ian Blenke "ian@blenke.com"

ENV LANG C.UTF-8

# Add systemd
RUN apt-get -y update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:pitti/systemd
RUN apt-get -y update

RUN apt-get -y install systemd
RUN ln -nsf /proc/self/mounts /etc/mtab

# Fail2ban really wants iptables
RUN apt-get -y install iptables

# Install Chef
RUN apt-get -y install curl build-essential libxml2-dev libxslt-dev git
RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Add the embedded chef bin to PATH
ENV PATH $PATH:/opt/chef/embedded/bin

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
RUN /opt/chef/embedded/bin/gem install bundler
RUN /opt/chef/embedded/bin/bundle install --binstubs
RUN /opt/chef/embedded/bin/bundle exec berks install

# Run cookbooks
RUN chef-solo || cat /etc/chef/chef-stacktrace.out ; false

# Add supervisord services
ADD ./supervisor /etc/supervisor

# Start the service
CMD ["/usr/bin/supervisord", "--nodaemon"]
