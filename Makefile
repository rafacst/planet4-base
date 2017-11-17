COMPOSER?=composer.json

.DEFAULT_GOAL := all

all : test update build
.PHONY : all

.PHONY : test
test:

.PHONY : update
update:
		./composer_update_lockfile.sh

.PHONY : build
build:
		./build.sh -rp
