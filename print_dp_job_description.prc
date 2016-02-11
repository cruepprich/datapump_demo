------------------------------------------------------------------------------------
-- File name: print_dp_job_description.prc
-- Purpose:   To demonstrate printing the elements of the ku$_jobdesc type.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            The p_job_description argument value can be gotten from the
--            dbms_datapump.get_status procedure. See show_dp_job.sql
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE print_dp_job_description(p_job_description ku$_jobdesc) IS
BEGIN
  dbms_output.put_line('Datapump Job Description');
  dbms_output.put_line('========================');
  dbms_output.put_line('job_name      : ' || p_job_description.job_name);
  dbms_output.put_line('operation     : ' || p_job_description.operation);
  dbms_output.put_line('job_mode      : ' || p_job_description.job_mode);
  dbms_output.put_line('remote_link   : ' || p_job_description.remote_link);
  dbms_output.put_line('owner         : ' || p_job_description.owner);
  dbms_output.put_line('instance      : ' || p_job_description.instance);
  dbms_output.put_line('db_version    : ' || p_job_description.db_version);
  dbms_output.put_line('creator_privs : ' || p_job_description.creator_privs);
  dbms_output.put_line('start_time    : ' || to_char(p_job_description.start_time ,'yyyymmdd hh24:mi:ss'));
  dbms_output.put_line('log_file      : ' || p_job_description.log_file);
  dbms_output.put_line('sql_file      : ' || p_job_description.sql_file);

  dbms_output.put_line('========================');
END;
/
