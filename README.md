	# Need to configure vivado here.

	mkdir work
	cd work
	curl -L https://github.com/ipbus/ipbb/archive/dev/2021h.tar.gz | tar xvz
	source ipbb-dev-2021h/env.sh 
	ipbb init build
	cd build

	ipbb add git https://github.com/ipbus/ipbus-firmware.git -b  v1.8
	ipbb add git -b developer git@github.com:ipbus-contrib/digilent.git 
	ipbb add git https://github.com/stnolting/neo430.git -b 0x0408
	
	# These next steps compile the software running on the neo430.
	# These are only required if you want to read mac address from prom. 
	# You will need msp430-gcc installed for this.
	# pushd src/digilent/components/neo430_wrapper/software/neo430_ipbus_address_terminal/
	# make clean_all 
	# make install
	# popd

	# Create IPBB project....
 	# For static ip address project. 
	ipbb proj create vivado top_a200-digilent-nexys-video digilent:projects/example top_digilent_nexys_video_a200.dep

	# To read mac from prom.
	# ipbb proj create vivado top_a200-macprom-example-24AA025E digilent:projects/example top_digilent_a200_macprom_24AA025E.dep
	
	cd proj/top_a200-digilent-nexys-video
	# OR
	# cd proj/top_a200-macprom-example-24AA025E

	ipbb vivado project
	ipbb vivado impl
	ipbb vivado bitfile

	# Only required for mac from prom design.
	# ipbb vivado memcfg
	
	# To package bitfile with addr table and file list.
	# ipbb vivado package

	deactivate
