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
