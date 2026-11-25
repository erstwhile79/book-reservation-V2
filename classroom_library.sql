-- ==========================================
-- 1. 책 목록 테이블 생성
-- ==========================================
CREATE TABLE public.books ( -- 책 목록 테이블 만들기
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- 책 고유 번호 자동 생성
    name TEXT NOT NULL UNIQUE -- 책 이름 필수 입력 및 중복 방지
); -- 책 목록 테이블 생성 완료

-- ==========================================
-- 2. 예약 테이블 생성
-- ==========================================
CREATE TABLE public.reservations ( -- 예약 테이블 만들기
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- 예약 고유 번호 자동 생성
    book_id BIGINT NOT NULL REFERENCES public.books(id) ON DELETE CASCADE, -- 책 삭제 시 해당 예약도 삭제
    reservation_date DATE NOT NULL DEFAULT CURRENT_DATE, -- 예약 날짜 저장
    duration INTEGER NOT NULL CHECK (duration > 0), -- 예약 기간 저장(일 단위, 1일 이상)
    student_name TEXT NOT NULL, -- 학생 식별용 별명 저장(실명 사용 지양)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), -- 예약 생성 시각 자동 저장
    CONSTRAINT unique_book_reservation UNIQUE (book_id) -- 같은 책의 중복 예약 방지
); -- 예약 테이블 생성 완료

-- ==========================================
-- 3. RLS(행 수준 보안) 활성화
-- ==========================================
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY; -- 책 목록 테이블 RLS 활성화
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY; -- 예약 테이블 RLS 활성화

-- ==========================================
-- 4. 사용자 접근 권한 설정
-- ==========================================
REVOKE ALL ON TABLE public.books FROM PUBLIC, anon, authenticated; -- 기존 책 목록 접근 권한 초기화
REVOKE ALL ON TABLE public.reservations FROM PUBLIC, anon, authenticated; -- 기존 예약 접근 권한 초기화
GRANT SELECT ON TABLE public.books TO anon; -- 비로그인 사용자에게 책 목록 조회만 허용
GRANT SELECT, INSERT, DELETE ON TABLE public.reservations TO anon; -- 비로그인 사용자에게 예약 조회, 추가, 삭제 허용

-- ==========================================
-- 5. 책 목록 RLS 정책 생성
-- ==========================================
CREATE POLICY "books_select" -- 책 목록 조회 정책 생성
ON public.books -- 책 목록 테이블에 적용
FOR SELECT -- 조회 작업만 허용
TO anon -- 비로그인 사용자 대상
USING (true); -- 모든 책 목록 조회 허용

-- ==========================================
-- 6. 예약 RLS 정책 생성
-- ==========================================
CREATE POLICY "reservations_select" -- 예약 조회 정책 생성
ON public.reservations -- 예약 테이블에 적용
FOR SELECT -- 조회 작업 허용
TO anon -- 비로그인 사용자 대상
USING (true); -- 모든 예약 내역 조회 허용

CREATE POLICY "reservations_insert" -- 예약 추가 정책 생성
ON public.reservations -- 예약 테이블에 적용
FOR INSERT -- 추가 작업 허용
TO anon -- 비로그인 사용자 대상
WITH CHECK (true); -- 새로운 예약 등록 허용

CREATE POLICY "reservations_delete" -- 예약 삭제 정책 생성
ON public.reservations -- 예약 테이블에 적용
FOR DELETE -- 삭제 작업 허용
TO anon -- 비로그인 사용자 대상
USING (true); -- 모든 예약 내역 삭제 허용

-- ==========================================
-- 7. 학급문고 책 목록 직접 입력
-- 아래 예시 책 이름을 실제 학급문고 책 이름으로 변경하세요.
-- ==========================================
INSERT INTO public.books (name) VALUES -- 책 이름 직접 입력하기
    ('강아지똥'), -- 첫 번째 책
    ('아낌없이 주는 나무'), -- 두 번째 책
    ('가만히 들어주었어'), -- 세 번째 책
    ('내 친구 샨티'), -- 네 번째 책
    ('목욕탕의 쭈그리'), -- 다섯 번째 책
    ('비벼 비벼 비빔밥'), -- 여섯 번째 책
    ('넌 어떻게 보이니?') -- 일곱 번째 책
ON CONFLICT (name) DO NOTHING; -- 이미 등록된 책은 중복 추가하지 않음

-- ==========================================
-- 사용 시 유의사항
-- 신규 테이블 생성용 SQL입니다. 기존 테이블이 있다면 그대로 재실행하지 마세요.
-- 추후 책 추가 시에는 7번 INSERT 구문만 수정하여 실행하세요.
-- 예약 기간이 지나도 예약은 자동으로 삭제되지 않습니다.
-- anon 사용자는 모든 예약을 조회하거나 삭제할 수 있습니다.
-- 학생 실명 대신 별명 또는 임의의 식별 코드를 사용하세요.
-- ==========================================
