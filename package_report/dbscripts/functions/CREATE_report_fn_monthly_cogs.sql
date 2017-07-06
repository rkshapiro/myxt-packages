-- Function: monthly_cogs(character varying, character varying)

-- DROP FUNCTION monthly_cogs(character varying, character varying);

CREATE OR REPLACE FUNCTION monthly_cogs(
    IN dstart character varying,
    IN dend character varying,
    OUT order_number character varying,
    OUT item_number character varying,
    OUT description character varying,
    OUT tot_qty_ordered numeric,
    OUT delivery_dt character varying,
    OUT custtype_code character varying,
    OUT prj_number character varying,
    OUT max_item_price numeric,
    OUT max_item_stdcost numeric,
    OUT max_item_actcost numeric,
    OUT max_tot_price numeric,
    OUT max_tot_stdcost numeric,
    OUT max_tot_actcost numeric,
    OUT prodcat_code character varying,
    OUT sale_flag character varying,
    OUT classcode character varying)
  RETURNS SETOF record AS
$BODY$
/*
	2012-04-11 pb:	Added "and not like '%DOC-TG%'"	to exclude teacher guides
	2012-05-22 rks:	Changed to work with new class codes; '%DOC-TG%' became '%TG' and added 'XCON'
	2013-04-30 rks: modified to use schedule date when promised date is missing
	2013-06-26 rks: changed to union results based on orders with or without promised date
	2014-04-16 rks: added check to treat a 2100-01-01 promised date as null
	2015-09-08 rks: changed REFURB to REFILL, filters to CONTAINS to include MEM items, and A-2 to CONTAINS ASSET
	2016-01-21 rks: added SOLD class code
*/
	-- get orders with promised date
	SELECT  cohead_number::character varying,		
	it.item_number::character varying,		
	it.item_descrip1::character varying,		
	sum(coitem_qtyord)::numeric,		
	(extract(year from coitem_promdate) || '-' || extract(month from coitem_promdate))::character varying ,		
	custtype_code::character varying,		
	prj_number::character varying,		
	max(item_listprice)::numeric ,		
	max(stdcost)::numeric ,		
	max(actcost)::numeric ,		
	sum(coitem_qtyord) * max(item_listprice)::numeric ,		
	sum(coitem_qtyord) * max(stdcost)::numeric ,		
	sum(coitem_qtyord) * max(actcost)::numeric ,		
	prodcat_code::character varying,
	case when _return.isfinalsale(cohead_id) then 
	'SALE'
	else 
	'' 
	end ::character varying as sale_flag,
	classcode::character varying
	FROM cohead 		
	JOIN custinfo ON (cohead_cust_id=cust_id) 		
	JOIN coitem ON (coitem_cohead_id=cohead_id) 		
	JOIN itemsite ON (coitem_itemsite_id=itemsite_id) 		
	JOIN item it ON (itemsite_item_id=it.item_id) 		
	JOIN custtype ON (cust_custtype_id = custtype_id)		
	join prodcat on (item_prodcat_id = prodcat_id)		
	left outer join prj on (cohead_prj_id = prj_id)		
	join 	(		
		SELECT --it.item_id as itemid, 	
		bi.bomitem_rev_id,
		sum(actcost(it.item_id)*bi.bomitem_qtyper) as actcost, sum(stdcost(it.item_id)*bi.bomitem_qtyper) as stdcost, 
		pt.item_number as parentnum,
		ic.classcode as classcode	
		FROM bomitem bi
		join item it on bomitem_item_id = it.item_id	
		--join classcode ic on it.item_classcode_id = classcode_id	
		LEFT OUTER JOIN itemcost on it.item_id = itemcost_item_id	
		left outer join item pt on pt.item_id = bi.bomitem_parent_item_id
		left outer join bomitem bp on bi.bomitem_parent_item_id = bp.bomitem_item_id	
		left outer join classcode pc on pt.item_classcode_id = pc.classcode_id	
		join (
		select case
		when classcode_code ~'D-' then 'Durable'
		else 'Consumable'
		end as classcode,classcode_id
		from classcode
		where classcode_code in ('C-COMPONENTS','C-ASSEMBLIES','D-PACK','CON')	
		OR classcode_code ~ 'REFILL'	-- 20150908:rks	
		OR classcode_code ~ 'XCON'
		OR classcode_code ~ 'BLOCK'
		) as ic on ic.classcode_id = it.item_classcode_id
		where it.item_active = true	
		--and bomitem_rev_id = getactiverevid('BOM',bomitem_parent_item_id)	
		and (pc.classcode_code ~ 'FG'	
		or pt.item_type = 'K')	
		group by pt.item_id,parentnum,bi.bomitem_rev_id,bp.bomitem_rev_id,ic.classcode	
		UNION	
		SELECT --item_id as itemid, 	
		0,actcost(item_id) as actcost, stdcost(item_id) as stdcost, item_number as parentnum,ic.classcode_code as classcode	
		from item	
		join classcode ic on item_classcode_id = classcode_id	
		where (classcode_code  ~ 'DOC' OR classcode_code ~ 'SOLD')
		and classcode_code not like '%TG%'	--	Added to exclude teacher guides -- 20150908:rks	
		order by parentnum
 		) as consumables on it.item_number = parentnum and (bomitem_rev_id = _report.getpriorrevid('BOM',it.item_id,coitem_promdate) or bomitem_rev_id = 0)		
	WHERE coitem_promdate >= cast($1 as date) and coitem_promdate <= cast($2 as date)		
		and NOT cust_number ~ 'ASSET' -- 20150908:rks		
		and coitem_status <> 'X'		
		and NOT prodcat_code ~ 'TRAINING'  --excluding training materials	
		and (coitem_promdate is not null and NOT coitem_promdate = '2100-01-01')
	group by  it.item_number, it.item_descrip1, custtype_code, prj_number,coitem_promdate,prodcat_code,parentnum, cohead_number,cohead_id,classcode
	union
	-- pick up orders without promised date
	SELECT cohead_number ::character varying,	
	it.item_number::character varying,		
	it.item_descrip1::character varying,		
	sum(coitem_qtyord)::numeric ,		
	(extract(year from coitem_scheddate) || '-' || extract(month from coitem_scheddate))::character varying ,		
	custtype_code::character varying,		
	prj_number::character varying,		
	max(item_listprice)::numeric ,		
	max(stdcost)::numeric ,		
	max(actcost)::numeric ,		
	sum(coitem_qtyord) * max(item_listprice)::numeric ,		
	sum(coitem_qtyord) * max(stdcost)::numeric ,		
	sum(coitem_qtyord) * max(actcost)::numeric ,		
	prodcat_code::character varying,
	case when isfinalsale(cohead_id) then 'SALE'
	else '' 
	end ::character varying as sale_flag,
	classcode::character varying
	FROM cohead 		
	JOIN custinfo ON (cohead_cust_id=cust_id) 		
	JOIN coitem ON (coitem_cohead_id=cohead_id) 		
	JOIN itemsite ON (coitem_itemsite_id=itemsite_id) 		
	JOIN item it ON (itemsite_item_id=it.item_id) 		
	JOIN custtype ON (cust_custtype_id = custtype_id)		
	join prodcat on (item_prodcat_id = prodcat_id)		
	left outer join prj on (cohead_prj_id = prj_id)		
	join 	(		
		SELECT --it.item_id as itemid, 	
		bi.bomitem_rev_id,
		sum(actcost(it.item_id)*bi.bomitem_qtyper) as actcost, sum(stdcost(it.item_id)*bi.bomitem_qtyper) as stdcost, 
		pt.item_number as parentnum,
		ic.classcode as classcode
		FROM bomitem bi
		join item it on bomitem_item_id = it.item_id	
		--join classcode ic on it.item_classcode_id = classcode_id	
		LEFT OUTER JOIN itemcost on it.item_id = itemcost_item_id	
		left outer join item pt on pt.item_id = bi.bomitem_parent_item_id
		left outer join bomitem bp on bi.bomitem_parent_item_id = bp.bomitem_item_id	
		left outer join classcode pc on pt.item_classcode_id = pc.classcode_id	
		join (
		select case
		when classcode_code ~'D-' then 'Durable'
		else 'Consumable'
		end as classcode,classcode_id
		from classcode
		where classcode_code in ('C-COMPONENTS','C-ASSEMBLIES','D-PACK','CON')	
		OR classcode_code ~ 'REFILL'	-- 20150908:rks	
		OR classcode_code ~ 'XCON'
		OR classcode_code ~ 'BLOCK'
		) as ic on ic.classcode_id = it.item_classcode_id
		where it.item_active = true	
		--and bomitem_rev_id = getactiverevid('BOM',bomitem_parent_item_id)	
		and (pc.classcode_code ~ 'FG'	
		or pt.item_type = 'K')	
		group by pt.item_id,parentnum,bi.bomitem_rev_id,bp.bomitem_rev_id,ic.classcode	
		UNION	
		SELECT --item_id as itemid, 	
		0,actcost(item_id) as actcost, stdcost(item_id) as stdcost, item_number as parentnum,ic.classcode_code as classcode	
		from item	
		join classcode ic on item_classcode_id = classcode_id	
		where (classcode_code  ~ 'DOC' OR classcode_code ~ 'SOLD')
		and classcode_code not like '%TG%'	--	Added to exclude teacher guides -- 20150908:rks	
		order by parentnum
 		) as consumables on it.item_number = parentnum and (bomitem_rev_id = getpriorrevid('BOM',it.item_id,coitem_scheddate) or bomitem_rev_id = 0)		
	WHERE coitem_scheddate >= cast($1 as date) and coitem_scheddate <= cast($2 as date)		
		and not cust_number ~ 'ASSET'		-- 20150908:rks	
		and coitem_status <> 'X'		
		and NOT prodcat_code ~ 'TRAINING'  --excluding training materials	
		and (coitem_promdate is null OR coitem_promdate = '2100-01-01')
	group by  it.item_number, it.item_descrip1, custtype_code, prj_number,coitem_scheddate,prodcat_code,parentnum,sale_flag,classcode,cohead_id,cohead_number	
	order by 2,1,16
	;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION monthly_cogs(character varying, character varying)
  OWNER TO admin;
GRANT EXECUTE ON FUNCTION monthly_cogs(character varying, character varying) TO admin;
GRANT EXECUTE ON FUNCTION monthly_cogs(character varying, character varying) TO public;
COMMENT ON FUNCTION monthly_cogs(character varying, character varying) IS 'new version of function to support sales orders with and without promised date';
