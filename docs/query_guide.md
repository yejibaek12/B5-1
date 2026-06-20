# 도서 대여 관리 시스템 - SQL 명령어 및 문법 가이드

본 문서는 프로젝트의 SQL 파일([schema.sql](../schema.sql), [insert.sql](../insert.sql), [queries.sql](../queries.sql))에서 사용된 주요 SQL 명령어들의 기본 개념, 문법 구조, 그리고 프로젝트 내 실제 사용 사례와 응용 예시를 정리한 **문법 및 사용법 가이드**입니다.

---

## 1. DDL (Data Definition Language - 데이터 정의어)
데이터베이스 객체(테이블, 인덱스 등)를 생성, 변경, 삭제할 때 사용하는 명령어입니다.

### 1.1. `DROP TABLE` (테이블 삭제)
* **개념**: 데이터베이스에서 기존에 존재하는 테이블과 그 안의 데이터를 영구적으로 완전히 삭제합니다.
* **기본 문법**:
  ```sql
  DROP TABLE [IF EXISTS] 테이블명;
  ```
  * `IF EXISTS`: 테이블이 존재하지 않을 때 발생하는 에러를 방지합니다.
* **프로젝트 내 사용 예시 ([schema.sql](../schema.sql))**:
  ```sql
  DROP TABLE IF EXISTS rental;
  DROP TABLE IF EXISTS book;
  DROP TABLE IF EXISTS member;
  DROP TABLE IF EXISTS category;
  ```
  > [!WARNING]
  > **삭제 순서의 중요성 (외래키 관계)**
  > 외래키(FK)로 연결된 관계에서 부모 테이블(`member`, `category`)을 자식 테이블(`rental`, `book`)보다 먼저 삭제하려고 하면 참조 무결성 제약조건 에러가 발생합니다. 따라서 자식 테이블인 `rental`과 `book`을 먼저 삭제한 후, 부모 테이블을 삭제해야 안전합니다.

---

### 1.2. `CREATE TABLE` (테이블 생성)
* **개념**: 새로운 테이블을 정의하고, 컬럼의 이름, 데이터 타입 및 제약조건을 설정합니다.
* **기본 문법**:
  ```sql
  CREATE TABLE 테이블명 (
      컬럼명 데이터타입 [제약조건],
      ...
      [CONSTRAINT 외래키명] FOREIGN KEY (컬럼명) REFERENCES 참조테이블(참조컬럼) [옵션]
  );
  ```
* **주요 제약조건 설명**:
  * `PRIMARY KEY (PK)`: 테이블의 각 행을 고유하게 식별합니다. 중복과 `NULL`을 허용하지 않습니다.
  * `AUTO_INCREMENT`: 데이터를 삽입할 때 자동으로 1씩 증가하는 숫자를 생성해 줍니다.
  * `NOT NULL`: 해당 컬럼에 빈 값(`NULL`)이 저장되는 것을 금지합니다.
  * `UNIQUE`: 중복된 값을 허용하지 않습니다.
  * `DEFAULT`: 값을 따로 입력하지 않았을 때 자동으로 적용되는 기본값을 지정합니다.
  * `FOREIGN KEY (FK)`: 다른 테이블의 기본키를 참조하여 테이블 간의 연결 고리를 만듭니다.
* **프로젝트 내 사용 예시 ([schema.sql](../schema.sql))**:
  ```sql
  CREATE TABLE book (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(150) NOT NULL,
      author VARCHAR(100),
      price INT NOT NULL,
      category_id INT,
      FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE SET NULL
  );
  ```
  * **ON DELETE SET NULL**: 부모 테이블(`category`)에서 데이터가 삭제되면, 해당 카테고리를 참조하던 책들의 `category_id`가 자동으로 `NULL`로 변경됩니다. (책 데이터 자체는 보존됨)
  * **ON DELETE CASCADE**: `rental` 테이블의 경우 회원이 탈퇴(`member` 삭제)하거나 책 정보가 아예 삭제되면 해당 대여 기록도 함께 연쇄 삭제되도록 `ON DELETE CASCADE`를 사용했습니다.

---

### 1.3. `CREATE INDEX` (인덱스 생성)
* **개념**: 테이블의 특정 컬럼에 색인을 생성하여 검색(`SELECT WHERE`) 및 정렬(`ORDER BY`) 속도를 획기적으로 빠르게 만듭니다.
* **기본 문법**:
  ```sql
  CREATE INDEX 인덱스명 ON 테이블명 (컬럼명);
  ```
* **프로젝트 내 사용 예시 ([schema.sql](../schema.sql) / [queries.sql](../queries.sql) Q17)**:
  ```sql
  CREATE INDEX idx_rental_rented_at ON rental(rented_at);
  ```
  * **적용 이유**: 미반납 도서 조회 및 대여 이력 조회 시 `rented_at` 컬럼에 대한 정렬 및 범위 검색이 많이 발생하므로 인덱스를 통해 성능을 높였습니다.

---

## 2. DML (Data Manipulation Language - 데이터 조작어)
테이블 내의 데이터를 조회, 삽입, 수정, 삭제하는 명령어입니다.

### 2.1. `INSERT INTO` (데이터 삽입)
* **개념**: 테이블에 새로운 행(데이터)을 추가합니다.
* **기본 문법**:
  ```sql
  INSERT INTO 테이블명 (컬럼1, 컬럼2, ...) VALUES (값1, 값2, ...);
  ```
  * 한 번에 여러 행을 추가할 때:
  ```sql
  INSERT INTO 테이블명 (컬럼1, 컬럼2) VALUES (값A1, 값A2), (값B1, 값B2), (값C1, 값C2);
  ```
* **프로젝트 내 사용 예시 ([insert.sql](../insert.sql))**:
  ```sql
  INSERT INTO member (email, name) VALUES 
  ('kim@example.com', '김철수'),
  ('lee@example.com', '이영희');
  ```
  * `id` 컬럼은 `AUTO_INCREMENT`로 지정되어 있어 자동으로 생성되므로, 데이터 삽입 대상 컬럼에서 제외하고 값을 기입했습니다.

---

### 2.2. `SELECT` (데이터 조회)
SQL에서 가장 많이 사용되며, 다양한 키워드를 사용해 원하는 조건에 따라 정제된 결과를 출력합니다.

#### A. 기본 조건 조회 (`WHERE`, `ORDER BY`, `LIMIT`)
* **`WHERE`**: 특정 조건을 만족하는 데이터만 걸러냅니다.
* **`ORDER BY`**: 특정 컬럼을 기준으로 데이터를 정렬합니다. (오름차순: `ASC`, 내림차순: `DESC`)
* **`LIMIT`**: 조회할 행의 최대 개수를 제한합니다.
* **프로젝트 예시 ([queries.sql](../queries.sql) Q1, Q3)**:
  ```sql
  -- 가격이 20,000원 이상인 도서를 가장 비싼 순으로 정렬
  SELECT * FROM book WHERE price >= 20000 ORDER BY price DESC;

  -- 가장 최근에 가입한 회원 3명만 출력
  SELECT * FROM member ORDER BY created_at DESC LIMIT 3;
  ```

> • **실행 결과**: [Q1 결과](../results/query_01_result.txt) | [Q3 결과](../results/query_03_result.txt)

#### B. 패턴 매칭 (`LIKE`)
* **개념**: 와일드카드 문자(`%`, `_`)를 사용하여 문자열의 일부가 일치하는 데이터를 검색합니다.
  * `%`: 0개 이상의 임의의 문자열 (예: `'김%'`은 '김'으로 시작하는 모든 글자)
  * `_`: 정확히 1개의 임의의 문자
* **프로젝트 예시 ([queries.sql](../queries.sql) Q2)**:
  ```sql
  -- 성이 '김'씨인 회원 검색
  SELECT * FROM member WHERE name LIKE '김%';
  ```

> • **실행 결과**: [Q2 결과](../results/query_02_result.txt)

#### C. 테이블 결합 (`JOIN`)
* **`INNER JOIN`**: 조인하는 두 테이블 양쪽 모두에 연관되는 매칭 데이터가 존재하는 행만 합쳐서 반환합니다.
* **`LEFT JOIN`**: 왼쪽 테이블의 모든 행을 유지하면서 오른쪽 테이블의 정보를 매칭시킵니다. 매칭 데이터가 없는 경우 오른쪽 테이블 영역은 `NULL`로 표시됩니다.
* **프로젝트 예시 ([queries.sql](../queries.sql) Q6, Q7)**:
  ```sql
  -- 책과 카테고리명을 매칭하여 조회 (INNER JOIN)
  SELECT b.title, c.name 
  FROM book b 
  INNER JOIN category c ON b.category_id = c.id;

  -- 회원별 대여 횟수 집계 (대여 이력이 없는 회원도 포함해야 하므로 LEFT JOIN 사용)
  SELECT m.name, COUNT(r.id) AS 대여횟수 
  FROM member m 
  LEFT JOIN rental r ON m.id = r.member_id 
  GROUP BY m.id, m.name;
  ```

> • **실행 결과**: [Q6 결과](../results/query_06_result.txt) | [Q7 결과](../results/query_07_result.txt)

> [!TIP]
> **JOIN과 GROUP BY의 핵심 차이점**
> * **`JOIN` (가로로 병합)**: 서로 다른 테이블들을 공통 컬럼 기준으로 **옆으로 이어 붙여** 정보를 확장합니다. (결과 데이터 행이 유지되거나 중복 매칭 시 늘어남)
> * **`GROUP BY` (세로로 압축)**: 가로로 펼쳐진 여러 행의 데이터를 특정 기준에 따라 **하나로 묶어 요약(COUNT, SUM, AVG 등)**합니다. (결과 행이 그룹당 1행으로 축소됨)


#### D. 집계 및 그룹화 (`GROUP BY`, `HAVING`)
* **`GROUP BY`**: 특정 컬럼을 기준으로 행들을 그룹으로 묶습니다.
* **`HAVING`**: `GROUP BY`로 그룹화된 결과에 집계 조건을 적용합니다. (※ `WHERE`는 그룹화 이전에 행 단위로 작동함)
* **집계 함수**: `COUNT()` (개수), `SUM()` (합계), `AVG()` (평균) 등
* **프로젝트 예시 ([queries.sql](../queries.sql) Q11, Q12)**:
  ```sql
  -- 누적 대여 건수가 2건 이상인 우수 회원 ID 추출 (HAVING 사용)
  SELECT member_id, COUNT(id) FROM rental GROUP BY member_id HAVING COUNT(id) >= 2;

  -- 카테고리명 기준 도서 총합 및 평균 가격 (SUM, AVG 사용)
  SELECT c.name, SUM(b.price), AVG(b.price) 
  FROM book b 
  INNER JOIN category c ON b.category_id = c.id 
  GROUP BY c.name;
  ```

> • **실행 결과**: [Q11 결과](../results/query_11_result.txt) | [Q12 결과](../results/query_12_result.txt)

> [!TIP]
> **WHERE와 HAVING의 핵심 차이점**
> * **`WHERE` (그룹화 전 필터링)**: 테이블 내 개별 행(Row) 단위로 조건에 맞춰 데이터를 걸러냅니다. 따라서 집계 함수(`COUNT`, `SUM`, `AVG` 등)를 조건식에 쓸 수 없습니다.
> * **`HAVING` (그룹화 후 필터링)**: `GROUP BY`로 묶인 결과 그룹들을 대상으로 조건을 걸어 필터링합니다. 주로 집계 함수가 포함된 조건을 다룰 때 사용합니다.


#### E. 서브쿼리 (Subquery)
* **개념**: 쿼리문 안에 포함된 또 다른 `SELECT` 문을 의미합니다.
* **프로젝트 예시 ([queries.sql](../queries.sql) Q13, Q14)**:
  ```sql
  -- 대여 기록이 없는 회원의 이름 조회 (NOT IN 서브쿼리)
  SELECT name FROM member 
  WHERE id NOT IN (SELECT DISTINCT member_id FROM rental);

  -- 평균 도서 가격보다 비싼 도서 조회 (비교 단일행 서브쿼리)
  SELECT title, price FROM book 
  WHERE price > (SELECT AVG(price) FROM book);
  ```

> • **실행 결과**: [Q13 결과](../results/query_13_result.txt) | [Q14 결과](../results/query_14_result.txt)

---

### 2.3. `UPDATE` (데이터 수정)
* **개념**: 테이블에 저장되어 있는 기존의 레코드 값을 변경합니다.
* **기본 문법**:
  ```sql
  UPDATE 테이블명 SET 컬럼1 = 변경할값1, 컬럼2 = 변경할값2, ... WHERE 조건;
  ```
  > [!CAUTION]
  > **WHERE 절 생략 주의**
  > `UPDATE` 문을 실행할 때 `WHERE` 절을 누락하거나 조건이 불명확하면 테이블의 **모든 행**의 데이터가 강제로 업데이트되는 치명적인 실수가 발생할 수 있습니다.
* **프로젝트 내 사용 예시 ([queries.sql](../queries.sql) Q15)**:
  ```sql
  UPDATE rental 
  SET returned_at = CURRENT_TIMESTAMP 
  WHERE member_id = 1 AND book_id = 2 AND returned_at IS NULL;
  ```

> • **실행 결과**: [Q15 결과](../results/query_15_result.txt)

---

### 2.4. `DELETE` (데이터 삭제)
* **개념**: 테이블에서 특정 행(데이터)을 제거합니다. (테이블 구조는 그대로 남음)
* **기본 문법**:
  ```sql
  DELETE FROM 테이블명 WHERE 조건;
  ```
* **프로젝트 내 사용 예시 ([queries.sql](../queries.sql) Q16)**:
  ```sql
  DELETE FROM book WHERE category_id IS NULL;
  ```

> • **실행 결과**: [Q16 결과](../results/query_16_result.txt)

---

## 3. 테이블 상태 제어 및 기타 명령어

### 3.1. `TRUNCATE TABLE` (테이블 비우기)
* **개념**: 테이블 내의 모든 행을 빠르게 통째로 지우고 인덱스와 일련번호(`AUTO_INCREMENT`)도 초기화합니다.
* **기본 문법**:
  ```sql
  TRUNCATE TABLE 테이블명;
  ```
* **`DELETE` vs `TRUNCATE` 비교**:
  * `DELETE`는 조건 설정이 가능하고 트랜잭션 롤백이 비교적 용이하나 속도가 느립니다.
  * `TRUNCATE`는 조건 없이 테이블 전체를 즉시 지우며 복구(Rollback)가 안 되지만 속도가 매우 빠릅니다.
* **프로젝트 내 사용 예시 ([insert.sql](../insert.sql))**:
  ```sql
  TRUNCATE TABLE rental;
  TRUNCATE TABLE book;
  ```

---

### 3.2. `SET FOREIGN_KEY_CHECKS` (외래키 제약조건 토글)
* **개념**: 일시적으로 외래키 제약조건 검사를 비활성화(`0`)하거나 다시 활성화(`1`)합니다.
* **프로젝트 내 사용 예시 ([insert.sql](../insert.sql))**:
  ```sql
  SET FOREIGN_KEY_CHECKS = 0;
  -- (테이블 TRUNCATE 및 데이터 재삽입 수행)
  SET FOREIGN_KEY_CHECKS = 1;
  ```
  * **목적**: 개발 및 테스트 과정에서 부모/자식 관계에 얽매이지 않고 안전하게 테이블을 비우고 신규 샘플 데이터를 삽입(Reset)할 때 주로 사용합니다.
