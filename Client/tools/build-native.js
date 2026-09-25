new Promise(resolve => debugSocket.request("doBuild", {projectFullPath:projectFilePath, cleanOnly:false, ignoreOldBuild:true}, resolve))
