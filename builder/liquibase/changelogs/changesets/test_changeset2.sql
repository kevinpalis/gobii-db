--liquibase formatted sql
--changeset venice.juanillas:test2_createTable _test1db context:dev splitStatements:false

--create table table1(
--	id int primary key,
--	name varchar(255)
--);

--changeset: venice.juanillas: test2_insert2Table_test1db context:dev splitStatements:false
insert into table values (1,'name1');
insert into table values (2,'name2');



