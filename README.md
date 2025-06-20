# GitHub Webhook Logstash Pipeline

Demo repo for processing GitHub webhook events with the ELK stack (Elasticsearch, Logstash, Kibana). 

## Quick Start

### Option 1: Complete ELK Stack with Docker Compose

1. **Start the stack:**
   ```bash
   git clone https://github.com/jnus/ghec-logstash.git
   cd ghec-logstash
   docker compose up -d
   ```

2. **Wait for services to start, then configure Kibana:**
   ```bash
   ./setup-kibana.sh
   ```

3. **Configure your GitHub webhooks:**
   - URL: `http://your-server:8080`
   - Content type: `application/json`
   - Events: Select the events you want to track

### Option 2: Logstash Only

If you already have Elasticsearch and Kibana running:

1. **Clone and start Logstash:**
   ```bash
   git clone https://github.com/jnus/ghec-logstash.git
   cd ghec-logstash
   
   # Edit logstash.conf to point to your Elasticsearch
   # Then start Logstash
   logstash -f logstash.conf
   ```

2. **Or with Docker:**
   ```bash
   docker build -t ghec-logstash .
   docker run -p 8080:8080 ghec-logstash
   ```

## Access Points

- **Webhook endpoint**: http://localhost:8080
- **Elasticsearch**: http://localhost:9200  
- **Kibana**: http://localhost:5601

## What It Does

- **Receives** GitHub webhooks on port 8080
- **Processes** all GitHub event types (push, pull_request, issues, etc.)
- **Extracts** key fields like repo name, sender, event details
- **Stores** data in Elasticsearch with daily indices
- **Visualizes** data in Kibana dashboards

## Supported Events

All GitHub webhook events including push, pull_request, issues, releases, stars, forks, and more.

## Key Fields Extracted

- `event_type` - GitHub event type
- `repo_name`, `repo_owner` - Repository info
- `sender_login` - Who triggered the event
- `action` - Event action (opened, closed, etc.)
- Event-specific fields (commit count, PR number, issue state, etc.)

## Testing

```bash
# Validate configuration
./validate-config.sh

# Send test webhook
./test-webhook.sh

# Check Elasticsearch data
curl "localhost:9200/github-webhooks-*/_search?pretty&size=1"
```

## Kibana Queries

- `event_type:push` - Push events only
- `repo_name:"your-repo"` - Filter by repository  
- `sender_login:"username"` - Filter by user
- `action:"opened" AND event_type:"pull_request"` - New PRs

## Configuration

The pipeline uses a whitelist approach - only essential fields are kept, dramatically reducing storage requirements.

Edit `logstash.conf` to:
- Change Elasticsearch host
- Modify field extraction
- Add new event types
- Adjust the whitelist

## Docker Compose Services

- **Elasticsearch**: Data storage (1GB heap)
- **Logstash**: Event processing 
- **Kibana**: Visualization interface

## Production Notes

- Enable HTTPS with reverse proxy
- Implement webhook signature verification
- Set up retention policies for old data
- Monitor with Kibana Stack Monitoring

## License

MIT License