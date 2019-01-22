import { exec, execSync } from 'child_process';
import { browser, promise } from 'protractor';

import { OEAttributes } from './OEAttributes.enum';
import { OEButtons } from './OEButtons.enum';
import { OEConfig } from './OEConfig';
import { OEElement } from './OEElement';
import { OEEvents } from './OEEvents.enum';
import { OEResultConn, OEResultData, OESocket } from './OESocket';
import { MessageType, OEUtils } from './OEUtils';

/**
 * Provides a communication link between Protractor and OpenEdge applications
 * for e2e tests. An ```OE Test Agent``` application will be executed to create
 * the integration tools, using socket communication.
 */
export class OEAgent {
  constructor(private oeSocket = new OESocket()) {}

  /**
   * Start the agent with the informed configuration.
   * This is the main method and has to be called before any other methods.
   *
   * @param config Configuration object with the initialization parameters.
   * @returns A promise result of the agent initialization and connection.
   */
  public start(config: OEConfig): OEResultConn {
    return browser.call(() => {
      const cmd = this.buildCommandLine(config);
      const cwd = `${__dirname.replace(/\\/g, '/')}/abl/`;

      OEUtils.consoleLogMessage(`Executing OpenEdge with command line: ${cmd}`, MessageType.INFO);
      OEUtils.consoleLogMessage(`Current working directory: ${cwd}`, MessageType.INFO);

      const run = exec(cmd, { cwd: cwd });

      // Will use "race" to guess if OpenEdge has been successfully opened.
      // This is not a 100% guarantee thing.
      const suc = new Promise((resolve) => setTimeout(() => resolve({ status: true }), 5 * 1000));
      const err = new Promise((resolve) => run.on('error', (error: Error) => resolve({ status: false, error: error })));

      return Promise.race([suc, err]).then((result) => {
        return result['status'] ? this.connect(config.host, config.port) : Promise.reject(result['error']);
      });
    });
  }

  /**
   * Establish a connection with OE Test Agent server.
   *
   * @param host Agent server host name or IP address.
   * @param port Agent server port number.
   */
  public connect(host: string, port: number): OEResultConn {
    return browser.call(() => this.oeSocket.connect(host, port));
  }

  public connected(): boolean {
    return this.oeSocket.connected();
  }

  /**
   * Search for an OE window widget with the informed title.
   *
   * @param title OE window title (full or partial).
   * @returns Window widget ```OEElement``` instance.
   */
  public findWindow(title: string): OEElement {
    const element: OEElement = new OEElement(this);

    browser.call(() => this.oeSocket.send(true, true, 'FINDWINDOW', title).then((id: string) => (element.id = parseInt(id))));

    return element;
  }

  /**
   * Wait until an OE window widget with the informed title is found or a
   * timeout error is raised.
   *
   * @param title OE window title (full or partial).
   * @param timeout Waiting timeout.
   *
   * @returns Window widget ```OEElement``` instance.
   */
  public waitForWindow(title: string, timeout = 10000): OEElement {
    const element = new OEElement(this);

    browser.wait(() => {
      return this.oeSocket.send(false, true, 'FINDWINDOW', title)
        .then((id: string) => (element.id = parseInt(id))).catch(() => browser.sleep(2000));
    }, timeout);

    return element;
  }

  /**
   * Search for an OE widget with the informed name attribute.
   *
   * @param name Widget ```NAME``` attribute.
   * @param visible ```true``` to only search visible elements.
   * @param parent Parent ```OEElement``` instance, if informed the agent
   * will consider a search only by the parent's children widgets.
   *
   * @returns Widget ```OEElement``` instance.
   */
  public findElement(name: string, visible = true, parent?: OEElement): OEElement {
    const element = new OEElement(this);
    const parentId = parent ? parent.id : '';

    browser.call(() => this.oeSocket.send(true, true, 'FINDELEMENT', name, visible, parentId).then((id: string) => (element.id = parseInt(id))));

    return element;
  }

  /**
   * Search for an OE widget considering the value of the informed attribute.
   *
   * @param attr Attribute name.
   * @param value Attribute value.
   * @param visible ```true``` to only search visible elements.
   * @param parent Parent ```OEElement``` instance, if informed the agent
   * will consider a search only by the parent's children widgets.
   *
   * @returns Widget ```OEElement``` instance.
   */
  public findElementByAttribute(attribute: OEAttributes, value: string, visible = true, parent?: OEElement): OEElement {
    const element = new OEElement(this);
    const parentId = parent ? parent.id : '';

    browser.call(() => this.oeSocket.send(true, true, 'FINDELEMENTBYATTRIBUTE', attribute, value, visible, parentId).then((id: string) => (element.id = parseInt(id))));

    return element;
  }

  /**
   * Wait until an OE widget is found with the informed name or a timeout
   * error is raised.
   *
   * @param name Widget ```NAME``` attribute.
   * @param timeout Waiting timeout.
   * @param visible ```true``` to only search visible elements.
   * @param parent Parent ```OEElement``` instance, if informed the agent
   * will consider a search only by the parent's children widgets.
   *
   * @returns Widget ```OEElement``` instance.
   */
  public waitForElement(name: string, visible = true, timeout = 10000, parent?: OEElement): OEElement {
    const element = new OEElement(this);
    const parentId = parent ? parent.id : '';

    browser.wait(() => {
      return this.oeSocket.send(false, true, 'FINDELEMENT', name, visible, parentId)
        .then((id: string) => (element.id = parseInt(id))).catch(() => browser.sleep(2000));
    }, timeout);

    return element;
  }

  /**
   * Get an attribute value of the informed element.
   *
   * @param element Widget ```OEElement``` instance.
   * @param attr Attribute name.
   *
   * @returns A result promise data of the command.
   */
  public get(attr: OEAttributes | string, element: OEElement): OEResultData {
    return browser.call(() => this.oeSocket.send(true, true, 'GET', element.id, attr));
  }

  /**
   * Set an attribute value to the informed element.
   *
   * @param element Widget ```OEElement``` instance.
   * @param attr Attribute name.
   * @param value Attribute value.
   *
   * @returns A result promise of the command.
   */
  public set(attr: OEAttributes | string, value: string, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'SET', element.id, attr, value).then(() => true));
  }

  public clear(element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'CLEAR', element.id).then(() => true));
  }

  /**
   * Send keys events to the informed element.
   *
   * @param keys Text or keys that will be sent to the element.
   * @param element Widget ```OEElement``` instance.
   *
   * @returns A result promise of the command.
   */
  public sendKeys(keys: string | number, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'SENDKEYS', element.id, keys).then(() => true));
  }

  /**
   * Select a row in a OE BROWSE widget.
   *
   * @param row Row number.
   * @param element Browse widget ```OEElement``` instance.
   *
   * @returns A result promise of the command.
   */
  public selectRow(row: number, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'SELECTROW', element.id, row).then(() => true));
  }

  /**
   * Moves a QUERY object result pointer of the informed BROWSE widget to the
   * specified row.
   *
   * @param element Browse widget ```OEElement``` instance.
   * @param row Row number.
   *
   * @returns A result promise of the command.
   */
  public repositionToRow(row: number, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'REPOSITIONTOROW', element.id, row).then(() => true));
  }

  /**
   * Check/Uncheck a TOGGLE-BOX widget.
   *
   * @param check ```true``` to check the widget.
   * @param element Browse widget ```OEElement``` instance.
   *
   * @returns A result promise of the command.
   */
  public check(check: boolean, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'CHECK', element.id, check).then(() => true));
  }

  /**
   * Select a value in a COMBO-BOX widget.
   *
   * @param value Selection value.
   * @param partial ```true``` to select the value even if it's partial.
   * @param element widget ```OEElement``` instance.
   *
   * @returns A result promise of the command.
   */
  public select(value: string | number, partial = false, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'SELECT', element.id, value, partial).then(() => true));
  }

  /**
   * Fire a ```CHOOSE``` event to the informed element.
   * OBS: There's a ```browser.sleep``` call to prevent overloading the server.
   *
   * @param element Widget ```OEElement``` instance.
   * @returns A result promise of the command.
   */
  public choose(element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, false, 'CHOOSE', element.id).then(() => browser.sleep(500)).then(() => true));
  }

  /**
   * Send an ```APPLY``` command to fire an event to the informed element.
   * OBS: There's a ```browser.sleep``` call to prevent overloading the server.
   *
   * @param event Event name.
   * @param element Widget ```OEElement``` instance.
   *
   * @returns A result promise of the command.
   */
  public apply(event: OEEvents | string, element: OEElement): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, false, 'APPLY', element.id, event).then(() => browser.sleep(500)).then(() => true));
  }

  /**
   * Query for one or more records in a OE table.
   *
   * @param table Table name.
   * @param where Query's WHERE clause.
   *
   * @returns A result promise data of the command.
   *
   * @example
   * ```typescript
   * const oe = new OEAgent();
   * let data: Object;
   *
   * oe.query("Department", "WHERE DeptCode = 'PRC'").then((result) => data = result);
   *
   * // The result of data will be:
   * // {
   * //   "Department": [{
   * //     "DeptCode": "PRC",
   * //     "DeptName": "Purchasing"
   * //   }]
   * // };
   * ```
   */
  public query(table: string, where: string): OEResultData {
    return browser.call(() => this.oeSocket.send(true, true, 'QUERY', table, where).then((result) => JSON.parse(result)));
  }

  /**
   * Create one or more records in a OE table.
   *
   * @param table Table name.
   * @param data TEMP-TABLE "like" JSON with the records.
   *
   * @returns A result promise of the command.
   *
   * @example
   * ```typescript
   * const oe = new OEAgent();
   * const data = {
   *   "Department": [{
   *     "DeptCode": "PRC",
   *     "DeptName": "Purchasing"
   *   },{
   *     "DeptCode": "HRM",
   *     "DeptName": "HR Management"
   *   }]
   * };
   *
   * oe.create("Department", data);
   * ```
   */
  public create(table: string, data: {}): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'CREATE', table, JSON.stringify(data)).then(() => true));
  }

  /**
   * Update one or more records in a OE table.
   *
   * @param table Table name.
   * @param data TEMP-TABLE "like" JSON with the records.
   * @param index Table index columns.
   *
   * @returns A result promise of the command.
   *
   * @example
   * ```typescript
   * const oe = new OEAgent();
   * const data = {
   *   "Department": [{
   *     "DeptCode": "PRC",
   *     "DeptName": "Purchasing Dept."
   *   },{
   *     "DeptCode": "HRM",
   *     "DeptName": "HR Managm. Dept."
   *   }]
   * };
   *
   * oe.update("Department", data, ["DeptCode"]);
   * ```
   */
  public update(table: string, data: {}, index: string[]): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'UPDATE', table, JSON.stringify(data), JSON.stringify(index)).then(() => true));
  }

  /**
   * Delete one or more records in a OE table.
   *
   * @param table Table name.
   * @param data TEMP-TABLE "like" JSON with the records.
   * @param index Table index columns.
   *
   * @returns A result promise of the command.
   *
   * @example
   * ```typescript
   * const oe = new OEAgent();
   * const data = {
   *   "Department": [{
   *     "DeptCode": "PRC"
   *   },{
   *     "DeptCode": "HRM"
   *   }]
   * };
   *
   * oe.delete("Department", data, ["DeptCode"]);
   * ```
   */
  public delete(table: string, data: {}, index: string[]): OEResultConn {
    return browser.call(() => this.oeSocket.send(true, true, 'DELETE', table, JSON.stringify(data), JSON.stringify(index)).then(() => true));
  }

  /**
   * Return ```true``` with there's an application with the informed title.
   * OBS: this is search all opened applications in the OS.
   *
   * @param title Window title.
   * @param timeout Waiting timeout.
   */
  public windowExists(title: string, timeout = 10000): promise.Promise<boolean> {
    return browser.call(() => new Promise((resolve) => {
      let winExists = true;

      try {
        execSync(`${__dirname.replace(/\\/g, '/')}/robot/Robot.exe -t ${timeout} -w "${title}"`);
      } catch (error) {
        winExists = false;
      }

      resolve(winExists);
    }));
  }

  /**
   * Send keys to an application with the informed title.
   * OBS: this is search all opened applications in the OS.
   *
   * @param title Window title.
   * @param keys Text or keys that will be sent.
   * @param timeout Waiting timeout.
   */
  public windowSendKeys(title: string, keys: string | string[], timeout = 10000): OEResultConn {
    return browser.call(() => new Promise((resolve, reject) => {
      keys = Array.isArray(keys) ? keys : [keys];
      keys = keys.join('');

      try {
        execSync(`${__dirname.replace(/\\/g, '/')}/robot/Robot.exe -t ${timeout} -w "${title}" -k ${keys}`);
        resolve(true);
      } catch (error) {
        reject(error);
      }
    }));
  }

  /**
   * Send an OK click in an OE alert-box error message.
   */
  public alertErrorOK(): OEResultConn {
    return this.alertClick('Error', OEButtons.OK);
  }

  /**
   * Send an OK click in an OE alert-box warning message.
   */
  public alertWarningOK(): OEResultConn {
    return this.alertClick('Warning', OEButtons.OK);
  }

  /**
   * Send an OK click in an OE alert-box info message.
   */
  public alertInfoOK(): OEResultConn {
    return this.alertClick('Information', OEButtons.OK);
  }

  /**
   * Send an YES click in an OE alert-box question message.
   */
  public alertQuestionYes(): OEResultConn {
    return this.alertClick('Question', OEButtons.YES);
  }

  /**
   * Send an NO click in an OE alert-box question message.
   */
  public alertQuestionNo(): OEResultConn {
    return this.alertClick('Question', OEButtons.NO);
  }

  /**
   * Send a click to an OE alert-box message.
   *
   * @param title Alert-box message title.
   * @param button Button type.
   * @param timeout Waiting timeout
   *
   * @return A result promise of the command.
   */
  public alertClick(title: string, button: OEButtons, timeout = 10000): OEResultConn {
    return browser.call(() => new Promise((resolve, reject) => {
      try {
        execSync(`${__dirname.replace(/\\/g, '/')}/robot/Robot.exe -t ${timeout} -w "${title}" -b ${button}`);
        resolve(true);
      } catch (error) {
        reject(error);
      }
    }));
  }

  /**
   * Send a ```RUN``` command to open an OE application.
   * OBS: There's a ```browser.sleep``` call to prevent overloading the server.
   *
   * @param run OE application path (full or partial according to PROPATH).
   * @param params Application input parameters.
   */
  public run(run: string, params: string[] = []): void {
    browser.call(() => this.oeSocket.send(true, false, 'RUN', run, params).then(() => browser.sleep(500)));
  }

  /**
   * Send a ```QUIT``` command to the agent. This will close the comunication
   * with the agent and quit the application.
   * OBS: There's a ```browser.sleep``` call to prevent overloading the server.
   */
  public quit(): void {
    browser.call(() => this.oeSocket.send(true, false, `QUIT`).then(() => browser.sleep(500)));
  }

  /**
   * Build the command line to start the agent application.
   *
   * @param config Configuration object.
   * @returns Built command line.
   */
  private buildCommandLine(config: OEConfig): string {
    let prm = '';
    let cmd = '';

    // Load the session parameters.
    prm += `${config.host},`;
    prm += `${config.port},`;
    prm += `${config.outDir},`;
    prm += `${(config.propath || []).join('|')},`;
    prm += `${config.startupFile},`;
    prm += `${(config.startupFileParams || []).join('|')},`;
    prm += `${config.inputCodepage || 'UTF-8'}`;

    // Load the command line.
    cmd += `"${config.dlcHome}/bin/prowin32.exe"`;
    cmd += ` -p "${__dirname.replace(/\\/g, '/')}/abl/OEStart.p"`;
    cmd += ` -param "${prm}"`;

    if (config.parameterFile) {
      cmd += ` -pf "${config.parameterFile}"`;
    }

    if (config.iniFile) {
      cmd += ` -basekey ini -ininame "${config.iniFile}"`;
    }

    return cmd;
  }
}
