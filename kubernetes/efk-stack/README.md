# EFK Stack Helm Umbrella Chart

This chart deploys an Elasticsearch, Fluent Bit, Kibana stack for Kubernetes log aggregation and search.

## Usage

```sh
helm dependency update
helm upgrade --install efk-stack . -n logging --create-namespace
