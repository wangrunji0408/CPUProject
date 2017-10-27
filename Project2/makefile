all: build

testalu: build
	nvc -e testalu
	nvc -r testalu -w 

test: build
	nvc -e testtop
	nvc -r testtop -w 

build: 
	nvc -a base.vhd
	nvc -a *.vhd

clean:
	rm -r work