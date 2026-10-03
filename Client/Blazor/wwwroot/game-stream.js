const bindings = new WeakMap();
export function attach(canvas, receiver) {
    const click = event => {
        canvas.focus();
        const rect = canvas.getBoundingClientRect();
        receiver.invokeMethodAsync('Click', Math.floor((event.clientX - rect.left) * 950 / rect.width), Math.floor((event.clientY - rect.top) * 700 / rect.height));
    };
    const key = event => {
        if (event.ctrlKey || event.metaKey || event.altKey || event.key === 'Tab') return;
        event.preventDefault();
        if (!event.repeat) receiver.invokeMethodAsync('Key', event.key);
    };
    canvas.addEventListener('click', click);
    canvas.addEventListener('keydown', key);
    bindings.set(canvas, { click, key });
    canvas.focus();
}
export async function draw(canvas, bytes) {
    const bitmap = await createImageBitmap(new Blob([bytes], { type: 'image/png' }));
    try { canvas.getContext('2d').drawImage(bitmap, 0, 0, 950, 700); }
    finally { bitmap.close(); }
}
export function detach(canvas) {
    const binding = bindings.get(canvas);
    if (!binding) return;
    canvas.removeEventListener('click', binding.click);
    canvas.removeEventListener('keydown', binding.key);
    bindings.delete(canvas);
}
