# Copilot Instructions for multi-apps

## Project Overview

Multi-app reverse-proxy deployment using Docker Compose + nginx to host multiple Node.js apps under a single domain with SSL/TLS.

**Architecture:** nginx reverse proxy → multiple Express.js microservices
- Apps run in isolated containers, exposed internally only
- nginx routes by path prefix (`/hello/`, `/time/`, `/cal/`, `/contacts/`)
- Production deployment at `localtower.org` with Let's Encrypt certificates

## Directory Structure

```
apps/               # Individual microservices (Express.js apps)
  hello-app/        # Simple greeting app on :8080
  time-app/         # Date/time display on :8081
  cal/              # Calendar app on :3000
  contact-app/      # Full-stack contacts app (client/server/DB)
nginx/
  multi-apps.conf   # Main nginx config - routes all apps by path
  certbot/conf/     # Let's Encrypt certificates (auto-renewed)
  ssl/              # Fallback self-signed certificates
scripts/
  renew-certs.sh    # Automated certificate renewal (runs via cron)
```

## Key Architecture Patterns

### Path-Based Routing
All apps are accessed via path prefixes through nginx on port 443:
- `https://localtower.org/hello/` → `hello-app:8080/`
- `https://localtower.org/time/` → `time-app:8081/`
- `https://localtower.org/cal/` → `calendar:3000`

**Critical:** Apps must use absolute paths (`/hello/`, `/time/`) in links—relative paths break when proxied.

### Volume Mounting Strategy
[docker-compose.yml](docker-compose.yml) uses live code mounting for development:
```yaml
volumes:
  - ./apps/hello-app:/app  # Changes reflect immediately
command: sh -c "npm install --production --silent && node index.js"
```
No image rebuild needed during development—edit code and restart container.

### SSL Certificate Management
Dual-certificate setup for zero-downtime:
1. **Fallback:** Self-signed certs in [nginx/ssl/](nginx/ssl/)
2. **Production:** Let's Encrypt in `nginx/certbot/conf/live/localtower.org/`

Switch between them in [nginx/multi-apps.conf](nginx/multi-apps.conf#L22-L23) `ssl_certificate` directives.

## Common Workflows

### Adding a New App
1. Create app in `apps/<name>/` with Dockerfile, index.js, package.json
2. Add service to [docker-compose.yml](docker-compose.yml):
   ```yaml
   myapp:
     build: ./apps/myapp
     expose: ["8099"]
     volumes: ["./apps/myapp:/app"]
   ```
3. Add nginx location block in [nginx/multi-apps.conf](nginx/multi-apps.conf):
   ```nginx
   location /myapp/ {
     proxy_pass http://myapp:8099/;
     proxy_set_header Host $host;
   }
   ```
4. Rebuild and restart: `docker compose up -d --build`

### Development Cycle
```bash
# Start all services
docker compose up -d --build

# Watch logs for specific app
docker compose logs -f hello-app

# Reload nginx after config changes
docker compose exec nginx nginx -s reload

# Restart single app after code changes
docker compose restart hello-app
```

### Certificate Renewal
Automated via cron (daily at 2 AM) running [scripts/renew-certs.sh](scripts/renew-certs.sh).

Manual renewal:
```bash
docker compose run --rm certbot renew
docker compose exec nginx nginx -s reload
```

Check certificate status: `docker compose run --rm certbot certificates`

## Project-Specific Conventions

- **Port allocation:** Apps use 808x range (hello=8080, time=8081, contacts=8082, cal=8083)
- **Health checks:** Not implemented for simple apps; contact-server uses `/health` endpoint
- **Nginx resolver:** Uses Docker DNS `127.0.0.11` for runtime service discovery
- **HTTP → HTTPS redirect:** All HTTP traffic auto-redirects except `/.well-known/acme-challenge/` (ACME validation)

## External Dependencies

- **Let's Encrypt:** Requires port 80 publicly accessible for ACME challenges
- **Docker Compose:** Project uses compose file format v3.8+ (no version key needed in modern Docker)
- **Referenced services:** Some services (`calendar`, `contacts`) reference sibling directories outside this repo (`../calendar`, `../contacts`)

## Debugging Tips

- **502 Bad Gateway:** Check if backend app container is running (`docker ps`)
- **Certificate errors:** Verify correct cert path in nginx config; check `docker compose logs nginx`
- **App changes not appearing:** Restart the specific container: `docker compose restart <app-name>`
- **ACME challenge failures:** Ensure port 80 is open and nginx config allows `/.well-known/acme-challenge/`
