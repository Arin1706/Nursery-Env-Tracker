/* เป็นการวัดค่าความเสียหายแบ่งเป็น 2 ส่วน ส่วนที่มาจากทางขนส่งหรือมาจากการขายหน้าร้านค้า
เพื่อสืบหาสาเหตุ เพื่อจัดโซน หรือการจัดส่งเพื่อลดความเสียหาย*/

--  ตารางแสดงผลรหัสพันธุ์พืช เเละปริมาณต้นไม้รวมเเต่ล่ะล็อตตารางสรุป
-- qty_received = จำนวนที่รับเข้ามาในล็อต
WITH rec AS(
	SELECT species_id, sum(qty_received) AS I
	FROM inventory
	GROUP BY species_id
),
/* ตารางที่สรุปยอดความเสียหายจากการขนส่ง โดยนำsheet loss_events
เข้ามาเชื่อมกับข้อมูลกับ sheet inventory  เนื่องจากสอง sheetนี้
มีการเชื่อมโยงข้อมูลในส่วน batch_id เมื่อนำข้อมูลในส่วนความเสียหาย 
รวมโโยการเเยกชนิดพันธุ์ */
-- loss_events = แสดงจำนวนความเสียหายของต้นไม้
-- l.qty = ยอดสูญเสีย
los AS (
	SELECT i.species_id, sum(l.qty) AS L
	FROM loss_events AS l
	JOIN inventory AS i ON i.batch_id = l.batch_id
	GROUP BY i.species_id
),
	/* แสดงข้อมูลที่สรุปรวมยอดขายต่อชนิดพันธุ์เชื่อมข้อมูลกับ inventory*/
sal AS (
	SELECT i.species_id, sum(s.qty) AS qty_sold
	FROM sales AS s
	JOIN inventory AS i ON i.batch_id = s.batch_id	
)
/* ส่วนการคำนวนเปอร์เซ็นต์ความเสียหายเทียบกับการรับเข้า inbound
rec : รวมยอดรับเข้า SUM(inventory.qty_received) เป็นคอลัมน์ I ต่อ species_id
los : รวมยอดสูญเสีย SUM(loss_events.qty) เป็นคอลัมน์ L ต่อ species_id (เชื่อมกับ inventory ผ่าน batch_id)
sal : รวมยอดขาย SUM(sales.qty) เป็นคอลัมน์ qty_sold ต่อ species_id
จากนั้น LEFT JOIN กับ species เพื่อให้แสดงทุกรายการชนิดพันธุ์ แม้บางชนิดจะยังไม่มีการรับ/ขาย/สูญเสีย

loss_pct_of_inbound = สัดส่วนความเสียหายเมื่อเทียบกับของที่รับเข้ามา
loss_pct_of_throughput = สัดส่วนความเสียหายเมื่อเทียบกับ ของที่ไหลออกจากคลังจริง (ขาย + เสีย)
*/
SELECT sp.common_name, 
ROUND (100.0 * coalesce(los.L,0) / NULLIF (coalesce (rec.I,0),0),2) AS loss_pct_of_inbound,
ROUND (100.0 * coalesce(los.L,0) / NULLIF (coalesce(sal.qty_sold,0)+ coalesce(los.L,0),0),2) AS loss_pct_of_throughput,
coalesce(rec.I,0) AS I_qty_in,
coalesce(sal.qty_sold,0) AS s_aty_sold,
coalesce(los.L,0) AS L_qty_lost
/* 
COALESCE(los.L, 0) : ถ้าไม่มีบันทึก loss ให้ถือว่า L = 0
COALESCE(rec.I, 0) : ถ้าไม่มีบันทึกรับเข้า ให้ I = 0
NULLIF(..., 0) : ถ้า I = 0 ให้คืนค่า NULL เพื่อหลบ “หารด้วยศูนย์”
100.0 * ... : บังคับให้คำนวณแบบทศนิยม (ไม่ใช่จำนวนเต็ม)
ROUND(..., 2) : ปัดทศนิยม 2 ตำแหน่ง */
FROM species sp
LEFT JOIN rec AS rec ON rec.species_id = sp.species_id
LEFT JOIN los AS los ON los.species_id = sp.species_id
LEFT JOIN sal AS sal ON sal.species_id = sp.species_id
ORDER BY loss_pct_of_inbound DESC;
