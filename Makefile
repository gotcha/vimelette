#!/usr/bin/make
#
.PHONY: bootstrap
bootstrap:
	virtualenv-2.6 --no-site-packages tests
	cd ${CURDIR}/tests; ./bin/python ./bootstrap.py

.PHONY: buildout
buildout:
	if ! test -f ./tests/bin/buildout;then make bootstrap;fi
	cd ${CURDIR}/tests; ./bin/buildout -vt 5

.PHONY: test
test:
	if ! test -f ./tests/bin/pybot;then make buildout;fi
	./tests/bin/pybot tests/vimelette.txt

.PHONY: cleanall
cleanall:
	cd ${CURDIR}/tests; rm -fr develop-eggs downloads eggs parts .installed.cfg
