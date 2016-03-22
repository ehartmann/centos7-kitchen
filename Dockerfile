# Latest version of centos
FROM centos:centos7
MAINTAINER Eric Hartmann <hartmann.eric@gmail.com>

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0
ENV ANSIBLE_VERSION 2.0.1.0

RUN yum clean all && \
    yum -y install sudo openssh-server openssh-clients which curl && \
    yum -y install epel-release && \
    yum -y install PyYAML python-jinja2 python-httplib2 python-keyczar python-paramiko python-setuptools git python-pip && \
    yum -y install git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel ruby

# Install Ansible    
RUN mkdir /etc/ansible/
RUN echo -e '[local]\nlocalhost' > /etc/ansible/hosts
RUN pip install ansible==${ANSIBLE_VERSION}

# Install Ruby
RUN mkdir -p /usr/src/ruby \
    && curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-${RUBY_VERSION}.tar.bz2" | tar -xjC /usr/src/ruby --strip-components=1 \
    && cd /usr/src/ruby \
    && autoconf \
    && ./configure --disable-install-doc \
    && make \
    && yum remove -y ruby \
    && make install \

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

# Reduce size of Docker image
RUN rm -r /usr/src/ruby &&
    yum -y remove epel-release zlib-devel gcc-c++ readline-devel libyaml-devel libffi-devel openssl-devel make autoconf automake libtool bison curl sqlite-devel ruby && \
    yum clean all