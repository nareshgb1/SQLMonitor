col object for a40
col pct for 99.99
col min_t for a25
col max_t for a25
col ct for 99999

select inst_id, object, subobject_name, ct, 100*ct/sum(ct) over() pct, min_t, max_t from 
	(
	select inst_id, nvl(object_name,'object id: ' || current_obj#) object, subobject_name, sum(ct) ct, min_t, max_t
	from
		(
		select inst_id, current_obj#, count(*) ct, 
			to_char(min(cast(sample_time as date)), 'yyyy/mm/dd hh24:mi:ss') min_t, 
			to_char(max(cast(sample_time as date)), 'yyyy/mm/dd hh24:mi:ss') max_t
		from G&ash
		where sql_id = '&1' and (event like 'db file s%' or event like 'cell %phy%') and session_state like 'WAIT%'
		-- and sample_time > sysdate - 5/1440
		group by inst_id, current_obj#),
	dba_objects
	where current_obj# = object_id(+)
	group by inst_id, subobject_name, nvl(object_name, 'object id: ' || current_obj#), min_t, max_t
	)
order by inst_id, ct desc
/
