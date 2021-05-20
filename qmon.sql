set lines 166
col ela_sec for 99999
col cpu_sec for 99999
col inst_id for 99 head inst
col sid for 99999
col px_qcsid  for 99999 head qcsid
col sql_start for a15
col binds_xml for a67
set long 300
col mgets for 999999.99 head "gets(M)"
col prds for 999999999999

select m.inst_id, m.PX_QCSID, m.sid, sql_plan_hash_value phv, to_char(m.sql_exec_start, 'dd-mon hh24:mi:ss') sql_start,  ELAPSED_TIME/1000000 ela_sec, 
	cpu_time/1000000 cpu_sec,
	buffer_gets/1000000 mgets, disk_reads prds,
	fetches,
--	BINDS_XML
        --dbms_lob.substr( regexp_replace(
         --       regexp_replace(regexp_replace(BINDS_XML, '"|binds|bind|name=|NUMBER|pos=| dty=| dtystr=| maxlen=| len=', ''),
          --              '   | [0-9]+>|<|>|:', ' '), '\/    |ID0|OMER|MENT|CRIBER|ANCE', ''), 98, 6) binds_xml
        --regexp_replace(BINDS_XML, 'pos=[^>]*\(>.*<\/bind>\)', '\1/', 1, 0)  binds_xml
	regexp_replace(
        regexp_replace(BINDS_XML, '<\/bind>|<binds>|<\/binds>| pos=[^>]+>', ' ', 1, 0)  
		, '<bind name=|"', '', 1, 0) 
		binds_xml
from gv$sql_monitor  m
where sql_id = '&1' 
order by m.sql_exec_start desc
/



