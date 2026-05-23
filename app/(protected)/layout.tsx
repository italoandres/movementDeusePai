import { SessionProvider } from '@/components/providers/SessionProvider';

/**
 * Protected Routes Layout
 * 
 * Wraps all protected routes with session management.
 * Automatically refreshes sessions and handles expiration.
 * 
 * Requirements: 14.2, 14.3, 14.4
 */
export default function ProtectedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <SessionProvider>
      {children}
    </SessionProvider>
  );
}
