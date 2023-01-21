#!/usr/bin/bash

kops create cluster --name=vprokube.devopslearnershub.xyz \
                    --state=s3://kopstate-bucket \
                    --zones=us-east-1a,us-east-1b \
                    --node-count=2 \
                    --node-size=t3.micro \
                    --node-volume-size=8 \
                    --master-size=t3.micro \
                    --master-volume-size=8 \
                    --dns-zone=vprokube.devopslearnershub.xyz

kops update cluster --name=vprokube.devopslearnershub.xyz --state=s3://kopstate-bucket --yes
cd ~/Repos/vprofile-kube-app || exit
kubectl create -f .
