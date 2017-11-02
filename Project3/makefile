all: build

testfakeram: build
	nvc -e testfakeram
	nvc -r testfakeram -w 

testramproj: build
	nvc -e testramproj
	nvc -r testramproj -w 

test: build
	nvc -e testtop
	nvc -r testtop -w 

build: 
	nvc -a base.vhd
	nvc -a *.vhd

clean:
	rm -r work