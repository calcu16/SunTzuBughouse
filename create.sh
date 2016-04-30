#!/bin/sh
rm -f db/chess.db
sqlite3 db/chess.db <sql/create.sql
chmod 666 db/chess.db
