# Load .env if it exists
ifneq (,$(wildcard ./.env))
	include .env
	export
endif

# Default forge command
FORGE = forge

# Targets
build:
	$(FORGE) build

test:
	$(FORGE) test

test-fork:
	$(FORGE) test --fork-url $(MAINNET_FORK_URL) -vvv

# Usage: make test-one NAME=test_swapExactTokensForTokens
test-one:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Please specify test name, e.g. make test-one NAME=test_swapExactTokensForTokens"; \
	else \
		$(FORGE) test --fork-url $(MAINNET_FORK_URL) -vvv --match-test $(NAME); \
	fi

clean:
	$(FORGE) clean

clean:
	$(FORGE) clean
