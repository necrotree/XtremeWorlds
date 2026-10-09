const bindings = new WeakMap();
export function attach(canvas, receiver, streamPath, gameWindow, fullscreenButton) {
    if (gameWindow) void prepareHudArtwork(gameWindow);
    const fullscreenStatus = gameWindow?.querySelector(".fullscreen-status");
    const fullscreenChanged = () => {
        const active = document.fullscreenElement === gameWindow;
        if (fullscreenButton) {
            fullscreenButton.textContent = active ? "Exit fullscreen" : "Fullscreen";
            fullscreenButton.setAttribute("aria-pressed", String(active));
        }
        release();
        if (active) canvas.focus({ preventScroll: true });
    };
    const toggleFullscreen = async () => {
        if (!gameWindow) return;
        try {
            if (fullscreenStatus) fullscreenStatus.textContent = "";
            if (document.fullscreenElement === gameWindow) await document.exitFullscreen();
            else await gameWindow.requestFullscreen();
            canvas.focus({ preventScroll: true });
        } catch {
            if (fullscreenStatus) fullscreenStatus.textContent = "Fullscreen is unavailable in this browser. You can use the browser fullscreen command instead.";
        }
    };
    const fullscreenKey = event => {
        if (event.key !== "F11" && !(event.key === "Enter" && event.altKey)) return;
        event.preventDefault();
        event.stopPropagation();
        if (!event.repeat) void toggleFullscreen();
    };
    const click = event => {
        canvas.focus();
        const rect = canvas.getBoundingClientRect();
        receiver.invokeMethodAsync('Click', Math.floor((event.clientX - rect.left) * 950 / rect.width), Math.floor((event.clientY - rect.top) * 700 / rect.height));
    };
    const rightClick = event => {
        event.preventDefault();
        canvas.focus({preventScroll:true});
        const rect = canvas.getBoundingClientRect();
        receiver.invokeMethodAsync('RightClick',Math.floor((event.clientX-rect.left)*950/rect.width),Math.floor((event.clientY-rect.top)*700/rect.height));
    };
    let charging = false;
    const held = new Set();
    const normalizeMovement = key => ({
        w: "ArrowUp", W: "ArrowUp", s: "ArrowDown", S: "ArrowDown",
        a: "ArrowLeft", A: "ArrowLeft", d: "ArrowRight", D: "ArrowRight"
    })[key] || (["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"].includes(key) ? key : null);
    const movement = key => normalizeMovement(key) !== null;
    const release = () => {
        charging = false; receiver.invokeMethodAsync("Key", "ChargeStop");
        receiver.invokeMethodAsync("Key", "StopAttack");
        for (const key of held) receiver.invokeMethodAsync('Movement', key, false);
        held.clear();
    };
    const up = event => {
        if (event.code === 'Space' || event.key === ' ') {
            event.preventDefault(); charging = false; receiver.invokeMethodAsync('Key','ChargeStop'); return;
        }
        if (!movement(event.key)) return;
        event.preventDefault();
        const direction = normalizeMovement(event.key);
        held.delete(direction);
        receiver.invokeMethodAsync('Movement', direction, false);
    };
    const key = event => {
        if (event.ctrlKey || event.metaKey || event.altKey || event.key === 'Tab') return;
        event.preventDefault();
        if (event.code === 'Space' || event.key === ' ') {
            if (!event.repeat && !charging) { charging = true; receiver.invokeMethodAsync('Key','ChargeStart'); }
            return;
        }
        if (event.key === 'e'  || event.key === 'E') { if (!event.repeat) receiver.invokeMethodAsync('Key','Pickup'); return; }
        if (movement(event.key)) {
            const direction = normalizeMovement(event.key);
            if (!held.has(direction)) { held.add(direction); receiver.invokeMethodAsync('Movement', direction, true); }
        } else if (!event.repeat) receiver.invokeMethodAsync('Key', event.key);
    };
    fullscreenButton?.addEventListener('click', toggleFullscreen);
    gameWindow?.addEventListener('keydown', fullscreenKey, true);
    document.addEventListener('fullscreenchange', fullscreenChanged);
    canvas.addEventListener('contextmenu', rightClick);
    canvas.addEventListener('click', click);
    canvas.addEventListener('keydown', key);
    canvas.addEventListener('keyup', up);
    canvas.addEventListener('blur', release);
    const visibility = () => { if (document.hidden) release(); };
    document.addEventListener('visibilitychange', visibility);
    const state = { click, rightClick, key, up, release, visibility, gameWindow, fullscreenButton, toggleFullscreen, fullscreenKey, fullscreenChanged, disposed: false, pending: null, patches: [], decoding: false };
    if (streamPath) {
        const url = new URL(streamPath, window.location.href);
        url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
        const connect = () => {
            if (state.disposed) return;
            const socket = new WebSocket(url);
            socket.binaryType = 'arraybuffer';
            state.socket = socket;
            socket.onmessage = event => {
                // Decoding a previous image never queues an unbounded list of stale frames.
                const view = new DataView(event.data);
                const patch = view.byteLength >= 12 && view.getUint32(0) === 0x58575031;
                if (patch) state.patches.push(event.data);
                else { state.pending = event.data; state.patches.length = 0; }
                if (state.patches.length > 2) { state.patches.length = 0; socket.send("keyframe"); }
                void paintLatest(canvas, state);
            };
            socket.onclose = () => {
                if (!state.disposed) state.retryTimer = setTimeout(connect, 500);
            };
            socket.onerror = () => socket.close();
        };
        connect();
    }
    bindings.set(canvas, state);
    canvas.focus();
}

async function paintLatest(canvas, state) {
    if (state.decoding || state.disposed) return;
    state.decoding = true;
    try {
        while ((state.pending || state.patches.length) && !state.disposed) {
            const bytes = state.pending || state.patches.shift();
            state.pending = null;
            const view = new DataView(bytes instanceof ArrayBuffer ? bytes : bytes.buffer, bytes.byteOffset || 0, bytes.byteLength);
            const patch = view.byteLength >= 12 && view.getUint32(0) === 0x58575031;
            const x = patch ? view.getInt32(4) : 0, y = patch ? view.getInt32(8) : 0;
            const image = patch ? new Uint8Array(view.buffer, view.byteOffset + 12, view.byteLength - 12) : bytes;
            const bitmap = await createImageBitmap(new Blob([image], { type: 'image/png' }));
            try { if (!state.disposed) canvas.getContext('2d').drawImage(bitmap, x, y); }
            finally { bitmap.close(); }
        }
    } finally { state.decoding = false; }
}

export async function draw(canvas, bytes) {
    const state = bindings.get(canvas);
    if (!state) return;
    state.pending = bytes;
    await paintLatest(canvas, state);
}

export function focusGame(canvas) { canvas.focus({preventScroll:true}); }

export function detach(canvas) {
    const binding = bindings.get(canvas);
    if (!binding) return;
    binding.disposed = true;
    binding.pending = null;
    binding.patches.length = 0;
    clearTimeout(binding.retryTimer);
    if (binding.socket) { binding.socket.onmessage = null; binding.socket.close(); }
    binding.release();
    binding.fullscreenButton?.removeEventListener("click", binding.toggleFullscreen);
    binding.gameWindow?.removeEventListener("keydown", binding.fullscreenKey, true);
    document.removeEventListener("fullscreenchange", binding.fullscreenChanged);
    if (binding.gameWindow && document.fullscreenElement === binding.gameWindow) void document.exitFullscreen().catch(() => {});
    canvas.removeEventListener('contextmenu', binding.rightClick);
    canvas.removeEventListener('click', binding.click);
    canvas.removeEventListener('keydown', binding.key);
    canvas.removeEventListener('keyup', binding.up);
    canvas.removeEventListener('blur', binding.release);
    document.removeEventListener('visibilitychange', binding.visibility);
    bindings.delete(canvas);
}

// Keep the original pixel art intact; its magenta background is a transparency key.
async function prepareHudArtwork(root) {
    for (const [name, variable] of [["bars.png", "--vital-art"], ["questblips.png", "--quest-art"]]) {
        try {
            const art = new Image();
            art.src = "/gfx/misc/" + name;
            await art.decode();
            const surface = document.createElement("canvas");
            surface.width = art.width; surface.height = art.height;
            const context = surface.getContext("2d");
            context.drawImage(art, 0, 0);
            const pixels = context.getImageData(0, 0, art.width, art.height);
            for (let i = 0; i < pixels.data.length; i += 4)
                if (pixels.data[i] === 255 && pixels.data[i + 1] === 0 && pixels.data[i + 2] === 255) pixels.data[i + 3] = 0;
            context.putImageData(pixels, 0, 0);
            root.style.setProperty(variable, `url("${surface.toDataURL()}")`);
        } catch { /* The original artwork remains available as the CSS fallback. */ }
    }
}
