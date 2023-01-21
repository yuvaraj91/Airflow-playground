REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
AIRFLOW_WEBSERVER_CONTAINER = airflow-webserver
AIRFLOW_SCHEDULER_CONTAINER = airflow-scheduler
VENV = ./venv

.PHONY: default build clean-venv init-venv airflow-down airflow-up

.PHONY: activate
activate:
ifneq (,$(wildcard $(VENV)))
	. $(VENV)/bin/activate
else
	@echo "Run $(BOLD)make init-venv $(RESET) to initialize a venv"
endif

.PHONY: build
build:
	@docker-compose build

.PHONY: airflow-up
airflow-up: airflow-down build
	@docker-compose up -d
	@docker exec -it ${AIRFLOW_WEBSERVER_CONTAINER} airflow users create --username airflow --password airflow --firstname admin --lastname admin --role Admin --email airflow@admin.org
	@echo $(AIRFLOW_MESSAGE)

.PHONY: airflow-down
airflow-down:
	@docker-compose down

.PHONY: airflow-webserver-logs
airflow-webserver-logs:
	@docker logs --follow $(AIRFLOW_WEBSERVER_CONTAINER)

.PHONY: airflow-scheduler-logs
airflow-scheduler-logs:
	@docker logs --follow $(AIRFLOW_SCHEDULER_CONTAINER)

.PHONY: airflow-webserver-shell
airflow-webserver-shell:
	@docker exec -it $(AIRFLOW_WEBSERVER_CONTAINER) /bin/bash

.PHONY: airflow-scheduler-shell
airflow-scheduler-shell:
	@docker exec -it $(AIRFLOW_SCHEDULER_CONTAINER) /bin/bash

.PHONY: clean-local
clean-local:
	@rm -rf logs
	@rm -f airflow.cfg
	@rm -f airflow.db
	@rm -f webserver_config.py

.PHONY: clean-metadata-db
clean-metadata-db: airflow-down
	@rm -rf postgres_data
	@echo "Folder $(BOLD)postgres_data$(RESET) was removed!"

.PHONY: clean-venv
clean-venv:
	@rm -rf venv

.PHONY: init-venv
init-venv: clean-venv
	pip3 install virtualenv; \
	virtualenv venv --python=python3.9; \
	. ./venv/bin/activate; \
	pip3 install -r requirements-dev.txt; \
	pip3 install -r requirements-providers.txt; \
	pip3 install -r requirements.txt;
