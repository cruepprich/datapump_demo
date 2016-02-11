------------------------------------------------------------------------------------
-- File name: print_dp_job_description.prc
-- Purpose:   To demonstrate printing the elements of the ku$_jobstatus type.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            The p_job_description argument value can be gotten from the
--            dbms_datapump.get_status procedure. See show_dp_job.sql.
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE print_dp_job_status(p_job_status ku$_jobstatus) IS
BEGIN

  dbms_output.put_line('Datapump Job Status');
  dbms_output.put_line('===================');
  dbms_output.put_line('job_name           : ' || p_job_status.job_name);
  dbms_output.put_line('operation          : ' || p_job_status.operation);
  dbms_output.put_line('job_mode           : ' || p_job_status.job_mode);
  dbms_output.put_line('bytes_processed    : ' || p_job_status.bytes_processed);
  dbms_output.put_line('total_bytes        : ' || p_job_status.total_bytes);
  dbms_output.put_line('percent_done       : ' || p_job_status.percent_done);
  dbms_output.put_line('degree             : ' || p_job_status.degree);
  dbms_output.put_line('error_count        : ' || p_job_status.error_count);
  dbms_output.put_line('state              : ' || p_job_status.state);
  dbms_output.put_line('phase              : ' || p_job_status.phase);
  dbms_output.put_line('restart_count      : ' || p_job_status.restart_count);
 -- dbms_output.put_line('worker_status_list : ' || p_job_status.worker_status_list);
--  dbms_output.put_line('files              : ' || p_job_status.files);
  dbms_output.put_line('===================');

END;
/
