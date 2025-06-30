-- p01.sql 연습문제 1번째

-- 1. practice db 사용
-- userinfo 테이블 생성
	-- id PK, auto inc, int
    -- nickname : 글자 20까지, 필수입력
    -- phone 글자 11까지, 중복방지
    -- reg-date 날짜, 기본값(오늘 날짜)
    
-- 3. desc로 테이블 정보 확인

USE practice;

CREATE TABLE userinfo (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nickname VARCHAR(20) NOT NULL,
    phone VARCHAR(11) UNIQUE,
    reg_date DATE DEFAULT(CURRENT_DATE)
);
