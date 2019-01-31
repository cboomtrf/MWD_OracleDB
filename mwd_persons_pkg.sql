/*
 * MWD_PERSONS_PKG is a proof of concept package for TAPI DML operations on Persons. 
 * This creates a single point of reference in which can be made sure business rules are implemented. 
 * Many TAPI scripts exist - MWD chose for personal research to make one from scratch.
 * Run this code to create the package. 
 * The process call would be inside a page package:
 * => BEGIN MWD_PERSONS_PKG.update_person(P_PERSON => V_PERSON, P_NATURAL_PERSON => V_NATURAL);
 */

create or replace package MWD_PERSONS_PKG as

    function get_persons_lov_query
		return varchar2;
		
	function get_person_id_by_ak(
		p_email in persons.email%type,
		p_person_type in persons.person_type%type
	) return persons.person_id%type;	

    procedure insert_person(
        p_person in persons%rowtype,
		p_natural_person in natural_persons%rowtype default null,
		p_legal_person in legal_persons%rowtype default null,
		p_person_id out persons.person_id%type
    );
	
    procedure update_person(
	    p_person in persons%rowtype,
		p_natural_person in natural_persons%rowtype default null,
		p_legal_person in legal_persons%rowtype default null
	);
	
	procedure delete_person(
		p_person_id in persons.person_id%type
	);
        
end MWD_PERSONS_PKG;

/ 

create or replace package body MWD_PERSONS_PKG as

	-- private declarations
	procedure insert_legal_person(
		p_legal in legal_persons%rowtype
	);
	
	procedure insert_natural_person(
		p_natural in natural_persons%rowtype
	);
    
	procedure update_natural_person(
		p_natural in natural_persons%rowtype
	);
	
	procedure update_legal_person(
		p_legal in legal_persons%rowtype
	);

	-- body content
    function get_persons_lov_query
		return varchar2
    is
        v_query varchar2(5000);
    begin
		v_query := 'SELECT
						(CASE WHEN p.person_type = ''LEGAL_PERSON''
                            THEN l.legal_name
                        ELSE
							CASE WHEN n.first_name IS NULL THEN '''' ELSE n.first_name || '' '' END ||
							n.last_name END) as display,            
						p.person_id as return
						from PERSONS p
                        LEFT JOIN LEGAL_PERSONS l
                            ON p.person_id = l.person_id
                        LEFT JOIN NATURAL_PERSONS n
                            ON p.person_id = n.person_id
                        order by 1';
		return v_query;
    end get_persons_lov_query;
	
	function get_person_id_by_ak(
		p_email in persons.email%type,
		p_person_type in persons.person_type%type
	) return persons.person_id%type
	is
		v_person_id persons.person_id%type;
	begin
		select person_id
			into v_person_id
			from persons
			where email = p_email
			and person_type = p_person_type;

		return v_person_id;
	end get_person_id_by_ak;
	
	procedure insert_legal_person(
		p_legal in legal_persons%rowtype
	) AS
	begin
		insert into MWD.LEGAL_PERSONS values p_legal;
	end insert_legal_person;
	
	procedure insert_natural_person(
		p_natural in natural_persons%rowtype
	) AS
	begin
		insert into MWD.NATURAL_PERSONS values p_natural;
	end insert_natural_person;

    procedure insert_person(
        p_person in persons%rowtype,
		p_natural_person in natural_persons%rowtype default null,
		p_legal_person in legal_persons%rowtype default null,
		p_person_id out persons.person_id%type
    ) AS
	begin
		insert into MWD.PERSONS values p_person;
		
		insert_legal_person(p_legal => p_legal_person);

		insert_natural_person(p_natural => p_natural_person);

	end insert_person;
	
	procedure update_natural_person(
		p_natural in natural_persons%rowtype
	) AS
	begin
		update MWD.NATURAL_PERSONS 
			set
				  first_name = p_natural.first_name
				, last_name = p_natural.last_name
			where person_id = p_natural.person_id;
	end update_natural_person;
	
	procedure update_legal_person(
		p_legal in legal_persons%rowtype
	) AS
	begin
		update MWD.LEGAL_PERSONS 
			set
				  legal_name = p_legal.legal_name
				, website = p_legal.website
			where person_id = p_legal.person_id;
	end update_legal_person;
	
	procedure update_person(
	    p_person in persons%rowtype,
		p_natural_person in natural_persons%rowtype default null,
		p_legal_person in legal_persons%rowtype default null
    ) AS
	begin
		update MWD.PERSONS 
			set
				  email = p_person.email
				, phone_fixed = p_person.phone_fixed
				, is_competitor = p_person.is_competitor
				, person_type = p_person.person_type
			where person_id = p_person.person_id;
		
		update_legal_person(p_legal => p_legal_person);

		update_natural_person(p_natural => p_natural_person);
	end update_person;
	
	procedure delete_person(
		p_person_id in persons.person_id%type
    ) AS
	begin
		delete from MWD.NATURAL_PERSONS
			where person_id = p_person_id;
			
		delete from MWD.LEGAL_PERSONS
			where person_id = p_person_id;
		
		delete from MWD.PERSONS 
			where person_id = p_person_id;
	end delete_person;

end MWD_PERSONS_PKG;