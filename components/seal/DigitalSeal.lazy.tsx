'use client';

import dynamic from 'next/dynamic';

/**
 * Lazy-loaded DigitalSeal Component
 * 
 * Dynamically imports the DigitalSeal component to reduce initial bundle size.
 * The seal is not critical for initial page load, so we can defer loading it.
 * 
 * Performance optimization for Task 24.1
 */

const DigitalSeal = dynamic(() => import('./DigitalSeal'), {
  loading: () => (
    <div className="inline-flex items-center gap-2 px-3 py-2 bg-gray-800 rounded-lg animate-pulse min-h-[44px]">
      <div className="w-5 h-5 bg-gray-700 rounded-full" />
      <div className="h-4 w-32 bg-gray-700 rounded" />
    </div>
  ),
  ssr: false,
});

export default DigitalSeal;
