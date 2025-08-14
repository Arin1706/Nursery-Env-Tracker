/* แสดงอายุของสินค้าโดยแบ่งตามล็อตเพื่อป้องกันสินค้าอายุตกค้างเสี่ยงต่อการหมดอายุ
julianday('now') → คืนค่าเป็นตัวเลขวันที่ปัจจุบันในรูปแบบ Julian Day Number (นับต่อเนื่องเป็นวัน)
julianday(i.received_ts) → แปลงวันที่รับสินค้าให้เป็น Julian Day Number
ลบกัน → ได้ จำนวนวันระหว่างวันที่รับกับวันนี้
CAST(... AS INT) → ตัดทศนิยมออกให้เหลือจำนวนวันเต็ม ๆ
ตั้งชื่อคอลัมน์เป็น age_days → “อายุของล็อต”
*/
SELECT i.batch_id, s.common_name,
       CAST((julianday('now') - julianday(i.received_ts)) AS INT) AS age_days,
       v.on_hand
FROM inventory i
JOIN species s USING(species_id)
JOIN v_stock_by_lot v USING(batch_id)
ORDER BY age_days DESC;

