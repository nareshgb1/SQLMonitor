REM author: Naresh Bhandare
REM shows the time spent against each plan operation (column ash.sql_plan_line_id) and event to identify plan bottleneck/main contributor
REM

set lines 166
col ct head "sample|count" for 999999
col op for a45
col pct for 999.9
col min_t for a15
col max_t for a15
col w for a30 trunc
col sql_plan_line_id for 99999 head pline_id

accept sql_id prompt "enter sql_id : "
accept phv prompt "enter plan hash value : "

with q1 as (
select sql_plan_hash_value phv, sql_plan_line_id
        , SQL_PLAN_OPERATION || ' ' ||  SQL_PLAN_OPTIONS op
        , decode(session_state, 'ON CPU', 'CPU', event) w
        , count(*) ct
        , min(sample_time) min_t
        , max(sample_time) max_t
from gv$active_Session_history
where sql_id = '&sql_id'
--      and sql_plan_hash_value = &phv
group by
        sql_plan_hash_value , sql_plan_line_id
        , SQL_PLAN_OPERATION || ' ' ||  SQL_PLAN_OPTIONS
        , decode(session_state, 'ON CPU', 'CPU', event)
order by
        count(*) desc
)
select phv, sql_plan_line_id, op, w, ct, 100*ratio_to_report(ct) over() pct
        , to_char(min_t, 'dd-mon hh24:mi:ss') min_t
        , to_char(max_t, 'dd-mon hh24:mi:ss') max_t
from q1
--order by ct desc
order by ct desc
/

