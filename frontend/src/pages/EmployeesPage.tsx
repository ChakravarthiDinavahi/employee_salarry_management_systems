import {
  Alert,
  Box,
  Button,
  CircularProgress,
  IconButton,
  Pagination,
  Paper,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Tooltip,
  Typography,
} from '@mui/material'
import { DeleteOutlined, EditOutlined } from '@mui/icons-material'
import { useCallback, useEffect, useState } from 'react'
import {
  createEmployee,
  deleteEmployee,
  fetchEmployees,
  updateEmployee,
} from '../api/employees'
import { EmployeeFormDialog } from '../components/EmployeeFormDialog'
import { useDebounced } from '../hooks/useDebounced'
import type { Employee, EmployeeInput } from '../types/employee'

export function EmployeesPage() {
  const [searchInput, setSearchInput] = useState('')
  const debouncedQ = useDebounced(searchInput.trim(), 350)
  const [page, setPage] = useState(1)
  const limit = 25

  const [rows, setRows] = useState<Employee[]>([])
  const [loading, setLoading] = useState(true)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [meta, setMeta] = useState({
    page: 1,
    pages: 1,
    count: 0,
    items: 25,
    from: 0,
    to: 0,
  })

  const [dialogOpen, setDialogOpen] = useState(false)
  const [dialogMode, setDialogMode] = useState<'create' | 'edit'>('create')
  const [editing, setEditing] = useState<Employee | null>(null)

  useEffect(() => {
    setPage(1)
  }, [debouncedQ])

  const load = useCallback(async () => {
    setLoading(true)
    setLoadError(null)
    try {
      const res = await fetchEmployees({
        q: debouncedQ || undefined,
        page,
        limit,
      })
      setRows(res.data)
      setMeta(res.meta)
    } catch {
      setLoadError('Could not load employees. Is the Rails API running on port 3000?')
      setRows([])
    } finally {
      setLoading(false)
    }
  }, [debouncedQ, page, limit])

  useEffect(() => {
    void load()
  }, [load])

  async function handleDelete(emp: Employee) {
    if (!window.confirm(`Delete ${emp.full_name}?`)) return
    try {
      await deleteEmployee(emp.id)
      await load()
    } catch {
      window.alert('Delete failed.')
    }
  }

  async function handleSubmit(input: EmployeeInput) {
    if (dialogMode === 'create') {
      await createEmployee(input)
    } else if (editing) {
      await updateEmployee(editing.id, input)
    }
    await load()
  }

  function openCreate() {
    setDialogMode('create')
    setEditing(null)
    setDialogOpen(true)
  }

  function openEdit(emp: Employee) {
    setDialogMode('edit')
    setEditing(emp)
    setDialogOpen(true)
  }

  return (
    <Stack spacing={2}>
      <Box
        sx={{
          display: 'flex',
          flexWrap: 'wrap',
          gap: 2,
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <Typography variant="h5" component="h1">
          Employees
        </Typography>
        <Button variant="contained" onClick={openCreate}>
          Add employee
        </Button>
      </Box>

      <TextField
        label="Search"
        placeholder="Name, job, country, or email"
        value={searchInput}
        onChange={(e) => setSearchInput(e.target.value)}
        fullWidth
        size="small"
        sx={{ maxWidth: 480 }}
      />

      {loadError ? <Alert severity="warning">{loadError}</Alert> : null}

      <Paper variant="outlined">
        <TableContainer sx={{ maxHeight: 'min(70vh, 640px)' }}>
          <Table size="small" stickyHeader>
            <TableHead>
              <TableRow>
                <TableCell>ID</TableCell>
                <TableCell>Name</TableCell>
                <TableCell>Job title</TableCell>
                <TableCell>Country</TableCell>
                <TableCell>Email</TableCell>
                <TableCell align="right">Salary</TableCell>
                <TableCell align="right" width={100}>
                  Actions
                </TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 6 }}>
                    <CircularProgress size={28} />
                  </TableCell>
                </TableRow>
              ) : rows.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7}>
                    <Typography color="text.secondary" sx={{ py: 3 }}>
                      No employees match this search.
                    </Typography>
                  </TableCell>
                </TableRow>
              ) : (
                rows.map((row) => (
                  <TableRow key={row.id} hover>
                    <TableCell>{row.id}</TableCell>
                    <TableCell>{row.full_name}</TableCell>
                    <TableCell>{row.job_title}</TableCell>
                    <TableCell>{row.country}</TableCell>
                    <TableCell>{row.email}</TableCell>
                    <TableCell align="right">{row.salary ?? '—'}</TableCell>
                    <TableCell align="right">
                      <Tooltip title="Edit">
                        <IconButton
                          size="small"
                          onClick={() => openEdit(row)}
                          aria-label={`Edit ${row.full_name}`}
                        >
                          <EditOutlined fontSize="small" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Delete">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => void handleDelete(row)}
                          aria-label={`Delete ${row.full_name}`}
                        >
                          <DeleteOutlined fontSize="small" />
                        </IconButton>
                      </Tooltip>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
        <Box
          sx={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: 2,
            px: 2,
            py: 1.5,
            borderTop: 1,
            borderColor: 'divider',
          }}
        >
          <Typography variant="body2" color="text.secondary">
            {meta.count === 0
              ? 'No records'
              : `Showing ${meta.from}–${meta.to} of ${meta.count}`}
          </Typography>
          <Pagination
            count={Math.max(1, meta.pages)}
            page={meta.page}
            onChange={(_, p) => setPage(p)}
            color="primary"
            size="small"
            disabled={loading || meta.pages <= 1}
          />
        </Box>
      </Paper>

      <EmployeeFormDialog
        open={dialogOpen}
        mode={dialogMode}
        employee={editing}
        onClose={() => setDialogOpen(false)}
        onSubmit={handleSubmit}
      />
    </Stack>
  )
}
