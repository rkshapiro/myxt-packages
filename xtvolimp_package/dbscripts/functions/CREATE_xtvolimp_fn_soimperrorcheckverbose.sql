-- Function: xtvolimp.soimperrorcheckverbose()

-- DROP FUNCTION xtvolimp.soimperrorcheckverbose();

CREATE OR REPLACE FUNCTION xtvolimp.soimperrorcheckverbose()
  RETURNS integer AS
$BODY$
-- Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full  of the software license.
DECLARE
  _error      boolean;
  _import     boolean;
  _soldsiteid INTEGER;
  _soldsitecode TEXT;
  _x RECORD;
  _item RECORD;

  
BEGIN
-- Set initial values
_import := true;
SELECT fetchmetricvalue('DefaultSellingWarehouseId') INTO _soldsiteid;
SELECT warehous_code INTO _soldsitecode FROM whsinfo WHERE warehous_id = _soldsiteid;

-- clear any previous error message in case this is a rerun
UPDATE xtvolimp.ordetail 
SET  ordetail_error = '',
     ordetail_import = true
WHERE length(ordetail_error) > 0;

        
FOR _x IN SELECT * FROM xtvolimp.soimp ORDER BY soimp_order_number

    LOOP 
        
        _error := false;
        -- check for a duplicate order
        PERFORM cohead_id 
        FROM cohead
        WHERE cohead_number = _x.soimp_order_number
        AND cohead_saletype_id = getsaletypeid('INT');
        
        IF (FOUND) THEN
            UPDATE xtvolimp.ordetail 
            SET  ordetail_error = 'Order ' || _x.soimp_order_number || ' already exists',
                 ordetail_import = false
            WHERE ordetail_orderdetailid = _x.orderdetailid;
            CONTINUE;
        END IF;
        
        -- skip checking DISCOUNT items
        IF (substring(_x.soimp_item_number from 1 for 4) <> 'DSC-') THEN
            -- Item does not exist  OK
            PERFORM item_id
            FROM item 
            WHERE item_number = _x.soimp_item_number;

            IF (NOT FOUND) THEN
                UPDATE xtvolimp.ordetail 
                SET  ordetail_error = 'Item ' || _x.soimp_item_number || ' is not defined',
                     ordetail_import = false
                WHERE ordetail_orderdetailid = _x.orderdetailid;
                CONTINUE;
            END IF;

            -- Item is inactive OK
            SELECT 
            CASE WHEN NOT item_active THEN true 
            END INTO _error
            FROM item 
            WHERE item_number = _x.soimp_item_number;

            IF (_error) THEN
                UPDATE xtvolimp.ordetail 
                SET  ordetail_error = 'Item ' || _x.soimp_item_number || ' is inactive',
                     ordetail_import = false
                WHERE ordetail_orderdetailid = _x.orderdetailid;
                CONTINUE;
            END IF;

            -- Item is not sold OK
            SELECT 
            CASE WHEN NOT item_sold THEN true 
            END INTO _error
            FROM item 
            WHERE item_number = _x.soimp_item_number;

            IF (_error) THEN
                UPDATE xtvolimp.ordetail 
                SET  ordetail_error = 'Item ' || _x.soimp_item_number || ' is not sold',
                     ordetail_import = false
                WHERE ordetail_orderdetailid = _x.orderdetailid;
                CONTINUE;
            END IF;

            -- Item Site does not exist OK
            SELECT 
            CASE WHEN itemsite_id IS NULL THEN true 
            END INTO _error
            FROM itemsite
            WHERE itemsite_item_id = getitemid(_x.soimp_item_number)
            AND itemsite_warehous_id = _soldsiteid;

            IF (_error) THEN
                UPDATE xtvolimp.ordetail 
                SET  ordetail_error = 'Item ' || _x.soimp_item_number || ' is missing item site for ' || _soldsitecode,
                     ordetail_import = false
                WHERE ordetail_orderdetailid = _x.orderdetailid;
                CONTINUE;
            END IF;

            -- Item Site is not active OK
            SELECT 
            CASE WHEN NOT itemsite_active THEN true 
            END INTO _error
            FROM itemsite
            WHERE itemsite_item_id = getitemid(_x.soimp_item_number)
            AND itemsite_warehous_id = _soldsiteid;

            IF (_error) THEN
                UPDATE xtvolimp.ordetail 
                SET  ordetail_error = 'Item site for ' || _x.soimp_item_number || ' in '|| _soldsitecode || ' is inactive',
                     ordetail_import = false
                WHERE ordetail_orderdetailid = _x.orderdetailid;
                CONTINUE;
            END IF;

            -- Item Site is not sold OK
            SELECT 
            CASE WHEN NOT itemsite_sold THEN true 
            END INTO _error
            FROM itemsite
            WHERE itemsite_item_id = getitemid(_x.soimp_item_number)
            AND itemsite_warehous_id = _soldsiteid;

            IF (_error) THEN
                UPDATE xtvolimp.ordetail 
                SET  ordetail_error = 'Item site for ' || _x.soimp_item_number || ' in '|| _soldsitecode || ' is not sold',
                     ordetail_import = false
                WHERE ordetail_orderdetailid = _x.orderdetailid;
                CONTINUE;
            END IF;   

            -- check that a kit item has a valid BOM
            IF((SELECT item_type FROM item WHERE item_id = getitemid(_x.soimp_item_number)) = 'K') THEN
                FOR _item IN
                SELECT bomitem_id,
                 itemsite_id,
                 itemsite_warehous_id,
                 COALESCE((itemsite_active AND item_active), false) AS active,
                 COALESCE((itemsite_sold AND item_sold), false) AS sold,
                 item_id,
                 item_type,
                 item_price_uom_id,
                 itemsite_createsopr,itemsite_createwo,itemsite_createsopo, itemsite_dropship,
                 bomitem_uom_id
                FROM bomitem 
                JOIN item ON (item_id=bomitem_item_id)
                LEFT OUTER JOIN itemsite ON ((itemsite_item_id=item_id) AND (itemsite_warehous_id=_soldsiteid))
                WHERE((bomitem_parent_item_id=getitemid(_x.soimp_item_number))
                AND (bomitem_rev_id=getactiverevid('BOM',getitemid(_x.soimp_item_number)))
                AND (CURRENT_DATE BETWEEN bomitem_effective AND (bomitem_expires - 1)))
                ORDER BY bomitem_seqnumber
                LOOP
                    IF (NOT _item.active) THEN
                        UPDATE xtvolimp.ordetail 
                        SET  ordetail_error = 'One or more of the components for '||_x.soimp_item_number||' is inactive for the '||_soldsitecode|| ' site.',
                             ordetail_import = false
                        WHERE ordetail_orderdetailid = _x.orderdetailid;
                        EXIT;
                    ELSIF (NOT _item.sold) THEN
                        UPDATE xtvolimp.ordetail 
                        SET  ordetail_error = 'One or more of the components for '||_x.soimp_item_number||' is not sold for the '||_soldsitecode|| ' site.',
                             ordetail_import = false
                        WHERE ordetail_orderdetailid = _x.orderdetailid;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;   
        END IF;
    END LOOP;

    -- Set the status to import if there were no errors found

    UPDATE xtvolimp.ordimp
    SET ordimp_orderstatus = 'Import'
    WHERE ordimp_orderstatus = 'Processing'
    AND ordimp_orderid NOT IN 
    (SELECT DISTINCT ordetail_orderid 
    FROM xtvolimp.ordetail 
    WHERE ordetail_import = false);

    RETURN (SELECT count(*) FROM xtvolimp.ordimp WHERE ordimp_orderstatus = 'Import' AND ordimp_inserted IS NULL);


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10000;
ALTER FUNCTION xtvolimp.soimperrorcheckverbose()
  OWNER TO admin;
