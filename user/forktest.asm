
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N 30

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	26e080e7          	jalr	622(ra) # 27a <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	4ac080e7          	jalr	1196(ra) # 4c8 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <forktest>:

void
forktest(void)
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec06                	sd	ra,24(sp)
  32:	e822                	sd	s0,16(sp)
  34:	e426                	sd	s1,8(sp)
  36:	e04a                	sd	s2,0(sp)
  38:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  3a:	00000517          	auipc	a0,0x0
  3e:	52650513          	addi	a0,a0,1318 # 560 <cpu_process_count+0x8>
  42:	00000097          	auipc	ra,0x0
  46:	fbe080e7          	jalr	-66(ra) # 0 <print>

  for(n=0; n< N; n++){
  4a:	4481                	li	s1,0
  4c:	4979                	li	s2,30
    pid = fork();
  4e:	00000097          	auipc	ra,0x0
  52:	452080e7          	jalr	1106(ra) # 4a0 <fork>
    if(pid < 0)
  56:	02054763          	bltz	a0,84 <forktest+0x56>
      break;
    if(pid == 0)
  5a:	c10d                	beqz	a0,7c <forktest+0x4e>
  for(n=0; n< N; n++){
  5c:	2485                	addiw	s1,s1,1
  5e:	ff2498e3          	bne	s1,s2,4e <forktest+0x20>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  62:	00000517          	auipc	a0,0x0
  66:	50e50513          	addi	a0,a0,1294 # 570 <cpu_process_count+0x18>
  6a:	00000097          	auipc	ra,0x0
  6e:	f96080e7          	jalr	-106(ra) # 0 <print>
    exit(1);
  72:	4505                	li	a0,1
  74:	00000097          	auipc	ra,0x0
  78:	434080e7          	jalr	1076(ra) # 4a8 <exit>
      exit(0);
  7c:	00000097          	auipc	ra,0x0
  80:	42c080e7          	jalr	1068(ra) # 4a8 <exit>
  if(n == N){
  84:	47f9                	li	a5,30
  86:	fcf48ee3          	beq	s1,a5,62 <forktest+0x34>
  }

  for(; n > 0; n--){
  8a:	00905b63          	blez	s1,a0 <forktest+0x72>
    if(wait(0) < 0){
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	420080e7          	jalr	1056(ra) # 4b0 <wait>
  98:	02054a63          	bltz	a0,cc <forktest+0x9e>
  for(; n > 0; n--){
  9c:	34fd                	addiw	s1,s1,-1
  9e:	f8e5                	bnez	s1,8e <forktest+0x60>
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
  a0:	4501                	li	a0,0
  a2:	00000097          	auipc	ra,0x0
  a6:	40e080e7          	jalr	1038(ra) # 4b0 <wait>
  aa:	57fd                	li	a5,-1
  ac:	02f51d63          	bne	a0,a5,e6 <forktest+0xb8>
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
  b0:	00000517          	auipc	a0,0x0
  b4:	51050513          	addi	a0,a0,1296 # 5c0 <cpu_process_count+0x68>
  b8:	00000097          	auipc	ra,0x0
  bc:	f48080e7          	jalr	-184(ra) # 0 <print>
}
  c0:	60e2                	ld	ra,24(sp)
  c2:	6442                	ld	s0,16(sp)
  c4:	64a2                	ld	s1,8(sp)
  c6:	6902                	ld	s2,0(sp)
  c8:	6105                	addi	sp,sp,32
  ca:	8082                	ret
      print("wait stopped early\n");
  cc:	00000517          	auipc	a0,0x0
  d0:	4c450513          	addi	a0,a0,1220 # 590 <cpu_process_count+0x38>
  d4:	00000097          	auipc	ra,0x0
  d8:	f2c080e7          	jalr	-212(ra) # 0 <print>
      exit(1);
  dc:	4505                	li	a0,1
  de:	00000097          	auipc	ra,0x0
  e2:	3ca080e7          	jalr	970(ra) # 4a8 <exit>
    print("wait got too many\n");
  e6:	00000517          	auipc	a0,0x0
  ea:	4c250513          	addi	a0,a0,1218 # 5a8 <cpu_process_count+0x50>
  ee:	00000097          	auipc	ra,0x0
  f2:	f12080e7          	jalr	-238(ra) # 0 <print>
    exit(1);
  f6:	4505                	li	a0,1
  f8:	00000097          	auipc	ra,0x0
  fc:	3b0080e7          	jalr	944(ra) # 4a8 <exit>

0000000000000100 <forktest2>:



void
forktest2(void)
{
 100:	712d                	addi	sp,sp,-288
 102:	ee06                	sd	ra,280(sp)
 104:	ea22                	sd	s0,272(sp)
 106:	e626                	sd	s1,264(sp)
 108:	e24a                	sd	s2,256(sp)
 10a:	fdce                	sd	s3,248(sp)
 10c:	1200                	addi	s0,sp,288
  int n, pid;
  int h[N*2]; 
  char *buf = "_";
  for(int i = 0 ; i < 2*N ; i++){
 10e:	ee040793          	addi	a5,s0,-288
 112:	fd040693          	addi	a3,s0,-48
    h[i] = -1;
 116:	577d                	li	a4,-1
 118:	c398                	sw	a4,0(a5)
  for(int i = 0 ; i < 2*N ; i++){
 11a:	0791                	addi	a5,a5,4
 11c:	fed79ee3          	bne	a5,a3,118 <forktest2+0x18>
  }
  print("fork test\n");
 120:	00000517          	auipc	a0,0x0
 124:	44050513          	addi	a0,a0,1088 # 560 <cpu_process_count+0x8>
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <print>
 130:	44f9                	li	s1,30
    if(pid < 0)
      break;
    if(pid == 0)
      exit(0);
    else{
      buf[0] = (char) pid + 48;
 132:	00000997          	auipc	s3,0x0
 136:	49e98993          	addi	s3,s3,1182 # 5d0 <cpu_process_count+0x78>
      if(h[pid] != -1){
 13a:	597d                	li	s2,-1
    pid = fork();
 13c:	00000097          	auipc	ra,0x0
 140:	364080e7          	jalr	868(ra) # 4a0 <fork>
    if(pid < 0)
 144:	02054963          	bltz	a0,176 <forktest2+0x76>
    if(pid == 0)
 148:	c531                	beqz	a0,194 <forktest2+0x94>
      buf[0] = (char) pid + 48;
 14a:	0305079b          	addiw	a5,a0,48
 14e:	00f98023          	sb	a5,0(s3)
      if(h[pid] != -1){
 152:	00251793          	slli	a5,a0,0x2
 156:	fd040713          	addi	a4,s0,-48
 15a:	97ba                	add	a5,a5,a4
 15c:	f107a783          	lw	a5,-240(a5)
 160:	03279e63          	bne	a5,s2,19c <forktest2+0x9c>
        print("faild!\n");
        exit(0);
      }
    }
    h[pid] = pid; 
 164:	00251793          	slli	a5,a0,0x2
 168:	fd040713          	addi	a4,s0,-48
 16c:	97ba                	add	a5,a5,a4
 16e:	f0a7a823          	sw	a0,-240(a5)
  for(n=0; n<N; n++){
 172:	34fd                	addiw	s1,s1,-1
 174:	f4e1                	bnez	s1,13c <forktest2+0x3c>
  }

  

  print("fork test OK\n");
 176:	00000517          	auipc	a0,0x0
 17a:	44a50513          	addi	a0,a0,1098 # 5c0 <cpu_process_count+0x68>
 17e:	00000097          	auipc	ra,0x0
 182:	e82080e7          	jalr	-382(ra) # 0 <print>
}
 186:	60f2                	ld	ra,280(sp)
 188:	6452                	ld	s0,272(sp)
 18a:	64b2                	ld	s1,264(sp)
 18c:	6912                	ld	s2,256(sp)
 18e:	79ee                	ld	s3,248(sp)
 190:	6115                	addi	sp,sp,288
 192:	8082                	ret
      exit(0);
 194:	00000097          	auipc	ra,0x0
 198:	314080e7          	jalr	788(ra) # 4a8 <exit>
        print("faild!\n");
 19c:	00000517          	auipc	a0,0x0
 1a0:	43c50513          	addi	a0,a0,1084 # 5d8 <cpu_process_count+0x80>
 1a4:	00000097          	auipc	ra,0x0
 1a8:	e5c080e7          	jalr	-420(ra) # 0 <print>
        exit(0);
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2fa080e7          	jalr	762(ra) # 4a8 <exit>

00000000000001b6 <ftest>:

void ftest(){
 1b6:	7179                	addi	sp,sp,-48
 1b8:	f406                	sd	ra,40(sp)
 1ba:	f022                	sd	s0,32(sp)
 1bc:	ec26                	sd	s1,24(sp)
 1be:	1800                	addi	s0,sp,48
  int pid  = -1 ; 
 1c0:	57fd                	li	a5,-1
 1c2:	fcf42e23          	sw	a5,-36(s0)
 1c6:	06400493          	li	s1,100
  for(int i = 0 ; i < 100 ; i++){
    pid = fork(); 
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2d6080e7          	jalr	726(ra) # 4a0 <fork>
 1d2:	fca42e23          	sw	a0,-36(s0)
    if(pid == 0 )
 1d6:	c905                	beqz	a0,206 <ftest+0x50>
      exit(0);
    else if (pid > 0)
 1d8:	02a05b63          	blez	a0,20e <ftest+0x58>
    {
      wait(&pid);
 1dc:	fdc40513          	addi	a0,s0,-36
 1e0:	00000097          	auipc	ra,0x0
 1e4:	2d0080e7          	jalr	720(ra) # 4b0 <wait>
  for(int i = 0 ; i < 100 ; i++){
 1e8:	34fd                	addiw	s1,s1,-1
 1ea:	f0e5                	bnez	s1,1ca <ftest+0x14>
    }
    else 
      exit(1);
  }
  print("Pass!!\n");
 1ec:	00000517          	auipc	a0,0x0
 1f0:	3f450513          	addi	a0,a0,1012 # 5e0 <cpu_process_count+0x88>
 1f4:	00000097          	auipc	ra,0x0
 1f8:	e0c080e7          	jalr	-500(ra) # 0 <print>
}
 1fc:	70a2                	ld	ra,40(sp)
 1fe:	7402                	ld	s0,32(sp)
 200:	64e2                	ld	s1,24(sp)
 202:	6145                	addi	sp,sp,48
 204:	8082                	ret
      exit(0);
 206:	00000097          	auipc	ra,0x0
 20a:	2a2080e7          	jalr	674(ra) # 4a8 <exit>
      exit(1);
 20e:	4505                	li	a0,1
 210:	00000097          	auipc	ra,0x0
 214:	298080e7          	jalr	664(ra) # 4a8 <exit>

0000000000000218 <main>:
int
main(void)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e406                	sd	ra,8(sp)
 21c:	e022                	sd	s0,0(sp)
 21e:	0800                	addi	s0,sp,16
  //list_test();
  ftest();
 220:	00000097          	auipc	ra,0x0
 224:	f96080e7          	jalr	-106(ra) # 1b6 <ftest>
  exit(0);
 228:	4501                	li	a0,0
 22a:	00000097          	auipc	ra,0x0
 22e:	27e080e7          	jalr	638(ra) # 4a8 <exit>

0000000000000232 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 238:	87aa                	mv	a5,a0
 23a:	0585                	addi	a1,a1,1
 23c:	0785                	addi	a5,a5,1
 23e:	fff5c703          	lbu	a4,-1(a1)
 242:	fee78fa3          	sb	a4,-1(a5)
 246:	fb75                	bnez	a4,23a <strcpy+0x8>
    ;
  return os;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret

000000000000024e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 254:	00054783          	lbu	a5,0(a0)
 258:	cb91                	beqz	a5,26c <strcmp+0x1e>
 25a:	0005c703          	lbu	a4,0(a1)
 25e:	00f71763          	bne	a4,a5,26c <strcmp+0x1e>
    p++, q++;
 262:	0505                	addi	a0,a0,1
 264:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 266:	00054783          	lbu	a5,0(a0)
 26a:	fbe5                	bnez	a5,25a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 26c:	0005c503          	lbu	a0,0(a1)
}
 270:	40a7853b          	subw	a0,a5,a0
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <strlen>:

uint
strlen(const char *s)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 280:	00054783          	lbu	a5,0(a0)
 284:	cf91                	beqz	a5,2a0 <strlen+0x26>
 286:	0505                	addi	a0,a0,1
 288:	87aa                	mv	a5,a0
 28a:	4685                	li	a3,1
 28c:	9e89                	subw	a3,a3,a0
 28e:	00f6853b          	addw	a0,a3,a5
 292:	0785                	addi	a5,a5,1
 294:	fff7c703          	lbu	a4,-1(a5)
 298:	fb7d                	bnez	a4,28e <strlen+0x14>
    ;
  return n;
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  for(n = 0; s[n]; n++)
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <strlen+0x20>

00000000000002a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e422                	sd	s0,8(sp)
 2a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2aa:	ce09                	beqz	a2,2c4 <memset+0x20>
 2ac:	87aa                	mv	a5,a0
 2ae:	fff6071b          	addiw	a4,a2,-1
 2b2:	1702                	slli	a4,a4,0x20
 2b4:	9301                	srli	a4,a4,0x20
 2b6:	0705                	addi	a4,a4,1
 2b8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2be:	0785                	addi	a5,a5,1
 2c0:	fee79de3          	bne	a5,a4,2ba <memset+0x16>
  }
  return dst;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <strchr>:

char*
strchr(const char *s, char c)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2d0:	00054783          	lbu	a5,0(a0)
 2d4:	cb99                	beqz	a5,2ea <strchr+0x20>
    if(*s == c)
 2d6:	00f58763          	beq	a1,a5,2e4 <strchr+0x1a>
  for(; *s; s++)
 2da:	0505                	addi	a0,a0,1
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	fbfd                	bnez	a5,2d6 <strchr+0xc>
      return (char*)s;
  return 0;
 2e2:	4501                	li	a0,0
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strchr+0x1a>

00000000000002ee <gets>:

char*
gets(char *buf, int max)
{
 2ee:	711d                	addi	sp,sp,-96
 2f0:	ec86                	sd	ra,88(sp)
 2f2:	e8a2                	sd	s0,80(sp)
 2f4:	e4a6                	sd	s1,72(sp)
 2f6:	e0ca                	sd	s2,64(sp)
 2f8:	fc4e                	sd	s3,56(sp)
 2fa:	f852                	sd	s4,48(sp)
 2fc:	f456                	sd	s5,40(sp)
 2fe:	f05a                	sd	s6,32(sp)
 300:	ec5e                	sd	s7,24(sp)
 302:	1080                	addi	s0,sp,96
 304:	8baa                	mv	s7,a0
 306:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 308:	892a                	mv	s2,a0
 30a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 30c:	4aa9                	li	s5,10
 30e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 310:	89a6                	mv	s3,s1
 312:	2485                	addiw	s1,s1,1
 314:	0344d863          	bge	s1,s4,344 <gets+0x56>
    cc = read(0, &c, 1);
 318:	4605                	li	a2,1
 31a:	faf40593          	addi	a1,s0,-81
 31e:	4501                	li	a0,0
 320:	00000097          	auipc	ra,0x0
 324:	1a0080e7          	jalr	416(ra) # 4c0 <read>
    if(cc < 1)
 328:	00a05e63          	blez	a0,344 <gets+0x56>
    buf[i++] = c;
 32c:	faf44783          	lbu	a5,-81(s0)
 330:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 334:	01578763          	beq	a5,s5,342 <gets+0x54>
 338:	0905                	addi	s2,s2,1
 33a:	fd679be3          	bne	a5,s6,310 <gets+0x22>
  for(i=0; i+1 < max; ){
 33e:	89a6                	mv	s3,s1
 340:	a011                	j	344 <gets+0x56>
 342:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 344:	99de                	add	s3,s3,s7
 346:	00098023          	sb	zero,0(s3)
  return buf;
}
 34a:	855e                	mv	a0,s7
 34c:	60e6                	ld	ra,88(sp)
 34e:	6446                	ld	s0,80(sp)
 350:	64a6                	ld	s1,72(sp)
 352:	6906                	ld	s2,64(sp)
 354:	79e2                	ld	s3,56(sp)
 356:	7a42                	ld	s4,48(sp)
 358:	7aa2                	ld	s5,40(sp)
 35a:	7b02                	ld	s6,32(sp)
 35c:	6be2                	ld	s7,24(sp)
 35e:	6125                	addi	sp,sp,96
 360:	8082                	ret

0000000000000362 <stat>:

int
stat(const char *n, struct stat *st)
{
 362:	1101                	addi	sp,sp,-32
 364:	ec06                	sd	ra,24(sp)
 366:	e822                	sd	s0,16(sp)
 368:	e426                	sd	s1,8(sp)
 36a:	e04a                	sd	s2,0(sp)
 36c:	1000                	addi	s0,sp,32
 36e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 370:	4581                	li	a1,0
 372:	00000097          	auipc	ra,0x0
 376:	176080e7          	jalr	374(ra) # 4e8 <open>
  if(fd < 0)
 37a:	02054563          	bltz	a0,3a4 <stat+0x42>
 37e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 380:	85ca                	mv	a1,s2
 382:	00000097          	auipc	ra,0x0
 386:	17e080e7          	jalr	382(ra) # 500 <fstat>
 38a:	892a                	mv	s2,a0
  close(fd);
 38c:	8526                	mv	a0,s1
 38e:	00000097          	auipc	ra,0x0
 392:	142080e7          	jalr	322(ra) # 4d0 <close>
  return r;
}
 396:	854a                	mv	a0,s2
 398:	60e2                	ld	ra,24(sp)
 39a:	6442                	ld	s0,16(sp)
 39c:	64a2                	ld	s1,8(sp)
 39e:	6902                	ld	s2,0(sp)
 3a0:	6105                	addi	sp,sp,32
 3a2:	8082                	ret
    return -1;
 3a4:	597d                	li	s2,-1
 3a6:	bfc5                	j	396 <stat+0x34>

00000000000003a8 <atoi>:

int
atoi(const char *s)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e422                	sd	s0,8(sp)
 3ac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ae:	00054603          	lbu	a2,0(a0)
 3b2:	fd06079b          	addiw	a5,a2,-48
 3b6:	0ff7f793          	andi	a5,a5,255
 3ba:	4725                	li	a4,9
 3bc:	02f76963          	bltu	a4,a5,3ee <atoi+0x46>
 3c0:	86aa                	mv	a3,a0
  n = 0;
 3c2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3c4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3c6:	0685                	addi	a3,a3,1
 3c8:	0025179b          	slliw	a5,a0,0x2
 3cc:	9fa9                	addw	a5,a5,a0
 3ce:	0017979b          	slliw	a5,a5,0x1
 3d2:	9fb1                	addw	a5,a5,a2
 3d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3d8:	0006c603          	lbu	a2,0(a3)
 3dc:	fd06071b          	addiw	a4,a2,-48
 3e0:	0ff77713          	andi	a4,a4,255
 3e4:	fee5f1e3          	bgeu	a1,a4,3c6 <atoi+0x1e>
  return n;
}
 3e8:	6422                	ld	s0,8(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret
  n = 0;
 3ee:	4501                	li	a0,0
 3f0:	bfe5                	j	3e8 <atoi+0x40>

00000000000003f2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e422                	sd	s0,8(sp)
 3f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3f8:	02b57663          	bgeu	a0,a1,424 <memmove+0x32>
    while(n-- > 0)
 3fc:	02c05163          	blez	a2,41e <memmove+0x2c>
 400:	fff6079b          	addiw	a5,a2,-1
 404:	1782                	slli	a5,a5,0x20
 406:	9381                	srli	a5,a5,0x20
 408:	0785                	addi	a5,a5,1
 40a:	97aa                	add	a5,a5,a0
  dst = vdst;
 40c:	872a                	mv	a4,a0
      *dst++ = *src++;
 40e:	0585                	addi	a1,a1,1
 410:	0705                	addi	a4,a4,1
 412:	fff5c683          	lbu	a3,-1(a1)
 416:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 41a:	fee79ae3          	bne	a5,a4,40e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 41e:	6422                	ld	s0,8(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret
    dst += n;
 424:	00c50733          	add	a4,a0,a2
    src += n;
 428:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 42a:	fec05ae3          	blez	a2,41e <memmove+0x2c>
 42e:	fff6079b          	addiw	a5,a2,-1
 432:	1782                	slli	a5,a5,0x20
 434:	9381                	srli	a5,a5,0x20
 436:	fff7c793          	not	a5,a5
 43a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 43c:	15fd                	addi	a1,a1,-1
 43e:	177d                	addi	a4,a4,-1
 440:	0005c683          	lbu	a3,0(a1)
 444:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 448:	fee79ae3          	bne	a5,a4,43c <memmove+0x4a>
 44c:	bfc9                	j	41e <memmove+0x2c>

000000000000044e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 44e:	1141                	addi	sp,sp,-16
 450:	e422                	sd	s0,8(sp)
 452:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 454:	ca05                	beqz	a2,484 <memcmp+0x36>
 456:	fff6069b          	addiw	a3,a2,-1
 45a:	1682                	slli	a3,a3,0x20
 45c:	9281                	srli	a3,a3,0x20
 45e:	0685                	addi	a3,a3,1
 460:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 462:	00054783          	lbu	a5,0(a0)
 466:	0005c703          	lbu	a4,0(a1)
 46a:	00e79863          	bne	a5,a4,47a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 46e:	0505                	addi	a0,a0,1
    p2++;
 470:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 472:	fed518e3          	bne	a0,a3,462 <memcmp+0x14>
  }
  return 0;
 476:	4501                	li	a0,0
 478:	a019                	j	47e <memcmp+0x30>
      return *p1 - *p2;
 47a:	40e7853b          	subw	a0,a5,a4
}
 47e:	6422                	ld	s0,8(sp)
 480:	0141                	addi	sp,sp,16
 482:	8082                	ret
  return 0;
 484:	4501                	li	a0,0
 486:	bfe5                	j	47e <memcmp+0x30>

0000000000000488 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 488:	1141                	addi	sp,sp,-16
 48a:	e406                	sd	ra,8(sp)
 48c:	e022                	sd	s0,0(sp)
 48e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 490:	00000097          	auipc	ra,0x0
 494:	f62080e7          	jalr	-158(ra) # 3f2 <memmove>
}
 498:	60a2                	ld	ra,8(sp)
 49a:	6402                	ld	s0,0(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret

00000000000004a0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a0:	4885                	li	a7,1
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4a8:	4889                	li	a7,2
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b0:	488d                	li	a7,3
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4b8:	4891                	li	a7,4
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <read>:
.global read
read:
 li a7, SYS_read
 4c0:	4895                	li	a7,5
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <write>:
.global write
write:
 li a7, SYS_write
 4c8:	48c1                	li	a7,16
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <close>:
.global close
close:
 li a7, SYS_close
 4d0:	48d5                	li	a7,21
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4d8:	4899                	li	a7,6
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e0:	489d                	li	a7,7
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <open>:
.global open
open:
 li a7, SYS_open
 4e8:	48bd                	li	a7,15
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f0:	48c5                	li	a7,17
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4f8:	48c9                	li	a7,18
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 500:	48a1                	li	a7,8
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <link>:
.global link
link:
 li a7, SYS_link
 508:	48cd                	li	a7,19
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 510:	48d1                	li	a7,20
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 518:	48a5                	li	a7,9
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <dup>:
.global dup
dup:
 li a7, SYS_dup
 520:	48a9                	li	a7,10
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 528:	48ad                	li	a7,11
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 530:	48b1                	li	a7,12
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 538:	48b5                	li	a7,13
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 540:	48b9                	li	a7,14
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <set_cpu>:
.global set_cpu
set_cpu:
 li a7, SYS_set_cpu
 548:	48d9                	li	a7,22
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <get_cpu>:
.global get_cpu
get_cpu:
 li a7, SYS_get_cpu
 550:	48dd                	li	a7,23
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <cpu_process_count>:
.global cpu_process_count
cpu_process_count:
 li a7, SYS_cpu_process_count
 558:	48e1                	li	a7,24
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret
