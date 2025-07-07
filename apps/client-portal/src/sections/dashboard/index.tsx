import { Card, Container } from '@mui/material';

import { useAuthContext } from 'src/auth/hooks';

import tasks from './tasks';
import TaskList from './TaskList';
import { GreetingCard } from './GreetingsCard';

const DashboardView = () => {
  const { user } = useAuthContext();

  return (
    <Container maxWidth="xl" sx={{ mt: 4, mb: 4 }}>
      <GreetingCard user={user?.user} />
      <Card sx={{ p: 3, borderRadius: 2 }}>
        <TaskList tasks={tasks} />
      </Card>
    </Container>
  );
};

export default DashboardView;
