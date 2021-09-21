cd ../sql-server
docker image rm mssql-2017-fts:latest
docker build -t mssql-2017-fts:latest .