const bindings = new WeakMap();
export function attach(canvas, receiver, streamPath) {
    const click = event => {
        canvas.focus();
        const rect = canvas.getBoundingClientRect();
        receiver.invokeMethodAsync('Click', Math.floor((event.clientX - rect.left) * 950 / rect.width), Math.floor((event.clientY - rect.top) * 700 / rect.height));
    };
    const held = new Set();
    const normalizeMovement = key => ({
        w: "ArrowUp", W: "ArrowUp", s: "ArrowDown", S: "ArrowDown",
        a: "ArrowLeft", A: "ArrowLeft", d: "ArrowRight", D: "ArrowRight"
    })[key] || (["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"].includes(key) ? key : null);
    const movement = key => normalizeMovement(key) !== null;
    const release = () => {
        for (const key of held) receiver.invokeMethodAsync('Movement', key, false);
        held.clear();
    };
    const up = event => {
        if (!movement(event.key)) return;
        event.preventDefault();
        const direction = normalizeMovement(event.key);
        held.delete(direction);
        receiver.invokeMethodAsync('Movement', direction, false);
    };
    const key = event => {
        if (event.ctrlKey || event.metaKey || event.altKey || event.key === 'Tab') return;
        event.preventDefault();
        if (movement(event.key)) {
            const direction = normalizeMovement(event.key);
            if (!held.has(direction)) { held.add(direction); receiver.invokeMethodAsync('Movement', direction, true); }
        } else if (!event.repeat) receiver.invokeMethodAsync('Key', event.key);
    };
    canvas.addEventListener('click', click);
    canvas.addEventListener('keydown', key);
    canvas.addEventListener('keyup', up);
    canvas.addEventListener('blur', release);
    const visibility = () => { if (document.hidden) release(); };
    document.addEventListener('visibilitychange', visibility);
    const state = { click, key, up, release, visibility, disposed: false, pending: null, patches: [], decoding: false };
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
    canvas.removeEventListener('click', binding.click);
    canvas.removeEventListener('keydown', binding.key);
    canvas.removeEventListener('keyup', binding.up);
    canvas.removeEventListener('blur', binding.release);
    document.removeEventListener('visibilitychange', binding.visibility);
    bindings.delete(canvas);
}
