import _ from 'lodash';
import React, { useState } from 'react';

import { Box, Card, Stack, Button, Typography, CardContent } from '@mui/material';

import { useCompany } from 'src/pages/companies/hooks';
import { useGetReviewStatusQuery, useSubmitForReviewMutation } from 'src/pages/companies/api';

import { Iconify } from 'src/components/iconify';

import { useAuthContext } from 'src/auth/hooks';

import TaskForm from './TaskForm';

type Task = {
  title: string;
  description: string;
};

type Props = {
  tasks: Task[];
};

const getIsCompleted = (task: string, companyDetails: any): boolean => {
  if (!companyDetails) return false;
  switch (task) {
    case 'Complete Company Details':
      return !!(
        companyDetails?.name &&
        companyDetails?.company_type &&
        companyDetails?.fein &&
        companyDetails?.nys_no &&
        companyDetails?.phone &&
        !_.isEmpty(companyDetails?.addresses) &&
        companyDetails?.payroll_config &&
        companyDetails?.payroll_config.frequency &&
        companyDetails?.payroll_config.period &&
        companyDetails?.payroll_config.start_date &&
        companyDetails?.payroll_config.check_start_number
      );
    case 'Link Bank Account':
      return !!(
        companyDetails?.bank_config?.bank_name &&
        companyDetails?.bank_config?.routing_number_ach &&
        companyDetails?.bank_config?.routing_number_wire &&
        companyDetails?.bank_config?.account_number &&
        companyDetails?.bank_config?.account_type &&
        companyDetails?.bank_config?.authorized
      );
    case 'Setup Unions':
      return !!(companyDetails?.union_config &&
      companyDetails?.union_config?.union_type === 'non-union'
        ? true
        : companyDetails?.union_config &&
          companyDetails?.union_config?.union_name &&
          companyDetails?.union_config?.agreement_type &&
          companyDetails?.union_config?.agreement_type_configuration?.aea_employer_id);
    case 'Configure Signatures':
      return companyDetails?.signature_type && companyDetails?.signature_type === 'single'
        ? !!companyDetails.signature_url
        : !!companyDetails.signature_url && !!companyDetails.secondary_signature_url;
    default:
      return false;
  }
};

const TaskList: React.FC<Props> = ({ tasks }) => {
  const [selectedTask, setSelectedTask] = useState<string | null>(null);
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id || null;
  const { company } = useCompany(currentCompanyId);
  const [submitForReview] = useSubmitForReviewMutation();

  const isDisableReviewButton = tasks
    .slice(0, 4)
    .map((task) => getIsCompleted(task.title, company))
    .includes(false);

  const { data } = useGetReviewStatusQuery(currentCompanyId, {
    skip: !currentCompanyId || isDisableReviewButton,
  });

  const reviewStatus = data?.data.review_status.status || 'Not Submitted';

  return (
    <>
      <Stack spacing={2}>
        {tasks.map((task) => {
          if (task.title === 'Send to Greenroom for Review') {
            return (
              <Box
                key={task.title}
                sx={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 2,
                  p: 3,
                  borderRadius: 2,
                  background:
                    reviewStatus === 'pending'
                      ? (theme) =>
                          `linear-gradient(135deg, ${theme.palette.primary.light}20 0%, ${theme.palette.primary.light}10 100%)`
                      : reviewStatus === 'approved'
                        ? (theme) =>
                            `linear-gradient(135deg, ${theme.palette.success.light}20 0%, ${theme.palette.success.light}10 100%)`
                        : reviewStatus === 'rejected'
                          ? (theme) =>
                              `linear-gradient(135deg, ${theme.palette.error.light}20 0%, ${theme.palette.error.light}10 100%)`
                          : 'transparent',
                  border:
                    reviewStatus === 'pending'
                      ? (theme) => `2px solid ${theme.palette.primary.main}`
                      : reviewStatus === 'approved'
                        ? (theme) => `2px solid ${theme.palette.success.main}`
                        : reviewStatus === 'rejected'
                          ? (theme) => `2px solid ${theme.palette.error.main}`
                          : 'none',
                }}
              >
                {reviewStatus === 'pending' ? (
                  <>
                    <Iconify
                      icon="streamline-ultimate:loading-bold"
                      width={32}
                      height={32}
                      sx={{
                        color: 'primary.main',
                        animation: 'spin 3s linear infinite',
                        '@keyframes spin': {
                          '0%': { transform: 'rotate(0deg)' },
                          '100%': { transform: 'rotate(360deg)' },
                        },
                      }}
                    />
                    <Typography variant="h6" sx={{ color: 'primary.dark', fontWeight: 600 }}>
                      TrackC is reviewing your information. It can take 2-3 working days
                    </Typography>
                  </>
                ) : reviewStatus === 'approved' ? (
                  <>
                    <Iconify
                      icon="mdi:check-circle"
                      width={32}
                      height={32}
                      sx={{ color: 'success.main' }}
                    />
                    <Typography variant="h6" sx={{ color: 'success.dark', fontWeight: 600 }}>
                      Your company has been approved! You can now start using TrackC.
                    </Typography>
                  </>
                ) : reviewStatus === 'rejected' ? (
                  <>
                    <Iconify
                      icon="mdi:close-circle"
                      width={32}
                      height={32}
                      sx={{ color: 'error.main', mr: 2, flexShrink: 0 }}
                    />
                    <Box sx={{ flex: 1 }}>
                      <Typography variant="h6" sx={{ color: 'error.dark', fontWeight: 600, mb: 1 }}>
                        Your submission needs attention. Please review and resubmit.
                      </Typography>

                      <Typography
                        variant="body2"
                        sx={{
                          color: 'error.main',
                          mb: 2,
                          p: 1.5,
                          bgcolor: 'error.lighter',
                          borderRadius: 1,
                          border: (theme) => `1px solid ${theme.palette.error.light}`,
                        }}
                      >
                        <strong>Notes:</strong>{' '}
                        {data?.data.review_status?.notes || 'No additional information provided.'}
                      </Typography>

                      <Button
                        variant="contained"
                        color="error"
                        size="small"
                        sx={{
                          fontWeight: 600,
                          '&:hover': {
                            transform: 'translateY(-1px)',
                            boxShadow: 2,
                          },
                        }}
                        onClick={() => submitForReview(currentCompanyId)}
                      >
                        Resubmit for Review
                      </Button>
                    </Box>
                  </>
                ) : (
                  <>
                    <Button
                      variant="contained"
                      color="primary"
                      disabled={isDisableReviewButton}
                      onClick={() => submitForReview(currentCompanyId)}
                      sx={{
                        px: 4,
                        py: 1.5,
                        borderRadius: 2,
                        fontWeight: 600,
                        background: (theme) =>
                          `linear-gradient(45deg, ${theme.palette.primary.main} 30%, ${theme.palette.primary.light} 90%)`,
                        boxShadow: (theme) => `0 3px 5px 2px ${theme.palette.primary.main}30`,
                        '&:hover': {
                          background: (theme) =>
                            `linear-gradient(45deg, ${theme.palette.primary.dark} 30%, ${theme.palette.primary.main} 90%)`,
                          transform: 'translateY(-2px)',
                          boxShadow: (theme) => `0 6px 10px 2px ${theme.palette.primary.main}40`,
                        },
                        '&:disabled': {
                          background: (theme) => theme.palette.grey[300],
                          color: (theme) => theme.palette.grey[500],
                          boxShadow: 'none',
                          cursor: 'not-allowed',
                        },
                      }}
                    >
                      {task.title}
                    </Button>
                    <Typography variant="body2" color="text.secondary">
                      due date - July 31, 2025
                    </Typography>
                  </>
                )}
              </Box>
            );
          }

          const isCompleted = getIsCompleted(task.title, company);
          const borderColor = isCompleted ? 'success.main' : 'error.main';
          const indexOfTask = _.indexOf(tasks, task);
          const isDisableForm = indexOfTask < 4 ? false : reviewStatus === 'Not Submitted';

          return (
            <Card
              key={task.title}
              variant="outlined"
              sx={{
                borderLeft: `7px solid`,
                borderLeftColor: borderColor,
              }}
            >
              <CardContent>
                <Typography variant="subtitle1" fontWeight="bold">
                  {task.title}
                </Typography>
                <Typography variant="body2" color="text.secondary" mt={0.5}>
                  {task.description}
                </Typography>
                <Box mt={2}>
                  <Button
                    variant="outlined"
                    onClick={() => setSelectedTask(task.title)}
                    color="primary"
                    disabled={isDisableForm}
                  >
                    {isCompleted ? 'View Form' : 'Start'}
                  </Button>
                  {task.title === 'Onboard people and Organizations' && (
                    <Typography variant="body2" color="text.secondary" component="span" ml={2}>
                      due date - Aug 27, 2024
                    </Typography>
                  )}
                </Box>
              </CardContent>
            </Card>
          );
        })}
      </Stack>
      <TaskForm
        open={!!selectedTask}
        onClose={() => setSelectedTask(null)}
        title={selectedTask || ''}
        isCompleted={selectedTask ? getIsCompleted(selectedTask, company) : false}
        reviewStatus={reviewStatus}
      />
    </>
  );
};

export default TaskList;
