------------------------------------------------------------------------------------
-- File name: monitor_dp.prc
-- Purpose:   This procedure demonstrates monitoring a datapump job.
--            It and prints the output to the console.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            A call to this procedure should be put into the procedure that
--            starts the datapump job with dbms_datapump.start().
--            The procedure will return the number of errors encountered in
--            p_errors.
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE monitor_dp(p_dp_handle IN NUMBER
                                      ,p_errors    OUT NUMBER) IS
  l_pct_done   NUMBER;
  l_job_status ku$_jobstatus;
  l_status     ku$_status;
  l_log_entry  ku$_logentry; -- For WIP and error messages
  idx          NUMBER;
  l_errors     PLS_INTEGER := 0;
  l_job_state  VARCHAR2(30) := 'UNDEFINED';
  l_job_desc   ku$_jobdesc;
  l_job_oper   VARCHAR2(30);
BEGIN
  dbms_application_info.set_module('DP','START');
  dbms_datapump.get_status(p_dp_handle,
                           dbms_datapump.ku$_status_job_desc,
                           -1,
                           l_job_state,
                           l_status);

  l_job_oper := l_status.job_description.operation; --import or export

  l_pct_done  := 0;
  l_job_state := 'UNDEFINED';
  WHILE (l_job_state != 'COMPLETED') AND (l_job_state != 'STOPPED')
  
   LOOP
    dbms_datapump.get_status(p_dp_handle,
                             dbms_datapump.ku$_status_job_error +
                             dbms_datapump.ku$_status_job_status +
                             dbms_datapump.ku$_status_wip,
                             -1,
                             l_job_state,
                             l_status);
    l_job_status := l_status.job_status;
    l_job_desc   := l_status.job_description;
  
    -- If the percentage done changed, display the new value.
    IF l_job_status.percent_done != l_pct_done
    THEN
 
      dbms_application_info.set_action(l_job_oper || ' % <' ||
                                       to_char(l_job_status.percent_done) ||
                                       '>, Errors <' || l_errors || '>');
      dbms_output.put_line(l_job_oper || ' % <' ||
                                       to_char(l_job_status.percent_done) ||
                                       '>, Errors <' || l_errors || '>');                                       
 
      l_pct_done := l_job_status.percent_done;
 
   END IF;
  
    -- If any work-in-progress (WIP) or error messages were received for the job,
    -- display them.
    IF (bitand(l_status.mask, dbms_datapump.ku$_status_wip) != 0)
    THEN
      l_log_entry := l_status.wip;
    ELSE
      IF (bitand(l_status.mask, dbms_datapump.ku$_status_job_error) != 0)
      THEN
        l_log_entry := l_status.error;
      ELSE
        l_log_entry := NULL;
      END IF;
    END IF;
    IF l_log_entry IS NOT NULL
    THEN
      idx := l_log_entry.first;
    
      WHILE idx IS NOT NULL LOOP
        --grep for oracle errors
        IF regexp_instr(upper(l_log_entry(idx).logtext),
                        'ORA-[[:digit:]]{5}') > 0
        THEN
          l_errors := l_errors + 1;
        END IF;
        dbms_output.put_line('DP Mon: ' || l_log_entry(idx).logtext);
        idx := l_log_entry.next(idx);
      END LOOP;
    
    END IF;
  
  END LOOP;

  p_errors := l_errors;

  dbms_application_info.set_module('DP','END');
END;
/
