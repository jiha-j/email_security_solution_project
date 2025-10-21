import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { issueApi } from '../services/api';
import StatusBadge from './StatusBadge';
import '../styles/IssueDetail.css';

const IssueDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [issue, setIssue] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadIssue();
  }, [id]);

  const loadIssue = async () => {
    try {
      setLoading(true);
      const data = await issueApi.getIssueById(id);
      setIssue(data);
    } catch (error) {
      console.error('이슈 로딩 실패:', error);
      alert('이슈를 불러올 수 없습니다.');
      navigate('/');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (newStatus) => {
    try {
      const updated = await issueApi.updateStatus(id, newStatus);
      setIssue(updated);
      alert('상태가 변경되었습니다.');
    } catch (error) {
      console.error('상태 변경 실패:', error);
      alert('상태 변경에 실패했습니다.');
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('ko-KR', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return <div className="loading">로딩 중...</div>;
  }

  if (!issue) {
    return <div className="error">이슈를 찾을 수 없습니다.</div>;
  }

  return (
    <div className="issue-detail">
      <button className="back-button" onClick={() => navigate('/')}>
        ← 대시보드로 돌아가기
      </button>

      <div className="detail-card">
        <div className="detail-header">
          <h1 className="detail-title">{issue.title}</h1>
          <div className="detail-badges">
            <StatusBadge status={issue.status} />
            <StatusBadge severity={issue.severity} />
            <span className={`type-badge-large ${issue.type.toLowerCase()}`}>
              {issue.type === 'INBOUND' ? '📥 수신메일' : '📤 발신메일'}
            </span>
          </div>
        </div>

        <div className="detail-section">
          <h2 className="section-subtitle">📝 상세 설명</h2>
          <p className="description">{issue.description}</p>
        </div>

        <div className="detail-section">
          <h2 className="section-subtitle">📂 이슈 정보</h2>
          <div className="info-grid">
            <div className="info-item">
              <span className="info-label">카테고리</span>
              <span className="info-value">{issue.category}</span>
            </div>
            <div className="info-item">
              <span className="info-label">심각도</span>
              <span className="info-value">
                <StatusBadge severity={issue.severity} />
              </span>
            </div>
            <div className="info-item">
              <span className="info-label">영향받은 이메일 수</span>
              <span className="info-value highlight">{issue.affectedEmails}건</span>
            </div>
            <div className="info-item">
              <span className="info-label">유형</span>
              <span className="info-value">
                {issue.type === 'INBOUND' ? '수신메일' : '발신메일'}
              </span>
            </div>
          </div>
        </div>

        <div className="detail-section">
          <h2 className="section-subtitle">🔍 기술 정보</h2>
          <div className="info-grid">
            <div className="info-item">
              <span className="info-label">출발지 IP</span>
              <span className="info-value code">{issue.sourceIp || '-'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">대상 이메일</span>
              <span className="info-value code">{issue.targetEmail || '-'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">탐지 시각</span>
              <span className="info-value">{formatDate(issue.detectedDate)}</span>
            </div>
            <div className="info-item">
              <span className="info-label">해결 시각</span>
              <span className="info-value">{formatDate(issue.resolvedDate)}</span>
            </div>
          </div>
        </div>

        <div className="detail-section">
          <h2 className="section-subtitle">⚠️ 권장 조치</h2>
          <div className="recommendations">
            {issue.severity === 'CRITICAL' && (
              <div className="recommendation critical">
                <strong>즉시 조치 필요:</strong> 해당 IP 차단 및 영향받은 시스템 점검
              </div>
            )}
            {issue.type === 'INBOUND' && (
              <div className="recommendation">
                • 메일 서버 필터링 규칙 업데이트<br />
                • 사용자 대상 피싱 주의 안내 발송<br />
                • 방화벽 정책 검토 및 강화
              </div>
            )}
            {issue.type === 'OUTBOUND' && (
              <div className="recommendation">
                • 발신자 계정 확인 및 보안 점검<br />
                • 내부 정책 위반 여부 검토<br />
                • 데이터 유출 경로 분석
              </div>
            )}
          </div>
        </div>

        <div className="action-buttons">
          <button
            className="action-btn pending"
            onClick={() => handleStatusChange('PENDING')}
            disabled={issue.status === 'PENDING'}
          >
            대기 상태로 변경
          </button>
          <button
            className="action-btn primary"
            onClick={() => handleStatusChange('REVIEW')}
            disabled={issue.status === 'REVIEW'}
          >
            검토 시작
          </button>
          <button
            className="action-btn success"
            onClick={() => handleStatusChange('RESOLVED')}
            disabled={issue.status === 'RESOLVED'}
          >
            해결 완료
          </button>
          <button
            className="action-btn danger"
            onClick={() => handleStatusChange('CRITICAL')}
            disabled={issue.status === 'CRITICAL'}
          >
            긴급으로 표시
          </button>
        </div>
      </div>
    </div>
  );
};

export default IssueDetail;
