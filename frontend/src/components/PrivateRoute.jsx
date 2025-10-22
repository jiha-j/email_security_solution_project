import React from 'react';
import { Navigate } from 'react-router-dom';

const PrivateRoute = ({ children }) => {
  const token = localStorage.getItem('token');

  if (!token) {
    // Not authenticated - redirect to login
    return <Navigate to="/login" replace />;
  }

  // Authenticated - render the protected component
  return children;
};

export default PrivateRoute;
