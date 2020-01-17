FROM circleci/node:12.13
MAINTAINER olizilla <oli@protocol.ai>

WORKDIR /tmp

ENV CLUSTER_VERSION v0.12.1
ENV CLUSTER_TAR ipfs-cluster-ctl_${CLUSTER_VERSION}_linux-amd64.tar.gz

RUN set -x \
  && wget -q "https://dist.ipfs.io/ipfs-cluster-ctl/$CLUSTER_VERSION/$CLUSTER_TAR" \
  && tar -xzf "$CLUSTER_TAR" --strip-components=1 ipfs-cluster-ctl/ipfs-cluster-ctl \
  && sudo mv ipfs-cluster-ctl /usr/local/bin

RUN set -x \
  && wget --quiet https://ipfs.io/ipfs/QmNgtrMpFRFFr7Gdw9HjoK2H43aVnQ1Ygu87kLP5CZRxB5/ -O dnslink-dnsimple \
  && chmod +x dnslink-dnsimple \
  && sudo mv dnslink-dnsimple /usr/local/bin

COPY scripts/pin-to-cluster.sh /usr/local/bin

ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT
