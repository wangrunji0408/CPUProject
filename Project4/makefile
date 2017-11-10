all: build

testfakeram: build
	nvc -e testfakeram
	nvc -r testfakeram -w 

test: build
	nvc -e testtop
	nvc -r testtop -w 

build: 
	nvc -a base.vhd
	nvc -a *.vhd

clean:
	rm -r work