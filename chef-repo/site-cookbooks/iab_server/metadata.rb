maintainer       "Kube Partners"
maintainer_email "stevemeyfroidt@kubepartners.co.uk"
license          "All rights reserved"
description      "Installs IAB Server to Apache/WSGI with a new MySQL database"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
recipe            "iab_server", "Install IAB Server from github into Apache/WSGI with a new MySQL database"

depends "mysql"
depends "database"
depends "apache2"
depends "django"
depends "application"
