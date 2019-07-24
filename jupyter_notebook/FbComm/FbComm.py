import sys
sys.path.insert(0, './')
sys.path.insert(1, '../')
import flatbuffers
import MnistProt.Mode
import MnistProt.Command
import MnistProt.Commands
import MnistProt.Stats
import MnistProt.InferenceInput
import MnistProt.InferenceOutput
import socket
import serial
import numpy as np

class FbComm:
    def __init__(self, *args, **kwargs):
        self._version = 100
        self._server_ip = kwargs['ip'] if 'ip' in kwargs else None
        self._server_port = kwargs['port'] if 'port' in kwargs else None
        self._uart = kwargs['uart'] if 'uart' in kwargs else None
        # Create serial port
        self._serial = None
        if self._uart:
            self._serial = serial.Serial(
                port=self._uart,
                baudrate=115200,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                bytesize=serial.EIGHTBITS,
                timeout=0.3, # IMPORTANT, can be lower or higher
                inter_byte_timeout=0.1 # Alternative
                )
            self._serial.isOpen()
        # Create and connect to socket
        self._tcp_client = None
        if self._server_ip:
            self._tcp_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self._tcp_client.connect((self._server_ip, self._server_port))
        print('Comm initialized')

    def __del__(self):
        if self._serial:
            self._serial.close()
        if self._tcp_client:
            self._tcp_client.close()

    def reqStats(self):
        print('Requesting stats...')
        self._builder = flatbuffers.Builder(1024)
        MnistProt.Commands.CommandsStart(self._builder)
        MnistProt.Commands.CommandsAddCmd(self._builder, MnistProt.Command.Command.CMD_GET_STATS)
        req = MnistProt.Commands.CommandsEnd(self._builder)
        self._builder.Finish(req)
        buf = self._builder.Output()
        # Send data
        if self._serial:
            self.sendDataUart(buf)
        if self._tcp_client:
            self.sendDataTcp(buf)
        # Receive data
        print('Receiving stats...')
        inp_buf = bytearray
        if self._serial:
            inp_buf = self._serial.read(100)
        if self._tcp_client:
            inp_buf = self.recvDataTcp()
        resp = MnistProt.Commands.Commands.GetRootAsCommands(inp_buf, 0)
        # Print responce
        print('Command: %d' % resp.Cmd())
        print('Version: %d' % resp.Stats().Version())
        print('Freq: %d' % resp.Stats().Freq())

    def reqInference(self, digit):
        # Create the image vector
        numElems = len(digit)
        print('Num of elements: %d' % numElems)
        builder = flatbuffers.Builder(4096)

        # Build digit
        MnistProt.InferenceInput.InferenceInputStartDigitVector(builder, numElems)
        for i in reversed(range(0, numElems)):
            builder.PrependFloat32(digit[i])
        digit_vect = builder.EndVector(numElems)
        MnistProt.InferenceInput.InferenceInputStart(builder)
        MnistProt.InferenceInput.InferenceInputAddDigit(builder, digit_vect)
        digit_elem = MnistProt.InferenceInput.InferenceInputEnd(builder)
        # Send image data
        print('Sending image data')
        MnistProt.Commands.CommandsStart(builder)
        MnistProt.Commands.CommandsAddCmd(builder, MnistProt.Command.Command.CMD_INFERENCE_INPUT)
        MnistProt.Commands.CommandsAddInput(builder, digit_elem)
        req = MnistProt.Commands.CommandsEnd(builder)
        builder.Finish(req)
        buf = builder.Output()
        if self._serial:
            self.sendDataUart(buf)
        if self._tcp_client:
            self.sendDataTcp(buf)
        # Receive results
        print('Receive results...')
        inp_buf = bytearray
        if self._serial:
            self._serial.timeout = 20
            inp_buf = self._serial.read(92)
        if self._tcp_client:
            inp_buf = self.recvDataTcp()
        resp = MnistProt.Commands.Commands.GetRootAsCommands(inp_buf, 0)
        print('Command: %d'% resp.Cmd())
        print('Execution time: %f msec' % resp.Ouput().TimerMs())
        for i in reversed(range(0, resp.Ouput().OutputFLength())):
            print('Out[%d]: %f' % (i, resp.Ouput().OutputF(i)))

    def sendDataUart(self, data):
        self._serial.write(data)

    def sendDataTcp(self, data):
        # Establish connection to TCP server and exchange data
        self._tcp_client.sendall(data)

    def recvDataTcp(self):
        received = self._tcp_client.recv(1024)
        return received


if __name__=="__main__":
    com = FbComm(ip='127.0.0.1', port=32001)
    # com = FbComm(uart='/dev/ttyUSB0')
    com.reqStats()

    # digit = np.load('../digit.txt.npy')
    # com.reqInference(digit)
