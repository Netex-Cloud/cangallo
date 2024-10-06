FROM bitnami/ruby:latest
FROM bkahlert/libguestfs:edge
ENV HOME=/home/libguestfs
RUN apt-get update && apt-get install -y build-essential cmake zlib1g-dev ca-certificates curl git libcrypt1 libffi8 libreadline-dev libsqlite3-dev libssl-dev libssl3 libyaml-0-2 libyaml-dev pkg-config procps sqlite3 unzip wget zlib1g
COPY --from=0 /opt/bitnami/ruby/ /opt/bitnami/ruby/
ENV PATH="/opt/bitnami/ruby/bin:$PATH"

RUN ruby -v
RUN guestfish -v

COPY . $HOME/app
COPY config.yaml.example $HOME/.cangallo/config.yaml
WORKDIR $HOME/app
RUN gem install bundler && bundle install
WORKDIR $HOME

# Install Keybase
RUN curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb \
    && apt install -y ./keybase_amd64.deb \
    && rm keybase_amd64.deb


# Install H2O Web Server
RUN git clone --recurse-submodules https://github.com/h2o/h2o.git
WORKDIR  $HOME/h2o
RUN mkdir -p build && cd build && cmake .. && make
RUN sed -i "s|access-log: /dev/stdout|access-log: $HOME/h2o/access.log|g" examples/h2o/h2o.conf
ENV H2O_ROOT=$HOME/app/images
CMD ["build/h2o", "-c", "examples/h2o/h2o.conf"]