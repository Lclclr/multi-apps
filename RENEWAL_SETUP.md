# Let's Encrypt Certificate Auto-Renewal Setup

This guide sets up automatic renewal of Let's Encrypt certificates for `localtower.org`.

## Option 1: Cron Job (Recommended)

1. **Open your crontab editor:**
   ```bash
   crontab -e
   ```

2. **Add one of these lines to run the renewal script:**

   - **Daily at 2 AM** (recommended - checks daily, renews only if needed):
     ```
     0 2 * * * /home/rei/Projects/multi-apps/scripts/renew-certs.sh >> /var/log/letsencrypt-renewal.log 2>&1
     ```

   - **Weekly on Monday at 2 AM**:
     ```
     0 2 * * 1 /home/rei/Projects/multi-apps/scripts/renew-certs.sh >> /var/log/letsencrypt-renewal.log 2>&1
     ```

3. **Save and exit** (in nano: Ctrl+O, Enter, Ctrl+X; in vim: `:wq`)

4. **Verify the cron job is set:**
   ```bash
   crontab -l
   ```

## Option 2: Manual Renewal

Run the renewal script manually anytime:

```bash
/home/rei/Projects/multi-apps/scripts/renew-certs.sh
```

## How It Works

- **certbot renew**: Checks for certificates expiring in 30 days or more. Only renews if needed.
- **nginx reload**: Gracefully reloads nginx to pick up new certificates without downtime.
- **Logs**: Check `/var/log/letsencrypt-renewal.log` for execution details.

## Monitoring

Check renewal status and expiration dates:

```bash
cd /home/rei/Projects/multi-apps
docker compose run --rm certbot certificates
```

View last renewal log:
```bash
tail -50 /var/log/letsencrypt-renewal.log
```

## Troubleshooting

If renewal fails, check:

1. **Docker is running:**
   ```bash
   docker ps
   ```

2. **Port 80 is still accessible** from the internet (required for ACME challenges)

3. **Nginx logs:**
   ```bash
   cd /home/rei/Projects/multi-apps
   docker compose logs nginx
   ```

4. **Certbot logs:**
   ```bash
   docker compose run --rm certbot logs
   ```

## Notes

- Let's Encrypt certificates expire every 90 days, so renewing every 30 days is safe.
- The `--keep-until-expiring` flag ensures old certs aren't replaced unnecessarily.
- Nginx reload is non-blocking; connections stay active during the reload.
