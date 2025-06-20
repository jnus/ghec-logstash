# GitHub Enterprise Cloud (GHEC) Logstash Configuration

A comprehensive Logstash configuration for processing GitHub.com webhook payloads. This configuration supports all webhook events documented at [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks/webhook-events-and-payloads).

## Features

- **Complete ELK Stack**: Full Elasticsearch, Logstash, and Kibana setup for GitHub webhook analytics
- **HTTP Input**: Receives webhook payloads on port 8080
- **Dual Format Support**: Handles both JSON and form-encoded webhook payloads
- **Event Processing**: Parses and enriches all GitHub webhook event types
- **Smart Event Detection**: Automatically detects event types from payload content
- **Common Fields**: Extracts repository, sender, and organization information
- **Event-Specific Parsing**: Handles specific fields for different webhook types:
  - Push events (commits, refs, branches)
  - Pull Request events (state, mergeable, draft status)
  - Issues events (state, labels, assignees)
  - Release events (tags, draft, prerelease)
  - Repository events (created, deleted, etc.)
  - Star/Watch/Fork events
  - Create/Delete events (branches, tags)
- **Elasticsearch Integration**: Stores data in time-based indices for efficient querying
- **Kibana Dashboards**: Pre-configured visualizations and search capabilities
- **Docker Compose**: One-command deployment of the entire stack

## Supported Webhook Events

This configuration processes all GitHub webhook events including:

- `push` - Repository push events
- `pull_request` - Pull request events
- `issues` - Issue events
- `issue_comment` - Issue comment events
- `pull_request_review` - PR review events
- `pull_request_review_comment` - PR review comment events
- `release` - Release events
- `repository` - Repository events
- `star` - Star events
- `watch` - Watch events
- `fork` - Fork events
- `create` - Branch/tag creation events
- `delete` - Branch/tag deletion events
- And many more...

## Quick Start

### Prerequisites

- Docker and Docker Compose (recommended)
- OR: Logstash 8.x, Elasticsearch 8.x, Kibana 8.x
- Java 11 or higher

### Option 1: Complete ELK Stack with Docker Compose (Recommended)

1. Clone this repository:
   ```bash
   git clone https://github.com/jnus/ghec-logstash.git
   cd ghec-logstash
   ```

2. Start the complete ELK stack:
   ```bash
   ./start-elk.sh
   ```

3. Wait for all services to be ready, then set up Kibana:
   ```bash
   ./setup-kibana.sh
   ```

4. Access the services:
   - **Logstash webhook endpoint**: http://localhost:8080/webhook
   - **Elasticsearch**: http://localhost:9200
   - **Kibana**: http://localhost:5601

5. Configure your GitHub repository webhooks to send to:
   ```
   http://your-server-ip:8080/webhook
   ```

### Option 2: Logstash Only

If you already have Elasticsearch and Kibana running:

### Option 2: Logstash Only

If you already have Elasticsearch and Kibana running:

1. Clone this repository:
   ```bash
   git clone https://github.com/jnus/ghec-logstash.git
   cd ghec-logstash
   ```

2. Start Logstash with the configuration:
   ```bash
   logstash -f logstash.conf
   ```

3. Configure your GitHub repository webhooks to send to:
   ```
   http://your-logstash-host:8080/webhook
   ```

### Docker Usage

You can also run individual components using Docker:

You can also run individual components using Docker:

```bash
# Build and run Logstash only
docker build -t ghec-logstash .
docker run -p 8080:8080 ghec-logstash
```

## ELK Stack Components

### Elasticsearch
Elasticsearch stores and indexes all GitHub webhook data in daily indices with the pattern `github-webhooks-YYYY.MM.dd`. Each webhook event becomes a document with structured fields for easy searching and aggregation.

**Key features:**
- Time-based indexing for efficient data management
- Full-text search across all webhook data
- Powerful aggregations for analytics
- RESTful API for custom queries

**Example queries:**
```bash
# Get all push events from today
curl "localhost:9200/github-webhooks-*/_search" -H "Content-Type: application/json" -d '{
  "query": {"term": {"event_type": "push"}},
  "sort": [{"@timestamp": {"order": "desc"}}]
}'

# Count events by repository
curl "localhost:9200/github-webhooks-*/_search" -H "Content-Type: application/json" -d '{
  "size": 0,
  "aggs": {
    "repositories": {
      "terms": {"field": "repo_full_name.keyword", "size": 10}
    }
  }
}'
```

### Logstash
Logstash processes incoming GitHub webhooks and transforms them into structured documents for Elasticsearch.

**Processing pipeline:**
1. **Input**: HTTP plugin receives webhooks on port 8080
2. **Filter**: Parses JSON/form-encoded payloads and extracts fields
3. **Enhancement**: Adds event metadata and infers event types
4. **Output**: Sends structured data to Elasticsearch

### Kibana
Kibana provides a web interface for visualizing and exploring your GitHub webhook data.

**Access**: http://localhost:5601

**Pre-configured features:**
- Index pattern: `github-webhooks-*` with `@timestamp` as time field
- Discover view for exploring webhook events
- Ready for custom dashboards and visualizations

**Useful Kibana queries:**
- `event_type:push` - Show only push events
- `repo_name:"your-repo-name"` - Filter by repository
- `sender_login:"username"` - Filter by user
- `action:"opened" AND event_type:"pull_request"` - New pull requests

**Sample dashboard widgets:**
- Events over time (timeline)
- Top repositories by activity
- Event types distribution
- Most active contributors
- Pull request states
- Issue creation trends

## Configuration

### ELK Stack Configuration

The Docker Compose setup includes:

```yaml
# Services Overview
- Elasticsearch: Data storage and search engine (port 9200)
- Logstash: Data processing pipeline (port 8080)
- Kibana: Visualization and exploration (port 5601)
```

**Elasticsearch configuration:**
- Memory: 1GB heap size (configurable via ES_JAVA_OPTS)
- Storage: Persistent volume for data retention
- Network: Internal cluster communication

**Logstash configuration:**
- Input: HTTP on port 8080 accepting JSON and form-encoded payloads
- Processing: Event type detection, field extraction, data enrichment
- Output: Elasticsearch with daily index rotation

**Kibana configuration:**
- Automatic Elasticsearch connection
- Pre-configured index patterns
- Ready for dashboard creation

### Output Configuration

The default configuration outputs to Elasticsearch. The configuration automatically:
- Creates daily indices: `github-webhooks-YYYY.MM.dd`
- Maps common GitHub webhook fields
- Preserves original payload data
- Adds processing metadata

For custom Elasticsearch configurations, modify the output section in `logstash.conf`:

```ruby
elasticsearch {
  hosts => ["your-elasticsearch-host:9200"]
  index => "github-webhooks-%{+YYYY.MM.dd}"
  template_name => "github-webhooks"
  # Add authentication if needed
  # user => "elastic"
  # password => "your-password"
}
```

### Security Considerations

For production deployments:

1. **Enable HTTPS**: Configure SSL/TLS termination
2. **Webhook Signatures**: Implement signature verification using the `X-Hub-Signature-256` header
3. **Authentication**: Add authentication middleware
4. **Rate Limiting**: Implement rate limiting to prevent abuse
5. **Network Security**: Restrict access to webhook endpoint

### GitHub Webhook Configuration

1. Go to your repository settings
2. Navigate to "Webhooks"
3. Click "Add webhook"
4. Set payload URL to your Logstash endpoint
5. Set content type to "application/json"
6. Select events you want to receive
7. Add a secret for security (recommended)

## Extracted Fields

The configuration extracts and adds the following fields to each event:

### Common Fields
- `event_type` - Type of GitHub event
- `delivery_id` - Unique delivery identifier
- `repo_name` - Repository name
- `repo_full_name` - Full repository name (owner/repo)
- `repo_id` - Repository ID
- `repo_owner` - Repository owner
- `repo_private` - Whether repository is private
- `sender_login` - Event sender username
- `sender_id` - Event sender ID
- `sender_type` - Event sender type (User, Bot, etc.)

### Event-Specific Fields
- **Push events**: `ref`, `before_sha`, `after_sha`, `commit_count`
- **Pull Request events**: `pr_number`, `pr_state`, `pr_title`, `pr_draft`
- **Issues events**: `issue_number`, `issue_state`, `issue_title`
- **Release events**: `release_tag`, `release_name`, `release_draft`
- And many more...

## Testing

### Test the Complete Pipeline

1. **Send a test webhook:**
   ```bash
   curl -X POST http://localhost:8080/webhook \
     -H "Content-Type: application/json" \
     -H "X-GitHub-Event: push" \
     -H "X-GitHub-Delivery: test-12345" \
     -d '{
       "repository": {"name": "test-repo", "full_name": "user/test-repo"},
       "commits": [{"message": "Test commit"}],
       "after": "abc123",
       "before": "def456",
       "ref": "refs/heads/main",
       "sender": {"login": "testuser"}
     }'
   ```

2. **Verify in Elasticsearch:**
   ```bash
   curl "http://localhost:9200/github-webhooks-*/_search?pretty&sort=@timestamp:desc&size=1"
   ```

3. **View in Kibana:**
   - Open http://localhost:5601
   - Go to Analytics > Discover
   - Select the `github-webhooks-*` index pattern
   - View your webhook data

### Use the Test Scripts

The repository includes several test scripts:

```bash
# Validate Logstash configuration
./validate-config.sh

# Test webhook processing
./test-webhook.sh

# Test external connectivity (for port forwarding)
./test-external-access.sh
```

## Monitoring

### ELK Stack Monitoring

Monitor your complete stack:

**Elasticsearch:**
```bash
# Cluster health
curl "localhost:9200/_cluster/health?pretty"

# Index statistics
curl "localhost:9200/_cat/indices?v"

# Document count by index
curl "localhost:9200/github-webhooks-*/_count"
```

**Logstash:**
```bash
# Check container status
docker compose ps

# View processing logs
docker logs ghec-logstash --follow

# Check input statistics
curl "localhost:9600/_node/stats/pipeline"
```

**Kibana:**
- Access monitoring via Stack Monitoring in Kibana
- View processing rates and errors
- Monitor index patterns and field mappings

### Key Metrics to Monitor

- **Input event rates**: Webhooks received per minute
- **Processing errors**: JSON parse failures, missing fields
- **Output delivery success**: Elasticsearch indexing success rate
- **Resource utilization**: CPU, memory, disk usage
- **Index size growth**: Elasticsearch storage consumption
- **Response times**: Webhook processing latency

### Alerts and Notifications

Consider setting up alerts for:
- High error rates in Logstash processing
- Elasticsearch cluster health issues
- Unusual webhook traffic patterns
- Storage space warnings

## Production Deployment

### Scaling Considerations

**Horizontal Scaling:**
- Multiple Logstash instances behind a load balancer
- Elasticsearch cluster with multiple nodes
- Separate Kibana instances for high availability

**Performance Tuning:**
```yaml
# docker-compose.yml adjustments for production
elasticsearch:
  environment:
    - ES_JAVA_OPTS=-Xms2g -Xmx2g  # Increase heap size
    - discovery.type=single-node  # Remove for cluster setup

logstash:
  environment:
    - LS_JAVA_OPTS=-Xms1g -Xmx1g  # Increase heap size
    - PIPELINE_WORKERS=4          # Increase workers
```

**Index Management:**
- Set up Index Lifecycle Management (ILM) policies
- Configure index templates for field mappings
- Implement retention policies for old data

### Security Best Practices

1. **Enable HTTPS**: Use a reverse proxy (nginx, traefik) for SSL termination
2. **Webhook Signatures**: Implement GitHub signature verification
3. **Authentication**: Enable Elasticsearch security features
4. **Network Security**: Use VPCs, security groups, firewalls
5. **Access Control**: Implement role-based access for Kibana

### High Availability Setup

```yaml
# Example HA configuration
version: '3.8'
services:
  elasticsearch-1:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - node.name=es-node-1
      - cluster.name=github-webhooks
      - discovery.seed_hosts=elasticsearch-2,elasticsearch-3
  
  logstash-1:
    image: ghec-logstash
    environment:
      - PIPELINE_WORKERS=8
  
  nginx:
    image: nginx
    ports:
      - "443:443"
    # SSL termination and load balancing
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.