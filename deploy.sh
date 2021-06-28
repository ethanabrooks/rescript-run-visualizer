#! /usr/bin/env bash
docker build -t run-visualizer --build-arg ENDPOINT="rldl12.eecs.umich.edu:1200/v1/graphql" .
docker run -it --rm -p 8081:80 --name run-visualizer -d run-visualizer 


