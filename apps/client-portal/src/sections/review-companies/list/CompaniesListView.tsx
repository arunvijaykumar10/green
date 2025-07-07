import type { Dayjs } from 'dayjs';
import type { TableHeadCellProps } from 'src/components/table';

import _ from 'lodash';
import dayjs from 'dayjs';
import { useCallback } from 'react';
import { varAlpha } from 'minimal-shared/utils';
import { useSetState } from 'minimal-shared/hooks';

import { Box, Tab, Card, Tabs, Table, TableBody } from '@mui/material';

import { fIsAfter, fIsBetween } from 'src/utils/format-time';

import { useListQuery } from 'src/pages/companies/api';
import { useListCompaniesQuery } from 'src/pages/review-companies/api';

import { Label } from 'src/components/label';
import { Scrollbar } from 'src/components/scrollbar';
import {
  useTable,
  TableNoData,
  getComparator,
  TableHeadCustom,
  TablePaginationCustom,
} from 'src/components/table';

import CompaniesTableRow from './CompaniesTableRow';
import { CompaniesTableToolbar } from './CompaniesTableToolbar';
import { CompaniesTableFiltersResult } from './CompaniesTableFilterResult';

interface TableFilters {
  name: string;
  status: string;
  startDate: Dayjs | null;
  endDate: Dayjs | null;
}

interface TableItem {
  id: number;
  name: string;
  code: string;
  type: string;
  status: string;
  submittedAt: Dayjs;
  reviewedAt: string | Dayjs;
}

const TABLE_HEAD: TableHeadCellProps[] = [
  { id: 'name', label: 'Company name' },
  { id: 'type', label: 'Company Type', align: 'center' },
  { id: 'submitedAt', label: 'Submitted Date' },
  { id: 'reviewedAt', label: 'Reviewed data' },
  { id: 'status', label: 'Status' },
];

const STATUS_OPTIONS = [
  {
    label: 'All',
    value: 'all',
  },
  {
    label: 'Pending',
    value: 'pending',
  },
  {
    label: 'Approved',
    value: 'approved',
  },

  {
    label: 'Rejected',
    value: 'rejected',
  },
];

const CompaniesListView = () => {
  const table = useTable();
  const { data: companiesData } = useListCompaniesQuery();
  const filters = useSetState<TableFilters>({
    name: '',
    status: 'all',
    startDate: null,
    endDate: null,
  });
  const { state: currentFilters, setState: updateFilters } = filters;

  const { data: companyResponse } = useListQuery();
  const approvedCompanies = companyResponse?.data.companies || [];
  const companies = companiesData?.data.company_reviews || [];
  const tableData = _.uniqBy(
    [
      ...companies.map((company) => ({
        id: company.company.id,
        name: company.company.name,
        code: company.company.code,
        type: company.company.company_type,
        status: company.status,
        submittedAt: dayjs(company.submitted_at),
        reviewedAt: company.reviewed_at ? dayjs(company.reviewed_at) : 'Not Reviewed',
      })),
      ...approvedCompanies.map((company) => ({
        id: company.id,
        name: company.name,
        code: company.code,
        type: company.company_type,
        status: company.approved ? 'approved' : 'rejected',
        submittedAt: dayjs(company.created_at),
        reviewedAt: company.updated_at ? dayjs(company.updated_at) : 'Not Reviewed',
      })),
    ],
    (datum) => datum.name
  );

  const dateError = fIsAfter(currentFilters.startDate, currentFilters.endDate);

  const dataFiltered = applyFilter({
    inputData: tableData,
    comparator: getComparator(table.order, table.orderBy),
    filters: currentFilters,
    dateError,
  });

  const canReset =
    !!currentFilters.name ||
    currentFilters.status !== 'all' ||
    (!!currentFilters.endDate && !!currentFilters.startDate);

  const handleFilterStatus = useCallback(
    (event: React.SyntheticEvent, newValue: string) => {
      table.onResetPage();
      updateFilters({ status: newValue });
    },
    [updateFilters, table]
  );

  const notFound = (!dataFiltered.length && canReset) || !dataFiltered.length;
  return (
    <Card sx={{ m: 3 }}>
      <Tabs
        value={currentFilters.status}
        onChange={handleFilterStatus}
        sx={[
          (theme) => ({
            px: 2.5,
            boxShadow: `inset 0 -2px 0 0 ${varAlpha(theme.vars.palette.grey['500Channel'], 0.08)}`,
          }),
        ]}
      >
        {STATUS_OPTIONS.map((tab) => (
          <Tab
            key={tab.value}
            iconPosition="end"
            value={tab.value}
            label={tab.label}
            icon={
              <Label
                variant={
                  ((tab.value === 'all' || tab.value === currentFilters.status) && 'filled') ||
                  'soft'
                }
                color={
                  (tab.value === 'approved' && 'success') ||
                  (tab.value === 'pending' && 'warning') ||
                  (tab.value === 'rejected' && 'error') ||
                  'default'
                }
              >
                {['approved', 'pending', 'rejected'].includes(tab.value)
                  ? tableData.filter((user) => user.status === tab.value).length
                  : tableData.length}
              </Label>
            }
          />
        ))}
      </Tabs>
      <CompaniesTableToolbar
        filters={filters}
        onResetPage={table.onResetPage}
        dateError={dateError}
      />
      {canReset && (
        <CompaniesTableFiltersResult
          filters={filters}
          totalResults={table.selected.length}
          onResetPage={table.onResetPage}
          sx={{ p: 2.5 }}
        />
      )}
      <Box sx={{ position: 'relative' }}>
        <Scrollbar sx={{ minHeight: 444 }}>
          <Table sx={{ minWidth: 960 }}>
            <TableHeadCustom headCells={TABLE_HEAD} />

            <TableBody>
              {_.map(
                dataFiltered.slice(
                  table.page * table.rowsPerPage,
                  table.page * table.rowsPerPage + table.rowsPerPage
                ),
                (row) => (
                  <CompaniesTableRow key={row.id} row={row} />
                )
              )}
              <TableNoData notFound={notFound} />
            </TableBody>
          </Table>
        </Scrollbar>
      </Box>
      <TablePaginationCustom
        page={table.page}
        count={dataFiltered.length}
        rowsPerPage={table.rowsPerPage}
        onPageChange={table.onChangePage}
        onRowsPerPageChange={table.onChangeRowsPerPage}
      />
    </Card>
  );
};

export default CompaniesListView;

// ----------------------------------------------------------------------

type ApplyFilterProps = {
  dateError: boolean;
  inputData: TableItem[];
  filters: TableFilters;
  comparator: (a: any, b: any) => number;
};

function applyFilter({ inputData, comparator, filters, dateError }: ApplyFilterProps) {
  const { status, name, startDate, endDate } = filters;

  const stabilizedThis = inputData.map((el, index) => [el, index] as const);

  stabilizedThis.sort((a, b) => {
    const order = comparator(a[0], b[0]);
    if (order !== 0) return order;
    return a[1] - b[1];
  });

  inputData = stabilizedThis.map((el) => el[0]);

  if (name) {
    inputData = inputData.filter((item) =>
      [item.name, item.code].some((field) => field?.toLowerCase().includes(name.toLowerCase()))
    );
  }

  if (status !== 'all') {
    inputData = inputData.filter((item) => item.status === status);
  }

  if (!dateError && startDate && endDate) {
    inputData = inputData.filter((item) => fIsBetween(item.submittedAt, startDate, endDate));
  }

  return inputData;
}
