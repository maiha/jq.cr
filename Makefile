SHELL=/bin/bash

.PHONY : test
test: spec check_version_mismatch

.PHONY : spec
spec:
	crystal spec -v

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep ^version: shard.yml)

test/%: shard.lock
	@echo "----------------------------------------------------------------------"
	@echo "[$*] TARGET=$(TARGET) CFLAGS=$(CFLAGS)"
	@echo "----------------------------------------------------------------------"
	@docker run -t -u "`id -u`" -v "`pwd`:/v" -w /v --rm "crystallang/crystal:$*" crystal spec $(VERBOSE) $(CFLAGS) $(TARGET)

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1 | sed -e 's/^v//')
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : version
version: README.md
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' $< ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
