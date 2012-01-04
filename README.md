Overview
========

A chef repo for IAB deployments onto EC2.

This project assumes the use of opscode's chef server.

Requirements
============

    sudo gem install chef
    gem install net-ssh net-ssh-multi fog highline
    gem install knife-ec2

SSH Configuration
=================

Stop ssh hassling you by adding this to your .ssh/config:

    Host *.amazonaws.com
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null

Credentials
===========

This project requires secrets that are not checked into github.

* `.chef/` contains opscode server credentials.
* `../credentials/aws/` contains AWS credentials.
(Note that the Amazon SSH key must be mode 600)

Github credentials
==================

The `application` recipe, which pulls from github, needs a private key for access to the source code.

So you should have a `~/.ssh/deployment_keys/` with the private and public keys used for this.

Though note that the private key is actually embedded in the application's databag so
the deployment_keys folder itself isn't used during deployment.

Cookbooks
=========

Download cookbooks from opscode community site for the 'cookbooks' directory.

Write custom cookbooks in the 'site-cookbooks' directory.

We also have custom 'roles' and 'data_bags'.

Create EC2 Server
=================

Create a new EC2 server using `./ec2_create.rb`.

Get help on the options: `./ec2_create.rb --help`.

Note that new nodes should be called `iab.<something>` to avoid 
collisions across the whole shared opscode platform!

Chef development
================

* `rake install`: upload local repo to chef server
* BUT data bags don't get uploaded so do: `rake databag:upload_all` as well

Roles
=====

* `iab_server` references the `iab_server` recipe. 
  Installs git, apache2, python, django, mysql.
  Uses the `application` recipe to install iab from master branch in github.
