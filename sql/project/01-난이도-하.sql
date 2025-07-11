-- 01
-- 하 난이도


-- 1. 모든 고객 목록 조회
-- 고객의 customer_id, first_name, last_name, country를 조회하고, customer_id 오름차순으로 정렬하세요.
SELECT
	customer_id,
	first_name,
	last_name,
	country
FROM customers
ORDER BY customer_id;

-- 2. 모든 앨범과 해당 아티스트 이름 출력
-- 각 앨범의 title과 해당 아티스트의 name을 출력하고, 앨범 제목 기준 오름차순 정렬하세요.
SELECT
	albums.title,
	artists.name
FROM albums
JOIN artists ON albums.artist_id = artists.artist_id -- JOIN으로 각 테이블의 id가 일치함을 알려줄것.
ORDER BY albums.title;

-- 3. 트랙(곡)별 단가와 재생 시간 조회
-- tracks 테이블에서 각 곡의 name, unit_price, milliseconds를 조회하세요.
-- 5분(300,000 milliseconds) 이상인 곡만 출력하세요.
SELECT
	name AS 곡명,
	unit_price,
	milliseconds
FROM tracks
WHERE milliseconds >= 300000; -- ''를 쓰지 않아도 됨

-- 4. 국가별 고객 수 집계
-- 각 국가(country)별로 고객 수를 집계하고, 고객 수가 많은 순서대로 정렬하세요.
SELECT
	country AS 국가,
	COUNT(customer_id) AS 고객수 -- 강사님은 COUNT(*) AS customer_count 이렇게 쓰심
FROM customers
GROUP BY country
ORDER BY 고객수 DESC;

-- 5. 각 장르별 트랙 수 집계
-- 각 장르(genres.name)별로 트랙 수를 집계하고, 트랙 수 내림차순으로 정렬하세요.
SELECT
	genres.name AS 장르,
	COUNT(tracks.track_id) AS 트랙수
FROM genres
JOIN tracks ON genres.genre_id = tracks.genre_id
GROUP BY genres.name
ORDER BY 트랙수 DESC;


