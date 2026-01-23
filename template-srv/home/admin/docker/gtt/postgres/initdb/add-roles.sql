-- Restore postgres superuser rights !
CREATE USER postgres;
DROP DATABASE IF EXISTS postgres;
CREATE DATABASE postgres;
ALTER DATABASE postgres OWNER TO postgres;
ALTER ROLE postgres SUPERUSER;

-- Add "root" role to avoid log error "FATAL:  role "root" does not exist" with "dbprod" as default Postgres user
CREATE USER root;
DROP DATABASE IF EXISTS "root";
CREATE DATABASE "root";
ALTER DATABASE "root" OWNER TO "root";
ALTER ROLE root SUPERUSER;

-- Add additional users if needed
