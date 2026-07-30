/** @type {import('next').NextConfig} */
const nextConfig = {
    output: 'export',
    images: {
        unoptimized: true,
    },
    eslint: {
        // Disable eslint during builds - we run it separately in CI
        ignoreDuringBuilds: true,
    },
    // Env-gated. When ON, sourcemaps ship inside the Tauri bundle so React
    // #185 / similar minified stack traces decode to real component + file
    // names in the logs. (No CDN exposure — bundle ships in-app.)
    //
    // Default OFF because sourcemaps add ~186 MB to the macOS bundle (256 →
    // 442 MB observed on v2.4.258 vs v2.4.252). Only enable when actively
    // triaging a minified-stack incident — set SHIP_SOURCE_MAPS=1 in CI for
    // that release, then flip back. Last triage: v2.4.255 for React #185.
    productionBrowserSourceMaps: process.env.SHIP_SOURCE_MAPS === '1',
    webpack: (config) => {
        // Raise the chunk-load timeout. In dev, a slow hot-reload rebuild can
        // make the webview's chunk fetch exceed webpack's default 120s budget,
        // surfacing a "ChunkLoadError: Loading chunk app/layout failed
        // (timeout)" overlay even though the chunk serves fine moments later.
        // A larger budget rides out those rebuild stalls instead of erroring.
        config.output = config.output || {};
        config.output.chunkLoadTimeout = 600000; // 10 min
        return config;
    },
}
export default nextConfig;

