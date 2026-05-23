'use client';

import { useEffect, useState, useCallback } from 'react';
import SealAward from './SealAward';

/**
 * SealChecker Component
 * 
 * Client component that checks seal conditions and displays award notification.
 * Triggered after chapter completion or message submission.
 * 
 * Requirements: 7.1, 7.4, 8.1, 8.4
 */

interface SealCheckerProps {
  userId: string;
  triggerCheck?: boolean;
  onCheckComplete?: () => void;
}

export default function SealChecker({
  triggerCheck = false,
  onCheckComplete,
}: SealCheckerProps) {
  const [showAward, setShowAward] = useState(false);
  const [awardReason, setAwardReason] = useState<'journey_complete' | 'first_message'>('journey_complete');
  const [isChecking, setIsChecking] = useState(false);

  const checkSealConditions = useCallback(async () => {
    if (isChecking) return;
    
    setIsChecking(true);

    try {
      const response = await fetch('/api/seal/check', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        console.error('Failed to check seal conditions');
        return;
      }

      const data = await response.json();

      if (data.awarded) {
        setAwardReason(data.reason);
        setShowAward(true);
      }
    } catch (error) {
      console.error('Error checking seal conditions:', error);
    } finally {
      setIsChecking(false);
      onCheckComplete?.();
    }
  }, [isChecking, onCheckComplete]);

  useEffect(() => {
    if (triggerCheck && !isChecking) {
      checkSealConditions();
    }
  }, [triggerCheck, checkSealConditions, isChecking]);

  const handleCloseAward = () => {
    setShowAward(false);
  };

  return (
    <SealAward
      show={showAward}
      onClose={handleCloseAward}
      reason={awardReason}
    />
  );
}
