(() => {
    const errors = [];
    function visit(node) {
        if (node.cachedDiagnostics) {
            for (const d of node.cachedDiagnostics) {
                if (d.severity === 1) errors.push({file: node.name, line: d.range.start.line + 1, code: d.code, message: d.message});
            }
        }
        if (node.entries) Object.values(node.entries).forEach(visit);
    }
    visit(fs.tree.rootFolder);
    return {project: projectFilePath, count: errors.length, errors};
})()
