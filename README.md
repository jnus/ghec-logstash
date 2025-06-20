# GitHub Enterprise Cloud (GHEC) Logstash Configuration

A comprehensive Logstash configuration for processing GitHub.com webhook payloads. This configuration supports all webhook events documented at [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks/webhook-events-and-payloads).

## Features

- **HTTP Input**: Receives webhook payloads on port 8080
- **Event Processing**: Parses and enriches all GitHub webhook event types
- **Common Fields**: Extracts repository, sender, and organization information
- **Event-Specific Parsing**: Handles specific fields for different webhook types:
  - Push events (commits, refs, branches)
  - Pull Request events (state, mergeable, draft status)
  - Issues events (state, labels, assignees)
  - Release events (tags, draft, prerelease)
  - Repository events (created, deleted, etc.)
  - Star/Watch/Fork events
  - Create/Delete events (branches, tags)
- **Flexible Output**: Configurable outputs to Elasticsearch, files, or stdout

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

- Logstash 7.x or 8.x
- Java 8 or higher

### Running the Configuration

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
   http://your-logstash-host:8080
   ```

### Docker Usage

You can also run this configuration using Docker:

```bash
# Create a simple Dockerfile
cat > Dockerfile << EOF
FROM docker.elastic.co/logstash/logstash:8.11.0
COPY logstash.conf /usr/share/logstash/pipeline/
EOF

# Build and run
docker build -t ghec-logstash .
docker run -p 8080:8080 ghec-logstash
```

## Configuration

### Output Configuration

The default configuration outputs to stdout for debugging. For production use, uncomment and configure the Elasticsearch output:

```ruby
elasticsearch {
  hosts => ["your-elasticsearch-host:9200"]
  index => "github-webhooks-%{+YYYY.MM.dd}"
  template_name => "github-webhooks"
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

You can test the configuration using curl:

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-GitHub-Delivery: 12345-67890" \
  -d @example-webhook.json
```

## Monitoring

Monitor your Logstash instance for:
- Input event rates
- Processing errors
- Output delivery success
- Resource utilization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.