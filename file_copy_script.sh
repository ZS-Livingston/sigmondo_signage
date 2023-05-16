#!/usr/bin/env bash

printf "Please enter the signage drives listfile: "
read -r listfile

printf "Please enter the file to copy: "
read -r file

# For each Onedrive in the list: 
#
# check if SIGMONDO directory exists
# and record its parent directory into a variable,
# as it  changes based on Onedrive language locale.

while IFS=$'\t' read -r f1
do
	apps=$(rclone ls --include "*/SIGMONDO/**" "$f1:" | perl -ne 'if (/(\d+ )(\w+)((\/\w+)+)/) {print "$2\n"; exit;}')
	if [[ -n "$apps" ]]
	then
		printf "SIGMONDO exists on the target remote %s in %s directory.\n" "$f1" "$apps"
		rclone copy "$file" "$f1:$apps/SIGMONDO/Main Area Media/" \
		&& printf "File copied to %s:%s/SIGMONDO/Main Area Media/\n" "$f1" "$apps"
	fi

done <"$listfile"

