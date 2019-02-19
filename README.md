# ipfs-dns-deploy

> A Docker image for pinning things to cluster and updating dns via circleci

## Usage

Pin a dir on cluster.ipfs.io

```bash
docker run olizilla/ipfs-dns-deploy \
  --host /dnsaddr/cluster.ipfs.io \
  --basic-auth $CLUSTER_USER:$CLUSTER_PASSWORD \
  add --rmin 3 --rmax 3 --name $DOMAIN \
  --recursive ./build
```

## Why

- We don't want to install `ipfs-cluster-ctl` for every ci build. So it's package it up an image.
- You can't use the docker image `ipfs/ipfs-cluster` as a primary image on circleci. Things like attaching the workspace fail.

Hence this image. It builds off `circleci/node` so it has all the tools to build websites.

## TODO

- Add https://github.com/ipfs/dnslink-dnsimple once https://github.com/ipfs/dnslink-dnsimple/pull/8 is merged.
- Include hugo. Or not. Each site should know how to fetch it's own build dependencies.
