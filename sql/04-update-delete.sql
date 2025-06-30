-- 04-update-delete.sql

SELECT * FROM members;
INSERT INTO members(name) VALUES ('익명');membersPRIMARY

-- update(데이터 수정)
UPDATE members SET name='xys' where id=1;
-- 원치 않는 케이스 (name 같다면 동시 수정)
UPDATE members SET email='lalala@kakao.com', name='xys' where id=1;

-- delete(데이터 삭제)
DELETE FROM members where id=1;
-- 테이블 모든 데이터 삭제(위험)
DELETE FROM members;