// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define N 30

void
print(const char *s)
{
  write(1, s, strlen(s));
}

void
forktest(void)
{
  int n, pid;

  print("fork test\n");

  for(n=0; n< N; n++){
    pid = fork();
    if(pid < 0)
      break;
    if(pid == 0)
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
    exit(1);
  }

  for(; n > 0; n--){
    if(wait(0) < 0){
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
}



void
forktest2(void)
{
  int n, pid;
  int h[N*2]; 
  char *buf = "_";
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
      buf[0] = (char) pid + 48;
      if(h[pid] != -1){
        print("faild!\n");
        exit(0);
      }
    }
    h[pid] = pid; 
  }

  

  print("fork test OK\n");
}

void ftest(){
  int pid  = -1 ; 
  for(int i = 0 ; i < 100 ; i++){
    pid = fork(); 
    if(pid == 0 )
      exit(0);
    else if (pid > 0)
    {
      wait(&pid);
    }
    else 
      exit(1);
  }
  print("Pass!!\n");
}
int
main(void)
{
  //list_test();
  ftest();
  exit(0);
}
