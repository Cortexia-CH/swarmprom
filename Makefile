check-env:
ifeq ($(wildcard .env),)
	cp .sample.env .env
	@echo "Generated \033[32m.env\033[0m"
	@echo "  \033[31m>> Check its default values\033[0m"
	@exit 1
else
include .env
export
endif

prom: check-env
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.dev.yml \
	config > docker-stack.yml

deploy-prom: check-env
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.deploy.yml \
	config > docker-stack.yml
	docker stack deploy -c docker-stack.yml $(SWARMPROM_STACKNAME)


###
# Operational commands

ps:
	# A lightly formatted version of docker ps
	docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}} ago'

check-stack:
ifeq ($(wildcard docker-stack.yml),)
	@echo "docker-stack.yml file is missing"
	@echo ">> use \033[1mmake \033[32mprom\033[0m"
	@exit 1
endif

pull: check-stack
	docker-compose -f docker-stack.yml pull

up: check-stack
	docker-compose -f docker-stack.yml up -d

down: check-stack
	docker-compose -f docker-stack.yml down

stop: check-stack
	docker-compose -f docker-stack.yml stop

logs: check-stack
	docker-compose -f docker-stack.yml logs --tail 10 -f
