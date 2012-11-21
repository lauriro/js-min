#!/bin/bash

EXIT=0

cd ${0%/*}

DIFF=$(../js-min.sh -t 'opt2|opt3' js-src.js | diff - js-min.js)
if [ -n "$DIFF" ];then
	EXIT=1
	printf "Test js-min.js fail:\n%s" "$DIFF" 1>&2 
fi

exit $EXIT

