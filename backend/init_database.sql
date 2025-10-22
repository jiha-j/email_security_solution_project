-- ====================================================================
-- 이메일 보안 모니터링 시스템 - 데이터베이스 초기화 스크립트
-- ====================================================================
-- MSSQL Server용 초기 세팅 SQL
-- 실행 방법: SQL Server Management Studio에서 실행 또는
--           sqlcmd -S localhost -U sa -P 1234 -i init_database.sql
-- ====================================================================

-- 1. 데이터베이스 생성
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'EmailSecurityDB')
BEGIN
    ALTER DATABASE EmailSecurityDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EmailSecurityDB;
END
GO

CREATE DATABASE EmailSecurityDB;
GO

USE EmailSecurityDB;
GO

-- 2. 테이블 생성
IF OBJECT_ID('security_issues', 'U') IS NOT NULL
    DROP TABLE security_issues;
GO

CREATE TABLE security_issues (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(1000),
    category NVARCHAR(100) NOT NULL,
    type NVARCHAR(20) NOT NULL,
    status NVARCHAR(20) NOT NULL,
    severity NVARCHAR(20) NOT NULL,
    detected_date DATETIME2 NOT NULL,
    resolved_date DATETIME2,
    affected_emails INT,
    source_ip NVARCHAR(50),
    target_email NVARCHAR(200),
    CONSTRAINT CHK_Type CHECK (type IN ('INBOUND', 'OUTBOUND')),
    CONSTRAINT CHK_Status CHECK (status IN ('PENDING', 'REVIEW', 'RESOLVED', 'CRITICAL')),
    CONSTRAINT CHK_Severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);
GO

-- 인덱스 생성
CREATE INDEX IDX_SecurityIssue_Status ON security_issues(status);
CREATE INDEX IDX_SecurityIssue_Type ON security_issues(type);
CREATE INDEX IDX_SecurityIssue_Severity ON security_issues(severity);
CREATE INDEX IDX_SecurityIssue_DetectedDate ON security_issues(detected_date DESC);
GO

-- Users 테이블 생성
IF OBJECT_ID('users', 'U') IS NOT NULL
    DROP TABLE users;
GO

CREATE TABLE users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    role NVARCHAR(20) NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT CHK_Role CHECK (role IN ('ROLE_USER', 'ROLE_MANAGER', 'ROLE_ADMIN'))
);
GO

-- Users 인덱스 생성
CREATE INDEX IDX_Users_Username ON users(username);
CREATE INDEX IDX_Users_Email ON users(email);
GO

-- 3. 샘플 데이터 삽입
PRINT '샘플 데이터 삽입 시작...';

-- 사용자 데이터 삽입
-- 비밀번호: admin123, manager123, user123 (BCrypt 해시값)
PRINT '사용자 계정 생성 중...';

INSERT INTO users (username, password, email, role, created_at, updated_at) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@company.com', 'ROLE_ADMIN', GETDATE(), GETDATE()),
('manager', '$2a$10$YJKPmWLOickgx2ZMRZoMyeLbR3qj8NsHLK0d1fLb2HSM6LJZdL17lh', 'manager@company.com', 'ROLE_MANAGER', GETDATE(), GETDATE()),
('user', '$2a$10$xn3LI/AJqicNat2R6zgx5.ExvZrLI5e5mHnTWZLdL17lhWyAV9uRG', 'user@company.com', 'ROLE_USER', GETDATE(), GETDATE());

PRINT '사용자 계정 생성 완료';
GO

-- 수신메일 이슈 (INBOUND)
INSERT INTO security_issues (
    title, description, category, type, status, severity,
    detected_date, resolved_date, affected_emails, source_ip, target_email
) VALUES
(
    N'대량 스팸 메일 탐지 (1,250건)',
    N'단일 IP에서 1시간 내 1,250건의 스팸 메일 발송 탐지',
    N'대량 스팸 메일 공격',
    'INBOUND',
    'CRITICAL',
    'CRITICAL',
    DATEADD(HOUR, -2, GETDATE()),
    NULL,
    1250,
    '203.142.78.91',
    'admin@company.com'
),
(
    N'피싱 사이트 링크 포함 메일',
    N'은행 사칭 피싱 사이트로 유도하는 링크 발견',
    N'개인정보 탈취 피싱 사이트 공격',
    'INBOUND',
    'PENDING',
    'HIGH',
    DATEADD(HOUR, -5, GETDATE()),
    NULL,
    15,
    '185.220.101.45',
    'hr@company.com'
),
(
    N'의심스러운 첨부파일 탐지',
    N'ransomware.exe 파일이 첨부된 메일 차단',
    N'바이러스, 랜섬웨어 등 악성코드 공격',
    'INBOUND',
    'CRITICAL',
    'CRITICAL',
    DATEADD(HOUR, -1, GETDATE()),
    NULL,
    3,
    '91.203.45.122',
    'finance@company.com'
),
(
    N'헤더 위변조 메일 탐지',
    N'CEO 이메일을 사칭한 송금 요청 메일',
    N'헤더 위·변조 및 유사 도메인 사칭 메일',
    'INBOUND',
    'REVIEW',
    'HIGH',
    DATEADD(HOUR, -8, GETDATE()),
    NULL,
    8,
    '172.104.88.29',
    'accounting@company.com'
),
(
    N'불법 릴레이 서버 사용 탐지',
    N'외부 서버를 통한 스팸 메일 발송 시도',
    N'불법 릴레이 서버 사용',
    'INBOUND',
    'PENDING',
    'MEDIUM',
    DATEADD(HOUR, -12, GETDATE()),
    NULL,
    45,
    '198.51.100.42',
    'mail-relay@company.com'
);

-- 발신메일 이슈 (OUTBOUND)
INSERT INTO security_issues (
    title, description, category, type, status, severity,
    detected_date, resolved_date, affected_emails, source_ip, target_email
) VALUES
(
    N'고객 정보 포함 메일 외부 발송',
    N'개인정보 500건이 포함된 엑셀 파일 외부 전송',
    N'기업 내부 정보 유출 및 오발송 사고',
    'OUTBOUND',
    'CRITICAL',
    'CRITICAL',
    DATEADD(HOUR, -3, GETDATE()),
    NULL,
    500,
    '192.168.1.105',
    'external-partner@gmail.com'
),
(
    N'바이러스 URL 공유 탐지',
    N'악성 URL이 포함된 메일 발송 차단',
    N'바이러스 URL 공유',
    'OUTBOUND',
    'REVIEW',
    'HIGH',
    DATEADD(HOUR, -6, GETDATE()),
    NULL,
    12,
    '192.168.1.87',
    'client@external.com'
),
(
    N'악성 메일 회신 탐지',
    N'피싱 메일에 대한 직원의 회신 차단',
    N'악성 메일 회신',
    'OUTBOUND',
    'RESOLVED',
    'MEDIUM',
    DATEADD(HOUR, -24, GETDATE()),
    DATEADD(HOUR, -20, GETDATE()),
    1,
    '192.168.1.54',
    'phishing@fake-bank.com'
),
(
    N'대용량 파일 무단 발송',
    N'500MB 파일을 승인 없이 외부로 발송',
    N'대용량 파일 사후관리 문제',
    'OUTBOUND',
    'PENDING',
    'LOW',
    DATEADD(HOUR, -10, GETDATE()),
    NULL,
    1,
    '192.168.1.92',
    'storage@external.com'
),
(
    N'망분리 환경 파일 전송 시도',
    N'내부망에서 외부망으로 첨부파일 전송 시도 탐지',
    N'망분리 환경에서 대용량 첨부파일 발송 문제',
    'OUTBOUND',
    'REVIEW',
    'MEDIUM',
    DATEADD(HOUR, -15, GETDATE()),
    NULL,
    1,
    '10.0.0.55',
    'external@partner.com'
);

-- 추가 수신메일 이슈
INSERT INTO security_issues (
    title, description, category, type, status, severity,
    detected_date, resolved_date, affected_emails, source_ip, target_email
) VALUES
(
    N'악성 매크로 포함 엑셀 파일 탐지',
    N'매크로 자동 실행 시 원격 서버 접속 시도하는 악성 파일 차단',
    N'바이러스, 랜섬웨어 등 악성코드 공격',
    'INBOUND',
    'REVIEW',
    'HIGH',
    DATEADD(HOUR, -4, GETDATE()),
    NULL,
    7,
    '104.28.16.238',
    'sales@company.com'
);

-- 추가 발신메일 이슈
INSERT INTO security_issues (
    title, description, category, type, status, severity,
    detected_date, resolved_date, affected_emails, source_ip, target_email
) VALUES
(
    N'승인되지 않은 대량 메일 발송 탐지',
    N'마케팅 승인 없이 2,300건의 광고 메일 발송 시도',
    N'악성 메일 회신',
    'OUTBOUND',
    'PENDING',
    'MEDIUM',
    DATEADD(HOUR, -7, GETDATE()),
    NULL,
    2300,
    '192.168.1.78',
    'multiple-recipients@various.com'
);

-- 추가 수신메일 이슈 (심각 + 대기)
INSERT INTO security_issues (
    title, description, category, type, status, severity,
    detected_date, resolved_date, affected_emails, source_ip, target_email
) VALUES
(
    N'제로데이 취약점 공격 시도 탐지',
    N'Exchange Server 제로데이 취약점을 이용한 원격 코드 실행 시도',
    N'바이러스, 랜섬웨어 등 악성코드 공격',
    'INBOUND',
    'PENDING',
    'CRITICAL',
    DATEADD(HOUR, -1, GETDATE()),
    NULL,
    25,
    '47.89.153.201',
    'mailserver@company.com'
);

-- 추가 수신메일 이슈 (보통 + 대기)
INSERT INTO security_issues (
    title, description, category, type, status, severity,
    detected_date, resolved_date, affected_emails, source_ip, target_email
) VALUES
(
    N'의심스러운 압축파일 첨부 메일',
    N'password-protected ZIP 파일 내부에 .scr 실행파일 포함',
    N'바이러스, 랜섬웨어 등 악성코드 공격',
    'INBOUND',
    'PENDING',
    'MEDIUM',
    DATEADD(HOUR, -9, GETDATE()),
    NULL,
    18,
    '213.174.92.66',
    'support@company.com'
);

GO

-- 4. 데이터 확인
PRINT '=== 데이터베이스 초기화 완료 ===';
PRINT '';
PRINT '생성된 테이블:';
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
PRINT '';
PRINT '생성된 사용자:';
SELECT
    COUNT(*) AS [총 사용자 수],
    SUM(CASE WHEN role = 'ROLE_ADMIN' THEN 1 ELSE 0 END) AS [관리자],
    SUM(CASE WHEN role = 'ROLE_MANAGER' THEN 1 ELSE 0 END) AS [매니저],
    SUM(CASE WHEN role = 'ROLE_USER' THEN 1 ELSE 0 END) AS [일반 사용자]
FROM users;
PRINT '';
PRINT '사용자 목록 (테스트용 계정):';
SELECT username, email, role FROM users;
PRINT '';
PRINT '삽입된 보안 이슈 데이터 수:';
SELECT
    COUNT(*) AS [총 이슈 수],
    SUM(CASE WHEN type = 'INBOUND' THEN 1 ELSE 0 END) AS [수신메일 이슈],
    SUM(CASE WHEN type = 'OUTBOUND' THEN 1 ELSE 0 END) AS [발신메일 이슈],
    SUM(CASE WHEN status = 'CRITICAL' THEN 1 ELSE 0 END) AS [긴급 이슈],
    SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS [대기 이슈],
    SUM(CASE WHEN status = 'REVIEW' THEN 1 ELSE 0 END) AS [검토중 이슈],
    SUM(CASE WHEN status = 'RESOLVED' THEN 1 ELSE 0 END) AS [해결 이슈]
FROM security_issues;
PRINT '';
PRINT '샘플 데이터 목록:';
SELECT
    id,
    title,
    type,
    status,
    severity,
    affected_emails AS [영향 이메일 수]
FROM security_issues
ORDER BY severity DESC, detected_date DESC;

PRINT '';
PRINT '=== 초기화 성공! ===';
PRINT '이제 Spring Boot 애플리케이션을 실행하세요.';
GO

-- ====================================================================
-- 생성된 테스트 사용자 계정 (총 3명)
-- ====================================================================
/*
👤 테스트 계정 정보
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 관리자 계정 (ROLE_ADMIN)
   - 사용자명: admin
   - 비밀번호: admin123
   - 이메일: admin@company.com
   - 권한: 모든 기능 접근 가능

2. 매니저 계정 (ROLE_MANAGER)
   - 사용자명: manager
   - 비밀번호: manager123
   - 이메일: manager@company.com
   - 권한: 이슈 상태 변경 가능

3. 일반 사용자 계정 (ROLE_USER)
   - 사용자명: user
   - 비밀번호: user123
   - 이메일: user@company.com
   - 권한: 조회만 가능

⚠️ 주의: 프로덕션 환경에서는 반드시 비밀번호를 변경하세요!
*/

-- ====================================================================
-- 생성된 보안 이슈 목록 (총 14건)
-- ====================================================================

/*
📥 수신메일 이슈 (INBOUND) - 8건
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

이슈 #1
  제목: 대량 스팸 메일 탐지 (1,250건)
  설명: 단일 IP에서 1시간 내 1,250건의 스팸 메일 발송 탐지
  카테고리: 대량 스팸 메일 공격
  유형: 수신메일 (INBOUND)
  상태: 긴급 (CRITICAL)
  심각도: 긴급 (CRITICAL)
  영향받은 이메일: 1,250건
  출발지 IP: 203.142.78.91
  대상 이메일: admin@company.com

이슈 #2
  제목: 피싱 사이트 링크 포함 메일
  설명: 은행 사칭 피싱 사이트로 유도하는 링크 발견
  카테고리: 개인정보 탈취 피싱 사이트 공격
  유형: 수신메일 (INBOUND)
  상태: 대기 (PENDING)
  심각도: 높음 (HIGH)
  영향받은 이메일: 15건
  출발지 IP: 185.220.101.45
  대상 이메일: hr@company.com

이슈 #3
  제목: 의심스러운 첨부파일 탐지
  설명: ransomware.exe 파일이 첨부된 메일 차단
  카테고리: 바이러스, 랜섬웨어 등 악성코드 공격
  유형: 수신메일 (INBOUND)
  상태: 긴급 (CRITICAL)
  심각도: 긴급 (CRITICAL)
  영향받은 이메일: 3건
  출발지 IP: 91.203.45.122
  대상 이메일: finance@company.com

이슈 #4
  제목: 헤더 위변조 메일 탐지
  설명: CEO 이메일을 사칭한 송금 요청 메일
  카테고리: 헤더 위·변조 및 유사 도메인 사칭 메일
  유형: 수신메일 (INBOUND)
  상태: 검토중 (REVIEW)
  심각도: 높음 (HIGH)
  영향받은 이메일: 8건
  출발지 IP: 172.104.88.29
  대상 이메일: accounting@company.com

이슈 #5
  제목: 불법 릴레이 서버 사용 탐지
  설명: 외부 서버를 통한 스팸 메일 발송 시도
  카테고리: 불법 릴레이 서버 사용
  유형: 수신메일 (INBOUND)
  상태: 대기 (PENDING)
  심각도: 보통 (MEDIUM)
  영향받은 이메일: 45건
  출발지 IP: 198.51.100.42
  대상 이메일: mail-relay@company.com

이슈 #11
  제목: 악성 매크로 포함 엑셀 파일 탐지
  설명: 매크로 자동 실행 시 원격 서버 접속 시도하는 악성 파일 차단
  카테고리: 바이러스, 랜섬웨어 등 악성코드 공격
  유형: 수신메일 (INBOUND)
  상태: 검토중 (REVIEW)
  심각도: 높음 (HIGH)
  영향받은 이메일: 7건
  출발지 IP: 104.28.16.238
  대상 이메일: sales@company.com

이슈 #13
  제목: 제로데이 취약점 공격 시도 탐지
  설명: Exchange Server 제로데이 취약점을 이용한 원격 코드 실행 시도
  카테고리: 바이러스, 랜섬웨어 등 악성코드 공격
  유형: 수신메일 (INBOUND)
  상태: 대기 (PENDING)
  심각도: 긴급 (CRITICAL)
  영향받은 이메일: 25건
  출발지 IP: 47.89.153.201
  대상 이메일: mailserver@company.com

이슈 #14
  제목: 의심스러운 압축파일 첨부 메일
  설명: password-protected ZIP 파일 내부에 .scr 실행파일 포함
  카테고리: 바이러스, 랜섬웨어 등 악성코드 공격
  유형: 수신메일 (INBOUND)
  상태: 대기 (PENDING)
  심각도: 보통 (MEDIUM)
  영향받은 이메일: 18건
  출발지 IP: 213.174.92.66
  대상 이메일: support@company.com


📤 발신메일 이슈 (OUTBOUND) - 6건
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

이슈 #6
  제목: 고객 정보 포함 메일 외부 발송
  설명: 개인정보 500건이 포함된 엑셀 파일 외부 전송
  카테고리: 기업 내부 정보 유출 및 오발송 사고
  유형: 발신메일 (OUTBOUND)
  상태: 긴급 (CRITICAL)
  심각도: 긴급 (CRITICAL)
  영향받은 이메일: 500건
  출발지 IP: 192.168.1.105
  대상 이메일: external-partner@gmail.com

이슈 #7
  제목: 바이러스 URL 공유 탐지
  설명: 악성 URL이 포함된 메일 발송 차단
  카테고리: 바이러스 URL 공유
  유형: 발신메일 (OUTBOUND)
  상태: 검토중 (REVIEW)
  심각도: 높음 (HIGH)
  영향받은 이메일: 12건
  출발지 IP: 192.168.1.87
  대상 이메일: client@external.com

이슈 #8
  제목: 악성 메일 회신 탐지
  설명: 피싱 메일에 대한 직원의 회신 차단
  카테고리: 악성 메일 회신
  유형: 발신메일 (OUTBOUND)
  상태: 해결 (RESOLVED)
  심각도: 보통 (MEDIUM)
  영향받은 이메일: 1건
  출발지 IP: 192.168.1.54
  대상 이메일: phishing@fake-bank.com

이슈 #9
  제목: 대용량 파일 무단 발송
  설명: 500MB 파일을 승인 없이 외부로 발송
  카테고리: 대용량 파일 사후관리 문제
  유형: 발신메일 (OUTBOUND)
  상태: 대기 (PENDING)
  심각도: 낮음 (LOW)
  영향받은 이메일: 1건
  출발지 IP: 192.168.1.92
  대상 이메일: storage@external.com

이슈 #10
  제목: 망분리 환경 파일 전송 시도
  설명: 내부망에서 외부망으로 첨부파일 전송 시도 탐지
  카테고리: 망분리 환경에서 대용량 첨부파일 발송 문제
  유형: 발신메일 (OUTBOUND)
  상태: 검토중 (REVIEW)
  심각도: 보통 (MEDIUM)
  영향받은 이메일: 1건
  출발지 IP: 10.0.0.55
  대상 이메일: external@partner.com

이슈 #12
  제목: 승인되지 않은 대량 메일 발송 탐지
  설명: 마케팅 승인 없이 2,300건의 광고 메일 발송 시도
  카테고리: 악성 메일 회신
  유형: 발신메일 (OUTBOUND)
  상태: 대기 (PENDING)
  심각도: 보통 (MEDIUM)
  영향받은 이메일: 2,300건
  출발지 IP: 192.168.1.78
  대상 이메일: multiple-recipients@various.com


📊 통계 요약
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
총 이슈 수: 14건

[유형별]
  - 수신메일 (INBOUND): 8건
  - 발신메일 (OUTBOUND): 6건

[상태별]
  - 긴급 (CRITICAL): 3건 (#1, #3, #6)
  - 대기 (PENDING): 6건 (#2, #5, #9, #13, #14, #12)
  - 검토중 (REVIEW): 4건 (#4, #11, #7, #10)
  - 해결 (RESOLVED): 1건 (#8)

[심각도별]
  - 긴급 (CRITICAL): 5건 (#1, #3, #6, #13)
  - 높음 (HIGH): 4건 (#2, #4, #11, #7)
  - 보통 (MEDIUM): 4건 (#5, #8, #10, #12, #14)
  - 낮음 (LOW): 1건 (#9)

*/
