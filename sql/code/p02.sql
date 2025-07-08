-- p02.sql 연습문제 2번째

-- practice db 이동
-- userinfo 테이블에
-- 데이터 5건 넣기 (별명,핸드폰 등) > 별명에 bob 포함  *C
-- 전체 조회(중간에 실행해주면서 모니터링)  *R
-- id가 3인 사람 조회 *R
-- 별명이 bob인 사람 조회  *R
-- 별명이 bob인 사람 핸드폰 번호 01099998888로 수정 (id로 수정하기) *U
-- 별명이 bob인 사람 삭제  *D

USE practice;

DESC userinfo;

INSERT INTO userinfo (nickname, phone) VALUES 
('aaa','01000000001'),('bbb','01000000002'),('ccc','01000000003'),('ddd','01000000004'),('eee','01000000005');

SELECT * FROM userinfo;

SELECT * FROM userinfo where id=3;

UPDATE userinfo SET nickname='bob',phone='01099998888' where id=1;

DELETE FROM userinfo where id=1;