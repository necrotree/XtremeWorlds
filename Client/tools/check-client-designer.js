(() => {
    let form;
    function visit(node) {
        if (node.name === "frmMirage.frm.tbform" && node.getFullPath().includes("/Sources/Src/")) form = node;
        if (node.entries) Object.values(node.entries).forEach(visit);
    }
    visit(fs.tree.rootFolder);
    if (!form) throw new Error("Main game form definition is missing");
    openEditors.openFile(form, false);
    return form.getFullPath();
})()
