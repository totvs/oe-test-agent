/**
 * Message type enum.
 * This should be used together with ```OEUtils.consoleLogMessage```.
 */
export declare enum MessageType {
    INFO = 1,
    WARNING = 2,
    ERROR = 3,
    SUCCESS = 4,
    FATAL = 5
}
export declare class OEUtils {
    /**
     * Shows a console message.
     *
     * @param message Message text.
     * @param type Message type.
     */
    static consoleLogMessage(message: string, type: MessageType): void;
}
