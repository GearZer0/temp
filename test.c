#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

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
