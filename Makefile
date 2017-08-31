SHELL=/bin/bash

.PHONY : test
test: spec check_version_mismatch

.PHONY : spec
spec:
	crystal spec -v

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep ^version: shard.yml)

