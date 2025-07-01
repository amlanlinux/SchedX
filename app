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
  <header className="bg-gradient-to-r from-blue-700 to-indigo-800 text-white p-4 shadow-2xl rounded-b-xl">
    <div className="container mx-auto flex justify-between items-center">
      <h1 className="text-3xl font-extrabold tracking-tight text-shadow-lg">SchedX</h1>
      <nav>
        <ul className="flex space-x-6">
          <li><a href="#" className="text-blue-100 hover:text-white transition duration-300 ease-in-out transform hover:scale-105">Dashboard</a></li>
          <li><a href="#" className="text-blue-100 hover:text-white transition duration-300 ease-in-out transform hover:scale-105">Jobs</a></li>
          <li><a href="#" className="text-blue-100 hover:text-white transition duration-300 ease-in-out transform hover:scale-105">Logs</a></li>
          <li><a href="#" className="text-blue-100 hover:text-white transition duration-300 ease-in-out transform hover:scale-105">Settings</a></li>
        </ul>
      </nav>
    </div>
  </header>
);

// Job Controls Component (Simplified)
const JobControls = ({ onAddJob }) => (
  <div className="flex flex-wrap gap-4 p-5 bg-white rounded-xl shadow-xl mb-6 justify-end border border-gray-100">
    <button
      onClick={onAddJob}
      className="flex items-center px-7 py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-full shadow-lg hover:shadow-xl hover:from-purple-700 hover:to-indigo-700 transition duration-300 transform hover:scale-105 focus:outline-none focus:ring-4 focus:ring-purple-300"
    >
      <PlusCircle className="mr-2" size={20} /> Add New Job
    </button>
  </div>
);

// Job Filter and Search Component
const JobFilterSearch = ({ onFilterChange, onSearchChange, searchTerm, selectedStatus }) => (
  <div className="flex flex-wrap gap-4 p-5 bg-white rounded-xl shadow-xl mb-6 items-center border border-gray-100">
    <div className="relative flex-grow min-w-[200px]">
      <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
      <input
        type="text"
        placeholder="Search job by name..."
        value={searchTerm}
        onChange={(e) => onSearchChange(e.target.value)}
        className="w-full pl-12 pr-5 py-3 border border-gray-200 rounded-full focus:outline-none focus:ring-3 focus:ring-blue-400 text-gray-700 placeholder-gray-400 shadow-sm"
      />
    </div>
    <div className="relative flex-grow min-w-[150px]">
      <Filter className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
      <select
        value={selectedStatus}
        onChange={(e) => onFilterChange(e.target.value)}
        className="w-full pl-12 pr-5 py-3 border border-gray-200 rounded-full appearance-none bg-white focus:outline-none focus:ring-3 focus:ring-blue-400 text-gray-700 shadow-sm"
      >
        <option value="All">All Statuses</option>
        <option value="Running">Running</option>
        <option value="Pending">Pending</option>
        <option value="Completed">Completed</option>
        <option value="Failed">Failed</option>
        <option value="Held">Held</option>
        <option value="On Ice">On Ice</option>
      </select>
      <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-gray-700">
        <svg className="fill-current h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/></svg>
      </div>
    </div>
  </div>
);

// Job List Component
const JobList = ({ jobs, onForceStart, onHold, onOffHold, onKill, onOnIce }) => {
  const getStatusColor = (status) => {
    switch (status) {
      case 'Running': return 'bg-green-200 text-green-900';
      case 'Pending': return 'bg-yellow-200 text-yellow-900';
      case 'Completed': return 'bg-blue-200 text-blue-900';
      case 'Failed': return 'bg-red-200 text-red-900';
      case 'Held': return 'bg-gray-200 text-gray-900';
      case 'On Ice': return 'bg-blue-200 text-blue-900';
      default: return 'bg-gray-200 text-gray-900';
    }
  };

  if (jobs.length === 0) {
    return (
      <div className="bg-white p-8 rounded-xl shadow-xl text-center text-gray-600 border border-gray-100">
        No jobs found matching your criteria.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-xl overflow-hidden border border-gray-100">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Job Name</th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Last Run</th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Next Run</th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-100">
            {jobs.map((job, index) => (
              <tr key={job.id} className={`hover:bg-gray-50 transition duration-150 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}`}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{job.name}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(job.status)}`}>
                    {job.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{job.lastRun}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{job.nextRun}</td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium flex items-center space-x-2">
                  <button
                    onClick={() => onForceStart(job.id)}
                    disabled={job.status === 'Running'}
                    className={`p-2 rounded-full transition duration-200 transform hover:scale-110 ${job.status === 'Running' ? 'text-gray-400 cursor-not-allowed bg-gray-100' : 'text-green-600 hover:bg-green-50 hover:text-green-800'}`}
                    title="Force Start"
                  >
                    <Play size={18} />
                  </button>
                  <button
                    onClick={() => onOnIce(job.id)}
                    disabled={job.status === 'Running' || job.status === 'On Ice'}
                    className={`p-2 rounded-full transition duration-200 transform hover:scale-110 ${job.status === 'Running' || job.status === 'On Ice' ? 'text-gray-400 cursor-not-allowed bg-gray-100' : 'text-blue-600 hover:bg-blue-50 hover:text-blue-800'}`}
                    title="On Ice"
                  >
                    <Snowflake size={18} />
                  </button>
                  <button
                    onClick={() => onHold(job.id)}
                    disabled={job.status === 'Held'}
                    className={`p-2 rounded-full transition duration-200 transform hover:scale-110 ${job.status === 'Held' ? 'text-gray-400 cursor-not-allowed bg-gray-100' : 'text-yellow-600 hover:bg-yellow-50 hover:text-yellow-800'}`}
                    title="On Hold"
                  >
                    <Pause size={18} />
                  </button>
                  <button
                    onClick={() => onOffHold(job.id)}
                    disabled={job.status !== 'Held' && job.status !== 'On Ice'} // Only off hold if currently held or on ice
                    className={`p-2 rounded-full transition duration-200 transform hover:scale-110 ${job.status !== 'Held' && job.status !== 'On Ice' ? 'text-gray-400 cursor-not-allowed bg-gray-100' : 'text-indigo-600 hover:bg-indigo-50 hover:text-indigo-800'}`}
                    title="Off Hold"
                  >
                    <RefreshCw size={18} />
                  </button>
                  <button
                    onClick={() => onKill(job.id)}
                    disabled={job.status === 'Completed' || job.status === 'Failed'}
                    className={`p-2 rounded-full transition duration-200 transform hover:scale-110 ${job.status === 'Completed' || job.status === 'Failed' ? 'text-gray-400 cursor-not-allowed bg-gray-100' : 'text-red-600 hover:bg-red-50 hover:text-red-800'}`}
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
    <div className="fixed inset-0 bg-gray-800 bg-opacity-60 flex items-center justify-center p-4 z-50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-lg transform transition-all duration-300 scale-100 opacity-100 border border-gray-200">
        <h2 className="text-3xl font-bold mb-6 text-gray-800 text-center">{job ? 'Edit Job' : 'Add New Job'}</h2>
        <div className="mb-4">
          <label htmlFor="jobName" className="block text-gray-700 text-sm font-bold mb-2">Job Name:</label>
          <input
            type="text"
            id="jobName"
            value={jobName}
            onChange={(e) => setJobName(e.target.value)}
            className="shadow-sm appearance-none border border-gray-300 rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="e.g., Daily Database Backup"
          />
        </div>
        <div className="mb-6">
          <label htmlFor="jobDefinition" className="block text-gray-700 text-sm font-bold mb-2">Job Definition (JSON):</label>
          <textarea
            id="jobDefinition"
            value={jobDefinition}
            onChange={(e) => setJobDefinition(e.target.value)}
            rows="10"
            className="shadow-sm appearance-none border border-gray-300 rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono text-sm"
            placeholder='e.g., {"type": "report", "frequency": "daily"}'
          ></textarea>
          {errorMessage && <p className="text-red-600 text-xs italic mt-2">{errorMessage}</p>}
        </div>
        <div className="flex justify-end gap-4">
          <button
            onClick={onClose}
            className="px-6 py-3 border border-gray-300 rounded-full text-gray-700 bg-gray-50 hover:bg-gray-100 transition duration-300 focus:outline-none focus:ring-2 focus:ring-gray-300 shadow-sm"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="flex items-center px-6 py-3 bg-gradient-to-r from-blue-600 to-cyan-600 text-white rounded-full shadow-lg hover:shadow-xl hover:from-blue-700 hover:to-cyan-700 transition duration-300 focus:outline-none focus:ring-4 focus:ring-blue-300"
          >
            Save Job
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
      // If a job is taken off hold, it typically goes back to pending or running based on its previous state.
      // For simplicity, setting to 'Pending' here.
      updateJobStatus(jobId, 'Pending');
    }
  };

  const handleKill = (jobId) => {
    const job = jobs.find(j => j.id === jobId);
    if (job) {
      alert(`Killing job: ${job.name}`);
      updateJobStatus(jobId, 'Failed');
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
        status: 'Pending',
        lastRun: 'N/A',
        nextRun: 'Scheduled',
      };
      setJobs([...jobs, newJob]);
    }
  };


  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-200 font-sans text-gray-800">
      <style>
        {`
          @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
          body {
            font-family: 'Inter', sans-serif;
          }
          .text-shadow-lg {
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
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
