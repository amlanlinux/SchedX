import React, { useState, useEffect } from 'react';
import { Play, Pause, XCircle, Filter, Search, PlusCircle, RefreshCw, Snowflake } from 'lucide-react'; // Icons

// Dummy data for jobs
const initialJobs = [
  { id: 'job-1', name: 'Daily Data Sync', status: 'Running', lastRun: '2024-07-01 10:00 AM', nextRun: '2024-07-02 10:00 AM', definition: JSON.stringify({ type: 'sync', source: 'DB1', destination: 'DB2', frequency: 'daily' }, null, 2) },
  { id: 'job-2', name: 'Weekly Report Generation', status: 'Pending', lastRun: '2024-06-28 08:00 AM', nextRun: '2024-07-05 08:00 AM', definition: JSON.stringify({ type: 'report', format: 'PDF', recipients: ['user@example.com'], schedule: 'weekly' }, null, 2) },
  { id: 'job-3', name: 'Monthly Backup', status: 'Completed', lastRun: '2024-06-01 02:00 AM', nextRun: '2024-07-01 02:00 AM', definition: JSON.stringify({ type: 'backup', target: '/data/backup', retention: '3 months', full: true }, null, 2) },
  { id: 'job-4', name: 'Hourly Cache Refresh', status: 'Failed', lastRun: '2024-07-01 12:30 PM', nextRun: '2024-07-01 01:30 PM', definition: JSON.stringify({ type: 'cache', service: 'API_Gateway', region: 'us-east-1' }, null, 2) },
  { id: 'job-5', name: 'System Maintenance', status: 'Held', lastRun: '2024-06-15 11:00 PM', nextRun: 'N/A', definition: JSON.stringify({ type: 'maintenance', duration: '2 hours', affectedSystems: ['web-server', 'db-server'] }, null, 2) },
  { id: 'job-6', name: 'User Data Import', status: 'Running', lastRun: '2024-07-01 09:00 AM', nextRun: '2024-07-02 09:00 AM', definition: JSON.stringify({ type: 'import', file: 'users.csv', schema: 'user_schema_v2' }, null, 2) },
  { id: 'job-7', name: 'Notification Service Check', status: 'Completed', lastRun: '2024-07-01 01:00 PM', nextRun: '2024-07-01 02:00 PM', definition: JSON.stringify({ type: 'health_check', service: 'notifications', threshold: '99%' }, null, 2) },
];

// Header Component
const Header = () => (
  <header className="bg-gradient-to-r from-blue-600 to-indigo-700 text-white p-4 shadow-lg rounded-b-lg">
    <div className="container mx-auto flex justify-between items-center">
      <h1 className="text-3xl font-extrabold tracking-tight">SchedX</h1>
      <nav>
        <ul className="flex space-x-6">
          <li><a href="#" className="hover:text-blue-200 transition duration-300">Dashboard</a></li>
          <li><a href="#" className="hover:text-blue-200 transition duration-300">Jobs</a></li>
          <li><a href="#" className="hover:text-blue-200 transition duration-300">Logs</a></li>
          <li><a href="#" className="hover:text-blue-200 transition duration-300">Settings</a></li>
        </ul>
      </nav>
    </div>
  </header>
);

// Job Controls Component (Simplified)
const JobControls = ({ onAddJob }) => (
  <div className="flex flex-wrap gap-4 p-4 bg-white rounded-lg shadow-md mb-6 justify-end">
    <button
      onClick={onAddJob}
      className="flex items-center px-6 py-3 bg-blue-500 text-white rounded-full shadow-md hover:bg-blue-600 transition duration-300 transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-400"
    >
      <PlusCircle className="mr-2" size={20} /> Add New Job
    </button>
  </div>
);

// Job Filter and Search Component
const JobFilterSearch = ({ onFilterChange, onSearchChange, searchTerm, selectedStatus }) => (
  <div className="flex flex-wrap gap-4 p-4 bg-white rounded-lg shadow-md mb-6 items-center">
    <div className="relative flex-grow min-w-[200px]">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
      <input
        type="text"
        placeholder="Search job by name..."
        value={searchTerm}
        onChange={(e) => onSearchChange(e.target.value)}
        className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-400"
      />
    </div>
    <div className="relative flex-grow min-w-[150px]">
      <Filter className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
      <select
        value={selectedStatus}
        onChange={(e) => onFilterChange(e.target.value)}
        className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-full appearance-none bg-white focus:outline-none focus:ring-2 focus:ring-blue-400"
      >
        <option value="All">All Statuses</option>
        <option value="Running">Running</option>
        <option value="Pending">Pending</option>
        <option value="Completed">Completed</option>
        <option value="Failed">Failed</option>
        <option value="Held">Held</option>
        <option value="On Ice">On Ice</option> {/* Added On Ice status */}
      </select>
      <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
        <svg className="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/></svg>
      </div>
    </div>
  </div>
);

// Job List Component
// Now includes per-job action buttons
const JobList = ({ jobs, onForceStart, onHold, onOffHold, onKill, onOnIce }) => {
  const getStatusColor = (status) => {
    switch (status) {
      case 'Running': return 'bg-green-100 text-green-800';
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      case 'Completed': return 'bg-blue-100 text-blue-800';
      case 'Failed': return 'bg-red-100 text-red-800';
      case 'Held': return 'bg-gray-100 text-gray-800';
      case 'On Ice': return 'bg-blue-100 text-blue-800'; // Color for On Ice
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (jobs.length === 0) {
    return (
      <div className="bg-white p-6 rounded-lg shadow-md text-center text-gray-600">
        No jobs found matching your criteria.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Job Name</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Run</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Next Run</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {jobs.map((job) => (
              <tr key={job.id} className="hover:bg-gray-50 transition duration-150">
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{job.name}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(job.status)}`}>
                    {job.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{job.lastRun}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{job.nextRun}</td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium flex items-center space-x-2">
                  <button
                    onClick={() => onForceStart(job.id)}
                    className="text-green-600 hover:text-green-900 transition duration-150 transform hover:scale-110"
                    title="Force Start"
                  >
                    <Play size={18} />
                  </button>
                  <button
                    onClick={() => onOnIce(job.id)}
                    className="text-blue-600 hover:text-blue-900 transition duration-150 transform hover:scale-110"
                    title="On Ice"
                  >
                    <Snowflake size={18} />
                  </button>
                  <button
                    onClick={() => onHold(job.id)}
                    className="text-yellow-600 hover:text-yellow-900 transition duration-150 transform hover:scale-110"
                    title="On Hold"
                  >
                    <Pause size={18} />
                  </button>
                  <button
                    onClick={() => onOffHold(job.id)}
                    className="text-indigo-600 hover:text-indigo-900 transition duration-150 transform hover:scale-110"
                    title="Off Hold"
                  >
                    <RefreshCw size={18} />
                  </button>
                  <button
                    onClick={() => onKill(job.id)}
                    className="text-red-600 hover:text-red-900 transition duration-150 transform hover:scale-110"
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
    // This modal is now primarily for adding new jobs.
    // If 'job' is provided, it means we are in an edit context (which is not
    // directly triggered from the table anymore, but the logic is kept for flexibility).
    if (job) {
      setJobName(job.name);
      setJobDefinition(job.definition);
    } else {
      setJobName('');
      setJobDefinition('');
    }
    setErrorMessage(''); // Clear error on open/job change
  }, [job, isOpen]);

  const handleSave = () => {
    if (!jobName.trim()) {
      setErrorMessage('Job Name cannot be empty.');
      return;
    }
    try {
      // Attempt to parse the definition to ensure it's valid JSON
      JSON.parse(jobDefinition);
      onSave({ ...job, name: jobName, definition: jobDefinition });
      onClose();
    } catch (e) {
      setErrorMessage('Invalid JSON in Job Definition.');
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-75 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg shadow-xl p-6 w-full max-w-lg transform transition-all sm:my-8 sm:w-full">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">{job ? 'Edit Job' : 'Add New Job'}</h2>
        <div className="mb-4">
          <label htmlFor="jobName" className="block text-gray-700 text-sm font-bold mb-2">Job Name:</label>
          <input
            type="text"
            id="jobName"
            value={jobName}
            onChange={(e) => setJobName(e.target.value)}
            className="shadow appearance-none border rounded-lg w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <div className="mb-6">
          <label htmlFor="jobDefinition" className="block text-gray-700 text-sm font-bold mb-2">Job Definition (JSON):</label>
          <textarea
            id="jobDefinition"
            value={jobDefinition}
            onChange={(e) => setJobDefinition(e.target.value)}
            rows="10"
            className="shadow appearance-none border rounded-lg w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 font-mono text-sm"
            placeholder='e.g., {"type": "report", "frequency": "daily"}'
          ></textarea>
          {errorMessage && <p className="text-red-500 text-xs italic mt-2">{errorMessage}</p>}
        </div>
        <div className="flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-5 py-2 border border-gray-300 rounded-full text-gray-700 hover:bg-gray-100 transition duration-300 focus:outline-none focus:ring-2 focus:ring-gray-300"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="flex items-center px-5 py-2 bg-blue-600 text-white rounded-full shadow-md hover:bg-blue-700 transition duration-300 focus:outline-none focus:ring-2 focus:ring-blue-400"
          >
            Save
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
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentJob, setCurrentJob] = useState(null); // Job being edited or null for new job

  // Filtered jobs based on search term and status
  const filteredJobs = jobs.filter(job => {
    const matchesSearch = job.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = selectedStatus === 'All' || job.status === selectedStatus;
    return matchesSearch && matchesStatus;
  });

  // Helper to update job status
  const updateJobStatus = (jobId, newStatus) => {
    setJobs(prevJobs =>
      prevJobs.map(job =>
        job.id === jobId ? { ...job, status: newStatus } : job
      )
    );
  };

  // Per-job action handlers
  const handleForceStart = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Force Starting job: ${job.name}`);
      updateJobStatus(jobId, 'Running');
    }
  };

  const handleOnHold = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Putting job on hold: ${job.name}`);
      updateJobStatus(jobId, 'Held');
    }
  };

  const handleOffHold = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Taking job off hold: ${job.name}`);
      // Decide what status it should go to after being off hold (e.g., Pending or Running if it was held while running)
      updateJobStatus(jobId, 'Pending'); // Default to Pending for demonstration
    }
  };

  const handleKill = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Killing job: ${job.name}`);
      updateJobStatus(jobId, 'Failed'); // Or 'Killed'
    }
  };

  const handleOnIce = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Putting job on ice: ${job.name}`);
      updateJobStatus(jobId, 'On Ice');
    }
  };

  const handleAddJob = () => {
    setCurrentJob(null); // Clear current job for new entry
    setIsModalOpen(true);
  };

  const handleSaveJob = (updatedJob) => {
    if (updatedJob.id) {
      // This path is less likely now, but kept for robustness if editing is re-introduced
      setJobs(jobs.map(job =>
        job.id === updatedJob.id ? { ...job, name: updatedJob.name, definition: updatedJob.definition } : job
      ));
    } else {
      // Add new job
      const newJob = {
        ...updatedJob,
        id: `job-${Date.now()}`, // Simple unique ID
        status: 'Pending', // New jobs start as pending
        lastRun: 'N/A',
        nextRun: 'Scheduled',
      };
      setJobs([...jobs, newJob]);
    }
  };


  return (
    <div className="min-h-screen bg-gray-100 font-sans text-gray-800">
      <style>
        {`
          @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
          body {
            font-family: 'Inter', sans-serif;
          }
        `}
      </style>
      <Header />
      <main className="container mx-auto p-6">
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
        />

        <JobModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSave={handleSaveJob}
          job={currentJob}
        />
      </main>
    </div>
  );
};

export default App;
