clear columns
set timing off

column value_string format a60
col tstamp_value for a32
col last_captured for a22
set lines 166 pages 43
col name for a20 head "bind var name"
col chld for 999
col DATATYPE_STRING for a15 head "data type"
break on chld skip 1


select /*+ rule */ distinct child_number chld
	, NAME
	, DATATYPE_STRING
	, to_char(LAST_CAPTURED, 'dd-mon-yy hh24:mi:ss') last_captured
	, VALUE_STRING 
        , anydata.accesstimestamp(value_anydata) tstamp_value
from gv$sql_bind_capture 
where sql_id = '&1'
  and (VALUE_STRING is not null  or anydata.accesstimestamp(value_anydata) is not null)
order by 
	chld,
	 name
/

clear breaks
set timing on
