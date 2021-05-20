set lines 166 pages 200
set recsep off

column first_load_time format a11 heading first_load
col last_load for a11
column last_active format a11 
column disk_reads heading prds
column rows_processed heading rowsp
column executions  format 9999 heading "Execs"
column sql_text heading "SQL Text"
column buffer_gets heading gets
col cpu_sec format 9999999.99
col ela_sec format 9999999.99
col gets_per_row format 999999 heading gets_row
col ela_per_row format 999999 heading "ms_row"
col users_executing for 9999 head users
col chld for 9999
set verify off
col inst_id for 9999 head inst
col sql_id_chld for a19 head "sql_id:cld@inst"
col cellofl_elig_mb for 9999999
col cellofl_ret_mb for 9999999
col io_int_mb for 9999999
col prdreq for a20 justify right head "prdreq(opt%)"
col cellofl_mb for a25 justify right head "Ofl MB(elig/ret%/int%)"

--alter session set nls_date_format='DD-MON-YY HH24:MI:SS';

col sql_id for a13
col inst_id for 99 head inst



select  sql_id||':'||child_number||'@'||inst_id sql_id_chld, plan_hash_value phv,
	--to_char(to_date(first_load_time, 'yyyy-mm-dd/hh24:mi:ss'),  'ddmon hh24:mi') first_load_time,
	substr(last_load_time,6,11) last_load, to_char(last_active_time, 'ddmon hh24:mi') last_active,
	rows_processed, executions, buffer_gets, disk_reads, 
	lpad(PHYSICAL_READ_REQUESTS || '(' || trunc(100*OPTIMIZED_PHY_READ_REQUESTS/PHYSICAL_READ_REQUESTS,1) || ')',20) prdreq,
	--trunc(IO_CELL_OFFLOAD_ELIGIBLE_BYTES/1024/1024) || '/' || trunc(IO_CELL_OFFLOAD_RETURNED_BYTES/1024/1024) cellofl_mb, 
	lpad( trunc(IO_CELL_OFFLOAD_ELIGIBLE_BYTES/1024/1024) || '/' || trunc(100*IO_CELL_OFFLOAD_RETURNED_BYTES/(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-1),2)
		|| '/' || trunc(100*IO_INTERCONNECT_BYTES/(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-1),2), 25) cellofl_mb,
	(cpu_time/1000000) cpu_sec, (elapsed_time/1000000) ela_sec
	--IO_INTERCONNECT_BYTES/1024/1024 io_int_mb
	--IO_CELL_OFFLOAD_RETURNED_BYTES/1024/1024 cellofl_ret_mb
	--IO_CELL_UNCOMPRESSED_BYTES, 
	--, users_executing
from gv$sql where sql_id = '&1'
/

undefine sql_id

