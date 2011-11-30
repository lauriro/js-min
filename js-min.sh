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

COMMENT_IN="comment_in"
COMMENT_OUT="comment_out"

while getopts ':l:i:o:' OPT; do
	case $OPT in
		l)  sed -e 's/^/ * /' -e '1i/**' -e '$a\ *\/' $OPTARG;;
		i)  COMMENT_IN="$OPTARG";;
		o)  COMMENT_OUT="$OPTARG";;

		:)  echo "Option -$OPTARG requires an argument." >&2; exit 1;;
		\?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
	esac
done

shift $((OPTIND-1))


for a in "$@"; do
	# join wrapped lines
	sed -e :a -e '/\\$/N' -e 's/\\\n//;ta' $a

	# Add extra ending comment
	echo '//*/'
done |

# remove comments BSD safe
sed -E \
		-e 's,//\*\* ('$COMMENT_OUT'),/* ,;ta' \
		-e 's,/\*\* ('$COMMENT_IN'),// ,' \
		-e 's,//.*$,,' \
		-e '/\/\*([^@!]|$)/ba' \
		-e b \
		-e :a \
		-e 's,/\*[^@!]([^*]|\*[^/])*\*/,,g;t' \
		-e 'N;ba' |

# regexps and strings to separated lines BDS safe
sed -E -e 's,/(\\\*|[^*])(\\/|[^/])*/,\
&\
,g' |
sed -E -e '/^[^\/]/s,"(\\"|[^"])*",\
&\
,g' |
sed -E -e '/^[^\/"]/s,'\''(\\'\''|[^'\''])*'\'',\
&\
,g' |

# remove spaces BSD safe
sed -E \
    -e "/^['\"\/]/b" \
    -e 's_[ 	]*([][+=/,:*!?<>;&|\)\(\}\{]|-)[ 	]*_\1_g' \
    -e 's,^  *in ,in ,g' \
    -e 's,\bcase $,case,g' \
    -e '/\b(for|while)\(/!s,;$,,;' |
	
# join regexps and strings back BSD safe
sed -E -n -e h -e :a -e 'n;/^(['\''"]|\/[^*])/{N;H;x;s,\n,,g;x;};ta' -e 'x;p' -e '$!ba' -e 'g;p' |

# cleanup BSD safe
sed -e 's/^[ 	]*//' -e '/^[ 	]*$/d' -e 's/^[\(\[]/;&/' |

# join closing closures to a previous line BSD safe
sed -E -e :a -e 'N;/\n([-+.,:?{|]|[][\}\(\):,]+$)/s/\n//g;ta' -e 'P;D' |

# minimize javascript
sed -E \
    -e 's,\breturn true\b,return!0,g' \
    -e 's,\breturn false\b,return!1,g' \
    -e 's,(\bnew [[:alpha:]]*)\(\),\1,g'


