export const getColor = (sts: string) => {
  switch (sts) {
    case 'approved':
      return 'success';
    case 'rejected':
      return 'error';
    default:
      return 'warning';
  }
};