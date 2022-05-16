
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyin>:

// what if you pass ridiculous pointers to system calls
// that read user memory with copyin?
void
copyin(char *s)
{
       0:	715d                	addi	sp,sp,-80
       2:	e486                	sd	ra,72(sp)
       4:	e0a2                	sd	s0,64(sp)
       6:	fc26                	sd	s1,56(sp)
       8:	f84a                	sd	s2,48(sp)
       a:	f44e                	sd	s3,40(sp)
       c:	f052                	sd	s4,32(sp)
       e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
      10:	4785                	li	a5,1
      12:	07fe                	slli	a5,a5,0x1f
      14:	fcf43023          	sd	a5,-64(s0)
      18:	57fd                	li	a5,-1
      1a:	fcf43423          	sd	a5,-56(s0)

  for(int ai = 0; ai < 2; ai++){
      1e:	fc040913          	addi	s2,s0,-64
    uint64 addr = addrs[ai];
    
    int fd = open("copyin1", O_CREATE|O_WRONLY);
      22:	00006a17          	auipc	s4,0x6
      26:	d76a0a13          	addi	s4,s4,-650 # 5d98 <malloc+0x11e>
    uint64 addr = addrs[ai];
      2a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
      2e:	20100593          	li	a1,513
      32:	8552                	mv	a0,s4
      34:	00006097          	auipc	ra,0x6
      38:	838080e7          	jalr	-1992(ra) # 586c <open>
      3c:	84aa                	mv	s1,a0
    if(fd < 0){
      3e:	08054863          	bltz	a0,ce <copyin+0xce>
      printf("open(copyin1) failed\n");
      exit(1);
    }
    int n = write(fd, (void*)addr, 8192);
      42:	6609                	lui	a2,0x2
      44:	85ce                	mv	a1,s3
      46:	00006097          	auipc	ra,0x6
      4a:	806080e7          	jalr	-2042(ra) # 584c <write>
    if(n >= 0){
      4e:	08055d63          	bgez	a0,e8 <copyin+0xe8>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
      exit(1);
    }
    close(fd);
      52:	8526                	mv	a0,s1
      54:	00006097          	auipc	ra,0x6
      58:	800080e7          	jalr	-2048(ra) # 5854 <close>
    unlink("copyin1");
      5c:	8552                	mv	a0,s4
      5e:	00006097          	auipc	ra,0x6
      62:	81e080e7          	jalr	-2018(ra) # 587c <unlink>
    
    n = write(1, (char*)addr, 8192);
      66:	6609                	lui	a2,0x2
      68:	85ce                	mv	a1,s3
      6a:	4505                	li	a0,1
      6c:	00005097          	auipc	ra,0x5
      70:	7e0080e7          	jalr	2016(ra) # 584c <write>
    if(n > 0){
      74:	08a04963          	bgtz	a0,106 <copyin+0x106>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }
    
    int fds[2];
    if(pipe(fds) < 0){
      78:	fb840513          	addi	a0,s0,-72
      7c:	00005097          	auipc	ra,0x5
      80:	7c0080e7          	jalr	1984(ra) # 583c <pipe>
      84:	0a054063          	bltz	a0,124 <copyin+0x124>
      printf("pipe() failed\n");
      exit(1);
    }
    n = write(fds[1], (char*)addr, 8192);
      88:	6609                	lui	a2,0x2
      8a:	85ce                	mv	a1,s3
      8c:	fbc42503          	lw	a0,-68(s0)
      90:	00005097          	auipc	ra,0x5
      94:	7bc080e7          	jalr	1980(ra) # 584c <write>
    if(n > 0){
      98:	0aa04363          	bgtz	a0,13e <copyin+0x13e>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }
    close(fds[0]);
      9c:	fb842503          	lw	a0,-72(s0)
      a0:	00005097          	auipc	ra,0x5
      a4:	7b4080e7          	jalr	1972(ra) # 5854 <close>
    close(fds[1]);
      a8:	fbc42503          	lw	a0,-68(s0)
      ac:	00005097          	auipc	ra,0x5
      b0:	7a8080e7          	jalr	1960(ra) # 5854 <close>
  for(int ai = 0; ai < 2; ai++){
      b4:	0921                	addi	s2,s2,8
      b6:	fd040793          	addi	a5,s0,-48
      ba:	f6f918e3          	bne	s2,a5,2a <copyin+0x2a>
  }
}
      be:	60a6                	ld	ra,72(sp)
      c0:	6406                	ld	s0,64(sp)
      c2:	74e2                	ld	s1,56(sp)
      c4:	7942                	ld	s2,48(sp)
      c6:	79a2                	ld	s3,40(sp)
      c8:	7a02                	ld	s4,32(sp)
      ca:	6161                	addi	sp,sp,80
      cc:	8082                	ret
      printf("open(copyin1) failed\n");
      ce:	00006517          	auipc	a0,0x6
      d2:	cd250513          	addi	a0,a0,-814 # 5da0 <malloc+0x126>
      d6:	00006097          	auipc	ra,0x6
      da:	ae6080e7          	jalr	-1306(ra) # 5bbc <printf>
      exit(1);
      de:	4505                	li	a0,1
      e0:	00005097          	auipc	ra,0x5
      e4:	74c080e7          	jalr	1868(ra) # 582c <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
      e8:	862a                	mv	a2,a0
      ea:	85ce                	mv	a1,s3
      ec:	00006517          	auipc	a0,0x6
      f0:	ccc50513          	addi	a0,a0,-820 # 5db8 <malloc+0x13e>
      f4:	00006097          	auipc	ra,0x6
      f8:	ac8080e7          	jalr	-1336(ra) # 5bbc <printf>
      exit(1);
      fc:	4505                	li	a0,1
      fe:	00005097          	auipc	ra,0x5
     102:	72e080e7          	jalr	1838(ra) # 582c <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     106:	862a                	mv	a2,a0
     108:	85ce                	mv	a1,s3
     10a:	00006517          	auipc	a0,0x6
     10e:	cde50513          	addi	a0,a0,-802 # 5de8 <malloc+0x16e>
     112:	00006097          	auipc	ra,0x6
     116:	aaa080e7          	jalr	-1366(ra) # 5bbc <printf>
      exit(1);
     11a:	4505                	li	a0,1
     11c:	00005097          	auipc	ra,0x5
     120:	710080e7          	jalr	1808(ra) # 582c <exit>
      printf("pipe() failed\n");
     124:	00006517          	auipc	a0,0x6
     128:	cf450513          	addi	a0,a0,-780 # 5e18 <malloc+0x19e>
     12c:	00006097          	auipc	ra,0x6
     130:	a90080e7          	jalr	-1392(ra) # 5bbc <printf>
      exit(1);
     134:	4505                	li	a0,1
     136:	00005097          	auipc	ra,0x5
     13a:	6f6080e7          	jalr	1782(ra) # 582c <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     13e:	862a                	mv	a2,a0
     140:	85ce                	mv	a1,s3
     142:	00006517          	auipc	a0,0x6
     146:	ce650513          	addi	a0,a0,-794 # 5e28 <malloc+0x1ae>
     14a:	00006097          	auipc	ra,0x6
     14e:	a72080e7          	jalr	-1422(ra) # 5bbc <printf>
      exit(1);
     152:	4505                	li	a0,1
     154:	00005097          	auipc	ra,0x5
     158:	6d8080e7          	jalr	1752(ra) # 582c <exit>

000000000000015c <copyout>:

// what if you pass ridiculous pointers to system calls
// that write user memory with copyout?
void
copyout(char *s)
{
     15c:	711d                	addi	sp,sp,-96
     15e:	ec86                	sd	ra,88(sp)
     160:	e8a2                	sd	s0,80(sp)
     162:	e4a6                	sd	s1,72(sp)
     164:	e0ca                	sd	s2,64(sp)
     166:	fc4e                	sd	s3,56(sp)
     168:	f852                	sd	s4,48(sp)
     16a:	f456                	sd	s5,40(sp)
     16c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     16e:	4785                	li	a5,1
     170:	07fe                	slli	a5,a5,0x1f
     172:	faf43823          	sd	a5,-80(s0)
     176:	57fd                	li	a5,-1
     178:	faf43c23          	sd	a5,-72(s0)

  for(int ai = 0; ai < 2; ai++){
     17c:	fb040913          	addi	s2,s0,-80
    uint64 addr = addrs[ai];

    int fd = open("README", 0);
     180:	00006a17          	auipc	s4,0x6
     184:	cd8a0a13          	addi	s4,s4,-808 # 5e58 <malloc+0x1de>
    int fds[2];
    if(pipe(fds) < 0){
      printf("pipe() failed\n");
      exit(1);
    }
    n = write(fds[1], "x", 1);
     188:	00006a97          	auipc	s5,0x6
     18c:	d20a8a93          	addi	s5,s5,-736 # 5ea8 <malloc+0x22e>
    uint64 addr = addrs[ai];
     190:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     194:	4581                	li	a1,0
     196:	8552                	mv	a0,s4
     198:	00005097          	auipc	ra,0x5
     19c:	6d4080e7          	jalr	1748(ra) # 586c <open>
     1a0:	84aa                	mv	s1,a0
    if(fd < 0){
     1a2:	08054663          	bltz	a0,22e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     1a6:	6609                	lui	a2,0x2
     1a8:	85ce                	mv	a1,s3
     1aa:	00005097          	auipc	ra,0x5
     1ae:	69a080e7          	jalr	1690(ra) # 5844 <read>
    if(n > 0){
     1b2:	08a04b63          	bgtz	a0,248 <copyout+0xec>
    close(fd);
     1b6:	8526                	mv	a0,s1
     1b8:	00005097          	auipc	ra,0x5
     1bc:	69c080e7          	jalr	1692(ra) # 5854 <close>
    if(pipe(fds) < 0){
     1c0:	fa840513          	addi	a0,s0,-88
     1c4:	00005097          	auipc	ra,0x5
     1c8:	678080e7          	jalr	1656(ra) # 583c <pipe>
     1cc:	08054d63          	bltz	a0,266 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     1d0:	4605                	li	a2,1
     1d2:	85d6                	mv	a1,s5
     1d4:	fac42503          	lw	a0,-84(s0)
     1d8:	00005097          	auipc	ra,0x5
     1dc:	674080e7          	jalr	1652(ra) # 584c <write>
    if(n != 1){
     1e0:	4785                	li	a5,1
     1e2:	08f51f63          	bne	a0,a5,280 <copyout+0x124>
      printf("pipe write failed\n");
      exit(1);
    }
    n = read(fds[0], (void*)addr, 8192);
     1e6:	6609                	lui	a2,0x2
     1e8:	85ce                	mv	a1,s3
     1ea:	fa842503          	lw	a0,-88(s0)
     1ee:	00005097          	auipc	ra,0x5
     1f2:	656080e7          	jalr	1622(ra) # 5844 <read>
    if(n > 0){
     1f6:	0aa04263          	bgtz	a0,29a <copyout+0x13e>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }
    close(fds[0]);
     1fa:	fa842503          	lw	a0,-88(s0)
     1fe:	00005097          	auipc	ra,0x5
     202:	656080e7          	jalr	1622(ra) # 5854 <close>
    close(fds[1]);
     206:	fac42503          	lw	a0,-84(s0)
     20a:	00005097          	auipc	ra,0x5
     20e:	64a080e7          	jalr	1610(ra) # 5854 <close>
  for(int ai = 0; ai < 2; ai++){
     212:	0921                	addi	s2,s2,8
     214:	fc040793          	addi	a5,s0,-64
     218:	f6f91ce3          	bne	s2,a5,190 <copyout+0x34>
  }
}
     21c:	60e6                	ld	ra,88(sp)
     21e:	6446                	ld	s0,80(sp)
     220:	64a6                	ld	s1,72(sp)
     222:	6906                	ld	s2,64(sp)
     224:	79e2                	ld	s3,56(sp)
     226:	7a42                	ld	s4,48(sp)
     228:	7aa2                	ld	s5,40(sp)
     22a:	6125                	addi	sp,sp,96
     22c:	8082                	ret
      printf("open(README) failed\n");
     22e:	00006517          	auipc	a0,0x6
     232:	c3250513          	addi	a0,a0,-974 # 5e60 <malloc+0x1e6>
     236:	00006097          	auipc	ra,0x6
     23a:	986080e7          	jalr	-1658(ra) # 5bbc <printf>
      exit(1);
     23e:	4505                	li	a0,1
     240:	00005097          	auipc	ra,0x5
     244:	5ec080e7          	jalr	1516(ra) # 582c <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     248:	862a                	mv	a2,a0
     24a:	85ce                	mv	a1,s3
     24c:	00006517          	auipc	a0,0x6
     250:	c2c50513          	addi	a0,a0,-980 # 5e78 <malloc+0x1fe>
     254:	00006097          	auipc	ra,0x6
     258:	968080e7          	jalr	-1688(ra) # 5bbc <printf>
      exit(1);
     25c:	4505                	li	a0,1
     25e:	00005097          	auipc	ra,0x5
     262:	5ce080e7          	jalr	1486(ra) # 582c <exit>
      printf("pipe() failed\n");
     266:	00006517          	auipc	a0,0x6
     26a:	bb250513          	addi	a0,a0,-1102 # 5e18 <malloc+0x19e>
     26e:	00006097          	auipc	ra,0x6
     272:	94e080e7          	jalr	-1714(ra) # 5bbc <printf>
      exit(1);
     276:	4505                	li	a0,1
     278:	00005097          	auipc	ra,0x5
     27c:	5b4080e7          	jalr	1460(ra) # 582c <exit>
      printf("pipe write failed\n");
     280:	00006517          	auipc	a0,0x6
     284:	c3050513          	addi	a0,a0,-976 # 5eb0 <malloc+0x236>
     288:	00006097          	auipc	ra,0x6
     28c:	934080e7          	jalr	-1740(ra) # 5bbc <printf>
      exit(1);
     290:	4505                	li	a0,1
     292:	00005097          	auipc	ra,0x5
     296:	59a080e7          	jalr	1434(ra) # 582c <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     29a:	862a                	mv	a2,a0
     29c:	85ce                	mv	a1,s3
     29e:	00006517          	auipc	a0,0x6
     2a2:	c2a50513          	addi	a0,a0,-982 # 5ec8 <malloc+0x24e>
     2a6:	00006097          	auipc	ra,0x6
     2aa:	916080e7          	jalr	-1770(ra) # 5bbc <printf>
      exit(1);
     2ae:	4505                	li	a0,1
     2b0:	00005097          	auipc	ra,0x5
     2b4:	57c080e7          	jalr	1404(ra) # 582c <exit>

00000000000002b8 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
     2b8:	715d                	addi	sp,sp,-80
     2ba:	e486                	sd	ra,72(sp)
     2bc:	e0a2                	sd	s0,64(sp)
     2be:	fc26                	sd	s1,56(sp)
     2c0:	f84a                	sd	s2,48(sp)
     2c2:	f44e                	sd	s3,40(sp)
     2c4:	f052                	sd	s4,32(sp)
     2c6:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
     2c8:	4901                	li	s2,0
     2ca:	49bd                	li	s3,15
    int pid = fork();
     2cc:	00005097          	auipc	ra,0x5
     2d0:	558080e7          	jalr	1368(ra) # 5824 <fork>
     2d4:	84aa                	mv	s1,a0
    if(pid < 0){
     2d6:	02054063          	bltz	a0,2f6 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
     2da:	c91d                	beqz	a0,310 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
     2dc:	4501                	li	a0,0
     2de:	00005097          	auipc	ra,0x5
     2e2:	556080e7          	jalr	1366(ra) # 5834 <wait>
  for(int avail = 0; avail < 15; avail++){
     2e6:	2905                	addiw	s2,s2,1
     2e8:	ff3912e3          	bne	s2,s3,2cc <execout+0x14>
    }
  }

  exit(0);
     2ec:	4501                	li	a0,0
     2ee:	00005097          	auipc	ra,0x5
     2f2:	53e080e7          	jalr	1342(ra) # 582c <exit>
      printf("fork failed\n");
     2f6:	00008517          	auipc	a0,0x8
     2fa:	8ba50513          	addi	a0,a0,-1862 # 7bb0 <malloc+0x1f36>
     2fe:	00006097          	auipc	ra,0x6
     302:	8be080e7          	jalr	-1858(ra) # 5bbc <printf>
      exit(1);
     306:	4505                	li	a0,1
     308:	00005097          	auipc	ra,0x5
     30c:	524080e7          	jalr	1316(ra) # 582c <exit>
        if(a == 0xffffffffffffffffLL)
     310:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
     312:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
     314:	6505                	lui	a0,0x1
     316:	00005097          	auipc	ra,0x5
     31a:	59e080e7          	jalr	1438(ra) # 58b4 <sbrk>
        if(a == 0xffffffffffffffffLL)
     31e:	01350763          	beq	a0,s3,32c <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
     322:	6785                	lui	a5,0x1
     324:	953e                	add	a0,a0,a5
     326:	ff450fa3          	sb	s4,-1(a0) # fff <opentest+0x4b>
      while(1){
     32a:	b7ed                	j	314 <execout+0x5c>
      for(int i = 0; i < avail; i++)
     32c:	01205a63          	blez	s2,340 <execout+0x88>
        sbrk(-4096);
     330:	757d                	lui	a0,0xfffff
     332:	00005097          	auipc	ra,0x5
     336:	582080e7          	jalr	1410(ra) # 58b4 <sbrk>
      for(int i = 0; i < avail; i++)
     33a:	2485                	addiw	s1,s1,1
     33c:	ff249ae3          	bne	s1,s2,330 <execout+0x78>
      close(1);
     340:	4505                	li	a0,1
     342:	00005097          	auipc	ra,0x5
     346:	512080e7          	jalr	1298(ra) # 5854 <close>
      char *args[] = { "echo", "x", 0 };
     34a:	00006517          	auipc	a0,0x6
     34e:	bae50513          	addi	a0,a0,-1106 # 5ef8 <malloc+0x27e>
     352:	faa43c23          	sd	a0,-72(s0)
     356:	00006797          	auipc	a5,0x6
     35a:	b5278793          	addi	a5,a5,-1198 # 5ea8 <malloc+0x22e>
     35e:	fcf43023          	sd	a5,-64(s0)
     362:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
     366:	fb840593          	addi	a1,s0,-72
     36a:	00005097          	auipc	ra,0x5
     36e:	4fa080e7          	jalr	1274(ra) # 5864 <exec>
      exit(0);
     372:	4501                	li	a0,0
     374:	00005097          	auipc	ra,0x5
     378:	4b8080e7          	jalr	1208(ra) # 582c <exit>

000000000000037c <copyinstr1>:
{
     37c:	1141                	addi	sp,sp,-16
     37e:	e406                	sd	ra,8(sp)
     380:	e022                	sd	s0,0(sp)
     382:	0800                	addi	s0,sp,16
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     384:	20100593          	li	a1,513
     388:	4505                	li	a0,1
     38a:	057e                	slli	a0,a0,0x1f
     38c:	00005097          	auipc	ra,0x5
     390:	4e0080e7          	jalr	1248(ra) # 586c <open>
    if(fd >= 0){
     394:	02055063          	bgez	a0,3b4 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     398:	20100593          	li	a1,513
     39c:	557d                	li	a0,-1
     39e:	00005097          	auipc	ra,0x5
     3a2:	4ce080e7          	jalr	1230(ra) # 586c <open>
    uint64 addr = addrs[ai];
     3a6:	55fd                	li	a1,-1
    if(fd >= 0){
     3a8:	00055863          	bgez	a0,3b8 <copyinstr1+0x3c>
}
     3ac:	60a2                	ld	ra,8(sp)
     3ae:	6402                	ld	s0,0(sp)
     3b0:	0141                	addi	sp,sp,16
     3b2:	8082                	ret
    uint64 addr = addrs[ai];
     3b4:	4585                	li	a1,1
     3b6:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
     3b8:	862a                	mv	a2,a0
     3ba:	00006517          	auipc	a0,0x6
     3be:	b4650513          	addi	a0,a0,-1210 # 5f00 <malloc+0x286>
     3c2:	00005097          	auipc	ra,0x5
     3c6:	7fa080e7          	jalr	2042(ra) # 5bbc <printf>
      exit(1);
     3ca:	4505                	li	a0,1
     3cc:	00005097          	auipc	ra,0x5
     3d0:	460080e7          	jalr	1120(ra) # 582c <exit>

00000000000003d4 <copyinstr2>:
{
     3d4:	7155                	addi	sp,sp,-208
     3d6:	e586                	sd	ra,200(sp)
     3d8:	e1a2                	sd	s0,192(sp)
     3da:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
     3dc:	f6840793          	addi	a5,s0,-152
     3e0:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
     3e4:	07800713          	li	a4,120
     3e8:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
     3ec:	0785                	addi	a5,a5,1
     3ee:	fed79de3          	bne	a5,a3,3e8 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
     3f2:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
     3f6:	f6840513          	addi	a0,s0,-152
     3fa:	00005097          	auipc	ra,0x5
     3fe:	482080e7          	jalr	1154(ra) # 587c <unlink>
  if(ret != -1){
     402:	57fd                	li	a5,-1
     404:	0ef51063          	bne	a0,a5,4e4 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
     408:	20100593          	li	a1,513
     40c:	f6840513          	addi	a0,s0,-152
     410:	00005097          	auipc	ra,0x5
     414:	45c080e7          	jalr	1116(ra) # 586c <open>
  if(fd != -1){
     418:	57fd                	li	a5,-1
     41a:	0ef51563          	bne	a0,a5,504 <copyinstr2+0x130>
  ret = link(b, b);
     41e:	f6840593          	addi	a1,s0,-152
     422:	852e                	mv	a0,a1
     424:	00005097          	auipc	ra,0x5
     428:	468080e7          	jalr	1128(ra) # 588c <link>
  if(ret != -1){
     42c:	57fd                	li	a5,-1
     42e:	0ef51b63          	bne	a0,a5,524 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
     432:	00007797          	auipc	a5,0x7
     436:	1ee78793          	addi	a5,a5,494 # 7620 <malloc+0x19a6>
     43a:	f4f43c23          	sd	a5,-168(s0)
     43e:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
     442:	f5840593          	addi	a1,s0,-168
     446:	f6840513          	addi	a0,s0,-152
     44a:	00005097          	auipc	ra,0x5
     44e:	41a080e7          	jalr	1050(ra) # 5864 <exec>
  if(ret != -1){
     452:	57fd                	li	a5,-1
     454:	0ef51963          	bne	a0,a5,546 <copyinstr2+0x172>
  int pid = fork();
     458:	00005097          	auipc	ra,0x5
     45c:	3cc080e7          	jalr	972(ra) # 5824 <fork>
  if(pid < 0){
     460:	10054363          	bltz	a0,566 <copyinstr2+0x192>
  if(pid == 0){
     464:	12051463          	bnez	a0,58c <copyinstr2+0x1b8>
     468:	00008797          	auipc	a5,0x8
     46c:	b5878793          	addi	a5,a5,-1192 # 7fc0 <big.1275>
     470:	00009697          	auipc	a3,0x9
     474:	b5068693          	addi	a3,a3,-1200 # 8fc0 <__global_pointer$+0x910>
      big[i] = 'x';
     478:	07800713          	li	a4,120
     47c:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
     480:	0785                	addi	a5,a5,1
     482:	fed79de3          	bne	a5,a3,47c <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
     486:	00009797          	auipc	a5,0x9
     48a:	b2078d23          	sb	zero,-1222(a5) # 8fc0 <__global_pointer$+0x910>
    char *args2[] = { big, big, big, 0 };
     48e:	00008797          	auipc	a5,0x8
     492:	9b278793          	addi	a5,a5,-1614 # 7e40 <malloc+0x21c6>
     496:	6390                	ld	a2,0(a5)
     498:	6794                	ld	a3,8(a5)
     49a:	6b98                	ld	a4,16(a5)
     49c:	6f9c                	ld	a5,24(a5)
     49e:	f2c43823          	sd	a2,-208(s0)
     4a2:	f2d43c23          	sd	a3,-200(s0)
     4a6:	f4e43023          	sd	a4,-192(s0)
     4aa:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
     4ae:	f3040593          	addi	a1,s0,-208
     4b2:	00006517          	auipc	a0,0x6
     4b6:	a4650513          	addi	a0,a0,-1466 # 5ef8 <malloc+0x27e>
     4ba:	00005097          	auipc	ra,0x5
     4be:	3aa080e7          	jalr	938(ra) # 5864 <exec>
    if(ret != -1){
     4c2:	57fd                	li	a5,-1
     4c4:	0af50e63          	beq	a0,a5,580 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
     4c8:	55fd                	li	a1,-1
     4ca:	00006517          	auipc	a0,0x6
     4ce:	ade50513          	addi	a0,a0,-1314 # 5fa8 <malloc+0x32e>
     4d2:	00005097          	auipc	ra,0x5
     4d6:	6ea080e7          	jalr	1770(ra) # 5bbc <printf>
      exit(1);
     4da:	4505                	li	a0,1
     4dc:	00005097          	auipc	ra,0x5
     4e0:	350080e7          	jalr	848(ra) # 582c <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
     4e4:	862a                	mv	a2,a0
     4e6:	f6840593          	addi	a1,s0,-152
     4ea:	00006517          	auipc	a0,0x6
     4ee:	a3650513          	addi	a0,a0,-1482 # 5f20 <malloc+0x2a6>
     4f2:	00005097          	auipc	ra,0x5
     4f6:	6ca080e7          	jalr	1738(ra) # 5bbc <printf>
    exit(1);
     4fa:	4505                	li	a0,1
     4fc:	00005097          	auipc	ra,0x5
     500:	330080e7          	jalr	816(ra) # 582c <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
     504:	862a                	mv	a2,a0
     506:	f6840593          	addi	a1,s0,-152
     50a:	00006517          	auipc	a0,0x6
     50e:	a3650513          	addi	a0,a0,-1482 # 5f40 <malloc+0x2c6>
     512:	00005097          	auipc	ra,0x5
     516:	6aa080e7          	jalr	1706(ra) # 5bbc <printf>
    exit(1);
     51a:	4505                	li	a0,1
     51c:	00005097          	auipc	ra,0x5
     520:	310080e7          	jalr	784(ra) # 582c <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
     524:	86aa                	mv	a3,a0
     526:	f6840613          	addi	a2,s0,-152
     52a:	85b2                	mv	a1,a2
     52c:	00006517          	auipc	a0,0x6
     530:	a3450513          	addi	a0,a0,-1484 # 5f60 <malloc+0x2e6>
     534:	00005097          	auipc	ra,0x5
     538:	688080e7          	jalr	1672(ra) # 5bbc <printf>
    exit(1);
     53c:	4505                	li	a0,1
     53e:	00005097          	auipc	ra,0x5
     542:	2ee080e7          	jalr	750(ra) # 582c <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
     546:	567d                	li	a2,-1
     548:	f6840593          	addi	a1,s0,-152
     54c:	00006517          	auipc	a0,0x6
     550:	a3c50513          	addi	a0,a0,-1476 # 5f88 <malloc+0x30e>
     554:	00005097          	auipc	ra,0x5
     558:	668080e7          	jalr	1640(ra) # 5bbc <printf>
    exit(1);
     55c:	4505                	li	a0,1
     55e:	00005097          	auipc	ra,0x5
     562:	2ce080e7          	jalr	718(ra) # 582c <exit>
    printf("fork failed\n");
     566:	00007517          	auipc	a0,0x7
     56a:	64a50513          	addi	a0,a0,1610 # 7bb0 <malloc+0x1f36>
     56e:	00005097          	auipc	ra,0x5
     572:	64e080e7          	jalr	1614(ra) # 5bbc <printf>
    exit(1);
     576:	4505                	li	a0,1
     578:	00005097          	auipc	ra,0x5
     57c:	2b4080e7          	jalr	692(ra) # 582c <exit>
    exit(747); // OK
     580:	2eb00513          	li	a0,747
     584:	00005097          	auipc	ra,0x5
     588:	2a8080e7          	jalr	680(ra) # 582c <exit>
  int st = 0;
     58c:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
     590:	f5440513          	addi	a0,s0,-172
     594:	00005097          	auipc	ra,0x5
     598:	2a0080e7          	jalr	672(ra) # 5834 <wait>
  if(st != 747){
     59c:	f5442703          	lw	a4,-172(s0)
     5a0:	2eb00793          	li	a5,747
     5a4:	00f71663          	bne	a4,a5,5b0 <copyinstr2+0x1dc>
}
     5a8:	60ae                	ld	ra,200(sp)
     5aa:	640e                	ld	s0,192(sp)
     5ac:	6169                	addi	sp,sp,208
     5ae:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
     5b0:	00006517          	auipc	a0,0x6
     5b4:	a2050513          	addi	a0,a0,-1504 # 5fd0 <malloc+0x356>
     5b8:	00005097          	auipc	ra,0x5
     5bc:	604080e7          	jalr	1540(ra) # 5bbc <printf>
    exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00005097          	auipc	ra,0x5
     5c6:	26a080e7          	jalr	618(ra) # 582c <exit>

00000000000005ca <copyinstr3>:
{
     5ca:	7179                	addi	sp,sp,-48
     5cc:	f406                	sd	ra,40(sp)
     5ce:	f022                	sd	s0,32(sp)
     5d0:	ec26                	sd	s1,24(sp)
     5d2:	1800                	addi	s0,sp,48
  sbrk(8192);
     5d4:	6509                	lui	a0,0x2
     5d6:	00005097          	auipc	ra,0x5
     5da:	2de080e7          	jalr	734(ra) # 58b4 <sbrk>
  uint64 top = (uint64) sbrk(0);
     5de:	4501                	li	a0,0
     5e0:	00005097          	auipc	ra,0x5
     5e4:	2d4080e7          	jalr	724(ra) # 58b4 <sbrk>
  if((top % PGSIZE) != 0){
     5e8:	03451793          	slli	a5,a0,0x34
     5ec:	e3c9                	bnez	a5,66e <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
     5ee:	4501                	li	a0,0
     5f0:	00005097          	auipc	ra,0x5
     5f4:	2c4080e7          	jalr	708(ra) # 58b4 <sbrk>
  if(top % PGSIZE){
     5f8:	03451793          	slli	a5,a0,0x34
     5fc:	e3d9                	bnez	a5,682 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
     5fe:	fff50493          	addi	s1,a0,-1 # 1fff <sharedfd+0x99>
  *b = 'x';
     602:	07800793          	li	a5,120
     606:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
     60a:	8526                	mv	a0,s1
     60c:	00005097          	auipc	ra,0x5
     610:	270080e7          	jalr	624(ra) # 587c <unlink>
  if(ret != -1){
     614:	57fd                	li	a5,-1
     616:	08f51363          	bne	a0,a5,69c <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
     61a:	20100593          	li	a1,513
     61e:	8526                	mv	a0,s1
     620:	00005097          	auipc	ra,0x5
     624:	24c080e7          	jalr	588(ra) # 586c <open>
  if(fd != -1){
     628:	57fd                	li	a5,-1
     62a:	08f51863          	bne	a0,a5,6ba <copyinstr3+0xf0>
  ret = link(b, b);
     62e:	85a6                	mv	a1,s1
     630:	8526                	mv	a0,s1
     632:	00005097          	auipc	ra,0x5
     636:	25a080e7          	jalr	602(ra) # 588c <link>
  if(ret != -1){
     63a:	57fd                	li	a5,-1
     63c:	08f51e63          	bne	a0,a5,6d8 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
     640:	00007797          	auipc	a5,0x7
     644:	fe078793          	addi	a5,a5,-32 # 7620 <malloc+0x19a6>
     648:	fcf43823          	sd	a5,-48(s0)
     64c:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
     650:	fd040593          	addi	a1,s0,-48
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	20e080e7          	jalr	526(ra) # 5864 <exec>
  if(ret != -1){
     65e:	57fd                	li	a5,-1
     660:	08f51c63          	bne	a0,a5,6f8 <copyinstr3+0x12e>
}
     664:	70a2                	ld	ra,40(sp)
     666:	7402                	ld	s0,32(sp)
     668:	64e2                	ld	s1,24(sp)
     66a:	6145                	addi	sp,sp,48
     66c:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
     66e:	0347d513          	srli	a0,a5,0x34
     672:	6785                	lui	a5,0x1
     674:	40a7853b          	subw	a0,a5,a0
     678:	00005097          	auipc	ra,0x5
     67c:	23c080e7          	jalr	572(ra) # 58b4 <sbrk>
     680:	b7bd                	j	5ee <copyinstr3+0x24>
    printf("oops\n");
     682:	00006517          	auipc	a0,0x6
     686:	97e50513          	addi	a0,a0,-1666 # 6000 <malloc+0x386>
     68a:	00005097          	auipc	ra,0x5
     68e:	532080e7          	jalr	1330(ra) # 5bbc <printf>
    exit(1);
     692:	4505                	li	a0,1
     694:	00005097          	auipc	ra,0x5
     698:	198080e7          	jalr	408(ra) # 582c <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
     69c:	862a                	mv	a2,a0
     69e:	85a6                	mv	a1,s1
     6a0:	00006517          	auipc	a0,0x6
     6a4:	88050513          	addi	a0,a0,-1920 # 5f20 <malloc+0x2a6>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	514080e7          	jalr	1300(ra) # 5bbc <printf>
    exit(1);
     6b0:	4505                	li	a0,1
     6b2:	00005097          	auipc	ra,0x5
     6b6:	17a080e7          	jalr	378(ra) # 582c <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
     6ba:	862a                	mv	a2,a0
     6bc:	85a6                	mv	a1,s1
     6be:	00006517          	auipc	a0,0x6
     6c2:	88250513          	addi	a0,a0,-1918 # 5f40 <malloc+0x2c6>
     6c6:	00005097          	auipc	ra,0x5
     6ca:	4f6080e7          	jalr	1270(ra) # 5bbc <printf>
    exit(1);
     6ce:	4505                	li	a0,1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	15c080e7          	jalr	348(ra) # 582c <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
     6d8:	86aa                	mv	a3,a0
     6da:	8626                	mv	a2,s1
     6dc:	85a6                	mv	a1,s1
     6de:	00006517          	auipc	a0,0x6
     6e2:	88250513          	addi	a0,a0,-1918 # 5f60 <malloc+0x2e6>
     6e6:	00005097          	auipc	ra,0x5
     6ea:	4d6080e7          	jalr	1238(ra) # 5bbc <printf>
    exit(1);
     6ee:	4505                	li	a0,1
     6f0:	00005097          	auipc	ra,0x5
     6f4:	13c080e7          	jalr	316(ra) # 582c <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
     6f8:	567d                	li	a2,-1
     6fa:	85a6                	mv	a1,s1
     6fc:	00006517          	auipc	a0,0x6
     700:	88c50513          	addi	a0,a0,-1908 # 5f88 <malloc+0x30e>
     704:	00005097          	auipc	ra,0x5
     708:	4b8080e7          	jalr	1208(ra) # 5bbc <printf>
    exit(1);
     70c:	4505                	li	a0,1
     70e:	00005097          	auipc	ra,0x5
     712:	11e080e7          	jalr	286(ra) # 582c <exit>

0000000000000716 <rwsbrk>:
{
     716:	1101                	addi	sp,sp,-32
     718:	ec06                	sd	ra,24(sp)
     71a:	e822                	sd	s0,16(sp)
     71c:	e426                	sd	s1,8(sp)
     71e:	e04a                	sd	s2,0(sp)
     720:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
     722:	6509                	lui	a0,0x2
     724:	00005097          	auipc	ra,0x5
     728:	190080e7          	jalr	400(ra) # 58b4 <sbrk>
  if(a == 0xffffffffffffffffLL) {
     72c:	57fd                	li	a5,-1
     72e:	06f50363          	beq	a0,a5,794 <rwsbrk+0x7e>
     732:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
     734:	7579                	lui	a0,0xffffe
     736:	00005097          	auipc	ra,0x5
     73a:	17e080e7          	jalr	382(ra) # 58b4 <sbrk>
     73e:	57fd                	li	a5,-1
     740:	06f50763          	beq	a0,a5,7ae <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
     744:	20100593          	li	a1,513
     748:	00006517          	auipc	a0,0x6
     74c:	8f850513          	addi	a0,a0,-1800 # 6040 <malloc+0x3c6>
     750:	00005097          	auipc	ra,0x5
     754:	11c080e7          	jalr	284(ra) # 586c <open>
     758:	892a                	mv	s2,a0
  if(fd < 0){
     75a:	06054763          	bltz	a0,7c8 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
     75e:	6505                	lui	a0,0x1
     760:	94aa                	add	s1,s1,a0
     762:	40000613          	li	a2,1024
     766:	85a6                	mv	a1,s1
     768:	854a                	mv	a0,s2
     76a:	00005097          	auipc	ra,0x5
     76e:	0e2080e7          	jalr	226(ra) # 584c <write>
     772:	862a                	mv	a2,a0
  if(n >= 0){
     774:	06054763          	bltz	a0,7e2 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
     778:	85a6                	mv	a1,s1
     77a:	00006517          	auipc	a0,0x6
     77e:	8e650513          	addi	a0,a0,-1818 # 6060 <malloc+0x3e6>
     782:	00005097          	auipc	ra,0x5
     786:	43a080e7          	jalr	1082(ra) # 5bbc <printf>
    exit(1);
     78a:	4505                	li	a0,1
     78c:	00005097          	auipc	ra,0x5
     790:	0a0080e7          	jalr	160(ra) # 582c <exit>
    printf("sbrk(rwsbrk) failed\n");
     794:	00006517          	auipc	a0,0x6
     798:	87450513          	addi	a0,a0,-1932 # 6008 <malloc+0x38e>
     79c:	00005097          	auipc	ra,0x5
     7a0:	420080e7          	jalr	1056(ra) # 5bbc <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	086080e7          	jalr	134(ra) # 582c <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
     7ae:	00006517          	auipc	a0,0x6
     7b2:	87250513          	addi	a0,a0,-1934 # 6020 <malloc+0x3a6>
     7b6:	00005097          	auipc	ra,0x5
     7ba:	406080e7          	jalr	1030(ra) # 5bbc <printf>
    exit(1);
     7be:	4505                	li	a0,1
     7c0:	00005097          	auipc	ra,0x5
     7c4:	06c080e7          	jalr	108(ra) # 582c <exit>
    printf("open(rwsbrk) failed\n");
     7c8:	00006517          	auipc	a0,0x6
     7cc:	88050513          	addi	a0,a0,-1920 # 6048 <malloc+0x3ce>
     7d0:	00005097          	auipc	ra,0x5
     7d4:	3ec080e7          	jalr	1004(ra) # 5bbc <printf>
    exit(1);
     7d8:	4505                	li	a0,1
     7da:	00005097          	auipc	ra,0x5
     7de:	052080e7          	jalr	82(ra) # 582c <exit>
  close(fd);
     7e2:	854a                	mv	a0,s2
     7e4:	00005097          	auipc	ra,0x5
     7e8:	070080e7          	jalr	112(ra) # 5854 <close>
  unlink("rwsbrk");
     7ec:	00006517          	auipc	a0,0x6
     7f0:	85450513          	addi	a0,a0,-1964 # 6040 <malloc+0x3c6>
     7f4:	00005097          	auipc	ra,0x5
     7f8:	088080e7          	jalr	136(ra) # 587c <unlink>
  fd = open("README", O_RDONLY);
     7fc:	4581                	li	a1,0
     7fe:	00005517          	auipc	a0,0x5
     802:	65a50513          	addi	a0,a0,1626 # 5e58 <malloc+0x1de>
     806:	00005097          	auipc	ra,0x5
     80a:	066080e7          	jalr	102(ra) # 586c <open>
     80e:	892a                	mv	s2,a0
  if(fd < 0){
     810:	02054963          	bltz	a0,842 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
     814:	4629                	li	a2,10
     816:	85a6                	mv	a1,s1
     818:	00005097          	auipc	ra,0x5
     81c:	02c080e7          	jalr	44(ra) # 5844 <read>
     820:	862a                	mv	a2,a0
  if(n >= 0){
     822:	02054d63          	bltz	a0,85c <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
     826:	85a6                	mv	a1,s1
     828:	00006517          	auipc	a0,0x6
     82c:	86850513          	addi	a0,a0,-1944 # 6090 <malloc+0x416>
     830:	00005097          	auipc	ra,0x5
     834:	38c080e7          	jalr	908(ra) # 5bbc <printf>
    exit(1);
     838:	4505                	li	a0,1
     83a:	00005097          	auipc	ra,0x5
     83e:	ff2080e7          	jalr	-14(ra) # 582c <exit>
    printf("open(rwsbrk) failed\n");
     842:	00006517          	auipc	a0,0x6
     846:	80650513          	addi	a0,a0,-2042 # 6048 <malloc+0x3ce>
     84a:	00005097          	auipc	ra,0x5
     84e:	372080e7          	jalr	882(ra) # 5bbc <printf>
    exit(1);
     852:	4505                	li	a0,1
     854:	00005097          	auipc	ra,0x5
     858:	fd8080e7          	jalr	-40(ra) # 582c <exit>
  close(fd);
     85c:	854a                	mv	a0,s2
     85e:	00005097          	auipc	ra,0x5
     862:	ff6080e7          	jalr	-10(ra) # 5854 <close>
  exit(0);
     866:	4501                	li	a0,0
     868:	00005097          	auipc	ra,0x5
     86c:	fc4080e7          	jalr	-60(ra) # 582c <exit>

0000000000000870 <truncate1>:
{
     870:	711d                	addi	sp,sp,-96
     872:	ec86                	sd	ra,88(sp)
     874:	e8a2                	sd	s0,80(sp)
     876:	e4a6                	sd	s1,72(sp)
     878:	e0ca                	sd	s2,64(sp)
     87a:	fc4e                	sd	s3,56(sp)
     87c:	f852                	sd	s4,48(sp)
     87e:	f456                	sd	s5,40(sp)
     880:	1080                	addi	s0,sp,96
     882:	8aaa                	mv	s5,a0
  unlink("truncfile");
     884:	00006517          	auipc	a0,0x6
     888:	83450513          	addi	a0,a0,-1996 # 60b8 <malloc+0x43e>
     88c:	00005097          	auipc	ra,0x5
     890:	ff0080e7          	jalr	-16(ra) # 587c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     894:	60100593          	li	a1,1537
     898:	00006517          	auipc	a0,0x6
     89c:	82050513          	addi	a0,a0,-2016 # 60b8 <malloc+0x43e>
     8a0:	00005097          	auipc	ra,0x5
     8a4:	fcc080e7          	jalr	-52(ra) # 586c <open>
     8a8:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     8aa:	4611                	li	a2,4
     8ac:	00006597          	auipc	a1,0x6
     8b0:	81c58593          	addi	a1,a1,-2020 # 60c8 <malloc+0x44e>
     8b4:	00005097          	auipc	ra,0x5
     8b8:	f98080e7          	jalr	-104(ra) # 584c <write>
  close(fd1);
     8bc:	8526                	mv	a0,s1
     8be:	00005097          	auipc	ra,0x5
     8c2:	f96080e7          	jalr	-106(ra) # 5854 <close>
  int fd2 = open("truncfile", O_RDONLY);
     8c6:	4581                	li	a1,0
     8c8:	00005517          	auipc	a0,0x5
     8cc:	7f050513          	addi	a0,a0,2032 # 60b8 <malloc+0x43e>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	f9c080e7          	jalr	-100(ra) # 586c <open>
     8d8:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     8da:	02000613          	li	a2,32
     8de:	fa040593          	addi	a1,s0,-96
     8e2:	00005097          	auipc	ra,0x5
     8e6:	f62080e7          	jalr	-158(ra) # 5844 <read>
  if(n != 4){
     8ea:	4791                	li	a5,4
     8ec:	0cf51e63          	bne	a0,a5,9c8 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     8f0:	40100593          	li	a1,1025
     8f4:	00005517          	auipc	a0,0x5
     8f8:	7c450513          	addi	a0,a0,1988 # 60b8 <malloc+0x43e>
     8fc:	00005097          	auipc	ra,0x5
     900:	f70080e7          	jalr	-144(ra) # 586c <open>
     904:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     906:	4581                	li	a1,0
     908:	00005517          	auipc	a0,0x5
     90c:	7b050513          	addi	a0,a0,1968 # 60b8 <malloc+0x43e>
     910:	00005097          	auipc	ra,0x5
     914:	f5c080e7          	jalr	-164(ra) # 586c <open>
     918:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     91a:	02000613          	li	a2,32
     91e:	fa040593          	addi	a1,s0,-96
     922:	00005097          	auipc	ra,0x5
     926:	f22080e7          	jalr	-222(ra) # 5844 <read>
     92a:	8a2a                	mv	s4,a0
  if(n != 0){
     92c:	ed4d                	bnez	a0,9e6 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     92e:	02000613          	li	a2,32
     932:	fa040593          	addi	a1,s0,-96
     936:	8526                	mv	a0,s1
     938:	00005097          	auipc	ra,0x5
     93c:	f0c080e7          	jalr	-244(ra) # 5844 <read>
     940:	8a2a                	mv	s4,a0
  if(n != 0){
     942:	e971                	bnez	a0,a16 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     944:	4619                	li	a2,6
     946:	00005597          	auipc	a1,0x5
     94a:	7ea58593          	addi	a1,a1,2026 # 6130 <malloc+0x4b6>
     94e:	854e                	mv	a0,s3
     950:	00005097          	auipc	ra,0x5
     954:	efc080e7          	jalr	-260(ra) # 584c <write>
  n = read(fd3, buf, sizeof(buf));
     958:	02000613          	li	a2,32
     95c:	fa040593          	addi	a1,s0,-96
     960:	854a                	mv	a0,s2
     962:	00005097          	auipc	ra,0x5
     966:	ee2080e7          	jalr	-286(ra) # 5844 <read>
  if(n != 6){
     96a:	4799                	li	a5,6
     96c:	0cf51d63          	bne	a0,a5,a46 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     970:	02000613          	li	a2,32
     974:	fa040593          	addi	a1,s0,-96
     978:	8526                	mv	a0,s1
     97a:	00005097          	auipc	ra,0x5
     97e:	eca080e7          	jalr	-310(ra) # 5844 <read>
  if(n != 2){
     982:	4789                	li	a5,2
     984:	0ef51063          	bne	a0,a5,a64 <truncate1+0x1f4>
  unlink("truncfile");
     988:	00005517          	auipc	a0,0x5
     98c:	73050513          	addi	a0,a0,1840 # 60b8 <malloc+0x43e>
     990:	00005097          	auipc	ra,0x5
     994:	eec080e7          	jalr	-276(ra) # 587c <unlink>
  close(fd1);
     998:	854e                	mv	a0,s3
     99a:	00005097          	auipc	ra,0x5
     99e:	eba080e7          	jalr	-326(ra) # 5854 <close>
  close(fd2);
     9a2:	8526                	mv	a0,s1
     9a4:	00005097          	auipc	ra,0x5
     9a8:	eb0080e7          	jalr	-336(ra) # 5854 <close>
  close(fd3);
     9ac:	854a                	mv	a0,s2
     9ae:	00005097          	auipc	ra,0x5
     9b2:	ea6080e7          	jalr	-346(ra) # 5854 <close>
}
     9b6:	60e6                	ld	ra,88(sp)
     9b8:	6446                	ld	s0,80(sp)
     9ba:	64a6                	ld	s1,72(sp)
     9bc:	6906                	ld	s2,64(sp)
     9be:	79e2                	ld	s3,56(sp)
     9c0:	7a42                	ld	s4,48(sp)
     9c2:	7aa2                	ld	s5,40(sp)
     9c4:	6125                	addi	sp,sp,96
     9c6:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     9c8:	862a                	mv	a2,a0
     9ca:	85d6                	mv	a1,s5
     9cc:	00005517          	auipc	a0,0x5
     9d0:	70450513          	addi	a0,a0,1796 # 60d0 <malloc+0x456>
     9d4:	00005097          	auipc	ra,0x5
     9d8:	1e8080e7          	jalr	488(ra) # 5bbc <printf>
    exit(1);
     9dc:	4505                	li	a0,1
     9de:	00005097          	auipc	ra,0x5
     9e2:	e4e080e7          	jalr	-434(ra) # 582c <exit>
    printf("aaa fd3=%d\n", fd3);
     9e6:	85ca                	mv	a1,s2
     9e8:	00005517          	auipc	a0,0x5
     9ec:	70850513          	addi	a0,a0,1800 # 60f0 <malloc+0x476>
     9f0:	00005097          	auipc	ra,0x5
     9f4:	1cc080e7          	jalr	460(ra) # 5bbc <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9f8:	8652                	mv	a2,s4
     9fa:	85d6                	mv	a1,s5
     9fc:	00005517          	auipc	a0,0x5
     a00:	70450513          	addi	a0,a0,1796 # 6100 <malloc+0x486>
     a04:	00005097          	auipc	ra,0x5
     a08:	1b8080e7          	jalr	440(ra) # 5bbc <printf>
    exit(1);
     a0c:	4505                	li	a0,1
     a0e:	00005097          	auipc	ra,0x5
     a12:	e1e080e7          	jalr	-482(ra) # 582c <exit>
    printf("bbb fd2=%d\n", fd2);
     a16:	85a6                	mv	a1,s1
     a18:	00005517          	auipc	a0,0x5
     a1c:	70850513          	addi	a0,a0,1800 # 6120 <malloc+0x4a6>
     a20:	00005097          	auipc	ra,0x5
     a24:	19c080e7          	jalr	412(ra) # 5bbc <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     a28:	8652                	mv	a2,s4
     a2a:	85d6                	mv	a1,s5
     a2c:	00005517          	auipc	a0,0x5
     a30:	6d450513          	addi	a0,a0,1748 # 6100 <malloc+0x486>
     a34:	00005097          	auipc	ra,0x5
     a38:	188080e7          	jalr	392(ra) # 5bbc <printf>
    exit(1);
     a3c:	4505                	li	a0,1
     a3e:	00005097          	auipc	ra,0x5
     a42:	dee080e7          	jalr	-530(ra) # 582c <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     a46:	862a                	mv	a2,a0
     a48:	85d6                	mv	a1,s5
     a4a:	00005517          	auipc	a0,0x5
     a4e:	6ee50513          	addi	a0,a0,1774 # 6138 <malloc+0x4be>
     a52:	00005097          	auipc	ra,0x5
     a56:	16a080e7          	jalr	362(ra) # 5bbc <printf>
    exit(1);
     a5a:	4505                	li	a0,1
     a5c:	00005097          	auipc	ra,0x5
     a60:	dd0080e7          	jalr	-560(ra) # 582c <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     a64:	862a                	mv	a2,a0
     a66:	85d6                	mv	a1,s5
     a68:	00005517          	auipc	a0,0x5
     a6c:	6f050513          	addi	a0,a0,1776 # 6158 <malloc+0x4de>
     a70:	00005097          	auipc	ra,0x5
     a74:	14c080e7          	jalr	332(ra) # 5bbc <printf>
    exit(1);
     a78:	4505                	li	a0,1
     a7a:	00005097          	auipc	ra,0x5
     a7e:	db2080e7          	jalr	-590(ra) # 582c <exit>

0000000000000a82 <truncate2>:
{
     a82:	7179                	addi	sp,sp,-48
     a84:	f406                	sd	ra,40(sp)
     a86:	f022                	sd	s0,32(sp)
     a88:	ec26                	sd	s1,24(sp)
     a8a:	e84a                	sd	s2,16(sp)
     a8c:	e44e                	sd	s3,8(sp)
     a8e:	1800                	addi	s0,sp,48
     a90:	89aa                	mv	s3,a0
  unlink("truncfile");
     a92:	00005517          	auipc	a0,0x5
     a96:	62650513          	addi	a0,a0,1574 # 60b8 <malloc+0x43e>
     a9a:	00005097          	auipc	ra,0x5
     a9e:	de2080e7          	jalr	-542(ra) # 587c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     aa2:	60100593          	li	a1,1537
     aa6:	00005517          	auipc	a0,0x5
     aaa:	61250513          	addi	a0,a0,1554 # 60b8 <malloc+0x43e>
     aae:	00005097          	auipc	ra,0x5
     ab2:	dbe080e7          	jalr	-578(ra) # 586c <open>
     ab6:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     ab8:	4611                	li	a2,4
     aba:	00005597          	auipc	a1,0x5
     abe:	60e58593          	addi	a1,a1,1550 # 60c8 <malloc+0x44e>
     ac2:	00005097          	auipc	ra,0x5
     ac6:	d8a080e7          	jalr	-630(ra) # 584c <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     aca:	40100593          	li	a1,1025
     ace:	00005517          	auipc	a0,0x5
     ad2:	5ea50513          	addi	a0,a0,1514 # 60b8 <malloc+0x43e>
     ad6:	00005097          	auipc	ra,0x5
     ada:	d96080e7          	jalr	-618(ra) # 586c <open>
     ade:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     ae0:	4605                	li	a2,1
     ae2:	00005597          	auipc	a1,0x5
     ae6:	3c658593          	addi	a1,a1,966 # 5ea8 <malloc+0x22e>
     aea:	8526                	mv	a0,s1
     aec:	00005097          	auipc	ra,0x5
     af0:	d60080e7          	jalr	-672(ra) # 584c <write>
  if(n != -1){
     af4:	57fd                	li	a5,-1
     af6:	02f51b63          	bne	a0,a5,b2c <truncate2+0xaa>
  unlink("truncfile");
     afa:	00005517          	auipc	a0,0x5
     afe:	5be50513          	addi	a0,a0,1470 # 60b8 <malloc+0x43e>
     b02:	00005097          	auipc	ra,0x5
     b06:	d7a080e7          	jalr	-646(ra) # 587c <unlink>
  close(fd1);
     b0a:	8526                	mv	a0,s1
     b0c:	00005097          	auipc	ra,0x5
     b10:	d48080e7          	jalr	-696(ra) # 5854 <close>
  close(fd2);
     b14:	854a                	mv	a0,s2
     b16:	00005097          	auipc	ra,0x5
     b1a:	d3e080e7          	jalr	-706(ra) # 5854 <close>
}
     b1e:	70a2                	ld	ra,40(sp)
     b20:	7402                	ld	s0,32(sp)
     b22:	64e2                	ld	s1,24(sp)
     b24:	6942                	ld	s2,16(sp)
     b26:	69a2                	ld	s3,8(sp)
     b28:	6145                	addi	sp,sp,48
     b2a:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     b2c:	862a                	mv	a2,a0
     b2e:	85ce                	mv	a1,s3
     b30:	00005517          	auipc	a0,0x5
     b34:	64850513          	addi	a0,a0,1608 # 6178 <malloc+0x4fe>
     b38:	00005097          	auipc	ra,0x5
     b3c:	084080e7          	jalr	132(ra) # 5bbc <printf>
    exit(1);
     b40:	4505                	li	a0,1
     b42:	00005097          	auipc	ra,0x5
     b46:	cea080e7          	jalr	-790(ra) # 582c <exit>

0000000000000b4a <truncate3>:
{
     b4a:	7159                	addi	sp,sp,-112
     b4c:	f486                	sd	ra,104(sp)
     b4e:	f0a2                	sd	s0,96(sp)
     b50:	eca6                	sd	s1,88(sp)
     b52:	e8ca                	sd	s2,80(sp)
     b54:	e4ce                	sd	s3,72(sp)
     b56:	e0d2                	sd	s4,64(sp)
     b58:	fc56                	sd	s5,56(sp)
     b5a:	1880                	addi	s0,sp,112
     b5c:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
     b5e:	60100593          	li	a1,1537
     b62:	00005517          	auipc	a0,0x5
     b66:	55650513          	addi	a0,a0,1366 # 60b8 <malloc+0x43e>
     b6a:	00005097          	auipc	ra,0x5
     b6e:	d02080e7          	jalr	-766(ra) # 586c <open>
     b72:	00005097          	auipc	ra,0x5
     b76:	ce2080e7          	jalr	-798(ra) # 5854 <close>
  pid = fork();
     b7a:	00005097          	auipc	ra,0x5
     b7e:	caa080e7          	jalr	-854(ra) # 5824 <fork>
  if(pid < 0){
     b82:	08054063          	bltz	a0,c02 <truncate3+0xb8>
  if(pid == 0){
     b86:	e969                	bnez	a0,c58 <truncate3+0x10e>
     b88:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
     b8c:	00005a17          	auipc	s4,0x5
     b90:	52ca0a13          	addi	s4,s4,1324 # 60b8 <malloc+0x43e>
      int n = write(fd, "1234567890", 10);
     b94:	00005a97          	auipc	s5,0x5
     b98:	63ca8a93          	addi	s5,s5,1596 # 61d0 <malloc+0x556>
      int fd = open("truncfile", O_WRONLY);
     b9c:	4585                	li	a1,1
     b9e:	8552                	mv	a0,s4
     ba0:	00005097          	auipc	ra,0x5
     ba4:	ccc080e7          	jalr	-820(ra) # 586c <open>
     ba8:	84aa                	mv	s1,a0
      if(fd < 0){
     baa:	06054a63          	bltz	a0,c1e <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
     bae:	4629                	li	a2,10
     bb0:	85d6                	mv	a1,s5
     bb2:	00005097          	auipc	ra,0x5
     bb6:	c9a080e7          	jalr	-870(ra) # 584c <write>
      if(n != 10){
     bba:	47a9                	li	a5,10
     bbc:	06f51f63          	bne	a0,a5,c3a <truncate3+0xf0>
      close(fd);
     bc0:	8526                	mv	a0,s1
     bc2:	00005097          	auipc	ra,0x5
     bc6:	c92080e7          	jalr	-878(ra) # 5854 <close>
      fd = open("truncfile", O_RDONLY);
     bca:	4581                	li	a1,0
     bcc:	8552                	mv	a0,s4
     bce:	00005097          	auipc	ra,0x5
     bd2:	c9e080e7          	jalr	-866(ra) # 586c <open>
     bd6:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
     bd8:	02000613          	li	a2,32
     bdc:	f9840593          	addi	a1,s0,-104
     be0:	00005097          	auipc	ra,0x5
     be4:	c64080e7          	jalr	-924(ra) # 5844 <read>
      close(fd);
     be8:	8526                	mv	a0,s1
     bea:	00005097          	auipc	ra,0x5
     bee:	c6a080e7          	jalr	-918(ra) # 5854 <close>
    for(int i = 0; i < 100; i++){
     bf2:	39fd                	addiw	s3,s3,-1
     bf4:	fa0994e3          	bnez	s3,b9c <truncate3+0x52>
    exit(0);
     bf8:	4501                	li	a0,0
     bfa:	00005097          	auipc	ra,0x5
     bfe:	c32080e7          	jalr	-974(ra) # 582c <exit>
    printf("%s: fork failed\n", s);
     c02:	85ca                	mv	a1,s2
     c04:	00005517          	auipc	a0,0x5
     c08:	59c50513          	addi	a0,a0,1436 # 61a0 <malloc+0x526>
     c0c:	00005097          	auipc	ra,0x5
     c10:	fb0080e7          	jalr	-80(ra) # 5bbc <printf>
    exit(1);
     c14:	4505                	li	a0,1
     c16:	00005097          	auipc	ra,0x5
     c1a:	c16080e7          	jalr	-1002(ra) # 582c <exit>
        printf("%s: open failed\n", s);
     c1e:	85ca                	mv	a1,s2
     c20:	00005517          	auipc	a0,0x5
     c24:	59850513          	addi	a0,a0,1432 # 61b8 <malloc+0x53e>
     c28:	00005097          	auipc	ra,0x5
     c2c:	f94080e7          	jalr	-108(ra) # 5bbc <printf>
        exit(1);
     c30:	4505                	li	a0,1
     c32:	00005097          	auipc	ra,0x5
     c36:	bfa080e7          	jalr	-1030(ra) # 582c <exit>
        printf("%s: write got %d, expected 10\n", s, n);
     c3a:	862a                	mv	a2,a0
     c3c:	85ca                	mv	a1,s2
     c3e:	00005517          	auipc	a0,0x5
     c42:	5a250513          	addi	a0,a0,1442 # 61e0 <malloc+0x566>
     c46:	00005097          	auipc	ra,0x5
     c4a:	f76080e7          	jalr	-138(ra) # 5bbc <printf>
        exit(1);
     c4e:	4505                	li	a0,1
     c50:	00005097          	auipc	ra,0x5
     c54:	bdc080e7          	jalr	-1060(ra) # 582c <exit>
     c58:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     c5c:	00005a17          	auipc	s4,0x5
     c60:	45ca0a13          	addi	s4,s4,1116 # 60b8 <malloc+0x43e>
    int n = write(fd, "xxx", 3);
     c64:	00005a97          	auipc	s5,0x5
     c68:	59ca8a93          	addi	s5,s5,1436 # 6200 <malloc+0x586>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     c6c:	60100593          	li	a1,1537
     c70:	8552                	mv	a0,s4
     c72:	00005097          	auipc	ra,0x5
     c76:	bfa080e7          	jalr	-1030(ra) # 586c <open>
     c7a:	84aa                	mv	s1,a0
    if(fd < 0){
     c7c:	04054763          	bltz	a0,cca <truncate3+0x180>
    int n = write(fd, "xxx", 3);
     c80:	460d                	li	a2,3
     c82:	85d6                	mv	a1,s5
     c84:	00005097          	auipc	ra,0x5
     c88:	bc8080e7          	jalr	-1080(ra) # 584c <write>
    if(n != 3){
     c8c:	478d                	li	a5,3
     c8e:	04f51c63          	bne	a0,a5,ce6 <truncate3+0x19c>
    close(fd);
     c92:	8526                	mv	a0,s1
     c94:	00005097          	auipc	ra,0x5
     c98:	bc0080e7          	jalr	-1088(ra) # 5854 <close>
  for(int i = 0; i < 150; i++){
     c9c:	39fd                	addiw	s3,s3,-1
     c9e:	fc0997e3          	bnez	s3,c6c <truncate3+0x122>
  wait(&xstatus);
     ca2:	fbc40513          	addi	a0,s0,-68
     ca6:	00005097          	auipc	ra,0x5
     caa:	b8e080e7          	jalr	-1138(ra) # 5834 <wait>
  unlink("truncfile");
     cae:	00005517          	auipc	a0,0x5
     cb2:	40a50513          	addi	a0,a0,1034 # 60b8 <malloc+0x43e>
     cb6:	00005097          	auipc	ra,0x5
     cba:	bc6080e7          	jalr	-1082(ra) # 587c <unlink>
  exit(xstatus);
     cbe:	fbc42503          	lw	a0,-68(s0)
     cc2:	00005097          	auipc	ra,0x5
     cc6:	b6a080e7          	jalr	-1174(ra) # 582c <exit>
      printf("%s: open failed\n", s);
     cca:	85ca                	mv	a1,s2
     ccc:	00005517          	auipc	a0,0x5
     cd0:	4ec50513          	addi	a0,a0,1260 # 61b8 <malloc+0x53e>
     cd4:	00005097          	auipc	ra,0x5
     cd8:	ee8080e7          	jalr	-280(ra) # 5bbc <printf>
      exit(1);
     cdc:	4505                	li	a0,1
     cde:	00005097          	auipc	ra,0x5
     ce2:	b4e080e7          	jalr	-1202(ra) # 582c <exit>
      printf("%s: write got %d, expected 3\n", s, n);
     ce6:	862a                	mv	a2,a0
     ce8:	85ca                	mv	a1,s2
     cea:	00005517          	auipc	a0,0x5
     cee:	51e50513          	addi	a0,a0,1310 # 6208 <malloc+0x58e>
     cf2:	00005097          	auipc	ra,0x5
     cf6:	eca080e7          	jalr	-310(ra) # 5bbc <printf>
      exit(1);
     cfa:	4505                	li	a0,1
     cfc:	00005097          	auipc	ra,0x5
     d00:	b30080e7          	jalr	-1232(ra) # 582c <exit>

0000000000000d04 <iputtest>:
{
     d04:	1101                	addi	sp,sp,-32
     d06:	ec06                	sd	ra,24(sp)
     d08:	e822                	sd	s0,16(sp)
     d0a:	e426                	sd	s1,8(sp)
     d0c:	1000                	addi	s0,sp,32
     d0e:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
     d10:	00005517          	auipc	a0,0x5
     d14:	51850513          	addi	a0,a0,1304 # 6228 <malloc+0x5ae>
     d18:	00005097          	auipc	ra,0x5
     d1c:	b7c080e7          	jalr	-1156(ra) # 5894 <mkdir>
     d20:	04054563          	bltz	a0,d6a <iputtest+0x66>
  if(chdir("iputdir") < 0){
     d24:	00005517          	auipc	a0,0x5
     d28:	50450513          	addi	a0,a0,1284 # 6228 <malloc+0x5ae>
     d2c:	00005097          	auipc	ra,0x5
     d30:	b70080e7          	jalr	-1168(ra) # 589c <chdir>
     d34:	04054963          	bltz	a0,d86 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
     d38:	00005517          	auipc	a0,0x5
     d3c:	53050513          	addi	a0,a0,1328 # 6268 <malloc+0x5ee>
     d40:	00005097          	auipc	ra,0x5
     d44:	b3c080e7          	jalr	-1220(ra) # 587c <unlink>
     d48:	04054d63          	bltz	a0,da2 <iputtest+0x9e>
  if(chdir("/") < 0){
     d4c:	00005517          	auipc	a0,0x5
     d50:	54c50513          	addi	a0,a0,1356 # 6298 <malloc+0x61e>
     d54:	00005097          	auipc	ra,0x5
     d58:	b48080e7          	jalr	-1208(ra) # 589c <chdir>
     d5c:	06054163          	bltz	a0,dbe <iputtest+0xba>
}
     d60:	60e2                	ld	ra,24(sp)
     d62:	6442                	ld	s0,16(sp)
     d64:	64a2                	ld	s1,8(sp)
     d66:	6105                	addi	sp,sp,32
     d68:	8082                	ret
    printf("%s: mkdir failed\n", s);
     d6a:	85a6                	mv	a1,s1
     d6c:	00005517          	auipc	a0,0x5
     d70:	4c450513          	addi	a0,a0,1220 # 6230 <malloc+0x5b6>
     d74:	00005097          	auipc	ra,0x5
     d78:	e48080e7          	jalr	-440(ra) # 5bbc <printf>
    exit(1);
     d7c:	4505                	li	a0,1
     d7e:	00005097          	auipc	ra,0x5
     d82:	aae080e7          	jalr	-1362(ra) # 582c <exit>
    printf("%s: chdir iputdir failed\n", s);
     d86:	85a6                	mv	a1,s1
     d88:	00005517          	auipc	a0,0x5
     d8c:	4c050513          	addi	a0,a0,1216 # 6248 <malloc+0x5ce>
     d90:	00005097          	auipc	ra,0x5
     d94:	e2c080e7          	jalr	-468(ra) # 5bbc <printf>
    exit(1);
     d98:	4505                	li	a0,1
     d9a:	00005097          	auipc	ra,0x5
     d9e:	a92080e7          	jalr	-1390(ra) # 582c <exit>
    printf("%s: unlink ../iputdir failed\n", s);
     da2:	85a6                	mv	a1,s1
     da4:	00005517          	auipc	a0,0x5
     da8:	4d450513          	addi	a0,a0,1236 # 6278 <malloc+0x5fe>
     dac:	00005097          	auipc	ra,0x5
     db0:	e10080e7          	jalr	-496(ra) # 5bbc <printf>
    exit(1);
     db4:	4505                	li	a0,1
     db6:	00005097          	auipc	ra,0x5
     dba:	a76080e7          	jalr	-1418(ra) # 582c <exit>
    printf("%s: chdir / failed\n", s);
     dbe:	85a6                	mv	a1,s1
     dc0:	00005517          	auipc	a0,0x5
     dc4:	4e050513          	addi	a0,a0,1248 # 62a0 <malloc+0x626>
     dc8:	00005097          	auipc	ra,0x5
     dcc:	df4080e7          	jalr	-524(ra) # 5bbc <printf>
    exit(1);
     dd0:	4505                	li	a0,1
     dd2:	00005097          	auipc	ra,0x5
     dd6:	a5a080e7          	jalr	-1446(ra) # 582c <exit>

0000000000000dda <exitiputtest>:
{
     dda:	7179                	addi	sp,sp,-48
     ddc:	f406                	sd	ra,40(sp)
     dde:	f022                	sd	s0,32(sp)
     de0:	ec26                	sd	s1,24(sp)
     de2:	1800                	addi	s0,sp,48
     de4:	84aa                	mv	s1,a0
  pid = fork();
     de6:	00005097          	auipc	ra,0x5
     dea:	a3e080e7          	jalr	-1474(ra) # 5824 <fork>
  if(pid < 0){
     dee:	04054663          	bltz	a0,e3a <exitiputtest+0x60>
  if(pid == 0){
     df2:	ed45                	bnez	a0,eaa <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     df4:	00005517          	auipc	a0,0x5
     df8:	43450513          	addi	a0,a0,1076 # 6228 <malloc+0x5ae>
     dfc:	00005097          	auipc	ra,0x5
     e00:	a98080e7          	jalr	-1384(ra) # 5894 <mkdir>
     e04:	04054963          	bltz	a0,e56 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
     e08:	00005517          	auipc	a0,0x5
     e0c:	42050513          	addi	a0,a0,1056 # 6228 <malloc+0x5ae>
     e10:	00005097          	auipc	ra,0x5
     e14:	a8c080e7          	jalr	-1396(ra) # 589c <chdir>
     e18:	04054d63          	bltz	a0,e72 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
     e1c:	00005517          	auipc	a0,0x5
     e20:	44c50513          	addi	a0,a0,1100 # 6268 <malloc+0x5ee>
     e24:	00005097          	auipc	ra,0x5
     e28:	a58080e7          	jalr	-1448(ra) # 587c <unlink>
     e2c:	06054163          	bltz	a0,e8e <exitiputtest+0xb4>
    exit(0);
     e30:	4501                	li	a0,0
     e32:	00005097          	auipc	ra,0x5
     e36:	9fa080e7          	jalr	-1542(ra) # 582c <exit>
    printf("%s: fork failed\n", s);
     e3a:	85a6                	mv	a1,s1
     e3c:	00005517          	auipc	a0,0x5
     e40:	36450513          	addi	a0,a0,868 # 61a0 <malloc+0x526>
     e44:	00005097          	auipc	ra,0x5
     e48:	d78080e7          	jalr	-648(ra) # 5bbc <printf>
    exit(1);
     e4c:	4505                	li	a0,1
     e4e:	00005097          	auipc	ra,0x5
     e52:	9de080e7          	jalr	-1570(ra) # 582c <exit>
      printf("%s: mkdir failed\n", s);
     e56:	85a6                	mv	a1,s1
     e58:	00005517          	auipc	a0,0x5
     e5c:	3d850513          	addi	a0,a0,984 # 6230 <malloc+0x5b6>
     e60:	00005097          	auipc	ra,0x5
     e64:	d5c080e7          	jalr	-676(ra) # 5bbc <printf>
      exit(1);
     e68:	4505                	li	a0,1
     e6a:	00005097          	auipc	ra,0x5
     e6e:	9c2080e7          	jalr	-1598(ra) # 582c <exit>
      printf("%s: child chdir failed\n", s);
     e72:	85a6                	mv	a1,s1
     e74:	00005517          	auipc	a0,0x5
     e78:	44450513          	addi	a0,a0,1092 # 62b8 <malloc+0x63e>
     e7c:	00005097          	auipc	ra,0x5
     e80:	d40080e7          	jalr	-704(ra) # 5bbc <printf>
      exit(1);
     e84:	4505                	li	a0,1
     e86:	00005097          	auipc	ra,0x5
     e8a:	9a6080e7          	jalr	-1626(ra) # 582c <exit>
      printf("%s: unlink ../iputdir failed\n", s);
     e8e:	85a6                	mv	a1,s1
     e90:	00005517          	auipc	a0,0x5
     e94:	3e850513          	addi	a0,a0,1000 # 6278 <malloc+0x5fe>
     e98:	00005097          	auipc	ra,0x5
     e9c:	d24080e7          	jalr	-732(ra) # 5bbc <printf>
      exit(1);
     ea0:	4505                	li	a0,1
     ea2:	00005097          	auipc	ra,0x5
     ea6:	98a080e7          	jalr	-1654(ra) # 582c <exit>
  wait(&xstatus);
     eaa:	fdc40513          	addi	a0,s0,-36
     eae:	00005097          	auipc	ra,0x5
     eb2:	986080e7          	jalr	-1658(ra) # 5834 <wait>
  exit(xstatus);
     eb6:	fdc42503          	lw	a0,-36(s0)
     eba:	00005097          	auipc	ra,0x5
     ebe:	972080e7          	jalr	-1678(ra) # 582c <exit>

0000000000000ec2 <openiputtest>:
{
     ec2:	7179                	addi	sp,sp,-48
     ec4:	f406                	sd	ra,40(sp)
     ec6:	f022                	sd	s0,32(sp)
     ec8:	ec26                	sd	s1,24(sp)
     eca:	1800                	addi	s0,sp,48
     ecc:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
     ece:	00005517          	auipc	a0,0x5
     ed2:	40250513          	addi	a0,a0,1026 # 62d0 <malloc+0x656>
     ed6:	00005097          	auipc	ra,0x5
     eda:	9be080e7          	jalr	-1602(ra) # 5894 <mkdir>
     ede:	04054263          	bltz	a0,f22 <openiputtest+0x60>
  pid = fork();
     ee2:	00005097          	auipc	ra,0x5
     ee6:	942080e7          	jalr	-1726(ra) # 5824 <fork>
  if(pid < 0){
     eea:	04054a63          	bltz	a0,f3e <openiputtest+0x7c>
  if(pid == 0){
     eee:	e93d                	bnez	a0,f64 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
     ef0:	4589                	li	a1,2
     ef2:	00005517          	auipc	a0,0x5
     ef6:	3de50513          	addi	a0,a0,990 # 62d0 <malloc+0x656>
     efa:	00005097          	auipc	ra,0x5
     efe:	972080e7          	jalr	-1678(ra) # 586c <open>
    if(fd >= 0){
     f02:	04054c63          	bltz	a0,f5a <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
     f06:	85a6                	mv	a1,s1
     f08:	00005517          	auipc	a0,0x5
     f0c:	3e850513          	addi	a0,a0,1000 # 62f0 <malloc+0x676>
     f10:	00005097          	auipc	ra,0x5
     f14:	cac080e7          	jalr	-852(ra) # 5bbc <printf>
      exit(1);
     f18:	4505                	li	a0,1
     f1a:	00005097          	auipc	ra,0x5
     f1e:	912080e7          	jalr	-1774(ra) # 582c <exit>
    printf("%s: mkdir oidir failed\n", s);
     f22:	85a6                	mv	a1,s1
     f24:	00005517          	auipc	a0,0x5
     f28:	3b450513          	addi	a0,a0,948 # 62d8 <malloc+0x65e>
     f2c:	00005097          	auipc	ra,0x5
     f30:	c90080e7          	jalr	-880(ra) # 5bbc <printf>
    exit(1);
     f34:	4505                	li	a0,1
     f36:	00005097          	auipc	ra,0x5
     f3a:	8f6080e7          	jalr	-1802(ra) # 582c <exit>
    printf("%s: fork failed\n", s);
     f3e:	85a6                	mv	a1,s1
     f40:	00005517          	auipc	a0,0x5
     f44:	26050513          	addi	a0,a0,608 # 61a0 <malloc+0x526>
     f48:	00005097          	auipc	ra,0x5
     f4c:	c74080e7          	jalr	-908(ra) # 5bbc <printf>
    exit(1);
     f50:	4505                	li	a0,1
     f52:	00005097          	auipc	ra,0x5
     f56:	8da080e7          	jalr	-1830(ra) # 582c <exit>
    exit(0);
     f5a:	4501                	li	a0,0
     f5c:	00005097          	auipc	ra,0x5
     f60:	8d0080e7          	jalr	-1840(ra) # 582c <exit>
  sleep(1);
     f64:	4505                	li	a0,1
     f66:	00005097          	auipc	ra,0x5
     f6a:	956080e7          	jalr	-1706(ra) # 58bc <sleep>
  if(unlink("oidir") != 0){
     f6e:	00005517          	auipc	a0,0x5
     f72:	36250513          	addi	a0,a0,866 # 62d0 <malloc+0x656>
     f76:	00005097          	auipc	ra,0x5
     f7a:	906080e7          	jalr	-1786(ra) # 587c <unlink>
     f7e:	cd19                	beqz	a0,f9c <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
     f80:	85a6                	mv	a1,s1
     f82:	00005517          	auipc	a0,0x5
     f86:	39650513          	addi	a0,a0,918 # 6318 <malloc+0x69e>
     f8a:	00005097          	auipc	ra,0x5
     f8e:	c32080e7          	jalr	-974(ra) # 5bbc <printf>
    exit(1);
     f92:	4505                	li	a0,1
     f94:	00005097          	auipc	ra,0x5
     f98:	898080e7          	jalr	-1896(ra) # 582c <exit>
  wait(&xstatus);
     f9c:	fdc40513          	addi	a0,s0,-36
     fa0:	00005097          	auipc	ra,0x5
     fa4:	894080e7          	jalr	-1900(ra) # 5834 <wait>
  exit(xstatus);
     fa8:	fdc42503          	lw	a0,-36(s0)
     fac:	00005097          	auipc	ra,0x5
     fb0:	880080e7          	jalr	-1920(ra) # 582c <exit>

0000000000000fb4 <opentest>:
{
     fb4:	1101                	addi	sp,sp,-32
     fb6:	ec06                	sd	ra,24(sp)
     fb8:	e822                	sd	s0,16(sp)
     fba:	e426                	sd	s1,8(sp)
     fbc:	1000                	addi	s0,sp,32
     fbe:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     fc0:	4581                	li	a1,0
     fc2:	00005517          	auipc	a0,0x5
     fc6:	f3650513          	addi	a0,a0,-202 # 5ef8 <malloc+0x27e>
     fca:	00005097          	auipc	ra,0x5
     fce:	8a2080e7          	jalr	-1886(ra) # 586c <open>
  if(fd < 0){
     fd2:	02054663          	bltz	a0,ffe <opentest+0x4a>
  close(fd);
     fd6:	00005097          	auipc	ra,0x5
     fda:	87e080e7          	jalr	-1922(ra) # 5854 <close>
  fd = open("doesnotexist", 0);
     fde:	4581                	li	a1,0
     fe0:	00005517          	auipc	a0,0x5
     fe4:	36850513          	addi	a0,a0,872 # 6348 <malloc+0x6ce>
     fe8:	00005097          	auipc	ra,0x5
     fec:	884080e7          	jalr	-1916(ra) # 586c <open>
  if(fd >= 0){
     ff0:	02055563          	bgez	a0,101a <opentest+0x66>
}
     ff4:	60e2                	ld	ra,24(sp)
     ff6:	6442                	ld	s0,16(sp)
     ff8:	64a2                	ld	s1,8(sp)
     ffa:	6105                	addi	sp,sp,32
     ffc:	8082                	ret
    printf("%s: open echo failed!\n", s);
     ffe:	85a6                	mv	a1,s1
    1000:	00005517          	auipc	a0,0x5
    1004:	33050513          	addi	a0,a0,816 # 6330 <malloc+0x6b6>
    1008:	00005097          	auipc	ra,0x5
    100c:	bb4080e7          	jalr	-1100(ra) # 5bbc <printf>
    exit(1);
    1010:	4505                	li	a0,1
    1012:	00005097          	auipc	ra,0x5
    1016:	81a080e7          	jalr	-2022(ra) # 582c <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
    101a:	85a6                	mv	a1,s1
    101c:	00005517          	auipc	a0,0x5
    1020:	33c50513          	addi	a0,a0,828 # 6358 <malloc+0x6de>
    1024:	00005097          	auipc	ra,0x5
    1028:	b98080e7          	jalr	-1128(ra) # 5bbc <printf>
    exit(1);
    102c:	4505                	li	a0,1
    102e:	00004097          	auipc	ra,0x4
    1032:	7fe080e7          	jalr	2046(ra) # 582c <exit>

0000000000001036 <writetest>:
{
    1036:	7139                	addi	sp,sp,-64
    1038:	fc06                	sd	ra,56(sp)
    103a:	f822                	sd	s0,48(sp)
    103c:	f426                	sd	s1,40(sp)
    103e:	f04a                	sd	s2,32(sp)
    1040:	ec4e                	sd	s3,24(sp)
    1042:	e852                	sd	s4,16(sp)
    1044:	e456                	sd	s5,8(sp)
    1046:	e05a                	sd	s6,0(sp)
    1048:	0080                	addi	s0,sp,64
    104a:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
    104c:	20200593          	li	a1,514
    1050:	00005517          	auipc	a0,0x5
    1054:	33050513          	addi	a0,a0,816 # 6380 <malloc+0x706>
    1058:	00005097          	auipc	ra,0x5
    105c:	814080e7          	jalr	-2028(ra) # 586c <open>
  if(fd < 0){
    1060:	0a054d63          	bltz	a0,111a <writetest+0xe4>
    1064:	892a                	mv	s2,a0
    1066:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    1068:	00005997          	auipc	s3,0x5
    106c:	34098993          	addi	s3,s3,832 # 63a8 <malloc+0x72e>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    1070:	00005a97          	auipc	s5,0x5
    1074:	370a8a93          	addi	s5,s5,880 # 63e0 <malloc+0x766>
  for(i = 0; i < N; i++){
    1078:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    107c:	4629                	li	a2,10
    107e:	85ce                	mv	a1,s3
    1080:	854a                	mv	a0,s2
    1082:	00004097          	auipc	ra,0x4
    1086:	7ca080e7          	jalr	1994(ra) # 584c <write>
    108a:	47a9                	li	a5,10
    108c:	0af51563          	bne	a0,a5,1136 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    1090:	4629                	li	a2,10
    1092:	85d6                	mv	a1,s5
    1094:	854a                	mv	a0,s2
    1096:	00004097          	auipc	ra,0x4
    109a:	7b6080e7          	jalr	1974(ra) # 584c <write>
    109e:	47a9                	li	a5,10
    10a0:	0af51a63          	bne	a0,a5,1154 <writetest+0x11e>
  for(i = 0; i < N; i++){
    10a4:	2485                	addiw	s1,s1,1
    10a6:	fd449be3          	bne	s1,s4,107c <writetest+0x46>
  close(fd);
    10aa:	854a                	mv	a0,s2
    10ac:	00004097          	auipc	ra,0x4
    10b0:	7a8080e7          	jalr	1960(ra) # 5854 <close>
  fd = open("small", O_RDONLY);
    10b4:	4581                	li	a1,0
    10b6:	00005517          	auipc	a0,0x5
    10ba:	2ca50513          	addi	a0,a0,714 # 6380 <malloc+0x706>
    10be:	00004097          	auipc	ra,0x4
    10c2:	7ae080e7          	jalr	1966(ra) # 586c <open>
    10c6:	84aa                	mv	s1,a0
  if(fd < 0){
    10c8:	0a054563          	bltz	a0,1172 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
    10cc:	7d000613          	li	a2,2000
    10d0:	0000a597          	auipc	a1,0xa
    10d4:	60858593          	addi	a1,a1,1544 # b6d8 <buf>
    10d8:	00004097          	auipc	ra,0x4
    10dc:	76c080e7          	jalr	1900(ra) # 5844 <read>
  if(i != N*SZ*2){
    10e0:	7d000793          	li	a5,2000
    10e4:	0af51563          	bne	a0,a5,118e <writetest+0x158>
  close(fd);
    10e8:	8526                	mv	a0,s1
    10ea:	00004097          	auipc	ra,0x4
    10ee:	76a080e7          	jalr	1898(ra) # 5854 <close>
  if(unlink("small") < 0){
    10f2:	00005517          	auipc	a0,0x5
    10f6:	28e50513          	addi	a0,a0,654 # 6380 <malloc+0x706>
    10fa:	00004097          	auipc	ra,0x4
    10fe:	782080e7          	jalr	1922(ra) # 587c <unlink>
    1102:	0a054463          	bltz	a0,11aa <writetest+0x174>
}
    1106:	70e2                	ld	ra,56(sp)
    1108:	7442                	ld	s0,48(sp)
    110a:	74a2                	ld	s1,40(sp)
    110c:	7902                	ld	s2,32(sp)
    110e:	69e2                	ld	s3,24(sp)
    1110:	6a42                	ld	s4,16(sp)
    1112:	6aa2                	ld	s5,8(sp)
    1114:	6b02                	ld	s6,0(sp)
    1116:	6121                	addi	sp,sp,64
    1118:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
    111a:	85da                	mv	a1,s6
    111c:	00005517          	auipc	a0,0x5
    1120:	26c50513          	addi	a0,a0,620 # 6388 <malloc+0x70e>
    1124:	00005097          	auipc	ra,0x5
    1128:	a98080e7          	jalr	-1384(ra) # 5bbc <printf>
    exit(1);
    112c:	4505                	li	a0,1
    112e:	00004097          	auipc	ra,0x4
    1132:	6fe080e7          	jalr	1790(ra) # 582c <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
    1136:	8626                	mv	a2,s1
    1138:	85da                	mv	a1,s6
    113a:	00005517          	auipc	a0,0x5
    113e:	27e50513          	addi	a0,a0,638 # 63b8 <malloc+0x73e>
    1142:	00005097          	auipc	ra,0x5
    1146:	a7a080e7          	jalr	-1414(ra) # 5bbc <printf>
      exit(1);
    114a:	4505                	li	a0,1
    114c:	00004097          	auipc	ra,0x4
    1150:	6e0080e7          	jalr	1760(ra) # 582c <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
    1154:	8626                	mv	a2,s1
    1156:	85da                	mv	a1,s6
    1158:	00005517          	auipc	a0,0x5
    115c:	29850513          	addi	a0,a0,664 # 63f0 <malloc+0x776>
    1160:	00005097          	auipc	ra,0x5
    1164:	a5c080e7          	jalr	-1444(ra) # 5bbc <printf>
      exit(1);
    1168:	4505                	li	a0,1
    116a:	00004097          	auipc	ra,0x4
    116e:	6c2080e7          	jalr	1730(ra) # 582c <exit>
    printf("%s: error: open small failed!\n", s);
    1172:	85da                	mv	a1,s6
    1174:	00005517          	auipc	a0,0x5
    1178:	2a450513          	addi	a0,a0,676 # 6418 <malloc+0x79e>
    117c:	00005097          	auipc	ra,0x5
    1180:	a40080e7          	jalr	-1472(ra) # 5bbc <printf>
    exit(1);
    1184:	4505                	li	a0,1
    1186:	00004097          	auipc	ra,0x4
    118a:	6a6080e7          	jalr	1702(ra) # 582c <exit>
    printf("%s: read failed\n", s);
    118e:	85da                	mv	a1,s6
    1190:	00005517          	auipc	a0,0x5
    1194:	2a850513          	addi	a0,a0,680 # 6438 <malloc+0x7be>
    1198:	00005097          	auipc	ra,0x5
    119c:	a24080e7          	jalr	-1500(ra) # 5bbc <printf>
    exit(1);
    11a0:	4505                	li	a0,1
    11a2:	00004097          	auipc	ra,0x4
    11a6:	68a080e7          	jalr	1674(ra) # 582c <exit>
    printf("%s: unlink small failed\n", s);
    11aa:	85da                	mv	a1,s6
    11ac:	00005517          	auipc	a0,0x5
    11b0:	2a450513          	addi	a0,a0,676 # 6450 <malloc+0x7d6>
    11b4:	00005097          	auipc	ra,0x5
    11b8:	a08080e7          	jalr	-1528(ra) # 5bbc <printf>
    exit(1);
    11bc:	4505                	li	a0,1
    11be:	00004097          	auipc	ra,0x4
    11c2:	66e080e7          	jalr	1646(ra) # 582c <exit>

00000000000011c6 <writebig>:
{
    11c6:	7139                	addi	sp,sp,-64
    11c8:	fc06                	sd	ra,56(sp)
    11ca:	f822                	sd	s0,48(sp)
    11cc:	f426                	sd	s1,40(sp)
    11ce:	f04a                	sd	s2,32(sp)
    11d0:	ec4e                	sd	s3,24(sp)
    11d2:	e852                	sd	s4,16(sp)
    11d4:	e456                	sd	s5,8(sp)
    11d6:	0080                	addi	s0,sp,64
    11d8:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
    11da:	20200593          	li	a1,514
    11de:	00005517          	auipc	a0,0x5
    11e2:	29250513          	addi	a0,a0,658 # 6470 <malloc+0x7f6>
    11e6:	00004097          	auipc	ra,0x4
    11ea:	686080e7          	jalr	1670(ra) # 586c <open>
    11ee:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
    11f0:	4481                	li	s1,0
    ((int*)buf)[0] = i;
    11f2:	0000a917          	auipc	s2,0xa
    11f6:	4e690913          	addi	s2,s2,1254 # b6d8 <buf>
  for(i = 0; i < MAXFILE; i++){
    11fa:	10c00a13          	li	s4,268
  if(fd < 0){
    11fe:	06054c63          	bltz	a0,1276 <writebig+0xb0>
    ((int*)buf)[0] = i;
    1202:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
    1206:	40000613          	li	a2,1024
    120a:	85ca                	mv	a1,s2
    120c:	854e                	mv	a0,s3
    120e:	00004097          	auipc	ra,0x4
    1212:	63e080e7          	jalr	1598(ra) # 584c <write>
    1216:	40000793          	li	a5,1024
    121a:	06f51c63          	bne	a0,a5,1292 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
    121e:	2485                	addiw	s1,s1,1
    1220:	ff4491e3          	bne	s1,s4,1202 <writebig+0x3c>
  close(fd);
    1224:	854e                	mv	a0,s3
    1226:	00004097          	auipc	ra,0x4
    122a:	62e080e7          	jalr	1582(ra) # 5854 <close>
  fd = open("big", O_RDONLY);
    122e:	4581                	li	a1,0
    1230:	00005517          	auipc	a0,0x5
    1234:	24050513          	addi	a0,a0,576 # 6470 <malloc+0x7f6>
    1238:	00004097          	auipc	ra,0x4
    123c:	634080e7          	jalr	1588(ra) # 586c <open>
    1240:	89aa                	mv	s3,a0
  n = 0;
    1242:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
    1244:	0000a917          	auipc	s2,0xa
    1248:	49490913          	addi	s2,s2,1172 # b6d8 <buf>
  if(fd < 0){
    124c:	06054263          	bltz	a0,12b0 <writebig+0xea>
    i = read(fd, buf, BSIZE);
    1250:	40000613          	li	a2,1024
    1254:	85ca                	mv	a1,s2
    1256:	854e                	mv	a0,s3
    1258:	00004097          	auipc	ra,0x4
    125c:	5ec080e7          	jalr	1516(ra) # 5844 <read>
    if(i == 0){
    1260:	c535                	beqz	a0,12cc <writebig+0x106>
    } else if(i != BSIZE){
    1262:	40000793          	li	a5,1024
    1266:	0af51f63          	bne	a0,a5,1324 <writebig+0x15e>
    if(((int*)buf)[0] != n){
    126a:	00092683          	lw	a3,0(s2)
    126e:	0c969a63          	bne	a3,s1,1342 <writebig+0x17c>
    n++;
    1272:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
    1274:	bff1                	j	1250 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
    1276:	85d6                	mv	a1,s5
    1278:	00005517          	auipc	a0,0x5
    127c:	20050513          	addi	a0,a0,512 # 6478 <malloc+0x7fe>
    1280:	00005097          	auipc	ra,0x5
    1284:	93c080e7          	jalr	-1732(ra) # 5bbc <printf>
    exit(1);
    1288:	4505                	li	a0,1
    128a:	00004097          	auipc	ra,0x4
    128e:	5a2080e7          	jalr	1442(ra) # 582c <exit>
      printf("%s: error: write big file failed\n", s, i);
    1292:	8626                	mv	a2,s1
    1294:	85d6                	mv	a1,s5
    1296:	00005517          	auipc	a0,0x5
    129a:	20250513          	addi	a0,a0,514 # 6498 <malloc+0x81e>
    129e:	00005097          	auipc	ra,0x5
    12a2:	91e080e7          	jalr	-1762(ra) # 5bbc <printf>
      exit(1);
    12a6:	4505                	li	a0,1
    12a8:	00004097          	auipc	ra,0x4
    12ac:	584080e7          	jalr	1412(ra) # 582c <exit>
    printf("%s: error: open big failed!\n", s);
    12b0:	85d6                	mv	a1,s5
    12b2:	00005517          	auipc	a0,0x5
    12b6:	20e50513          	addi	a0,a0,526 # 64c0 <malloc+0x846>
    12ba:	00005097          	auipc	ra,0x5
    12be:	902080e7          	jalr	-1790(ra) # 5bbc <printf>
    exit(1);
    12c2:	4505                	li	a0,1
    12c4:	00004097          	auipc	ra,0x4
    12c8:	568080e7          	jalr	1384(ra) # 582c <exit>
      if(n == MAXFILE - 1){
    12cc:	10b00793          	li	a5,267
    12d0:	02f48a63          	beq	s1,a5,1304 <writebig+0x13e>
  close(fd);
    12d4:	854e                	mv	a0,s3
    12d6:	00004097          	auipc	ra,0x4
    12da:	57e080e7          	jalr	1406(ra) # 5854 <close>
  if(unlink("big") < 0){
    12de:	00005517          	auipc	a0,0x5
    12e2:	19250513          	addi	a0,a0,402 # 6470 <malloc+0x7f6>
    12e6:	00004097          	auipc	ra,0x4
    12ea:	596080e7          	jalr	1430(ra) # 587c <unlink>
    12ee:	06054963          	bltz	a0,1360 <writebig+0x19a>
}
    12f2:	70e2                	ld	ra,56(sp)
    12f4:	7442                	ld	s0,48(sp)
    12f6:	74a2                	ld	s1,40(sp)
    12f8:	7902                	ld	s2,32(sp)
    12fa:	69e2                	ld	s3,24(sp)
    12fc:	6a42                	ld	s4,16(sp)
    12fe:	6aa2                	ld	s5,8(sp)
    1300:	6121                	addi	sp,sp,64
    1302:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
    1304:	10b00613          	li	a2,267
    1308:	85d6                	mv	a1,s5
    130a:	00005517          	auipc	a0,0x5
    130e:	1d650513          	addi	a0,a0,470 # 64e0 <malloc+0x866>
    1312:	00005097          	auipc	ra,0x5
    1316:	8aa080e7          	jalr	-1878(ra) # 5bbc <printf>
        exit(1);
    131a:	4505                	li	a0,1
    131c:	00004097          	auipc	ra,0x4
    1320:	510080e7          	jalr	1296(ra) # 582c <exit>
      printf("%s: read failed %d\n", s, i);
    1324:	862a                	mv	a2,a0
    1326:	85d6                	mv	a1,s5
    1328:	00005517          	auipc	a0,0x5
    132c:	1e050513          	addi	a0,a0,480 # 6508 <malloc+0x88e>
    1330:	00005097          	auipc	ra,0x5
    1334:	88c080e7          	jalr	-1908(ra) # 5bbc <printf>
      exit(1);
    1338:	4505                	li	a0,1
    133a:	00004097          	auipc	ra,0x4
    133e:	4f2080e7          	jalr	1266(ra) # 582c <exit>
      printf("%s: read content of block %d is %d\n", s,
    1342:	8626                	mv	a2,s1
    1344:	85d6                	mv	a1,s5
    1346:	00005517          	auipc	a0,0x5
    134a:	1da50513          	addi	a0,a0,474 # 6520 <malloc+0x8a6>
    134e:	00005097          	auipc	ra,0x5
    1352:	86e080e7          	jalr	-1938(ra) # 5bbc <printf>
      exit(1);
    1356:	4505                	li	a0,1
    1358:	00004097          	auipc	ra,0x4
    135c:	4d4080e7          	jalr	1236(ra) # 582c <exit>
    printf("%s: unlink big failed\n", s);
    1360:	85d6                	mv	a1,s5
    1362:	00005517          	auipc	a0,0x5
    1366:	1e650513          	addi	a0,a0,486 # 6548 <malloc+0x8ce>
    136a:	00005097          	auipc	ra,0x5
    136e:	852080e7          	jalr	-1966(ra) # 5bbc <printf>
    exit(1);
    1372:	4505                	li	a0,1
    1374:	00004097          	auipc	ra,0x4
    1378:	4b8080e7          	jalr	1208(ra) # 582c <exit>

000000000000137c <createtest>:
{
    137c:	7179                	addi	sp,sp,-48
    137e:	f406                	sd	ra,40(sp)
    1380:	f022                	sd	s0,32(sp)
    1382:	ec26                	sd	s1,24(sp)
    1384:	e84a                	sd	s2,16(sp)
    1386:	1800                	addi	s0,sp,48
  name[0] = 'a';
    1388:	06100793          	li	a5,97
    138c:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
    1390:	fc040d23          	sb	zero,-38(s0)
    1394:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    1398:	06400913          	li	s2,100
    name[1] = '0' + i;
    139c:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
    13a0:	20200593          	li	a1,514
    13a4:	fd840513          	addi	a0,s0,-40
    13a8:	00004097          	auipc	ra,0x4
    13ac:	4c4080e7          	jalr	1220(ra) # 586c <open>
    close(fd);
    13b0:	00004097          	auipc	ra,0x4
    13b4:	4a4080e7          	jalr	1188(ra) # 5854 <close>
  for(i = 0; i < N; i++){
    13b8:	2485                	addiw	s1,s1,1
    13ba:	0ff4f493          	andi	s1,s1,255
    13be:	fd249fe3          	bne	s1,s2,139c <createtest+0x20>
  name[0] = 'a';
    13c2:	06100793          	li	a5,97
    13c6:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
    13ca:	fc040d23          	sb	zero,-38(s0)
    13ce:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    13d2:	06400913          	li	s2,100
    name[1] = '0' + i;
    13d6:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
    13da:	fd840513          	addi	a0,s0,-40
    13de:	00004097          	auipc	ra,0x4
    13e2:	49e080e7          	jalr	1182(ra) # 587c <unlink>
  for(i = 0; i < N; i++){
    13e6:	2485                	addiw	s1,s1,1
    13e8:	0ff4f493          	andi	s1,s1,255
    13ec:	ff2495e3          	bne	s1,s2,13d6 <createtest+0x5a>
}
    13f0:	70a2                	ld	ra,40(sp)
    13f2:	7402                	ld	s0,32(sp)
    13f4:	64e2                	ld	s1,24(sp)
    13f6:	6942                	ld	s2,16(sp)
    13f8:	6145                	addi	sp,sp,48
    13fa:	8082                	ret

00000000000013fc <dirtest>:
{
    13fc:	1101                	addi	sp,sp,-32
    13fe:	ec06                	sd	ra,24(sp)
    1400:	e822                	sd	s0,16(sp)
    1402:	e426                	sd	s1,8(sp)
    1404:	1000                	addi	s0,sp,32
    1406:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    1408:	00005517          	auipc	a0,0x5
    140c:	15850513          	addi	a0,a0,344 # 6560 <malloc+0x8e6>
    1410:	00004097          	auipc	ra,0x4
    1414:	484080e7          	jalr	1156(ra) # 5894 <mkdir>
    1418:	04054563          	bltz	a0,1462 <dirtest+0x66>
  if(chdir("dir0") < 0){
    141c:	00005517          	auipc	a0,0x5
    1420:	14450513          	addi	a0,a0,324 # 6560 <malloc+0x8e6>
    1424:	00004097          	auipc	ra,0x4
    1428:	478080e7          	jalr	1144(ra) # 589c <chdir>
    142c:	04054963          	bltz	a0,147e <dirtest+0x82>
  if(chdir("..") < 0){
    1430:	00005517          	auipc	a0,0x5
    1434:	15050513          	addi	a0,a0,336 # 6580 <malloc+0x906>
    1438:	00004097          	auipc	ra,0x4
    143c:	464080e7          	jalr	1124(ra) # 589c <chdir>
    1440:	04054d63          	bltz	a0,149a <dirtest+0x9e>
  if(unlink("dir0") < 0){
    1444:	00005517          	auipc	a0,0x5
    1448:	11c50513          	addi	a0,a0,284 # 6560 <malloc+0x8e6>
    144c:	00004097          	auipc	ra,0x4
    1450:	430080e7          	jalr	1072(ra) # 587c <unlink>
    1454:	06054163          	bltz	a0,14b6 <dirtest+0xba>
}
    1458:	60e2                	ld	ra,24(sp)
    145a:	6442                	ld	s0,16(sp)
    145c:	64a2                	ld	s1,8(sp)
    145e:	6105                	addi	sp,sp,32
    1460:	8082                	ret
    printf("%s: mkdir failed\n", s);
    1462:	85a6                	mv	a1,s1
    1464:	00005517          	auipc	a0,0x5
    1468:	dcc50513          	addi	a0,a0,-564 # 6230 <malloc+0x5b6>
    146c:	00004097          	auipc	ra,0x4
    1470:	750080e7          	jalr	1872(ra) # 5bbc <printf>
    exit(1);
    1474:	4505                	li	a0,1
    1476:	00004097          	auipc	ra,0x4
    147a:	3b6080e7          	jalr	950(ra) # 582c <exit>
    printf("%s: chdir dir0 failed\n", s);
    147e:	85a6                	mv	a1,s1
    1480:	00005517          	auipc	a0,0x5
    1484:	0e850513          	addi	a0,a0,232 # 6568 <malloc+0x8ee>
    1488:	00004097          	auipc	ra,0x4
    148c:	734080e7          	jalr	1844(ra) # 5bbc <printf>
    exit(1);
    1490:	4505                	li	a0,1
    1492:	00004097          	auipc	ra,0x4
    1496:	39a080e7          	jalr	922(ra) # 582c <exit>
    printf("%s: chdir .. failed\n", s);
    149a:	85a6                	mv	a1,s1
    149c:	00005517          	auipc	a0,0x5
    14a0:	0ec50513          	addi	a0,a0,236 # 6588 <malloc+0x90e>
    14a4:	00004097          	auipc	ra,0x4
    14a8:	718080e7          	jalr	1816(ra) # 5bbc <printf>
    exit(1);
    14ac:	4505                	li	a0,1
    14ae:	00004097          	auipc	ra,0x4
    14b2:	37e080e7          	jalr	894(ra) # 582c <exit>
    printf("%s: unlink dir0 failed\n", s);
    14b6:	85a6                	mv	a1,s1
    14b8:	00005517          	auipc	a0,0x5
    14bc:	0e850513          	addi	a0,a0,232 # 65a0 <malloc+0x926>
    14c0:	00004097          	auipc	ra,0x4
    14c4:	6fc080e7          	jalr	1788(ra) # 5bbc <printf>
    exit(1);
    14c8:	4505                	li	a0,1
    14ca:	00004097          	auipc	ra,0x4
    14ce:	362080e7          	jalr	866(ra) # 582c <exit>

00000000000014d2 <exectest>:
{
    14d2:	715d                	addi	sp,sp,-80
    14d4:	e486                	sd	ra,72(sp)
    14d6:	e0a2                	sd	s0,64(sp)
    14d8:	fc26                	sd	s1,56(sp)
    14da:	f84a                	sd	s2,48(sp)
    14dc:	0880                	addi	s0,sp,80
    14de:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    14e0:	00005797          	auipc	a5,0x5
    14e4:	a1878793          	addi	a5,a5,-1512 # 5ef8 <malloc+0x27e>
    14e8:	fcf43023          	sd	a5,-64(s0)
    14ec:	00005797          	auipc	a5,0x5
    14f0:	0cc78793          	addi	a5,a5,204 # 65b8 <malloc+0x93e>
    14f4:	fcf43423          	sd	a5,-56(s0)
    14f8:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    14fc:	00005517          	auipc	a0,0x5
    1500:	0c450513          	addi	a0,a0,196 # 65c0 <malloc+0x946>
    1504:	00004097          	auipc	ra,0x4
    1508:	378080e7          	jalr	888(ra) # 587c <unlink>
  pid = fork();
    150c:	00004097          	auipc	ra,0x4
    1510:	318080e7          	jalr	792(ra) # 5824 <fork>
  if(pid < 0) {
    1514:	04054663          	bltz	a0,1560 <exectest+0x8e>
    1518:	84aa                	mv	s1,a0
  if(pid == 0) {
    151a:	e959                	bnez	a0,15b0 <exectest+0xde>
    close(1);
    151c:	4505                	li	a0,1
    151e:	00004097          	auipc	ra,0x4
    1522:	336080e7          	jalr	822(ra) # 5854 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1526:	20100593          	li	a1,513
    152a:	00005517          	auipc	a0,0x5
    152e:	09650513          	addi	a0,a0,150 # 65c0 <malloc+0x946>
    1532:	00004097          	auipc	ra,0x4
    1536:	33a080e7          	jalr	826(ra) # 586c <open>
    if(fd < 0) {
    153a:	04054163          	bltz	a0,157c <exectest+0xaa>
    if(fd != 1) {
    153e:	4785                	li	a5,1
    1540:	04f50c63          	beq	a0,a5,1598 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    1544:	85ca                	mv	a1,s2
    1546:	00005517          	auipc	a0,0x5
    154a:	09a50513          	addi	a0,a0,154 # 65e0 <malloc+0x966>
    154e:	00004097          	auipc	ra,0x4
    1552:	66e080e7          	jalr	1646(ra) # 5bbc <printf>
      exit(1);
    1556:	4505                	li	a0,1
    1558:	00004097          	auipc	ra,0x4
    155c:	2d4080e7          	jalr	724(ra) # 582c <exit>
     printf("%s: fork failed\n", s);
    1560:	85ca                	mv	a1,s2
    1562:	00005517          	auipc	a0,0x5
    1566:	c3e50513          	addi	a0,a0,-962 # 61a0 <malloc+0x526>
    156a:	00004097          	auipc	ra,0x4
    156e:	652080e7          	jalr	1618(ra) # 5bbc <printf>
     exit(1);
    1572:	4505                	li	a0,1
    1574:	00004097          	auipc	ra,0x4
    1578:	2b8080e7          	jalr	696(ra) # 582c <exit>
      printf("%s: create failed\n", s);
    157c:	85ca                	mv	a1,s2
    157e:	00005517          	auipc	a0,0x5
    1582:	04a50513          	addi	a0,a0,74 # 65c8 <malloc+0x94e>
    1586:	00004097          	auipc	ra,0x4
    158a:	636080e7          	jalr	1590(ra) # 5bbc <printf>
      exit(1);
    158e:	4505                	li	a0,1
    1590:	00004097          	auipc	ra,0x4
    1594:	29c080e7          	jalr	668(ra) # 582c <exit>
    if(exec("echo", echoargv) < 0){
    1598:	fc040593          	addi	a1,s0,-64
    159c:	00005517          	auipc	a0,0x5
    15a0:	95c50513          	addi	a0,a0,-1700 # 5ef8 <malloc+0x27e>
    15a4:	00004097          	auipc	ra,0x4
    15a8:	2c0080e7          	jalr	704(ra) # 5864 <exec>
    15ac:	02054163          	bltz	a0,15ce <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    15b0:	fdc40513          	addi	a0,s0,-36
    15b4:	00004097          	auipc	ra,0x4
    15b8:	280080e7          	jalr	640(ra) # 5834 <wait>
    15bc:	02951763          	bne	a0,s1,15ea <exectest+0x118>
  if(xstatus != 0)
    15c0:	fdc42503          	lw	a0,-36(s0)
    15c4:	cd0d                	beqz	a0,15fe <exectest+0x12c>
    exit(xstatus);
    15c6:	00004097          	auipc	ra,0x4
    15ca:	266080e7          	jalr	614(ra) # 582c <exit>
      printf("%s: exec echo failed\n", s);
    15ce:	85ca                	mv	a1,s2
    15d0:	00005517          	auipc	a0,0x5
    15d4:	02050513          	addi	a0,a0,32 # 65f0 <malloc+0x976>
    15d8:	00004097          	auipc	ra,0x4
    15dc:	5e4080e7          	jalr	1508(ra) # 5bbc <printf>
      exit(1);
    15e0:	4505                	li	a0,1
    15e2:	00004097          	auipc	ra,0x4
    15e6:	24a080e7          	jalr	586(ra) # 582c <exit>
    printf("%s: wait failed!\n", s);
    15ea:	85ca                	mv	a1,s2
    15ec:	00005517          	auipc	a0,0x5
    15f0:	01c50513          	addi	a0,a0,28 # 6608 <malloc+0x98e>
    15f4:	00004097          	auipc	ra,0x4
    15f8:	5c8080e7          	jalr	1480(ra) # 5bbc <printf>
    15fc:	b7d1                	j	15c0 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    15fe:	4581                	li	a1,0
    1600:	00005517          	auipc	a0,0x5
    1604:	fc050513          	addi	a0,a0,-64 # 65c0 <malloc+0x946>
    1608:	00004097          	auipc	ra,0x4
    160c:	264080e7          	jalr	612(ra) # 586c <open>
  if(fd < 0) {
    1610:	02054a63          	bltz	a0,1644 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1614:	4609                	li	a2,2
    1616:	fb840593          	addi	a1,s0,-72
    161a:	00004097          	auipc	ra,0x4
    161e:	22a080e7          	jalr	554(ra) # 5844 <read>
    1622:	4789                	li	a5,2
    1624:	02f50e63          	beq	a0,a5,1660 <exectest+0x18e>
    printf("%s: read failed\n", s);
    1628:	85ca                	mv	a1,s2
    162a:	00005517          	auipc	a0,0x5
    162e:	e0e50513          	addi	a0,a0,-498 # 6438 <malloc+0x7be>
    1632:	00004097          	auipc	ra,0x4
    1636:	58a080e7          	jalr	1418(ra) # 5bbc <printf>
    exit(1);
    163a:	4505                	li	a0,1
    163c:	00004097          	auipc	ra,0x4
    1640:	1f0080e7          	jalr	496(ra) # 582c <exit>
    printf("%s: open failed\n", s);
    1644:	85ca                	mv	a1,s2
    1646:	00005517          	auipc	a0,0x5
    164a:	b7250513          	addi	a0,a0,-1166 # 61b8 <malloc+0x53e>
    164e:	00004097          	auipc	ra,0x4
    1652:	56e080e7          	jalr	1390(ra) # 5bbc <printf>
    exit(1);
    1656:	4505                	li	a0,1
    1658:	00004097          	auipc	ra,0x4
    165c:	1d4080e7          	jalr	468(ra) # 582c <exit>
  unlink("echo-ok");
    1660:	00005517          	auipc	a0,0x5
    1664:	f6050513          	addi	a0,a0,-160 # 65c0 <malloc+0x946>
    1668:	00004097          	auipc	ra,0x4
    166c:	214080e7          	jalr	532(ra) # 587c <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1670:	fb844703          	lbu	a4,-72(s0)
    1674:	04f00793          	li	a5,79
    1678:	00f71863          	bne	a4,a5,1688 <exectest+0x1b6>
    167c:	fb944703          	lbu	a4,-71(s0)
    1680:	04b00793          	li	a5,75
    1684:	02f70063          	beq	a4,a5,16a4 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1688:	85ca                	mv	a1,s2
    168a:	00005517          	auipc	a0,0x5
    168e:	f9650513          	addi	a0,a0,-106 # 6620 <malloc+0x9a6>
    1692:	00004097          	auipc	ra,0x4
    1696:	52a080e7          	jalr	1322(ra) # 5bbc <printf>
    exit(1);
    169a:	4505                	li	a0,1
    169c:	00004097          	auipc	ra,0x4
    16a0:	190080e7          	jalr	400(ra) # 582c <exit>
    exit(0);
    16a4:	4501                	li	a0,0
    16a6:	00004097          	auipc	ra,0x4
    16aa:	186080e7          	jalr	390(ra) # 582c <exit>

00000000000016ae <pipe1>:
{
    16ae:	711d                	addi	sp,sp,-96
    16b0:	ec86                	sd	ra,88(sp)
    16b2:	e8a2                	sd	s0,80(sp)
    16b4:	e4a6                	sd	s1,72(sp)
    16b6:	e0ca                	sd	s2,64(sp)
    16b8:	fc4e                	sd	s3,56(sp)
    16ba:	f852                	sd	s4,48(sp)
    16bc:	f456                	sd	s5,40(sp)
    16be:	f05a                	sd	s6,32(sp)
    16c0:	ec5e                	sd	s7,24(sp)
    16c2:	1080                	addi	s0,sp,96
    16c4:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    16c6:	fa840513          	addi	a0,s0,-88
    16ca:	00004097          	auipc	ra,0x4
    16ce:	172080e7          	jalr	370(ra) # 583c <pipe>
    16d2:	ed25                	bnez	a0,174a <pipe1+0x9c>
    16d4:	84aa                	mv	s1,a0
  pid = fork();
    16d6:	00004097          	auipc	ra,0x4
    16da:	14e080e7          	jalr	334(ra) # 5824 <fork>
    16de:	8a2a                	mv	s4,a0
  if(pid == 0){
    16e0:	c159                	beqz	a0,1766 <pipe1+0xb8>
  } else if(pid > 0){
    16e2:	16a05e63          	blez	a0,185e <pipe1+0x1b0>
    close(fds[1]);
    16e6:	fac42503          	lw	a0,-84(s0)
    16ea:	00004097          	auipc	ra,0x4
    16ee:	16a080e7          	jalr	362(ra) # 5854 <close>
    total = 0;
    16f2:	8a26                	mv	s4,s1
    cc = 1;
    16f4:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    16f6:	0000aa97          	auipc	s5,0xa
    16fa:	fe2a8a93          	addi	s5,s5,-30 # b6d8 <buf>
      if(cc > sizeof(buf))
    16fe:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1700:	864e                	mv	a2,s3
    1702:	85d6                	mv	a1,s5
    1704:	fa842503          	lw	a0,-88(s0)
    1708:	00004097          	auipc	ra,0x4
    170c:	13c080e7          	jalr	316(ra) # 5844 <read>
    1710:	10a05263          	blez	a0,1814 <pipe1+0x166>
      for(i = 0; i < n; i++){
    1714:	0000a717          	auipc	a4,0xa
    1718:	fc470713          	addi	a4,a4,-60 # b6d8 <buf>
    171c:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1720:	00074683          	lbu	a3,0(a4)
    1724:	0ff4f793          	andi	a5,s1,255
    1728:	2485                	addiw	s1,s1,1
    172a:	0cf69163          	bne	a3,a5,17ec <pipe1+0x13e>
      for(i = 0; i < n; i++){
    172e:	0705                	addi	a4,a4,1
    1730:	fec498e3          	bne	s1,a2,1720 <pipe1+0x72>
      total += n;
    1734:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1738:	0019979b          	slliw	a5,s3,0x1
    173c:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1740:	013b7363          	bgeu	s6,s3,1746 <pipe1+0x98>
        cc = sizeof(buf);
    1744:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1746:	84b2                	mv	s1,a2
    1748:	bf65                	j	1700 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    174a:	85ca                	mv	a1,s2
    174c:	00005517          	auipc	a0,0x5
    1750:	eec50513          	addi	a0,a0,-276 # 6638 <malloc+0x9be>
    1754:	00004097          	auipc	ra,0x4
    1758:	468080e7          	jalr	1128(ra) # 5bbc <printf>
    exit(1);
    175c:	4505                	li	a0,1
    175e:	00004097          	auipc	ra,0x4
    1762:	0ce080e7          	jalr	206(ra) # 582c <exit>
    close(fds[0]);
    1766:	fa842503          	lw	a0,-88(s0)
    176a:	00004097          	auipc	ra,0x4
    176e:	0ea080e7          	jalr	234(ra) # 5854 <close>
    for(n = 0; n < N; n++){
    1772:	0000ab17          	auipc	s6,0xa
    1776:	f66b0b13          	addi	s6,s6,-154 # b6d8 <buf>
    177a:	416004bb          	negw	s1,s6
    177e:	0ff4f493          	andi	s1,s1,255
    1782:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1786:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1788:	6a85                	lui	s5,0x1
    178a:	42da8a93          	addi	s5,s5,1069 # 142d <dirtest+0x31>
{
    178e:	87da                	mv	a5,s6
        buf[i] = seq++;
    1790:	0097873b          	addw	a4,a5,s1
    1794:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1798:	0785                	addi	a5,a5,1
    179a:	fef99be3          	bne	s3,a5,1790 <pipe1+0xe2>
    179e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    17a2:	40900613          	li	a2,1033
    17a6:	85de                	mv	a1,s7
    17a8:	fac42503          	lw	a0,-84(s0)
    17ac:	00004097          	auipc	ra,0x4
    17b0:	0a0080e7          	jalr	160(ra) # 584c <write>
    17b4:	40900793          	li	a5,1033
    17b8:	00f51c63          	bne	a0,a5,17d0 <pipe1+0x122>
    for(n = 0; n < N; n++){
    17bc:	24a5                	addiw	s1,s1,9
    17be:	0ff4f493          	andi	s1,s1,255
    17c2:	fd5a16e3          	bne	s4,s5,178e <pipe1+0xe0>
    exit(0);
    17c6:	4501                	li	a0,0
    17c8:	00004097          	auipc	ra,0x4
    17cc:	064080e7          	jalr	100(ra) # 582c <exit>
        printf("%s: pipe1 oops 1\n", s);
    17d0:	85ca                	mv	a1,s2
    17d2:	00005517          	auipc	a0,0x5
    17d6:	e7e50513          	addi	a0,a0,-386 # 6650 <malloc+0x9d6>
    17da:	00004097          	auipc	ra,0x4
    17de:	3e2080e7          	jalr	994(ra) # 5bbc <printf>
        exit(1);
    17e2:	4505                	li	a0,1
    17e4:	00004097          	auipc	ra,0x4
    17e8:	048080e7          	jalr	72(ra) # 582c <exit>
          printf("%s: pipe1 oops 2\n", s);
    17ec:	85ca                	mv	a1,s2
    17ee:	00005517          	auipc	a0,0x5
    17f2:	e7a50513          	addi	a0,a0,-390 # 6668 <malloc+0x9ee>
    17f6:	00004097          	auipc	ra,0x4
    17fa:	3c6080e7          	jalr	966(ra) # 5bbc <printf>
}
    17fe:	60e6                	ld	ra,88(sp)
    1800:	6446                	ld	s0,80(sp)
    1802:	64a6                	ld	s1,72(sp)
    1804:	6906                	ld	s2,64(sp)
    1806:	79e2                	ld	s3,56(sp)
    1808:	7a42                	ld	s4,48(sp)
    180a:	7aa2                	ld	s5,40(sp)
    180c:	7b02                	ld	s6,32(sp)
    180e:	6be2                	ld	s7,24(sp)
    1810:	6125                	addi	sp,sp,96
    1812:	8082                	ret
    if(total != N * SZ){
    1814:	6785                	lui	a5,0x1
    1816:	42d78793          	addi	a5,a5,1069 # 142d <dirtest+0x31>
    181a:	02fa0063          	beq	s4,a5,183a <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    181e:	85d2                	mv	a1,s4
    1820:	00005517          	auipc	a0,0x5
    1824:	e6050513          	addi	a0,a0,-416 # 6680 <malloc+0xa06>
    1828:	00004097          	auipc	ra,0x4
    182c:	394080e7          	jalr	916(ra) # 5bbc <printf>
      exit(1);
    1830:	4505                	li	a0,1
    1832:	00004097          	auipc	ra,0x4
    1836:	ffa080e7          	jalr	-6(ra) # 582c <exit>
    close(fds[0]);
    183a:	fa842503          	lw	a0,-88(s0)
    183e:	00004097          	auipc	ra,0x4
    1842:	016080e7          	jalr	22(ra) # 5854 <close>
    wait(&xstatus);
    1846:	fa440513          	addi	a0,s0,-92
    184a:	00004097          	auipc	ra,0x4
    184e:	fea080e7          	jalr	-22(ra) # 5834 <wait>
    exit(xstatus);
    1852:	fa442503          	lw	a0,-92(s0)
    1856:	00004097          	auipc	ra,0x4
    185a:	fd6080e7          	jalr	-42(ra) # 582c <exit>
    printf("%s: fork() failed\n", s);
    185e:	85ca                	mv	a1,s2
    1860:	00005517          	auipc	a0,0x5
    1864:	e4050513          	addi	a0,a0,-448 # 66a0 <malloc+0xa26>
    1868:	00004097          	auipc	ra,0x4
    186c:	354080e7          	jalr	852(ra) # 5bbc <printf>
    exit(1);
    1870:	4505                	li	a0,1
    1872:	00004097          	auipc	ra,0x4
    1876:	fba080e7          	jalr	-70(ra) # 582c <exit>

000000000000187a <killstatus>:
{
    187a:	7139                	addi	sp,sp,-64
    187c:	fc06                	sd	ra,56(sp)
    187e:	f822                	sd	s0,48(sp)
    1880:	f426                	sd	s1,40(sp)
    1882:	f04a                	sd	s2,32(sp)
    1884:	ec4e                	sd	s3,24(sp)
    1886:	e852                	sd	s4,16(sp)
    1888:	0080                	addi	s0,sp,64
    188a:	8a2a                	mv	s4,a0
    188c:	06400913          	li	s2,100
    if(xst != -1) {
    1890:	59fd                	li	s3,-1
    int pid1 = fork();
    1892:	00004097          	auipc	ra,0x4
    1896:	f92080e7          	jalr	-110(ra) # 5824 <fork>
    189a:	84aa                	mv	s1,a0
    if(pid1 < 0){
    189c:	02054f63          	bltz	a0,18da <killstatus+0x60>
    if(pid1 == 0){
    18a0:	c939                	beqz	a0,18f6 <killstatus+0x7c>
    sleep(1);
    18a2:	4505                	li	a0,1
    18a4:	00004097          	auipc	ra,0x4
    18a8:	018080e7          	jalr	24(ra) # 58bc <sleep>
    kill(pid1);
    18ac:	8526                	mv	a0,s1
    18ae:	00004097          	auipc	ra,0x4
    18b2:	fae080e7          	jalr	-82(ra) # 585c <kill>
    wait(&xst);
    18b6:	fcc40513          	addi	a0,s0,-52
    18ba:	00004097          	auipc	ra,0x4
    18be:	f7a080e7          	jalr	-134(ra) # 5834 <wait>
    if(xst != -1) {
    18c2:	fcc42783          	lw	a5,-52(s0)
    18c6:	03379d63          	bne	a5,s3,1900 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    18ca:	397d                	addiw	s2,s2,-1
    18cc:	fc0913e3          	bnez	s2,1892 <killstatus+0x18>
  exit(0);
    18d0:	4501                	li	a0,0
    18d2:	00004097          	auipc	ra,0x4
    18d6:	f5a080e7          	jalr	-166(ra) # 582c <exit>
      printf("%s: fork failed\n", s);
    18da:	85d2                	mv	a1,s4
    18dc:	00005517          	auipc	a0,0x5
    18e0:	8c450513          	addi	a0,a0,-1852 # 61a0 <malloc+0x526>
    18e4:	00004097          	auipc	ra,0x4
    18e8:	2d8080e7          	jalr	728(ra) # 5bbc <printf>
      exit(1);
    18ec:	4505                	li	a0,1
    18ee:	00004097          	auipc	ra,0x4
    18f2:	f3e080e7          	jalr	-194(ra) # 582c <exit>
        getpid();
    18f6:	00004097          	auipc	ra,0x4
    18fa:	fb6080e7          	jalr	-74(ra) # 58ac <getpid>
      while(1) {
    18fe:	bfe5                	j	18f6 <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    1900:	85d2                	mv	a1,s4
    1902:	00005517          	auipc	a0,0x5
    1906:	db650513          	addi	a0,a0,-586 # 66b8 <malloc+0xa3e>
    190a:	00004097          	auipc	ra,0x4
    190e:	2b2080e7          	jalr	690(ra) # 5bbc <printf>
       exit(1);
    1912:	4505                	li	a0,1
    1914:	00004097          	auipc	ra,0x4
    1918:	f18080e7          	jalr	-232(ra) # 582c <exit>

000000000000191c <preempt>:
{
    191c:	7139                	addi	sp,sp,-64
    191e:	fc06                	sd	ra,56(sp)
    1920:	f822                	sd	s0,48(sp)
    1922:	f426                	sd	s1,40(sp)
    1924:	f04a                	sd	s2,32(sp)
    1926:	ec4e                	sd	s3,24(sp)
    1928:	e852                	sd	s4,16(sp)
    192a:	0080                	addi	s0,sp,64
    192c:	84aa                	mv	s1,a0
  pid1 = fork();
    192e:	00004097          	auipc	ra,0x4
    1932:	ef6080e7          	jalr	-266(ra) # 5824 <fork>
  if(pid1 < 0) {
    1936:	00054563          	bltz	a0,1940 <preempt+0x24>
    193a:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    193c:	e105                	bnez	a0,195c <preempt+0x40>
    for(;;)
    193e:	a001                	j	193e <preempt+0x22>
    printf("%s: fork failed", s);
    1940:	85a6                	mv	a1,s1
    1942:	00005517          	auipc	a0,0x5
    1946:	d9650513          	addi	a0,a0,-618 # 66d8 <malloc+0xa5e>
    194a:	00004097          	auipc	ra,0x4
    194e:	272080e7          	jalr	626(ra) # 5bbc <printf>
    exit(1);
    1952:	4505                	li	a0,1
    1954:	00004097          	auipc	ra,0x4
    1958:	ed8080e7          	jalr	-296(ra) # 582c <exit>
  pid2 = fork();
    195c:	00004097          	auipc	ra,0x4
    1960:	ec8080e7          	jalr	-312(ra) # 5824 <fork>
    1964:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    1966:	00054463          	bltz	a0,196e <preempt+0x52>
  if(pid2 == 0)
    196a:	e105                	bnez	a0,198a <preempt+0x6e>
    for(;;)
    196c:	a001                	j	196c <preempt+0x50>
    printf("%s: fork failed\n", s);
    196e:	85a6                	mv	a1,s1
    1970:	00005517          	auipc	a0,0x5
    1974:	83050513          	addi	a0,a0,-2000 # 61a0 <malloc+0x526>
    1978:	00004097          	auipc	ra,0x4
    197c:	244080e7          	jalr	580(ra) # 5bbc <printf>
    exit(1);
    1980:	4505                	li	a0,1
    1982:	00004097          	auipc	ra,0x4
    1986:	eaa080e7          	jalr	-342(ra) # 582c <exit>
  pipe(pfds);
    198a:	fc840513          	addi	a0,s0,-56
    198e:	00004097          	auipc	ra,0x4
    1992:	eae080e7          	jalr	-338(ra) # 583c <pipe>
  pid3 = fork();
    1996:	00004097          	auipc	ra,0x4
    199a:	e8e080e7          	jalr	-370(ra) # 5824 <fork>
    199e:	892a                	mv	s2,a0
  if(pid3 < 0) {
    19a0:	02054e63          	bltz	a0,19dc <preempt+0xc0>
  if(pid3 == 0){
    19a4:	e525                	bnez	a0,1a0c <preempt+0xf0>
    close(pfds[0]);
    19a6:	fc842503          	lw	a0,-56(s0)
    19aa:	00004097          	auipc	ra,0x4
    19ae:	eaa080e7          	jalr	-342(ra) # 5854 <close>
    if(write(pfds[1], "x", 1) != 1)
    19b2:	4605                	li	a2,1
    19b4:	00004597          	auipc	a1,0x4
    19b8:	4f458593          	addi	a1,a1,1268 # 5ea8 <malloc+0x22e>
    19bc:	fcc42503          	lw	a0,-52(s0)
    19c0:	00004097          	auipc	ra,0x4
    19c4:	e8c080e7          	jalr	-372(ra) # 584c <write>
    19c8:	4785                	li	a5,1
    19ca:	02f51763          	bne	a0,a5,19f8 <preempt+0xdc>
    close(pfds[1]);
    19ce:	fcc42503          	lw	a0,-52(s0)
    19d2:	00004097          	auipc	ra,0x4
    19d6:	e82080e7          	jalr	-382(ra) # 5854 <close>
    for(;;)
    19da:	a001                	j	19da <preempt+0xbe>
     printf("%s: fork failed\n", s);
    19dc:	85a6                	mv	a1,s1
    19de:	00004517          	auipc	a0,0x4
    19e2:	7c250513          	addi	a0,a0,1986 # 61a0 <malloc+0x526>
    19e6:	00004097          	auipc	ra,0x4
    19ea:	1d6080e7          	jalr	470(ra) # 5bbc <printf>
     exit(1);
    19ee:	4505                	li	a0,1
    19f0:	00004097          	auipc	ra,0x4
    19f4:	e3c080e7          	jalr	-452(ra) # 582c <exit>
      printf("%s: preempt write error", s);
    19f8:	85a6                	mv	a1,s1
    19fa:	00005517          	auipc	a0,0x5
    19fe:	cee50513          	addi	a0,a0,-786 # 66e8 <malloc+0xa6e>
    1a02:	00004097          	auipc	ra,0x4
    1a06:	1ba080e7          	jalr	442(ra) # 5bbc <printf>
    1a0a:	b7d1                	j	19ce <preempt+0xb2>
  close(pfds[1]);
    1a0c:	fcc42503          	lw	a0,-52(s0)
    1a10:	00004097          	auipc	ra,0x4
    1a14:	e44080e7          	jalr	-444(ra) # 5854 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    1a18:	660d                	lui	a2,0x3
    1a1a:	0000a597          	auipc	a1,0xa
    1a1e:	cbe58593          	addi	a1,a1,-834 # b6d8 <buf>
    1a22:	fc842503          	lw	a0,-56(s0)
    1a26:	00004097          	auipc	ra,0x4
    1a2a:	e1e080e7          	jalr	-482(ra) # 5844 <read>
    1a2e:	4785                	li	a5,1
    1a30:	02f50363          	beq	a0,a5,1a56 <preempt+0x13a>
    printf("%s: preempt read error", s);
    1a34:	85a6                	mv	a1,s1
    1a36:	00005517          	auipc	a0,0x5
    1a3a:	cca50513          	addi	a0,a0,-822 # 6700 <malloc+0xa86>
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	17e080e7          	jalr	382(ra) # 5bbc <printf>
}
    1a46:	70e2                	ld	ra,56(sp)
    1a48:	7442                	ld	s0,48(sp)
    1a4a:	74a2                	ld	s1,40(sp)
    1a4c:	7902                	ld	s2,32(sp)
    1a4e:	69e2                	ld	s3,24(sp)
    1a50:	6a42                	ld	s4,16(sp)
    1a52:	6121                	addi	sp,sp,64
    1a54:	8082                	ret
  close(pfds[0]);
    1a56:	fc842503          	lw	a0,-56(s0)
    1a5a:	00004097          	auipc	ra,0x4
    1a5e:	dfa080e7          	jalr	-518(ra) # 5854 <close>
  printf("kill... ");
    1a62:	00005517          	auipc	a0,0x5
    1a66:	cb650513          	addi	a0,a0,-842 # 6718 <malloc+0xa9e>
    1a6a:	00004097          	auipc	ra,0x4
    1a6e:	152080e7          	jalr	338(ra) # 5bbc <printf>
  kill(pid1);
    1a72:	8552                	mv	a0,s4
    1a74:	00004097          	auipc	ra,0x4
    1a78:	de8080e7          	jalr	-536(ra) # 585c <kill>
  kill(pid2);
    1a7c:	854e                	mv	a0,s3
    1a7e:	00004097          	auipc	ra,0x4
    1a82:	dde080e7          	jalr	-546(ra) # 585c <kill>
  kill(pid3);
    1a86:	854a                	mv	a0,s2
    1a88:	00004097          	auipc	ra,0x4
    1a8c:	dd4080e7          	jalr	-556(ra) # 585c <kill>
  printf("wait... ");
    1a90:	00005517          	auipc	a0,0x5
    1a94:	c9850513          	addi	a0,a0,-872 # 6728 <malloc+0xaae>
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	124080e7          	jalr	292(ra) # 5bbc <printf>
  wait(0);
    1aa0:	4501                	li	a0,0
    1aa2:	00004097          	auipc	ra,0x4
    1aa6:	d92080e7          	jalr	-622(ra) # 5834 <wait>
  wait(0);
    1aaa:	4501                	li	a0,0
    1aac:	00004097          	auipc	ra,0x4
    1ab0:	d88080e7          	jalr	-632(ra) # 5834 <wait>
  wait(0);
    1ab4:	4501                	li	a0,0
    1ab6:	00004097          	auipc	ra,0x4
    1aba:	d7e080e7          	jalr	-642(ra) # 5834 <wait>
    1abe:	b761                	j	1a46 <preempt+0x12a>

0000000000001ac0 <exitwait>:
{
    1ac0:	7139                	addi	sp,sp,-64
    1ac2:	fc06                	sd	ra,56(sp)
    1ac4:	f822                	sd	s0,48(sp)
    1ac6:	f426                	sd	s1,40(sp)
    1ac8:	f04a                	sd	s2,32(sp)
    1aca:	ec4e                	sd	s3,24(sp)
    1acc:	e852                	sd	s4,16(sp)
    1ace:	0080                	addi	s0,sp,64
    1ad0:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1ad2:	4901                	li	s2,0
    1ad4:	06400993          	li	s3,100
    pid = fork();
    1ad8:	00004097          	auipc	ra,0x4
    1adc:	d4c080e7          	jalr	-692(ra) # 5824 <fork>
    1ae0:	84aa                	mv	s1,a0
    if(pid < 0){
    1ae2:	02054a63          	bltz	a0,1b16 <exitwait+0x56>
    if(pid){
    1ae6:	c151                	beqz	a0,1b6a <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1ae8:	fcc40513          	addi	a0,s0,-52
    1aec:	00004097          	auipc	ra,0x4
    1af0:	d48080e7          	jalr	-696(ra) # 5834 <wait>
    1af4:	02951f63          	bne	a0,s1,1b32 <exitwait+0x72>
      if(i != xstate) {
    1af8:	fcc42783          	lw	a5,-52(s0)
    1afc:	05279963          	bne	a5,s2,1b4e <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1b00:	2905                	addiw	s2,s2,1
    1b02:	fd391be3          	bne	s2,s3,1ad8 <exitwait+0x18>
}
    1b06:	70e2                	ld	ra,56(sp)
    1b08:	7442                	ld	s0,48(sp)
    1b0a:	74a2                	ld	s1,40(sp)
    1b0c:	7902                	ld	s2,32(sp)
    1b0e:	69e2                	ld	s3,24(sp)
    1b10:	6a42                	ld	s4,16(sp)
    1b12:	6121                	addi	sp,sp,64
    1b14:	8082                	ret
      printf("%s: fork failed\n", s);
    1b16:	85d2                	mv	a1,s4
    1b18:	00004517          	auipc	a0,0x4
    1b1c:	68850513          	addi	a0,a0,1672 # 61a0 <malloc+0x526>
    1b20:	00004097          	auipc	ra,0x4
    1b24:	09c080e7          	jalr	156(ra) # 5bbc <printf>
      exit(1);
    1b28:	4505                	li	a0,1
    1b2a:	00004097          	auipc	ra,0x4
    1b2e:	d02080e7          	jalr	-766(ra) # 582c <exit>
        printf("%s: wait wrong pid\n", s);
    1b32:	85d2                	mv	a1,s4
    1b34:	00005517          	auipc	a0,0x5
    1b38:	c0450513          	addi	a0,a0,-1020 # 6738 <malloc+0xabe>
    1b3c:	00004097          	auipc	ra,0x4
    1b40:	080080e7          	jalr	128(ra) # 5bbc <printf>
        exit(1);
    1b44:	4505                	li	a0,1
    1b46:	00004097          	auipc	ra,0x4
    1b4a:	ce6080e7          	jalr	-794(ra) # 582c <exit>
        printf("%s: wait wrong exit status\n", s);
    1b4e:	85d2                	mv	a1,s4
    1b50:	00005517          	auipc	a0,0x5
    1b54:	c0050513          	addi	a0,a0,-1024 # 6750 <malloc+0xad6>
    1b58:	00004097          	auipc	ra,0x4
    1b5c:	064080e7          	jalr	100(ra) # 5bbc <printf>
        exit(1);
    1b60:	4505                	li	a0,1
    1b62:	00004097          	auipc	ra,0x4
    1b66:	cca080e7          	jalr	-822(ra) # 582c <exit>
      exit(i);
    1b6a:	854a                	mv	a0,s2
    1b6c:	00004097          	auipc	ra,0x4
    1b70:	cc0080e7          	jalr	-832(ra) # 582c <exit>

0000000000001b74 <reparent>:
{
    1b74:	7179                	addi	sp,sp,-48
    1b76:	f406                	sd	ra,40(sp)
    1b78:	f022                	sd	s0,32(sp)
    1b7a:	ec26                	sd	s1,24(sp)
    1b7c:	e84a                	sd	s2,16(sp)
    1b7e:	e44e                	sd	s3,8(sp)
    1b80:	e052                	sd	s4,0(sp)
    1b82:	1800                	addi	s0,sp,48
    1b84:	89aa                	mv	s3,a0
  int master_pid = getpid();
    1b86:	00004097          	auipc	ra,0x4
    1b8a:	d26080e7          	jalr	-730(ra) # 58ac <getpid>
    1b8e:	8a2a                	mv	s4,a0
    1b90:	0c800913          	li	s2,200
    int pid = fork();
    1b94:	00004097          	auipc	ra,0x4
    1b98:	c90080e7          	jalr	-880(ra) # 5824 <fork>
    1b9c:	84aa                	mv	s1,a0
    if(pid < 0){
    1b9e:	02054263          	bltz	a0,1bc2 <reparent+0x4e>
    if(pid){
    1ba2:	cd21                	beqz	a0,1bfa <reparent+0x86>
      if(wait(0) != pid){
    1ba4:	4501                	li	a0,0
    1ba6:	00004097          	auipc	ra,0x4
    1baa:	c8e080e7          	jalr	-882(ra) # 5834 <wait>
    1bae:	02951863          	bne	a0,s1,1bde <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    1bb2:	397d                	addiw	s2,s2,-1
    1bb4:	fe0910e3          	bnez	s2,1b94 <reparent+0x20>
  exit(0);
    1bb8:	4501                	li	a0,0
    1bba:	00004097          	auipc	ra,0x4
    1bbe:	c72080e7          	jalr	-910(ra) # 582c <exit>
      printf("%s: fork failed\n", s);
    1bc2:	85ce                	mv	a1,s3
    1bc4:	00004517          	auipc	a0,0x4
    1bc8:	5dc50513          	addi	a0,a0,1500 # 61a0 <malloc+0x526>
    1bcc:	00004097          	auipc	ra,0x4
    1bd0:	ff0080e7          	jalr	-16(ra) # 5bbc <printf>
      exit(1);
    1bd4:	4505                	li	a0,1
    1bd6:	00004097          	auipc	ra,0x4
    1bda:	c56080e7          	jalr	-938(ra) # 582c <exit>
        printf("%s: wait wrong pid\n", s);
    1bde:	85ce                	mv	a1,s3
    1be0:	00005517          	auipc	a0,0x5
    1be4:	b5850513          	addi	a0,a0,-1192 # 6738 <malloc+0xabe>
    1be8:	00004097          	auipc	ra,0x4
    1bec:	fd4080e7          	jalr	-44(ra) # 5bbc <printf>
        exit(1);
    1bf0:	4505                	li	a0,1
    1bf2:	00004097          	auipc	ra,0x4
    1bf6:	c3a080e7          	jalr	-966(ra) # 582c <exit>
      int pid2 = fork();
    1bfa:	00004097          	auipc	ra,0x4
    1bfe:	c2a080e7          	jalr	-982(ra) # 5824 <fork>
      if(pid2 < 0){
    1c02:	00054763          	bltz	a0,1c10 <reparent+0x9c>
      exit(0);
    1c06:	4501                	li	a0,0
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	c24080e7          	jalr	-988(ra) # 582c <exit>
        kill(master_pid);
    1c10:	8552                	mv	a0,s4
    1c12:	00004097          	auipc	ra,0x4
    1c16:	c4a080e7          	jalr	-950(ra) # 585c <kill>
        exit(1);
    1c1a:	4505                	li	a0,1
    1c1c:	00004097          	auipc	ra,0x4
    1c20:	c10080e7          	jalr	-1008(ra) # 582c <exit>

0000000000001c24 <twochildren>:
{
    1c24:	1101                	addi	sp,sp,-32
    1c26:	ec06                	sd	ra,24(sp)
    1c28:	e822                	sd	s0,16(sp)
    1c2a:	e426                	sd	s1,8(sp)
    1c2c:	e04a                	sd	s2,0(sp)
    1c2e:	1000                	addi	s0,sp,32
    1c30:	892a                	mv	s2,a0
    1c32:	3e800493          	li	s1,1000
    int pid1 = fork();
    1c36:	00004097          	auipc	ra,0x4
    1c3a:	bee080e7          	jalr	-1042(ra) # 5824 <fork>
    if(pid1 < 0){
    1c3e:	02054c63          	bltz	a0,1c76 <twochildren+0x52>
    if(pid1 == 0){
    1c42:	c921                	beqz	a0,1c92 <twochildren+0x6e>
      int pid2 = fork();
    1c44:	00004097          	auipc	ra,0x4
    1c48:	be0080e7          	jalr	-1056(ra) # 5824 <fork>
      if(pid2 < 0){
    1c4c:	04054763          	bltz	a0,1c9a <twochildren+0x76>
      if(pid2 == 0){
    1c50:	c13d                	beqz	a0,1cb6 <twochildren+0x92>
        wait(0);
    1c52:	4501                	li	a0,0
    1c54:	00004097          	auipc	ra,0x4
    1c58:	be0080e7          	jalr	-1056(ra) # 5834 <wait>
        wait(0);
    1c5c:	4501                	li	a0,0
    1c5e:	00004097          	auipc	ra,0x4
    1c62:	bd6080e7          	jalr	-1066(ra) # 5834 <wait>
  for(int i = 0; i < 1000; i++){
    1c66:	34fd                	addiw	s1,s1,-1
    1c68:	f4f9                	bnez	s1,1c36 <twochildren+0x12>
}
    1c6a:	60e2                	ld	ra,24(sp)
    1c6c:	6442                	ld	s0,16(sp)
    1c6e:	64a2                	ld	s1,8(sp)
    1c70:	6902                	ld	s2,0(sp)
    1c72:	6105                	addi	sp,sp,32
    1c74:	8082                	ret
      printf("%s: fork failed\n", s);
    1c76:	85ca                	mv	a1,s2
    1c78:	00004517          	auipc	a0,0x4
    1c7c:	52850513          	addi	a0,a0,1320 # 61a0 <malloc+0x526>
    1c80:	00004097          	auipc	ra,0x4
    1c84:	f3c080e7          	jalr	-196(ra) # 5bbc <printf>
      exit(1);
    1c88:	4505                	li	a0,1
    1c8a:	00004097          	auipc	ra,0x4
    1c8e:	ba2080e7          	jalr	-1118(ra) # 582c <exit>
      exit(0);
    1c92:	00004097          	auipc	ra,0x4
    1c96:	b9a080e7          	jalr	-1126(ra) # 582c <exit>
        printf("%s: fork failed\n", s);
    1c9a:	85ca                	mv	a1,s2
    1c9c:	00004517          	auipc	a0,0x4
    1ca0:	50450513          	addi	a0,a0,1284 # 61a0 <malloc+0x526>
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	f18080e7          	jalr	-232(ra) # 5bbc <printf>
        exit(1);
    1cac:	4505                	li	a0,1
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	b7e080e7          	jalr	-1154(ra) # 582c <exit>
        exit(0);
    1cb6:	00004097          	auipc	ra,0x4
    1cba:	b76080e7          	jalr	-1162(ra) # 582c <exit>

0000000000001cbe <forkfork>:
{
    1cbe:	7179                	addi	sp,sp,-48
    1cc0:	f406                	sd	ra,40(sp)
    1cc2:	f022                	sd	s0,32(sp)
    1cc4:	ec26                	sd	s1,24(sp)
    1cc6:	1800                	addi	s0,sp,48
    1cc8:	84aa                	mv	s1,a0
    int pid = fork();
    1cca:	00004097          	auipc	ra,0x4
    1cce:	b5a080e7          	jalr	-1190(ra) # 5824 <fork>
    if(pid < 0){
    1cd2:	04054163          	bltz	a0,1d14 <forkfork+0x56>
    if(pid == 0){
    1cd6:	cd29                	beqz	a0,1d30 <forkfork+0x72>
    int pid = fork();
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	b4c080e7          	jalr	-1204(ra) # 5824 <fork>
    if(pid < 0){
    1ce0:	02054a63          	bltz	a0,1d14 <forkfork+0x56>
    if(pid == 0){
    1ce4:	c531                	beqz	a0,1d30 <forkfork+0x72>
    wait(&xstatus);
    1ce6:	fdc40513          	addi	a0,s0,-36
    1cea:	00004097          	auipc	ra,0x4
    1cee:	b4a080e7          	jalr	-1206(ra) # 5834 <wait>
    if(xstatus != 0) {
    1cf2:	fdc42783          	lw	a5,-36(s0)
    1cf6:	ebbd                	bnez	a5,1d6c <forkfork+0xae>
    wait(&xstatus);
    1cf8:	fdc40513          	addi	a0,s0,-36
    1cfc:	00004097          	auipc	ra,0x4
    1d00:	b38080e7          	jalr	-1224(ra) # 5834 <wait>
    if(xstatus != 0) {
    1d04:	fdc42783          	lw	a5,-36(s0)
    1d08:	e3b5                	bnez	a5,1d6c <forkfork+0xae>
}
    1d0a:	70a2                	ld	ra,40(sp)
    1d0c:	7402                	ld	s0,32(sp)
    1d0e:	64e2                	ld	s1,24(sp)
    1d10:	6145                	addi	sp,sp,48
    1d12:	8082                	ret
      printf("%s: fork failed", s);
    1d14:	85a6                	mv	a1,s1
    1d16:	00005517          	auipc	a0,0x5
    1d1a:	9c250513          	addi	a0,a0,-1598 # 66d8 <malloc+0xa5e>
    1d1e:	00004097          	auipc	ra,0x4
    1d22:	e9e080e7          	jalr	-354(ra) # 5bbc <printf>
      exit(1);
    1d26:	4505                	li	a0,1
    1d28:	00004097          	auipc	ra,0x4
    1d2c:	b04080e7          	jalr	-1276(ra) # 582c <exit>
{
    1d30:	0c800493          	li	s1,200
        int pid1 = fork();
    1d34:	00004097          	auipc	ra,0x4
    1d38:	af0080e7          	jalr	-1296(ra) # 5824 <fork>
        if(pid1 < 0){
    1d3c:	00054f63          	bltz	a0,1d5a <forkfork+0x9c>
        if(pid1 == 0){
    1d40:	c115                	beqz	a0,1d64 <forkfork+0xa6>
        wait(0);
    1d42:	4501                	li	a0,0
    1d44:	00004097          	auipc	ra,0x4
    1d48:	af0080e7          	jalr	-1296(ra) # 5834 <wait>
      for(int j = 0; j < 200; j++){
    1d4c:	34fd                	addiw	s1,s1,-1
    1d4e:	f0fd                	bnez	s1,1d34 <forkfork+0x76>
      exit(0);
    1d50:	4501                	li	a0,0
    1d52:	00004097          	auipc	ra,0x4
    1d56:	ada080e7          	jalr	-1318(ra) # 582c <exit>
          exit(1);
    1d5a:	4505                	li	a0,1
    1d5c:	00004097          	auipc	ra,0x4
    1d60:	ad0080e7          	jalr	-1328(ra) # 582c <exit>
          exit(0);
    1d64:	00004097          	auipc	ra,0x4
    1d68:	ac8080e7          	jalr	-1336(ra) # 582c <exit>
      printf("%s: fork in child failed", s);
    1d6c:	85a6                	mv	a1,s1
    1d6e:	00005517          	auipc	a0,0x5
    1d72:	a0250513          	addi	a0,a0,-1534 # 6770 <malloc+0xaf6>
    1d76:	00004097          	auipc	ra,0x4
    1d7a:	e46080e7          	jalr	-442(ra) # 5bbc <printf>
      exit(1);
    1d7e:	4505                	li	a0,1
    1d80:	00004097          	auipc	ra,0x4
    1d84:	aac080e7          	jalr	-1364(ra) # 582c <exit>

0000000000001d88 <forkforkfork>:
{
    1d88:	1101                	addi	sp,sp,-32
    1d8a:	ec06                	sd	ra,24(sp)
    1d8c:	e822                	sd	s0,16(sp)
    1d8e:	e426                	sd	s1,8(sp)
    1d90:	1000                	addi	s0,sp,32
    1d92:	84aa                	mv	s1,a0
  unlink("stopforking");
    1d94:	00005517          	auipc	a0,0x5
    1d98:	9fc50513          	addi	a0,a0,-1540 # 6790 <malloc+0xb16>
    1d9c:	00004097          	auipc	ra,0x4
    1da0:	ae0080e7          	jalr	-1312(ra) # 587c <unlink>
  int pid = fork();
    1da4:	00004097          	auipc	ra,0x4
    1da8:	a80080e7          	jalr	-1408(ra) # 5824 <fork>
  if(pid < 0){
    1dac:	04054563          	bltz	a0,1df6 <forkforkfork+0x6e>
  if(pid == 0){
    1db0:	c12d                	beqz	a0,1e12 <forkforkfork+0x8a>
  sleep(20); // two seconds
    1db2:	4551                	li	a0,20
    1db4:	00004097          	auipc	ra,0x4
    1db8:	b08080e7          	jalr	-1272(ra) # 58bc <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    1dbc:	20200593          	li	a1,514
    1dc0:	00005517          	auipc	a0,0x5
    1dc4:	9d050513          	addi	a0,a0,-1584 # 6790 <malloc+0xb16>
    1dc8:	00004097          	auipc	ra,0x4
    1dcc:	aa4080e7          	jalr	-1372(ra) # 586c <open>
    1dd0:	00004097          	auipc	ra,0x4
    1dd4:	a84080e7          	jalr	-1404(ra) # 5854 <close>
  wait(0);
    1dd8:	4501                	li	a0,0
    1dda:	00004097          	auipc	ra,0x4
    1dde:	a5a080e7          	jalr	-1446(ra) # 5834 <wait>
  sleep(10); // one second
    1de2:	4529                	li	a0,10
    1de4:	00004097          	auipc	ra,0x4
    1de8:	ad8080e7          	jalr	-1320(ra) # 58bc <sleep>
}
    1dec:	60e2                	ld	ra,24(sp)
    1dee:	6442                	ld	s0,16(sp)
    1df0:	64a2                	ld	s1,8(sp)
    1df2:	6105                	addi	sp,sp,32
    1df4:	8082                	ret
    printf("%s: fork failed", s);
    1df6:	85a6                	mv	a1,s1
    1df8:	00005517          	auipc	a0,0x5
    1dfc:	8e050513          	addi	a0,a0,-1824 # 66d8 <malloc+0xa5e>
    1e00:	00004097          	auipc	ra,0x4
    1e04:	dbc080e7          	jalr	-580(ra) # 5bbc <printf>
    exit(1);
    1e08:	4505                	li	a0,1
    1e0a:	00004097          	auipc	ra,0x4
    1e0e:	a22080e7          	jalr	-1502(ra) # 582c <exit>
      int fd = open("stopforking", 0);
    1e12:	00005497          	auipc	s1,0x5
    1e16:	97e48493          	addi	s1,s1,-1666 # 6790 <malloc+0xb16>
    1e1a:	4581                	li	a1,0
    1e1c:	8526                	mv	a0,s1
    1e1e:	00004097          	auipc	ra,0x4
    1e22:	a4e080e7          	jalr	-1458(ra) # 586c <open>
      if(fd >= 0){
    1e26:	02055463          	bgez	a0,1e4e <forkforkfork+0xc6>
      if(fork() < 0){
    1e2a:	00004097          	auipc	ra,0x4
    1e2e:	9fa080e7          	jalr	-1542(ra) # 5824 <fork>
    1e32:	fe0554e3          	bgez	a0,1e1a <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    1e36:	20200593          	li	a1,514
    1e3a:	8526                	mv	a0,s1
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	a30080e7          	jalr	-1488(ra) # 586c <open>
    1e44:	00004097          	auipc	ra,0x4
    1e48:	a10080e7          	jalr	-1520(ra) # 5854 <close>
    1e4c:	b7f9                	j	1e1a <forkforkfork+0x92>
        exit(0);
    1e4e:	4501                	li	a0,0
    1e50:	00004097          	auipc	ra,0x4
    1e54:	9dc080e7          	jalr	-1572(ra) # 582c <exit>

0000000000001e58 <reparent2>:
{
    1e58:	1101                	addi	sp,sp,-32
    1e5a:	ec06                	sd	ra,24(sp)
    1e5c:	e822                	sd	s0,16(sp)
    1e5e:	e426                	sd	s1,8(sp)
    1e60:	1000                	addi	s0,sp,32
    1e62:	32000493          	li	s1,800
    int pid1 = fork();
    1e66:	00004097          	auipc	ra,0x4
    1e6a:	9be080e7          	jalr	-1602(ra) # 5824 <fork>
    if(pid1 < 0){
    1e6e:	00054f63          	bltz	a0,1e8c <reparent2+0x34>
    if(pid1 == 0){
    1e72:	c915                	beqz	a0,1ea6 <reparent2+0x4e>
    wait(0);
    1e74:	4501                	li	a0,0
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	9be080e7          	jalr	-1602(ra) # 5834 <wait>
  for(int i = 0; i < 800; i++){
    1e7e:	34fd                	addiw	s1,s1,-1
    1e80:	f0fd                	bnez	s1,1e66 <reparent2+0xe>
  exit(0);
    1e82:	4501                	li	a0,0
    1e84:	00004097          	auipc	ra,0x4
    1e88:	9a8080e7          	jalr	-1624(ra) # 582c <exit>
      printf("fork failed\n");
    1e8c:	00006517          	auipc	a0,0x6
    1e90:	d2450513          	addi	a0,a0,-732 # 7bb0 <malloc+0x1f36>
    1e94:	00004097          	auipc	ra,0x4
    1e98:	d28080e7          	jalr	-728(ra) # 5bbc <printf>
      exit(1);
    1e9c:	4505                	li	a0,1
    1e9e:	00004097          	auipc	ra,0x4
    1ea2:	98e080e7          	jalr	-1650(ra) # 582c <exit>
      fork();
    1ea6:	00004097          	auipc	ra,0x4
    1eaa:	97e080e7          	jalr	-1666(ra) # 5824 <fork>
      fork();
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	976080e7          	jalr	-1674(ra) # 5824 <fork>
      exit(0);
    1eb6:	4501                	li	a0,0
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	974080e7          	jalr	-1676(ra) # 582c <exit>

0000000000001ec0 <mem>:
{
    1ec0:	7139                	addi	sp,sp,-64
    1ec2:	fc06                	sd	ra,56(sp)
    1ec4:	f822                	sd	s0,48(sp)
    1ec6:	f426                	sd	s1,40(sp)
    1ec8:	f04a                	sd	s2,32(sp)
    1eca:	ec4e                	sd	s3,24(sp)
    1ecc:	0080                	addi	s0,sp,64
    1ece:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    1ed0:	00004097          	auipc	ra,0x4
    1ed4:	954080e7          	jalr	-1708(ra) # 5824 <fork>
    m1 = 0;
    1ed8:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    1eda:	6909                	lui	s2,0x2
    1edc:	71190913          	addi	s2,s2,1809 # 2711 <unlinkread+0x191>
  if((pid = fork()) == 0){
    1ee0:	ed39                	bnez	a0,1f3e <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    1ee2:	854a                	mv	a0,s2
    1ee4:	00004097          	auipc	ra,0x4
    1ee8:	d96080e7          	jalr	-618(ra) # 5c7a <malloc>
    1eec:	c501                	beqz	a0,1ef4 <mem+0x34>
      *(char**)m2 = m1;
    1eee:	e104                	sd	s1,0(a0)
      m1 = m2;
    1ef0:	84aa                	mv	s1,a0
    1ef2:	bfc5                	j	1ee2 <mem+0x22>
    while(m1){
    1ef4:	c881                	beqz	s1,1f04 <mem+0x44>
      m2 = *(char**)m1;
    1ef6:	8526                	mv	a0,s1
    1ef8:	6084                	ld	s1,0(s1)
      free(m1);
    1efa:	00004097          	auipc	ra,0x4
    1efe:	cf8080e7          	jalr	-776(ra) # 5bf2 <free>
    while(m1){
    1f02:	f8f5                	bnez	s1,1ef6 <mem+0x36>
    m1 = malloc(1024*20);
    1f04:	6515                	lui	a0,0x5
    1f06:	00004097          	auipc	ra,0x4
    1f0a:	d74080e7          	jalr	-652(ra) # 5c7a <malloc>
    if(m1 == 0){
    1f0e:	c911                	beqz	a0,1f22 <mem+0x62>
    free(m1);
    1f10:	00004097          	auipc	ra,0x4
    1f14:	ce2080e7          	jalr	-798(ra) # 5bf2 <free>
    exit(0);
    1f18:	4501                	li	a0,0
    1f1a:	00004097          	auipc	ra,0x4
    1f1e:	912080e7          	jalr	-1774(ra) # 582c <exit>
      printf("couldn't allocate mem?!!\n", s);
    1f22:	85ce                	mv	a1,s3
    1f24:	00005517          	auipc	a0,0x5
    1f28:	87c50513          	addi	a0,a0,-1924 # 67a0 <malloc+0xb26>
    1f2c:	00004097          	auipc	ra,0x4
    1f30:	c90080e7          	jalr	-880(ra) # 5bbc <printf>
      exit(1);
    1f34:	4505                	li	a0,1
    1f36:	00004097          	auipc	ra,0x4
    1f3a:	8f6080e7          	jalr	-1802(ra) # 582c <exit>
    wait(&xstatus);
    1f3e:	fcc40513          	addi	a0,s0,-52
    1f42:	00004097          	auipc	ra,0x4
    1f46:	8f2080e7          	jalr	-1806(ra) # 5834 <wait>
    if(xstatus == -1){
    1f4a:	fcc42503          	lw	a0,-52(s0)
    1f4e:	57fd                	li	a5,-1
    1f50:	00f50663          	beq	a0,a5,1f5c <mem+0x9c>
    exit(xstatus);
    1f54:	00004097          	auipc	ra,0x4
    1f58:	8d8080e7          	jalr	-1832(ra) # 582c <exit>
      exit(0);
    1f5c:	4501                	li	a0,0
    1f5e:	00004097          	auipc	ra,0x4
    1f62:	8ce080e7          	jalr	-1842(ra) # 582c <exit>

0000000000001f66 <sharedfd>:
{
    1f66:	7159                	addi	sp,sp,-112
    1f68:	f486                	sd	ra,104(sp)
    1f6a:	f0a2                	sd	s0,96(sp)
    1f6c:	eca6                	sd	s1,88(sp)
    1f6e:	e8ca                	sd	s2,80(sp)
    1f70:	e4ce                	sd	s3,72(sp)
    1f72:	e0d2                	sd	s4,64(sp)
    1f74:	fc56                	sd	s5,56(sp)
    1f76:	f85a                	sd	s6,48(sp)
    1f78:	f45e                	sd	s7,40(sp)
    1f7a:	1880                	addi	s0,sp,112
    1f7c:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    1f7e:	00005517          	auipc	a0,0x5
    1f82:	84250513          	addi	a0,a0,-1982 # 67c0 <malloc+0xb46>
    1f86:	00004097          	auipc	ra,0x4
    1f8a:	8f6080e7          	jalr	-1802(ra) # 587c <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    1f8e:	20200593          	li	a1,514
    1f92:	00005517          	auipc	a0,0x5
    1f96:	82e50513          	addi	a0,a0,-2002 # 67c0 <malloc+0xb46>
    1f9a:	00004097          	auipc	ra,0x4
    1f9e:	8d2080e7          	jalr	-1838(ra) # 586c <open>
  if(fd < 0){
    1fa2:	04054a63          	bltz	a0,1ff6 <sharedfd+0x90>
    1fa6:	892a                	mv	s2,a0
  pid = fork();
    1fa8:	00004097          	auipc	ra,0x4
    1fac:	87c080e7          	jalr	-1924(ra) # 5824 <fork>
    1fb0:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    1fb2:	06300593          	li	a1,99
    1fb6:	c119                	beqz	a0,1fbc <sharedfd+0x56>
    1fb8:	07000593          	li	a1,112
    1fbc:	4629                	li	a2,10
    1fbe:	fa040513          	addi	a0,s0,-96
    1fc2:	00003097          	auipc	ra,0x3
    1fc6:	666080e7          	jalr	1638(ra) # 5628 <memset>
    1fca:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    1fce:	4629                	li	a2,10
    1fd0:	fa040593          	addi	a1,s0,-96
    1fd4:	854a                	mv	a0,s2
    1fd6:	00004097          	auipc	ra,0x4
    1fda:	876080e7          	jalr	-1930(ra) # 584c <write>
    1fde:	47a9                	li	a5,10
    1fe0:	02f51963          	bne	a0,a5,2012 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    1fe4:	34fd                	addiw	s1,s1,-1
    1fe6:	f4e5                	bnez	s1,1fce <sharedfd+0x68>
  if(pid == 0) {
    1fe8:	04099363          	bnez	s3,202e <sharedfd+0xc8>
    exit(0);
    1fec:	4501                	li	a0,0
    1fee:	00004097          	auipc	ra,0x4
    1ff2:	83e080e7          	jalr	-1986(ra) # 582c <exit>
    printf("%s: cannot open sharedfd for writing", s);
    1ff6:	85d2                	mv	a1,s4
    1ff8:	00004517          	auipc	a0,0x4
    1ffc:	7d850513          	addi	a0,a0,2008 # 67d0 <malloc+0xb56>
    2000:	00004097          	auipc	ra,0x4
    2004:	bbc080e7          	jalr	-1092(ra) # 5bbc <printf>
    exit(1);
    2008:	4505                	li	a0,1
    200a:	00004097          	auipc	ra,0x4
    200e:	822080e7          	jalr	-2014(ra) # 582c <exit>
      printf("%s: write sharedfd failed\n", s);
    2012:	85d2                	mv	a1,s4
    2014:	00004517          	auipc	a0,0x4
    2018:	7e450513          	addi	a0,a0,2020 # 67f8 <malloc+0xb7e>
    201c:	00004097          	auipc	ra,0x4
    2020:	ba0080e7          	jalr	-1120(ra) # 5bbc <printf>
      exit(1);
    2024:	4505                	li	a0,1
    2026:	00004097          	auipc	ra,0x4
    202a:	806080e7          	jalr	-2042(ra) # 582c <exit>
    wait(&xstatus);
    202e:	f9c40513          	addi	a0,s0,-100
    2032:	00004097          	auipc	ra,0x4
    2036:	802080e7          	jalr	-2046(ra) # 5834 <wait>
    if(xstatus != 0)
    203a:	f9c42983          	lw	s3,-100(s0)
    203e:	00098763          	beqz	s3,204c <sharedfd+0xe6>
      exit(xstatus);
    2042:	854e                	mv	a0,s3
    2044:	00003097          	auipc	ra,0x3
    2048:	7e8080e7          	jalr	2024(ra) # 582c <exit>
  close(fd);
    204c:	854a                	mv	a0,s2
    204e:	00004097          	auipc	ra,0x4
    2052:	806080e7          	jalr	-2042(ra) # 5854 <close>
  fd = open("sharedfd", 0);
    2056:	4581                	li	a1,0
    2058:	00004517          	auipc	a0,0x4
    205c:	76850513          	addi	a0,a0,1896 # 67c0 <malloc+0xb46>
    2060:	00004097          	auipc	ra,0x4
    2064:	80c080e7          	jalr	-2036(ra) # 586c <open>
    2068:	8baa                	mv	s7,a0
  nc = np = 0;
    206a:	8ace                	mv	s5,s3
  if(fd < 0){
    206c:	02054563          	bltz	a0,2096 <sharedfd+0x130>
    2070:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    2074:	06300493          	li	s1,99
      if(buf[i] == 'p')
    2078:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    207c:	4629                	li	a2,10
    207e:	fa040593          	addi	a1,s0,-96
    2082:	855e                	mv	a0,s7
    2084:	00003097          	auipc	ra,0x3
    2088:	7c0080e7          	jalr	1984(ra) # 5844 <read>
    208c:	02a05f63          	blez	a0,20ca <sharedfd+0x164>
    2090:	fa040793          	addi	a5,s0,-96
    2094:	a01d                	j	20ba <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    2096:	85d2                	mv	a1,s4
    2098:	00004517          	auipc	a0,0x4
    209c:	78050513          	addi	a0,a0,1920 # 6818 <malloc+0xb9e>
    20a0:	00004097          	auipc	ra,0x4
    20a4:	b1c080e7          	jalr	-1252(ra) # 5bbc <printf>
    exit(1);
    20a8:	4505                	li	a0,1
    20aa:	00003097          	auipc	ra,0x3
    20ae:	782080e7          	jalr	1922(ra) # 582c <exit>
        nc++;
    20b2:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    20b4:	0785                	addi	a5,a5,1
    20b6:	fd2783e3          	beq	a5,s2,207c <sharedfd+0x116>
      if(buf[i] == 'c')
    20ba:	0007c703          	lbu	a4,0(a5)
    20be:	fe970ae3          	beq	a4,s1,20b2 <sharedfd+0x14c>
      if(buf[i] == 'p')
    20c2:	ff6719e3          	bne	a4,s6,20b4 <sharedfd+0x14e>
        np++;
    20c6:	2a85                	addiw	s5,s5,1
    20c8:	b7f5                	j	20b4 <sharedfd+0x14e>
  close(fd);
    20ca:	855e                	mv	a0,s7
    20cc:	00003097          	auipc	ra,0x3
    20d0:	788080e7          	jalr	1928(ra) # 5854 <close>
  unlink("sharedfd");
    20d4:	00004517          	auipc	a0,0x4
    20d8:	6ec50513          	addi	a0,a0,1772 # 67c0 <malloc+0xb46>
    20dc:	00003097          	auipc	ra,0x3
    20e0:	7a0080e7          	jalr	1952(ra) # 587c <unlink>
  if(nc == N*SZ && np == N*SZ){
    20e4:	6789                	lui	a5,0x2
    20e6:	71078793          	addi	a5,a5,1808 # 2710 <unlinkread+0x190>
    20ea:	00f99763          	bne	s3,a5,20f8 <sharedfd+0x192>
    20ee:	6789                	lui	a5,0x2
    20f0:	71078793          	addi	a5,a5,1808 # 2710 <unlinkread+0x190>
    20f4:	02fa8063          	beq	s5,a5,2114 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    20f8:	85d2                	mv	a1,s4
    20fa:	00004517          	auipc	a0,0x4
    20fe:	74650513          	addi	a0,a0,1862 # 6840 <malloc+0xbc6>
    2102:	00004097          	auipc	ra,0x4
    2106:	aba080e7          	jalr	-1350(ra) # 5bbc <printf>
    exit(1);
    210a:	4505                	li	a0,1
    210c:	00003097          	auipc	ra,0x3
    2110:	720080e7          	jalr	1824(ra) # 582c <exit>
    exit(0);
    2114:	4501                	li	a0,0
    2116:	00003097          	auipc	ra,0x3
    211a:	716080e7          	jalr	1814(ra) # 582c <exit>

000000000000211e <fourfiles>:
{
    211e:	7171                	addi	sp,sp,-176
    2120:	f506                	sd	ra,168(sp)
    2122:	f122                	sd	s0,160(sp)
    2124:	ed26                	sd	s1,152(sp)
    2126:	e94a                	sd	s2,144(sp)
    2128:	e54e                	sd	s3,136(sp)
    212a:	e152                	sd	s4,128(sp)
    212c:	fcd6                	sd	s5,120(sp)
    212e:	f8da                	sd	s6,112(sp)
    2130:	f4de                	sd	s7,104(sp)
    2132:	f0e2                	sd	s8,96(sp)
    2134:	ece6                	sd	s9,88(sp)
    2136:	e8ea                	sd	s10,80(sp)
    2138:	e4ee                	sd	s11,72(sp)
    213a:	1900                	addi	s0,sp,176
    213c:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    213e:	00004797          	auipc	a5,0x4
    2142:	c2278793          	addi	a5,a5,-990 # 5d60 <malloc+0xe6>
    2146:	f6f43823          	sd	a5,-144(s0)
    214a:	00004797          	auipc	a5,0x4
    214e:	c1e78793          	addi	a5,a5,-994 # 5d68 <malloc+0xee>
    2152:	f6f43c23          	sd	a5,-136(s0)
    2156:	00004797          	auipc	a5,0x4
    215a:	c1a78793          	addi	a5,a5,-998 # 5d70 <malloc+0xf6>
    215e:	f8f43023          	sd	a5,-128(s0)
    2162:	00004797          	auipc	a5,0x4
    2166:	c1678793          	addi	a5,a5,-1002 # 5d78 <malloc+0xfe>
    216a:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    216e:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    2172:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    2174:	4481                	li	s1,0
    2176:	4a11                	li	s4,4
    fname = names[pi];
    2178:	00093983          	ld	s3,0(s2)
    unlink(fname);
    217c:	854e                	mv	a0,s3
    217e:	00003097          	auipc	ra,0x3
    2182:	6fe080e7          	jalr	1790(ra) # 587c <unlink>
    pid = fork();
    2186:	00003097          	auipc	ra,0x3
    218a:	69e080e7          	jalr	1694(ra) # 5824 <fork>
    if(pid < 0){
    218e:	04054563          	bltz	a0,21d8 <fourfiles+0xba>
    if(pid == 0){
    2192:	c12d                	beqz	a0,21f4 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    2194:	2485                	addiw	s1,s1,1
    2196:	0921                	addi	s2,s2,8
    2198:	ff4490e3          	bne	s1,s4,2178 <fourfiles+0x5a>
    219c:	4491                	li	s1,4
    wait(&xstatus);
    219e:	f6c40513          	addi	a0,s0,-148
    21a2:	00003097          	auipc	ra,0x3
    21a6:	692080e7          	jalr	1682(ra) # 5834 <wait>
    if(xstatus != 0)
    21aa:	f6c42503          	lw	a0,-148(s0)
    21ae:	ed69                	bnez	a0,2288 <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    21b0:	34fd                	addiw	s1,s1,-1
    21b2:	f4f5                	bnez	s1,219e <fourfiles+0x80>
    21b4:	03000b13          	li	s6,48
    total = 0;
    21b8:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    21bc:	00009a17          	auipc	s4,0x9
    21c0:	51ca0a13          	addi	s4,s4,1308 # b6d8 <buf>
    21c4:	00009a97          	auipc	s5,0x9
    21c8:	515a8a93          	addi	s5,s5,1301 # b6d9 <buf+0x1>
    if(total != N*SZ){
    21cc:	6d05                	lui	s10,0x1
    21ce:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0xc2>
  for(i = 0; i < NCHILD; i++){
    21d2:	03400d93          	li	s11,52
    21d6:	a23d                	j	2304 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    21d8:	85e6                	mv	a1,s9
    21da:	00006517          	auipc	a0,0x6
    21de:	9d650513          	addi	a0,a0,-1578 # 7bb0 <malloc+0x1f36>
    21e2:	00004097          	auipc	ra,0x4
    21e6:	9da080e7          	jalr	-1574(ra) # 5bbc <printf>
      exit(1);
    21ea:	4505                	li	a0,1
    21ec:	00003097          	auipc	ra,0x3
    21f0:	640080e7          	jalr	1600(ra) # 582c <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    21f4:	20200593          	li	a1,514
    21f8:	854e                	mv	a0,s3
    21fa:	00003097          	auipc	ra,0x3
    21fe:	672080e7          	jalr	1650(ra) # 586c <open>
    2202:	892a                	mv	s2,a0
      if(fd < 0){
    2204:	04054763          	bltz	a0,2252 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    2208:	1f400613          	li	a2,500
    220c:	0304859b          	addiw	a1,s1,48
    2210:	00009517          	auipc	a0,0x9
    2214:	4c850513          	addi	a0,a0,1224 # b6d8 <buf>
    2218:	00003097          	auipc	ra,0x3
    221c:	410080e7          	jalr	1040(ra) # 5628 <memset>
    2220:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    2222:	00009997          	auipc	s3,0x9
    2226:	4b698993          	addi	s3,s3,1206 # b6d8 <buf>
    222a:	1f400613          	li	a2,500
    222e:	85ce                	mv	a1,s3
    2230:	854a                	mv	a0,s2
    2232:	00003097          	auipc	ra,0x3
    2236:	61a080e7          	jalr	1562(ra) # 584c <write>
    223a:	85aa                	mv	a1,a0
    223c:	1f400793          	li	a5,500
    2240:	02f51763          	bne	a0,a5,226e <fourfiles+0x150>
      for(i = 0; i < N; i++){
    2244:	34fd                	addiw	s1,s1,-1
    2246:	f0f5                	bnez	s1,222a <fourfiles+0x10c>
      exit(0);
    2248:	4501                	li	a0,0
    224a:	00003097          	auipc	ra,0x3
    224e:	5e2080e7          	jalr	1506(ra) # 582c <exit>
        printf("create failed\n", s);
    2252:	85e6                	mv	a1,s9
    2254:	00004517          	auipc	a0,0x4
    2258:	60450513          	addi	a0,a0,1540 # 6858 <malloc+0xbde>
    225c:	00004097          	auipc	ra,0x4
    2260:	960080e7          	jalr	-1696(ra) # 5bbc <printf>
        exit(1);
    2264:	4505                	li	a0,1
    2266:	00003097          	auipc	ra,0x3
    226a:	5c6080e7          	jalr	1478(ra) # 582c <exit>
          printf("write failed %d\n", n);
    226e:	00004517          	auipc	a0,0x4
    2272:	5fa50513          	addi	a0,a0,1530 # 6868 <malloc+0xbee>
    2276:	00004097          	auipc	ra,0x4
    227a:	946080e7          	jalr	-1722(ra) # 5bbc <printf>
          exit(1);
    227e:	4505                	li	a0,1
    2280:	00003097          	auipc	ra,0x3
    2284:	5ac080e7          	jalr	1452(ra) # 582c <exit>
      exit(xstatus);
    2288:	00003097          	auipc	ra,0x3
    228c:	5a4080e7          	jalr	1444(ra) # 582c <exit>
          printf("wrong char\n", s);
    2290:	85e6                	mv	a1,s9
    2292:	00004517          	auipc	a0,0x4
    2296:	5ee50513          	addi	a0,a0,1518 # 6880 <malloc+0xc06>
    229a:	00004097          	auipc	ra,0x4
    229e:	922080e7          	jalr	-1758(ra) # 5bbc <printf>
          exit(1);
    22a2:	4505                	li	a0,1
    22a4:	00003097          	auipc	ra,0x3
    22a8:	588080e7          	jalr	1416(ra) # 582c <exit>
      total += n;
    22ac:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    22b0:	660d                	lui	a2,0x3
    22b2:	85d2                	mv	a1,s4
    22b4:	854e                	mv	a0,s3
    22b6:	00003097          	auipc	ra,0x3
    22ba:	58e080e7          	jalr	1422(ra) # 5844 <read>
    22be:	02a05363          	blez	a0,22e4 <fourfiles+0x1c6>
    22c2:	00009797          	auipc	a5,0x9
    22c6:	41678793          	addi	a5,a5,1046 # b6d8 <buf>
    22ca:	fff5069b          	addiw	a3,a0,-1
    22ce:	1682                	slli	a3,a3,0x20
    22d0:	9281                	srli	a3,a3,0x20
    22d2:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    22d4:	0007c703          	lbu	a4,0(a5)
    22d8:	fa971ce3          	bne	a4,s1,2290 <fourfiles+0x172>
      for(j = 0; j < n; j++){
    22dc:	0785                	addi	a5,a5,1
    22de:	fed79be3          	bne	a5,a3,22d4 <fourfiles+0x1b6>
    22e2:	b7e9                	j	22ac <fourfiles+0x18e>
    close(fd);
    22e4:	854e                	mv	a0,s3
    22e6:	00003097          	auipc	ra,0x3
    22ea:	56e080e7          	jalr	1390(ra) # 5854 <close>
    if(total != N*SZ){
    22ee:	03a91963          	bne	s2,s10,2320 <fourfiles+0x202>
    unlink(fname);
    22f2:	8562                	mv	a0,s8
    22f4:	00003097          	auipc	ra,0x3
    22f8:	588080e7          	jalr	1416(ra) # 587c <unlink>
  for(i = 0; i < NCHILD; i++){
    22fc:	0ba1                	addi	s7,s7,8
    22fe:	2b05                	addiw	s6,s6,1
    2300:	03bb0e63          	beq	s6,s11,233c <fourfiles+0x21e>
    fname = names[i];
    2304:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    2308:	4581                	li	a1,0
    230a:	8562                	mv	a0,s8
    230c:	00003097          	auipc	ra,0x3
    2310:	560080e7          	jalr	1376(ra) # 586c <open>
    2314:	89aa                	mv	s3,a0
    total = 0;
    2316:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    231a:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    231e:	bf49                	j	22b0 <fourfiles+0x192>
      printf("wrong length %d\n", total);
    2320:	85ca                	mv	a1,s2
    2322:	00004517          	auipc	a0,0x4
    2326:	56e50513          	addi	a0,a0,1390 # 6890 <malloc+0xc16>
    232a:	00004097          	auipc	ra,0x4
    232e:	892080e7          	jalr	-1902(ra) # 5bbc <printf>
      exit(1);
    2332:	4505                	li	a0,1
    2334:	00003097          	auipc	ra,0x3
    2338:	4f8080e7          	jalr	1272(ra) # 582c <exit>
}
    233c:	70aa                	ld	ra,168(sp)
    233e:	740a                	ld	s0,160(sp)
    2340:	64ea                	ld	s1,152(sp)
    2342:	694a                	ld	s2,144(sp)
    2344:	69aa                	ld	s3,136(sp)
    2346:	6a0a                	ld	s4,128(sp)
    2348:	7ae6                	ld	s5,120(sp)
    234a:	7b46                	ld	s6,112(sp)
    234c:	7ba6                	ld	s7,104(sp)
    234e:	7c06                	ld	s8,96(sp)
    2350:	6ce6                	ld	s9,88(sp)
    2352:	6d46                	ld	s10,80(sp)
    2354:	6da6                	ld	s11,72(sp)
    2356:	614d                	addi	sp,sp,176
    2358:	8082                	ret

000000000000235a <createdelete>:
{
    235a:	7175                	addi	sp,sp,-144
    235c:	e506                	sd	ra,136(sp)
    235e:	e122                	sd	s0,128(sp)
    2360:	fca6                	sd	s1,120(sp)
    2362:	f8ca                	sd	s2,112(sp)
    2364:	f4ce                	sd	s3,104(sp)
    2366:	f0d2                	sd	s4,96(sp)
    2368:	ecd6                	sd	s5,88(sp)
    236a:	e8da                	sd	s6,80(sp)
    236c:	e4de                	sd	s7,72(sp)
    236e:	e0e2                	sd	s8,64(sp)
    2370:	fc66                	sd	s9,56(sp)
    2372:	0900                	addi	s0,sp,144
    2374:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    2376:	4901                	li	s2,0
    2378:	4991                	li	s3,4
    pid = fork();
    237a:	00003097          	auipc	ra,0x3
    237e:	4aa080e7          	jalr	1194(ra) # 5824 <fork>
    2382:	84aa                	mv	s1,a0
    if(pid < 0){
    2384:	02054f63          	bltz	a0,23c2 <createdelete+0x68>
    if(pid == 0){
    2388:	c939                	beqz	a0,23de <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    238a:	2905                	addiw	s2,s2,1
    238c:	ff3917e3          	bne	s2,s3,237a <createdelete+0x20>
    2390:	4491                	li	s1,4
    wait(&xstatus);
    2392:	f7c40513          	addi	a0,s0,-132
    2396:	00003097          	auipc	ra,0x3
    239a:	49e080e7          	jalr	1182(ra) # 5834 <wait>
    if(xstatus != 0)
    239e:	f7c42903          	lw	s2,-132(s0)
    23a2:	0e091263          	bnez	s2,2486 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    23a6:	34fd                	addiw	s1,s1,-1
    23a8:	f4ed                	bnez	s1,2392 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    23aa:	f8040123          	sb	zero,-126(s0)
    23ae:	03000993          	li	s3,48
    23b2:	5a7d                	li	s4,-1
    23b4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    23b8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    23ba:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    23bc:	07400a93          	li	s5,116
    23c0:	a29d                	j	2526 <createdelete+0x1cc>
      printf("fork failed\n", s);
    23c2:	85e6                	mv	a1,s9
    23c4:	00005517          	auipc	a0,0x5
    23c8:	7ec50513          	addi	a0,a0,2028 # 7bb0 <malloc+0x1f36>
    23cc:	00003097          	auipc	ra,0x3
    23d0:	7f0080e7          	jalr	2032(ra) # 5bbc <printf>
      exit(1);
    23d4:	4505                	li	a0,1
    23d6:	00003097          	auipc	ra,0x3
    23da:	456080e7          	jalr	1110(ra) # 582c <exit>
      name[0] = 'p' + pi;
    23de:	0709091b          	addiw	s2,s2,112
    23e2:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    23e6:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    23ea:	4951                	li	s2,20
    23ec:	a015                	j	2410 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    23ee:	85e6                	mv	a1,s9
    23f0:	00004517          	auipc	a0,0x4
    23f4:	1d850513          	addi	a0,a0,472 # 65c8 <malloc+0x94e>
    23f8:	00003097          	auipc	ra,0x3
    23fc:	7c4080e7          	jalr	1988(ra) # 5bbc <printf>
          exit(1);
    2400:	4505                	li	a0,1
    2402:	00003097          	auipc	ra,0x3
    2406:	42a080e7          	jalr	1066(ra) # 582c <exit>
      for(i = 0; i < N; i++){
    240a:	2485                	addiw	s1,s1,1
    240c:	07248863          	beq	s1,s2,247c <createdelete+0x122>
        name[1] = '0' + i;
    2410:	0304879b          	addiw	a5,s1,48
    2414:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    2418:	20200593          	li	a1,514
    241c:	f8040513          	addi	a0,s0,-128
    2420:	00003097          	auipc	ra,0x3
    2424:	44c080e7          	jalr	1100(ra) # 586c <open>
        if(fd < 0){
    2428:	fc0543e3          	bltz	a0,23ee <createdelete+0x94>
        close(fd);
    242c:	00003097          	auipc	ra,0x3
    2430:	428080e7          	jalr	1064(ra) # 5854 <close>
        if(i > 0 && (i % 2 ) == 0){
    2434:	fc905be3          	blez	s1,240a <createdelete+0xb0>
    2438:	0014f793          	andi	a5,s1,1
    243c:	f7f9                	bnez	a5,240a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    243e:	01f4d79b          	srliw	a5,s1,0x1f
    2442:	9fa5                	addw	a5,a5,s1
    2444:	4017d79b          	sraiw	a5,a5,0x1
    2448:	0307879b          	addiw	a5,a5,48
    244c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    2450:	f8040513          	addi	a0,s0,-128
    2454:	00003097          	auipc	ra,0x3
    2458:	428080e7          	jalr	1064(ra) # 587c <unlink>
    245c:	fa0557e3          	bgez	a0,240a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    2460:	85e6                	mv	a1,s9
    2462:	00004517          	auipc	a0,0x4
    2466:	eb650513          	addi	a0,a0,-330 # 6318 <malloc+0x69e>
    246a:	00003097          	auipc	ra,0x3
    246e:	752080e7          	jalr	1874(ra) # 5bbc <printf>
            exit(1);
    2472:	4505                	li	a0,1
    2474:	00003097          	auipc	ra,0x3
    2478:	3b8080e7          	jalr	952(ra) # 582c <exit>
      exit(0);
    247c:	4501                	li	a0,0
    247e:	00003097          	auipc	ra,0x3
    2482:	3ae080e7          	jalr	942(ra) # 582c <exit>
      exit(1);
    2486:	4505                	li	a0,1
    2488:	00003097          	auipc	ra,0x3
    248c:	3a4080e7          	jalr	932(ra) # 582c <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    2490:	f8040613          	addi	a2,s0,-128
    2494:	85e6                	mv	a1,s9
    2496:	00004517          	auipc	a0,0x4
    249a:	41250513          	addi	a0,a0,1042 # 68a8 <malloc+0xc2e>
    249e:	00003097          	auipc	ra,0x3
    24a2:	71e080e7          	jalr	1822(ra) # 5bbc <printf>
        exit(1);
    24a6:	4505                	li	a0,1
    24a8:	00003097          	auipc	ra,0x3
    24ac:	384080e7          	jalr	900(ra) # 582c <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    24b0:	054b7163          	bgeu	s6,s4,24f2 <createdelete+0x198>
      if(fd >= 0)
    24b4:	02055a63          	bgez	a0,24e8 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    24b8:	2485                	addiw	s1,s1,1
    24ba:	0ff4f493          	andi	s1,s1,255
    24be:	05548c63          	beq	s1,s5,2516 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    24c2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    24c6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    24ca:	4581                	li	a1,0
    24cc:	f8040513          	addi	a0,s0,-128
    24d0:	00003097          	auipc	ra,0x3
    24d4:	39c080e7          	jalr	924(ra) # 586c <open>
      if((i == 0 || i >= N/2) && fd < 0){
    24d8:	00090463          	beqz	s2,24e0 <createdelete+0x186>
    24dc:	fd2bdae3          	bge	s7,s2,24b0 <createdelete+0x156>
    24e0:	fa0548e3          	bltz	a0,2490 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    24e4:	014b7963          	bgeu	s6,s4,24f6 <createdelete+0x19c>
        close(fd);
    24e8:	00003097          	auipc	ra,0x3
    24ec:	36c080e7          	jalr	876(ra) # 5854 <close>
    24f0:	b7e1                	j	24b8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    24f2:	fc0543e3          	bltz	a0,24b8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    24f6:	f8040613          	addi	a2,s0,-128
    24fa:	85e6                	mv	a1,s9
    24fc:	00004517          	auipc	a0,0x4
    2500:	3d450513          	addi	a0,a0,980 # 68d0 <malloc+0xc56>
    2504:	00003097          	auipc	ra,0x3
    2508:	6b8080e7          	jalr	1720(ra) # 5bbc <printf>
        exit(1);
    250c:	4505                	li	a0,1
    250e:	00003097          	auipc	ra,0x3
    2512:	31e080e7          	jalr	798(ra) # 582c <exit>
  for(i = 0; i < N; i++){
    2516:	2905                	addiw	s2,s2,1
    2518:	2a05                	addiw	s4,s4,1
    251a:	2985                	addiw	s3,s3,1
    251c:	0ff9f993          	andi	s3,s3,255
    2520:	47d1                	li	a5,20
    2522:	02f90a63          	beq	s2,a5,2556 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    2526:	84e2                	mv	s1,s8
    2528:	bf69                	j	24c2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    252a:	2905                	addiw	s2,s2,1
    252c:	0ff97913          	andi	s2,s2,255
    2530:	2985                	addiw	s3,s3,1
    2532:	0ff9f993          	andi	s3,s3,255
    2536:	03490863          	beq	s2,s4,2566 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    253a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    253c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    2540:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    2544:	f8040513          	addi	a0,s0,-128
    2548:	00003097          	auipc	ra,0x3
    254c:	334080e7          	jalr	820(ra) # 587c <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    2550:	34fd                	addiw	s1,s1,-1
    2552:	f4ed                	bnez	s1,253c <createdelete+0x1e2>
    2554:	bfd9                	j	252a <createdelete+0x1d0>
    2556:	03000993          	li	s3,48
    255a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    255e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    2560:	08400a13          	li	s4,132
    2564:	bfd9                	j	253a <createdelete+0x1e0>
}
    2566:	60aa                	ld	ra,136(sp)
    2568:	640a                	ld	s0,128(sp)
    256a:	74e6                	ld	s1,120(sp)
    256c:	7946                	ld	s2,112(sp)
    256e:	79a6                	ld	s3,104(sp)
    2570:	7a06                	ld	s4,96(sp)
    2572:	6ae6                	ld	s5,88(sp)
    2574:	6b46                	ld	s6,80(sp)
    2576:	6ba6                	ld	s7,72(sp)
    2578:	6c06                	ld	s8,64(sp)
    257a:	7ce2                	ld	s9,56(sp)
    257c:	6149                	addi	sp,sp,144
    257e:	8082                	ret

0000000000002580 <unlinkread>:
{
    2580:	7179                	addi	sp,sp,-48
    2582:	f406                	sd	ra,40(sp)
    2584:	f022                	sd	s0,32(sp)
    2586:	ec26                	sd	s1,24(sp)
    2588:	e84a                	sd	s2,16(sp)
    258a:	e44e                	sd	s3,8(sp)
    258c:	1800                	addi	s0,sp,48
    258e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
    2590:	20200593          	li	a1,514
    2594:	00004517          	auipc	a0,0x4
    2598:	36450513          	addi	a0,a0,868 # 68f8 <malloc+0xc7e>
    259c:	00003097          	auipc	ra,0x3
    25a0:	2d0080e7          	jalr	720(ra) # 586c <open>
  if(fd < 0){
    25a4:	0e054563          	bltz	a0,268e <unlinkread+0x10e>
    25a8:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
    25aa:	4615                	li	a2,5
    25ac:	00004597          	auipc	a1,0x4
    25b0:	37c58593          	addi	a1,a1,892 # 6928 <malloc+0xcae>
    25b4:	00003097          	auipc	ra,0x3
    25b8:	298080e7          	jalr	664(ra) # 584c <write>
  close(fd);
    25bc:	8526                	mv	a0,s1
    25be:	00003097          	auipc	ra,0x3
    25c2:	296080e7          	jalr	662(ra) # 5854 <close>
  fd = open("unlinkread", O_RDWR);
    25c6:	4589                	li	a1,2
    25c8:	00004517          	auipc	a0,0x4
    25cc:	33050513          	addi	a0,a0,816 # 68f8 <malloc+0xc7e>
    25d0:	00003097          	auipc	ra,0x3
    25d4:	29c080e7          	jalr	668(ra) # 586c <open>
    25d8:	84aa                	mv	s1,a0
  if(fd < 0){
    25da:	0c054863          	bltz	a0,26aa <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    25de:	00004517          	auipc	a0,0x4
    25e2:	31a50513          	addi	a0,a0,794 # 68f8 <malloc+0xc7e>
    25e6:	00003097          	auipc	ra,0x3
    25ea:	296080e7          	jalr	662(ra) # 587c <unlink>
    25ee:	ed61                	bnez	a0,26c6 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    25f0:	20200593          	li	a1,514
    25f4:	00004517          	auipc	a0,0x4
    25f8:	30450513          	addi	a0,a0,772 # 68f8 <malloc+0xc7e>
    25fc:	00003097          	auipc	ra,0x3
    2600:	270080e7          	jalr	624(ra) # 586c <open>
    2604:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    2606:	460d                	li	a2,3
    2608:	00004597          	auipc	a1,0x4
    260c:	36858593          	addi	a1,a1,872 # 6970 <malloc+0xcf6>
    2610:	00003097          	auipc	ra,0x3
    2614:	23c080e7          	jalr	572(ra) # 584c <write>
  close(fd1);
    2618:	854a                	mv	a0,s2
    261a:	00003097          	auipc	ra,0x3
    261e:	23a080e7          	jalr	570(ra) # 5854 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    2622:	660d                	lui	a2,0x3
    2624:	00009597          	auipc	a1,0x9
    2628:	0b458593          	addi	a1,a1,180 # b6d8 <buf>
    262c:	8526                	mv	a0,s1
    262e:	00003097          	auipc	ra,0x3
    2632:	216080e7          	jalr	534(ra) # 5844 <read>
    2636:	4795                	li	a5,5
    2638:	0af51563          	bne	a0,a5,26e2 <unlinkread+0x162>
  if(buf[0] != 'h'){
    263c:	00009717          	auipc	a4,0x9
    2640:	09c74703          	lbu	a4,156(a4) # b6d8 <buf>
    2644:	06800793          	li	a5,104
    2648:	0af71b63          	bne	a4,a5,26fe <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    264c:	4629                	li	a2,10
    264e:	00009597          	auipc	a1,0x9
    2652:	08a58593          	addi	a1,a1,138 # b6d8 <buf>
    2656:	8526                	mv	a0,s1
    2658:	00003097          	auipc	ra,0x3
    265c:	1f4080e7          	jalr	500(ra) # 584c <write>
    2660:	47a9                	li	a5,10
    2662:	0af51c63          	bne	a0,a5,271a <unlinkread+0x19a>
  close(fd);
    2666:	8526                	mv	a0,s1
    2668:	00003097          	auipc	ra,0x3
    266c:	1ec080e7          	jalr	492(ra) # 5854 <close>
  unlink("unlinkread");
    2670:	00004517          	auipc	a0,0x4
    2674:	28850513          	addi	a0,a0,648 # 68f8 <malloc+0xc7e>
    2678:	00003097          	auipc	ra,0x3
    267c:	204080e7          	jalr	516(ra) # 587c <unlink>
}
    2680:	70a2                	ld	ra,40(sp)
    2682:	7402                	ld	s0,32(sp)
    2684:	64e2                	ld	s1,24(sp)
    2686:	6942                	ld	s2,16(sp)
    2688:	69a2                	ld	s3,8(sp)
    268a:	6145                	addi	sp,sp,48
    268c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    268e:	85ce                	mv	a1,s3
    2690:	00004517          	auipc	a0,0x4
    2694:	27850513          	addi	a0,a0,632 # 6908 <malloc+0xc8e>
    2698:	00003097          	auipc	ra,0x3
    269c:	524080e7          	jalr	1316(ra) # 5bbc <printf>
    exit(1);
    26a0:	4505                	li	a0,1
    26a2:	00003097          	auipc	ra,0x3
    26a6:	18a080e7          	jalr	394(ra) # 582c <exit>
    printf("%s: open unlinkread failed\n", s);
    26aa:	85ce                	mv	a1,s3
    26ac:	00004517          	auipc	a0,0x4
    26b0:	28450513          	addi	a0,a0,644 # 6930 <malloc+0xcb6>
    26b4:	00003097          	auipc	ra,0x3
    26b8:	508080e7          	jalr	1288(ra) # 5bbc <printf>
    exit(1);
    26bc:	4505                	li	a0,1
    26be:	00003097          	auipc	ra,0x3
    26c2:	16e080e7          	jalr	366(ra) # 582c <exit>
    printf("%s: unlink unlinkread failed\n", s);
    26c6:	85ce                	mv	a1,s3
    26c8:	00004517          	auipc	a0,0x4
    26cc:	28850513          	addi	a0,a0,648 # 6950 <malloc+0xcd6>
    26d0:	00003097          	auipc	ra,0x3
    26d4:	4ec080e7          	jalr	1260(ra) # 5bbc <printf>
    exit(1);
    26d8:	4505                	li	a0,1
    26da:	00003097          	auipc	ra,0x3
    26de:	152080e7          	jalr	338(ra) # 582c <exit>
    printf("%s: unlinkread read failed", s);
    26e2:	85ce                	mv	a1,s3
    26e4:	00004517          	auipc	a0,0x4
    26e8:	29450513          	addi	a0,a0,660 # 6978 <malloc+0xcfe>
    26ec:	00003097          	auipc	ra,0x3
    26f0:	4d0080e7          	jalr	1232(ra) # 5bbc <printf>
    exit(1);
    26f4:	4505                	li	a0,1
    26f6:	00003097          	auipc	ra,0x3
    26fa:	136080e7          	jalr	310(ra) # 582c <exit>
    printf("%s: unlinkread wrong data\n", s);
    26fe:	85ce                	mv	a1,s3
    2700:	00004517          	auipc	a0,0x4
    2704:	29850513          	addi	a0,a0,664 # 6998 <malloc+0xd1e>
    2708:	00003097          	auipc	ra,0x3
    270c:	4b4080e7          	jalr	1204(ra) # 5bbc <printf>
    exit(1);
    2710:	4505                	li	a0,1
    2712:	00003097          	auipc	ra,0x3
    2716:	11a080e7          	jalr	282(ra) # 582c <exit>
    printf("%s: unlinkread write failed\n", s);
    271a:	85ce                	mv	a1,s3
    271c:	00004517          	auipc	a0,0x4
    2720:	29c50513          	addi	a0,a0,668 # 69b8 <malloc+0xd3e>
    2724:	00003097          	auipc	ra,0x3
    2728:	498080e7          	jalr	1176(ra) # 5bbc <printf>
    exit(1);
    272c:	4505                	li	a0,1
    272e:	00003097          	auipc	ra,0x3
    2732:	0fe080e7          	jalr	254(ra) # 582c <exit>

0000000000002736 <linktest>:
{
    2736:	1101                	addi	sp,sp,-32
    2738:	ec06                	sd	ra,24(sp)
    273a:	e822                	sd	s0,16(sp)
    273c:	e426                	sd	s1,8(sp)
    273e:	e04a                	sd	s2,0(sp)
    2740:	1000                	addi	s0,sp,32
    2742:	892a                	mv	s2,a0
  unlink("lf1");
    2744:	00004517          	auipc	a0,0x4
    2748:	29450513          	addi	a0,a0,660 # 69d8 <malloc+0xd5e>
    274c:	00003097          	auipc	ra,0x3
    2750:	130080e7          	jalr	304(ra) # 587c <unlink>
  unlink("lf2");
    2754:	00004517          	auipc	a0,0x4
    2758:	28c50513          	addi	a0,a0,652 # 69e0 <malloc+0xd66>
    275c:	00003097          	auipc	ra,0x3
    2760:	120080e7          	jalr	288(ra) # 587c <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    2764:	20200593          	li	a1,514
    2768:	00004517          	auipc	a0,0x4
    276c:	27050513          	addi	a0,a0,624 # 69d8 <malloc+0xd5e>
    2770:	00003097          	auipc	ra,0x3
    2774:	0fc080e7          	jalr	252(ra) # 586c <open>
  if(fd < 0){
    2778:	10054763          	bltz	a0,2886 <linktest+0x150>
    277c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    277e:	4615                	li	a2,5
    2780:	00004597          	auipc	a1,0x4
    2784:	1a858593          	addi	a1,a1,424 # 6928 <malloc+0xcae>
    2788:	00003097          	auipc	ra,0x3
    278c:	0c4080e7          	jalr	196(ra) # 584c <write>
    2790:	4795                	li	a5,5
    2792:	10f51863          	bne	a0,a5,28a2 <linktest+0x16c>
  close(fd);
    2796:	8526                	mv	a0,s1
    2798:	00003097          	auipc	ra,0x3
    279c:	0bc080e7          	jalr	188(ra) # 5854 <close>
  if(link("lf1", "lf2") < 0){
    27a0:	00004597          	auipc	a1,0x4
    27a4:	24058593          	addi	a1,a1,576 # 69e0 <malloc+0xd66>
    27a8:	00004517          	auipc	a0,0x4
    27ac:	23050513          	addi	a0,a0,560 # 69d8 <malloc+0xd5e>
    27b0:	00003097          	auipc	ra,0x3
    27b4:	0dc080e7          	jalr	220(ra) # 588c <link>
    27b8:	10054363          	bltz	a0,28be <linktest+0x188>
  unlink("lf1");
    27bc:	00004517          	auipc	a0,0x4
    27c0:	21c50513          	addi	a0,a0,540 # 69d8 <malloc+0xd5e>
    27c4:	00003097          	auipc	ra,0x3
    27c8:	0b8080e7          	jalr	184(ra) # 587c <unlink>
  if(open("lf1", 0) >= 0){
    27cc:	4581                	li	a1,0
    27ce:	00004517          	auipc	a0,0x4
    27d2:	20a50513          	addi	a0,a0,522 # 69d8 <malloc+0xd5e>
    27d6:	00003097          	auipc	ra,0x3
    27da:	096080e7          	jalr	150(ra) # 586c <open>
    27de:	0e055e63          	bgez	a0,28da <linktest+0x1a4>
  fd = open("lf2", 0);
    27e2:	4581                	li	a1,0
    27e4:	00004517          	auipc	a0,0x4
    27e8:	1fc50513          	addi	a0,a0,508 # 69e0 <malloc+0xd66>
    27ec:	00003097          	auipc	ra,0x3
    27f0:	080080e7          	jalr	128(ra) # 586c <open>
    27f4:	84aa                	mv	s1,a0
  if(fd < 0){
    27f6:	10054063          	bltz	a0,28f6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    27fa:	660d                	lui	a2,0x3
    27fc:	00009597          	auipc	a1,0x9
    2800:	edc58593          	addi	a1,a1,-292 # b6d8 <buf>
    2804:	00003097          	auipc	ra,0x3
    2808:	040080e7          	jalr	64(ra) # 5844 <read>
    280c:	4795                	li	a5,5
    280e:	10f51263          	bne	a0,a5,2912 <linktest+0x1dc>
  close(fd);
    2812:	8526                	mv	a0,s1
    2814:	00003097          	auipc	ra,0x3
    2818:	040080e7          	jalr	64(ra) # 5854 <close>
  if(link("lf2", "lf2") >= 0){
    281c:	00004597          	auipc	a1,0x4
    2820:	1c458593          	addi	a1,a1,452 # 69e0 <malloc+0xd66>
    2824:	852e                	mv	a0,a1
    2826:	00003097          	auipc	ra,0x3
    282a:	066080e7          	jalr	102(ra) # 588c <link>
    282e:	10055063          	bgez	a0,292e <linktest+0x1f8>
  unlink("lf2");
    2832:	00004517          	auipc	a0,0x4
    2836:	1ae50513          	addi	a0,a0,430 # 69e0 <malloc+0xd66>
    283a:	00003097          	auipc	ra,0x3
    283e:	042080e7          	jalr	66(ra) # 587c <unlink>
  if(link("lf2", "lf1") >= 0){
    2842:	00004597          	auipc	a1,0x4
    2846:	19658593          	addi	a1,a1,406 # 69d8 <malloc+0xd5e>
    284a:	00004517          	auipc	a0,0x4
    284e:	19650513          	addi	a0,a0,406 # 69e0 <malloc+0xd66>
    2852:	00003097          	auipc	ra,0x3
    2856:	03a080e7          	jalr	58(ra) # 588c <link>
    285a:	0e055863          	bgez	a0,294a <linktest+0x214>
  if(link(".", "lf1") >= 0){
    285e:	00004597          	auipc	a1,0x4
    2862:	17a58593          	addi	a1,a1,378 # 69d8 <malloc+0xd5e>
    2866:	00004517          	auipc	a0,0x4
    286a:	28250513          	addi	a0,a0,642 # 6ae8 <malloc+0xe6e>
    286e:	00003097          	auipc	ra,0x3
    2872:	01e080e7          	jalr	30(ra) # 588c <link>
    2876:	0e055863          	bgez	a0,2966 <linktest+0x230>
}
    287a:	60e2                	ld	ra,24(sp)
    287c:	6442                	ld	s0,16(sp)
    287e:	64a2                	ld	s1,8(sp)
    2880:	6902                	ld	s2,0(sp)
    2882:	6105                	addi	sp,sp,32
    2884:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    2886:	85ca                	mv	a1,s2
    2888:	00004517          	auipc	a0,0x4
    288c:	16050513          	addi	a0,a0,352 # 69e8 <malloc+0xd6e>
    2890:	00003097          	auipc	ra,0x3
    2894:	32c080e7          	jalr	812(ra) # 5bbc <printf>
    exit(1);
    2898:	4505                	li	a0,1
    289a:	00003097          	auipc	ra,0x3
    289e:	f92080e7          	jalr	-110(ra) # 582c <exit>
    printf("%s: write lf1 failed\n", s);
    28a2:	85ca                	mv	a1,s2
    28a4:	00004517          	auipc	a0,0x4
    28a8:	15c50513          	addi	a0,a0,348 # 6a00 <malloc+0xd86>
    28ac:	00003097          	auipc	ra,0x3
    28b0:	310080e7          	jalr	784(ra) # 5bbc <printf>
    exit(1);
    28b4:	4505                	li	a0,1
    28b6:	00003097          	auipc	ra,0x3
    28ba:	f76080e7          	jalr	-138(ra) # 582c <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    28be:	85ca                	mv	a1,s2
    28c0:	00004517          	auipc	a0,0x4
    28c4:	15850513          	addi	a0,a0,344 # 6a18 <malloc+0xd9e>
    28c8:	00003097          	auipc	ra,0x3
    28cc:	2f4080e7          	jalr	756(ra) # 5bbc <printf>
    exit(1);
    28d0:	4505                	li	a0,1
    28d2:	00003097          	auipc	ra,0x3
    28d6:	f5a080e7          	jalr	-166(ra) # 582c <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    28da:	85ca                	mv	a1,s2
    28dc:	00004517          	auipc	a0,0x4
    28e0:	15c50513          	addi	a0,a0,348 # 6a38 <malloc+0xdbe>
    28e4:	00003097          	auipc	ra,0x3
    28e8:	2d8080e7          	jalr	728(ra) # 5bbc <printf>
    exit(1);
    28ec:	4505                	li	a0,1
    28ee:	00003097          	auipc	ra,0x3
    28f2:	f3e080e7          	jalr	-194(ra) # 582c <exit>
    printf("%s: open lf2 failed\n", s);
    28f6:	85ca                	mv	a1,s2
    28f8:	00004517          	auipc	a0,0x4
    28fc:	17050513          	addi	a0,a0,368 # 6a68 <malloc+0xdee>
    2900:	00003097          	auipc	ra,0x3
    2904:	2bc080e7          	jalr	700(ra) # 5bbc <printf>
    exit(1);
    2908:	4505                	li	a0,1
    290a:	00003097          	auipc	ra,0x3
    290e:	f22080e7          	jalr	-222(ra) # 582c <exit>
    printf("%s: read lf2 failed\n", s);
    2912:	85ca                	mv	a1,s2
    2914:	00004517          	auipc	a0,0x4
    2918:	16c50513          	addi	a0,a0,364 # 6a80 <malloc+0xe06>
    291c:	00003097          	auipc	ra,0x3
    2920:	2a0080e7          	jalr	672(ra) # 5bbc <printf>
    exit(1);
    2924:	4505                	li	a0,1
    2926:	00003097          	auipc	ra,0x3
    292a:	f06080e7          	jalr	-250(ra) # 582c <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    292e:	85ca                	mv	a1,s2
    2930:	00004517          	auipc	a0,0x4
    2934:	16850513          	addi	a0,a0,360 # 6a98 <malloc+0xe1e>
    2938:	00003097          	auipc	ra,0x3
    293c:	284080e7          	jalr	644(ra) # 5bbc <printf>
    exit(1);
    2940:	4505                	li	a0,1
    2942:	00003097          	auipc	ra,0x3
    2946:	eea080e7          	jalr	-278(ra) # 582c <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    294a:	85ca                	mv	a1,s2
    294c:	00004517          	auipc	a0,0x4
    2950:	17450513          	addi	a0,a0,372 # 6ac0 <malloc+0xe46>
    2954:	00003097          	auipc	ra,0x3
    2958:	268080e7          	jalr	616(ra) # 5bbc <printf>
    exit(1);
    295c:	4505                	li	a0,1
    295e:	00003097          	auipc	ra,0x3
    2962:	ece080e7          	jalr	-306(ra) # 582c <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    2966:	85ca                	mv	a1,s2
    2968:	00004517          	auipc	a0,0x4
    296c:	18850513          	addi	a0,a0,392 # 6af0 <malloc+0xe76>
    2970:	00003097          	auipc	ra,0x3
    2974:	24c080e7          	jalr	588(ra) # 5bbc <printf>
    exit(1);
    2978:	4505                	li	a0,1
    297a:	00003097          	auipc	ra,0x3
    297e:	eb2080e7          	jalr	-334(ra) # 582c <exit>

0000000000002982 <concreate>:
{
    2982:	7135                	addi	sp,sp,-160
    2984:	ed06                	sd	ra,152(sp)
    2986:	e922                	sd	s0,144(sp)
    2988:	e526                	sd	s1,136(sp)
    298a:	e14a                	sd	s2,128(sp)
    298c:	fcce                	sd	s3,120(sp)
    298e:	f8d2                	sd	s4,112(sp)
    2990:	f4d6                	sd	s5,104(sp)
    2992:	f0da                	sd	s6,96(sp)
    2994:	ecde                	sd	s7,88(sp)
    2996:	1100                	addi	s0,sp,160
    2998:	89aa                	mv	s3,a0
  file[0] = 'C';
    299a:	04300793          	li	a5,67
    299e:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    29a2:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    29a6:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    29a8:	4b0d                	li	s6,3
    29aa:	4a85                	li	s5,1
      link("C0", file);
    29ac:	00004b97          	auipc	s7,0x4
    29b0:	164b8b93          	addi	s7,s7,356 # 6b10 <malloc+0xe96>
  for(i = 0; i < N; i++){
    29b4:	02800a13          	li	s4,40
    29b8:	acc1                	j	2c88 <concreate+0x306>
      link("C0", file);
    29ba:	fa840593          	addi	a1,s0,-88
    29be:	855e                	mv	a0,s7
    29c0:	00003097          	auipc	ra,0x3
    29c4:	ecc080e7          	jalr	-308(ra) # 588c <link>
    if(pid == 0) {
    29c8:	a45d                	j	2c6e <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    29ca:	4795                	li	a5,5
    29cc:	02f9693b          	remw	s2,s2,a5
    29d0:	4785                	li	a5,1
    29d2:	02f90b63          	beq	s2,a5,2a08 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    29d6:	20200593          	li	a1,514
    29da:	fa840513          	addi	a0,s0,-88
    29de:	00003097          	auipc	ra,0x3
    29e2:	e8e080e7          	jalr	-370(ra) # 586c <open>
      if(fd < 0){
    29e6:	26055b63          	bgez	a0,2c5c <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    29ea:	fa840593          	addi	a1,s0,-88
    29ee:	00004517          	auipc	a0,0x4
    29f2:	12a50513          	addi	a0,a0,298 # 6b18 <malloc+0xe9e>
    29f6:	00003097          	auipc	ra,0x3
    29fa:	1c6080e7          	jalr	454(ra) # 5bbc <printf>
        exit(1);
    29fe:	4505                	li	a0,1
    2a00:	00003097          	auipc	ra,0x3
    2a04:	e2c080e7          	jalr	-468(ra) # 582c <exit>
      link("C0", file);
    2a08:	fa840593          	addi	a1,s0,-88
    2a0c:	00004517          	auipc	a0,0x4
    2a10:	10450513          	addi	a0,a0,260 # 6b10 <malloc+0xe96>
    2a14:	00003097          	auipc	ra,0x3
    2a18:	e78080e7          	jalr	-392(ra) # 588c <link>
      exit(0);
    2a1c:	4501                	li	a0,0
    2a1e:	00003097          	auipc	ra,0x3
    2a22:	e0e080e7          	jalr	-498(ra) # 582c <exit>
        exit(1);
    2a26:	4505                	li	a0,1
    2a28:	00003097          	auipc	ra,0x3
    2a2c:	e04080e7          	jalr	-508(ra) # 582c <exit>
  memset(fa, 0, sizeof(fa));
    2a30:	02800613          	li	a2,40
    2a34:	4581                	li	a1,0
    2a36:	f8040513          	addi	a0,s0,-128
    2a3a:	00003097          	auipc	ra,0x3
    2a3e:	bee080e7          	jalr	-1042(ra) # 5628 <memset>
  fd = open(".", 0);
    2a42:	4581                	li	a1,0
    2a44:	00004517          	auipc	a0,0x4
    2a48:	0a450513          	addi	a0,a0,164 # 6ae8 <malloc+0xe6e>
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	e20080e7          	jalr	-480(ra) # 586c <open>
    2a54:	892a                	mv	s2,a0
  n = 0;
    2a56:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2a58:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    2a5c:	02700b13          	li	s6,39
      fa[i] = 1;
    2a60:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    2a62:	a03d                	j	2a90 <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    2a64:	f7240613          	addi	a2,s0,-142
    2a68:	85ce                	mv	a1,s3
    2a6a:	00004517          	auipc	a0,0x4
    2a6e:	0ce50513          	addi	a0,a0,206 # 6b38 <malloc+0xebe>
    2a72:	00003097          	auipc	ra,0x3
    2a76:	14a080e7          	jalr	330(ra) # 5bbc <printf>
        exit(1);
    2a7a:	4505                	li	a0,1
    2a7c:	00003097          	auipc	ra,0x3
    2a80:	db0080e7          	jalr	-592(ra) # 582c <exit>
      fa[i] = 1;
    2a84:	fb040793          	addi	a5,s0,-80
    2a88:	973e                	add	a4,a4,a5
    2a8a:	fd770823          	sb	s7,-48(a4)
      n++;
    2a8e:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    2a90:	4641                	li	a2,16
    2a92:	f7040593          	addi	a1,s0,-144
    2a96:	854a                	mv	a0,s2
    2a98:	00003097          	auipc	ra,0x3
    2a9c:	dac080e7          	jalr	-596(ra) # 5844 <read>
    2aa0:	04a05a63          	blez	a0,2af4 <concreate+0x172>
    if(de.inum == 0)
    2aa4:	f7045783          	lhu	a5,-144(s0)
    2aa8:	d7e5                	beqz	a5,2a90 <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2aaa:	f7244783          	lbu	a5,-142(s0)
    2aae:	ff4791e3          	bne	a5,s4,2a90 <concreate+0x10e>
    2ab2:	f7444783          	lbu	a5,-140(s0)
    2ab6:	ffe9                	bnez	a5,2a90 <concreate+0x10e>
      i = de.name[1] - '0';
    2ab8:	f7344783          	lbu	a5,-141(s0)
    2abc:	fd07879b          	addiw	a5,a5,-48
    2ac0:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    2ac4:	faeb60e3          	bltu	s6,a4,2a64 <concreate+0xe2>
      if(fa[i]){
    2ac8:	fb040793          	addi	a5,s0,-80
    2acc:	97ba                	add	a5,a5,a4
    2ace:	fd07c783          	lbu	a5,-48(a5)
    2ad2:	dbcd                	beqz	a5,2a84 <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    2ad4:	f7240613          	addi	a2,s0,-142
    2ad8:	85ce                	mv	a1,s3
    2ada:	00004517          	auipc	a0,0x4
    2ade:	07e50513          	addi	a0,a0,126 # 6b58 <malloc+0xede>
    2ae2:	00003097          	auipc	ra,0x3
    2ae6:	0da080e7          	jalr	218(ra) # 5bbc <printf>
        exit(1);
    2aea:	4505                	li	a0,1
    2aec:	00003097          	auipc	ra,0x3
    2af0:	d40080e7          	jalr	-704(ra) # 582c <exit>
  close(fd);
    2af4:	854a                	mv	a0,s2
    2af6:	00003097          	auipc	ra,0x3
    2afa:	d5e080e7          	jalr	-674(ra) # 5854 <close>
  if(n != N){
    2afe:	02800793          	li	a5,40
    2b02:	00fa9763          	bne	s5,a5,2b10 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    2b06:	4a8d                	li	s5,3
    2b08:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    2b0a:	02800a13          	li	s4,40
    2b0e:	a8c9                	j	2be0 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    2b10:	85ce                	mv	a1,s3
    2b12:	00004517          	auipc	a0,0x4
    2b16:	06e50513          	addi	a0,a0,110 # 6b80 <malloc+0xf06>
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	0a2080e7          	jalr	162(ra) # 5bbc <printf>
    exit(1);
    2b22:	4505                	li	a0,1
    2b24:	00003097          	auipc	ra,0x3
    2b28:	d08080e7          	jalr	-760(ra) # 582c <exit>
      printf("%s: fork failed\n", s);
    2b2c:	85ce                	mv	a1,s3
    2b2e:	00003517          	auipc	a0,0x3
    2b32:	67250513          	addi	a0,a0,1650 # 61a0 <malloc+0x526>
    2b36:	00003097          	auipc	ra,0x3
    2b3a:	086080e7          	jalr	134(ra) # 5bbc <printf>
      exit(1);
    2b3e:	4505                	li	a0,1
    2b40:	00003097          	auipc	ra,0x3
    2b44:	cec080e7          	jalr	-788(ra) # 582c <exit>
      close(open(file, 0));
    2b48:	4581                	li	a1,0
    2b4a:	fa840513          	addi	a0,s0,-88
    2b4e:	00003097          	auipc	ra,0x3
    2b52:	d1e080e7          	jalr	-738(ra) # 586c <open>
    2b56:	00003097          	auipc	ra,0x3
    2b5a:	cfe080e7          	jalr	-770(ra) # 5854 <close>
      close(open(file, 0));
    2b5e:	4581                	li	a1,0
    2b60:	fa840513          	addi	a0,s0,-88
    2b64:	00003097          	auipc	ra,0x3
    2b68:	d08080e7          	jalr	-760(ra) # 586c <open>
    2b6c:	00003097          	auipc	ra,0x3
    2b70:	ce8080e7          	jalr	-792(ra) # 5854 <close>
      close(open(file, 0));
    2b74:	4581                	li	a1,0
    2b76:	fa840513          	addi	a0,s0,-88
    2b7a:	00003097          	auipc	ra,0x3
    2b7e:	cf2080e7          	jalr	-782(ra) # 586c <open>
    2b82:	00003097          	auipc	ra,0x3
    2b86:	cd2080e7          	jalr	-814(ra) # 5854 <close>
      close(open(file, 0));
    2b8a:	4581                	li	a1,0
    2b8c:	fa840513          	addi	a0,s0,-88
    2b90:	00003097          	auipc	ra,0x3
    2b94:	cdc080e7          	jalr	-804(ra) # 586c <open>
    2b98:	00003097          	auipc	ra,0x3
    2b9c:	cbc080e7          	jalr	-836(ra) # 5854 <close>
      close(open(file, 0));
    2ba0:	4581                	li	a1,0
    2ba2:	fa840513          	addi	a0,s0,-88
    2ba6:	00003097          	auipc	ra,0x3
    2baa:	cc6080e7          	jalr	-826(ra) # 586c <open>
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	ca6080e7          	jalr	-858(ra) # 5854 <close>
      close(open(file, 0));
    2bb6:	4581                	li	a1,0
    2bb8:	fa840513          	addi	a0,s0,-88
    2bbc:	00003097          	auipc	ra,0x3
    2bc0:	cb0080e7          	jalr	-848(ra) # 586c <open>
    2bc4:	00003097          	auipc	ra,0x3
    2bc8:	c90080e7          	jalr	-880(ra) # 5854 <close>
    if(pid == 0)
    2bcc:	08090363          	beqz	s2,2c52 <concreate+0x2d0>
      wait(0);
    2bd0:	4501                	li	a0,0
    2bd2:	00003097          	auipc	ra,0x3
    2bd6:	c62080e7          	jalr	-926(ra) # 5834 <wait>
  for(i = 0; i < N; i++){
    2bda:	2485                	addiw	s1,s1,1
    2bdc:	0f448563          	beq	s1,s4,2cc6 <concreate+0x344>
    file[1] = '0' + i;
    2be0:	0304879b          	addiw	a5,s1,48
    2be4:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    2be8:	00003097          	auipc	ra,0x3
    2bec:	c3c080e7          	jalr	-964(ra) # 5824 <fork>
    2bf0:	892a                	mv	s2,a0
    if(pid < 0){
    2bf2:	f2054de3          	bltz	a0,2b2c <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    2bf6:	0354e73b          	remw	a4,s1,s5
    2bfa:	00a767b3          	or	a5,a4,a0
    2bfe:	2781                	sext.w	a5,a5
    2c00:	d7a1                	beqz	a5,2b48 <concreate+0x1c6>
    2c02:	01671363          	bne	a4,s6,2c08 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    2c06:	f129                	bnez	a0,2b48 <concreate+0x1c6>
      unlink(file);
    2c08:	fa840513          	addi	a0,s0,-88
    2c0c:	00003097          	auipc	ra,0x3
    2c10:	c70080e7          	jalr	-912(ra) # 587c <unlink>
      unlink(file);
    2c14:	fa840513          	addi	a0,s0,-88
    2c18:	00003097          	auipc	ra,0x3
    2c1c:	c64080e7          	jalr	-924(ra) # 587c <unlink>
      unlink(file);
    2c20:	fa840513          	addi	a0,s0,-88
    2c24:	00003097          	auipc	ra,0x3
    2c28:	c58080e7          	jalr	-936(ra) # 587c <unlink>
      unlink(file);
    2c2c:	fa840513          	addi	a0,s0,-88
    2c30:	00003097          	auipc	ra,0x3
    2c34:	c4c080e7          	jalr	-948(ra) # 587c <unlink>
      unlink(file);
    2c38:	fa840513          	addi	a0,s0,-88
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	c40080e7          	jalr	-960(ra) # 587c <unlink>
      unlink(file);
    2c44:	fa840513          	addi	a0,s0,-88
    2c48:	00003097          	auipc	ra,0x3
    2c4c:	c34080e7          	jalr	-972(ra) # 587c <unlink>
    2c50:	bfb5                	j	2bcc <concreate+0x24a>
      exit(0);
    2c52:	4501                	li	a0,0
    2c54:	00003097          	auipc	ra,0x3
    2c58:	bd8080e7          	jalr	-1064(ra) # 582c <exit>
      close(fd);
    2c5c:	00003097          	auipc	ra,0x3
    2c60:	bf8080e7          	jalr	-1032(ra) # 5854 <close>
    if(pid == 0) {
    2c64:	bb65                	j	2a1c <concreate+0x9a>
      close(fd);
    2c66:	00003097          	auipc	ra,0x3
    2c6a:	bee080e7          	jalr	-1042(ra) # 5854 <close>
      wait(&xstatus);
    2c6e:	f6c40513          	addi	a0,s0,-148
    2c72:	00003097          	auipc	ra,0x3
    2c76:	bc2080e7          	jalr	-1086(ra) # 5834 <wait>
      if(xstatus != 0)
    2c7a:	f6c42483          	lw	s1,-148(s0)
    2c7e:	da0494e3          	bnez	s1,2a26 <concreate+0xa4>
  for(i = 0; i < N; i++){
    2c82:	2905                	addiw	s2,s2,1
    2c84:	db4906e3          	beq	s2,s4,2a30 <concreate+0xae>
    file[1] = '0' + i;
    2c88:	0309079b          	addiw	a5,s2,48
    2c8c:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    2c90:	fa840513          	addi	a0,s0,-88
    2c94:	00003097          	auipc	ra,0x3
    2c98:	be8080e7          	jalr	-1048(ra) # 587c <unlink>
    pid = fork();
    2c9c:	00003097          	auipc	ra,0x3
    2ca0:	b88080e7          	jalr	-1144(ra) # 5824 <fork>
    if(pid && (i % 3) == 1){
    2ca4:	d20503e3          	beqz	a0,29ca <concreate+0x48>
    2ca8:	036967bb          	remw	a5,s2,s6
    2cac:	d15787e3          	beq	a5,s5,29ba <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    2cb0:	20200593          	li	a1,514
    2cb4:	fa840513          	addi	a0,s0,-88
    2cb8:	00003097          	auipc	ra,0x3
    2cbc:	bb4080e7          	jalr	-1100(ra) # 586c <open>
      if(fd < 0){
    2cc0:	fa0553e3          	bgez	a0,2c66 <concreate+0x2e4>
    2cc4:	b31d                	j	29ea <concreate+0x68>
}
    2cc6:	60ea                	ld	ra,152(sp)
    2cc8:	644a                	ld	s0,144(sp)
    2cca:	64aa                	ld	s1,136(sp)
    2ccc:	690a                	ld	s2,128(sp)
    2cce:	79e6                	ld	s3,120(sp)
    2cd0:	7a46                	ld	s4,112(sp)
    2cd2:	7aa6                	ld	s5,104(sp)
    2cd4:	7b06                	ld	s6,96(sp)
    2cd6:	6be6                	ld	s7,88(sp)
    2cd8:	610d                	addi	sp,sp,160
    2cda:	8082                	ret

0000000000002cdc <linkunlink>:
{
    2cdc:	711d                	addi	sp,sp,-96
    2cde:	ec86                	sd	ra,88(sp)
    2ce0:	e8a2                	sd	s0,80(sp)
    2ce2:	e4a6                	sd	s1,72(sp)
    2ce4:	e0ca                	sd	s2,64(sp)
    2ce6:	fc4e                	sd	s3,56(sp)
    2ce8:	f852                	sd	s4,48(sp)
    2cea:	f456                	sd	s5,40(sp)
    2cec:	f05a                	sd	s6,32(sp)
    2cee:	ec5e                	sd	s7,24(sp)
    2cf0:	e862                	sd	s8,16(sp)
    2cf2:	e466                	sd	s9,8(sp)
    2cf4:	1080                	addi	s0,sp,96
    2cf6:	84aa                	mv	s1,a0
  unlink("x");
    2cf8:	00003517          	auipc	a0,0x3
    2cfc:	1b050513          	addi	a0,a0,432 # 5ea8 <malloc+0x22e>
    2d00:	00003097          	auipc	ra,0x3
    2d04:	b7c080e7          	jalr	-1156(ra) # 587c <unlink>
  pid = fork();
    2d08:	00003097          	auipc	ra,0x3
    2d0c:	b1c080e7          	jalr	-1252(ra) # 5824 <fork>
  if(pid < 0){
    2d10:	02054b63          	bltz	a0,2d46 <linkunlink+0x6a>
    2d14:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    2d16:	4c85                	li	s9,1
    2d18:	e119                	bnez	a0,2d1e <linkunlink+0x42>
    2d1a:	06100c93          	li	s9,97
    2d1e:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    2d22:	41c659b7          	lui	s3,0x41c65
    2d26:	e6d9899b          	addiw	s3,s3,-403
    2d2a:	690d                	lui	s2,0x3
    2d2c:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    2d30:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    2d32:	4b05                	li	s6,1
      unlink("x");
    2d34:	00003a97          	auipc	s5,0x3
    2d38:	174a8a93          	addi	s5,s5,372 # 5ea8 <malloc+0x22e>
      link("cat", "x");
    2d3c:	00004b97          	auipc	s7,0x4
    2d40:	e7cb8b93          	addi	s7,s7,-388 # 6bb8 <malloc+0xf3e>
    2d44:	a091                	j	2d88 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    2d46:	85a6                	mv	a1,s1
    2d48:	00003517          	auipc	a0,0x3
    2d4c:	45850513          	addi	a0,a0,1112 # 61a0 <malloc+0x526>
    2d50:	00003097          	auipc	ra,0x3
    2d54:	e6c080e7          	jalr	-404(ra) # 5bbc <printf>
    exit(1);
    2d58:	4505                	li	a0,1
    2d5a:	00003097          	auipc	ra,0x3
    2d5e:	ad2080e7          	jalr	-1326(ra) # 582c <exit>
      close(open("x", O_RDWR | O_CREATE));
    2d62:	20200593          	li	a1,514
    2d66:	8556                	mv	a0,s5
    2d68:	00003097          	auipc	ra,0x3
    2d6c:	b04080e7          	jalr	-1276(ra) # 586c <open>
    2d70:	00003097          	auipc	ra,0x3
    2d74:	ae4080e7          	jalr	-1308(ra) # 5854 <close>
    2d78:	a031                	j	2d84 <linkunlink+0xa8>
      unlink("x");
    2d7a:	8556                	mv	a0,s5
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	b00080e7          	jalr	-1280(ra) # 587c <unlink>
  for(i = 0; i < 100; i++){
    2d84:	34fd                	addiw	s1,s1,-1
    2d86:	c09d                	beqz	s1,2dac <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2d88:	033c87bb          	mulw	a5,s9,s3
    2d8c:	012787bb          	addw	a5,a5,s2
    2d90:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2d94:	0347f7bb          	remuw	a5,a5,s4
    2d98:	d7e9                	beqz	a5,2d62 <linkunlink+0x86>
    } else if((x % 3) == 1){
    2d9a:	ff6790e3          	bne	a5,s6,2d7a <linkunlink+0x9e>
      link("cat", "x");
    2d9e:	85d6                	mv	a1,s5
    2da0:	855e                	mv	a0,s7
    2da2:	00003097          	auipc	ra,0x3
    2da6:	aea080e7          	jalr	-1302(ra) # 588c <link>
    2daa:	bfe9                	j	2d84 <linkunlink+0xa8>
  if(pid)
    2dac:	020c0463          	beqz	s8,2dd4 <linkunlink+0xf8>
    wait(0);
    2db0:	4501                	li	a0,0
    2db2:	00003097          	auipc	ra,0x3
    2db6:	a82080e7          	jalr	-1406(ra) # 5834 <wait>
}
    2dba:	60e6                	ld	ra,88(sp)
    2dbc:	6446                	ld	s0,80(sp)
    2dbe:	64a6                	ld	s1,72(sp)
    2dc0:	6906                	ld	s2,64(sp)
    2dc2:	79e2                	ld	s3,56(sp)
    2dc4:	7a42                	ld	s4,48(sp)
    2dc6:	7aa2                	ld	s5,40(sp)
    2dc8:	7b02                	ld	s6,32(sp)
    2dca:	6be2                	ld	s7,24(sp)
    2dcc:	6c42                	ld	s8,16(sp)
    2dce:	6ca2                	ld	s9,8(sp)
    2dd0:	6125                	addi	sp,sp,96
    2dd2:	8082                	ret
    exit(0);
    2dd4:	4501                	li	a0,0
    2dd6:	00003097          	auipc	ra,0x3
    2dda:	a56080e7          	jalr	-1450(ra) # 582c <exit>

0000000000002dde <bigdir>:
{
    2dde:	715d                	addi	sp,sp,-80
    2de0:	e486                	sd	ra,72(sp)
    2de2:	e0a2                	sd	s0,64(sp)
    2de4:	fc26                	sd	s1,56(sp)
    2de6:	f84a                	sd	s2,48(sp)
    2de8:	f44e                	sd	s3,40(sp)
    2dea:	f052                	sd	s4,32(sp)
    2dec:	ec56                	sd	s5,24(sp)
    2dee:	e85a                	sd	s6,16(sp)
    2df0:	0880                	addi	s0,sp,80
    2df2:	89aa                	mv	s3,a0
  unlink("bd");
    2df4:	00004517          	auipc	a0,0x4
    2df8:	dcc50513          	addi	a0,a0,-564 # 6bc0 <malloc+0xf46>
    2dfc:	00003097          	auipc	ra,0x3
    2e00:	a80080e7          	jalr	-1408(ra) # 587c <unlink>
  fd = open("bd", O_CREATE);
    2e04:	20000593          	li	a1,512
    2e08:	00004517          	auipc	a0,0x4
    2e0c:	db850513          	addi	a0,a0,-584 # 6bc0 <malloc+0xf46>
    2e10:	00003097          	auipc	ra,0x3
    2e14:	a5c080e7          	jalr	-1444(ra) # 586c <open>
  if(fd < 0){
    2e18:	0c054963          	bltz	a0,2eea <bigdir+0x10c>
  close(fd);
    2e1c:	00003097          	auipc	ra,0x3
    2e20:	a38080e7          	jalr	-1480(ra) # 5854 <close>
  for(i = 0; i < N; i++){
    2e24:	4901                	li	s2,0
    name[0] = 'x';
    2e26:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    2e2a:	00004a17          	auipc	s4,0x4
    2e2e:	d96a0a13          	addi	s4,s4,-618 # 6bc0 <malloc+0xf46>
  for(i = 0; i < N; i++){
    2e32:	1f400b13          	li	s6,500
    name[0] = 'x';
    2e36:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    2e3a:	41f9579b          	sraiw	a5,s2,0x1f
    2e3e:	01a7d71b          	srliw	a4,a5,0x1a
    2e42:	012707bb          	addw	a5,a4,s2
    2e46:	4067d69b          	sraiw	a3,a5,0x6
    2e4a:	0306869b          	addiw	a3,a3,48
    2e4e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2e52:	03f7f793          	andi	a5,a5,63
    2e56:	9f99                	subw	a5,a5,a4
    2e58:	0307879b          	addiw	a5,a5,48
    2e5c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2e60:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    2e64:	fb040593          	addi	a1,s0,-80
    2e68:	8552                	mv	a0,s4
    2e6a:	00003097          	auipc	ra,0x3
    2e6e:	a22080e7          	jalr	-1502(ra) # 588c <link>
    2e72:	84aa                	mv	s1,a0
    2e74:	e949                	bnez	a0,2f06 <bigdir+0x128>
  for(i = 0; i < N; i++){
    2e76:	2905                	addiw	s2,s2,1
    2e78:	fb691fe3          	bne	s2,s6,2e36 <bigdir+0x58>
  unlink("bd");
    2e7c:	00004517          	auipc	a0,0x4
    2e80:	d4450513          	addi	a0,a0,-700 # 6bc0 <malloc+0xf46>
    2e84:	00003097          	auipc	ra,0x3
    2e88:	9f8080e7          	jalr	-1544(ra) # 587c <unlink>
    name[0] = 'x';
    2e8c:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    2e90:	1f400a13          	li	s4,500
    name[0] = 'x';
    2e94:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    2e98:	41f4d79b          	sraiw	a5,s1,0x1f
    2e9c:	01a7d71b          	srliw	a4,a5,0x1a
    2ea0:	009707bb          	addw	a5,a4,s1
    2ea4:	4067d69b          	sraiw	a3,a5,0x6
    2ea8:	0306869b          	addiw	a3,a3,48
    2eac:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2eb0:	03f7f793          	andi	a5,a5,63
    2eb4:	9f99                	subw	a5,a5,a4
    2eb6:	0307879b          	addiw	a5,a5,48
    2eba:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2ebe:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    2ec2:	fb040513          	addi	a0,s0,-80
    2ec6:	00003097          	auipc	ra,0x3
    2eca:	9b6080e7          	jalr	-1610(ra) # 587c <unlink>
    2ece:	ed21                	bnez	a0,2f26 <bigdir+0x148>
  for(i = 0; i < N; i++){
    2ed0:	2485                	addiw	s1,s1,1
    2ed2:	fd4491e3          	bne	s1,s4,2e94 <bigdir+0xb6>
}
    2ed6:	60a6                	ld	ra,72(sp)
    2ed8:	6406                	ld	s0,64(sp)
    2eda:	74e2                	ld	s1,56(sp)
    2edc:	7942                	ld	s2,48(sp)
    2ede:	79a2                	ld	s3,40(sp)
    2ee0:	7a02                	ld	s4,32(sp)
    2ee2:	6ae2                	ld	s5,24(sp)
    2ee4:	6b42                	ld	s6,16(sp)
    2ee6:	6161                	addi	sp,sp,80
    2ee8:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    2eea:	85ce                	mv	a1,s3
    2eec:	00004517          	auipc	a0,0x4
    2ef0:	cdc50513          	addi	a0,a0,-804 # 6bc8 <malloc+0xf4e>
    2ef4:	00003097          	auipc	ra,0x3
    2ef8:	cc8080e7          	jalr	-824(ra) # 5bbc <printf>
    exit(1);
    2efc:	4505                	li	a0,1
    2efe:	00003097          	auipc	ra,0x3
    2f02:	92e080e7          	jalr	-1746(ra) # 582c <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    2f06:	fb040613          	addi	a2,s0,-80
    2f0a:	85ce                	mv	a1,s3
    2f0c:	00004517          	auipc	a0,0x4
    2f10:	cdc50513          	addi	a0,a0,-804 # 6be8 <malloc+0xf6e>
    2f14:	00003097          	auipc	ra,0x3
    2f18:	ca8080e7          	jalr	-856(ra) # 5bbc <printf>
      exit(1);
    2f1c:	4505                	li	a0,1
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	90e080e7          	jalr	-1778(ra) # 582c <exit>
      printf("%s: bigdir unlink failed", s);
    2f26:	85ce                	mv	a1,s3
    2f28:	00004517          	auipc	a0,0x4
    2f2c:	ce050513          	addi	a0,a0,-800 # 6c08 <malloc+0xf8e>
    2f30:	00003097          	auipc	ra,0x3
    2f34:	c8c080e7          	jalr	-884(ra) # 5bbc <printf>
      exit(1);
    2f38:	4505                	li	a0,1
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	8f2080e7          	jalr	-1806(ra) # 582c <exit>

0000000000002f42 <subdir>:
{
    2f42:	1101                	addi	sp,sp,-32
    2f44:	ec06                	sd	ra,24(sp)
    2f46:	e822                	sd	s0,16(sp)
    2f48:	e426                	sd	s1,8(sp)
    2f4a:	e04a                	sd	s2,0(sp)
    2f4c:	1000                	addi	s0,sp,32
    2f4e:	892a                	mv	s2,a0
  unlink("ff");
    2f50:	00004517          	auipc	a0,0x4
    2f54:	e0850513          	addi	a0,a0,-504 # 6d58 <malloc+0x10de>
    2f58:	00003097          	auipc	ra,0x3
    2f5c:	924080e7          	jalr	-1756(ra) # 587c <unlink>
  if(mkdir("dd") != 0){
    2f60:	00004517          	auipc	a0,0x4
    2f64:	cc850513          	addi	a0,a0,-824 # 6c28 <malloc+0xfae>
    2f68:	00003097          	auipc	ra,0x3
    2f6c:	92c080e7          	jalr	-1748(ra) # 5894 <mkdir>
    2f70:	38051663          	bnez	a0,32fc <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2f74:	20200593          	li	a1,514
    2f78:	00004517          	auipc	a0,0x4
    2f7c:	cd050513          	addi	a0,a0,-816 # 6c48 <malloc+0xfce>
    2f80:	00003097          	auipc	ra,0x3
    2f84:	8ec080e7          	jalr	-1812(ra) # 586c <open>
    2f88:	84aa                	mv	s1,a0
  if(fd < 0){
    2f8a:	38054763          	bltz	a0,3318 <subdir+0x3d6>
  write(fd, "ff", 2);
    2f8e:	4609                	li	a2,2
    2f90:	00004597          	auipc	a1,0x4
    2f94:	dc858593          	addi	a1,a1,-568 # 6d58 <malloc+0x10de>
    2f98:	00003097          	auipc	ra,0x3
    2f9c:	8b4080e7          	jalr	-1868(ra) # 584c <write>
  close(fd);
    2fa0:	8526                	mv	a0,s1
    2fa2:	00003097          	auipc	ra,0x3
    2fa6:	8b2080e7          	jalr	-1870(ra) # 5854 <close>
  if(unlink("dd") >= 0){
    2faa:	00004517          	auipc	a0,0x4
    2fae:	c7e50513          	addi	a0,a0,-898 # 6c28 <malloc+0xfae>
    2fb2:	00003097          	auipc	ra,0x3
    2fb6:	8ca080e7          	jalr	-1846(ra) # 587c <unlink>
    2fba:	36055d63          	bgez	a0,3334 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2fbe:	00004517          	auipc	a0,0x4
    2fc2:	ce250513          	addi	a0,a0,-798 # 6ca0 <malloc+0x1026>
    2fc6:	00003097          	auipc	ra,0x3
    2fca:	8ce080e7          	jalr	-1842(ra) # 5894 <mkdir>
    2fce:	38051163          	bnez	a0,3350 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2fd2:	20200593          	li	a1,514
    2fd6:	00004517          	auipc	a0,0x4
    2fda:	cf250513          	addi	a0,a0,-782 # 6cc8 <malloc+0x104e>
    2fde:	00003097          	auipc	ra,0x3
    2fe2:	88e080e7          	jalr	-1906(ra) # 586c <open>
    2fe6:	84aa                	mv	s1,a0
  if(fd < 0){
    2fe8:	38054263          	bltz	a0,336c <subdir+0x42a>
  write(fd, "FF", 2);
    2fec:	4609                	li	a2,2
    2fee:	00004597          	auipc	a1,0x4
    2ff2:	d0a58593          	addi	a1,a1,-758 # 6cf8 <malloc+0x107e>
    2ff6:	00003097          	auipc	ra,0x3
    2ffa:	856080e7          	jalr	-1962(ra) # 584c <write>
  close(fd);
    2ffe:	8526                	mv	a0,s1
    3000:	00003097          	auipc	ra,0x3
    3004:	854080e7          	jalr	-1964(ra) # 5854 <close>
  fd = open("dd/dd/../ff", 0);
    3008:	4581                	li	a1,0
    300a:	00004517          	auipc	a0,0x4
    300e:	cf650513          	addi	a0,a0,-778 # 6d00 <malloc+0x1086>
    3012:	00003097          	auipc	ra,0x3
    3016:	85a080e7          	jalr	-1958(ra) # 586c <open>
    301a:	84aa                	mv	s1,a0
  if(fd < 0){
    301c:	36054663          	bltz	a0,3388 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3020:	660d                	lui	a2,0x3
    3022:	00008597          	auipc	a1,0x8
    3026:	6b658593          	addi	a1,a1,1718 # b6d8 <buf>
    302a:	00003097          	auipc	ra,0x3
    302e:	81a080e7          	jalr	-2022(ra) # 5844 <read>
  if(cc != 2 || buf[0] != 'f'){
    3032:	4789                	li	a5,2
    3034:	36f51863          	bne	a0,a5,33a4 <subdir+0x462>
    3038:	00008717          	auipc	a4,0x8
    303c:	6a074703          	lbu	a4,1696(a4) # b6d8 <buf>
    3040:	06600793          	li	a5,102
    3044:	36f71063          	bne	a4,a5,33a4 <subdir+0x462>
  close(fd);
    3048:	8526                	mv	a0,s1
    304a:	00003097          	auipc	ra,0x3
    304e:	80a080e7          	jalr	-2038(ra) # 5854 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3052:	00004597          	auipc	a1,0x4
    3056:	cfe58593          	addi	a1,a1,-770 # 6d50 <malloc+0x10d6>
    305a:	00004517          	auipc	a0,0x4
    305e:	c6e50513          	addi	a0,a0,-914 # 6cc8 <malloc+0x104e>
    3062:	00003097          	auipc	ra,0x3
    3066:	82a080e7          	jalr	-2006(ra) # 588c <link>
    306a:	34051b63          	bnez	a0,33c0 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    306e:	00004517          	auipc	a0,0x4
    3072:	c5a50513          	addi	a0,a0,-934 # 6cc8 <malloc+0x104e>
    3076:	00003097          	auipc	ra,0x3
    307a:	806080e7          	jalr	-2042(ra) # 587c <unlink>
    307e:	34051f63          	bnez	a0,33dc <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3082:	4581                	li	a1,0
    3084:	00004517          	auipc	a0,0x4
    3088:	c4450513          	addi	a0,a0,-956 # 6cc8 <malloc+0x104e>
    308c:	00002097          	auipc	ra,0x2
    3090:	7e0080e7          	jalr	2016(ra) # 586c <open>
    3094:	36055263          	bgez	a0,33f8 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3098:	00004517          	auipc	a0,0x4
    309c:	b9050513          	addi	a0,a0,-1136 # 6c28 <malloc+0xfae>
    30a0:	00002097          	auipc	ra,0x2
    30a4:	7fc080e7          	jalr	2044(ra) # 589c <chdir>
    30a8:	36051663          	bnez	a0,3414 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    30ac:	00004517          	auipc	a0,0x4
    30b0:	d3c50513          	addi	a0,a0,-708 # 6de8 <malloc+0x116e>
    30b4:	00002097          	auipc	ra,0x2
    30b8:	7e8080e7          	jalr	2024(ra) # 589c <chdir>
    30bc:	36051a63          	bnez	a0,3430 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    30c0:	00004517          	auipc	a0,0x4
    30c4:	d5850513          	addi	a0,a0,-680 # 6e18 <malloc+0x119e>
    30c8:	00002097          	auipc	ra,0x2
    30cc:	7d4080e7          	jalr	2004(ra) # 589c <chdir>
    30d0:	36051e63          	bnez	a0,344c <subdir+0x50a>
  if(chdir("./..") != 0){
    30d4:	00004517          	auipc	a0,0x4
    30d8:	d7450513          	addi	a0,a0,-652 # 6e48 <malloc+0x11ce>
    30dc:	00002097          	auipc	ra,0x2
    30e0:	7c0080e7          	jalr	1984(ra) # 589c <chdir>
    30e4:	38051263          	bnez	a0,3468 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    30e8:	4581                	li	a1,0
    30ea:	00004517          	auipc	a0,0x4
    30ee:	c6650513          	addi	a0,a0,-922 # 6d50 <malloc+0x10d6>
    30f2:	00002097          	auipc	ra,0x2
    30f6:	77a080e7          	jalr	1914(ra) # 586c <open>
    30fa:	84aa                	mv	s1,a0
  if(fd < 0){
    30fc:	38054463          	bltz	a0,3484 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3100:	660d                	lui	a2,0x3
    3102:	00008597          	auipc	a1,0x8
    3106:	5d658593          	addi	a1,a1,1494 # b6d8 <buf>
    310a:	00002097          	auipc	ra,0x2
    310e:	73a080e7          	jalr	1850(ra) # 5844 <read>
    3112:	4789                	li	a5,2
    3114:	38f51663          	bne	a0,a5,34a0 <subdir+0x55e>
  close(fd);
    3118:	8526                	mv	a0,s1
    311a:	00002097          	auipc	ra,0x2
    311e:	73a080e7          	jalr	1850(ra) # 5854 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3122:	4581                	li	a1,0
    3124:	00004517          	auipc	a0,0x4
    3128:	ba450513          	addi	a0,a0,-1116 # 6cc8 <malloc+0x104e>
    312c:	00002097          	auipc	ra,0x2
    3130:	740080e7          	jalr	1856(ra) # 586c <open>
    3134:	38055463          	bgez	a0,34bc <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3138:	20200593          	li	a1,514
    313c:	00004517          	auipc	a0,0x4
    3140:	d9c50513          	addi	a0,a0,-612 # 6ed8 <malloc+0x125e>
    3144:	00002097          	auipc	ra,0x2
    3148:	728080e7          	jalr	1832(ra) # 586c <open>
    314c:	38055663          	bgez	a0,34d8 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3150:	20200593          	li	a1,514
    3154:	00004517          	auipc	a0,0x4
    3158:	db450513          	addi	a0,a0,-588 # 6f08 <malloc+0x128e>
    315c:	00002097          	auipc	ra,0x2
    3160:	710080e7          	jalr	1808(ra) # 586c <open>
    3164:	38055863          	bgez	a0,34f4 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3168:	20000593          	li	a1,512
    316c:	00004517          	auipc	a0,0x4
    3170:	abc50513          	addi	a0,a0,-1348 # 6c28 <malloc+0xfae>
    3174:	00002097          	auipc	ra,0x2
    3178:	6f8080e7          	jalr	1784(ra) # 586c <open>
    317c:	38055a63          	bgez	a0,3510 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3180:	4589                	li	a1,2
    3182:	00004517          	auipc	a0,0x4
    3186:	aa650513          	addi	a0,a0,-1370 # 6c28 <malloc+0xfae>
    318a:	00002097          	auipc	ra,0x2
    318e:	6e2080e7          	jalr	1762(ra) # 586c <open>
    3192:	38055d63          	bgez	a0,352c <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3196:	4585                	li	a1,1
    3198:	00004517          	auipc	a0,0x4
    319c:	a9050513          	addi	a0,a0,-1392 # 6c28 <malloc+0xfae>
    31a0:	00002097          	auipc	ra,0x2
    31a4:	6cc080e7          	jalr	1740(ra) # 586c <open>
    31a8:	3a055063          	bgez	a0,3548 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    31ac:	00004597          	auipc	a1,0x4
    31b0:	dec58593          	addi	a1,a1,-532 # 6f98 <malloc+0x131e>
    31b4:	00004517          	auipc	a0,0x4
    31b8:	d2450513          	addi	a0,a0,-732 # 6ed8 <malloc+0x125e>
    31bc:	00002097          	auipc	ra,0x2
    31c0:	6d0080e7          	jalr	1744(ra) # 588c <link>
    31c4:	3a050063          	beqz	a0,3564 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    31c8:	00004597          	auipc	a1,0x4
    31cc:	dd058593          	addi	a1,a1,-560 # 6f98 <malloc+0x131e>
    31d0:	00004517          	auipc	a0,0x4
    31d4:	d3850513          	addi	a0,a0,-712 # 6f08 <malloc+0x128e>
    31d8:	00002097          	auipc	ra,0x2
    31dc:	6b4080e7          	jalr	1716(ra) # 588c <link>
    31e0:	3a050063          	beqz	a0,3580 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    31e4:	00004597          	auipc	a1,0x4
    31e8:	b6c58593          	addi	a1,a1,-1172 # 6d50 <malloc+0x10d6>
    31ec:	00004517          	auipc	a0,0x4
    31f0:	a5c50513          	addi	a0,a0,-1444 # 6c48 <malloc+0xfce>
    31f4:	00002097          	auipc	ra,0x2
    31f8:	698080e7          	jalr	1688(ra) # 588c <link>
    31fc:	3a050063          	beqz	a0,359c <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3200:	00004517          	auipc	a0,0x4
    3204:	cd850513          	addi	a0,a0,-808 # 6ed8 <malloc+0x125e>
    3208:	00002097          	auipc	ra,0x2
    320c:	68c080e7          	jalr	1676(ra) # 5894 <mkdir>
    3210:	3a050463          	beqz	a0,35b8 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3214:	00004517          	auipc	a0,0x4
    3218:	cf450513          	addi	a0,a0,-780 # 6f08 <malloc+0x128e>
    321c:	00002097          	auipc	ra,0x2
    3220:	678080e7          	jalr	1656(ra) # 5894 <mkdir>
    3224:	3a050863          	beqz	a0,35d4 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3228:	00004517          	auipc	a0,0x4
    322c:	b2850513          	addi	a0,a0,-1240 # 6d50 <malloc+0x10d6>
    3230:	00002097          	auipc	ra,0x2
    3234:	664080e7          	jalr	1636(ra) # 5894 <mkdir>
    3238:	3a050c63          	beqz	a0,35f0 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    323c:	00004517          	auipc	a0,0x4
    3240:	ccc50513          	addi	a0,a0,-820 # 6f08 <malloc+0x128e>
    3244:	00002097          	auipc	ra,0x2
    3248:	638080e7          	jalr	1592(ra) # 587c <unlink>
    324c:	3c050063          	beqz	a0,360c <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3250:	00004517          	auipc	a0,0x4
    3254:	c8850513          	addi	a0,a0,-888 # 6ed8 <malloc+0x125e>
    3258:	00002097          	auipc	ra,0x2
    325c:	624080e7          	jalr	1572(ra) # 587c <unlink>
    3260:	3c050463          	beqz	a0,3628 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3264:	00004517          	auipc	a0,0x4
    3268:	9e450513          	addi	a0,a0,-1564 # 6c48 <malloc+0xfce>
    326c:	00002097          	auipc	ra,0x2
    3270:	630080e7          	jalr	1584(ra) # 589c <chdir>
    3274:	3c050863          	beqz	a0,3644 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3278:	00004517          	auipc	a0,0x4
    327c:	e7050513          	addi	a0,a0,-400 # 70e8 <malloc+0x146e>
    3280:	00002097          	auipc	ra,0x2
    3284:	61c080e7          	jalr	1564(ra) # 589c <chdir>
    3288:	3c050c63          	beqz	a0,3660 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    328c:	00004517          	auipc	a0,0x4
    3290:	ac450513          	addi	a0,a0,-1340 # 6d50 <malloc+0x10d6>
    3294:	00002097          	auipc	ra,0x2
    3298:	5e8080e7          	jalr	1512(ra) # 587c <unlink>
    329c:	3e051063          	bnez	a0,367c <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    32a0:	00004517          	auipc	a0,0x4
    32a4:	9a850513          	addi	a0,a0,-1624 # 6c48 <malloc+0xfce>
    32a8:	00002097          	auipc	ra,0x2
    32ac:	5d4080e7          	jalr	1492(ra) # 587c <unlink>
    32b0:	3e051463          	bnez	a0,3698 <subdir+0x756>
  if(unlink("dd") == 0){
    32b4:	00004517          	auipc	a0,0x4
    32b8:	97450513          	addi	a0,a0,-1676 # 6c28 <malloc+0xfae>
    32bc:	00002097          	auipc	ra,0x2
    32c0:	5c0080e7          	jalr	1472(ra) # 587c <unlink>
    32c4:	3e050863          	beqz	a0,36b4 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    32c8:	00004517          	auipc	a0,0x4
    32cc:	e9050513          	addi	a0,a0,-368 # 7158 <malloc+0x14de>
    32d0:	00002097          	auipc	ra,0x2
    32d4:	5ac080e7          	jalr	1452(ra) # 587c <unlink>
    32d8:	3e054c63          	bltz	a0,36d0 <subdir+0x78e>
  if(unlink("dd") < 0){
    32dc:	00004517          	auipc	a0,0x4
    32e0:	94c50513          	addi	a0,a0,-1716 # 6c28 <malloc+0xfae>
    32e4:	00002097          	auipc	ra,0x2
    32e8:	598080e7          	jalr	1432(ra) # 587c <unlink>
    32ec:	40054063          	bltz	a0,36ec <subdir+0x7aa>
}
    32f0:	60e2                	ld	ra,24(sp)
    32f2:	6442                	ld	s0,16(sp)
    32f4:	64a2                	ld	s1,8(sp)
    32f6:	6902                	ld	s2,0(sp)
    32f8:	6105                	addi	sp,sp,32
    32fa:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    32fc:	85ca                	mv	a1,s2
    32fe:	00004517          	auipc	a0,0x4
    3302:	93250513          	addi	a0,a0,-1742 # 6c30 <malloc+0xfb6>
    3306:	00003097          	auipc	ra,0x3
    330a:	8b6080e7          	jalr	-1866(ra) # 5bbc <printf>
    exit(1);
    330e:	4505                	li	a0,1
    3310:	00002097          	auipc	ra,0x2
    3314:	51c080e7          	jalr	1308(ra) # 582c <exit>
    printf("%s: create dd/ff failed\n", s);
    3318:	85ca                	mv	a1,s2
    331a:	00004517          	auipc	a0,0x4
    331e:	93650513          	addi	a0,a0,-1738 # 6c50 <malloc+0xfd6>
    3322:	00003097          	auipc	ra,0x3
    3326:	89a080e7          	jalr	-1894(ra) # 5bbc <printf>
    exit(1);
    332a:	4505                	li	a0,1
    332c:	00002097          	auipc	ra,0x2
    3330:	500080e7          	jalr	1280(ra) # 582c <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3334:	85ca                	mv	a1,s2
    3336:	00004517          	auipc	a0,0x4
    333a:	93a50513          	addi	a0,a0,-1734 # 6c70 <malloc+0xff6>
    333e:	00003097          	auipc	ra,0x3
    3342:	87e080e7          	jalr	-1922(ra) # 5bbc <printf>
    exit(1);
    3346:	4505                	li	a0,1
    3348:	00002097          	auipc	ra,0x2
    334c:	4e4080e7          	jalr	1252(ra) # 582c <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3350:	85ca                	mv	a1,s2
    3352:	00004517          	auipc	a0,0x4
    3356:	95650513          	addi	a0,a0,-1706 # 6ca8 <malloc+0x102e>
    335a:	00003097          	auipc	ra,0x3
    335e:	862080e7          	jalr	-1950(ra) # 5bbc <printf>
    exit(1);
    3362:	4505                	li	a0,1
    3364:	00002097          	auipc	ra,0x2
    3368:	4c8080e7          	jalr	1224(ra) # 582c <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    336c:	85ca                	mv	a1,s2
    336e:	00004517          	auipc	a0,0x4
    3372:	96a50513          	addi	a0,a0,-1686 # 6cd8 <malloc+0x105e>
    3376:	00003097          	auipc	ra,0x3
    337a:	846080e7          	jalr	-1978(ra) # 5bbc <printf>
    exit(1);
    337e:	4505                	li	a0,1
    3380:	00002097          	auipc	ra,0x2
    3384:	4ac080e7          	jalr	1196(ra) # 582c <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3388:	85ca                	mv	a1,s2
    338a:	00004517          	auipc	a0,0x4
    338e:	98650513          	addi	a0,a0,-1658 # 6d10 <malloc+0x1096>
    3392:	00003097          	auipc	ra,0x3
    3396:	82a080e7          	jalr	-2006(ra) # 5bbc <printf>
    exit(1);
    339a:	4505                	li	a0,1
    339c:	00002097          	auipc	ra,0x2
    33a0:	490080e7          	jalr	1168(ra) # 582c <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    33a4:	85ca                	mv	a1,s2
    33a6:	00004517          	auipc	a0,0x4
    33aa:	98a50513          	addi	a0,a0,-1654 # 6d30 <malloc+0x10b6>
    33ae:	00003097          	auipc	ra,0x3
    33b2:	80e080e7          	jalr	-2034(ra) # 5bbc <printf>
    exit(1);
    33b6:	4505                	li	a0,1
    33b8:	00002097          	auipc	ra,0x2
    33bc:	474080e7          	jalr	1140(ra) # 582c <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    33c0:	85ca                	mv	a1,s2
    33c2:	00004517          	auipc	a0,0x4
    33c6:	99e50513          	addi	a0,a0,-1634 # 6d60 <malloc+0x10e6>
    33ca:	00002097          	auipc	ra,0x2
    33ce:	7f2080e7          	jalr	2034(ra) # 5bbc <printf>
    exit(1);
    33d2:	4505                	li	a0,1
    33d4:	00002097          	auipc	ra,0x2
    33d8:	458080e7          	jalr	1112(ra) # 582c <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    33dc:	85ca                	mv	a1,s2
    33de:	00004517          	auipc	a0,0x4
    33e2:	9aa50513          	addi	a0,a0,-1622 # 6d88 <malloc+0x110e>
    33e6:	00002097          	auipc	ra,0x2
    33ea:	7d6080e7          	jalr	2006(ra) # 5bbc <printf>
    exit(1);
    33ee:	4505                	li	a0,1
    33f0:	00002097          	auipc	ra,0x2
    33f4:	43c080e7          	jalr	1084(ra) # 582c <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    33f8:	85ca                	mv	a1,s2
    33fa:	00004517          	auipc	a0,0x4
    33fe:	9ae50513          	addi	a0,a0,-1618 # 6da8 <malloc+0x112e>
    3402:	00002097          	auipc	ra,0x2
    3406:	7ba080e7          	jalr	1978(ra) # 5bbc <printf>
    exit(1);
    340a:	4505                	li	a0,1
    340c:	00002097          	auipc	ra,0x2
    3410:	420080e7          	jalr	1056(ra) # 582c <exit>
    printf("%s: chdir dd failed\n", s);
    3414:	85ca                	mv	a1,s2
    3416:	00004517          	auipc	a0,0x4
    341a:	9ba50513          	addi	a0,a0,-1606 # 6dd0 <malloc+0x1156>
    341e:	00002097          	auipc	ra,0x2
    3422:	79e080e7          	jalr	1950(ra) # 5bbc <printf>
    exit(1);
    3426:	4505                	li	a0,1
    3428:	00002097          	auipc	ra,0x2
    342c:	404080e7          	jalr	1028(ra) # 582c <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3430:	85ca                	mv	a1,s2
    3432:	00004517          	auipc	a0,0x4
    3436:	9c650513          	addi	a0,a0,-1594 # 6df8 <malloc+0x117e>
    343a:	00002097          	auipc	ra,0x2
    343e:	782080e7          	jalr	1922(ra) # 5bbc <printf>
    exit(1);
    3442:	4505                	li	a0,1
    3444:	00002097          	auipc	ra,0x2
    3448:	3e8080e7          	jalr	1000(ra) # 582c <exit>
    printf("chdir dd/../../dd failed\n", s);
    344c:	85ca                	mv	a1,s2
    344e:	00004517          	auipc	a0,0x4
    3452:	9da50513          	addi	a0,a0,-1574 # 6e28 <malloc+0x11ae>
    3456:	00002097          	auipc	ra,0x2
    345a:	766080e7          	jalr	1894(ra) # 5bbc <printf>
    exit(1);
    345e:	4505                	li	a0,1
    3460:	00002097          	auipc	ra,0x2
    3464:	3cc080e7          	jalr	972(ra) # 582c <exit>
    printf("%s: chdir ./.. failed\n", s);
    3468:	85ca                	mv	a1,s2
    346a:	00004517          	auipc	a0,0x4
    346e:	9e650513          	addi	a0,a0,-1562 # 6e50 <malloc+0x11d6>
    3472:	00002097          	auipc	ra,0x2
    3476:	74a080e7          	jalr	1866(ra) # 5bbc <printf>
    exit(1);
    347a:	4505                	li	a0,1
    347c:	00002097          	auipc	ra,0x2
    3480:	3b0080e7          	jalr	944(ra) # 582c <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3484:	85ca                	mv	a1,s2
    3486:	00004517          	auipc	a0,0x4
    348a:	9e250513          	addi	a0,a0,-1566 # 6e68 <malloc+0x11ee>
    348e:	00002097          	auipc	ra,0x2
    3492:	72e080e7          	jalr	1838(ra) # 5bbc <printf>
    exit(1);
    3496:	4505                	li	a0,1
    3498:	00002097          	auipc	ra,0x2
    349c:	394080e7          	jalr	916(ra) # 582c <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    34a0:	85ca                	mv	a1,s2
    34a2:	00004517          	auipc	a0,0x4
    34a6:	9e650513          	addi	a0,a0,-1562 # 6e88 <malloc+0x120e>
    34aa:	00002097          	auipc	ra,0x2
    34ae:	712080e7          	jalr	1810(ra) # 5bbc <printf>
    exit(1);
    34b2:	4505                	li	a0,1
    34b4:	00002097          	auipc	ra,0x2
    34b8:	378080e7          	jalr	888(ra) # 582c <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    34bc:	85ca                	mv	a1,s2
    34be:	00004517          	auipc	a0,0x4
    34c2:	9ea50513          	addi	a0,a0,-1558 # 6ea8 <malloc+0x122e>
    34c6:	00002097          	auipc	ra,0x2
    34ca:	6f6080e7          	jalr	1782(ra) # 5bbc <printf>
    exit(1);
    34ce:	4505                	li	a0,1
    34d0:	00002097          	auipc	ra,0x2
    34d4:	35c080e7          	jalr	860(ra) # 582c <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    34d8:	85ca                	mv	a1,s2
    34da:	00004517          	auipc	a0,0x4
    34de:	a0e50513          	addi	a0,a0,-1522 # 6ee8 <malloc+0x126e>
    34e2:	00002097          	auipc	ra,0x2
    34e6:	6da080e7          	jalr	1754(ra) # 5bbc <printf>
    exit(1);
    34ea:	4505                	li	a0,1
    34ec:	00002097          	auipc	ra,0x2
    34f0:	340080e7          	jalr	832(ra) # 582c <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    34f4:	85ca                	mv	a1,s2
    34f6:	00004517          	auipc	a0,0x4
    34fa:	a2250513          	addi	a0,a0,-1502 # 6f18 <malloc+0x129e>
    34fe:	00002097          	auipc	ra,0x2
    3502:	6be080e7          	jalr	1726(ra) # 5bbc <printf>
    exit(1);
    3506:	4505                	li	a0,1
    3508:	00002097          	auipc	ra,0x2
    350c:	324080e7          	jalr	804(ra) # 582c <exit>
    printf("%s: create dd succeeded!\n", s);
    3510:	85ca                	mv	a1,s2
    3512:	00004517          	auipc	a0,0x4
    3516:	a2650513          	addi	a0,a0,-1498 # 6f38 <malloc+0x12be>
    351a:	00002097          	auipc	ra,0x2
    351e:	6a2080e7          	jalr	1698(ra) # 5bbc <printf>
    exit(1);
    3522:	4505                	li	a0,1
    3524:	00002097          	auipc	ra,0x2
    3528:	308080e7          	jalr	776(ra) # 582c <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    352c:	85ca                	mv	a1,s2
    352e:	00004517          	auipc	a0,0x4
    3532:	a2a50513          	addi	a0,a0,-1494 # 6f58 <malloc+0x12de>
    3536:	00002097          	auipc	ra,0x2
    353a:	686080e7          	jalr	1670(ra) # 5bbc <printf>
    exit(1);
    353e:	4505                	li	a0,1
    3540:	00002097          	auipc	ra,0x2
    3544:	2ec080e7          	jalr	748(ra) # 582c <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3548:	85ca                	mv	a1,s2
    354a:	00004517          	auipc	a0,0x4
    354e:	a2e50513          	addi	a0,a0,-1490 # 6f78 <malloc+0x12fe>
    3552:	00002097          	auipc	ra,0x2
    3556:	66a080e7          	jalr	1642(ra) # 5bbc <printf>
    exit(1);
    355a:	4505                	li	a0,1
    355c:	00002097          	auipc	ra,0x2
    3560:	2d0080e7          	jalr	720(ra) # 582c <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3564:	85ca                	mv	a1,s2
    3566:	00004517          	auipc	a0,0x4
    356a:	a4250513          	addi	a0,a0,-1470 # 6fa8 <malloc+0x132e>
    356e:	00002097          	auipc	ra,0x2
    3572:	64e080e7          	jalr	1614(ra) # 5bbc <printf>
    exit(1);
    3576:	4505                	li	a0,1
    3578:	00002097          	auipc	ra,0x2
    357c:	2b4080e7          	jalr	692(ra) # 582c <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3580:	85ca                	mv	a1,s2
    3582:	00004517          	auipc	a0,0x4
    3586:	a4e50513          	addi	a0,a0,-1458 # 6fd0 <malloc+0x1356>
    358a:	00002097          	auipc	ra,0x2
    358e:	632080e7          	jalr	1586(ra) # 5bbc <printf>
    exit(1);
    3592:	4505                	li	a0,1
    3594:	00002097          	auipc	ra,0x2
    3598:	298080e7          	jalr	664(ra) # 582c <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    359c:	85ca                	mv	a1,s2
    359e:	00004517          	auipc	a0,0x4
    35a2:	a5a50513          	addi	a0,a0,-1446 # 6ff8 <malloc+0x137e>
    35a6:	00002097          	auipc	ra,0x2
    35aa:	616080e7          	jalr	1558(ra) # 5bbc <printf>
    exit(1);
    35ae:	4505                	li	a0,1
    35b0:	00002097          	auipc	ra,0x2
    35b4:	27c080e7          	jalr	636(ra) # 582c <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    35b8:	85ca                	mv	a1,s2
    35ba:	00004517          	auipc	a0,0x4
    35be:	a6650513          	addi	a0,a0,-1434 # 7020 <malloc+0x13a6>
    35c2:	00002097          	auipc	ra,0x2
    35c6:	5fa080e7          	jalr	1530(ra) # 5bbc <printf>
    exit(1);
    35ca:	4505                	li	a0,1
    35cc:	00002097          	auipc	ra,0x2
    35d0:	260080e7          	jalr	608(ra) # 582c <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    35d4:	85ca                	mv	a1,s2
    35d6:	00004517          	auipc	a0,0x4
    35da:	a6a50513          	addi	a0,a0,-1430 # 7040 <malloc+0x13c6>
    35de:	00002097          	auipc	ra,0x2
    35e2:	5de080e7          	jalr	1502(ra) # 5bbc <printf>
    exit(1);
    35e6:	4505                	li	a0,1
    35e8:	00002097          	auipc	ra,0x2
    35ec:	244080e7          	jalr	580(ra) # 582c <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    35f0:	85ca                	mv	a1,s2
    35f2:	00004517          	auipc	a0,0x4
    35f6:	a6e50513          	addi	a0,a0,-1426 # 7060 <malloc+0x13e6>
    35fa:	00002097          	auipc	ra,0x2
    35fe:	5c2080e7          	jalr	1474(ra) # 5bbc <printf>
    exit(1);
    3602:	4505                	li	a0,1
    3604:	00002097          	auipc	ra,0x2
    3608:	228080e7          	jalr	552(ra) # 582c <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    360c:	85ca                	mv	a1,s2
    360e:	00004517          	auipc	a0,0x4
    3612:	a7a50513          	addi	a0,a0,-1414 # 7088 <malloc+0x140e>
    3616:	00002097          	auipc	ra,0x2
    361a:	5a6080e7          	jalr	1446(ra) # 5bbc <printf>
    exit(1);
    361e:	4505                	li	a0,1
    3620:	00002097          	auipc	ra,0x2
    3624:	20c080e7          	jalr	524(ra) # 582c <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3628:	85ca                	mv	a1,s2
    362a:	00004517          	auipc	a0,0x4
    362e:	a7e50513          	addi	a0,a0,-1410 # 70a8 <malloc+0x142e>
    3632:	00002097          	auipc	ra,0x2
    3636:	58a080e7          	jalr	1418(ra) # 5bbc <printf>
    exit(1);
    363a:	4505                	li	a0,1
    363c:	00002097          	auipc	ra,0x2
    3640:	1f0080e7          	jalr	496(ra) # 582c <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3644:	85ca                	mv	a1,s2
    3646:	00004517          	auipc	a0,0x4
    364a:	a8250513          	addi	a0,a0,-1406 # 70c8 <malloc+0x144e>
    364e:	00002097          	auipc	ra,0x2
    3652:	56e080e7          	jalr	1390(ra) # 5bbc <printf>
    exit(1);
    3656:	4505                	li	a0,1
    3658:	00002097          	auipc	ra,0x2
    365c:	1d4080e7          	jalr	468(ra) # 582c <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3660:	85ca                	mv	a1,s2
    3662:	00004517          	auipc	a0,0x4
    3666:	a8e50513          	addi	a0,a0,-1394 # 70f0 <malloc+0x1476>
    366a:	00002097          	auipc	ra,0x2
    366e:	552080e7          	jalr	1362(ra) # 5bbc <printf>
    exit(1);
    3672:	4505                	li	a0,1
    3674:	00002097          	auipc	ra,0x2
    3678:	1b8080e7          	jalr	440(ra) # 582c <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    367c:	85ca                	mv	a1,s2
    367e:	00003517          	auipc	a0,0x3
    3682:	70a50513          	addi	a0,a0,1802 # 6d88 <malloc+0x110e>
    3686:	00002097          	auipc	ra,0x2
    368a:	536080e7          	jalr	1334(ra) # 5bbc <printf>
    exit(1);
    368e:	4505                	li	a0,1
    3690:	00002097          	auipc	ra,0x2
    3694:	19c080e7          	jalr	412(ra) # 582c <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3698:	85ca                	mv	a1,s2
    369a:	00004517          	auipc	a0,0x4
    369e:	a7650513          	addi	a0,a0,-1418 # 7110 <malloc+0x1496>
    36a2:	00002097          	auipc	ra,0x2
    36a6:	51a080e7          	jalr	1306(ra) # 5bbc <printf>
    exit(1);
    36aa:	4505                	li	a0,1
    36ac:	00002097          	auipc	ra,0x2
    36b0:	180080e7          	jalr	384(ra) # 582c <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    36b4:	85ca                	mv	a1,s2
    36b6:	00004517          	auipc	a0,0x4
    36ba:	a7a50513          	addi	a0,a0,-1414 # 7130 <malloc+0x14b6>
    36be:	00002097          	auipc	ra,0x2
    36c2:	4fe080e7          	jalr	1278(ra) # 5bbc <printf>
    exit(1);
    36c6:	4505                	li	a0,1
    36c8:	00002097          	auipc	ra,0x2
    36cc:	164080e7          	jalr	356(ra) # 582c <exit>
    printf("%s: unlink dd/dd failed\n", s);
    36d0:	85ca                	mv	a1,s2
    36d2:	00004517          	auipc	a0,0x4
    36d6:	a8e50513          	addi	a0,a0,-1394 # 7160 <malloc+0x14e6>
    36da:	00002097          	auipc	ra,0x2
    36de:	4e2080e7          	jalr	1250(ra) # 5bbc <printf>
    exit(1);
    36e2:	4505                	li	a0,1
    36e4:	00002097          	auipc	ra,0x2
    36e8:	148080e7          	jalr	328(ra) # 582c <exit>
    printf("%s: unlink dd failed\n", s);
    36ec:	85ca                	mv	a1,s2
    36ee:	00004517          	auipc	a0,0x4
    36f2:	a9250513          	addi	a0,a0,-1390 # 7180 <malloc+0x1506>
    36f6:	00002097          	auipc	ra,0x2
    36fa:	4c6080e7          	jalr	1222(ra) # 5bbc <printf>
    exit(1);
    36fe:	4505                	li	a0,1
    3700:	00002097          	auipc	ra,0x2
    3704:	12c080e7          	jalr	300(ra) # 582c <exit>

0000000000003708 <bigwrite>:
{
    3708:	715d                	addi	sp,sp,-80
    370a:	e486                	sd	ra,72(sp)
    370c:	e0a2                	sd	s0,64(sp)
    370e:	fc26                	sd	s1,56(sp)
    3710:	f84a                	sd	s2,48(sp)
    3712:	f44e                	sd	s3,40(sp)
    3714:	f052                	sd	s4,32(sp)
    3716:	ec56                	sd	s5,24(sp)
    3718:	e85a                	sd	s6,16(sp)
    371a:	e45e                	sd	s7,8(sp)
    371c:	0880                	addi	s0,sp,80
    371e:	8baa                	mv	s7,a0
  unlink("bigwrite");
    3720:	00004517          	auipc	a0,0x4
    3724:	a7850513          	addi	a0,a0,-1416 # 7198 <malloc+0x151e>
    3728:	00002097          	auipc	ra,0x2
    372c:	154080e7          	jalr	340(ra) # 587c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    3730:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
    3734:	00004a97          	auipc	s5,0x4
    3738:	a64a8a93          	addi	s5,s5,-1436 # 7198 <malloc+0x151e>
      int cc = write(fd, buf, sz);
    373c:	00008a17          	auipc	s4,0x8
    3740:	f9ca0a13          	addi	s4,s4,-100 # b6d8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    3744:	6b0d                	lui	s6,0x3
    3746:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x287>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    374a:	20200593          	li	a1,514
    374e:	8556                	mv	a0,s5
    3750:	00002097          	auipc	ra,0x2
    3754:	11c080e7          	jalr	284(ra) # 586c <open>
    3758:	892a                	mv	s2,a0
    if(fd < 0){
    375a:	04054d63          	bltz	a0,37b4 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
    375e:	8626                	mv	a2,s1
    3760:	85d2                	mv	a1,s4
    3762:	00002097          	auipc	ra,0x2
    3766:	0ea080e7          	jalr	234(ra) # 584c <write>
    376a:	89aa                	mv	s3,a0
      if(cc != sz){
    376c:	06a49463          	bne	s1,a0,37d4 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
    3770:	8626                	mv	a2,s1
    3772:	85d2                	mv	a1,s4
    3774:	854a                	mv	a0,s2
    3776:	00002097          	auipc	ra,0x2
    377a:	0d6080e7          	jalr	214(ra) # 584c <write>
      if(cc != sz){
    377e:	04951963          	bne	a0,s1,37d0 <bigwrite+0xc8>
    close(fd);
    3782:	854a                	mv	a0,s2
    3784:	00002097          	auipc	ra,0x2
    3788:	0d0080e7          	jalr	208(ra) # 5854 <close>
    unlink("bigwrite");
    378c:	8556                	mv	a0,s5
    378e:	00002097          	auipc	ra,0x2
    3792:	0ee080e7          	jalr	238(ra) # 587c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    3796:	1d74849b          	addiw	s1,s1,471
    379a:	fb6498e3          	bne	s1,s6,374a <bigwrite+0x42>
}
    379e:	60a6                	ld	ra,72(sp)
    37a0:	6406                	ld	s0,64(sp)
    37a2:	74e2                	ld	s1,56(sp)
    37a4:	7942                	ld	s2,48(sp)
    37a6:	79a2                	ld	s3,40(sp)
    37a8:	7a02                	ld	s4,32(sp)
    37aa:	6ae2                	ld	s5,24(sp)
    37ac:	6b42                	ld	s6,16(sp)
    37ae:	6ba2                	ld	s7,8(sp)
    37b0:	6161                	addi	sp,sp,80
    37b2:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
    37b4:	85de                	mv	a1,s7
    37b6:	00004517          	auipc	a0,0x4
    37ba:	9f250513          	addi	a0,a0,-1550 # 71a8 <malloc+0x152e>
    37be:	00002097          	auipc	ra,0x2
    37c2:	3fe080e7          	jalr	1022(ra) # 5bbc <printf>
      exit(1);
    37c6:	4505                	li	a0,1
    37c8:	00002097          	auipc	ra,0x2
    37cc:	064080e7          	jalr	100(ra) # 582c <exit>
    37d0:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
    37d2:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
    37d4:	86ce                	mv	a3,s3
    37d6:	8626                	mv	a2,s1
    37d8:	85de                	mv	a1,s7
    37da:	00004517          	auipc	a0,0x4
    37de:	9ee50513          	addi	a0,a0,-1554 # 71c8 <malloc+0x154e>
    37e2:	00002097          	auipc	ra,0x2
    37e6:	3da080e7          	jalr	986(ra) # 5bbc <printf>
        exit(1);
    37ea:	4505                	li	a0,1
    37ec:	00002097          	auipc	ra,0x2
    37f0:	040080e7          	jalr	64(ra) # 582c <exit>

00000000000037f4 <manywrites>:
{
    37f4:	711d                	addi	sp,sp,-96
    37f6:	ec86                	sd	ra,88(sp)
    37f8:	e8a2                	sd	s0,80(sp)
    37fa:	e4a6                	sd	s1,72(sp)
    37fc:	e0ca                	sd	s2,64(sp)
    37fe:	fc4e                	sd	s3,56(sp)
    3800:	f852                	sd	s4,48(sp)
    3802:	f456                	sd	s5,40(sp)
    3804:	f05a                	sd	s6,32(sp)
    3806:	ec5e                	sd	s7,24(sp)
    3808:	1080                	addi	s0,sp,96
    380a:	8a2a                	mv	s4,a0
    int pid = fork();
    380c:	00002097          	auipc	ra,0x2
    3810:	018080e7          	jalr	24(ra) # 5824 <fork>
    if(pid < 0){
    3814:	04054763          	bltz	a0,3862 <manywrites+0x6e>
    3818:	84aa                	mv	s1,a0
    if(pid == 0){
    381a:	c135                	beqz	a0,387e <manywrites+0x8a>
    int pid = fork();
    381c:	00002097          	auipc	ra,0x2
    3820:	008080e7          	jalr	8(ra) # 5824 <fork>
    if(pid < 0){
    3824:	02054f63          	bltz	a0,3862 <manywrites+0x6e>
    if(pid == 0){
    3828:	c931                	beqz	a0,387c <manywrites+0x88>
    int st = 0;
    382a:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    382e:	fa840513          	addi	a0,s0,-88
    3832:	00002097          	auipc	ra,0x2
    3836:	002080e7          	jalr	2(ra) # 5834 <wait>
    if(st != 0)
    383a:	fa842503          	lw	a0,-88(s0)
    383e:	10051763          	bnez	a0,394c <manywrites+0x158>
    int st = 0;
    3842:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    3846:	fa840513          	addi	a0,s0,-88
    384a:	00002097          	auipc	ra,0x2
    384e:	fea080e7          	jalr	-22(ra) # 5834 <wait>
    if(st != 0)
    3852:	fa842503          	lw	a0,-88(s0)
    3856:	e97d                	bnez	a0,394c <manywrites+0x158>
  exit(0);
    3858:	4501                	li	a0,0
    385a:	00002097          	auipc	ra,0x2
    385e:	fd2080e7          	jalr	-46(ra) # 582c <exit>
      printf("fork failed\n");
    3862:	00004517          	auipc	a0,0x4
    3866:	34e50513          	addi	a0,a0,846 # 7bb0 <malloc+0x1f36>
    386a:	00002097          	auipc	ra,0x2
    386e:	352080e7          	jalr	850(ra) # 5bbc <printf>
      exit(1);
    3872:	4505                	li	a0,1
    3874:	00002097          	auipc	ra,0x2
    3878:	fb8080e7          	jalr	-72(ra) # 582c <exit>
  for(int ci = 0; ci < nchildren; ci++){
    387c:	4485                	li	s1,1
      name[0] = 'b';
    387e:	06200793          	li	a5,98
    3882:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    3886:	0614879b          	addiw	a5,s1,97
    388a:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    388e:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    3892:	fa840513          	addi	a0,s0,-88
    3896:	00002097          	auipc	ra,0x2
    389a:	fe6080e7          	jalr	-26(ra) # 587c <unlink>
    389e:	4bd1                	li	s7,20
        for(int i = 0; i < ci+1; i++){
    38a0:	4b01                	li	s6,0
          int cc = write(fd, buf, sz);
    38a2:	00008a97          	auipc	s5,0x8
    38a6:	e36a8a93          	addi	s5,s5,-458 # b6d8 <buf>
        for(int i = 0; i < ci+1; i++){
    38aa:	89da                	mv	s3,s6
          int fd = open(name, O_CREATE | O_RDWR);
    38ac:	20200593          	li	a1,514
    38b0:	fa840513          	addi	a0,s0,-88
    38b4:	00002097          	auipc	ra,0x2
    38b8:	fb8080e7          	jalr	-72(ra) # 586c <open>
    38bc:	892a                	mv	s2,a0
          if(fd < 0){
    38be:	04054763          	bltz	a0,390c <manywrites+0x118>
          int cc = write(fd, buf, sz);
    38c2:	660d                	lui	a2,0x3
    38c4:	85d6                	mv	a1,s5
    38c6:	00002097          	auipc	ra,0x2
    38ca:	f86080e7          	jalr	-122(ra) # 584c <write>
          if(cc != sz){
    38ce:	678d                	lui	a5,0x3
    38d0:	04f51e63          	bne	a0,a5,392c <manywrites+0x138>
          close(fd);
    38d4:	854a                	mv	a0,s2
    38d6:	00002097          	auipc	ra,0x2
    38da:	f7e080e7          	jalr	-130(ra) # 5854 <close>
        for(int i = 0; i < ci+1; i++){
    38de:	2985                	addiw	s3,s3,1
    38e0:	fd34d6e3          	bge	s1,s3,38ac <manywrites+0xb8>
        unlink(name);
    38e4:	fa840513          	addi	a0,s0,-88
    38e8:	00002097          	auipc	ra,0x2
    38ec:	f94080e7          	jalr	-108(ra) # 587c <unlink>
      for(int iters = 0; iters < howmany; iters++){
    38f0:	3bfd                	addiw	s7,s7,-1
    38f2:	fa0b9ce3          	bnez	s7,38aa <manywrites+0xb6>
      unlink(name);
    38f6:	fa840513          	addi	a0,s0,-88
    38fa:	00002097          	auipc	ra,0x2
    38fe:	f82080e7          	jalr	-126(ra) # 587c <unlink>
      exit(0);
    3902:	4501                	li	a0,0
    3904:	00002097          	auipc	ra,0x2
    3908:	f28080e7          	jalr	-216(ra) # 582c <exit>
            printf("%s: cannot create %s\n", s, name);
    390c:	fa840613          	addi	a2,s0,-88
    3910:	85d2                	mv	a1,s4
    3912:	00004517          	auipc	a0,0x4
    3916:	8ce50513          	addi	a0,a0,-1842 # 71e0 <malloc+0x1566>
    391a:	00002097          	auipc	ra,0x2
    391e:	2a2080e7          	jalr	674(ra) # 5bbc <printf>
            exit(1);
    3922:	4505                	li	a0,1
    3924:	00002097          	auipc	ra,0x2
    3928:	f08080e7          	jalr	-248(ra) # 582c <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    392c:	86aa                	mv	a3,a0
    392e:	660d                	lui	a2,0x3
    3930:	85d2                	mv	a1,s4
    3932:	00004517          	auipc	a0,0x4
    3936:	89650513          	addi	a0,a0,-1898 # 71c8 <malloc+0x154e>
    393a:	00002097          	auipc	ra,0x2
    393e:	282080e7          	jalr	642(ra) # 5bbc <printf>
            exit(1);
    3942:	4505                	li	a0,1
    3944:	00002097          	auipc	ra,0x2
    3948:	ee8080e7          	jalr	-280(ra) # 582c <exit>
      exit(st);
    394c:	00002097          	auipc	ra,0x2
    3950:	ee0080e7          	jalr	-288(ra) # 582c <exit>

0000000000003954 <bigfile>:
{
    3954:	7139                	addi	sp,sp,-64
    3956:	fc06                	sd	ra,56(sp)
    3958:	f822                	sd	s0,48(sp)
    395a:	f426                	sd	s1,40(sp)
    395c:	f04a                	sd	s2,32(sp)
    395e:	ec4e                	sd	s3,24(sp)
    3960:	e852                	sd	s4,16(sp)
    3962:	e456                	sd	s5,8(sp)
    3964:	0080                	addi	s0,sp,64
    3966:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    3968:	00004517          	auipc	a0,0x4
    396c:	89050513          	addi	a0,a0,-1904 # 71f8 <malloc+0x157e>
    3970:	00002097          	auipc	ra,0x2
    3974:	f0c080e7          	jalr	-244(ra) # 587c <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    3978:	20200593          	li	a1,514
    397c:	00004517          	auipc	a0,0x4
    3980:	87c50513          	addi	a0,a0,-1924 # 71f8 <malloc+0x157e>
    3984:	00002097          	auipc	ra,0x2
    3988:	ee8080e7          	jalr	-280(ra) # 586c <open>
    398c:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    398e:	4481                	li	s1,0
    memset(buf, i, SZ);
    3990:	00008917          	auipc	s2,0x8
    3994:	d4890913          	addi	s2,s2,-696 # b6d8 <buf>
  for(i = 0; i < N; i++){
    3998:	4a51                	li	s4,20
  if(fd < 0){
    399a:	0a054063          	bltz	a0,3a3a <bigfile+0xe6>
    memset(buf, i, SZ);
    399e:	25800613          	li	a2,600
    39a2:	85a6                	mv	a1,s1
    39a4:	854a                	mv	a0,s2
    39a6:	00002097          	auipc	ra,0x2
    39aa:	c82080e7          	jalr	-894(ra) # 5628 <memset>
    if(write(fd, buf, SZ) != SZ){
    39ae:	25800613          	li	a2,600
    39b2:	85ca                	mv	a1,s2
    39b4:	854e                	mv	a0,s3
    39b6:	00002097          	auipc	ra,0x2
    39ba:	e96080e7          	jalr	-362(ra) # 584c <write>
    39be:	25800793          	li	a5,600
    39c2:	08f51a63          	bne	a0,a5,3a56 <bigfile+0x102>
  for(i = 0; i < N; i++){
    39c6:	2485                	addiw	s1,s1,1
    39c8:	fd449be3          	bne	s1,s4,399e <bigfile+0x4a>
  close(fd);
    39cc:	854e                	mv	a0,s3
    39ce:	00002097          	auipc	ra,0x2
    39d2:	e86080e7          	jalr	-378(ra) # 5854 <close>
  fd = open("bigfile.dat", 0);
    39d6:	4581                	li	a1,0
    39d8:	00004517          	auipc	a0,0x4
    39dc:	82050513          	addi	a0,a0,-2016 # 71f8 <malloc+0x157e>
    39e0:	00002097          	auipc	ra,0x2
    39e4:	e8c080e7          	jalr	-372(ra) # 586c <open>
    39e8:	8a2a                	mv	s4,a0
  total = 0;
    39ea:	4981                	li	s3,0
  for(i = 0; ; i++){
    39ec:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    39ee:	00008917          	auipc	s2,0x8
    39f2:	cea90913          	addi	s2,s2,-790 # b6d8 <buf>
  if(fd < 0){
    39f6:	06054e63          	bltz	a0,3a72 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    39fa:	12c00613          	li	a2,300
    39fe:	85ca                	mv	a1,s2
    3a00:	8552                	mv	a0,s4
    3a02:	00002097          	auipc	ra,0x2
    3a06:	e42080e7          	jalr	-446(ra) # 5844 <read>
    if(cc < 0){
    3a0a:	08054263          	bltz	a0,3a8e <bigfile+0x13a>
    if(cc == 0)
    3a0e:	c971                	beqz	a0,3ae2 <bigfile+0x18e>
    if(cc != SZ/2){
    3a10:	12c00793          	li	a5,300
    3a14:	08f51b63          	bne	a0,a5,3aaa <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    3a18:	01f4d79b          	srliw	a5,s1,0x1f
    3a1c:	9fa5                	addw	a5,a5,s1
    3a1e:	4017d79b          	sraiw	a5,a5,0x1
    3a22:	00094703          	lbu	a4,0(s2)
    3a26:	0af71063          	bne	a4,a5,3ac6 <bigfile+0x172>
    3a2a:	12b94703          	lbu	a4,299(s2)
    3a2e:	08f71c63          	bne	a4,a5,3ac6 <bigfile+0x172>
    total += cc;
    3a32:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    3a36:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    3a38:	b7c9                	j	39fa <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    3a3a:	85d6                	mv	a1,s5
    3a3c:	00003517          	auipc	a0,0x3
    3a40:	7cc50513          	addi	a0,a0,1996 # 7208 <malloc+0x158e>
    3a44:	00002097          	auipc	ra,0x2
    3a48:	178080e7          	jalr	376(ra) # 5bbc <printf>
    exit(1);
    3a4c:	4505                	li	a0,1
    3a4e:	00002097          	auipc	ra,0x2
    3a52:	dde080e7          	jalr	-546(ra) # 582c <exit>
      printf("%s: write bigfile failed\n", s);
    3a56:	85d6                	mv	a1,s5
    3a58:	00003517          	auipc	a0,0x3
    3a5c:	7d050513          	addi	a0,a0,2000 # 7228 <malloc+0x15ae>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	15c080e7          	jalr	348(ra) # 5bbc <printf>
      exit(1);
    3a68:	4505                	li	a0,1
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	dc2080e7          	jalr	-574(ra) # 582c <exit>
    printf("%s: cannot open bigfile\n", s);
    3a72:	85d6                	mv	a1,s5
    3a74:	00003517          	auipc	a0,0x3
    3a78:	7d450513          	addi	a0,a0,2004 # 7248 <malloc+0x15ce>
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	140080e7          	jalr	320(ra) # 5bbc <printf>
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	00002097          	auipc	ra,0x2
    3a8a:	da6080e7          	jalr	-602(ra) # 582c <exit>
      printf("%s: read bigfile failed\n", s);
    3a8e:	85d6                	mv	a1,s5
    3a90:	00003517          	auipc	a0,0x3
    3a94:	7d850513          	addi	a0,a0,2008 # 7268 <malloc+0x15ee>
    3a98:	00002097          	auipc	ra,0x2
    3a9c:	124080e7          	jalr	292(ra) # 5bbc <printf>
      exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	00002097          	auipc	ra,0x2
    3aa6:	d8a080e7          	jalr	-630(ra) # 582c <exit>
      printf("%s: short read bigfile\n", s);
    3aaa:	85d6                	mv	a1,s5
    3aac:	00003517          	auipc	a0,0x3
    3ab0:	7dc50513          	addi	a0,a0,2012 # 7288 <malloc+0x160e>
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	108080e7          	jalr	264(ra) # 5bbc <printf>
      exit(1);
    3abc:	4505                	li	a0,1
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	d6e080e7          	jalr	-658(ra) # 582c <exit>
      printf("%s: read bigfile wrong data\n", s);
    3ac6:	85d6                	mv	a1,s5
    3ac8:	00003517          	auipc	a0,0x3
    3acc:	7d850513          	addi	a0,a0,2008 # 72a0 <malloc+0x1626>
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	0ec080e7          	jalr	236(ra) # 5bbc <printf>
      exit(1);
    3ad8:	4505                	li	a0,1
    3ada:	00002097          	auipc	ra,0x2
    3ade:	d52080e7          	jalr	-686(ra) # 582c <exit>
  close(fd);
    3ae2:	8552                	mv	a0,s4
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	d70080e7          	jalr	-656(ra) # 5854 <close>
  if(total != N*SZ){
    3aec:	678d                	lui	a5,0x3
    3aee:	ee078793          	addi	a5,a5,-288 # 2ee0 <bigdir+0x102>
    3af2:	02f99363          	bne	s3,a5,3b18 <bigfile+0x1c4>
  unlink("bigfile.dat");
    3af6:	00003517          	auipc	a0,0x3
    3afa:	70250513          	addi	a0,a0,1794 # 71f8 <malloc+0x157e>
    3afe:	00002097          	auipc	ra,0x2
    3b02:	d7e080e7          	jalr	-642(ra) # 587c <unlink>
}
    3b06:	70e2                	ld	ra,56(sp)
    3b08:	7442                	ld	s0,48(sp)
    3b0a:	74a2                	ld	s1,40(sp)
    3b0c:	7902                	ld	s2,32(sp)
    3b0e:	69e2                	ld	s3,24(sp)
    3b10:	6a42                	ld	s4,16(sp)
    3b12:	6aa2                	ld	s5,8(sp)
    3b14:	6121                	addi	sp,sp,64
    3b16:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    3b18:	85d6                	mv	a1,s5
    3b1a:	00003517          	auipc	a0,0x3
    3b1e:	7a650513          	addi	a0,a0,1958 # 72c0 <malloc+0x1646>
    3b22:	00002097          	auipc	ra,0x2
    3b26:	09a080e7          	jalr	154(ra) # 5bbc <printf>
    exit(1);
    3b2a:	4505                	li	a0,1
    3b2c:	00002097          	auipc	ra,0x2
    3b30:	d00080e7          	jalr	-768(ra) # 582c <exit>

0000000000003b34 <fourteen>:
{
    3b34:	1101                	addi	sp,sp,-32
    3b36:	ec06                	sd	ra,24(sp)
    3b38:	e822                	sd	s0,16(sp)
    3b3a:	e426                	sd	s1,8(sp)
    3b3c:	1000                	addi	s0,sp,32
    3b3e:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    3b40:	00004517          	auipc	a0,0x4
    3b44:	97050513          	addi	a0,a0,-1680 # 74b0 <malloc+0x1836>
    3b48:	00002097          	auipc	ra,0x2
    3b4c:	d4c080e7          	jalr	-692(ra) # 5894 <mkdir>
    3b50:	e165                	bnez	a0,3c30 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3b52:	00003517          	auipc	a0,0x3
    3b56:	7b650513          	addi	a0,a0,1974 # 7308 <malloc+0x168e>
    3b5a:	00002097          	auipc	ra,0x2
    3b5e:	d3a080e7          	jalr	-710(ra) # 5894 <mkdir>
    3b62:	e56d                	bnez	a0,3c4c <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3b64:	20000593          	li	a1,512
    3b68:	00003517          	auipc	a0,0x3
    3b6c:	7f850513          	addi	a0,a0,2040 # 7360 <malloc+0x16e6>
    3b70:	00002097          	auipc	ra,0x2
    3b74:	cfc080e7          	jalr	-772(ra) # 586c <open>
  if(fd < 0){
    3b78:	0e054863          	bltz	a0,3c68 <fourteen+0x134>
  close(fd);
    3b7c:	00002097          	auipc	ra,0x2
    3b80:	cd8080e7          	jalr	-808(ra) # 5854 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3b84:	4581                	li	a1,0
    3b86:	00004517          	auipc	a0,0x4
    3b8a:	85250513          	addi	a0,a0,-1966 # 73d8 <malloc+0x175e>
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	cde080e7          	jalr	-802(ra) # 586c <open>
  if(fd < 0){
    3b96:	0e054763          	bltz	a0,3c84 <fourteen+0x150>
  close(fd);
    3b9a:	00002097          	auipc	ra,0x2
    3b9e:	cba080e7          	jalr	-838(ra) # 5854 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    3ba2:	00004517          	auipc	a0,0x4
    3ba6:	8a650513          	addi	a0,a0,-1882 # 7448 <malloc+0x17ce>
    3baa:	00002097          	auipc	ra,0x2
    3bae:	cea080e7          	jalr	-790(ra) # 5894 <mkdir>
    3bb2:	c57d                	beqz	a0,3ca0 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    3bb4:	00004517          	auipc	a0,0x4
    3bb8:	8ec50513          	addi	a0,a0,-1812 # 74a0 <malloc+0x1826>
    3bbc:	00002097          	auipc	ra,0x2
    3bc0:	cd8080e7          	jalr	-808(ra) # 5894 <mkdir>
    3bc4:	cd65                	beqz	a0,3cbc <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    3bc6:	00004517          	auipc	a0,0x4
    3bca:	8da50513          	addi	a0,a0,-1830 # 74a0 <malloc+0x1826>
    3bce:	00002097          	auipc	ra,0x2
    3bd2:	cae080e7          	jalr	-850(ra) # 587c <unlink>
  unlink("12345678901234/12345678901234");
    3bd6:	00004517          	auipc	a0,0x4
    3bda:	87250513          	addi	a0,a0,-1934 # 7448 <malloc+0x17ce>
    3bde:	00002097          	auipc	ra,0x2
    3be2:	c9e080e7          	jalr	-866(ra) # 587c <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    3be6:	00003517          	auipc	a0,0x3
    3bea:	7f250513          	addi	a0,a0,2034 # 73d8 <malloc+0x175e>
    3bee:	00002097          	auipc	ra,0x2
    3bf2:	c8e080e7          	jalr	-882(ra) # 587c <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    3bf6:	00003517          	auipc	a0,0x3
    3bfa:	76a50513          	addi	a0,a0,1898 # 7360 <malloc+0x16e6>
    3bfe:	00002097          	auipc	ra,0x2
    3c02:	c7e080e7          	jalr	-898(ra) # 587c <unlink>
  unlink("12345678901234/123456789012345");
    3c06:	00003517          	auipc	a0,0x3
    3c0a:	70250513          	addi	a0,a0,1794 # 7308 <malloc+0x168e>
    3c0e:	00002097          	auipc	ra,0x2
    3c12:	c6e080e7          	jalr	-914(ra) # 587c <unlink>
  unlink("12345678901234");
    3c16:	00004517          	auipc	a0,0x4
    3c1a:	89a50513          	addi	a0,a0,-1894 # 74b0 <malloc+0x1836>
    3c1e:	00002097          	auipc	ra,0x2
    3c22:	c5e080e7          	jalr	-930(ra) # 587c <unlink>
}
    3c26:	60e2                	ld	ra,24(sp)
    3c28:	6442                	ld	s0,16(sp)
    3c2a:	64a2                	ld	s1,8(sp)
    3c2c:	6105                	addi	sp,sp,32
    3c2e:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    3c30:	85a6                	mv	a1,s1
    3c32:	00003517          	auipc	a0,0x3
    3c36:	6ae50513          	addi	a0,a0,1710 # 72e0 <malloc+0x1666>
    3c3a:	00002097          	auipc	ra,0x2
    3c3e:	f82080e7          	jalr	-126(ra) # 5bbc <printf>
    exit(1);
    3c42:	4505                	li	a0,1
    3c44:	00002097          	auipc	ra,0x2
    3c48:	be8080e7          	jalr	-1048(ra) # 582c <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3c4c:	85a6                	mv	a1,s1
    3c4e:	00003517          	auipc	a0,0x3
    3c52:	6da50513          	addi	a0,a0,1754 # 7328 <malloc+0x16ae>
    3c56:	00002097          	auipc	ra,0x2
    3c5a:	f66080e7          	jalr	-154(ra) # 5bbc <printf>
    exit(1);
    3c5e:	4505                	li	a0,1
    3c60:	00002097          	auipc	ra,0x2
    3c64:	bcc080e7          	jalr	-1076(ra) # 582c <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3c68:	85a6                	mv	a1,s1
    3c6a:	00003517          	auipc	a0,0x3
    3c6e:	72650513          	addi	a0,a0,1830 # 7390 <malloc+0x1716>
    3c72:	00002097          	auipc	ra,0x2
    3c76:	f4a080e7          	jalr	-182(ra) # 5bbc <printf>
    exit(1);
    3c7a:	4505                	li	a0,1
    3c7c:	00002097          	auipc	ra,0x2
    3c80:	bb0080e7          	jalr	-1104(ra) # 582c <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3c84:	85a6                	mv	a1,s1
    3c86:	00003517          	auipc	a0,0x3
    3c8a:	78250513          	addi	a0,a0,1922 # 7408 <malloc+0x178e>
    3c8e:	00002097          	auipc	ra,0x2
    3c92:	f2e080e7          	jalr	-210(ra) # 5bbc <printf>
    exit(1);
    3c96:	4505                	li	a0,1
    3c98:	00002097          	auipc	ra,0x2
    3c9c:	b94080e7          	jalr	-1132(ra) # 582c <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    3ca0:	85a6                	mv	a1,s1
    3ca2:	00003517          	auipc	a0,0x3
    3ca6:	7c650513          	addi	a0,a0,1990 # 7468 <malloc+0x17ee>
    3caa:	00002097          	auipc	ra,0x2
    3cae:	f12080e7          	jalr	-238(ra) # 5bbc <printf>
    exit(1);
    3cb2:	4505                	li	a0,1
    3cb4:	00002097          	auipc	ra,0x2
    3cb8:	b78080e7          	jalr	-1160(ra) # 582c <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    3cbc:	85a6                	mv	a1,s1
    3cbe:	00004517          	auipc	a0,0x4
    3cc2:	80250513          	addi	a0,a0,-2046 # 74c0 <malloc+0x1846>
    3cc6:	00002097          	auipc	ra,0x2
    3cca:	ef6080e7          	jalr	-266(ra) # 5bbc <printf>
    exit(1);
    3cce:	4505                	li	a0,1
    3cd0:	00002097          	auipc	ra,0x2
    3cd4:	b5c080e7          	jalr	-1188(ra) # 582c <exit>

0000000000003cd8 <rmdot>:
{
    3cd8:	1101                	addi	sp,sp,-32
    3cda:	ec06                	sd	ra,24(sp)
    3cdc:	e822                	sd	s0,16(sp)
    3cde:	e426                	sd	s1,8(sp)
    3ce0:	1000                	addi	s0,sp,32
    3ce2:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3ce4:	00004517          	auipc	a0,0x4
    3ce8:	81450513          	addi	a0,a0,-2028 # 74f8 <malloc+0x187e>
    3cec:	00002097          	auipc	ra,0x2
    3cf0:	ba8080e7          	jalr	-1112(ra) # 5894 <mkdir>
    3cf4:	e549                	bnez	a0,3d7e <rmdot+0xa6>
  if(chdir("dots") != 0){
    3cf6:	00004517          	auipc	a0,0x4
    3cfa:	80250513          	addi	a0,a0,-2046 # 74f8 <malloc+0x187e>
    3cfe:	00002097          	auipc	ra,0x2
    3d02:	b9e080e7          	jalr	-1122(ra) # 589c <chdir>
    3d06:	e951                	bnez	a0,3d9a <rmdot+0xc2>
  if(unlink(".") == 0){
    3d08:	00003517          	auipc	a0,0x3
    3d0c:	de050513          	addi	a0,a0,-544 # 6ae8 <malloc+0xe6e>
    3d10:	00002097          	auipc	ra,0x2
    3d14:	b6c080e7          	jalr	-1172(ra) # 587c <unlink>
    3d18:	cd59                	beqz	a0,3db6 <rmdot+0xde>
  if(unlink("..") == 0){
    3d1a:	00003517          	auipc	a0,0x3
    3d1e:	86650513          	addi	a0,a0,-1946 # 6580 <malloc+0x906>
    3d22:	00002097          	auipc	ra,0x2
    3d26:	b5a080e7          	jalr	-1190(ra) # 587c <unlink>
    3d2a:	c545                	beqz	a0,3dd2 <rmdot+0xfa>
  if(chdir("/") != 0){
    3d2c:	00002517          	auipc	a0,0x2
    3d30:	56c50513          	addi	a0,a0,1388 # 6298 <malloc+0x61e>
    3d34:	00002097          	auipc	ra,0x2
    3d38:	b68080e7          	jalr	-1176(ra) # 589c <chdir>
    3d3c:	e94d                	bnez	a0,3dee <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3d3e:	00004517          	auipc	a0,0x4
    3d42:	82250513          	addi	a0,a0,-2014 # 7560 <malloc+0x18e6>
    3d46:	00002097          	auipc	ra,0x2
    3d4a:	b36080e7          	jalr	-1226(ra) # 587c <unlink>
    3d4e:	cd55                	beqz	a0,3e0a <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3d50:	00004517          	auipc	a0,0x4
    3d54:	83850513          	addi	a0,a0,-1992 # 7588 <malloc+0x190e>
    3d58:	00002097          	auipc	ra,0x2
    3d5c:	b24080e7          	jalr	-1244(ra) # 587c <unlink>
    3d60:	c179                	beqz	a0,3e26 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3d62:	00003517          	auipc	a0,0x3
    3d66:	79650513          	addi	a0,a0,1942 # 74f8 <malloc+0x187e>
    3d6a:	00002097          	auipc	ra,0x2
    3d6e:	b12080e7          	jalr	-1262(ra) # 587c <unlink>
    3d72:	e961                	bnez	a0,3e42 <rmdot+0x16a>
}
    3d74:	60e2                	ld	ra,24(sp)
    3d76:	6442                	ld	s0,16(sp)
    3d78:	64a2                	ld	s1,8(sp)
    3d7a:	6105                	addi	sp,sp,32
    3d7c:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3d7e:	85a6                	mv	a1,s1
    3d80:	00003517          	auipc	a0,0x3
    3d84:	78050513          	addi	a0,a0,1920 # 7500 <malloc+0x1886>
    3d88:	00002097          	auipc	ra,0x2
    3d8c:	e34080e7          	jalr	-460(ra) # 5bbc <printf>
    exit(1);
    3d90:	4505                	li	a0,1
    3d92:	00002097          	auipc	ra,0x2
    3d96:	a9a080e7          	jalr	-1382(ra) # 582c <exit>
    printf("%s: chdir dots failed\n", s);
    3d9a:	85a6                	mv	a1,s1
    3d9c:	00003517          	auipc	a0,0x3
    3da0:	77c50513          	addi	a0,a0,1916 # 7518 <malloc+0x189e>
    3da4:	00002097          	auipc	ra,0x2
    3da8:	e18080e7          	jalr	-488(ra) # 5bbc <printf>
    exit(1);
    3dac:	4505                	li	a0,1
    3dae:	00002097          	auipc	ra,0x2
    3db2:	a7e080e7          	jalr	-1410(ra) # 582c <exit>
    printf("%s: rm . worked!\n", s);
    3db6:	85a6                	mv	a1,s1
    3db8:	00003517          	auipc	a0,0x3
    3dbc:	77850513          	addi	a0,a0,1912 # 7530 <malloc+0x18b6>
    3dc0:	00002097          	auipc	ra,0x2
    3dc4:	dfc080e7          	jalr	-516(ra) # 5bbc <printf>
    exit(1);
    3dc8:	4505                	li	a0,1
    3dca:	00002097          	auipc	ra,0x2
    3dce:	a62080e7          	jalr	-1438(ra) # 582c <exit>
    printf("%s: rm .. worked!\n", s);
    3dd2:	85a6                	mv	a1,s1
    3dd4:	00003517          	auipc	a0,0x3
    3dd8:	77450513          	addi	a0,a0,1908 # 7548 <malloc+0x18ce>
    3ddc:	00002097          	auipc	ra,0x2
    3de0:	de0080e7          	jalr	-544(ra) # 5bbc <printf>
    exit(1);
    3de4:	4505                	li	a0,1
    3de6:	00002097          	auipc	ra,0x2
    3dea:	a46080e7          	jalr	-1466(ra) # 582c <exit>
    printf("%s: chdir / failed\n", s);
    3dee:	85a6                	mv	a1,s1
    3df0:	00002517          	auipc	a0,0x2
    3df4:	4b050513          	addi	a0,a0,1200 # 62a0 <malloc+0x626>
    3df8:	00002097          	auipc	ra,0x2
    3dfc:	dc4080e7          	jalr	-572(ra) # 5bbc <printf>
    exit(1);
    3e00:	4505                	li	a0,1
    3e02:	00002097          	auipc	ra,0x2
    3e06:	a2a080e7          	jalr	-1494(ra) # 582c <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3e0a:	85a6                	mv	a1,s1
    3e0c:	00003517          	auipc	a0,0x3
    3e10:	75c50513          	addi	a0,a0,1884 # 7568 <malloc+0x18ee>
    3e14:	00002097          	auipc	ra,0x2
    3e18:	da8080e7          	jalr	-600(ra) # 5bbc <printf>
    exit(1);
    3e1c:	4505                	li	a0,1
    3e1e:	00002097          	auipc	ra,0x2
    3e22:	a0e080e7          	jalr	-1522(ra) # 582c <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3e26:	85a6                	mv	a1,s1
    3e28:	00003517          	auipc	a0,0x3
    3e2c:	76850513          	addi	a0,a0,1896 # 7590 <malloc+0x1916>
    3e30:	00002097          	auipc	ra,0x2
    3e34:	d8c080e7          	jalr	-628(ra) # 5bbc <printf>
    exit(1);
    3e38:	4505                	li	a0,1
    3e3a:	00002097          	auipc	ra,0x2
    3e3e:	9f2080e7          	jalr	-1550(ra) # 582c <exit>
    printf("%s: unlink dots failed!\n", s);
    3e42:	85a6                	mv	a1,s1
    3e44:	00003517          	auipc	a0,0x3
    3e48:	76c50513          	addi	a0,a0,1900 # 75b0 <malloc+0x1936>
    3e4c:	00002097          	auipc	ra,0x2
    3e50:	d70080e7          	jalr	-656(ra) # 5bbc <printf>
    exit(1);
    3e54:	4505                	li	a0,1
    3e56:	00002097          	auipc	ra,0x2
    3e5a:	9d6080e7          	jalr	-1578(ra) # 582c <exit>

0000000000003e5e <dirfile>:
{
    3e5e:	1101                	addi	sp,sp,-32
    3e60:	ec06                	sd	ra,24(sp)
    3e62:	e822                	sd	s0,16(sp)
    3e64:	e426                	sd	s1,8(sp)
    3e66:	e04a                	sd	s2,0(sp)
    3e68:	1000                	addi	s0,sp,32
    3e6a:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3e6c:	20000593          	li	a1,512
    3e70:	00003517          	auipc	a0,0x3
    3e74:	76050513          	addi	a0,a0,1888 # 75d0 <malloc+0x1956>
    3e78:	00002097          	auipc	ra,0x2
    3e7c:	9f4080e7          	jalr	-1548(ra) # 586c <open>
  if(fd < 0){
    3e80:	0e054d63          	bltz	a0,3f7a <dirfile+0x11c>
  close(fd);
    3e84:	00002097          	auipc	ra,0x2
    3e88:	9d0080e7          	jalr	-1584(ra) # 5854 <close>
  if(chdir("dirfile") == 0){
    3e8c:	00003517          	auipc	a0,0x3
    3e90:	74450513          	addi	a0,a0,1860 # 75d0 <malloc+0x1956>
    3e94:	00002097          	auipc	ra,0x2
    3e98:	a08080e7          	jalr	-1528(ra) # 589c <chdir>
    3e9c:	cd6d                	beqz	a0,3f96 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3e9e:	4581                	li	a1,0
    3ea0:	00003517          	auipc	a0,0x3
    3ea4:	77850513          	addi	a0,a0,1912 # 7618 <malloc+0x199e>
    3ea8:	00002097          	auipc	ra,0x2
    3eac:	9c4080e7          	jalr	-1596(ra) # 586c <open>
  if(fd >= 0){
    3eb0:	10055163          	bgez	a0,3fb2 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3eb4:	20000593          	li	a1,512
    3eb8:	00003517          	auipc	a0,0x3
    3ebc:	76050513          	addi	a0,a0,1888 # 7618 <malloc+0x199e>
    3ec0:	00002097          	auipc	ra,0x2
    3ec4:	9ac080e7          	jalr	-1620(ra) # 586c <open>
  if(fd >= 0){
    3ec8:	10055363          	bgez	a0,3fce <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3ecc:	00003517          	auipc	a0,0x3
    3ed0:	74c50513          	addi	a0,a0,1868 # 7618 <malloc+0x199e>
    3ed4:	00002097          	auipc	ra,0x2
    3ed8:	9c0080e7          	jalr	-1600(ra) # 5894 <mkdir>
    3edc:	10050763          	beqz	a0,3fea <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3ee0:	00003517          	auipc	a0,0x3
    3ee4:	73850513          	addi	a0,a0,1848 # 7618 <malloc+0x199e>
    3ee8:	00002097          	auipc	ra,0x2
    3eec:	994080e7          	jalr	-1644(ra) # 587c <unlink>
    3ef0:	10050b63          	beqz	a0,4006 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3ef4:	00003597          	auipc	a1,0x3
    3ef8:	72458593          	addi	a1,a1,1828 # 7618 <malloc+0x199e>
    3efc:	00002517          	auipc	a0,0x2
    3f00:	f5c50513          	addi	a0,a0,-164 # 5e58 <malloc+0x1de>
    3f04:	00002097          	auipc	ra,0x2
    3f08:	988080e7          	jalr	-1656(ra) # 588c <link>
    3f0c:	10050b63          	beqz	a0,4022 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3f10:	00003517          	auipc	a0,0x3
    3f14:	6c050513          	addi	a0,a0,1728 # 75d0 <malloc+0x1956>
    3f18:	00002097          	auipc	ra,0x2
    3f1c:	964080e7          	jalr	-1692(ra) # 587c <unlink>
    3f20:	10051f63          	bnez	a0,403e <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3f24:	4589                	li	a1,2
    3f26:	00003517          	auipc	a0,0x3
    3f2a:	bc250513          	addi	a0,a0,-1086 # 6ae8 <malloc+0xe6e>
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	93e080e7          	jalr	-1730(ra) # 586c <open>
  if(fd >= 0){
    3f36:	12055263          	bgez	a0,405a <dirfile+0x1fc>
  fd = open(".", 0);
    3f3a:	4581                	li	a1,0
    3f3c:	00003517          	auipc	a0,0x3
    3f40:	bac50513          	addi	a0,a0,-1108 # 6ae8 <malloc+0xe6e>
    3f44:	00002097          	auipc	ra,0x2
    3f48:	928080e7          	jalr	-1752(ra) # 586c <open>
    3f4c:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3f4e:	4605                	li	a2,1
    3f50:	00002597          	auipc	a1,0x2
    3f54:	f5858593          	addi	a1,a1,-168 # 5ea8 <malloc+0x22e>
    3f58:	00002097          	auipc	ra,0x2
    3f5c:	8f4080e7          	jalr	-1804(ra) # 584c <write>
    3f60:	10a04b63          	bgtz	a0,4076 <dirfile+0x218>
  close(fd);
    3f64:	8526                	mv	a0,s1
    3f66:	00002097          	auipc	ra,0x2
    3f6a:	8ee080e7          	jalr	-1810(ra) # 5854 <close>
}
    3f6e:	60e2                	ld	ra,24(sp)
    3f70:	6442                	ld	s0,16(sp)
    3f72:	64a2                	ld	s1,8(sp)
    3f74:	6902                	ld	s2,0(sp)
    3f76:	6105                	addi	sp,sp,32
    3f78:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3f7a:	85ca                	mv	a1,s2
    3f7c:	00003517          	auipc	a0,0x3
    3f80:	65c50513          	addi	a0,a0,1628 # 75d8 <malloc+0x195e>
    3f84:	00002097          	auipc	ra,0x2
    3f88:	c38080e7          	jalr	-968(ra) # 5bbc <printf>
    exit(1);
    3f8c:	4505                	li	a0,1
    3f8e:	00002097          	auipc	ra,0x2
    3f92:	89e080e7          	jalr	-1890(ra) # 582c <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3f96:	85ca                	mv	a1,s2
    3f98:	00003517          	auipc	a0,0x3
    3f9c:	66050513          	addi	a0,a0,1632 # 75f8 <malloc+0x197e>
    3fa0:	00002097          	auipc	ra,0x2
    3fa4:	c1c080e7          	jalr	-996(ra) # 5bbc <printf>
    exit(1);
    3fa8:	4505                	li	a0,1
    3faa:	00002097          	auipc	ra,0x2
    3fae:	882080e7          	jalr	-1918(ra) # 582c <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3fb2:	85ca                	mv	a1,s2
    3fb4:	00003517          	auipc	a0,0x3
    3fb8:	67450513          	addi	a0,a0,1652 # 7628 <malloc+0x19ae>
    3fbc:	00002097          	auipc	ra,0x2
    3fc0:	c00080e7          	jalr	-1024(ra) # 5bbc <printf>
    exit(1);
    3fc4:	4505                	li	a0,1
    3fc6:	00002097          	auipc	ra,0x2
    3fca:	866080e7          	jalr	-1946(ra) # 582c <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3fce:	85ca                	mv	a1,s2
    3fd0:	00003517          	auipc	a0,0x3
    3fd4:	65850513          	addi	a0,a0,1624 # 7628 <malloc+0x19ae>
    3fd8:	00002097          	auipc	ra,0x2
    3fdc:	be4080e7          	jalr	-1052(ra) # 5bbc <printf>
    exit(1);
    3fe0:	4505                	li	a0,1
    3fe2:	00002097          	auipc	ra,0x2
    3fe6:	84a080e7          	jalr	-1974(ra) # 582c <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3fea:	85ca                	mv	a1,s2
    3fec:	00003517          	auipc	a0,0x3
    3ff0:	66450513          	addi	a0,a0,1636 # 7650 <malloc+0x19d6>
    3ff4:	00002097          	auipc	ra,0x2
    3ff8:	bc8080e7          	jalr	-1080(ra) # 5bbc <printf>
    exit(1);
    3ffc:	4505                	li	a0,1
    3ffe:	00002097          	auipc	ra,0x2
    4002:	82e080e7          	jalr	-2002(ra) # 582c <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4006:	85ca                	mv	a1,s2
    4008:	00003517          	auipc	a0,0x3
    400c:	67050513          	addi	a0,a0,1648 # 7678 <malloc+0x19fe>
    4010:	00002097          	auipc	ra,0x2
    4014:	bac080e7          	jalr	-1108(ra) # 5bbc <printf>
    exit(1);
    4018:	4505                	li	a0,1
    401a:	00002097          	auipc	ra,0x2
    401e:	812080e7          	jalr	-2030(ra) # 582c <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    4022:	85ca                	mv	a1,s2
    4024:	00003517          	auipc	a0,0x3
    4028:	67c50513          	addi	a0,a0,1660 # 76a0 <malloc+0x1a26>
    402c:	00002097          	auipc	ra,0x2
    4030:	b90080e7          	jalr	-1136(ra) # 5bbc <printf>
    exit(1);
    4034:	4505                	li	a0,1
    4036:	00001097          	auipc	ra,0x1
    403a:	7f6080e7          	jalr	2038(ra) # 582c <exit>
    printf("%s: unlink dirfile failed!\n", s);
    403e:	85ca                	mv	a1,s2
    4040:	00003517          	auipc	a0,0x3
    4044:	68850513          	addi	a0,a0,1672 # 76c8 <malloc+0x1a4e>
    4048:	00002097          	auipc	ra,0x2
    404c:	b74080e7          	jalr	-1164(ra) # 5bbc <printf>
    exit(1);
    4050:	4505                	li	a0,1
    4052:	00001097          	auipc	ra,0x1
    4056:	7da080e7          	jalr	2010(ra) # 582c <exit>
    printf("%s: open . for writing succeeded!\n", s);
    405a:	85ca                	mv	a1,s2
    405c:	00003517          	auipc	a0,0x3
    4060:	68c50513          	addi	a0,a0,1676 # 76e8 <malloc+0x1a6e>
    4064:	00002097          	auipc	ra,0x2
    4068:	b58080e7          	jalr	-1192(ra) # 5bbc <printf>
    exit(1);
    406c:	4505                	li	a0,1
    406e:	00001097          	auipc	ra,0x1
    4072:	7be080e7          	jalr	1982(ra) # 582c <exit>
    printf("%s: write . succeeded!\n", s);
    4076:	85ca                	mv	a1,s2
    4078:	00003517          	auipc	a0,0x3
    407c:	69850513          	addi	a0,a0,1688 # 7710 <malloc+0x1a96>
    4080:	00002097          	auipc	ra,0x2
    4084:	b3c080e7          	jalr	-1220(ra) # 5bbc <printf>
    exit(1);
    4088:	4505                	li	a0,1
    408a:	00001097          	auipc	ra,0x1
    408e:	7a2080e7          	jalr	1954(ra) # 582c <exit>

0000000000004092 <iref>:
{
    4092:	7139                	addi	sp,sp,-64
    4094:	fc06                	sd	ra,56(sp)
    4096:	f822                	sd	s0,48(sp)
    4098:	f426                	sd	s1,40(sp)
    409a:	f04a                	sd	s2,32(sp)
    409c:	ec4e                	sd	s3,24(sp)
    409e:	e852                	sd	s4,16(sp)
    40a0:	e456                	sd	s5,8(sp)
    40a2:	e05a                	sd	s6,0(sp)
    40a4:	0080                	addi	s0,sp,64
    40a6:	8b2a                	mv	s6,a0
    40a8:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    40ac:	00003a17          	auipc	s4,0x3
    40b0:	67ca0a13          	addi	s4,s4,1660 # 7728 <malloc+0x1aae>
    mkdir("");
    40b4:	00003497          	auipc	s1,0x3
    40b8:	e1c48493          	addi	s1,s1,-484 # 6ed0 <malloc+0x1256>
    link("README", "");
    40bc:	00002a97          	auipc	s5,0x2
    40c0:	d9ca8a93          	addi	s5,s5,-612 # 5e58 <malloc+0x1de>
    fd = open("xx", O_CREATE);
    40c4:	00003997          	auipc	s3,0x3
    40c8:	55c98993          	addi	s3,s3,1372 # 7620 <malloc+0x19a6>
    40cc:	a891                	j	4120 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    40ce:	85da                	mv	a1,s6
    40d0:	00003517          	auipc	a0,0x3
    40d4:	66050513          	addi	a0,a0,1632 # 7730 <malloc+0x1ab6>
    40d8:	00002097          	auipc	ra,0x2
    40dc:	ae4080e7          	jalr	-1308(ra) # 5bbc <printf>
      exit(1);
    40e0:	4505                	li	a0,1
    40e2:	00001097          	auipc	ra,0x1
    40e6:	74a080e7          	jalr	1866(ra) # 582c <exit>
      printf("%s: chdir irefd failed\n", s);
    40ea:	85da                	mv	a1,s6
    40ec:	00003517          	auipc	a0,0x3
    40f0:	65c50513          	addi	a0,a0,1628 # 7748 <malloc+0x1ace>
    40f4:	00002097          	auipc	ra,0x2
    40f8:	ac8080e7          	jalr	-1336(ra) # 5bbc <printf>
      exit(1);
    40fc:	4505                	li	a0,1
    40fe:	00001097          	auipc	ra,0x1
    4102:	72e080e7          	jalr	1838(ra) # 582c <exit>
      close(fd);
    4106:	00001097          	auipc	ra,0x1
    410a:	74e080e7          	jalr	1870(ra) # 5854 <close>
    410e:	a889                	j	4160 <iref+0xce>
    unlink("xx");
    4110:	854e                	mv	a0,s3
    4112:	00001097          	auipc	ra,0x1
    4116:	76a080e7          	jalr	1898(ra) # 587c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    411a:	397d                	addiw	s2,s2,-1
    411c:	06090063          	beqz	s2,417c <iref+0xea>
    if(mkdir("irefd") != 0){
    4120:	8552                	mv	a0,s4
    4122:	00001097          	auipc	ra,0x1
    4126:	772080e7          	jalr	1906(ra) # 5894 <mkdir>
    412a:	f155                	bnez	a0,40ce <iref+0x3c>
    if(chdir("irefd") != 0){
    412c:	8552                	mv	a0,s4
    412e:	00001097          	auipc	ra,0x1
    4132:	76e080e7          	jalr	1902(ra) # 589c <chdir>
    4136:	f955                	bnez	a0,40ea <iref+0x58>
    mkdir("");
    4138:	8526                	mv	a0,s1
    413a:	00001097          	auipc	ra,0x1
    413e:	75a080e7          	jalr	1882(ra) # 5894 <mkdir>
    link("README", "");
    4142:	85a6                	mv	a1,s1
    4144:	8556                	mv	a0,s5
    4146:	00001097          	auipc	ra,0x1
    414a:	746080e7          	jalr	1862(ra) # 588c <link>
    fd = open("", O_CREATE);
    414e:	20000593          	li	a1,512
    4152:	8526                	mv	a0,s1
    4154:	00001097          	auipc	ra,0x1
    4158:	718080e7          	jalr	1816(ra) # 586c <open>
    if(fd >= 0)
    415c:	fa0555e3          	bgez	a0,4106 <iref+0x74>
    fd = open("xx", O_CREATE);
    4160:	20000593          	li	a1,512
    4164:	854e                	mv	a0,s3
    4166:	00001097          	auipc	ra,0x1
    416a:	706080e7          	jalr	1798(ra) # 586c <open>
    if(fd >= 0)
    416e:	fa0541e3          	bltz	a0,4110 <iref+0x7e>
      close(fd);
    4172:	00001097          	auipc	ra,0x1
    4176:	6e2080e7          	jalr	1762(ra) # 5854 <close>
    417a:	bf59                	j	4110 <iref+0x7e>
    417c:	03300493          	li	s1,51
    chdir("..");
    4180:	00002997          	auipc	s3,0x2
    4184:	40098993          	addi	s3,s3,1024 # 6580 <malloc+0x906>
    unlink("irefd");
    4188:	00003917          	auipc	s2,0x3
    418c:	5a090913          	addi	s2,s2,1440 # 7728 <malloc+0x1aae>
    chdir("..");
    4190:	854e                	mv	a0,s3
    4192:	00001097          	auipc	ra,0x1
    4196:	70a080e7          	jalr	1802(ra) # 589c <chdir>
    unlink("irefd");
    419a:	854a                	mv	a0,s2
    419c:	00001097          	auipc	ra,0x1
    41a0:	6e0080e7          	jalr	1760(ra) # 587c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    41a4:	34fd                	addiw	s1,s1,-1
    41a6:	f4ed                	bnez	s1,4190 <iref+0xfe>
  chdir("/");
    41a8:	00002517          	auipc	a0,0x2
    41ac:	0f050513          	addi	a0,a0,240 # 6298 <malloc+0x61e>
    41b0:	00001097          	auipc	ra,0x1
    41b4:	6ec080e7          	jalr	1772(ra) # 589c <chdir>
}
    41b8:	70e2                	ld	ra,56(sp)
    41ba:	7442                	ld	s0,48(sp)
    41bc:	74a2                	ld	s1,40(sp)
    41be:	7902                	ld	s2,32(sp)
    41c0:	69e2                	ld	s3,24(sp)
    41c2:	6a42                	ld	s4,16(sp)
    41c4:	6aa2                	ld	s5,8(sp)
    41c6:	6b02                	ld	s6,0(sp)
    41c8:	6121                	addi	sp,sp,64
    41ca:	8082                	ret

00000000000041cc <forktest>:
{
    41cc:	7179                	addi	sp,sp,-48
    41ce:	f406                	sd	ra,40(sp)
    41d0:	f022                	sd	s0,32(sp)
    41d2:	ec26                	sd	s1,24(sp)
    41d4:	e84a                	sd	s2,16(sp)
    41d6:	e44e                	sd	s3,8(sp)
    41d8:	1800                	addi	s0,sp,48
    41da:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    41dc:	4481                	li	s1,0
    41de:	3e800913          	li	s2,1000
    pid = fork();
    41e2:	00001097          	auipc	ra,0x1
    41e6:	642080e7          	jalr	1602(ra) # 5824 <fork>
    if(pid < 0)
    41ea:	02054863          	bltz	a0,421a <forktest+0x4e>
    if(pid == 0)
    41ee:	c115                	beqz	a0,4212 <forktest+0x46>
  for(n=0; n<N; n++){
    41f0:	2485                	addiw	s1,s1,1
    41f2:	ff2498e3          	bne	s1,s2,41e2 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    41f6:	85ce                	mv	a1,s3
    41f8:	00003517          	auipc	a0,0x3
    41fc:	58050513          	addi	a0,a0,1408 # 7778 <malloc+0x1afe>
    4200:	00002097          	auipc	ra,0x2
    4204:	9bc080e7          	jalr	-1604(ra) # 5bbc <printf>
    exit(1);
    4208:	4505                	li	a0,1
    420a:	00001097          	auipc	ra,0x1
    420e:	622080e7          	jalr	1570(ra) # 582c <exit>
      exit(0);
    4212:	00001097          	auipc	ra,0x1
    4216:	61a080e7          	jalr	1562(ra) # 582c <exit>
  if (n == 0) {
    421a:	cc9d                	beqz	s1,4258 <forktest+0x8c>
  if(n == N){
    421c:	3e800793          	li	a5,1000
    4220:	fcf48be3          	beq	s1,a5,41f6 <forktest+0x2a>
  for(; n > 0; n--){
    4224:	00905b63          	blez	s1,423a <forktest+0x6e>
    if(wait(0) < 0){
    4228:	4501                	li	a0,0
    422a:	00001097          	auipc	ra,0x1
    422e:	60a080e7          	jalr	1546(ra) # 5834 <wait>
    4232:	04054163          	bltz	a0,4274 <forktest+0xa8>
  for(; n > 0; n--){
    4236:	34fd                	addiw	s1,s1,-1
    4238:	f8e5                	bnez	s1,4228 <forktest+0x5c>
  if(wait(0) != -1){
    423a:	4501                	li	a0,0
    423c:	00001097          	auipc	ra,0x1
    4240:	5f8080e7          	jalr	1528(ra) # 5834 <wait>
    4244:	57fd                	li	a5,-1
    4246:	04f51563          	bne	a0,a5,4290 <forktest+0xc4>
}
    424a:	70a2                	ld	ra,40(sp)
    424c:	7402                	ld	s0,32(sp)
    424e:	64e2                	ld	s1,24(sp)
    4250:	6942                	ld	s2,16(sp)
    4252:	69a2                	ld	s3,8(sp)
    4254:	6145                	addi	sp,sp,48
    4256:	8082                	ret
    printf("%s: no fork at all!\n", s);
    4258:	85ce                	mv	a1,s3
    425a:	00003517          	auipc	a0,0x3
    425e:	50650513          	addi	a0,a0,1286 # 7760 <malloc+0x1ae6>
    4262:	00002097          	auipc	ra,0x2
    4266:	95a080e7          	jalr	-1702(ra) # 5bbc <printf>
    exit(1);
    426a:	4505                	li	a0,1
    426c:	00001097          	auipc	ra,0x1
    4270:	5c0080e7          	jalr	1472(ra) # 582c <exit>
      printf("%s: wait stopped early\n", s);
    4274:	85ce                	mv	a1,s3
    4276:	00003517          	auipc	a0,0x3
    427a:	52a50513          	addi	a0,a0,1322 # 77a0 <malloc+0x1b26>
    427e:	00002097          	auipc	ra,0x2
    4282:	93e080e7          	jalr	-1730(ra) # 5bbc <printf>
      exit(1);
    4286:	4505                	li	a0,1
    4288:	00001097          	auipc	ra,0x1
    428c:	5a4080e7          	jalr	1444(ra) # 582c <exit>
    printf("%s: wait got too many\n", s);
    4290:	85ce                	mv	a1,s3
    4292:	00003517          	auipc	a0,0x3
    4296:	52650513          	addi	a0,a0,1318 # 77b8 <malloc+0x1b3e>
    429a:	00002097          	auipc	ra,0x2
    429e:	922080e7          	jalr	-1758(ra) # 5bbc <printf>
    exit(1);
    42a2:	4505                	li	a0,1
    42a4:	00001097          	auipc	ra,0x1
    42a8:	588080e7          	jalr	1416(ra) # 582c <exit>

00000000000042ac <sbrkbasic>:
{
    42ac:	715d                	addi	sp,sp,-80
    42ae:	e486                	sd	ra,72(sp)
    42b0:	e0a2                	sd	s0,64(sp)
    42b2:	fc26                	sd	s1,56(sp)
    42b4:	f84a                	sd	s2,48(sp)
    42b6:	f44e                	sd	s3,40(sp)
    42b8:	f052                	sd	s4,32(sp)
    42ba:	ec56                	sd	s5,24(sp)
    42bc:	0880                	addi	s0,sp,80
    42be:	8a2a                	mv	s4,a0
  pid = fork();
    42c0:	00001097          	auipc	ra,0x1
    42c4:	564080e7          	jalr	1380(ra) # 5824 <fork>
  if(pid < 0){
    42c8:	02054c63          	bltz	a0,4300 <sbrkbasic+0x54>
  if(pid == 0){
    42cc:	ed21                	bnez	a0,4324 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    42ce:	40000537          	lui	a0,0x40000
    42d2:	00001097          	auipc	ra,0x1
    42d6:	5e2080e7          	jalr	1506(ra) # 58b4 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    42da:	57fd                	li	a5,-1
    42dc:	02f50f63          	beq	a0,a5,431a <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    42e0:	400007b7          	lui	a5,0x40000
    42e4:	97aa                	add	a5,a5,a0
      *b = 99;
    42e6:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    42ea:	6705                	lui	a4,0x1
      *b = 99;
    42ec:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1918>
    for(b = a; b < a+TOOMUCH; b += 4096){
    42f0:	953a                	add	a0,a0,a4
    42f2:	fef51de3          	bne	a0,a5,42ec <sbrkbasic+0x40>
    exit(1);
    42f6:	4505                	li	a0,1
    42f8:	00001097          	auipc	ra,0x1
    42fc:	534080e7          	jalr	1332(ra) # 582c <exit>
    printf("fork failed in sbrkbasic\n");
    4300:	00003517          	auipc	a0,0x3
    4304:	4d050513          	addi	a0,a0,1232 # 77d0 <malloc+0x1b56>
    4308:	00002097          	auipc	ra,0x2
    430c:	8b4080e7          	jalr	-1868(ra) # 5bbc <printf>
    exit(1);
    4310:	4505                	li	a0,1
    4312:	00001097          	auipc	ra,0x1
    4316:	51a080e7          	jalr	1306(ra) # 582c <exit>
      exit(0);
    431a:	4501                	li	a0,0
    431c:	00001097          	auipc	ra,0x1
    4320:	510080e7          	jalr	1296(ra) # 582c <exit>
  wait(&xstatus);
    4324:	fbc40513          	addi	a0,s0,-68
    4328:	00001097          	auipc	ra,0x1
    432c:	50c080e7          	jalr	1292(ra) # 5834 <wait>
  if(xstatus == 1){
    4330:	fbc42703          	lw	a4,-68(s0)
    4334:	4785                	li	a5,1
    4336:	00f70e63          	beq	a4,a5,4352 <sbrkbasic+0xa6>
  a = sbrk(0);
    433a:	4501                	li	a0,0
    433c:	00001097          	auipc	ra,0x1
    4340:	578080e7          	jalr	1400(ra) # 58b4 <sbrk>
    4344:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    4346:	4901                	li	s2,0
    *b = 1;
    4348:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    434a:	6985                	lui	s3,0x1
    434c:	38898993          	addi	s3,s3,904 # 1388 <createtest+0xc>
    4350:	a005                	j	4370 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    4352:	85d2                	mv	a1,s4
    4354:	00003517          	auipc	a0,0x3
    4358:	49c50513          	addi	a0,a0,1180 # 77f0 <malloc+0x1b76>
    435c:	00002097          	auipc	ra,0x2
    4360:	860080e7          	jalr	-1952(ra) # 5bbc <printf>
    exit(1);
    4364:	4505                	li	a0,1
    4366:	00001097          	auipc	ra,0x1
    436a:	4c6080e7          	jalr	1222(ra) # 582c <exit>
    a = b + 1;
    436e:	84be                	mv	s1,a5
    b = sbrk(1);
    4370:	4505                	li	a0,1
    4372:	00001097          	auipc	ra,0x1
    4376:	542080e7          	jalr	1346(ra) # 58b4 <sbrk>
    if(b != a){
    437a:	04951b63          	bne	a0,s1,43d0 <sbrkbasic+0x124>
    *b = 1;
    437e:	01548023          	sb	s5,0(s1)
    a = b + 1;
    4382:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    4386:	2905                	addiw	s2,s2,1
    4388:	ff3913e3          	bne	s2,s3,436e <sbrkbasic+0xc2>
  pid = fork();
    438c:	00001097          	auipc	ra,0x1
    4390:	498080e7          	jalr	1176(ra) # 5824 <fork>
    4394:	892a                	mv	s2,a0
  if(pid < 0){
    4396:	04054e63          	bltz	a0,43f2 <sbrkbasic+0x146>
  c = sbrk(1);
    439a:	4505                	li	a0,1
    439c:	00001097          	auipc	ra,0x1
    43a0:	518080e7          	jalr	1304(ra) # 58b4 <sbrk>
  c = sbrk(1);
    43a4:	4505                	li	a0,1
    43a6:	00001097          	auipc	ra,0x1
    43aa:	50e080e7          	jalr	1294(ra) # 58b4 <sbrk>
  if(c != a + 1){
    43ae:	0489                	addi	s1,s1,2
    43b0:	04a48f63          	beq	s1,a0,440e <sbrkbasic+0x162>
    printf("%s: sbrk test failed post-fork\n", s);
    43b4:	85d2                	mv	a1,s4
    43b6:	00003517          	auipc	a0,0x3
    43ba:	49a50513          	addi	a0,a0,1178 # 7850 <malloc+0x1bd6>
    43be:	00001097          	auipc	ra,0x1
    43c2:	7fe080e7          	jalr	2046(ra) # 5bbc <printf>
    exit(1);
    43c6:	4505                	li	a0,1
    43c8:	00001097          	auipc	ra,0x1
    43cc:	464080e7          	jalr	1124(ra) # 582c <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    43d0:	872a                	mv	a4,a0
    43d2:	86a6                	mv	a3,s1
    43d4:	864a                	mv	a2,s2
    43d6:	85d2                	mv	a1,s4
    43d8:	00003517          	auipc	a0,0x3
    43dc:	43850513          	addi	a0,a0,1080 # 7810 <malloc+0x1b96>
    43e0:	00001097          	auipc	ra,0x1
    43e4:	7dc080e7          	jalr	2012(ra) # 5bbc <printf>
      exit(1);
    43e8:	4505                	li	a0,1
    43ea:	00001097          	auipc	ra,0x1
    43ee:	442080e7          	jalr	1090(ra) # 582c <exit>
    printf("%s: sbrk test fork failed\n", s);
    43f2:	85d2                	mv	a1,s4
    43f4:	00003517          	auipc	a0,0x3
    43f8:	43c50513          	addi	a0,a0,1084 # 7830 <malloc+0x1bb6>
    43fc:	00001097          	auipc	ra,0x1
    4400:	7c0080e7          	jalr	1984(ra) # 5bbc <printf>
    exit(1);
    4404:	4505                	li	a0,1
    4406:	00001097          	auipc	ra,0x1
    440a:	426080e7          	jalr	1062(ra) # 582c <exit>
  if(pid == 0)
    440e:	00091763          	bnez	s2,441c <sbrkbasic+0x170>
    exit(0);
    4412:	4501                	li	a0,0
    4414:	00001097          	auipc	ra,0x1
    4418:	418080e7          	jalr	1048(ra) # 582c <exit>
  wait(&xstatus);
    441c:	fbc40513          	addi	a0,s0,-68
    4420:	00001097          	auipc	ra,0x1
    4424:	414080e7          	jalr	1044(ra) # 5834 <wait>
  exit(xstatus);
    4428:	fbc42503          	lw	a0,-68(s0)
    442c:	00001097          	auipc	ra,0x1
    4430:	400080e7          	jalr	1024(ra) # 582c <exit>

0000000000004434 <sbrkmuch>:
{
    4434:	7179                	addi	sp,sp,-48
    4436:	f406                	sd	ra,40(sp)
    4438:	f022                	sd	s0,32(sp)
    443a:	ec26                	sd	s1,24(sp)
    443c:	e84a                	sd	s2,16(sp)
    443e:	e44e                	sd	s3,8(sp)
    4440:	e052                	sd	s4,0(sp)
    4442:	1800                	addi	s0,sp,48
    4444:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    4446:	4501                	li	a0,0
    4448:	00001097          	auipc	ra,0x1
    444c:	46c080e7          	jalr	1132(ra) # 58b4 <sbrk>
    4450:	892a                	mv	s2,a0
  a = sbrk(0);
    4452:	4501                	li	a0,0
    4454:	00001097          	auipc	ra,0x1
    4458:	460080e7          	jalr	1120(ra) # 58b4 <sbrk>
    445c:	84aa                	mv	s1,a0
  p = sbrk(amt);
    445e:	06400537          	lui	a0,0x6400
    4462:	9d05                	subw	a0,a0,s1
    4464:	00001097          	auipc	ra,0x1
    4468:	450080e7          	jalr	1104(ra) # 58b4 <sbrk>
  if (p != a) {
    446c:	0ca49863          	bne	s1,a0,453c <sbrkmuch+0x108>
  char *eee = sbrk(0);
    4470:	4501                	li	a0,0
    4472:	00001097          	auipc	ra,0x1
    4476:	442080e7          	jalr	1090(ra) # 58b4 <sbrk>
    447a:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    447c:	00a4f963          	bgeu	s1,a0,448e <sbrkmuch+0x5a>
    *pp = 1;
    4480:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    4482:	6705                	lui	a4,0x1
    *pp = 1;
    4484:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    4488:	94ba                	add	s1,s1,a4
    448a:	fef4ede3          	bltu	s1,a5,4484 <sbrkmuch+0x50>
  *lastaddr = 99;
    448e:	064007b7          	lui	a5,0x6400
    4492:	06300713          	li	a4,99
    4496:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1917>
  a = sbrk(0);
    449a:	4501                	li	a0,0
    449c:	00001097          	auipc	ra,0x1
    44a0:	418080e7          	jalr	1048(ra) # 58b4 <sbrk>
    44a4:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    44a6:	757d                	lui	a0,0xfffff
    44a8:	00001097          	auipc	ra,0x1
    44ac:	40c080e7          	jalr	1036(ra) # 58b4 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    44b0:	57fd                	li	a5,-1
    44b2:	0af50363          	beq	a0,a5,4558 <sbrkmuch+0x124>
  c = sbrk(0);
    44b6:	4501                	li	a0,0
    44b8:	00001097          	auipc	ra,0x1
    44bc:	3fc080e7          	jalr	1020(ra) # 58b4 <sbrk>
  if(c != a - PGSIZE){
    44c0:	77fd                	lui	a5,0xfffff
    44c2:	97a6                	add	a5,a5,s1
    44c4:	0af51863          	bne	a0,a5,4574 <sbrkmuch+0x140>
  a = sbrk(0);
    44c8:	4501                	li	a0,0
    44ca:	00001097          	auipc	ra,0x1
    44ce:	3ea080e7          	jalr	1002(ra) # 58b4 <sbrk>
    44d2:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    44d4:	6505                	lui	a0,0x1
    44d6:	00001097          	auipc	ra,0x1
    44da:	3de080e7          	jalr	990(ra) # 58b4 <sbrk>
    44de:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    44e0:	0aa49a63          	bne	s1,a0,4594 <sbrkmuch+0x160>
    44e4:	4501                	li	a0,0
    44e6:	00001097          	auipc	ra,0x1
    44ea:	3ce080e7          	jalr	974(ra) # 58b4 <sbrk>
    44ee:	6785                	lui	a5,0x1
    44f0:	97a6                	add	a5,a5,s1
    44f2:	0af51163          	bne	a0,a5,4594 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    44f6:	064007b7          	lui	a5,0x6400
    44fa:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1917>
    44fe:	06300793          	li	a5,99
    4502:	0af70963          	beq	a4,a5,45b4 <sbrkmuch+0x180>
  a = sbrk(0);
    4506:	4501                	li	a0,0
    4508:	00001097          	auipc	ra,0x1
    450c:	3ac080e7          	jalr	940(ra) # 58b4 <sbrk>
    4510:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    4512:	4501                	li	a0,0
    4514:	00001097          	auipc	ra,0x1
    4518:	3a0080e7          	jalr	928(ra) # 58b4 <sbrk>
    451c:	40a9053b          	subw	a0,s2,a0
    4520:	00001097          	auipc	ra,0x1
    4524:	394080e7          	jalr	916(ra) # 58b4 <sbrk>
  if(c != a){
    4528:	0aa49463          	bne	s1,a0,45d0 <sbrkmuch+0x19c>
}
    452c:	70a2                	ld	ra,40(sp)
    452e:	7402                	ld	s0,32(sp)
    4530:	64e2                	ld	s1,24(sp)
    4532:	6942                	ld	s2,16(sp)
    4534:	69a2                	ld	s3,8(sp)
    4536:	6a02                	ld	s4,0(sp)
    4538:	6145                	addi	sp,sp,48
    453a:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    453c:	85ce                	mv	a1,s3
    453e:	00003517          	auipc	a0,0x3
    4542:	33250513          	addi	a0,a0,818 # 7870 <malloc+0x1bf6>
    4546:	00001097          	auipc	ra,0x1
    454a:	676080e7          	jalr	1654(ra) # 5bbc <printf>
    exit(1);
    454e:	4505                	li	a0,1
    4550:	00001097          	auipc	ra,0x1
    4554:	2dc080e7          	jalr	732(ra) # 582c <exit>
    printf("%s: sbrk could not deallocate\n", s);
    4558:	85ce                	mv	a1,s3
    455a:	00003517          	auipc	a0,0x3
    455e:	35e50513          	addi	a0,a0,862 # 78b8 <malloc+0x1c3e>
    4562:	00001097          	auipc	ra,0x1
    4566:	65a080e7          	jalr	1626(ra) # 5bbc <printf>
    exit(1);
    456a:	4505                	li	a0,1
    456c:	00001097          	auipc	ra,0x1
    4570:	2c0080e7          	jalr	704(ra) # 582c <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    4574:	86aa                	mv	a3,a0
    4576:	8626                	mv	a2,s1
    4578:	85ce                	mv	a1,s3
    457a:	00003517          	auipc	a0,0x3
    457e:	35e50513          	addi	a0,a0,862 # 78d8 <malloc+0x1c5e>
    4582:	00001097          	auipc	ra,0x1
    4586:	63a080e7          	jalr	1594(ra) # 5bbc <printf>
    exit(1);
    458a:	4505                	li	a0,1
    458c:	00001097          	auipc	ra,0x1
    4590:	2a0080e7          	jalr	672(ra) # 582c <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    4594:	86d2                	mv	a3,s4
    4596:	8626                	mv	a2,s1
    4598:	85ce                	mv	a1,s3
    459a:	00003517          	auipc	a0,0x3
    459e:	37e50513          	addi	a0,a0,894 # 7918 <malloc+0x1c9e>
    45a2:	00001097          	auipc	ra,0x1
    45a6:	61a080e7          	jalr	1562(ra) # 5bbc <printf>
    exit(1);
    45aa:	4505                	li	a0,1
    45ac:	00001097          	auipc	ra,0x1
    45b0:	280080e7          	jalr	640(ra) # 582c <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    45b4:	85ce                	mv	a1,s3
    45b6:	00003517          	auipc	a0,0x3
    45ba:	39250513          	addi	a0,a0,914 # 7948 <malloc+0x1cce>
    45be:	00001097          	auipc	ra,0x1
    45c2:	5fe080e7          	jalr	1534(ra) # 5bbc <printf>
    exit(1);
    45c6:	4505                	li	a0,1
    45c8:	00001097          	auipc	ra,0x1
    45cc:	264080e7          	jalr	612(ra) # 582c <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    45d0:	86aa                	mv	a3,a0
    45d2:	8626                	mv	a2,s1
    45d4:	85ce                	mv	a1,s3
    45d6:	00003517          	auipc	a0,0x3
    45da:	3aa50513          	addi	a0,a0,938 # 7980 <malloc+0x1d06>
    45de:	00001097          	auipc	ra,0x1
    45e2:	5de080e7          	jalr	1502(ra) # 5bbc <printf>
    exit(1);
    45e6:	4505                	li	a0,1
    45e8:	00001097          	auipc	ra,0x1
    45ec:	244080e7          	jalr	580(ra) # 582c <exit>

00000000000045f0 <kernmem>:
{
    45f0:	715d                	addi	sp,sp,-80
    45f2:	e486                	sd	ra,72(sp)
    45f4:	e0a2                	sd	s0,64(sp)
    45f6:	fc26                	sd	s1,56(sp)
    45f8:	f84a                	sd	s2,48(sp)
    45fa:	f44e                	sd	s3,40(sp)
    45fc:	f052                	sd	s4,32(sp)
    45fe:	ec56                	sd	s5,24(sp)
    4600:	0880                	addi	s0,sp,80
    4602:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4604:	4485                	li	s1,1
    4606:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    4608:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    460a:	69b1                	lui	s3,0xc
    460c:	35098993          	addi	s3,s3,848 # c350 <buf+0xc78>
    4610:	1003d937          	lui	s2,0x1003d
    4614:	090e                	slli	s2,s2,0x3
    4616:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002ed98>
    pid = fork();
    461a:	00001097          	auipc	ra,0x1
    461e:	20a080e7          	jalr	522(ra) # 5824 <fork>
    if(pid < 0){
    4622:	02054963          	bltz	a0,4654 <kernmem+0x64>
    if(pid == 0){
    4626:	c529                	beqz	a0,4670 <kernmem+0x80>
    wait(&xstatus);
    4628:	fbc40513          	addi	a0,s0,-68
    462c:	00001097          	auipc	ra,0x1
    4630:	208080e7          	jalr	520(ra) # 5834 <wait>
    if(xstatus != -1)  // did kernel kill child?
    4634:	fbc42783          	lw	a5,-68(s0)
    4638:	05579d63          	bne	a5,s5,4692 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    463c:	94ce                	add	s1,s1,s3
    463e:	fd249ee3          	bne	s1,s2,461a <kernmem+0x2a>
}
    4642:	60a6                	ld	ra,72(sp)
    4644:	6406                	ld	s0,64(sp)
    4646:	74e2                	ld	s1,56(sp)
    4648:	7942                	ld	s2,48(sp)
    464a:	79a2                	ld	s3,40(sp)
    464c:	7a02                	ld	s4,32(sp)
    464e:	6ae2                	ld	s5,24(sp)
    4650:	6161                	addi	sp,sp,80
    4652:	8082                	ret
      printf("%s: fork failed\n", s);
    4654:	85d2                	mv	a1,s4
    4656:	00002517          	auipc	a0,0x2
    465a:	b4a50513          	addi	a0,a0,-1206 # 61a0 <malloc+0x526>
    465e:	00001097          	auipc	ra,0x1
    4662:	55e080e7          	jalr	1374(ra) # 5bbc <printf>
      exit(1);
    4666:	4505                	li	a0,1
    4668:	00001097          	auipc	ra,0x1
    466c:	1c4080e7          	jalr	452(ra) # 582c <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    4670:	0004c683          	lbu	a3,0(s1)
    4674:	8626                	mv	a2,s1
    4676:	85d2                	mv	a1,s4
    4678:	00003517          	auipc	a0,0x3
    467c:	33050513          	addi	a0,a0,816 # 79a8 <malloc+0x1d2e>
    4680:	00001097          	auipc	ra,0x1
    4684:	53c080e7          	jalr	1340(ra) # 5bbc <printf>
      exit(1);
    4688:	4505                	li	a0,1
    468a:	00001097          	auipc	ra,0x1
    468e:	1a2080e7          	jalr	418(ra) # 582c <exit>
      exit(1);
    4692:	4505                	li	a0,1
    4694:	00001097          	auipc	ra,0x1
    4698:	198080e7          	jalr	408(ra) # 582c <exit>

000000000000469c <MAXVAplus>:
{
    469c:	7179                	addi	sp,sp,-48
    469e:	f406                	sd	ra,40(sp)
    46a0:	f022                	sd	s0,32(sp)
    46a2:	ec26                	sd	s1,24(sp)
    46a4:	e84a                	sd	s2,16(sp)
    46a6:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    46a8:	4785                	li	a5,1
    46aa:	179a                	slli	a5,a5,0x26
    46ac:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    46b0:	fd843783          	ld	a5,-40(s0)
    46b4:	cf85                	beqz	a5,46ec <MAXVAplus+0x50>
    46b6:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    46b8:	54fd                	li	s1,-1
    pid = fork();
    46ba:	00001097          	auipc	ra,0x1
    46be:	16a080e7          	jalr	362(ra) # 5824 <fork>
    if(pid < 0){
    46c2:	02054b63          	bltz	a0,46f8 <MAXVAplus+0x5c>
    if(pid == 0){
    46c6:	c539                	beqz	a0,4714 <MAXVAplus+0x78>
    wait(&xstatus);
    46c8:	fd440513          	addi	a0,s0,-44
    46cc:	00001097          	auipc	ra,0x1
    46d0:	168080e7          	jalr	360(ra) # 5834 <wait>
    if(xstatus != -1)  // did kernel kill child?
    46d4:	fd442783          	lw	a5,-44(s0)
    46d8:	06979463          	bne	a5,s1,4740 <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    46dc:	fd843783          	ld	a5,-40(s0)
    46e0:	0786                	slli	a5,a5,0x1
    46e2:	fcf43c23          	sd	a5,-40(s0)
    46e6:	fd843783          	ld	a5,-40(s0)
    46ea:	fbe1                	bnez	a5,46ba <MAXVAplus+0x1e>
}
    46ec:	70a2                	ld	ra,40(sp)
    46ee:	7402                	ld	s0,32(sp)
    46f0:	64e2                	ld	s1,24(sp)
    46f2:	6942                	ld	s2,16(sp)
    46f4:	6145                	addi	sp,sp,48
    46f6:	8082                	ret
      printf("%s: fork failed\n", s);
    46f8:	85ca                	mv	a1,s2
    46fa:	00002517          	auipc	a0,0x2
    46fe:	aa650513          	addi	a0,a0,-1370 # 61a0 <malloc+0x526>
    4702:	00001097          	auipc	ra,0x1
    4706:	4ba080e7          	jalr	1210(ra) # 5bbc <printf>
      exit(1);
    470a:	4505                	li	a0,1
    470c:	00001097          	auipc	ra,0x1
    4710:	120080e7          	jalr	288(ra) # 582c <exit>
      *(char*)a = 99;
    4714:	fd843783          	ld	a5,-40(s0)
    4718:	06300713          	li	a4,99
    471c:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    4720:	fd843603          	ld	a2,-40(s0)
    4724:	85ca                	mv	a1,s2
    4726:	00003517          	auipc	a0,0x3
    472a:	2a250513          	addi	a0,a0,674 # 79c8 <malloc+0x1d4e>
    472e:	00001097          	auipc	ra,0x1
    4732:	48e080e7          	jalr	1166(ra) # 5bbc <printf>
      exit(1);
    4736:	4505                	li	a0,1
    4738:	00001097          	auipc	ra,0x1
    473c:	0f4080e7          	jalr	244(ra) # 582c <exit>
      exit(1);
    4740:	4505                	li	a0,1
    4742:	00001097          	auipc	ra,0x1
    4746:	0ea080e7          	jalr	234(ra) # 582c <exit>

000000000000474a <sbrkfail>:
{
    474a:	7119                	addi	sp,sp,-128
    474c:	fc86                	sd	ra,120(sp)
    474e:	f8a2                	sd	s0,112(sp)
    4750:	f4a6                	sd	s1,104(sp)
    4752:	f0ca                	sd	s2,96(sp)
    4754:	ecce                	sd	s3,88(sp)
    4756:	e8d2                	sd	s4,80(sp)
    4758:	e4d6                	sd	s5,72(sp)
    475a:	0100                	addi	s0,sp,128
    475c:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    475e:	fb040513          	addi	a0,s0,-80
    4762:	00001097          	auipc	ra,0x1
    4766:	0da080e7          	jalr	218(ra) # 583c <pipe>
    476a:	e901                	bnez	a0,477a <sbrkfail+0x30>
    476c:	f8040493          	addi	s1,s0,-128
    4770:	fa840a13          	addi	s4,s0,-88
    4774:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    4776:	5afd                	li	s5,-1
    4778:	a08d                	j	47da <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    477a:	85ca                	mv	a1,s2
    477c:	00002517          	auipc	a0,0x2
    4780:	ebc50513          	addi	a0,a0,-324 # 6638 <malloc+0x9be>
    4784:	00001097          	auipc	ra,0x1
    4788:	438080e7          	jalr	1080(ra) # 5bbc <printf>
    exit(1);
    478c:	4505                	li	a0,1
    478e:	00001097          	auipc	ra,0x1
    4792:	09e080e7          	jalr	158(ra) # 582c <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4796:	4501                	li	a0,0
    4798:	00001097          	auipc	ra,0x1
    479c:	11c080e7          	jalr	284(ra) # 58b4 <sbrk>
    47a0:	064007b7          	lui	a5,0x6400
    47a4:	40a7853b          	subw	a0,a5,a0
    47a8:	00001097          	auipc	ra,0x1
    47ac:	10c080e7          	jalr	268(ra) # 58b4 <sbrk>
      write(fds[1], "x", 1);
    47b0:	4605                	li	a2,1
    47b2:	00001597          	auipc	a1,0x1
    47b6:	6f658593          	addi	a1,a1,1782 # 5ea8 <malloc+0x22e>
    47ba:	fb442503          	lw	a0,-76(s0)
    47be:	00001097          	auipc	ra,0x1
    47c2:	08e080e7          	jalr	142(ra) # 584c <write>
      for(;;) sleep(1000);
    47c6:	3e800513          	li	a0,1000
    47ca:	00001097          	auipc	ra,0x1
    47ce:	0f2080e7          	jalr	242(ra) # 58bc <sleep>
    47d2:	bfd5                	j	47c6 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    47d4:	0991                	addi	s3,s3,4
    47d6:	03498563          	beq	s3,s4,4800 <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    47da:	00001097          	auipc	ra,0x1
    47de:	04a080e7          	jalr	74(ra) # 5824 <fork>
    47e2:	00a9a023          	sw	a0,0(s3)
    47e6:	d945                	beqz	a0,4796 <sbrkfail+0x4c>
    if(pids[i] != -1)
    47e8:	ff5506e3          	beq	a0,s5,47d4 <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    47ec:	4605                	li	a2,1
    47ee:	faf40593          	addi	a1,s0,-81
    47f2:	fb042503          	lw	a0,-80(s0)
    47f6:	00001097          	auipc	ra,0x1
    47fa:	04e080e7          	jalr	78(ra) # 5844 <read>
    47fe:	bfd9                	j	47d4 <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    4800:	6505                	lui	a0,0x1
    4802:	00001097          	auipc	ra,0x1
    4806:	0b2080e7          	jalr	178(ra) # 58b4 <sbrk>
    480a:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    480c:	5afd                	li	s5,-1
    480e:	a021                	j	4816 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4810:	0491                	addi	s1,s1,4
    4812:	01448f63          	beq	s1,s4,4830 <sbrkfail+0xe6>
    if(pids[i] == -1)
    4816:	4088                	lw	a0,0(s1)
    4818:	ff550ce3          	beq	a0,s5,4810 <sbrkfail+0xc6>
    kill(pids[i]);
    481c:	00001097          	auipc	ra,0x1
    4820:	040080e7          	jalr	64(ra) # 585c <kill>
    wait(0);
    4824:	4501                	li	a0,0
    4826:	00001097          	auipc	ra,0x1
    482a:	00e080e7          	jalr	14(ra) # 5834 <wait>
    482e:	b7cd                	j	4810 <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    4830:	57fd                	li	a5,-1
    4832:	04f98163          	beq	s3,a5,4874 <sbrkfail+0x12a>
  pid = fork();
    4836:	00001097          	auipc	ra,0x1
    483a:	fee080e7          	jalr	-18(ra) # 5824 <fork>
    483e:	84aa                	mv	s1,a0
  if(pid < 0){
    4840:	04054863          	bltz	a0,4890 <sbrkfail+0x146>
  if(pid == 0){
    4844:	c525                	beqz	a0,48ac <sbrkfail+0x162>
  wait(&xstatus);
    4846:	fbc40513          	addi	a0,s0,-68
    484a:	00001097          	auipc	ra,0x1
    484e:	fea080e7          	jalr	-22(ra) # 5834 <wait>
  if(xstatus != -1 && xstatus != 2)
    4852:	fbc42783          	lw	a5,-68(s0)
    4856:	577d                	li	a4,-1
    4858:	00e78563          	beq	a5,a4,4862 <sbrkfail+0x118>
    485c:	4709                	li	a4,2
    485e:	08e79d63          	bne	a5,a4,48f8 <sbrkfail+0x1ae>
}
    4862:	70e6                	ld	ra,120(sp)
    4864:	7446                	ld	s0,112(sp)
    4866:	74a6                	ld	s1,104(sp)
    4868:	7906                	ld	s2,96(sp)
    486a:	69e6                	ld	s3,88(sp)
    486c:	6a46                	ld	s4,80(sp)
    486e:	6aa6                	ld	s5,72(sp)
    4870:	6109                	addi	sp,sp,128
    4872:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4874:	85ca                	mv	a1,s2
    4876:	00003517          	auipc	a0,0x3
    487a:	16a50513          	addi	a0,a0,362 # 79e0 <malloc+0x1d66>
    487e:	00001097          	auipc	ra,0x1
    4882:	33e080e7          	jalr	830(ra) # 5bbc <printf>
    exit(1);
    4886:	4505                	li	a0,1
    4888:	00001097          	auipc	ra,0x1
    488c:	fa4080e7          	jalr	-92(ra) # 582c <exit>
    printf("%s: fork failed\n", s);
    4890:	85ca                	mv	a1,s2
    4892:	00002517          	auipc	a0,0x2
    4896:	90e50513          	addi	a0,a0,-1778 # 61a0 <malloc+0x526>
    489a:	00001097          	auipc	ra,0x1
    489e:	322080e7          	jalr	802(ra) # 5bbc <printf>
    exit(1);
    48a2:	4505                	li	a0,1
    48a4:	00001097          	auipc	ra,0x1
    48a8:	f88080e7          	jalr	-120(ra) # 582c <exit>
    a = sbrk(0);
    48ac:	4501                	li	a0,0
    48ae:	00001097          	auipc	ra,0x1
    48b2:	006080e7          	jalr	6(ra) # 58b4 <sbrk>
    48b6:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    48b8:	3e800537          	lui	a0,0x3e800
    48bc:	00001097          	auipc	ra,0x1
    48c0:	ff8080e7          	jalr	-8(ra) # 58b4 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    48c4:	874e                	mv	a4,s3
    48c6:	3e8007b7          	lui	a5,0x3e800
    48ca:	97ce                	add	a5,a5,s3
    48cc:	6685                	lui	a3,0x1
      n += *(a+i);
    48ce:	00074603          	lbu	a2,0(a4) # 1000 <opentest+0x4c>
    48d2:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    48d4:	9736                	add	a4,a4,a3
    48d6:	fef71ce3          	bne	a4,a5,48ce <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    48da:	8626                	mv	a2,s1
    48dc:	85ca                	mv	a1,s2
    48de:	00003517          	auipc	a0,0x3
    48e2:	12250513          	addi	a0,a0,290 # 7a00 <malloc+0x1d86>
    48e6:	00001097          	auipc	ra,0x1
    48ea:	2d6080e7          	jalr	726(ra) # 5bbc <printf>
    exit(1);
    48ee:	4505                	li	a0,1
    48f0:	00001097          	auipc	ra,0x1
    48f4:	f3c080e7          	jalr	-196(ra) # 582c <exit>
    exit(1);
    48f8:	4505                	li	a0,1
    48fa:	00001097          	auipc	ra,0x1
    48fe:	f32080e7          	jalr	-206(ra) # 582c <exit>

0000000000004902 <sbrkarg>:
{
    4902:	7179                	addi	sp,sp,-48
    4904:	f406                	sd	ra,40(sp)
    4906:	f022                	sd	s0,32(sp)
    4908:	ec26                	sd	s1,24(sp)
    490a:	e84a                	sd	s2,16(sp)
    490c:	e44e                	sd	s3,8(sp)
    490e:	1800                	addi	s0,sp,48
    4910:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    4912:	6505                	lui	a0,0x1
    4914:	00001097          	auipc	ra,0x1
    4918:	fa0080e7          	jalr	-96(ra) # 58b4 <sbrk>
    491c:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    491e:	20100593          	li	a1,513
    4922:	00003517          	auipc	a0,0x3
    4926:	10e50513          	addi	a0,a0,270 # 7a30 <malloc+0x1db6>
    492a:	00001097          	auipc	ra,0x1
    492e:	f42080e7          	jalr	-190(ra) # 586c <open>
    4932:	84aa                	mv	s1,a0
  unlink("sbrk");
    4934:	00003517          	auipc	a0,0x3
    4938:	0fc50513          	addi	a0,a0,252 # 7a30 <malloc+0x1db6>
    493c:	00001097          	auipc	ra,0x1
    4940:	f40080e7          	jalr	-192(ra) # 587c <unlink>
  if(fd < 0)  {
    4944:	0404c163          	bltz	s1,4986 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    4948:	6605                	lui	a2,0x1
    494a:	85ca                	mv	a1,s2
    494c:	8526                	mv	a0,s1
    494e:	00001097          	auipc	ra,0x1
    4952:	efe080e7          	jalr	-258(ra) # 584c <write>
    4956:	04054663          	bltz	a0,49a2 <sbrkarg+0xa0>
  close(fd);
    495a:	8526                	mv	a0,s1
    495c:	00001097          	auipc	ra,0x1
    4960:	ef8080e7          	jalr	-264(ra) # 5854 <close>
  a = sbrk(PGSIZE);
    4964:	6505                	lui	a0,0x1
    4966:	00001097          	auipc	ra,0x1
    496a:	f4e080e7          	jalr	-178(ra) # 58b4 <sbrk>
  if(pipe((int *) a) != 0){
    496e:	00001097          	auipc	ra,0x1
    4972:	ece080e7          	jalr	-306(ra) # 583c <pipe>
    4976:	e521                	bnez	a0,49be <sbrkarg+0xbc>
}
    4978:	70a2                	ld	ra,40(sp)
    497a:	7402                	ld	s0,32(sp)
    497c:	64e2                	ld	s1,24(sp)
    497e:	6942                	ld	s2,16(sp)
    4980:	69a2                	ld	s3,8(sp)
    4982:	6145                	addi	sp,sp,48
    4984:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    4986:	85ce                	mv	a1,s3
    4988:	00003517          	auipc	a0,0x3
    498c:	0b050513          	addi	a0,a0,176 # 7a38 <malloc+0x1dbe>
    4990:	00001097          	auipc	ra,0x1
    4994:	22c080e7          	jalr	556(ra) # 5bbc <printf>
    exit(1);
    4998:	4505                	li	a0,1
    499a:	00001097          	auipc	ra,0x1
    499e:	e92080e7          	jalr	-366(ra) # 582c <exit>
    printf("%s: write sbrk failed\n", s);
    49a2:	85ce                	mv	a1,s3
    49a4:	00003517          	auipc	a0,0x3
    49a8:	0ac50513          	addi	a0,a0,172 # 7a50 <malloc+0x1dd6>
    49ac:	00001097          	auipc	ra,0x1
    49b0:	210080e7          	jalr	528(ra) # 5bbc <printf>
    exit(1);
    49b4:	4505                	li	a0,1
    49b6:	00001097          	auipc	ra,0x1
    49ba:	e76080e7          	jalr	-394(ra) # 582c <exit>
    printf("%s: pipe() failed\n", s);
    49be:	85ce                	mv	a1,s3
    49c0:	00002517          	auipc	a0,0x2
    49c4:	c7850513          	addi	a0,a0,-904 # 6638 <malloc+0x9be>
    49c8:	00001097          	auipc	ra,0x1
    49cc:	1f4080e7          	jalr	500(ra) # 5bbc <printf>
    exit(1);
    49d0:	4505                	li	a0,1
    49d2:	00001097          	auipc	ra,0x1
    49d6:	e5a080e7          	jalr	-422(ra) # 582c <exit>

00000000000049da <validatetest>:
{
    49da:	7139                	addi	sp,sp,-64
    49dc:	fc06                	sd	ra,56(sp)
    49de:	f822                	sd	s0,48(sp)
    49e0:	f426                	sd	s1,40(sp)
    49e2:	f04a                	sd	s2,32(sp)
    49e4:	ec4e                	sd	s3,24(sp)
    49e6:	e852                	sd	s4,16(sp)
    49e8:	e456                	sd	s5,8(sp)
    49ea:	e05a                	sd	s6,0(sp)
    49ec:	0080                	addi	s0,sp,64
    49ee:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    49f0:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    49f2:	00003997          	auipc	s3,0x3
    49f6:	07698993          	addi	s3,s3,118 # 7a68 <malloc+0x1dee>
    49fa:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    49fc:	6a85                	lui	s5,0x1
    49fe:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    4a02:	85a6                	mv	a1,s1
    4a04:	854e                	mv	a0,s3
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	e86080e7          	jalr	-378(ra) # 588c <link>
    4a0e:	01251f63          	bne	a0,s2,4a2c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    4a12:	94d6                	add	s1,s1,s5
    4a14:	ff4497e3          	bne	s1,s4,4a02 <validatetest+0x28>
}
    4a18:	70e2                	ld	ra,56(sp)
    4a1a:	7442                	ld	s0,48(sp)
    4a1c:	74a2                	ld	s1,40(sp)
    4a1e:	7902                	ld	s2,32(sp)
    4a20:	69e2                	ld	s3,24(sp)
    4a22:	6a42                	ld	s4,16(sp)
    4a24:	6aa2                	ld	s5,8(sp)
    4a26:	6b02                	ld	s6,0(sp)
    4a28:	6121                	addi	sp,sp,64
    4a2a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    4a2c:	85da                	mv	a1,s6
    4a2e:	00003517          	auipc	a0,0x3
    4a32:	04a50513          	addi	a0,a0,74 # 7a78 <malloc+0x1dfe>
    4a36:	00001097          	auipc	ra,0x1
    4a3a:	186080e7          	jalr	390(ra) # 5bbc <printf>
      exit(1);
    4a3e:	4505                	li	a0,1
    4a40:	00001097          	auipc	ra,0x1
    4a44:	dec080e7          	jalr	-532(ra) # 582c <exit>

0000000000004a48 <bsstest>:
  for(i = 0; i < sizeof(uninit); i++){
    4a48:	00004797          	auipc	a5,0x4
    4a4c:	58078793          	addi	a5,a5,1408 # 8fc8 <uninit>
    4a50:	00007697          	auipc	a3,0x7
    4a54:	c8868693          	addi	a3,a3,-888 # b6d8 <buf>
    if(uninit[i] != '\0'){
    4a58:	0007c703          	lbu	a4,0(a5)
    4a5c:	e709                	bnez	a4,4a66 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
    4a5e:	0785                	addi	a5,a5,1
    4a60:	fed79ce3          	bne	a5,a3,4a58 <bsstest+0x10>
    4a64:	8082                	ret
{
    4a66:	1141                	addi	sp,sp,-16
    4a68:	e406                	sd	ra,8(sp)
    4a6a:	e022                	sd	s0,0(sp)
    4a6c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
    4a6e:	85aa                	mv	a1,a0
    4a70:	00003517          	auipc	a0,0x3
    4a74:	02850513          	addi	a0,a0,40 # 7a98 <malloc+0x1e1e>
    4a78:	00001097          	auipc	ra,0x1
    4a7c:	144080e7          	jalr	324(ra) # 5bbc <printf>
      exit(1);
    4a80:	4505                	li	a0,1
    4a82:	00001097          	auipc	ra,0x1
    4a86:	daa080e7          	jalr	-598(ra) # 582c <exit>

0000000000004a8a <bigargtest>:
{
    4a8a:	7179                	addi	sp,sp,-48
    4a8c:	f406                	sd	ra,40(sp)
    4a8e:	f022                	sd	s0,32(sp)
    4a90:	ec26                	sd	s1,24(sp)
    4a92:	1800                	addi	s0,sp,48
    4a94:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4a96:	00003517          	auipc	a0,0x3
    4a9a:	01a50513          	addi	a0,a0,26 # 7ab0 <malloc+0x1e36>
    4a9e:	00001097          	auipc	ra,0x1
    4aa2:	dde080e7          	jalr	-546(ra) # 587c <unlink>
  pid = fork();
    4aa6:	00001097          	auipc	ra,0x1
    4aaa:	d7e080e7          	jalr	-642(ra) # 5824 <fork>
  if(pid == 0){
    4aae:	c121                	beqz	a0,4aee <bigargtest+0x64>
  } else if(pid < 0){
    4ab0:	0a054063          	bltz	a0,4b50 <bigargtest+0xc6>
  wait(&xstatus);
    4ab4:	fdc40513          	addi	a0,s0,-36
    4ab8:	00001097          	auipc	ra,0x1
    4abc:	d7c080e7          	jalr	-644(ra) # 5834 <wait>
  if(xstatus != 0)
    4ac0:	fdc42503          	lw	a0,-36(s0)
    4ac4:	e545                	bnez	a0,4b6c <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    4ac6:	4581                	li	a1,0
    4ac8:	00003517          	auipc	a0,0x3
    4acc:	fe850513          	addi	a0,a0,-24 # 7ab0 <malloc+0x1e36>
    4ad0:	00001097          	auipc	ra,0x1
    4ad4:	d9c080e7          	jalr	-612(ra) # 586c <open>
  if(fd < 0){
    4ad8:	08054e63          	bltz	a0,4b74 <bigargtest+0xea>
  close(fd);
    4adc:	00001097          	auipc	ra,0x1
    4ae0:	d78080e7          	jalr	-648(ra) # 5854 <close>
}
    4ae4:	70a2                	ld	ra,40(sp)
    4ae6:	7402                	ld	s0,32(sp)
    4ae8:	64e2                	ld	s1,24(sp)
    4aea:	6145                	addi	sp,sp,48
    4aec:	8082                	ret
    4aee:	00003797          	auipc	a5,0x3
    4af2:	3d278793          	addi	a5,a5,978 # 7ec0 <args.1864>
    4af6:	00003697          	auipc	a3,0x3
    4afa:	4c268693          	addi	a3,a3,1218 # 7fb8 <args.1864+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    4afe:	00003717          	auipc	a4,0x3
    4b02:	fc270713          	addi	a4,a4,-62 # 7ac0 <malloc+0x1e46>
    4b06:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    4b08:	07a1                	addi	a5,a5,8
    4b0a:	fed79ee3          	bne	a5,a3,4b06 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    4b0e:	00003597          	auipc	a1,0x3
    4b12:	3b258593          	addi	a1,a1,946 # 7ec0 <args.1864>
    4b16:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    4b1a:	00001517          	auipc	a0,0x1
    4b1e:	3de50513          	addi	a0,a0,990 # 5ef8 <malloc+0x27e>
    4b22:	00001097          	auipc	ra,0x1
    4b26:	d42080e7          	jalr	-702(ra) # 5864 <exec>
    fd = open("bigarg-ok", O_CREATE);
    4b2a:	20000593          	li	a1,512
    4b2e:	00003517          	auipc	a0,0x3
    4b32:	f8250513          	addi	a0,a0,-126 # 7ab0 <malloc+0x1e36>
    4b36:	00001097          	auipc	ra,0x1
    4b3a:	d36080e7          	jalr	-714(ra) # 586c <open>
    close(fd);
    4b3e:	00001097          	auipc	ra,0x1
    4b42:	d16080e7          	jalr	-746(ra) # 5854 <close>
    exit(0);
    4b46:	4501                	li	a0,0
    4b48:	00001097          	auipc	ra,0x1
    4b4c:	ce4080e7          	jalr	-796(ra) # 582c <exit>
    printf("%s: bigargtest: fork failed\n", s);
    4b50:	85a6                	mv	a1,s1
    4b52:	00003517          	auipc	a0,0x3
    4b56:	04e50513          	addi	a0,a0,78 # 7ba0 <malloc+0x1f26>
    4b5a:	00001097          	auipc	ra,0x1
    4b5e:	062080e7          	jalr	98(ra) # 5bbc <printf>
    exit(1);
    4b62:	4505                	li	a0,1
    4b64:	00001097          	auipc	ra,0x1
    4b68:	cc8080e7          	jalr	-824(ra) # 582c <exit>
    exit(xstatus);
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	cc0080e7          	jalr	-832(ra) # 582c <exit>
    printf("%s: bigarg test failed!\n", s);
    4b74:	85a6                	mv	a1,s1
    4b76:	00003517          	auipc	a0,0x3
    4b7a:	04a50513          	addi	a0,a0,74 # 7bc0 <malloc+0x1f46>
    4b7e:	00001097          	auipc	ra,0x1
    4b82:	03e080e7          	jalr	62(ra) # 5bbc <printf>
    exit(1);
    4b86:	4505                	li	a0,1
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	ca4080e7          	jalr	-860(ra) # 582c <exit>

0000000000004b90 <fsfull>:
{
    4b90:	7171                	addi	sp,sp,-176
    4b92:	f506                	sd	ra,168(sp)
    4b94:	f122                	sd	s0,160(sp)
    4b96:	ed26                	sd	s1,152(sp)
    4b98:	e94a                	sd	s2,144(sp)
    4b9a:	e54e                	sd	s3,136(sp)
    4b9c:	e152                	sd	s4,128(sp)
    4b9e:	fcd6                	sd	s5,120(sp)
    4ba0:	f8da                	sd	s6,112(sp)
    4ba2:	f4de                	sd	s7,104(sp)
    4ba4:	f0e2                	sd	s8,96(sp)
    4ba6:	ece6                	sd	s9,88(sp)
    4ba8:	e8ea                	sd	s10,80(sp)
    4baa:	e4ee                	sd	s11,72(sp)
    4bac:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4bae:	00003517          	auipc	a0,0x3
    4bb2:	03250513          	addi	a0,a0,50 # 7be0 <malloc+0x1f66>
    4bb6:	00001097          	auipc	ra,0x1
    4bba:	006080e7          	jalr	6(ra) # 5bbc <printf>
  for(nfiles = 0; ; nfiles++){
    4bbe:	4481                	li	s1,0
    name[0] = 'f';
    4bc0:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4bc4:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bc8:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bcc:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4bce:	00003c97          	auipc	s9,0x3
    4bd2:	022c8c93          	addi	s9,s9,34 # 7bf0 <malloc+0x1f76>
    int total = 0;
    4bd6:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4bd8:	00007a17          	auipc	s4,0x7
    4bdc:	b00a0a13          	addi	s4,s4,-1280 # b6d8 <buf>
    name[0] = 'f';
    4be0:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4be4:	0384c7bb          	divw	a5,s1,s8
    4be8:	0307879b          	addiw	a5,a5,48
    4bec:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4bf0:	0384e7bb          	remw	a5,s1,s8
    4bf4:	0377c7bb          	divw	a5,a5,s7
    4bf8:	0307879b          	addiw	a5,a5,48
    4bfc:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c00:	0374e7bb          	remw	a5,s1,s7
    4c04:	0367c7bb          	divw	a5,a5,s6
    4c08:	0307879b          	addiw	a5,a5,48
    4c0c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c10:	0364e7bb          	remw	a5,s1,s6
    4c14:	0307879b          	addiw	a5,a5,48
    4c18:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c1c:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4c20:	f5040593          	addi	a1,s0,-176
    4c24:	8566                	mv	a0,s9
    4c26:	00001097          	auipc	ra,0x1
    4c2a:	f96080e7          	jalr	-106(ra) # 5bbc <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4c2e:	20200593          	li	a1,514
    4c32:	f5040513          	addi	a0,s0,-176
    4c36:	00001097          	auipc	ra,0x1
    4c3a:	c36080e7          	jalr	-970(ra) # 586c <open>
    4c3e:	892a                	mv	s2,a0
    if(fd < 0){
    4c40:	0a055663          	bgez	a0,4cec <fsfull+0x15c>
      printf("open %s failed\n", name);
    4c44:	f5040593          	addi	a1,s0,-176
    4c48:	00003517          	auipc	a0,0x3
    4c4c:	fb850513          	addi	a0,a0,-72 # 7c00 <malloc+0x1f86>
    4c50:	00001097          	auipc	ra,0x1
    4c54:	f6c080e7          	jalr	-148(ra) # 5bbc <printf>
  while(nfiles >= 0){
    4c58:	0604c363          	bltz	s1,4cbe <fsfull+0x12e>
    name[0] = 'f';
    4c5c:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4c60:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c64:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c68:	4929                	li	s2,10
  while(nfiles >= 0){
    4c6a:	5afd                	li	s5,-1
    name[0] = 'f';
    4c6c:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c70:	0344c7bb          	divw	a5,s1,s4
    4c74:	0307879b          	addiw	a5,a5,48
    4c78:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c7c:	0344e7bb          	remw	a5,s1,s4
    4c80:	0337c7bb          	divw	a5,a5,s3
    4c84:	0307879b          	addiw	a5,a5,48
    4c88:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c8c:	0334e7bb          	remw	a5,s1,s3
    4c90:	0327c7bb          	divw	a5,a5,s2
    4c94:	0307879b          	addiw	a5,a5,48
    4c98:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c9c:	0324e7bb          	remw	a5,s1,s2
    4ca0:	0307879b          	addiw	a5,a5,48
    4ca4:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4ca8:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4cac:	f5040513          	addi	a0,s0,-176
    4cb0:	00001097          	auipc	ra,0x1
    4cb4:	bcc080e7          	jalr	-1076(ra) # 587c <unlink>
    nfiles--;
    4cb8:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4cba:	fb5499e3          	bne	s1,s5,4c6c <fsfull+0xdc>
  printf("fsfull test finished\n");
    4cbe:	00003517          	auipc	a0,0x3
    4cc2:	f6250513          	addi	a0,a0,-158 # 7c20 <malloc+0x1fa6>
    4cc6:	00001097          	auipc	ra,0x1
    4cca:	ef6080e7          	jalr	-266(ra) # 5bbc <printf>
}
    4cce:	70aa                	ld	ra,168(sp)
    4cd0:	740a                	ld	s0,160(sp)
    4cd2:	64ea                	ld	s1,152(sp)
    4cd4:	694a                	ld	s2,144(sp)
    4cd6:	69aa                	ld	s3,136(sp)
    4cd8:	6a0a                	ld	s4,128(sp)
    4cda:	7ae6                	ld	s5,120(sp)
    4cdc:	7b46                	ld	s6,112(sp)
    4cde:	7ba6                	ld	s7,104(sp)
    4ce0:	7c06                	ld	s8,96(sp)
    4ce2:	6ce6                	ld	s9,88(sp)
    4ce4:	6d46                	ld	s10,80(sp)
    4ce6:	6da6                	ld	s11,72(sp)
    4ce8:	614d                	addi	sp,sp,176
    4cea:	8082                	ret
    int total = 0;
    4cec:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4cee:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4cf2:	40000613          	li	a2,1024
    4cf6:	85d2                	mv	a1,s4
    4cf8:	854a                	mv	a0,s2
    4cfa:	00001097          	auipc	ra,0x1
    4cfe:	b52080e7          	jalr	-1198(ra) # 584c <write>
      if(cc < BSIZE)
    4d02:	00aad563          	bge	s5,a0,4d0c <fsfull+0x17c>
      total += cc;
    4d06:	00a989bb          	addw	s3,s3,a0
    while(1){
    4d0a:	b7e5                	j	4cf2 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4d0c:	85ce                	mv	a1,s3
    4d0e:	00003517          	auipc	a0,0x3
    4d12:	f0250513          	addi	a0,a0,-254 # 7c10 <malloc+0x1f96>
    4d16:	00001097          	auipc	ra,0x1
    4d1a:	ea6080e7          	jalr	-346(ra) # 5bbc <printf>
    close(fd);
    4d1e:	854a                	mv	a0,s2
    4d20:	00001097          	auipc	ra,0x1
    4d24:	b34080e7          	jalr	-1228(ra) # 5854 <close>
    if(total == 0)
    4d28:	f20988e3          	beqz	s3,4c58 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4d2c:	2485                	addiw	s1,s1,1
    4d2e:	bd4d                	j	4be0 <fsfull+0x50>

0000000000004d30 <argptest>:
{
    4d30:	1101                	addi	sp,sp,-32
    4d32:	ec06                	sd	ra,24(sp)
    4d34:	e822                	sd	s0,16(sp)
    4d36:	e426                	sd	s1,8(sp)
    4d38:	e04a                	sd	s2,0(sp)
    4d3a:	1000                	addi	s0,sp,32
    4d3c:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    4d3e:	4581                	li	a1,0
    4d40:	00003517          	auipc	a0,0x3
    4d44:	ef850513          	addi	a0,a0,-264 # 7c38 <malloc+0x1fbe>
    4d48:	00001097          	auipc	ra,0x1
    4d4c:	b24080e7          	jalr	-1244(ra) # 586c <open>
  if (fd < 0) {
    4d50:	02054b63          	bltz	a0,4d86 <argptest+0x56>
    4d54:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    4d56:	4501                	li	a0,0
    4d58:	00001097          	auipc	ra,0x1
    4d5c:	b5c080e7          	jalr	-1188(ra) # 58b4 <sbrk>
    4d60:	567d                	li	a2,-1
    4d62:	fff50593          	addi	a1,a0,-1
    4d66:	8526                	mv	a0,s1
    4d68:	00001097          	auipc	ra,0x1
    4d6c:	adc080e7          	jalr	-1316(ra) # 5844 <read>
  close(fd);
    4d70:	8526                	mv	a0,s1
    4d72:	00001097          	auipc	ra,0x1
    4d76:	ae2080e7          	jalr	-1310(ra) # 5854 <close>
}
    4d7a:	60e2                	ld	ra,24(sp)
    4d7c:	6442                	ld	s0,16(sp)
    4d7e:	64a2                	ld	s1,8(sp)
    4d80:	6902                	ld	s2,0(sp)
    4d82:	6105                	addi	sp,sp,32
    4d84:	8082                	ret
    printf("%s: open failed\n", s);
    4d86:	85ca                	mv	a1,s2
    4d88:	00001517          	auipc	a0,0x1
    4d8c:	43050513          	addi	a0,a0,1072 # 61b8 <malloc+0x53e>
    4d90:	00001097          	auipc	ra,0x1
    4d94:	e2c080e7          	jalr	-468(ra) # 5bbc <printf>
    exit(1);
    4d98:	4505                	li	a0,1
    4d9a:	00001097          	auipc	ra,0x1
    4d9e:	a92080e7          	jalr	-1390(ra) # 582c <exit>

0000000000004da2 <stacktest>:
{
    4da2:	7179                	addi	sp,sp,-48
    4da4:	f406                	sd	ra,40(sp)
    4da6:	f022                	sd	s0,32(sp)
    4da8:	ec26                	sd	s1,24(sp)
    4daa:	1800                	addi	s0,sp,48
    4dac:	84aa                	mv	s1,a0
  pid = fork();
    4dae:	00001097          	auipc	ra,0x1
    4db2:	a76080e7          	jalr	-1418(ra) # 5824 <fork>
  if(pid == 0) {
    4db6:	c115                	beqz	a0,4dda <stacktest+0x38>
  } else if(pid < 0){
    4db8:	04054463          	bltz	a0,4e00 <stacktest+0x5e>
  wait(&xstatus);
    4dbc:	fdc40513          	addi	a0,s0,-36
    4dc0:	00001097          	auipc	ra,0x1
    4dc4:	a74080e7          	jalr	-1420(ra) # 5834 <wait>
  if(xstatus == -1)  // kernel killed child?
    4dc8:	fdc42503          	lw	a0,-36(s0)
    4dcc:	57fd                	li	a5,-1
    4dce:	04f50763          	beq	a0,a5,4e1c <stacktest+0x7a>
    exit(xstatus);
    4dd2:	00001097          	auipc	ra,0x1
    4dd6:	a5a080e7          	jalr	-1446(ra) # 582c <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    4dda:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    4ddc:	77fd                	lui	a5,0xfffff
    4dde:	97ba                	add	a5,a5,a4
    4de0:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0918>
    4de4:	85a6                	mv	a1,s1
    4de6:	00003517          	auipc	a0,0x3
    4dea:	e5a50513          	addi	a0,a0,-422 # 7c40 <malloc+0x1fc6>
    4dee:	00001097          	auipc	ra,0x1
    4df2:	dce080e7          	jalr	-562(ra) # 5bbc <printf>
    exit(1);
    4df6:	4505                	li	a0,1
    4df8:	00001097          	auipc	ra,0x1
    4dfc:	a34080e7          	jalr	-1484(ra) # 582c <exit>
    printf("%s: fork failed\n", s);
    4e00:	85a6                	mv	a1,s1
    4e02:	00001517          	auipc	a0,0x1
    4e06:	39e50513          	addi	a0,a0,926 # 61a0 <malloc+0x526>
    4e0a:	00001097          	auipc	ra,0x1
    4e0e:	db2080e7          	jalr	-590(ra) # 5bbc <printf>
    exit(1);
    4e12:	4505                	li	a0,1
    4e14:	00001097          	auipc	ra,0x1
    4e18:	a18080e7          	jalr	-1512(ra) # 582c <exit>
    exit(0);
    4e1c:	4501                	li	a0,0
    4e1e:	00001097          	auipc	ra,0x1
    4e22:	a0e080e7          	jalr	-1522(ra) # 582c <exit>

0000000000004e26 <pgbug>:
{
    4e26:	7179                	addi	sp,sp,-48
    4e28:	f406                	sd	ra,40(sp)
    4e2a:	f022                	sd	s0,32(sp)
    4e2c:	ec26                	sd	s1,24(sp)
    4e2e:	1800                	addi	s0,sp,48
  argv[0] = 0;
    4e30:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    4e34:	00003497          	auipc	s1,0x3
    4e38:	07c4b483          	ld	s1,124(s1) # 7eb0 <__SDATA_BEGIN__>
    4e3c:	fd840593          	addi	a1,s0,-40
    4e40:	8526                	mv	a0,s1
    4e42:	00001097          	auipc	ra,0x1
    4e46:	a22080e7          	jalr	-1502(ra) # 5864 <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
    4e4a:	8526                	mv	a0,s1
    4e4c:	00001097          	auipc	ra,0x1
    4e50:	9f0080e7          	jalr	-1552(ra) # 583c <pipe>
  exit(0);
    4e54:	4501                	li	a0,0
    4e56:	00001097          	auipc	ra,0x1
    4e5a:	9d6080e7          	jalr	-1578(ra) # 582c <exit>

0000000000004e5e <sbrkbugs>:
{
    4e5e:	1141                	addi	sp,sp,-16
    4e60:	e406                	sd	ra,8(sp)
    4e62:	e022                	sd	s0,0(sp)
    4e64:	0800                	addi	s0,sp,16
  int pid = fork();
    4e66:	00001097          	auipc	ra,0x1
    4e6a:	9be080e7          	jalr	-1602(ra) # 5824 <fork>
  if(pid < 0){
    4e6e:	02054263          	bltz	a0,4e92 <sbrkbugs+0x34>
  if(pid == 0){
    4e72:	ed0d                	bnez	a0,4eac <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    4e74:	00001097          	auipc	ra,0x1
    4e78:	a40080e7          	jalr	-1472(ra) # 58b4 <sbrk>
    sbrk(-sz);
    4e7c:	40a0053b          	negw	a0,a0
    4e80:	00001097          	auipc	ra,0x1
    4e84:	a34080e7          	jalr	-1484(ra) # 58b4 <sbrk>
    exit(0);
    4e88:	4501                	li	a0,0
    4e8a:	00001097          	auipc	ra,0x1
    4e8e:	9a2080e7          	jalr	-1630(ra) # 582c <exit>
    printf("fork failed\n");
    4e92:	00003517          	auipc	a0,0x3
    4e96:	d1e50513          	addi	a0,a0,-738 # 7bb0 <malloc+0x1f36>
    4e9a:	00001097          	auipc	ra,0x1
    4e9e:	d22080e7          	jalr	-734(ra) # 5bbc <printf>
    exit(1);
    4ea2:	4505                	li	a0,1
    4ea4:	00001097          	auipc	ra,0x1
    4ea8:	988080e7          	jalr	-1656(ra) # 582c <exit>
  wait(0);
    4eac:	4501                	li	a0,0
    4eae:	00001097          	auipc	ra,0x1
    4eb2:	986080e7          	jalr	-1658(ra) # 5834 <wait>
  pid = fork();
    4eb6:	00001097          	auipc	ra,0x1
    4eba:	96e080e7          	jalr	-1682(ra) # 5824 <fork>
  if(pid < 0){
    4ebe:	02054563          	bltz	a0,4ee8 <sbrkbugs+0x8a>
  if(pid == 0){
    4ec2:	e121                	bnez	a0,4f02 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    4ec4:	00001097          	auipc	ra,0x1
    4ec8:	9f0080e7          	jalr	-1552(ra) # 58b4 <sbrk>
    sbrk(-(sz - 3500));
    4ecc:	6785                	lui	a5,0x1
    4ece:	dac7879b          	addiw	a5,a5,-596
    4ed2:	40a7853b          	subw	a0,a5,a0
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	9de080e7          	jalr	-1570(ra) # 58b4 <sbrk>
    exit(0);
    4ede:	4501                	li	a0,0
    4ee0:	00001097          	auipc	ra,0x1
    4ee4:	94c080e7          	jalr	-1716(ra) # 582c <exit>
    printf("fork failed\n");
    4ee8:	00003517          	auipc	a0,0x3
    4eec:	cc850513          	addi	a0,a0,-824 # 7bb0 <malloc+0x1f36>
    4ef0:	00001097          	auipc	ra,0x1
    4ef4:	ccc080e7          	jalr	-820(ra) # 5bbc <printf>
    exit(1);
    4ef8:	4505                	li	a0,1
    4efa:	00001097          	auipc	ra,0x1
    4efe:	932080e7          	jalr	-1742(ra) # 582c <exit>
  wait(0);
    4f02:	4501                	li	a0,0
    4f04:	00001097          	auipc	ra,0x1
    4f08:	930080e7          	jalr	-1744(ra) # 5834 <wait>
  pid = fork();
    4f0c:	00001097          	auipc	ra,0x1
    4f10:	918080e7          	jalr	-1768(ra) # 5824 <fork>
  if(pid < 0){
    4f14:	02054a63          	bltz	a0,4f48 <sbrkbugs+0xea>
  if(pid == 0){
    4f18:	e529                	bnez	a0,4f62 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    4f1a:	00001097          	auipc	ra,0x1
    4f1e:	99a080e7          	jalr	-1638(ra) # 58b4 <sbrk>
    4f22:	67ad                	lui	a5,0xb
    4f24:	8007879b          	addiw	a5,a5,-2048
    4f28:	40a7853b          	subw	a0,a5,a0
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	988080e7          	jalr	-1656(ra) # 58b4 <sbrk>
    sbrk(-10);
    4f34:	5559                	li	a0,-10
    4f36:	00001097          	auipc	ra,0x1
    4f3a:	97e080e7          	jalr	-1666(ra) # 58b4 <sbrk>
    exit(0);
    4f3e:	4501                	li	a0,0
    4f40:	00001097          	auipc	ra,0x1
    4f44:	8ec080e7          	jalr	-1812(ra) # 582c <exit>
    printf("fork failed\n");
    4f48:	00003517          	auipc	a0,0x3
    4f4c:	c6850513          	addi	a0,a0,-920 # 7bb0 <malloc+0x1f36>
    4f50:	00001097          	auipc	ra,0x1
    4f54:	c6c080e7          	jalr	-916(ra) # 5bbc <printf>
    exit(1);
    4f58:	4505                	li	a0,1
    4f5a:	00001097          	auipc	ra,0x1
    4f5e:	8d2080e7          	jalr	-1838(ra) # 582c <exit>
  wait(0);
    4f62:	4501                	li	a0,0
    4f64:	00001097          	auipc	ra,0x1
    4f68:	8d0080e7          	jalr	-1840(ra) # 5834 <wait>
  exit(0);
    4f6c:	4501                	li	a0,0
    4f6e:	00001097          	auipc	ra,0x1
    4f72:	8be080e7          	jalr	-1858(ra) # 582c <exit>

0000000000004f76 <sbrklast>:
{
    4f76:	7179                	addi	sp,sp,-48
    4f78:	f406                	sd	ra,40(sp)
    4f7a:	f022                	sd	s0,32(sp)
    4f7c:	ec26                	sd	s1,24(sp)
    4f7e:	e84a                	sd	s2,16(sp)
    4f80:	e44e                	sd	s3,8(sp)
    4f82:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    4f84:	4501                	li	a0,0
    4f86:	00001097          	auipc	ra,0x1
    4f8a:	92e080e7          	jalr	-1746(ra) # 58b4 <sbrk>
  if((top % 4096) != 0)
    4f8e:	03451793          	slli	a5,a0,0x34
    4f92:	efc1                	bnez	a5,502a <sbrklast+0xb4>
  sbrk(4096);
    4f94:	6505                	lui	a0,0x1
    4f96:	00001097          	auipc	ra,0x1
    4f9a:	91e080e7          	jalr	-1762(ra) # 58b4 <sbrk>
  sbrk(10);
    4f9e:	4529                	li	a0,10
    4fa0:	00001097          	auipc	ra,0x1
    4fa4:	914080e7          	jalr	-1772(ra) # 58b4 <sbrk>
  sbrk(-20);
    4fa8:	5531                	li	a0,-20
    4faa:	00001097          	auipc	ra,0x1
    4fae:	90a080e7          	jalr	-1782(ra) # 58b4 <sbrk>
  top = (uint64) sbrk(0);
    4fb2:	4501                	li	a0,0
    4fb4:	00001097          	auipc	ra,0x1
    4fb8:	900080e7          	jalr	-1792(ra) # 58b4 <sbrk>
    4fbc:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    4fbe:	fc050913          	addi	s2,a0,-64 # fc0 <opentest+0xc>
  p[0] = 'x';
    4fc2:	07800793          	li	a5,120
    4fc6:	fcf50023          	sb	a5,-64(a0)
  p[1] = '\0';
    4fca:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    4fce:	20200593          	li	a1,514
    4fd2:	854a                	mv	a0,s2
    4fd4:	00001097          	auipc	ra,0x1
    4fd8:	898080e7          	jalr	-1896(ra) # 586c <open>
    4fdc:	89aa                	mv	s3,a0
  write(fd, p, 1);
    4fde:	4605                	li	a2,1
    4fe0:	85ca                	mv	a1,s2
    4fe2:	00001097          	auipc	ra,0x1
    4fe6:	86a080e7          	jalr	-1942(ra) # 584c <write>
  close(fd);
    4fea:	854e                	mv	a0,s3
    4fec:	00001097          	auipc	ra,0x1
    4ff0:	868080e7          	jalr	-1944(ra) # 5854 <close>
  fd = open(p, O_RDWR);
    4ff4:	4589                	li	a1,2
    4ff6:	854a                	mv	a0,s2
    4ff8:	00001097          	auipc	ra,0x1
    4ffc:	874080e7          	jalr	-1932(ra) # 586c <open>
  p[0] = '\0';
    5000:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    5004:	4605                	li	a2,1
    5006:	85ca                	mv	a1,s2
    5008:	00001097          	auipc	ra,0x1
    500c:	83c080e7          	jalr	-1988(ra) # 5844 <read>
  if(p[0] != 'x')
    5010:	fc04c703          	lbu	a4,-64(s1)
    5014:	07800793          	li	a5,120
    5018:	02f71363          	bne	a4,a5,503e <sbrklast+0xc8>
}
    501c:	70a2                	ld	ra,40(sp)
    501e:	7402                	ld	s0,32(sp)
    5020:	64e2                	ld	s1,24(sp)
    5022:	6942                	ld	s2,16(sp)
    5024:	69a2                	ld	s3,8(sp)
    5026:	6145                	addi	sp,sp,48
    5028:	8082                	ret
    sbrk(4096 - (top % 4096));
    502a:	0347d513          	srli	a0,a5,0x34
    502e:	6785                	lui	a5,0x1
    5030:	40a7853b          	subw	a0,a5,a0
    5034:	00001097          	auipc	ra,0x1
    5038:	880080e7          	jalr	-1920(ra) # 58b4 <sbrk>
    503c:	bfa1                	j	4f94 <sbrklast+0x1e>
    exit(1);
    503e:	4505                	li	a0,1
    5040:	00000097          	auipc	ra,0x0
    5044:	7ec080e7          	jalr	2028(ra) # 582c <exit>

0000000000005048 <sbrk8000>:
{
    5048:	1141                	addi	sp,sp,-16
    504a:	e406                	sd	ra,8(sp)
    504c:	e022                	sd	s0,0(sp)
    504e:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    5050:	80000537          	lui	a0,0x80000
    5054:	0511                	addi	a0,a0,4
    5056:	00001097          	auipc	ra,0x1
    505a:	85e080e7          	jalr	-1954(ra) # 58b4 <sbrk>
  volatile char *top = sbrk(0);
    505e:	4501                	li	a0,0
    5060:	00001097          	auipc	ra,0x1
    5064:	854080e7          	jalr	-1964(ra) # 58b4 <sbrk>
  *(top-1) = *(top-1) + 1;
    5068:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <__BSS_END__+0xffffffff7fff1917>
    506c:	0785                	addi	a5,a5,1
    506e:	0ff7f793          	andi	a5,a5,255
    5072:	fef50fa3          	sb	a5,-1(a0)
}
    5076:	60a2                	ld	ra,8(sp)
    5078:	6402                	ld	s0,0(sp)
    507a:	0141                	addi	sp,sp,16
    507c:	8082                	ret

000000000000507e <badwrite>:
{
    507e:	7179                	addi	sp,sp,-48
    5080:	f406                	sd	ra,40(sp)
    5082:	f022                	sd	s0,32(sp)
    5084:	ec26                	sd	s1,24(sp)
    5086:	e84a                	sd	s2,16(sp)
    5088:	e44e                	sd	s3,8(sp)
    508a:	e052                	sd	s4,0(sp)
    508c:	1800                	addi	s0,sp,48
  unlink("junk");
    508e:	00003517          	auipc	a0,0x3
    5092:	bda50513          	addi	a0,a0,-1062 # 7c68 <malloc+0x1fee>
    5096:	00000097          	auipc	ra,0x0
    509a:	7e6080e7          	jalr	2022(ra) # 587c <unlink>
    509e:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    50a2:	00003997          	auipc	s3,0x3
    50a6:	bc698993          	addi	s3,s3,-1082 # 7c68 <malloc+0x1fee>
    write(fd, (char*)0xffffffffffL, 1);
    50aa:	5a7d                	li	s4,-1
    50ac:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    50b0:	20100593          	li	a1,513
    50b4:	854e                	mv	a0,s3
    50b6:	00000097          	auipc	ra,0x0
    50ba:	7b6080e7          	jalr	1974(ra) # 586c <open>
    50be:	84aa                	mv	s1,a0
    if(fd < 0){
    50c0:	06054b63          	bltz	a0,5136 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    50c4:	4605                	li	a2,1
    50c6:	85d2                	mv	a1,s4
    50c8:	00000097          	auipc	ra,0x0
    50cc:	784080e7          	jalr	1924(ra) # 584c <write>
    close(fd);
    50d0:	8526                	mv	a0,s1
    50d2:	00000097          	auipc	ra,0x0
    50d6:	782080e7          	jalr	1922(ra) # 5854 <close>
    unlink("junk");
    50da:	854e                	mv	a0,s3
    50dc:	00000097          	auipc	ra,0x0
    50e0:	7a0080e7          	jalr	1952(ra) # 587c <unlink>
  for(int i = 0; i < assumed_free; i++){
    50e4:	397d                	addiw	s2,s2,-1
    50e6:	fc0915e3          	bnez	s2,50b0 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    50ea:	20100593          	li	a1,513
    50ee:	00003517          	auipc	a0,0x3
    50f2:	b7a50513          	addi	a0,a0,-1158 # 7c68 <malloc+0x1fee>
    50f6:	00000097          	auipc	ra,0x0
    50fa:	776080e7          	jalr	1910(ra) # 586c <open>
    50fe:	84aa                	mv	s1,a0
  if(fd < 0){
    5100:	04054863          	bltz	a0,5150 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    5104:	4605                	li	a2,1
    5106:	00001597          	auipc	a1,0x1
    510a:	da258593          	addi	a1,a1,-606 # 5ea8 <malloc+0x22e>
    510e:	00000097          	auipc	ra,0x0
    5112:	73e080e7          	jalr	1854(ra) # 584c <write>
    5116:	4785                	li	a5,1
    5118:	04f50963          	beq	a0,a5,516a <badwrite+0xec>
    printf("write failed\n");
    511c:	00003517          	auipc	a0,0x3
    5120:	b6c50513          	addi	a0,a0,-1172 # 7c88 <malloc+0x200e>
    5124:	00001097          	auipc	ra,0x1
    5128:	a98080e7          	jalr	-1384(ra) # 5bbc <printf>
    exit(1);
    512c:	4505                	li	a0,1
    512e:	00000097          	auipc	ra,0x0
    5132:	6fe080e7          	jalr	1790(ra) # 582c <exit>
      printf("open junk failed\n");
    5136:	00003517          	auipc	a0,0x3
    513a:	b3a50513          	addi	a0,a0,-1222 # 7c70 <malloc+0x1ff6>
    513e:	00001097          	auipc	ra,0x1
    5142:	a7e080e7          	jalr	-1410(ra) # 5bbc <printf>
      exit(1);
    5146:	4505                	li	a0,1
    5148:	00000097          	auipc	ra,0x0
    514c:	6e4080e7          	jalr	1764(ra) # 582c <exit>
    printf("open junk failed\n");
    5150:	00003517          	auipc	a0,0x3
    5154:	b2050513          	addi	a0,a0,-1248 # 7c70 <malloc+0x1ff6>
    5158:	00001097          	auipc	ra,0x1
    515c:	a64080e7          	jalr	-1436(ra) # 5bbc <printf>
    exit(1);
    5160:	4505                	li	a0,1
    5162:	00000097          	auipc	ra,0x0
    5166:	6ca080e7          	jalr	1738(ra) # 582c <exit>
  close(fd);
    516a:	8526                	mv	a0,s1
    516c:	00000097          	auipc	ra,0x0
    5170:	6e8080e7          	jalr	1768(ra) # 5854 <close>
  unlink("junk");
    5174:	00003517          	auipc	a0,0x3
    5178:	af450513          	addi	a0,a0,-1292 # 7c68 <malloc+0x1fee>
    517c:	00000097          	auipc	ra,0x0
    5180:	700080e7          	jalr	1792(ra) # 587c <unlink>
  exit(0);
    5184:	4501                	li	a0,0
    5186:	00000097          	auipc	ra,0x0
    518a:	6a6080e7          	jalr	1702(ra) # 582c <exit>

000000000000518e <badarg>:
{
    518e:	7139                	addi	sp,sp,-64
    5190:	fc06                	sd	ra,56(sp)
    5192:	f822                	sd	s0,48(sp)
    5194:	f426                	sd	s1,40(sp)
    5196:	f04a                	sd	s2,32(sp)
    5198:	ec4e                	sd	s3,24(sp)
    519a:	0080                	addi	s0,sp,64
    519c:	64b1                	lui	s1,0xc
    519e:	35048493          	addi	s1,s1,848 # c350 <buf+0xc78>
    argv[0] = (char*)0xffffffff;
    51a2:	597d                	li	s2,-1
    51a4:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    51a8:	00001997          	auipc	s3,0x1
    51ac:	d5098993          	addi	s3,s3,-688 # 5ef8 <malloc+0x27e>
    argv[0] = (char*)0xffffffff;
    51b0:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    51b4:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    51b8:	fc040593          	addi	a1,s0,-64
    51bc:	854e                	mv	a0,s3
    51be:	00000097          	auipc	ra,0x0
    51c2:	6a6080e7          	jalr	1702(ra) # 5864 <exec>
  for(int i = 0; i < 50000; i++){
    51c6:	34fd                	addiw	s1,s1,-1
    51c8:	f4e5                	bnez	s1,51b0 <badarg+0x22>
  exit(0);
    51ca:	4501                	li	a0,0
    51cc:	00000097          	auipc	ra,0x0
    51d0:	660080e7          	jalr	1632(ra) # 582c <exit>

00000000000051d4 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    51d4:	7139                	addi	sp,sp,-64
    51d6:	fc06                	sd	ra,56(sp)
    51d8:	f822                	sd	s0,48(sp)
    51da:	f426                	sd	s1,40(sp)
    51dc:	f04a                	sd	s2,32(sp)
    51de:	ec4e                	sd	s3,24(sp)
    51e0:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    51e2:	fc840513          	addi	a0,s0,-56
    51e6:	00000097          	auipc	ra,0x0
    51ea:	656080e7          	jalr	1622(ra) # 583c <pipe>
    51ee:	06054863          	bltz	a0,525e <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    51f2:	00000097          	auipc	ra,0x0
    51f6:	632080e7          	jalr	1586(ra) # 5824 <fork>

  if(pid < 0){
    51fa:	06054f63          	bltz	a0,5278 <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    51fe:	ed59                	bnez	a0,529c <countfree+0xc8>
    close(fds[0]);
    5200:	fc842503          	lw	a0,-56(s0)
    5204:	00000097          	auipc	ra,0x0
    5208:	650080e7          	jalr	1616(ra) # 5854 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    520c:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    520e:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5210:	00001917          	auipc	s2,0x1
    5214:	c9890913          	addi	s2,s2,-872 # 5ea8 <malloc+0x22e>
      uint64 a = (uint64) sbrk(4096);
    5218:	6505                	lui	a0,0x1
    521a:	00000097          	auipc	ra,0x0
    521e:	69a080e7          	jalr	1690(ra) # 58b4 <sbrk>
      if(a == 0xffffffffffffffff){
    5222:	06950863          	beq	a0,s1,5292 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    5226:	6785                	lui	a5,0x1
    5228:	953e                	add	a0,a0,a5
    522a:	ff350fa3          	sb	s3,-1(a0) # fff <opentest+0x4b>
      if(write(fds[1], "x", 1) != 1){
    522e:	4605                	li	a2,1
    5230:	85ca                	mv	a1,s2
    5232:	fcc42503          	lw	a0,-52(s0)
    5236:	00000097          	auipc	ra,0x0
    523a:	616080e7          	jalr	1558(ra) # 584c <write>
    523e:	4785                	li	a5,1
    5240:	fcf50ce3          	beq	a0,a5,5218 <countfree+0x44>
        printf("write() failed in countfree()\n");
    5244:	00003517          	auipc	a0,0x3
    5248:	a9450513          	addi	a0,a0,-1388 # 7cd8 <malloc+0x205e>
    524c:	00001097          	auipc	ra,0x1
    5250:	970080e7          	jalr	-1680(ra) # 5bbc <printf>
        exit(1);
    5254:	4505                	li	a0,1
    5256:	00000097          	auipc	ra,0x0
    525a:	5d6080e7          	jalr	1494(ra) # 582c <exit>
    printf("pipe() failed in countfree()\n");
    525e:	00003517          	auipc	a0,0x3
    5262:	a3a50513          	addi	a0,a0,-1478 # 7c98 <malloc+0x201e>
    5266:	00001097          	auipc	ra,0x1
    526a:	956080e7          	jalr	-1706(ra) # 5bbc <printf>
    exit(1);
    526e:	4505                	li	a0,1
    5270:	00000097          	auipc	ra,0x0
    5274:	5bc080e7          	jalr	1468(ra) # 582c <exit>
    printf("fork failed in countfree()\n");
    5278:	00003517          	auipc	a0,0x3
    527c:	a4050513          	addi	a0,a0,-1472 # 7cb8 <malloc+0x203e>
    5280:	00001097          	auipc	ra,0x1
    5284:	93c080e7          	jalr	-1732(ra) # 5bbc <printf>
    exit(1);
    5288:	4505                	li	a0,1
    528a:	00000097          	auipc	ra,0x0
    528e:	5a2080e7          	jalr	1442(ra) # 582c <exit>
      }
    }

    exit(0);
    5292:	4501                	li	a0,0
    5294:	00000097          	auipc	ra,0x0
    5298:	598080e7          	jalr	1432(ra) # 582c <exit>
  }

  close(fds[1]);
    529c:	fcc42503          	lw	a0,-52(s0)
    52a0:	00000097          	auipc	ra,0x0
    52a4:	5b4080e7          	jalr	1460(ra) # 5854 <close>

  int n = 0;
    52a8:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    52aa:	4605                	li	a2,1
    52ac:	fc740593          	addi	a1,s0,-57
    52b0:	fc842503          	lw	a0,-56(s0)
    52b4:	00000097          	auipc	ra,0x0
    52b8:	590080e7          	jalr	1424(ra) # 5844 <read>
    if(cc < 0){
    52bc:	00054563          	bltz	a0,52c6 <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    52c0:	c105                	beqz	a0,52e0 <countfree+0x10c>
      break;
    n += 1;
    52c2:	2485                	addiw	s1,s1,1
  while(1){
    52c4:	b7dd                	j	52aa <countfree+0xd6>
      printf("read() failed in countfree()\n");
    52c6:	00003517          	auipc	a0,0x3
    52ca:	a3250513          	addi	a0,a0,-1486 # 7cf8 <malloc+0x207e>
    52ce:	00001097          	auipc	ra,0x1
    52d2:	8ee080e7          	jalr	-1810(ra) # 5bbc <printf>
      exit(1);
    52d6:	4505                	li	a0,1
    52d8:	00000097          	auipc	ra,0x0
    52dc:	554080e7          	jalr	1364(ra) # 582c <exit>
  }

  close(fds[0]);
    52e0:	fc842503          	lw	a0,-56(s0)
    52e4:	00000097          	auipc	ra,0x0
    52e8:	570080e7          	jalr	1392(ra) # 5854 <close>
  wait((int*)0);
    52ec:	4501                	li	a0,0
    52ee:	00000097          	auipc	ra,0x0
    52f2:	546080e7          	jalr	1350(ra) # 5834 <wait>
  
  return n;
}
    52f6:	8526                	mv	a0,s1
    52f8:	70e2                	ld	ra,56(sp)
    52fa:	7442                	ld	s0,48(sp)
    52fc:	74a2                	ld	s1,40(sp)
    52fe:	7902                	ld	s2,32(sp)
    5300:	69e2                	ld	s3,24(sp)
    5302:	6121                	addi	sp,sp,64
    5304:	8082                	ret

0000000000005306 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5306:	7179                	addi	sp,sp,-48
    5308:	f406                	sd	ra,40(sp)
    530a:	f022                	sd	s0,32(sp)
    530c:	ec26                	sd	s1,24(sp)
    530e:	e84a                	sd	s2,16(sp)
    5310:	1800                	addi	s0,sp,48
    5312:	84aa                	mv	s1,a0
    5314:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5316:	00003517          	auipc	a0,0x3
    531a:	a0250513          	addi	a0,a0,-1534 # 7d18 <malloc+0x209e>
    531e:	00001097          	auipc	ra,0x1
    5322:	89e080e7          	jalr	-1890(ra) # 5bbc <printf>
  if((pid = fork()) < 0) {
    5326:	00000097          	auipc	ra,0x0
    532a:	4fe080e7          	jalr	1278(ra) # 5824 <fork>
    532e:	02054e63          	bltz	a0,536a <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    5332:	c929                	beqz	a0,5384 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    5334:	fdc40513          	addi	a0,s0,-36
    5338:	00000097          	auipc	ra,0x0
    533c:	4fc080e7          	jalr	1276(ra) # 5834 <wait>
    if(xstatus != 0) 
    5340:	fdc42783          	lw	a5,-36(s0)
    5344:	c7b9                	beqz	a5,5392 <run+0x8c>
      printf("FAILED\n");
    5346:	00003517          	auipc	a0,0x3
    534a:	9fa50513          	addi	a0,a0,-1542 # 7d40 <malloc+0x20c6>
    534e:	00001097          	auipc	ra,0x1
    5352:	86e080e7          	jalr	-1938(ra) # 5bbc <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5356:	fdc42503          	lw	a0,-36(s0)
  }
}
    535a:	00153513          	seqz	a0,a0
    535e:	70a2                	ld	ra,40(sp)
    5360:	7402                	ld	s0,32(sp)
    5362:	64e2                	ld	s1,24(sp)
    5364:	6942                	ld	s2,16(sp)
    5366:	6145                	addi	sp,sp,48
    5368:	8082                	ret
    printf("runtest: fork error\n");
    536a:	00003517          	auipc	a0,0x3
    536e:	9be50513          	addi	a0,a0,-1602 # 7d28 <malloc+0x20ae>
    5372:	00001097          	auipc	ra,0x1
    5376:	84a080e7          	jalr	-1974(ra) # 5bbc <printf>
    exit(1);
    537a:	4505                	li	a0,1
    537c:	00000097          	auipc	ra,0x0
    5380:	4b0080e7          	jalr	1200(ra) # 582c <exit>
    f(s);
    5384:	854a                	mv	a0,s2
    5386:	9482                	jalr	s1
    exit(0);
    5388:	4501                	li	a0,0
    538a:	00000097          	auipc	ra,0x0
    538e:	4a2080e7          	jalr	1186(ra) # 582c <exit>
      printf("OK\n");
    5392:	00003517          	auipc	a0,0x3
    5396:	9b650513          	addi	a0,a0,-1610 # 7d48 <malloc+0x20ce>
    539a:	00001097          	auipc	ra,0x1
    539e:	822080e7          	jalr	-2014(ra) # 5bbc <printf>
    53a2:	bf55                	j	5356 <run+0x50>

00000000000053a4 <main>:

int
main(int argc, char *argv[])
{
    53a4:	7159                	addi	sp,sp,-112
    53a6:	f486                	sd	ra,104(sp)
    53a8:	f0a2                	sd	s0,96(sp)
    53aa:	eca6                	sd	s1,88(sp)
    53ac:	e8ca                	sd	s2,80(sp)
    53ae:	e4ce                	sd	s3,72(sp)
    53b0:	e0d2                	sd	s4,64(sp)
    53b2:	fc56                	sd	s5,56(sp)
    53b4:	f85a                	sd	s6,48(sp)
    53b6:	1880                	addi	s0,sp,112
    53b8:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    53ba:	4789                	li	a5,2
    53bc:	08f50563          	beq	a0,a5,5446 <main+0xa2>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    53c0:	4785                	li	a5,1
  char *justone = 0;
    53c2:	4901                	li	s2,0
  } else if(argc > 1){
    53c4:	0aa7cf63          	blt	a5,a0,5482 <main+0xde>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    53c8:	00003797          	auipc	a5,0x3
    53cc:	a7878793          	addi	a5,a5,-1416 # 7e40 <malloc+0x21c6>
    53d0:	7388                	ld	a0,32(a5)
    53d2:	778c                	ld	a1,40(a5)
    53d4:	7b90                	ld	a2,48(a5)
    53d6:	7f94                	ld	a3,56(a5)
    53d8:	63b8                	ld	a4,64(a5)
    53da:	67bc                	ld	a5,72(a5)
    53dc:	f8a43823          	sd	a0,-112(s0)
    53e0:	f8b43c23          	sd	a1,-104(s0)
    53e4:	fac43023          	sd	a2,-96(s0)
    53e8:	fad43423          	sd	a3,-88(s0)
    53ec:	fae43823          	sd	a4,-80(s0)
    53f0:	faf43c23          	sd	a5,-72(s0)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    53f4:	00003517          	auipc	a0,0x3
    53f8:	a0c50513          	addi	a0,a0,-1524 # 7e00 <malloc+0x2186>
    53fc:	00000097          	auipc	ra,0x0
    5400:	7c0080e7          	jalr	1984(ra) # 5bbc <printf>
  int free0 = countfree();
    5404:	00000097          	auipc	ra,0x0
    5408:	dd0080e7          	jalr	-560(ra) # 51d4 <countfree>
    540c:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    540e:	f9843503          	ld	a0,-104(s0)
    5412:	f9040493          	addi	s1,s0,-112
  int fail = 0;
    5416:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    5418:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    541a:	e55d                	bnez	a0,54c8 <main+0x124>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    541c:	00000097          	auipc	ra,0x0
    5420:	db8080e7          	jalr	-584(ra) # 51d4 <countfree>
    5424:	85aa                	mv	a1,a0
    5426:	0f455163          	bge	a0,s4,5508 <main+0x164>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    542a:	8652                	mv	a2,s4
    542c:	00003517          	auipc	a0,0x3
    5430:	98c50513          	addi	a0,a0,-1652 # 7db8 <malloc+0x213e>
    5434:	00000097          	auipc	ra,0x0
    5438:	788080e7          	jalr	1928(ra) # 5bbc <printf>
    exit(1);
    543c:	4505                	li	a0,1
    543e:	00000097          	auipc	ra,0x0
    5442:	3ee080e7          	jalr	1006(ra) # 582c <exit>
    5446:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5448:	00003597          	auipc	a1,0x3
    544c:	90858593          	addi	a1,a1,-1784 # 7d50 <malloc+0x20d6>
    5450:	6488                	ld	a0,8(s1)
    5452:	00000097          	auipc	ra,0x0
    5456:	180080e7          	jalr	384(ra) # 55d2 <strcmp>
    545a:	10050563          	beqz	a0,5564 <main+0x1c0>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    545e:	00003597          	auipc	a1,0x3
    5462:	9da58593          	addi	a1,a1,-1574 # 7e38 <malloc+0x21be>
    5466:	6488                	ld	a0,8(s1)
    5468:	00000097          	auipc	ra,0x0
    546c:	16a080e7          	jalr	362(ra) # 55d2 <strcmp>
    5470:	c97d                	beqz	a0,5566 <main+0x1c2>
  } else if(argc == 2 && argv[1][0] != '-'){
    5472:	0084b903          	ld	s2,8(s1)
    5476:	00094703          	lbu	a4,0(s2)
    547a:	02d00793          	li	a5,45
    547e:	f4f715e3          	bne	a4,a5,53c8 <main+0x24>
    printf("Usage: usertests [-c] [testname]\n");
    5482:	00003517          	auipc	a0,0x3
    5486:	8d650513          	addi	a0,a0,-1834 # 7d58 <malloc+0x20de>
    548a:	00000097          	auipc	ra,0x0
    548e:	732080e7          	jalr	1842(ra) # 5bbc <printf>
    exit(1);
    5492:	4505                	li	a0,1
    5494:	00000097          	auipc	ra,0x0
    5498:	398080e7          	jalr	920(ra) # 582c <exit>
          exit(1);
    549c:	4505                	li	a0,1
    549e:	00000097          	auipc	ra,0x0
    54a2:	38e080e7          	jalr	910(ra) # 582c <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    54a6:	40a905bb          	subw	a1,s2,a0
    54aa:	855a                	mv	a0,s6
    54ac:	00000097          	auipc	ra,0x0
    54b0:	710080e7          	jalr	1808(ra) # 5bbc <printf>
        if(continuous != 2)
    54b4:	09498463          	beq	s3,s4,553c <main+0x198>
          exit(1);
    54b8:	4505                	li	a0,1
    54ba:	00000097          	auipc	ra,0x0
    54be:	372080e7          	jalr	882(ra) # 582c <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    54c2:	04c1                	addi	s1,s1,16
    54c4:	6488                	ld	a0,8(s1)
    54c6:	c115                	beqz	a0,54ea <main+0x146>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    54c8:	00090863          	beqz	s2,54d8 <main+0x134>
    54cc:	85ca                	mv	a1,s2
    54ce:	00000097          	auipc	ra,0x0
    54d2:	104080e7          	jalr	260(ra) # 55d2 <strcmp>
    54d6:	f575                	bnez	a0,54c2 <main+0x11e>
      if(!run(t->f, t->s))
    54d8:	648c                	ld	a1,8(s1)
    54da:	6088                	ld	a0,0(s1)
    54dc:	00000097          	auipc	ra,0x0
    54e0:	e2a080e7          	jalr	-470(ra) # 5306 <run>
    54e4:	fd79                	bnez	a0,54c2 <main+0x11e>
        fail = 1;
    54e6:	89d6                	mv	s3,s5
    54e8:	bfe9                	j	54c2 <main+0x11e>
  if(fail){
    54ea:	f20989e3          	beqz	s3,541c <main+0x78>
    printf("SOME TESTS FAILED\n");
    54ee:	00003517          	auipc	a0,0x3
    54f2:	8b250513          	addi	a0,a0,-1870 # 7da0 <malloc+0x2126>
    54f6:	00000097          	auipc	ra,0x0
    54fa:	6c6080e7          	jalr	1734(ra) # 5bbc <printf>
    exit(1);
    54fe:	4505                	li	a0,1
    5500:	00000097          	auipc	ra,0x0
    5504:	32c080e7          	jalr	812(ra) # 582c <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5508:	00003517          	auipc	a0,0x3
    550c:	8e050513          	addi	a0,a0,-1824 # 7de8 <malloc+0x216e>
    5510:	00000097          	auipc	ra,0x0
    5514:	6ac080e7          	jalr	1708(ra) # 5bbc <printf>
    exit(0);
    5518:	4501                	li	a0,0
    551a:	00000097          	auipc	ra,0x0
    551e:	312080e7          	jalr	786(ra) # 582c <exit>
        printf("SOME TESTS FAILED\n");
    5522:	8556                	mv	a0,s5
    5524:	00000097          	auipc	ra,0x0
    5528:	698080e7          	jalr	1688(ra) # 5bbc <printf>
        if(continuous != 2)
    552c:	f74998e3          	bne	s3,s4,549c <main+0xf8>
      int free1 = countfree();
    5530:	00000097          	auipc	ra,0x0
    5534:	ca4080e7          	jalr	-860(ra) # 51d4 <countfree>
      if(free1 < free0){
    5538:	f72547e3          	blt	a0,s2,54a6 <main+0x102>
      int free0 = countfree();
    553c:	00000097          	auipc	ra,0x0
    5540:	c98080e7          	jalr	-872(ra) # 51d4 <countfree>
    5544:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5546:	f9843583          	ld	a1,-104(s0)
    554a:	d1fd                	beqz	a1,5530 <main+0x18c>
    554c:	f9040493          	addi	s1,s0,-112
        if(!run(t->f, t->s)){
    5550:	6088                	ld	a0,0(s1)
    5552:	00000097          	auipc	ra,0x0
    5556:	db4080e7          	jalr	-588(ra) # 5306 <run>
    555a:	d561                	beqz	a0,5522 <main+0x17e>
      for (struct test *t = tests; t->s != 0; t++) {
    555c:	04c1                	addi	s1,s1,16
    555e:	648c                	ld	a1,8(s1)
    5560:	f9e5                	bnez	a1,5550 <main+0x1ac>
    5562:	b7f9                	j	5530 <main+0x18c>
    continuous = 1;
    5564:	4985                	li	s3,1
  } tests[] = {
    5566:	00003797          	auipc	a5,0x3
    556a:	8da78793          	addi	a5,a5,-1830 # 7e40 <malloc+0x21c6>
    556e:	7388                	ld	a0,32(a5)
    5570:	778c                	ld	a1,40(a5)
    5572:	7b90                	ld	a2,48(a5)
    5574:	7f94                	ld	a3,56(a5)
    5576:	63b8                	ld	a4,64(a5)
    5578:	67bc                	ld	a5,72(a5)
    557a:	f8a43823          	sd	a0,-112(s0)
    557e:	f8b43c23          	sd	a1,-104(s0)
    5582:	fac43023          	sd	a2,-96(s0)
    5586:	fad43423          	sd	a3,-88(s0)
    558a:	fae43823          	sd	a4,-80(s0)
    558e:	faf43c23          	sd	a5,-72(s0)
    printf("continuous usertests starting\n");
    5592:	00003517          	auipc	a0,0x3
    5596:	88650513          	addi	a0,a0,-1914 # 7e18 <malloc+0x219e>
    559a:	00000097          	auipc	ra,0x0
    559e:	622080e7          	jalr	1570(ra) # 5bbc <printf>
        printf("SOME TESTS FAILED\n");
    55a2:	00002a97          	auipc	s5,0x2
    55a6:	7fea8a93          	addi	s5,s5,2046 # 7da0 <malloc+0x2126>
        if(continuous != 2)
    55aa:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    55ac:	00002b17          	auipc	s6,0x2
    55b0:	7d4b0b13          	addi	s6,s6,2004 # 7d80 <malloc+0x2106>
    55b4:	b761                	j	553c <main+0x198>

00000000000055b6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    55b6:	1141                	addi	sp,sp,-16
    55b8:	e422                	sd	s0,8(sp)
    55ba:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    55bc:	87aa                	mv	a5,a0
    55be:	0585                	addi	a1,a1,1
    55c0:	0785                	addi	a5,a5,1
    55c2:	fff5c703          	lbu	a4,-1(a1)
    55c6:	fee78fa3          	sb	a4,-1(a5)
    55ca:	fb75                	bnez	a4,55be <strcpy+0x8>
    ;
  return os;
}
    55cc:	6422                	ld	s0,8(sp)
    55ce:	0141                	addi	sp,sp,16
    55d0:	8082                	ret

00000000000055d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    55d2:	1141                	addi	sp,sp,-16
    55d4:	e422                	sd	s0,8(sp)
    55d6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    55d8:	00054783          	lbu	a5,0(a0)
    55dc:	cb91                	beqz	a5,55f0 <strcmp+0x1e>
    55de:	0005c703          	lbu	a4,0(a1)
    55e2:	00f71763          	bne	a4,a5,55f0 <strcmp+0x1e>
    p++, q++;
    55e6:	0505                	addi	a0,a0,1
    55e8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    55ea:	00054783          	lbu	a5,0(a0)
    55ee:	fbe5                	bnez	a5,55de <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    55f0:	0005c503          	lbu	a0,0(a1)
}
    55f4:	40a7853b          	subw	a0,a5,a0
    55f8:	6422                	ld	s0,8(sp)
    55fa:	0141                	addi	sp,sp,16
    55fc:	8082                	ret

00000000000055fe <strlen>:

uint
strlen(const char *s)
{
    55fe:	1141                	addi	sp,sp,-16
    5600:	e422                	sd	s0,8(sp)
    5602:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5604:	00054783          	lbu	a5,0(a0)
    5608:	cf91                	beqz	a5,5624 <strlen+0x26>
    560a:	0505                	addi	a0,a0,1
    560c:	87aa                	mv	a5,a0
    560e:	4685                	li	a3,1
    5610:	9e89                	subw	a3,a3,a0
    5612:	00f6853b          	addw	a0,a3,a5
    5616:	0785                	addi	a5,a5,1
    5618:	fff7c703          	lbu	a4,-1(a5)
    561c:	fb7d                	bnez	a4,5612 <strlen+0x14>
    ;
  return n;
}
    561e:	6422                	ld	s0,8(sp)
    5620:	0141                	addi	sp,sp,16
    5622:	8082                	ret
  for(n = 0; s[n]; n++)
    5624:	4501                	li	a0,0
    5626:	bfe5                	j	561e <strlen+0x20>

0000000000005628 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5628:	1141                	addi	sp,sp,-16
    562a:	e422                	sd	s0,8(sp)
    562c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    562e:	ce09                	beqz	a2,5648 <memset+0x20>
    5630:	87aa                	mv	a5,a0
    5632:	fff6071b          	addiw	a4,a2,-1
    5636:	1702                	slli	a4,a4,0x20
    5638:	9301                	srli	a4,a4,0x20
    563a:	0705                	addi	a4,a4,1
    563c:	972a                	add	a4,a4,a0
    cdst[i] = c;
    563e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5642:	0785                	addi	a5,a5,1
    5644:	fee79de3          	bne	a5,a4,563e <memset+0x16>
  }
  return dst;
}
    5648:	6422                	ld	s0,8(sp)
    564a:	0141                	addi	sp,sp,16
    564c:	8082                	ret

000000000000564e <strchr>:

char*
strchr(const char *s, char c)
{
    564e:	1141                	addi	sp,sp,-16
    5650:	e422                	sd	s0,8(sp)
    5652:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5654:	00054783          	lbu	a5,0(a0)
    5658:	cb99                	beqz	a5,566e <strchr+0x20>
    if(*s == c)
    565a:	00f58763          	beq	a1,a5,5668 <strchr+0x1a>
  for(; *s; s++)
    565e:	0505                	addi	a0,a0,1
    5660:	00054783          	lbu	a5,0(a0)
    5664:	fbfd                	bnez	a5,565a <strchr+0xc>
      return (char*)s;
  return 0;
    5666:	4501                	li	a0,0
}
    5668:	6422                	ld	s0,8(sp)
    566a:	0141                	addi	sp,sp,16
    566c:	8082                	ret
  return 0;
    566e:	4501                	li	a0,0
    5670:	bfe5                	j	5668 <strchr+0x1a>

0000000000005672 <gets>:

char*
gets(char *buf, int max)
{
    5672:	711d                	addi	sp,sp,-96
    5674:	ec86                	sd	ra,88(sp)
    5676:	e8a2                	sd	s0,80(sp)
    5678:	e4a6                	sd	s1,72(sp)
    567a:	e0ca                	sd	s2,64(sp)
    567c:	fc4e                	sd	s3,56(sp)
    567e:	f852                	sd	s4,48(sp)
    5680:	f456                	sd	s5,40(sp)
    5682:	f05a                	sd	s6,32(sp)
    5684:	ec5e                	sd	s7,24(sp)
    5686:	1080                	addi	s0,sp,96
    5688:	8baa                	mv	s7,a0
    568a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    568c:	892a                	mv	s2,a0
    568e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5690:	4aa9                	li	s5,10
    5692:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5694:	89a6                	mv	s3,s1
    5696:	2485                	addiw	s1,s1,1
    5698:	0344d863          	bge	s1,s4,56c8 <gets+0x56>
    cc = read(0, &c, 1);
    569c:	4605                	li	a2,1
    569e:	faf40593          	addi	a1,s0,-81
    56a2:	4501                	li	a0,0
    56a4:	00000097          	auipc	ra,0x0
    56a8:	1a0080e7          	jalr	416(ra) # 5844 <read>
    if(cc < 1)
    56ac:	00a05e63          	blez	a0,56c8 <gets+0x56>
    buf[i++] = c;
    56b0:	faf44783          	lbu	a5,-81(s0)
    56b4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    56b8:	01578763          	beq	a5,s5,56c6 <gets+0x54>
    56bc:	0905                	addi	s2,s2,1
    56be:	fd679be3          	bne	a5,s6,5694 <gets+0x22>
  for(i=0; i+1 < max; ){
    56c2:	89a6                	mv	s3,s1
    56c4:	a011                	j	56c8 <gets+0x56>
    56c6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    56c8:	99de                	add	s3,s3,s7
    56ca:	00098023          	sb	zero,0(s3)
  return buf;
}
    56ce:	855e                	mv	a0,s7
    56d0:	60e6                	ld	ra,88(sp)
    56d2:	6446                	ld	s0,80(sp)
    56d4:	64a6                	ld	s1,72(sp)
    56d6:	6906                	ld	s2,64(sp)
    56d8:	79e2                	ld	s3,56(sp)
    56da:	7a42                	ld	s4,48(sp)
    56dc:	7aa2                	ld	s5,40(sp)
    56de:	7b02                	ld	s6,32(sp)
    56e0:	6be2                	ld	s7,24(sp)
    56e2:	6125                	addi	sp,sp,96
    56e4:	8082                	ret

00000000000056e6 <stat>:

int
stat(const char *n, struct stat *st)
{
    56e6:	1101                	addi	sp,sp,-32
    56e8:	ec06                	sd	ra,24(sp)
    56ea:	e822                	sd	s0,16(sp)
    56ec:	e426                	sd	s1,8(sp)
    56ee:	e04a                	sd	s2,0(sp)
    56f0:	1000                	addi	s0,sp,32
    56f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    56f4:	4581                	li	a1,0
    56f6:	00000097          	auipc	ra,0x0
    56fa:	176080e7          	jalr	374(ra) # 586c <open>
  if(fd < 0)
    56fe:	02054563          	bltz	a0,5728 <stat+0x42>
    5702:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5704:	85ca                	mv	a1,s2
    5706:	00000097          	auipc	ra,0x0
    570a:	17e080e7          	jalr	382(ra) # 5884 <fstat>
    570e:	892a                	mv	s2,a0
  close(fd);
    5710:	8526                	mv	a0,s1
    5712:	00000097          	auipc	ra,0x0
    5716:	142080e7          	jalr	322(ra) # 5854 <close>
  return r;
}
    571a:	854a                	mv	a0,s2
    571c:	60e2                	ld	ra,24(sp)
    571e:	6442                	ld	s0,16(sp)
    5720:	64a2                	ld	s1,8(sp)
    5722:	6902                	ld	s2,0(sp)
    5724:	6105                	addi	sp,sp,32
    5726:	8082                	ret
    return -1;
    5728:	597d                	li	s2,-1
    572a:	bfc5                	j	571a <stat+0x34>

000000000000572c <atoi>:

int
atoi(const char *s)
{
    572c:	1141                	addi	sp,sp,-16
    572e:	e422                	sd	s0,8(sp)
    5730:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5732:	00054603          	lbu	a2,0(a0)
    5736:	fd06079b          	addiw	a5,a2,-48
    573a:	0ff7f793          	andi	a5,a5,255
    573e:	4725                	li	a4,9
    5740:	02f76963          	bltu	a4,a5,5772 <atoi+0x46>
    5744:	86aa                	mv	a3,a0
  n = 0;
    5746:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5748:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    574a:	0685                	addi	a3,a3,1
    574c:	0025179b          	slliw	a5,a0,0x2
    5750:	9fa9                	addw	a5,a5,a0
    5752:	0017979b          	slliw	a5,a5,0x1
    5756:	9fb1                	addw	a5,a5,a2
    5758:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    575c:	0006c603          	lbu	a2,0(a3)
    5760:	fd06071b          	addiw	a4,a2,-48
    5764:	0ff77713          	andi	a4,a4,255
    5768:	fee5f1e3          	bgeu	a1,a4,574a <atoi+0x1e>
  return n;
}
    576c:	6422                	ld	s0,8(sp)
    576e:	0141                	addi	sp,sp,16
    5770:	8082                	ret
  n = 0;
    5772:	4501                	li	a0,0
    5774:	bfe5                	j	576c <atoi+0x40>

0000000000005776 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5776:	1141                	addi	sp,sp,-16
    5778:	e422                	sd	s0,8(sp)
    577a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    577c:	02b57663          	bgeu	a0,a1,57a8 <memmove+0x32>
    while(n-- > 0)
    5780:	02c05163          	blez	a2,57a2 <memmove+0x2c>
    5784:	fff6079b          	addiw	a5,a2,-1
    5788:	1782                	slli	a5,a5,0x20
    578a:	9381                	srli	a5,a5,0x20
    578c:	0785                	addi	a5,a5,1
    578e:	97aa                	add	a5,a5,a0
  dst = vdst;
    5790:	872a                	mv	a4,a0
      *dst++ = *src++;
    5792:	0585                	addi	a1,a1,1
    5794:	0705                	addi	a4,a4,1
    5796:	fff5c683          	lbu	a3,-1(a1)
    579a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    579e:	fee79ae3          	bne	a5,a4,5792 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    57a2:	6422                	ld	s0,8(sp)
    57a4:	0141                	addi	sp,sp,16
    57a6:	8082                	ret
    dst += n;
    57a8:	00c50733          	add	a4,a0,a2
    src += n;
    57ac:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    57ae:	fec05ae3          	blez	a2,57a2 <memmove+0x2c>
    57b2:	fff6079b          	addiw	a5,a2,-1
    57b6:	1782                	slli	a5,a5,0x20
    57b8:	9381                	srli	a5,a5,0x20
    57ba:	fff7c793          	not	a5,a5
    57be:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    57c0:	15fd                	addi	a1,a1,-1
    57c2:	177d                	addi	a4,a4,-1
    57c4:	0005c683          	lbu	a3,0(a1)
    57c8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    57cc:	fee79ae3          	bne	a5,a4,57c0 <memmove+0x4a>
    57d0:	bfc9                	j	57a2 <memmove+0x2c>

00000000000057d2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    57d2:	1141                	addi	sp,sp,-16
    57d4:	e422                	sd	s0,8(sp)
    57d6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    57d8:	ca05                	beqz	a2,5808 <memcmp+0x36>
    57da:	fff6069b          	addiw	a3,a2,-1
    57de:	1682                	slli	a3,a3,0x20
    57e0:	9281                	srli	a3,a3,0x20
    57e2:	0685                	addi	a3,a3,1
    57e4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    57e6:	00054783          	lbu	a5,0(a0)
    57ea:	0005c703          	lbu	a4,0(a1)
    57ee:	00e79863          	bne	a5,a4,57fe <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    57f2:	0505                	addi	a0,a0,1
    p2++;
    57f4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    57f6:	fed518e3          	bne	a0,a3,57e6 <memcmp+0x14>
  }
  return 0;
    57fa:	4501                	li	a0,0
    57fc:	a019                	j	5802 <memcmp+0x30>
      return *p1 - *p2;
    57fe:	40e7853b          	subw	a0,a5,a4
}
    5802:	6422                	ld	s0,8(sp)
    5804:	0141                	addi	sp,sp,16
    5806:	8082                	ret
  return 0;
    5808:	4501                	li	a0,0
    580a:	bfe5                	j	5802 <memcmp+0x30>

000000000000580c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    580c:	1141                	addi	sp,sp,-16
    580e:	e406                	sd	ra,8(sp)
    5810:	e022                	sd	s0,0(sp)
    5812:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5814:	00000097          	auipc	ra,0x0
    5818:	f62080e7          	jalr	-158(ra) # 5776 <memmove>
}
    581c:	60a2                	ld	ra,8(sp)
    581e:	6402                	ld	s0,0(sp)
    5820:	0141                	addi	sp,sp,16
    5822:	8082                	ret

0000000000005824 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5824:	4885                	li	a7,1
 ecall
    5826:	00000073          	ecall
 ret
    582a:	8082                	ret

000000000000582c <exit>:
.global exit
exit:
 li a7, SYS_exit
    582c:	4889                	li	a7,2
 ecall
    582e:	00000073          	ecall
 ret
    5832:	8082                	ret

0000000000005834 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5834:	488d                	li	a7,3
 ecall
    5836:	00000073          	ecall
 ret
    583a:	8082                	ret

000000000000583c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    583c:	4891                	li	a7,4
 ecall
    583e:	00000073          	ecall
 ret
    5842:	8082                	ret

0000000000005844 <read>:
.global read
read:
 li a7, SYS_read
    5844:	4895                	li	a7,5
 ecall
    5846:	00000073          	ecall
 ret
    584a:	8082                	ret

000000000000584c <write>:
.global write
write:
 li a7, SYS_write
    584c:	48c1                	li	a7,16
 ecall
    584e:	00000073          	ecall
 ret
    5852:	8082                	ret

0000000000005854 <close>:
.global close
close:
 li a7, SYS_close
    5854:	48d5                	li	a7,21
 ecall
    5856:	00000073          	ecall
 ret
    585a:	8082                	ret

000000000000585c <kill>:
.global kill
kill:
 li a7, SYS_kill
    585c:	4899                	li	a7,6
 ecall
    585e:	00000073          	ecall
 ret
    5862:	8082                	ret

0000000000005864 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5864:	489d                	li	a7,7
 ecall
    5866:	00000073          	ecall
 ret
    586a:	8082                	ret

000000000000586c <open>:
.global open
open:
 li a7, SYS_open
    586c:	48bd                	li	a7,15
 ecall
    586e:	00000073          	ecall
 ret
    5872:	8082                	ret

0000000000005874 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5874:	48c5                	li	a7,17
 ecall
    5876:	00000073          	ecall
 ret
    587a:	8082                	ret

000000000000587c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    587c:	48c9                	li	a7,18
 ecall
    587e:	00000073          	ecall
 ret
    5882:	8082                	ret

0000000000005884 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5884:	48a1                	li	a7,8
 ecall
    5886:	00000073          	ecall
 ret
    588a:	8082                	ret

000000000000588c <link>:
.global link
link:
 li a7, SYS_link
    588c:	48cd                	li	a7,19
 ecall
    588e:	00000073          	ecall
 ret
    5892:	8082                	ret

0000000000005894 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5894:	48d1                	li	a7,20
 ecall
    5896:	00000073          	ecall
 ret
    589a:	8082                	ret

000000000000589c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    589c:	48a5                	li	a7,9
 ecall
    589e:	00000073          	ecall
 ret
    58a2:	8082                	ret

00000000000058a4 <dup>:
.global dup
dup:
 li a7, SYS_dup
    58a4:	48a9                	li	a7,10
 ecall
    58a6:	00000073          	ecall
 ret
    58aa:	8082                	ret

00000000000058ac <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    58ac:	48ad                	li	a7,11
 ecall
    58ae:	00000073          	ecall
 ret
    58b2:	8082                	ret

00000000000058b4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    58b4:	48b1                	li	a7,12
 ecall
    58b6:	00000073          	ecall
 ret
    58ba:	8082                	ret

00000000000058bc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    58bc:	48b5                	li	a7,13
 ecall
    58be:	00000073          	ecall
 ret
    58c2:	8082                	ret

00000000000058c4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    58c4:	48b9                	li	a7,14
 ecall
    58c6:	00000073          	ecall
 ret
    58ca:	8082                	ret

00000000000058cc <set_cpu>:
.global set_cpu
set_cpu:
 li a7, SYS_set_cpu
    58cc:	48d9                	li	a7,22
 ecall
    58ce:	00000073          	ecall
 ret
    58d2:	8082                	ret

00000000000058d4 <get_cpu>:
.global get_cpu
get_cpu:
 li a7, SYS_get_cpu
    58d4:	48dd                	li	a7,23
 ecall
    58d6:	00000073          	ecall
 ret
    58da:	8082                	ret

00000000000058dc <cpu_process_count>:
.global cpu_process_count
cpu_process_count:
 li a7, SYS_cpu_process_count
    58dc:	48e1                	li	a7,24
 ecall
    58de:	00000073          	ecall
 ret
    58e2:	8082                	ret

00000000000058e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    58e4:	1101                	addi	sp,sp,-32
    58e6:	ec06                	sd	ra,24(sp)
    58e8:	e822                	sd	s0,16(sp)
    58ea:	1000                	addi	s0,sp,32
    58ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    58f0:	4605                	li	a2,1
    58f2:	fef40593          	addi	a1,s0,-17
    58f6:	00000097          	auipc	ra,0x0
    58fa:	f56080e7          	jalr	-170(ra) # 584c <write>
}
    58fe:	60e2                	ld	ra,24(sp)
    5900:	6442                	ld	s0,16(sp)
    5902:	6105                	addi	sp,sp,32
    5904:	8082                	ret

0000000000005906 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5906:	7139                	addi	sp,sp,-64
    5908:	fc06                	sd	ra,56(sp)
    590a:	f822                	sd	s0,48(sp)
    590c:	f426                	sd	s1,40(sp)
    590e:	f04a                	sd	s2,32(sp)
    5910:	ec4e                	sd	s3,24(sp)
    5912:	0080                	addi	s0,sp,64
    5914:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5916:	c299                	beqz	a3,591c <printint+0x16>
    5918:	0805c863          	bltz	a1,59a8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    591c:	2581                	sext.w	a1,a1
  neg = 0;
    591e:	4881                	li	a7,0
    5920:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5924:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5926:	2601                	sext.w	a2,a2
    5928:	00002517          	auipc	a0,0x2
    592c:	57050513          	addi	a0,a0,1392 # 7e98 <digits>
    5930:	883a                	mv	a6,a4
    5932:	2705                	addiw	a4,a4,1
    5934:	02c5f7bb          	remuw	a5,a1,a2
    5938:	1782                	slli	a5,a5,0x20
    593a:	9381                	srli	a5,a5,0x20
    593c:	97aa                	add	a5,a5,a0
    593e:	0007c783          	lbu	a5,0(a5)
    5942:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5946:	0005879b          	sext.w	a5,a1
    594a:	02c5d5bb          	divuw	a1,a1,a2
    594e:	0685                	addi	a3,a3,1
    5950:	fec7f0e3          	bgeu	a5,a2,5930 <printint+0x2a>
  if(neg)
    5954:	00088b63          	beqz	a7,596a <printint+0x64>
    buf[i++] = '-';
    5958:	fd040793          	addi	a5,s0,-48
    595c:	973e                	add	a4,a4,a5
    595e:	02d00793          	li	a5,45
    5962:	fef70823          	sb	a5,-16(a4)
    5966:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    596a:	02e05863          	blez	a4,599a <printint+0x94>
    596e:	fc040793          	addi	a5,s0,-64
    5972:	00e78933          	add	s2,a5,a4
    5976:	fff78993          	addi	s3,a5,-1
    597a:	99ba                	add	s3,s3,a4
    597c:	377d                	addiw	a4,a4,-1
    597e:	1702                	slli	a4,a4,0x20
    5980:	9301                	srli	a4,a4,0x20
    5982:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5986:	fff94583          	lbu	a1,-1(s2)
    598a:	8526                	mv	a0,s1
    598c:	00000097          	auipc	ra,0x0
    5990:	f58080e7          	jalr	-168(ra) # 58e4 <putc>
  while(--i >= 0)
    5994:	197d                	addi	s2,s2,-1
    5996:	ff3918e3          	bne	s2,s3,5986 <printint+0x80>
}
    599a:	70e2                	ld	ra,56(sp)
    599c:	7442                	ld	s0,48(sp)
    599e:	74a2                	ld	s1,40(sp)
    59a0:	7902                	ld	s2,32(sp)
    59a2:	69e2                	ld	s3,24(sp)
    59a4:	6121                	addi	sp,sp,64
    59a6:	8082                	ret
    x = -xx;
    59a8:	40b005bb          	negw	a1,a1
    neg = 1;
    59ac:	4885                	li	a7,1
    x = -xx;
    59ae:	bf8d                	j	5920 <printint+0x1a>

00000000000059b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    59b0:	7119                	addi	sp,sp,-128
    59b2:	fc86                	sd	ra,120(sp)
    59b4:	f8a2                	sd	s0,112(sp)
    59b6:	f4a6                	sd	s1,104(sp)
    59b8:	f0ca                	sd	s2,96(sp)
    59ba:	ecce                	sd	s3,88(sp)
    59bc:	e8d2                	sd	s4,80(sp)
    59be:	e4d6                	sd	s5,72(sp)
    59c0:	e0da                	sd	s6,64(sp)
    59c2:	fc5e                	sd	s7,56(sp)
    59c4:	f862                	sd	s8,48(sp)
    59c6:	f466                	sd	s9,40(sp)
    59c8:	f06a                	sd	s10,32(sp)
    59ca:	ec6e                	sd	s11,24(sp)
    59cc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    59ce:	0005c903          	lbu	s2,0(a1)
    59d2:	18090f63          	beqz	s2,5b70 <vprintf+0x1c0>
    59d6:	8aaa                	mv	s5,a0
    59d8:	8b32                	mv	s6,a2
    59da:	00158493          	addi	s1,a1,1
  state = 0;
    59de:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    59e0:	02500a13          	li	s4,37
      if(c == 'd'){
    59e4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    59e8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    59ec:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    59f0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    59f4:	00002b97          	auipc	s7,0x2
    59f8:	4a4b8b93          	addi	s7,s7,1188 # 7e98 <digits>
    59fc:	a839                	j	5a1a <vprintf+0x6a>
        putc(fd, c);
    59fe:	85ca                	mv	a1,s2
    5a00:	8556                	mv	a0,s5
    5a02:	00000097          	auipc	ra,0x0
    5a06:	ee2080e7          	jalr	-286(ra) # 58e4 <putc>
    5a0a:	a019                	j	5a10 <vprintf+0x60>
    } else if(state == '%'){
    5a0c:	01498f63          	beq	s3,s4,5a2a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5a10:	0485                	addi	s1,s1,1
    5a12:	fff4c903          	lbu	s2,-1(s1)
    5a16:	14090d63          	beqz	s2,5b70 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5a1a:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5a1e:	fe0997e3          	bnez	s3,5a0c <vprintf+0x5c>
      if(c == '%'){
    5a22:	fd479ee3          	bne	a5,s4,59fe <vprintf+0x4e>
        state = '%';
    5a26:	89be                	mv	s3,a5
    5a28:	b7e5                	j	5a10 <vprintf+0x60>
      if(c == 'd'){
    5a2a:	05878063          	beq	a5,s8,5a6a <vprintf+0xba>
      } else if(c == 'l') {
    5a2e:	05978c63          	beq	a5,s9,5a86 <vprintf+0xd6>
      } else if(c == 'x') {
    5a32:	07a78863          	beq	a5,s10,5aa2 <vprintf+0xf2>
      } else if(c == 'p') {
    5a36:	09b78463          	beq	a5,s11,5abe <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5a3a:	07300713          	li	a4,115
    5a3e:	0ce78663          	beq	a5,a4,5b0a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5a42:	06300713          	li	a4,99
    5a46:	0ee78e63          	beq	a5,a4,5b42 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5a4a:	11478863          	beq	a5,s4,5b5a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5a4e:	85d2                	mv	a1,s4
    5a50:	8556                	mv	a0,s5
    5a52:	00000097          	auipc	ra,0x0
    5a56:	e92080e7          	jalr	-366(ra) # 58e4 <putc>
        putc(fd, c);
    5a5a:	85ca                	mv	a1,s2
    5a5c:	8556                	mv	a0,s5
    5a5e:	00000097          	auipc	ra,0x0
    5a62:	e86080e7          	jalr	-378(ra) # 58e4 <putc>
      }
      state = 0;
    5a66:	4981                	li	s3,0
    5a68:	b765                	j	5a10 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5a6a:	008b0913          	addi	s2,s6,8
    5a6e:	4685                	li	a3,1
    5a70:	4629                	li	a2,10
    5a72:	000b2583          	lw	a1,0(s6)
    5a76:	8556                	mv	a0,s5
    5a78:	00000097          	auipc	ra,0x0
    5a7c:	e8e080e7          	jalr	-370(ra) # 5906 <printint>
    5a80:	8b4a                	mv	s6,s2
      state = 0;
    5a82:	4981                	li	s3,0
    5a84:	b771                	j	5a10 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5a86:	008b0913          	addi	s2,s6,8
    5a8a:	4681                	li	a3,0
    5a8c:	4629                	li	a2,10
    5a8e:	000b2583          	lw	a1,0(s6)
    5a92:	8556                	mv	a0,s5
    5a94:	00000097          	auipc	ra,0x0
    5a98:	e72080e7          	jalr	-398(ra) # 5906 <printint>
    5a9c:	8b4a                	mv	s6,s2
      state = 0;
    5a9e:	4981                	li	s3,0
    5aa0:	bf85                	j	5a10 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5aa2:	008b0913          	addi	s2,s6,8
    5aa6:	4681                	li	a3,0
    5aa8:	4641                	li	a2,16
    5aaa:	000b2583          	lw	a1,0(s6)
    5aae:	8556                	mv	a0,s5
    5ab0:	00000097          	auipc	ra,0x0
    5ab4:	e56080e7          	jalr	-426(ra) # 5906 <printint>
    5ab8:	8b4a                	mv	s6,s2
      state = 0;
    5aba:	4981                	li	s3,0
    5abc:	bf91                	j	5a10 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5abe:	008b0793          	addi	a5,s6,8
    5ac2:	f8f43423          	sd	a5,-120(s0)
    5ac6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5aca:	03000593          	li	a1,48
    5ace:	8556                	mv	a0,s5
    5ad0:	00000097          	auipc	ra,0x0
    5ad4:	e14080e7          	jalr	-492(ra) # 58e4 <putc>
  putc(fd, 'x');
    5ad8:	85ea                	mv	a1,s10
    5ada:	8556                	mv	a0,s5
    5adc:	00000097          	auipc	ra,0x0
    5ae0:	e08080e7          	jalr	-504(ra) # 58e4 <putc>
    5ae4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5ae6:	03c9d793          	srli	a5,s3,0x3c
    5aea:	97de                	add	a5,a5,s7
    5aec:	0007c583          	lbu	a1,0(a5)
    5af0:	8556                	mv	a0,s5
    5af2:	00000097          	auipc	ra,0x0
    5af6:	df2080e7          	jalr	-526(ra) # 58e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5afa:	0992                	slli	s3,s3,0x4
    5afc:	397d                	addiw	s2,s2,-1
    5afe:	fe0914e3          	bnez	s2,5ae6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5b02:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5b06:	4981                	li	s3,0
    5b08:	b721                	j	5a10 <vprintf+0x60>
        s = va_arg(ap, char*);
    5b0a:	008b0993          	addi	s3,s6,8
    5b0e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5b12:	02090163          	beqz	s2,5b34 <vprintf+0x184>
        while(*s != 0){
    5b16:	00094583          	lbu	a1,0(s2)
    5b1a:	c9a1                	beqz	a1,5b6a <vprintf+0x1ba>
          putc(fd, *s);
    5b1c:	8556                	mv	a0,s5
    5b1e:	00000097          	auipc	ra,0x0
    5b22:	dc6080e7          	jalr	-570(ra) # 58e4 <putc>
          s++;
    5b26:	0905                	addi	s2,s2,1
        while(*s != 0){
    5b28:	00094583          	lbu	a1,0(s2)
    5b2c:	f9e5                	bnez	a1,5b1c <vprintf+0x16c>
        s = va_arg(ap, char*);
    5b2e:	8b4e                	mv	s6,s3
      state = 0;
    5b30:	4981                	li	s3,0
    5b32:	bdf9                	j	5a10 <vprintf+0x60>
          s = "(null)";
    5b34:	00002917          	auipc	s2,0x2
    5b38:	35c90913          	addi	s2,s2,860 # 7e90 <malloc+0x2216>
        while(*s != 0){
    5b3c:	02800593          	li	a1,40
    5b40:	bff1                	j	5b1c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5b42:	008b0913          	addi	s2,s6,8
    5b46:	000b4583          	lbu	a1,0(s6)
    5b4a:	8556                	mv	a0,s5
    5b4c:	00000097          	auipc	ra,0x0
    5b50:	d98080e7          	jalr	-616(ra) # 58e4 <putc>
    5b54:	8b4a                	mv	s6,s2
      state = 0;
    5b56:	4981                	li	s3,0
    5b58:	bd65                	j	5a10 <vprintf+0x60>
        putc(fd, c);
    5b5a:	85d2                	mv	a1,s4
    5b5c:	8556                	mv	a0,s5
    5b5e:	00000097          	auipc	ra,0x0
    5b62:	d86080e7          	jalr	-634(ra) # 58e4 <putc>
      state = 0;
    5b66:	4981                	li	s3,0
    5b68:	b565                	j	5a10 <vprintf+0x60>
        s = va_arg(ap, char*);
    5b6a:	8b4e                	mv	s6,s3
      state = 0;
    5b6c:	4981                	li	s3,0
    5b6e:	b54d                	j	5a10 <vprintf+0x60>
    }
  }
}
    5b70:	70e6                	ld	ra,120(sp)
    5b72:	7446                	ld	s0,112(sp)
    5b74:	74a6                	ld	s1,104(sp)
    5b76:	7906                	ld	s2,96(sp)
    5b78:	69e6                	ld	s3,88(sp)
    5b7a:	6a46                	ld	s4,80(sp)
    5b7c:	6aa6                	ld	s5,72(sp)
    5b7e:	6b06                	ld	s6,64(sp)
    5b80:	7be2                	ld	s7,56(sp)
    5b82:	7c42                	ld	s8,48(sp)
    5b84:	7ca2                	ld	s9,40(sp)
    5b86:	7d02                	ld	s10,32(sp)
    5b88:	6de2                	ld	s11,24(sp)
    5b8a:	6109                	addi	sp,sp,128
    5b8c:	8082                	ret

0000000000005b8e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5b8e:	715d                	addi	sp,sp,-80
    5b90:	ec06                	sd	ra,24(sp)
    5b92:	e822                	sd	s0,16(sp)
    5b94:	1000                	addi	s0,sp,32
    5b96:	e010                	sd	a2,0(s0)
    5b98:	e414                	sd	a3,8(s0)
    5b9a:	e818                	sd	a4,16(s0)
    5b9c:	ec1c                	sd	a5,24(s0)
    5b9e:	03043023          	sd	a6,32(s0)
    5ba2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5ba6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5baa:	8622                	mv	a2,s0
    5bac:	00000097          	auipc	ra,0x0
    5bb0:	e04080e7          	jalr	-508(ra) # 59b0 <vprintf>
}
    5bb4:	60e2                	ld	ra,24(sp)
    5bb6:	6442                	ld	s0,16(sp)
    5bb8:	6161                	addi	sp,sp,80
    5bba:	8082                	ret

0000000000005bbc <printf>:

void
printf(const char *fmt, ...)
{
    5bbc:	711d                	addi	sp,sp,-96
    5bbe:	ec06                	sd	ra,24(sp)
    5bc0:	e822                	sd	s0,16(sp)
    5bc2:	1000                	addi	s0,sp,32
    5bc4:	e40c                	sd	a1,8(s0)
    5bc6:	e810                	sd	a2,16(s0)
    5bc8:	ec14                	sd	a3,24(s0)
    5bca:	f018                	sd	a4,32(s0)
    5bcc:	f41c                	sd	a5,40(s0)
    5bce:	03043823          	sd	a6,48(s0)
    5bd2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5bd6:	00840613          	addi	a2,s0,8
    5bda:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5bde:	85aa                	mv	a1,a0
    5be0:	4505                	li	a0,1
    5be2:	00000097          	auipc	ra,0x0
    5be6:	dce080e7          	jalr	-562(ra) # 59b0 <vprintf>
}
    5bea:	60e2                	ld	ra,24(sp)
    5bec:	6442                	ld	s0,16(sp)
    5bee:	6125                	addi	sp,sp,96
    5bf0:	8082                	ret

0000000000005bf2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5bf2:	1141                	addi	sp,sp,-16
    5bf4:	e422                	sd	s0,8(sp)
    5bf6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5bf8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5bfc:	00002797          	auipc	a5,0x2
    5c00:	2bc7b783          	ld	a5,700(a5) # 7eb8 <freep>
    5c04:	a805                	j	5c34 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5c06:	4618                	lw	a4,8(a2)
    5c08:	9db9                	addw	a1,a1,a4
    5c0a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5c0e:	6398                	ld	a4,0(a5)
    5c10:	6318                	ld	a4,0(a4)
    5c12:	fee53823          	sd	a4,-16(a0)
    5c16:	a091                	j	5c5a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5c18:	ff852703          	lw	a4,-8(a0)
    5c1c:	9e39                	addw	a2,a2,a4
    5c1e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5c20:	ff053703          	ld	a4,-16(a0)
    5c24:	e398                	sd	a4,0(a5)
    5c26:	a099                	j	5c6c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c28:	6398                	ld	a4,0(a5)
    5c2a:	00e7e463          	bltu	a5,a4,5c32 <free+0x40>
    5c2e:	00e6ea63          	bltu	a3,a4,5c42 <free+0x50>
{
    5c32:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c34:	fed7fae3          	bgeu	a5,a3,5c28 <free+0x36>
    5c38:	6398                	ld	a4,0(a5)
    5c3a:	00e6e463          	bltu	a3,a4,5c42 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c3e:	fee7eae3          	bltu	a5,a4,5c32 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5c42:	ff852583          	lw	a1,-8(a0)
    5c46:	6390                	ld	a2,0(a5)
    5c48:	02059713          	slli	a4,a1,0x20
    5c4c:	9301                	srli	a4,a4,0x20
    5c4e:	0712                	slli	a4,a4,0x4
    5c50:	9736                	add	a4,a4,a3
    5c52:	fae60ae3          	beq	a2,a4,5c06 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5c56:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5c5a:	4790                	lw	a2,8(a5)
    5c5c:	02061713          	slli	a4,a2,0x20
    5c60:	9301                	srli	a4,a4,0x20
    5c62:	0712                	slli	a4,a4,0x4
    5c64:	973e                	add	a4,a4,a5
    5c66:	fae689e3          	beq	a3,a4,5c18 <free+0x26>
  } else
    p->s.ptr = bp;
    5c6a:	e394                	sd	a3,0(a5)
  freep = p;
    5c6c:	00002717          	auipc	a4,0x2
    5c70:	24f73623          	sd	a5,588(a4) # 7eb8 <freep>
}
    5c74:	6422                	ld	s0,8(sp)
    5c76:	0141                	addi	sp,sp,16
    5c78:	8082                	ret

0000000000005c7a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5c7a:	7139                	addi	sp,sp,-64
    5c7c:	fc06                	sd	ra,56(sp)
    5c7e:	f822                	sd	s0,48(sp)
    5c80:	f426                	sd	s1,40(sp)
    5c82:	f04a                	sd	s2,32(sp)
    5c84:	ec4e                	sd	s3,24(sp)
    5c86:	e852                	sd	s4,16(sp)
    5c88:	e456                	sd	s5,8(sp)
    5c8a:	e05a                	sd	s6,0(sp)
    5c8c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5c8e:	02051493          	slli	s1,a0,0x20
    5c92:	9081                	srli	s1,s1,0x20
    5c94:	04bd                	addi	s1,s1,15
    5c96:	8091                	srli	s1,s1,0x4
    5c98:	0014899b          	addiw	s3,s1,1
    5c9c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5c9e:	00002517          	auipc	a0,0x2
    5ca2:	21a53503          	ld	a0,538(a0) # 7eb8 <freep>
    5ca6:	c515                	beqz	a0,5cd2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5ca8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5caa:	4798                	lw	a4,8(a5)
    5cac:	02977f63          	bgeu	a4,s1,5cea <malloc+0x70>
    5cb0:	8a4e                	mv	s4,s3
    5cb2:	0009871b          	sext.w	a4,s3
    5cb6:	6685                	lui	a3,0x1
    5cb8:	00d77363          	bgeu	a4,a3,5cbe <malloc+0x44>
    5cbc:	6a05                	lui	s4,0x1
    5cbe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5cc2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5cc6:	00002917          	auipc	s2,0x2
    5cca:	1f290913          	addi	s2,s2,498 # 7eb8 <freep>
  if(p == (char*)-1)
    5cce:	5afd                	li	s5,-1
    5cd0:	a88d                	j	5d42 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5cd2:	00009797          	auipc	a5,0x9
    5cd6:	a0678793          	addi	a5,a5,-1530 # e6d8 <base>
    5cda:	00002717          	auipc	a4,0x2
    5cde:	1cf73f23          	sd	a5,478(a4) # 7eb8 <freep>
    5ce2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ce4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5ce8:	b7e1                	j	5cb0 <malloc+0x36>
      if(p->s.size == nunits)
    5cea:	02e48b63          	beq	s1,a4,5d20 <malloc+0xa6>
        p->s.size -= nunits;
    5cee:	4137073b          	subw	a4,a4,s3
    5cf2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5cf4:	1702                	slli	a4,a4,0x20
    5cf6:	9301                	srli	a4,a4,0x20
    5cf8:	0712                	slli	a4,a4,0x4
    5cfa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5cfc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5d00:	00002717          	auipc	a4,0x2
    5d04:	1aa73c23          	sd	a0,440(a4) # 7eb8 <freep>
      return (void*)(p + 1);
    5d08:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5d0c:	70e2                	ld	ra,56(sp)
    5d0e:	7442                	ld	s0,48(sp)
    5d10:	74a2                	ld	s1,40(sp)
    5d12:	7902                	ld	s2,32(sp)
    5d14:	69e2                	ld	s3,24(sp)
    5d16:	6a42                	ld	s4,16(sp)
    5d18:	6aa2                	ld	s5,8(sp)
    5d1a:	6b02                	ld	s6,0(sp)
    5d1c:	6121                	addi	sp,sp,64
    5d1e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5d20:	6398                	ld	a4,0(a5)
    5d22:	e118                	sd	a4,0(a0)
    5d24:	bff1                	j	5d00 <malloc+0x86>
  hp->s.size = nu;
    5d26:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5d2a:	0541                	addi	a0,a0,16
    5d2c:	00000097          	auipc	ra,0x0
    5d30:	ec6080e7          	jalr	-314(ra) # 5bf2 <free>
  return freep;
    5d34:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5d38:	d971                	beqz	a0,5d0c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5d3a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5d3c:	4798                	lw	a4,8(a5)
    5d3e:	fa9776e3          	bgeu	a4,s1,5cea <malloc+0x70>
    if(p == freep)
    5d42:	00093703          	ld	a4,0(s2)
    5d46:	853e                	mv	a0,a5
    5d48:	fef719e3          	bne	a4,a5,5d3a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5d4c:	8552                	mv	a0,s4
    5d4e:	00000097          	auipc	ra,0x0
    5d52:	b66080e7          	jalr	-1178(ra) # 58b4 <sbrk>
  if(p == (char*)-1)
    5d56:	fd5518e3          	bne	a0,s5,5d26 <malloc+0xac>
        return 0;
    5d5a:	4501                	li	a0,0
    5d5c:	bf45                	j	5d0c <malloc+0x92>
