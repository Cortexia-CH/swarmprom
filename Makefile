###
# Usual suspects... docker management

ps:
	docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}} ago'

init: check-env

config: check-env
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.dev.yml \
	config > docker-stack.yml

pull: config
	docker-compose -f docker-stack.yml pull $(services)

up: check-stack
	docker-compose -f docker-stack.yml up -d $(services)

down: check-stack
	docker-compose -f docker-stack.yml down

stop: check-stack
	docker-compose -f docker-stack.yml stop $(services)

logs: check-stack
	docker-compose -f docker-stack.yml logs --tail 10 -f $(services)

# no build

# no push

deploy: check-env
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.deploy.yml \
	config > docker-stack.yml
	docker stack deploy -c docker-stack.yml $(SWARMPROM_STACKNAME)


###
# Helpers for initialization

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

check-stack: check-env
ifeq ($(wildcard docker-stack.yml),)
	@echo "docker-stack.yml file is missing"
	@echo ">> use \033[1mmake \033[32mconfig\033[0m"
	@exit 1
endif
