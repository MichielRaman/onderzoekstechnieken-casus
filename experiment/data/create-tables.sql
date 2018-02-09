/* The database is expected to already exist. This script will only create
 * the necessary tables within the database.
 *
 * Run with e.g.
 *
 * mysql -h HOST -udbo -pdbo dbo < create-db.sh
 */

CREATE TABLE category (
ca_id int NOT NULL,
ca_description varchar(50) default NULL,
ca_code varchar(50) default NULL,
PRIMARY KEY (ca_id)
) ;
CREATE TABLE customer (
cu_id int NOT NULL ,
cu_name varchar(50) default NULL,
cu_telephone varchar(50) default NULL,
cu_fax varchar(50) default NULL,
cu_email varchar(50) default NULL,
PRIMARY KEY (cu_id)
) ;
CREATE TABLE invoice (
in_id int NOT NULL ,
in_cu_id int default NULL,
in_date datetime(0) default NULL,
in_description char(50) default NULL,
in_total int default NULL,
in_discount char(50) default NULL,
in_totalafterdiscount int default NULL,
PRIMARY KEY (in_id)
)  ;

CREATE INDEX in_cu_id ON
 invoice (in_cu_id);
CREATE TABLE invoicedetail (
ind_id int NOT NULL ,
ind_in_id int default NULL,
ind_it_id int default NULL,
ind_qty int default NULL,
ind_total float default NULL,
PRIMARY KEY (ind_id)
) ;

CREATE INDEX ind_in_id ON
 invoicedetail (ind_in_id);
CREATE INDEX ind_it_id ON
 invoicedetail (ind_it_id);
CREATE TABLE item (
it_id int NOT NULL ,
it_ca_id int default NULL,
it_lo_id int default NULL,
it_serialnumber char(50) default NULL,
it_code char(50) default NULL,
it_barcode char(10) default NULL,
it_expirydate datetime(0) default NULL,
it_description char(50) default NULL,
it_manufacturer char(50) default NULL,
it_price float default NULL,
it_qtity int default NULL,
PRIMARY KEY (it_id)
)  ;

CREATE INDEX it_ca_id ON
 item (it_ca_id);
CREATE INDEX it_lo_id ON
 item (it_lo_id);

CREATE TABLE location (lo_id int NOT NULL ,
lo_description varchar(50) default NULL,
lo_code varchar(50) default NULL,
PRIMARY KEY (lo_id)
) ;
CREATE TABLE movement (
mo_id int NOT NULL ,
mo_us_id int default NULL,
mo_description char(50) default NULL,
mo_date datetime(0) default NULL,
PRIMARY KEY (mo_id)
)  ;

CREATE INDEX mo_us_id ON
 movement (mo_us_id);
CREATE TABLE movement_details (
mod_id int NOT NULL ,
mod_mo_id int default NULL,
mod_it_id int default NULL,
mod_qtity int default NULL,
mod_fromlocation char(50) default NULL,
mod_tolocation char(50) default NULL,
PRIMARY KEY (mod_id)
)  ;

CREATE INDEX mod_it_id ON
 movement_details (mod_it_id);
CREATE INDEX mod_mo_id ON
 movement_details (mod_mo_id);
CREATE TABLE purchaseorder (
po_id int NOT NULL ,
po_us_id int default NULL,
po_su_id int default NULL,
po_description char(50) default NULL,
po_dateofissue datetime(0) default NULL,
po_recievedate datetime(0) default NULL,
po_status char(50) default NULL,
PRIMARY KEY (po_id)
)  ;

CREATE INDEX po_us_id ON
 purchaseorder (po_us_id);
CREATE INDEX po_su_id ON
 purchaseorder (po_su_id);
CREATE TABLE purchaseorder_details (
pod_id int NOT NULL ,
pod_po_id int default NULL,
pod_it_id int default NULL,
pod_qtity int default NULL,
pod_remainingqtity int default NULL,
PRIMARY KEY (pod_id)
) ;

CREATE INDEX pod_po_id ON
purchaseorder_details (pod_po_id);
CREATE INDEX pod_it_id ON
 purchaseorder_details (pod_it_id);
CREATE TABLE receipt (
re_id int NOT NULL ,
re_cu_id int default NULL,
re_date datetime(0) default NULL,
re_amount int default NULL,
re_modeofpayment varchar(50) default NULL,
re_checknumber varchar(50) default NULL,
re_bank varchar(50) default NULL,
PRIMARY KEY (re_id)
) ;

CREATE INDEX re_cu_id ON
receipt (re_cu_id);
CREATE TABLE stockcount (
st_id int NOT NULL ,
st_us_id int default NULL,
st_description varchar(50) default NULL,
st_date datetime(0) default NULL,
st_status varchar(50) default NULL,
PRIMARY KEY (st_id)
) ;

CREATE INDEX st_us_id ON
 stockcount (st_us_id);
CREATE TABLE stockcount_details (
std_id int NOT NULL ,
std_st_id int default NULL,
std_it_id int default NULL,
std_qtity int default NULL,
std_remainingqtity int default NULL,
PRIMARY KEY (std_id)
) ;

CREATE INDEX std_st_id ON
 stockcount_details (std_st_id);
CREATE INDEX std_it_id ON
 stockcount_details (std_it_id);
CREATE TABLE supplier (
su_id int NOT NULL ,
su_name varchar(50) default NULL,
su_phone varchar(50) default NULL,
su_address varchar(50) default NULL,
su_fax varchar(50) default NULL,
su_email varchar(50) default NULL,
PRIMARY KEY (su_id)
) ;
CREATE TABLE users (
us_id int NOT NULL ,
us_code varchar(50) default NULL,
us_name varchar(50) default NULL,
us_password varchar(50) default NULL,
us_class varchar(50) default NULL,
PRIMARY KEY (us_id)
) ;

ALTER TABLE invoice
ADD FOREIGN KEY (in_cu_id)
 REFERENCES customer (cu_id);
ALTER TABLE invoicedetail
ADD FOREIGN KEY (ind_it_id)
 REFERENCES item (it_id);
ALTER TABLE invoicedetail
ADD FOREIGN KEY (ind_in_id)
REFERENCES invoice (in_id);
ALTER TABLE item
ADD FOREIGN KEY (it_ca_id)
REFERENCES category (ca_id);
ALTER TABLE item
ADD FOREIGN KEY (it_lo_id)
 REFERENCES location (lo_id);
ALTER TABLE movement
ADD FOREIGN KEY (mo_us_id)
REFERENCES users (us_id);
ALTER TABLE movement_details
ADD FOREIGN KEY (mod_mo_id)
REFERENCES movement (mo_id);
ALTER TABLE movement_details
ADD FOREIGN KEY (mod_it_id)
REFERENCES item (it_id);
ALTER TABLE purchaseorder
ADD FOREIGN KEY (po_su_id)
 REFERENCES supplier (su_id);
ALTER TABLE purchaseorder
ADD FOREIGN KEY (po_us_id)
REFERENCES users (us_id);
ALTER TABLE purchaseorder_details
ADD FOREIGN KEY (pod_po_id)
 REFERENCES purchaseorder (po_id);
ALTER TABLE purchaseorder_details
ADD FOREIGN KEY (pod_it_id)
REFERENCES item (it_id);
ALTER TABLE receipt
ADD FOREIGN KEY (re_cu_id)
REFERENCES customer (cu_id);
ALTER TABLE stockcount
ADD FOREIGN KEY (st_us_id)
REFERENCES users (us_id);
ALTER TABLE stockcount_details
ADD FOREIGN KEY (std_st_id)
REFERENCES stockcount (st_id);
ALTER TABLE stockcount_details
ADD FOREIGN KEY (std_it_id)
REFERENCES item (it_id);
