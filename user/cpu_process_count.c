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
  
  int proc_num_of_cpu = cpu_process_count(atoi(argv[1]));
  if(proc_num_of_cpu < 0){
    fprintf(2, "failed to get to this cpu's proc number\n"); 
    exit(1); 
  }
  printf("cpu's proc numuber is: %d", proc_num_of_cpu);
  exit(0);
}