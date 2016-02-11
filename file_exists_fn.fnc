------------------------------------------------------------------------------------
-- File name: file_exists_fn.fnc
-- Purpose:   To demonstrate how to check for an existing file.
-- Author:    Christoph Ruepprich
--            http://ruepprich.wordpress.com
--            cruepprich@gmail.com
-- Notes:     For educational purposes only.
--
------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION file_exists_fn(p_filename  VARCHAR2
                                         ,p_directory VARCHAR2 DEFAULT 'DATA_PUMP_DIR')
  RETURN BOOLEAN IS
  l_file_length NUMBER;
  l_block_size  NUMBER;
  l_exists      BOOLEAN;
BEGIN
  utl_file.fgetattr(location    => p_directory,
                    filename    => p_filename,
                    fexists     => l_exists,
                    file_length => l_file_length,
                    block_size  => l_block_size);

  RETURN l_exists;
END file_exists_fn;
/
