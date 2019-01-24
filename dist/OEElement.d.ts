import { promise } from 'protractor';
import { OEAgent } from './OEAgent';
import { OEAttributes } from './OEAttributes.enum';
import { OEEvents } from './OEEvents.enum';
export declare class OEElement {
    private oe;
    id: number;
    constructor(oe: OEAgent);
    /**
     * Wait until an OE child widget is found with the informed name attribute or
     * a timeout error is raised.
     *
     * @param name Widget ```NAME``` attribute.
     * @param visible ```true``` to only search visible elements.
     * @param timeout Waiting timeout.
     *
     * @returns Widget ```OEElement``` instance.
     */
    waitForElement(name: string, visible?: boolean, timeout?: number): OEElement;
    /**
     * Searches for an OE child widget with the informed name attribute.
     *
     * @param name Widget ```NAME``` attribute.
     * @param visible ```true``` to only search visible elements.
     *
     * @returns Widget ```OEElement``` instance.
     */
    findElement(name: string, visible?: boolean): OEElement;
    /**
     * Search for an OE child widget with the value of the informed attribute.
     *
     * @param attr Attribute name.
     * @param value Attribute value.
     * @param visible ```true``` to only search visible elements.
     *
     * @returns Widget ```OEElement``` instance.
     */
    findElementByAttribute(attribute: OEAttributes, value: string, visible?: boolean): OEElement;
    /**
     * Return this widget ```SENSITIVE``` value.
     * @returns A promise result data of the command.
     */
    isEnabled(): promise.Promise<boolean>;
    /**
     * Return this widget ```CHECKED``` value.
     * @returns A promise result data of the command.
     */
    isChecked(): promise.Promise<boolean>;
    /**
     * Clears this widget ```SCREEN-VALUE```.
     * @returns This widget ```OEElement``` instance.
     */
    clear(): OEElement;
    /**
     * Changes this widget ```SCREEN-VALUE```.
     *
     * @param value Widget's new ```SCREEN-VALUE```.
     * @returns This widget ```OEElement``` instance.
     */
    sendKeys(keys: string | number): OEElement;
    /**
     * Returns this widget ```SCREEN-VALUE```.
     * @returns A promise result data of the command.
     */
    getValue(): promise.Promise<string>;
    /**
     * Checks/Unchecks this TOGGLE-BOX widget.
     *
     * @param check ```true``` to check the widget.
     * @returns This widget ```OEElement``` instance.
     */
    check(check: boolean): OEElement;
    /**
     * Selects a value in this COMBO-BOX or RADIO-SET widget.
     *
     * @param value Selection value.
     * @param partial ```true``` if it's a partial value.
     *
     * @returns This widget ```OEElement``` instance.
     */
    select(value: string | number, partial?: boolean): OEElement;
    /**
     * Selects a row in this BROWSE widget.
     *
     * @param row Row number.
     * @returns This widget ```OEElement``` instance.
     */
    selectRow(row: number): OEElement;
    /**
     * Moves the QUERY result pointer of this BROWSE widget to the specified row.
     *
     * @param row Row number.
     * @returns This widget ```OEElement``` instance.
     */
    repositionToRow(row: number): OEElement;
    /**
     * Fire this widget ```CHOOSE``` event.
     * @returns This widget ```OEElement``` instance.
     */
    choose(): OEElement;
    /**
     * Sends an ```APPLY``` command with an event to this widget.
     *
     * @param event Event name.
     * @returns This widget ```OEElement``` instance.
     */
    apply(apply: OEEvents | string): OEElement;
    /**
     * Gets this widget's informed attribute value.
     *
     * @param attr Attribute name.
     * @returns A promise result data of the command.
     */
    get(attribute: OEAttributes): promise.Promise<string>;
    /**
     * Sets this widget's informed attribute value.
     *
     * @param attr Attribute name.
     * @param value Attribute value.
     *
     * @returns This widget ```OEElement``` instance.
     */
    set(attribute: OEAttributes, value: string): OEElement;
}
//# sourceMappingURL=OEElement.d.ts.map