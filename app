import React, { useState, useEffect } from 'react';
import { Play, Pause, XCircle, Filter, Search, PlusCircle, RefreshCw, Snowflake } from 'lucide-react'; // Icons

// Dummy data for jobs
const initialJobs = [
  { id: 'job-1', name: 'Daily Data Sync', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'sync', source: 'DB1', destination: 'DB2', frequency: 'daily' }, null, 2) },
  { id: 'job-2', name: 'Weekly Report Generation', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'report', format: 'PDF', recipients: ['user@example.com'], schedule: 'weekly' }, null, 2) },
  { id: 'job-3', name: 'Monthly Backup', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'backup', target: '/data/backup', retention: '3 months', full: true }, null, 2) },
  { id: 'job-4', name: 'Hourly Cache Refresh', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'cache', service: 'API_Gateway', region: 'us-east-1' }, null, 2) },
  { id: 'job-5', name: 'System Maintenance', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'maintenance', duration: '2 hours', affectedSystems: ['web-server', 'db-server'] }, null, 2) },
  { id: 'job-6', name: 'User Data Import', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'import', file: 'users.csv', schema: 'user_schema_v2' }, null, 2) },
  { id: 'job-7', name: 'Notification Service Check', status: 'Unknown', lastRun: 'N/A', nextRun: 'N/A', definition: JSON.stringify({ type: 'health_check', service: 'notifications', threshold: '99%' }, null, 2) },
];

// Header Component
const Header = () => (
  <header className="header">
    <div className="container header-content">
      <h1 className="header-title">SchedX</h1>
      <nav>
        <ul className="header-nav-list">
          <li><a href="#" className="header-nav-link">Dashboard</a></li>
          <li><a href="#" className="header-nav-link">Jobs</a></li>
          <li><a href="#" className="header-nav-link">Logs</a></li>
          <li><a href="#" className="header-nav-link">Settings</a></li>
        </ul>
      </nav>
    </div>
  </header>
);

// Job Controls Component (Simplified)
const JobControls = ({ onAddJob }) => (
  <div className="job-controls-container">
    <button
      onClick={onAddJob}
      className="add-job-button"
    >
      <PlusCircle className="icon-mr" size={20} /> Add New Job
    </button>
  </div>
);

// Job Filter and Search Component
const JobFilterSearch = ({ onFilterChange, onSearchChange, searchTerm, selectedStatus }) => (
  <div className="filter-search-container">
    <div className="search-input-wrapper">
      <Search className="search-icon" size={20} />
      <input
        type="text"
        placeholder="Search job by name..."
        value={searchTerm}
        onChange={(e) => onSearchChange(e.target.value)}
        className="search-input"
      />
    </div>
    <div className="filter-select-wrapper">
      <Filter className="filter-icon" size={20} />
      <select
        value={selectedStatus}
        onChange={(e) => onFilterChange(e.target.value)}
        className="filter-select"
      >
        <option value="All">All Statuses</option>
        <option value="Running">Running</option>
        <option value="Pending">Pending</option>
        <option value="Completed">Completed</option>
        <option value="Failed">Failed</option>
        <option value="Held">Held</option>
        <option value="On Ice">On Ice</option>
      </select>
      <div className="select-arrow">
        <svg className="fill-current" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/></svg>
      </div>
    </div>
  </div>
);

// Job List Component
const JobList = ({ jobs, onForceStart, onHold, onOffHold, onKill, onOnIce, onRefreshData, loadingJobIds, onJobNameClick }) => {
  const getStatusColorClass = (status) => {
    switch (status) {
      case 'Running': return 'status-running';
      case 'Pending': return 'status-pending';
      case 'Completed': return 'status-completed';
      case 'Failed': return 'status-failed';
      case 'Held': return 'status-held';
      case 'On Ice': return 'status-on-ice';
      case 'Unknown':
      case 'Failed to Load':
      default: return 'status-default';
    }
  };

  if (jobs.length === 0) {
    return (
      <div className="no-jobs-message">
        No jobs found matching your criteria.
      </div>
    );
  }

  return (
    <div className="job-list-container">
      <div className="table-wrapper">
        <table className="job-table">
          <thead>
            <tr>
              <th>Job Name</th>
              <th>Status</th>
              <th>Last Run</th>
              <th>Next Run</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {jobs.map((job, index) => (
              <tr key={job.id} className={index % 2 === 0 ? 'even-row' : 'odd-row'}>
                <td className="job-name-clickable" onClick={() => onJobNameClick(job.name)}>
                  {job.name}
                </td>
                <td>
                  <span className={`status-badge ${getStatusColorClass(job.status)}`}>
                    {loadingJobIds.includes(job.id) ? 'Loading...' : job.status}
                  </span>
                </td>
                <td>{job.lastRun}</td>
                <td>{job.nextRun}</td>
                <td className="job-actions">
                  <button
                    onClick={() => onRefreshData(job.id, job.name)}
                    className="action-button action-refresh"
                    title="Refresh Status & Runs"
                    disabled={loadingJobIds.includes(job.id)}
                  >
                    <RefreshCw size={18} className={loadingJobIds.includes(job.id) ? 'animate-spin' : ''} />
                  </button>
                  <button
                    onClick={() => onForceStart(job.id)}
                    disabled={job.status === 'Running'}
                    className={`action-button action-force-start ${job.status === 'Running' ? 'disabled' : ''}`}
                    title="Force Start"
                  >
                    <Play size={18} />
                  </button>
                  <button
                    onClick={() => onOnIce(job.id)}
                    disabled={job.status === 'Running' || job.status === 'On Ice'}
                    className={`action-button action-on-ice ${job.status === 'Running' || job.status === 'On Ice' ? 'disabled' : ''}`}
                    title="On Ice"
                  >
                    <Snowflake size={18} />
                  </button>
                  <button
                    onClick={() => onHold(job.id)}
                    disabled={job.status === 'Held'}
                    className={`action-button action-on-hold ${job.status === 'Held' ? 'disabled' : ''}`}
                    title="On Hold"
                  >
                    <Pause size={18} />
                  </button>
                  <button
                    onClick={() => onOffHold(job.id)}
                    disabled={job.status !== 'Held' && job.status !== 'On Ice'}
                    className={`action-button action-off-hold ${job.status !== 'Held' && job.status !== 'On Ice' ? 'disabled' : ''}`}
                    title="Off Hold"
                  >
                    <RefreshCw size={18} />
                  </button>
                  <button
                    onClick={() => onKill(job.id)}
                    disabled={job.status === 'Completed' || job.status === 'Failed'}
                    className={`action-button action-kill ${job.status === 'Completed' || job.status === 'Failed' ? 'disabled' : ''}`}
                    title="Kill"
                  >
                    <XCircle size={18} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

// Job Modal for Add New Job
const JobModal = ({ isOpen, onClose, onSave, job }) => {
  const [jobName, setJobName] = useState('');
  const [jobDefinition, setJobDefinition] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  useEffect(() => {
    if (job) {
      setJobName(job.name);
      setJobDefinition(job.definition);
    } else {
      setJobName('');
      setJobDefinition('');
    }
    setErrorMessage('');
  }, [job, isOpen]);

  const handleSave = () => {
    if (!jobName.trim()) {
      setErrorMessage('Job Name cannot be empty.');
      return;
    }
    try {
      JSON.parse(jobDefinition);
      onSave({ ...job, name: jobName, definition: jobDefinition });
      onClose();
    } catch (e) {
      setErrorMessage('Invalid JSON in Job Definition.');
    }
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2 className="modal-title">{job ? 'Edit Job' : 'Add New Job'}</h2>
        <div className="form-group">
          <label htmlFor="jobName" className="form-label">Job Name:</label>
          <input
            type="text"
            id="jobName"
            value={jobName}
            onChange={(e) => setJobName(e.target.value)}
            className="form-input"
            placeholder="e.g., Daily Database Backup"
          />
        </div>
        <div className="form-group">
          <label htmlFor="jobDefinition" className="form-label">Job Definition (JSON):</label>
          <textarea
            id="jobDefinition"
            value={jobDefinition}
            onChange={(e) => setJobDefinition(e.target.value)}
            rows="10"
            className="form-textarea"
            placeholder='e.g., {"type": "report", "frequency": "daily"}'
          ></textarea>
          {errorMessage && <p className="error-message">{errorMessage}</p>}
        </div>
        <div className="modal-actions">
          <button
            onClick={onClose}
            className="modal-button modal-button-cancel"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="modal-button modal-button-save"
          >
            Save Job
          </button>
        </div>
      </div>
    </div>
  );
};

// New Job Definition Modal Component
const JobDefinitionModal = ({ isOpen, onClose, jobName, definition, isLoading, error }) => {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2 className="modal-title">Job Definition: {jobName}</h2>
        <div className="form-group">
          <label htmlFor="jobDefinitionDisplay" className="form-label">Definition (JSON):</label>
          {isLoading ? (
            <p className="loading-message">Loading definition...</p>
          ) : error ? (
            <p className="error-message">{error}</p>
          ) : (
            <textarea
              id="jobDefinitionDisplay"
              value={definition}
              rows="15"
              readOnly
              className="form-textarea definition-display"
            ></textarea>
          )}
        </div>
        <div className="modal-actions">
          <button
            onClick={onClose}
            className="modal-button modal-button-cancel"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};


// Main App Component
const App = () => {
  const [jobs, setJobs] = useState(initialJobs);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('All');
  const [loadingJobIds, setLoadingJobIds] = useState([]); // State to track loading jobs for status/runs
  const [isModalOpen, setIsModalOpen] = useState(false); // For Add/Edit Job modal
  const [currentJob, setCurrentJob] = useState(null);

  // States for Job Definition Modal
  const [isDefinitionModalOpen, setIsDefinitionModalOpen] = useState(false);
  const [currentJobDefinition, setCurrentJobDefinition] = useState('');
  const [currentJobNameForDefinition, setCurrentJobNameForDefinition] = useState('');
  const [loadingDefinition, setLoadingDefinition] = useState(false);
  const [definitionError, setDefinitionError] = useState(null);


  // Filtered jobs based on search term and status
  const filteredJobs = jobs.filter(job => {
    const matchesSearch = job.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = selectedStatus === 'All' || job.status === selectedStatus;
    return matchesSearch && matchesStatus;
  });

  // Helper to update job properties (status, lastRun, nextRun)
  const updateJobProperties = (jobId, updates) => {
    setJobs(prevJobs =>
      prevJobs.map(job =>
        job.id === jobId ? { ...job, ...updates } : job
      )
    );
  };

  // Simulate fetching all job data (status, lastRun, nextRun) from APIs
  const refreshJobData = async (jobId, jobName) => {
    setLoadingJobIds(prev => [...prev, jobId]); // Add job to loading state
    try {
      // Simulate API call to www.jobstatusapi.com for status and lastRun
      const formattedJobNameForStatus = jobName.replace(/\s+/g, '').toLowerCase();
      // In a real application, you would replace this with an actual fetch call:
      // const statusResponse = await fetch(`https://www.jobstatusapi.com/fetch_job/${formattedJobNameForStatus}`);
      // const statusData = await statusResponse.json();
      // const newStatus = statusData.status || 'Unknown';
      // const newLastRun = statusData.lastRunTime || 'N/A';

      // Simulation for status API response
      const simulatedStatuses = ['Running', 'Completed', 'Failed', 'Pending', 'Held', 'On Ice'];
      const simulatedNewStatus = simulatedStatuses[Math.floor(Math.random() * simulatedStatuses.length)];
      const simulatedNewLastRun = new Date().toLocaleString(); // Current time as last run

      // Simulate API call to www.fetchjobjil.com for nextRun (and definition, though not used here)
      const formattedJobNameForDefinition = jobName.replace(/\s+/g, '').toLowerCase();
      // In a real application:
      // const definitionResponse = await fetch(`https://www.fetchjobjil.com/${formattedJobNameForDefinition}`);
      // const definitionData = await definitionResponse.json();
      // const newNextRun = definitionData.scheduleDate && definitionData.scheduleTime
      //                                ? `${definitionData.scheduleDate} ${definitionData.scheduleTime}`
      //                                : 'N/A';

      // Simulation for definition/schedule API response
      const simulatedNextRunDate = new Date();
      simulatedNextRunDate.setDate(simulatedNextRunDate.getDate() + Math.floor(Math.random() * 7) + 1); // 1-7 days in future
      const simulatedNewNextRun = `${simulatedNextRunDate.getFullYear()}-${(simulatedNextRunDate.getMonth() + 1).toString().padStart(2, '0')}-${simulatedNextRunDate.getDate().toString().padStart(2, '0')} ${Math.floor(Math.random() * 24).toString().padStart(2, '0')}:00`;


      await new Promise(resolve => setTimeout(resolve, 1500)); // Simulate network delay for both fetches

      updateJobProperties(jobId, {
        status: simulatedNewStatus,
        lastRun: simulatedNewLastRun,
        nextRun: simulatedNewNextRun
      });

    } catch (error) {
      console.error(`Error refreshing data for ${jobName}:`, error);
      updateJobProperties(jobId, {
        status: 'Failed to Load',
        lastRun: 'Error',
        nextRun: 'Error'
      });
    } finally {
      setLoadingJobIds(prev => prev.filter(id => id !== jobId)); // Remove job from loading state
    }
  };

  // Handler for clicking job name to fetch definition
  const handleJobNameClick = async (jobName) => {
    setCurrentJobNameForDefinition(jobName);
    setCurrentJobDefinition(''); // Clear previous definition
    setDefinitionError(null);
    setLoadingDefinition(true);
    setIsDefinitionModalOpen(true);

    try {
      // Simulate API call to www.fetchjobjil.com for definition
      const formattedJobName = jobName.replace(/\s+/g, '').toLowerCase();
      // In a real app: const response = await fetch(`https://www.fetchjobjil.com/${formattedJobName}`);
      // In a real app: const data = await response.json();
      // In a real app: const fetchedDefinition = data.definition;

      // Simulate fetching the definition from our initialJobs data
      const job = initialJobs.find(j => j.name.replace(/\s+/g, '').toLowerCase() === formattedJobName);

      await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate network delay

      if (job) {
        setCurrentJobDefinition(job.definition);
      } else {
        setDefinitionError(`Definition for "${jobName}" not found in dummy data.`);
      }
    } catch (error) {
      console.error(`Error fetching definition for ${jobName}:`, error);
      setDefinitionError('Failed to load job definition. Please try again.');
    } finally {
      setLoadingDefinition(false);
    }
  };


  // Per-job action handlers (these just update local state for demo purposes)
  const handleForceStart = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Force Starting job: ${job.name}`);
      updateJobProperties(jobId, { status: 'Running' });
    }
  };

  const handleOnHold = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Putting job on hold: ${job.name}`);
      updateJobProperties(jobId, { status: 'Held' });
    }
  };

  const handleOffHold = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Taking job off hold: ${job.name}`);
      updateJobProperties(jobId, { status: 'Pending' }); // Or whatever the next logical state is
    }
  };

  const handleKill = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Killing job: ${job.name}`);
      updateJobProperties(jobId, { status: 'Failed' });
    }
  };

  const handleOnIce = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Putting job on ice: ${job.name}`);
      updateJobProperties(jobId, { status: 'On Ice' });
    }
  };

  const handleAddJob = () => {
    setCurrentJob(null);
    setIsModalOpen(true);
  };

  const handleSaveJob = (updatedJob) => {
    if (updatedJob.id) {
      setJobs(jobs.map(job =>
        job.id === updatedJob.id ? { ...job, name: updatedJob.name, definition: updatedJob.definition } : job
      ));
    } else {
      const newJob = {
        ...updatedJob,
        id: `job-${Date.now()}`,
        status: 'Unknown', // New jobs start with 'Unknown' status to be fetched
        lastRun: 'N/A',
        nextRun: 'N/A',
      };
      setJobs([...jobs, newJob]);
    }
  };


  return (
    <div className="app-container">
      <style>
        {`
          /* Import Google Font - Inter */
          @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

          /* Base Styles */
          body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            background: linear-gradient(to bottom right, #f8fafc, #e2e8f0); /* Light gradient background */
            min-height: 100vh;
            color: #333;
          }

          .app-container {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
          }

          .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1.5rem; /* Equivalent to px-6 */
          }

          /* Header */
          .header {
            background: linear-gradient(to right, #2563eb, #4f46e5); /* from-blue-700 to-indigo-800 */
            color: white;
            padding: 1rem 0; /* p-4 */
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); /* shadow-2xl */
            border-bottom-left-radius: 0.75rem; /* rounded-b-xl */
            border-bottom-right-radius: 0.75rem; /* rounded-b-xl */
          }

          .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
          }

          .header-title {
            font-size: 2.25rem; /* text-3xl */
            font-weight: 800; /* font-extrabold */
            letter-spacing: -0.05em; /* tracking-tight */
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3); /* text-shadow-lg */
          }

          .header-nav-list {
            display: flex;
            list-style: none;
            margin: 0;
            padding: 0;
            gap: 1.5rem; /* space-x-6 */
          }

          .header-nav-link {
            color: #bfdbfe; /* text-blue-100 */
            text-decoration: none;
            transition: color 0.3s ease-in-out, transform 0.3s ease-in-out;
          }

          .header-nav-link:hover {
            color: white;
            transform: scale(1.05);
          }

          /* Main Content Area */
          .main-content {
            flex-grow: 1;
            padding: 1.5rem; /* p-6 */
          }

          /* Job Controls */
          .job-controls-container {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem; /* gap-4 */
            padding: 1.25rem; /* p-5 */
            background-color: white;
            border-radius: 0.75rem; /* rounded-xl */
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); /* shadow-xl */
            margin-bottom: 1.5rem; /* mb-6 */
            justify-content: flex-end; /* justify-end */
            border: 1px solid #f3f4f6; /* border border-gray-100 */
          }

          .add-job-button {
            display: flex;
            align-items: center;
            padding: 0.75rem 1.75rem; /* px-7 py-3 */
            background: linear-gradient(to right, #9333ea, #6366f1); /* from-purple-600 to-indigo-600 */
            color: white;
            border-radius: 9999px; /* rounded-full */
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); /* shadow-lg */
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
          }

          .add-job-button:hover {
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); /* hover:shadow-xl */
            background: linear-gradient(to right, #7e22ce, #5a57e6); /* hover:from-purple-700 hover:to-indigo-700 */
            transform: scale(1.05);
          }

          .add-job-button:focus {
            outline: none;
            box-shadow: 0 0 0 4px rgba(167, 139, 250, 0.5); /* focus:ring-4 focus:ring-purple-300 */
          }

          .icon-mr {
            margin-right: 0.5rem; /* mr-2 */
          }

          /* Filter and Search */
          .filter-search-container {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem; /* gap-4 */
            padding: 1.25rem; /* p-5 */
            background-color: white;
            border-radius: 0.75rem; /* rounded-xl */
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); /* shadow-xl */
            margin-bottom: 1.5rem; /* mb-6 */
            align-items: center;
            border: 1px solid #f3f4f6; /* border border-gray-100 */
          }

          .search-input-wrapper,
          .filter-select-wrapper {
            position: relative;
            flex-grow: 1;
            min-width: 200px; /* min-w-[200px] */
          }

          .search-icon,
          .filter-icon {
            position: absolute;
            left: 1rem; /* left-4 */
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af; /* text-gray-400 */
          }

          .search-input,
          .filter-select {
            width: 100%;
            padding: 0.75rem 1.25rem 0.75rem 3rem; /* pl-12 pr-5 py-3 */
            border: 1px solid #e5e7eb; /* border border-gray-200 */
            border-radius: 9999px; /* rounded-full */
            outline: none;
            transition: all 0.2s ease;
            color: #374151; /* text-gray-700 */
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); /* shadow-sm */
          }

          .search-input::placeholder {
            color: #9ca3af; /* placeholder-gray-400 */
          }

          .search-input:focus,
          .filter-select:focus {
            border-color: #60a5fa; /* focus:ring-3 focus:ring-blue-400 */
            box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.5);
          }

          .filter-select {
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background-color: white;
          }

          .select-arrow {
            position: absolute;
            inset-y: 0;
            right: 0;
            display: flex;
            align-items: center;
            padding-right: 1rem; /* px-4 */
            color: #374151; /* text-gray-700 */
            pointer-events: none;
          }

          .select-arrow svg {
            height: 1.25rem; /* h-5 */
            width: 1.25rem; /* w-5 */
          }

          /* Job List Table */
          .no-jobs-message {
            background-color: white;
            padding: 2rem; /* p-8 */
            border-radius: 0.75rem; /* rounded-xl */
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); /* shadow-xl */
            text-align: center;
            color: #4b5563; /* text-gray-600 */
            border: 1px solid #f3f4f6; /* border border-gray-100 */
          }

          .job-list-container {
            background-color: white;
            border-radius: 0.75rem; /* rounded-xl */
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); /* shadow-xl */
            overflow: hidden;
            border: 1px solid #f3f4f6; /* border border-gray-100 */
          }

          .table-wrapper {
            overflow-x: auto;
          }

          .job-table {
            min-width: 100%;
            border-collapse: collapse;
            table-layout: fixed; /* Ensures columns don't stretch excessively */
          }

          .job-table thead {
            background-color: #f9fafb; /* bg-gray-50 */
          }

          .job-table th {
            padding: 1rem 1.5rem; /* px-6 py-4 */
            text-align: left;
            font-size: 0.75rem; /* text-xs */
            font-weight: 600; /* font-semibold */
            color: #4b5563; /* text-gray-600 */
            text-transform: uppercase;
            letter-spacing: 0.05em; /* tracking-wider */
          }

          .job-table tbody {
            background-color: white;
          }

          .job-table tr {
            transition: background-color 0.15s ease; /* hover:bg-gray-50 transition duration-150 */
          }

          .job-table tr:hover {
            background-color: #f9fafb;
          }

          .job-table .even-row {
            background-color: white;
          }

          .job-table .odd-row {
            background-color: #f9fafb; /* bg-gray-50 */
          }

          .job-table td {
            padding: 1rem 1.5rem; /* px-6 py-4 */
            white-space: nowrap;
            font-size: 0.875rem; /* text-sm */
            color: #374151; /* text-gray-900 */
          }

          .job-table td:first-child {
            font-weight: 500; /* font-medium */
          }

          .job-table td:nth-child(3),
          .job-table td:nth-child(4) {
            color: #4b5563; /* text-gray-600 */
          }

          /* New style for clickable job name */
          .job-name-clickable {
            cursor: pointer;
            color: #2563eb; /* blue-600 */
            text-decoration: underline;
            transition: color 0.2s ease;
          }

          .job-name-clickable:hover {
            color: #1e40af; /* blue-800 */
          }


          /* Status Badges */
          .status-badge {
            padding: 0.25rem 0.75rem; /* px-3 py-1 */
            display: inline-flex;
            font-size: 0.75rem; /* text-xs */
            line-height: 1.25; /* leading-5 */
            font-weight: 600; /* font-semibold */
            border-radius: 9999px; /* rounded-full */
          }

          .status-running { background-color: #dcfce7; color: #166534; } /* bg-green-200 text-green-900 */
          .status-pending { background-color: #fef9c3; color: #854d09; } /* bg-yellow-200 text-yellow-900 */
          .status-completed { background-color: #bfdbfe; color: #1e40af; } /* bg-blue-200 text-blue-900 */
          .status-failed { background-color: #fee2e2; color: #991b1b; } /* bg-red-200 text-red-900 */
          .status-held { background-color: #e5e7eb; color: #374151; } /* bg-gray-200 text-gray-900 */
          .status-on-ice { background-color: #bfdbfe; color: #1e40af; } /* bg-blue-200 text-blue-900 (reused blue for consistency) */
          .status-default { background-color: #e5e7eb; color: #374151; } /* bg-gray-200 text-gray-900 */

          /* Job Actions Buttons */
          .job-actions {
            text-align: right;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.5rem; /* space-x-2 */
          }

          .action-button {
            padding: 0.5rem; /* p-2 */
            border-radius: 9999px; /* rounded-full */
            transition: all 0.2s ease; /* transition duration-200 transform hover:scale-110 */
            border: none;
            background: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .action-button:hover:not(.disabled) {
            transform: scale(1.1);
          }

          /* Specific button colors and hover effects */
          .action-force-start { color: #16a34a; } /* text-green-600 */
          .action-force-start:hover:not(.disabled) { background-color: #f0fdf4; color: #15803d; } /* hover:bg-green-50 hover:text-green-800 */

          .action-on-ice { color: #2563eb; } /* text-blue-600 */
          .action-on-ice:hover:not(.disabled) { background-color: #eff6ff; color: #1e40af; } /* hover:bg-blue-50 hover:text-blue-800 */

          .action-on-hold { color: #ca8a04; } /* text-yellow-600 */
          .action-on-hold:hover:not(.disabled) { background-color: #fffbeb; color: #a16207; } /* hover:bg-yellow-50 hover:text-yellow-800 */

          .action-off-hold { color: #4f46e5; } /* text-indigo-600 */
          .action-off-hold:hover:not(.disabled) { background-color: #eef2ff; color: #4338ca; } /* hover:bg-indigo-50 hover:text-indigo-800 */

          .action-kill { color: #dc2626; } /* text-red-600 */
          .action-kill:hover:not(.disabled) { background-color: #fef2f2; color: #b91c1c; } /* hover:bg-red-50 hover:text-red-800 */

          /* New Refresh button styles */
          .action-refresh {
            color: #0ea5e9; /* text-sky-500 */
          }
          .action-refresh:hover:not(.disabled) {
            background-color: #f0f9ff; /* hover:bg-sky-50 */
            color: #0284c7; /* hover:text-sky-700 */
          }

          /* Disabled state for action buttons */
          .action-button.disabled {
            color: #9ca3af; /* text-gray-400 */
            background-color: #f3f4f6; /* bg-gray-100 */
            cursor: not-allowed;
            transform: none; /* Prevent scale on hover for disabled buttons */
          }

          /* Modal Styles */
          .modal-overlay {
            position: fixed;
            inset: 0;
            background-color: rgba(31, 41, 55, 0.6); /* bg-gray-800 bg-opacity-60 */
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem; /* p-4 */
            z-index: 50;
            backdrop-filter: blur(4px); /* backdrop-blur-sm */
          }

          .modal-content {
            background-color: white;
            border-radius: 1rem; /* rounded-2xl */
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); /* shadow-2xl */
            padding: 2rem; /* p-8 */
            width: 100%;
            max-width: 32rem; /* max-w-lg */
            transform: scale(1);
            opacity: 1;
            transition: all 0.3s ease; /* transition duration-300 */
            border: 1px solid #e5e7eb; /* border border-gray-200 */
          }

          .modal-title {
            font-size: 1.875rem; /* text-3xl */
            font-weight: 700; /* font-bold */
            margin-bottom: 1.5rem; /* mb-6 */
            color: #1f2937; /* text-gray-800 */
            text-align: center;
          }

          .form-group {
            margin-bottom: 1rem; /* mb-4 */
          }

          .form-label {
            display: block;
            color: #374151; /* text-gray-700 */
            font-size: 0.875rem; /* text-sm */
            font-weight: 700; /* font-bold */
            margin-bottom: 0.5rem; /* mb-2 */
          }

          .form-input,
          .form-textarea {
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); /* shadow-sm */
            appearance: none;
            border: 1px solid #d1d5db; /* border border-gray-300 */
            border-radius: 0.5rem; /* rounded-lg */
            width: 100%;
            padding: 0.75rem 1rem; /* py-3 px-4 */
            color: #374151; /* text-gray-700 */
            line-height: 1.25; /* leading-tight */
            outline: none;
            transition: all 0.2s ease;
          }

          .form-input:focus,
          .form-textarea:focus {
            border-color: #3b82f6; /* focus:ring-2 focus:ring-blue-500 */
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.5);
          }

          .form-textarea {
            font-family: 'Inter', sans-serif; /* Keep font-mono look */
            font-size: 0.875rem; /* text-sm */
          }

          .error-message {
            color: #dc2626; /* text-red-600 */
            font-size: 0.75rem; /* text-xs */
            font-style: italic;
            margin-top: 0.5rem; /* mt-2 */
          }

          .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 1rem; /* gap-4 */
          }

          .modal-button {
            padding: 0.75rem 1.5rem; /* px-6 py-3 */
            border-radius: 9999px; /* rounded-full */
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.06); /* shadow-lg */
          }

          .modal-button-cancel {
            border: 1px solid #d1d5db; /* border border-gray-300 */
            color: #374151; /* text-gray-700 */
            background-color: #f9fafb; /* bg-gray-50 */
          }

          .modal-button-cancel:hover {
            background-color: #f3f4f6; /* hover:bg-gray-100 */
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); /* shadow-sm */
          }

          .modal-button-cancel:focus {
            outline: none;
            box-shadow: 0 0 0 2px rgba(209, 213, 219, 0.5); /* focus:ring-2 focus:ring-gray-300 */
          }

          .modal-button-save {
            background: linear-gradient(to right, #2563eb, #06b6d4); /* from-blue-600 to-cyan-600 */
            color: white;
          }

          .modal-button-save:hover {
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); /* hover:shadow-xl */
            background: linear-gradient(to right, #1d4ed8, #0891b2); /* hover:from-blue-700 hover:to-cyan-700 */
          }

          .modal-button-save:focus {
            outline: none;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.5); /* focus:ring-4 focus:ring-blue-300 */
          }

          /* Responsive adjustments */
          @media (max-width: 768px) {
            .header-nav-list {
              display: none; /* Hide nav on small screens for simplicity */
            }

            .header-content {
              justify-content: center; /* Center title when nav is hidden */
            }

            .filter-search-container {
              flex-direction: column;
              align-items: stretch;
            }

            .search-input-wrapper,
            .filter-select-wrapper {
              min-width: unset;
              width: 100%;
            }

            .job-actions {
              justify-content: center; /* Center action buttons on small screens */
              flex-wrap: wrap; /* Allow buttons to wrap */
            }

            .job-table th, .job-table td {
              padding: 0.75rem 1rem; /* Smaller padding on small screens */
            }
          }

          @media (max-width: 480px) {
            .header-title {
              font-size: 1.75rem; /* Even smaller title on very small screens */
            }

            .main-content {
              padding: 1rem;
            }

            .job-controls-container,
            .filter-search-container,
            .job-list-container,
            .no-jobs-message,
            .modal-content {
              padding: 1rem;
              border-radius: 0.5rem;
            }

            .add-job-button,
            .modal-button {
              padding: 0.6rem 1.2rem;
              font-size: 0.9rem;
            }
          }

          /* Spin animation for refresh icon */
          @keyframes spin {
            from {
              transform: rotate(0deg);
            }
            to {
              transform: rotate(360deg);
            }
          }

          .animate-spin {
            animation: spin 1s linear infinite;
          }

          /* Definition display textarea */
          .definition-display {
            background-color: #f8fafc; /* bg-gray-50 */
            font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, Courier, monospace;
            font-size: 0.85rem;
            line-height: 1.4;
            resize: vertical; /* Allow vertical resizing */
          }

          .loading-message {
            text-align: center;
            padding: 2rem;
            color: #4b5563;
            font-style: italic;
          }
        `}
      </style>
      <Header />
      <main className="main-content">
        <JobControls
          onAddJob={handleAddJob}
        />
        <JobFilterSearch
          searchTerm={searchTerm}
          onSearchChange={setSearchTerm}
          selectedStatus={selectedStatus}
          onFilterChange={setSelectedStatus}
        />
        <JobList
          jobs={filteredJobs}
          onForceStart={handleForceStart}
          onHold={handleOnHold}
          onOffHold={handleOffHold}
          onKill={handleKill}
          onOnIce={handleOnIce}
          onRefreshData={refreshJobData} // Updated prop name
          loadingJobIds={loadingJobIds} // Pass loading state
          onJobNameClick={handleJobNameClick} // Pass the new click handler
        />

        <JobModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSave={handleSaveJob}
          job={currentJob}
        />

        <JobDefinitionModal
          isOpen={isDefinitionModalOpen}
          onClose={() => setIsDefinitionModalOpen(false)}
          jobName={currentJobNameForDefinition}
          definition={currentJobDefinition}
          isLoading={loadingDefinition}
          error={definitionError}
        />
      </main>
    </div>
  );
};

export default App;
