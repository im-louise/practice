-- p03.sql 연습문제 3번째

-- practice db 사용
USE practice;
-- 스키마 확인 & 데이터 확인
DESC userinfo;
SELECT * FROM userinfo;
-- userinfo email 컬럼 추가 40글자 제한, 중복 불가로
ALTER TABLE userinfo ADD COLUMN email VARCHAR(40) UNIQUE;
-- nickname 길이 제한 100자로 늘리기
ALTER TABLE userinfo MODIFY COLUMN nickname VARCHAR(100);
-- reg_date 컬럼 삭제
ALTER TABLE userinfo DROP COLUMN reg_date;
-- 실제 한명의 email 수정
UPDATE userinfo SET email='bbb@kakao.com' where id=2;
