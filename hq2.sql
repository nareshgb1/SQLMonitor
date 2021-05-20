clear columns

set lines 166 pages 100
col min_time for a12
col max_time for a12
col av_ela for 999,999
col av_cpu for 999,999
col av_ela_ms for 99999.99
col av_cpu_ms for 99999.99
col av_io_ms for 99999.9
col av_cl_ms for 9999.9
col av_ela for 999,999
col av_rows for 999,999.99
col av_gets for 999,999,999
col av_prds for 99,999.99
col sql_id for a14
col inst for 99


select sql_id
--	, dbid
	, phv
	, min_snap,
        (select to_char(begin_interval_time, 'dd-mon hh24:mi') from dba_hist_snapshot t where t.snap_id = min_snap and rownum = 1) min_time,
        max_snap,
        (select to_char(end_interval_time, 'dd-mon hh24:mi') from dba_hist_snapshot t where t.snap_id = max_snap and rownum = 1) max_time
	, execs
	, decode(execs, 0, 0, rowsp/execs)  av_rows
-- average in seconds
--	, av_ela_ms/1000 av_ela
--	, av_cpu_ms/1000 av_cpu
-- average in milliseconds
--	, case when av_ela_ms > 99999000 then round(av_ela_ms/1000/60,0) || 'm'
--		when av_ela_ms between 1000 and  round(ela_ms/execs/1000, 2) || ' s'
--		  when decode(execs, 0, 0, ela_ms/execs) > 0 then round(ela_ms/execs, 2) || ' ms'
--		when execs = 0 then '0'
--	   end as av_ela
	, av_ela_ms
	, av_cpu_ms
	, av_cl_ms
	, av_io_ms
	, decode(execs, 0, 0, gets/execs) av_gets
	, decode(execs, 0, 0, prds/execs) av_prds
from (
select sql_id
	, min(snap_id) min_snap, max(snap_id) max_snap
	, sum(executions_delta) execs
	, sum(elapsed_time_delta/1000000) ela_sec
	, sum(cpu_time_delta/1000000) cpu_sec
	, sum(elapsed_time_delta/1000) ela_ms
	, sum(cpu_time_delta/1000) cpu_ms
	, sum(rows_processed_delta) rowsp
	, sum(buffer_gets_delta) gets
	, sum(disk_reads_delta) prds
	, decode(sum(executions_delta), 0, 0, sum(elapsed_time_delta/1000)/sum(executions_delta)) av_ela_ms
	, decode(sum(executions_delta), 0, 0, sum(cpu_time_delta/1000)/sum(executions_delta)) av_cpu_ms
	, decode(sum(executions_delta), 0, 0, sum(iowait_delta/1000)/sum(executions_delta)) av_io_ms
	, decode(sum(executions_delta), 0, 0, sum(clwait_delta/1000)/sum(executions_delta)) av_cl_ms
	, decode(sum(executions_delta), 0, 0, sum(buffer_gets_delta)/sum(executions_delta)) av_gets
	, decode(sum(executions_delta), 0, 0, sum(disk_reads_delta)/sum(executions_delta)) av_prds
	, plan_hash_value phv
	, dbid
from dba_hist_sqlstat where sql_id = '&1'
group by sql_id , plan_hash_value , dbid
)
/

