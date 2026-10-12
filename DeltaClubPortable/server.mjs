import http from 'node:http'
import net from 'node:net'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const root = path.dirname(fileURLToPath(import.meta.url))
const apiPort = Number(process.env.DELTA_API_PORT || 8081)
const host = process.env.DELTA_HOST || '127.0.0.1'
const mimeTypes = {
  '.css': 'text/css; charset=utf-8',
  '.gif': 'image/gif',
  '.html': 'text/html; charset=utf-8',
  '.ico': 'image/x-icon',
  '.jpeg': 'image/jpeg',
  '.jpg': 'image/jpeg',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.webp': 'image/webp'
}

function proxyRequest(req, res) {
  const requestPath = req.url.startsWith('/api/') ? req.url.slice(4) : req.url
  const upstream = http.request({
    host: '127.0.0.1',
    port: apiPort,
    method: req.method,
    path: requestPath,
    headers: { ...req.headers, host: `127.0.0.1:${apiPort}` }
  }, (response) => {
    res.writeHead(response.statusCode || 502, response.headers)
    response.pipe(res)
  })
  upstream.on('error', () => {
    if (!res.headersSent) res.writeHead(502, { 'content-type': 'text/plain; charset=utf-8' })
    res.end('Delta API is not running. Start the package with START.bat.')
  })
  req.pipe(upstream)
}

function serveStatic(site, port) {
  const siteRoot = path.join(root, 'web', site)
  const server = http.createServer((req, res) => {
    const pathname = new URL(req.url, `http://${req.headers.host || 'localhost'}`).pathname
    if (pathname === '/api' || pathname.startsWith('/api/') || pathname === '/file' || pathname.startsWith('/file/')) {
      proxyRequest(req, res)
      return
    }

    let requestedPath
    try {
      requestedPath = decodeURIComponent(pathname)
    } catch {
      res.writeHead(400).end('Bad request')
      return
    }
    const resolved = path.resolve(siteRoot, `.${requestedPath}`)
    if (resolved !== siteRoot && !resolved.startsWith(`${siteRoot}${path.sep}`)) {
      res.writeHead(403).end('Forbidden')
      return
    }
    let filePath = resolved
    if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) filePath = path.join(filePath, 'index.html')
    if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) filePath = path.join(siteRoot, 'index.html')
    if (!fs.existsSync(filePath)) {
      res.writeHead(503, { 'content-type': 'text/plain; charset=utf-8' })
      res.end(`The ${site} web build is missing. Rebuild the portable package.`)
      return
    }
    res.writeHead(200, {
      'content-type': mimeTypes[path.extname(filePath).toLowerCase()] || 'application/octet-stream',
      'cache-control': path.basename(filePath) === 'index.html' ? 'no-cache' : 'public, max-age=3600'
    })
    fs.createReadStream(filePath).pipe(res)
  })

  server.on('upgrade', (req, socket, head) => {
    if (!req.url.startsWith('/ws/')) {
      socket.destroy()
      return
    }
    const upstream = net.connect(apiPort, '127.0.0.1', () => {
      const headers = { ...req.headers, host: `127.0.0.1:${apiPort}` }
      const lines = [`${req.method} ${req.url} HTTP/${req.httpVersion}`]
      for (const [name, value] of Object.entries(headers)) lines.push(`${name}: ${value}`)
      upstream.write(`${lines.join('\r\n')}\r\n\r\n`)
      if (head.length) upstream.write(head)
      socket.pipe(upstream).pipe(socket)
    })
    upstream.on('error', () => socket.destroy())
    socket.on('error', () => upstream.destroy())
  })

  server.listen(port, host, () => console.log(`${site} listening on http://${host}:${port}`))
  return server
}

const adminServer = serveStatic('admin', Number(process.env.DELTA_ADMIN_PORT || 3000))
const h5Server = serveStatic('h5', Number(process.env.DELTA_H5_PORT || 5174))

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => {
    adminServer.close()
    h5Server.close()
    process.exit(0)
  })
}
