-- Table: matlistcomment

--DROP TABLE matlistcomment;

CREATE TABLE matlistcomment
(
  matlistcomment_id integer NOT NULL,
  matlistcomment_cmnt text,
  CONSTRAINT matlistcomment_pk PRIMARY KEY (matlistcomment_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE matlistcomment
  OWNER TO mfgadmin;
GRANT ALL ON TABLE matlistcomment TO mfgadmin;
GRANT ALL ON TABLE matlistcomment TO xtrole;


INSERT INTO _return.matlistcomment(
            matlistcomment_id, matlistcomment_cmnt)
    VALUES (1, 'This Materials List specifies the contents of one box of science curriculum materials. Your order for a particular Kit may contain more than one box and each box will have a unique Materials list associated with it.  Please use the "Received" column as a means for you to verify receipt of the contents of the box in your preparation to use the materials in your classroom instruction.  The items marked with an X in the "Returnable" column are meant to be returned to ASSET upon the completion of your use of the kit.  Please ensure that the materials identified as "Returnable" on this Materials List are returned in the same module container they were supplied in.  The "Returned" column will help facilitate this process of packing all of the returnable items into the box.  Failure to return items that are marked as returnable or returning items that have obviously been damaged due to neglect may result in charges to your school for replacement of the missing or damaged items. Consumable items do not need to be returned to ASSET.  If you find that you have not been provided all of the materials listed on the Materials List, please contact the ASSET Customer Care at customercare@assetinc.org.  Thank you for your support of the ASSET Program.');

INSERT INTO _return.matlistcomment(
            matlistcomment_id, matlistcomment_cmnt)
    VALUES (2, 'All rented Materials have a return date.  A Member must return a rented Module within ten (10) days of the return date.  Members may request extensions to return dates by contacting ASSET Customer Care.  If a Module is not returned on a timely basis, the Member will be subject to the following late charges:
Failure to return within 30 days of Return Date – $100 per module
Failure to return within 60 days of Return Date – Current Vendor List Price for Selected Module Title');
    

