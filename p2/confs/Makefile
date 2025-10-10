.PHONY: all ingress app1 app2 app3

all: ingress app1 app2 app3

ingress:
	kubectl apply -f /home/vagrant/confs/ingress.yml

app1:
	kubectl apply -f /home/vagrant/confs/app1

app2:
	kubectl apply -f /home/vagrant/confs/app2

app3:
	kubectl apply -f /home/vagrant/confs/app3

fclean:
	kubectl delete -f /home/vagrant/confs/ingress.yml
	kubectl delete -f /home/vagrant/confs/app1
	kubectl delete -f /home/vagrant/confs/app2
	kubectl delete -f /home/vagrant/confs/app3