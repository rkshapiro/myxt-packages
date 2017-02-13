-- Function: islastcomment(integer,text,text)

-- DROP FUNCTION islastcomment(integer,text,text);

CREATE OR REPLACE FUNCTION islastcomment(integer,text,text)
  RETURNS integer AS
$BODY$
-- 20130425:rks ASSET function to identify the most recent version of a specific comment
DECLARE
	psourceid ALIAS FOR $1;
	psource ALIAS FOR $2;
	pcmnttypename ALIAS FOR $3;
	_maxdate TIMESTAMP;
	_lastcommentid INTEGER;

BEGIN
	SELECT MAX(comment_date) INTO _maxdate
	FROM comment
	JOIN cmnttype ON comment_cmnttype_id = cmnttype_id
	WHERE comment_source_id = psourceid
	AND comment_source = psource
	AND cmnttype_name = pcmnttypename;

	SELECT comment_id INTO _lastcommentid
	FROM comment
	JOIN cmnttype ON comment_cmnttype_id = cmnttype_id
	WHERE comment_source_id = psourceid
	AND comment_source = psource
	AND cmnttype_name = pcmnttypename
	AND comment_date = _maxdate;

	RETURN _lastcommentid;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION islastcomment(integer,text,text) OWNER TO admin;