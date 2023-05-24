import React, { ReactNode } from 'react';
import CssBaseline from '@mui/material/CssBaseline';
import Container from '@mui/material/Container';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Navigation from './Navigation';
import Copyright from './Copyright';


// TODO remove, this demo shouldn't need to reset the theme.
const defaultTheme = createTheme();

function Layout(props: { children: ReactNode }) {
  return (
    <>
      <ThemeProvider theme={defaultTheme}>
        <Container component="main" maxWidth="xs">
          <CssBaseline />
          <Navigation />
          <>{props.children}</>
          <Copyright sx={{ mt: 8, mb: 4 }} />
        </Container>
      </ThemeProvider>
    </>
  )
}

export default Layout;