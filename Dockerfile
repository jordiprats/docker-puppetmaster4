FROM ubuntu:16.04
MAINTAINER Jordi Prats

COPY runme.sh /usr/local/bin/
COPY mkvols.sh /usr/local/bin/

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install tzdata -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install locales -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install git -y

#
# timezone and locale
#
RUN echo "Europe/Andorra" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

RUN export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN DEBIAN_FRONTEND=noninteractive apt-get install gcc -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install make -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install wget -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install strace -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install libxml2-dev -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install zlib1g-dev -y

#
# puppet repo
#
RUN wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
RUN dpkg -i puppetlabs-release-pc1-xenial.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get update

#
# puppet server
#
RUN DEBIAN_FRONTEND=noninteractive apt-get install puppetserver -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install hiera -y

# root@3e0236d13b29:/opt/puppetlabs/server/bin# ./puppetserver start

# root      6516  199 11.3 5777060 1153624 ?     Sl   12:42   2:49 /usr/bin/java -Xms2g -Xmx2g -XX:MaxPermSize=256m -Djava.security.egd=/dev/urandom -XX:OnOutOfMemoryError=kill -9 %p -cp /opt/puppetlabs/server/apps/puppetserver/puppet-server-release.jar clojure.main -m puppetlabs.trapperkeeper.main --config /etc/puppetlabs/puppetserver/conf.d --bootstrap-config /etc/puppetlabs/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/ --restart-file /opt/puppetlabs/server/data/puppetserver/restartcounter

# root@0b39e98ba12a:/etc/puppetlabs# /opt/puppetlabs/bin/puppet module list
# /etc/puppetlabs/code/environments/production/modules (no modules installed)
# /etc/puppetlabs/code/modules (no modules installed)
# /opt/puppetlabs/puppet/modules (no modules installed)

# pendent
#
# RUN mkdir -p /usr/local/src/puppet-masterless
# RUN git clone https://github.com/jordiprats/puppet-masterless /usr/local/src/puppet-masterless
#
# RUN mkdir -p /usr/local/src/eyp-puppet
# RUN git clone https://github.com/jordiprats/eyp-puppet /usr/local/src/eyp-puppet
#
# RUN mkdir -p /usr/local/puppet-masterless
# RUN git clone https://github.com/jordiprats/puppet-masterless /usr/local/puppet-masterless


#
# dependencies
#

# yamlwildcard - TODO: actualitzar puppet4
RUN mkdir -p /usr/local/src/yamlwildcard
RUN git clone https://github.com/jordiprats/hiera-yaml_wildcard /usr/local/src/yamlwildcard
RUN bash -c 'cd /usr/local/src/yamlwildcard; gem build /usr/local/src/yamlwildcard/hiera-yaml_wildcard.gemspec'
RUN gem install /usr/local/src/yamlwildcard/hiera-yaml_wildcard-0.1.0.gem

#deep_merge
RUN gem install deep_merge

#templates puppe module generate
RUN mkdir -p /usr/local/src/puppet-module-skeleton
RUN git clone https://github.com/NTTCom-MS/puppet-module-skeleton.git /usr/local/src/puppet-module-skeleton
RUN bash -c 'cd /usr/local/src/puppet-module-skeleton; bash install.sh'

#
# puppet strings
#
RUN /opt/puppetlabs/bin/puppet resource package yard provider=puppet_gem
RUN /opt/puppetlabs/bin/puppet module install puppetlabs-strings

VOLUME ["/etc/puppetlabs/puppet/ssl"]
VOLUME ["/etc/puppetlabs/code"]


CMD /bin/bash /usr/local/bin/runme.sh
EXPOSE 8140
