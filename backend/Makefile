# Makefile for Docker Compose Development

# Variables
COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = myapp

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

## Development Commands

.PHONY: dev
dev: ## Start all services in development mode
	@echo "$(GREEN)Starting all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up --build

.PHONY: dev-detached
dev-detached: ## Start all services in development mode (detached)
	@echo "$(GREEN)Starting all services in detached mode...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up --build -d

.PHONY: stop
stop: ## Stop all running services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) stop

.PHONY: down
down: ## Stop and remove all containers, networks
	@echo "$(RED)Stopping and removing containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

.PHONY: down-volumes
down-volumes: ## Stop and remove all containers, networks, and volumes
	@echo "$(RED)Stopping and removing containers, networks, and volumes...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v

.PHONY: restart
restart: down dev ## Restart all services

## Build Commands

.PHONY: build
build: ## Build all services
	@echo "$(GREEN)Building all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

.PHONY: build-no-cache
build-no-cache: ## Build all services without cache
	@echo "$(GREEN)Building all services without cache...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build --no-cache

.PHONY: pull
pull: ## Pull latest images
	@echo "$(GREEN)Pulling latest images...$(NC)"
	docker-compose -f $(COMPOSE_FILE) pull

## Database Commands

.PHONY: db-shell
db-shell: ## Connect to PostgreSQL shell
	@echo "$(GREEN)Connecting to database shell...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec db psql -U user -d mydatabase

.PHONY: db-logs
db-logs: ## Show database logs
	docker-compose -f $(COMPOSE_FILE) logs -f db

## Service Management

.PHONY: logs
logs: ## Show logs for all services
	docker-compose -f $(COMPOSE_FILE) logs -f

.PHONY: logs-backend
logs-backend: ## Show backend service logs
	docker-compose -f $(COMPOSE_FILE) logs -f backend

.PHONY: backend-shell
backend-shell: ## Connect to backend container shell
	docker-compose -f $(COMPOSE_FILE) exec backend /bin/bash

.PHONY: ps
ps: ## Show running containers
	docker-compose -f $(COMPOSE_FILE) ps

## Cleanup Commands

.PHONY: clean
clean: ## Remove stopped containers and unused images
	@echo "$(YELLOW)Cleaning up containers and images...$(NC)"
	docker container prune -f
	docker image prune -f

.PHONY: clean-all
clean-all: ## Remove all containers, images, volumes, and networks
	@echo "$(RED)WARNING: This will remove ALL Docker resources!$(NC)"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]
	docker system prune -a -f --volumes

## Environment

.PHONY: env-example
env-example: ## Create example environment file
	@echo "$(GREEN)Creating .env.example file...$(NC)"
	@echo "DATABASE_URL=postgresql://user:password@localhost:5433/mydatabase" > .env.example
	@echo "JWT_SECRET=your-super-secret-jwt-key-here" >> .env.example
	@echo "Created .env.example - copy to .env and update values"

.PHONY: check-env
check-env: ## Check if required environment variables are set
	@echo "$(GREEN)Checking environment variables...$(NC)"
	@if [ ! -f .env ]; then echo "$(RED)Error: .env file not found!$(NC)"; exit 1; fi
	@grep -q "DATABASE_URL" .env || (echo "$(RED)Error: DATABASE_URL not set in .env$(NC)" && exit 1)
	@grep -q "JWT_SECRET" .env || (echo "$(RED)Error: JWT_SECRET not set in .env$(NC)" && exit 1)
	@echo "$(GREEN)Environment variables check passed!$(NC)"

## Help

.PHONY: help
help: ## Show this help message
	@echo "$(GREEN)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)Quick start:$(NC)"
	@echo "  1. Copy .env.example to .env: $(YELLOW)make env-example && cp .env.example .env$(NC)"
	@echo "  2. Edit .env with your values"
	@echo "  3. Start development: $(YELLOW)make dev$(NC)"