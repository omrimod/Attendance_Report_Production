#!/bin/bash

mkdir /home/mongodb/secrets -p
#chown -R 999:1000 /home/mongodb/secrets

MONGO_ROOT_USERNAME=process.env.MONGO_INITDB_ROOT_USERNAME
MONGO_ROOT_PASSWORD=process.env.MONGO_INITDB_ROOT_PASSWORD

# Genreate passwords for users
ROOT_PASSWORD=$(openssl rand -base64 12)
echo "Generated root password: $ROOT_PASSWORD"
FRONT_USER=front_user
MANAGEMENT_USER=management_user
WORKER_USER=worker_user
FRONT_PASSWORD=$(openssl rand -base64 12)
MANAGEMENT_PASSWORD=$(openssl rand -base64 12)
WORKER_PASSWORD=$(openssl rand -base64 12)
AGENDA_WORKER_PASSWORD=$(openssl rand -base64 12)
json="{\"front\":{\"name\":\"$FRONT_USER\",\"pass\":\"$FRONT_PASSWORD\"},\"management\":{\"name\":\"$MANAGEMENT_USER\",\"pass\":\"$MANAGEMENT_PASSWORD\"},\"worker\":{\"name\":\"$WORKER_USER\",\"pass\":\"$WORKER_PASSWORD\" ,\"agenda_pass\":\"$AGENDA_WORKER_PASSWORD\"}}"
echo $json > '/home/mongodb/secrets/sec.json'
hash=$(echo -n '1234' | sha256sum | awk '{print $1}')
sleep 10
# Run mongosh shell commands, authenticating directly

mongosh -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase "admin" <<EOF
// Now we are authenticated and can create the new database and user
use Users
db.createRole(
  {
    role: "readAttendance",
    privileges: [
      { resource: { db: "Users", collection: "attendances" }, actions: [ "find" ] }
    ],
    roles: []
  }
)

db.createRole(
  {
    role: "readWriteAttendance",
    privileges: [
      { resource: { db: "Users", collection: "attendances" }, actions: [ "insert", "update", "remove", "find" ] }
    ],
    roles: []
  }
)

db.createRole(
  {
    role: "readUsers",
    privileges: [
      { resource: { db: "Users", collection: "users" }, actions: [ "find" ] }
    ],
    roles: []
  }
)

db.createRole(
  {
    role: "readWriteUsers",
    privileges: [
      { resource: { db: "Users", collection: "users" }, actions: [ "insert", "update", "remove", "find" ] }
    ],
    roles: []
  }
)

db.createRole(
  {
    role: "readWriteAdmins",
    privileges: [
      { resource: { db: "Users", collection: "admins" }, actions: [ "insert", "update", "remove", "find" ] }
    ],
    roles: []
  }
)

db.createRole(
  {
    role: "readWiteSessions",
    privileges: [
      { resource: { db: "Users", collection: "sessions" }, actions: [ "insert", "update", "remove", "find", "createIndex" ] }
    ],
    roles: []
  }
)

db.createUser(
  {
    user: "$FRONT_USER",
    pwd:  "$FRONT_PASSWORD",
    roles: [ { role: "readUsers", db: "Users" }, { role: "readWriteAttendance", db: "Users" }, { role: "readWiteSessions", db: "Users" } ]
  }
)

db.createUser(
  {
    user: "$MANAGEMENT_USER",
    pwd:  "$MANAGEMENT_PASSWORD",
    roles: [ { role: "readWriteUsers", db: "Users" }, {role: "readWriteAdmins", db: "Users"} ]
  }
)

db.createUser(
  {
    user: "$WORKER_USER",
    pwd:  "$WORKER_PASSWORD",
    roles: [ { role: "readUsers", db: "Users" }, { role: "readWriteAttendance", db: "Users" } ]
  }
)

db.admins.insertOne({admin: "admin", passwordHash: "$hash", resetPassword: true})

use Agenda
db.createUser(
  {
    user: "$WORKER_USER",
    pwd:  "$AGENDA_WORKER_PASSWORD",
    roles: [ { role: "readWrite", db: "Agenda" } ]
  }
)
use admin
db.changeUserPassword("$MONGO_INITDB_ROOT_USERNAME", "$ROOT_PASSWORD")

EOF
