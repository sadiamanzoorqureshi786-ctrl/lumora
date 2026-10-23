import React from 'react';
import { Link } from 'react-router-dom';

function NotFound() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-9xl font-bold text-cyan-400">404</h1>
        <p className="text-2xl text-white mb-8">Page Not Found</p>
        <Link 
          to="/" 
          className="bg-cyan-600 hover:bg-cyan-700 text-white px-8 py-3 rounded-lg font-semibold transition"
        >
          Go Home
        </Link>
      </div>
    </div>
  );
}

export default NotFound;