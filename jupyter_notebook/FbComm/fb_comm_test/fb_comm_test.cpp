//============================================================================
// Name        : fb_comm_test.cpp
// Author      : Dimitris Tassopoulos <dimtass@gmail.com>
// Version     :
// Copyright   : MIT
// Description : Test the FbComm.py on your PC by using sockets. The only reason
//				 that this is a C++ file is that also the code for the STM32F7
//				 is for C++ and also flatbuffers like C++, too.
//============================================================================

#include <iostream>
#include <stdio.h>
#include <string.h> /* memset() */
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>

#include "flatbuffers.h"
#include "mnist_schema_generated.h"

#define PORT    "32001" /* Port to listen on */
#define BACKLOG 10  /* Passed to listen() */
using namespace std;


#define TRACE(X) printf X
#define CODE_VERSION 100
#define SystemCoreClock 216000000

void CmdSendStats(int sock)
{
    flatbuffers::FlatBufferBuilder fbb;

    MnistProt::StatsBuilder stats_builder(fbb);
    stats_builder.add_version(CODE_VERSION);
    stats_builder.add_freq(SystemCoreClock);
    stats_builder.add_mode(MnistProt::Mode_ACCELERATION_CMSIS_NN);
    auto stats = stats_builder.Finish();

    MnistProt::CommandsBuilder builder(fbb);
    builder.add_cmd(MnistProt::Command_CMD_GET_STATS);
    builder.add_stats(stats);
    auto resp = builder.Finish();

    fbb.Finish(resp);

    uint8_t *buf = fbb.GetBufferPointer();
    int buf_size = fbb.GetSize();

    TRACE(("Sending CmdSendStats: %d\n", buf_size));
    send(sock, buf, buf_size, 0);
}

void RunInference(int sock, float *data, size_t data_size)
{
	/* Create fake data */
	flatbuffers::FlatBufferBuilder fbb;

	float output_f[10] = {0,0.2,0,0,0,0.8,0,0,0,0};
	uint32_t end_time = 3254;

    auto out_vect = fbb.CreateVector(output_f, 10);
    auto output = MnistProt::CreateInferenceOutput(fbb, out_vect, 0, end_time);

    MnistProt::CommandsBuilder builder(fbb);
    builder.add_cmd(MnistProt::Command_CMD_INFERENCE_OUTPUT);
    builder.add_ouput(output);
    auto resp = builder.Finish();
    fbb.Finish(resp);

    uint8_t *buf = fbb.GetBufferPointer();
    int buf_size = fbb.GetSize();

    TRACE(("Sending RunInference: %d\n", buf_size));
    send(sock, buf, buf_size, 0);
}

void fb_uart_parser(int sock, uint8_t *buffer, size_t bufferlen)
{
    TRACE(("fb_uart_parser: %lu\n", bufferlen));
    auto req = MnistProt::GetCommands(buffer);

    flatbuffers::Verifier verifier(reinterpret_cast<unsigned char*>(buffer),bufferlen);
    bool isCommand = req->Verify(verifier);
    if (!isCommand) {
        TRACE(("[FB] Invalid flatbuffer data received\n"));
        return;
    }

    TRACE(("[FB] Processing flatbuffer...\n"));
    if (req->cmd() == MnistProt::Command_CMD_GET_STATS) {
        TRACE(("[FB] Sending stats\n"));
        CmdSendStats(sock);
    }
    else if (req->cmd() == MnistProt::Command_CMD_INFERENCE_INPUT) {
        TRACE(("[FB] Running inference on image\n"));
        auto digit = req->input();
        TRACE(("digit size: %d\n", digit->digit()->size()));
        float *p = (float*) digit->digit()->data();

        RunInference(sock, p, digit->digit()->size());
    }
}


void handle(int newsock)
{
    /* recv(), send(), close() */
	uint8_t data[4096];
	int data_len = recv(newsock, data , 4096 , 0);
	TRACE(("[TCP] recv: %d\n", data_len));

	if (data_len > 0) {
		fb_uart_parser(newsock, data, data_len);
	}
}

int main() {
	int sock;
	struct addrinfo hints, *res;
	int reuseaddr = 1; /* True */

	/* Get the address info */
	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	if (getaddrinfo(NULL, PORT, &hints, &res) != 0) {
		perror("getaddrinfo");
		return 1;
	}

	/* Create the socket */
	sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
	if (sock == -1) {
		perror("socket");
		return 1;
	}

	/* Enable the socket to reuse the address */
	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, sizeof(int)) == -1) {
		perror("setsockopt");
		return 1;
	}

	/* Bind to the address */
	if (bind(sock, res->ai_addr, res->ai_addrlen) == -1) {
		perror("bind");
		return 1;
	}

	/* Listen */
	if (listen(sock, BACKLOG) == -1) {
		perror("listen");
		return 1;
	}

	freeaddrinfo(res);

	TRACE(("Listening on port: %s\n", PORT));

	/* Main loop */
	while (1) {
		socklen_t size = sizeof(struct sockaddr_in);
		struct sockaddr_in their_addr;
		int newsock = accept(sock, (struct sockaddr*)&their_addr, &size);

		if (newsock == -1) {
			perror("accept");
		}
		else {
			printf("Got a connection from %s on port %d\n",
					inet_ntoa(their_addr.sin_addr), htons(their_addr.sin_port));
			handle(newsock);
		}
	}

	close(sock);

	return 0;
}

