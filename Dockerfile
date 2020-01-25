FROM centos:centos7

# This image provides a Node.JS environment you can use to run your Node.JS
# applications.

# Add $HOME/node_modules/.bin to the $PATH, allowing user to make npm scripts
# available on the CLI without using npm's --global installation mode
# This image will be initialized with "npm run $NPM_RUN"
# See https://docs.npmjs.com/misc/scripts, and your repo's package.json
# file for possible values of NPM_RUN
# Description
# Environment:
# * $NPM_RUN - Select an alternate / custom runtime mode, defined in your package.json files' scripts section (default: npm run "start").
# Expose ports:
# * 8080 - Unprivileged port used by nodejs application

ENV NODEJS_VERSION=10 \
    NPM_RUN=start \
    NAME=nodejs \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

ENV SUMMARY="Platform for building and running Node.js $NODEJS_VERSION applications" \
    DESCRIPTION="Node.js $NODEJS_VERSION available as container is a base platform for \
building and running various Node.js $NODEJS_VERSION applications and frameworks. \
Node.js is a platform built on Chrome's JavaScript runtime for easily building \
fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model \
that makes it lightweight and efficient, perfect for data-intensive real-time applications \
that run across distributed devices."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Node.js $NODEJS_VERSION" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.deployments-dir="${APP_ROOT}/src" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858"\
      com.redhat.component="rh-$NAME$NODEJS_VERSION-container" \
      name="centos/$NAME-$NODEJS_VERSION-centos7" \
      version="$NODEJS_VERSION" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>" \
      help="For more information visit https://github.com/djdrisco/kubernetes-centos7-node" 


RUN yum -y update \
  && yum -y install centos-release-scl \
  && yum -y install which devtoolset-7-make devtoolset-7-gcc devtoolset-7-gcc-c++ \
  && curl -sL https://nodejs.org/dist/v8.9.1/node-v8.9.1.tar.gz | tar xz -C /tmp \
  && cd /tmp/node-v8.9.1 \
  && scl enable devtoolset-7 "./configure" \
  && scl enable devtoolset-7 "make -j $(nproc)" \
  && scl enable devtoolset-7 "make install" \
  && cd / \
  && node -v \
  && npm -v \
#  && rm -rf /tmp/node* \
#  && yum clean all \
#  && rm -rf /var/cache/yum

#RUN yum install -y centos-release-scl-rh && \
#    ( [ "rh-${NAME}${NODEJS_VERSION}" != "${NODEJS_SCL}" ] && yum remove -y ${NODEJS_SCL}\* || : ) && \
#    INSTALL_PKGS="rh-nodejs${NODEJS_VERSION}-nodejs rh-nodejs${NODEJS_VERSION}-npm rh-nodejs${NODEJS_VERSION}-nodejs-nodemon nss_wrapper" && \
#    ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon && \
#    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
#    rpm -V $INSTALL_PKGS && \
#    yum -y clean all --enablerepo='*'
    


#IS THIS REQUIRED?
# Drop the root user and make the content of /opt/app-root owned by user 1001
#RUN chown -R 1001:0 ${APP_ROOT} && chmod -R ug+rwx ${APP_ROOT} && \
#    rpm-file-permissions

#USER 1001

#test nodemon
#CMD ["nodemon", "-h"]

#test node install
#CMD  ["node","-v"]

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install production dependencies.
RUN npm install --only=production

# Copy local code to the container image.
COPY . ./

# Run the web service on container startup.
CMD [ "npm", "start" ]
