------------------------------------------------------------------------------------
-- File name: show_dumpfile_info.sql
-- Purpose:   To demonstrate how to retrieve details from the datapump
--            dump file.
-- Notes:     The code for this procedure comes from Oracle Support
--            Note 462488.1.
------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE show_dumpfile_info(
  p_dir  VARCHAR2 DEFAULT 'DATA_PUMP_DIR',
  p_file VARCHAR2 DEFAULT 'EXPDAT.DMP')
AS
-- p_dir         = directory object where dumpfile can be found
-- p_file        = simple filename of export dumpfile (case-sensitive)
  v_separator   VARCHAR2(80) := '--------------------------------------' ||
                                '--------------------------------------';
  v_path        all_directories.directory_path%type := '?';
  v_filetype    NUMBER;                 -- 0=unknown 1=expdp 2=exp
  v_fileversion VARCHAR2(15);           -- 0.1=10gR1 1.1=10gR2 2.1=11g
  v_info_table  sys.ku$_dumpfile_info;  -- PL/SQL table with file info
  type valtype  IS VARRAY(22) OF VARCHAR2(2048);
  var_values    valtype := valtype();
  no_file_found EXCEPTION;
  PRAGMA        exception_init(no_file_found, -39211);

BEGIN

-- Show generic info:
-- ==================

  dbms_output.put_line(v_separator);
  dbms_output.put_line('Purpose..: Obtain details about export ' ||
        'dumpfile.        Version: 19-MAR-2008');
  dbms_output.put_line('Required.: RDBMS version: 10.2.0.1.0 or higher');
  dbms_output.put_line('.          ' ||
        'Export dumpfile version: 7.3.4.0.0 or higher');
  dbms_output.put_line('.          ' ||
        'Export Data Pump dumpfile version: 10.1.0.1.0 or higher');
  dbms_output.put_line('Usage....: ' ||
        'execute show_dumfile_info(''DIRECTORY'', ''DUMPFILE'');');
  dbms_output.put_line('Example..: ' ||
        'exec show_dumfile_info(''MY_DIR'', ''expdp_s.dmp'')');
  dbms_output.put_line(v_separator);
  dbms_output.put_line('Filename.: ' || p_file);
  dbms_output.put_line('Directory: ' || p_dir);

-- Retrieve Export dumpfile details:
-- =================================

  SELECT directory_path INTO v_path FROM all_directories
   WHERE directory_name = p_dir
      OR directory_name = UPPER(p_dir);

  dbms_datapump.get_dumpfile_info(
           filename   => p_file,       directory => UPPER(p_dir),
           info_table => v_info_table, filetype  => v_filetype);

  var_values.EXTEND(22);
  FOR i in 1 .. 22 LOOP
    BEGIN
      SELECT value INTO var_values(i) FROM TABLE(v_info_table)
       WHERE item_code = i;
    EXCEPTION WHEN OTHERS THEN var_values(i) := '';
    END;
  END LOOP;

-- Show dumpfile details:
-- ======================
-- For Oracle10g Release 2 and higher:
--    dbms_datapump.KU$_DFHDR_FILE_VERSION        CONSTANT NUMBER := 1;
--    dbms_datapump.KU$_DFHDR_MASTER_PRESENT      CONSTANT NUMBER := 2;
--    dbms_datapump.KU$_DFHDR_GUID                CONSTANT NUMBER := 3;
--    dbms_datapump.KU$_DFHDR_FILE_NUMBER         CONSTANT NUMBER := 4;
--    dbms_datapump.KU$_DFHDR_CHARSET_ID          CONSTANT NUMBER := 5;
--    dbms_datapump.KU$_DFHDR_CREATION_DATE       CONSTANT NUMBER := 6;
--    dbms_datapump.KU$_DFHDR_FLAGS               CONSTANT NUMBER := 7;
--    dbms_datapump.KU$_DFHDR_JOB_NAME            CONSTANT NUMBER := 8;
--    dbms_datapump.KU$_DFHDR_PLATFORM            CONSTANT NUMBER := 9;
--    dbms_datapump.KU$_DFHDR_INSTANCE            CONSTANT NUMBER := 10;
--    dbms_datapump.KU$_DFHDR_LANGUAGE            CONSTANT NUMBER := 11;
--    dbms_datapump.KU$_DFHDR_BLOCKSIZE           CONSTANT NUMBER := 12;
--    dbms_datapump.KU$_DFHDR_DIRPATH             CONSTANT NUMBER := 13;
--    dbms_datapump.KU$_DFHDR_METADATA_COMPRESSED CONSTANT NUMBER := 14;
--    dbms_datapump.KU$_DFHDR_DB_VERSION          CONSTANT NUMBER := 15;
-- For Oracle11gR1:
--    dbms_datapump.KU$_DFHDR_MASTER_PIECE_COUNT  CONSTANT NUMBER := 16;
--    dbms_datapump.KU$_DFHDR_MASTER_PIECE_NUMBER CONSTANT NUMBER := 17;
--    dbms_datapump.KU$_DFHDR_DATA_COMPRESSED     CONSTANT NUMBER := 18;
--    dbms_datapump.KU$_DFHDR_METADATA_ENCRYPTED  CONSTANT NUMBER := 19;
--    dbms_datapump.KU$_DFHDR_DATA_ENCRYPTED      CONSTANT NUMBER := 20;
-- For Oracle11gR2:
--    dbms_datapump.KU$_DFHDR_COLUMNS_ENCRYPTED   CONSTANT NUMBER := 21;
--    dbms_datapump.KU$_DFHDR_ENCPWD_MODE         CONSTANT NUMBER := 22;

-- For Oracle10gR2: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 15;
-- For Oracle11gR1: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 20;
-- For Oracle11gR2: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 22;

  dbms_output.put_line('Disk Path: ' || v_path);

  IF v_filetype = 1 OR v_filetype = 2 THEN
    -- Get characterset name:
    BEGIN
      SELECT var_values(5) || ' (' || nls_charset_name(var_values(5)) ||
        ')' INTO var_values(5) FROM dual;
    EXCEPTION WHEN OTHERS THEN null;
    END;
    IF v_filetype = 2 THEN
      dbms_output.put_line(
         'Filetype.: ' || v_filetype || ' (Original Export dumpfile)');
      dbms_output.put_line(v_separator);
      SELECT DECODE(var_values(13), '0', '0 (Conventional Path)',
        '1', '1 (Direct Path)', var_values(13))
        INTO var_values(13) FROM dual;
      dbms_output.put_line('...Characterset ID.: ' || var_values(5));
      dbms_output.put_line('...Direct Path.....: ' || var_values(13));
      dbms_output.put_line('...Export Version..: ' || var_values(15));
    ELSIF v_filetype = 1 THEN
      dbms_output.put_line(
         'Filetype.: ' || v_filetype || ' (Export Data Pump dumpfile)');
      dbms_output.put_line(v_separator);
      SELECT SUBSTR(var_values(1), 1, 15) INTO v_fileversion FROM dual;
      SELECT DECODE(var_values(1),
                    '0.1', '0.1 (Oracle10g Release 1: 10.1.0.x)',
                    '1.1', '1.1 (Oracle10g Release 2: 10.2.0.x)',
                    '2.1', '2.1 (Oracle11g Release 1: 11.1.0.x)',
                    '3.1', '3.1 (Oracle11g Release 2: 11.2.0.x)',
        var_values(1)) INTO var_values(1) FROM dual;
      SELECT DECODE(var_values(2), '0', '0 (No)', '1', '1 (Yes)',
        var_values(2)) INTO var_values(2) FROM dual;
      SELECT DECODE(var_values(14), '0', '0 (No)', '1', '1 (Yes)',
        var_values(14)) INTO var_values(14) FROM dual;
      SELECT DECODE(var_values(18), '0', '0 (No)', '1', '1 (Yes)',
        var_values(18)) INTO var_values(18) FROM dual;
      SELECT DECODE(var_values(19), '0', '0 (No)', '1', '1 (Yes)',
        var_values(19)) INTO var_values(19) FROM dual;
      SELECT DECODE(var_values(20), '0', '0 (No)', '1', '1 (Yes)',
        var_values(20)) INTO var_values(20) FROM dual;
      SELECT DECODE(var_values(21), '0', '0 (No)', '1', '1 (Yes)',
        var_values(21)) INTO var_values(21) FROM dual;
      SELECT DECODE(var_values(22),
                    '1', '1 (Unknown)',
                    '2', '2 (None)',
                    '3', '3 (Password)',
                    '4', '4 (Dual)',
                    '5', '5 (Transparent)',
        var_values(22)) INTO var_values(22) FROM dual;

      dbms_output.put_line('...File Version....: ' || var_values(1));
      dbms_output.put_line('...Master Present..: ' || var_values(2));
      dbms_output.put_line('...GUID............: ' || var_values(3));
      dbms_output.put_line('...File Number.....: ' || var_values(4));
      dbms_output.put_line('...Characterset ID.: ' || var_values(5));
      dbms_output.put_line('...Creation Date...: ' || var_values(6));
      dbms_output.put_line('...Flags...........: ' || var_values(7));
      dbms_output.put_line('...Job Name........: ' || var_values(8));
      dbms_output.put_line('...Platform........: ' || var_values(9));
      IF v_fileversion >= '2.1' THEN
        dbms_output.put_line('...Instance........: ' || var_values(10));
      END IF;
      dbms_output.put_line('...Language........: ' || var_values(11));
      dbms_output.put_line('...Block size......: ' || var_values(12));
      dbms_output.put_line('...Metadata Compres: ' || var_values(14));
      IF dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE > 15 THEN
        dbms_output.put_line('...Data Compressed.: ' || var_values(18));
        dbms_output.put_line('...Metadata Encrypt: ' || var_values(19));
        dbms_output.put_line('...Data Encrypted..: ' || var_values(20));
        dbms_output.put_line('...Column Encrypted: ' || var_values(21));
        dbms_output.put_line('...Encrypt.pwd. mod: ' || var_values(22));
        IF v_fileversion = '2.1' or v_fileversion = '3.1' THEN
          dbms_output.put_line('...Master Piece Cnt: ' || var_values(16));
          dbms_output.put_line('...Master Piece Num: ' || var_values(17));
        END IF;
      END IF;
      IF v_fileversion >= '1.1' THEN
        dbms_output.put_line('...Job Version.....: ' || var_values(15));
      END IF;
      dbms_output.put_line('...Max Items Code..: ' ||
                  dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE);
    END IF;
  ELSE
    dbms_output.put_line('Filetype.: ' || v_filetype);
    dbms_output.put_line(v_separator);
    dbms_output.put_line('ERROR....: Not an export dumpfile.');
  END IF;
  dbms_output.put_line(v_separator);

EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('Disk Path: ?');
    dbms_output.put_line('Filetype.: ?');
    dbms_output.put_line(v_separator);
    dbms_output.put_line('ERROR....: Directory Object does not exist.');
    dbms_output.put_line(v_separator);
  WHEN no_file_found THEN
    dbms_output.put_line('Disk Path: ' || v_path);
    dbms_output.put_line('Filetype.: ?');
    dbms_output.put_line(v_separator);
    dbms_output.put_line('ERROR....: File does not exist.');
    dbms_output.put_line(v_separator);
END;
/
