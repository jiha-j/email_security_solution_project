import React from 'react';
import '../styles/ChartSection.css';

const ChartSection = ({ stats }) => {
  if (!stats) return null;

  const maxValue = Math.max(
    stats.inboundIssues,
    stats.outboundIssues,
    stats.issuesBySeverity?.CRITICAL || 0,
    stats.issuesBySeverity?.HIGH || 0,
    stats.issuesBySeverity?.MEDIUM || 0,
    stats.issuesBySeverity?.LOW || 0
  );

  const getBarWidth = (value) => {
    return maxValue > 0 ? (value / maxValue) * 100 : 0;
  };

  return (
    <div className="chart-section">
      <div className="chart-container">
        <h3 className="chart-title">📊 유형별 분포</h3>
        <div className="chart-bars">
          <div className="chart-bar-item">
            <div className="bar-label">
              <span className="label-name">수신메일</span>
              <span className="label-value">{stats.inboundIssues}건</span>
            </div>
            <div className="bar-wrapper">
              <div
                className="bar inbound"
                style={{ width: `${getBarWidth(stats.inboundIssues)}%` }}
              ></div>
            </div>
          </div>
          <div className="chart-bar-item">
            <div className="bar-label">
              <span className="label-name">발신메일</span>
              <span className="label-value">{stats.outboundIssues}건</span>
            </div>
            <div className="bar-wrapper">
              <div
                className="bar outbound"
                style={{ width: `${getBarWidth(stats.outboundIssues)}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>

      <div className="chart-container">
        <h3 className="chart-title">🎯 심각도별 분포</h3>
        <div className="chart-bars">
          <div className="chart-bar-item">
            <div className="bar-label">
              <span className="label-name">심각</span>
              <span className="label-value">{stats.issuesBySeverity?.CRITICAL || 0}건</span>
            </div>
            <div className="bar-wrapper">
              <div
                className="bar critical"
                style={{ width: `${getBarWidth(stats.issuesBySeverity?.CRITICAL || 0)}%` }}
              ></div>
            </div>
          </div>
          <div className="chart-bar-item">
            <div className="bar-label">
              <span className="label-name">높음</span>
              <span className="label-value">{stats.issuesBySeverity?.HIGH || 0}건</span>
            </div>
            <div className="bar-wrapper">
              <div
                className="bar high"
                style={{ width: `${getBarWidth(stats.issuesBySeverity?.HIGH || 0)}%` }}
              ></div>
            </div>
          </div>
          <div className="chart-bar-item">
            <div className="bar-label">
              <span className="label-name">보통</span>
              <span className="label-value">{stats.issuesBySeverity?.MEDIUM || 0}건</span>
            </div>
            <div className="bar-wrapper">
              <div
                className="bar medium"
                style={{ width: `${getBarWidth(stats.issuesBySeverity?.MEDIUM || 0)}%` }}
              ></div>
            </div>
          </div>
          <div className="chart-bar-item">
            <div className="bar-label">
              <span className="label-name">낮음</span>
              <span className="label-value">{stats.issuesBySeverity?.LOW || 0}건</span>
            </div>
            <div className="bar-wrapper">
              <div
                className="bar low"
                style={{ width: `${getBarWidth(stats.issuesBySeverity?.LOW || 0)}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChartSection;
