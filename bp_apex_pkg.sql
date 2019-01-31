/*
 * BP_APEX_PKG is intended to be an APEX general utility package that expands
 * existing APEX functionality, creating one place where functionality may be
 * added when needed.
 * E.g. a wish surfaced to set session variables with autonomous transactions.
 * This wrapper is a variation of Alexandria's set_item.
 */

create or replace 
	package BP_APEX_PKG as

    procedure set_autotrans_sv(
		p_name in varchar2,
		p_value in varchar2 = NULL)
	);
        
end BP_APEX;
/ 

create or replace 
	package body BP_APEX as

	procedure set_autotrans_sv
		(p_name  in varchar2
		,p_value in varchar2 := NULL) 
	as
		PRAGMA AUTONOMOUS_TRANSACTION;
	begin
		APEX_UTIL.set_session_state
			(p_name => p_name
			,p_value => p_value);
		COMMIT;
	end set_autotrans_sv;
	
end BP_APEX;