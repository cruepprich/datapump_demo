------------------------------------------------------------------------------------
-- File name: exp_two_tables_reusefile.prc
-- Purpose:   To demonstrate the export of two tables from a given schema.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            The procedure will export the EMP and DEPT tables from
--            the SCOTT schema.
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE exp_two_tables_reusefile IS
  l_dp_handle PLS_INTEGER; --datapump job handle
  l_job_name  VARCHAR2(30); --name for datapump job
  l_dumpfile  VARCHAR2(30); --name of dump file
  l_logfile   VARCHAR2(30); --name of log file
  l_dpdir     VARCHAR2(30); --name of datapump directory object
  e_start_job1 EXCEPTION;
  e_start_job2 EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_start_job1, -31626); --failed datapump events can leave master table behind
  PRAGMA EXCEPTION_INIT(e_start_job2, -31634); --failed datapump events can leave session behind  
BEGIN
  l_job_name := 'exp_two_tables_reusefile';
  l_dumpfile := l_job_name || '.dmp';
  l_logfile  := l_job_name || '.log';
  l_dpdir    := 'DATA_PUMP_DIR';

  BEGIN -- open job
    l_dp_handle := dbms_datapump.open(operation => 'EXPORT',
                                      job_mode  => 'TABLE', --> needed for skipping tables
                                      job_name  => 'dp_schema',
                                      version   => '10.0.0');
  EXCEPTION
    WHEN e_start_job1 THEN
      
      DECLARE
        l_table_name VARCHAR2(30);
      BEGIN
        SELECT nvl(MAX(table_name), 'x')
          INTO l_table_name
          FROM user_tables
         WHERE table_name = l_job_name;
        IF l_table_name != 'x'
        THEN
          dbms_output.put_line('Datapump Master Table ' || l_job_name ||
                               ' exists.');
        END IF;
      END;
      
      RAISE;
      
    WHEN e_start_job2 THEN
      dbms_output.put_line( 'Check for existing data pump session.');
      RAISE;
    WHEN OTHERS THEN
      raise_application_error(-20000,
                              'Error when opening job: ' || SQLERRM);
  END;

  BEGIN -- add dump file
    dbms_datapump.add_file(handle    => l_dp_handle,
                           filename  => l_dumpfile,
                           directory => l_dpdir,
                           filesize  => '1G',
                           reusefile => 1);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_datapump.detach(handle => l_dp_handle);                           
      raise_application_error(-20010,
                              'Error when adding dump file: ' || SQLERRM);   
  END;

  BEGIN -- add log file
    dbms_datapump.add_file(handle    => l_dp_handle,
                           filename  => l_logfile,
                           directory => l_dpdir,
                           filetype  => dbms_datapump.ku$_file_type_log_file);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20020,
                              'Error when adding log file: ' || SQLERRM);
  END;

  BEGIN -- specify schema
    dbms_datapump.metadata_filter(handle => l_dp_handle,
                                  NAME   => 'SCHEMA_LIST',
                                  VALUE  => 'SCOTT');
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20030,
                              'Error when adding metadata filter: ' ||
                              SQLERRM);
  END;

  BEGIN -- specify tables
    dbms_datapump.metadata_filter(handle => l_dp_handle,
                                  --NAME   => 'NAME_EXPR',
                                  --VALUE  => 'IN (''EMP'',''DEPT'')'
                                  NAME   => 'NAME_LIST',
                                  VALUE  => 'EMP,DEPT'
				);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20032,
                              'Error when adding metadata filter: ' ||
                              SQLERRM);
  END;

  BEGIN -- start job
    dbms_datapump.start_job(handle => l_dp_handle);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20040,
                              'Error when starting job: ' || SQLERRM);
  END;

  BEGIN -- detach
    dbms_datapump.detach(handle => l_dp_handle);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20050, SQLERRM);
  END;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Main exception: ' || SQLERRM);
    raise;
END exp_two_tables_reusefile;
/
