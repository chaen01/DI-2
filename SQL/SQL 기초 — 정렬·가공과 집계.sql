-- SQL 기초 — 정렬·가공과 집계
-- 다운로드: 2026. 11. 24. 오후 10:34:41
-- 학습용 SQL 모음 — 각 섹션의 코드와 실습 쿼리를 한 파일에 정리

-- ═════════════════════════════════════════════════
-- 1. 두 환경의 문법 차이 — 한눈에 보기
-- ═════════════════════════════════════════════════

-- [C1] LMS(DuckDB) 준비 — BigQuery로 학습한다면 이 셀은 건너뛰세요.
-- BigQuery와 똑같은 `project_name.dataset_name.표` 이름을 쓸 수 있도록 이름 공간을 만듭니다.
-- ATTACH IF NOT EXISTS ':memory:' AS project_name;
-- CREATE SCHEMA IF NOT EXISTS project_name.dataset_name;

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

-- [C4]
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

-- ═════════════════════════════════════════════════
-- 2. ▶️ **코드 실행하기 · 코드 셀 5 [C5]**
-- ═════════════════════════════════════════════════

-- [C5]
SELECT
  order_id,
  status,
  amount
FROM project_name.dataset_name.orders
WHERE
  amount IS NOT NULL
ORDER BY
  amount DESC
LIMIT 5

-- ═════════════════════════════════════════════════
-- 3. ▶️ **코드 실행하기 · 코드 셀 6 [C6]**
-- ═════════════════════════════════════════════════

-- [C6]
SELECT
  order_id,
  order_date,
  amount
FROM project_name.dataset_name.orders
ORDER BY
  order_date NULLS LAST
LIMIT 5

-- ═════════════════════════════════════════════════
-- 4. ⌨️ 백문이 불여일타 (1)
-- ═════════════════════════════════════════════════

-- [C7] ⌨️ 백문이 불여일타 (1) — customers 가입일 최근 순 정렬
SELECT name, signup_date
FROM project_name.dataset_name.customers
ORDER BY signup_date DESC
-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 5. ⌨️ 백문이 불여일타 (2)
-- ═════════════════════════════════════════════════

-- [C8] ⌨️ 백문이 불여일타 (2) — 가장 비싼 상품 TOP 3
SELECT product_name, price
FROM project_name.dataset_name.products
ORDER BY price DESC
LIMIT 3
-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 6. ▶️ **코드 실행하기 · 코드 셀 9 [C9]**
-- ═════════════════════════════════════════════════

-- [C9]
SELECT
  name AS 고객명,
  country AS 국가,
  grade AS 등급
FROM project_name.dataset_name.customers
LIMIT 5

-- ═════════════════════════════════════════════════
-- 7. ▶️ **코드 실행하기 · 코드 셀 10 [C10]**
-- ═════════════════════════════════════════════════

-- [C10]
SELECT
  product_name,
  category,
  price
FROM project_name.dataset_name.products
WHERE
  product_name LIKE '%스니커즈%'

-- ═════════════════════════════════════════════════
-- 8. ▶️ **코드 실행하기 · 코드 셀 11 [C11]**
-- ═════════════════════════════════════════════════

-- [C11]
SELECT DISTINCT
  status
FROM project_name.dataset_name.orders
WHERE
  status LIKE 'P%'
ORDER BY
  status

-- ═════════════════════════════════════════════════
-- 9. ▶️ **코드 실행하기 · 코드 셀 12 [C12]**
-- ═════════════════════════════════════════════════

-- [C12]
SELECT DISTINCT
  status
FROM project_name.dataset_name.orders
WHERE
  status LIKE 'P___'
ORDER BY
  status

-- ═════════════════════════════════════════════════
-- 10. ⌨️ 백문이 불여일타 (3)
-- ═════════════════════════════════════════════════

-- [C13] ⌨️ 백문이 불여일타 (3) — 고객 등급 종류 중복 없이 조회
SELECT DISTINCT grade
FROM project_name.dataset_name.customers

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 11. ⌨️ 백문이 불여일타 (4)
-- ═════════════════════════════════════════════════

-- [C14] ⌨️ 백문이 불여일타 (4) — 부츠 상품 한글 별칭 조회
SELECT 
  product_name AS 상품명,
  price AS 가격
FROM project_name.dataset_name.products
WHERE
  product_name LIKE '%부츠%'

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 12. ▶️ **코드 실행하기 · 코드 셀 15 [C15]**
-- ═════════════════════════════════════════════════

-- [C15]
SELECT
  order_id,
  amount,
  CASE WHEN amount >= 200000 THEN '고액' WHEN amount >= 100000 THEN '중액' ELSE '소액' END AS amount_class
FROM project_name.dataset_name.orders
WHERE
  amount IS NOT NULL
ORDER BY
  amount DESC

-- ═════════════════════════════════════════════════
-- 13. ⌨️ 백문이 불여일타 (5)
-- ═════════════════════════════════════════════════

-- [C16] ⌨️ 백문이 불여일타 (5) — 주문 상태 실패/정상 분류
SELECT 
  order_id,
  status,
  CASE WHEN status IN ('Cancelled', 'Returned') THEN '실패' ELSE '정상' END AS result
FROM project_name.dataset_name.orders

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 14. ⌨️ 백문이 불여일타 (6)
-- ═════════════════════════════════════════════════

-- [C17] ⌨️ 백문이 불여일타 (6) — 가격 3단 분류 tier 열 만들기
SELECT 
  product_name,
  price,
  CASE WHEN price >= 100000 THEN '프리미엄' WHEN price >= 30000 THEN '스탠다드' ELSE '베이직' END AS tier
FROM project_name.dataset_name.products
ORDER BY
  price DESC

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 15. ▶️ **코드 실행하기 · 코드 셀 18 [C18]**
-- ═════════════════════════════════════════════════

-- [C18]
SELECT
  COUNT(*) AS 주문건수,
  SUM(amount) AS 총매출,
  AVG(amount) AS 평균금액,
  MAX(amount) AS 최고금액,
  MIN(amount) AS 최저금액
FROM project_name.dataset_name.orders
WHERE
  amount IS NOT NULL

-- ═════════════════════════════════════════════════
-- 16. ▶️ **코드 실행하기 · 코드 셀 19 [C19]**
-- ═════════════════════════════════════════════════

-- [C19]
SELECT
  COUNT(*) AS 전체행수,
  COUNT(amount) AS 금액있는행수
FROM project_name.dataset_name.orders

-- ═════════════════════════════════════════════════
-- 17. ⌨️ 백문이 불여일타 (7)
-- ═════════════════════════════════════════════════

-- [C20] ⌨️ 백문이 불여일타 (7) — 전체 고객 수 세기
SELECT
  COUNT(*) AS '총 고객 수'
FROM project_name.dataset_name.customers

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 18. ⌨️ 백문이 불여일타 (8)
-- ═════════════════════════════════════════════════

-- [C21] ⌨️ 백문이 불여일타 (8) — 최고가·최저가·평균가 한 번에
SELECT 
  MAX(price) AS '가장 비싼 가격',
  MIN(price) AS '가장 싼 가격',
  AVG(price) AS '평균 가격'
FROM project_name.dataset_name.products

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 19. ▶️ **코드 실행하기 · 코드 셀 22 [C22]**
-- ═════════════════════════════════════════════════

-- [C22]
SELECT
  status,
  COUNT(*) AS 건수,
  SUM(amount) AS 매출합
FROM project_name.dataset_name.orders
GROUP BY
  status
ORDER BY
  매출합 DESC

-- ═════════════════════════════════════════════════
-- 20. ▶️ **코드 실행하기 · 코드 셀 23 [C23]**
-- ═════════════════════════════════════════════════

-- [C23]
SELECT
  category,
  COUNT(*) AS 상품수,
  AVG(price) AS 평균가격
FROM project_name.dataset_name.products
GROUP BY
  category
ORDER BY
  평균가격 DESC

-- ═════════════════════════════════════════════════
-- 21. ▶️ **코드 실행하기 · 코드 셀 24 [C24]**
-- ═════════════════════════════════════════════════

-- [C24]
SELECT
  status,
  SUM(amount) AS 매출합
FROM project_name.dataset_name.orders
WHERE
  amount IS NOT NULL /* (행 단계) NULL 금액 제외 */
GROUP BY
  status
HAVING
  SUM(amount) >= 500000 /* (그룹 단계) 매출 50만 이상만 */
ORDER BY
  매출합 DESC

-- ═════════════════════════════════════════════════
-- 22. ⌨️ 백문이 불여일타 (9)
-- ═════════════════════════════════════════════════

-- [C25] ⌨️ 백문이 불여일타 (9) — 국가별 고객 수 집계와 정렬
SELECT 
  country,
  COUNT(*) AS 고객수
FROM project_name.dataset_name.customers
GROUP BY country
ORDER BY 고객수 DESC

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 23. ⌨️ 백문이 불여일타 (10)
-- ═════════════════════════════════════════════════

-- [C26] ⌨️ 백문이 불여일타 (10) — 고객별 총액 20만원 이상 조회
SELECT
  customer_id,
  SUM(amount) AS 총액
FROM project_name.dataset_name.orders
WHERE amount IS NOT NULL
GROUP BY customer_id
HAVING 총액 >= 200000
ORDER BY 총액 DESC
-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 24. ⌨️ 백문이 불여일타 (11)
-- ═════════════════════════════════════════════════

-- [C27] ⌨️ 백문이 불여일타 (11) — 카테고리별 상품 요약 리포트
SELECT
  category AS 카테고리명,
  COUNT(*) AS 상품수,
  AVG(price) AS 평균가격,
  MAX(price) AS 최고가격
FROM project_name.dataset_name.products
GROUP BY category
HAVING 상품수 >= 2
ORDER BY 평균가격 DESC

-- 여기에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 25. 📒 연습 문제 — 정렬·가공·집계 (10문항)
-- ═════════════════════════════════════════════════

-- [C28] 📒 연습 문제 — 정렬·가공·집계 (1/10)

-- 문제: orders를 amount 오름차순으로 정렬하고, order_id는 '주문번호', amount는 '가격'이라는 별칭으로 조회합니다.
SELECT
  order_id AS 주문번호,
  amount AS 가격
FROM project_name.dataset_name.orders
ORDER BY 가격 
-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 26. <details>
-- ═════════════════════════════════════════════════

-- [C29] 📒 연습 문제 — 정렬·가공·집계 (2/10)

-- 문제: orders의 status에서 중복을 제거하고, '상태'라는 별칭을 붙여 조회합니다.
SELECT DISTINCT
  status AS 상태
FROM project_name.dataset_name.orders

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 27. <details>
-- ═════════════════════════════════════════════════

-- [C30] 📒 연습 문제 — 정렬·가공·집계 (3/10)

-- 문제: customers에서 이름이 '김'으로 시작하는 고객을 조회합니다.
SELECT *
FROM project_name.dataset_name.customers
WHERE name LIKE '김%'
-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 28. <details>
-- ═════════════════════════════════════════════════

-- [C31] 📒 연습 문제 — 정렬·가공·집계 (4/10)

-- 문제: products에서 상품명에 '러너'가 포함된 상품을 조회합니다.
SELECT *
FROM project_name.dataset_name.products
WHERE product_name LIKE '%러너%'
-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 29. <details>
-- ═════════════════════════════════════════════════

-- [C32] 📒 연습 문제 — 정렬·가공·집계 (5/10)

-- 문제: orders에서 amount 200,000원을 기준으로 '고액'/'일반'을 나눈 열(등급)을 함께 조회합니다. (amount가 NULL이면
--       '미확정')
SELECT
  order_id,
  amount,
  CASE WHEN amount IS NULL THEN '미확정' WHEN amount >= 200000 THEN '고액' ELSE '일반' END AS 등급
FROM project_name.dataset_name.orders


-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 30. <details>
-- ═════════════════════════════════════════════════

-- [C33] 📒 연습 문제 — 정렬·가공·집계 (6/10)
--date_trunc('month', d)
-- 문제: orders에서 order_date의 '연도'만 뽑아 order_id·order_date와 함께 조회합니다.
SELECT
  order_id,
  order_date,
  EXTRACT(YEAR FROM order_date) AS 주문연도
FROM project_name.dataset_name.orders

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 31. <details>
-- ═════════════════════════════════════════════════

-- [C34] 📒 연습 문제 — 정렬·가공·집계 (7/10)

-- 문제: status별로 주문 건수와 amount 합계를 구합니다.
SELECT
  status,
  COUNT(*) AS 주문건수,
  SUM(amount) AS 총합계
FROM project_name.dataset_name.orders
GROUP BY status

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 32. <details>
-- ═════════════════════════════════════════════════

-- [C35] 📒 연습 문제 — 정렬·가공·집계 (8/10)

-- 문제: status별 amount 합계가 500,000원 이상인 상태만 남기고, 합계가 큰 순으로 정렬합니다.
SELECT
  status,
  COUNT(*) AS 주문건수,
  SUM(amount) AS 매출합계
FROM project_name.dataset_name.orders
GROUP BY status
HAVING 매출합계 >= 500000
ORDER BY 매출합계 DESC

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 33. <details>
-- ═════════════════════════════════════════════════

-- [C36] 📒 연습 문제 — 정렬·가공·집계 (9/10)

-- 문제: orders에서 금액이 가장 큰 주문 3건만 조회합니다. (정렬 + 개수 제한)
SELECT order_id, amount
FROM project_name.dataset_name.orders
ORDER BY amount DESC NULLS LAST
LIMIT 3
-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 34. <details>
-- ═════════════════════════════════════════════════

-- [C37] 📒 연습 문제 — 정렬·가공·집계 (10/10)

-- 문제: orders의 전체 주문 건수와 '금액이 있는' 주문 건수를 한 줄에 함께 구합니다.
SELECT
  COUNT(*) AS 주문건수,
  COUNT(amount) AS '금액이 있는 주문 건수'
FROM project_name.dataset_name.orders



-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 35. 🧪 종합 실습 — 카테고리·상태별 매출 요약
-- ═════════════════════════════════════════════════

-- [C38] 🧪 종합 실습 — 카테고리·상태별 매출 요약 (1/3)
SELECT 
  date_trunc('month', order_date) AS 월,
  COUNT(*) AS 주문건수,
  SUM(amount) AS 매출합계
FROM project_name.dataset_name.orders
WHERE amount IS NOT NULL
GROUP BY 월
ORDER BY 월 NULLS LAST

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 36. **질문 2.** 위 월별 매출을 그래프로 그려, 추이를 한눈에 봅니다.
-- ═════════════════════════════════════════════════

-- [C39] 🧪 종합 실습 — 카테고리·상태별 매출 요약 (2/3)

SELECT
  date_trunc('month', order_date) /* BigQuery: DATE_TRUNC(order_date, MONTH) */ AS month,
  SUM(amount) AS revenue
FROM project_name.dataset_name.orders
WHERE
  amount IS NOT NULL
GROUP BY
  month
ORDER BY
  month NULLS LAST

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 37. **질문 3.** 고객 등급별로 몇 명인지, 그리고 가장 많은 등급이 무엇인지 확인합니다.
-- ═════════════════════════════════════════════════

-- [C40] 🧪 종합 실습 — 카테고리·상태별 매출 요약 (3/3)
SELECT
  grade,
  COUNT(*) AS 고객수, 
FROM project_name.dataset_name.customers
GROUP BY grade
ORDER BY 고객수 DESC

-- 아래에 SQL 쿼리를 작성하세요.

-- ═════════════════════════════════════════════════
-- 38. 코드 퀴즈
-- ═════════════════════════════════════════════════

-- [C41] 코드 퀴즈 — 상태별 평균 주문 금액
SELECT
  status,
  AVG(amount) AS 평균주문금액
FROM project_name.dataset_name.orders
WHERE amount IS NOT NULL
GROUP BY status
ORDER BY 평균주문금액 DESC
-- 여기에 SQL 쿼리를 작성하세요.
