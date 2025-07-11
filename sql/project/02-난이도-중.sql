-- 02
-- 중 난이도

-- 1. 직원별 담당 고객 수 집계
-- 각 직원(employee_id, first_name, last_name)이 담당하는 고객 수를 집계하세요.
-- 고객이 한 명도 없는 직원도 모두 포함하고, 고객 수 내림차순으로 정렬하세요.
SELECT
	employees.employee_id AS 직원별, -- 테이블명도 앞에 명시해줄것/두 테이블에 같은 컬럼명이 존재함
	employees.first_name AS 이름,
	employees.last_name AS 성,
	COUNT(customers.customer_id) AS 고객수
FROM employees
LEFT JOIN customers ON employees.employee_id = customers.support_rep_id -- 고객이 없는 직원도 포함이라 LEFT JOIN/support 같은 필드를 통해 고객이 어떤 직원을 담당자로 갖는지 나타낸다.
GROUP BY 직원별, 이름, 성
ORDER BY 고객수 DESC;

-- 2. 가장 많이 팔린 트랙 TOP 5
-- 판매량(구매된 수량)이 가장 많은 트랙 5개(track_id, name, 총 판매수량)를 출력하세요.
-- 동일 판매수량일 경우 트랙 이름 오름차순 정렬하세요.
SELECT
	tracks.track_id,
	tracks.name AS 이름,
	COUNT(invoice_items.track_id) AS 총판매수량
FROM tracks
JOIN invoice_items ON tracks.track_id = invoice_items.track_id
GROUP BY tracks.track_id, tracks.name -- name도 SELECT에 나오고 일부 DB에서는 GROUP BY에 같이 명시해야 함
ORDER BY 총판매수량 DESC, 이름 ASC -- 정렬 두 조건을 차례대로 쓰기
LIMIT 5;

-- 3. 2010년 이전에 가입한 고객 목록
-- 2010년 1월 1일 이전에 첫 인보이스를 발행한 고객의 customer_id, first_name, last_name, 첫구매일을 조회하세요.
SELECT
	customers.customer_id,
	customers.first_name AS 이름,
	customers.last_name AS 성,
	invoices.invoice_date AS 첫구매일
FROM customers
JOIN invoices ON customers.customer_id = invoices.customer_id
WHERE invoice_date <= '2010-01-01'
GROUP BY customers.customer_id, 첫구매일
ORDER BY 첫구매일;

-- 4. 국가별 총 매출 집계 (상위 10개 국가)
-- 국가(billing_country)별 총 매출을 집계해, 매출이 많은 상위 10개 국가의 국가명과 총 매출을 출력하세요.
SELECT
	billing_country,
	SUM(total) AS 총매출
FROM invoices
GROUP BY billing_country
ORDER BY 총매출 DESC
LIMIT 10;

-- 5. 각 고객의 최근 구매 내역
-- 각 고객별로 가장 최근 인보이스(invoice_id, invoice_date, total) 정보를 출력하세요.
SELECT customer_id, invoice_id, invoice_date, total
FROM(
	SELECT
		customer_id,
		invoice_id,
		invoice_date,
		total,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY invoice_date DESC) AS 최신인보이스
	FROM invoices
) t
WHERE 최신인보이스 = 1;

-- 아래는 2-5 강사님 정답 다른버전(서브쿼리 버전) / 결과값이 조금 다름

SELECT i.customer_id, i.invoice_id, i.invoice_date, i.total
FROM invoices i
WHERE i.invoice_date = (
    SELECT MAX(invoice_date)
    FROM invoices
    WHERE customer_id = i.customer_id
);


