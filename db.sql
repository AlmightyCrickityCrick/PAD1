CREATE USER repl_user REPLICATION LOGIN ENCRYPTED PASSWORD 'repl_user';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO repl_user;
ALTER USER repl_user WITH SUPERUSER;
select pg_create_physical_replication_slot('replication_slot');
