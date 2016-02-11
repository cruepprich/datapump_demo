DECLARE
  l_dp_handle NUMBER;
BEGIN
  l_dp_handle := dbms_datapump.attach('dp_schema');
  dbms_output.put_line(dbms_datapump.get_status(l_dp_handle,4, 0).job_status.state);
  dbms_datapump.detach(l_dp_handle);
END;
