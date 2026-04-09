import { AppBar, Box, Container, Tab, Tabs, Toolbar, Typography } from '@mui/material'
import { Link as RouterLink, Outlet, useLocation } from 'react-router-dom'

export function Layout() {
  const location = useLocation()
  const tab =
    location.pathname.startsWith('/insights') ? '/insights' : '/employees'

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <AppBar position="static" color="default" elevation={1}>
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 0, mr: 3 }}>
            Employee Salary
          </Typography>
          <Tabs
            value={tab}
            textColor="primary"
            indicatorColor="primary"
            sx={{ flexGrow: 1 }}
          >
            <Tab
              label="Employees"
              value="/employees"
              component={RouterLink}
              to="/employees"
            />
            <Tab
              label="Salary insights"
              value="/insights"
              component={RouterLink}
              to="/insights"
            />
          </Tabs>
        </Toolbar>
      </AppBar>
      <Container maxWidth="xl" sx={{ py: 3, flex: 1 }}>
        <Outlet />
      </Container>
    </Box>
  )
}
