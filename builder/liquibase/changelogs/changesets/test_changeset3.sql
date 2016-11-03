--liquibase formatted sql
--changeset: venice.juanillas: test2_insert2Table_test1db context:dev splitStatements:false

insert into table1 values (1,'name1');
insert into table1 values (2,'name2');



