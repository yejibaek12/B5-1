## 0. 기존 테이블 삭제 (외래키 제약조건 관계를 고려하여 자식 테이블부터 삭제)
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;

## 1. 카테고리 테이블 생성 (부모 테이블)
CREATE TABLE category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

## 2. 회원 테이블 생성 (부모 테이블)
CREATE TABLE member (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

## 3. 도서 테이블 생성 (category의 자식 테이블)
CREATE TABLE book (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100),
    price INT NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE SET NULL
);

## 4. 대여 기록 테이블 생성 (member, book의 자식 테이블)
CREATE TABLE rental (
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    rented_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    returned_at DATETIME NULL,
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

## 5. 인덱스 생성
## 적용 이유: 기간별 대여 통계나 대여중인 항목을 필터링할 때 rented_at 컬럼이 WHERE 및 ORDER BY 절에 빈번하게 사용되므로 조회 속도를 높이기 위해 적용함.
CREATE INDEX idx_rental_rented_at ON rental(rented_at);