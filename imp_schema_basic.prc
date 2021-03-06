------------------------------------------------------------------------------------
-- File name: imp_schema_basic.prc
-- Purpose:   To demonstrate a full schema import.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            Be sure to edit the file name for variable l_file to reflect
--            the name of the dump file.
--            Also edit the l_from_schema, l_to_schema, l_from_ts and l_to_ts
--            as necessary.
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE imp_schema_basic IS
  l_dp_handle   PLS_INTEGER; --datapump job handle
  l_job_name    VARCHAR2(30); --name for datapump job
  l_dumpfile    VARCHAR2(30); --name of dumpfile to be imported
  l_logfile     VARCHAR2(30); --name of log file
  l_dpdir       VARCHAR2(30); --name of datapump directory object
  l_errors      PLS_INTEGER := 0; --number of errors logged during monitoring
  l_from_schema VARCHAR2(30); --schema from dump file
  l_to_schema   VARCHAR2(30); --destination schema
  l_from_ts     VARCHAR2(30); --tablespace from dump file
  l_to_ts       VARCHAR2(30); --destination tablespace
  l_db_link     VARCHAR2(30); --database link

  e_start_job1 EXCEPTION;
  e_start_job2 EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_start_job1, -31626); --failed datapump events can leave master table behind
  PRAGMA EXCEPTION_INIT(e_start_job2, -31634); --failed datapump events can leave session behind  
BEGIN
  l_job_name := 'imp_schema_basic';
  l_dumpfile := 'dp_schema.dmp';
  l_logfile  := l_job_name || '.log';
  l_dpdir    := 'DATA_PUMP_DIR';
  
  l_from_schema := 'SCOTT';  --needs exp_full_database
  l_to_schema   := 'FRED';
  l_from_ts     := 'USERS';
  l_to_ts       := 'FRED_TS';

  BEGIN --Open job
    l_dp_handle := dbms_datapump.open(operation => 'IMPORT',
                                      job_mode  => 'SCHEMA',
                                      job_name  => l_job_name);
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
      dbms_output.put_line('Check for existing data pump session.');
      RAISE;
    WHEN OTHERS THEN
      raise_application_error(-20000,
                              'Error when opening job: ' || SQLERRM);
  END;

  BEGIN --Add dump file
    dbms_datapump.add_file(handle    => l_dp_handle,
                           filename  => l_dumpfile,
                           directory => l_dpdir,
                           filetype  => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20020,
                              'Error when adding dump file: ' || SQLERRM);
  END;
    
  BEGIN --Add log file
    dbms_datapump.add_file(handle    => l_dp_handle,
                           filename  => l_logfile,
                           directory => l_dpdir,
                           filetype  => dbms_datapump.ku$_file_type_log_file);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20022,
                              'Error when adding log file: ' || SQLERRM);
  END;

  BEGIN --Remap schema
    dbms_datapump.metadata_remap(handle    => l_dp_handle,
                                 NAME      => 'REMAP_SCHEMA',
                                 old_value => l_from_schema,
                                 VALUE     => l_to_schema);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20032,
                              'Error when adding metadata remap schema: ' ||
                              SQLERRM);
  END;

  BEGIN --Remap tablespace
    dbms_datapump.metadata_remap(handle    => l_dp_handle,
                                 NAME      => 'REMAP_TABLESPACE',
                                 old_value => l_from_ts,
                                 VALUE     => l_to_ts);                                
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20033,
                              'Error when adding metadata remap ts: ' ||
                              SQLERRM);
  END;
   
  BEGIN --set parameters
    dbms_datapump.set_parameter(l_dp_handle, 'TABLE_EXISTS_ACTION', 'APPEND');
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20036,
                              'Error when adding parameter: ' || SQLERRM);
  END;
           
  BEGIN --Start job
    dbms_datapump.start_job(handle => l_dp_handle);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20040,
                              'Error when starting job: ' || SQLERRM);
  END;

  BEGIN --Monitor export job
    monitor_dp(p_dp_handle => l_dp_handle, p_errors => l_errors);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error monitoring the dp job <' || SQLERRM || '> ');
      RAISE;
  END;

  BEGIN  --Detach job
    dbms_datapump.detach(handle => l_dp_handle);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20050, SQLERRM);
  END;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Main exception: ' || SQLERRM);
    RAISE;
END imp_schema_basic;
/
