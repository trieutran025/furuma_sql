use furama_resort;
-- 2.	Hiển thị thông tin của tất cả nhân viên có trong hệ thống có tên bắt đầu là một trong các ký tự “H”, “T” hoặc “K” và có tối đa 15 kí tự.
SELECT *FROM nhan_vien
WHERE ho_ten like 'H%' OR  ho_ten like 'K%' OR ho_ten like 'T%' AND length(ho_ten)=15;
-- 3.	Hiển thị thông tin của tất cả khách hàng có độ tuổi từ 18 đến 50 tuổi và có địa chỉ ở “Đà Nẵng” hoặc “Quảng Trị”.
SELECT *FROM khach_hang
WHERE timestampdiff(year,ngay_sinh,curdate()) BETWEEN 18 and 50
and (dia_chi like '%Đà Nẵng%' or dia_chi like '%Quảng Trị%');

-- 4.	Đếm xem tương ứng với mỗi khách hàng đã từng đặt phòng bao nhiêu lần. 
-- Kết quả hiển thị được sắp xếp tăng dần theo số lần đặt phòng của khách hàng. 
-- Chỉ đếm những khách hàng nào có Tên loại khách hàng là “Diamond”.
SELECT KH.ma_khach_hang,
	   KH.ho_ten,
       count(1) as so_lan_goi
FROM 
	khach_hang KH 
RIGHT JOIN hop_dong HD ON KH.ma_khach_hang = HD.ma_khach_hang
LEFT JOIN loai_khach LK ON KH.ma_loai_khach = LK.ma_loai_khach
WHERE LK.ten_loai_khach = 'Diamond'
GROUP BY KH.ma_khach_hang,KH.ho_ten
ORDER BY so_lan_goi;
-- 5.	Hiển thị ma_khach_hang, ho_ten, ten_loai_khach, ma_hop_dong, ten_dich_vu, 
-- ngay_lam_hop_dong, ngay_ket_thuc, tong_tien (Với tổng tiền được tính theo công thức như sau: 
-- Chi Phí Thuê + Số Lượng * Giá, với Số Lượng và Giá là từ bảng dich_vu_di_kem, hop_dong_chi_tiet) 
-- cho tất cả các khách hàng đã từng đặt phòng. (những khách hàng nào chưa từng đặt phòng cũng phải hiển thị ra).


-- 6.	Hiển thị ma_dich_vu, ten_dich_vu, dien_tich, chi_phi_thue, ten_loai_dich_vu 
-- của tất cả các loại dịch vụ chưa từng được khách hàng thực hiện đặt từ quý 1 
-- của năm 2021 (Quý 1 là tháng 1, 2, 3).
SELECT
    ma_dich_vu,
    ten_dich_vu,
    dien_tich,
    chi_phi_thue,
    ten_loai_dich_vu
from
    dich_vu
    JOIN loai_dich_vu USING (ma_loai_dich_vu)
WHERE
    ma_dich_vu not in (
        SELECT
            ma_dich_vu
        from
            dich_vu
            join hop_dong using (ma_dich_vu)
        WHERE
            QUARTER(ngay_lam_hop_dong) =1 
            and year(ngay_lam_hop_dong) = 2021
    );
-- 7.	Hiển thị thông tin ma_dich_vu, ten_dich_vu, dien_tich, so_nguoi_toi_da, chi_phi_thue, ten_loai_dich_vu 
-- của tất cả các loại dịch vụ đã từng được khách hàng đặt phòng trong năm 2020 
-- chưa từng được khách hàng đặt phòng trong năm 2021.
SELECT 	DV.ma_dich_vu,
		DV.ten_dich_vu,
        DV.dien_tich,
        DV.so_nguoi_toi_da,
        DV.chi_phi_thue,
        LDV.ten_loai_dich_vu
FROM dich_vu DV
join loai_dich_vu LDV USING(ma_loai_dich_vu)
WHERE( ma_dich_vu IN(
		SELECT
            ma_dich_vu 
        from
            dich_vu
            join hop_dong using (ma_dich_vu)
        WHERE
              year(ngay_lam_hop_dong) = 2020
              )
		AND ma_dich_vu NOT IN(
			SELECT
				ma_dich_vu
			from
				dich_vu
				join hop_dong using (ma_dich_vu)
			WHERE
				 year(ngay_lam_hop_dong) = 2021
				  )
		);
-- 8.	Hiển thị thông tin ho_ten khách hàng có trong hệ thống, với yêu cầu ho_ten không trùng nhau.
-- Học viên sử dụng theo 3 cách khác nhau để thực hiện yêu cầu trên.
SELECT DISTINCT ho_ten 
FROM khach_hang ;

SELECT GROUP_CONCAT(DISTINCT ho_ten) as ho_ten
FROM khach_hang
GROUP BY ho_ten;

SELECT ho_ten
FROM khach_hang KH1
WHERE NOT EXISTS(
	SELECT 1
    FROM khach_hang KH2
    WHERE KH2.ho_ten = KH1.ho_ten
    AND KH2.ma_khach_hang < KH1.ma_khach_hang
);
-- 9.	Thực hiện thống kê doanh thu theo tháng, nghĩa là tương ứng với 
-- mỗi tháng trong năm 2021 thì sẽ có bao nhiêu khách hàng thực hiện đặt phòng.
SELECT month(ngay_lam_hop_dong) as '#thang' ,COUNT(1) as so_luong_khach_hang
FROM hop_dong HD 
JOIN khach_hang KH on KH.ma_khach_hang = HD.ma_khach_hang
WHERE year(ngay_lam_hop_dong) = 2021
GROUP BY month(ngay_lam_hop_dong)
ORDER BY month(ngay_lam_hop_dong) ASC;
-- 10.	Hiển thị thông tin tương ứng với từng hợp đồng thì đã sử dụng bao nhiêu dịch vụ đi kèm.
-- Kết quả hiển thị bao gồm ma_hop_dong, ngay_lam_hop_dong, ngay_ket_thuc, 
-- tien_dat_coc, so_luong_dich_vu_di_kem (được tính dựa trên việc sum so_luong ở dich_vu_di_kem).
SET @row_number = 0;
SELECT (@row_number:=@row_number + 1) as ma_hop_dong ,ngay_lam_hop_dong,ngay_ket_thuc
FROM hop_dong
GROUP BY ngay_lam_hop_dong,ngay_ket_thuc;
-- 11.	Hiển thị thông tin các dịch vụ đi kèm đã được sử dụng bởi những 
-- khách hàng có ten_loai_khach là “Diamond” và có dia_chi ở “Vinh” hoặc “Quảng Ngãi”.
SELECT ma_dich_vu_di_kem,ten_dich_vu_di_kem FROM dich_vu_di_kem
JOIN hop_dong_chi_tiet USING(ma_dich_vu_di_kem)
JOIN hop_dong USING(ma_hop_dong)
WHERE ( SELECT dia_chi 
		FROM khach_hang

-- 12.	Hiển thị thông tin ma_hop_dong, ho_ten (nhân viên), ho_ten (khách hàng), so_dien_thoai (khách hàng), 
-- ten_dich_vu, so_luong_dich_vu_di_kem (được tính dựa trên việc sum so_luong ở dich_vu_di_kem), tien_dat_coc 
-- của tất cả các dịch vụ đã từng được khách hàng đặt vào 3 tháng cuối năm 2020 nhưng chưa từng được khách hàng 
-- đặt vào 6 tháng đầu năm 2021.

-- 13.	Hiển thị thông tin các Dịch vụ đi kèm được sử dụng nhiều nhất bởi các Khách hàng đã đặt phòng. 
-- (Lưu ý là có thể có nhiều dịch vụ có số lần sử dụng nhiều như nhau).


-- 14.	Hiển thị thông tin tất cả các Dịch vụ đi kèm chỉ mới được sử dụng một lần duy nhất. 
-- Thông tin hiển thị bao gồm ma_hop_dong, ten_loai_dich_vu, ten_dich_vu_di_kem, so_lan_su_dung 
-- (được tính dựa trên việc count các ma_dich_vu_di_kem).

-- 15.	Hiển thi thông tin của tất cả nhân viên bao gồm ma_nhan_vien, ho_ten, ten_trinh_do, 
-- ten_bo_phan, so_dien_thoai, dia_chi mới chỉ lập được tối đa 3 hợp đồng từ năm 2020 đến 2021.

-- 16.	Xóa những Nhân viên chưa từng lập được hợp đồng nào từ năm 2019 đến năm 2021.

-- 17.	Cập nhật thông tin những khách hàng có ten_loai_khach từ Platinum lên Diamond, 
-- chỉ cập nhật những khách hàng đã từng đặt phòng với Tổng Tiền thanh toán 
-- trong năm 2021 là lớn hơn 10.000.000 VNĐ.

-- 18.	Xóa những khách hàng có hợp đồng trước năm 2021 (chú ý ràng buộc giữa các bảng).

-- 19.	Cập nhật giá cho các dịch vụ đi kèm được sử dụng trên 10 lần trong năm 2020 lên gấp đôi.

-- 20.	Hiển thị thông tin của tất cả các nhân viên và khách hàng có trong hệ thống, 
-- thông tin hiển thị bao gồm id (ma_nhan_vien, ma_khach_hang), 
-- ho_ten, email, so_dien_thoai, ngay_sinh, dia_chi.