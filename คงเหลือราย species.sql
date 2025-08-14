
-- คงเหลือราย species  v_stock_by_species = คงเหลือต่อ ชนิดพันธุ์
-- common_name = ชื่อสามัญของต้นไม้

SELECT * FROM v_stock_by_species ORDER BY common_name;

/*การแสดงผลจะแสดงชื่อสามัญของต้นไม้โดยเรียงตามตัวอักษรมีการบอกจำนวนคงเหลือในสต็อก column ที่แสดงผล
species_id,common_name,on_hand*/
