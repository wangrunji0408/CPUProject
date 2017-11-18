ifndef ENTITY
	ENTITY = top
endif

all: build

# usage: make test [ENTITY=top]
test: build
	nvc -e test${ENTITY}
	nvc -r test${ENTITY} -w 

build: 
	nvc -a base.vhd
	nvc -a *.vhd
	nvc -a test/*.vhd
	nvc -a device/*.vhd

clean:
	rm -r work