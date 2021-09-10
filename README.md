# bullseye-mongodump-s3

Debian slim + MongoDump + AWS CLI docker image for Kubernetes; rigged up to backup mongodb, a single database, or a single collection to an s3 bucket

[![docker pulls](https://img.shields.io/docker/pulls/recipedude/bullseye-aws-nfs-clients.svg?style=plastic)](https://cloud.docker.com/u/recipedude/repository/docker/recipedude/bullseye-mongodump-s3)

This docker image contains:

- Debian Bullseye Slim
- [MongoDB Community Edition](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Environment variables

### MongoDB and mongodump options

- ```MONGO_URI``` - specifies the resolvable [URI connection string](https://docs.mongodb.com/database-tools/mongodump/#std-option-mongodump.--uri) of the MongoDB deployment
- ```MONGODUMP_DB``` - specifies a [database to backup](https://docs.mongodb.com/database-tools/mongodump/#std-option-mongodump.--db). If you do not specify a database, [mongodump](https://docs.mongodb.com/database-tools/mongodump/#std-program-mongodump) copies all databases in this instance into the dump files.
- ```MONGODUMP_COLLECTION``` - Specifies a [collection to backup](https://docs.mongodb.com/database-tools/mongodump/#std-option-mongodump.--collection). If you do not specify a collection, this option copies all collections in the specified database or instance to the dump files.
- ```MONGO_READPREFERENCE``` - specifies the [read preference](https://docs.mongodb.com/database-tools/mongodump/#std-option-mongodump.--readPreference) for [mongodump](https://docs.mongodb.com/database-tools/mongodump/#std-program-mongodump). 
- ```MONGODUMP_GZIP``` - compresses the output [--gzip](https://docs.mongodb.com/database-tools/mongodump/#std-option-mongodump.--gzip)
- ```MONGODUMP_OPLOG``` - creates a file named [oplog.bson](https://docs.mongodb.com/database-tools/mongodump/#std-option-mongodump.--oplog) as part of the [mongodump](https://docs.mongodb.com/database-tools/mongodump/#std-program-mongodump) output. If `MONGODUMP_DB` is provided this option is ignored.
- ```MONGODUMP_OPTIONS``` - added to the [mongodump](https://docs.mongodb.com/database-tools/mongodump/#std-program-mongodump) command line allowing you to pass in arbitrary arguments according to your use-case
- ```MONGODUMP_ARCHIVE``` - output to an [archive file](https://docs.mongodb.com/database-tools/mongodump/#output-to-an-archive-file) see: [Archiving and compression in MongoDB tools](https://www.mongodb.com/blog/post/archiving-and-compression-in-mongodb-tools)
- ```MONGODUMP_ARCHIVE_FILENAME``` - overrides the filename of the archive

### AWS Credentials and S3 options

Pass in the following environment variables for AWS CLI credientals.

- ```AWS_ACCESS_KEY_ID``` – Specifies an AWS access key associated with an IAM user or role.
- ```AWS_SECRET_ACCESS_KEY``` – Specifies the secret key associated with the access key. This is essentially the "password" for the access key.
- ```AWS_DEFAULT_REGION``` – Specifies the [AWS Region](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-region) to send the request to.
- ```AWS_PROFILE```  - specifies a pre-configured AWS profile - see AWS CLI docs
- ```AWS_S3_BUCKET``` - Specifies the AWS S3 bucket
- ```AWS_S3_PATH``` - Optional path within the S3 bucket - must include `/` absolute path

For more options you can configure with environment variables refer to: [AWS Environment Variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)


## Examples

**Backup the all databases to S3 using AWS access keys**

```
docker run --name mongodump-s3 \
  -e "MONGO_URI=mongodb://user:pass@host:port"
  -e "AWS_ACCESS_KEY_ID=your_aws_access_key"
  -e "AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key"
  -e "AWS_DEFAULT_REGION=us-east-1"
  -e "AWS_S3_BUCKET=your_aws_bucket"
  recipedude/bullseye-mongodb-s3:latest 
```

**Backup all databases to S3 using AWS profile**

Options include:
- gzip compress the backup
- use a secondary replicaset node rather than the primary node
- use a preconfigured AWS profile for the passing of AWS credentials 
- point in time backup using --oplog

```
docker run --name mongodump-s3 --rm \
  -e "AWS_PROFILE=self" \
  -e "AWS_S3_BUCKET=rl.mongodb" \
  -e "MONGO_READPREFERENCE=secondary" \
  -e "MONGO_URI=mongodb://host1:27017,host2:27017,host3:27017" \
  -e "MONGODUMP_GZIP=true" \
  -e "MONGODUMP_OPLOG=true" \
  --mount type=bind,source=/Users/username/.aws,target=/root/.aws \
  recipedude/bullseye-mongodb-s3:latest 
```

Output will look as thus:

```
Running mongodump
Backup name: 2021-09-10_16-38-36_UTC.tar
Fri Sep 10 16:38:36 UTC 2021
2021-09-10T16:38:37.039+0000	writing admin.system.version to dump/admin/system.version.bson.gz
2021-09-10T16:38:37.043+0000	done dumping admin.system.version (1 document)
2021-09-10T16:38:37.046+0000	writing recipes.recipe_docs to dump/recipes/recipe_docs.bson.gz
2021-09-10T16:38:37.069+0000	writing recipes.ingredient_docs to dump/recipes/ingredient_docs.bson.gz
2021-09-10T16:38:37.069+0000	writing recipes.search_word_docs to dump/recipes/search_word_docs.bson.gz
2021-09-10T16:38:37.071+0000	writing recipes.recipe_stat_docs to dump/recipes/recipe_stat_docs.bson.gz
2021-09-10T16:38:38.000+0000	done dumping recipes.search_word_docs (36309 documents)
2021-09-10T16:38:39.902+0000	done dumping recipes.recipe_stat_docs (53206 documents)
2021-09-10T16:38:39.972+0000	[........................]      recipes.recipe_docs  1489/55955   (2.7%)
2021-09-10T16:38:39.972+0000	[#####...................]  recipes.ingredient_docs    896/3786  (23.7%)
2021-09-10T16:38:39.972+0000
2021-09-10T16:38:42.972+0000	[#.......................]      recipes.recipe_docs  4509/55955   (8.1%)
2021-09-10T16:38:42.972+0000	[##################......]  recipes.ingredient_docs   2985/3786  (78.8%)
2021-09-10T16:38:42.972+0000
2021-09-10T16:38:45.144+0000	[########################]  recipes.ingredient_docs  3786/3786  (100.0%)
2021-09-10T16:38:45.144+0000	done dumping recipes.ingredient_docs (3786 documents)
2021-09-10T16:38:45.972+0000	[###.....................]  recipes.recipe_docs  7199/55955  (12.9%)
2021-09-10T16:38:48.973+0000	[####....................]  recipes.recipe_docs  10339/55955  (18.5%)
2021-09-10T16:38:51.972+0000	[#####...................]  recipes.recipe_docs  13437/55955  (24.0%)
2021-09-10T16:38:54.972+0000	[######..................]  recipes.recipe_docs  16238/55955  (29.0%)
2021-09-10T16:38:57.973+0000	[########................]  recipes.recipe_docs  19234/55955  (34.4%)
2021-09-10T16:39:00.972+0000	[#########...............]  recipes.recipe_docs  22638/55955  (40.5%)
2021-09-10T16:39:03.972+0000	[##########..............]  recipes.recipe_docs  25480/55955  (45.5%)
2021-09-10T16:39:06.972+0000	[############............]  recipes.recipe_docs  28339/55955  (50.6%)
2021-09-10T16:39:09.950+0000	[#############...........]  recipes.recipe_docs  31556/55955  (56.4%)
2021-09-10T16:39:12.950+0000	[##############..........]  recipes.recipe_docs  34627/55955  (61.9%)
2021-09-10T16:39:15.950+0000	[################........]  recipes.recipe_docs  38003/55955  (67.9%)
2021-09-10T16:39:18.950+0000	[#################.......]  recipes.recipe_docs  41007/55955  (73.3%)
2021-09-10T16:39:21.950+0000	[##################......]  recipes.recipe_docs  44280/55955  (79.1%)
2021-09-10T16:39:24.950+0000	[####################....]  recipes.recipe_docs  47319/55955  (84.6%)
2021-09-10T16:39:27.950+0000	[#####################...]  recipes.recipe_docs  50490/55955  (90.2%)
2021-09-10T16:39:30.950+0000	[######################..]  recipes.recipe_docs  52910/55955  (94.6%)
2021-09-10T16:39:33.451+0000	[########################]  recipes.recipe_docs  55955/55955  (100.0%)
2021-09-10T16:39:33.451+0000	done dumping recipes.recipe_docs (55955 documents)
2021-09-10T16:39:33.453+0000	writing captured oplog to
2021-09-10T16:39:33.455+0000		dumped 22 oplog entries
Fri Sep 10 16:39:33 UTC 2021
tar -cvzf "2021-09-10_16-38-36_UTC.tar" dump
dump/
dump/recipes/
dump/recipes/ingredient_docs.metadata.json.gz
dump/recipes/ingredient_docs.bson.gz
dump/recipes/recipe_stat_docs.metadata.json.gz
dump/recipes/recipe_docs.bson.gz
dump/recipes/search_word_docs.bson.gz
dump/recipes/recipe_docs.metadata.json.gz
dump/recipes/search_word_docs.metadata.json.gz
dump/recipes/recipe_stat_docs.bson.gz
dump/admin/
dump/admin/system.version.metadata.json.gz
dump/admin/system.version.bson.gz
dump/oplog.bson
Fri Sep 10 16:39:43 UTC 2021
S3 object: s3://rl.mongodb/2021-09-10_16-38-36_UTC.tar
Running: aws s3 cp "2021-09-10_16-38-36_UTC.tar" "s3://rl.mongodb/2021-09-10_16-38-36_UTC.tar"
upload: ./2021-09-10_16-38-36_UTC.tar to s3://rl.mongodb/2021-09-10_16-38-36_UTC.tar
finished
Fri Sep 10 16:39:53 UTC 2021
```

**Backup all databases to S3 using AWS profile**

Options include:
- gzip compress the backup
- use a secondary replicaset node rather than the primary node
- use a preconfigured AWS profile for the passing of AWS credentials 
- point in time backup using --oplog

```
docker run --name mongodump-s3 --rm \
  -e "AWS_PROFILE=self" \
  -e "AWS_S3_BUCKET=rl.mongodb" \
  -e "MONGO_READPREFERENCE=secondary" \
  -e "MONGO_URI=mongodb://host1:27017,host2:27017,host3:27017" \
  -e "MONGODUMP_GZIP=true" \
  -e "MONGODUMP_OPLOG=true" \
  -e "MONGODUMP_ARCHIVE=true"
  --mount type=bind,source=/Users/username/.aws,target=/root/.aws \
  recipedude/bullseye-mongodb-s3:latest 
```

Output will look as thus:

```

```









