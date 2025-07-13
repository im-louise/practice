-- 03
-- 상 난이도

SELECT
	genres.genre_id,
	genres.name, -- 장르별
	ROW_NUMBER() OVER (ORDER BY SUM(tracks.track_id) DESC, artists.name ASC) AS 순위,
	artists.artist_id,
	artists.name AS 아티스트,
	SUM(tracks.track_id) AS track_count
FROM artists, tracks
JOIN genres ON tracks.genre_id = genres.genre_id
GROUP BY genres.name, track_id, artists.artist_id, genres.genre_id, genres.name
LIMIT 3;

-- 1. 월별 매출 및 전월 대비 증감률
-- 각 연월(YYYY-MM)별 총 매출과, 전월 대비 매출 증감률을 구하세요.
-- 결과는 연월 오름차순 정렬하세요.
SELECT
*
FROM
JOIN
WHERE
GROUP BY
ORDER BY
LIMIT;


-- 2. 장르별 상위 3개 아티스트 및 트랙 수
-- 각 장르별로 트랙 수가 가장 많은 상위 3명의 아티스트(artist_id, name, track_count)를 구하세요.
-- 동점일 경우 아티스트 이름 오름차순 정렬.
WITH track_count_number AS (
	SELECT
		g.genre_id,
        g.name AS genre_name,
        a.artist_id,
        a.name AS artist_name,
        COUNT(t.track_id) AS track_count
	FROM tracks t
	JOIN genres g ON t.genre_id = g.genre_id
    JOIN albums al ON t.album_id = al.album_id
    JOIN artists a ON al.artist_id = a.artist_id
	GROUP BY g.genre_id, g.name, a.artist_id, a.name
),
ranked_by_genre AS (
	SELECT
		genre_name AS 장르,
		artist_name AS 아티스트,
		track_count AS 트랙수,
		ROW_NUMBER() OVER(PARTITION BY genre_name ORDER BY track_count DESC, artist_name ASC) AS 순위
	FROM track_count_number
)
SELECT
	장르,
	순위,
	트랙수,
	아티스트
FROM ranked_by_genre
WHERE 순위 <= 3;



-- 3. 고객별 누적 구매액 및 등급 산출
-- 각 고객의 누적 구매액을 구하고,
-- 상위 20%는 'VIP', 하위 20%는 'Low', 나머지는 'Normal' 등급을 부여하세요.
SELECT
*
FROM
JOIN
WHERE
GROUP BY
ORDER BY
LIMIT;







-- 4. 국가별 재구매율(Repeat Rate)
-- 각 국가별로 전체 고객 수, 2회 이상 구매한 고객 수, 재구매율을 구하세요.
-- 결과는 재구매율 내림차순 정렬.
SELECT
*
FROM
JOIN
WHERE
GROUP BY
ORDER BY
LIMIT;







-- 5. 최근 1년간 월별 신규 고객 및 잔존 고객
-- 최근 1년(마지막 인보이스 기준 12개월) 동안,
-- 각 월별 신규 고객 수와 해당 월에 구매한 기존 고객 수를 구하세요.
SELECT
*
FROM
JOIN
WHERE
GROUP BY
ORDER BY
LIMIT;




