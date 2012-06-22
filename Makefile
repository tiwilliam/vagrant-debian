all: softclean
	bash build.sh

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