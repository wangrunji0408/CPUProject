ifndef ENTITY
	ENTITY = top
endif

all: build

# usage: make test [ENTITY=top]
test: build
	nvc -e test${ENTITY}
	nvc -r test${ENTITY} -w 

build: 
	nvc -a cpu/Base.vhd cpu/KernelData.vhd device/*.vhd mock/*.vhd cpu/*.vhd *.vhd test/*.vhd
	nvc -e cpu

clean:
	rm -r work