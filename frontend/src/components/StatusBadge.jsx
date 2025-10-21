import React from 'react';
import '../styles/StatusBadge.css';

const StatusBadge = ({ status, severity }) => {
  const getStatusStyle = (status) => {
    const styles = {
      PENDING: { bg: '#FFA726', label: '대기' },
      REVIEW: { bg: '#42A5F5', label: '검토중' },
      CRITICAL: { bg: '#EF5350', label: '긴급' },
      RESOLVED: { bg: '#66BB6A', label: '해결' },
      
    };
    return styles[status] || { bg: '#9E9E9E', label: status };
  };

  const getSeverityStyle = (severity) => {
    const styles = {
      LOW: { bg: '#AED581', label: '낮음' },
      MEDIUM: { bg: '#FFD54F', label: '보통' },
      HIGH: { bg: '#FF8A65', label: '높음' },
      CRITICAL: { bg: '#E57373', label: '심각' }
    };
    return styles[severity] || { bg: '#9E9E9E', label: severity };
  };

  if (status) {
    const style = getStatusStyle(status);
    return (
      <span className="status-badge" style={{ backgroundColor: style.bg }}>
        {style.label}
      </span>
    );
  }

  if (severity) {
    const style = getSeverityStyle(severity);
    return (
      <span className="severity-badge" style={{ backgroundColor: style.bg }}>
        {style.label}
      </span>
    );
  }

  return null;
};

export default StatusBadge;
