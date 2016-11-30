#!/bin/sh
#
# Exports a database to a file and uploads it to Google Drive.

# Bail out if there are any errors.
set -e

dir=$(dirname `readlink -f $0`)

# Ensure the gdrive utility is installed
command -v gdrive >/dev/null 2>&1 || { echo >&2 "gdrive (https://github.com/prasmussen/gdrive) command line utility is required but not installed. Aborting."; exit 1; }

if [ "$1" = 'config' ]; then
	overwrite="y"
	if [ -f "$dir/db-dump.conf"  ]; then
		read -p "Config file already exists, overwrite? (Y/n): " overwrite
		if [ "$overwrite" != "n" ]; then
			overwrite="y"
		fi
	fi

	if [ "$overwrite" = "y" ]; then
		echo "Generating config file..."
		read -p "Enter Database Name: " userdbname
		read -p "Enter Google Drive Folder ID: " usergdrivefolderid

		cp "$dir/db-dump.conf.dist" "$dir/db-dump.conf"
		sed -i "s/dbname=\"\"/dbname=\"$userdbname\"/" "$dir/db-dump.conf"
		sed -i "s/gdrivefolderid=\"\"/gdrivefolderid=\"$usergdrivefolderid\"/" "$dir/db-dump.conf"

		echo "Config file generated."
	else
		echo "Aborting."
	fi

	exit
fi

# Ensure we have a conf file
if ! [ -f "$dir/db-dump.conf"  ]; then
	echo >&2 "Config file does not exist, run '$0 config' to generate it. Aborting."
	exit 1
fi

# Load config file
. "$dir/db-dump.conf"

# Allow config overrides per user
if [ -f "$HOME/.config/db-dump.conf" ]; then
	. "$HOME/.config/db-dump.conf"
fi

# Make sure $dbname and $gdrivefolderid aren't empty
if [ -z "$dbname" ]; then
	echo >&2 "dbname variable not set. Aborting."
	exit 1
fi

if [ -z "$gdrivefolderid" ]; then
	echo >&2 "gdrivefolderid variable not set. Aborting."
	exit 1
fi

# Make sure the local directory exists
mkdir -p "$dumpdir"

# Delete local export files older than two weeks
find "$dumpdir" -type f -name "*.sql.gz" -mtime +"$retentiondays" -print -exec rm "{}" \;

# Zip up any existing export files
find "$dumpdir" -type f -name "*.sql" -print -exec gzip "{}" \;

# Dump the live database to a file
file="$dbname-$(date +$dateformat).sql"
path="$dumpdir/$file"

mysqldump $mysqlopts "$dbname" > "$path"

# Upload the newly created file to Google Drive
gdrive upload --parent "$gdrivefolderid" "$path"
