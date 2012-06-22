all: softclean
	bash build.sh

softclean:
	@mkdir -p build
	chown -R ${USER} build
	chmod -R u+w build
	rm -rf build/iso/custom
	rm -rf build/iso/initrd

clean:
	@mkdir -p build
	chown -R ${USER} build
	chmod -R u+w build
	rm -rf build