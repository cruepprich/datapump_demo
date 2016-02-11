------------------------------------------------------------------------------------
-- File name: show_dp_job.prc
-- Purpose:   To demonstrate the dbms_datapump.get_status procedure.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            To print the job description and status, the procedures
--            print_dp_job_description, and print_dp_job_status have to
--            be compiled.
--            The p_job_name argument is case sensitive.
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE show_dp_job(p_job_name IN VARCHAR2) IS
  l_pct_done        NUMBER;
  l_job_status      ku$_jobstatus;
  l_status          ku$_status;
  l_log_entry       ku$_logentry; -- For WIP and error messages
  idx               NUMBER;
  l_errors          PLS_INTEGER := 0;
  l_job_state       VARCHAR2(30) := 'UNDEFINED';
  l_job_desc        ku$_jobdesc;
  l_job_oper        VARCHAR2(30);
  l_job_description ku$_jobdesc;
  l_dp_handle       PLS_INTEGER;
BEGIN

  l_dp_handle := dbms_datapump.attach(job_name => p_job_name, job_owner => USER);

  dbms_datapump.get_status(l_dp_handle,
                           dbms_datapump.ku$_status_job_error +
                           dbms_datapump.ku$_status_job_status +
                           dbms_datapump.ku$_status_wip +
                           dbms_datapump.ku$_status_job_desc,
                           -1,
                           l_job_state,
                           l_status);

  l_job_description := l_status.job_description;
  l_job_oper        := l_status.job_description.operation; --import or export

  print_dp_job_description(l_status.job_description);
  print_dp_job_status(l_status.job_status);

  dbms_datapump.detach(l_dp_handle);
END show_dp_job;
/
