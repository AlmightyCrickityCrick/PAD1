#!/bin/bash


if [[ -z `psql -Atqc "\\list ranking_service_repo"` ]]; then
  echo "Database does not exist. Creating..."
  mix ecto.create
  mix ecto.migrate
  echo "Database created."
fi

mix run --no-halt
