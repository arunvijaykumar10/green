import React, { useState, useEffect } from 'react';

import { Box, Stack, Drawer, Tooltip, Typography, IconButton } from '@mui/material';

import { Iconify } from 'src/components/iconify';

import { SignatureForm } from './forms/signature/SignatureForm';
import { UnionSetupForm } from './forms/union-setup/UnionSetupForm';
import { BankAccountForm } from './forms/bank-account/BankAccountForm';
import { CompanyDetailsForm } from './forms/company-details/CompanyDetailsForm';

interface TaskFormProps {
  open: boolean;
  onClose: () => void;
  title: string;
  isCompleted?: boolean;
  reviewStatus?: string;
}

const TaskForm: React.FC<TaskFormProps> = ({
  open,
  onClose,
  title,
  isCompleted = false,
  reviewStatus = 'Not Submitted',
}) => {
  const [isEditMode, setIsEditMode] = useState(false);

  useEffect(() => {
    if (open) {
      setIsEditMode(!isCompleted);
    }
  }, [open, isCompleted]);

  const handleClose = () => {
    setIsEditMode(false);
    onClose();
  };

  const renderForm = () => {
    const isViewMode = isCompleted && !isEditMode;

    switch (title) {
      case 'Complete Company Details':
        return (
          <CompanyDetailsForm
            onSubmit={handleClose}
            isViewMode={isViewMode}
            isEditMode={isEditMode}
          />
        );
      case 'Link Bank Account':
        return (
          <BankAccountForm onSubmit={handleClose} isViewMode={isViewMode} isEditMode={isEditMode} />
        );
      case 'Configure Signatures':
        return (
          <SignatureForm onSubmit={handleClose} isViewMode={isViewMode} isEditMode={isEditMode} />
        );
      case 'Setup Unions':
        return (
          <UnionSetupForm onSubmit={handleClose} isViewMode={isViewMode} isEditMode={isEditMode} />
        );
      default:
        return <Typography>Task Not Available</Typography>;
    }
  };

  return (
    <Drawer anchor="right" open={open} onClose={handleClose}>
      <Box
        sx={{
          minHeight: '100%',
          display: 'flex',
          flexDirection: 'column',
          p: { xs: 1, sm: 3 },
          width: { xs: '100vw', md: title === 'Configure Signatures' ? 600 : 500 },
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
          <Box display="flex" gap={1}>
            <Typography variant="h4">{title}</Typography>
            {isCompleted &&
              !isEditMode &&
              reviewStatus !== 'pending' &&
              reviewStatus !== 'approved' && (
                <Tooltip title="edit">
                  <IconButton onClick={() => setIsEditMode(true)}>
                    <Iconify icon="eva:edit-2-fill" width={20} height={20} />
                  </IconButton>
                </Tooltip>
              )}
          </Box>
          <IconButton
            onClick={onClose}
            sx={{
              fontWeight: 'bold',
              '&:hover': { color: 'red' },
            }}
          >
            <Iconify icon="eva:close-fill" width={26} height={26} />
          </IconButton>
        </Box>

        <Stack spacing={2} p={1} direction="column" sx={{ flex: 1 }}>
          {renderForm()}
        </Stack>
      </Box>
    </Drawer>
  );
};

export default TaskForm;
