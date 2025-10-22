import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { issueApi } from '../services/api';
import '../styles/IssueRegister.css';

const IssueRegister = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: '',
    type: 'INBOUND',
    severity: 'MEDIUM',
    affectedEmails: '',
    sourceIp: '',
    targetEmail: ''
  });

  const [loading, setLoading] = useState(false);

  const categories = {
    INBOUND: [
      '대량 스팸 메일 공격',
      '불법 릴레이 서버 사용',
      '바이러스, 랜섬웨어 등 악성코드 공격',
      '개인정보 탈취 피싱 사이트 공격',
      '헤더 위·변조 및 유사 도메인 사칭 메일'
    ],
    OUTBOUND: [
      '악성 메일 회신',
      '바이러스 URL 공유',
      '기업 내부 정보 유출 및 오발송 사고',
      '대용량 파일 사후관리 문제',
      '망분리 환경에서 대용량 첨부파일 발송 문제'
    ]
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));

    // 유형이 변경되면 카테고리 초기화
    if (name === 'type') {
      setFormData(prev => ({
        ...prev,
        category: ''
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // 유효성 검사
    if (!formData.title.trim()) {
      alert('이슈 제목을 입력해주세요.');
      return;
    }
    if (!formData.description.trim()) {
      alert('상세 설명을 입력해주세요.');
      return;
    }
    if (!formData.category) {
      alert('카테고리를 선택해주세요.');
      return;
    }
    if (!formData.affectedEmails || formData.affectedEmails <= 0) {
      alert('영향받은 이메일 수를 입력해주세요.');
      return;
    }

    try {
      setLoading(true);

      // API 요청 데이터 준비
      const issueData = {
        ...formData,
        affectedEmails: parseInt(formData.affectedEmails),
        status: 'PENDING' // 기본값으로 대기 상태
      };

      await issueApi.createIssue(issueData);
      alert('보안 이슈가 성공적으로 등록되었습니다.');
      navigate('/');
    } catch (error) {
      console.error('이슈 등록 실패:', error);
      alert('이슈 등록에 실패했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="issue-register">
      <button className="back-button" onClick={() => navigate('/')}>
        ← 대시보드로 돌아가기
      </button>

      <div className="register-card">
        <div className="register-header">
          <h1 className="register-title">📝 보안 이슈 등록</h1>
          <p className="register-subtitle">새로운 보안 이슈를 시스템에 등록합니다</p>
        </div>

        <form onSubmit={handleSubmit}>
          {/* 기본 정보 */}
          <div className="form-section">
            <h2 className="section-title">📋 기본 정보</h2>

            <div className="form-group">
              <label className="form-label">이슈 제목 *</label>
              <input
                type="text"
                name="title"
                value={formData.title}
                onChange={handleChange}
                className="form-input"
                placeholder="예: 대량 스팸 메일 탐지 (1,250건)"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">상세 설명 *</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleChange}
                className="form-textarea"
                placeholder="이슈에 대한 상세한 설명을 입력하세요"
                rows="4"
                required
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">유형 *</label>
                <select
                  name="type"
                  value={formData.type}
                  onChange={handleChange}
                  className="form-select"
                >
                  <option value="INBOUND">📥 수신메일</option>
                  <option value="OUTBOUND">📤 발신메일</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">심각도 *</label>
                <select
                  name="severity"
                  value={formData.severity}
                  onChange={handleChange}
                  className="form-select"
                >
                  <option value="LOW">낮음</option>
                  <option value="MEDIUM">보통</option>
                  <option value="HIGH">높음</option>
                  <option value="CRITICAL">긴급</option>
                </select>
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">카테고리 *</label>
              <select
                name="category"
                value={formData.category}
                onChange={handleChange}
                className="form-select"
                required
              >
                <option value="">카테고리 선택</option>
                {categories[formData.type].map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* 기술 정보 */}
          <div className="form-section">
            <h2 className="section-title">🔍 기술 정보</h2>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">영향받은 이메일 수 *</label>
                <input
                  type="number"
                  name="affectedEmails"
                  value={formData.affectedEmails}
                  onChange={handleChange}
                  className="form-input"
                  placeholder="0"
                  min="1"
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">출발지 IP</label>
                <input
                  type="text"
                  name="sourceIp"
                  value={formData.sourceIp}
                  onChange={handleChange}
                  className="form-input"
                  placeholder="예: 192.168.1.100"
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">대상 이메일</label>
              <input
                type="email"
                name="targetEmail"
                value={formData.targetEmail}
                onChange={handleChange}
                className="form-input"
                placeholder="예: admin@company.com"
              />
            </div>
          </div>

          {/* 버튼 영역 */}
          <div className="form-actions">
            <button
              type="button"
              className="btn-cancel"
              onClick={() => navigate('/')}
              disabled={loading}
            >
              취소
            </button>
            <button
              type="submit"
              className="btn-submit"
              disabled={loading}
            >
              {loading ? '등록 중...' : '✅ 이슈 등록'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default IssueRegister;
