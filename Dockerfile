FROM ubuntu:14.04 

# First installing Ubuntu Packages to setup infrastructure 

RUN apt-get update && apt-get install -y \
    git \
    python-dev \
    python3-pip \
    python-setuptools \
    vim \
    tmux \
    curl \
    nodejs \
    npm

RUN npm install -g bower

# Configure Django project
COPY ./webapp /app

WORKDIR /app


RUN apt-get install -y python-pip

# Virtual Environment 

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN pip install virtualenv
RUN pip install virtualenvwrapper
RUN export WORKON_HOME=$HOME/.virtualenvs
RUN export PROJECT_HOME=$HOME/Devel
RUN export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
RUN export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python3'
RUN source /usr/local/bin/virtualenvwrapper_lazy.sh

RUN mkdir -p /opt/virtualenvs
ENV WORKON_HOME /opt/virtualenvs
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh \
    && mkvirtualenv --no-site-package -p /usr/bin/python3 Knight  \
    && workon Knight \
    && pip3 install -r /app/requirements.txt"


# Install MongoDB.
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
  apt-get update && \
  apt-get install -y mongodb-org && \
  rm -rf /var/lib/apt/lists/*


# Define mountable directories.
VOLUME ["/data/db"]


# Expose ports.
#   - 27017: process
#   - 28017: http
EXPOSE 27017
EXPOSE 8000

RUN npm install -g gulp

#RUN gulp clean

#RUN glup dev
RUN apt-get update && apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
