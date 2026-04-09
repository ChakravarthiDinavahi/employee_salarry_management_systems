import {
  Alert,
  Paper,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
} from '@mui/material'
import { useEffect, useMemo, useState } from 'react'
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { fetchSalaryInsights } from '../api/salaryInsights'
import type { SalaryInsightsPayload } from '../types/insights'

export function InsightsPage() {
  const [data, setData] = useState<SalaryInsightsPayload | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const payload = await fetchSalaryInsights()
        if (!cancelled) setData(payload)
      } catch {
        if (!cancelled) {
          setError(
            'Could not load insights. Is the Rails API running on port 3000?',
          )
          setData(null)
        }
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    void load()
    return () => {
      cancelled = true
    }
  }, [])

  const avgByCountryChart = useMemo(() => {
    if (!data) return []
    return Object.entries(data.average_salary_by_country)
      .map(([country, avg]) => ({
        country,
        average: parseFloat(avg),
      }))
      .filter((d) => Number.isFinite(d.average))
      .sort((a, b) => b.average - a.average)
      .slice(0, 24)
  }, [data])

  const minMaxRows = useMemo(() => {
    if (!data) return []
    return Object.entries(data.min_max_salary_by_country).sort(([a], [b]) =>
      a.localeCompare(b),
    )
  }, [data])

  const titleCountryRows = data?.average_salary_by_job_title_and_country ?? []

  return (
    <Stack spacing={3}>
      <Typography variant="h5" component="h1">
        Salary insights
      </Typography>

      {error ? <Alert severity="warning">{error}</Alert> : null}

      {loading ? (
        <Typography color="text.secondary">Loading aggregates…</Typography>
      ) : null}

      {!loading && data ? (
        <>
          <Paper variant="outlined" sx={{ p: 2 }}>
            <Typography variant="subtitle1" gutterBottom>
              Average salary by country (top 24)
            </Typography>
            <ResponsiveContainer width="100%" height={360}>
              <BarChart
                data={avgByCountryChart}
                margin={{ top: 8, right: 8, left: 8, bottom: 64 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis
                  dataKey="country"
                  angle={-35}
                  textAnchor="end"
                  height={72}
                  interval={0}
                  tick={{ fontSize: 11 }}
                />
                <YAxis
                  tickFormatter={(v) =>
                    typeof v === 'number' ? v.toLocaleString() : String(v)
                  }
                />
                <Tooltip
                  formatter={(value) =>
                    typeof value === 'number'
                      ? value.toLocaleString(undefined, {
                          minimumFractionDigits: 2,
                          maximumFractionDigits: 2,
                        })
                      : String(value ?? '')
                  }
                />
                <Bar dataKey="average" fill="#1976d2" name="Average" />
              </BarChart>
            </ResponsiveContainer>
          </Paper>

          <Paper variant="outlined">
            <Typography variant="subtitle1" sx={{ px: 2, pt: 2, pb: 1 }}>
              Min / max salary by country
            </Typography>
            <TableContainer sx={{ maxHeight: 360 }}>
              <Table size="small" stickyHeader>
                <TableHead>
                  <TableRow>
                    <TableCell>Country</TableCell>
                    <TableCell align="right">Min</TableCell>
                    <TableCell align="right">Max</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {minMaxRows.map(([country, mm]) => (
                    <TableRow key={country}>
                      <TableCell>{country}</TableCell>
                      <TableCell align="right">{mm.min}</TableCell>
                      <TableCell align="right">{mm.max}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>

          <Paper variant="outlined">
            <Typography variant="subtitle1" sx={{ px: 2, pt: 2, pb: 1 }}>
              Average salary by job title and country
            </Typography>
            <TableContainer sx={{ maxHeight: 480 }}>
              <Table size="small" stickyHeader>
                <TableHead>
                  <TableRow>
                    <TableCell>Job title</TableCell>
                    <TableCell>Country</TableCell>
                    <TableCell align="right">Average</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {titleCountryRows.map((row, i) => (
                    <TableRow key={`${row.job_title}-${row.country}-${i}`}>
                      <TableCell>{row.job_title}</TableCell>
                      <TableCell>{row.country}</TableCell>
                      <TableCell align="right">{row.average}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>
        </>
      ) : null}
    </Stack>
  )
}
