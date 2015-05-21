test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec 

.PHONY: test