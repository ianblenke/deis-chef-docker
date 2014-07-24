Introduction
------------

This image augments deis hosts with chef-solo management, and is meant to be run as a --privileged container with volumes mounted for access to the underlying host for management.

This image is based on Ubuntu 14.04 Trusty, mostly for systemd v204, from which fail2ban will watch the systemd journals for ssh attempts.

The service is installed and configured with Chef solo, mostly to allow additional chef management functionality of deis nodes as there is no omnibus chef for coreos.

Supervise is used for spawning processes in this container, mostly to avoid accidentally running systemd, but also to allow a plugable way of running multiple managed daemons in this privileged container.


Background
----------

When deploying a deis host node, it is a rude awakening to find a total lack of support for coreos userspace tools for configuration management.

Rather than fight the trend toward putting everything in a container, embrace it! This project is an attempt to do just that.


Installation
------------

This can be run on a deis host node:

```
sudo bash -c "
cat <<EOF > /etc/systemd/system/deis-chef-docker.service
[Unit]
Description=deis-chef-docker

[Service]
ExecStart=/bin/docker run --name deis-chef-docker --privileged -v=/lib/systemd:/lib/systemd -v=/var/run/docker.sock:/tmp/docker.sock ianblenke/deis-chef-docker
ExecStop=/bin/docker stop deis-chef-docker ; /bin/docker rm deis-chef-docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
"
sudo systemctl disable deis-chef-docker
sudo systemctl enable deis-chef-docker
sudo systemctl start deis-chef-docker
```

Alternatively, edit your contrib/coreos/user-data and add a service definition:

```
  - name: stop-update-engine.service
    command: start
    content: |
      [Unit]
      Description=deis-chef-docker
      
      [Service]
      ExecStart=/bin/docker run --name deis-chef-docker --privileged -v=/lib/systemd:/lib/systemd ianblenke/deis-chef-docker
      ExecStop=/bin/docker stop deis-chef-docker ; /bin/docker rm deis-chef-docker
      Restart=on-failure
      
      [Install]
      WantedBy=multi-user.target
```

The next deis host node you provision should configure this service on boot and start automatically.


Bugs / Contributing
-------------------

If you devise something partcularly clever for deis, I would love a pull request!

For this reason, this project is bound to acquire additional components over time. You are wise to fork this project to suit your needs.

http://github.com/ianblenke/deis-chef-docker

