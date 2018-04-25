--liquibase formatted sql

--changeset kpalis:add_tadm_superadmin context:seed_general splitStatements:false
select * from createTimescoper('Timescope', 'Root', 'tadm', 't1m3sc0p3admin', 'tadm.gobii@gmail.com', 1);

--to authenticate
--SELECT * FROM timescoper WHERE username = 'tadm' AND password = crypt('t1m3sc0p3admin', password);