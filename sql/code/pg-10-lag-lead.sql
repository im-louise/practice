-- pg-10-lag-lead.sql

-- 매일 체중 기록
-- LAG() - 이전 값을 가져온다.ABORT
-- 매달 매출을 확인
-- 위 테이블에 증감률 컬럼 추가

-- 전월 대비 매출 분석

WITH monthly_sales AS (
	SELECT
		DATE_TRUNC('month', order_date) AS 월,
		SUM(amount) as 월매출
	FROM orders
	GROUP BY 월
),
compare_before AS (
	SELECT
		TO_CHAR(월, 'YYYY-MM') as 년월,
		월매출,
		LAG(월매출, 1) OVER(ORDER BY 월) AS 전월매출,
		월매출 - LAG(월매출, 1) OVER(ORDER BY 월) AS 증감액,
		CASE
			WHEN LAG(월매출, 1) OVER(ORDER BY 월) IS NULL THEN NULL
			ELSE ROUND(
				(월매출 - LAG(월매출, 1) OVER(ORDER BY 월)) * 100 -- 매출변동
				/
				LAG(월매출, 1) OVER(ORDER BY 월)  -- 저번달
			, 2)::TEXT || '%'
		END AS 증감률
	FROM monthly_sales
)
ORDER BY 월;

--
-- 아래는 깔끔 간략하게 수정한 버전
--

WITH monthly_sales AS (
	SELECT
		DATE_TRUNC('month', order_date) AS 월,
		SUM(amount) as 월매출
	FROM orders
	GROUP BY 월
),
compare_before AS (
	SELECT
		TO_CHAR(월, 'YYYY-MM') as 년월,
		월매출,
		LAG(월매출, 1) OVER(ORDER BY 월) AS 전월매출
	FROM monthly_sales
)
SELECT
	*,
	월매출 - 전월매출 AS 증감액,
	CASE
			WHEN 전월매출 IS NULL THEN NULL
			ELSE ROUND((월매출 - 전월매출) * 100 / 전월매출, 2)::TEXT || '%'
	END AS 증감률
FROM compare_before
ORDER BY 년월;


-- 고객별 다음 구매를 예측?
-- [고객ID, 주문일, 구매액,
-- 다음구매일, 구매간격(일수), 다음구매액수, 구매금액차이]
-- order by customer_id, order_date LIMIT 10;

SELECT
  customer_id,
  order_date AS 주문일,
  amount AS 구매액,
  LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일,
  LEAD(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매금액
FROM orders
WHERE customer_id='CUST-000001' -- 특정 고객의 주문 목록을 볼때
ORDER BY customer_id, order_date
LIMIT 10;


-- 아래는
-- AI
-- 답변

SELECT
  customer_id,
  order_date AS 주문일,
  amount AS 구매액,
  LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일,
  CASE
    WHEN LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) IS NULL THEN NULL
    ELSE
      DATE_PART('day', LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) - order_date)
  END AS 구매간격,
  LEAD(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매액수,
  CASE
    WHEN LEAD(amount) OVER (PARTITION BY customer_id ORDER BY order_date) IS NULL THEN NULL
    ELSE
      LEAD(amount) OVER (PARTITION BY customer_id ORDER BY order_date) - amount
  END AS 구매금액차이
FROM orders
ORDER BY customer_id, order_date
LIMIT 10;


-- [고객ID, 주문일, 금액, 구매순서(ROW_NUMBER)]
-- 이전구매간격, 다음구매간격
-- 금액변화=(이번-저번), 금액변화율
-- 누적 구매 금액(SUM OVER)
-- [추가]누적 평균 구매 금액(AVG OVER)

WITH customer_orders AS (
	SELECT
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS 구매순서,
	  customer_id,
	  amount,
	  LAG(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 이전구매금액,
	  LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 이전구매일,
	  order_date,
	  LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일
	FROM orders
)
SELECT
	customer_id,
	order_date,
	amount,
	구매순서,
	-- 구매간격
	order_date - 이전구매일 AS 이전구매간격,
	다음구매일 - order_date AS 다음구매간격,
	-- 구매금액변화
	amount - 이전구매금액 AS 금액변화,
	CASE
		WHEN 이전구매금액 IS NULL THEN NULL
		ELSE ROUND((amount - 이전구매금액) * 100 / 이전구매금액, 2)::TEXT || '%'
	END AS 금액변화율,
	-- 누적금액통계
	SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS 누적구매금액,
	AVG(amount) OVER(
		PARTITION BY customer_id
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- ROWS(행들) / UNBOUNDED PRECEDING(앞에 있는거 전체) / CURRENT ROW(현재,나부터)
		-- 현재 확인중인 ROW부터 맨 앞까지
	) AS 평균구매금액,
	-- 고객 구매 단계 분류
	CASE
		WHEN 구매순서 = 1 THEN '첫구매'
		WHEN 구매순서 <= 3 THEN '신규고객'
		WHEN 구매순서 <= 10 THEN '일반고객'
		ELSE 'VIP'
	END AS 고객단계
FROM customer_orders
ORDER BY customer_id, order_date;


