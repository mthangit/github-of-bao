-- 21521428
-- Hoàng Mạnh Thắng
USE Qly_GiaoVu
GO
------------
-- III
------------
-- 19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT MAKHOA, TENKHOA
FROM (
    SELECT MAKHOA, TENKHOA, RANK() OVER (ORDER BY NGTLAP) AS RANK_NGTL
    FROM KHOA
) AS KHOA_RANK
WHERE RANK_NGTL = 1
GO

-- 20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”
SELECT COUNT(*)
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS')

-- 21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT MAKHOA, HOCVI , COUNT(*) AS SL
FROM GIAOVIEN
WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY MAKHOA, HOCVI
ORDER BY MAKHOA

-- 22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt)
SELECT MAMH, KQUA, COUNT(*) AS SL
FROM HOCVIEN, KETQUATHI
WHERE HOCVIEN.MAHV = KETQUATHI.MAHV
GROUP BY MAMH, KQUA
ORDER BY MAMH

-- 23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp,
--  đồng thời dạy cho lớp đó ít nhất một môn học.
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV IN (
    SELECT MAGV
FROM LOP, GIANGDAY
WHERE LOP.MALOP = GIANGDAY.MALOP AND LOP.MAGVCN = GIANGDAY.MAGV
)

-- 24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HO + ' ' + TEN AS HOTENTRGLOP
FROM HOCVIEN, LOP
WHERE HOCVIEN.MAHV = LOP.TRGLOP AND LOP.SISO = (
    SELECT MAX(SISO)
    FROM LOP
)

-- 25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).



-- 26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT KQ.MAHV, HO + ' ' + TEN AS HOTEN
FROM
    (
SELECT MAHV, COUNT(*) AS SL, RANK () OVER (ORDER BY COUNT(*) DESC) AS RANK_SL
    FROM KETQUATHI
    WHERE  DIEM BETWEEN 9 AND 10
    GROUP BY MAHV
) AS KQ INNER JOIN HOCVIEN ON KQ.MAHV = HOCVIEN.MAHV
WHERE RANK_SL = 1

-- 27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT LOP.MALOP, A.MAHV, A.HOTEN
FROM
    LOP LEFT JOIN(
SELECT MALOP, KQ.MAHV, HO + ' ' + TEN AS HOTEN
    FROM (
SELECT MAHV, COUNT(*) AS SL, RANK () OVER (ORDER BY COUNT(*) DESC) AS RANK_SL
        FROM KETQUATHI
        WHERE  DIEM BETWEEN 9 AND 10
        GROUP BY MAHV
) AS KQ INNER JOIN HOCVIEN ON KQ.MAHV = HOCVIEN.MAHV
    WHERE RANK_SL = 1
) AS A ON LOP.MALOP = A.MALOP

-- 28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT HOCKY, NAM, MAGV, COUNT(MAMH) AS SL_MH, COUNT(MALOP) AS SL_LOP
FROM GIANGDAY
GROUP BY HOCKY, NAM, MAGV
ORDER BY NAM

-- 29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất
SELECT HOCKY, NAM, RANK.MAGV, HOTEN
FROM (
SELECT HOCKY, NAM, MAGV, RANK() OVER (PARTITION BY HOCKY, NAM ORDER BY COUNT(MAMH) DESC) AS RANK_SL, COUNT(MAMH) AS SL_MH
    FROM GIANGDAY
    GROUP BY HOCKY, NAM, MAGV ) AS RANK INNER JOIN GIAOVIEN ON RANK.MAGV = GIAOVIEN.MAGV
WHERE RANK_SL = 1
ORDER BY NAM, HOCKY, SL_MH DESC

-- 30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
SELECT RANK.MAMH, TENMH
FROM (
SELECT DISTINCT MAMH, RANK() OVER (ORDER BY COUNT(MAHV) DESC) AS RANK_SL, COUNT(MAHV) AS SL
    FROM KETQUATHI
    WHERE LANTHI = 1 AND DIEM < 5
    GROUP BY MAMH
    ) AS RANK INNER JOIN MONHOC ON RANK.MAMH = MONHOC.MAMH
WHERE RANK_SL = 1

-- 31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).

SELECT DISTINCT HOCVIEN.MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN, KETQUATHI
WHERE (
    HOCVIEN.MAHV = KETQUATHI.MAHV
    AND NOT EXISTS (
        SELECT *
    FROM KETQUATHI AS KQ
    WHERE KQ.MAHV = HOCVIEN.MAHV AND KQ.LANTHI = 1 AND KQ.DIEM < 5
    )
)

-- 32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).

SELECT DISTINCT HOCVIEN.MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN, KETQUATHI
WHERE (
    HOCVIEN.MAHV = KETQUATHI.MAHV
    AND NOT EXISTS (
        SELECT *
    FROM KETQUATHI AS KQ
    WHERE (
            KQ.MAHV = HOCVIEN.MAHV
        AND LANTHI = (
                SELECT MAX(LANTHI)
        FROM KETQUATHI AS KQ2
        WHERE KQ2.MAHV = HOCVIEN.MAHV
        GROUP BY MAHV
            )
        AND KQ.DIEM < 5
        )
    )
)

