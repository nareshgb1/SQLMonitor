clear columns

set lines 166 pages 100
col min_time for a12
col max_time for a12
col min_snap for 99999999
col max_snap for 99999999
col execs for 99999
col av_ela for 999999
col av_cpu for 999999
col av_ap for 999999
col av_ela_ms for 999.9
col av_cpu_ms for 999.9
col av_ap_ms for 999.9
col av_ela for 999,999
col av_rows for 999,999,999
col av_gets_k for 999,999
col av_prds_k for 999,999
col av_dwts_k for 999,999
col av_fetch for 99999 head av_ftch
col sql_id for a14


select '&1' sql_id
--      , dbid
        , phv
        , min_snap,
        (select to_char(begin_interval_time, 'dd-mon hh24:mi') from dba_hist_snapshot t where t.snap_id = min_snap and rownum = 1) min_time,
        max_snap,
        (select to_char(end_interval_time, 'dd-mon hh24:mi') from dba_hist_snapshot t where t.snap_id = max_snap and rownum = 1) max_time
        , execs
        , rowsp/decode(execs,0,1,execs)  av_rows
        , rowsp/decode(fetches,0,1,fetches)  av_fetch
-- average in seconds
        , av_ela
        , av_cpu
        , av_ap
-- average in milliseconds
--      , case when av_ela_ms > 99999000 then round(av_ela_ms/1000/60,0) || 'm'
--              when av_ela_ms between 1000 and  round(ela_ms/execs/1000, 2) || ' s'
--                when decode(execs, 0, 0, ela_ms/execs) > 0 then round(ela_ms/execs, 2) || ' ms'
--              when execs = 0 then '0'
--         end as av_ela
--      , av_ela_ms
--      , av_cpu_ms
        , av_gets_K
        , av_prds_K
        , av_dwts_k
from (
select min(snap_id) min_snap, max(snap_id) max_snap
        , sum(executions_delta) execs
        , sum(elapsed_time_delta/1000000) ela_sec
        , sum(cpu_time_delta/1000000) cpu_sec
        , sum(elapsed_time_delta/1000) ela_ms
        , sum(cpu_time_delta/1000) cpu_ms
        , sum(APWAIT_DELTA/1000) ap_ms
        , sum(rows_processed_delta) rowsp
        , sum(buffer_gets_delta) gets
        , sum(disk_reads_delta) prds
        , sum(fetches_delta) fetches
        , sum(elapsed_time_delta/1000000)/sum(decode(executions_delta,0,1,executions_delta)) av_ela
        , sum(cpu_time_delta/1000000)/sum(decode(executions_delta,0,1,executions_delta)) av_cpu
        , sum(APWAIT_DELTA/1000000)/sum(decode(executions_delta,0,1,executions_delta)) av_ap
        , sum(buffer_gets_delta/1000)/sum(decode(executions_delta,0,1,executions_delta)) av_gets_K
        , sum(disk_reads_delta/1000)/sum(decode(executions_delta,0,1,executions_delta)) av_prds_K
        , sum(DIRECT_WRITES_DELTA/1000)/sum(decode(executions_delta,0,1,executions_delta)) av_dwts_K
        --, decode(sum(executions_delta), 0, 0, sum(elapsed_time_delta/1000)/sum(executions_delta)) av_ela_ms
        --, decode(sum(executions_delta), 0, 0, sum(cpu_time_delta/1000)/sum(executions_delta)) av_cpu_ms
        --, decode(sum(executions_delta), 0, 0, sum(APWAIT_DELTA/1000)/sum(executions_delta)) av_ap_ms
        --, decode(sum(executions_delta), 0, 0, sum(buffer_gets_delta)/sum(executions_delta)) av_gets
        --, decode(sum(executions_delta), 0, 0, sum(disk_reads_delta)/sum(executions_delta)) av_prds
        , plan_hash_value phv
        , dbid
from dba_hist_sqlstat where sql_id = '&1'
group by plan_hash_value
        , dbid
)
/


