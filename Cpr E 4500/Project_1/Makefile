# Project: RPC Date Service
# Platform: macOS
# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall -Wextra -std=c99

# RPC libraries (macOS)
RPC_LIBS = -lrpcsvc

# Source files
SERVER_SRCS = server.c date_svc.c
CLIENT_SRCS = client.c date_clnt.c

# Object files
SERVER_OBJS = $(SERVER_SRCS:.c=.o)
CLIENT_OBJS = $(CLIENT_SRCS:.c=.o)

# Targets
all: server client

# Build server
server: $(SERVER_OBJS)
	$(CC) $(CFLAGS) -o server $(SERVER_OBJS) $(RPC_LIBS)

# Build client
client: $(CLIENT_OBJS)
	$(CC) $(CFLAGS) -o client $(CLIENT_OBJS) $(RPC_LIBS)

# Compile .c to .o
%.o: %.c date.h
	$(CC) $(CFLAGS) -c $<

# Clean build artifacts
clean:
	rm -f *.o server client

.PHONY: all clean
