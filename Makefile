all: softclean
	bash build.sh

softclean:
	@mkdir -p build
	chown -R ${USER} build
	chmod -R u+w build
	rm -rf build/iso/custom
	rm -rf build/iso/initrd
	rm -rf *.box

clean:
	@mkdir -p build
	chown -R ${USER} build
	chmod -R u+w build
	rm -rf build
