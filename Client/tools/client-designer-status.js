(() => {
    const g = getCurrentFormEditorGlobals();
    return {
        form: g?.designer?.properties?.Name,
        count: g?.allControls?.length,
        controls: g?.allControls?.filter(c => /^(host|cmdEditor)/.test(c.properties?.Name)).map(c => ({name:c.properties?.Name, type:c.properties?._className})),
        dialogs: Array.from(document.querySelectorAll('.simpleMsgBox')).map(n => n.innerText)
    };
})()
