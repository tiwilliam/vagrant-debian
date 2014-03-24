all: 64

32: deps softclean build-32
64: deps softclean build-64

deps:
	@which bsdtar || { echo "ERROR: bsdtar not found. Aborting."; exit 1; }
	@which mkisofs || which genisoimage || { echo "ERROR: mkisofs not found. Aborting."; exit 1; }
	@which vagrant || { echo "ERROR: vagrant not found. Aborting."; exit 1; }
	@which VBoxManage || { echo "ERROR: VirtualBox not found. Aborting."; exit 1; }

fixowner:
	@mkdir -p build
	@chown -R ${USER} build
	@chmod -R u+w build

build-32: fixowner
	bash src/build.sh 32

build-64: fixowner
	bash src/build.sh 64

softclean: fixowner
	rm -rf build/custom
	rm -rf build/initrd
	rm -rf *.box

clean: fixowner
	rm -rf build
	rm -rf *.box
