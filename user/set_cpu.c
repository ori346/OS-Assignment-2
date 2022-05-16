#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{

  
  if(argc < 2){
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  int cpu = set_cpu(atoi(argv[1]));
  if(cpu < 0){
    fprintf(2, "failed to change to this cpu\n"); 
    exit(1); 
  }

  printf("cpu assigned to is %d\n", cpu);
  exit(0);
}