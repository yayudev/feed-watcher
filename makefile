.PHONY: build test

init:
	npm install

docs:
	docco src/*.coffee

clean-docs:
	rm -rf docs/

clean: clean-docs
	rm -rf lib/ test/*.js

build:
	coffee -o lib/ -c src/

test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec

dist: clean init docs build test

publish: dist
	npm publish
