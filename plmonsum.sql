
REM Author Naresh Bhandare
REM Display summary data from sql_plan_monitor for an SQL - argument 1 is sql_id
REM

set lines 166
set verify off
col id for 999
col plan_op for a26 trunc
col warea_mb for 99999
col warea_max for 9999
col temp_mb for 999999
col temp_max for 999999
col min_t for a14
col max_t for a8
col inst_id for 99 head inst
col prd_gb for 999999.99

break on exec_start skip 1

select count(distinct sql_exec_start) total_execs from gv$sql_plan_monitor where sql_id = '&1'
/

select 
	SQL_PLAN_HASH_VALUE phv,
	PLAN_LINE_ID id, plan_operation || ' ' || plan_options plan_op,
	sum(starts) starts, sum(output_rows) out_rows,
	sum(PHYSICAL_READ_BYTES/1024/1024/1024) prd_gb,
	sum(PHYSICAL_READ_REQUESTS) prd_req,
	to_char(min(first_change_time), 'mm/dd hh24:mi:ss') min_t,
	to_char(max(last_change_time), 'hh24:mi:ss') max_t,
	sum(workarea_mem)/1024/1024 warea_mb,
	sum(WORKAREA_MAX_MEM)/1024/1024 warea_max,
	sum(WORKAREA_TEMPSEG)/1024/1024 temp_mb,
	sum(WORKAREA_MAX_TEMPSEG)/1024/1024 temp_max
from gv$sql_plan_monitor where sql_id = '&1'
group by  SQL_PLAN_HASH_VALUE, PLAN_LINE_ID,  plan_operation || ' ' || plan_options
order by  PLAN_LINE_ID
/
