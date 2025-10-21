import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

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

export default api;
