--liquibase formatted sql

--changeset raza:germplasm_par_type_cv context:seed_general splitStatements:false    

select * from createCVinGroup('germplasm_prop',1,'par1_type','Parent 1 type of the germplasm name',10,null,null,1);
select * from createCVinGroup('germplasm_prop',1,'par2_type','Parent 2 type of the germplasm name',11,null,null,1);
select * from createCVinGroup('germplasm_prop',1,'par3_type','Parent 3 type of the germplasm name',12,null,null,1);
select * from createCVinGroup('germplasm_prop',1,'par4_type','Parent 4 type of the germplasm name',13,null,null,1);
