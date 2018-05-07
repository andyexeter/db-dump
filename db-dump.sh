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
		read -p "Enter Database Name: " userdb_name
		read -p "Enter Google Drive Folder ID: " usergdrive_folder_id

		cp "$dir/db-dump.conf.dist" "$dir/db-dump.conf"
		sed -i "s/db_name=\"\"/db_name=\"$userdb_name\"/" "$dir/db-dump.conf"
		sed -i "s/gdrive_folder_id=\"\"/gdrive_folder_id=\"$usergdrive_folder_id\"/" "$dir/db-dump.conf"

		echo "Config file generated."
	else
		echo "Aborting."
	fi

	exit
fi

# Ensure we have a conf file
if ! [ -f "$dir/db-dump.conf" ]; then
	echo >&2 "Config file does not exist, run '$0 config' to generate it. Aborting."
	exit 1
fi

# Load config file
. "$dir/db-dump.conf"

# Allow config overrides per user
if [ -f "$HOME/.config/db-dump.conf" ]; then
	. "$HOME/.config/db-dump.conf"
fi

# If an argument is passed and it's a file source it as a config file
if [ "$1" != "" ] && [ -f "$1" ]; then
    . "$1"
    echo "Using '$1' as config file"
fi

# Make sure $db_name and $gdrive_folder_id aren't empty
if [ -z "$db_name" ]; then
	echo >&2 "db_name variable not set. Aborting."
	exit 1
fi

if [ -z "$gdrive_folder_id" ]; then
	echo >&2 "gdrive_folder_id variable not set. Aborting."
	exit 1
fi

# Make sure the local directory exists
mkdir -p "$dump_dir"

# Delete exports older than $retention_days
find "$dump_dir" -type f -name "*.sql.gz" -mtime +"$retention_days" -exec rm -f "{}" \;

# Zip up any existing export files
find "$dump_dir" -type f -name "*.sql" -exec gzip "{}" \;

# Dump the live database to a file
file="$db_name-$(date +$date_format).sql"

mysqldump $mysql_opts "$db_name" > "$dump_dir/$file"

# Sync local directory with our Drive directory
gdrive sync upload --delete-extraneous --no-progress "$dump_dir" "$gdrive_folder_id" >/dev/null 2>&1
