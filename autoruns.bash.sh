#!/bin/bash
#MIT License
#
#Copyright (c) 2020 Nick Trebes
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

if [ `id -u` -ne 0 ]; then
	echo "$0: must be run as root"
	exit 1
fi

function ar_getexe {
	if [ -d "/proc/$1" ]; then
		if [ -e "/proc/$1/exe" ]; then
			ls -l "/proc/$1/exe" | tr -s ' ' | cut -d' ' -f11
		elif [ -e "/proc/$1/path/a.out" ]; then
			ls -l "/proc/$1/path/a.out" | tr -s ' ' | cut -d' ' -f11
		fi
	fi
}

function ar_sysv {
	echo init: sysv
}

function ar_smf {
	echo init: smf
}

function ar_systemd {
	echo init: systemd
}

function ar_upstart {
	echo init: upstart
}

function ar_test_systemd {
	case $1 in
		'/lib/systemd/systemd'|'/usr/lib/systemd/systemd')
			ar_systemd
			exit 0
			;;
	esac
}

ar_test_systemd `ar_getexe 1`
ar_test_systemd `ls -l /sbin/init | tr -s ' ' | cut -d' ' -f11`

if [ -d /etc/init ]; then
	if [ `grep pstart /etc/inittab | wc -l` -gt 0 ]; then
		ar_upstart
	else
		ar_sysv
	fi
else
	ar_sysv
fi

