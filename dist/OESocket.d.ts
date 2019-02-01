import { promise } from 'protractor';
/**
 * Provides a socket communication with the agent server.
 */
export declare class OESocket {
    private retries;
    private isConnected;
    private socket;
    constructor();
    /**
     * Creates a new client connection to the agent server.
     *
     * @param host Agent server host name or IP address.
     * @param port Agent server port number.
     *
     * @returns A promise result of the command.
     */
    connect(host: string, port: number): promise.Promise<boolean | Error>;
    /**
     * Returns the agent server connection status.
     * @returns ```true``` if the agent server is connected.
     */
    connected(): boolean;
    /**
     * Closes the connection with the agent server.
     */
    close(): void;
    /**
     * Event fired when the client connects to the agent server.
     * @param resolve Resolve function of the connection Promise.
     */
    private onConnect;
    /**
     * Event fired when the client closes its communication with the agent server.
     */
    private onClose;
    /**
     * Event fired when a error occurs at with the agent server communication.
     *
     * @param connect Connection function (to retry).
     * @param error Error object that was raised.
     * @param reject The reject function of the connection Promise.
     */
    private onError;
    /**
     * Event fired when the client receives data from the agent server.
     *
     * @param data Data received from the agent server.
     * @returns A promise result according to the received data.
     */
    private onData;
    /**
     * Sends a command to the agent server.
     *
     * @param wait ```true``` if the command needs a response.
     * @param args Command name and arguments.
     */
    send(wait: boolean, ...args: any[]): promise.Promise<string>;
}
//# sourceMappingURL=OESocket.d.ts.map