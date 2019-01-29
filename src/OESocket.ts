import * as net from 'net';
import { promise } from 'protractor';

import { MessageType, OEUtils } from './OEUtils';

/**
 * Provides a socket communication with the agent server.
 */
export class OESocket {
  private isConnected = false;
  private socket!: net.Socket;

  constructor() {}

  /**
   * Creates a new client connection to the agent server.
   *
   * @param host Agent server host name or IP address.
   * @param port Agent server port number.
   *
   * @returns A promise result of the command.
   */
  public connect(host: string, port: number): promise.Promise<boolean | Error> {
    return new Promise((resolve, reject) => {
      OEUtils.consoleLogMessage(`Connecting on agent server at "${host}:${port}"`, MessageType.INFO);

      const connect = () => this.socket = net.createConnection(port, host);
      const retries = 5;

      connect();

      this.socket.on('connect', () => this.onConnect(resolve));
      this.socket.on('close', () => this.onClose());
      this.socket.on('error', (error: Error) => this.onError(connect, retries, error, reject));
    });
  }

  /**
   * Returns the agent server connection status.
   * @returns ```true``` if the agent server is connected.
   */
  public connected(): boolean {
    return this.isConnected;
  }

  /**
   * Closes the connection with the agent server.
   */
  public close(): void {
    this.socket.end();
  }

  /**
   * Event fired when the client connects to the agent server.
   * @param resolve Resolve function of the connection Promise.
   */
  private onConnect(resolve): void {
    this.isConnected = true;
    OEUtils.consoleLogMessage(`Agent server successfuly connected`, MessageType.SUCCESS);
    resolve(true);
  }

  /**
   * Event fired when the client closes its communication with the agent server.
   */
  private onClose(): void {
    this.socket.removeAllListeners();
    this.socket.destroy();
    this.socket = undefined as unknown as net.Socket;
    this.isConnected = false;
    OEUtils.consoleLogMessage(`Agent server connection closed`, MessageType.WARNING);
  }

  /**
   * Event fired when a error occurs at with the agent server communication.
   *
   * @param connect Connection function (to retry).
   * @param retries Maximum of connection retries.
   * @param error Error object that was raised.
   * @param reject The reject function of the connection Promise.
   */
  private onError(connect: Function, retries: number, error: NodeJS.ErrnoException, reject: (error: Error) => void): void {
    if (error.code === 'ECONNRESET') {
      this.socket.end();
    } else if (retries > 0) {
      retries--;
      setTimeout(connect, 1000);
    } else {
      OEUtils.consoleLogMessage(`Agent server connection error: ${error.message}`, MessageType.ERROR);
      reject(error);
    }
  }

  /**
   * Event fired when the client receives data from the agent server.
   *
   * @param data Data received from the agent server.
   * @returns A promise result according to the received data.
   */
  private onData(data: string): promise.Promise<string> {
    let promise: promise.Promise<string>;

    const output = data.split('|');
    const status = output[0].toUpperCase();
    const result = output.length > 1 ? output[1] : '';

    if (status === 'OK') {
      OEUtils.consoleLogMessage(`Data received: "${data}"`, MessageType.SUCCESS);
      promise = Promise.resolve(result);
    } else {
      OEUtils.consoleLogMessage(`Data received: "${data}"`, MessageType.ERROR);
      promise = Promise.reject<string>(new Error(result));
    }

    return promise;
  }

  /**
   * Sends a command to the agent server.
   *
   * @param wait ```true``` if the command needs a response.
   * @param args Command name and arguments.
   */
  public send(wait: boolean, ...args: any[]): promise.Promise<string> {
    return new Promise((resolve, reject) => {
      const message = `${wait}|${args.join('|')}`;

      OEUtils.consoleLogMessage(`Sending data: "${message}"`, MessageType.INFO);
      this.socket.write(message);

      if (wait) {
        this.socket.once('data', (data: Buffer) => this.onData(data.toString('utf-8')).then(resolve).catch(reject));
      } else {
        resolve('OK');
      }
    });
  }
}
