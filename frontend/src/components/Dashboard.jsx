import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { issueApi } from '../services/api';
import StatCard from './StatCard';
import StatusBadge from './StatusBadge';
import ChartSection from './ChartSection';
import '../styles/Dashboard.css';

const Dashboard = () => {
  const navigate = useNavigate();
  const [stats, setStats] = useState(null);
  const [issues, setIssues] = useState([]);
  const [top3, setTop3] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('ALL');
  const [severityFilter, setSeverityFilter] = useState('ALL');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [statsData, issuesData, top3Data] = await Promise.all([
        issueApi.getDashboardStats(),
        issueApi.getAllIssues(),
        issueApi.getTop3Issues()
      ]);
      setStats(statsData);
      setIssues(issuesData);
      setTop3(top3Data);
    } catch (error) {
      console.error('데이터 로딩 실패:', error);
      // If no data exists, try to initialize sample data
      try {
        await issueApi.initSampleData();
        loadData(); // Retry loading
      } catch (initError) {
        console.error('샘플 데이터 초기화 실패:', initError);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (id, newStatus) => {
    try {
      await issueApi.updateStatus(id, newStatus);
      loadData(); // Reload data
    } catch (error) {
      console.error('상태 변경 실패:', error);
      alert('상태 변경에 실패했습니다.');
    }
  };

  const getFilteredIssues = () => {
    let filtered = issues;

    // Apply type/status filter
    if (filter !== 'ALL') {
      if (filter === 'INBOUND') {
        filtered = filtered.filter(issue => issue.type === 'INBOUND');
      } else if (filter === 'OUTBOUND') {
        filtered = filtered.filter(issue => issue.type === 'OUTBOUND');
      } else {
        filtered = filtered.filter(issue => issue.status === filter);
      }
    }

    // Apply severity filter
    if (severityFilter !== 'ALL') {
      filtered = filtered.filter(issue => issue.severity === severityFilter);
    }

    return filtered;
  };

  const getPaginatedIssues = () => {
    const filtered = getFilteredIssues();
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return filtered.slice(startIndex, endIndex);
  };

  const totalPages = Math.ceil(getFilteredIssues().length / itemsPerPage);

  const handleFilterChange = (newFilter) => {
    setFilter(newFilter);
    setCurrentPage(1);
  };

  const handleSeverityFilterChange = (e) => {
    setSeverityFilter(e.target.value);
    setCurrentPage(1);
  };

  if (loading) {
    return <div className="loading">로딩 중...</div>;
  }

  if (!stats) {
    return <div className="error">데이터를 불러올 수 없습니다.</div>;
  }

  return (
    <div className="dashboard">
      {/* Statistics Cards */}
      <div className="stats-grid">
        <StatCard
          title="전체 이슈"
          value={stats.totalIssues}
          icon="📊"
          color="#6366f1"
          onClick={() => handleFilterChange('ALL')}
        />
        <StatCard
          title="수신메일"
          value={stats.inboundIssues}
          icon="📥"
          color="#3b82f6"
          onClick={() => handleFilterChange('INBOUND')}
        />
        <StatCard
          title="발신메일"
          value={stats.outboundIssues}
          icon="📤"
          color="#f59e0b"
          onClick={() => handleFilterChange('OUTBOUND')}
        />
        <StatCard
          title="긴급 이슈"
          value={stats.criticalIssues}
          icon="🚨"
          color="#b91c1c"
          onClick={() => handleFilterChange('CRITICAL')}
        />
      </div>

      {/* Top 3 Critical Issues */}
      <div className="section">
        <h2 className="section-title">🔥 긴급 이슈 TOP 3</h2>
        <div className="top3-grid">
          {top3.map((issue, index) => (
            <div
              key={issue.id}
              className="top3-card"
              onClick={() => navigate(`/issue/${issue.id}`)}
            >
              <div className="top3-rank">#{index + 1}</div>
              <h3 className="top3-title">{issue.title}</h3>
              <div className="top3-badges">
                <StatusBadge severity={issue.severity} />
                <StatusBadge status={issue.status} />
              </div>
              <div className="top3-info">
                <span className={`type-badge ${issue.type.toLowerCase()}`}>
                  {issue.type === 'INBOUND' ? '수신' : '발신'}
                </span>
                <span className="top3-affected">
                  <strong>{issue.affectedEmails}</strong>건 영향
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Chart Section */}
      <ChartSection stats={stats} />

      {/* Issues List */}
      <div className="section">
        <div className="section-header">
          <h2 className="section-title">📋 보안 이슈 목록</h2>
          <div className="filter-controls">
            <div className="filter-buttons">
              {['PENDING', 'REVIEW', 'RESOLVED'].map(status => (
                <button
                  key={status}
                  className={`filter-btn ${filter === status ? 'active' : ''}`}
                  onClick={() => handleFilterChange(status)}
                >
                  {status === 'PENDING' ? '대기' :
                   status === 'REVIEW' ? '검토중' : '해결'}
                </button>
              ))}
            </div>
            <div className="severity-filter-wrapper">
              <span className="severity-filter-label">심각도 :</span>
              <select
                className="severity-filter-dropdown"
                value={severityFilter}
                onChange={handleSeverityFilterChange}
              >
                <option value="ALL">전체</option>
                <option value="MEDIUM">보통</option>
                <option value="HIGH">높음</option>
                <option value="CRITICAL">긴급</option>
              </select>
            </div>
          </div>
        </div>

        <div className="issues-table">
          <div className="issues-header">
            <div className="col-title">이슈</div>
            <div className="col-type">유형</div>
            <div className="col-severity">심각도</div>
            <div className="col-status">상태</div>
            <div className="col-affected">영향</div>
          </div>
          {getPaginatedIssues().map(issue => (
            <div
              key={issue.id}
              className="issue-row"
              onClick={() => navigate(`/issue/${issue.id}`)}
            >
              <div className="col-title">
                <span className="issue-title">{issue.title}</span>
                <span className="issue-category">({issue.category})</span>
              </div>
              <div className="col-type">
                <span className={`type-badge ${issue.type.toLowerCase()}`}>
                  {issue.type === 'INBOUND' ? '수신' : '발신'}
                </span>
              </div>
              <div className="col-severity">
                <StatusBadge severity={issue.severity} />
              </div>
              <div className="col-status">
                <StatusBadge status={issue.status} />
              </div>
              <div className="col-affected">
                <strong>{issue.affectedEmails}</strong>건
              </div>
            </div>
          ))}
        </div>

        {/* Pagination Controls */}
        {totalPages > 1 && (
          <div className="pagination">
            <button
              className="page-btn"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage(currentPage - 1)}
            >
              ◀ 이전
            </button>
            <span className="page-info">
              페이지 <strong>{currentPage}</strong> / {totalPages}
            </span>
            <button
              className="page-btn"
              disabled={currentPage === totalPages}
              onClick={() => setCurrentPage(currentPage + 1)}
            >
              다음 ▶
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
