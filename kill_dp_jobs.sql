------------------------------------------------------------------------------------
-- File name: kill_dp_jobs.sql
-- Purpose:   Kill current datapump sessions and drop associated tables.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--            Run with dba privileges.
------------------------------------------------------------------------------------
BEGIN
  FOR r1 IN (SELECT username
                   ,action
                   ,sid
                   ,serial#
               FROM v$session
              WHERE module LIKE 'Data Pump%') LOOP
    dbms_output.put_line('Killing sid: ' || r1.sid);
    BEGIN
      EXECUTE IMMEDIATE 'alter system kill session ''' || r1.sid || ',' ||
                        r1.serial# || '''';
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Error killg sid: ' || SQLERRM);
    END;
  
    dbms_output.put_line('Dropping table ' || r1.username || '.' ||
                         r1.action);
    BEGIN
      EXECUTE IMMEDIATE 'drop table "' || r1.username || '"."' || r1.action || '"';
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Error dropping table: ' || SQLERRM);
    END;
  
  END LOOP;
END;
