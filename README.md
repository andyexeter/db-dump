# Google Drive MySQL Dumper

Small script which exports a MySQL database to a file and uploads it to Google Drive.

By default, the script works on a two week retention policy. That is, local backups are kept
for up to two weeks, any backup files the script finds in the backup directory will be gzipped before
the newest backup is exported.

## Requirements
Requires the [gdrive](https://github.com/prasmussen/gdrive) command line utility for Google Drive.

## Installation
1. Download the [gdrive](https://github.com/prasmussen/gdrive)  utility from its GitHub page and follow its installation guide.
2. Clone this repository
3. Make the `db-dump.sh` script executable, and link it somewhere it can be called from any directory e.g:

```sh
$ chmod +x /path/to/db-dump.sh
$ sudo ln -s /path/to/db-dump.sh /usr/local/bin/db-dump
```

4. Set up your `db-dump.conf` file, either manually by copying `db-dump.conf.dist`, or by typing `db-dump config` at the command line:
```bash
$ db-dump config
Generating config file...
Enter Database Name: mydatabase    
Enter Google Drive Folder ID: abc123def456
Config file generated.
```

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

## Automation
The easiest way to automatically run the script over a given interval is to link it into one of the
`/etc/cron.*` directories, e.g:

```sh
sudo ln -s /path/to/db-dump.sh /etc/cron.daily/db-dump
```

The above command will cause the script to be run once every 24 hours.

## Licence
The MIT License (MIT) Copyright (c) 2016

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
