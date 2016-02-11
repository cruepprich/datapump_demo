------------------------------------------------------------------------------------
-- File name: show_dp_job_state.sql
-- Purpose:   Display the state of a given datapump job.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
-- Notes:     The substitution variable dp_job_name is case sensitive.
------------------------------------------------------------------------------------
DECLARE
  l_dp_handle NUMBER;
BEGIN
  l_dp_handle := dbms_datapump.attach('&dp_job_name');
  dbms_output.put_line(dbms_datapump.get_status(l_dp_handle,4, 0).job_status.state);
  dbms_datapump.detach(l_dp_handle);
END;
/
