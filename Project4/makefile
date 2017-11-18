ifndef ENTITY
	ENTITY = top
endif

all: build

# usage: make test [ENTITY=top]
test: build
	nvc -e test${ENTITY}
	nvc -r test${ENTITY} -w 

build: 
	nvc -a cpu/Base.vhd
	nvc -a *.vhd
	nvc -a test/*.vhd
	nvc -a device/*.vhd
	nvc -a mock/*.vhd
	nvc -a cpu/*.vhd
	nvc -e cpu

clean:
	rm -r work