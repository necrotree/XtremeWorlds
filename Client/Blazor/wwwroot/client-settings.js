let handler;
export function install(receiver) {
  if (handler) window.removeEventListener('keydown', handler, true);
  handler = event => {
    if (event.key !== 'F1') return;
    event.preventDefault();
    event.stopPropagation();
    receiver.invokeMethodAsync('ToggleConnectionSettings');
  };
  window.addEventListener('keydown', handler, true);
}
export function uninstall() {
  if (handler) window.removeEventListener('keydown', handler, true);
  handler = undefined;
}

window.downloadServerGraphic = (filename, base64) => {
  const bytes = Uint8Array.from(atob(base64), ch => ch.charCodeAt(0));
  const url = URL.createObjectURL(new Blob([bytes], {type:'image/png'}));
  const link = document.createElement('a');
  link.href = url; link.download = filename; document.body.append(link); link.click(); link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
};
