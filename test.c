#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <string.h>

pid_t child_pid;

void killChildProcess() {
    // Terminate the child process
    kill(child_pid, SIGTERM);
}

int main() {
    pid_t pid;

    // Create new process
    pid = fork();

    if (pid == 0) {
        // Child process code
        // This block is executed only by the child process

        // Create a new session and obtain a new PID
        setsid();

        // Open the file in append mode and create it if it doesn't exist
        int file = open("test.txt", O_CREAT | O_WRONLY | O_APPEND, 0644);

        // Create a Unix domain socket
        int sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
        if (sockfd == -1) {
            perror("Error creating socket");
            exit(1);
        }

        // Bind the socket to a file
        struct sockaddr_un address;
        memset(&address, 0, sizeof(struct sockaddr_un));
        address.sun_family = AF_UNIX;
        strncpy(address.sun_path, "notmalicious.sock", sizeof(address.sun_path) - 1);

        if (bind(sockfd, (struct sockaddr *)&address, sizeof(struct sockaddr_un)) == -1) {
            perror("Error binding socket");
            exit(1);
        }

        // Start listening for incoming connections
        if (listen(sockfd, 5) == -1) {
            perror("Error listening on socket");
            exit(1);
        }

        // Accept incoming connections
        struct sockaddr_un client_address;
        socklen_t client_address_len = sizeof(client_address);
        int client_sockfd = accept(sockfd, (struct sockaddr *)&client_address, &client_address_len);
        if (client_sockfd == -1) {
            perror("Error accepting connection");
            exit(1);
        }

        // Redirect file output to the accepted socket
        dup2(client_sockfd, file);

        // Keep the file open in the background
        while (1) {
            sleep(1);
        }

        exit(0);
    } else {
        // Parent process code continues here

        // Store the child process PID
        child_pid = pid;

        // Print the child process PID
        printf("Child PID: %d\n", pid);

        // Print the parent process PID
        printf("Parent PID: %d\n", getpid());

        // Wait for user input to terminate the processes
        printf("Press any key to terminate the processes.\n");
        getchar();

        // Terminate the child process
        killChildProcess();

        // Wait for the child process to terminate
        waitpid(pid, NULL, 0);
    }

    return 0;
}
