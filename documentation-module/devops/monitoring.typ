// Monitoring, Logging, and Observability - FlutterGristAPI
// Comprehensive guide to system monitoring and logging

#import "../common/styles.typ": *

= Monitoring, Logging, and Observability

This chapter covers monitoring infrastructure health, analyzing logs, and maintaining observability of the FlutterGristAPI system.

== Monitoring Overview

=== What to Monitor

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Category*], [*Metrics*], [*Priority*],

  [*Container Health*], [Status, restarts, exit codes], [High],
  [*Resource Usage*], [CPU, memory, disk, network], [High],
  [*Application*], [Grist availability, API response times], [High],
  [*Data*], [Database size, backup status], [Medium],
  [*Logs*], [Error rates, warning patterns], [Medium],
  [*Network*], [Port availability, connectivity], [Low],
)

=== Monitoring Strategy

*Levels of Monitoring:*

1. *Reactive*: Check when issues occur
2. *Proactive*: Regular scheduled checks
3. *Automated*: Continuous monitoring with alerts

This guide focuses on levels 1-2. For level 3, consider implementing:
- Prometheus + Grafana for metrics
- ELK Stack (Elasticsearch, Logstash, Kibana) for logs
- Alertmanager for notifications

== Container Health Monitoring

=== Quick Status Check

```bash
# View all containers
docker ps

# Expected output:
# CONTAINER ID   IMAGE                  STATUS         PORTS                    NAMES
# abc123...      gristlabs/grist:latest Up 2 hours    0.0.0.0:8484->8484/tcp  grist_server
```

*Status Indicators:*
- `Up X hours/days`: Healthy, running
- `Restarting`: Container crashing repeatedly
- `Exited (0)`: Stopped successfully
- `Exited (1)`: Stopped with error

=== Detailed Container Status

```bash
# Docker Compose status
docker-compose ps

# Example output:
#     Name              Command           State           Ports
# ----------------------------------------------------------------
# grist_server   /usr/bin/tini...    Up      0.0.0.0:8484->8484/tcp

# Show all containers (including stopped)
docker-compose ps -a

# Check specific service
docker-compose ps grist
```

=== Container Restart Monitoring

```bash
# Check restart count
docker inspect grist_server \
  --format='{{.RestartCount}}'

# View last restart time
docker inspect grist_server \
  --format='{{.State.StartedAt}}'

# Check if container is restarting
docker inspect grist_server \
  --format='{{.State.Restarting}}'
```

#info_box(type: "warning")[
  **High Restart Count**

  If restart count is high (>5), investigate logs for errors:

  ```bash
  docker-compose logs --tail=100 grist
  ```
]

=== Health Check Configuration

Add health checks to `docker-compose.yml`:

```yaml
services:
  grist:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8484/health"]
      interval: 30s      # Check every 30 seconds
      timeout: 10s       # Wait max 10 seconds
      retries: 3         # Retry 3 times before unhealthy
      start_period: 40s  # Grace period after start
```

*Check health status:*

```bash
# View health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Detailed health info
docker inspect grist_server \
  --format='{{json .State.Health}}' | jq .

# View health check logs
docker inspect grist_server \
  --format='{{range .State.Health.Log}}{{.Output}}{{end}}'
```

== Resource Monitoring

=== Real-Time Resource Usage

```bash
# Monitor all containers
docker stats

# Example output:
# CONTAINER ID   NAME           CPU %   MEM USAGE / LIMIT   MEM %   NET I/O
# abc123...      grist_server   2.5%    350MiB / 16GiB      2.1%    1.2MB / 850KB

# Monitor specific container
docker stats grist_server

# Non-interactive snapshot
docker stats --no-stream

# Format output
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

=== CPU Monitoring

```bash
# Get current CPU usage
docker stats --no-stream grist_server \
  --format "{{.CPUPerc}}"

# Monitor CPU over time (5 samples, 2s interval)
for i in {1..5}; do
  docker stats --no-stream grist_server \
    --format "{{.CPUPerc}}"
  sleep 2
done
```

*CPU Thresholds:*
- < 50%: Normal operation
- 50-80%: High load, monitor
- > 80%: Critical, investigate

=== Memory Monitoring

```bash
# Get current memory usage
docker stats --no-stream grist_server \
  --format "{{.MemUsage}}"

# Get memory percentage
docker stats --no-stream grist_server \
  --format "{{.MemPerc}}"

# View detailed memory stats
docker inspect grist_server \
  --format='{{json .HostConfig.Memory}}'
```

*Memory Thresholds:*
- < 70%: Normal
- 70-85%: Warning
- > 85%: Critical (risk of OOM kill)

#info_box(type: "danger")[
  **Out of Memory (OOM) Kill**

  If container memory reaches limit, Docker may kill it. Check logs for:

  ```
  Error: OOMKilled
  Exit Code: 137
  ```

  Solution: Increase memory limits or optimize application.
]

=== Disk Space Monitoring

```bash
# Check Docker disk usage
docker system df

# Example output:
# TYPE            TOTAL    ACTIVE   SIZE      RECLAIMABLE
# Images          5        2        2.5GB     1.2GB (48%)
# Containers      3        1        150MB     100MB (66%)
# Local Volumes   2        1        5GB       2GB (40%)
# Build Cache     0        0        0B        0B

# Detailed breakdown
docker system df -v

# Check Grist data directory size
du -sh grist-module/grist-data/

# Monitor available disk space
df -h | grep -E '(Filesystem|/$)'
```

*Disk Space Thresholds:*
- < 70%: Normal
- 70-85%: Warning, plan cleanup
- > 85%: Critical, immediate action needed

*Cleanup Commands:*

```bash
# Remove unused containers, networks, images
docker system prune

# Remove unused volumes (CAUTION!)
docker system prune --volumes

# Remove all stopped containers
docker container prune

# Remove dangling images
docker image prune
```

=== Network Monitoring

```bash
# View network I/O
docker stats --format \
  "table {{.Name}}\t{{.NetIO}}"

# Check port availability
lsof -i :8484  # macOS/Linux
netstat -ano | findstr :8484  # Windows

# Test Grist connectivity
curl -I http://localhost:8484

# From another container
docker exec flutter_dev curl -I http://grist:8484
```

== Log Management

=== Log Access Methods

==== Method 1: Docker Compose

```bash
# Follow all service logs
docker-compose logs -f

# Follow specific service
docker-compose logs -f grist

# Last N lines
docker-compose logs --tail=50 grist

# Logs since timestamp
docker-compose logs --since 2025-01-10T10:00:00 grist

# Logs with timestamps
docker-compose logs -t grist

# Logs until timestamp
docker-compose logs --until 2025-01-10T12:00:00 grist
```

==== Method 2: Docker Command

```bash
# Follow container logs
docker logs -f grist_server

# Last 100 lines
docker logs --tail=100 grist_server

# Logs in real-time with timestamps
docker logs -tf grist_server

# Logs since 1 hour ago
docker logs --since 1h grist_server
```

==== Method 3: Direct Log Files

```bash
# Find log file location
docker inspect grist_server \
  --format='{{.LogPath}}'

# Example output:
# /var/lib/docker/containers/abc123.../abc123...-json.log

# View log file (requires sudo)
sudo tail -f /var/lib/docker/containers/abc123.../*-json.log

# Parse JSON logs
sudo cat /var/lib/docker/containers/abc123.../*-json.log | \
  jq -r '.log'
```

=== Log Filtering and Analysis

==== Filter by Pattern

```bash
# Search for errors
docker-compose logs grist | grep -i error

# Search for warnings
docker-compose logs grist | grep -i warn

# Case-insensitive search
docker-compose logs grist | grep -i "connection refused"

# Multiple patterns
docker-compose logs grist | grep -E "(error|warning|failed)"

# Exclude patterns
docker-compose logs grist | grep -v "debug"
```

==== Count Log Events

```bash
# Count error occurrences
docker-compose logs grist | grep -c "error"

# Count by severity
docker-compose logs grist | grep -c "ERROR"
docker-compose logs grist | grep -c "WARN"
docker-compose logs grist | grep -c "INFO"

# Show unique errors
docker-compose logs grist | grep "error" | sort -u
```

==== Time-Based Analysis

```bash
# Logs from last hour
docker-compose logs --since 1h grist

# Logs from last 30 minutes
docker-compose logs --since 30m grist

# Logs between time ranges
docker-compose logs \
  --since 2025-01-10T09:00:00 \
  --until 2025-01-10T10:00:00 \
  grist

# Today's logs
docker-compose logs --since $(date +%Y-%m-%d) grist
```

=== Log Rotation and Retention

==== Configure Log Rotation

Add to `docker-compose.yml`:

```yaml
services:
  grist:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"      # Max size per file
        max-file: "5"        # Number of files to keep
        compress: "true"     # Compress rotated logs
```

*Retention Calculation:*
- Max size: 10 MB
- Max files: 5
- Total: 50 MB max per service

==== Manual Log Rotation

```bash
# Force log rotation (restart container)
docker-compose restart grist

# View log sizes
docker ps -q | xargs docker inspect \
  --format='{{.Name}} {{.LogPath}}' | \
  while read name path; do
    echo "$name: $(sudo du -h $path | cut -f1)"
  done

# Clear logs (CAUTION: Data loss!)
truncate -s 0 $(docker inspect grist_server \
  --format='{{.LogPath}}')
```

=== Structured Logging

==== Log Format Standards

*Recommended format (JSON):*

```json
{
  "timestamp": "2025-01-10T14:30:00Z",
  "level": "ERROR",
  "service": "grist",
  "message": "Database connection failed",
  "details": {
    "host": "localhost",
    "port": 5432,
    "error": "connection timeout"
  }
}
```

==== Parse JSON Logs

```bash
# Pretty print JSON logs
docker-compose logs --no-log-prefix grist | \
  jq -r '.message'

# Filter by log level
docker-compose logs --no-log-prefix grist | \
  jq 'select(.level == "ERROR")'

# Extract specific fields
docker-compose logs --no-log-prefix grist | \
  jq -r '[.timestamp, .level, .message] | @tsv'
```

== Application-Level Monitoring

=== Grist Service Monitoring

==== Health Check Endpoint

```bash
# Simple health check
curl http://localhost:8484/health

# With response details
curl -v http://localhost:8484/health

# From Docker network
docker exec flutter_dev curl http://grist:8484/health
```

==== API Availability Test

```bash
# Test API endpoint (replace with your API key)
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:8484/api/docs

# Test with timing
curl -w "@-" -o /dev/null -s \
  -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:8484/api/docs <<'EOF'
time_namelookup:  %{time_namelookup}\n
time_connect:     %{time_connect}\n
time_total:       %{time_total}\n
EOF
```

==== Database Size Monitoring

```bash
# Check Grist data size
du -sh grist-module/grist-data/

# Watch size over time
watch -n 60 'du -sh grist-module/grist-data/'

# Detailed breakdown
du -h grist-module/grist-data/ | sort -hr | head -20

# Count documents
find grist-module/grist-data/ -name "*.grist" | wc -l
```

=== Performance Metrics

==== Response Time Monitoring

```bash
# Measure API response time
time curl -o /dev/null -s http://localhost:8484/

# Detailed timing breakdown
curl -w "@-" -o /dev/null -s http://localhost:8484/ <<'EOF'
    time_namelookup:  %{time_namelookup}s\n
       time_connect:  %{time_connect}s\n
    time_appconnect:  %{time_appconnect}s\n
   time_pretransfer:  %{time_pretransfer}s\n
      time_redirect:  %{time_redirect}s\n
 time_starttransfer:  %{time_starttransfer}s\n
                    ----------\n
         time_total:  %{time_total}s\n
EOF

# Monitor response time over period
for i in {1..10}; do
  echo "Sample $i:"
  curl -w "%{time_total}s\n" -o /dev/null -s \
    http://localhost:8484/
  sleep 5
done
```

*Response Time Thresholds:*
- < 100ms: Excellent
- 100-500ms: Good
- 500ms-1s: Acceptable
- > 1s: Needs optimization

==== Load Testing

```bash
# Simple load test with curl
seq 100 | xargs -n1 -P10 bash -c \
  'curl -o /dev/null -s http://localhost:8484/'

# Apache Bench (if installed)
ab -n 1000 -c 10 http://localhost:8484/

# Using hey (modern alternative)
hey -n 1000 -c 10 http://localhost:8484/
```

== Monitoring Scripts

=== Daily Health Check Script

```bash
#!/bin/bash
# daily_health_check.sh

echo "=== FlutterGristAPI Health Check ==="
echo "Date: $(date)"
echo ""

# Container status
echo "--- Container Status ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Resource usage
echo "--- Resource Usage ---"
docker stats --no-stream \
  --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo ""

# Disk space
echo "--- Disk Space ---"
du -sh grist-module/grist-data/
df -h | grep -E '(Filesystem|/$)'
echo ""

# Grist availability
echo "--- Grist Availability ---"
if curl -f -s http://localhost:8484/health > /dev/null; then
  echo "✓ Grist is available"
else
  echo "✗ Grist is not responding"
fi
echo ""

# Recent errors
echo "--- Recent Errors (last hour) ---"
docker-compose logs --since 1h grist | grep -i error | tail -10
echo ""

echo "=== End of Health Check ==="
```

*Run daily check:*

```bash
chmod +x daily_health_check.sh
./daily_health_check.sh

# Schedule with cron (daily at 9 AM)
# crontab -e
# 0 9 * * * /path/to/daily_health_check.sh >> /var/log/grist-health.log
```

=== Automated Monitoring Dashboard

```bash
#!/bin/bash
# monitoring_dashboard.sh

while true; do
  clear
  echo "╔═══════════════════════════════════════════════════╗"
  echo "║  FlutterGristAPI Monitoring Dashboard            ║"
  echo "║  Updated: $(date +'%Y-%m-%d %H:%M:%S')                    ║"
  echo "╚═══════════════════════════════════════════════════╝"
  echo ""

  echo "📊 Container Status:"
  docker ps --format "  {{.Names}}: {{.Status}}"
  echo ""

  echo "💻 Resource Usage:"
  docker stats --no-stream \
    --format "  {{.Name}}: CPU {{.CPUPerc}}, Memory {{.MemUsage}}"
  echo ""

  echo "💾 Disk Space:"
  echo "  Grist Data: $(du -sh grist-module/grist-data/ | cut -f1)"
  echo "  Docker: $(docker system df --format 'Images {{.Size}}, Containers {{.Size}}' | head -1)"
  echo ""

  echo "🌐 Grist Availability:"
  if curl -f -s http://localhost:8484/health > /dev/null 2>&1; then
    echo "  ✓ Available (http://localhost:8484)"
  else
    echo "  ✗ Not Responding"
  fi
  echo ""

  echo "📝 Recent Log Activity:"
  docker-compose logs --tail=3 --since 1m grist 2>/dev/null | \
    sed 's/^/  /'
  echo ""

  echo "Press Ctrl+C to exit..."
  sleep 10
done
```

*Run dashboard:*

```bash
chmod +x monitoring_dashboard.sh
./monitoring_dashboard.sh
```

== Alerting Strategies

=== Email Alerts

```bash
#!/bin/bash
# alert_on_high_cpu.sh

THRESHOLD=80
EMAIL="admin@example.com"

CPU=$(docker stats --no-stream grist_server \
  --format "{{.CPUPerc}}" | sed 's/%//')

if (( $(echo "$CPU > $THRESHOLD" | bc -l) )); then
  echo "High CPU usage detected: ${CPU}%" | \
    mail -s "FlutterGrist Alert: High CPU" $EMAIL
fi
```

=== Slack/Discord Webhooks

```bash
#!/bin/bash
# alert_to_slack.sh

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
MESSAGE="Grist container restarted unexpectedly"

RESTART_COUNT=$(docker inspect grist_server \
  --format='{{.RestartCount}}')

if [ "$RESTART_COUNT" -gt 5 ]; then
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"⚠️ Alert: $MESSAGE (restarts: $RESTART_COUNT)\"}" \
    $WEBHOOK_URL
fi
```

== Advanced Monitoring Tools

=== Prometheus + Grafana (Optional)

For production environments, consider implementing:

```yaml
# docker-compose.monitoring.yml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
```

=== cAdvisor (Container Metrics)

```yaml
services:
  cadvisor:
    image: google/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
```

Access cAdvisor dashboard at: http://localhost:8080

#section_separator()

#info_box(type: "success")[
  **Monitoring Best Practices**

  1. *Regular Checks*: Run daily health checks
  2. *Baseline Metrics*: Know your normal resource usage
  3. *Log Retention*: Keep logs for at least 30 days
  4. *Automated Alerts*: Set up alerts for critical issues
  5. *Documentation*: Record incidents and resolutions
  6. *Capacity Planning*: Monitor trends to predict scaling needs
]
