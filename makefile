.PHONY: build test

init:
	npm install

docs:
	docco src/*.js

clean-docs:
	rm -rf docs/

clean: clean-docs
	rm -rf lib/

build:
	babel -o lib/index.js src/index.js

test:
	./node_modules/.bin/mocha --require test/babelhook.js --reporter spec

dist: clean init docs build test

publish: dist
	npm publish
