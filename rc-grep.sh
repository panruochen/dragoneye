#!/bin/bash
#========================================================
#
#  A helper script to combining find+xargs for searching
#
#========================================================
#set -e -o pipefail

usage_and_exit()
{
	echo "Usage: $(basename $0) [-e PATTERN1] [-e PATTERN2] [-l] [-i] FILES1 FILES2..." >&2
	exit $1
}

has_patterns=
grep_options=()
find_options=()
while getopts ":e:li" o ;
do
    case "${o}" in
    e)
			grep_options+=("-e" "${OPTARG}")
			has_patterns=y
        ;;
    l)
			grep_options+=("-l")
        ;;
    i)
			grep_options+=("-i")
        ;;
    *)
		usage_and_exit 0
        ;;
    esac
done
shift $((OPTIND-1))
##echo "$@" ; exit


for a in "$@"
do
	if [ -n "$find_options" ]; then
		find_options+=("-o")
	fi
	find_options+=("-name" "$a")
done

if [ ${#find_options[@]} -eq 0 -o -z "$has_patterns" ]; then
	usage_and_exit 0
fi

set +e
find \( -type f -a \( "${find_options[@]}" \) \) -print0| xargs -0 grep "${grep_options[@]}"


