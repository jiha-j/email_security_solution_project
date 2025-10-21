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

-- 3. 샘플 데이터 삽입
PRINT '샘플 데이터 삽입 시작...';

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

GO

-- 4. 데이터 확인
PRINT '=== 데이터베이스 초기화 완료 ===';
PRINT '';
PRINT '생성된 테이블:';
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
PRINT '';
PRINT '삽입된 데이터 수:';
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
