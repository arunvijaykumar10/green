import { Card, Typography } from '@mui/material';

type GreetingCardProps = {
  user?: {
    full_name?: string;
  };
};

export const GreetingCard = ({ user }: GreetingCardProps) => (
  <Card sx={{ p: 3, mb: 3, borderRadius: 2 }}>
    <Typography variant="h4" sx={{ mb: 1 }}>
      Hi!, {user?.full_name || 'User'}
    </Typography>
    <Typography variant="body1" color="text.secondary">
      Additional information needs to be captured and submitted
    </Typography>
  </Card>
);
