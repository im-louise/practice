-- pg-06-cte.sql

-- CTE (Common Table Expression) -> 쿼리 속의 '이름이 있는' 임시 테이블
-- 가독성 : 복잡한 쿼리를 단계별로 나누어 이해하기 쉬움
-- 재사용 : 한 번 정의한 결과를 여러 번 사용 가능
-- 유지보수 : 각 단계별로 수정이 용이
-- 디버깅 : 단계별로 결과를 확인할 수 있음

-- 평균 주문 금액보다 큰 주문들의 고객 정보
SELECT c.customer_name, o.amount
FROM customer c
INNER JOIN orders o ON c.customer_id=o.customer_id
WHERE o.amount > (SELECT AVG(amount) FROM orders)
LIMIT 10;

-- 1단계 : 평균 주문 금액 계산
WITH avg_order AS (
	SELECT AVG(amount) as avg_amount
	FROM orders
)
-- 2단계 : 평균보다 큰 주문 찾기

SELECT c.customer_name, o.amount, ao.avg_amount
FROM customer c
JOIN orders o ON c.customer_id=o.customer_id
JOIN avg_orders ao ON o.amount > ao.avg_amount
LIMIT 10;


-- 요구사항(과제)
-- 1. 각 지역별 고객 수(DISTINCT customer_id)와 지역별 주문 수를 계산하세요
-- 2. 지역별 평균 주문 금액도 함께 표시하세요
-- 3. 고객 수가 많은 지역 순으로 정렬하세요
-- 힌트:
-- - 먼저 지역별 기본 통계를 CTE로 만들어보세요
-- - 그 다음 고객 수 기준으로 정렬하세요
-- -- 예상 결과
-- 지역    고객수   주문수   평균주문금액
-- 서울    143     7,234   567,890
-- 부산    141     6,987   534,123
-- 대구    140     6,876   545,678

WITH region_summary AS (
SELECT
	c.region AS 지역명,
	COUNT(DISTINCT c.customer_id) AS 고객수,
	COUNT(o.order_id) AS 주문수,
	COALESCE(AVG(o.amount), 0) AS 평균주문금액
FROM customer c
LEFT JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.region
)
SELECT
	지역명,
	고객수,
	주문수,
	ROUND(평균주문금액) AS 평균주문금액
FROM region_summary
ORDER BY 고객수 DESC


-- 아래는 ai 답변

WITH regional_stats AS (
  SELECT
    c.region
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(o.order_id) AS order_count,
    AVG(o.amount) AS avg_amount
  FROM customer c
  JOIN orders o ON c.customer_id = o.customer_id
  GROUP BY c.region
)
SELECT 
  region,
  customer_count,
  order_count,
  avg_amount
FROM regional_stats
ORDER BY customer_count DESC;



-- 요구사항(과제2)
-- 1. 각 상품의 총 판매량과 총 매출액을 계산하세요
-- 2. 상품 카테고리별로 그룹화하여 표시하세요
-- 3. 각 카테고리 내에서 매출액이 높은 순서로 정렬하세요
-- 4. 각 상품의 평균 주문 금액도 함께 표시하세요
-- :전구: 힌트:
-- - 먼저 상품별 판매 통계를 CTE로 만들어보세요
-- - products 테이블과 orders 테이블을 JOIN하세요
-- - 카테고리별로 정렬하되, 각 카테고리 내에서는 매출액 순으로 정렬하세요
-- ---
-- 카테고리      상품명           총판매량   총매출액      평균주문금액   주문건수   상품가격
-- 전자제품      스마트폰 123     450       125,678,900   279,286       450       567,890
-- 전자제품      노트북 456       298       98,234,500    329,644       298       1,234,567
-- 전자제품      태블릿 789       356       87,654,321    246,197       356       890,123
-- 컴퓨터        키보드 234       567       45,678,900    80,563        567       123,456
-- 컴퓨터        마우스 345       678       34,567,890    50,982        678       89,012
-- 액세서리      이어폰 456       234       23,456,789    100,243       234       234,567


WITH product_sales AS (
  SELECT
	p.category AS 카테고리,
    p.product_name AS 제품명,
    p.price AS 상품가격,
    SUM(o.quantity) AS 총판매량,
	SUM(o.amount) AS 총매출액,
	COUNT(o.order_id) AS 주문건수,
    AVG(o.amount) AS 평균주문금액
  FROM products p
  LEFT JOIN orders o ON p.product_id = o.product_id
  GROUP BY p.product_name, p.category, p.price
)
SELECT
  카테고리,
  제품명,
  총판매량,
  총매출액,
  ROUND(평균주문금액) AS 평균주문금액,
  주문건수,
  상품가격
FROM product_sales
ORDER BY 카테고리, 총매출액 DESC;


-- 아래는 ai 답변
WITH product_stats AS (
  SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS total_sales,
    AVG(o.amount) AS avg_order_amount
  FROM products p
  JOIN orders o ON p.product_id = o.product_id
  GROUP BY p.product_id, p.product_name, p.category, p.price
)

SELECT
  category,
  product_name,
  order_count AS 총판매량,
  total_sales AS 총매출액,
  avg_order_amount AS 평균주문금액,
  order_count AS 주문건수,
  price AS 상품가격
FROM product_stats
ORDER BY category, total_sales DESC;



-- 카테고리별 매출 비중 분석
WITH product_sales AS (
	SELECT
		p.category AS 카테고리,
		p.product_name AS 제품명,
		p.price AS 상품가격,
		SUM(o.quantity) AS 총판매량,
		SUM(o.amount) AS 제품총매출액,
		COUNT(o.order_id) AS 주문건수,
		AVG(o.amount) AS 평균주문금액
	FROM products p
	LEFT JOIN orders o ON p.product_id=o.product_id
	GROUP BY p.category, p.product_name, p.price
),
category_total AS (
	SELECT
		카테고리,
		SUM(제품총매출액) AS 카테고리총매출액
	FROM product_sales
	GROUP BY 카테고리
)
SELECT
	ps.카테고리,
	ps.제품명,
	ROUND(ps.제품총매출액 * 100 / ct.카테고리총매출액, 2) AS 카테고리매출비중
FROM product_sales ps
INNER JOIN category_total ct ON ps.카테고리=ct.카테고리
ORDER BY ps.카테고리, ps.제품총매출액 DESC;

-- 고객 구매금액에 따라 VIP(상위 20%) / 일반(전체평균보다 높음) / 신규로 나누어 등급통계를 보자.
-- [등급, 등급별 회원수, 등급별 구매액총합, 등급별 평균 주문수]

-- 1. 고객별 총 구매 금액 + 주문수
WITH customer_total AS (
	SELECT
		customer_id,
		SUM(amount) as 총구매액,
		COUNT(*) AS 총주문수
	FROM orders
	GROUP BY customer_id
),
-- 2. 구매 금액 기준 계산
purchase_threshold AS (
	SELECT
		AVG(총구매액) AS 일반기준,
		-- 상위 20% 기준값 구하기
		PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY 총구매액) AS vip기준
	FROM customer_total
),
	-- 상위 20% 자르기
	-- LIMIT 1 OFFSET(SELECT COUNT(*) * 0.2 FROM customer_total)
-- 3. 고객 등급 분류
customer_grade AS (
	SELECT
		ct.customer_id,
		ct.총구매액,
		ct.총주문수,
		CASE 
			WHEN ct.총구매액 >= pt.vip기준 THEN 'VIP'
			WHEN ct.총구매액 >= pt.일반기준 THEN '일반'
			ELSE '신규'
		END AS 등급
	FROM customer_total ct
	CROSS JOIN purchase_threshold pt
)
-- 4. 등급별 통계 출력
SELECT
	등급,
	COUNT(*) AS 등급별고객수,
	SUM(총구매액) AS 등급별총구매액,
	ROUND(AVG(총주문수), 2) AS 등급별평균주문수
FROM customer_grade
GROUP BY 등급
	






