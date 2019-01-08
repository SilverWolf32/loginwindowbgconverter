#
# Makefile for loginwindowbgconverter
# vim:set fo=tcqr:
#

loginwindowbgconverter: loginwindowbgconverter.swift
	swiftc -g -o loginwindowbgconverter loginwindowbgconverter.swift

release: loginwindowbgconverter.swift
	mkdir -p dist/
	swiftc -o dist/loginwindowbgconverter loginwindowbgconverter.swift

clean:
	rm -f loginwindowbgconverter
