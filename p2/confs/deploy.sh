#!/bin/bash

kubectl apply -f /home/vagrant/confs/ingress.yml
kubectl apply -f /home/vagrant/confs/app1
kubectl apply -f /home/vagrant/confs/app2
kubectl apply -f /home/vagrant/confs/app3