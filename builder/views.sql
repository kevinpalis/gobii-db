/*
	GOBII FlatMeta Views

	This file will contain views that the GOBII applications (or middle tier) can use, 
	especially in cases when the physical structure is different from the logical structure of the schema.

	IMPORTANT: ALL Views SHOULD start with V_
*/

CREATE OR REPLACE VIEW v_all_projects_full_details AS
	select p.project_id, p.name, p.code, p.description, p.pi_contact as pi_contact_id,
		c.firstname as pi_first_name, c.lastname as pi_last_name, p.created_by, p.created_date, p.modified_by, p.modified_date, p.status
	from project p 
	join contact c on p.pi_contact = c.contact_id;

/*
	I don't think we need this as we can simply directly use the project table for this.
CREATE VIEW project_view AS
	select
		project_id,
		name,
		code,
		description,
		pi_contact
	from
		project
*/