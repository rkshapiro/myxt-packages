-- Function:  itemcomponent(character varying)

-- DROP FUNCTION  itemcomponent(character varying);

CREATE OR REPLACE FUNCTION  itemcomponent(IN _item_number character varying, OUT _bom_item_number character varying, OUT _bom_uom character varying, OUT _bom_qty numeric, OUT _bom_item_class_code character varying, OUT _bom_item_type character, OUT _bom_item_desc_1 character varying, OUT _bom_item_desc_2 character varying, OUT _bom_item_comments character varying, OUT _bom_level integer, OUT _bom_parent_item_number character varying, OUT _bom_item_extdescrip character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
  _x RECORD;

BEGIN
-- 20130906:jjb Removed the dependence on the itemcomponentdata type and just returned all params through the OUT parameters
--              Implemented _bom_item_parent_id (bomdata_bomwork_parent_id from the indentedbom function) per Rebecca's 9/5/13 5:01 e-mail
-- 20130910:jjb Removed _bom_item_parent_id and implemented _bom_level and _bom_parent_item_number
-- 20130923:jjb Returns original item along with all the bomdata
-- 20131011:jjb __bom_item_comments now returns up to 1000 characters
-- 20131119:jjb Now returns extended description per Albie's request 
-- 20131126:jjb Fixed a bug where __bom_item_comments was only returning 1000 characters for the first item -- not the subitems
-- 20140505:jjb _bom_qty returns a 1 (not a 0) for the main item per Albie's request

	FOR _x IN
		SELECT 
			item_number::character varying(255) AS __bom_item_number,
			(SELECT uom_name FROM uom WHERE item_inv_uom_id=uom_id)::character varying(255) AS __bom_uom,
			(SELECT classcode_code
			 FROM classcode
			 WHERE classcode_id=item_classcode_id)::character varying(255) AS __bom_item_class_code,
			item_type AS __bom_item_type,
			item_descrip1::character varying(255) AS __bom_item_desc_1,
			item_descrip2::character varying(255) AS __bom_item_desc_2,
			item_comments::character varying(1000) AS __bom_item_comments,
			item_extdescrip::character varying(255) AS __bom_item_extdescrip
		FROM item
		WHERE item_number=_item_number
	LOOP
		RETURN QUERY SELECT 
			_x.__bom_item_number,
			_x.__bom_uom,
			1.0::numeric(18,6),
			_x.__bom_item_class_code,
			_x.__bom_item_type,
			_x.__bom_item_desc_1,
			_x.__bom_item_desc_2,
			_x.__bom_item_comments,
			0::integer,
			''::character varying(255),
			_x.__bom_item_extdescrip;

	END LOOP;



	FOR _x IN
		SELECT 
			bomdata_item_number::character varying(255) AS __bom_item_number,
			bomdata_uom_name::character varying(255) AS __bom_uom, 	
			(bomdata_qtyper + bomdata_qtyfxd) AS __bom_qty,				
			(SELECT classcode_code
			 FROM classcode
			 WHERE classcode_id=item_classcode_id)::character varying(255) AS __bom_item_class_code,
			item_type AS __bom_item_type,
			item_descrip1::character varying(255) AS __bom_item_desc_1,
			item_descrip2::character varying(255) AS __bom_item_desc_2,
			item_comments::character varying(1000) AS __bom_item_comments,
			bomdata_bomwork_level AS __bom_level,
			(SELECT item_number FROM item WHERE bomitem.bomitem_parent_item_id=item.item_id)::character varying(255) AS __bom_parent_item_number,
			item_extdescrip::character varying(255) AS __bom_item_extdescrip
		FROM indentedbom(getitemid(_item_number), getactiverevid('BOM',getitemid(_item_number)), 0, 0)
			JOIN item ON bomdata_item_id=item_id
			JOIN bomitem ON bomdata_bomitem_id=bomitem_id
		WHERE item_type<>'K'
	LOOP
		RETURN QUERY SELECT 
			_x.__bom_item_number,
			_x.__bom_uom,
			_x.__bom_qty,
			_x.__bom_item_class_code,
			_x.__bom_item_type,
			_x.__bom_item_desc_1,
			_x.__bom_item_desc_2,
			_x.__bom_item_comments,
			_x.__bom_level,
			_x.__bom_parent_item_number,
			_x.__bom_item_extdescrip;
	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION  itemcomponent(character varying) OWNER TO "admin";
GRANT EXECUTE ON FUNCTION  itemcomponent(character varying) TO public;
GRANT EXECUTE ON FUNCTION  itemcomponent(character varying) TO "admin";
GRANT EXECUTE ON FUNCTION  itemcomponent(character varying) TO xtrole;
