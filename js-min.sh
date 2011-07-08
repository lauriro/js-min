#!/bin/sh
#
# Tool for merging and minimizing js files
#
# Usage: ./js-min.sh [-l LICENSE_FILE] [FILE]... > min.js
#
#
# THE BEER-WARE LICENSE
# =====================
#
# <lauri@rooden.ee> wrote this file. As long as you retain this notice
# you can do whatever you want with this stuff. If we meet some day, and
# you think this stuff is worth it, you can buy me a beer in return.
# -- Lauri Rooden
#
#
# Dependencies
# ============
#
# The following is a list of compile dependencies for this project. These
# dependencies are required to compile and run the application:
#   - Unix tools: cat, sed
#
#

while getopts ":l:" opt; do case $opt in
	l)
		sed -e 's/^/ * /' -e '1i/**' -e '$a\ *\/' $OPTARG
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
esac done

shift $((OPTIND-1))

for a in "$@"; do
	# remove comments
	sed -r 's_//.*$__;:n s_/\*[^@]([^*]|\*[^/])*\*/__g;/\/\*[^@]/{N;bn}' $a |
	# strings to separated lines
	sed -r "s_\/(\\\/|[^\/])*\/_\n&\n_g" |sed -r '/^[^\/]/s_"(\\"|[^"])*"_\n&\n_g' | sed -r "/^[^\/\"]/s_'(\\'|[^'])*'_\n&\n_g" |
	# remove spaces
	sed -r '/^['\''"\/]/!{s_\s*([][+=/,:*!?<>;&|\)\(\}\{]|-)\s*_\1_g;s_^\sin\s_in _;/\b(for|while)\(/!s_;$__}' |
	sed -r ':a;/^[][\}\(\)\s\n]*$/{s_\n__;N;$!ba}' |
	# join strings back
	sed -ne 'h;:a;n;/^['\''"\/]/{N;H;x;s_\n__g;x;ba};x;p;$!ba;g;p' |
	sed -e 's/^\s*//' \
	    -e '/^\s*$/d' \
	    -e 's/^[\(\[]/;&/'
done

