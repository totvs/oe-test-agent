"use strict";var __awaiter=this&&this.__awaiter||function(e,t,r,o){return new(r||(r=Promise))(function(n,s){function i(e){try{a(o.next(e))}catch(e){s(e)}}function c(e){try{a(o.throw(e))}catch(e){s(e)}}function a(e){e.done?n(e.value):new r(function(t){t(e.value)}).then(i,c)}a((o=o.apply(e,t||[])).next())})};Object.defineProperty(exports,"__esModule",{value:!0});const child_process_1=require("child_process"),protractor_1=require("protractor"),OEButtons_enum_1=require("./OEButtons.enum"),OEElement_1=require("./OEElement"),OESocket_1=require("./OESocket"),OEUtils_1=require("./OEUtils");class OEAgent{constructor(e=new OESocket_1.OESocket){this.oeSocket=e}start(e){return protractor_1.browser.call(()=>new Promise((t,r)=>{const o=this.buildCommandLine(e),n=`${__dirname.replace(/\\/g,"/")}/abl/`;OEUtils_1.OEUtils.consoleLogMessage(`Executing OpenEdge with command line: ${o}`,OEUtils_1.MessageType.INFO),OEUtils_1.OEUtils.consoleLogMessage(`Current working directory: ${n}`,OEUtils_1.MessageType.INFO);const s=child_process_1.exec(o,{cwd:n}),i=new Promise(e=>setTimeout(()=>e({status:!0}),1e4)),c=new Promise(e=>s.on("error",t=>e({status:!1,error:t})));return Promise.race([i,c]).then(o=>o.status?this.connect(e.host,e.port).then(t):r(o.error))}))}connect(e,t){return protractor_1.browser.call(()=>this.oeSocket.connect(e,t))}connected(){return this.oeSocket.connected()}waitForWindow(e,t=OEAgent.DEFAULT_TIMEOUT){const r=new OEElement_1.OEElement(this);return protractor_1.browser.wait(()=>__awaiter(this,void 0,void 0,function*(){try{const t=yield this.oeSocket.send(!0,"FINDWINDOW",e);return r.id=parseInt(t),!0}catch(e){return yield protractor_1.browser.sleep(2e3),!1}}),t),r}findWindow(e){const t=new OEElement_1.OEElement(this);return protractor_1.browser.call(()=>this.oeSocket.send(!0,"FINDWINDOW",e).then(e=>t.id=parseInt(e))),t}waitForElement(e,t=!0,r=OEAgent.DEFAULT_TIMEOUT,o){const n=new OEElement_1.OEElement(this);return protractor_1.browser.wait(()=>__awaiter(this,void 0,void 0,function*(){try{const r=yield this.oeSocket.send(!0,"FINDELEMENT",e,t,o?o.id:"");return n.id=parseInt(r),!0}catch(e){return yield protractor_1.browser.sleep(2e3),!1}}),r),n}findElement(e,t=!0,r){const o=new OEElement_1.OEElement(this);return protractor_1.browser.call(()=>this.oeSocket.send(!0,"FINDELEMENT",e,t,r?r.id:"").then(e=>o.id=parseInt(e))),o}findElementByAttribute(e,t,r=!0,o){const n=new OEElement_1.OEElement(this);return protractor_1.browser.call(()=>this.oeSocket.send(!0,"FINDELEMENTBYATTRIBUTE",e,t,r,o?o.id:"").then(e=>n.id=parseInt(e))),n}isElementValid(e){return protractor_1.browser.call(()=>e.id>0).then(()=>!0).catch(()=>!1)}clear(e){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"CLEAR",e.id).then(()=>!0))}sendKeys(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"SENDKEYS",t.id,e).then(()=>!0))}check(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"CHECK",t.id,e).then(()=>!0))}select(e,t=!1,r){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"SELECT",r.id,e,t).then(()=>!0))}selectRow(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"SELECTROW",t.id,e).then(()=>!0))}repositionToRow(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"REPOSITIONTOROW",t.id,e).then(()=>!0))}choose(e){return protractor_1.browser.call(()=>this.oeSocket.send(!1,"CHOOSE",e.id).then(()=>protractor_1.browser.sleep(1e3)).then(()=>!0))}apply(e,t,r=!1){return protractor_1.browser.call(()=>this.oeSocket.send(r,"APPLY",t.id,e).then(()=>protractor_1.browser.sleep(1e3)).then(()=>!0))}get(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"GET",t.id,e))}set(e,t,r){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"SET",r.id,e,t).then(()=>!0))}query(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"QUERY",e,t).then(e=>JSON.parse(e)))}create(e,t){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"CREATE",e,JSON.stringify(t)).then(()=>!0))}update(e,t,r){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"UPDATE",e,JSON.stringify(t),JSON.stringify(r)).then(()=>!0))}delete(e,t,r){return protractor_1.browser.call(()=>this.oeSocket.send(!0,"DELETE",e,JSON.stringify(t),JSON.stringify(r)).then(()=>!0))}run(e,t=[]){return protractor_1.browser.call(()=>this.oeSocket.send(!1,"RUN",e,t).then(()=>protractor_1.browser.sleep(1e3))).then(()=>!0)}quit(){return protractor_1.browser.call(()=>this.oeSocket.send(!1,"QUIT").then(()=>protractor_1.browser.sleep(2e3))).then(()=>!0)}windowExists(e,t=OEAgent.DEFAULT_TIMEOUT){return protractor_1.browser.call(()=>new Promise(r=>{let o=!0;OEUtils_1.OEUtils.consoleLogMessage(`(Robot) Searching "${e}" window`,OEUtils_1.MessageType.INFO);try{child_process_1.execSync(`${__dirname.replace(/\\/g,"/")}/robot/Robot.exe -t ${t} -w "${e}"`)}catch(e){o=!1}r(o)}))}windowSendKeys(e,t,r=OEAgent.DEFAULT_TIMEOUT){return protractor_1.browser.call(()=>new Promise((o,n)=>{const s=(t=Array.isArray(t)?t:[t]).join("");OEUtils_1.OEUtils.consoleLogMessage(`(Robot) Sending keyboard events "${s}" to "${e}" window`,OEUtils_1.MessageType.INFO);try{child_process_1.execSync(`${__dirname.replace(/\\/g,"/")}/robot/Robot.exe -t ${r} -w "${e}" -k ${s}`),o(!0)}catch(e){n(e)}}))}alertErrorOK(){return this.alertClick("Error",OEButtons_enum_1.OEButtons.OK)}alertWarningOK(){return this.alertClick("Warning",OEButtons_enum_1.OEButtons.OK)}alertInfoOK(){return this.alertClick("Information",OEButtons_enum_1.OEButtons.OK)}alertQuestionYes(){return this.alertClick("Question",OEButtons_enum_1.OEButtons.YES)}alertQuestionNo(){return this.alertClick("Question",OEButtons_enum_1.OEButtons.NO)}alertClick(e,t,r=OEAgent.DEFAULT_TIMEOUT){return protractor_1.browser.call(()=>new Promise((o,n)=>{OEUtils_1.OEUtils.consoleLogMessage(`(Robot) Sending "${t}" click to "${e}" alert-box message`,OEUtils_1.MessageType.INFO);try{child_process_1.execSync(`${__dirname.replace(/\\/g,"/")}/robot/Robot.exe -t ${r} -w "${e}" -b ${t}`),o(!0)}catch(e){n(e)}}))}buildCommandLine(e){let t="",r="";return t+=`${e.host},`,t+=`${e.port},`,t+=`${e.outDir},`,t+=`${(e.propath||[]).join("|")},`,t+=`${e.startupFile},`,t+=`${(e.startupFileParams||[]).join("|")},`,t+=`${e.inputCodepage||"UTF-8"}`,r+=`"${e.dlcHome}/bin/prowin32.exe"`,r+=` -p "${__dirname.replace(/\\/g,"/")}/abl/OEStart.p"`,r+=` -param "${t}"`,e.parameterFile&&(r+=` -pf "${e.parameterFile}"`),e.iniFile&&(r+=` -basekey ini -ininame "${e.iniFile}"`),r}}OEAgent.DEFAULT_TIMEOUT=5e3,exports.OEAgent=OEAgent,exports.oeAgent=new OEAgent;