FROM ubuntu:16.04
MAINTAINER Jordi Prats

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

RUN DEBIAN_FRONTEND=noninteractive apt-get update

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
RUN DEBIAN_FRONTEND=noninteractive apt-get install puppetserver

EXPOSE 8140

# root@3e0236d13b29:/opt/puppetlabs/server/bin# ./puppetserver start

# root      6516  199 11.3 5777060 1153624 ?     Sl   12:42   2:49 /usr/bin/java -Xms2g -Xmx2g -XX:MaxPermSize=256m -Djava.security.egd=/dev/urandom -XX:OnOutOfMemoryError=kill -9 %p -cp /opt/puppetlabs/server/apps/puppetserver/puppet-server-release.jar clojure.main -m puppetlabs.trapperkeeper.main --config /etc/puppetlabs/puppetserver/conf.d --bootstrap-config /etc/puppetlabs/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/ --restart-file /opt/puppetlabs/server/data/puppetserver/restartcounter


#CMD /bin/bash /usr/local/bin/runme.sh
