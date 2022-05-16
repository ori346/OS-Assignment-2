#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main()
{
  int cpu = get_cpu();
  printf("current cpu is %d\n", cpu);
  exit(0);
}