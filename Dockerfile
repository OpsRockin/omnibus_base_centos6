FROM centos:6
MAINTAINER sawanoboriyu@higanworks.com

RUN yum update -y
RUN yum install curl git -y

## Chef DK
RUN curl -s chef.sh | bash -s -- -P chefdk

## Prepare for omnibus
RUN mkdir /root/chefrepo
ADD files/Berksfile /root/chefrepo/Berksfile
WORKDIR /root/chefrepo
RUN berks vendor cookbooks
RUN chef-client -z -o "omnibus::default"

ADD files/Gemfile /root/Gemfile
ADD files/prebundle.sh /root/prebundle.sh
WORKDIR /root
RUN ./prebundle.sh

ADD files/bash_with_env.sh /home/omnibus/bash_with_env.sh
ADD files/build.sh /home/omnibus/build.sh

ENV HOME /home/omnibus

ONBUILD ADD . /home/omnibus/omnibus-project
ONBUILD VOLUME ["pkg", "/home/omnibus/omnibus-project/pkg"]

WORKDIR /home/omnibus/omnibus-project
ONBUILD RUN bash -c 'source /home/omnibus/load-omnibus-toolchain.sh ; bundle install --binstubs bundle_bin --without development test'

CMD ["/home/omnibus/build.sh"]
