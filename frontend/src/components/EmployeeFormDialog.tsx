import {
  Alert,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Stack,
  TextField,
} from '@mui/material'
import axios from 'axios'
import { useEffect, useState } from 'react'
import type { Employee, EmployeeInput } from '../types/employee'

const empty: EmployeeInput = {
  first_name: '',
  last_name: '',
  job_title: '',
  country: '',
  email: '',
  salary: '',
}

type Props = {
  open: boolean
  mode: 'create' | 'edit'
  employee: Employee | null
  onClose: () => void
  onSubmit: (input: EmployeeInput) => Promise<void>
}

export function EmployeeFormDialog({
  open,
  mode,
  employee,
  onClose,
  onSubmit,
}: Props) {
  const [values, setValues] = useState<EmployeeInput>(empty)
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!open) return
    setError(null)
    if (employee && mode === 'edit') {
      setValues({
        first_name: employee.first_name,
        last_name: employee.last_name,
        job_title: employee.job_title,
        country: employee.country,
        email: employee.email,
        salary: employee.salary ?? '',
      })
    } else {
      setValues(empty)
    }
  }, [open, employee, mode])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    setSaving(true)
    try {
      await onSubmit(values)
      onClose()
    } catch (err: unknown) {
      if (axios.isAxiosError(err) && err.response?.data) {
        const body = err.response.data as { errors?: string[] }
        if (Array.isArray(body.errors) && body.errors.length > 0) {
          setError(body.errors.join(' '))
          return
        }
      }
      setError('Could not save employee.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      <form onSubmit={handleSubmit}>
        <DialogTitle>
          {mode === 'create' ? 'Add employee' : 'Edit employee'}
        </DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            {error ? <Alert severity="error">{error}</Alert> : null}
            <TextField
              required
              label="First name"
              value={values.first_name}
              onChange={(e) =>
                setValues((v) => ({ ...v, first_name: e.target.value }))
              }
              fullWidth
            />
            <TextField
              required
              label="Last name"
              value={values.last_name}
              onChange={(e) =>
                setValues((v) => ({ ...v, last_name: e.target.value }))
              }
              fullWidth
            />
            <TextField
              required
              label="Job title"
              value={values.job_title}
              onChange={(e) =>
                setValues((v) => ({ ...v, job_title: e.target.value }))
              }
              fullWidth
            />
            <TextField
              required
              label="Country"
              value={values.country}
              onChange={(e) =>
                setValues((v) => ({ ...v, country: e.target.value }))
              }
              fullWidth
            />
            <TextField
              required
              type="email"
              label="Email"
              value={values.email}
              onChange={(e) =>
                setValues((v) => ({ ...v, email: e.target.value }))
              }
              fullWidth
            />
            <TextField
              required
              type="number"
              slotProps={{
                htmlInput: { step: '0.01', min: '0' },
              }}
              label="Salary"
              value={values.salary}
              onChange={(e) =>
                setValues((v) => ({ ...v, salary: e.target.value }))
              }
              fullWidth
            />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose} disabled={saving}>
            Cancel
          </Button>
          <Button type="submit" variant="contained" disabled={saving}>
            {saving ? 'Saving…' : 'Save'}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  )
}
