#!/bin/sh
#
#
# Tool for merging and minimizing js files
#
#    @version  pre-0.3
#    @author   Lauri Rooden - https://github.com/lauriro/js-min
#    @license  MIT License  - http://lauri.rooden.ee/mit-license.txt
#
# Usage: ./js-min.sh [-t TOGGLE_REGEXP] [FILE]... > min.js
#


export LC_ALL=C

# Comment blocks may be toggled with the `-t` option.
getopts t: OPT && {
	TOGGLE="$OPTARG"
	shift;shift
}

for a in "$@"; do
	# join wrapped lines
	sed -e :a -e '/\\$/N' -e 's/\\\n//;ta' $a

	# Add extra ending comment
	echo '//*/'
done |

# remove comments BSD safe
sed -E \
    -e 's,//\*\* ('${TOGGLE-COMMENT_OUT}'),/* ,;ta' \
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


