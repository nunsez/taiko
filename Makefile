ARGS = $(filter-out $@, $(MAKECMDGOALS))
%:
	@true

COMPOSE_FILE ?= "./compose.yml"

attach:
	docker attach $(shell docker compose --file $(COMPOSE_FILE) images | grep --regexp='.*-app' | cut --delimiter=' ' --fields=1 | head --lines=1)

in:
	docker compose --file $(COMPOSE_FILE) run --rm app /bin/bash

setup: build install-deps
	$(info The project was successfully configured. Don't forget to add the file with environment variables.)

build:
	USER_ID=$(shell id --user) docker compose --progress tty --file $(COMPOSE_FILE) build

install-deps:
	docker compose --file $(COMPOSE_FILE) run --rm app mix do deps.get, deps.compile

up:
	docker compose --file $(COMPOSE_FILE) up --detach

down:
	docker compose --file $(COMPOSE_FILE) down --remove-orphans

restart:
	docker compose --file $(COMPOSE_FILE) restart $(ARGS)

remove-dangling:
	@if [ -n "$(shell docker images --filter='dangling=true' --quiet)" ]; then \
		docker rmi $(shell docker images --filter='dangling=true' --quiet); \
	fi

logs:
	docker compose --file $(COMPOSE_FILE) logs --follow $(ARGS)
