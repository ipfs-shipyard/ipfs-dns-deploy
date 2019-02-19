# ipfs-dns-deploy

> A Docker image for pinning things to cluster and updating dns via circleci

## Usage

Pin a dir on cluster.ipfs.io

```bash
docker run olizilla/ipfs-dns-deploy ipfs-cluster-ctl \
  --host /dnsaddr/cluster.ipfs.io \
  --basic-auth $CLUSTER_USER:$CLUSTER_PASSWORD \
  add --rmin 3 --rmax 3 --name $DOMAIN \
  --recursive ./build
```

Update the DNSLink for a domain via dnsimple

```bash
docker run olizilla/ipfs-dns-deploy dnslink-dnsimple \
  -d $DOMAIN -l /ipfs/$HASH -r _dnslink
```

## Why

- We don't want to install `ipfs-cluster-ctl` and `dnslink-dnsimple` for every ci build. So it's packaged up as an image.
- You can't use the `ipfs/ipfs-cluster` docker image as a primary image on circleci. Things like attaching the workspace fail.

Hence this image. It builds off `circleci/node` so it has all the tools to build websites.

## TODO

- Update https://github.com/ipfs/dnslink-dnsimple once https://github.com/ipfs/dnslink-dnsimple/pull/8 is merged.
- Include hugo. Or not. Each site should know how to fetch it's own build dependencies.
