#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#define N 30

int main(int argc, char const *argv[])
{
    int n, pid;
    int h[N*2]; 
    for(int i = 0 ; i < 2*N ; i++){
        h[i] = -1;
    }
    print("fork test\n");

    for(n=0; n<N; n++){
        pid = fork();
        if(pid < 0)
        break;
        if(pid == 0)
        exit(0);
        else{
        if(h[pid] != -1){
            print("faild!\n");
            exit(0);
        }
        }
        h[pid] = pid; 
    }
    return 0;
}
