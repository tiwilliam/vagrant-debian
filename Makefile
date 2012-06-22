all: 64

32: deps softclean build-32
64: deps softclean build-64

build-32:
	bash build.sh 32

build-64:
	bash build.sh 64

deps:
	@which -s VBoxManage || { echo "ERROR: VirtualBox not found. Aborting."; exit 1; }
	@which -s mkisofs || { echo "ERROR: mkisofs not found. Aborting."; exit 1; }
	@which -s bsdtar || { echo "ERROR: bsdtar not found. Aborting."; exit 1; }

softclean: fixowner
	rm -rf build/iso/custom
	rm -rf build/iso/initrd
	rm -rf *.box

clean: fixowner
	rm -rf build
	rm -rf *.box

fixowner:
	@mkdir -p build
	chown -R ${USER} build
	chmod -R u+w build