-- SQL 기초 — 테이블 결합과 중첩 쿼리
-- 다운로드: 2026. 11. 25. 오전 12:03:33
-- 학습용 SQL 모음 — 각 섹션의 코드와 실습 쿼리를 한 파일에 정리

-- ═════════════════════════════════════════════════
-- 1. 두 환경의 문법 차이 — 한눈에 보기
-- ═════════════════════════════════════════════════

-- [C1] LMS(DuckDB) 준비 — BigQuery로 학습한다면 이 셀은 건너뛰세요.
-- BigQuery와 똑같은 `project_name.dataset_name.표` 이름을 쓸 수 있도록 이름 공간을 만듭니다.
ATTACH IF NOT EXISTS ':memory:' AS project_name;
CREATE SCHEMA IF NOT EXISTS project_name.dataset_name;

-- [C2]
CREATE OR REPLACE TABLE project_name.dataset_name.customers (
  customer_id STRING,
  name STRING,
  country STRING,
  signup_date DATE,
  grade STRING
);


INSERT INTO project_name.dataset_name.customers VALUES
  ('C001', '김민준', 'Korea', '2023-01-05', 'Gold'),
  ('C002', '이서연', 'Korea', '2023-02-11', 'Silver'),
  ('C003', '박도윤', 'Japan', '2023-02-20', 'Bronze'),
  ('C004', '최지우', 'USA', '2023-03-03', 'Gold'),
  ('C005', '정하준', 'Korea', '2023-03-15', 'Silver'),
  ('C006', '강서윤', 'Korea', '2023-04-01', 'Bronze'),
  ('C007', '조은우', 'Japan', '2023-04-18', 'Silver'),
  ('C008', '윤지호', 'USA', '2023-05-09', 'Gold'),
  ('C009', '임하은', 'Korea', '2023-05-22', 'Bronze'),
  ('C010', '한예준', 'Korea', '2023-06-02', 'Silver'),
  ('C011', '오시우', NULL, '2023-06-19', 'Bronze'),
  ('C012', '신아린', 'Japan', '2023-07-07', 'Silver'),
  ('C013', '권준서', 'Korea', '2023-07-25', 'Gold'),
  ('C014', '황지안', 'USA', '2023-08-10', NULL),
  ('C015', '안수아', 'Korea', '2023-08-28', 'Bronze')

-- [C3]
CREATE OR REPLACE TABLE project_name.dataset_name.products (
  product_id STRING,
  product_name STRING,
  category STRING,
  price DECIMAL(12,2)
);

INSERT INTO project_name.dataset_name.products VALUES
  ('P01', '에어러너', 'Running', 89000),
  ('P02', '클래식 스니커즈', 'Sneakers', 65000),
  ('P03', '첼시 부츠', 'Boots', 145000),
  ('P04', '여름 샌들', 'Sandals', 38000),
  ('P05', '트레일 러너', 'Running', 119000),
  ('P06', '캔버스 스니커즈', 'Sneakers', 49000),
  ('P07', '워커 부츠', 'Boots', 175000),
  ('P08', '슬리퍼 샌들', 'Sandals', 25000),
  ('P09', '양말 세트', 'Accessory', 12000),
  ('P10', '운동화 끈', 'Accessory', 5000)

-- [C4]
CREATE OR REPLACE TABLE project_name.dataset_name.orders (
  order_id STRING,
  customer_id STRING,
  order_date DATE,
  status STRING,
  amount DECIMAL(12,2)
);

INSERT INTO project_name.dataset_name.orders VALUES
  ('O0001', 'C001', '2023-09-02', 'Paid', 125000),
  ('O0002', 'C002', '2023-09-05', 'Shipped', 89000),
  ('O0003', 'C001', '2023-09-11', 'Returned', 45000),
  ('O0004', 'C003', '2023-09-15', 'Paid', 230000),
  ('O0005', 'C004', '2023-09-20', 'Cancelled', NULL),
  ('O0006', 'C005', '2023-09-25', 'Shipped', 67000),
  ('O0007', 'C002', '2023-10-01', 'Paid', 158000),
  ('O0008', 'C006', '2023-10-04', 'Placed', 32000),
  ('O0009', 'C007', '2023-10-12', 'Shipped', 410000),
  ('O0010', 'C008', '2023-10-19', 'Paid', 99000),
  ('O0011', 'C001', '2023-10-23', 'Paid', 76000),
  ('O0012', 'C009', '2023-10-28', 'Cancelled', NULL),
  ('O0013', 'C010', '2023-11-02', 'Shipped', 142000),
  ('O0014', 'C004', '2023-11-08', 'Paid', 88000),
  ('O0015', 'C011', '2023-11-13', 'Placed', 53000),
  ('O0016', 'C012', '2023-11-19', 'Shipped', 175000),
  ('O0017', 'C002', '2023-11-24', 'Returned', 61000),
  ('O0018', 'C013', '2023-11-29', 'Paid', 320000),
  ('O0019', 'C005', '2023-12-03', 'Paid', 47000),
  ('O0020', 'C008', '2023-12-09', 'Shipped', 215000),
  ('O0021', 'C014', '2023-12-14', 'Placed', 38000),
  ('O0022', 'C001', '2023-12-20', 'Paid', 134000),
  ('O0023', 'C015', '2023-12-25', 'Shipped', 92000),
  ('O0024', 'C007', '2024-01-03', 'Paid', 268000),
  ('O0025', 'C010', '2024-01-09', 'Cancelled', NULL),
  ('O0026', 'C003', '2024-01-15', 'Paid', 119000),
  ('O0027', 'C013', '2024-01-22', 'Shipped', 405000),
  ('O0028', 'C006', '2024-01-28', 'Paid', 58000),
  ('O0029', 'C004', '2024-02-04', 'Returned', 73000),
  ('O0030', 'C012', '2024-02-11', 'Paid', 187000)

-- [C5]
CREATE OR REPLACE TABLE project_name.dataset_name.order_items (
  order_id STRING,
  product_id STRING,
  quantity INT64,
  unit_price DECIMAL(12,2)
);

INSERT INTO project_name.dataset_name.order_items VALUES
  ('O0001', 'P01', 1, 125000),
  ('O0002', 'P02', 2, 44500),
  ('O0003', 'P03', 1, 45000),
  ('O0004', 'P04', 2, 115000),
  ('O0006', 'P05', 1, 67000),
  ('O0007', 'P06', 2, 79000),
  ('O0008', 'P07', 1, 32000),
  ('O0009', 'P08', 2, 205000),
  ('O0010', 'P09', 1, 99000),
  ('O0011', 'P01', 2, 38000),
  ('O0013', 'P02', 1, 142000),
  ('O0014', 'P03', 2, 44000),
  ('O0015', 'P04', 1, 53000),
  ('O0016', 'P05', 2, 87500),
  ('O0017', 'P06', 1, 61000),
  ('O0018', 'P07', 2, 160000),
  ('O0019', 'P08', 1, 47000),
  ('O0020', 'P09', 2, 107500),
  ('O0021', 'P01', 1, 38000),
  ('O0022', 'P02', 2, 67000),
  ('O0023', 'P03', 1, 92000),
  ('O0024', 'P04', 2, 134000),
  ('O0026', 'P05', 1, 119000),
  ('O0027', 'P06', 2, 202500),
  ('O0028', 'P07', 1, 58000),
  ('O0029', 'P08', 2, 36500),
  ('O0030', 'P09', 1, 187000)

-- ═════════════════════════════════════════════════
-- 2. ⌨️ 백문이 불여일타 (1)
-- ═════════════════════════════════════════════════

-- [C6] ⌨️ 백문이 불여일타 (1) — customer_id의 PK 자격(유일성) 확인
SELECT 
  COUNT(*) AS '전체 행 수',
  COUNT(DISTINCT(customer_id)) AS '고유 고객수'
FROM project_name.dataset_name.customers

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 3. ▶️ **코드 실행하기 · 코드 셀 7 [C7]**
-- ═════════════════════════════════════════════════

-- [C7]
SELECT
  o.order_id,
  o.amount,
  c.name AS 고객명,
  c.country AS 국가
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.customers AS c
  ON o.customer_id = c.customer_id
WHERE
  o.amount IS NOT NULL
ORDER BY
  o.amount DESC
LIMIT 5

-- ═════════════════════════════════════════════════
-- 4. ▶️ **코드 실행하기 · 코드 셀 8 [C8]**
-- ═════════════════════════════════════════════════

-- [C8]
SELECT
  oi.order_id,
  p.product_name AS 상품명,
  p.category AS 카테고리,
  oi.quantity AS 수량,
  oi.unit_price AS 단가,
  oi.quantity * oi.unit_price AS 라인합계
FROM project_name.dataset_name.order_items AS oi
JOIN project_name.dataset_name.products AS p
  ON oi.product_id = p.product_id
ORDER BY
  라인합계 DESC
LIMIT 5

-- ═════════════════════════════════════════════════
-- 5. ⌨️ 백문이 불여일타 (2)
-- ═════════════════════════════════════════════════

-- [C9] ⌨️ 백문이 불여일타 (2) — 주문번호·금액·고객 등급 조회
SELECT
  o.order_id AS 주문번호,
  o.amount AS 금액,
  c.grade AS 등급
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.customers AS c ON o.customer_id = c.customer_id
WHERE
  o.amount IS NOT NULL
ORDER BY o.amount DESC, o.order_id
LIMIT 5

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 6. ⌨️ 백문이 불여일타 (3)
-- ═════════════════════════════════════════════════

-- [C10] ⌨️ 백문이 불여일타 (3) — 카테고리별 총 판매수량
SELECT
  p.category,
  SUM(oi.quantity) AS 총수량
FROM project_name.dataset_name.order_items AS oi
JOIN project_name.dataset_name.products AS p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY 총수량 DESC

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 7. ▶️ **코드 실행하기 · 코드 셀 11 [C11]**
-- ═════════════════════════════════════════════════

-- [C11]
SELECT
  o.order_id,
  o.amount,
  oi.product_id,
  oi.quantity
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.order_items AS oi
  ON o.order_id = oi.order_id
ORDER BY
  o.order_id NULLS LAST
LIMIT 6

-- ═════════════════════════════════════════════════
-- 8. ⌨️ 백문이 불여일타 (4)
-- ═════════════════════════════════════════════════

-- [C12] ⌨️ 백문이 불여일타 (4) — 국가별 매출 구하기
SELECT
  c.country AS 국가,
  SUM(o.amount) AS 매출합
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.customers AS c ON o.customer_id = c.customer_id
WHERE
  o.amount IS NOT NULL AND c.country IS NOT NULL
GROUP BY c.country
ORDER BY 매출합 DESC

-- 여기에 SQL 쿼리를 작성하세요.


-- ═════════════════════════════════════════════════
-- 9. ▶️ **코드 실행하기 · 코드 셀 13 [C13]**
-- ═════════════════════════════════════════════════

-- [C13]
SELECT
  p.product_id,
  p.product_name AS 상품명,
  SUM(oi.quantity) AS 총판매수량
FROM project_name.dataset_name.products AS p
LEFT JOIN project_name.dataset_name.order_items AS oi
  ON p.product_id = oi.product_id
GROUP BY
  p.product_id,
  상품명
ORDER BY
  총판매수량 NULLS LAST

-- ═════════════════════════════════════════════════
-- 10. ⌨️ 백문이 불여일타 (5)
-- ═════════════════════════════════════════════════

-- -- [C14] ⌨️ 백문이 불여일타 (5) — 한 번도 팔리지 않은 상품 찾기
SELECT
  p.product_id,
  p.product_name AS 상품명,
  SUM(oi.quantity) AS 총판매수량
FROM project_name.dataset_name.products AS p
LEFT JOIN project_name.dataset_name.order_items AS oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, 상품명
HAVING 총판매수량 IS NULL
-- -- 여기에 SQL 쿼리를 작성하세요.

-- SELECT
--   p.product_id,
--   p.product_name
-- FROM project_name.dataset_name.products AS p
-- LEFT JOIN project_name.dataset_name.order_items AS oi
--   ON p.product_id = oi.product_id
-- WHERE
--   oi.order_id IS NULL

-- ═════════════════════════════════════════════════
-- 11. ▶️ **코드 실행하기 · 코드 셀 15 [C15]**
-- ═════════════════════════════════════════════════

-- [C15]
SELECT
  p.product_name AS 상품명,
  SUM(oi.quantity) AS 총판매수량
FROM project_name.dataset_name.order_items AS oi
RIGHT JOIN project_name.dataset_name.products AS p
  ON oi.product_id = p.product_id
GROUP BY
  상품명
ORDER BY
  총판매수량 NULLS LAST

-- ═════════════════════════════════════════════════
-- 12. ▶️ **코드 실행하기 · 코드 셀 16 [C16]**
-- ═════════════════════════════════════════════════

-- [C16]
SELECT
  name,
  '골드회원' AS 사유
FROM project_name.dataset_name.customers
WHERE
  grade = 'Gold'
UNION ALL
SELECT
  name,
  '한국고객' AS 사유
FROM project_name.dataset_name.customers
WHERE
  country = 'Korea'
ORDER BY
  name NULLS LAST

-- ═════════════════════════════════════════════════
-- 13. ⌨️ 백문이 불여일타 (6)
-- ═════════════════════════════════════════════════

-- [C17] ⌨️ 백문이 불여일타 (6) — UNION으로 주의 주문 목록 만들기
-- SELECT
--   order_id,
--   status
-- FROM project_name.dataset_name.orders
-- WHERE amount >= 300000
-- UNION DISTINCT
-- SELECT
--   order_id,
--   status
-- FROM project_name.dataset_name.orders
-- WHERE status = 'Returned'

SELECT
  order_id
FROM project_name.dataset_name.orders
WHERE
  amount >= 300000
UNION DISTINCT
SELECT
  order_id
FROM project_name.dataset_name.orders
WHERE
  status = 'Returned'

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 14. ▶️ **코드 실행하기 · 코드 셀 18 [C18]**
-- ═════════════════════════════════════════════════

-- [C18]
SELECT
  'UNION DISTINCT (중복제거)' AS 방식,
  COUNT(*) AS 행수
FROM (
  SELECT
    name
  FROM project_name.dataset_name.customers
  WHERE
    grade = 'Gold'
  UNION DISTINCT
  SELECT
    name
  FROM project_name.dataset_name.customers
  WHERE
    country = 'Korea'
) AS t
UNION ALL
SELECT
  'UNION ALL (중복유지)',
  COUNT(*)
FROM (
  SELECT
    name
  FROM project_name.dataset_name.customers
  WHERE
    grade = 'Gold'
  UNION ALL
  SELECT
    name
  FROM project_name.dataset_name.customers
  WHERE
    country = 'Korea'
) AS t

-- ═════════════════════════════════════════════════
-- 15. ▶️ **코드 실행하기 · 코드 셀 19 [C19]**
-- ═════════════════════════════════════════════════

-- [C19]
SELECT
  order_id,
  amount
FROM project_name.dataset_name.orders
WHERE
  amount > (
    SELECT
      AVG(amount)
    FROM project_name.dataset_name.orders
  )
ORDER BY
  amount DESC

-- ═════════════════════════════════════════════════
-- 16. ▶️ **코드 실행하기 · 코드 셀 20 [C20]**
-- ═════════════════════════════════════════════════

-- [C20]
SELECT
  order_id,
  customer_id,
  amount
FROM project_name.dataset_name.orders
WHERE
  customer_id IN (
    SELECT
      customer_id
    FROM project_name.dataset_name.customers
    WHERE
      country = 'USA'
  )

-- ═════════════════════════════════════════════════
-- 17. ▶️ **코드 실행하기 · 코드 셀 21 [C21]**
-- ═════════════════════════════════════════════════

-- [C21]
SELECT
  *
FROM (
  SELECT
    customer_id,
    SUM(amount) AS total_amount
  FROM project_name.dataset_name.orders
  WHERE
    amount IS NOT NULL
  GROUP BY
    customer_id
) AS customer_total
WHERE
  total_amount >= 200000
ORDER BY
  total_amount DESC

-- ═════════════════════════════════════════════════
-- 18. ⌨️ 백문이 불여일타 (7)
-- ═════════════════════════════════════════════════

-- [C22] ⌨️ 백문이 불여일타 (7) — 서브쿼리로 한국 고객 주문 조회

SELECT order_id, amount
FROM project_name.dataset_name.orders
WHERE customer_id IN (
  SELECT customer_id
  FROM project_name.dataset_name.customers
  WHERE country = 'Korea'
) AND amount IS NOT NULL
ORDER BY amount DESC





-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 19. ▶️ **코드 실행하기 · 코드 셀 23 [C23]**
-- ═════════════════════════════════════════════════

-- [C23]
SELECT
  order_id,
  amount,
  (
    SELECT
      ROUND(AVG(amount), 0)
    FROM project_name.dataset_name.orders
  ) AS 전체평균,
  amount - (
    SELECT
      AVG(amount)
    FROM project_name.dataset_name.orders
  ) AS 평균과의차이
FROM project_name.dataset_name.orders
WHERE
  amount IS NOT NULL
ORDER BY
  amount DESC
LIMIT 5

-- ═════════════════════════════════════════════════
-- 20. ▶️ **코드 실행하기 · 코드 셀 24 [C24]**
-- ═════════════════════════════════════════════════

-- [C24]
SELECT
  c.country,
  p.category,
  SUM(oi.quantity * oi.unit_price) AS 매출
FROM project_name.dataset_name.customers AS c
JOIN project_name.dataset_name.orders AS o
  ON c.customer_id = o.customer_id
JOIN project_name.dataset_name.order_items AS oi
  ON o.order_id = oi.order_id
JOIN project_name.dataset_name.products AS p
  ON oi.product_id = p.product_id
WHERE
  c.country IS NOT NULL
GROUP BY
  c.country,
  p.category
ORDER BY
  매출 DESC

-- ═════════════════════════════════════════════════
-- 21. ▶️ **코드 실행하기 · 코드 셀 25 [C25]**
-- ═════════════════════════════════════════════════

-- [C25]
SELECT
  customer_id,
  name,
  country
FROM project_name.dataset_name.customers AS c
WHERE
  EXISTS (
    SELECT 1
    FROM project_name.dataset_name.orders AS o
    WHERE o.customer_id = c.customer_id
  )
ORDER BY
  customer_id

-- ═════════════════════════════════════════════════
-- 22. 📒 연습 문제 — 조인과 서브쿼리 (5문항)
-- ═════════════════════════════════════════════════

-- [C26] 📒 연습 문제 — 조인과 서브쿼리 (1/5)

-- 문제: 고객의 국가(country)별 주문 건수를 구하고, 많은 순으로 정렬합니다.
SELECT
  c.country,
  COUNT(*) AS 주문건수
FROM project_name.dataset_name.customers AS c
JOIN project_name.dataset_name.orders AS o 
ON c.customer_id = o.customer_id
WHERE c.country IS NOT NULL
GROUP BY c.country
ORDER BY 주문건수 DESC

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 23. <details>
-- ═════════════════════════════════════════════════

-- [C27] 📒 연습 문제 — 조인과 서브쿼리 (2/5)

-- 문제: orders·order_items·products 세 테이블을 조인해 주문번호·상품명·수량·단가를 조회합니다.
SELECT
  o.order_id,
  p.product_name,
  oi.quantity,
  oi.unit_price
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.order_items AS oi ON o.order_id = oi.order_id
JOIN project_name.dataset_name.products AS p ON oi.product_id = p.product_id
ORDER BY o.order_id

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 24. <details>
-- ═════════════════════════════════════════════════

-- [C28] 📒 연습 문제 — 조인과 서브쿼리 (3/5)

-- 문제: 주문이 한 건도 없는 고객의 이름과 국가를 찾으세요. (LEFT JOIN 활용)

SELECT c.name, c.country
FROM project_name.dataset_name.customers AS c
LEFT JOIN project_name.dataset_name.orders AS o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 25. <details>
-- ═════════════════════════════════════════════════

-- [C29] 📒 연습 문제 — 조인과 서브쿼리 (4/5)

-- 문제: 카테고리별 총매출(수량 × 단가)을 구하고 매출이 큰 순으로 정렬합니다.

SELECT 
  p.category,
  SUM(oi.quantity * oi.unit_price) AS 매출
FROM project_name.dataset_name.order_items AS oi  
JOIN project_name.dataset_name.products AS p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY 매출 DESC


-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 26. <details>
-- ═════════════════════════════════════════════════

-- [C30] 📒 연습 문제 — 조인과 서브쿼리 (5/5)

-- 문제: 전체 주문의 평균 금액보다 큰 주문만 조회합니다. (서브쿼리 활용)
SELECT order_id, amount
FROM project_name.dataset_name.orders
WHERE amount > (
  SELECT AVG(amount)
  FROM project_name.dataset_name.orders
)
ORDER BY amount DESC



-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 27. 🧪 종합 실습 — 월별·카테고리별 매출 TOP 10
-- ═════════════════════════════════════════════════

-- [C31] 🧪 종합 실습 — 월별·카테고리별 매출 TOP 10 (1/4)

SELECT
  p.category,
  SUM(oi.quantity * oi.unit_price) AS 매출
FROM project_name.dataset_name.order_items AS oi
JOIN project_name.dataset_name.products AS p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY 매출 DESC
-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 28. **질문 2.** 고객 이름별 총 구매액 TOP 5를 구합니다. (`orders` + `customers`)
-- ═════════════════════════════════════════════════

-- [C32] 🧪 종합 실습 — 월별·카테고리별 매출 TOP 10 (2/4)
SELECT
  c.name,
  SUM(o.amount) AS 총구매액
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.customers AS c ON o.customer_id = c.customer_id
WHERE o.amount IS NOT NULL
GROUP BY c.name
ORDER BY 총구매액 DESC
LIMIT 5

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 29. **질문 3.** 월별 × 카테고리별 매출을 구해, 매출 상위 10개 (월, 카테고리) 조합을 보여주세요. 그리고 카테고리별 매출을 그래프로 그립니다.
-- ═════════════════════════════════════════════════

-- [C33] 🧪 종합 실습 — 월별·카테고리별 매출 TOP 10 (3/4)

SELECT
  date_trunc('month', o.order_date) AS 월,
  p.category,
  SUM(oi.quantity * oi.unit_price) AS 매출
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.order_items AS oi ON o.order_id = oi.order_id
JOIN project_name.dataset_name.products AS p ON oi.product_id = p.product_id
GROUP BY 월, p.category
ORDER BY 매출 DESC
LIMIT 10

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 30. <details>
-- ═════════════════════════════════════════════════

-- [C34] 🧪 종합 실습 — 월별·카테고리별 매출 TOP 10 (4/4)

SELECT
  p.category AS category,
  SUM(oi.quantity * oi.unit_price) AS revenue
FROM project_name.dataset_name.order_items AS oi
JOIN project_name.dataset_name.products AS p
  ON oi.product_id = p.product_id
GROUP BY
  category
ORDER BY
  revenue DESC

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 31. 코드 퀴즈
-- ═════════════════════════════════════════════════

-- [C35] 코드 퀴즈 — 등급별 총 매출
SELECT 
  c.grade,
  SUM(o.amount) AS 총매출
FROM project_name.dataset_name.orders AS o
JOIN project_name.dataset_name.customers AS c ON o.customer_id = c.customer_id
WHERE o.amount IS NOT NULL
GROUP BY c.grade
ORDER BY 총매출 DESC

-- 여기에 SQL 쿼리를 작성하세요.
