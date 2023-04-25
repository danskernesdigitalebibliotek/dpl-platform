# Retrieving backups

## When to use

When you wish to download an automatic backup made by Lagoon, and optionally
restore it into an existing site.

## Prerequisites

* Administrative access to the site in the Lagoon UI
* (for restore) administrative cluster-access to the site

## Procedure

Step overview:

1. Download the backup
2. Upload the backup to relevant pods
3. Extract the backup.
4. Cache clearing
5. Cleanup

While most steps are different for file and database backups, step 1 is close to
identical for the two guides.

Be aware that the guide instructs you to copy the backups to `/tmp` inside the
cli pod. Depending on the resources available on the node `/tmp` may not have
enough space in which case you may need to modify the `cli` deployment to add
a temporary volume, or place the backup inside the existing `/site/default/files`
folder.

### Step 1, downloading the backup

 To download the backup access the Lagoon UI and schedule the retrieval of a
 backup. To do this,

 1. Log in to the environments Lagoon UI (consult the
 [environment documentation](../platform-environments.md) for the url)
 2. Access the sites project
 3. Access the sites environment ("Main" for production)
 4. Click on the "Backups" tab
 5. Click on the "Retrieve" button for the backups you wish to download and/or
    restore. Use to "Source" column to differentiate the types of backups.
    "nginx" are backups of the sites files, while "mariadb" are backups of the
    sites database.
 6. The Buttons changes to "Downloading..." when pressed, wait for them to
    change to "Download", then click them again to download the backup

### Step 2a, restore a database

To restore the database we must first copy the backup into a running cli-pod
for a site, and then import the database-dump on top of the running site.

1. Copy the uncompressed mariadb sql file you want to restore into the `dpl-platform/infrastructure`
   folder from which we will launch dplsh
2. Launch dplsh from the infrastructure folder ([instructions](using-dplsh.md))
   and follow the procedure below:

```sh
# 1. Authenticate against the cluster.
$ task cluster:auth

# 2. List the namespaces to identify the sites namespace
# The namespace will be on the form <sitename>-<branchname>
# eg "bib-rb-main" for the "main" branch for the "bib-rb" site.
$ kubectl get ns

# 3. Export the name of the namespace as SITE_NS
# eg.
$ export SITE_NS=bib-rb-main

# 4. Copy the *mariadb.sql file to the CLI pod in the sites namespace
# eg.
kubectl cp \
  -n $SITE_NS  \
  *mariadb.sql \
  $(kubectl -n $SITE_NS get pod -l app.kubernetes.io/instance=cli -o jsonpath="{.items[0].metadata.name}"):/tmp/database-backup.sql

# 5. Have drush inside the CLI-pod import the database and clear out the backup
kubectl exec \
  -n $SITE_NS \
  deployment/cli \
  -- \
    bash -c " \
         echo Verifying file \
      && test -s /tmp/database-backup.sql \
         || (echo database-backup.sql is missing or empty && exit 1) \
      && echo Dropping database \
      && drush sql-drop -y \
      && echo Importing backup \
      && drush sqlc < /tmp/database-backup.sql \
      && echo Clearing cache \
      && drush cr \
      && rm /tmp/database-backup.sql
    "
```

### Step 2b, restore a sites files

To restore backed up files into a site we must first copy the backup into a
running cli-pod for a site, and then rsync the files on top top of the running
site.

1. Copy tar.gz file into the `dpl-platform/infrastructure` folder from which we
   will launch dplsh
2. Launch dplsh from the infrastructure folder ([instructions](using-dplsh.md))
   and follow the procedure below:

```sh
# 1. Authenticate against the cluster.
$ task cluster:auth

# 2. List the namespaces to identify the sites namespace
# The namespace will be on the form <sitename>-<branchname>
# eg "bib-rb-main" for the "main" branch for the "bib-rb" site.
$ kubectl get ns

# 3. Export the name of the namespace as SITE_NS
# eg.
$ export SITE_NS=bib-rb-main

# 4. Copy the files tar-ball into the CLI pod in the sites namespace
# eg.
kubectl cp \
  -n $SITE_NS  \
  backup*-nginx-*.tar.gz \
  $(kubectl -n $SITE_NS get pod -l app.kubernetes.io/instance=cli -o jsonpath="{.items[0].metadata.name}"):/tmp/files-backup.tar.gz

# 5. Replace the current files with the backup.
# The following
# - Verifies the backup exists
# - Removes the existing sites/default/files
# - Un-tars the backup into its new location
# - Fixes permissions and clears the cache
# - Removes the backup archive
#
# These steps can also be performed one by one if you want to.
kubectl exec \
  -n $SITE_NS \
  deployment/cli \
  -- \
    bash -c " \
         echo Verifying file \
      && test -s /tmp/files-backup.tar.gz \
         || (echo files-backup.tar.gz is missing or empty && exit 1) \
      && tar ztf /tmp/files-backup.tar.gz data/nginx &> /dev/null \
         || (echo could not verify the tar.gz file files-backup.tar && exit 1) \
      && test -d /app/web/sites/default/files \
         || (echo Could not find destination /app/web/sites/default/files \
             && exit 1) \
      && echo Removing existing sites/default/files \
      && rm -fr /app/web/sites/default/files \
      && echo Unpacking backup \
      && mkdir -p /app/web/sites/default/files \
      && tar --strip 2 --gzip --extract --file /tmp/files-backup.tar.gz \
             --directory /app/web/sites/default/files data/nginx \
      && echo Fixing permissions \
      && chmod -R 777 /app/web/sites/default/files \
      && echo Clearing cache \
      && drush cr \
      && echo Deleting backup archive \
      && rm /tmp/files-backup.tar.gz
    "

#  NOTE: In some situations some files in /app/web/sites/default/files might
#  be locked by running processes. In that situations delete all the files you
#  can from /app/web/sites/default/files manually, and then repeat the step
#  above skipping the removal of /app/web/sites/default/files
```
