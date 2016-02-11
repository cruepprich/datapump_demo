------------------------------------------------------------------------------------
-- File name: get_dp_job_state.prc
-- Purpose:   To demonstrate printing the datapump job state to the terminal.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            The argument p_job_name is case sensitive.
------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_dp_job_state(p_job_name IN VARCHAR2) 
RETURN VARCHAR2
IS
  l_state  VARCHAR2(30);
  l_handle NUMBER;
BEGIN
  l_handle := dbms_datapump.attach(p_job_name);


  dbms_output.put_line( sys.dbms_datapump.get_status(handle  => l_handle,
                                           mask    => 4,
                                           timeout => NULL).job_status.state);

  dbms_datapump.detach(handle => l_handle);
  
  RETURN l_state;
END get_dp_job_state;
/
