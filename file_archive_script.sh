#!/usr/bin/env bash

printf "Please enter the signage drives listfile: "
read -r listfile

printf "Please enter the file to move: "
read -r file

# For each Onedrive in the list: 
#
# check if SIGMONDO directory exists
# and record its parent directory into a variable,
# as it changes based on Onedrive language locale.

while IFS=$'\t' read -r f1
do
	apps=$(rclone ls --include "*/SIGMONDO/**" "$f1:" | perl -ne 'if (/(\d+ )(\w+)((\/\w+)+)/) {print "$2\n"; exit;}')
	if [[ -n "$apps" ]]
	then
		printf "SIGMONDO exists on the target remote %s in %s directory.\n" "$f1" "$apps"
		
		# Check if "Signage Archive" directory exists
		archive=$(rclone ls --include "*/Signage Archive/**" "$f1:" | perl -ne 'if (/(\d+ )(\w+)((\/\w+)+)/) {print "$2\n"; exit;}')
		if [[ -z "$archive" ]]
		then
			# If "Signage Archive" directory doesn't exist, create it
			rclone mkdir "$f1:$apps/Signage Archive"
			printf "Created Signage Archive directory on %s:%s/Signage Archive/\n" "$f1" "$apps"
		fi
		
		# Move the file
		rclone moveto "$f1:$apps/SIGMONDO/Main Area Media/$file" "$f1:$apps/Signage Archive/$file" \
		&& printf "File moved to %s:%s/Signage Archive/\n" "$f1" "$apps"
	fi

done <"$listfile"
