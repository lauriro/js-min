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
#   - Unix tools: sed
#
#

while getopts ':l:' OPT; do
	case $OPT in
		l)  sed -e 's/^/ * /' -e '1i/**' -e '$a\ *\/' $OPTARG;;

		:)  echo "Option -$OPTARG requires an argument." >&2; exit 1;;
		\?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
	esac
done

shift $((OPTIND-1))


for a in "$@"; do
	# remove comments BSD safe
	sed -E -e 's,//.*$,,' -e '/\/\*([^@!]|$)/ba' -e b -e :a -e 's,/\*[^@!]([^*]|\*[^/])*\*/,,g;t' -e 'N;ba' $a |

	# regexps and strings to separated lines BDS safe
	sed -E -e 's,/(\\/|[^*/])*/,\
&\
,g' | sed -E -e '/^[^\/]/s,"(\\"|[^"])*",\
&\
,g' | sed -E -e '/^[^\/"]/s,'\''(\\'\''|[^'\''])*'\'',\
&\
,g' |

	# remove spaces BSD safe
	sed -E -e "/^['\"\/]/b" \
	       -e 's_[ 	]*([][+=/,:*!?<>;&|\)\(\}\{]|-)[ 	]*_\1_g' \
	       -e 's,^ in ,in ,g' \
	       -e '/\b(for|while)\(/!s,;$,,;' |

	# join regexps and strings back BSD safe
	sed -E -n -e h -e :a -e 'n;/^(['\''"]|\/[^*])/{N;H;x;s,\n,,g;x;};ta' -e 'x;p' -e '$!ba' -e 'g;p' |

	# join closing closures to a previous line BSD safe
	sed -E -e :a -e 'N;/\n[][\}\(\):]+$/s/\n//g;ta' -e 'P;D' |

	# final cleanup BSD safe
	sed -e 's/^[ 	]*//' -e '/^[ 	]*$/d' -e 's/^[\(\[]/;&/'
done

