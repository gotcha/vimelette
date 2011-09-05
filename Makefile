#!/usr/bin/make
#
all: test

tests/bin/python:
	virtualenv-2.6 --no-site-packages tests

tests/bin/buildout: tests/bin/python tests/bootstrap.py tests/buildout.cfg
	cd tests; ./bin/python bootstrap.py

tests/bin/pybot: tests/bin/buildout
	cd tests; ./bin/buildout -vt 5

.PHONY: test
test: tests/bin/pybot
	tests/bin/pybot tests/vimelette.txt

.PHONY: cleanall
cleanall:
	cd tests; rm -fr bin develop-eggs downloads eggs parts .installed.cfg
