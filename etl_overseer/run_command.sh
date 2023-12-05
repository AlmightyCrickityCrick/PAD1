#!/bin/bash


if [[ -z `psql -Atqc "\\list ranking_service_repo"` ]]; then
  echo "Database does not exist. Creating..."
  mix ecto.create
  mix ecto.migrate --repo UnoWarehouse.Repo
  echo "Database created."
fi

mix run --no-halt
