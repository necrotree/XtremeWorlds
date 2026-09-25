new Promise(resolve => {
    let file;
    function visit(n) {
        if (n.name === "clsDX11Surface.cls") file = n;
        if (n.entries) Object.values(n.entries).forEach(visit);
    }
    visit(fs.tree.rootFolder);
    fs.readFile(file, (code, data) => resolve({code, text: new TextDecoder().decode(data).slice(0,3600)}));
})
