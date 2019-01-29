import { OEAttributes } from './OEAttributes.enum';
import { OEButtons } from './OEButtons.enum';
import { OEConfig } from './OEConfig';
import { OEElement } from './OEElement';
import { OEEvents } from './OEEvents.enum';
import { OESocket } from './OESocket';
/**
 * Provides the interaction between the e2e Protractor tests and
 * Progress OpenEdge applications.
 */
export declare class OEAgent {
    private oeSocket;
    constructor(oeSocket?: OESocket);
    /**
     * Starts the agent application.
     *
     * @param config Configuration object.
     * @returns A promise result of the agent initialization and connection.
     */
    start(config: OEConfig): Promise<boolean | Error>;
    /**
     * Connects to the agent server.
     *
     * @param host Agent server host name or IP address.
     * @param port Agent server port number.
     */
    connect(host: string, port: number): Promise<boolean | Error>;
    /**
     * Returns the agent server connection status.
     * @returns ```true``` if the agent server is connected.
     */
    connected(): boolean;
    /**
     * Waits until an OE window with the informed title is found or a timeout
     * error is raised.
     *
     * @param title OE window title (full or partial).
     * @param timeout Waiting timeout.
     *
     * @returns Window ```OEElement``` instance.
     */
    waitForWindow(title: string, timeout?: number): OEElement;
    /**
     * Searches for an OE window with the informed title.
     *
     * @param title OE window title (full or partial).
     * @returns Window ```OEElement``` instance.
     */
    findWindow(title: string): OEElement;
    /**
     * Wait until an OE widget is found with the informed name attribute or a
     * timeout error is raised.
     *
     * @param name Widget ```NAME``` attribute.
     * @param visible ```true``` to only search visible elements.
     * @param timeout Waiting timeout.
     * @param parent Parent ```OEElement``` instance, if informed the agent
     * will consider a search only by its children.
     *
     * @returns Widget ```OEElement``` instance.
     */
    waitForElement(name: string, visible?: boolean, timeout?: number, parent?: OEElement): OEElement;
    /**
     * Searches for an OE widget with the informed name attribute.
     *
     * @param name Widget ```NAME``` attribute.
     * @param visible ```true``` to only search visible elements.
     * @param parent Parent ```OEElement``` instance, if informed the agent
     * will consider a search only by its children.
     *
     * @returns Widget ```OEElement``` instance.
     */
    findElement(name: string, visible?: boolean, parent?: OEElement): OEElement;
    /**
     * Search for an OE widget with the value of the informed attribute.
     *
     * @param attr Attribute name.
     * @param value Attribute value.
     * @param visible ```true``` to only search visible elements.
     * @param parent Parent ```OEElement``` instance, if informed the agent
     * will consider a search only by its children.
     *
     * @returns Widget ```OEElement``` instance.
     */
    findElementByAttribute(attribute: OEAttributes, value: string, visible?: boolean, parent?: OEElement): OEElement;
    /**
     * Clears the widget ```SCREEN-VALUE```.
     *
     * @param element Widget ```OEElement``` instance.
     * @returns A promise result of the command.
     */
    clear(element: OEElement): Promise<boolean | Error>;
    /**
     * Changes the widget ```SCREEN-VALUE```.
     *
     * @param value Widget's new ```SCREEN-VALUE```.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result of the command.
     */
    sendKeys(value: string | number, element: OEElement): Promise<boolean | Error>;
    /**
     * Checks/Unchecks a TOGGLE-BOX widget.
     *
     * @param check ```true``` to check the widget.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result of the command.
     */
    check(check: boolean, element: OEElement): Promise<boolean | Error>;
    /**
     * Selects a value in a COMBO-BOX or RADIO-SET widget.
     *
     * @param value Selection value.
     * @param partial ```true``` if it's a partial value.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result of the command.
     */
    select(value: string | number, partial: boolean | undefined, element: OEElement): Promise<boolean | Error>;
    /**
     * Selects a row in a BROWSE widget.
     *
     * @param row Row number.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result of the command.
     */
    selectRow(row: number, element: OEElement): Promise<boolean | Error>;
    /**
     * Moves a QUERY result pointer of a BROWSE widget to the specified row.
     *
     * @param row Row number.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result of the command.
     */
    repositionToRow(row: number, element: OEElement): Promise<boolean | Error>;
    /**
     * Fire the widget ```CHOOSE``` event.
     *
     * @param element Widget ```OEElement``` instance.
     * @returns A promise result of the command.
     */
    choose(element: OEElement): Promise<boolean | Error>;
    /**
     * Sends an ```APPLY``` command with an event to the widget.
     *
     * @param event Event name.
     * @param element Widget ```OEElement``` instance.
     * @param wait ```true``` to wait the ```APPLY``` event.
     *
     * @returns A promise result of the command.
     */
    apply(event: OEEvents | string, element: OEElement, wait?: boolean): Promise<boolean | Error>;
    /**
     * Gets the widget's informed attribute value.
     *
     * @param attr Attribute name.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result data of the command.
     */
    get(attr: OEAttributes | string, element: OEElement): Promise<string>;
    /**
     * Sets the widget's informed attribute value.
     *
     * @param attr Attribute name.
     * @param value Attribute value.
     * @param element Widget ```OEElement``` instance.
     *
     * @returns A promise result of the command.
     */
    set(attr: OEAttributes | string, value: string, element: OEElement): Promise<boolean | Error>;
    /**
     * Selects one or more records of the informed table.
     *
     * @param table Table name.
     * @param where Query's WHERE clause.
     *
     * @returns A promise result data of the command.
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
    query(table: string, where: string): Promise<Object | Error>;
    /**
     * Creates one or more records in the informed table.
     *
     * @param table Table name.
     * @param data TEMP-TABLE "like" JSON with the records.
     *
     * @returns A promise result of the command.
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
    create(table: string, data: Object): Promise<boolean | Error>;
    /**
     * Updates one or more records of the informed table.
     *
     * @param table Table name.
     * @param data TEMP-TABLE "like" JSON with the records.
     * @param index Table index columns.
     *
     * @returns A promise result of the command.
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
    update(table: string, data: Object, index: string[]): Promise<boolean | Error>;
    /**
     * Deletes one or more records of the informed table.
     *
     * @param table Table name.
     * @param data TEMP-TABLE "like" JSON with the records.
     * @param index Table index columns.
     *
     * @returns A promise result of the command.
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
    delete(table: string, data: {}, index: string[]): Promise<boolean | Error>;
    /**
     * Sends a ```RUN``` command to open an OE application.
     *
     * @param run OE application path (full or partial according to PROPATH).
     * @param params Application input parameters.
     *
     * @returns A promise result of the command.
     */
    run(run: string, params?: string[]): Promise<boolean | Error>;
    /**
     * Sends a ```QUIT``` command to the agent.
     * This will close all comunication with the agent server.
     *
     * @returns A promise result of the command.
     */
    quit(): Promise<boolean | Error>;
    /**
     * Tests if an application exists with the informed title.
     * OBS: this uses Robot and will consider all opened applications in the OS.
     *
     * @param title Window title.
     * @param timeout Waiting timeout.
     *
     * @returns A promise result of the command.
     */
    windowExists(title: string, timeout?: number): Promise<boolean>;
    /**
     * Sends keyboard events to an application with the informed title.
     * OBS: this uses Robot and will consider all opened applications in the OS.
     *
     * @param title Window title.
     * @param keys Keyboard events.
     * @param timeout Waiting timeout.
     *
     * @returns A promise result of the command.
     */
    windowSendKeys(title: string, keys: string | string[], timeout?: number): Promise<boolean | Error>;
    /**
     * Sends an "OK" click in an OE alert-box error message.
     * @returns A promise result of the command.
     */
    alertErrorOK(): Promise<boolean | Error>;
    /**
     * Send an "OK" click in an OE alert-box warning message.
     * @returns A promise result of the command.
     */
    alertWarningOK(): Promise<boolean | Error>;
    /**
     * Send an "OK" click in an OE alert-box info message.
     * @returns A promise result of the command.
     */
    alertInfoOK(): Promise<boolean | Error>;
    /**
     * Send a "YES" click in an OE alert-box question message.
     * @returns A promise result of the command.
     */
    alertQuestionYes(): Promise<boolean | Error>;
    /**
     * Send a "NO" click in an OE alert-box question message.
     * @returns A promise result of the command.
     */
    alertQuestionNo(): Promise<boolean | Error>;
    /**
     * Sends a click to an OE alert-box message.
     *
     * @param title Alert-box message title.
     * @param button Button type.
     * @param timeout Waiting timeout.
     *
     * @returns A promise result of the command.
     */
    alertClick(title: string, button: OEButtons, timeout?: number): Promise<boolean | Error>;
    /**
     * Build the command line to start the agent application.
     *
     * @param config Configuration object.
     * @returns Built command line.
     */
    private buildCommandLine;
}
//# sourceMappingURL=OEAgent.d.ts.map