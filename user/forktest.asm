
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  100

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
  10:	2ac080e7          	jalr	684(ra) # 2b8 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	4ea080e7          	jalr	1258(ra) # 506 <write>
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
  2e:	cb010113          	addi	sp,sp,-848
  32:	34113423          	sd	ra,840(sp)
  36:	34813023          	sd	s0,832(sp)
  3a:	32913c23          	sd	s1,824(sp)
  3e:	33213823          	sd	s2,816(sp)
  42:	33313423          	sd	s3,808(sp)
  46:	0e80                	addi	s0,sp,848
  int n, pid;
  int h[N*2]; 
  //char buf[1];
  for(int i = 0 ; i < 2*N ; i++){
  48:	cb040793          	addi	a5,s0,-848
  4c:	fd040693          	addi	a3,s0,-48
    h[i] = -1;
  50:	577d                	li	a4,-1
  52:	c398                	sw	a4,0(a5)
  for(int i = 0 ; i < 2*N ; i++){
  54:	0791                	addi	a5,a5,4
  56:	fed79ee3          	bne	a5,a3,52 <forktest+0x24>
  }
  print("fork test\n");
  5a:	00000517          	auipc	a0,0x0
  5e:	52e50513          	addi	a0,a0,1326 # 588 <uptime+0xa>
  62:	00000097          	auipc	ra,0x0
  66:	f9e080e7          	jalr	-98(ra) # 0 <print>

  for(n=0; n<N; n++){
  6a:	4481                	li	s1,0
      break;
    if(pid == 0)
      exit(0);
    else{
      //buf[0] = (char) pid + 48;
      if(h[pid] != -1){
  6c:	59fd                	li	s3,-1
  for(n=0; n<N; n++){
  6e:	06400913          	li	s2,100
    pid = fork();
  72:	00000097          	auipc	ra,0x0
  76:	46c080e7          	jalr	1132(ra) # 4de <fork>
    if(pid < 0)
  7a:	06054463          	bltz	a0,e2 <forktest+0xb4>
    if(pid == 0)
  7e:	c129                	beqz	a0,c0 <forktest+0x92>
      if(h[pid] != -1){
  80:	00251793          	slli	a5,a0,0x2
  84:	fd040713          	addi	a4,s0,-48
  88:	97ba                	add	a5,a5,a4
  8a:	ce07a783          	lw	a5,-800(a5)
  8e:	03379d63          	bne	a5,s3,c8 <forktest+0x9a>
        print("faild!\n");
        exit(0);
      }
    }
    h[pid] = pid; 
  92:	00251793          	slli	a5,a0,0x2
  96:	fd040713          	addi	a4,s0,-48
  9a:	97ba                	add	a5,a5,a4
  9c:	cea7a023          	sw	a0,-800(a5)
  for(n=0; n<N; n++){
  a0:	2485                	addiw	s1,s1,1
  a2:	fd2498e3          	bne	s1,s2,72 <forktest+0x44>
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  a6:	00000517          	auipc	a0,0x0
  aa:	4fa50513          	addi	a0,a0,1274 # 5a0 <uptime+0x22>
  ae:	00000097          	auipc	ra,0x0
  b2:	f52080e7          	jalr	-174(ra) # 0 <print>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	42e080e7          	jalr	1070(ra) # 4e6 <exit>
      exit(0);
  c0:	00000097          	auipc	ra,0x0
  c4:	426080e7          	jalr	1062(ra) # 4e6 <exit>
        print("faild!\n");
  c8:	00000517          	auipc	a0,0x0
  cc:	4d050513          	addi	a0,a0,1232 # 598 <uptime+0x1a>
  d0:	00000097          	auipc	ra,0x0
  d4:	f30080e7          	jalr	-208(ra) # 0 <print>
        exit(0);
  d8:	4501                	li	a0,0
  da:	00000097          	auipc	ra,0x0
  de:	40c080e7          	jalr	1036(ra) # 4e6 <exit>
  if(n == N){
  e2:	06400793          	li	a5,100
  e6:	fcf480e3          	beq	s1,a5,a6 <forktest+0x78>
  }

  for(; n > 0; n--){
  ea:	00905b63          	blez	s1,100 <forktest+0xd2>
    if(wait(0) < 0){
  ee:	4501                	li	a0,0
  f0:	00000097          	auipc	ra,0x0
  f4:	3fe080e7          	jalr	1022(ra) # 4ee <wait>
  f8:	04054163          	bltz	a0,13a <forktest+0x10c>
  for(; n > 0; n--){
  fc:	34fd                	addiw	s1,s1,-1
  fe:	f8e5                	bnez	s1,ee <forktest+0xc0>
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	3ec080e7          	jalr	1004(ra) # 4ee <wait>
 10a:	57fd                	li	a5,-1
 10c:	04f51463          	bne	a0,a5,154 <forktest+0x126>
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
 110:	00000517          	auipc	a0,0x0
 114:	4e050513          	addi	a0,a0,1248 # 5f0 <uptime+0x72>
 118:	00000097          	auipc	ra,0x0
 11c:	ee8080e7          	jalr	-280(ra) # 0 <print>
}
 120:	34813083          	ld	ra,840(sp)
 124:	34013403          	ld	s0,832(sp)
 128:	33813483          	ld	s1,824(sp)
 12c:	33013903          	ld	s2,816(sp)
 130:	32813983          	ld	s3,808(sp)
 134:	35010113          	addi	sp,sp,848
 138:	8082                	ret
      print("wait stopped early\n");
 13a:	00000517          	auipc	a0,0x0
 13e:	48650513          	addi	a0,a0,1158 # 5c0 <uptime+0x42>
 142:	00000097          	auipc	ra,0x0
 146:	ebe080e7          	jalr	-322(ra) # 0 <print>
      exit(1);
 14a:	4505                	li	a0,1
 14c:	00000097          	auipc	ra,0x0
 150:	39a080e7          	jalr	922(ra) # 4e6 <exit>
    print("wait got too many\n");
 154:	00000517          	auipc	a0,0x0
 158:	48450513          	addi	a0,a0,1156 # 5d8 <uptime+0x5a>
 15c:	00000097          	auipc	ra,0x0
 160:	ea4080e7          	jalr	-348(ra) # 0 <print>
    exit(1);
 164:	4505                	li	a0,1
 166:	00000097          	auipc	ra,0x0
 16a:	380080e7          	jalr	896(ra) # 4e6 <exit>

000000000000016e <forktest2>:



void
forktest2(void)
{
 16e:	cb010113          	addi	sp,sp,-848
 172:	34113423          	sd	ra,840(sp)
 176:	34813023          	sd	s0,832(sp)
 17a:	32913c23          	sd	s1,824(sp)
 17e:	33213823          	sd	s2,816(sp)
 182:	33313423          	sd	s3,808(sp)
 186:	33413023          	sd	s4,800(sp)
 18a:	0e80                	addi	s0,sp,848
  int n, pid;
  int h[N*2]; 
  char *buf = "_";
  for(int i = 0 ; i < 2*N ; i++){
 18c:	cb040793          	addi	a5,s0,-848
 190:	fd040693          	addi	a3,s0,-48
    h[i] = -1;
 194:	577d                	li	a4,-1
 196:	c398                	sw	a4,0(a5)
  for(int i = 0 ; i < 2*N ; i++){
 198:	0791                	addi	a5,a5,4
 19a:	fed79ee3          	bne	a5,a3,196 <forktest2+0x28>
  }
  print("fork test\n");
 19e:	00000517          	auipc	a0,0x0
 1a2:	3ea50513          	addi	a0,a0,1002 # 588 <uptime+0xa>
 1a6:	00000097          	auipc	ra,0x0
 1aa:	e5a080e7          	jalr	-422(ra) # 0 <print>
 1ae:	06400913          	li	s2,100
    if(pid < 0)
      break;
    if(pid == 0)
      exit(0);
    else{
      buf[0] = (char) pid + 48;
 1b2:	00000997          	auipc	s3,0x0
 1b6:	44e98993          	addi	s3,s3,1102 # 600 <uptime+0x82>
      print(buf);
      if(h[pid] != -1){
 1ba:	5a7d                	li	s4,-1
    pid = fork();
 1bc:	00000097          	auipc	ra,0x0
 1c0:	322080e7          	jalr	802(ra) # 4de <fork>
 1c4:	84aa                	mv	s1,a0
    if(pid < 0)
 1c6:	02054f63          	bltz	a0,204 <forktest2+0x96>
    if(pid == 0)
 1ca:	c525                	beqz	a0,232 <forktest2+0xc4>
      buf[0] = (char) pid + 48;
 1cc:	0305079b          	addiw	a5,a0,48
 1d0:	00f98023          	sb	a5,0(s3)
      print(buf);
 1d4:	854e                	mv	a0,s3
 1d6:	00000097          	auipc	ra,0x0
 1da:	e2a080e7          	jalr	-470(ra) # 0 <print>
      if(h[pid] != -1){
 1de:	00249793          	slli	a5,s1,0x2
 1e2:	fd040713          	addi	a4,s0,-48
 1e6:	97ba                	add	a5,a5,a4
 1e8:	ce07a783          	lw	a5,-800(a5)
 1ec:	05479863          	bne	a5,s4,23c <forktest2+0xce>
        print("faild!\n");
        exit(0);
      }
    }
    h[pid] = pid; 
 1f0:	00249793          	slli	a5,s1,0x2
 1f4:	fd040713          	addi	a4,s0,-48
 1f8:	97ba                	add	a5,a5,a4
 1fa:	ce97a023          	sw	s1,-800(a5)
  for(n=0; n<N; n++){
 1fe:	397d                	addiw	s2,s2,-1
 200:	fa091ee3          	bnez	s2,1bc <forktest2+0x4e>
  }

  

  print("fork test OK\n");
 204:	00000517          	auipc	a0,0x0
 208:	3ec50513          	addi	a0,a0,1004 # 5f0 <uptime+0x72>
 20c:	00000097          	auipc	ra,0x0
 210:	df4080e7          	jalr	-524(ra) # 0 <print>
}
 214:	34813083          	ld	ra,840(sp)
 218:	34013403          	ld	s0,832(sp)
 21c:	33813483          	ld	s1,824(sp)
 220:	33013903          	ld	s2,816(sp)
 224:	32813983          	ld	s3,808(sp)
 228:	32013a03          	ld	s4,800(sp)
 22c:	35010113          	addi	sp,sp,848
 230:	8082                	ret
      exit(0);
 232:	4501                	li	a0,0
 234:	00000097          	auipc	ra,0x0
 238:	2b2080e7          	jalr	690(ra) # 4e6 <exit>
        print("faild!\n");
 23c:	00000517          	auipc	a0,0x0
 240:	35c50513          	addi	a0,a0,860 # 598 <uptime+0x1a>
 244:	00000097          	auipc	ra,0x0
 248:	dbc080e7          	jalr	-580(ra) # 0 <print>
        exit(0);
 24c:	4501                	li	a0,0
 24e:	00000097          	auipc	ra,0x0
 252:	298080e7          	jalr	664(ra) # 4e6 <exit>

0000000000000256 <main>:
int
main(void)
{
 256:	1141                	addi	sp,sp,-16
 258:	e406                	sd	ra,8(sp)
 25a:	e022                	sd	s0,0(sp)
 25c:	0800                	addi	s0,sp,16

  forktest2();
 25e:	00000097          	auipc	ra,0x0
 262:	f10080e7          	jalr	-240(ra) # 16e <forktest2>
  exit(0);
 266:	4501                	li	a0,0
 268:	00000097          	auipc	ra,0x0
 26c:	27e080e7          	jalr	638(ra) # 4e6 <exit>

0000000000000270 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 276:	87aa                	mv	a5,a0
 278:	0585                	addi	a1,a1,1
 27a:	0785                	addi	a5,a5,1
 27c:	fff5c703          	lbu	a4,-1(a1)
 280:	fee78fa3          	sb	a4,-1(a5)
 284:	fb75                	bnez	a4,278 <strcpy+0x8>
    ;
  return os;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 292:	00054783          	lbu	a5,0(a0)
 296:	cb91                	beqz	a5,2aa <strcmp+0x1e>
 298:	0005c703          	lbu	a4,0(a1)
 29c:	00f71763          	bne	a4,a5,2aa <strcmp+0x1e>
    p++, q++;
 2a0:	0505                	addi	a0,a0,1
 2a2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	fbe5                	bnez	a5,298 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2aa:	0005c503          	lbu	a0,0(a1)
}
 2ae:	40a7853b          	subw	a0,a5,a0
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret

00000000000002b8 <strlen>:

uint
strlen(const char *s)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	cf91                	beqz	a5,2de <strlen+0x26>
 2c4:	0505                	addi	a0,a0,1
 2c6:	87aa                	mv	a5,a0
 2c8:	4685                	li	a3,1
 2ca:	9e89                	subw	a3,a3,a0
 2cc:	00f6853b          	addw	a0,a3,a5
 2d0:	0785                	addi	a5,a5,1
 2d2:	fff7c703          	lbu	a4,-1(a5)
 2d6:	fb7d                	bnez	a4,2cc <strlen+0x14>
    ;
  return n;
}
 2d8:	6422                	ld	s0,8(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret
  for(n = 0; s[n]; n++)
 2de:	4501                	li	a0,0
 2e0:	bfe5                	j	2d8 <strlen+0x20>

00000000000002e2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2e8:	ce09                	beqz	a2,302 <memset+0x20>
 2ea:	87aa                	mv	a5,a0
 2ec:	fff6071b          	addiw	a4,a2,-1
 2f0:	1702                	slli	a4,a4,0x20
 2f2:	9301                	srli	a4,a4,0x20
 2f4:	0705                	addi	a4,a4,1
 2f6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2f8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2fc:	0785                	addi	a5,a5,1
 2fe:	fee79de3          	bne	a5,a4,2f8 <memset+0x16>
  }
  return dst;
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <strchr>:

char*
strchr(const char *s, char c)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 30e:	00054783          	lbu	a5,0(a0)
 312:	cb99                	beqz	a5,328 <strchr+0x20>
    if(*s == c)
 314:	00f58763          	beq	a1,a5,322 <strchr+0x1a>
  for(; *s; s++)
 318:	0505                	addi	a0,a0,1
 31a:	00054783          	lbu	a5,0(a0)
 31e:	fbfd                	bnez	a5,314 <strchr+0xc>
      return (char*)s;
  return 0;
 320:	4501                	li	a0,0
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  return 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <strchr+0x1a>

000000000000032c <gets>:

char*
gets(char *buf, int max)
{
 32c:	711d                	addi	sp,sp,-96
 32e:	ec86                	sd	ra,88(sp)
 330:	e8a2                	sd	s0,80(sp)
 332:	e4a6                	sd	s1,72(sp)
 334:	e0ca                	sd	s2,64(sp)
 336:	fc4e                	sd	s3,56(sp)
 338:	f852                	sd	s4,48(sp)
 33a:	f456                	sd	s5,40(sp)
 33c:	f05a                	sd	s6,32(sp)
 33e:	ec5e                	sd	s7,24(sp)
 340:	1080                	addi	s0,sp,96
 342:	8baa                	mv	s7,a0
 344:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 346:	892a                	mv	s2,a0
 348:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 34a:	4aa9                	li	s5,10
 34c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 34e:	89a6                	mv	s3,s1
 350:	2485                	addiw	s1,s1,1
 352:	0344d863          	bge	s1,s4,382 <gets+0x56>
    cc = read(0, &c, 1);
 356:	4605                	li	a2,1
 358:	faf40593          	addi	a1,s0,-81
 35c:	4501                	li	a0,0
 35e:	00000097          	auipc	ra,0x0
 362:	1a0080e7          	jalr	416(ra) # 4fe <read>
    if(cc < 1)
 366:	00a05e63          	blez	a0,382 <gets+0x56>
    buf[i++] = c;
 36a:	faf44783          	lbu	a5,-81(s0)
 36e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 372:	01578763          	beq	a5,s5,380 <gets+0x54>
 376:	0905                	addi	s2,s2,1
 378:	fd679be3          	bne	a5,s6,34e <gets+0x22>
  for(i=0; i+1 < max; ){
 37c:	89a6                	mv	s3,s1
 37e:	a011                	j	382 <gets+0x56>
 380:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 382:	99de                	add	s3,s3,s7
 384:	00098023          	sb	zero,0(s3)
  return buf;
}
 388:	855e                	mv	a0,s7
 38a:	60e6                	ld	ra,88(sp)
 38c:	6446                	ld	s0,80(sp)
 38e:	64a6                	ld	s1,72(sp)
 390:	6906                	ld	s2,64(sp)
 392:	79e2                	ld	s3,56(sp)
 394:	7a42                	ld	s4,48(sp)
 396:	7aa2                	ld	s5,40(sp)
 398:	7b02                	ld	s6,32(sp)
 39a:	6be2                	ld	s7,24(sp)
 39c:	6125                	addi	sp,sp,96
 39e:	8082                	ret

00000000000003a0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a0:	1101                	addi	sp,sp,-32
 3a2:	ec06                	sd	ra,24(sp)
 3a4:	e822                	sd	s0,16(sp)
 3a6:	e426                	sd	s1,8(sp)
 3a8:	e04a                	sd	s2,0(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ae:	4581                	li	a1,0
 3b0:	00000097          	auipc	ra,0x0
 3b4:	176080e7          	jalr	374(ra) # 526 <open>
  if(fd < 0)
 3b8:	02054563          	bltz	a0,3e2 <stat+0x42>
 3bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3be:	85ca                	mv	a1,s2
 3c0:	00000097          	auipc	ra,0x0
 3c4:	17e080e7          	jalr	382(ra) # 53e <fstat>
 3c8:	892a                	mv	s2,a0
  close(fd);
 3ca:	8526                	mv	a0,s1
 3cc:	00000097          	auipc	ra,0x0
 3d0:	142080e7          	jalr	322(ra) # 50e <close>
  return r;
}
 3d4:	854a                	mv	a0,s2
 3d6:	60e2                	ld	ra,24(sp)
 3d8:	6442                	ld	s0,16(sp)
 3da:	64a2                	ld	s1,8(sp)
 3dc:	6902                	ld	s2,0(sp)
 3de:	6105                	addi	sp,sp,32
 3e0:	8082                	ret
    return -1;
 3e2:	597d                	li	s2,-1
 3e4:	bfc5                	j	3d4 <stat+0x34>

00000000000003e6 <atoi>:

int
atoi(const char *s)
{
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e422                	sd	s0,8(sp)
 3ea:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ec:	00054603          	lbu	a2,0(a0)
 3f0:	fd06079b          	addiw	a5,a2,-48
 3f4:	0ff7f793          	andi	a5,a5,255
 3f8:	4725                	li	a4,9
 3fa:	02f76963          	bltu	a4,a5,42c <atoi+0x46>
 3fe:	86aa                	mv	a3,a0
  n = 0;
 400:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 402:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 404:	0685                	addi	a3,a3,1
 406:	0025179b          	slliw	a5,a0,0x2
 40a:	9fa9                	addw	a5,a5,a0
 40c:	0017979b          	slliw	a5,a5,0x1
 410:	9fb1                	addw	a5,a5,a2
 412:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 416:	0006c603          	lbu	a2,0(a3)
 41a:	fd06071b          	addiw	a4,a2,-48
 41e:	0ff77713          	andi	a4,a4,255
 422:	fee5f1e3          	bgeu	a1,a4,404 <atoi+0x1e>
  return n;
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  n = 0;
 42c:	4501                	li	a0,0
 42e:	bfe5                	j	426 <atoi+0x40>

0000000000000430 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 430:	1141                	addi	sp,sp,-16
 432:	e422                	sd	s0,8(sp)
 434:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 436:	02b57663          	bgeu	a0,a1,462 <memmove+0x32>
    while(n-- > 0)
 43a:	02c05163          	blez	a2,45c <memmove+0x2c>
 43e:	fff6079b          	addiw	a5,a2,-1
 442:	1782                	slli	a5,a5,0x20
 444:	9381                	srli	a5,a5,0x20
 446:	0785                	addi	a5,a5,1
 448:	97aa                	add	a5,a5,a0
  dst = vdst;
 44a:	872a                	mv	a4,a0
      *dst++ = *src++;
 44c:	0585                	addi	a1,a1,1
 44e:	0705                	addi	a4,a4,1
 450:	fff5c683          	lbu	a3,-1(a1)
 454:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 458:	fee79ae3          	bne	a5,a4,44c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 45c:	6422                	ld	s0,8(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret
    dst += n;
 462:	00c50733          	add	a4,a0,a2
    src += n;
 466:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 468:	fec05ae3          	blez	a2,45c <memmove+0x2c>
 46c:	fff6079b          	addiw	a5,a2,-1
 470:	1782                	slli	a5,a5,0x20
 472:	9381                	srli	a5,a5,0x20
 474:	fff7c793          	not	a5,a5
 478:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47a:	15fd                	addi	a1,a1,-1
 47c:	177d                	addi	a4,a4,-1
 47e:	0005c683          	lbu	a3,0(a1)
 482:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 486:	fee79ae3          	bne	a5,a4,47a <memmove+0x4a>
 48a:	bfc9                	j	45c <memmove+0x2c>

000000000000048c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 48c:	1141                	addi	sp,sp,-16
 48e:	e422                	sd	s0,8(sp)
 490:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 492:	ca05                	beqz	a2,4c2 <memcmp+0x36>
 494:	fff6069b          	addiw	a3,a2,-1
 498:	1682                	slli	a3,a3,0x20
 49a:	9281                	srli	a3,a3,0x20
 49c:	0685                	addi	a3,a3,1
 49e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4a0:	00054783          	lbu	a5,0(a0)
 4a4:	0005c703          	lbu	a4,0(a1)
 4a8:	00e79863          	bne	a5,a4,4b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4ac:	0505                	addi	a0,a0,1
    p2++;
 4ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b0:	fed518e3          	bne	a0,a3,4a0 <memcmp+0x14>
  }
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	a019                	j	4bc <memcmp+0x30>
      return *p1 - *p2;
 4b8:	40e7853b          	subw	a0,a5,a4
}
 4bc:	6422                	ld	s0,8(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret
  return 0;
 4c2:	4501                	li	a0,0
 4c4:	bfe5                	j	4bc <memcmp+0x30>

00000000000004c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e406                	sd	ra,8(sp)
 4ca:	e022                	sd	s0,0(sp)
 4cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ce:	00000097          	auipc	ra,0x0
 4d2:	f62080e7          	jalr	-158(ra) # 430 <memmove>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret

00000000000004de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4de:	4885                	li	a7,1
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e6:	4889                	li	a7,2
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ee:	488d                	li	a7,3
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f6:	4891                	li	a7,4
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <read>:
.global read
read:
 li a7, SYS_read
 4fe:	4895                	li	a7,5
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <write>:
.global write
write:
 li a7, SYS_write
 506:	48c1                	li	a7,16
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <close>:
.global close
close:
 li a7, SYS_close
 50e:	48d5                	li	a7,21
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <kill>:
.global kill
kill:
 li a7, SYS_kill
 516:	4899                	li	a7,6
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <exec>:
.global exec
exec:
 li a7, SYS_exec
 51e:	489d                	li	a7,7
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <open>:
.global open
open:
 li a7, SYS_open
 526:	48bd                	li	a7,15
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52e:	48c5                	li	a7,17
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 536:	48c9                	li	a7,18
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53e:	48a1                	li	a7,8
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <link>:
.global link
link:
 li a7, SYS_link
 546:	48cd                	li	a7,19
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54e:	48d1                	li	a7,20
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 556:	48a5                	li	a7,9
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <dup>:
.global dup
dup:
 li a7, SYS_dup
 55e:	48a9                	li	a7,10
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 566:	48ad                	li	a7,11
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 56e:	48b1                	li	a7,12
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 576:	48b5                	li	a7,13
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57e:	48b9                	li	a7,14
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret
