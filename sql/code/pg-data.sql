-- pg06
-- 데이터
-- 삽입

-- 외래 키 제약 조건 때문에 순서대로 삭제
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
-- 고객 테이블 생성
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    region VARCHAR(50),
    registration_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);

-- 고객 데이터 삽입 (1,000명)
INSERT INTO customers (customer_id, customer_name, email, phone, region, registration_date, status)
SELECT 
    'CUST-' || LPAD(generate_series::text, 6, '0') as customer_id,
    '고객' || generate_series as customer_name,
    'customer' || generate_series || '@example.com' as email,
    '010-' || LPAD((random() * 9000 + 1000)::int::text, 4, '0') || '-' || LPAD((random() * 9000 + 1000)::int::text, 4, '0') as phone,
    (ARRAY['서울', '부산', '대구', '인천', '광주', '대전', '울산'])[floor(random() * 7) + 1] as region,
    '2023-01-01'::date + (random() * 365)::int as registration_date,
    CASE WHEN random() < 0.95 THEN 'active' ELSE 'inactive' END as status
FROM generate_series(1, 1000);

-- 상품 테이블 생성
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10, 2),
    stock_quantity INTEGER,
    supplier VARCHAR(100)
);

-- 상품 데이터 삽입 (500개)
INSERT INTO products (product_id, product_name, category, price, stock_quantity, supplier)
SELECT 
    'PROD-' || LPAD(generate_series::text, 5, '0') as product_id,
    (ARRAY['스마트폰', '노트북', '태블릿', '이어폰', '키보드', '마우스', '모니터', '스피커', '충전기', '케이블'])[floor(random() * 10) + 1] || ' ' || 
    (ARRAY['프리미엄', '스탠다드', '베이직', '프로', '울트라', '맥스'])[floor(random() * 6) + 1] || ' ' || generate_series as product_name,
    (ARRAY['전자제품', '컴퓨터', '액세서리', '모바일', '음향기기'])[floor(random() * 5) + 1] as category,
    (random() * 1900000 + 100000)::decimal(10,2) as price,
    (random() * 1000 + 10)::int as stock_quantity,
    '공급업체' || (floor(random() * 20) + 1)::text as supplier
FROM generate_series(1, 500);

-- 주문 테이블 생성
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    amount DECIMAL(12, 2),
    order_date DATE,
    status VARCHAR(20),
    region VARCHAR(50),
    payment_method VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 스마트 주문 데이터 생성 (50,000건)
WITH customer_weights AS (
    -- 고객별 주문 가중치 설정 (현실적 분포)
    SELECT 
        customer_id,
        region,
        CASE 
            WHEN random() < 0.05 THEN 50    -- 5% 고객: VIP (많은 주문)
            WHEN random() < 0.15 THEN 20    -- 10% 고객: 우수 고객
            WHEN random() < 0.40 THEN 8     -- 25% 고객: 일반 고객
            WHEN random() < 0.70 THEN 3     -- 30% 고객: 가끔 구매
            WHEN random() < 0.90 THEN 1     -- 20% 고객: 가끔 구매
            ELSE 0                          -- 10% 고객: 미구매
        END as weight
    FROM customers
),
product_weights AS (
    -- 상품별 인기도 설정 (파레토 법칙 적용)
    SELECT 
        product_id,
        category,
        price,
        CASE 
            WHEN random() < 0.15 THEN 30    -- 15% 상품: 인기 상품
            WHEN random() < 0.35 THEN 15    -- 20% 상품: 보통 인기
            WHEN random() < 0.65 THEN 8     -- 30% 상품: 평균적 판매
            WHEN random() < 0.85 THEN 3     -- 20% 상품: 저조한 판매
            ELSE 1                          -- 15% 상품: 거의 안 팔림
        END as popularity
    FROM products
),
expanded_customers AS (
    -- 가중치에 따라 고객 확장
    SELECT 
        customer_id,
        region,
        row_number() OVER () as seq
    FROM customer_weights
    CROSS JOIN generate_series(1, weight)
    WHERE weight > 0
),
expanded_products AS (
    -- 가중치에 따라 상품 확장
    SELECT 
        product_id,
        category,
        price,
        row_number() OVER () as seq
    FROM product_weights
    CROSS JOIN generate_series(1, popularity)
),
random_combinations AS (
    -- 랜덤 조합 생성
    SELECT 
        ec.customer_id,
        ec.region,
        ep.product_id,
        ep.category,
        ep.price,
        row_number() OVER () as order_seq
    FROM (
        SELECT *, row_number() OVER (ORDER BY random()) as rn
        FROM expanded_customers
    ) ec
    JOIN (
        SELECT *, row_number() OVER (ORDER BY random()) as rn  
        FROM expanded_products
    ) ep ON ec.rn = ep.rn
    LIMIT 50000
)
INSERT INTO orders (order_id, customer_id, product_id, quantity, unit_price, amount, order_date, status, region, payment_method)
SELECT 
    'ORDER-' || LPAD(order_seq::text, 8, '0') as order_id,
    customer_id,
    product_id,
    (floor(random() * 5) + 1)::int as quantity,
    price * (0.8 + random() * 0.4) as unit_price, -- 상품 가격의 80~120%
    0 as amount, -- 나중에 계산
    '2024-01-01'::date + (random() * 210)::int as order_date,
    (ARRAY['pending', 'processing', 'shipped', 'delivered', 'cancelled'])[floor(random() * 5) + 1] as status,
    region,
    (ARRAY['card', 'cash', 'transfer', 'mobile'])[floor(random() * 4) + 1] as payment_method
FROM random_combinations;

-- 주문 금액 계산
UPDATE orders SET amount = quantity * unit_price;

-- pg07
-- 데이터
-- 삽입

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id INTEGER REFERENCES employees(employee_id),
    department VARCHAR(50),
    position VARCHAR(50),
    salary DECIMAL(10),
    hire_date DATE,
    level INTEGER
);

-- 조직도 데이터 삽입 (4단계 계층)
INSERT INTO employees VALUES
-- CEO (1단계)
(1, 'CEO 김대표', NULL, '경영진', 'CEO', 150000000, '2020-01-01', 1),

-- 이사급 (2단계)
(2, '이사 박영업', 1, '영업본부', '이사', 120000000, '2020-03-01', 2),
(3, '이사 최개발', 1, '개발본부', '이사', 120000000, '2020-03-01', 2),
(4, '이사 정마케팅', 1, '마케팅본부', '이사', 110000000, '2020-04-01', 2),
(5, '이사 한인사', 1, '인사본부', '이사', 110000000, '2020-04-01', 2),

-- 부장급 (3단계)
(6, '부장 김영업1', 2, '영업1팀', '부장', 90000000, '2020-06-01', 3),
(7, '부장 이영업2', 2, '영업2팀', '부장', 90000000, '2020-06-01', 3),
(8, '부장 박프론트', 3, '프론트엔드팀', '부장', 95000000, '2020-07-01', 3),
(9, '부장 최백엔드', 3, '백엔드팀', '부장', 95000000, '2020-07-01', 3),
(10, '부장 정마케팅', 4, '마케팅팀', '부장', 85000000, '2020-08-01', 3),
(11, '부장 한인사', 5, '인사팀', '부장', 85000000, '2020-08-01', 3),

-- 팀장급 (4단계)
(12, '팀장 김영업A', 6, '영업1팀', '팀장', 70000000, '2021-01-01', 4),
(13, '팀장 이영업B', 6, '영업1팀', '팀장', 70000000, '2021-01-01', 4),
(14, '팀장 박영업C', 7, '영업2팀', '팀장', 70000000, '2021-01-01', 4),
(15, '팀장 최영업D', 7, '영업2팀', '팀장', 70000000, '2021-01-01', 4),
(16, '팀장 정프론트', 8, '프론트엔드팀', '팀장', 75000000, '2021-02-01', 4),
(17, '팀장 한백엔드', 9, '백엔드팀', '팀장', 75000000, '2021-02-01', 4),
(18, '팀장 김마케팅', 10, '마케팅팀', '팀장', 65000000, '2021-03-01', 4),
(19, '팀장 이인사', 11, '인사팀', '팀장', 65000000, '2021-03-01', 4),

-- 사원급 (5단계)
(20, '사원 박영업1', 12, '영업1팀', '사원', 45000000, '2021-06-01', 5),
(21, '사원 최영업2', 12, '영업1팀', '사원', 45000000, '2021-06-01', 5),
(22, '사원 김영업3', 13, '영업1팀', '사원', 45000000, '2021-06-01', 5),
(23, '사원 이영업4', 14, '영업2팀', '사원', 45000000, '2021-07-01', 5),
(24, '사원 정영업5', 15, '영업2팀', '사원', 45000000, '2021-07-01', 5),
(25, '사원 한프론트1', 16, '프론트엔드팀', '사원', 50000000, '2021-08-01', 5),
(26, '사원 박프론트2', 16, '프론트엔드팀', '사원', 50000000, '2021-08-01', 5),
(27, '사원 최백엔드1', 17, '백엔드팀', '사원', 50000000, '2021-09-01', 5),
(28, '사원 김백엔드2', 17, '백엔드팀', '사원', 50000000, '2021-09-01', 5),
(29, '사원 이마케팅', 18, '마케팅팀', '사원', 40000000, '2021-10-01', 5),
(30, '사원 정인사', 19, '인사팀', '사원', 40000000, '2021-10-01', 5);

