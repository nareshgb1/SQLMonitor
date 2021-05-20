col ct head "sample|count" for 999999
col op for a45
col pct for 99.9
col min_t for a20
col max_t for a20
col w for a25 trunc
set lines 166

accept sql_id prompt "enter sql_id : "
accept phv prompt "enter plan hash value : "
accept start_snap_id prompt "enter snap_id to check from : "
accept end_snap_id prompt "enter snap_id to check upto : "

with q1 as (
select sql_plan_line_id pline
	, SQL_PLAN_OPERATION || ' ' ||  SQL_PLAN_OPTIONS op
	, decode(session_state, 'ON CPU', 'CPU', event) w
	, count(*) ct
	, min(sample_time) min_t
        , max(sample_time) max_t
from dba_hist_active_sess_history
where sql_id = '&sql_id' 
	and sql_plan_hash_value = &phv
  and snap_id between &start_snap_id and &end_snap_id
group by 
	sql_plan_line_id
	, SQL_PLAN_OPERATION || ' ' ||  SQL_PLAN_OPTIONS
	, decode(session_state, 'ON CPU', 'CPU', event)
order by 
	count(*) desc
)
select pline, op, w, ct, 100*ratio_to_report(ct) over() pct
	, to_char(min_t, 'yyyy/mm/dd hh24:mi:ss') min_t
	, to_char(max_t, 'yyyy/mm/dd hh24:mi:ss') max_t
from q1
order by ct desc
/

