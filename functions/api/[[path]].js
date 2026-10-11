import worker from "../../src/worker.js";

// Cloudflare Pages Functions adapter. API routes are handled by the shared worker
// module; non-API paths are served by Pages' static asset pipeline.
export async function onRequest(context) {
  const url = new URL(context.request.url);
  if (!url.pathname.startsWith("/api/")) return context.next();
  return worker.fetch(context.request, {
    ...context.env,
    // The shared Worker expects an ASSETS binding for its non-API fallback.
    // Pages handles assets itself; this stub is only a safety fallback.
    ASSETS: { fetch: () => context.next() },
  });
}
