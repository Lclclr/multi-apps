# multi-apps (nginx + two simple apps)

This workspace contains two simple web apps and an example nginx config that reverses proxies between them:

- `apps/hello-app` — Hello World app (listens on port **8080**)
- `apps/time-app` — Date/Time app (listens on port **8081**)
- `nginx/multi-apps.conf` — nginx config showing how to proxy `/hello/` and `/time/`

## Quick start (node)

1. Install Node.js (>= 18) and npm.

2. Run Hello app:

```bash
cd apps/hello-app
npm install
npm start
# app available at http://localhost:8080/
```

3. Run Time app:

```bash
cd apps/time-app
npm install
npm start
# app available at http://localhost:8081/
```

4. Test apps directly in the browser:

- http://localhost:8080/ (Hello)
- http://localhost:8081/ (Date/Time)

## Using nginx as a reverse-proxy

Copy `nginx/multi-apps.conf` into your nginx config (e.g. `/etc/nginx/conf.d/multi-apps.conf`) and reload nginx:

```bash
sudo cp nginx/multi-apps.conf /etc/nginx/conf.d/multi-apps.conf
sudo nginx -t && sudo systemctl reload nginx
```

Now you can access the apps via:

- `http://<server>/hello/` -> proxied to the Hello app
- `http://<server>/time/` -> proxied to the Time app

Note: Links between apps use absolute paths (`/hello/` and `/time/`) so they work through nginx.

## Docker (optional)

Each app includes a `Dockerfile`. Example:

```bash
# build
docker build -t hello-app:latest ./apps/hello-app
# run
docker run -p 8080:8080 hello-app:latest
```

### docker-compose (optional)

Run all services (hello, time, nginx) together locally using docker compose:

```bash
# default behavior uses docker-compose.yml
docker compose build
docker compose up -d --build
# then open http://localhost:8080/hello/ and http://localhost:8080/time/
```

### Local development with live code (optional)

You can add `docker-compose.override.yml` to mount your local app directories into the containers so changes are live without rebuilding images. Compose automatically picks up `docker-compose.override.yml` when present.

```bash
# start dev stack (override applied automatically)
docker compose up -d --build
# or explicitly include it:
# docker compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
```

Notes:

- The override mounts `./apps/hello-app` and `./apps/time-app` into the containers and runs `npm install` on container start so local edits are active immediately.
- If you prefer not to use mounts, remove or rename `docker-compose.override.yml` and start normally.

## Next steps / testing

- Start both apps and verify direct access on ports 8080 and 8081.
- Add `nginx/multi-apps.conf` to your nginx and confirm proxying.

If you want, I can:

- Add systemd unit files, or
- Create docker-compose that runs nginx + both apps, or
- Help you test locally with a simple script.
