const express = require('express');
const client = require('prom-client');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const SERVICE_NAME = process.env.SERVICE_NAME || 'demo-service';

// Mutable state for scenario simulation
let state = {
  healthStatus: parseInt(process.env.HEALTH_STATUS || '200'),
  responseDelay: parseInt(process.env.RESPONSE_DELAY || '0'),
};

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [register],
});

const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register],
});

// Middleware: metrics + delay
app.use(async (req, res, next) => {
  if (state.responseDelay > 0) {
    await new Promise(resolve => setTimeout(resolve, state.responseDelay));
  }
  const end = httpDuration.startTimer({ method: req.method, path: req.path });
  res.on('finish', () => {
    httpRequestsTotal.inc({ method: req.method, path: req.path, status: res.statusCode });
    end({ status: res.statusCode });
  });
  next();
});

app.get('/health', (req, res) => {
  if (state.healthStatus !== 200) {
    return res.status(state.healthStatus).json({ status: 'error', code: state.healthStatus, service: SERVICE_NAME });
  }
  res.json({ status: 'ok', service: SERVICE_NAME, uptime: process.uptime() });
});

app.get('/api/status', (req, res) => {
  res.json({
    service: SERVICE_NAME,
    status: state.healthStatus === 200 ? 'ok' : 'degraded',
    health_status: state.healthStatus,
    response_delay_ms: state.responseDelay,
    uptime: process.uptime(),
    memory: process.memoryUsage(),
  });
});

app.post('/control', (req, res) => {
  const { status, delay } = req.body;
  if (status !== undefined) state.healthStatus = status;
  if (delay !== undefined) state.responseDelay = delay;
  res.json({ ok: true, state });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(PORT, () => {
  console.log(`${SERVICE_NAME} running on port ${PORT}`);
});