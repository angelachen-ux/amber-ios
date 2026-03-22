import { registerNode } from '../engine.js';

registerNode('http.fetch', async (_input, cfg) => {
  const url = String(cfg.url);
  const method = String(cfg.method || 'GET');
  const headers = (cfg.headers || {}) as Record<string, string>;
  const body = cfg.body;
  const res = await fetch(url, { method, headers, body: body ? JSON.stringify(body) : undefined });
  const text = await res.text();
  return { status: res.status, headers: Object.fromEntries(res.headers.entries()), body: text };
});




