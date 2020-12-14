OS := $(shell uname | awk '{print tolower($$0)}')
MACHINE := $(shell uname -m)

.DEFAULT_GOAL:=help

# set default shell
SHELL=/bin/bash -o pipefail -o errexit
DEV_ROCKS = "busted 2.0.0" "busted-htest 1.0.0" "luacheck 0.24.0" "luacov 0.14.0"

ifeq ($(OS), darwin)
	LUAROCKS ?= luarocks-5.1
	OS ?= macos
else
	LUAROCKS ?= luarocks
	OS ?= $(OS)
endif

.PHONY: upload install remove test lint dependencies help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# upload:
# 	@$(LUAROCKS) upload $(ROCKSPEC)

install:  ## Install the busted_resty via luarocks
	@$(LUAROCKS) make

remove:  ## Remove the busted_resty via luarocks
	-@$(LUAROCKS) remove busted_resty

lint:  ## Lint Lua code
	@luacheck -q .
	@!(grep -R -E -n -w '#only|#o' spec && echo "#only or #o tag detected") >&2
	@!(grep -R -E -n -- '---\s+ONLY' t && echo "--- ONLY block detected") >&2

test: dependencies remove install  ## Run unit tests
	@bash run_test.sh

dependencies:  ## Install busted_resty dependencies via luarocks
	@for rock in $(DEV_ROCKS) ; do \
		if $(LUAROCKS) list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock already installed, skipping ; \
		else \
			echo $$rock not found, installing via luarocks... ; \
			$(LUAROCKS) install $$rock ; \
		fi \
	done;
