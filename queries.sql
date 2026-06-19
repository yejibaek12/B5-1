# ==========================================
# 1. 기본 조회 4개 (WHERE, ORDER BY, LIMIT)
# ==========================================

# Q1. 가격이 20,000원 이상인 도서 목록을 가격 높은 순으로 조회
SELECT * FROM book WHERE price >= 20000 ORDER BY price DESC;

# Q2. 성이 '김'씨인 회원 정보 검색
SELECT * FROM member WHERE name LIKE '김%';

# Q3. 가장 최근에 가입한 회원 3명 조회
# (특정 DB 문법 설명: LIMIT 구문은 MySQL, PostgreSQL 등에서 지원하는 조회 제한 문법이며, Oracle의 ROWNUM 또는 SQL Server의 TOP에 대응됩니다.)
SELECT * FROM member ORDER BY created_at DESC LIMIT 3;

# Q4. 아직 반납되지 않고 대여 중인 기록만 대여일 순으로 조회
SELECT * FROM rental WHERE returned_at IS NULL ORDER BY rented_at ASC;


# ==========================================
# 2. 조인 4개 (INNER JOIN 2개, LEFT JOIN 1개 포함)
# ==========================================

# Q5. 현재 대여 중인 책의 제목과 대여한 회원의 이름을 함께 조회 (INNER JOIN 1)
SELECT m.name AS 회원명, b.title AS 도서명, r.rented_at AS 대여일
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id
WHERE r.returned_at IS NULL;

# Q6. 도서별 제목과 해당 도서의 카테고리명을 매칭하여 조회 (INNER JOIN 2)
SELECT b.id, b.title, c.name AS 카테고리명
FROM book b
INNER JOIN category c ON b.category_id = c.id;

# Q7. 전체 회원 리스트와 각각의 총 대여 횟수 조회 (대여 기록이 없는 회원도 포함 - LEFT JOIN)
SELECT m.id, m.name, COUNT(r.id) AS 총_대여_횟수
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name;

# Q8. 'IT/컴퓨터' 카테고리에 속한 도서들만 조인하여 조회
SELECT b.title, b.author, c.name
FROM book b
INNER JOIN category c ON b.category_id = c.id
WHERE c.name = 'IT/컴퓨터';


# ==========================================
# 3. 집계 4개 (COUNT, SUM, AVG 중 2개 이상 + GROUP BY)
# ==========================================

# Q9. 카테고리별 등록된 도서 수량과 평균 가격 집계
SELECT category_id, COUNT(id) AS 도서_수량, AVG(price) AS 평균_가격
FROM book
GROUP BY category_id;

# Q10. 회원별로 반납 완료된 총 대여 횟수 집계
SELECT member_id, COUNT(id) AS 반납_완료_건수
FROM rental
WHERE returned_at IS NOT NULL
GROUP BY member_id;

# Q11. 누적 대여 건수가 2건 이상인 회원 ID 추출 (HAVING 활용)
SELECT member_id, COUNT(id) AS 대여_건수
FROM rental
GROUP BY member_id
HAVING COUNT(id) >= 2;

# Q12. 카테고리별 도서의 총 가격(SUM) 및 평균 가격(AVG) 조회 (SUM, AVG 활용)
SELECT c.name AS 카테고리명, SUM(b.price) AS 총_가격, AVG(b.price) AS 평균_가격
FROM book b
INNER JOIN category c ON b.category_id = c.id
GROUP BY c.name;


# ==========================================
# 4. 서브쿼리 2개
# ==========================================

# Q13. 대여 기록이 한 번도 없는 회원의 이름 조회 (NOT IN 서브쿼리)
SELECT name 
FROM member 
WHERE id NOT IN (SELECT DISTINCT member_id FROM rental);

# Q14. 전체 도서 평균 가격보다 비싼 도서 목록 조회 (비교 단일행 서브쿼리)
SELECT title, price 
FROM book 
WHERE price > (SELECT AVG(price) FROM book);


# ==========================================
# 5. 데이터 수정 및 삭제 2개 (UPDATE, DELETE)
# ==========================================

# Q15. 회원 ID 1번이 빌린 2번 도서에 대해 현재 시간으로 반납 처리 업데이트 (UPDATE)
UPDATE rental 
SET returned_at = CURRENT_TIMESTAMP 
WHERE member_id = 1 AND book_id = 2 AND returned_at IS NULL;

# Q16. 카테고리 ID가 없는 도서 데이터 일괄 삭제 (DELETE)
DELETE FROM book 
WHERE category_id IS NULL;


# ==========================================
# 6. 인덱스 1개 (CREATE INDEX + 적용 이유)
# ==========================================

# Q17. 대여일(rented_at) 기준 검색 및 정렬 성능 최적화를 위한 인덱스 생성
# 적용 이유: 기간별 대여 통계나 대여중인 항목을 필터링할 때 rented_at 컬럼이 WHERE 및 ORDER BY 절에 빈번하게 사용되므로 조회 속도를 높이기 위해 적용함.
CREATE INDEX idx_rental_rented_at ON rental(rented_at);