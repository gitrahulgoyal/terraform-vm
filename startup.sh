#!/bin/bash
yum install -y httpd
service httpd start
chkconfig httpd on
echo '<body bgcolor=#FF00AA></body>' > /var/www/html/index.html