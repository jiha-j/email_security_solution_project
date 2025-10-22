import React from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate } from 'react-router-dom';
import Dashboard from './components/Dashboard';
import IssueDetail from './components/IssueDetail';
import IssueRegister from './components/IssueRegister';
import Login from './components/Login';
import Register from './components/Register';
import PrivateRoute from './components/PrivateRoute';
import './styles/App.css';

const AppHeader = () => {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem('user') || 'null');

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <header className="app-header">
      <h1>🔒 Email 송수신 보안 모니터링 시스템 DashBoard(Feat. EG-platform)</h1>
      {user && (
        <div className="header-user-info">
          <span className="user-name">{user.username}</span>
          <button className="logout-btn" onClick={handleLogout}>로그아웃</button>
        </div>
      )}
    </header>
  );
};

function App() {
  return (
    <Router>
      <div className="app">
        <Routes>
          {/* Public routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Register />} />

          {/* Protected routes */}
          <Route path="/" element={
            <PrivateRoute>
              <AppHeader />
              <main className="app-main">
                <Dashboard />
              </main>
            </PrivateRoute>
          } />
          <Route path="/issue/:id" element={
            <PrivateRoute>
              <AppHeader />
              <main className="app-main">
                <IssueDetail />
              </main>
            </PrivateRoute>
          } />
          <Route path="/register" element={
            <PrivateRoute>
              <AppHeader />
              <main className="app-main">
                <IssueRegister />
              </main>
            </PrivateRoute>
          } />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
