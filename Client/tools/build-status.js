({
    project: projectFilePath,
    debugMode,
    output: debugConsoleOutput?.innerText?.slice(-2000),
    dialogs: Array.from(document.querySelectorAll('.simpleMsgBox')).map(n => n.innerText),
    buildPath: projectBuildPath
})
