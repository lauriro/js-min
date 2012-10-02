#!/bin/sh
#
#
# Tool for merging and minimizing js files
#
#    @version  pre-0.3
#    @author   Lauri Rooden - https://github.com/lauriro/js-min
#    @license  MIT License  - http://www.opensource.org/licenses/mit-license
#
# Usage: ./js-min.sh [-l LICENSE_FILE] [-i comment_in_regexp] [-o comment_out_regexp] [FILE]... > min.js
#


export LC_ALL=C

COMMENT_IN="comment_in"
COMMENT_OUT="comment_out"

while getopts ':l:i:o:' OPT; do
	case $OPT in
		l)  sed -e 's/^/ * /' -e '1i\
/**' -e '$a\
\ *\/' $OPTARG;;
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
    -e 's,//.*$,,;tx' \
    -e :x \
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
    -e 's,case $,case,g' \
    -e '/(for|while)\(/!s,;$,,;' |

# join regexps and strings back BSD safe
sed -E -n -e h -e :a -e 'n;/^(['\''"]|\/[^*])/{N;H;x;s,\n,,g;x;};ta' -e 'x;p' -e '$!ba' -e 'g;p' |

# cleanup BSD safe
sed -e 's/^[ 	]*//' -e '/^[ 	]*$/d' -e 's/^[\(\[]/;&/' |

# join lines
sed -E -e :a -e 'N;/[{:?,\|]\n|\n[][)(}{+:?,.\|+-]/s/\n//g' -e '$!ta'  -e 'P;D' |

# minimize javascript
sed -E \
    -e 's/return true/return\!0/g' \
    -e 's,return false,return\!1,g' \
    -e 's,;},},g' \
    -e 's,(new [[:alpha:]]*)\(\),\1,g'


