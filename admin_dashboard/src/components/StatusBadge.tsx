import React from 'react';

interface StatusBadgeProps {
  status: string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const s = (status || 'Placed').toLowerCase();

  let className = 'badge badge-placed';

  if (s.includes('delivered')) {
    className = 'badge badge-success';
  } else if (s.includes('cancel')) {
    className = 'badge badge-danger';
  } else if (s.includes('wash') || s.includes('clean') || s.includes('iron') || s.includes('way') || s.includes('progress')) {
    className = 'badge badge-progress';
  } else if (s.includes('pickup') || s.includes('assign') || s.includes('store') || s.includes('ready') || s.includes('check')) {
    className = 'badge badge-placed';
  }

  return (
    <span className={className}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', backgroundColor: 'currentColor' }}></span>
      {status}
    </span>
  );
};
