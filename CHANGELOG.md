# Changelog

## v2.0

Now uses the `sync` command to sync the local dump directory to Drive directory instead of just
uploading newly created dumps. This has been done primarily so that old dumps are gzipped on Drive

You may need to create a new remote backup directory because of a bug in gdrive (https://github.com/prasmussen/gdrive/issues/166)
