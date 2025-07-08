-- 29-exists.sql

-- 전자제품을 구매(sales)한 고객 정보(customer)
SELECT
	customer_id,
    customer_name,
    customer_type
FROM customers
WHERE customer_id IN (
	SELECT customer_id FROM sales WHERE category='전자제품'
);
-- exists를 활용해서 위에꺼를 다시 쓰기/아래꺼는 데이터를 불러오는게 아니라서 빠른 시간에 실행됨/존재 여부 확인은 이 방법이 가장 빠름
SELECT
	customer_id,
    customer_name,
    customer_type
FROM customers c
WHERE EXISTS (
	SELECT 1 FROM sales s WHERE s.customer_id=c.customer_id AND s.category='전자제품'
);

-- EXISTS (~~한 적이 있는)
-- 전자제품과 의류를 모두 구매해 본적이 있고 동시에 50만원 이상 구매 이력도 가진 고객을 찾자.

SELECT
    customer_name,
    customer_type
FROM customers c
WHERE EXISTS (SELECT 1 FROM sales s1 WHERE s1.customer_id=c.customer_id AND s1.category='전자제품') -- 전자제품 산 사람..
	AND
WHERE EXISTS (SELECT 1 FROM sales s2 WHERE s2.customer_id=c.customer_id AND s2.category='의류')  -- 의류 산 사람..
    AND
WHERE EXISTS (SELECT 1 FROM sales s3 WHERE s3.customer_id=c.customer_id AND s3.total_amount >=500000) -- 50만원 이상
);

