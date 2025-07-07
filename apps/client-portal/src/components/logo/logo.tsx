import type { LinkProps } from '@mui/material/Link';

import { forwardRef } from 'react';
import { mergeClasses } from 'minimal-shared/utils';

import Link from '@mui/material/Link';
import { styled } from '@mui/material/styles';

import { RouterLink } from 'src/routes/components';

import { logoClasses } from './classes';

// ----------------------------------------------------------------------

export type LogoProps = LinkProps & {
  logoVariant?: 'primary' | 'secondary' | 'avatar';
  disabled?: boolean;
};

export const Logo = forwardRef<HTMLAnchorElement, LogoProps>((props, ref) => {
  const { className, href = '/', logoVariant: variant = 'primary', disabled, sx, ...other } = props;

  const getLogoImage = (vart: 'primary' | 'secondary' | 'avatar') => {
    switch (vart) {
      case 'primary':
        return '/logo-assets/Logo Assets/01-Primary-Logo/Dark Green/Greenroom-PrimaryLogo-DarkGreen.svg';
      case 'secondary':
        return '/logo-assets/Logo Assets/02-Secondary-Logo/Dark Green/Greenroom-SecondaryLogo-DarkGreen.svg';
      case 'avatar':
        return '/logo-assets/Logo Assets/03-Avatar/Dark Green/Greenroom-Avatar-DarkGreen.svg';
      default:
        return '/logo-assets/Logo Assets/01-Primary-Logo/Dark Green/Greenroom-PrimaryLogo-DarkGreen.svg';
    }
  };

  const logoImage = getLogoImage(variant);

  return (
    <LogoRoot
      ref={ref}
      component={RouterLink}
      href={href}
      aria-label="Logo"
      underline="none"
      className={mergeClasses([logoClasses.root, className])}
      sx={[
        () => ({
          height: 32,
          width: '100%',
          ...(variant === 'primary' && { pr: 3, my: 3 }),
          ...(disabled && { pointerEvents: 'none' }),
        }),
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
      {...other}
    >
      <img src={logoImage} alt="Logo" width="100%" height="100%" />
    </LogoRoot>
  );
});

// ----------------------------------------------------------------------

const LogoRoot = styled(Link)(() => ({
  flexShrink: 0,
  color: 'transparent',
  display: 'inline-flex',
  verticalAlign: 'middle',
}));
