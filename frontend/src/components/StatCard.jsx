import React from 'react';
import '../styles/StatCard.css';

const StatCard = ({ title, value, icon, color, onClick }) => {
  return (
    <div
      className="stat-card"
      style={{ borderLeftColor: color }}
      onClick={onClick}
    >
      <span className="stat-icon">{icon}</span>
      <span className="stat-title">{title}</span>
      <span className="stat-value" style={{ color }}>{value}</span>
    </div>
  );
};

export default StatCard;
