------------------------------------------------------------------------------------
-- File name: get_dp_job_state.sql
-- Purpose:   Demonstrates use of a basic function to return job state.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     The parameter p_job_name is case sensitive.
------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION show_dp_job_state(p_job_name VARCHAR2)
  RETURN VARCHAR2
  IS
  l_dp_handle NUMBER;
  l_state     VARCHAR2(30);
BEGIN
  l_dp_handle := dbms_datapump.attach(p_job_name);
  l_state := dbms_datapump.get_status(l_dp_handle,4, 0).job_status.state;
  dbms_datapump.detach(l_dp_handle);
  RETURN l_state;
END;
