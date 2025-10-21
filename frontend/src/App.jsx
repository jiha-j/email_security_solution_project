import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Dashboard from './components/Dashboard';
import IssueDetail from './components/IssueDetail';
import './styles/App.css';

function App() {
  return (
    <Router>
      <div className="app">
        <header className="app-header">
          <h1>🔒 Email 송수신 보안 모니터링 시스템 DashBoard(Feat. EG-platform)</h1>
        </header>
        <main className="app-main">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/issue/:id" element={<IssueDetail />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
