import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Axios interceptor to add JWT token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle 401 errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid - clear storage and redirect to login
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// API endpoints
export const issueApi = {
  // Get all issues
  getAllIssues: async () => {
    const response = await api.get('/issues');
    return response.data;
  },

  // Get issue by ID
  getIssueById: async (id) => {
    const response = await api.get(`/issues/${id}`);
    return response.data;
  },

  // Get top 3 critical issues
  getTop3Issues: async () => {
    const response = await api.get('/issues/top3');
    return response.data;
  },

  // Get dashboard statistics
  getDashboardStats: async () => {
    const response = await api.get('/issues/stats');
    return response.data;
  },

  // Create new issue
  createIssue: async (issueData) => {
    const response = await api.post('/issues', issueData);
    return response.data;
  },

  // Update issue status
  updateStatus: async (id, status) => {
    const response = await api.put(`/issues/${id}/status`, { status });
    return response.data;
  },

  // Initialize sample data
  initSampleData: async () => {
    const response = await api.post('/issues/init-sample');
    return response.data;
  },
};

// Authentication API
export const authApi = {
  // Login
  login: async (loginData) => {
    const response = await api.post('/auth/login', loginData);
    return response.data;
  },

  // Signup
  signup: async (signupData) => {
    const response = await api.post('/auth/signup', signupData);
    return response.data;
  },
};

export default api;
