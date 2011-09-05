#!/usr/bin/make
#

.PHONY: install
install: bootstrap buildout

.PHONY: bootstrap
bootstrap:
	virtualenv-2.6 --no-site-packages .
	./bin/python bootstrap.py

.PHONY: buildout
buildout:
	if ! test -f bin/buildout;then make bootstrap;fi
	bin/buildout -vt 5

.PHONY: test
test:
	if ! test -f bin/pybot;then make buildout;fi
	bin/pybot vimelette.txt

.PHONY: cleanall
cleanall:
	rm -fr develop-eggs downloads eggs parts .installed.cfg
