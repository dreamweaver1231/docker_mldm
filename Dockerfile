# machine learning gears
FROM kaggle/python
MAINTAINER Marsan Ma <marsan@gmail.com>

#---------------------------------
#   basic tools
#---------------------------------
RUN apt-get update
RUN apt-get install -y wget htop vim unzip procps

RUN conda install mkl
RUN conda install libgfortran

#---------------------------------
#   Python libs
#---------------------------------
RUN pip install -U \
  pandas \
  mongoengine \
  bottle \
  cherrypy \
  jieba3k \
  yolk3k \
  azure \
  cython \
  html5lib \
  pyyaml \
  demjson \
  hanziconv \
  ftfy \
  hiredis \
  google-api-python-client

RUN pip install -U \
  Django \
  django-pipeline \
  django-bootstrap3 \
  django_compressor \
  rest-pandas \
  gunicorn \
  boto3 \
  PyMySQL

RUN pip install \
  djangoajax \
  django-dashing


# MySQL
RUN apt-get install -y python3-dev libmysqlclient-dev
RUN pip install mysqlclient


# pathos (python parallel process)
#RUN pip install -U git+https://github.com/uqfoundation/pathos.git@master

#RUN pip install -U \
#  newspaper3k
##---------------------------------
##   Install Java8
##---------------------------------
## Install Java.
#RUN apt-get update  && \
#    DEBIAN_FRONTEND=noninteractive \
#        apt-get install -y -q --no-install-recommends \
#            software-properties-common && \
#    echo "==> Install Java 8..."  && \
#    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
#    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
#    apt-get update  && \
#    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
#    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
#    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
#    echo "==> Clean up..."  && \
#    apt-get remove -y --auto-remove software-properties-common  && \
#    apt-get clean  && \
#    rm -rf /var/lib/apt/lists/* && \
#    rm -rf /var/cache/oracle-jdk8-installer
#
## Define commonly used JAVA_HOME variable
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


#---------------------------------
#   GNU scientific lib
#---------------------------------
#RUN apt-get install -y libgsl0ldbl
#RUN curl -s ftp://ftp.gnu.org/gnu/gsl/gsl-latest.tar.gz | tar -xz -C /usr/local/
#RUN cd /usr/local/ && 

#---------------------------------
#   Hadoop
#---------------------------------
#RUN curl -s http://www.eu.apache.org/dist/hadoop/common/hadoop-2.7.0/hadoop-2.7.0.tar.gz | tar -xz -C /usr/local/
#RUN cd /usr/local && ln -s ./hadoop-2.7.0 hadoop

# Tensorflow
RUN pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.10.0-cp35-cp35m-linux_x86_64.whl


#---------------------------------
#   Supervisord
#---------------------------------
# Install Supervisor.
RUN \
  apt-get update && \
  apt-get install -y supervisor && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# Define mountable directories.
VOLUME ["/etc/supervisor/conf.d"]

# ------------------------------------------------------------------------------
# Security changes
# - Determine runlevel and services at startup [BOOT-5180]
RUN update-rc.d supervisor defaults

# - Check the output of apt-cache policy manually to determine why output is empty [KRNL-5788]
RUN apt-get update | apt-get upgrade -y

# - Install a PAM module for password strength testing like pam_cracklib or pam_passwdqc [AUTH-9262]
RUN apt-get install libpam-cracklib -y
RUN ln -s /lib/x86_64-linux-gnu/security/pam_cracklib.so /lib/security



#---------------------------------
#   Enviroment
#---------------------------------
# Timezone
RUN echo "Asia/Taipei" > /etc/timezone 
RUN dpkg-reconfigure -f noninteractive tzdata

# Add runner script
COPY files/bashrc .bashrc
COPY files/vimrc .vimrc

# setup supervisor apps & start supervisor
COPY files/supervisor/* /etc/supervisor/conf.d/
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

## Set the working directory
WORKDIR /home/workspace

EXPOSE 8880:8900
EXPOSE 80
EXPOSE 443

