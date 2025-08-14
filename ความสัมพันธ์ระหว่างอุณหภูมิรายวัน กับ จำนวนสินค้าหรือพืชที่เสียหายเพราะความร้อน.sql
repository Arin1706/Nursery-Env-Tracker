/* heat_spikes) = คำนวณค่า อุณหภูมิเฉลี่ยต่อวัน จากข้อมูลสภาพแวดล้อม
date(log_ts) → ดึงเฉพาะวันที่ (ตัดเวลาออก) จากข้อมูล log
AVG(temperature_c) → คำนวณค่าอุณหภูมิเฉลี่ยในวันนั้น
GROUP BY date(log_ts) → จัดกลุ่มตามวันที่
ผลลัพธ์: วันละ 1 แถว พร้อมค่าอุณหภูมิเฉลี่ย (avg_t)
*/
WITH heat_spikes AS (
  SELECT date(log_ts) AS d, AVG(temperature_c) AS avg_t
  FROM env_logs GROUP BY date(log_ts)
),

/* (loss_by_day) = รวมยอด จำนวนสูญเสียต่อวัน เฉพาะสาเหตุ "heat"
date(event_ts) → ดึงวันที่ของเหตุการณ์สูญเสีย
SUM(qty) → รวมจำนวนสูญเสียในวันนั้น
WHERE cause='heat' → เลือกเฉพาะเหตุผลที่สาเหตุคือ ความร้อน
ผลลัพธ์: วันละ 1 แถว พร้อมจำนวนสูญเสีย (lost_qty) */
loss_by_day AS (
  SELECT date(event_ts) AS d, SUM(qty) AS lost_qty
  FROM loss_events WHERE cause='heat'
  GROUP BY date(event_ts)
)
/* LEFT JOIN ... USING(d) → จับคู่ตารางทั้งสองตามวันที่ (d)
ใช้ LEFT JOIN เพราะบางวันอาจไม่มีการเสียหาย → จะยังคงแสดงอุณหภูมิและใส่ 0 ให้จำนวนสูญเสีย
IFNULL(l.lost_qty,0) → ถ้าไม่มีข้อมูลการเสียหายในวันนั้น ให้ใส่ 0 แทน NULL
ORDER BY h.d → เรียงตามวันที่จากเก่าไปใหม่ 
*/ 
SELECT h.d, h.avg_t, IFNULL(l.lost_qty,0) AS lost_qty
FROM heat_spikes h LEFT JOIN loss_by_day l USING(d)
ORDER BY h.d;
