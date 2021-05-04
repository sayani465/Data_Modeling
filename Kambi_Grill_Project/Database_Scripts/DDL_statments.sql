
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-------------------- TABLES Creation for Member Domain --------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------





CREATE TABLE  membership_type  (
    
        membership_type_id                 INT NOT NULL PRIMARY KEY,
        membership_name                    VARCHAR(50),
        created_date                       TIMESTAMP,
        updated_date                       TIMESTAMP
    
)    
; 




CREATE TABLE  customer  (
                
        customer_id                        INT NOT NULL PRIMARY KEY,
        first_name                         VARCHAR(30),
        last_name                          VARCHAR(30),
        loyalty_number                     VARCHAR(30),
        created_date                       TIMESTAMP,
        updated_date                       TIMESTAMP,
        membership_type_id                 INT,
        membership_valid_from_date         TIMESTAMP,
        membership_valid_to_date           TIMESTAMP
                
)                
;                




CREATE TABLE  customer_preference  (
                
        customer_preference_id             INT NOT NULL PRIMARY KEY,
        customer_id                        INT,
        preference_id                        INT,
        prefrence_name                     VARCHAR(30),
        prefrence_value                    VARCHAR(30),
        created_date                       TIMESTAMP,
        updated_date                       TIMESTAMP
                
)                
;                




CREATE TABLE  preference  (
                
        preference_id                      INT NOT NULL PRIMARY KEY,
        preference_name                    VARCHAR(30),
        preference_type                    VARCHAR(30),
        created_date                       TIMESTAMP,
        updated_date                       TIMESTAMP
                
)                
;





CREATE TABLE  customer_audit_log  (
                
        audit_id                          INT NOT NULL PRIMARY KEY,
        table_name                        VARCHAR(30),
        primary_key                       VARCHAR(30),
        column_name                       VARCHAR(30),
        old_value                         VARCHAR(30),
        new_value                         VARCHAR(30),
        created_date                      TIMESTAMP
                
)                
;                





---------------------------------------------------------------------------
---------------------------------------------------------------------------
----------------- TABLES Creation for Marketing Domain --------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------




CREATE TABLE  campaign  (
                
        campaign_id                       INT NOT NULL PRIMARY KEY,
        campaign_name                     VARCHAR(50),
        membership_type_id                INT,
        store_id                          INT,
        is_expired                        VARCHAR(5),
        discount_rate_1                   INT,
        discount_rate_2                   INT,
        valid_from_date                   TIMESTAMP,
        valid_to_date                     TIMESTAMP,
        created_date                      TIMESTAMP,
        updated_date                      TIMESTAMP,
        created_by                        VARCHAR(30),
        updated_by                        VARCHAR(30)
                
)                
;                
        


CREATE TABLE  store  (
                
        store_id                          INT NOT NULL PRIMARY KEY,
        store_name                        VARCHAR(30),
        address                           VARCHAR(100),
        city                              VARCHAR(30),
        country                           VARCHAR(30),
        tax_rate_1                        INT,
        tax_rate_2                        INT,
        created_date                      TIMESTAMP,
        updated_date                      TIMESTAMP
                
)                
;                




CREATE TABLE  campaign_audit_log  (
                
        campaign_audit_id                          INT NOT NULL PRIMARY KEY,
        table_name                        VARCHAR(30),
        primary_key                       VARCHAR(30),
        column_name                       VARCHAR(30),
        old_value                         VARCHAR(30),
        new_value                         VARCHAR(30),
        created_date                      TIMESTAMP
                
)                
;                





--------------------------------------------------------------------------
--------------------------------------------------------------------------
------------------- TABLES Creation for Order Domain ---------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------





CREATE TABLE  order  (
        order_id                          INT NOT NULL PRIMARY KEY,
        customer_id                       INT,
        campaign_id                       INT,
        store_id                          INT,
        order_status_id                   INT,
        sub_total                         INT,
        total                             INT,
        tax_total_1                       INT,
        tax_total_2                       INT,
        discount_total_1                  INT,
        discount_total_2                  INT,
        created_date                      TIMESTAMP,
        updated_date                      TIMESTAMP
                
)                
;                





CREATE TABLE  order_list  (
                
        order_list_id                     INT NOT NULL PRIMARY KEY,
        order_id                          INT,
        item_id                           INT,
        sale_price                        INT,
        created_date                      TIMESTAMP,
        updated_date                      TIMESTAMP
                
)                
;                





CREATE TABLE  order_status  (

        order_status_id                   INT NOT NULL PRIMARY KEY,
        order_status_name                 VARCHAR(30),
        created_date                      TIMESTAMP,
        updated_date                      TIMESTAMP
                
)                
;        




CREATE TABLE  item  (
                
        item_id                           INT NOT NULL PRIMARY KEY,
        item_name                         VARCHAR(30),
        parent_item_id                    INT,
        is_available                      VARCHAR(5),
        sale_price                        INT,
        cost_price                        INT,
        created_date                      TIMESTAMP,
        updated_date                      TIMESTAMP
                
)                
;                




CREATE TABLE  order_audit_log  (
                
        order_audit_log_id                INT NOT NULL PRIMARY KEY,
        table_name                        VARCHAR(30),
        primary_key                       VARCHAR(30),
        column_name                       VARCHAR(30),
        old_value                         VARCHAR(30),
        new_value                         VARCHAR(30),
        created_date                      TIMESTAMP
                
)                
;                
        



---------------------------------------------------------------------------
---------------------------------------------------------------------------
-------------------- Adding foreign key Constraints -----------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



ALTER TABLE customer
  ADD CONSTRAINT FK_membership_type_id
  FOREIGN KEY (membership_type_id) REFERENCES membership_type(membership_type_id)
;




ALTER TABLE customer_preference
  ADD CONSTRAINT FK_customer_id
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
;



ALTER TABLE customer_preference
  ADD CONSTRAINT FK_preference_id
  FOREIGN KEY (preference_id) REFERENCES preference(preference_id)
;



ALTER TABLE campaign
  ADD CONSTRAINT FK_membership_type_id
  FOREIGN KEY (membership_type_id) REFERENCES membership_type(membership_type_id)
;



ALTER TABLE campaign
  ADD CONSTRAINT FK_store_id
  FOREIGN KEY (store_id) REFERENCES store(store_id)
;



ALTER TABLE order
  ADD CONSTRAINT FK_campaign_id
  FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id)
;


ALTER TABLE order
  ADD CONSTRAINT FK_customer_id
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
;



ALTER TABLE order
  ADD CONSTRAINT FK_store_id
  FOREIGN KEY (store_id) REFERENCES store(store_id)
;



ALTER TABLE order
  ADD CONSTRAINT FK_order_status_id
  FOREIGN KEY (order_status_id) REFERENCES order_status(order_status_id)
;





ALTER TABLE order_list
  ADD CONSTRAINT FK_order_id
  FOREIGN KEY (order_id) REFERENCES order(order_id)
;



ALTER TABLE order_list
  ADD CONSTRAINT FK_item_id
  FOREIGN KEY (item_id) REFERENCES item(item_id)
;



ALTER TABLE item
  ADD CONSTRAINT FK_parent_item_id
  FOREIGN KEY (parent_item_id) REFERENCES item(item_id)
;