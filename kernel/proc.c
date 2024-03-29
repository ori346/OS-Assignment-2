#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"



struct cpu cpus[NCPU];


struct proc proc[NPROC];

struct proc *initproc;

struct headList{
  struct proc * head;
  struct proc * tail; 
  struct spinlock lock;
};


struct headList readyQueus[NCPU];
struct headList zombies = {0 , 0};
struct headList sleeping = {0 , 0} ; 
struct headList unusing = {0 , 0};   


int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);


//add a proccess to the end of the list
void add(struct headList * list , struct proc * new_proc){
    //printf("try to add proc num: %d\n" , new_proc);
    acquire(&list->lock);

    //case the queue is empty
    if(list->tail == 0){
      list->head = new_proc;
      list->tail = new_proc;
      release(&list->lock);
      return;
    }
    struct proc *p = list->tail; 
    acquire(&p->list_lock);
    release(&list->lock);
    p->next = new_proc;
    list->tail = new_proc;
    new_proc->next = 0 ; 
    release(&p->list_lock);
    
    //printf("add proc num: %d succsesfuly\n" , new_proc);
}

//remove the first element from the list 
struct proc* remove(struct headList *list){
  struct proc* output = 0; 
  acquire(&list->lock);

  //case of empty quequ 
  if(list->head == 0){
    release(&list->lock);
    return 0;
  }

  struct proc *p = list->head; 
  acquire(&p->list_lock);
  output = list->head;
  list->head = p->next; 

  //case of removing the last element
  if(p->next == 0)
    list->tail = 0;

  p->next = 0;
  release(&p->list_lock);
  release(&list->lock);

  return output;
} 

//remove procces with  specifec index
 void remove_index1(struct headList *list , int ind){
  //TODO change the implimntion to not lock all the list
  acquire(&list->lock);
  if(list->head == 0){
    release(&list->lock);
    return;
  }
    
  struct proc *prev = 0;
  struct proc *curr = list->head; 
  while((curr->next != 0 ) || (curr->index != ind) ){
    prev = curr; 
    curr = curr->next;
  }
  if(curr->index == ind){
    if(prev == 0){
      list->head = curr->next; 
    }
    else{
    prev->next = curr->next;
    }
    if(curr->index == list->tail->index){
      list->tail = prev;
    }
    curr->next = 0; 
    }
  release(&list->lock);

}

 void remove_index(struct headList *list , int ind){
  //TODO change the implimntion to not lock all the list
  struct spinlock * l1 = &list->lock; 
  
  acquire(l1);
  if(list->head == 0){
    release(l1);
    return;
  }

 
  struct proc *prev = 0;
  struct proc *curr = list->head; 
  struct spinlock * l2 = &curr->list_lock;
  acquire(l2);

  while(curr->next != 0 && curr->index != ind){
    release(l1); 
    l1 = l2; 
    prev = curr; 
    curr = curr->next;
    l2 = &curr->list_lock;
    acquire(l2); 
  }

  if(curr->index == ind){

    if(prev == 0){
      list->head = curr->next;  
    }
    else{
      prev->next = curr->next;
    }

    if(curr->index == list->tail->index){
      list->tail = prev;
    }
  
    curr->next = 0;
  }
    release(l1);
    release(l2);
}

/*
void add(struct headList * list , struct proc* new_proc){
    //printf("try to add proc num: %d\n" , new_proc); 
    acquire(&new_proc->list_lock);
    acquire(&list->lock);

    //case the queue is empty
    if(list->head == 0){
      //printf("bla\n");
      list->head = new_proc;
      release(&list->lock);
      new_proc->next = 0;
      release(&new_proc->list_lock);
      return;
    }
    else{
      //printf("bla2\n");
      struct proc *p1 = list->head;
      //release(&list->lock);
      struct proc *p2;

      acquire(&p1->list_lock);
      while (p1->next != 0)
      {
        //printf("loop\n");
        p2 = p1->next;
        acquire(&p2->list_lock);
        release(&p1->list_lock);
        p1 = p2;
      }
      
      
      p1->next = new_proc;
      release(&p1->list_lock);
      release(&new_proc->list_lock);
      release(&list->lock);
      //printf("add proc num: %d succsesfuly\n" , new_proc);
    }
}


struct proc* remove(struct headList * list){
   
  struct proc* to_remove;
  acquire(&list->lock);
  //case of empty queue 
  if(list->head == 0){
    release(&list->lock);
    return 0;
  }
  
  to_remove = list->head;
  //printf("remove %d\n" , to_remove->index); 
  acquire(&to_remove->list_lock);
  if(to_remove->next == 0){
    list->head = 0;
  }
  else{
    acquire(&to_remove->next->list_lock);
    list->head = to_remove->next;
    release(&to_remove->next->list_lock);
  }
  
  //release(&list->lock);
  
  to_remove->next = 0;
  release(&to_remove->list_lock);
  release(&list->lock);
  return to_remove;
}
*/

void printList(struct headList* list){
  acquire(&list->lock);
  printf("the list: ");
  if(list->head == 0){
    printf("empty\n");
    return;
  }
  struct proc *p = list->head;
  while(p != 0 ){ 
    printf("%d " , p->index); 
    p = p->next;
  }

  printf("\n"); 
  release(&list->lock);
  
}

/*
struct proc* remove_index(struct headList *list , int ind){
  //TODO change the implimntion to not lock all the list
  
  struct proc* to_remove;
  acquire(&list->lock);
  if(list->head == 0){
      release(&list->lock);
      return 0;
  }
  else if(&proc[ind] == list->head){
    
    to_remove = list->head; 
    acquire(&to_remove->list_lock);
    if(to_remove->next == 0){
      list->head = 0;
    }
    else{
      acquire(&to_remove->next->list_lock);
      list->head = to_remove->next;
      release(&to_remove->next->list_lock);
    }
    
    release(&list->lock);
    
    to_remove->next = 0;
    release(&to_remove->list_lock);
    return to_remove;      
  }

  struct proc *prev = list->head;
  //release(&list->lock);
  struct proc *curr = prev;

  acquire(&prev->list_lock);
  while (prev->next != 0){
    acquire(&prev->next->list_lock);
    curr = prev->next;
    if(curr->index == ind){
      prev->next = curr->next;
      release(&prev->list_lock);
      curr->next = 0;
      release(&curr->list_lock);
      return curr;
    }
    release(&prev->list_lock);
    prev = curr;
  }
  release(&curr->list_lock);
  release(&list->lock);
  return 0;
  
}

*/

int set_cpu(int cpu_num){
  acquire(&myproc()->lock);
  struct proc *p = myproc();
  //acquire(&p->lock);
  if(p == 0 || cpu_num > CPUS || cpu_num < 0){
    release(&p->lock);
    return -1;
  }

  remove_index(&readyQueus[p->cpu], p->index);
  p->cpu = cpu_num;
  add(&readyQueus[cpu_num], p);
  release(&p->lock);
  yield();
  return cpu_num;
}

int get_cpu(){
  return cpuid();
}

int cpu_process_count(int cpu_num){
  if(cpu_num > CPUS || cpu_num < 0)
    return -1;
  return cpus[cpu_num].n_proc;
}

extern char trampoline[]; // trampoline.S
extern uint64 cas(volatile void* addr ,  int expected , int newval );
// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  int i = 0; 
  for(int j = 0 ; j < NCPU ; j++){
    readyQueus[j].head = 0; 
    readyQueus[j].tail = 0;
    initlock(&readyQueus[j].lock , "cpu");
    cpus[j].index = j ;
    cpus[j].n_proc = 0 ;
  }
  initlock(&zombies.lock , "zombies");
  initlock(&sleeping.lock , "sleepings;");
  initlock(&unusing.lock , "unsing");
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      initlock(&p->list_lock, "list_lock");
      p->kstack = KSTACK((int) (p - proc));
      p->index = i++;
      p->next = 0;
      p->cpu = 0; 
      add(&unusing , p);
  }   

}



// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu* 
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid() {
  int pid; 
  do{
    pid = nextpid; 
  }while(cas(&nextpid , pid , pid + 1)); 
  
  //acquire(&pid_lock);
  //pid = nextpid;
  //nextpid = nextpid + 1;
  //release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  
  p = remove(&unusing);
  if(p == 0)
    return 0 ;
  acquire(&p->lock);
//   for(p = proc; p < &proc[NPROC]; p++) {
//     acquire(&p->lock);
//     if(p->state == UNUSED) {
//       goto found;
//     } else {
//       release(&p->lock);
//     }
//   }
//   return 0;

// found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
    
  remove_index(&zombies , p->index);

  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->next = 0; 
  p->state = UNUSED;
  add(&unusing , p); 
  
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
  add(&readyQueus[0] , p );
  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.

int min_cpu(){
  struct cpu * output = cpus , *c ;
  for( c = cpus ; c < &cpus[CPUS] ; c++ ){
    if(c->n_proc < output->n_proc)
      output = c;
  }
  return output->index;
}

int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  #ifdef ON 
  int cpu_index = min_cpu();
  int prev ;
  np->cpu = cpu_index; 
  do{
    prev = cpus[cpu_index].n_proc; 
  }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1)); 
  #elif OFF
  np->cpu = p->cpu;
  #endif 

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  add(&readyQueus[np->cpu], np);
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;
  add(&zombies , p); 
  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p = 0;
  struct cpu *c = mycpu();
  
  c->proc = 0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();
    
    #ifdef ON
    for(int i = c->index ; ; i = (i + 1) % CPUS ){
       p = remove(&readyQueus[i]); 
        if(p != 0)
          break;    
    }

    if(p->cpu != c->index){
      int prev ; 
      do{
        prev = cpus[c->index].n_proc; 
      }while(cas(&(cpus[c->index].n_proc) , prev , prev + 1));
    }

    p->cpu = c->index ; 
    #elif OFF
    do{
      p = remove(&readyQueus[c->index]);
    }while(p == 0);
    #endif

    acquire(&p->lock);
    p->state = RUNNING;
    p->cpu = c->index;
    c->proc = p;
    swtch(&c->context, &p->context);
    
    // Process is done running for now.
    // It should have changed its p->state before coming back.
    c->proc = 0;
    release(&p->lock);
    
    // for(p = proc; p < &proc[NPROC]; p++) {
    //   acquire(&p->lock);
    //   if(p->state == RUNNABLE) {
    //     // Switch to chosen process.  It is the process's job
    //     // to release its lock and then reacquire it
    //     // before jumping back to us.
    //     p->state = RUNNING;
    //     p->cpu = c->index;
    //     c->proc = p;
    //     swtch(&c->context, &p->context);

    //     // Process is done running for now.
    //     // It should have changed its p->state before coming back.
    //     c->proc = 0;
    //   }
    //   release(&p->lock);
    // }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  add(&readyQueus[p->cpu] , p);
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  add(&sleeping , p);
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  
  //printList(&sleeping);
  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;
  //printList(&sleeping);
  for(p = sleeping.head; p != 0; p = p->next) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        remove_index(&sleeping , p->index);
        p->state = RUNNABLE;
        #ifdef ON 
        int cpu_index = min_cpu();
        int prev ;
        p->cpu = cpu_index; 
        do{
          prev = cpus[cpu_index].n_proc; 
        }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1));
        #endif 
        add(&readyQueus[p->cpu] , p);     
      }
      release(&p->lock);
    }
  }
  //printList(&sleeping);
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
        add(&readyQueus[p->cpu] , p); 
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}
