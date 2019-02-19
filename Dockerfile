FROM circleci/node:10.15.1
MAINTAINER olizilla <oli@protocol.ai>

ENV CLUSTER_VERSION v0.9.0
ENV CLUSTER_TAR ipfs-cluster-ctl_${CLUSTER_VERSION}_linux-amd64.tar.gz

WORKDIR /tmp

RUN set -x \
  && wget -q "https://dist.ipfs.io/ipfs-cluster-ctl/$CLUSTER_VERSION/$CLUSTER_TAR" \
  && tar -xzf "$CLUSTER_TAR" --strip 1

ENTRYPOINT ["./ipfs-cluster-ctl"]
CMD ["--help"]
