# Google Drive MySQL Dumper

Small script which exports a MySQL database to a file and uploads it to Google Drive.

By default, the script works on a two week retention policy. That is, local backups are kept
for up to two weeks, any backup files the script finds in the backup directory will be gzipped before
the newest backup is exported.

## Requirements
Requires the [gdrive](https://github.com/prasmussen/gdrive) command line utility for Google Drive.

## Configuration

The following options are required to be set and do **not** have default values:

| Option | Description |
| ------ | ----------- |
| dbname | Name of the database to export |
| gdrivefolderid | Google Drive folder ID where files get uploaded |

The following options **do** have default values can be tweaked as desired

| Option | Description | Default |
| ------ | ----------- | ------- |
| dateformat | Date format for dates appended to export files | `%Y-%m-%d_%H:%M:%S` |
| dumpdir | The local directory where export files will be stored | `/var/spool/db-dump` |
| retentiondays | The number of days to retain local export files | `14` |

Options can be changed in the main `db-dump.conf` file or can be overridden on a per user basis by creating
a config file within your home directory: `$HOME/.config/db-dump.conf`
