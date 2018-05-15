#
# Makefile for loginwindowbgconverter
# vim:set fo=tcqr:
#

loginwindowbgconverter: loginwindowbgconverter.swift
	swiftc -g -o loginwindowbgconverter loginwindowbgconverter.swift

clean:
	rm -f loginwindowbgconverter
