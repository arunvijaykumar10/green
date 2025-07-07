import type { Dayjs } from 'dayjs';

import React from 'react';

import { Link, TableRow, TableCell } from '@mui/material';

import { RouterLink } from 'src/routes/components';

import { fDate } from 'src/utils/format-time';

import { Label } from 'src/components/label';

interface TableRowProps {
  row: {
    id: number;
    name: string;
    code: string;
    type: string;
    status: string;
    submittedAt: Dayjs;
    reviewedAt: string | Dayjs;
  };
}

const CompaniesTableRow = ({ row }: TableRowProps) => {
  const {  name, type, status, submittedAt, reviewedAt } = row;
  const detailsHref = `/companies/${name}`;
  return (
    <TableRow>
      <TableCell>
        <Link
          component={RouterLink}
          href={detailsHref}
          color="inherit"
          onMouseEnter={(e) => (e.currentTarget.style.textDecoration = 'underline')}
          onMouseLeave={(e) => (e.currentTarget.style.textDecoration = 'none')}
        >
          {name}
        </Link>
      </TableCell>
      <TableCell align="center">{type}</TableCell>
      <TableCell>{fDate(submittedAt)}</TableCell>
      <TableCell>{typeof reviewedAt === 'string' ? reviewedAt : fDate(reviewedAt)}</TableCell>
      <TableCell>
        <Label
          variant="soft"
          color={
            (status === 'approved' && 'success') ||
            (status === 'pending' && 'warning') ||
            (status === 'rejected' && 'error') ||
            'default'
          }
        >
          {status}
        </Label>
      </TableCell>
    </TableRow>
  );
};

export default CompaniesTableRow;
