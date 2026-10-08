window.worldEditor={
save(json){localStorage.setItem('xtremeworlds-map-editor-v1',json)},
load(){return localStorage.getItem('xtremeworlds-map-editor-v1')},
export(filename,json){const url=URL.createObjectURL(new Blob([json],{type:'application/json'}));const link=document.createElement('a');link.href=url;link.download=filename.replace(/[^a-z0-9._-]/gi,'_');document.body.append(link);link.click();link.remove();setTimeout(()=>URL.revokeObjectURL(url),1000)},
import(){return new Promise((resolve,reject)=>{const input=document.createElement('input');input.type='file';input.accept='.json,application/json';input.onchange=async()=>{try{resolve(input.files?.[0]?await input.files[0].text():null)}catch(err){reject(err)}};input.click()})}
};