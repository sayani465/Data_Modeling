
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---- Gross generated revenue by campaign/store/customer/membership type----
---------------------------------------------------------------------------
---------------------------------------------------------------------------



SELECT 

  str.store_id,
  str.store_name,
  COALESCE(SUM(ord.total),0) revenue

FROM store str
  LEFT JOIN  order ord
    ON ord.store_id = str.store_id
    AND ord.created_date >= str.created_date 

GROUP BY str.store_id,str.store_name
ORDER BY revenue DESC
;



SELECT 

  camp.campaign_id,
  camp.campaign_name,
  COALESCE(SUM(ord.total),0) revenue

FROM campaign camp
  LEFT JOIN  order ord
    ON ord.campaign_id = camp.campaign_id
    AND ord.created_date >= camp.created_date
    AND UPPER(camp.is_expired) = 'NO'

GROUP BY camp.campaign_id,camp.campaign_name
ORDER BY camp.campaign_id 
;






SELECT 

  cust.first_name,
  cust.last_name,
  cust.loyalty_number,
  COALESCE(SUM(ord.total),0) revenue


FROM  customer cust
  LEFT JOIN  order ord
    ON ord.customer_id = cust.customer_id
    AND ord.created_date >= cust.created_date

GROUP BY cust.first_name,cust.last_name,cust.loyalty_number
ORDER BY revenue DESC
;





SELECT 

  mem.membership_type_id,
  mem.membership_name,
  COALESCE(SUM(ord.total),0) revenue

FROM  membership_type mem
  INNER JOIN customer cust
    ON mem.membership_type_id = cust.membership_type_id
    LEFT JOIN order ord
    ON ord.customer_id = cust.customer_id
    AND ord.created_date >= cust.created_date

GROUP BY mem.membership_type_id,mem.membership_name
ORDER BY revenue DESC
;



---------------------------------------------------------------------------
---------------------------------------------------------------------------
------------- How long until the first customer orders? -------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------


SELECT 

  cust_data.first_name,
  cust_data.last_name,
  cust_data.loyalty_number,
  cust_data.customer_created_date,
  cust_data.order_created_date,
  cust_data.Reqired_Days 

FROM 
 
   (

      SELECT
        cust.customer_id,
        cust.first_name,
        cust.last_name,
        cust.loyalty_number,
        cust.created_date as customer_created_date,
        ord.created_date as order_created_date,
        (DAYS(ord.created_date) - DAYS(cust.created_date)) AS Reqired_Days,
        ROW_NUMBER() OVER (PARTITION BY first_name,last_name,loyalty_number  ORDER BY cust.created_date) row_num

      FROM customer cust
      INNER JOIN order ord
        ON ord.customer_id = cust.customer_id
        AND ord.created_date >= cust.created_date 
 
   ) cust_data

    WHERE cust_data.row_num = 1
    
ORDER BY cust_data.loyalty_number
;   
        
        




---------------------------------------------------------------------------
---------------------------------------------------------------------------
-------------- What items are the most/least popular? ---------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



SELECT 

  Quantity.item_name ,
  COALESCE(SUM(Quantity.item_quantity),0) Total_Sold_Quantity

FROM 

   (
      SELECT

        ord_lst.order_id,
        itm.item_id,
        itm.item_name,
        ord_lst.sale_price ordered_sale_price,
        itm.sale_price item_sale_price,
        ord_lst.sale_price/itm.sale_price AS item_quantity


      FROM item itm
        LEFT JOIN order_list ord_lst
          ON itm.item_id = ord_lst.item_id
          AND   ord_lst.created_date >= itm.created_date
          
      WHERE  itm.parent_item_id is null
     

   ) Quantity

GROUP BY Quantity.item_name
ORDER BY Total_Sold_Quantity DESC
;      
      



---------------------------------------------------------------------------
---------------------------------------------------------------------------
--------------------- What is our gross per sale? -------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------


SELECT 


  AVG(total) Gross_per_sale


FROM order

;



---------------------------------------------------------------------------
---------------------------------------------------------------------------
-------- What items should we remove due to customer preferences? ---------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



SELECT 

  Quantity.item_name ,
  COALESCE(SUM(Quantity.item_quantity),0) Total_Sold_Quantity

FROM 

   (
      SELECT

        ord_lst.order_id,
        itm.item_id,
        itm.item_name,
        ord_lst.sale_price ordered_sale_price,
        itm.sale_price item_sale_price,
        ord_lst.sale_price/itm.sale_price AS item_quantity


      FROM item itm
        LEFT JOIN order_list ord_lst
          ON itm.item_id = ord_lst.item_id
          AND   ord_lst.created_date >= itm.created_date
          
      WHERE  itm.parent_item_id is null
     

   ) Quantity

GROUP BY Quantity.item_name
ORDER BY Total_Sold_Quantity DESC
;  



---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------- How can we improve targeting of marketing campaigns? -----------
---------------------------------------------------------------------------
---------------------------------------------------------------------------




SELECT 

  camp.campaign_id,
  camp.campaign_name,
  COALESCE(COUNT(ord.order_id),0) Number_of_Orders,
  COALESCE(SUM(ord.total),0) revenue

FROM campaign camp
  LEFT JOIN  order ord
    ON ord.campaign_id = camp.campaign_id
    AND ord.created_date >= camp.created_date
    AND UPPER(camp.is_expired) = 'NO'

GROUP BY camp.campaign_id,camp.campaign_name
ORDER BY camp.campaign_id 
;






---------------------------------------------------------------------------
---------------------------------------------------------------------------
----- How long does it take for an order to be processed/delivered? -------
---------------------------------------------------------------------------
---------------------------------------------------------------------------





SELECT 

  ord.order_id,
  ord_St.order_status_name,
  ord_St.updated_date,
  ord_St.created_date,
  (MINUTES_BETWEEN(ord_St.updated_date,ord_St.created_date))  AS Minutes_Taken
  


FROM order ord
  INNER JOIN order_status ord_St
    ON ord.order_status_id = ord_St.order_status_id
     AND LOWER(ord_St.order_status_name) IN ('in progress', 'delivered')

ORDER BY ord.order_id
;





------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------- How long does it take for customers to add their first preference? ------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





SELECT 

  cust_data.first_name,
  cust_data.last_name,
  cust_data.loyalty_number,
  cust_data.customer_created_date,
  cust_data.cust_pref_created_date,
  cust_data.Reqired_Days 

FROM 
 
   (

      SELECT
        cust.customer_id,
        cust.first_name,
        cust.last_name,
        cust.loyalty_number,
        cust.created_date as customer_created_date,
        cust_pref.created_date as cust_pref_created_date,
        (DAYS(cust_pref.created_date) - DAYS(cust.created_date)) AS Reqired_Days,
        ROW_NUMBER() OVER (PARTITION BY cust.first_name,cust.last_name,cust.loyalty_number  ORDER BY cust.created_date) row_num

      FROM customer cust
      LEFT JOIN customer_preference cust_pref
        ON cust_pref.customer_id = cust.customer_id
        AND cust_pref.created_date >= cust.created_date 
 
   ) cust_data

    WHERE cust_data.row_num = 1
    
ORDER BY cust_data.loyalty_number
;




---------------------------------------------------------------------------
---------------------------------------------------------------------------
---- How long does it take for customers to improve their membership? -----
---------------------------------------------------------------------------
---------------------------------------------------------------------------




SELECT 
  cust_data.cust1_first_name AS first_name,
  cust_data.cust1_last_name AS last_name,
  cust_data.cust1_loyalty_number AS loyalty_number,
  cust_data.cust2_created_date AS upgrade_date,
  mem.membership_name AS upgraded_membership,
  cust_data.days_taken

FROM
  (
      SELECT

        cust1.first_name as cust1_first_name,
        cust1.last_name as cust1_last_name,
        cust1.loyalty_number as cust1_loyalty_number,
        cust1.membership_type_id as cust1_membership_type_id,
        cust1.created_date as cust1_created_date,
        cust2.first_name as cust2_first_name,
        cust2.last_name as cust2_last_name,
        cust2.loyalty_number as cust2_loyalty_number,
        cust2.membership_type_id as cust2_membership_type_id,
        cust2.created_date as cust2_created_date,
        DAYS_BETWEEN(cust2.created_date,cust1.created_date) days_taken,
        ROW_NUMBER() OVER (PARTITION BY cust1.first_name,cust1.last_name,cust1.loyalty_number,cust1.membership_type_id  ORDER BY cust2.membership_type_id) row_num

      FROM customer cust1
        INNER JOIN customer cust2
          ON cust1.first_name = cust2.first_name
          AND cust1.last_name = cust2.last_name
          AND cust1.loyalty_number = cust2.loyalty_number
          AND cust2.membership_type_id > cust1.membership_type_id
          AND cust2.created_date > cust1.created_date
  )  cust_data
  
  INNER JOIN membership_type mem
    ON mem.membership_type_id = cust_data.cust2_membership_type_id
    
WHERE cust_data.row_num = 1
ORDER BY cust_data.cust2_created_date
; 
 



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
---- How many campaigns does it take to improve a customer's membership? ------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


SELECT 
  cust_data.cust1_first_name AS first_name,
  cust_data.cust1_last_name AS last_name,
  cust_data.cust1_loyalty_number AS loyalty_number,
  cust_data.cust2_created_date AS upgrade_date,
  mem.membership_name AS upgraded_membership,
  (COUNT(ord.order_id)+1) AS Num_of_Campaign_for_Upgradation

FROM
  (
      SELECT

        cust1.customer_id  as cust1_customer_id,
        cust1.first_name as cust1_first_name,
        cust1.last_name as cust1_last_name,
        cust1.loyalty_number as cust1_loyalty_number,
        cust1.membership_type_id as cust1_membership_type_id,
        cust1.created_date as cust1_created_date,
        cust2.customer_id  as cust2_customer_id,
        cust2.first_name as cust2_first_name,
        cust2.last_name as cust2_last_name,
        cust2.loyalty_number as cust2_loyalty_number,
        cust2.membership_type_id as cust2_membership_type_id,
        cust2.created_date as cust2_created_date,
        ROW_NUMBER() OVER (PARTITION BY cust1.first_name,cust1.last_name,cust1.loyalty_number,cust1.membership_type_id  ORDER BY cust2.membership_type_id) row_num

      FROM customer cust1
        INNER JOIN customer cust2
          ON cust1.first_name = cust2.first_name
          AND cust1.last_name = cust2.last_name
          AND cust1.loyalty_number = cust2.loyalty_number
          AND cust2.membership_type_id > cust1.membership_type_id
          AND cust2.created_date > cust1.created_date
  )  cust_data
  
  INNER JOIN membership_type mem
    ON mem.membership_type_id = cust_data.cust2_membership_type_id
  INNER JOIN order ord  
    ON cust_data.cust1_customer_id = ord.customer_id  
    AND ord.campaign_id IS NOT NULL
    
WHERE cust_data.row_num = 1
GROUP BY   cust_data.cust1_first_name, cust_data.cust1_last_name, cust_data.cust1_loyalty_number, cust_data.cust2_created_date, mem.membership_name
ORDER BY cust_data.cust1_loyalty_number
; 





---------------------------------------------------------------------------
---------------------------------------------------------------------------
------------- Which store sees the most campaign action? ------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



SELECT 

  str.store_id,
  str.store_name,
  COALESCE(COUNT(ord.order_id),0) Used_Campaign_Number,
  COALESCE(SUM(ord.total),0) Earned_Revenue

FROM store str
  LEFT JOIN order ord
  ON ord.store_id = str.store_id
  AND ord.campaign_id IS NOT NULL
GROUP BY str.store_id,str.store_name
ORDER BY str.store_id
;







SELECT 
  cust_data.store_id,
  cust_data.store_name,
  cust_data.membership_name,
  COUNT(1) Membership_count

FROM
  (
      SELECT 

        str.store_id,
        str.store_name,
        cust.first_name,
        cust.last_name,
        cust.loyalty_number,
        mem.membership_name,
        ROW_NUMBER() OVER (PARTITION BY str.store_id, str.store_name, cust.first_name, cust.last_name, cust.loyalty_number  ORDER BY cust.membership_type_id desc) row_num

      FROM  store str
        INNER JOIN order ord
          ON ord.store_id = str.store_id
        INNER JOIN customer cust
          ON ord.customer_id = cust.customer_id
        INNER JOIN membership_type mem
          ON cust.membership_type_id = mem.membership_type_id
          
  )  cust_data          
          
WHERE cust_data.row_num = 1          
GROUP BY cust_data.store_id, cust_data.store_name, cust_data.membership_name
ORDER BY cust_data.store_id,cust_data.membership_name
;




---------------------------------------------------------------------------
---------------------------------------------------------------------------
----------- Can we create new "menu meals" to improve sales? --------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------




SELECT 

  pref.preference_name,
  pref.preference_type,
  COUNT(cust_pref.preference_id) Preference_Count

FROM preference pref 

  LEFT JOIN 
    (

      SELECT 

        cust.first_name,
        cust.last_name,
        cust.loyalty_number,
        cust_pref.preference_id
  
      FROM customer_preference cust_pref
        INNER JOIN customer cust
        ON cust.customer_id = cust_pref.customer_id
    
      GROUP BY  cust.first_name,  cust.last_name,  cust.loyalty_number,  cust_pref.preference_id


    ) cust_pref

    ON pref.preference_id = cust_pref.preference_id

GROUP BY pref.preference_name, pref.preference_type
ORDER BY Preference_Count DESC

;







SELECT 

  Quantity.item_name ,
  COALESCE(SUM(Quantity.item_quantity),0) Total_Sold_Quantity

FROM 

   (
      SELECT

        ord_lst.order_id,
        itm.item_id,
        itm.item_name,
        ord_lst.sale_price ordered_sale_price,
        itm.sale_price item_sale_price,
        ord_lst.sale_price/itm.sale_price AS item_quantity


      FROM item itm
        LEFT JOIN order_list ord_lst
          ON itm.item_id = ord_lst.item_id
          AND   ord_lst.created_date >= itm.created_date
          
      WHERE  itm.parent_item_id is null
     

   ) Quantity

GROUP BY Quantity.item_name
ORDER BY Total_Sold_Quantity DESC
;      
     

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
---- We want to measure the value of membership types as members return to ensure we have the correct levels?------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------





SELECT 

  mem.membership_type_id,
  mem.membership_name,
  COALESCE(COUNT(ord.order_id),0) Number_of_Orders,
  COALESCE(SUM(ord.total),0) revenue

FROM  membership_type mem
  INNER JOIN customer cust
    ON mem.membership_type_id = cust.membership_type_id
    LEFT JOIN order ord
    ON ord.customer_id = cust.customer_id
    AND ord.created_date >= cust.created_date

GROUP BY mem.membership_type_id,mem.membership_name
ORDER BY revenue DESC
;



SELECT 

  cust.first_name,
  cust.last_name,
  cust.loyalty_number,
  mem.membership_name,
  COALESCE(COUNT(ord.order_id),0) Number_of_Orders,
  COALESCE(SUM(ord.total),0) revenue

FROM customer cust
  INNER JOIN membership_type mem 
    ON cust.membership_type_id = mem.membership_type_id 
  LEFT JOIN  order ord
    ON ord.customer_id = cust.customer_id
    AND ord.created_date >= cust.created_date
    AND ord.created_date BETWEEN cust.membership_valid_from_date and cust.membership_valid_to_date

GROUP BY cust.customer_id, cust.first_name, cust.last_name, cust.loyalty_number, mem.membership_type_id, mem.membership_name
ORDER BY cust.loyalty_number
;
	

