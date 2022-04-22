FROM circleci/node:12.13
MAINTAINER olizilla <oli@protocol.ai>

WORKDIR /tmp

ENV CLUSTER_VERSION v1.0.0
ENV CLUSTER_TAR ipfs-cluster-ctl_${CLUSTER_VERSION}_linux-amd64.tar.gz

# Fix certificates
RUN sudo apt-get update && sudo apt-get install -y ca-certificates libgnutls30 wget && sudo update-ca-certificates

RUN set -x \
  && wget "https://dist.ipfs.io/ipfs-cluster-ctl/$CLUSTER_VERSION/$CLUSTER_TAR" \
  && tar -xzf "$CLUSTER_TAR" --strip-components=1 ipfs-cluster-ctl/ipfs-cluster-ctl \
  && sudo mv ipfs-cluster-ctl /usr/local/bin

RUN set -x \
  && wget --quiet https://ipfs.io/ipfs/QmNgtrMpFRFFr7Gdw9HjoK2H43aVnQ1Ygu87kLP5CZRxB5/ -O dnslink-dnsimple \
  && chmod +x dnslink-dnsimple \
  && sudo mv dnslink-dnsimple /usr/local/bin

COPY scripts/pin-to-cluster.sh /usr/local/bin
RUN sudo chown circleci:circleci /usr/local/bin/pin-to-cluster.sh
RUN sudo chmod go+rx /usr/local/bin/pin-to-cluster.sh

ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT
