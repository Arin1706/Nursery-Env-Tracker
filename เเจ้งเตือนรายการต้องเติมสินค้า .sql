-- เเจ้งเตือนรายการต้องเติมสินค้า v_reorder_suggestions = เปรียบเทียบ on_hand กับ Min‑Max ⇒ suggested_qty
/* min_qty = สินค้าขั้นต่ำต้องมีในสต็อก , max_qty = สินค้ามากที่สุดที่อยู่ในสต๊อก, on_hand = สินค้าคงเหลือ, 
suggested_qty = จำนวนสินค้าที่ไว้คำนวณในระบบการสั่งสินค้าเพิ่ม  
on_hand >= max_qty *ไม่ต้องสั่งเพิ่ม
on_hand < max_qty 
on_hand < min_qty *สั่งมาเติมตามจำนวนที่ suggested_qty แสดง */

SELECT species_id, common_name, min_qty, max_qty, on_hand, suggested_qty
FROM v_reorder_suggestions
WHERE suggested_qty > 0
ORDER BY suggested_qty DESC;

/*การแสดงผล จะมีการแสดงของ column  
species_id,common_name,min_qty,max_qty,on_hand,suggested_qty 
การขึ้นข้อมูลขึ้นอยู่กับ การตั้งค่า WHERE เรามีการตั้งค่าให้ suggested_qty > 0 จึงจะแสดงผล
เนื่องจากข้อมูลของเรา suggested_qty = 0 ทำให้ไม่มีการแสดงผล */
