-- 03-insert.sql

USE lecture;
DESC members;

-- 데이터 입력 (create)
INSERT INTO members (name, email) VALUES ('louise','louise.kakao.com');
INSERT INTO members (name, email) VALUES ('jenny','jenny.kakao.com');
-- 여러 줄로 데이터 입력 (col1,col2) > 순서 잘 맞추기!
INSERT INTO members (email, name) VALUES 
('noah.kakao.com','noah'),('april@kakao.com','april');

-- 데이터 전체 조회 (read)
SELECT * FROM members;
-- 단일 데이터 조회 ( *=모든 컬럼)
SELECT * FROM members where id=1;
