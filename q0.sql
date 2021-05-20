set lines 166 pages 200
set recsep off

column first_load_time format a11 heading first_load
col last_load for a11
column last_active format a11 
column disk_reads heading prds
column rows_processed heading rowsp
column executions  format 999,999,999 heading "Execs"
column sql_text heading "SQL Text"
column plan_table_output format a145
column child_number format 9999 heading "Child|Number"
column buffer_gets heading gets
col cpu_sec format 9999999.99
col ela_sec format 9999999.99
col gets_per_row format 999999 heading gets_row
col ela_per_row format 999999 heading "ms_row"
col users_executing for 9999 head users
col chld for 9999
set verify off
col inst_id for 9999 head inst
col sql_id_chld for a17 head "sqlid:chld@inst"
col dwts_k for 99999

--alter session set nls_date_format='DD-MON-YY HH24:MI:SS';

col sql_id for a13
col inst_id for 99 head inst

select  sql_id||':'||child_number||'@'||inst_id  sql_id_chld, plan_hash_value phv,
	to_char(to_date(first_load_time, 'yyyy-mm-dd/hh24:mi:ss'),  'ddmon hh24:mi') first_load_time,
	substr(last_load_time,6,11) last_load,
	to_char(last_active_time, 'ddmon hh24:mi') last_active,
	disk_reads, buffer_gets, DIRECT_WRITES/1000 dwts_k, rows_processed, executions,
	(cpu_time/1000000) cpu_sec, (elapsed_time/1000000) ela_sec, --hash_value, sql_id,
	buffer_gets/(decode(rows_processed, 0, 1, rows_processed)) gets_per_row,
	elapsed_time/1000/(decode(rows_processed, 0, 1, rows_processed)) ela_per_row
	, users_executing
from gv$sql where sql_id = '&1'
/

undefine sql_id

