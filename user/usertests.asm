
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	878080e7          	jalr	-1928(ra) # 5888 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	866080e7          	jalr	-1946(ra) # 5888 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	07a50513          	addi	a0,a0,122 # 60b8 <malloc+0x422>
      46:	00006097          	auipc	ra,0x6
      4a:	b92080e7          	jalr	-1134(ra) # 5bd8 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	7f8080e7          	jalr	2040(ra) # 5848 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	5e078793          	addi	a5,a5,1504 # 9638 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	ce868693          	addi	a3,a3,-792 # bd48 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	05850513          	addi	a0,a0,88 # 60d8 <malloc+0x442>
      88:	00006097          	auipc	ra,0x6
      8c:	b50080e7          	jalr	-1200(ra) # 5bd8 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	7b6080e7          	jalr	1974(ra) # 5848 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	04850513          	addi	a0,a0,72 # 60f0 <malloc+0x45a>
      b0:	00005097          	auipc	ra,0x5
      b4:	7d8080e7          	jalr	2008(ra) # 5888 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	7b4080e7          	jalr	1972(ra) # 5870 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	04a50513          	addi	a0,a0,74 # 6110 <malloc+0x47a>
      ce:	00005097          	auipc	ra,0x5
      d2:	7ba080e7          	jalr	1978(ra) # 5888 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	01250513          	addi	a0,a0,18 # 60f8 <malloc+0x462>
      ee:	00006097          	auipc	ra,0x6
      f2:	aea080e7          	jalr	-1302(ra) # 5bd8 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	750080e7          	jalr	1872(ra) # 5848 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	01e50513          	addi	a0,a0,30 # 6120 <malloc+0x48a>
     10a:	00006097          	auipc	ra,0x6
     10e:	ace080e7          	jalr	-1330(ra) # 5bd8 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	734080e7          	jalr	1844(ra) # 5848 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	01c50513          	addi	a0,a0,28 # 6148 <malloc+0x4b2>
     134:	00005097          	auipc	ra,0x5
     138:	764080e7          	jalr	1892(ra) # 5898 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	00850513          	addi	a0,a0,8 # 6148 <malloc+0x4b2>
     148:	00005097          	auipc	ra,0x5
     14c:	740080e7          	jalr	1856(ra) # 5888 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	00458593          	addi	a1,a1,4 # 6158 <malloc+0x4c2>
     15c:	00005097          	auipc	ra,0x5
     160:	70c080e7          	jalr	1804(ra) # 5868 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	fe050513          	addi	a0,a0,-32 # 6148 <malloc+0x4b2>
     170:	00005097          	auipc	ra,0x5
     174:	718080e7          	jalr	1816(ra) # 5888 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	fe458593          	addi	a1,a1,-28 # 6160 <malloc+0x4ca>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	6e2080e7          	jalr	1762(ra) # 5868 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	fb450513          	addi	a0,a0,-76 # 6148 <malloc+0x4b2>
     19c:	00005097          	auipc	ra,0x5
     1a0:	6fc080e7          	jalr	1788(ra) # 5898 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	6ca080e7          	jalr	1738(ra) # 5870 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	6c0080e7          	jalr	1728(ra) # 5870 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	f9e50513          	addi	a0,a0,-98 # 6168 <malloc+0x4d2>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	a06080e7          	jalr	-1530(ra) # 5bd8 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	66c080e7          	jalr	1644(ra) # 5848 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	678080e7          	jalr	1656(ra) # 5888 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	658080e7          	jalr	1624(ra) # 5870 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	652080e7          	jalr	1618(ra) # 5898 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	cd450513          	addi	a0,a0,-812 # 5f50 <malloc+0x2ba>
     284:	00005097          	auipc	ra,0x5
     288:	614080e7          	jalr	1556(ra) # 5898 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	cc0a8a93          	addi	s5,s5,-832 # 5f50 <malloc+0x2ba>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	ab0a0a13          	addi	s4,s4,-1360 # bd48 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x267>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	5dc080e7          	jalr	1500(ra) # 5888 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	5aa080e7          	jalr	1450(ra) # 5868 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	596080e7          	jalr	1430(ra) # 5868 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	590080e7          	jalr	1424(ra) # 5870 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	5ae080e7          	jalr	1454(ra) # 5898 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	e7e50513          	addi	a0,a0,-386 # 6190 <malloc+0x4fa>
     31a:	00006097          	auipc	ra,0x6
     31e:	8be080e7          	jalr	-1858(ra) # 5bd8 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	524080e7          	jalr	1316(ra) # 5848 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	e7a50513          	addi	a0,a0,-390 # 61b0 <malloc+0x51a>
     33e:	00006097          	auipc	ra,0x6
     342:	89a080e7          	jalr	-1894(ra) # 5bd8 <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	500080e7          	jalr	1280(ra) # 5848 <exit>

0000000000000350 <copyin>:
{
     350:	715d                	addi	sp,sp,-80
     352:	e486                	sd	ra,72(sp)
     354:	e0a2                	sd	s0,64(sp)
     356:	fc26                	sd	s1,56(sp)
     358:	f84a                	sd	s2,48(sp)
     35a:	f44e                	sd	s3,40(sp)
     35c:	f052                	sd	s4,32(sp)
     35e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     360:	4785                	li	a5,1
     362:	07fe                	slli	a5,a5,0x1f
     364:	fcf43023          	sd	a5,-64(s0)
     368:	57fd                	li	a5,-1
     36a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     36e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     372:	00006a17          	auipc	s4,0x6
     376:	e56a0a13          	addi	s4,s4,-426 # 61c8 <malloc+0x532>
    uint64 addr = addrs[ai];
     37a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37e:	20100593          	li	a1,513
     382:	8552                	mv	a0,s4
     384:	00005097          	auipc	ra,0x5
     388:	504080e7          	jalr	1284(ra) # 5888 <open>
     38c:	84aa                	mv	s1,a0
    if(fd < 0){
     38e:	08054863          	bltz	a0,41e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     392:	6609                	lui	a2,0x2
     394:	85ce                	mv	a1,s3
     396:	00005097          	auipc	ra,0x5
     39a:	4d2080e7          	jalr	1234(ra) # 5868 <write>
    if(n >= 0){
     39e:	08055d63          	bgez	a0,438 <copyin+0xe8>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	4cc080e7          	jalr	1228(ra) # 5870 <close>
    unlink("copyin1");
     3ac:	8552                	mv	a0,s4
     3ae:	00005097          	auipc	ra,0x5
     3b2:	4ea080e7          	jalr	1258(ra) # 5898 <unlink>
    n = write(1, (char*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ce                	mv	a1,s3
     3ba:	4505                	li	a0,1
     3bc:	00005097          	auipc	ra,0x5
     3c0:	4ac080e7          	jalr	1196(ra) # 5868 <write>
    if(n > 0){
     3c4:	08a04963          	bgtz	a0,456 <copyin+0x106>
    if(pipe(fds) < 0){
     3c8:	fb840513          	addi	a0,s0,-72
     3cc:	00005097          	auipc	ra,0x5
     3d0:	48c080e7          	jalr	1164(ra) # 5858 <pipe>
     3d4:	0a054063          	bltz	a0,474 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d8:	6609                	lui	a2,0x2
     3da:	85ce                	mv	a1,s3
     3dc:	fbc42503          	lw	a0,-68(s0)
     3e0:	00005097          	auipc	ra,0x5
     3e4:	488080e7          	jalr	1160(ra) # 5868 <write>
    if(n > 0){
     3e8:	0aa04363          	bgtz	a0,48e <copyin+0x13e>
    close(fds[0]);
     3ec:	fb842503          	lw	a0,-72(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	480080e7          	jalr	1152(ra) # 5870 <close>
    close(fds[1]);
     3f8:	fbc42503          	lw	a0,-68(s0)
     3fc:	00005097          	auipc	ra,0x5
     400:	474080e7          	jalr	1140(ra) # 5870 <close>
  for(int ai = 0; ai < 2; ai++){
     404:	0921                	addi	s2,s2,8
     406:	fd040793          	addi	a5,s0,-48
     40a:	f6f918e3          	bne	s2,a5,37a <copyin+0x2a>
}
     40e:	60a6                	ld	ra,72(sp)
     410:	6406                	ld	s0,64(sp)
     412:	74e2                	ld	s1,56(sp)
     414:	7942                	ld	s2,48(sp)
     416:	79a2                	ld	s3,40(sp)
     418:	7a02                	ld	s4,32(sp)
     41a:	6161                	addi	sp,sp,80
     41c:	8082                	ret
      printf("open(copyin1) failed\n");
     41e:	00006517          	auipc	a0,0x6
     422:	db250513          	addi	a0,a0,-590 # 61d0 <malloc+0x53a>
     426:	00005097          	auipc	ra,0x5
     42a:	7b2080e7          	jalr	1970(ra) # 5bd8 <printf>
      exit(1);
     42e:	4505                	li	a0,1
     430:	00005097          	auipc	ra,0x5
     434:	418080e7          	jalr	1048(ra) # 5848 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     438:	862a                	mv	a2,a0
     43a:	85ce                	mv	a1,s3
     43c:	00006517          	auipc	a0,0x6
     440:	dac50513          	addi	a0,a0,-596 # 61e8 <malloc+0x552>
     444:	00005097          	auipc	ra,0x5
     448:	794080e7          	jalr	1940(ra) # 5bd8 <printf>
      exit(1);
     44c:	4505                	li	a0,1
     44e:	00005097          	auipc	ra,0x5
     452:	3fa080e7          	jalr	1018(ra) # 5848 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     456:	862a                	mv	a2,a0
     458:	85ce                	mv	a1,s3
     45a:	00006517          	auipc	a0,0x6
     45e:	dbe50513          	addi	a0,a0,-578 # 6218 <malloc+0x582>
     462:	00005097          	auipc	ra,0x5
     466:	776080e7          	jalr	1910(ra) # 5bd8 <printf>
      exit(1);
     46a:	4505                	li	a0,1
     46c:	00005097          	auipc	ra,0x5
     470:	3dc080e7          	jalr	988(ra) # 5848 <exit>
      printf("pipe() failed\n");
     474:	00006517          	auipc	a0,0x6
     478:	dd450513          	addi	a0,a0,-556 # 6248 <malloc+0x5b2>
     47c:	00005097          	auipc	ra,0x5
     480:	75c080e7          	jalr	1884(ra) # 5bd8 <printf>
      exit(1);
     484:	4505                	li	a0,1
     486:	00005097          	auipc	ra,0x5
     48a:	3c2080e7          	jalr	962(ra) # 5848 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48e:	862a                	mv	a2,a0
     490:	85ce                	mv	a1,s3
     492:	00006517          	auipc	a0,0x6
     496:	dc650513          	addi	a0,a0,-570 # 6258 <malloc+0x5c2>
     49a:	00005097          	auipc	ra,0x5
     49e:	73e080e7          	jalr	1854(ra) # 5bd8 <printf>
      exit(1);
     4a2:	4505                	li	a0,1
     4a4:	00005097          	auipc	ra,0x5
     4a8:	3a4080e7          	jalr	932(ra) # 5848 <exit>

00000000000004ac <copyout>:
{
     4ac:	711d                	addi	sp,sp,-96
     4ae:	ec86                	sd	ra,88(sp)
     4b0:	e8a2                	sd	s0,80(sp)
     4b2:	e4a6                	sd	s1,72(sp)
     4b4:	e0ca                	sd	s2,64(sp)
     4b6:	fc4e                	sd	s3,56(sp)
     4b8:	f852                	sd	s4,48(sp)
     4ba:	f456                	sd	s5,40(sp)
     4bc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4be:	4785                	li	a5,1
     4c0:	07fe                	slli	a5,a5,0x1f
     4c2:	faf43823          	sd	a5,-80(s0)
     4c6:	57fd                	li	a5,-1
     4c8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4cc:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4d0:	00006a17          	auipc	s4,0x6
     4d4:	db8a0a13          	addi	s4,s4,-584 # 6288 <malloc+0x5f2>
    n = write(fds[1], "x", 1);
     4d8:	00006a97          	auipc	s5,0x6
     4dc:	c88a8a93          	addi	s5,s5,-888 # 6160 <malloc+0x4ca>
    uint64 addr = addrs[ai];
     4e0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e4:	4581                	li	a1,0
     4e6:	8552                	mv	a0,s4
     4e8:	00005097          	auipc	ra,0x5
     4ec:	3a0080e7          	jalr	928(ra) # 5888 <open>
     4f0:	84aa                	mv	s1,a0
    if(fd < 0){
     4f2:	08054663          	bltz	a0,57e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f6:	6609                	lui	a2,0x2
     4f8:	85ce                	mv	a1,s3
     4fa:	00005097          	auipc	ra,0x5
     4fe:	366080e7          	jalr	870(ra) # 5860 <read>
    if(n > 0){
     502:	08a04b63          	bgtz	a0,598 <copyout+0xec>
    close(fd);
     506:	8526                	mv	a0,s1
     508:	00005097          	auipc	ra,0x5
     50c:	368080e7          	jalr	872(ra) # 5870 <close>
    if(pipe(fds) < 0){
     510:	fa840513          	addi	a0,s0,-88
     514:	00005097          	auipc	ra,0x5
     518:	344080e7          	jalr	836(ra) # 5858 <pipe>
     51c:	08054d63          	bltz	a0,5b6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     520:	4605                	li	a2,1
     522:	85d6                	mv	a1,s5
     524:	fac42503          	lw	a0,-84(s0)
     528:	00005097          	auipc	ra,0x5
     52c:	340080e7          	jalr	832(ra) # 5868 <write>
    if(n != 1){
     530:	4785                	li	a5,1
     532:	08f51f63          	bne	a0,a5,5d0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     536:	6609                	lui	a2,0x2
     538:	85ce                	mv	a1,s3
     53a:	fa842503          	lw	a0,-88(s0)
     53e:	00005097          	auipc	ra,0x5
     542:	322080e7          	jalr	802(ra) # 5860 <read>
    if(n > 0){
     546:	0aa04263          	bgtz	a0,5ea <copyout+0x13e>
    close(fds[0]);
     54a:	fa842503          	lw	a0,-88(s0)
     54e:	00005097          	auipc	ra,0x5
     552:	322080e7          	jalr	802(ra) # 5870 <close>
    close(fds[1]);
     556:	fac42503          	lw	a0,-84(s0)
     55a:	00005097          	auipc	ra,0x5
     55e:	316080e7          	jalr	790(ra) # 5870 <close>
  for(int ai = 0; ai < 2; ai++){
     562:	0921                	addi	s2,s2,8
     564:	fc040793          	addi	a5,s0,-64
     568:	f6f91ce3          	bne	s2,a5,4e0 <copyout+0x34>
}
     56c:	60e6                	ld	ra,88(sp)
     56e:	6446                	ld	s0,80(sp)
     570:	64a6                	ld	s1,72(sp)
     572:	6906                	ld	s2,64(sp)
     574:	79e2                	ld	s3,56(sp)
     576:	7a42                	ld	s4,48(sp)
     578:	7aa2                	ld	s5,40(sp)
     57a:	6125                	addi	sp,sp,96
     57c:	8082                	ret
      printf("open(README) failed\n");
     57e:	00006517          	auipc	a0,0x6
     582:	d1250513          	addi	a0,a0,-750 # 6290 <malloc+0x5fa>
     586:	00005097          	auipc	ra,0x5
     58a:	652080e7          	jalr	1618(ra) # 5bd8 <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	00005097          	auipc	ra,0x5
     594:	2b8080e7          	jalr	696(ra) # 5848 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     598:	862a                	mv	a2,a0
     59a:	85ce                	mv	a1,s3
     59c:	00006517          	auipc	a0,0x6
     5a0:	d0c50513          	addi	a0,a0,-756 # 62a8 <malloc+0x612>
     5a4:	00005097          	auipc	ra,0x5
     5a8:	634080e7          	jalr	1588(ra) # 5bd8 <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00005097          	auipc	ra,0x5
     5b2:	29a080e7          	jalr	666(ra) # 5848 <exit>
      printf("pipe() failed\n");
     5b6:	00006517          	auipc	a0,0x6
     5ba:	c9250513          	addi	a0,a0,-878 # 6248 <malloc+0x5b2>
     5be:	00005097          	auipc	ra,0x5
     5c2:	61a080e7          	jalr	1562(ra) # 5bd8 <printf>
      exit(1);
     5c6:	4505                	li	a0,1
     5c8:	00005097          	auipc	ra,0x5
     5cc:	280080e7          	jalr	640(ra) # 5848 <exit>
      printf("pipe write failed\n");
     5d0:	00006517          	auipc	a0,0x6
     5d4:	d0850513          	addi	a0,a0,-760 # 62d8 <malloc+0x642>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	600080e7          	jalr	1536(ra) # 5bd8 <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	266080e7          	jalr	614(ra) # 5848 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ea:	862a                	mv	a2,a0
     5ec:	85ce                	mv	a1,s3
     5ee:	00006517          	auipc	a0,0x6
     5f2:	d0250513          	addi	a0,a0,-766 # 62f0 <malloc+0x65a>
     5f6:	00005097          	auipc	ra,0x5
     5fa:	5e2080e7          	jalr	1506(ra) # 5bd8 <printf>
      exit(1);
     5fe:	4505                	li	a0,1
     600:	00005097          	auipc	ra,0x5
     604:	248080e7          	jalr	584(ra) # 5848 <exit>

0000000000000608 <truncate1>:
{
     608:	711d                	addi	sp,sp,-96
     60a:	ec86                	sd	ra,88(sp)
     60c:	e8a2                	sd	s0,80(sp)
     60e:	e4a6                	sd	s1,72(sp)
     610:	e0ca                	sd	s2,64(sp)
     612:	fc4e                	sd	s3,56(sp)
     614:	f852                	sd	s4,48(sp)
     616:	f456                	sd	s5,40(sp)
     618:	1080                	addi	s0,sp,96
     61a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     61c:	00006517          	auipc	a0,0x6
     620:	b2c50513          	addi	a0,a0,-1236 # 6148 <malloc+0x4b2>
     624:	00005097          	auipc	ra,0x5
     628:	274080e7          	jalr	628(ra) # 5898 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62c:	60100593          	li	a1,1537
     630:	00006517          	auipc	a0,0x6
     634:	b1850513          	addi	a0,a0,-1256 # 6148 <malloc+0x4b2>
     638:	00005097          	auipc	ra,0x5
     63c:	250080e7          	jalr	592(ra) # 5888 <open>
     640:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     642:	4611                	li	a2,4
     644:	00006597          	auipc	a1,0x6
     648:	b1458593          	addi	a1,a1,-1260 # 6158 <malloc+0x4c2>
     64c:	00005097          	auipc	ra,0x5
     650:	21c080e7          	jalr	540(ra) # 5868 <write>
  close(fd1);
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	21a080e7          	jalr	538(ra) # 5870 <close>
  int fd2 = open("truncfile", O_RDONLY);
     65e:	4581                	li	a1,0
     660:	00006517          	auipc	a0,0x6
     664:	ae850513          	addi	a0,a0,-1304 # 6148 <malloc+0x4b2>
     668:	00005097          	auipc	ra,0x5
     66c:	220080e7          	jalr	544(ra) # 5888 <open>
     670:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     672:	02000613          	li	a2,32
     676:	fa040593          	addi	a1,s0,-96
     67a:	00005097          	auipc	ra,0x5
     67e:	1e6080e7          	jalr	486(ra) # 5860 <read>
  if(n != 4){
     682:	4791                	li	a5,4
     684:	0cf51e63          	bne	a0,a5,760 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     688:	40100593          	li	a1,1025
     68c:	00006517          	auipc	a0,0x6
     690:	abc50513          	addi	a0,a0,-1348 # 6148 <malloc+0x4b2>
     694:	00005097          	auipc	ra,0x5
     698:	1f4080e7          	jalr	500(ra) # 5888 <open>
     69c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     69e:	4581                	li	a1,0
     6a0:	00006517          	auipc	a0,0x6
     6a4:	aa850513          	addi	a0,a0,-1368 # 6148 <malloc+0x4b2>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	1e0080e7          	jalr	480(ra) # 5888 <open>
     6b0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6b2:	02000613          	li	a2,32
     6b6:	fa040593          	addi	a1,s0,-96
     6ba:	00005097          	auipc	ra,0x5
     6be:	1a6080e7          	jalr	422(ra) # 5860 <read>
     6c2:	8a2a                	mv	s4,a0
  if(n != 0){
     6c4:	ed4d                	bnez	a0,77e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	190080e7          	jalr	400(ra) # 5860 <read>
     6d8:	8a2a                	mv	s4,a0
  if(n != 0){
     6da:	e971                	bnez	a0,7ae <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6dc:	4619                	li	a2,6
     6de:	00006597          	auipc	a1,0x6
     6e2:	ca258593          	addi	a1,a1,-862 # 6380 <malloc+0x6ea>
     6e6:	854e                	mv	a0,s3
     6e8:	00005097          	auipc	ra,0x5
     6ec:	180080e7          	jalr	384(ra) # 5868 <write>
  n = read(fd3, buf, sizeof(buf));
     6f0:	02000613          	li	a2,32
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	854a                	mv	a0,s2
     6fa:	00005097          	auipc	ra,0x5
     6fe:	166080e7          	jalr	358(ra) # 5860 <read>
  if(n != 6){
     702:	4799                	li	a5,6
     704:	0cf51d63          	bne	a0,a5,7de <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     708:	02000613          	li	a2,32
     70c:	fa040593          	addi	a1,s0,-96
     710:	8526                	mv	a0,s1
     712:	00005097          	auipc	ra,0x5
     716:	14e080e7          	jalr	334(ra) # 5860 <read>
  if(n != 2){
     71a:	4789                	li	a5,2
     71c:	0ef51063          	bne	a0,a5,7fc <truncate1+0x1f4>
  unlink("truncfile");
     720:	00006517          	auipc	a0,0x6
     724:	a2850513          	addi	a0,a0,-1496 # 6148 <malloc+0x4b2>
     728:	00005097          	auipc	ra,0x5
     72c:	170080e7          	jalr	368(ra) # 5898 <unlink>
  close(fd1);
     730:	854e                	mv	a0,s3
     732:	00005097          	auipc	ra,0x5
     736:	13e080e7          	jalr	318(ra) # 5870 <close>
  close(fd2);
     73a:	8526                	mv	a0,s1
     73c:	00005097          	auipc	ra,0x5
     740:	134080e7          	jalr	308(ra) # 5870 <close>
  close(fd3);
     744:	854a                	mv	a0,s2
     746:	00005097          	auipc	ra,0x5
     74a:	12a080e7          	jalr	298(ra) # 5870 <close>
}
     74e:	60e6                	ld	ra,88(sp)
     750:	6446                	ld	s0,80(sp)
     752:	64a6                	ld	s1,72(sp)
     754:	6906                	ld	s2,64(sp)
     756:	79e2                	ld	s3,56(sp)
     758:	7a42                	ld	s4,48(sp)
     75a:	7aa2                	ld	s5,40(sp)
     75c:	6125                	addi	sp,sp,96
     75e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     760:	862a                	mv	a2,a0
     762:	85d6                	mv	a1,s5
     764:	00006517          	auipc	a0,0x6
     768:	bbc50513          	addi	a0,a0,-1092 # 6320 <malloc+0x68a>
     76c:	00005097          	auipc	ra,0x5
     770:	46c080e7          	jalr	1132(ra) # 5bd8 <printf>
    exit(1);
     774:	4505                	li	a0,1
     776:	00005097          	auipc	ra,0x5
     77a:	0d2080e7          	jalr	210(ra) # 5848 <exit>
    printf("aaa fd3=%d\n", fd3);
     77e:	85ca                	mv	a1,s2
     780:	00006517          	auipc	a0,0x6
     784:	bc050513          	addi	a0,a0,-1088 # 6340 <malloc+0x6aa>
     788:	00005097          	auipc	ra,0x5
     78c:	450080e7          	jalr	1104(ra) # 5bd8 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     790:	8652                	mv	a2,s4
     792:	85d6                	mv	a1,s5
     794:	00006517          	auipc	a0,0x6
     798:	bbc50513          	addi	a0,a0,-1092 # 6350 <malloc+0x6ba>
     79c:	00005097          	auipc	ra,0x5
     7a0:	43c080e7          	jalr	1084(ra) # 5bd8 <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	0a2080e7          	jalr	162(ra) # 5848 <exit>
    printf("bbb fd2=%d\n", fd2);
     7ae:	85a6                	mv	a1,s1
     7b0:	00006517          	auipc	a0,0x6
     7b4:	bc050513          	addi	a0,a0,-1088 # 6370 <malloc+0x6da>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	420080e7          	jalr	1056(ra) # 5bd8 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7c0:	8652                	mv	a2,s4
     7c2:	85d6                	mv	a1,s5
     7c4:	00006517          	auipc	a0,0x6
     7c8:	b8c50513          	addi	a0,a0,-1140 # 6350 <malloc+0x6ba>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	40c080e7          	jalr	1036(ra) # 5bd8 <printf>
    exit(1);
     7d4:	4505                	li	a0,1
     7d6:	00005097          	auipc	ra,0x5
     7da:	072080e7          	jalr	114(ra) # 5848 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7de:	862a                	mv	a2,a0
     7e0:	85d6                	mv	a1,s5
     7e2:	00006517          	auipc	a0,0x6
     7e6:	ba650513          	addi	a0,a0,-1114 # 6388 <malloc+0x6f2>
     7ea:	00005097          	auipc	ra,0x5
     7ee:	3ee080e7          	jalr	1006(ra) # 5bd8 <printf>
    exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00005097          	auipc	ra,0x5
     7f8:	054080e7          	jalr	84(ra) # 5848 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     7fc:	862a                	mv	a2,a0
     7fe:	85d6                	mv	a1,s5
     800:	00006517          	auipc	a0,0x6
     804:	ba850513          	addi	a0,a0,-1112 # 63a8 <malloc+0x712>
     808:	00005097          	auipc	ra,0x5
     80c:	3d0080e7          	jalr	976(ra) # 5bd8 <printf>
    exit(1);
     810:	4505                	li	a0,1
     812:	00005097          	auipc	ra,0x5
     816:	036080e7          	jalr	54(ra) # 5848 <exit>

000000000000081a <writetest>:
{
     81a:	7139                	addi	sp,sp,-64
     81c:	fc06                	sd	ra,56(sp)
     81e:	f822                	sd	s0,48(sp)
     820:	f426                	sd	s1,40(sp)
     822:	f04a                	sd	s2,32(sp)
     824:	ec4e                	sd	s3,24(sp)
     826:	e852                	sd	s4,16(sp)
     828:	e456                	sd	s5,8(sp)
     82a:	e05a                	sd	s6,0(sp)
     82c:	0080                	addi	s0,sp,64
     82e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     830:	20200593          	li	a1,514
     834:	00006517          	auipc	a0,0x6
     838:	b9450513          	addi	a0,a0,-1132 # 63c8 <malloc+0x732>
     83c:	00005097          	auipc	ra,0x5
     840:	04c080e7          	jalr	76(ra) # 5888 <open>
  if(fd < 0){
     844:	0a054d63          	bltz	a0,8fe <writetest+0xe4>
     848:	892a                	mv	s2,a0
     84a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     84c:	00006997          	auipc	s3,0x6
     850:	ba498993          	addi	s3,s3,-1116 # 63f0 <malloc+0x75a>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     854:	00006a97          	auipc	s5,0x6
     858:	bd4a8a93          	addi	s5,s5,-1068 # 6428 <malloc+0x792>
  for(i = 0; i < N; i++){
     85c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	4629                	li	a2,10
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00005097          	auipc	ra,0x5
     86a:	002080e7          	jalr	2(ra) # 5868 <write>
     86e:	47a9                	li	a5,10
     870:	0af51563          	bne	a0,a5,91a <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85d6                	mv	a1,s5
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	fee080e7          	jalr	-18(ra) # 5868 <write>
     882:	47a9                	li	a5,10
     884:	0af51a63          	bne	a0,a5,938 <writetest+0x11e>
  for(i = 0; i < N; i++){
     888:	2485                	addiw	s1,s1,1
     88a:	fd449be3          	bne	s1,s4,860 <writetest+0x46>
  close(fd);
     88e:	854a                	mv	a0,s2
     890:	00005097          	auipc	ra,0x5
     894:	fe0080e7          	jalr	-32(ra) # 5870 <close>
  fd = open("small", O_RDONLY);
     898:	4581                	li	a1,0
     89a:	00006517          	auipc	a0,0x6
     89e:	b2e50513          	addi	a0,a0,-1234 # 63c8 <malloc+0x732>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	fe6080e7          	jalr	-26(ra) # 5888 <open>
     8aa:	84aa                	mv	s1,a0
  if(fd < 0){
     8ac:	0a054563          	bltz	a0,956 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8b0:	7d000613          	li	a2,2000
     8b4:	0000b597          	auipc	a1,0xb
     8b8:	49458593          	addi	a1,a1,1172 # bd48 <buf>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	fa4080e7          	jalr	-92(ra) # 5860 <read>
  if(i != N*SZ*2){
     8c4:	7d000793          	li	a5,2000
     8c8:	0af51563          	bne	a0,a5,972 <writetest+0x158>
  close(fd);
     8cc:	8526                	mv	a0,s1
     8ce:	00005097          	auipc	ra,0x5
     8d2:	fa2080e7          	jalr	-94(ra) # 5870 <close>
  if(unlink("small") < 0){
     8d6:	00006517          	auipc	a0,0x6
     8da:	af250513          	addi	a0,a0,-1294 # 63c8 <malloc+0x732>
     8de:	00005097          	auipc	ra,0x5
     8e2:	fba080e7          	jalr	-70(ra) # 5898 <unlink>
     8e6:	0a054463          	bltz	a0,98e <writetest+0x174>
}
     8ea:	70e2                	ld	ra,56(sp)
     8ec:	7442                	ld	s0,48(sp)
     8ee:	74a2                	ld	s1,40(sp)
     8f0:	7902                	ld	s2,32(sp)
     8f2:	69e2                	ld	s3,24(sp)
     8f4:	6a42                	ld	s4,16(sp)
     8f6:	6aa2                	ld	s5,8(sp)
     8f8:	6b02                	ld	s6,0(sp)
     8fa:	6121                	addi	sp,sp,64
     8fc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     8fe:	85da                	mv	a1,s6
     900:	00006517          	auipc	a0,0x6
     904:	ad050513          	addi	a0,a0,-1328 # 63d0 <malloc+0x73a>
     908:	00005097          	auipc	ra,0x5
     90c:	2d0080e7          	jalr	720(ra) # 5bd8 <printf>
    exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	f36080e7          	jalr	-202(ra) # 5848 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     91a:	8626                	mv	a2,s1
     91c:	85da                	mv	a1,s6
     91e:	00006517          	auipc	a0,0x6
     922:	ae250513          	addi	a0,a0,-1310 # 6400 <malloc+0x76a>
     926:	00005097          	auipc	ra,0x5
     92a:	2b2080e7          	jalr	690(ra) # 5bd8 <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	f18080e7          	jalr	-232(ra) # 5848 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     938:	8626                	mv	a2,s1
     93a:	85da                	mv	a1,s6
     93c:	00006517          	auipc	a0,0x6
     940:	afc50513          	addi	a0,a0,-1284 # 6438 <malloc+0x7a2>
     944:	00005097          	auipc	ra,0x5
     948:	294080e7          	jalr	660(ra) # 5bd8 <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	efa080e7          	jalr	-262(ra) # 5848 <exit>
    printf("%s: error: open small failed!\n", s);
     956:	85da                	mv	a1,s6
     958:	00006517          	auipc	a0,0x6
     95c:	b0850513          	addi	a0,a0,-1272 # 6460 <malloc+0x7ca>
     960:	00005097          	auipc	ra,0x5
     964:	278080e7          	jalr	632(ra) # 5bd8 <printf>
    exit(1);
     968:	4505                	li	a0,1
     96a:	00005097          	auipc	ra,0x5
     96e:	ede080e7          	jalr	-290(ra) # 5848 <exit>
    printf("%s: read failed\n", s);
     972:	85da                	mv	a1,s6
     974:	00006517          	auipc	a0,0x6
     978:	b0c50513          	addi	a0,a0,-1268 # 6480 <malloc+0x7ea>
     97c:	00005097          	auipc	ra,0x5
     980:	25c080e7          	jalr	604(ra) # 5bd8 <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	ec2080e7          	jalr	-318(ra) # 5848 <exit>
    printf("%s: unlink small failed\n", s);
     98e:	85da                	mv	a1,s6
     990:	00006517          	auipc	a0,0x6
     994:	b0850513          	addi	a0,a0,-1272 # 6498 <malloc+0x802>
     998:	00005097          	auipc	ra,0x5
     99c:	240080e7          	jalr	576(ra) # 5bd8 <printf>
    exit(1);
     9a0:	4505                	li	a0,1
     9a2:	00005097          	auipc	ra,0x5
     9a6:	ea6080e7          	jalr	-346(ra) # 5848 <exit>

00000000000009aa <writebig>:
{
     9aa:	7139                	addi	sp,sp,-64
     9ac:	fc06                	sd	ra,56(sp)
     9ae:	f822                	sd	s0,48(sp)
     9b0:	f426                	sd	s1,40(sp)
     9b2:	f04a                	sd	s2,32(sp)
     9b4:	ec4e                	sd	s3,24(sp)
     9b6:	e852                	sd	s4,16(sp)
     9b8:	e456                	sd	s5,8(sp)
     9ba:	0080                	addi	s0,sp,64
     9bc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9be:	20200593          	li	a1,514
     9c2:	00006517          	auipc	a0,0x6
     9c6:	af650513          	addi	a0,a0,-1290 # 64b8 <malloc+0x822>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	ebe080e7          	jalr	-322(ra) # 5888 <open>
     9d2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9d4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9d6:	0000b917          	auipc	s2,0xb
     9da:	37290913          	addi	s2,s2,882 # bd48 <buf>
  for(i = 0; i < MAXFILE; i++){
     9de:	10c00a13          	li	s4,268
  if(fd < 0){
     9e2:	06054c63          	bltz	a0,a5a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9e6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9ea:	40000613          	li	a2,1024
     9ee:	85ca                	mv	a1,s2
     9f0:	854e                	mv	a0,s3
     9f2:	00005097          	auipc	ra,0x5
     9f6:	e76080e7          	jalr	-394(ra) # 5868 <write>
     9fa:	40000793          	li	a5,1024
     9fe:	06f51c63          	bne	a0,a5,a76 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a02:	2485                	addiw	s1,s1,1
     a04:	ff4491e3          	bne	s1,s4,9e6 <writebig+0x3c>
  close(fd);
     a08:	854e                	mv	a0,s3
     a0a:	00005097          	auipc	ra,0x5
     a0e:	e66080e7          	jalr	-410(ra) # 5870 <close>
  fd = open("big", O_RDONLY);
     a12:	4581                	li	a1,0
     a14:	00006517          	auipc	a0,0x6
     a18:	aa450513          	addi	a0,a0,-1372 # 64b8 <malloc+0x822>
     a1c:	00005097          	auipc	ra,0x5
     a20:	e6c080e7          	jalr	-404(ra) # 5888 <open>
     a24:	89aa                	mv	s3,a0
  n = 0;
     a26:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a28:	0000b917          	auipc	s2,0xb
     a2c:	32090913          	addi	s2,s2,800 # bd48 <buf>
  if(fd < 0){
     a30:	06054263          	bltz	a0,a94 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a34:	40000613          	li	a2,1024
     a38:	85ca                	mv	a1,s2
     a3a:	854e                	mv	a0,s3
     a3c:	00005097          	auipc	ra,0x5
     a40:	e24080e7          	jalr	-476(ra) # 5860 <read>
    if(i == 0){
     a44:	c535                	beqz	a0,ab0 <writebig+0x106>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	0af51f63          	bne	a0,a5,b08 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0c969a63          	bne	a3,s1,b26 <writebig+0x17c>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	bff1                	j	a34 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00006517          	auipc	a0,0x6
     a60:	a6450513          	addi	a0,a0,-1436 # 64c0 <malloc+0x82a>
     a64:	00005097          	auipc	ra,0x5
     a68:	174080e7          	jalr	372(ra) # 5bd8 <printf>
    exit(1);
     a6c:	4505                	li	a0,1
     a6e:	00005097          	auipc	ra,0x5
     a72:	dda080e7          	jalr	-550(ra) # 5848 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a76:	8626                	mv	a2,s1
     a78:	85d6                	mv	a1,s5
     a7a:	00006517          	auipc	a0,0x6
     a7e:	a6650513          	addi	a0,a0,-1434 # 64e0 <malloc+0x84a>
     a82:	00005097          	auipc	ra,0x5
     a86:	156080e7          	jalr	342(ra) # 5bd8 <printf>
      exit(1);
     a8a:	4505                	li	a0,1
     a8c:	00005097          	auipc	ra,0x5
     a90:	dbc080e7          	jalr	-580(ra) # 5848 <exit>
    printf("%s: error: open big failed!\n", s);
     a94:	85d6                	mv	a1,s5
     a96:	00006517          	auipc	a0,0x6
     a9a:	a7250513          	addi	a0,a0,-1422 # 6508 <malloc+0x872>
     a9e:	00005097          	auipc	ra,0x5
     aa2:	13a080e7          	jalr	314(ra) # 5bd8 <printf>
    exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00005097          	auipc	ra,0x5
     aac:	da0080e7          	jalr	-608(ra) # 5848 <exit>
      if(n == MAXFILE - 1){
     ab0:	10b00793          	li	a5,267
     ab4:	02f48a63          	beq	s1,a5,ae8 <writebig+0x13e>
  close(fd);
     ab8:	854e                	mv	a0,s3
     aba:	00005097          	auipc	ra,0x5
     abe:	db6080e7          	jalr	-586(ra) # 5870 <close>
  if(unlink("big") < 0){
     ac2:	00006517          	auipc	a0,0x6
     ac6:	9f650513          	addi	a0,a0,-1546 # 64b8 <malloc+0x822>
     aca:	00005097          	auipc	ra,0x5
     ace:	dce080e7          	jalr	-562(ra) # 5898 <unlink>
     ad2:	06054963          	bltz	a0,b44 <writebig+0x19a>
}
     ad6:	70e2                	ld	ra,56(sp)
     ad8:	7442                	ld	s0,48(sp)
     ada:	74a2                	ld	s1,40(sp)
     adc:	7902                	ld	s2,32(sp)
     ade:	69e2                	ld	s3,24(sp)
     ae0:	6a42                	ld	s4,16(sp)
     ae2:	6aa2                	ld	s5,8(sp)
     ae4:	6121                	addi	sp,sp,64
     ae6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ae8:	10b00613          	li	a2,267
     aec:	85d6                	mv	a1,s5
     aee:	00006517          	auipc	a0,0x6
     af2:	a3a50513          	addi	a0,a0,-1478 # 6528 <malloc+0x892>
     af6:	00005097          	auipc	ra,0x5
     afa:	0e2080e7          	jalr	226(ra) # 5bd8 <printf>
        exit(1);
     afe:	4505                	li	a0,1
     b00:	00005097          	auipc	ra,0x5
     b04:	d48080e7          	jalr	-696(ra) # 5848 <exit>
      printf("%s: read failed %d\n", s, i);
     b08:	862a                	mv	a2,a0
     b0a:	85d6                	mv	a1,s5
     b0c:	00006517          	auipc	a0,0x6
     b10:	a4450513          	addi	a0,a0,-1468 # 6550 <malloc+0x8ba>
     b14:	00005097          	auipc	ra,0x5
     b18:	0c4080e7          	jalr	196(ra) # 5bd8 <printf>
      exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00005097          	auipc	ra,0x5
     b22:	d2a080e7          	jalr	-726(ra) # 5848 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b26:	8626                	mv	a2,s1
     b28:	85d6                	mv	a1,s5
     b2a:	00006517          	auipc	a0,0x6
     b2e:	a3e50513          	addi	a0,a0,-1474 # 6568 <malloc+0x8d2>
     b32:	00005097          	auipc	ra,0x5
     b36:	0a6080e7          	jalr	166(ra) # 5bd8 <printf>
      exit(1);
     b3a:	4505                	li	a0,1
     b3c:	00005097          	auipc	ra,0x5
     b40:	d0c080e7          	jalr	-756(ra) # 5848 <exit>
    printf("%s: unlink big failed\n", s);
     b44:	85d6                	mv	a1,s5
     b46:	00006517          	auipc	a0,0x6
     b4a:	a4a50513          	addi	a0,a0,-1462 # 6590 <malloc+0x8fa>
     b4e:	00005097          	auipc	ra,0x5
     b52:	08a080e7          	jalr	138(ra) # 5bd8 <printf>
    exit(1);
     b56:	4505                	li	a0,1
     b58:	00005097          	auipc	ra,0x5
     b5c:	cf0080e7          	jalr	-784(ra) # 5848 <exit>

0000000000000b60 <unlinkread>:
{
     b60:	7179                	addi	sp,sp,-48
     b62:	f406                	sd	ra,40(sp)
     b64:	f022                	sd	s0,32(sp)
     b66:	ec26                	sd	s1,24(sp)
     b68:	e84a                	sd	s2,16(sp)
     b6a:	e44e                	sd	s3,8(sp)
     b6c:	1800                	addi	s0,sp,48
     b6e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b70:	20200593          	li	a1,514
     b74:	00005517          	auipc	a0,0x5
     b78:	36c50513          	addi	a0,a0,876 # 5ee0 <malloc+0x24a>
     b7c:	00005097          	auipc	ra,0x5
     b80:	d0c080e7          	jalr	-756(ra) # 5888 <open>
  if(fd < 0){
     b84:	0e054563          	bltz	a0,c6e <unlinkread+0x10e>
     b88:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b8a:	4615                	li	a2,5
     b8c:	00006597          	auipc	a1,0x6
     b90:	a3c58593          	addi	a1,a1,-1476 # 65c8 <malloc+0x932>
     b94:	00005097          	auipc	ra,0x5
     b98:	cd4080e7          	jalr	-812(ra) # 5868 <write>
  close(fd);
     b9c:	8526                	mv	a0,s1
     b9e:	00005097          	auipc	ra,0x5
     ba2:	cd2080e7          	jalr	-814(ra) # 5870 <close>
  fd = open("unlinkread", O_RDWR);
     ba6:	4589                	li	a1,2
     ba8:	00005517          	auipc	a0,0x5
     bac:	33850513          	addi	a0,a0,824 # 5ee0 <malloc+0x24a>
     bb0:	00005097          	auipc	ra,0x5
     bb4:	cd8080e7          	jalr	-808(ra) # 5888 <open>
     bb8:	84aa                	mv	s1,a0
  if(fd < 0){
     bba:	0c054863          	bltz	a0,c8a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bbe:	00005517          	auipc	a0,0x5
     bc2:	32250513          	addi	a0,a0,802 # 5ee0 <malloc+0x24a>
     bc6:	00005097          	auipc	ra,0x5
     bca:	cd2080e7          	jalr	-814(ra) # 5898 <unlink>
     bce:	ed61                	bnez	a0,ca6 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd0:	20200593          	li	a1,514
     bd4:	00005517          	auipc	a0,0x5
     bd8:	30c50513          	addi	a0,a0,780 # 5ee0 <malloc+0x24a>
     bdc:	00005097          	auipc	ra,0x5
     be0:	cac080e7          	jalr	-852(ra) # 5888 <open>
     be4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be6:	460d                	li	a2,3
     be8:	00006597          	auipc	a1,0x6
     bec:	a2858593          	addi	a1,a1,-1496 # 6610 <malloc+0x97a>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	c78080e7          	jalr	-904(ra) # 5868 <write>
  close(fd1);
     bf8:	854a                	mv	a0,s2
     bfa:	00005097          	auipc	ra,0x5
     bfe:	c76080e7          	jalr	-906(ra) # 5870 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c02:	660d                	lui	a2,0x3
     c04:	0000b597          	auipc	a1,0xb
     c08:	14458593          	addi	a1,a1,324 # bd48 <buf>
     c0c:	8526                	mv	a0,s1
     c0e:	00005097          	auipc	ra,0x5
     c12:	c52080e7          	jalr	-942(ra) # 5860 <read>
     c16:	4795                	li	a5,5
     c18:	0af51563          	bne	a0,a5,cc2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c1c:	0000b717          	auipc	a4,0xb
     c20:	12c74703          	lbu	a4,300(a4) # bd48 <buf>
     c24:	06800793          	li	a5,104
     c28:	0af71b63          	bne	a4,a5,cde <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c2c:	4629                	li	a2,10
     c2e:	0000b597          	auipc	a1,0xb
     c32:	11a58593          	addi	a1,a1,282 # bd48 <buf>
     c36:	8526                	mv	a0,s1
     c38:	00005097          	auipc	ra,0x5
     c3c:	c30080e7          	jalr	-976(ra) # 5868 <write>
     c40:	47a9                	li	a5,10
     c42:	0af51c63          	bne	a0,a5,cfa <unlinkread+0x19a>
  close(fd);
     c46:	8526                	mv	a0,s1
     c48:	00005097          	auipc	ra,0x5
     c4c:	c28080e7          	jalr	-984(ra) # 5870 <close>
  unlink("unlinkread");
     c50:	00005517          	auipc	a0,0x5
     c54:	29050513          	addi	a0,a0,656 # 5ee0 <malloc+0x24a>
     c58:	00005097          	auipc	ra,0x5
     c5c:	c40080e7          	jalr	-960(ra) # 5898 <unlink>
}
     c60:	70a2                	ld	ra,40(sp)
     c62:	7402                	ld	s0,32(sp)
     c64:	64e2                	ld	s1,24(sp)
     c66:	6942                	ld	s2,16(sp)
     c68:	69a2                	ld	s3,8(sp)
     c6a:	6145                	addi	sp,sp,48
     c6c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c6e:	85ce                	mv	a1,s3
     c70:	00006517          	auipc	a0,0x6
     c74:	93850513          	addi	a0,a0,-1736 # 65a8 <malloc+0x912>
     c78:	00005097          	auipc	ra,0x5
     c7c:	f60080e7          	jalr	-160(ra) # 5bd8 <printf>
    exit(1);
     c80:	4505                	li	a0,1
     c82:	00005097          	auipc	ra,0x5
     c86:	bc6080e7          	jalr	-1082(ra) # 5848 <exit>
    printf("%s: open unlinkread failed\n", s);
     c8a:	85ce                	mv	a1,s3
     c8c:	00006517          	auipc	a0,0x6
     c90:	94450513          	addi	a0,a0,-1724 # 65d0 <malloc+0x93a>
     c94:	00005097          	auipc	ra,0x5
     c98:	f44080e7          	jalr	-188(ra) # 5bd8 <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00005097          	auipc	ra,0x5
     ca2:	baa080e7          	jalr	-1110(ra) # 5848 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ca6:	85ce                	mv	a1,s3
     ca8:	00006517          	auipc	a0,0x6
     cac:	94850513          	addi	a0,a0,-1720 # 65f0 <malloc+0x95a>
     cb0:	00005097          	auipc	ra,0x5
     cb4:	f28080e7          	jalr	-216(ra) # 5bd8 <printf>
    exit(1);
     cb8:	4505                	li	a0,1
     cba:	00005097          	auipc	ra,0x5
     cbe:	b8e080e7          	jalr	-1138(ra) # 5848 <exit>
    printf("%s: unlinkread read failed", s);
     cc2:	85ce                	mv	a1,s3
     cc4:	00006517          	auipc	a0,0x6
     cc8:	95450513          	addi	a0,a0,-1708 # 6618 <malloc+0x982>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	f0c080e7          	jalr	-244(ra) # 5bd8 <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	b72080e7          	jalr	-1166(ra) # 5848 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cde:	85ce                	mv	a1,s3
     ce0:	00006517          	auipc	a0,0x6
     ce4:	95850513          	addi	a0,a0,-1704 # 6638 <malloc+0x9a2>
     ce8:	00005097          	auipc	ra,0x5
     cec:	ef0080e7          	jalr	-272(ra) # 5bd8 <printf>
    exit(1);
     cf0:	4505                	li	a0,1
     cf2:	00005097          	auipc	ra,0x5
     cf6:	b56080e7          	jalr	-1194(ra) # 5848 <exit>
    printf("%s: unlinkread write failed\n", s);
     cfa:	85ce                	mv	a1,s3
     cfc:	00006517          	auipc	a0,0x6
     d00:	95c50513          	addi	a0,a0,-1700 # 6658 <malloc+0x9c2>
     d04:	00005097          	auipc	ra,0x5
     d08:	ed4080e7          	jalr	-300(ra) # 5bd8 <printf>
    exit(1);
     d0c:	4505                	li	a0,1
     d0e:	00005097          	auipc	ra,0x5
     d12:	b3a080e7          	jalr	-1222(ra) # 5848 <exit>

0000000000000d16 <linktest>:
{
     d16:	1101                	addi	sp,sp,-32
     d18:	ec06                	sd	ra,24(sp)
     d1a:	e822                	sd	s0,16(sp)
     d1c:	e426                	sd	s1,8(sp)
     d1e:	e04a                	sd	s2,0(sp)
     d20:	1000                	addi	s0,sp,32
     d22:	892a                	mv	s2,a0
  unlink("lf1");
     d24:	00006517          	auipc	a0,0x6
     d28:	95450513          	addi	a0,a0,-1708 # 6678 <malloc+0x9e2>
     d2c:	00005097          	auipc	ra,0x5
     d30:	b6c080e7          	jalr	-1172(ra) # 5898 <unlink>
  unlink("lf2");
     d34:	00006517          	auipc	a0,0x6
     d38:	94c50513          	addi	a0,a0,-1716 # 6680 <malloc+0x9ea>
     d3c:	00005097          	auipc	ra,0x5
     d40:	b5c080e7          	jalr	-1188(ra) # 5898 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d44:	20200593          	li	a1,514
     d48:	00006517          	auipc	a0,0x6
     d4c:	93050513          	addi	a0,a0,-1744 # 6678 <malloc+0x9e2>
     d50:	00005097          	auipc	ra,0x5
     d54:	b38080e7          	jalr	-1224(ra) # 5888 <open>
  if(fd < 0){
     d58:	10054763          	bltz	a0,e66 <linktest+0x150>
     d5c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d5e:	4615                	li	a2,5
     d60:	00006597          	auipc	a1,0x6
     d64:	86858593          	addi	a1,a1,-1944 # 65c8 <malloc+0x932>
     d68:	00005097          	auipc	ra,0x5
     d6c:	b00080e7          	jalr	-1280(ra) # 5868 <write>
     d70:	4795                	li	a5,5
     d72:	10f51863          	bne	a0,a5,e82 <linktest+0x16c>
  close(fd);
     d76:	8526                	mv	a0,s1
     d78:	00005097          	auipc	ra,0x5
     d7c:	af8080e7          	jalr	-1288(ra) # 5870 <close>
  if(link("lf1", "lf2") < 0){
     d80:	00006597          	auipc	a1,0x6
     d84:	90058593          	addi	a1,a1,-1792 # 6680 <malloc+0x9ea>
     d88:	00006517          	auipc	a0,0x6
     d8c:	8f050513          	addi	a0,a0,-1808 # 6678 <malloc+0x9e2>
     d90:	00005097          	auipc	ra,0x5
     d94:	b18080e7          	jalr	-1256(ra) # 58a8 <link>
     d98:	10054363          	bltz	a0,e9e <linktest+0x188>
  unlink("lf1");
     d9c:	00006517          	auipc	a0,0x6
     da0:	8dc50513          	addi	a0,a0,-1828 # 6678 <malloc+0x9e2>
     da4:	00005097          	auipc	ra,0x5
     da8:	af4080e7          	jalr	-1292(ra) # 5898 <unlink>
  if(open("lf1", 0) >= 0){
     dac:	4581                	li	a1,0
     dae:	00006517          	auipc	a0,0x6
     db2:	8ca50513          	addi	a0,a0,-1846 # 6678 <malloc+0x9e2>
     db6:	00005097          	auipc	ra,0x5
     dba:	ad2080e7          	jalr	-1326(ra) # 5888 <open>
     dbe:	0e055e63          	bgez	a0,eba <linktest+0x1a4>
  fd = open("lf2", 0);
     dc2:	4581                	li	a1,0
     dc4:	00006517          	auipc	a0,0x6
     dc8:	8bc50513          	addi	a0,a0,-1860 # 6680 <malloc+0x9ea>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	abc080e7          	jalr	-1348(ra) # 5888 <open>
     dd4:	84aa                	mv	s1,a0
  if(fd < 0){
     dd6:	10054063          	bltz	a0,ed6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dda:	660d                	lui	a2,0x3
     ddc:	0000b597          	auipc	a1,0xb
     de0:	f6c58593          	addi	a1,a1,-148 # bd48 <buf>
     de4:	00005097          	auipc	ra,0x5
     de8:	a7c080e7          	jalr	-1412(ra) # 5860 <read>
     dec:	4795                	li	a5,5
     dee:	10f51263          	bne	a0,a5,ef2 <linktest+0x1dc>
  close(fd);
     df2:	8526                	mv	a0,s1
     df4:	00005097          	auipc	ra,0x5
     df8:	a7c080e7          	jalr	-1412(ra) # 5870 <close>
  if(link("lf2", "lf2") >= 0){
     dfc:	00006597          	auipc	a1,0x6
     e00:	88458593          	addi	a1,a1,-1916 # 6680 <malloc+0x9ea>
     e04:	852e                	mv	a0,a1
     e06:	00005097          	auipc	ra,0x5
     e0a:	aa2080e7          	jalr	-1374(ra) # 58a8 <link>
     e0e:	10055063          	bgez	a0,f0e <linktest+0x1f8>
  unlink("lf2");
     e12:	00006517          	auipc	a0,0x6
     e16:	86e50513          	addi	a0,a0,-1938 # 6680 <malloc+0x9ea>
     e1a:	00005097          	auipc	ra,0x5
     e1e:	a7e080e7          	jalr	-1410(ra) # 5898 <unlink>
  if(link("lf2", "lf1") >= 0){
     e22:	00006597          	auipc	a1,0x6
     e26:	85658593          	addi	a1,a1,-1962 # 6678 <malloc+0x9e2>
     e2a:	00006517          	auipc	a0,0x6
     e2e:	85650513          	addi	a0,a0,-1962 # 6680 <malloc+0x9ea>
     e32:	00005097          	auipc	ra,0x5
     e36:	a76080e7          	jalr	-1418(ra) # 58a8 <link>
     e3a:	0e055863          	bgez	a0,f2a <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e3e:	00006597          	auipc	a1,0x6
     e42:	83a58593          	addi	a1,a1,-1990 # 6678 <malloc+0x9e2>
     e46:	00006517          	auipc	a0,0x6
     e4a:	94250513          	addi	a0,a0,-1726 # 6788 <malloc+0xaf2>
     e4e:	00005097          	auipc	ra,0x5
     e52:	a5a080e7          	jalr	-1446(ra) # 58a8 <link>
     e56:	0e055863          	bgez	a0,f46 <linktest+0x230>
}
     e5a:	60e2                	ld	ra,24(sp)
     e5c:	6442                	ld	s0,16(sp)
     e5e:	64a2                	ld	s1,8(sp)
     e60:	6902                	ld	s2,0(sp)
     e62:	6105                	addi	sp,sp,32
     e64:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e66:	85ca                	mv	a1,s2
     e68:	00006517          	auipc	a0,0x6
     e6c:	82050513          	addi	a0,a0,-2016 # 6688 <malloc+0x9f2>
     e70:	00005097          	auipc	ra,0x5
     e74:	d68080e7          	jalr	-664(ra) # 5bd8 <printf>
    exit(1);
     e78:	4505                	li	a0,1
     e7a:	00005097          	auipc	ra,0x5
     e7e:	9ce080e7          	jalr	-1586(ra) # 5848 <exit>
    printf("%s: write lf1 failed\n", s);
     e82:	85ca                	mv	a1,s2
     e84:	00006517          	auipc	a0,0x6
     e88:	81c50513          	addi	a0,a0,-2020 # 66a0 <malloc+0xa0a>
     e8c:	00005097          	auipc	ra,0x5
     e90:	d4c080e7          	jalr	-692(ra) # 5bd8 <printf>
    exit(1);
     e94:	4505                	li	a0,1
     e96:	00005097          	auipc	ra,0x5
     e9a:	9b2080e7          	jalr	-1614(ra) # 5848 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e9e:	85ca                	mv	a1,s2
     ea0:	00006517          	auipc	a0,0x6
     ea4:	81850513          	addi	a0,a0,-2024 # 66b8 <malloc+0xa22>
     ea8:	00005097          	auipc	ra,0x5
     eac:	d30080e7          	jalr	-720(ra) # 5bd8 <printf>
    exit(1);
     eb0:	4505                	li	a0,1
     eb2:	00005097          	auipc	ra,0x5
     eb6:	996080e7          	jalr	-1642(ra) # 5848 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     eba:	85ca                	mv	a1,s2
     ebc:	00006517          	auipc	a0,0x6
     ec0:	81c50513          	addi	a0,a0,-2020 # 66d8 <malloc+0xa42>
     ec4:	00005097          	auipc	ra,0x5
     ec8:	d14080e7          	jalr	-748(ra) # 5bd8 <printf>
    exit(1);
     ecc:	4505                	li	a0,1
     ece:	00005097          	auipc	ra,0x5
     ed2:	97a080e7          	jalr	-1670(ra) # 5848 <exit>
    printf("%s: open lf2 failed\n", s);
     ed6:	85ca                	mv	a1,s2
     ed8:	00006517          	auipc	a0,0x6
     edc:	83050513          	addi	a0,a0,-2000 # 6708 <malloc+0xa72>
     ee0:	00005097          	auipc	ra,0x5
     ee4:	cf8080e7          	jalr	-776(ra) # 5bd8 <printf>
    exit(1);
     ee8:	4505                	li	a0,1
     eea:	00005097          	auipc	ra,0x5
     eee:	95e080e7          	jalr	-1698(ra) # 5848 <exit>
    printf("%s: read lf2 failed\n", s);
     ef2:	85ca                	mv	a1,s2
     ef4:	00006517          	auipc	a0,0x6
     ef8:	82c50513          	addi	a0,a0,-2004 # 6720 <malloc+0xa8a>
     efc:	00005097          	auipc	ra,0x5
     f00:	cdc080e7          	jalr	-804(ra) # 5bd8 <printf>
    exit(1);
     f04:	4505                	li	a0,1
     f06:	00005097          	auipc	ra,0x5
     f0a:	942080e7          	jalr	-1726(ra) # 5848 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f0e:	85ca                	mv	a1,s2
     f10:	00006517          	auipc	a0,0x6
     f14:	82850513          	addi	a0,a0,-2008 # 6738 <malloc+0xaa2>
     f18:	00005097          	auipc	ra,0x5
     f1c:	cc0080e7          	jalr	-832(ra) # 5bd8 <printf>
    exit(1);
     f20:	4505                	li	a0,1
     f22:	00005097          	auipc	ra,0x5
     f26:	926080e7          	jalr	-1754(ra) # 5848 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     f2a:	85ca                	mv	a1,s2
     f2c:	00006517          	auipc	a0,0x6
     f30:	83450513          	addi	a0,a0,-1996 # 6760 <malloc+0xaca>
     f34:	00005097          	auipc	ra,0x5
     f38:	ca4080e7          	jalr	-860(ra) # 5bd8 <printf>
    exit(1);
     f3c:	4505                	li	a0,1
     f3e:	00005097          	auipc	ra,0x5
     f42:	90a080e7          	jalr	-1782(ra) # 5848 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f46:	85ca                	mv	a1,s2
     f48:	00006517          	auipc	a0,0x6
     f4c:	84850513          	addi	a0,a0,-1976 # 6790 <malloc+0xafa>
     f50:	00005097          	auipc	ra,0x5
     f54:	c88080e7          	jalr	-888(ra) # 5bd8 <printf>
    exit(1);
     f58:	4505                	li	a0,1
     f5a:	00005097          	auipc	ra,0x5
     f5e:	8ee080e7          	jalr	-1810(ra) # 5848 <exit>

0000000000000f62 <validatetest>:
{
     f62:	7139                	addi	sp,sp,-64
     f64:	fc06                	sd	ra,56(sp)
     f66:	f822                	sd	s0,48(sp)
     f68:	f426                	sd	s1,40(sp)
     f6a:	f04a                	sd	s2,32(sp)
     f6c:	ec4e                	sd	s3,24(sp)
     f6e:	e852                	sd	s4,16(sp)
     f70:	e456                	sd	s5,8(sp)
     f72:	e05a                	sd	s6,0(sp)
     f74:	0080                	addi	s0,sp,64
     f76:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     f78:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
     f7a:	00006997          	auipc	s3,0x6
     f7e:	83698993          	addi	s3,s3,-1994 # 67b0 <malloc+0xb1a>
     f82:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     f84:	6a85                	lui	s5,0x1
     f86:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
     f8a:	85a6                	mv	a1,s1
     f8c:	854e                	mv	a0,s3
     f8e:	00005097          	auipc	ra,0x5
     f92:	91a080e7          	jalr	-1766(ra) # 58a8 <link>
     f96:	01251f63          	bne	a0,s2,fb4 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     f9a:	94d6                	add	s1,s1,s5
     f9c:	ff4497e3          	bne	s1,s4,f8a <validatetest+0x28>
}
     fa0:	70e2                	ld	ra,56(sp)
     fa2:	7442                	ld	s0,48(sp)
     fa4:	74a2                	ld	s1,40(sp)
     fa6:	7902                	ld	s2,32(sp)
     fa8:	69e2                	ld	s3,24(sp)
     faa:	6a42                	ld	s4,16(sp)
     fac:	6aa2                	ld	s5,8(sp)
     fae:	6b02                	ld	s6,0(sp)
     fb0:	6121                	addi	sp,sp,64
     fb2:	8082                	ret
      printf("%s: link should not succeed\n", s);
     fb4:	85da                	mv	a1,s6
     fb6:	00006517          	auipc	a0,0x6
     fba:	80a50513          	addi	a0,a0,-2038 # 67c0 <malloc+0xb2a>
     fbe:	00005097          	auipc	ra,0x5
     fc2:	c1a080e7          	jalr	-998(ra) # 5bd8 <printf>
      exit(1);
     fc6:	4505                	li	a0,1
     fc8:	00005097          	auipc	ra,0x5
     fcc:	880080e7          	jalr	-1920(ra) # 5848 <exit>

0000000000000fd0 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
     fd0:	7179                	addi	sp,sp,-48
     fd2:	f406                	sd	ra,40(sp)
     fd4:	f022                	sd	s0,32(sp)
     fd6:	ec26                	sd	s1,24(sp)
     fd8:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
     fda:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
     fde:	00007497          	auipc	s1,0x7
     fe2:	5424b483          	ld	s1,1346(s1) # 8520 <__SDATA_BEGIN__>
     fe6:	fd840593          	addi	a1,s0,-40
     fea:	8526                	mv	a0,s1
     fec:	00005097          	auipc	ra,0x5
     ff0:	894080e7          	jalr	-1900(ra) # 5880 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
     ff4:	8526                	mv	a0,s1
     ff6:	00005097          	auipc	ra,0x5
     ffa:	862080e7          	jalr	-1950(ra) # 5858 <pipe>

  exit(0);
     ffe:	4501                	li	a0,0
    1000:	00005097          	auipc	ra,0x5
    1004:	848080e7          	jalr	-1976(ra) # 5848 <exit>

0000000000001008 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1008:	7139                	addi	sp,sp,-64
    100a:	fc06                	sd	ra,56(sp)
    100c:	f822                	sd	s0,48(sp)
    100e:	f426                	sd	s1,40(sp)
    1010:	f04a                	sd	s2,32(sp)
    1012:	ec4e                	sd	s3,24(sp)
    1014:	0080                	addi	s0,sp,64
    1016:	64b1                	lui	s1,0xc
    1018:	35048493          	addi	s1,s1,848 # c350 <buf+0x608>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    101c:	597d                	li	s2,-1
    101e:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1022:	00005997          	auipc	s3,0x5
    1026:	0ce98993          	addi	s3,s3,206 # 60f0 <malloc+0x45a>
    argv[0] = (char*)0xffffffff;
    102a:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    102e:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1032:	fc040593          	addi	a1,s0,-64
    1036:	854e                	mv	a0,s3
    1038:	00005097          	auipc	ra,0x5
    103c:	848080e7          	jalr	-1976(ra) # 5880 <exec>
  for(int i = 0; i < 50000; i++){
    1040:	34fd                	addiw	s1,s1,-1
    1042:	f4e5                	bnez	s1,102a <badarg+0x22>
  }
  
  exit(0);
    1044:	4501                	li	a0,0
    1046:	00005097          	auipc	ra,0x5
    104a:	802080e7          	jalr	-2046(ra) # 5848 <exit>

000000000000104e <copyinstr2>:
{
    104e:	7155                	addi	sp,sp,-208
    1050:	e586                	sd	ra,200(sp)
    1052:	e1a2                	sd	s0,192(sp)
    1054:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1056:	f6840793          	addi	a5,s0,-152
    105a:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    105e:	07800713          	li	a4,120
    1062:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1066:	0785                	addi	a5,a5,1
    1068:	fed79de3          	bne	a5,a3,1062 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    106c:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1070:	f6840513          	addi	a0,s0,-152
    1074:	00005097          	auipc	ra,0x5
    1078:	824080e7          	jalr	-2012(ra) # 5898 <unlink>
  if(ret != -1){
    107c:	57fd                	li	a5,-1
    107e:	0ef51063          	bne	a0,a5,115e <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    1082:	20100593          	li	a1,513
    1086:	f6840513          	addi	a0,s0,-152
    108a:	00004097          	auipc	ra,0x4
    108e:	7fe080e7          	jalr	2046(ra) # 5888 <open>
  if(fd != -1){
    1092:	57fd                	li	a5,-1
    1094:	0ef51563          	bne	a0,a5,117e <copyinstr2+0x130>
  ret = link(b, b);
    1098:	f6840593          	addi	a1,s0,-152
    109c:	852e                	mv	a0,a1
    109e:	00005097          	auipc	ra,0x5
    10a2:	80a080e7          	jalr	-2038(ra) # 58a8 <link>
  if(ret != -1){
    10a6:	57fd                	li	a5,-1
    10a8:	0ef51b63          	bne	a0,a5,119e <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    10ac:	00007797          	auipc	a5,0x7
    10b0:	8e478793          	addi	a5,a5,-1820 # 7990 <malloc+0x1cfa>
    10b4:	f4f43c23          	sd	a5,-168(s0)
    10b8:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    10bc:	f5840593          	addi	a1,s0,-168
    10c0:	f6840513          	addi	a0,s0,-152
    10c4:	00004097          	auipc	ra,0x4
    10c8:	7bc080e7          	jalr	1980(ra) # 5880 <exec>
  if(ret != -1){
    10cc:	57fd                	li	a5,-1
    10ce:	0ef51963          	bne	a0,a5,11c0 <copyinstr2+0x172>
  int pid = fork();
    10d2:	00004097          	auipc	ra,0x4
    10d6:	76e080e7          	jalr	1902(ra) # 5840 <fork>
  if(pid < 0){
    10da:	10054363          	bltz	a0,11e0 <copyinstr2+0x192>
  if(pid == 0){
    10de:	12051463          	bnez	a0,1206 <copyinstr2+0x1b8>
    10e2:	00007797          	auipc	a5,0x7
    10e6:	54e78793          	addi	a5,a5,1358 # 8630 <big.1275>
    10ea:	00008697          	auipc	a3,0x8
    10ee:	54668693          	addi	a3,a3,1350 # 9630 <__global_pointer$+0x910>
      big[i] = 'x';
    10f2:	07800713          	li	a4,120
    10f6:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    10fa:	0785                	addi	a5,a5,1
    10fc:	fed79de3          	bne	a5,a3,10f6 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1100:	00008797          	auipc	a5,0x8
    1104:	52078823          	sb	zero,1328(a5) # 9630 <__global_pointer$+0x910>
    char *args2[] = { big, big, big, 0 };
    1108:	00007797          	auipc	a5,0x7
    110c:	01878793          	addi	a5,a5,24 # 8120 <malloc+0x248a>
    1110:	6390                	ld	a2,0(a5)
    1112:	6794                	ld	a3,8(a5)
    1114:	6b98                	ld	a4,16(a5)
    1116:	6f9c                	ld	a5,24(a5)
    1118:	f2c43823          	sd	a2,-208(s0)
    111c:	f2d43c23          	sd	a3,-200(s0)
    1120:	f4e43023          	sd	a4,-192(s0)
    1124:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1128:	f3040593          	addi	a1,s0,-208
    112c:	00005517          	auipc	a0,0x5
    1130:	fc450513          	addi	a0,a0,-60 # 60f0 <malloc+0x45a>
    1134:	00004097          	auipc	ra,0x4
    1138:	74c080e7          	jalr	1868(ra) # 5880 <exec>
    if(ret != -1){
    113c:	57fd                	li	a5,-1
    113e:	0af50e63          	beq	a0,a5,11fa <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1142:	55fd                	li	a1,-1
    1144:	00005517          	auipc	a0,0x5
    1148:	72450513          	addi	a0,a0,1828 # 6868 <malloc+0xbd2>
    114c:	00005097          	auipc	ra,0x5
    1150:	a8c080e7          	jalr	-1396(ra) # 5bd8 <printf>
      exit(1);
    1154:	4505                	li	a0,1
    1156:	00004097          	auipc	ra,0x4
    115a:	6f2080e7          	jalr	1778(ra) # 5848 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    115e:	862a                	mv	a2,a0
    1160:	f6840593          	addi	a1,s0,-152
    1164:	00005517          	auipc	a0,0x5
    1168:	67c50513          	addi	a0,a0,1660 # 67e0 <malloc+0xb4a>
    116c:	00005097          	auipc	ra,0x5
    1170:	a6c080e7          	jalr	-1428(ra) # 5bd8 <printf>
    exit(1);
    1174:	4505                	li	a0,1
    1176:	00004097          	auipc	ra,0x4
    117a:	6d2080e7          	jalr	1746(ra) # 5848 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    117e:	862a                	mv	a2,a0
    1180:	f6840593          	addi	a1,s0,-152
    1184:	00005517          	auipc	a0,0x5
    1188:	67c50513          	addi	a0,a0,1660 # 6800 <malloc+0xb6a>
    118c:	00005097          	auipc	ra,0x5
    1190:	a4c080e7          	jalr	-1460(ra) # 5bd8 <printf>
    exit(1);
    1194:	4505                	li	a0,1
    1196:	00004097          	auipc	ra,0x4
    119a:	6b2080e7          	jalr	1714(ra) # 5848 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    119e:	86aa                	mv	a3,a0
    11a0:	f6840613          	addi	a2,s0,-152
    11a4:	85b2                	mv	a1,a2
    11a6:	00005517          	auipc	a0,0x5
    11aa:	67a50513          	addi	a0,a0,1658 # 6820 <malloc+0xb8a>
    11ae:	00005097          	auipc	ra,0x5
    11b2:	a2a080e7          	jalr	-1494(ra) # 5bd8 <printf>
    exit(1);
    11b6:	4505                	li	a0,1
    11b8:	00004097          	auipc	ra,0x4
    11bc:	690080e7          	jalr	1680(ra) # 5848 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    11c0:	567d                	li	a2,-1
    11c2:	f6840593          	addi	a1,s0,-152
    11c6:	00005517          	auipc	a0,0x5
    11ca:	68250513          	addi	a0,a0,1666 # 6848 <malloc+0xbb2>
    11ce:	00005097          	auipc	ra,0x5
    11d2:	a0a080e7          	jalr	-1526(ra) # 5bd8 <printf>
    exit(1);
    11d6:	4505                	li	a0,1
    11d8:	00004097          	auipc	ra,0x4
    11dc:	670080e7          	jalr	1648(ra) # 5848 <exit>
    printf("fork failed\n");
    11e0:	00006517          	auipc	a0,0x6
    11e4:	ae850513          	addi	a0,a0,-1304 # 6cc8 <malloc+0x1032>
    11e8:	00005097          	auipc	ra,0x5
    11ec:	9f0080e7          	jalr	-1552(ra) # 5bd8 <printf>
    exit(1);
    11f0:	4505                	li	a0,1
    11f2:	00004097          	auipc	ra,0x4
    11f6:	656080e7          	jalr	1622(ra) # 5848 <exit>
    exit(747); // OK
    11fa:	2eb00513          	li	a0,747
    11fe:	00004097          	auipc	ra,0x4
    1202:	64a080e7          	jalr	1610(ra) # 5848 <exit>
  int st = 0;
    1206:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    120a:	f5440513          	addi	a0,s0,-172
    120e:	00004097          	auipc	ra,0x4
    1212:	642080e7          	jalr	1602(ra) # 5850 <wait>
  if(st != 747){
    1216:	f5442703          	lw	a4,-172(s0)
    121a:	2eb00793          	li	a5,747
    121e:	00f71663          	bne	a4,a5,122a <copyinstr2+0x1dc>
}
    1222:	60ae                	ld	ra,200(sp)
    1224:	640e                	ld	s0,192(sp)
    1226:	6169                	addi	sp,sp,208
    1228:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    122a:	00005517          	auipc	a0,0x5
    122e:	66650513          	addi	a0,a0,1638 # 6890 <malloc+0xbfa>
    1232:	00005097          	auipc	ra,0x5
    1236:	9a6080e7          	jalr	-1626(ra) # 5bd8 <printf>
    exit(1);
    123a:	4505                	li	a0,1
    123c:	00004097          	auipc	ra,0x4
    1240:	60c080e7          	jalr	1548(ra) # 5848 <exit>

0000000000001244 <truncate3>:
{
    1244:	7159                	addi	sp,sp,-112
    1246:	f486                	sd	ra,104(sp)
    1248:	f0a2                	sd	s0,96(sp)
    124a:	eca6                	sd	s1,88(sp)
    124c:	e8ca                	sd	s2,80(sp)
    124e:	e4ce                	sd	s3,72(sp)
    1250:	e0d2                	sd	s4,64(sp)
    1252:	fc56                	sd	s5,56(sp)
    1254:	1880                	addi	s0,sp,112
    1256:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    1258:	60100593          	li	a1,1537
    125c:	00005517          	auipc	a0,0x5
    1260:	eec50513          	addi	a0,a0,-276 # 6148 <malloc+0x4b2>
    1264:	00004097          	auipc	ra,0x4
    1268:	624080e7          	jalr	1572(ra) # 5888 <open>
    126c:	00004097          	auipc	ra,0x4
    1270:	604080e7          	jalr	1540(ra) # 5870 <close>
  pid = fork();
    1274:	00004097          	auipc	ra,0x4
    1278:	5cc080e7          	jalr	1484(ra) # 5840 <fork>
  if(pid < 0){
    127c:	08054063          	bltz	a0,12fc <truncate3+0xb8>
  if(pid == 0){
    1280:	e969                	bnez	a0,1352 <truncate3+0x10e>
    1282:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1286:	00005a17          	auipc	s4,0x5
    128a:	ec2a0a13          	addi	s4,s4,-318 # 6148 <malloc+0x4b2>
      int n = write(fd, "1234567890", 10);
    128e:	00005a97          	auipc	s5,0x5
    1292:	662a8a93          	addi	s5,s5,1634 # 68f0 <malloc+0xc5a>
      int fd = open("truncfile", O_WRONLY);
    1296:	4585                	li	a1,1
    1298:	8552                	mv	a0,s4
    129a:	00004097          	auipc	ra,0x4
    129e:	5ee080e7          	jalr	1518(ra) # 5888 <open>
    12a2:	84aa                	mv	s1,a0
      if(fd < 0){
    12a4:	06054a63          	bltz	a0,1318 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    12a8:	4629                	li	a2,10
    12aa:	85d6                	mv	a1,s5
    12ac:	00004097          	auipc	ra,0x4
    12b0:	5bc080e7          	jalr	1468(ra) # 5868 <write>
      if(n != 10){
    12b4:	47a9                	li	a5,10
    12b6:	06f51f63          	bne	a0,a5,1334 <truncate3+0xf0>
      close(fd);
    12ba:	8526                	mv	a0,s1
    12bc:	00004097          	auipc	ra,0x4
    12c0:	5b4080e7          	jalr	1460(ra) # 5870 <close>
      fd = open("truncfile", O_RDONLY);
    12c4:	4581                	li	a1,0
    12c6:	8552                	mv	a0,s4
    12c8:	00004097          	auipc	ra,0x4
    12cc:	5c0080e7          	jalr	1472(ra) # 5888 <open>
    12d0:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    12d2:	02000613          	li	a2,32
    12d6:	f9840593          	addi	a1,s0,-104
    12da:	00004097          	auipc	ra,0x4
    12de:	586080e7          	jalr	1414(ra) # 5860 <read>
      close(fd);
    12e2:	8526                	mv	a0,s1
    12e4:	00004097          	auipc	ra,0x4
    12e8:	58c080e7          	jalr	1420(ra) # 5870 <close>
    for(int i = 0; i < 100; i++){
    12ec:	39fd                	addiw	s3,s3,-1
    12ee:	fa0994e3          	bnez	s3,1296 <truncate3+0x52>
    exit(0);
    12f2:	4501                	li	a0,0
    12f4:	00004097          	auipc	ra,0x4
    12f8:	554080e7          	jalr	1364(ra) # 5848 <exit>
    printf("%s: fork failed\n", s);
    12fc:	85ca                	mv	a1,s2
    12fe:	00005517          	auipc	a0,0x5
    1302:	5c250513          	addi	a0,a0,1474 # 68c0 <malloc+0xc2a>
    1306:	00005097          	auipc	ra,0x5
    130a:	8d2080e7          	jalr	-1838(ra) # 5bd8 <printf>
    exit(1);
    130e:	4505                	li	a0,1
    1310:	00004097          	auipc	ra,0x4
    1314:	538080e7          	jalr	1336(ra) # 5848 <exit>
        printf("%s: open failed\n", s);
    1318:	85ca                	mv	a1,s2
    131a:	00005517          	auipc	a0,0x5
    131e:	5be50513          	addi	a0,a0,1470 # 68d8 <malloc+0xc42>
    1322:	00005097          	auipc	ra,0x5
    1326:	8b6080e7          	jalr	-1866(ra) # 5bd8 <printf>
        exit(1);
    132a:	4505                	li	a0,1
    132c:	00004097          	auipc	ra,0x4
    1330:	51c080e7          	jalr	1308(ra) # 5848 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1334:	862a                	mv	a2,a0
    1336:	85ca                	mv	a1,s2
    1338:	00005517          	auipc	a0,0x5
    133c:	5c850513          	addi	a0,a0,1480 # 6900 <malloc+0xc6a>
    1340:	00005097          	auipc	ra,0x5
    1344:	898080e7          	jalr	-1896(ra) # 5bd8 <printf>
        exit(1);
    1348:	4505                	li	a0,1
    134a:	00004097          	auipc	ra,0x4
    134e:	4fe080e7          	jalr	1278(ra) # 5848 <exit>
    1352:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1356:	00005a17          	auipc	s4,0x5
    135a:	df2a0a13          	addi	s4,s4,-526 # 6148 <malloc+0x4b2>
    int n = write(fd, "xxx", 3);
    135e:	00005a97          	auipc	s5,0x5
    1362:	5c2a8a93          	addi	s5,s5,1474 # 6920 <malloc+0xc8a>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1366:	60100593          	li	a1,1537
    136a:	8552                	mv	a0,s4
    136c:	00004097          	auipc	ra,0x4
    1370:	51c080e7          	jalr	1308(ra) # 5888 <open>
    1374:	84aa                	mv	s1,a0
    if(fd < 0){
    1376:	04054763          	bltz	a0,13c4 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    137a:	460d                	li	a2,3
    137c:	85d6                	mv	a1,s5
    137e:	00004097          	auipc	ra,0x4
    1382:	4ea080e7          	jalr	1258(ra) # 5868 <write>
    if(n != 3){
    1386:	478d                	li	a5,3
    1388:	04f51c63          	bne	a0,a5,13e0 <truncate3+0x19c>
    close(fd);
    138c:	8526                	mv	a0,s1
    138e:	00004097          	auipc	ra,0x4
    1392:	4e2080e7          	jalr	1250(ra) # 5870 <close>
  for(int i = 0; i < 150; i++){
    1396:	39fd                	addiw	s3,s3,-1
    1398:	fc0997e3          	bnez	s3,1366 <truncate3+0x122>
  wait(&xstatus);
    139c:	fbc40513          	addi	a0,s0,-68
    13a0:	00004097          	auipc	ra,0x4
    13a4:	4b0080e7          	jalr	1200(ra) # 5850 <wait>
  unlink("truncfile");
    13a8:	00005517          	auipc	a0,0x5
    13ac:	da050513          	addi	a0,a0,-608 # 6148 <malloc+0x4b2>
    13b0:	00004097          	auipc	ra,0x4
    13b4:	4e8080e7          	jalr	1256(ra) # 5898 <unlink>
  exit(xstatus);
    13b8:	fbc42503          	lw	a0,-68(s0)
    13bc:	00004097          	auipc	ra,0x4
    13c0:	48c080e7          	jalr	1164(ra) # 5848 <exit>
      printf("%s: open failed\n", s);
    13c4:	85ca                	mv	a1,s2
    13c6:	00005517          	auipc	a0,0x5
    13ca:	51250513          	addi	a0,a0,1298 # 68d8 <malloc+0xc42>
    13ce:	00005097          	auipc	ra,0x5
    13d2:	80a080e7          	jalr	-2038(ra) # 5bd8 <printf>
      exit(1);
    13d6:	4505                	li	a0,1
    13d8:	00004097          	auipc	ra,0x4
    13dc:	470080e7          	jalr	1136(ra) # 5848 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    13e0:	862a                	mv	a2,a0
    13e2:	85ca                	mv	a1,s2
    13e4:	00005517          	auipc	a0,0x5
    13e8:	54450513          	addi	a0,a0,1348 # 6928 <malloc+0xc92>
    13ec:	00004097          	auipc	ra,0x4
    13f0:	7ec080e7          	jalr	2028(ra) # 5bd8 <printf>
      exit(1);
    13f4:	4505                	li	a0,1
    13f6:	00004097          	auipc	ra,0x4
    13fa:	452080e7          	jalr	1106(ra) # 5848 <exit>

00000000000013fe <exectest>:
{
    13fe:	715d                	addi	sp,sp,-80
    1400:	e486                	sd	ra,72(sp)
    1402:	e0a2                	sd	s0,64(sp)
    1404:	fc26                	sd	s1,56(sp)
    1406:	f84a                	sd	s2,48(sp)
    1408:	0880                	addi	s0,sp,80
    140a:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    140c:	00005797          	auipc	a5,0x5
    1410:	ce478793          	addi	a5,a5,-796 # 60f0 <malloc+0x45a>
    1414:	fcf43023          	sd	a5,-64(s0)
    1418:	00005797          	auipc	a5,0x5
    141c:	53078793          	addi	a5,a5,1328 # 6948 <malloc+0xcb2>
    1420:	fcf43423          	sd	a5,-56(s0)
    1424:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1428:	00005517          	auipc	a0,0x5
    142c:	52850513          	addi	a0,a0,1320 # 6950 <malloc+0xcba>
    1430:	00004097          	auipc	ra,0x4
    1434:	468080e7          	jalr	1128(ra) # 5898 <unlink>
  pid = fork();
    1438:	00004097          	auipc	ra,0x4
    143c:	408080e7          	jalr	1032(ra) # 5840 <fork>
  if(pid < 0) {
    1440:	04054663          	bltz	a0,148c <exectest+0x8e>
    1444:	84aa                	mv	s1,a0
  if(pid == 0) {
    1446:	e959                	bnez	a0,14dc <exectest+0xde>
    close(1);
    1448:	4505                	li	a0,1
    144a:	00004097          	auipc	ra,0x4
    144e:	426080e7          	jalr	1062(ra) # 5870 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1452:	20100593          	li	a1,513
    1456:	00005517          	auipc	a0,0x5
    145a:	4fa50513          	addi	a0,a0,1274 # 6950 <malloc+0xcba>
    145e:	00004097          	auipc	ra,0x4
    1462:	42a080e7          	jalr	1066(ra) # 5888 <open>
    if(fd < 0) {
    1466:	04054163          	bltz	a0,14a8 <exectest+0xaa>
    if(fd != 1) {
    146a:	4785                	li	a5,1
    146c:	04f50c63          	beq	a0,a5,14c4 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    1470:	85ca                	mv	a1,s2
    1472:	00005517          	auipc	a0,0x5
    1476:	4fe50513          	addi	a0,a0,1278 # 6970 <malloc+0xcda>
    147a:	00004097          	auipc	ra,0x4
    147e:	75e080e7          	jalr	1886(ra) # 5bd8 <printf>
      exit(1);
    1482:	4505                	li	a0,1
    1484:	00004097          	auipc	ra,0x4
    1488:	3c4080e7          	jalr	964(ra) # 5848 <exit>
     printf("%s: fork failed\n", s);
    148c:	85ca                	mv	a1,s2
    148e:	00005517          	auipc	a0,0x5
    1492:	43250513          	addi	a0,a0,1074 # 68c0 <malloc+0xc2a>
    1496:	00004097          	auipc	ra,0x4
    149a:	742080e7          	jalr	1858(ra) # 5bd8 <printf>
     exit(1);
    149e:	4505                	li	a0,1
    14a0:	00004097          	auipc	ra,0x4
    14a4:	3a8080e7          	jalr	936(ra) # 5848 <exit>
      printf("%s: create failed\n", s);
    14a8:	85ca                	mv	a1,s2
    14aa:	00005517          	auipc	a0,0x5
    14ae:	4ae50513          	addi	a0,a0,1198 # 6958 <malloc+0xcc2>
    14b2:	00004097          	auipc	ra,0x4
    14b6:	726080e7          	jalr	1830(ra) # 5bd8 <printf>
      exit(1);
    14ba:	4505                	li	a0,1
    14bc:	00004097          	auipc	ra,0x4
    14c0:	38c080e7          	jalr	908(ra) # 5848 <exit>
    if(exec("echo", echoargv) < 0){
    14c4:	fc040593          	addi	a1,s0,-64
    14c8:	00005517          	auipc	a0,0x5
    14cc:	c2850513          	addi	a0,a0,-984 # 60f0 <malloc+0x45a>
    14d0:	00004097          	auipc	ra,0x4
    14d4:	3b0080e7          	jalr	944(ra) # 5880 <exec>
    14d8:	02054163          	bltz	a0,14fa <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    14dc:	fdc40513          	addi	a0,s0,-36
    14e0:	00004097          	auipc	ra,0x4
    14e4:	370080e7          	jalr	880(ra) # 5850 <wait>
    14e8:	02951763          	bne	a0,s1,1516 <exectest+0x118>
  if(xstatus != 0)
    14ec:	fdc42503          	lw	a0,-36(s0)
    14f0:	cd0d                	beqz	a0,152a <exectest+0x12c>
    exit(xstatus);
    14f2:	00004097          	auipc	ra,0x4
    14f6:	356080e7          	jalr	854(ra) # 5848 <exit>
      printf("%s: exec echo failed\n", s);
    14fa:	85ca                	mv	a1,s2
    14fc:	00005517          	auipc	a0,0x5
    1500:	48450513          	addi	a0,a0,1156 # 6980 <malloc+0xcea>
    1504:	00004097          	auipc	ra,0x4
    1508:	6d4080e7          	jalr	1748(ra) # 5bd8 <printf>
      exit(1);
    150c:	4505                	li	a0,1
    150e:	00004097          	auipc	ra,0x4
    1512:	33a080e7          	jalr	826(ra) # 5848 <exit>
    printf("%s: wait failed!\n", s);
    1516:	85ca                	mv	a1,s2
    1518:	00005517          	auipc	a0,0x5
    151c:	48050513          	addi	a0,a0,1152 # 6998 <malloc+0xd02>
    1520:	00004097          	auipc	ra,0x4
    1524:	6b8080e7          	jalr	1720(ra) # 5bd8 <printf>
    1528:	b7d1                	j	14ec <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    152a:	4581                	li	a1,0
    152c:	00005517          	auipc	a0,0x5
    1530:	42450513          	addi	a0,a0,1060 # 6950 <malloc+0xcba>
    1534:	00004097          	auipc	ra,0x4
    1538:	354080e7          	jalr	852(ra) # 5888 <open>
  if(fd < 0) {
    153c:	02054a63          	bltz	a0,1570 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1540:	4609                	li	a2,2
    1542:	fb840593          	addi	a1,s0,-72
    1546:	00004097          	auipc	ra,0x4
    154a:	31a080e7          	jalr	794(ra) # 5860 <read>
    154e:	4789                	li	a5,2
    1550:	02f50e63          	beq	a0,a5,158c <exectest+0x18e>
    printf("%s: read failed\n", s);
    1554:	85ca                	mv	a1,s2
    1556:	00005517          	auipc	a0,0x5
    155a:	f2a50513          	addi	a0,a0,-214 # 6480 <malloc+0x7ea>
    155e:	00004097          	auipc	ra,0x4
    1562:	67a080e7          	jalr	1658(ra) # 5bd8 <printf>
    exit(1);
    1566:	4505                	li	a0,1
    1568:	00004097          	auipc	ra,0x4
    156c:	2e0080e7          	jalr	736(ra) # 5848 <exit>
    printf("%s: open failed\n", s);
    1570:	85ca                	mv	a1,s2
    1572:	00005517          	auipc	a0,0x5
    1576:	36650513          	addi	a0,a0,870 # 68d8 <malloc+0xc42>
    157a:	00004097          	auipc	ra,0x4
    157e:	65e080e7          	jalr	1630(ra) # 5bd8 <printf>
    exit(1);
    1582:	4505                	li	a0,1
    1584:	00004097          	auipc	ra,0x4
    1588:	2c4080e7          	jalr	708(ra) # 5848 <exit>
  unlink("echo-ok");
    158c:	00005517          	auipc	a0,0x5
    1590:	3c450513          	addi	a0,a0,964 # 6950 <malloc+0xcba>
    1594:	00004097          	auipc	ra,0x4
    1598:	304080e7          	jalr	772(ra) # 5898 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    159c:	fb844703          	lbu	a4,-72(s0)
    15a0:	04f00793          	li	a5,79
    15a4:	00f71863          	bne	a4,a5,15b4 <exectest+0x1b6>
    15a8:	fb944703          	lbu	a4,-71(s0)
    15ac:	04b00793          	li	a5,75
    15b0:	02f70063          	beq	a4,a5,15d0 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    15b4:	85ca                	mv	a1,s2
    15b6:	00005517          	auipc	a0,0x5
    15ba:	3fa50513          	addi	a0,a0,1018 # 69b0 <malloc+0xd1a>
    15be:	00004097          	auipc	ra,0x4
    15c2:	61a080e7          	jalr	1562(ra) # 5bd8 <printf>
    exit(1);
    15c6:	4505                	li	a0,1
    15c8:	00004097          	auipc	ra,0x4
    15cc:	280080e7          	jalr	640(ra) # 5848 <exit>
    exit(0);
    15d0:	4501                	li	a0,0
    15d2:	00004097          	auipc	ra,0x4
    15d6:	276080e7          	jalr	630(ra) # 5848 <exit>

00000000000015da <pipe1>:
{
    15da:	711d                	addi	sp,sp,-96
    15dc:	ec86                	sd	ra,88(sp)
    15de:	e8a2                	sd	s0,80(sp)
    15e0:	e4a6                	sd	s1,72(sp)
    15e2:	e0ca                	sd	s2,64(sp)
    15e4:	fc4e                	sd	s3,56(sp)
    15e6:	f852                	sd	s4,48(sp)
    15e8:	f456                	sd	s5,40(sp)
    15ea:	f05a                	sd	s6,32(sp)
    15ec:	ec5e                	sd	s7,24(sp)
    15ee:	1080                	addi	s0,sp,96
    15f0:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    15f2:	fa840513          	addi	a0,s0,-88
    15f6:	00004097          	auipc	ra,0x4
    15fa:	262080e7          	jalr	610(ra) # 5858 <pipe>
    15fe:	ed25                	bnez	a0,1676 <pipe1+0x9c>
    1600:	84aa                	mv	s1,a0
  pid = fork();
    1602:	00004097          	auipc	ra,0x4
    1606:	23e080e7          	jalr	574(ra) # 5840 <fork>
    160a:	8a2a                	mv	s4,a0
  if(pid == 0){
    160c:	c159                	beqz	a0,1692 <pipe1+0xb8>
  } else if(pid > 0){
    160e:	16a05e63          	blez	a0,178a <pipe1+0x1b0>
    close(fds[1]);
    1612:	fac42503          	lw	a0,-84(s0)
    1616:	00004097          	auipc	ra,0x4
    161a:	25a080e7          	jalr	602(ra) # 5870 <close>
    total = 0;
    161e:	8a26                	mv	s4,s1
    cc = 1;
    1620:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1622:	0000aa97          	auipc	s5,0xa
    1626:	726a8a93          	addi	s5,s5,1830 # bd48 <buf>
      if(cc > sizeof(buf))
    162a:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    162c:	864e                	mv	a2,s3
    162e:	85d6                	mv	a1,s5
    1630:	fa842503          	lw	a0,-88(s0)
    1634:	00004097          	auipc	ra,0x4
    1638:	22c080e7          	jalr	556(ra) # 5860 <read>
    163c:	10a05263          	blez	a0,1740 <pipe1+0x166>
      for(i = 0; i < n; i++){
    1640:	0000a717          	auipc	a4,0xa
    1644:	70870713          	addi	a4,a4,1800 # bd48 <buf>
    1648:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    164c:	00074683          	lbu	a3,0(a4)
    1650:	0ff4f793          	andi	a5,s1,255
    1654:	2485                	addiw	s1,s1,1
    1656:	0cf69163          	bne	a3,a5,1718 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    165a:	0705                	addi	a4,a4,1
    165c:	fec498e3          	bne	s1,a2,164c <pipe1+0x72>
      total += n;
    1660:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1664:	0019979b          	slliw	a5,s3,0x1
    1668:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    166c:	013b7363          	bgeu	s6,s3,1672 <pipe1+0x98>
        cc = sizeof(buf);
    1670:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1672:	84b2                	mv	s1,a2
    1674:	bf65                	j	162c <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    1676:	85ca                	mv	a1,s2
    1678:	00005517          	auipc	a0,0x5
    167c:	35050513          	addi	a0,a0,848 # 69c8 <malloc+0xd32>
    1680:	00004097          	auipc	ra,0x4
    1684:	558080e7          	jalr	1368(ra) # 5bd8 <printf>
    exit(1);
    1688:	4505                	li	a0,1
    168a:	00004097          	auipc	ra,0x4
    168e:	1be080e7          	jalr	446(ra) # 5848 <exit>
    close(fds[0]);
    1692:	fa842503          	lw	a0,-88(s0)
    1696:	00004097          	auipc	ra,0x4
    169a:	1da080e7          	jalr	474(ra) # 5870 <close>
    for(n = 0; n < N; n++){
    169e:	0000ab17          	auipc	s6,0xa
    16a2:	6aab0b13          	addi	s6,s6,1706 # bd48 <buf>
    16a6:	416004bb          	negw	s1,s6
    16aa:	0ff4f493          	andi	s1,s1,255
    16ae:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    16b2:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    16b4:	6a85                	lui	s5,0x1
    16b6:	42da8a93          	addi	s5,s5,1069 # 142d <exectest+0x2f>
{
    16ba:	87da                	mv	a5,s6
        buf[i] = seq++;
    16bc:	0097873b          	addw	a4,a5,s1
    16c0:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    16c4:	0785                	addi	a5,a5,1
    16c6:	fef99be3          	bne	s3,a5,16bc <pipe1+0xe2>
    16ca:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    16ce:	40900613          	li	a2,1033
    16d2:	85de                	mv	a1,s7
    16d4:	fac42503          	lw	a0,-84(s0)
    16d8:	00004097          	auipc	ra,0x4
    16dc:	190080e7          	jalr	400(ra) # 5868 <write>
    16e0:	40900793          	li	a5,1033
    16e4:	00f51c63          	bne	a0,a5,16fc <pipe1+0x122>
    for(n = 0; n < N; n++){
    16e8:	24a5                	addiw	s1,s1,9
    16ea:	0ff4f493          	andi	s1,s1,255
    16ee:	fd5a16e3          	bne	s4,s5,16ba <pipe1+0xe0>
    exit(0);
    16f2:	4501                	li	a0,0
    16f4:	00004097          	auipc	ra,0x4
    16f8:	154080e7          	jalr	340(ra) # 5848 <exit>
        printf("%s: pipe1 oops 1\n", s);
    16fc:	85ca                	mv	a1,s2
    16fe:	00005517          	auipc	a0,0x5
    1702:	2e250513          	addi	a0,a0,738 # 69e0 <malloc+0xd4a>
    1706:	00004097          	auipc	ra,0x4
    170a:	4d2080e7          	jalr	1234(ra) # 5bd8 <printf>
        exit(1);
    170e:	4505                	li	a0,1
    1710:	00004097          	auipc	ra,0x4
    1714:	138080e7          	jalr	312(ra) # 5848 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	2de50513          	addi	a0,a0,734 # 69f8 <malloc+0xd62>
    1722:	00004097          	auipc	ra,0x4
    1726:	4b6080e7          	jalr	1206(ra) # 5bd8 <printf>
}
    172a:	60e6                	ld	ra,88(sp)
    172c:	6446                	ld	s0,80(sp)
    172e:	64a6                	ld	s1,72(sp)
    1730:	6906                	ld	s2,64(sp)
    1732:	79e2                	ld	s3,56(sp)
    1734:	7a42                	ld	s4,48(sp)
    1736:	7aa2                	ld	s5,40(sp)
    1738:	7b02                	ld	s6,32(sp)
    173a:	6be2                	ld	s7,24(sp)
    173c:	6125                	addi	sp,sp,96
    173e:	8082                	ret
    if(total != N * SZ){
    1740:	6785                	lui	a5,0x1
    1742:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0x2f>
    1746:	02fa0063          	beq	s4,a5,1766 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    174a:	85d2                	mv	a1,s4
    174c:	00005517          	auipc	a0,0x5
    1750:	2c450513          	addi	a0,a0,708 # 6a10 <malloc+0xd7a>
    1754:	00004097          	auipc	ra,0x4
    1758:	484080e7          	jalr	1156(ra) # 5bd8 <printf>
      exit(1);
    175c:	4505                	li	a0,1
    175e:	00004097          	auipc	ra,0x4
    1762:	0ea080e7          	jalr	234(ra) # 5848 <exit>
    close(fds[0]);
    1766:	fa842503          	lw	a0,-88(s0)
    176a:	00004097          	auipc	ra,0x4
    176e:	106080e7          	jalr	262(ra) # 5870 <close>
    wait(&xstatus);
    1772:	fa440513          	addi	a0,s0,-92
    1776:	00004097          	auipc	ra,0x4
    177a:	0da080e7          	jalr	218(ra) # 5850 <wait>
    exit(xstatus);
    177e:	fa442503          	lw	a0,-92(s0)
    1782:	00004097          	auipc	ra,0x4
    1786:	0c6080e7          	jalr	198(ra) # 5848 <exit>
    printf("%s: fork() failed\n", s);
    178a:	85ca                	mv	a1,s2
    178c:	00005517          	auipc	a0,0x5
    1790:	2a450513          	addi	a0,a0,676 # 6a30 <malloc+0xd9a>
    1794:	00004097          	auipc	ra,0x4
    1798:	444080e7          	jalr	1092(ra) # 5bd8 <printf>
    exit(1);
    179c:	4505                	li	a0,1
    179e:	00004097          	auipc	ra,0x4
    17a2:	0aa080e7          	jalr	170(ra) # 5848 <exit>

00000000000017a6 <exitwait>:
{
    17a6:	7139                	addi	sp,sp,-64
    17a8:	fc06                	sd	ra,56(sp)
    17aa:	f822                	sd	s0,48(sp)
    17ac:	f426                	sd	s1,40(sp)
    17ae:	f04a                	sd	s2,32(sp)
    17b0:	ec4e                	sd	s3,24(sp)
    17b2:	e852                	sd	s4,16(sp)
    17b4:	0080                	addi	s0,sp,64
    17b6:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    17b8:	4901                	li	s2,0
    17ba:	06400993          	li	s3,100
    pid = fork();
    17be:	00004097          	auipc	ra,0x4
    17c2:	082080e7          	jalr	130(ra) # 5840 <fork>
    17c6:	84aa                	mv	s1,a0
    if(pid < 0){
    17c8:	02054a63          	bltz	a0,17fc <exitwait+0x56>
    if(pid){
    17cc:	c151                	beqz	a0,1850 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    17ce:	fcc40513          	addi	a0,s0,-52
    17d2:	00004097          	auipc	ra,0x4
    17d6:	07e080e7          	jalr	126(ra) # 5850 <wait>
    17da:	02951f63          	bne	a0,s1,1818 <exitwait+0x72>
      if(i != xstate) {
    17de:	fcc42783          	lw	a5,-52(s0)
    17e2:	05279963          	bne	a5,s2,1834 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    17e6:	2905                	addiw	s2,s2,1
    17e8:	fd391be3          	bne	s2,s3,17be <exitwait+0x18>
}
    17ec:	70e2                	ld	ra,56(sp)
    17ee:	7442                	ld	s0,48(sp)
    17f0:	74a2                	ld	s1,40(sp)
    17f2:	7902                	ld	s2,32(sp)
    17f4:	69e2                	ld	s3,24(sp)
    17f6:	6a42                	ld	s4,16(sp)
    17f8:	6121                	addi	sp,sp,64
    17fa:	8082                	ret
      printf("%s: fork failed\n", s);
    17fc:	85d2                	mv	a1,s4
    17fe:	00005517          	auipc	a0,0x5
    1802:	0c250513          	addi	a0,a0,194 # 68c0 <malloc+0xc2a>
    1806:	00004097          	auipc	ra,0x4
    180a:	3d2080e7          	jalr	978(ra) # 5bd8 <printf>
      exit(1);
    180e:	4505                	li	a0,1
    1810:	00004097          	auipc	ra,0x4
    1814:	038080e7          	jalr	56(ra) # 5848 <exit>
        printf("%s: wait wrong pid\n", s);
    1818:	85d2                	mv	a1,s4
    181a:	00005517          	auipc	a0,0x5
    181e:	22e50513          	addi	a0,a0,558 # 6a48 <malloc+0xdb2>
    1822:	00004097          	auipc	ra,0x4
    1826:	3b6080e7          	jalr	950(ra) # 5bd8 <printf>
        exit(1);
    182a:	4505                	li	a0,1
    182c:	00004097          	auipc	ra,0x4
    1830:	01c080e7          	jalr	28(ra) # 5848 <exit>
        printf("%s: wait wrong exit status\n", s);
    1834:	85d2                	mv	a1,s4
    1836:	00005517          	auipc	a0,0x5
    183a:	22a50513          	addi	a0,a0,554 # 6a60 <malloc+0xdca>
    183e:	00004097          	auipc	ra,0x4
    1842:	39a080e7          	jalr	922(ra) # 5bd8 <printf>
        exit(1);
    1846:	4505                	li	a0,1
    1848:	00004097          	auipc	ra,0x4
    184c:	000080e7          	jalr	ra # 5848 <exit>
      exit(i);
    1850:	854a                	mv	a0,s2
    1852:	00004097          	auipc	ra,0x4
    1856:	ff6080e7          	jalr	-10(ra) # 5848 <exit>

000000000000185a <twochildren>:
{
    185a:	1101                	addi	sp,sp,-32
    185c:	ec06                	sd	ra,24(sp)
    185e:	e822                	sd	s0,16(sp)
    1860:	e426                	sd	s1,8(sp)
    1862:	e04a                	sd	s2,0(sp)
    1864:	1000                	addi	s0,sp,32
    1866:	892a                	mv	s2,a0
    1868:	3e800493          	li	s1,1000
    int pid1 = fork();
    186c:	00004097          	auipc	ra,0x4
    1870:	fd4080e7          	jalr	-44(ra) # 5840 <fork>
    if(pid1 < 0){
    1874:	02054c63          	bltz	a0,18ac <twochildren+0x52>
    if(pid1 == 0){
    1878:	c921                	beqz	a0,18c8 <twochildren+0x6e>
      int pid2 = fork();
    187a:	00004097          	auipc	ra,0x4
    187e:	fc6080e7          	jalr	-58(ra) # 5840 <fork>
      if(pid2 < 0){
    1882:	04054763          	bltz	a0,18d0 <twochildren+0x76>
      if(pid2 == 0){
    1886:	c13d                	beqz	a0,18ec <twochildren+0x92>
        wait(0);
    1888:	4501                	li	a0,0
    188a:	00004097          	auipc	ra,0x4
    188e:	fc6080e7          	jalr	-58(ra) # 5850 <wait>
        wait(0);
    1892:	4501                	li	a0,0
    1894:	00004097          	auipc	ra,0x4
    1898:	fbc080e7          	jalr	-68(ra) # 5850 <wait>
  for(int i = 0; i < 1000; i++){
    189c:	34fd                	addiw	s1,s1,-1
    189e:	f4f9                	bnez	s1,186c <twochildren+0x12>
}
    18a0:	60e2                	ld	ra,24(sp)
    18a2:	6442                	ld	s0,16(sp)
    18a4:	64a2                	ld	s1,8(sp)
    18a6:	6902                	ld	s2,0(sp)
    18a8:	6105                	addi	sp,sp,32
    18aa:	8082                	ret
      printf("%s: fork failed\n", s);
    18ac:	85ca                	mv	a1,s2
    18ae:	00005517          	auipc	a0,0x5
    18b2:	01250513          	addi	a0,a0,18 # 68c0 <malloc+0xc2a>
    18b6:	00004097          	auipc	ra,0x4
    18ba:	322080e7          	jalr	802(ra) # 5bd8 <printf>
      exit(1);
    18be:	4505                	li	a0,1
    18c0:	00004097          	auipc	ra,0x4
    18c4:	f88080e7          	jalr	-120(ra) # 5848 <exit>
      exit(0);
    18c8:	00004097          	auipc	ra,0x4
    18cc:	f80080e7          	jalr	-128(ra) # 5848 <exit>
        printf("%s: fork failed\n", s);
    18d0:	85ca                	mv	a1,s2
    18d2:	00005517          	auipc	a0,0x5
    18d6:	fee50513          	addi	a0,a0,-18 # 68c0 <malloc+0xc2a>
    18da:	00004097          	auipc	ra,0x4
    18de:	2fe080e7          	jalr	766(ra) # 5bd8 <printf>
        exit(1);
    18e2:	4505                	li	a0,1
    18e4:	00004097          	auipc	ra,0x4
    18e8:	f64080e7          	jalr	-156(ra) # 5848 <exit>
        exit(0);
    18ec:	00004097          	auipc	ra,0x4
    18f0:	f5c080e7          	jalr	-164(ra) # 5848 <exit>

00000000000018f4 <forkfork>:
{
    18f4:	7179                	addi	sp,sp,-48
    18f6:	f406                	sd	ra,40(sp)
    18f8:	f022                	sd	s0,32(sp)
    18fa:	ec26                	sd	s1,24(sp)
    18fc:	1800                	addi	s0,sp,48
    18fe:	84aa                	mv	s1,a0
    int pid = fork();
    1900:	00004097          	auipc	ra,0x4
    1904:	f40080e7          	jalr	-192(ra) # 5840 <fork>
    if(pid < 0){
    1908:	04054163          	bltz	a0,194a <forkfork+0x56>
    if(pid == 0){
    190c:	cd29                	beqz	a0,1966 <forkfork+0x72>
    int pid = fork();
    190e:	00004097          	auipc	ra,0x4
    1912:	f32080e7          	jalr	-206(ra) # 5840 <fork>
    if(pid < 0){
    1916:	02054a63          	bltz	a0,194a <forkfork+0x56>
    if(pid == 0){
    191a:	c531                	beqz	a0,1966 <forkfork+0x72>
    wait(&xstatus);
    191c:	fdc40513          	addi	a0,s0,-36
    1920:	00004097          	auipc	ra,0x4
    1924:	f30080e7          	jalr	-208(ra) # 5850 <wait>
    if(xstatus != 0) {
    1928:	fdc42783          	lw	a5,-36(s0)
    192c:	ebbd                	bnez	a5,19a2 <forkfork+0xae>
    wait(&xstatus);
    192e:	fdc40513          	addi	a0,s0,-36
    1932:	00004097          	auipc	ra,0x4
    1936:	f1e080e7          	jalr	-226(ra) # 5850 <wait>
    if(xstatus != 0) {
    193a:	fdc42783          	lw	a5,-36(s0)
    193e:	e3b5                	bnez	a5,19a2 <forkfork+0xae>
}
    1940:	70a2                	ld	ra,40(sp)
    1942:	7402                	ld	s0,32(sp)
    1944:	64e2                	ld	s1,24(sp)
    1946:	6145                	addi	sp,sp,48
    1948:	8082                	ret
      printf("%s: fork failed", s);
    194a:	85a6                	mv	a1,s1
    194c:	00005517          	auipc	a0,0x5
    1950:	13450513          	addi	a0,a0,308 # 6a80 <malloc+0xdea>
    1954:	00004097          	auipc	ra,0x4
    1958:	284080e7          	jalr	644(ra) # 5bd8 <printf>
      exit(1);
    195c:	4505                	li	a0,1
    195e:	00004097          	auipc	ra,0x4
    1962:	eea080e7          	jalr	-278(ra) # 5848 <exit>
{
    1966:	0c800493          	li	s1,200
        int pid1 = fork();
    196a:	00004097          	auipc	ra,0x4
    196e:	ed6080e7          	jalr	-298(ra) # 5840 <fork>
        if(pid1 < 0){
    1972:	00054f63          	bltz	a0,1990 <forkfork+0x9c>
        if(pid1 == 0){
    1976:	c115                	beqz	a0,199a <forkfork+0xa6>
        wait(0);
    1978:	4501                	li	a0,0
    197a:	00004097          	auipc	ra,0x4
    197e:	ed6080e7          	jalr	-298(ra) # 5850 <wait>
      for(int j = 0; j < 200; j++){
    1982:	34fd                	addiw	s1,s1,-1
    1984:	f0fd                	bnez	s1,196a <forkfork+0x76>
      exit(0);
    1986:	4501                	li	a0,0
    1988:	00004097          	auipc	ra,0x4
    198c:	ec0080e7          	jalr	-320(ra) # 5848 <exit>
          exit(1);
    1990:	4505                	li	a0,1
    1992:	00004097          	auipc	ra,0x4
    1996:	eb6080e7          	jalr	-330(ra) # 5848 <exit>
          exit(0);
    199a:	00004097          	auipc	ra,0x4
    199e:	eae080e7          	jalr	-338(ra) # 5848 <exit>
      printf("%s: fork in child failed", s);
    19a2:	85a6                	mv	a1,s1
    19a4:	00005517          	auipc	a0,0x5
    19a8:	0ec50513          	addi	a0,a0,236 # 6a90 <malloc+0xdfa>
    19ac:	00004097          	auipc	ra,0x4
    19b0:	22c080e7          	jalr	556(ra) # 5bd8 <printf>
      exit(1);
    19b4:	4505                	li	a0,1
    19b6:	00004097          	auipc	ra,0x4
    19ba:	e92080e7          	jalr	-366(ra) # 5848 <exit>

00000000000019be <reparent2>:
{
    19be:	1101                	addi	sp,sp,-32
    19c0:	ec06                	sd	ra,24(sp)
    19c2:	e822                	sd	s0,16(sp)
    19c4:	e426                	sd	s1,8(sp)
    19c6:	1000                	addi	s0,sp,32
    19c8:	32000493          	li	s1,800
    int pid1 = fork();
    19cc:	00004097          	auipc	ra,0x4
    19d0:	e74080e7          	jalr	-396(ra) # 5840 <fork>
    if(pid1 < 0){
    19d4:	00054f63          	bltz	a0,19f2 <reparent2+0x34>
    if(pid1 == 0){
    19d8:	c915                	beqz	a0,1a0c <reparent2+0x4e>
    wait(0);
    19da:	4501                	li	a0,0
    19dc:	00004097          	auipc	ra,0x4
    19e0:	e74080e7          	jalr	-396(ra) # 5850 <wait>
  for(int i = 0; i < 800; i++){
    19e4:	34fd                	addiw	s1,s1,-1
    19e6:	f0fd                	bnez	s1,19cc <reparent2+0xe>
  exit(0);
    19e8:	4501                	li	a0,0
    19ea:	00004097          	auipc	ra,0x4
    19ee:	e5e080e7          	jalr	-418(ra) # 5848 <exit>
      printf("fork failed\n");
    19f2:	00005517          	auipc	a0,0x5
    19f6:	2d650513          	addi	a0,a0,726 # 6cc8 <malloc+0x1032>
    19fa:	00004097          	auipc	ra,0x4
    19fe:	1de080e7          	jalr	478(ra) # 5bd8 <printf>
      exit(1);
    1a02:	4505                	li	a0,1
    1a04:	00004097          	auipc	ra,0x4
    1a08:	e44080e7          	jalr	-444(ra) # 5848 <exit>
      fork();
    1a0c:	00004097          	auipc	ra,0x4
    1a10:	e34080e7          	jalr	-460(ra) # 5840 <fork>
      fork();
    1a14:	00004097          	auipc	ra,0x4
    1a18:	e2c080e7          	jalr	-468(ra) # 5840 <fork>
      exit(0);
    1a1c:	4501                	li	a0,0
    1a1e:	00004097          	auipc	ra,0x4
    1a22:	e2a080e7          	jalr	-470(ra) # 5848 <exit>

0000000000001a26 <createdelete>:
{
    1a26:	7175                	addi	sp,sp,-144
    1a28:	e506                	sd	ra,136(sp)
    1a2a:	e122                	sd	s0,128(sp)
    1a2c:	fca6                	sd	s1,120(sp)
    1a2e:	f8ca                	sd	s2,112(sp)
    1a30:	f4ce                	sd	s3,104(sp)
    1a32:	f0d2                	sd	s4,96(sp)
    1a34:	ecd6                	sd	s5,88(sp)
    1a36:	e8da                	sd	s6,80(sp)
    1a38:	e4de                	sd	s7,72(sp)
    1a3a:	e0e2                	sd	s8,64(sp)
    1a3c:	fc66                	sd	s9,56(sp)
    1a3e:	0900                	addi	s0,sp,144
    1a40:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1a42:	4901                	li	s2,0
    1a44:	4991                	li	s3,4
    pid = fork();
    1a46:	00004097          	auipc	ra,0x4
    1a4a:	dfa080e7          	jalr	-518(ra) # 5840 <fork>
    1a4e:	84aa                	mv	s1,a0
    if(pid < 0){
    1a50:	02054f63          	bltz	a0,1a8e <createdelete+0x68>
    if(pid == 0){
    1a54:	c939                	beqz	a0,1aaa <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1a56:	2905                	addiw	s2,s2,1
    1a58:	ff3917e3          	bne	s2,s3,1a46 <createdelete+0x20>
    1a5c:	4491                	li	s1,4
    wait(&xstatus);
    1a5e:	f7c40513          	addi	a0,s0,-132
    1a62:	00004097          	auipc	ra,0x4
    1a66:	dee080e7          	jalr	-530(ra) # 5850 <wait>
    if(xstatus != 0)
    1a6a:	f7c42903          	lw	s2,-132(s0)
    1a6e:	0e091263          	bnez	s2,1b52 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1a72:	34fd                	addiw	s1,s1,-1
    1a74:	f4ed                	bnez	s1,1a5e <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1a76:	f8040123          	sb	zero,-126(s0)
    1a7a:	03000993          	li	s3,48
    1a7e:	5a7d                	li	s4,-1
    1a80:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1a84:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1a86:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1a88:	07400a93          	li	s5,116
    1a8c:	a29d                	j	1bf2 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1a8e:	85e6                	mv	a1,s9
    1a90:	00005517          	auipc	a0,0x5
    1a94:	23850513          	addi	a0,a0,568 # 6cc8 <malloc+0x1032>
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	140080e7          	jalr	320(ra) # 5bd8 <printf>
      exit(1);
    1aa0:	4505                	li	a0,1
    1aa2:	00004097          	auipc	ra,0x4
    1aa6:	da6080e7          	jalr	-602(ra) # 5848 <exit>
      name[0] = 'p' + pi;
    1aaa:	0709091b          	addiw	s2,s2,112
    1aae:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1ab2:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1ab6:	4951                	li	s2,20
    1ab8:	a015                	j	1adc <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1aba:	85e6                	mv	a1,s9
    1abc:	00005517          	auipc	a0,0x5
    1ac0:	e9c50513          	addi	a0,a0,-356 # 6958 <malloc+0xcc2>
    1ac4:	00004097          	auipc	ra,0x4
    1ac8:	114080e7          	jalr	276(ra) # 5bd8 <printf>
          exit(1);
    1acc:	4505                	li	a0,1
    1ace:	00004097          	auipc	ra,0x4
    1ad2:	d7a080e7          	jalr	-646(ra) # 5848 <exit>
      for(i = 0; i < N; i++){
    1ad6:	2485                	addiw	s1,s1,1
    1ad8:	07248863          	beq	s1,s2,1b48 <createdelete+0x122>
        name[1] = '0' + i;
    1adc:	0304879b          	addiw	a5,s1,48
    1ae0:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1ae4:	20200593          	li	a1,514
    1ae8:	f8040513          	addi	a0,s0,-128
    1aec:	00004097          	auipc	ra,0x4
    1af0:	d9c080e7          	jalr	-612(ra) # 5888 <open>
        if(fd < 0){
    1af4:	fc0543e3          	bltz	a0,1aba <createdelete+0x94>
        close(fd);
    1af8:	00004097          	auipc	ra,0x4
    1afc:	d78080e7          	jalr	-648(ra) # 5870 <close>
        if(i > 0 && (i % 2 ) == 0){
    1b00:	fc905be3          	blez	s1,1ad6 <createdelete+0xb0>
    1b04:	0014f793          	andi	a5,s1,1
    1b08:	f7f9                	bnez	a5,1ad6 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1b0a:	01f4d79b          	srliw	a5,s1,0x1f
    1b0e:	9fa5                	addw	a5,a5,s1
    1b10:	4017d79b          	sraiw	a5,a5,0x1
    1b14:	0307879b          	addiw	a5,a5,48
    1b18:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1b1c:	f8040513          	addi	a0,s0,-128
    1b20:	00004097          	auipc	ra,0x4
    1b24:	d78080e7          	jalr	-648(ra) # 5898 <unlink>
    1b28:	fa0557e3          	bgez	a0,1ad6 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1b2c:	85e6                	mv	a1,s9
    1b2e:	00005517          	auipc	a0,0x5
    1b32:	f8250513          	addi	a0,a0,-126 # 6ab0 <malloc+0xe1a>
    1b36:	00004097          	auipc	ra,0x4
    1b3a:	0a2080e7          	jalr	162(ra) # 5bd8 <printf>
            exit(1);
    1b3e:	4505                	li	a0,1
    1b40:	00004097          	auipc	ra,0x4
    1b44:	d08080e7          	jalr	-760(ra) # 5848 <exit>
      exit(0);
    1b48:	4501                	li	a0,0
    1b4a:	00004097          	auipc	ra,0x4
    1b4e:	cfe080e7          	jalr	-770(ra) # 5848 <exit>
      exit(1);
    1b52:	4505                	li	a0,1
    1b54:	00004097          	auipc	ra,0x4
    1b58:	cf4080e7          	jalr	-780(ra) # 5848 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1b5c:	f8040613          	addi	a2,s0,-128
    1b60:	85e6                	mv	a1,s9
    1b62:	00005517          	auipc	a0,0x5
    1b66:	f6650513          	addi	a0,a0,-154 # 6ac8 <malloc+0xe32>
    1b6a:	00004097          	auipc	ra,0x4
    1b6e:	06e080e7          	jalr	110(ra) # 5bd8 <printf>
        exit(1);
    1b72:	4505                	li	a0,1
    1b74:	00004097          	auipc	ra,0x4
    1b78:	cd4080e7          	jalr	-812(ra) # 5848 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1b7c:	054b7163          	bgeu	s6,s4,1bbe <createdelete+0x198>
      if(fd >= 0)
    1b80:	02055a63          	bgez	a0,1bb4 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1b84:	2485                	addiw	s1,s1,1
    1b86:	0ff4f493          	andi	s1,s1,255
    1b8a:	05548c63          	beq	s1,s5,1be2 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1b8e:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1b92:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1b96:	4581                	li	a1,0
    1b98:	f8040513          	addi	a0,s0,-128
    1b9c:	00004097          	auipc	ra,0x4
    1ba0:	cec080e7          	jalr	-788(ra) # 5888 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1ba4:	00090463          	beqz	s2,1bac <createdelete+0x186>
    1ba8:	fd2bdae3          	bge	s7,s2,1b7c <createdelete+0x156>
    1bac:	fa0548e3          	bltz	a0,1b5c <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bb0:	014b7963          	bgeu	s6,s4,1bc2 <createdelete+0x19c>
        close(fd);
    1bb4:	00004097          	auipc	ra,0x4
    1bb8:	cbc080e7          	jalr	-836(ra) # 5870 <close>
    1bbc:	b7e1                	j	1b84 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bbe:	fc0543e3          	bltz	a0,1b84 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1bc2:	f8040613          	addi	a2,s0,-128
    1bc6:	85e6                	mv	a1,s9
    1bc8:	00005517          	auipc	a0,0x5
    1bcc:	f2850513          	addi	a0,a0,-216 # 6af0 <malloc+0xe5a>
    1bd0:	00004097          	auipc	ra,0x4
    1bd4:	008080e7          	jalr	8(ra) # 5bd8 <printf>
        exit(1);
    1bd8:	4505                	li	a0,1
    1bda:	00004097          	auipc	ra,0x4
    1bde:	c6e080e7          	jalr	-914(ra) # 5848 <exit>
  for(i = 0; i < N; i++){
    1be2:	2905                	addiw	s2,s2,1
    1be4:	2a05                	addiw	s4,s4,1
    1be6:	2985                	addiw	s3,s3,1
    1be8:	0ff9f993          	andi	s3,s3,255
    1bec:	47d1                	li	a5,20
    1bee:	02f90a63          	beq	s2,a5,1c22 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1bf2:	84e2                	mv	s1,s8
    1bf4:	bf69                	j	1b8e <createdelete+0x168>
  for(i = 0; i < N; i++){
    1bf6:	2905                	addiw	s2,s2,1
    1bf8:	0ff97913          	andi	s2,s2,255
    1bfc:	2985                	addiw	s3,s3,1
    1bfe:	0ff9f993          	andi	s3,s3,255
    1c02:	03490863          	beq	s2,s4,1c32 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1c06:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1c08:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1c0c:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1c10:	f8040513          	addi	a0,s0,-128
    1c14:	00004097          	auipc	ra,0x4
    1c18:	c84080e7          	jalr	-892(ra) # 5898 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1c1c:	34fd                	addiw	s1,s1,-1
    1c1e:	f4ed                	bnez	s1,1c08 <createdelete+0x1e2>
    1c20:	bfd9                	j	1bf6 <createdelete+0x1d0>
    1c22:	03000993          	li	s3,48
    1c26:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1c2a:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1c2c:	08400a13          	li	s4,132
    1c30:	bfd9                	j	1c06 <createdelete+0x1e0>
}
    1c32:	60aa                	ld	ra,136(sp)
    1c34:	640a                	ld	s0,128(sp)
    1c36:	74e6                	ld	s1,120(sp)
    1c38:	7946                	ld	s2,112(sp)
    1c3a:	79a6                	ld	s3,104(sp)
    1c3c:	7a06                	ld	s4,96(sp)
    1c3e:	6ae6                	ld	s5,88(sp)
    1c40:	6b46                	ld	s6,80(sp)
    1c42:	6ba6                	ld	s7,72(sp)
    1c44:	6c06                	ld	s8,64(sp)
    1c46:	7ce2                	ld	s9,56(sp)
    1c48:	6149                	addi	sp,sp,144
    1c4a:	8082                	ret

0000000000001c4c <linkunlink>:
{
    1c4c:	711d                	addi	sp,sp,-96
    1c4e:	ec86                	sd	ra,88(sp)
    1c50:	e8a2                	sd	s0,80(sp)
    1c52:	e4a6                	sd	s1,72(sp)
    1c54:	e0ca                	sd	s2,64(sp)
    1c56:	fc4e                	sd	s3,56(sp)
    1c58:	f852                	sd	s4,48(sp)
    1c5a:	f456                	sd	s5,40(sp)
    1c5c:	f05a                	sd	s6,32(sp)
    1c5e:	ec5e                	sd	s7,24(sp)
    1c60:	e862                	sd	s8,16(sp)
    1c62:	e466                	sd	s9,8(sp)
    1c64:	1080                	addi	s0,sp,96
    1c66:	84aa                	mv	s1,a0
  unlink("x");
    1c68:	00004517          	auipc	a0,0x4
    1c6c:	4f850513          	addi	a0,a0,1272 # 6160 <malloc+0x4ca>
    1c70:	00004097          	auipc	ra,0x4
    1c74:	c28080e7          	jalr	-984(ra) # 5898 <unlink>
  pid = fork();
    1c78:	00004097          	auipc	ra,0x4
    1c7c:	bc8080e7          	jalr	-1080(ra) # 5840 <fork>
  if(pid < 0){
    1c80:	02054b63          	bltz	a0,1cb6 <linkunlink+0x6a>
    1c84:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1c86:	4c85                	li	s9,1
    1c88:	e119                	bnez	a0,1c8e <linkunlink+0x42>
    1c8a:	06100c93          	li	s9,97
    1c8e:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1c92:	41c659b7          	lui	s3,0x41c65
    1c96:	e6d9899b          	addiw	s3,s3,-403
    1c9a:	690d                	lui	s2,0x3
    1c9c:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1ca0:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1ca2:	4b05                	li	s6,1
      unlink("x");
    1ca4:	00004a97          	auipc	s5,0x4
    1ca8:	4bca8a93          	addi	s5,s5,1212 # 6160 <malloc+0x4ca>
      link("cat", "x");
    1cac:	00005b97          	auipc	s7,0x5
    1cb0:	e6cb8b93          	addi	s7,s7,-404 # 6b18 <malloc+0xe82>
    1cb4:	a091                	j	1cf8 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1cb6:	85a6                	mv	a1,s1
    1cb8:	00005517          	auipc	a0,0x5
    1cbc:	c0850513          	addi	a0,a0,-1016 # 68c0 <malloc+0xc2a>
    1cc0:	00004097          	auipc	ra,0x4
    1cc4:	f18080e7          	jalr	-232(ra) # 5bd8 <printf>
    exit(1);
    1cc8:	4505                	li	a0,1
    1cca:	00004097          	auipc	ra,0x4
    1cce:	b7e080e7          	jalr	-1154(ra) # 5848 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1cd2:	20200593          	li	a1,514
    1cd6:	8556                	mv	a0,s5
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	bb0080e7          	jalr	-1104(ra) # 5888 <open>
    1ce0:	00004097          	auipc	ra,0x4
    1ce4:	b90080e7          	jalr	-1136(ra) # 5870 <close>
    1ce8:	a031                	j	1cf4 <linkunlink+0xa8>
      unlink("x");
    1cea:	8556                	mv	a0,s5
    1cec:	00004097          	auipc	ra,0x4
    1cf0:	bac080e7          	jalr	-1108(ra) # 5898 <unlink>
  for(i = 0; i < 100; i++){
    1cf4:	34fd                	addiw	s1,s1,-1
    1cf6:	c09d                	beqz	s1,1d1c <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1cf8:	033c87bb          	mulw	a5,s9,s3
    1cfc:	012787bb          	addw	a5,a5,s2
    1d00:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1d04:	0347f7bb          	remuw	a5,a5,s4
    1d08:	d7e9                	beqz	a5,1cd2 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1d0a:	ff6790e3          	bne	a5,s6,1cea <linkunlink+0x9e>
      link("cat", "x");
    1d0e:	85d6                	mv	a1,s5
    1d10:	855e                	mv	a0,s7
    1d12:	00004097          	auipc	ra,0x4
    1d16:	b96080e7          	jalr	-1130(ra) # 58a8 <link>
    1d1a:	bfe9                	j	1cf4 <linkunlink+0xa8>
  if(pid)
    1d1c:	020c0463          	beqz	s8,1d44 <linkunlink+0xf8>
    wait(0);
    1d20:	4501                	li	a0,0
    1d22:	00004097          	auipc	ra,0x4
    1d26:	b2e080e7          	jalr	-1234(ra) # 5850 <wait>
}
    1d2a:	60e6                	ld	ra,88(sp)
    1d2c:	6446                	ld	s0,80(sp)
    1d2e:	64a6                	ld	s1,72(sp)
    1d30:	6906                	ld	s2,64(sp)
    1d32:	79e2                	ld	s3,56(sp)
    1d34:	7a42                	ld	s4,48(sp)
    1d36:	7aa2                	ld	s5,40(sp)
    1d38:	7b02                	ld	s6,32(sp)
    1d3a:	6be2                	ld	s7,24(sp)
    1d3c:	6c42                	ld	s8,16(sp)
    1d3e:	6ca2                	ld	s9,8(sp)
    1d40:	6125                	addi	sp,sp,96
    1d42:	8082                	ret
    exit(0);
    1d44:	4501                	li	a0,0
    1d46:	00004097          	auipc	ra,0x4
    1d4a:	b02080e7          	jalr	-1278(ra) # 5848 <exit>

0000000000001d4e <forktest>:
{
    1d4e:	7179                	addi	sp,sp,-48
    1d50:	f406                	sd	ra,40(sp)
    1d52:	f022                	sd	s0,32(sp)
    1d54:	ec26                	sd	s1,24(sp)
    1d56:	e84a                	sd	s2,16(sp)
    1d58:	e44e                	sd	s3,8(sp)
    1d5a:	1800                	addi	s0,sp,48
    1d5c:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1d5e:	4481                	li	s1,0
    1d60:	3e800913          	li	s2,1000
    pid = fork();
    1d64:	00004097          	auipc	ra,0x4
    1d68:	adc080e7          	jalr	-1316(ra) # 5840 <fork>
    if(pid < 0)
    1d6c:	02054863          	bltz	a0,1d9c <forktest+0x4e>
    if(pid == 0)
    1d70:	c115                	beqz	a0,1d94 <forktest+0x46>
  for(n=0; n<N; n++){
    1d72:	2485                	addiw	s1,s1,1
    1d74:	ff2498e3          	bne	s1,s2,1d64 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1d78:	85ce                	mv	a1,s3
    1d7a:	00005517          	auipc	a0,0x5
    1d7e:	dbe50513          	addi	a0,a0,-578 # 6b38 <malloc+0xea2>
    1d82:	00004097          	auipc	ra,0x4
    1d86:	e56080e7          	jalr	-426(ra) # 5bd8 <printf>
    exit(1);
    1d8a:	4505                	li	a0,1
    1d8c:	00004097          	auipc	ra,0x4
    1d90:	abc080e7          	jalr	-1348(ra) # 5848 <exit>
      exit(0);
    1d94:	00004097          	auipc	ra,0x4
    1d98:	ab4080e7          	jalr	-1356(ra) # 5848 <exit>
  if (n == 0) {
    1d9c:	cc9d                	beqz	s1,1dda <forktest+0x8c>
  if(n == N){
    1d9e:	3e800793          	li	a5,1000
    1da2:	fcf48be3          	beq	s1,a5,1d78 <forktest+0x2a>
  for(; n > 0; n--){
    1da6:	00905b63          	blez	s1,1dbc <forktest+0x6e>
    if(wait(0) < 0){
    1daa:	4501                	li	a0,0
    1dac:	00004097          	auipc	ra,0x4
    1db0:	aa4080e7          	jalr	-1372(ra) # 5850 <wait>
    1db4:	04054163          	bltz	a0,1df6 <forktest+0xa8>
  for(; n > 0; n--){
    1db8:	34fd                	addiw	s1,s1,-1
    1dba:	f8e5                	bnez	s1,1daa <forktest+0x5c>
  if(wait(0) != -1){
    1dbc:	4501                	li	a0,0
    1dbe:	00004097          	auipc	ra,0x4
    1dc2:	a92080e7          	jalr	-1390(ra) # 5850 <wait>
    1dc6:	57fd                	li	a5,-1
    1dc8:	04f51563          	bne	a0,a5,1e12 <forktest+0xc4>
}
    1dcc:	70a2                	ld	ra,40(sp)
    1dce:	7402                	ld	s0,32(sp)
    1dd0:	64e2                	ld	s1,24(sp)
    1dd2:	6942                	ld	s2,16(sp)
    1dd4:	69a2                	ld	s3,8(sp)
    1dd6:	6145                	addi	sp,sp,48
    1dd8:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1dda:	85ce                	mv	a1,s3
    1ddc:	00005517          	auipc	a0,0x5
    1de0:	d4450513          	addi	a0,a0,-700 # 6b20 <malloc+0xe8a>
    1de4:	00004097          	auipc	ra,0x4
    1de8:	df4080e7          	jalr	-524(ra) # 5bd8 <printf>
    exit(1);
    1dec:	4505                	li	a0,1
    1dee:	00004097          	auipc	ra,0x4
    1df2:	a5a080e7          	jalr	-1446(ra) # 5848 <exit>
      printf("%s: wait stopped early\n", s);
    1df6:	85ce                	mv	a1,s3
    1df8:	00005517          	auipc	a0,0x5
    1dfc:	d6850513          	addi	a0,a0,-664 # 6b60 <malloc+0xeca>
    1e00:	00004097          	auipc	ra,0x4
    1e04:	dd8080e7          	jalr	-552(ra) # 5bd8 <printf>
      exit(1);
    1e08:	4505                	li	a0,1
    1e0a:	00004097          	auipc	ra,0x4
    1e0e:	a3e080e7          	jalr	-1474(ra) # 5848 <exit>
    printf("%s: wait got too many\n", s);
    1e12:	85ce                	mv	a1,s3
    1e14:	00005517          	auipc	a0,0x5
    1e18:	d6450513          	addi	a0,a0,-668 # 6b78 <malloc+0xee2>
    1e1c:	00004097          	auipc	ra,0x4
    1e20:	dbc080e7          	jalr	-580(ra) # 5bd8 <printf>
    exit(1);
    1e24:	4505                	li	a0,1
    1e26:	00004097          	auipc	ra,0x4
    1e2a:	a22080e7          	jalr	-1502(ra) # 5848 <exit>

0000000000001e2e <kernmem>:
{
    1e2e:	715d                	addi	sp,sp,-80
    1e30:	e486                	sd	ra,72(sp)
    1e32:	e0a2                	sd	s0,64(sp)
    1e34:	fc26                	sd	s1,56(sp)
    1e36:	f84a                	sd	s2,48(sp)
    1e38:	f44e                	sd	s3,40(sp)
    1e3a:	f052                	sd	s4,32(sp)
    1e3c:	ec56                	sd	s5,24(sp)
    1e3e:	0880                	addi	s0,sp,80
    1e40:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1e42:	4485                	li	s1,1
    1e44:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1e46:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1e48:	69b1                	lui	s3,0xc
    1e4a:	35098993          	addi	s3,s3,848 # c350 <buf+0x608>
    1e4e:	1003d937          	lui	s2,0x1003d
    1e52:	090e                	slli	s2,s2,0x3
    1e54:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e728>
    pid = fork();
    1e58:	00004097          	auipc	ra,0x4
    1e5c:	9e8080e7          	jalr	-1560(ra) # 5840 <fork>
    if(pid < 0){
    1e60:	02054963          	bltz	a0,1e92 <kernmem+0x64>
    if(pid == 0){
    1e64:	c529                	beqz	a0,1eae <kernmem+0x80>
    wait(&xstatus);
    1e66:	fbc40513          	addi	a0,s0,-68
    1e6a:	00004097          	auipc	ra,0x4
    1e6e:	9e6080e7          	jalr	-1562(ra) # 5850 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1e72:	fbc42783          	lw	a5,-68(s0)
    1e76:	05579d63          	bne	a5,s5,1ed0 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1e7a:	94ce                	add	s1,s1,s3
    1e7c:	fd249ee3          	bne	s1,s2,1e58 <kernmem+0x2a>
}
    1e80:	60a6                	ld	ra,72(sp)
    1e82:	6406                	ld	s0,64(sp)
    1e84:	74e2                	ld	s1,56(sp)
    1e86:	7942                	ld	s2,48(sp)
    1e88:	79a2                	ld	s3,40(sp)
    1e8a:	7a02                	ld	s4,32(sp)
    1e8c:	6ae2                	ld	s5,24(sp)
    1e8e:	6161                	addi	sp,sp,80
    1e90:	8082                	ret
      printf("%s: fork failed\n", s);
    1e92:	85d2                	mv	a1,s4
    1e94:	00005517          	auipc	a0,0x5
    1e98:	a2c50513          	addi	a0,a0,-1492 # 68c0 <malloc+0xc2a>
    1e9c:	00004097          	auipc	ra,0x4
    1ea0:	d3c080e7          	jalr	-708(ra) # 5bd8 <printf>
      exit(1);
    1ea4:	4505                	li	a0,1
    1ea6:	00004097          	auipc	ra,0x4
    1eaa:	9a2080e7          	jalr	-1630(ra) # 5848 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    1eae:	0004c683          	lbu	a3,0(s1)
    1eb2:	8626                	mv	a2,s1
    1eb4:	85d2                	mv	a1,s4
    1eb6:	00005517          	auipc	a0,0x5
    1eba:	cda50513          	addi	a0,a0,-806 # 6b90 <malloc+0xefa>
    1ebe:	00004097          	auipc	ra,0x4
    1ec2:	d1a080e7          	jalr	-742(ra) # 5bd8 <printf>
      exit(1);
    1ec6:	4505                	li	a0,1
    1ec8:	00004097          	auipc	ra,0x4
    1ecc:	980080e7          	jalr	-1664(ra) # 5848 <exit>
      exit(1);
    1ed0:	4505                	li	a0,1
    1ed2:	00004097          	auipc	ra,0x4
    1ed6:	976080e7          	jalr	-1674(ra) # 5848 <exit>

0000000000001eda <MAXVAplus>:
{
    1eda:	7179                	addi	sp,sp,-48
    1edc:	f406                	sd	ra,40(sp)
    1ede:	f022                	sd	s0,32(sp)
    1ee0:	ec26                	sd	s1,24(sp)
    1ee2:	e84a                	sd	s2,16(sp)
    1ee4:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    1ee6:	4785                	li	a5,1
    1ee8:	179a                	slli	a5,a5,0x26
    1eea:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    1eee:	fd843783          	ld	a5,-40(s0)
    1ef2:	cf85                	beqz	a5,1f2a <MAXVAplus+0x50>
    1ef4:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    1ef6:	54fd                	li	s1,-1
    pid = fork();
    1ef8:	00004097          	auipc	ra,0x4
    1efc:	948080e7          	jalr	-1720(ra) # 5840 <fork>
    if(pid < 0){
    1f00:	02054b63          	bltz	a0,1f36 <MAXVAplus+0x5c>
    if(pid == 0){
    1f04:	c539                	beqz	a0,1f52 <MAXVAplus+0x78>
    wait(&xstatus);
    1f06:	fd440513          	addi	a0,s0,-44
    1f0a:	00004097          	auipc	ra,0x4
    1f0e:	946080e7          	jalr	-1722(ra) # 5850 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1f12:	fd442783          	lw	a5,-44(s0)
    1f16:	06979463          	bne	a5,s1,1f7e <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    1f1a:	fd843783          	ld	a5,-40(s0)
    1f1e:	0786                	slli	a5,a5,0x1
    1f20:	fcf43c23          	sd	a5,-40(s0)
    1f24:	fd843783          	ld	a5,-40(s0)
    1f28:	fbe1                	bnez	a5,1ef8 <MAXVAplus+0x1e>
}
    1f2a:	70a2                	ld	ra,40(sp)
    1f2c:	7402                	ld	s0,32(sp)
    1f2e:	64e2                	ld	s1,24(sp)
    1f30:	6942                	ld	s2,16(sp)
    1f32:	6145                	addi	sp,sp,48
    1f34:	8082                	ret
      printf("%s: fork failed\n", s);
    1f36:	85ca                	mv	a1,s2
    1f38:	00005517          	auipc	a0,0x5
    1f3c:	98850513          	addi	a0,a0,-1656 # 68c0 <malloc+0xc2a>
    1f40:	00004097          	auipc	ra,0x4
    1f44:	c98080e7          	jalr	-872(ra) # 5bd8 <printf>
      exit(1);
    1f48:	4505                	li	a0,1
    1f4a:	00004097          	auipc	ra,0x4
    1f4e:	8fe080e7          	jalr	-1794(ra) # 5848 <exit>
      *(char*)a = 99;
    1f52:	fd843783          	ld	a5,-40(s0)
    1f56:	06300713          	li	a4,99
    1f5a:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    1f5e:	fd843603          	ld	a2,-40(s0)
    1f62:	85ca                	mv	a1,s2
    1f64:	00005517          	auipc	a0,0x5
    1f68:	c4c50513          	addi	a0,a0,-948 # 6bb0 <malloc+0xf1a>
    1f6c:	00004097          	auipc	ra,0x4
    1f70:	c6c080e7          	jalr	-916(ra) # 5bd8 <printf>
      exit(1);
    1f74:	4505                	li	a0,1
    1f76:	00004097          	auipc	ra,0x4
    1f7a:	8d2080e7          	jalr	-1838(ra) # 5848 <exit>
      exit(1);
    1f7e:	4505                	li	a0,1
    1f80:	00004097          	auipc	ra,0x4
    1f84:	8c8080e7          	jalr	-1848(ra) # 5848 <exit>

0000000000001f88 <bigargtest>:
{
    1f88:	7179                	addi	sp,sp,-48
    1f8a:	f406                	sd	ra,40(sp)
    1f8c:	f022                	sd	s0,32(sp)
    1f8e:	ec26                	sd	s1,24(sp)
    1f90:	1800                	addi	s0,sp,48
    1f92:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    1f94:	00005517          	auipc	a0,0x5
    1f98:	c3450513          	addi	a0,a0,-972 # 6bc8 <malloc+0xf32>
    1f9c:	00004097          	auipc	ra,0x4
    1fa0:	8fc080e7          	jalr	-1796(ra) # 5898 <unlink>
  pid = fork();
    1fa4:	00004097          	auipc	ra,0x4
    1fa8:	89c080e7          	jalr	-1892(ra) # 5840 <fork>
  if(pid == 0){
    1fac:	c121                	beqz	a0,1fec <bigargtest+0x64>
  } else if(pid < 0){
    1fae:	0a054063          	bltz	a0,204e <bigargtest+0xc6>
  wait(&xstatus);
    1fb2:	fdc40513          	addi	a0,s0,-36
    1fb6:	00004097          	auipc	ra,0x4
    1fba:	89a080e7          	jalr	-1894(ra) # 5850 <wait>
  if(xstatus != 0)
    1fbe:	fdc42503          	lw	a0,-36(s0)
    1fc2:	e545                	bnez	a0,206a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    1fc4:	4581                	li	a1,0
    1fc6:	00005517          	auipc	a0,0x5
    1fca:	c0250513          	addi	a0,a0,-1022 # 6bc8 <malloc+0xf32>
    1fce:	00004097          	auipc	ra,0x4
    1fd2:	8ba080e7          	jalr	-1862(ra) # 5888 <open>
  if(fd < 0){
    1fd6:	08054e63          	bltz	a0,2072 <bigargtest+0xea>
  close(fd);
    1fda:	00004097          	auipc	ra,0x4
    1fde:	896080e7          	jalr	-1898(ra) # 5870 <close>
}
    1fe2:	70a2                	ld	ra,40(sp)
    1fe4:	7402                	ld	s0,32(sp)
    1fe6:	64e2                	ld	s1,24(sp)
    1fe8:	6145                	addi	sp,sp,48
    1fea:	8082                	ret
    1fec:	00006797          	auipc	a5,0x6
    1ff0:	54478793          	addi	a5,a5,1348 # 8530 <args.1864>
    1ff4:	00006697          	auipc	a3,0x6
    1ff8:	63468693          	addi	a3,a3,1588 # 8628 <args.1864+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1ffc:	00005717          	auipc	a4,0x5
    2000:	bdc70713          	addi	a4,a4,-1060 # 6bd8 <malloc+0xf42>
    2004:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2006:	07a1                	addi	a5,a5,8
    2008:	fed79ee3          	bne	a5,a3,2004 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    200c:	00006597          	auipc	a1,0x6
    2010:	52458593          	addi	a1,a1,1316 # 8530 <args.1864>
    2014:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2018:	00004517          	auipc	a0,0x4
    201c:	0d850513          	addi	a0,a0,216 # 60f0 <malloc+0x45a>
    2020:	00004097          	auipc	ra,0x4
    2024:	860080e7          	jalr	-1952(ra) # 5880 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2028:	20000593          	li	a1,512
    202c:	00005517          	auipc	a0,0x5
    2030:	b9c50513          	addi	a0,a0,-1124 # 6bc8 <malloc+0xf32>
    2034:	00004097          	auipc	ra,0x4
    2038:	854080e7          	jalr	-1964(ra) # 5888 <open>
    close(fd);
    203c:	00004097          	auipc	ra,0x4
    2040:	834080e7          	jalr	-1996(ra) # 5870 <close>
    exit(0);
    2044:	4501                	li	a0,0
    2046:	00004097          	auipc	ra,0x4
    204a:	802080e7          	jalr	-2046(ra) # 5848 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    204e:	85a6                	mv	a1,s1
    2050:	00005517          	auipc	a0,0x5
    2054:	c6850513          	addi	a0,a0,-920 # 6cb8 <malloc+0x1022>
    2058:	00004097          	auipc	ra,0x4
    205c:	b80080e7          	jalr	-1152(ra) # 5bd8 <printf>
    exit(1);
    2060:	4505                	li	a0,1
    2062:	00003097          	auipc	ra,0x3
    2066:	7e6080e7          	jalr	2022(ra) # 5848 <exit>
    exit(xstatus);
    206a:	00003097          	auipc	ra,0x3
    206e:	7de080e7          	jalr	2014(ra) # 5848 <exit>
    printf("%s: bigarg test failed!\n", s);
    2072:	85a6                	mv	a1,s1
    2074:	00005517          	auipc	a0,0x5
    2078:	c6450513          	addi	a0,a0,-924 # 6cd8 <malloc+0x1042>
    207c:	00004097          	auipc	ra,0x4
    2080:	b5c080e7          	jalr	-1188(ra) # 5bd8 <printf>
    exit(1);
    2084:	4505                	li	a0,1
    2086:	00003097          	auipc	ra,0x3
    208a:	7c2080e7          	jalr	1986(ra) # 5848 <exit>

000000000000208e <stacktest>:
{
    208e:	7179                	addi	sp,sp,-48
    2090:	f406                	sd	ra,40(sp)
    2092:	f022                	sd	s0,32(sp)
    2094:	ec26                	sd	s1,24(sp)
    2096:	1800                	addi	s0,sp,48
    2098:	84aa                	mv	s1,a0
  pid = fork();
    209a:	00003097          	auipc	ra,0x3
    209e:	7a6080e7          	jalr	1958(ra) # 5840 <fork>
  if(pid == 0) {
    20a2:	c115                	beqz	a0,20c6 <stacktest+0x38>
  } else if(pid < 0){
    20a4:	04054463          	bltz	a0,20ec <stacktest+0x5e>
  wait(&xstatus);
    20a8:	fdc40513          	addi	a0,s0,-36
    20ac:	00003097          	auipc	ra,0x3
    20b0:	7a4080e7          	jalr	1956(ra) # 5850 <wait>
  if(xstatus == -1)  // kernel killed child?
    20b4:	fdc42503          	lw	a0,-36(s0)
    20b8:	57fd                	li	a5,-1
    20ba:	04f50763          	beq	a0,a5,2108 <stacktest+0x7a>
    exit(xstatus);
    20be:	00003097          	auipc	ra,0x3
    20c2:	78a080e7          	jalr	1930(ra) # 5848 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    20c6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    20c8:	77fd                	lui	a5,0xfffff
    20ca:	97ba                	add	a5,a5,a4
    20cc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff02a8>
    20d0:	85a6                	mv	a1,s1
    20d2:	00005517          	auipc	a0,0x5
    20d6:	c2650513          	addi	a0,a0,-986 # 6cf8 <malloc+0x1062>
    20da:	00004097          	auipc	ra,0x4
    20de:	afe080e7          	jalr	-1282(ra) # 5bd8 <printf>
    exit(1);
    20e2:	4505                	li	a0,1
    20e4:	00003097          	auipc	ra,0x3
    20e8:	764080e7          	jalr	1892(ra) # 5848 <exit>
    printf("%s: fork failed\n", s);
    20ec:	85a6                	mv	a1,s1
    20ee:	00004517          	auipc	a0,0x4
    20f2:	7d250513          	addi	a0,a0,2002 # 68c0 <malloc+0xc2a>
    20f6:	00004097          	auipc	ra,0x4
    20fa:	ae2080e7          	jalr	-1310(ra) # 5bd8 <printf>
    exit(1);
    20fe:	4505                	li	a0,1
    2100:	00003097          	auipc	ra,0x3
    2104:	748080e7          	jalr	1864(ra) # 5848 <exit>
    exit(0);
    2108:	4501                	li	a0,0
    210a:	00003097          	auipc	ra,0x3
    210e:	73e080e7          	jalr	1854(ra) # 5848 <exit>

0000000000002112 <copyinstr3>:
{
    2112:	7179                	addi	sp,sp,-48
    2114:	f406                	sd	ra,40(sp)
    2116:	f022                	sd	s0,32(sp)
    2118:	ec26                	sd	s1,24(sp)
    211a:	1800                	addi	s0,sp,48
  sbrk(8192);
    211c:	6509                	lui	a0,0x2
    211e:	00003097          	auipc	ra,0x3
    2122:	7b2080e7          	jalr	1970(ra) # 58d0 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2126:	4501                	li	a0,0
    2128:	00003097          	auipc	ra,0x3
    212c:	7a8080e7          	jalr	1960(ra) # 58d0 <sbrk>
  if((top % PGSIZE) != 0){
    2130:	03451793          	slli	a5,a0,0x34
    2134:	e3c9                	bnez	a5,21b6 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2136:	4501                	li	a0,0
    2138:	00003097          	auipc	ra,0x3
    213c:	798080e7          	jalr	1944(ra) # 58d0 <sbrk>
  if(top % PGSIZE){
    2140:	03451793          	slli	a5,a0,0x34
    2144:	e3d9                	bnez	a5,21ca <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2146:	fff50493          	addi	s1,a0,-1 # 1fff <bigargtest+0x77>
  *b = 'x';
    214a:	07800793          	li	a5,120
    214e:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2152:	8526                	mv	a0,s1
    2154:	00003097          	auipc	ra,0x3
    2158:	744080e7          	jalr	1860(ra) # 5898 <unlink>
  if(ret != -1){
    215c:	57fd                	li	a5,-1
    215e:	08f51363          	bne	a0,a5,21e4 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2162:	20100593          	li	a1,513
    2166:	8526                	mv	a0,s1
    2168:	00003097          	auipc	ra,0x3
    216c:	720080e7          	jalr	1824(ra) # 5888 <open>
  if(fd != -1){
    2170:	57fd                	li	a5,-1
    2172:	08f51863          	bne	a0,a5,2202 <copyinstr3+0xf0>
  ret = link(b, b);
    2176:	85a6                	mv	a1,s1
    2178:	8526                	mv	a0,s1
    217a:	00003097          	auipc	ra,0x3
    217e:	72e080e7          	jalr	1838(ra) # 58a8 <link>
  if(ret != -1){
    2182:	57fd                	li	a5,-1
    2184:	08f51e63          	bne	a0,a5,2220 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2188:	00006797          	auipc	a5,0x6
    218c:	80878793          	addi	a5,a5,-2040 # 7990 <malloc+0x1cfa>
    2190:	fcf43823          	sd	a5,-48(s0)
    2194:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2198:	fd040593          	addi	a1,s0,-48
    219c:	8526                	mv	a0,s1
    219e:	00003097          	auipc	ra,0x3
    21a2:	6e2080e7          	jalr	1762(ra) # 5880 <exec>
  if(ret != -1){
    21a6:	57fd                	li	a5,-1
    21a8:	08f51c63          	bne	a0,a5,2240 <copyinstr3+0x12e>
}
    21ac:	70a2                	ld	ra,40(sp)
    21ae:	7402                	ld	s0,32(sp)
    21b0:	64e2                	ld	s1,24(sp)
    21b2:	6145                	addi	sp,sp,48
    21b4:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    21b6:	0347d513          	srli	a0,a5,0x34
    21ba:	6785                	lui	a5,0x1
    21bc:	40a7853b          	subw	a0,a5,a0
    21c0:	00003097          	auipc	ra,0x3
    21c4:	710080e7          	jalr	1808(ra) # 58d0 <sbrk>
    21c8:	b7bd                	j	2136 <copyinstr3+0x24>
    printf("oops\n");
    21ca:	00005517          	auipc	a0,0x5
    21ce:	b5650513          	addi	a0,a0,-1194 # 6d20 <malloc+0x108a>
    21d2:	00004097          	auipc	ra,0x4
    21d6:	a06080e7          	jalr	-1530(ra) # 5bd8 <printf>
    exit(1);
    21da:	4505                	li	a0,1
    21dc:	00003097          	auipc	ra,0x3
    21e0:	66c080e7          	jalr	1644(ra) # 5848 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    21e4:	862a                	mv	a2,a0
    21e6:	85a6                	mv	a1,s1
    21e8:	00004517          	auipc	a0,0x4
    21ec:	5f850513          	addi	a0,a0,1528 # 67e0 <malloc+0xb4a>
    21f0:	00004097          	auipc	ra,0x4
    21f4:	9e8080e7          	jalr	-1560(ra) # 5bd8 <printf>
    exit(1);
    21f8:	4505                	li	a0,1
    21fa:	00003097          	auipc	ra,0x3
    21fe:	64e080e7          	jalr	1614(ra) # 5848 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2202:	862a                	mv	a2,a0
    2204:	85a6                	mv	a1,s1
    2206:	00004517          	auipc	a0,0x4
    220a:	5fa50513          	addi	a0,a0,1530 # 6800 <malloc+0xb6a>
    220e:	00004097          	auipc	ra,0x4
    2212:	9ca080e7          	jalr	-1590(ra) # 5bd8 <printf>
    exit(1);
    2216:	4505                	li	a0,1
    2218:	00003097          	auipc	ra,0x3
    221c:	630080e7          	jalr	1584(ra) # 5848 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2220:	86aa                	mv	a3,a0
    2222:	8626                	mv	a2,s1
    2224:	85a6                	mv	a1,s1
    2226:	00004517          	auipc	a0,0x4
    222a:	5fa50513          	addi	a0,a0,1530 # 6820 <malloc+0xb8a>
    222e:	00004097          	auipc	ra,0x4
    2232:	9aa080e7          	jalr	-1622(ra) # 5bd8 <printf>
    exit(1);
    2236:	4505                	li	a0,1
    2238:	00003097          	auipc	ra,0x3
    223c:	610080e7          	jalr	1552(ra) # 5848 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2240:	567d                	li	a2,-1
    2242:	85a6                	mv	a1,s1
    2244:	00004517          	auipc	a0,0x4
    2248:	60450513          	addi	a0,a0,1540 # 6848 <malloc+0xbb2>
    224c:	00004097          	auipc	ra,0x4
    2250:	98c080e7          	jalr	-1652(ra) # 5bd8 <printf>
    exit(1);
    2254:	4505                	li	a0,1
    2256:	00003097          	auipc	ra,0x3
    225a:	5f2080e7          	jalr	1522(ra) # 5848 <exit>

000000000000225e <rwsbrk>:
{
    225e:	1101                	addi	sp,sp,-32
    2260:	ec06                	sd	ra,24(sp)
    2262:	e822                	sd	s0,16(sp)
    2264:	e426                	sd	s1,8(sp)
    2266:	e04a                	sd	s2,0(sp)
    2268:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    226a:	6509                	lui	a0,0x2
    226c:	00003097          	auipc	ra,0x3
    2270:	664080e7          	jalr	1636(ra) # 58d0 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2274:	57fd                	li	a5,-1
    2276:	06f50363          	beq	a0,a5,22dc <rwsbrk+0x7e>
    227a:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    227c:	7579                	lui	a0,0xffffe
    227e:	00003097          	auipc	ra,0x3
    2282:	652080e7          	jalr	1618(ra) # 58d0 <sbrk>
    2286:	57fd                	li	a5,-1
    2288:	06f50763          	beq	a0,a5,22f6 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    228c:	20100593          	li	a1,513
    2290:	00004517          	auipc	a0,0x4
    2294:	b6850513          	addi	a0,a0,-1176 # 5df8 <malloc+0x162>
    2298:	00003097          	auipc	ra,0x3
    229c:	5f0080e7          	jalr	1520(ra) # 5888 <open>
    22a0:	892a                	mv	s2,a0
  if(fd < 0){
    22a2:	06054763          	bltz	a0,2310 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    22a6:	6505                	lui	a0,0x1
    22a8:	94aa                	add	s1,s1,a0
    22aa:	40000613          	li	a2,1024
    22ae:	85a6                	mv	a1,s1
    22b0:	854a                	mv	a0,s2
    22b2:	00003097          	auipc	ra,0x3
    22b6:	5b6080e7          	jalr	1462(ra) # 5868 <write>
    22ba:	862a                	mv	a2,a0
  if(n >= 0){
    22bc:	06054763          	bltz	a0,232a <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    22c0:	85a6                	mv	a1,s1
    22c2:	00005517          	auipc	a0,0x5
    22c6:	ab650513          	addi	a0,a0,-1354 # 6d78 <malloc+0x10e2>
    22ca:	00004097          	auipc	ra,0x4
    22ce:	90e080e7          	jalr	-1778(ra) # 5bd8 <printf>
    exit(1);
    22d2:	4505                	li	a0,1
    22d4:	00003097          	auipc	ra,0x3
    22d8:	574080e7          	jalr	1396(ra) # 5848 <exit>
    printf("sbrk(rwsbrk) failed\n");
    22dc:	00005517          	auipc	a0,0x5
    22e0:	a4c50513          	addi	a0,a0,-1460 # 6d28 <malloc+0x1092>
    22e4:	00004097          	auipc	ra,0x4
    22e8:	8f4080e7          	jalr	-1804(ra) # 5bd8 <printf>
    exit(1);
    22ec:	4505                	li	a0,1
    22ee:	00003097          	auipc	ra,0x3
    22f2:	55a080e7          	jalr	1370(ra) # 5848 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    22f6:	00005517          	auipc	a0,0x5
    22fa:	a4a50513          	addi	a0,a0,-1462 # 6d40 <malloc+0x10aa>
    22fe:	00004097          	auipc	ra,0x4
    2302:	8da080e7          	jalr	-1830(ra) # 5bd8 <printf>
    exit(1);
    2306:	4505                	li	a0,1
    2308:	00003097          	auipc	ra,0x3
    230c:	540080e7          	jalr	1344(ra) # 5848 <exit>
    printf("open(rwsbrk) failed\n");
    2310:	00005517          	auipc	a0,0x5
    2314:	a5050513          	addi	a0,a0,-1456 # 6d60 <malloc+0x10ca>
    2318:	00004097          	auipc	ra,0x4
    231c:	8c0080e7          	jalr	-1856(ra) # 5bd8 <printf>
    exit(1);
    2320:	4505                	li	a0,1
    2322:	00003097          	auipc	ra,0x3
    2326:	526080e7          	jalr	1318(ra) # 5848 <exit>
  close(fd);
    232a:	854a                	mv	a0,s2
    232c:	00003097          	auipc	ra,0x3
    2330:	544080e7          	jalr	1348(ra) # 5870 <close>
  unlink("rwsbrk");
    2334:	00004517          	auipc	a0,0x4
    2338:	ac450513          	addi	a0,a0,-1340 # 5df8 <malloc+0x162>
    233c:	00003097          	auipc	ra,0x3
    2340:	55c080e7          	jalr	1372(ra) # 5898 <unlink>
  fd = open("README", O_RDONLY);
    2344:	4581                	li	a1,0
    2346:	00004517          	auipc	a0,0x4
    234a:	f4250513          	addi	a0,a0,-190 # 6288 <malloc+0x5f2>
    234e:	00003097          	auipc	ra,0x3
    2352:	53a080e7          	jalr	1338(ra) # 5888 <open>
    2356:	892a                	mv	s2,a0
  if(fd < 0){
    2358:	02054963          	bltz	a0,238a <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    235c:	4629                	li	a2,10
    235e:	85a6                	mv	a1,s1
    2360:	00003097          	auipc	ra,0x3
    2364:	500080e7          	jalr	1280(ra) # 5860 <read>
    2368:	862a                	mv	a2,a0
  if(n >= 0){
    236a:	02054d63          	bltz	a0,23a4 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    236e:	85a6                	mv	a1,s1
    2370:	00005517          	auipc	a0,0x5
    2374:	a3850513          	addi	a0,a0,-1480 # 6da8 <malloc+0x1112>
    2378:	00004097          	auipc	ra,0x4
    237c:	860080e7          	jalr	-1952(ra) # 5bd8 <printf>
    exit(1);
    2380:	4505                	li	a0,1
    2382:	00003097          	auipc	ra,0x3
    2386:	4c6080e7          	jalr	1222(ra) # 5848 <exit>
    printf("open(rwsbrk) failed\n");
    238a:	00005517          	auipc	a0,0x5
    238e:	9d650513          	addi	a0,a0,-1578 # 6d60 <malloc+0x10ca>
    2392:	00004097          	auipc	ra,0x4
    2396:	846080e7          	jalr	-1978(ra) # 5bd8 <printf>
    exit(1);
    239a:	4505                	li	a0,1
    239c:	00003097          	auipc	ra,0x3
    23a0:	4ac080e7          	jalr	1196(ra) # 5848 <exit>
  close(fd);
    23a4:	854a                	mv	a0,s2
    23a6:	00003097          	auipc	ra,0x3
    23aa:	4ca080e7          	jalr	1226(ra) # 5870 <close>
  exit(0);
    23ae:	4501                	li	a0,0
    23b0:	00003097          	auipc	ra,0x3
    23b4:	498080e7          	jalr	1176(ra) # 5848 <exit>

00000000000023b8 <sbrkbasic>:
{
    23b8:	715d                	addi	sp,sp,-80
    23ba:	e486                	sd	ra,72(sp)
    23bc:	e0a2                	sd	s0,64(sp)
    23be:	fc26                	sd	s1,56(sp)
    23c0:	f84a                	sd	s2,48(sp)
    23c2:	f44e                	sd	s3,40(sp)
    23c4:	f052                	sd	s4,32(sp)
    23c6:	ec56                	sd	s5,24(sp)
    23c8:	0880                	addi	s0,sp,80
    23ca:	8a2a                	mv	s4,a0
  pid = fork();
    23cc:	00003097          	auipc	ra,0x3
    23d0:	474080e7          	jalr	1140(ra) # 5840 <fork>
  if(pid < 0){
    23d4:	02054c63          	bltz	a0,240c <sbrkbasic+0x54>
  if(pid == 0){
    23d8:	ed21                	bnez	a0,2430 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    23da:	40000537          	lui	a0,0x40000
    23de:	00003097          	auipc	ra,0x3
    23e2:	4f2080e7          	jalr	1266(ra) # 58d0 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    23e6:	57fd                	li	a5,-1
    23e8:	02f50f63          	beq	a0,a5,2426 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    23ec:	400007b7          	lui	a5,0x40000
    23f0:	97aa                	add	a5,a5,a0
      *b = 99;
    23f2:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    23f6:	6705                	lui	a4,0x1
      *b = 99;
    23f8:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff12a8>
    for(b = a; b < a+TOOMUCH; b += 4096){
    23fc:	953a                	add	a0,a0,a4
    23fe:	fef51de3          	bne	a0,a5,23f8 <sbrkbasic+0x40>
    exit(1);
    2402:	4505                	li	a0,1
    2404:	00003097          	auipc	ra,0x3
    2408:	444080e7          	jalr	1092(ra) # 5848 <exit>
    printf("fork failed in sbrkbasic\n");
    240c:	00005517          	auipc	a0,0x5
    2410:	9c450513          	addi	a0,a0,-1596 # 6dd0 <malloc+0x113a>
    2414:	00003097          	auipc	ra,0x3
    2418:	7c4080e7          	jalr	1988(ra) # 5bd8 <printf>
    exit(1);
    241c:	4505                	li	a0,1
    241e:	00003097          	auipc	ra,0x3
    2422:	42a080e7          	jalr	1066(ra) # 5848 <exit>
      exit(0);
    2426:	4501                	li	a0,0
    2428:	00003097          	auipc	ra,0x3
    242c:	420080e7          	jalr	1056(ra) # 5848 <exit>
  wait(&xstatus);
    2430:	fbc40513          	addi	a0,s0,-68
    2434:	00003097          	auipc	ra,0x3
    2438:	41c080e7          	jalr	1052(ra) # 5850 <wait>
  if(xstatus == 1){
    243c:	fbc42703          	lw	a4,-68(s0)
    2440:	4785                	li	a5,1
    2442:	00f70e63          	beq	a4,a5,245e <sbrkbasic+0xa6>
  a = sbrk(0);
    2446:	4501                	li	a0,0
    2448:	00003097          	auipc	ra,0x3
    244c:	488080e7          	jalr	1160(ra) # 58d0 <sbrk>
    2450:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2452:	4901                	li	s2,0
    *b = 1;
    2454:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    2456:	6985                	lui	s3,0x1
    2458:	38898993          	addi	s3,s3,904 # 1388 <truncate3+0x144>
    245c:	a005                	j	247c <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    245e:	85d2                	mv	a1,s4
    2460:	00005517          	auipc	a0,0x5
    2464:	99050513          	addi	a0,a0,-1648 # 6df0 <malloc+0x115a>
    2468:	00003097          	auipc	ra,0x3
    246c:	770080e7          	jalr	1904(ra) # 5bd8 <printf>
    exit(1);
    2470:	4505                	li	a0,1
    2472:	00003097          	auipc	ra,0x3
    2476:	3d6080e7          	jalr	982(ra) # 5848 <exit>
    a = b + 1;
    247a:	84be                	mv	s1,a5
    b = sbrk(1);
    247c:	4505                	li	a0,1
    247e:	00003097          	auipc	ra,0x3
    2482:	452080e7          	jalr	1106(ra) # 58d0 <sbrk>
    if(b != a){
    2486:	04951b63          	bne	a0,s1,24dc <sbrkbasic+0x124>
    *b = 1;
    248a:	01548023          	sb	s5,0(s1)
    a = b + 1;
    248e:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2492:	2905                	addiw	s2,s2,1
    2494:	ff3913e3          	bne	s2,s3,247a <sbrkbasic+0xc2>
  pid = fork();
    2498:	00003097          	auipc	ra,0x3
    249c:	3a8080e7          	jalr	936(ra) # 5840 <fork>
    24a0:	892a                	mv	s2,a0
  if(pid < 0){
    24a2:	04054e63          	bltz	a0,24fe <sbrkbasic+0x146>
  c = sbrk(1);
    24a6:	4505                	li	a0,1
    24a8:	00003097          	auipc	ra,0x3
    24ac:	428080e7          	jalr	1064(ra) # 58d0 <sbrk>
  c = sbrk(1);
    24b0:	4505                	li	a0,1
    24b2:	00003097          	auipc	ra,0x3
    24b6:	41e080e7          	jalr	1054(ra) # 58d0 <sbrk>
  if(c != a + 1){
    24ba:	0489                	addi	s1,s1,2
    24bc:	04a48f63          	beq	s1,a0,251a <sbrkbasic+0x162>
    printf("%s: sbrk test failed post-fork\n", s);
    24c0:	85d2                	mv	a1,s4
    24c2:	00005517          	auipc	a0,0x5
    24c6:	98e50513          	addi	a0,a0,-1650 # 6e50 <malloc+0x11ba>
    24ca:	00003097          	auipc	ra,0x3
    24ce:	70e080e7          	jalr	1806(ra) # 5bd8 <printf>
    exit(1);
    24d2:	4505                	li	a0,1
    24d4:	00003097          	auipc	ra,0x3
    24d8:	374080e7          	jalr	884(ra) # 5848 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    24dc:	872a                	mv	a4,a0
    24de:	86a6                	mv	a3,s1
    24e0:	864a                	mv	a2,s2
    24e2:	85d2                	mv	a1,s4
    24e4:	00005517          	auipc	a0,0x5
    24e8:	92c50513          	addi	a0,a0,-1748 # 6e10 <malloc+0x117a>
    24ec:	00003097          	auipc	ra,0x3
    24f0:	6ec080e7          	jalr	1772(ra) # 5bd8 <printf>
      exit(1);
    24f4:	4505                	li	a0,1
    24f6:	00003097          	auipc	ra,0x3
    24fa:	352080e7          	jalr	850(ra) # 5848 <exit>
    printf("%s: sbrk test fork failed\n", s);
    24fe:	85d2                	mv	a1,s4
    2500:	00005517          	auipc	a0,0x5
    2504:	93050513          	addi	a0,a0,-1744 # 6e30 <malloc+0x119a>
    2508:	00003097          	auipc	ra,0x3
    250c:	6d0080e7          	jalr	1744(ra) # 5bd8 <printf>
    exit(1);
    2510:	4505                	li	a0,1
    2512:	00003097          	auipc	ra,0x3
    2516:	336080e7          	jalr	822(ra) # 5848 <exit>
  if(pid == 0)
    251a:	00091763          	bnez	s2,2528 <sbrkbasic+0x170>
    exit(0);
    251e:	4501                	li	a0,0
    2520:	00003097          	auipc	ra,0x3
    2524:	328080e7          	jalr	808(ra) # 5848 <exit>
  wait(&xstatus);
    2528:	fbc40513          	addi	a0,s0,-68
    252c:	00003097          	auipc	ra,0x3
    2530:	324080e7          	jalr	804(ra) # 5850 <wait>
  exit(xstatus);
    2534:	fbc42503          	lw	a0,-68(s0)
    2538:	00003097          	auipc	ra,0x3
    253c:	310080e7          	jalr	784(ra) # 5848 <exit>

0000000000002540 <sbrkmuch>:
{
    2540:	7179                	addi	sp,sp,-48
    2542:	f406                	sd	ra,40(sp)
    2544:	f022                	sd	s0,32(sp)
    2546:	ec26                	sd	s1,24(sp)
    2548:	e84a                	sd	s2,16(sp)
    254a:	e44e                	sd	s3,8(sp)
    254c:	e052                	sd	s4,0(sp)
    254e:	1800                	addi	s0,sp,48
    2550:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2552:	4501                	li	a0,0
    2554:	00003097          	auipc	ra,0x3
    2558:	37c080e7          	jalr	892(ra) # 58d0 <sbrk>
    255c:	892a                	mv	s2,a0
  a = sbrk(0);
    255e:	4501                	li	a0,0
    2560:	00003097          	auipc	ra,0x3
    2564:	370080e7          	jalr	880(ra) # 58d0 <sbrk>
    2568:	84aa                	mv	s1,a0
  p = sbrk(amt);
    256a:	06400537          	lui	a0,0x6400
    256e:	9d05                	subw	a0,a0,s1
    2570:	00003097          	auipc	ra,0x3
    2574:	360080e7          	jalr	864(ra) # 58d0 <sbrk>
  if (p != a) {
    2578:	0ca49863          	bne	s1,a0,2648 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    257c:	4501                	li	a0,0
    257e:	00003097          	auipc	ra,0x3
    2582:	352080e7          	jalr	850(ra) # 58d0 <sbrk>
    2586:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2588:	00a4f963          	bgeu	s1,a0,259a <sbrkmuch+0x5a>
    *pp = 1;
    258c:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    258e:	6705                	lui	a4,0x1
    *pp = 1;
    2590:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2594:	94ba                	add	s1,s1,a4
    2596:	fef4ede3          	bltu	s1,a5,2590 <sbrkmuch+0x50>
  *lastaddr = 99;
    259a:	064007b7          	lui	a5,0x6400
    259e:	06300713          	li	a4,99
    25a2:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f12a7>
  a = sbrk(0);
    25a6:	4501                	li	a0,0
    25a8:	00003097          	auipc	ra,0x3
    25ac:	328080e7          	jalr	808(ra) # 58d0 <sbrk>
    25b0:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    25b2:	757d                	lui	a0,0xfffff
    25b4:	00003097          	auipc	ra,0x3
    25b8:	31c080e7          	jalr	796(ra) # 58d0 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    25bc:	57fd                	li	a5,-1
    25be:	0af50363          	beq	a0,a5,2664 <sbrkmuch+0x124>
  c = sbrk(0);
    25c2:	4501                	li	a0,0
    25c4:	00003097          	auipc	ra,0x3
    25c8:	30c080e7          	jalr	780(ra) # 58d0 <sbrk>
  if(c != a - PGSIZE){
    25cc:	77fd                	lui	a5,0xfffff
    25ce:	97a6                	add	a5,a5,s1
    25d0:	0af51863          	bne	a0,a5,2680 <sbrkmuch+0x140>
  a = sbrk(0);
    25d4:	4501                	li	a0,0
    25d6:	00003097          	auipc	ra,0x3
    25da:	2fa080e7          	jalr	762(ra) # 58d0 <sbrk>
    25de:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    25e0:	6505                	lui	a0,0x1
    25e2:	00003097          	auipc	ra,0x3
    25e6:	2ee080e7          	jalr	750(ra) # 58d0 <sbrk>
    25ea:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    25ec:	0aa49a63          	bne	s1,a0,26a0 <sbrkmuch+0x160>
    25f0:	4501                	li	a0,0
    25f2:	00003097          	auipc	ra,0x3
    25f6:	2de080e7          	jalr	734(ra) # 58d0 <sbrk>
    25fa:	6785                	lui	a5,0x1
    25fc:	97a6                	add	a5,a5,s1
    25fe:	0af51163          	bne	a0,a5,26a0 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2602:	064007b7          	lui	a5,0x6400
    2606:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f12a7>
    260a:	06300793          	li	a5,99
    260e:	0af70963          	beq	a4,a5,26c0 <sbrkmuch+0x180>
  a = sbrk(0);
    2612:	4501                	li	a0,0
    2614:	00003097          	auipc	ra,0x3
    2618:	2bc080e7          	jalr	700(ra) # 58d0 <sbrk>
    261c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    261e:	4501                	li	a0,0
    2620:	00003097          	auipc	ra,0x3
    2624:	2b0080e7          	jalr	688(ra) # 58d0 <sbrk>
    2628:	40a9053b          	subw	a0,s2,a0
    262c:	00003097          	auipc	ra,0x3
    2630:	2a4080e7          	jalr	676(ra) # 58d0 <sbrk>
  if(c != a){
    2634:	0aa49463          	bne	s1,a0,26dc <sbrkmuch+0x19c>
}
    2638:	70a2                	ld	ra,40(sp)
    263a:	7402                	ld	s0,32(sp)
    263c:	64e2                	ld	s1,24(sp)
    263e:	6942                	ld	s2,16(sp)
    2640:	69a2                	ld	s3,8(sp)
    2642:	6a02                	ld	s4,0(sp)
    2644:	6145                	addi	sp,sp,48
    2646:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2648:	85ce                	mv	a1,s3
    264a:	00005517          	auipc	a0,0x5
    264e:	82650513          	addi	a0,a0,-2010 # 6e70 <malloc+0x11da>
    2652:	00003097          	auipc	ra,0x3
    2656:	586080e7          	jalr	1414(ra) # 5bd8 <printf>
    exit(1);
    265a:	4505                	li	a0,1
    265c:	00003097          	auipc	ra,0x3
    2660:	1ec080e7          	jalr	492(ra) # 5848 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2664:	85ce                	mv	a1,s3
    2666:	00005517          	auipc	a0,0x5
    266a:	85250513          	addi	a0,a0,-1966 # 6eb8 <malloc+0x1222>
    266e:	00003097          	auipc	ra,0x3
    2672:	56a080e7          	jalr	1386(ra) # 5bd8 <printf>
    exit(1);
    2676:	4505                	li	a0,1
    2678:	00003097          	auipc	ra,0x3
    267c:	1d0080e7          	jalr	464(ra) # 5848 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2680:	86aa                	mv	a3,a0
    2682:	8626                	mv	a2,s1
    2684:	85ce                	mv	a1,s3
    2686:	00005517          	auipc	a0,0x5
    268a:	85250513          	addi	a0,a0,-1966 # 6ed8 <malloc+0x1242>
    268e:	00003097          	auipc	ra,0x3
    2692:	54a080e7          	jalr	1354(ra) # 5bd8 <printf>
    exit(1);
    2696:	4505                	li	a0,1
    2698:	00003097          	auipc	ra,0x3
    269c:	1b0080e7          	jalr	432(ra) # 5848 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    26a0:	86d2                	mv	a3,s4
    26a2:	8626                	mv	a2,s1
    26a4:	85ce                	mv	a1,s3
    26a6:	00005517          	auipc	a0,0x5
    26aa:	87250513          	addi	a0,a0,-1934 # 6f18 <malloc+0x1282>
    26ae:	00003097          	auipc	ra,0x3
    26b2:	52a080e7          	jalr	1322(ra) # 5bd8 <printf>
    exit(1);
    26b6:	4505                	li	a0,1
    26b8:	00003097          	auipc	ra,0x3
    26bc:	190080e7          	jalr	400(ra) # 5848 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    26c0:	85ce                	mv	a1,s3
    26c2:	00005517          	auipc	a0,0x5
    26c6:	88650513          	addi	a0,a0,-1914 # 6f48 <malloc+0x12b2>
    26ca:	00003097          	auipc	ra,0x3
    26ce:	50e080e7          	jalr	1294(ra) # 5bd8 <printf>
    exit(1);
    26d2:	4505                	li	a0,1
    26d4:	00003097          	auipc	ra,0x3
    26d8:	174080e7          	jalr	372(ra) # 5848 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    26dc:	86aa                	mv	a3,a0
    26de:	8626                	mv	a2,s1
    26e0:	85ce                	mv	a1,s3
    26e2:	00005517          	auipc	a0,0x5
    26e6:	89e50513          	addi	a0,a0,-1890 # 6f80 <malloc+0x12ea>
    26ea:	00003097          	auipc	ra,0x3
    26ee:	4ee080e7          	jalr	1262(ra) # 5bd8 <printf>
    exit(1);
    26f2:	4505                	li	a0,1
    26f4:	00003097          	auipc	ra,0x3
    26f8:	154080e7          	jalr	340(ra) # 5848 <exit>

00000000000026fc <sbrkarg>:
{
    26fc:	7179                	addi	sp,sp,-48
    26fe:	f406                	sd	ra,40(sp)
    2700:	f022                	sd	s0,32(sp)
    2702:	ec26                	sd	s1,24(sp)
    2704:	e84a                	sd	s2,16(sp)
    2706:	e44e                	sd	s3,8(sp)
    2708:	1800                	addi	s0,sp,48
    270a:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    270c:	6505                	lui	a0,0x1
    270e:	00003097          	auipc	ra,0x3
    2712:	1c2080e7          	jalr	450(ra) # 58d0 <sbrk>
    2716:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2718:	20100593          	li	a1,513
    271c:	00005517          	auipc	a0,0x5
    2720:	88c50513          	addi	a0,a0,-1908 # 6fa8 <malloc+0x1312>
    2724:	00003097          	auipc	ra,0x3
    2728:	164080e7          	jalr	356(ra) # 5888 <open>
    272c:	84aa                	mv	s1,a0
  unlink("sbrk");
    272e:	00005517          	auipc	a0,0x5
    2732:	87a50513          	addi	a0,a0,-1926 # 6fa8 <malloc+0x1312>
    2736:	00003097          	auipc	ra,0x3
    273a:	162080e7          	jalr	354(ra) # 5898 <unlink>
  if(fd < 0)  {
    273e:	0404c163          	bltz	s1,2780 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2742:	6605                	lui	a2,0x1
    2744:	85ca                	mv	a1,s2
    2746:	8526                	mv	a0,s1
    2748:	00003097          	auipc	ra,0x3
    274c:	120080e7          	jalr	288(ra) # 5868 <write>
    2750:	04054663          	bltz	a0,279c <sbrkarg+0xa0>
  close(fd);
    2754:	8526                	mv	a0,s1
    2756:	00003097          	auipc	ra,0x3
    275a:	11a080e7          	jalr	282(ra) # 5870 <close>
  a = sbrk(PGSIZE);
    275e:	6505                	lui	a0,0x1
    2760:	00003097          	auipc	ra,0x3
    2764:	170080e7          	jalr	368(ra) # 58d0 <sbrk>
  if(pipe((int *) a) != 0){
    2768:	00003097          	auipc	ra,0x3
    276c:	0f0080e7          	jalr	240(ra) # 5858 <pipe>
    2770:	e521                	bnez	a0,27b8 <sbrkarg+0xbc>
}
    2772:	70a2                	ld	ra,40(sp)
    2774:	7402                	ld	s0,32(sp)
    2776:	64e2                	ld	s1,24(sp)
    2778:	6942                	ld	s2,16(sp)
    277a:	69a2                	ld	s3,8(sp)
    277c:	6145                	addi	sp,sp,48
    277e:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2780:	85ce                	mv	a1,s3
    2782:	00005517          	auipc	a0,0x5
    2786:	82e50513          	addi	a0,a0,-2002 # 6fb0 <malloc+0x131a>
    278a:	00003097          	auipc	ra,0x3
    278e:	44e080e7          	jalr	1102(ra) # 5bd8 <printf>
    exit(1);
    2792:	4505                	li	a0,1
    2794:	00003097          	auipc	ra,0x3
    2798:	0b4080e7          	jalr	180(ra) # 5848 <exit>
    printf("%s: write sbrk failed\n", s);
    279c:	85ce                	mv	a1,s3
    279e:	00005517          	auipc	a0,0x5
    27a2:	82a50513          	addi	a0,a0,-2006 # 6fc8 <malloc+0x1332>
    27a6:	00003097          	auipc	ra,0x3
    27aa:	432080e7          	jalr	1074(ra) # 5bd8 <printf>
    exit(1);
    27ae:	4505                	li	a0,1
    27b0:	00003097          	auipc	ra,0x3
    27b4:	098080e7          	jalr	152(ra) # 5848 <exit>
    printf("%s: pipe() failed\n", s);
    27b8:	85ce                	mv	a1,s3
    27ba:	00004517          	auipc	a0,0x4
    27be:	20e50513          	addi	a0,a0,526 # 69c8 <malloc+0xd32>
    27c2:	00003097          	auipc	ra,0x3
    27c6:	416080e7          	jalr	1046(ra) # 5bd8 <printf>
    exit(1);
    27ca:	4505                	li	a0,1
    27cc:	00003097          	auipc	ra,0x3
    27d0:	07c080e7          	jalr	124(ra) # 5848 <exit>

00000000000027d4 <argptest>:
{
    27d4:	1101                	addi	sp,sp,-32
    27d6:	ec06                	sd	ra,24(sp)
    27d8:	e822                	sd	s0,16(sp)
    27da:	e426                	sd	s1,8(sp)
    27dc:	e04a                	sd	s2,0(sp)
    27de:	1000                	addi	s0,sp,32
    27e0:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    27e2:	4581                	li	a1,0
    27e4:	00004517          	auipc	a0,0x4
    27e8:	7fc50513          	addi	a0,a0,2044 # 6fe0 <malloc+0x134a>
    27ec:	00003097          	auipc	ra,0x3
    27f0:	09c080e7          	jalr	156(ra) # 5888 <open>
  if (fd < 0) {
    27f4:	02054b63          	bltz	a0,282a <argptest+0x56>
    27f8:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    27fa:	4501                	li	a0,0
    27fc:	00003097          	auipc	ra,0x3
    2800:	0d4080e7          	jalr	212(ra) # 58d0 <sbrk>
    2804:	567d                	li	a2,-1
    2806:	fff50593          	addi	a1,a0,-1
    280a:	8526                	mv	a0,s1
    280c:	00003097          	auipc	ra,0x3
    2810:	054080e7          	jalr	84(ra) # 5860 <read>
  close(fd);
    2814:	8526                	mv	a0,s1
    2816:	00003097          	auipc	ra,0x3
    281a:	05a080e7          	jalr	90(ra) # 5870 <close>
}
    281e:	60e2                	ld	ra,24(sp)
    2820:	6442                	ld	s0,16(sp)
    2822:	64a2                	ld	s1,8(sp)
    2824:	6902                	ld	s2,0(sp)
    2826:	6105                	addi	sp,sp,32
    2828:	8082                	ret
    printf("%s: open failed\n", s);
    282a:	85ca                	mv	a1,s2
    282c:	00004517          	auipc	a0,0x4
    2830:	0ac50513          	addi	a0,a0,172 # 68d8 <malloc+0xc42>
    2834:	00003097          	auipc	ra,0x3
    2838:	3a4080e7          	jalr	932(ra) # 5bd8 <printf>
    exit(1);
    283c:	4505                	li	a0,1
    283e:	00003097          	auipc	ra,0x3
    2842:	00a080e7          	jalr	10(ra) # 5848 <exit>

0000000000002846 <sbrkbugs>:
{
    2846:	1141                	addi	sp,sp,-16
    2848:	e406                	sd	ra,8(sp)
    284a:	e022                	sd	s0,0(sp)
    284c:	0800                	addi	s0,sp,16
  int pid = fork();
    284e:	00003097          	auipc	ra,0x3
    2852:	ff2080e7          	jalr	-14(ra) # 5840 <fork>
  if(pid < 0){
    2856:	02054263          	bltz	a0,287a <sbrkbugs+0x34>
  if(pid == 0){
    285a:	ed0d                	bnez	a0,2894 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    285c:	00003097          	auipc	ra,0x3
    2860:	074080e7          	jalr	116(ra) # 58d0 <sbrk>
    sbrk(-sz);
    2864:	40a0053b          	negw	a0,a0
    2868:	00003097          	auipc	ra,0x3
    286c:	068080e7          	jalr	104(ra) # 58d0 <sbrk>
    exit(0);
    2870:	4501                	li	a0,0
    2872:	00003097          	auipc	ra,0x3
    2876:	fd6080e7          	jalr	-42(ra) # 5848 <exit>
    printf("fork failed\n");
    287a:	00004517          	auipc	a0,0x4
    287e:	44e50513          	addi	a0,a0,1102 # 6cc8 <malloc+0x1032>
    2882:	00003097          	auipc	ra,0x3
    2886:	356080e7          	jalr	854(ra) # 5bd8 <printf>
    exit(1);
    288a:	4505                	li	a0,1
    288c:	00003097          	auipc	ra,0x3
    2890:	fbc080e7          	jalr	-68(ra) # 5848 <exit>
  wait(0);
    2894:	4501                	li	a0,0
    2896:	00003097          	auipc	ra,0x3
    289a:	fba080e7          	jalr	-70(ra) # 5850 <wait>
  pid = fork();
    289e:	00003097          	auipc	ra,0x3
    28a2:	fa2080e7          	jalr	-94(ra) # 5840 <fork>
  if(pid < 0){
    28a6:	02054563          	bltz	a0,28d0 <sbrkbugs+0x8a>
  if(pid == 0){
    28aa:	e121                	bnez	a0,28ea <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    28ac:	00003097          	auipc	ra,0x3
    28b0:	024080e7          	jalr	36(ra) # 58d0 <sbrk>
    sbrk(-(sz - 3500));
    28b4:	6785                	lui	a5,0x1
    28b6:	dac7879b          	addiw	a5,a5,-596
    28ba:	40a7853b          	subw	a0,a5,a0
    28be:	00003097          	auipc	ra,0x3
    28c2:	012080e7          	jalr	18(ra) # 58d0 <sbrk>
    exit(0);
    28c6:	4501                	li	a0,0
    28c8:	00003097          	auipc	ra,0x3
    28cc:	f80080e7          	jalr	-128(ra) # 5848 <exit>
    printf("fork failed\n");
    28d0:	00004517          	auipc	a0,0x4
    28d4:	3f850513          	addi	a0,a0,1016 # 6cc8 <malloc+0x1032>
    28d8:	00003097          	auipc	ra,0x3
    28dc:	300080e7          	jalr	768(ra) # 5bd8 <printf>
    exit(1);
    28e0:	4505                	li	a0,1
    28e2:	00003097          	auipc	ra,0x3
    28e6:	f66080e7          	jalr	-154(ra) # 5848 <exit>
  wait(0);
    28ea:	4501                	li	a0,0
    28ec:	00003097          	auipc	ra,0x3
    28f0:	f64080e7          	jalr	-156(ra) # 5850 <wait>
  pid = fork();
    28f4:	00003097          	auipc	ra,0x3
    28f8:	f4c080e7          	jalr	-180(ra) # 5840 <fork>
  if(pid < 0){
    28fc:	02054a63          	bltz	a0,2930 <sbrkbugs+0xea>
  if(pid == 0){
    2900:	e529                	bnez	a0,294a <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2902:	00003097          	auipc	ra,0x3
    2906:	fce080e7          	jalr	-50(ra) # 58d0 <sbrk>
    290a:	67ad                	lui	a5,0xb
    290c:	8007879b          	addiw	a5,a5,-2048
    2910:	40a7853b          	subw	a0,a5,a0
    2914:	00003097          	auipc	ra,0x3
    2918:	fbc080e7          	jalr	-68(ra) # 58d0 <sbrk>
    sbrk(-10);
    291c:	5559                	li	a0,-10
    291e:	00003097          	auipc	ra,0x3
    2922:	fb2080e7          	jalr	-78(ra) # 58d0 <sbrk>
    exit(0);
    2926:	4501                	li	a0,0
    2928:	00003097          	auipc	ra,0x3
    292c:	f20080e7          	jalr	-224(ra) # 5848 <exit>
    printf("fork failed\n");
    2930:	00004517          	auipc	a0,0x4
    2934:	39850513          	addi	a0,a0,920 # 6cc8 <malloc+0x1032>
    2938:	00003097          	auipc	ra,0x3
    293c:	2a0080e7          	jalr	672(ra) # 5bd8 <printf>
    exit(1);
    2940:	4505                	li	a0,1
    2942:	00003097          	auipc	ra,0x3
    2946:	f06080e7          	jalr	-250(ra) # 5848 <exit>
  wait(0);
    294a:	4501                	li	a0,0
    294c:	00003097          	auipc	ra,0x3
    2950:	f04080e7          	jalr	-252(ra) # 5850 <wait>
  exit(0);
    2954:	4501                	li	a0,0
    2956:	00003097          	auipc	ra,0x3
    295a:	ef2080e7          	jalr	-270(ra) # 5848 <exit>

000000000000295e <sbrklast>:
{
    295e:	7179                	addi	sp,sp,-48
    2960:	f406                	sd	ra,40(sp)
    2962:	f022                	sd	s0,32(sp)
    2964:	ec26                	sd	s1,24(sp)
    2966:	e84a                	sd	s2,16(sp)
    2968:	e44e                	sd	s3,8(sp)
    296a:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    296c:	4501                	li	a0,0
    296e:	00003097          	auipc	ra,0x3
    2972:	f62080e7          	jalr	-158(ra) # 58d0 <sbrk>
  if((top % 4096) != 0)
    2976:	03451793          	slli	a5,a0,0x34
    297a:	efc1                	bnez	a5,2a12 <sbrklast+0xb4>
  sbrk(4096);
    297c:	6505                	lui	a0,0x1
    297e:	00003097          	auipc	ra,0x3
    2982:	f52080e7          	jalr	-174(ra) # 58d0 <sbrk>
  sbrk(10);
    2986:	4529                	li	a0,10
    2988:	00003097          	auipc	ra,0x3
    298c:	f48080e7          	jalr	-184(ra) # 58d0 <sbrk>
  sbrk(-20);
    2990:	5531                	li	a0,-20
    2992:	00003097          	auipc	ra,0x3
    2996:	f3e080e7          	jalr	-194(ra) # 58d0 <sbrk>
  top = (uint64) sbrk(0);
    299a:	4501                	li	a0,0
    299c:	00003097          	auipc	ra,0x3
    29a0:	f34080e7          	jalr	-204(ra) # 58d0 <sbrk>
    29a4:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    29a6:	fc050913          	addi	s2,a0,-64 # fc0 <validatetest+0x5e>
  p[0] = 'x';
    29aa:	07800793          	li	a5,120
    29ae:	fcf50023          	sb	a5,-64(a0)
  p[1] = '\0';
    29b2:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    29b6:	20200593          	li	a1,514
    29ba:	854a                	mv	a0,s2
    29bc:	00003097          	auipc	ra,0x3
    29c0:	ecc080e7          	jalr	-308(ra) # 5888 <open>
    29c4:	89aa                	mv	s3,a0
  write(fd, p, 1);
    29c6:	4605                	li	a2,1
    29c8:	85ca                	mv	a1,s2
    29ca:	00003097          	auipc	ra,0x3
    29ce:	e9e080e7          	jalr	-354(ra) # 5868 <write>
  close(fd);
    29d2:	854e                	mv	a0,s3
    29d4:	00003097          	auipc	ra,0x3
    29d8:	e9c080e7          	jalr	-356(ra) # 5870 <close>
  fd = open(p, O_RDWR);
    29dc:	4589                	li	a1,2
    29de:	854a                	mv	a0,s2
    29e0:	00003097          	auipc	ra,0x3
    29e4:	ea8080e7          	jalr	-344(ra) # 5888 <open>
  p[0] = '\0';
    29e8:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    29ec:	4605                	li	a2,1
    29ee:	85ca                	mv	a1,s2
    29f0:	00003097          	auipc	ra,0x3
    29f4:	e70080e7          	jalr	-400(ra) # 5860 <read>
  if(p[0] != 'x')
    29f8:	fc04c703          	lbu	a4,-64(s1)
    29fc:	07800793          	li	a5,120
    2a00:	02f71363          	bne	a4,a5,2a26 <sbrklast+0xc8>
}
    2a04:	70a2                	ld	ra,40(sp)
    2a06:	7402                	ld	s0,32(sp)
    2a08:	64e2                	ld	s1,24(sp)
    2a0a:	6942                	ld	s2,16(sp)
    2a0c:	69a2                	ld	s3,8(sp)
    2a0e:	6145                	addi	sp,sp,48
    2a10:	8082                	ret
    sbrk(4096 - (top % 4096));
    2a12:	0347d513          	srli	a0,a5,0x34
    2a16:	6785                	lui	a5,0x1
    2a18:	40a7853b          	subw	a0,a5,a0
    2a1c:	00003097          	auipc	ra,0x3
    2a20:	eb4080e7          	jalr	-332(ra) # 58d0 <sbrk>
    2a24:	bfa1                	j	297c <sbrklast+0x1e>
    exit(1);
    2a26:	4505                	li	a0,1
    2a28:	00003097          	auipc	ra,0x3
    2a2c:	e20080e7          	jalr	-480(ra) # 5848 <exit>

0000000000002a30 <sbrk8000>:
{
    2a30:	1141                	addi	sp,sp,-16
    2a32:	e406                	sd	ra,8(sp)
    2a34:	e022                	sd	s0,0(sp)
    2a36:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2a38:	80000537          	lui	a0,0x80000
    2a3c:	0511                	addi	a0,a0,4
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	e92080e7          	jalr	-366(ra) # 58d0 <sbrk>
  volatile char *top = sbrk(0);
    2a46:	4501                	li	a0,0
    2a48:	00003097          	auipc	ra,0x3
    2a4c:	e88080e7          	jalr	-376(ra) # 58d0 <sbrk>
  *(top-1) = *(top-1) + 1;
    2a50:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <__BSS_END__+0xffffffff7fff12a7>
    2a54:	0785                	addi	a5,a5,1
    2a56:	0ff7f793          	andi	a5,a5,255
    2a5a:	fef50fa3          	sb	a5,-1(a0)
}
    2a5e:	60a2                	ld	ra,8(sp)
    2a60:	6402                	ld	s0,0(sp)
    2a62:	0141                	addi	sp,sp,16
    2a64:	8082                	ret

0000000000002a66 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2a66:	715d                	addi	sp,sp,-80
    2a68:	e486                	sd	ra,72(sp)
    2a6a:	e0a2                	sd	s0,64(sp)
    2a6c:	fc26                	sd	s1,56(sp)
    2a6e:	f84a                	sd	s2,48(sp)
    2a70:	f44e                	sd	s3,40(sp)
    2a72:	f052                	sd	s4,32(sp)
    2a74:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2a76:	4901                	li	s2,0
    2a78:	49bd                	li	s3,15
    int pid = fork();
    2a7a:	00003097          	auipc	ra,0x3
    2a7e:	dc6080e7          	jalr	-570(ra) # 5840 <fork>
    2a82:	84aa                	mv	s1,a0
    if(pid < 0){
    2a84:	02054063          	bltz	a0,2aa4 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2a88:	c91d                	beqz	a0,2abe <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2a8a:	4501                	li	a0,0
    2a8c:	00003097          	auipc	ra,0x3
    2a90:	dc4080e7          	jalr	-572(ra) # 5850 <wait>
  for(int avail = 0; avail < 15; avail++){
    2a94:	2905                	addiw	s2,s2,1
    2a96:	ff3912e3          	bne	s2,s3,2a7a <execout+0x14>
    }
  }

  exit(0);
    2a9a:	4501                	li	a0,0
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	dac080e7          	jalr	-596(ra) # 5848 <exit>
      printf("fork failed\n");
    2aa4:	00004517          	auipc	a0,0x4
    2aa8:	22450513          	addi	a0,a0,548 # 6cc8 <malloc+0x1032>
    2aac:	00003097          	auipc	ra,0x3
    2ab0:	12c080e7          	jalr	300(ra) # 5bd8 <printf>
      exit(1);
    2ab4:	4505                	li	a0,1
    2ab6:	00003097          	auipc	ra,0x3
    2aba:	d92080e7          	jalr	-622(ra) # 5848 <exit>
        if(a == 0xffffffffffffffffLL)
    2abe:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2ac0:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2ac2:	6505                	lui	a0,0x1
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	e0c080e7          	jalr	-500(ra) # 58d0 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2acc:	01350763          	beq	a0,s3,2ada <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2ad0:	6785                	lui	a5,0x1
    2ad2:	953e                	add	a0,a0,a5
    2ad4:	ff450fa3          	sb	s4,-1(a0) # fff <pgbug+0x2f>
      while(1){
    2ad8:	b7ed                	j	2ac2 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2ada:	01205a63          	blez	s2,2aee <execout+0x88>
        sbrk(-4096);
    2ade:	757d                	lui	a0,0xfffff
    2ae0:	00003097          	auipc	ra,0x3
    2ae4:	df0080e7          	jalr	-528(ra) # 58d0 <sbrk>
      for(int i = 0; i < avail; i++)
    2ae8:	2485                	addiw	s1,s1,1
    2aea:	ff249ae3          	bne	s1,s2,2ade <execout+0x78>
      close(1);
    2aee:	4505                	li	a0,1
    2af0:	00003097          	auipc	ra,0x3
    2af4:	d80080e7          	jalr	-640(ra) # 5870 <close>
      char *args[] = { "echo", "x", 0 };
    2af8:	00003517          	auipc	a0,0x3
    2afc:	5f850513          	addi	a0,a0,1528 # 60f0 <malloc+0x45a>
    2b00:	faa43c23          	sd	a0,-72(s0)
    2b04:	00003797          	auipc	a5,0x3
    2b08:	65c78793          	addi	a5,a5,1628 # 6160 <malloc+0x4ca>
    2b0c:	fcf43023          	sd	a5,-64(s0)
    2b10:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2b14:	fb840593          	addi	a1,s0,-72
    2b18:	00003097          	auipc	ra,0x3
    2b1c:	d68080e7          	jalr	-664(ra) # 5880 <exec>
      exit(0);
    2b20:	4501                	li	a0,0
    2b22:	00003097          	auipc	ra,0x3
    2b26:	d26080e7          	jalr	-730(ra) # 5848 <exit>

0000000000002b2a <fourteen>:
{
    2b2a:	1101                	addi	sp,sp,-32
    2b2c:	ec06                	sd	ra,24(sp)
    2b2e:	e822                	sd	s0,16(sp)
    2b30:	e426                	sd	s1,8(sp)
    2b32:	1000                	addi	s0,sp,32
    2b34:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2b36:	00004517          	auipc	a0,0x4
    2b3a:	68250513          	addi	a0,a0,1666 # 71b8 <malloc+0x1522>
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	d72080e7          	jalr	-654(ra) # 58b0 <mkdir>
    2b46:	e165                	bnez	a0,2c26 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	4c850513          	addi	a0,a0,1224 # 7010 <malloc+0x137a>
    2b50:	00003097          	auipc	ra,0x3
    2b54:	d60080e7          	jalr	-672(ra) # 58b0 <mkdir>
    2b58:	e56d                	bnez	a0,2c42 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2b5a:	20000593          	li	a1,512
    2b5e:	00004517          	auipc	a0,0x4
    2b62:	50a50513          	addi	a0,a0,1290 # 7068 <malloc+0x13d2>
    2b66:	00003097          	auipc	ra,0x3
    2b6a:	d22080e7          	jalr	-734(ra) # 5888 <open>
  if(fd < 0){
    2b6e:	0e054863          	bltz	a0,2c5e <fourteen+0x134>
  close(fd);
    2b72:	00003097          	auipc	ra,0x3
    2b76:	cfe080e7          	jalr	-770(ra) # 5870 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b7a:	4581                	li	a1,0
    2b7c:	00004517          	auipc	a0,0x4
    2b80:	56450513          	addi	a0,a0,1380 # 70e0 <malloc+0x144a>
    2b84:	00003097          	auipc	ra,0x3
    2b88:	d04080e7          	jalr	-764(ra) # 5888 <open>
  if(fd < 0){
    2b8c:	0e054763          	bltz	a0,2c7a <fourteen+0x150>
  close(fd);
    2b90:	00003097          	auipc	ra,0x3
    2b94:	ce0080e7          	jalr	-800(ra) # 5870 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2b98:	00004517          	auipc	a0,0x4
    2b9c:	5b850513          	addi	a0,a0,1464 # 7150 <malloc+0x14ba>
    2ba0:	00003097          	auipc	ra,0x3
    2ba4:	d10080e7          	jalr	-752(ra) # 58b0 <mkdir>
    2ba8:	c57d                	beqz	a0,2c96 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2baa:	00004517          	auipc	a0,0x4
    2bae:	5fe50513          	addi	a0,a0,1534 # 71a8 <malloc+0x1512>
    2bb2:	00003097          	auipc	ra,0x3
    2bb6:	cfe080e7          	jalr	-770(ra) # 58b0 <mkdir>
    2bba:	cd65                	beqz	a0,2cb2 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2bbc:	00004517          	auipc	a0,0x4
    2bc0:	5ec50513          	addi	a0,a0,1516 # 71a8 <malloc+0x1512>
    2bc4:	00003097          	auipc	ra,0x3
    2bc8:	cd4080e7          	jalr	-812(ra) # 5898 <unlink>
  unlink("12345678901234/12345678901234");
    2bcc:	00004517          	auipc	a0,0x4
    2bd0:	58450513          	addi	a0,a0,1412 # 7150 <malloc+0x14ba>
    2bd4:	00003097          	auipc	ra,0x3
    2bd8:	cc4080e7          	jalr	-828(ra) # 5898 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2bdc:	00004517          	auipc	a0,0x4
    2be0:	50450513          	addi	a0,a0,1284 # 70e0 <malloc+0x144a>
    2be4:	00003097          	auipc	ra,0x3
    2be8:	cb4080e7          	jalr	-844(ra) # 5898 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2bec:	00004517          	auipc	a0,0x4
    2bf0:	47c50513          	addi	a0,a0,1148 # 7068 <malloc+0x13d2>
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	ca4080e7          	jalr	-860(ra) # 5898 <unlink>
  unlink("12345678901234/123456789012345");
    2bfc:	00004517          	auipc	a0,0x4
    2c00:	41450513          	addi	a0,a0,1044 # 7010 <malloc+0x137a>
    2c04:	00003097          	auipc	ra,0x3
    2c08:	c94080e7          	jalr	-876(ra) # 5898 <unlink>
  unlink("12345678901234");
    2c0c:	00004517          	auipc	a0,0x4
    2c10:	5ac50513          	addi	a0,a0,1452 # 71b8 <malloc+0x1522>
    2c14:	00003097          	auipc	ra,0x3
    2c18:	c84080e7          	jalr	-892(ra) # 5898 <unlink>
}
    2c1c:	60e2                	ld	ra,24(sp)
    2c1e:	6442                	ld	s0,16(sp)
    2c20:	64a2                	ld	s1,8(sp)
    2c22:	6105                	addi	sp,sp,32
    2c24:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2c26:	85a6                	mv	a1,s1
    2c28:	00004517          	auipc	a0,0x4
    2c2c:	3c050513          	addi	a0,a0,960 # 6fe8 <malloc+0x1352>
    2c30:	00003097          	auipc	ra,0x3
    2c34:	fa8080e7          	jalr	-88(ra) # 5bd8 <printf>
    exit(1);
    2c38:	4505                	li	a0,1
    2c3a:	00003097          	auipc	ra,0x3
    2c3e:	c0e080e7          	jalr	-1010(ra) # 5848 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2c42:	85a6                	mv	a1,s1
    2c44:	00004517          	auipc	a0,0x4
    2c48:	3ec50513          	addi	a0,a0,1004 # 7030 <malloc+0x139a>
    2c4c:	00003097          	auipc	ra,0x3
    2c50:	f8c080e7          	jalr	-116(ra) # 5bd8 <printf>
    exit(1);
    2c54:	4505                	li	a0,1
    2c56:	00003097          	auipc	ra,0x3
    2c5a:	bf2080e7          	jalr	-1038(ra) # 5848 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2c5e:	85a6                	mv	a1,s1
    2c60:	00004517          	auipc	a0,0x4
    2c64:	43850513          	addi	a0,a0,1080 # 7098 <malloc+0x1402>
    2c68:	00003097          	auipc	ra,0x3
    2c6c:	f70080e7          	jalr	-144(ra) # 5bd8 <printf>
    exit(1);
    2c70:	4505                	li	a0,1
    2c72:	00003097          	auipc	ra,0x3
    2c76:	bd6080e7          	jalr	-1066(ra) # 5848 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2c7a:	85a6                	mv	a1,s1
    2c7c:	00004517          	auipc	a0,0x4
    2c80:	49450513          	addi	a0,a0,1172 # 7110 <malloc+0x147a>
    2c84:	00003097          	auipc	ra,0x3
    2c88:	f54080e7          	jalr	-172(ra) # 5bd8 <printf>
    exit(1);
    2c8c:	4505                	li	a0,1
    2c8e:	00003097          	auipc	ra,0x3
    2c92:	bba080e7          	jalr	-1094(ra) # 5848 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2c96:	85a6                	mv	a1,s1
    2c98:	00004517          	auipc	a0,0x4
    2c9c:	4d850513          	addi	a0,a0,1240 # 7170 <malloc+0x14da>
    2ca0:	00003097          	auipc	ra,0x3
    2ca4:	f38080e7          	jalr	-200(ra) # 5bd8 <printf>
    exit(1);
    2ca8:	4505                	li	a0,1
    2caa:	00003097          	auipc	ra,0x3
    2cae:	b9e080e7          	jalr	-1122(ra) # 5848 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2cb2:	85a6                	mv	a1,s1
    2cb4:	00004517          	auipc	a0,0x4
    2cb8:	51450513          	addi	a0,a0,1300 # 71c8 <malloc+0x1532>
    2cbc:	00003097          	auipc	ra,0x3
    2cc0:	f1c080e7          	jalr	-228(ra) # 5bd8 <printf>
    exit(1);
    2cc4:	4505                	li	a0,1
    2cc6:	00003097          	auipc	ra,0x3
    2cca:	b82080e7          	jalr	-1150(ra) # 5848 <exit>

0000000000002cce <iputtest>:
{
    2cce:	1101                	addi	sp,sp,-32
    2cd0:	ec06                	sd	ra,24(sp)
    2cd2:	e822                	sd	s0,16(sp)
    2cd4:	e426                	sd	s1,8(sp)
    2cd6:	1000                	addi	s0,sp,32
    2cd8:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2cda:	00004517          	auipc	a0,0x4
    2cde:	52650513          	addi	a0,a0,1318 # 7200 <malloc+0x156a>
    2ce2:	00003097          	auipc	ra,0x3
    2ce6:	bce080e7          	jalr	-1074(ra) # 58b0 <mkdir>
    2cea:	04054563          	bltz	a0,2d34 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2cee:	00004517          	auipc	a0,0x4
    2cf2:	51250513          	addi	a0,a0,1298 # 7200 <malloc+0x156a>
    2cf6:	00003097          	auipc	ra,0x3
    2cfa:	bc2080e7          	jalr	-1086(ra) # 58b8 <chdir>
    2cfe:	04054963          	bltz	a0,2d50 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2d02:	00004517          	auipc	a0,0x4
    2d06:	53e50513          	addi	a0,a0,1342 # 7240 <malloc+0x15aa>
    2d0a:	00003097          	auipc	ra,0x3
    2d0e:	b8e080e7          	jalr	-1138(ra) # 5898 <unlink>
    2d12:	04054d63          	bltz	a0,2d6c <iputtest+0x9e>
  if(chdir("/") < 0){
    2d16:	00004517          	auipc	a0,0x4
    2d1a:	55a50513          	addi	a0,a0,1370 # 7270 <malloc+0x15da>
    2d1e:	00003097          	auipc	ra,0x3
    2d22:	b9a080e7          	jalr	-1126(ra) # 58b8 <chdir>
    2d26:	06054163          	bltz	a0,2d88 <iputtest+0xba>
}
    2d2a:	60e2                	ld	ra,24(sp)
    2d2c:	6442                	ld	s0,16(sp)
    2d2e:	64a2                	ld	s1,8(sp)
    2d30:	6105                	addi	sp,sp,32
    2d32:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2d34:	85a6                	mv	a1,s1
    2d36:	00004517          	auipc	a0,0x4
    2d3a:	4d250513          	addi	a0,a0,1234 # 7208 <malloc+0x1572>
    2d3e:	00003097          	auipc	ra,0x3
    2d42:	e9a080e7          	jalr	-358(ra) # 5bd8 <printf>
    exit(1);
    2d46:	4505                	li	a0,1
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	b00080e7          	jalr	-1280(ra) # 5848 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2d50:	85a6                	mv	a1,s1
    2d52:	00004517          	auipc	a0,0x4
    2d56:	4ce50513          	addi	a0,a0,1230 # 7220 <malloc+0x158a>
    2d5a:	00003097          	auipc	ra,0x3
    2d5e:	e7e080e7          	jalr	-386(ra) # 5bd8 <printf>
    exit(1);
    2d62:	4505                	li	a0,1
    2d64:	00003097          	auipc	ra,0x3
    2d68:	ae4080e7          	jalr	-1308(ra) # 5848 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2d6c:	85a6                	mv	a1,s1
    2d6e:	00004517          	auipc	a0,0x4
    2d72:	4e250513          	addi	a0,a0,1250 # 7250 <malloc+0x15ba>
    2d76:	00003097          	auipc	ra,0x3
    2d7a:	e62080e7          	jalr	-414(ra) # 5bd8 <printf>
    exit(1);
    2d7e:	4505                	li	a0,1
    2d80:	00003097          	auipc	ra,0x3
    2d84:	ac8080e7          	jalr	-1336(ra) # 5848 <exit>
    printf("%s: chdir / failed\n", s);
    2d88:	85a6                	mv	a1,s1
    2d8a:	00004517          	auipc	a0,0x4
    2d8e:	4ee50513          	addi	a0,a0,1262 # 7278 <malloc+0x15e2>
    2d92:	00003097          	auipc	ra,0x3
    2d96:	e46080e7          	jalr	-442(ra) # 5bd8 <printf>
    exit(1);
    2d9a:	4505                	li	a0,1
    2d9c:	00003097          	auipc	ra,0x3
    2da0:	aac080e7          	jalr	-1364(ra) # 5848 <exit>

0000000000002da4 <exitiputtest>:
{
    2da4:	7179                	addi	sp,sp,-48
    2da6:	f406                	sd	ra,40(sp)
    2da8:	f022                	sd	s0,32(sp)
    2daa:	ec26                	sd	s1,24(sp)
    2dac:	1800                	addi	s0,sp,48
    2dae:	84aa                	mv	s1,a0
  pid = fork();
    2db0:	00003097          	auipc	ra,0x3
    2db4:	a90080e7          	jalr	-1392(ra) # 5840 <fork>
  if(pid < 0){
    2db8:	04054663          	bltz	a0,2e04 <exitiputtest+0x60>
  if(pid == 0){
    2dbc:	ed45                	bnez	a0,2e74 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2dbe:	00004517          	auipc	a0,0x4
    2dc2:	44250513          	addi	a0,a0,1090 # 7200 <malloc+0x156a>
    2dc6:	00003097          	auipc	ra,0x3
    2dca:	aea080e7          	jalr	-1302(ra) # 58b0 <mkdir>
    2dce:	04054963          	bltz	a0,2e20 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2dd2:	00004517          	auipc	a0,0x4
    2dd6:	42e50513          	addi	a0,a0,1070 # 7200 <malloc+0x156a>
    2dda:	00003097          	auipc	ra,0x3
    2dde:	ade080e7          	jalr	-1314(ra) # 58b8 <chdir>
    2de2:	04054d63          	bltz	a0,2e3c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2de6:	00004517          	auipc	a0,0x4
    2dea:	45a50513          	addi	a0,a0,1114 # 7240 <malloc+0x15aa>
    2dee:	00003097          	auipc	ra,0x3
    2df2:	aaa080e7          	jalr	-1366(ra) # 5898 <unlink>
    2df6:	06054163          	bltz	a0,2e58 <exitiputtest+0xb4>
    exit(0);
    2dfa:	4501                	li	a0,0
    2dfc:	00003097          	auipc	ra,0x3
    2e00:	a4c080e7          	jalr	-1460(ra) # 5848 <exit>
    printf("%s: fork failed\n", s);
    2e04:	85a6                	mv	a1,s1
    2e06:	00004517          	auipc	a0,0x4
    2e0a:	aba50513          	addi	a0,a0,-1350 # 68c0 <malloc+0xc2a>
    2e0e:	00003097          	auipc	ra,0x3
    2e12:	dca080e7          	jalr	-566(ra) # 5bd8 <printf>
    exit(1);
    2e16:	4505                	li	a0,1
    2e18:	00003097          	auipc	ra,0x3
    2e1c:	a30080e7          	jalr	-1488(ra) # 5848 <exit>
      printf("%s: mkdir failed\n", s);
    2e20:	85a6                	mv	a1,s1
    2e22:	00004517          	auipc	a0,0x4
    2e26:	3e650513          	addi	a0,a0,998 # 7208 <malloc+0x1572>
    2e2a:	00003097          	auipc	ra,0x3
    2e2e:	dae080e7          	jalr	-594(ra) # 5bd8 <printf>
      exit(1);
    2e32:	4505                	li	a0,1
    2e34:	00003097          	auipc	ra,0x3
    2e38:	a14080e7          	jalr	-1516(ra) # 5848 <exit>
      printf("%s: child chdir failed\n", s);
    2e3c:	85a6                	mv	a1,s1
    2e3e:	00004517          	auipc	a0,0x4
    2e42:	45250513          	addi	a0,a0,1106 # 7290 <malloc+0x15fa>
    2e46:	00003097          	auipc	ra,0x3
    2e4a:	d92080e7          	jalr	-622(ra) # 5bd8 <printf>
      exit(1);
    2e4e:	4505                	li	a0,1
    2e50:	00003097          	auipc	ra,0x3
    2e54:	9f8080e7          	jalr	-1544(ra) # 5848 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2e58:	85a6                	mv	a1,s1
    2e5a:	00004517          	auipc	a0,0x4
    2e5e:	3f650513          	addi	a0,a0,1014 # 7250 <malloc+0x15ba>
    2e62:	00003097          	auipc	ra,0x3
    2e66:	d76080e7          	jalr	-650(ra) # 5bd8 <printf>
      exit(1);
    2e6a:	4505                	li	a0,1
    2e6c:	00003097          	auipc	ra,0x3
    2e70:	9dc080e7          	jalr	-1572(ra) # 5848 <exit>
  wait(&xstatus);
    2e74:	fdc40513          	addi	a0,s0,-36
    2e78:	00003097          	auipc	ra,0x3
    2e7c:	9d8080e7          	jalr	-1576(ra) # 5850 <wait>
  exit(xstatus);
    2e80:	fdc42503          	lw	a0,-36(s0)
    2e84:	00003097          	auipc	ra,0x3
    2e88:	9c4080e7          	jalr	-1596(ra) # 5848 <exit>

0000000000002e8c <dirtest>:
{
    2e8c:	1101                	addi	sp,sp,-32
    2e8e:	ec06                	sd	ra,24(sp)
    2e90:	e822                	sd	s0,16(sp)
    2e92:	e426                	sd	s1,8(sp)
    2e94:	1000                	addi	s0,sp,32
    2e96:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2e98:	00004517          	auipc	a0,0x4
    2e9c:	41050513          	addi	a0,a0,1040 # 72a8 <malloc+0x1612>
    2ea0:	00003097          	auipc	ra,0x3
    2ea4:	a10080e7          	jalr	-1520(ra) # 58b0 <mkdir>
    2ea8:	04054563          	bltz	a0,2ef2 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2eac:	00004517          	auipc	a0,0x4
    2eb0:	3fc50513          	addi	a0,a0,1020 # 72a8 <malloc+0x1612>
    2eb4:	00003097          	auipc	ra,0x3
    2eb8:	a04080e7          	jalr	-1532(ra) # 58b8 <chdir>
    2ebc:	04054963          	bltz	a0,2f0e <dirtest+0x82>
  if(chdir("..") < 0){
    2ec0:	00004517          	auipc	a0,0x4
    2ec4:	40850513          	addi	a0,a0,1032 # 72c8 <malloc+0x1632>
    2ec8:	00003097          	auipc	ra,0x3
    2ecc:	9f0080e7          	jalr	-1552(ra) # 58b8 <chdir>
    2ed0:	04054d63          	bltz	a0,2f2a <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2ed4:	00004517          	auipc	a0,0x4
    2ed8:	3d450513          	addi	a0,a0,980 # 72a8 <malloc+0x1612>
    2edc:	00003097          	auipc	ra,0x3
    2ee0:	9bc080e7          	jalr	-1604(ra) # 5898 <unlink>
    2ee4:	06054163          	bltz	a0,2f46 <dirtest+0xba>
}
    2ee8:	60e2                	ld	ra,24(sp)
    2eea:	6442                	ld	s0,16(sp)
    2eec:	64a2                	ld	s1,8(sp)
    2eee:	6105                	addi	sp,sp,32
    2ef0:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2ef2:	85a6                	mv	a1,s1
    2ef4:	00004517          	auipc	a0,0x4
    2ef8:	31450513          	addi	a0,a0,788 # 7208 <malloc+0x1572>
    2efc:	00003097          	auipc	ra,0x3
    2f00:	cdc080e7          	jalr	-804(ra) # 5bd8 <printf>
    exit(1);
    2f04:	4505                	li	a0,1
    2f06:	00003097          	auipc	ra,0x3
    2f0a:	942080e7          	jalr	-1726(ra) # 5848 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2f0e:	85a6                	mv	a1,s1
    2f10:	00004517          	auipc	a0,0x4
    2f14:	3a050513          	addi	a0,a0,928 # 72b0 <malloc+0x161a>
    2f18:	00003097          	auipc	ra,0x3
    2f1c:	cc0080e7          	jalr	-832(ra) # 5bd8 <printf>
    exit(1);
    2f20:	4505                	li	a0,1
    2f22:	00003097          	auipc	ra,0x3
    2f26:	926080e7          	jalr	-1754(ra) # 5848 <exit>
    printf("%s: chdir .. failed\n", s);
    2f2a:	85a6                	mv	a1,s1
    2f2c:	00004517          	auipc	a0,0x4
    2f30:	3a450513          	addi	a0,a0,932 # 72d0 <malloc+0x163a>
    2f34:	00003097          	auipc	ra,0x3
    2f38:	ca4080e7          	jalr	-860(ra) # 5bd8 <printf>
    exit(1);
    2f3c:	4505                	li	a0,1
    2f3e:	00003097          	auipc	ra,0x3
    2f42:	90a080e7          	jalr	-1782(ra) # 5848 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2f46:	85a6                	mv	a1,s1
    2f48:	00004517          	auipc	a0,0x4
    2f4c:	3a050513          	addi	a0,a0,928 # 72e8 <malloc+0x1652>
    2f50:	00003097          	auipc	ra,0x3
    2f54:	c88080e7          	jalr	-888(ra) # 5bd8 <printf>
    exit(1);
    2f58:	4505                	li	a0,1
    2f5a:	00003097          	auipc	ra,0x3
    2f5e:	8ee080e7          	jalr	-1810(ra) # 5848 <exit>

0000000000002f62 <subdir>:
{
    2f62:	1101                	addi	sp,sp,-32
    2f64:	ec06                	sd	ra,24(sp)
    2f66:	e822                	sd	s0,16(sp)
    2f68:	e426                	sd	s1,8(sp)
    2f6a:	e04a                	sd	s2,0(sp)
    2f6c:	1000                	addi	s0,sp,32
    2f6e:	892a                	mv	s2,a0
  unlink("ff");
    2f70:	00004517          	auipc	a0,0x4
    2f74:	4c050513          	addi	a0,a0,1216 # 7430 <malloc+0x179a>
    2f78:	00003097          	auipc	ra,0x3
    2f7c:	920080e7          	jalr	-1760(ra) # 5898 <unlink>
  if(mkdir("dd") != 0){
    2f80:	00004517          	auipc	a0,0x4
    2f84:	38050513          	addi	a0,a0,896 # 7300 <malloc+0x166a>
    2f88:	00003097          	auipc	ra,0x3
    2f8c:	928080e7          	jalr	-1752(ra) # 58b0 <mkdir>
    2f90:	38051663          	bnez	a0,331c <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2f94:	20200593          	li	a1,514
    2f98:	00004517          	auipc	a0,0x4
    2f9c:	38850513          	addi	a0,a0,904 # 7320 <malloc+0x168a>
    2fa0:	00003097          	auipc	ra,0x3
    2fa4:	8e8080e7          	jalr	-1816(ra) # 5888 <open>
    2fa8:	84aa                	mv	s1,a0
  if(fd < 0){
    2faa:	38054763          	bltz	a0,3338 <subdir+0x3d6>
  write(fd, "ff", 2);
    2fae:	4609                	li	a2,2
    2fb0:	00004597          	auipc	a1,0x4
    2fb4:	48058593          	addi	a1,a1,1152 # 7430 <malloc+0x179a>
    2fb8:	00003097          	auipc	ra,0x3
    2fbc:	8b0080e7          	jalr	-1872(ra) # 5868 <write>
  close(fd);
    2fc0:	8526                	mv	a0,s1
    2fc2:	00003097          	auipc	ra,0x3
    2fc6:	8ae080e7          	jalr	-1874(ra) # 5870 <close>
  if(unlink("dd") >= 0){
    2fca:	00004517          	auipc	a0,0x4
    2fce:	33650513          	addi	a0,a0,822 # 7300 <malloc+0x166a>
    2fd2:	00003097          	auipc	ra,0x3
    2fd6:	8c6080e7          	jalr	-1850(ra) # 5898 <unlink>
    2fda:	36055d63          	bgez	a0,3354 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2fde:	00004517          	auipc	a0,0x4
    2fe2:	39a50513          	addi	a0,a0,922 # 7378 <malloc+0x16e2>
    2fe6:	00003097          	auipc	ra,0x3
    2fea:	8ca080e7          	jalr	-1846(ra) # 58b0 <mkdir>
    2fee:	38051163          	bnez	a0,3370 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2ff2:	20200593          	li	a1,514
    2ff6:	00004517          	auipc	a0,0x4
    2ffa:	3aa50513          	addi	a0,a0,938 # 73a0 <malloc+0x170a>
    2ffe:	00003097          	auipc	ra,0x3
    3002:	88a080e7          	jalr	-1910(ra) # 5888 <open>
    3006:	84aa                	mv	s1,a0
  if(fd < 0){
    3008:	38054263          	bltz	a0,338c <subdir+0x42a>
  write(fd, "FF", 2);
    300c:	4609                	li	a2,2
    300e:	00004597          	auipc	a1,0x4
    3012:	3c258593          	addi	a1,a1,962 # 73d0 <malloc+0x173a>
    3016:	00003097          	auipc	ra,0x3
    301a:	852080e7          	jalr	-1966(ra) # 5868 <write>
  close(fd);
    301e:	8526                	mv	a0,s1
    3020:	00003097          	auipc	ra,0x3
    3024:	850080e7          	jalr	-1968(ra) # 5870 <close>
  fd = open("dd/dd/../ff", 0);
    3028:	4581                	li	a1,0
    302a:	00004517          	auipc	a0,0x4
    302e:	3ae50513          	addi	a0,a0,942 # 73d8 <malloc+0x1742>
    3032:	00003097          	auipc	ra,0x3
    3036:	856080e7          	jalr	-1962(ra) # 5888 <open>
    303a:	84aa                	mv	s1,a0
  if(fd < 0){
    303c:	36054663          	bltz	a0,33a8 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3040:	660d                	lui	a2,0x3
    3042:	00009597          	auipc	a1,0x9
    3046:	d0658593          	addi	a1,a1,-762 # bd48 <buf>
    304a:	00003097          	auipc	ra,0x3
    304e:	816080e7          	jalr	-2026(ra) # 5860 <read>
  if(cc != 2 || buf[0] != 'f'){
    3052:	4789                	li	a5,2
    3054:	36f51863          	bne	a0,a5,33c4 <subdir+0x462>
    3058:	00009717          	auipc	a4,0x9
    305c:	cf074703          	lbu	a4,-784(a4) # bd48 <buf>
    3060:	06600793          	li	a5,102
    3064:	36f71063          	bne	a4,a5,33c4 <subdir+0x462>
  close(fd);
    3068:	8526                	mv	a0,s1
    306a:	00003097          	auipc	ra,0x3
    306e:	806080e7          	jalr	-2042(ra) # 5870 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3072:	00004597          	auipc	a1,0x4
    3076:	3b658593          	addi	a1,a1,950 # 7428 <malloc+0x1792>
    307a:	00004517          	auipc	a0,0x4
    307e:	32650513          	addi	a0,a0,806 # 73a0 <malloc+0x170a>
    3082:	00003097          	auipc	ra,0x3
    3086:	826080e7          	jalr	-2010(ra) # 58a8 <link>
    308a:	34051b63          	bnez	a0,33e0 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    308e:	00004517          	auipc	a0,0x4
    3092:	31250513          	addi	a0,a0,786 # 73a0 <malloc+0x170a>
    3096:	00003097          	auipc	ra,0x3
    309a:	802080e7          	jalr	-2046(ra) # 5898 <unlink>
    309e:	34051f63          	bnez	a0,33fc <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    30a2:	4581                	li	a1,0
    30a4:	00004517          	auipc	a0,0x4
    30a8:	2fc50513          	addi	a0,a0,764 # 73a0 <malloc+0x170a>
    30ac:	00002097          	auipc	ra,0x2
    30b0:	7dc080e7          	jalr	2012(ra) # 5888 <open>
    30b4:	36055263          	bgez	a0,3418 <subdir+0x4b6>
  if(chdir("dd") != 0){
    30b8:	00004517          	auipc	a0,0x4
    30bc:	24850513          	addi	a0,a0,584 # 7300 <malloc+0x166a>
    30c0:	00002097          	auipc	ra,0x2
    30c4:	7f8080e7          	jalr	2040(ra) # 58b8 <chdir>
    30c8:	36051663          	bnez	a0,3434 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    30cc:	00004517          	auipc	a0,0x4
    30d0:	3f450513          	addi	a0,a0,1012 # 74c0 <malloc+0x182a>
    30d4:	00002097          	auipc	ra,0x2
    30d8:	7e4080e7          	jalr	2020(ra) # 58b8 <chdir>
    30dc:	36051a63          	bnez	a0,3450 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    30e0:	00004517          	auipc	a0,0x4
    30e4:	41050513          	addi	a0,a0,1040 # 74f0 <malloc+0x185a>
    30e8:	00002097          	auipc	ra,0x2
    30ec:	7d0080e7          	jalr	2000(ra) # 58b8 <chdir>
    30f0:	36051e63          	bnez	a0,346c <subdir+0x50a>
  if(chdir("./..") != 0){
    30f4:	00004517          	auipc	a0,0x4
    30f8:	42c50513          	addi	a0,a0,1068 # 7520 <malloc+0x188a>
    30fc:	00002097          	auipc	ra,0x2
    3100:	7bc080e7          	jalr	1980(ra) # 58b8 <chdir>
    3104:	38051263          	bnez	a0,3488 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3108:	4581                	li	a1,0
    310a:	00004517          	auipc	a0,0x4
    310e:	31e50513          	addi	a0,a0,798 # 7428 <malloc+0x1792>
    3112:	00002097          	auipc	ra,0x2
    3116:	776080e7          	jalr	1910(ra) # 5888 <open>
    311a:	84aa                	mv	s1,a0
  if(fd < 0){
    311c:	38054463          	bltz	a0,34a4 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3120:	660d                	lui	a2,0x3
    3122:	00009597          	auipc	a1,0x9
    3126:	c2658593          	addi	a1,a1,-986 # bd48 <buf>
    312a:	00002097          	auipc	ra,0x2
    312e:	736080e7          	jalr	1846(ra) # 5860 <read>
    3132:	4789                	li	a5,2
    3134:	38f51663          	bne	a0,a5,34c0 <subdir+0x55e>
  close(fd);
    3138:	8526                	mv	a0,s1
    313a:	00002097          	auipc	ra,0x2
    313e:	736080e7          	jalr	1846(ra) # 5870 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3142:	4581                	li	a1,0
    3144:	00004517          	auipc	a0,0x4
    3148:	25c50513          	addi	a0,a0,604 # 73a0 <malloc+0x170a>
    314c:	00002097          	auipc	ra,0x2
    3150:	73c080e7          	jalr	1852(ra) # 5888 <open>
    3154:	38055463          	bgez	a0,34dc <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3158:	20200593          	li	a1,514
    315c:	00004517          	auipc	a0,0x4
    3160:	45450513          	addi	a0,a0,1108 # 75b0 <malloc+0x191a>
    3164:	00002097          	auipc	ra,0x2
    3168:	724080e7          	jalr	1828(ra) # 5888 <open>
    316c:	38055663          	bgez	a0,34f8 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3170:	20200593          	li	a1,514
    3174:	00004517          	auipc	a0,0x4
    3178:	46c50513          	addi	a0,a0,1132 # 75e0 <malloc+0x194a>
    317c:	00002097          	auipc	ra,0x2
    3180:	70c080e7          	jalr	1804(ra) # 5888 <open>
    3184:	38055863          	bgez	a0,3514 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3188:	20000593          	li	a1,512
    318c:	00004517          	auipc	a0,0x4
    3190:	17450513          	addi	a0,a0,372 # 7300 <malloc+0x166a>
    3194:	00002097          	auipc	ra,0x2
    3198:	6f4080e7          	jalr	1780(ra) # 5888 <open>
    319c:	38055a63          	bgez	a0,3530 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    31a0:	4589                	li	a1,2
    31a2:	00004517          	auipc	a0,0x4
    31a6:	15e50513          	addi	a0,a0,350 # 7300 <malloc+0x166a>
    31aa:	00002097          	auipc	ra,0x2
    31ae:	6de080e7          	jalr	1758(ra) # 5888 <open>
    31b2:	38055d63          	bgez	a0,354c <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    31b6:	4585                	li	a1,1
    31b8:	00004517          	auipc	a0,0x4
    31bc:	14850513          	addi	a0,a0,328 # 7300 <malloc+0x166a>
    31c0:	00002097          	auipc	ra,0x2
    31c4:	6c8080e7          	jalr	1736(ra) # 5888 <open>
    31c8:	3a055063          	bgez	a0,3568 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    31cc:	00004597          	auipc	a1,0x4
    31d0:	4a458593          	addi	a1,a1,1188 # 7670 <malloc+0x19da>
    31d4:	00004517          	auipc	a0,0x4
    31d8:	3dc50513          	addi	a0,a0,988 # 75b0 <malloc+0x191a>
    31dc:	00002097          	auipc	ra,0x2
    31e0:	6cc080e7          	jalr	1740(ra) # 58a8 <link>
    31e4:	3a050063          	beqz	a0,3584 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    31e8:	00004597          	auipc	a1,0x4
    31ec:	48858593          	addi	a1,a1,1160 # 7670 <malloc+0x19da>
    31f0:	00004517          	auipc	a0,0x4
    31f4:	3f050513          	addi	a0,a0,1008 # 75e0 <malloc+0x194a>
    31f8:	00002097          	auipc	ra,0x2
    31fc:	6b0080e7          	jalr	1712(ra) # 58a8 <link>
    3200:	3a050063          	beqz	a0,35a0 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3204:	00004597          	auipc	a1,0x4
    3208:	22458593          	addi	a1,a1,548 # 7428 <malloc+0x1792>
    320c:	00004517          	auipc	a0,0x4
    3210:	11450513          	addi	a0,a0,276 # 7320 <malloc+0x168a>
    3214:	00002097          	auipc	ra,0x2
    3218:	694080e7          	jalr	1684(ra) # 58a8 <link>
    321c:	3a050063          	beqz	a0,35bc <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3220:	00004517          	auipc	a0,0x4
    3224:	39050513          	addi	a0,a0,912 # 75b0 <malloc+0x191a>
    3228:	00002097          	auipc	ra,0x2
    322c:	688080e7          	jalr	1672(ra) # 58b0 <mkdir>
    3230:	3a050463          	beqz	a0,35d8 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3234:	00004517          	auipc	a0,0x4
    3238:	3ac50513          	addi	a0,a0,940 # 75e0 <malloc+0x194a>
    323c:	00002097          	auipc	ra,0x2
    3240:	674080e7          	jalr	1652(ra) # 58b0 <mkdir>
    3244:	3a050863          	beqz	a0,35f4 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3248:	00004517          	auipc	a0,0x4
    324c:	1e050513          	addi	a0,a0,480 # 7428 <malloc+0x1792>
    3250:	00002097          	auipc	ra,0x2
    3254:	660080e7          	jalr	1632(ra) # 58b0 <mkdir>
    3258:	3a050c63          	beqz	a0,3610 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    325c:	00004517          	auipc	a0,0x4
    3260:	38450513          	addi	a0,a0,900 # 75e0 <malloc+0x194a>
    3264:	00002097          	auipc	ra,0x2
    3268:	634080e7          	jalr	1588(ra) # 5898 <unlink>
    326c:	3c050063          	beqz	a0,362c <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3270:	00004517          	auipc	a0,0x4
    3274:	34050513          	addi	a0,a0,832 # 75b0 <malloc+0x191a>
    3278:	00002097          	auipc	ra,0x2
    327c:	620080e7          	jalr	1568(ra) # 5898 <unlink>
    3280:	3c050463          	beqz	a0,3648 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3284:	00004517          	auipc	a0,0x4
    3288:	09c50513          	addi	a0,a0,156 # 7320 <malloc+0x168a>
    328c:	00002097          	auipc	ra,0x2
    3290:	62c080e7          	jalr	1580(ra) # 58b8 <chdir>
    3294:	3c050863          	beqz	a0,3664 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3298:	00004517          	auipc	a0,0x4
    329c:	52850513          	addi	a0,a0,1320 # 77c0 <malloc+0x1b2a>
    32a0:	00002097          	auipc	ra,0x2
    32a4:	618080e7          	jalr	1560(ra) # 58b8 <chdir>
    32a8:	3c050c63          	beqz	a0,3680 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    32ac:	00004517          	auipc	a0,0x4
    32b0:	17c50513          	addi	a0,a0,380 # 7428 <malloc+0x1792>
    32b4:	00002097          	auipc	ra,0x2
    32b8:	5e4080e7          	jalr	1508(ra) # 5898 <unlink>
    32bc:	3e051063          	bnez	a0,369c <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    32c0:	00004517          	auipc	a0,0x4
    32c4:	06050513          	addi	a0,a0,96 # 7320 <malloc+0x168a>
    32c8:	00002097          	auipc	ra,0x2
    32cc:	5d0080e7          	jalr	1488(ra) # 5898 <unlink>
    32d0:	3e051463          	bnez	a0,36b8 <subdir+0x756>
  if(unlink("dd") == 0){
    32d4:	00004517          	auipc	a0,0x4
    32d8:	02c50513          	addi	a0,a0,44 # 7300 <malloc+0x166a>
    32dc:	00002097          	auipc	ra,0x2
    32e0:	5bc080e7          	jalr	1468(ra) # 5898 <unlink>
    32e4:	3e050863          	beqz	a0,36d4 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    32e8:	00004517          	auipc	a0,0x4
    32ec:	54850513          	addi	a0,a0,1352 # 7830 <malloc+0x1b9a>
    32f0:	00002097          	auipc	ra,0x2
    32f4:	5a8080e7          	jalr	1448(ra) # 5898 <unlink>
    32f8:	3e054c63          	bltz	a0,36f0 <subdir+0x78e>
  if(unlink("dd") < 0){
    32fc:	00004517          	auipc	a0,0x4
    3300:	00450513          	addi	a0,a0,4 # 7300 <malloc+0x166a>
    3304:	00002097          	auipc	ra,0x2
    3308:	594080e7          	jalr	1428(ra) # 5898 <unlink>
    330c:	40054063          	bltz	a0,370c <subdir+0x7aa>
}
    3310:	60e2                	ld	ra,24(sp)
    3312:	6442                	ld	s0,16(sp)
    3314:	64a2                	ld	s1,8(sp)
    3316:	6902                	ld	s2,0(sp)
    3318:	6105                	addi	sp,sp,32
    331a:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    331c:	85ca                	mv	a1,s2
    331e:	00004517          	auipc	a0,0x4
    3322:	fea50513          	addi	a0,a0,-22 # 7308 <malloc+0x1672>
    3326:	00003097          	auipc	ra,0x3
    332a:	8b2080e7          	jalr	-1870(ra) # 5bd8 <printf>
    exit(1);
    332e:	4505                	li	a0,1
    3330:	00002097          	auipc	ra,0x2
    3334:	518080e7          	jalr	1304(ra) # 5848 <exit>
    printf("%s: create dd/ff failed\n", s);
    3338:	85ca                	mv	a1,s2
    333a:	00004517          	auipc	a0,0x4
    333e:	fee50513          	addi	a0,a0,-18 # 7328 <malloc+0x1692>
    3342:	00003097          	auipc	ra,0x3
    3346:	896080e7          	jalr	-1898(ra) # 5bd8 <printf>
    exit(1);
    334a:	4505                	li	a0,1
    334c:	00002097          	auipc	ra,0x2
    3350:	4fc080e7          	jalr	1276(ra) # 5848 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3354:	85ca                	mv	a1,s2
    3356:	00004517          	auipc	a0,0x4
    335a:	ff250513          	addi	a0,a0,-14 # 7348 <malloc+0x16b2>
    335e:	00003097          	auipc	ra,0x3
    3362:	87a080e7          	jalr	-1926(ra) # 5bd8 <printf>
    exit(1);
    3366:	4505                	li	a0,1
    3368:	00002097          	auipc	ra,0x2
    336c:	4e0080e7          	jalr	1248(ra) # 5848 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3370:	85ca                	mv	a1,s2
    3372:	00004517          	auipc	a0,0x4
    3376:	00e50513          	addi	a0,a0,14 # 7380 <malloc+0x16ea>
    337a:	00003097          	auipc	ra,0x3
    337e:	85e080e7          	jalr	-1954(ra) # 5bd8 <printf>
    exit(1);
    3382:	4505                	li	a0,1
    3384:	00002097          	auipc	ra,0x2
    3388:	4c4080e7          	jalr	1220(ra) # 5848 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    338c:	85ca                	mv	a1,s2
    338e:	00004517          	auipc	a0,0x4
    3392:	02250513          	addi	a0,a0,34 # 73b0 <malloc+0x171a>
    3396:	00003097          	auipc	ra,0x3
    339a:	842080e7          	jalr	-1982(ra) # 5bd8 <printf>
    exit(1);
    339e:	4505                	li	a0,1
    33a0:	00002097          	auipc	ra,0x2
    33a4:	4a8080e7          	jalr	1192(ra) # 5848 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    33a8:	85ca                	mv	a1,s2
    33aa:	00004517          	auipc	a0,0x4
    33ae:	03e50513          	addi	a0,a0,62 # 73e8 <malloc+0x1752>
    33b2:	00003097          	auipc	ra,0x3
    33b6:	826080e7          	jalr	-2010(ra) # 5bd8 <printf>
    exit(1);
    33ba:	4505                	li	a0,1
    33bc:	00002097          	auipc	ra,0x2
    33c0:	48c080e7          	jalr	1164(ra) # 5848 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    33c4:	85ca                	mv	a1,s2
    33c6:	00004517          	auipc	a0,0x4
    33ca:	04250513          	addi	a0,a0,66 # 7408 <malloc+0x1772>
    33ce:	00003097          	auipc	ra,0x3
    33d2:	80a080e7          	jalr	-2038(ra) # 5bd8 <printf>
    exit(1);
    33d6:	4505                	li	a0,1
    33d8:	00002097          	auipc	ra,0x2
    33dc:	470080e7          	jalr	1136(ra) # 5848 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    33e0:	85ca                	mv	a1,s2
    33e2:	00004517          	auipc	a0,0x4
    33e6:	05650513          	addi	a0,a0,86 # 7438 <malloc+0x17a2>
    33ea:	00002097          	auipc	ra,0x2
    33ee:	7ee080e7          	jalr	2030(ra) # 5bd8 <printf>
    exit(1);
    33f2:	4505                	li	a0,1
    33f4:	00002097          	auipc	ra,0x2
    33f8:	454080e7          	jalr	1108(ra) # 5848 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    33fc:	85ca                	mv	a1,s2
    33fe:	00004517          	auipc	a0,0x4
    3402:	06250513          	addi	a0,a0,98 # 7460 <malloc+0x17ca>
    3406:	00002097          	auipc	ra,0x2
    340a:	7d2080e7          	jalr	2002(ra) # 5bd8 <printf>
    exit(1);
    340e:	4505                	li	a0,1
    3410:	00002097          	auipc	ra,0x2
    3414:	438080e7          	jalr	1080(ra) # 5848 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3418:	85ca                	mv	a1,s2
    341a:	00004517          	auipc	a0,0x4
    341e:	06650513          	addi	a0,a0,102 # 7480 <malloc+0x17ea>
    3422:	00002097          	auipc	ra,0x2
    3426:	7b6080e7          	jalr	1974(ra) # 5bd8 <printf>
    exit(1);
    342a:	4505                	li	a0,1
    342c:	00002097          	auipc	ra,0x2
    3430:	41c080e7          	jalr	1052(ra) # 5848 <exit>
    printf("%s: chdir dd failed\n", s);
    3434:	85ca                	mv	a1,s2
    3436:	00004517          	auipc	a0,0x4
    343a:	07250513          	addi	a0,a0,114 # 74a8 <malloc+0x1812>
    343e:	00002097          	auipc	ra,0x2
    3442:	79a080e7          	jalr	1946(ra) # 5bd8 <printf>
    exit(1);
    3446:	4505                	li	a0,1
    3448:	00002097          	auipc	ra,0x2
    344c:	400080e7          	jalr	1024(ra) # 5848 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3450:	85ca                	mv	a1,s2
    3452:	00004517          	auipc	a0,0x4
    3456:	07e50513          	addi	a0,a0,126 # 74d0 <malloc+0x183a>
    345a:	00002097          	auipc	ra,0x2
    345e:	77e080e7          	jalr	1918(ra) # 5bd8 <printf>
    exit(1);
    3462:	4505                	li	a0,1
    3464:	00002097          	auipc	ra,0x2
    3468:	3e4080e7          	jalr	996(ra) # 5848 <exit>
    printf("chdir dd/../../dd failed\n", s);
    346c:	85ca                	mv	a1,s2
    346e:	00004517          	auipc	a0,0x4
    3472:	09250513          	addi	a0,a0,146 # 7500 <malloc+0x186a>
    3476:	00002097          	auipc	ra,0x2
    347a:	762080e7          	jalr	1890(ra) # 5bd8 <printf>
    exit(1);
    347e:	4505                	li	a0,1
    3480:	00002097          	auipc	ra,0x2
    3484:	3c8080e7          	jalr	968(ra) # 5848 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3488:	85ca                	mv	a1,s2
    348a:	00004517          	auipc	a0,0x4
    348e:	09e50513          	addi	a0,a0,158 # 7528 <malloc+0x1892>
    3492:	00002097          	auipc	ra,0x2
    3496:	746080e7          	jalr	1862(ra) # 5bd8 <printf>
    exit(1);
    349a:	4505                	li	a0,1
    349c:	00002097          	auipc	ra,0x2
    34a0:	3ac080e7          	jalr	940(ra) # 5848 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    34a4:	85ca                	mv	a1,s2
    34a6:	00004517          	auipc	a0,0x4
    34aa:	09a50513          	addi	a0,a0,154 # 7540 <malloc+0x18aa>
    34ae:	00002097          	auipc	ra,0x2
    34b2:	72a080e7          	jalr	1834(ra) # 5bd8 <printf>
    exit(1);
    34b6:	4505                	li	a0,1
    34b8:	00002097          	auipc	ra,0x2
    34bc:	390080e7          	jalr	912(ra) # 5848 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    34c0:	85ca                	mv	a1,s2
    34c2:	00004517          	auipc	a0,0x4
    34c6:	09e50513          	addi	a0,a0,158 # 7560 <malloc+0x18ca>
    34ca:	00002097          	auipc	ra,0x2
    34ce:	70e080e7          	jalr	1806(ra) # 5bd8 <printf>
    exit(1);
    34d2:	4505                	li	a0,1
    34d4:	00002097          	auipc	ra,0x2
    34d8:	374080e7          	jalr	884(ra) # 5848 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    34dc:	85ca                	mv	a1,s2
    34de:	00004517          	auipc	a0,0x4
    34e2:	0a250513          	addi	a0,a0,162 # 7580 <malloc+0x18ea>
    34e6:	00002097          	auipc	ra,0x2
    34ea:	6f2080e7          	jalr	1778(ra) # 5bd8 <printf>
    exit(1);
    34ee:	4505                	li	a0,1
    34f0:	00002097          	auipc	ra,0x2
    34f4:	358080e7          	jalr	856(ra) # 5848 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    34f8:	85ca                	mv	a1,s2
    34fa:	00004517          	auipc	a0,0x4
    34fe:	0c650513          	addi	a0,a0,198 # 75c0 <malloc+0x192a>
    3502:	00002097          	auipc	ra,0x2
    3506:	6d6080e7          	jalr	1750(ra) # 5bd8 <printf>
    exit(1);
    350a:	4505                	li	a0,1
    350c:	00002097          	auipc	ra,0x2
    3510:	33c080e7          	jalr	828(ra) # 5848 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3514:	85ca                	mv	a1,s2
    3516:	00004517          	auipc	a0,0x4
    351a:	0da50513          	addi	a0,a0,218 # 75f0 <malloc+0x195a>
    351e:	00002097          	auipc	ra,0x2
    3522:	6ba080e7          	jalr	1722(ra) # 5bd8 <printf>
    exit(1);
    3526:	4505                	li	a0,1
    3528:	00002097          	auipc	ra,0x2
    352c:	320080e7          	jalr	800(ra) # 5848 <exit>
    printf("%s: create dd succeeded!\n", s);
    3530:	85ca                	mv	a1,s2
    3532:	00004517          	auipc	a0,0x4
    3536:	0de50513          	addi	a0,a0,222 # 7610 <malloc+0x197a>
    353a:	00002097          	auipc	ra,0x2
    353e:	69e080e7          	jalr	1694(ra) # 5bd8 <printf>
    exit(1);
    3542:	4505                	li	a0,1
    3544:	00002097          	auipc	ra,0x2
    3548:	304080e7          	jalr	772(ra) # 5848 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    354c:	85ca                	mv	a1,s2
    354e:	00004517          	auipc	a0,0x4
    3552:	0e250513          	addi	a0,a0,226 # 7630 <malloc+0x199a>
    3556:	00002097          	auipc	ra,0x2
    355a:	682080e7          	jalr	1666(ra) # 5bd8 <printf>
    exit(1);
    355e:	4505                	li	a0,1
    3560:	00002097          	auipc	ra,0x2
    3564:	2e8080e7          	jalr	744(ra) # 5848 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3568:	85ca                	mv	a1,s2
    356a:	00004517          	auipc	a0,0x4
    356e:	0e650513          	addi	a0,a0,230 # 7650 <malloc+0x19ba>
    3572:	00002097          	auipc	ra,0x2
    3576:	666080e7          	jalr	1638(ra) # 5bd8 <printf>
    exit(1);
    357a:	4505                	li	a0,1
    357c:	00002097          	auipc	ra,0x2
    3580:	2cc080e7          	jalr	716(ra) # 5848 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3584:	85ca                	mv	a1,s2
    3586:	00004517          	auipc	a0,0x4
    358a:	0fa50513          	addi	a0,a0,250 # 7680 <malloc+0x19ea>
    358e:	00002097          	auipc	ra,0x2
    3592:	64a080e7          	jalr	1610(ra) # 5bd8 <printf>
    exit(1);
    3596:	4505                	li	a0,1
    3598:	00002097          	auipc	ra,0x2
    359c:	2b0080e7          	jalr	688(ra) # 5848 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    35a0:	85ca                	mv	a1,s2
    35a2:	00004517          	auipc	a0,0x4
    35a6:	10650513          	addi	a0,a0,262 # 76a8 <malloc+0x1a12>
    35aa:	00002097          	auipc	ra,0x2
    35ae:	62e080e7          	jalr	1582(ra) # 5bd8 <printf>
    exit(1);
    35b2:	4505                	li	a0,1
    35b4:	00002097          	auipc	ra,0x2
    35b8:	294080e7          	jalr	660(ra) # 5848 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    35bc:	85ca                	mv	a1,s2
    35be:	00004517          	auipc	a0,0x4
    35c2:	11250513          	addi	a0,a0,274 # 76d0 <malloc+0x1a3a>
    35c6:	00002097          	auipc	ra,0x2
    35ca:	612080e7          	jalr	1554(ra) # 5bd8 <printf>
    exit(1);
    35ce:	4505                	li	a0,1
    35d0:	00002097          	auipc	ra,0x2
    35d4:	278080e7          	jalr	632(ra) # 5848 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    35d8:	85ca                	mv	a1,s2
    35da:	00004517          	auipc	a0,0x4
    35de:	11e50513          	addi	a0,a0,286 # 76f8 <malloc+0x1a62>
    35e2:	00002097          	auipc	ra,0x2
    35e6:	5f6080e7          	jalr	1526(ra) # 5bd8 <printf>
    exit(1);
    35ea:	4505                	li	a0,1
    35ec:	00002097          	auipc	ra,0x2
    35f0:	25c080e7          	jalr	604(ra) # 5848 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    35f4:	85ca                	mv	a1,s2
    35f6:	00004517          	auipc	a0,0x4
    35fa:	12250513          	addi	a0,a0,290 # 7718 <malloc+0x1a82>
    35fe:	00002097          	auipc	ra,0x2
    3602:	5da080e7          	jalr	1498(ra) # 5bd8 <printf>
    exit(1);
    3606:	4505                	li	a0,1
    3608:	00002097          	auipc	ra,0x2
    360c:	240080e7          	jalr	576(ra) # 5848 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3610:	85ca                	mv	a1,s2
    3612:	00004517          	auipc	a0,0x4
    3616:	12650513          	addi	a0,a0,294 # 7738 <malloc+0x1aa2>
    361a:	00002097          	auipc	ra,0x2
    361e:	5be080e7          	jalr	1470(ra) # 5bd8 <printf>
    exit(1);
    3622:	4505                	li	a0,1
    3624:	00002097          	auipc	ra,0x2
    3628:	224080e7          	jalr	548(ra) # 5848 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    362c:	85ca                	mv	a1,s2
    362e:	00004517          	auipc	a0,0x4
    3632:	13250513          	addi	a0,a0,306 # 7760 <malloc+0x1aca>
    3636:	00002097          	auipc	ra,0x2
    363a:	5a2080e7          	jalr	1442(ra) # 5bd8 <printf>
    exit(1);
    363e:	4505                	li	a0,1
    3640:	00002097          	auipc	ra,0x2
    3644:	208080e7          	jalr	520(ra) # 5848 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3648:	85ca                	mv	a1,s2
    364a:	00004517          	auipc	a0,0x4
    364e:	13650513          	addi	a0,a0,310 # 7780 <malloc+0x1aea>
    3652:	00002097          	auipc	ra,0x2
    3656:	586080e7          	jalr	1414(ra) # 5bd8 <printf>
    exit(1);
    365a:	4505                	li	a0,1
    365c:	00002097          	auipc	ra,0x2
    3660:	1ec080e7          	jalr	492(ra) # 5848 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3664:	85ca                	mv	a1,s2
    3666:	00004517          	auipc	a0,0x4
    366a:	13a50513          	addi	a0,a0,314 # 77a0 <malloc+0x1b0a>
    366e:	00002097          	auipc	ra,0x2
    3672:	56a080e7          	jalr	1386(ra) # 5bd8 <printf>
    exit(1);
    3676:	4505                	li	a0,1
    3678:	00002097          	auipc	ra,0x2
    367c:	1d0080e7          	jalr	464(ra) # 5848 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3680:	85ca                	mv	a1,s2
    3682:	00004517          	auipc	a0,0x4
    3686:	14650513          	addi	a0,a0,326 # 77c8 <malloc+0x1b32>
    368a:	00002097          	auipc	ra,0x2
    368e:	54e080e7          	jalr	1358(ra) # 5bd8 <printf>
    exit(1);
    3692:	4505                	li	a0,1
    3694:	00002097          	auipc	ra,0x2
    3698:	1b4080e7          	jalr	436(ra) # 5848 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    369c:	85ca                	mv	a1,s2
    369e:	00004517          	auipc	a0,0x4
    36a2:	dc250513          	addi	a0,a0,-574 # 7460 <malloc+0x17ca>
    36a6:	00002097          	auipc	ra,0x2
    36aa:	532080e7          	jalr	1330(ra) # 5bd8 <printf>
    exit(1);
    36ae:	4505                	li	a0,1
    36b0:	00002097          	auipc	ra,0x2
    36b4:	198080e7          	jalr	408(ra) # 5848 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    36b8:	85ca                	mv	a1,s2
    36ba:	00004517          	auipc	a0,0x4
    36be:	12e50513          	addi	a0,a0,302 # 77e8 <malloc+0x1b52>
    36c2:	00002097          	auipc	ra,0x2
    36c6:	516080e7          	jalr	1302(ra) # 5bd8 <printf>
    exit(1);
    36ca:	4505                	li	a0,1
    36cc:	00002097          	auipc	ra,0x2
    36d0:	17c080e7          	jalr	380(ra) # 5848 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    36d4:	85ca                	mv	a1,s2
    36d6:	00004517          	auipc	a0,0x4
    36da:	13250513          	addi	a0,a0,306 # 7808 <malloc+0x1b72>
    36de:	00002097          	auipc	ra,0x2
    36e2:	4fa080e7          	jalr	1274(ra) # 5bd8 <printf>
    exit(1);
    36e6:	4505                	li	a0,1
    36e8:	00002097          	auipc	ra,0x2
    36ec:	160080e7          	jalr	352(ra) # 5848 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    36f0:	85ca                	mv	a1,s2
    36f2:	00004517          	auipc	a0,0x4
    36f6:	14650513          	addi	a0,a0,326 # 7838 <malloc+0x1ba2>
    36fa:	00002097          	auipc	ra,0x2
    36fe:	4de080e7          	jalr	1246(ra) # 5bd8 <printf>
    exit(1);
    3702:	4505                	li	a0,1
    3704:	00002097          	auipc	ra,0x2
    3708:	144080e7          	jalr	324(ra) # 5848 <exit>
    printf("%s: unlink dd failed\n", s);
    370c:	85ca                	mv	a1,s2
    370e:	00004517          	auipc	a0,0x4
    3712:	14a50513          	addi	a0,a0,330 # 7858 <malloc+0x1bc2>
    3716:	00002097          	auipc	ra,0x2
    371a:	4c2080e7          	jalr	1218(ra) # 5bd8 <printf>
    exit(1);
    371e:	4505                	li	a0,1
    3720:	00002097          	auipc	ra,0x2
    3724:	128080e7          	jalr	296(ra) # 5848 <exit>

0000000000003728 <rmdot>:
{
    3728:	1101                	addi	sp,sp,-32
    372a:	ec06                	sd	ra,24(sp)
    372c:	e822                	sd	s0,16(sp)
    372e:	e426                	sd	s1,8(sp)
    3730:	1000                	addi	s0,sp,32
    3732:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3734:	00004517          	auipc	a0,0x4
    3738:	13c50513          	addi	a0,a0,316 # 7870 <malloc+0x1bda>
    373c:	00002097          	auipc	ra,0x2
    3740:	174080e7          	jalr	372(ra) # 58b0 <mkdir>
    3744:	e549                	bnez	a0,37ce <rmdot+0xa6>
  if(chdir("dots") != 0){
    3746:	00004517          	auipc	a0,0x4
    374a:	12a50513          	addi	a0,a0,298 # 7870 <malloc+0x1bda>
    374e:	00002097          	auipc	ra,0x2
    3752:	16a080e7          	jalr	362(ra) # 58b8 <chdir>
    3756:	e951                	bnez	a0,37ea <rmdot+0xc2>
  if(unlink(".") == 0){
    3758:	00003517          	auipc	a0,0x3
    375c:	03050513          	addi	a0,a0,48 # 6788 <malloc+0xaf2>
    3760:	00002097          	auipc	ra,0x2
    3764:	138080e7          	jalr	312(ra) # 5898 <unlink>
    3768:	cd59                	beqz	a0,3806 <rmdot+0xde>
  if(unlink("..") == 0){
    376a:	00004517          	auipc	a0,0x4
    376e:	b5e50513          	addi	a0,a0,-1186 # 72c8 <malloc+0x1632>
    3772:	00002097          	auipc	ra,0x2
    3776:	126080e7          	jalr	294(ra) # 5898 <unlink>
    377a:	c545                	beqz	a0,3822 <rmdot+0xfa>
  if(chdir("/") != 0){
    377c:	00004517          	auipc	a0,0x4
    3780:	af450513          	addi	a0,a0,-1292 # 7270 <malloc+0x15da>
    3784:	00002097          	auipc	ra,0x2
    3788:	134080e7          	jalr	308(ra) # 58b8 <chdir>
    378c:	e94d                	bnez	a0,383e <rmdot+0x116>
  if(unlink("dots/.") == 0){
    378e:	00004517          	auipc	a0,0x4
    3792:	14a50513          	addi	a0,a0,330 # 78d8 <malloc+0x1c42>
    3796:	00002097          	auipc	ra,0x2
    379a:	102080e7          	jalr	258(ra) # 5898 <unlink>
    379e:	cd55                	beqz	a0,385a <rmdot+0x132>
  if(unlink("dots/..") == 0){
    37a0:	00004517          	auipc	a0,0x4
    37a4:	16050513          	addi	a0,a0,352 # 7900 <malloc+0x1c6a>
    37a8:	00002097          	auipc	ra,0x2
    37ac:	0f0080e7          	jalr	240(ra) # 5898 <unlink>
    37b0:	c179                	beqz	a0,3876 <rmdot+0x14e>
  if(unlink("dots") != 0){
    37b2:	00004517          	auipc	a0,0x4
    37b6:	0be50513          	addi	a0,a0,190 # 7870 <malloc+0x1bda>
    37ba:	00002097          	auipc	ra,0x2
    37be:	0de080e7          	jalr	222(ra) # 5898 <unlink>
    37c2:	e961                	bnez	a0,3892 <rmdot+0x16a>
}
    37c4:	60e2                	ld	ra,24(sp)
    37c6:	6442                	ld	s0,16(sp)
    37c8:	64a2                	ld	s1,8(sp)
    37ca:	6105                	addi	sp,sp,32
    37cc:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    37ce:	85a6                	mv	a1,s1
    37d0:	00004517          	auipc	a0,0x4
    37d4:	0a850513          	addi	a0,a0,168 # 7878 <malloc+0x1be2>
    37d8:	00002097          	auipc	ra,0x2
    37dc:	400080e7          	jalr	1024(ra) # 5bd8 <printf>
    exit(1);
    37e0:	4505                	li	a0,1
    37e2:	00002097          	auipc	ra,0x2
    37e6:	066080e7          	jalr	102(ra) # 5848 <exit>
    printf("%s: chdir dots failed\n", s);
    37ea:	85a6                	mv	a1,s1
    37ec:	00004517          	auipc	a0,0x4
    37f0:	0a450513          	addi	a0,a0,164 # 7890 <malloc+0x1bfa>
    37f4:	00002097          	auipc	ra,0x2
    37f8:	3e4080e7          	jalr	996(ra) # 5bd8 <printf>
    exit(1);
    37fc:	4505                	li	a0,1
    37fe:	00002097          	auipc	ra,0x2
    3802:	04a080e7          	jalr	74(ra) # 5848 <exit>
    printf("%s: rm . worked!\n", s);
    3806:	85a6                	mv	a1,s1
    3808:	00004517          	auipc	a0,0x4
    380c:	0a050513          	addi	a0,a0,160 # 78a8 <malloc+0x1c12>
    3810:	00002097          	auipc	ra,0x2
    3814:	3c8080e7          	jalr	968(ra) # 5bd8 <printf>
    exit(1);
    3818:	4505                	li	a0,1
    381a:	00002097          	auipc	ra,0x2
    381e:	02e080e7          	jalr	46(ra) # 5848 <exit>
    printf("%s: rm .. worked!\n", s);
    3822:	85a6                	mv	a1,s1
    3824:	00004517          	auipc	a0,0x4
    3828:	09c50513          	addi	a0,a0,156 # 78c0 <malloc+0x1c2a>
    382c:	00002097          	auipc	ra,0x2
    3830:	3ac080e7          	jalr	940(ra) # 5bd8 <printf>
    exit(1);
    3834:	4505                	li	a0,1
    3836:	00002097          	auipc	ra,0x2
    383a:	012080e7          	jalr	18(ra) # 5848 <exit>
    printf("%s: chdir / failed\n", s);
    383e:	85a6                	mv	a1,s1
    3840:	00004517          	auipc	a0,0x4
    3844:	a3850513          	addi	a0,a0,-1480 # 7278 <malloc+0x15e2>
    3848:	00002097          	auipc	ra,0x2
    384c:	390080e7          	jalr	912(ra) # 5bd8 <printf>
    exit(1);
    3850:	4505                	li	a0,1
    3852:	00002097          	auipc	ra,0x2
    3856:	ff6080e7          	jalr	-10(ra) # 5848 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    385a:	85a6                	mv	a1,s1
    385c:	00004517          	auipc	a0,0x4
    3860:	08450513          	addi	a0,a0,132 # 78e0 <malloc+0x1c4a>
    3864:	00002097          	auipc	ra,0x2
    3868:	374080e7          	jalr	884(ra) # 5bd8 <printf>
    exit(1);
    386c:	4505                	li	a0,1
    386e:	00002097          	auipc	ra,0x2
    3872:	fda080e7          	jalr	-38(ra) # 5848 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3876:	85a6                	mv	a1,s1
    3878:	00004517          	auipc	a0,0x4
    387c:	09050513          	addi	a0,a0,144 # 7908 <malloc+0x1c72>
    3880:	00002097          	auipc	ra,0x2
    3884:	358080e7          	jalr	856(ra) # 5bd8 <printf>
    exit(1);
    3888:	4505                	li	a0,1
    388a:	00002097          	auipc	ra,0x2
    388e:	fbe080e7          	jalr	-66(ra) # 5848 <exit>
    printf("%s: unlink dots failed!\n", s);
    3892:	85a6                	mv	a1,s1
    3894:	00004517          	auipc	a0,0x4
    3898:	09450513          	addi	a0,a0,148 # 7928 <malloc+0x1c92>
    389c:	00002097          	auipc	ra,0x2
    38a0:	33c080e7          	jalr	828(ra) # 5bd8 <printf>
    exit(1);
    38a4:	4505                	li	a0,1
    38a6:	00002097          	auipc	ra,0x2
    38aa:	fa2080e7          	jalr	-94(ra) # 5848 <exit>

00000000000038ae <dirfile>:
{
    38ae:	1101                	addi	sp,sp,-32
    38b0:	ec06                	sd	ra,24(sp)
    38b2:	e822                	sd	s0,16(sp)
    38b4:	e426                	sd	s1,8(sp)
    38b6:	e04a                	sd	s2,0(sp)
    38b8:	1000                	addi	s0,sp,32
    38ba:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    38bc:	20000593          	li	a1,512
    38c0:	00002517          	auipc	a0,0x2
    38c4:	7d850513          	addi	a0,a0,2008 # 6098 <malloc+0x402>
    38c8:	00002097          	auipc	ra,0x2
    38cc:	fc0080e7          	jalr	-64(ra) # 5888 <open>
  if(fd < 0){
    38d0:	0e054d63          	bltz	a0,39ca <dirfile+0x11c>
  close(fd);
    38d4:	00002097          	auipc	ra,0x2
    38d8:	f9c080e7          	jalr	-100(ra) # 5870 <close>
  if(chdir("dirfile") == 0){
    38dc:	00002517          	auipc	a0,0x2
    38e0:	7bc50513          	addi	a0,a0,1980 # 6098 <malloc+0x402>
    38e4:	00002097          	auipc	ra,0x2
    38e8:	fd4080e7          	jalr	-44(ra) # 58b8 <chdir>
    38ec:	cd6d                	beqz	a0,39e6 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    38ee:	4581                	li	a1,0
    38f0:	00004517          	auipc	a0,0x4
    38f4:	09850513          	addi	a0,a0,152 # 7988 <malloc+0x1cf2>
    38f8:	00002097          	auipc	ra,0x2
    38fc:	f90080e7          	jalr	-112(ra) # 5888 <open>
  if(fd >= 0){
    3900:	10055163          	bgez	a0,3a02 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3904:	20000593          	li	a1,512
    3908:	00004517          	auipc	a0,0x4
    390c:	08050513          	addi	a0,a0,128 # 7988 <malloc+0x1cf2>
    3910:	00002097          	auipc	ra,0x2
    3914:	f78080e7          	jalr	-136(ra) # 5888 <open>
  if(fd >= 0){
    3918:	10055363          	bgez	a0,3a1e <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    391c:	00004517          	auipc	a0,0x4
    3920:	06c50513          	addi	a0,a0,108 # 7988 <malloc+0x1cf2>
    3924:	00002097          	auipc	ra,0x2
    3928:	f8c080e7          	jalr	-116(ra) # 58b0 <mkdir>
    392c:	10050763          	beqz	a0,3a3a <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3930:	00004517          	auipc	a0,0x4
    3934:	05850513          	addi	a0,a0,88 # 7988 <malloc+0x1cf2>
    3938:	00002097          	auipc	ra,0x2
    393c:	f60080e7          	jalr	-160(ra) # 5898 <unlink>
    3940:	10050b63          	beqz	a0,3a56 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3944:	00004597          	auipc	a1,0x4
    3948:	04458593          	addi	a1,a1,68 # 7988 <malloc+0x1cf2>
    394c:	00003517          	auipc	a0,0x3
    3950:	93c50513          	addi	a0,a0,-1732 # 6288 <malloc+0x5f2>
    3954:	00002097          	auipc	ra,0x2
    3958:	f54080e7          	jalr	-172(ra) # 58a8 <link>
    395c:	10050b63          	beqz	a0,3a72 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3960:	00002517          	auipc	a0,0x2
    3964:	73850513          	addi	a0,a0,1848 # 6098 <malloc+0x402>
    3968:	00002097          	auipc	ra,0x2
    396c:	f30080e7          	jalr	-208(ra) # 5898 <unlink>
    3970:	10051f63          	bnez	a0,3a8e <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3974:	4589                	li	a1,2
    3976:	00003517          	auipc	a0,0x3
    397a:	e1250513          	addi	a0,a0,-494 # 6788 <malloc+0xaf2>
    397e:	00002097          	auipc	ra,0x2
    3982:	f0a080e7          	jalr	-246(ra) # 5888 <open>
  if(fd >= 0){
    3986:	12055263          	bgez	a0,3aaa <dirfile+0x1fc>
  fd = open(".", 0);
    398a:	4581                	li	a1,0
    398c:	00003517          	auipc	a0,0x3
    3990:	dfc50513          	addi	a0,a0,-516 # 6788 <malloc+0xaf2>
    3994:	00002097          	auipc	ra,0x2
    3998:	ef4080e7          	jalr	-268(ra) # 5888 <open>
    399c:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    399e:	4605                	li	a2,1
    39a0:	00002597          	auipc	a1,0x2
    39a4:	7c058593          	addi	a1,a1,1984 # 6160 <malloc+0x4ca>
    39a8:	00002097          	auipc	ra,0x2
    39ac:	ec0080e7          	jalr	-320(ra) # 5868 <write>
    39b0:	10a04b63          	bgtz	a0,3ac6 <dirfile+0x218>
  close(fd);
    39b4:	8526                	mv	a0,s1
    39b6:	00002097          	auipc	ra,0x2
    39ba:	eba080e7          	jalr	-326(ra) # 5870 <close>
}
    39be:	60e2                	ld	ra,24(sp)
    39c0:	6442                	ld	s0,16(sp)
    39c2:	64a2                	ld	s1,8(sp)
    39c4:	6902                	ld	s2,0(sp)
    39c6:	6105                	addi	sp,sp,32
    39c8:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    39ca:	85ca                	mv	a1,s2
    39cc:	00004517          	auipc	a0,0x4
    39d0:	f7c50513          	addi	a0,a0,-132 # 7948 <malloc+0x1cb2>
    39d4:	00002097          	auipc	ra,0x2
    39d8:	204080e7          	jalr	516(ra) # 5bd8 <printf>
    exit(1);
    39dc:	4505                	li	a0,1
    39de:	00002097          	auipc	ra,0x2
    39e2:	e6a080e7          	jalr	-406(ra) # 5848 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    39e6:	85ca                	mv	a1,s2
    39e8:	00004517          	auipc	a0,0x4
    39ec:	f8050513          	addi	a0,a0,-128 # 7968 <malloc+0x1cd2>
    39f0:	00002097          	auipc	ra,0x2
    39f4:	1e8080e7          	jalr	488(ra) # 5bd8 <printf>
    exit(1);
    39f8:	4505                	li	a0,1
    39fa:	00002097          	auipc	ra,0x2
    39fe:	e4e080e7          	jalr	-434(ra) # 5848 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3a02:	85ca                	mv	a1,s2
    3a04:	00004517          	auipc	a0,0x4
    3a08:	f9450513          	addi	a0,a0,-108 # 7998 <malloc+0x1d02>
    3a0c:	00002097          	auipc	ra,0x2
    3a10:	1cc080e7          	jalr	460(ra) # 5bd8 <printf>
    exit(1);
    3a14:	4505                	li	a0,1
    3a16:	00002097          	auipc	ra,0x2
    3a1a:	e32080e7          	jalr	-462(ra) # 5848 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3a1e:	85ca                	mv	a1,s2
    3a20:	00004517          	auipc	a0,0x4
    3a24:	f7850513          	addi	a0,a0,-136 # 7998 <malloc+0x1d02>
    3a28:	00002097          	auipc	ra,0x2
    3a2c:	1b0080e7          	jalr	432(ra) # 5bd8 <printf>
    exit(1);
    3a30:	4505                	li	a0,1
    3a32:	00002097          	auipc	ra,0x2
    3a36:	e16080e7          	jalr	-490(ra) # 5848 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3a3a:	85ca                	mv	a1,s2
    3a3c:	00004517          	auipc	a0,0x4
    3a40:	f8450513          	addi	a0,a0,-124 # 79c0 <malloc+0x1d2a>
    3a44:	00002097          	auipc	ra,0x2
    3a48:	194080e7          	jalr	404(ra) # 5bd8 <printf>
    exit(1);
    3a4c:	4505                	li	a0,1
    3a4e:	00002097          	auipc	ra,0x2
    3a52:	dfa080e7          	jalr	-518(ra) # 5848 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3a56:	85ca                	mv	a1,s2
    3a58:	00004517          	auipc	a0,0x4
    3a5c:	f9050513          	addi	a0,a0,-112 # 79e8 <malloc+0x1d52>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	178080e7          	jalr	376(ra) # 5bd8 <printf>
    exit(1);
    3a68:	4505                	li	a0,1
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	dde080e7          	jalr	-546(ra) # 5848 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3a72:	85ca                	mv	a1,s2
    3a74:	00004517          	auipc	a0,0x4
    3a78:	f9c50513          	addi	a0,a0,-100 # 7a10 <malloc+0x1d7a>
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	15c080e7          	jalr	348(ra) # 5bd8 <printf>
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	00002097          	auipc	ra,0x2
    3a8a:	dc2080e7          	jalr	-574(ra) # 5848 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3a8e:	85ca                	mv	a1,s2
    3a90:	00004517          	auipc	a0,0x4
    3a94:	fa850513          	addi	a0,a0,-88 # 7a38 <malloc+0x1da2>
    3a98:	00002097          	auipc	ra,0x2
    3a9c:	140080e7          	jalr	320(ra) # 5bd8 <printf>
    exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	00002097          	auipc	ra,0x2
    3aa6:	da6080e7          	jalr	-602(ra) # 5848 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3aaa:	85ca                	mv	a1,s2
    3aac:	00004517          	auipc	a0,0x4
    3ab0:	fac50513          	addi	a0,a0,-84 # 7a58 <malloc+0x1dc2>
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	124080e7          	jalr	292(ra) # 5bd8 <printf>
    exit(1);
    3abc:	4505                	li	a0,1
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	d8a080e7          	jalr	-630(ra) # 5848 <exit>
    printf("%s: write . succeeded!\n", s);
    3ac6:	85ca                	mv	a1,s2
    3ac8:	00004517          	auipc	a0,0x4
    3acc:	fb850513          	addi	a0,a0,-72 # 7a80 <malloc+0x1dea>
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	108080e7          	jalr	264(ra) # 5bd8 <printf>
    exit(1);
    3ad8:	4505                	li	a0,1
    3ada:	00002097          	auipc	ra,0x2
    3ade:	d6e080e7          	jalr	-658(ra) # 5848 <exit>

0000000000003ae2 <iref>:
{
    3ae2:	7139                	addi	sp,sp,-64
    3ae4:	fc06                	sd	ra,56(sp)
    3ae6:	f822                	sd	s0,48(sp)
    3ae8:	f426                	sd	s1,40(sp)
    3aea:	f04a                	sd	s2,32(sp)
    3aec:	ec4e                	sd	s3,24(sp)
    3aee:	e852                	sd	s4,16(sp)
    3af0:	e456                	sd	s5,8(sp)
    3af2:	e05a                	sd	s6,0(sp)
    3af4:	0080                	addi	s0,sp,64
    3af6:	8b2a                	mv	s6,a0
    3af8:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3afc:	00004a17          	auipc	s4,0x4
    3b00:	f9ca0a13          	addi	s4,s4,-100 # 7a98 <malloc+0x1e02>
    mkdir("");
    3b04:	00004497          	auipc	s1,0x4
    3b08:	aa448493          	addi	s1,s1,-1372 # 75a8 <malloc+0x1912>
    link("README", "");
    3b0c:	00002a97          	auipc	s5,0x2
    3b10:	77ca8a93          	addi	s5,s5,1916 # 6288 <malloc+0x5f2>
    fd = open("xx", O_CREATE);
    3b14:	00004997          	auipc	s3,0x4
    3b18:	e7c98993          	addi	s3,s3,-388 # 7990 <malloc+0x1cfa>
    3b1c:	a891                	j	3b70 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3b1e:	85da                	mv	a1,s6
    3b20:	00004517          	auipc	a0,0x4
    3b24:	f8050513          	addi	a0,a0,-128 # 7aa0 <malloc+0x1e0a>
    3b28:	00002097          	auipc	ra,0x2
    3b2c:	0b0080e7          	jalr	176(ra) # 5bd8 <printf>
      exit(1);
    3b30:	4505                	li	a0,1
    3b32:	00002097          	auipc	ra,0x2
    3b36:	d16080e7          	jalr	-746(ra) # 5848 <exit>
      printf("%s: chdir irefd failed\n", s);
    3b3a:	85da                	mv	a1,s6
    3b3c:	00004517          	auipc	a0,0x4
    3b40:	f7c50513          	addi	a0,a0,-132 # 7ab8 <malloc+0x1e22>
    3b44:	00002097          	auipc	ra,0x2
    3b48:	094080e7          	jalr	148(ra) # 5bd8 <printf>
      exit(1);
    3b4c:	4505                	li	a0,1
    3b4e:	00002097          	auipc	ra,0x2
    3b52:	cfa080e7          	jalr	-774(ra) # 5848 <exit>
      close(fd);
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	d1a080e7          	jalr	-742(ra) # 5870 <close>
    3b5e:	a889                	j	3bb0 <iref+0xce>
    unlink("xx");
    3b60:	854e                	mv	a0,s3
    3b62:	00002097          	auipc	ra,0x2
    3b66:	d36080e7          	jalr	-714(ra) # 5898 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3b6a:	397d                	addiw	s2,s2,-1
    3b6c:	06090063          	beqz	s2,3bcc <iref+0xea>
    if(mkdir("irefd") != 0){
    3b70:	8552                	mv	a0,s4
    3b72:	00002097          	auipc	ra,0x2
    3b76:	d3e080e7          	jalr	-706(ra) # 58b0 <mkdir>
    3b7a:	f155                	bnez	a0,3b1e <iref+0x3c>
    if(chdir("irefd") != 0){
    3b7c:	8552                	mv	a0,s4
    3b7e:	00002097          	auipc	ra,0x2
    3b82:	d3a080e7          	jalr	-710(ra) # 58b8 <chdir>
    3b86:	f955                	bnez	a0,3b3a <iref+0x58>
    mkdir("");
    3b88:	8526                	mv	a0,s1
    3b8a:	00002097          	auipc	ra,0x2
    3b8e:	d26080e7          	jalr	-730(ra) # 58b0 <mkdir>
    link("README", "");
    3b92:	85a6                	mv	a1,s1
    3b94:	8556                	mv	a0,s5
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	d12080e7          	jalr	-750(ra) # 58a8 <link>
    fd = open("", O_CREATE);
    3b9e:	20000593          	li	a1,512
    3ba2:	8526                	mv	a0,s1
    3ba4:	00002097          	auipc	ra,0x2
    3ba8:	ce4080e7          	jalr	-796(ra) # 5888 <open>
    if(fd >= 0)
    3bac:	fa0555e3          	bgez	a0,3b56 <iref+0x74>
    fd = open("xx", O_CREATE);
    3bb0:	20000593          	li	a1,512
    3bb4:	854e                	mv	a0,s3
    3bb6:	00002097          	auipc	ra,0x2
    3bba:	cd2080e7          	jalr	-814(ra) # 5888 <open>
    if(fd >= 0)
    3bbe:	fa0541e3          	bltz	a0,3b60 <iref+0x7e>
      close(fd);
    3bc2:	00002097          	auipc	ra,0x2
    3bc6:	cae080e7          	jalr	-850(ra) # 5870 <close>
    3bca:	bf59                	j	3b60 <iref+0x7e>
    3bcc:	03300493          	li	s1,51
    chdir("..");
    3bd0:	00003997          	auipc	s3,0x3
    3bd4:	6f898993          	addi	s3,s3,1784 # 72c8 <malloc+0x1632>
    unlink("irefd");
    3bd8:	00004917          	auipc	s2,0x4
    3bdc:	ec090913          	addi	s2,s2,-320 # 7a98 <malloc+0x1e02>
    chdir("..");
    3be0:	854e                	mv	a0,s3
    3be2:	00002097          	auipc	ra,0x2
    3be6:	cd6080e7          	jalr	-810(ra) # 58b8 <chdir>
    unlink("irefd");
    3bea:	854a                	mv	a0,s2
    3bec:	00002097          	auipc	ra,0x2
    3bf0:	cac080e7          	jalr	-852(ra) # 5898 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3bf4:	34fd                	addiw	s1,s1,-1
    3bf6:	f4ed                	bnez	s1,3be0 <iref+0xfe>
  chdir("/");
    3bf8:	00003517          	auipc	a0,0x3
    3bfc:	67850513          	addi	a0,a0,1656 # 7270 <malloc+0x15da>
    3c00:	00002097          	auipc	ra,0x2
    3c04:	cb8080e7          	jalr	-840(ra) # 58b8 <chdir>
}
    3c08:	70e2                	ld	ra,56(sp)
    3c0a:	7442                	ld	s0,48(sp)
    3c0c:	74a2                	ld	s1,40(sp)
    3c0e:	7902                	ld	s2,32(sp)
    3c10:	69e2                	ld	s3,24(sp)
    3c12:	6a42                	ld	s4,16(sp)
    3c14:	6aa2                	ld	s5,8(sp)
    3c16:	6b02                	ld	s6,0(sp)
    3c18:	6121                	addi	sp,sp,64
    3c1a:	8082                	ret

0000000000003c1c <openiputtest>:
{
    3c1c:	7179                	addi	sp,sp,-48
    3c1e:	f406                	sd	ra,40(sp)
    3c20:	f022                	sd	s0,32(sp)
    3c22:	ec26                	sd	s1,24(sp)
    3c24:	1800                	addi	s0,sp,48
    3c26:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3c28:	00004517          	auipc	a0,0x4
    3c2c:	ea850513          	addi	a0,a0,-344 # 7ad0 <malloc+0x1e3a>
    3c30:	00002097          	auipc	ra,0x2
    3c34:	c80080e7          	jalr	-896(ra) # 58b0 <mkdir>
    3c38:	04054263          	bltz	a0,3c7c <openiputtest+0x60>
  pid = fork();
    3c3c:	00002097          	auipc	ra,0x2
    3c40:	c04080e7          	jalr	-1020(ra) # 5840 <fork>
  if(pid < 0){
    3c44:	04054a63          	bltz	a0,3c98 <openiputtest+0x7c>
  if(pid == 0){
    3c48:	e93d                	bnez	a0,3cbe <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3c4a:	4589                	li	a1,2
    3c4c:	00004517          	auipc	a0,0x4
    3c50:	e8450513          	addi	a0,a0,-380 # 7ad0 <malloc+0x1e3a>
    3c54:	00002097          	auipc	ra,0x2
    3c58:	c34080e7          	jalr	-972(ra) # 5888 <open>
    if(fd >= 0){
    3c5c:	04054c63          	bltz	a0,3cb4 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3c60:	85a6                	mv	a1,s1
    3c62:	00004517          	auipc	a0,0x4
    3c66:	e8e50513          	addi	a0,a0,-370 # 7af0 <malloc+0x1e5a>
    3c6a:	00002097          	auipc	ra,0x2
    3c6e:	f6e080e7          	jalr	-146(ra) # 5bd8 <printf>
      exit(1);
    3c72:	4505                	li	a0,1
    3c74:	00002097          	auipc	ra,0x2
    3c78:	bd4080e7          	jalr	-1068(ra) # 5848 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3c7c:	85a6                	mv	a1,s1
    3c7e:	00004517          	auipc	a0,0x4
    3c82:	e5a50513          	addi	a0,a0,-422 # 7ad8 <malloc+0x1e42>
    3c86:	00002097          	auipc	ra,0x2
    3c8a:	f52080e7          	jalr	-174(ra) # 5bd8 <printf>
    exit(1);
    3c8e:	4505                	li	a0,1
    3c90:	00002097          	auipc	ra,0x2
    3c94:	bb8080e7          	jalr	-1096(ra) # 5848 <exit>
    printf("%s: fork failed\n", s);
    3c98:	85a6                	mv	a1,s1
    3c9a:	00003517          	auipc	a0,0x3
    3c9e:	c2650513          	addi	a0,a0,-986 # 68c0 <malloc+0xc2a>
    3ca2:	00002097          	auipc	ra,0x2
    3ca6:	f36080e7          	jalr	-202(ra) # 5bd8 <printf>
    exit(1);
    3caa:	4505                	li	a0,1
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	b9c080e7          	jalr	-1124(ra) # 5848 <exit>
    exit(0);
    3cb4:	4501                	li	a0,0
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	b92080e7          	jalr	-1134(ra) # 5848 <exit>
  sleep(1);
    3cbe:	4505                	li	a0,1
    3cc0:	00002097          	auipc	ra,0x2
    3cc4:	c18080e7          	jalr	-1000(ra) # 58d8 <sleep>
  if(unlink("oidir") != 0){
    3cc8:	00004517          	auipc	a0,0x4
    3ccc:	e0850513          	addi	a0,a0,-504 # 7ad0 <malloc+0x1e3a>
    3cd0:	00002097          	auipc	ra,0x2
    3cd4:	bc8080e7          	jalr	-1080(ra) # 5898 <unlink>
    3cd8:	cd19                	beqz	a0,3cf6 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3cda:	85a6                	mv	a1,s1
    3cdc:	00003517          	auipc	a0,0x3
    3ce0:	dd450513          	addi	a0,a0,-556 # 6ab0 <malloc+0xe1a>
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	ef4080e7          	jalr	-268(ra) # 5bd8 <printf>
    exit(1);
    3cec:	4505                	li	a0,1
    3cee:	00002097          	auipc	ra,0x2
    3cf2:	b5a080e7          	jalr	-1190(ra) # 5848 <exit>
  wait(&xstatus);
    3cf6:	fdc40513          	addi	a0,s0,-36
    3cfa:	00002097          	auipc	ra,0x2
    3cfe:	b56080e7          	jalr	-1194(ra) # 5850 <wait>
  exit(xstatus);
    3d02:	fdc42503          	lw	a0,-36(s0)
    3d06:	00002097          	auipc	ra,0x2
    3d0a:	b42080e7          	jalr	-1214(ra) # 5848 <exit>

0000000000003d0e <forkforkfork>:
{
    3d0e:	1101                	addi	sp,sp,-32
    3d10:	ec06                	sd	ra,24(sp)
    3d12:	e822                	sd	s0,16(sp)
    3d14:	e426                	sd	s1,8(sp)
    3d16:	1000                	addi	s0,sp,32
    3d18:	84aa                	mv	s1,a0
  unlink("stopforking");
    3d1a:	00004517          	auipc	a0,0x4
    3d1e:	dfe50513          	addi	a0,a0,-514 # 7b18 <malloc+0x1e82>
    3d22:	00002097          	auipc	ra,0x2
    3d26:	b76080e7          	jalr	-1162(ra) # 5898 <unlink>
  int pid = fork();
    3d2a:	00002097          	auipc	ra,0x2
    3d2e:	b16080e7          	jalr	-1258(ra) # 5840 <fork>
  if(pid < 0){
    3d32:	04054563          	bltz	a0,3d7c <forkforkfork+0x6e>
  if(pid == 0){
    3d36:	c12d                	beqz	a0,3d98 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3d38:	4551                	li	a0,20
    3d3a:	00002097          	auipc	ra,0x2
    3d3e:	b9e080e7          	jalr	-1122(ra) # 58d8 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3d42:	20200593          	li	a1,514
    3d46:	00004517          	auipc	a0,0x4
    3d4a:	dd250513          	addi	a0,a0,-558 # 7b18 <malloc+0x1e82>
    3d4e:	00002097          	auipc	ra,0x2
    3d52:	b3a080e7          	jalr	-1222(ra) # 5888 <open>
    3d56:	00002097          	auipc	ra,0x2
    3d5a:	b1a080e7          	jalr	-1254(ra) # 5870 <close>
  wait(0);
    3d5e:	4501                	li	a0,0
    3d60:	00002097          	auipc	ra,0x2
    3d64:	af0080e7          	jalr	-1296(ra) # 5850 <wait>
  sleep(10); // one second
    3d68:	4529                	li	a0,10
    3d6a:	00002097          	auipc	ra,0x2
    3d6e:	b6e080e7          	jalr	-1170(ra) # 58d8 <sleep>
}
    3d72:	60e2                	ld	ra,24(sp)
    3d74:	6442                	ld	s0,16(sp)
    3d76:	64a2                	ld	s1,8(sp)
    3d78:	6105                	addi	sp,sp,32
    3d7a:	8082                	ret
    printf("%s: fork failed", s);
    3d7c:	85a6                	mv	a1,s1
    3d7e:	00003517          	auipc	a0,0x3
    3d82:	d0250513          	addi	a0,a0,-766 # 6a80 <malloc+0xdea>
    3d86:	00002097          	auipc	ra,0x2
    3d8a:	e52080e7          	jalr	-430(ra) # 5bd8 <printf>
    exit(1);
    3d8e:	4505                	li	a0,1
    3d90:	00002097          	auipc	ra,0x2
    3d94:	ab8080e7          	jalr	-1352(ra) # 5848 <exit>
      int fd = open("stopforking", 0);
    3d98:	00004497          	auipc	s1,0x4
    3d9c:	d8048493          	addi	s1,s1,-640 # 7b18 <malloc+0x1e82>
    3da0:	4581                	li	a1,0
    3da2:	8526                	mv	a0,s1
    3da4:	00002097          	auipc	ra,0x2
    3da8:	ae4080e7          	jalr	-1308(ra) # 5888 <open>
      if(fd >= 0){
    3dac:	02055463          	bgez	a0,3dd4 <forkforkfork+0xc6>
      if(fork() < 0){
    3db0:	00002097          	auipc	ra,0x2
    3db4:	a90080e7          	jalr	-1392(ra) # 5840 <fork>
    3db8:	fe0554e3          	bgez	a0,3da0 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3dbc:	20200593          	li	a1,514
    3dc0:	8526                	mv	a0,s1
    3dc2:	00002097          	auipc	ra,0x2
    3dc6:	ac6080e7          	jalr	-1338(ra) # 5888 <open>
    3dca:	00002097          	auipc	ra,0x2
    3dce:	aa6080e7          	jalr	-1370(ra) # 5870 <close>
    3dd2:	b7f9                	j	3da0 <forkforkfork+0x92>
        exit(0);
    3dd4:	4501                	li	a0,0
    3dd6:	00002097          	auipc	ra,0x2
    3dda:	a72080e7          	jalr	-1422(ra) # 5848 <exit>

0000000000003dde <killstatus>:
{
    3dde:	7139                	addi	sp,sp,-64
    3de0:	fc06                	sd	ra,56(sp)
    3de2:	f822                	sd	s0,48(sp)
    3de4:	f426                	sd	s1,40(sp)
    3de6:	f04a                	sd	s2,32(sp)
    3de8:	ec4e                	sd	s3,24(sp)
    3dea:	e852                	sd	s4,16(sp)
    3dec:	0080                	addi	s0,sp,64
    3dee:	8a2a                	mv	s4,a0
    3df0:	06400913          	li	s2,100
    if(xst != -1) {
    3df4:	59fd                	li	s3,-1
    int pid1 = fork();
    3df6:	00002097          	auipc	ra,0x2
    3dfa:	a4a080e7          	jalr	-1462(ra) # 5840 <fork>
    3dfe:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3e00:	02054f63          	bltz	a0,3e3e <killstatus+0x60>
    if(pid1 == 0){
    3e04:	c939                	beqz	a0,3e5a <killstatus+0x7c>
    sleep(1);
    3e06:	4505                	li	a0,1
    3e08:	00002097          	auipc	ra,0x2
    3e0c:	ad0080e7          	jalr	-1328(ra) # 58d8 <sleep>
    kill(pid1);
    3e10:	8526                	mv	a0,s1
    3e12:	00002097          	auipc	ra,0x2
    3e16:	a66080e7          	jalr	-1434(ra) # 5878 <kill>
    wait(&xst);
    3e1a:	fcc40513          	addi	a0,s0,-52
    3e1e:	00002097          	auipc	ra,0x2
    3e22:	a32080e7          	jalr	-1486(ra) # 5850 <wait>
    if(xst != -1) {
    3e26:	fcc42783          	lw	a5,-52(s0)
    3e2a:	03379d63          	bne	a5,s3,3e64 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    3e2e:	397d                	addiw	s2,s2,-1
    3e30:	fc0913e3          	bnez	s2,3df6 <killstatus+0x18>
  exit(0);
    3e34:	4501                	li	a0,0
    3e36:	00002097          	auipc	ra,0x2
    3e3a:	a12080e7          	jalr	-1518(ra) # 5848 <exit>
      printf("%s: fork failed\n", s);
    3e3e:	85d2                	mv	a1,s4
    3e40:	00003517          	auipc	a0,0x3
    3e44:	a8050513          	addi	a0,a0,-1408 # 68c0 <malloc+0xc2a>
    3e48:	00002097          	auipc	ra,0x2
    3e4c:	d90080e7          	jalr	-624(ra) # 5bd8 <printf>
      exit(1);
    3e50:	4505                	li	a0,1
    3e52:	00002097          	auipc	ra,0x2
    3e56:	9f6080e7          	jalr	-1546(ra) # 5848 <exit>
        getpid();
    3e5a:	00002097          	auipc	ra,0x2
    3e5e:	a6e080e7          	jalr	-1426(ra) # 58c8 <getpid>
      while(1) {
    3e62:	bfe5                	j	3e5a <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    3e64:	85d2                	mv	a1,s4
    3e66:	00004517          	auipc	a0,0x4
    3e6a:	cc250513          	addi	a0,a0,-830 # 7b28 <malloc+0x1e92>
    3e6e:	00002097          	auipc	ra,0x2
    3e72:	d6a080e7          	jalr	-662(ra) # 5bd8 <printf>
       exit(1);
    3e76:	4505                	li	a0,1
    3e78:	00002097          	auipc	ra,0x2
    3e7c:	9d0080e7          	jalr	-1584(ra) # 5848 <exit>

0000000000003e80 <preempt>:
{
    3e80:	7139                	addi	sp,sp,-64
    3e82:	fc06                	sd	ra,56(sp)
    3e84:	f822                	sd	s0,48(sp)
    3e86:	f426                	sd	s1,40(sp)
    3e88:	f04a                	sd	s2,32(sp)
    3e8a:	ec4e                	sd	s3,24(sp)
    3e8c:	e852                	sd	s4,16(sp)
    3e8e:	0080                	addi	s0,sp,64
    3e90:	84aa                	mv	s1,a0
  pid1 = fork();
    3e92:	00002097          	auipc	ra,0x2
    3e96:	9ae080e7          	jalr	-1618(ra) # 5840 <fork>
  if(pid1 < 0) {
    3e9a:	00054563          	bltz	a0,3ea4 <preempt+0x24>
    3e9e:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    3ea0:	e105                	bnez	a0,3ec0 <preempt+0x40>
    for(;;)
    3ea2:	a001                	j	3ea2 <preempt+0x22>
    printf("%s: fork failed", s);
    3ea4:	85a6                	mv	a1,s1
    3ea6:	00003517          	auipc	a0,0x3
    3eaa:	bda50513          	addi	a0,a0,-1062 # 6a80 <malloc+0xdea>
    3eae:	00002097          	auipc	ra,0x2
    3eb2:	d2a080e7          	jalr	-726(ra) # 5bd8 <printf>
    exit(1);
    3eb6:	4505                	li	a0,1
    3eb8:	00002097          	auipc	ra,0x2
    3ebc:	990080e7          	jalr	-1648(ra) # 5848 <exit>
  pid2 = fork();
    3ec0:	00002097          	auipc	ra,0x2
    3ec4:	980080e7          	jalr	-1664(ra) # 5840 <fork>
    3ec8:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3eca:	00054463          	bltz	a0,3ed2 <preempt+0x52>
  if(pid2 == 0)
    3ece:	e105                	bnez	a0,3eee <preempt+0x6e>
    for(;;)
    3ed0:	a001                	j	3ed0 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3ed2:	85a6                	mv	a1,s1
    3ed4:	00003517          	auipc	a0,0x3
    3ed8:	9ec50513          	addi	a0,a0,-1556 # 68c0 <malloc+0xc2a>
    3edc:	00002097          	auipc	ra,0x2
    3ee0:	cfc080e7          	jalr	-772(ra) # 5bd8 <printf>
    exit(1);
    3ee4:	4505                	li	a0,1
    3ee6:	00002097          	auipc	ra,0x2
    3eea:	962080e7          	jalr	-1694(ra) # 5848 <exit>
  pipe(pfds);
    3eee:	fc840513          	addi	a0,s0,-56
    3ef2:	00002097          	auipc	ra,0x2
    3ef6:	966080e7          	jalr	-1690(ra) # 5858 <pipe>
  pid3 = fork();
    3efa:	00002097          	auipc	ra,0x2
    3efe:	946080e7          	jalr	-1722(ra) # 5840 <fork>
    3f02:	892a                	mv	s2,a0
  if(pid3 < 0) {
    3f04:	02054e63          	bltz	a0,3f40 <preempt+0xc0>
  if(pid3 == 0){
    3f08:	e525                	bnez	a0,3f70 <preempt+0xf0>
    close(pfds[0]);
    3f0a:	fc842503          	lw	a0,-56(s0)
    3f0e:	00002097          	auipc	ra,0x2
    3f12:	962080e7          	jalr	-1694(ra) # 5870 <close>
    if(write(pfds[1], "x", 1) != 1)
    3f16:	4605                	li	a2,1
    3f18:	00002597          	auipc	a1,0x2
    3f1c:	24858593          	addi	a1,a1,584 # 6160 <malloc+0x4ca>
    3f20:	fcc42503          	lw	a0,-52(s0)
    3f24:	00002097          	auipc	ra,0x2
    3f28:	944080e7          	jalr	-1724(ra) # 5868 <write>
    3f2c:	4785                	li	a5,1
    3f2e:	02f51763          	bne	a0,a5,3f5c <preempt+0xdc>
    close(pfds[1]);
    3f32:	fcc42503          	lw	a0,-52(s0)
    3f36:	00002097          	auipc	ra,0x2
    3f3a:	93a080e7          	jalr	-1734(ra) # 5870 <close>
    for(;;)
    3f3e:	a001                	j	3f3e <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3f40:	85a6                	mv	a1,s1
    3f42:	00003517          	auipc	a0,0x3
    3f46:	97e50513          	addi	a0,a0,-1666 # 68c0 <malloc+0xc2a>
    3f4a:	00002097          	auipc	ra,0x2
    3f4e:	c8e080e7          	jalr	-882(ra) # 5bd8 <printf>
     exit(1);
    3f52:	4505                	li	a0,1
    3f54:	00002097          	auipc	ra,0x2
    3f58:	8f4080e7          	jalr	-1804(ra) # 5848 <exit>
      printf("%s: preempt write error", s);
    3f5c:	85a6                	mv	a1,s1
    3f5e:	00004517          	auipc	a0,0x4
    3f62:	bea50513          	addi	a0,a0,-1046 # 7b48 <malloc+0x1eb2>
    3f66:	00002097          	auipc	ra,0x2
    3f6a:	c72080e7          	jalr	-910(ra) # 5bd8 <printf>
    3f6e:	b7d1                	j	3f32 <preempt+0xb2>
  close(pfds[1]);
    3f70:	fcc42503          	lw	a0,-52(s0)
    3f74:	00002097          	auipc	ra,0x2
    3f78:	8fc080e7          	jalr	-1796(ra) # 5870 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3f7c:	660d                	lui	a2,0x3
    3f7e:	00008597          	auipc	a1,0x8
    3f82:	dca58593          	addi	a1,a1,-566 # bd48 <buf>
    3f86:	fc842503          	lw	a0,-56(s0)
    3f8a:	00002097          	auipc	ra,0x2
    3f8e:	8d6080e7          	jalr	-1834(ra) # 5860 <read>
    3f92:	4785                	li	a5,1
    3f94:	02f50363          	beq	a0,a5,3fba <preempt+0x13a>
    printf("%s: preempt read error", s);
    3f98:	85a6                	mv	a1,s1
    3f9a:	00004517          	auipc	a0,0x4
    3f9e:	bc650513          	addi	a0,a0,-1082 # 7b60 <malloc+0x1eca>
    3fa2:	00002097          	auipc	ra,0x2
    3fa6:	c36080e7          	jalr	-970(ra) # 5bd8 <printf>
}
    3faa:	70e2                	ld	ra,56(sp)
    3fac:	7442                	ld	s0,48(sp)
    3fae:	74a2                	ld	s1,40(sp)
    3fb0:	7902                	ld	s2,32(sp)
    3fb2:	69e2                	ld	s3,24(sp)
    3fb4:	6a42                	ld	s4,16(sp)
    3fb6:	6121                	addi	sp,sp,64
    3fb8:	8082                	ret
  close(pfds[0]);
    3fba:	fc842503          	lw	a0,-56(s0)
    3fbe:	00002097          	auipc	ra,0x2
    3fc2:	8b2080e7          	jalr	-1870(ra) # 5870 <close>
  printf("kill... ");
    3fc6:	00004517          	auipc	a0,0x4
    3fca:	bb250513          	addi	a0,a0,-1102 # 7b78 <malloc+0x1ee2>
    3fce:	00002097          	auipc	ra,0x2
    3fd2:	c0a080e7          	jalr	-1014(ra) # 5bd8 <printf>
  kill(pid1);
    3fd6:	8552                	mv	a0,s4
    3fd8:	00002097          	auipc	ra,0x2
    3fdc:	8a0080e7          	jalr	-1888(ra) # 5878 <kill>
  kill(pid2);
    3fe0:	854e                	mv	a0,s3
    3fe2:	00002097          	auipc	ra,0x2
    3fe6:	896080e7          	jalr	-1898(ra) # 5878 <kill>
  kill(pid3);
    3fea:	854a                	mv	a0,s2
    3fec:	00002097          	auipc	ra,0x2
    3ff0:	88c080e7          	jalr	-1908(ra) # 5878 <kill>
  printf("wait... ");
    3ff4:	00004517          	auipc	a0,0x4
    3ff8:	b9450513          	addi	a0,a0,-1132 # 7b88 <malloc+0x1ef2>
    3ffc:	00002097          	auipc	ra,0x2
    4000:	bdc080e7          	jalr	-1060(ra) # 5bd8 <printf>
  wait(0);
    4004:	4501                	li	a0,0
    4006:	00002097          	auipc	ra,0x2
    400a:	84a080e7          	jalr	-1974(ra) # 5850 <wait>
  wait(0);
    400e:	4501                	li	a0,0
    4010:	00002097          	auipc	ra,0x2
    4014:	840080e7          	jalr	-1984(ra) # 5850 <wait>
  wait(0);
    4018:	4501                	li	a0,0
    401a:	00002097          	auipc	ra,0x2
    401e:	836080e7          	jalr	-1994(ra) # 5850 <wait>
    4022:	b761                	j	3faa <preempt+0x12a>

0000000000004024 <reparent>:
{
    4024:	7179                	addi	sp,sp,-48
    4026:	f406                	sd	ra,40(sp)
    4028:	f022                	sd	s0,32(sp)
    402a:	ec26                	sd	s1,24(sp)
    402c:	e84a                	sd	s2,16(sp)
    402e:	e44e                	sd	s3,8(sp)
    4030:	e052                	sd	s4,0(sp)
    4032:	1800                	addi	s0,sp,48
    4034:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4036:	00002097          	auipc	ra,0x2
    403a:	892080e7          	jalr	-1902(ra) # 58c8 <getpid>
    403e:	8a2a                	mv	s4,a0
    4040:	0c800913          	li	s2,200
    int pid = fork();
    4044:	00001097          	auipc	ra,0x1
    4048:	7fc080e7          	jalr	2044(ra) # 5840 <fork>
    404c:	84aa                	mv	s1,a0
    if(pid < 0){
    404e:	02054263          	bltz	a0,4072 <reparent+0x4e>
    if(pid){
    4052:	cd21                	beqz	a0,40aa <reparent+0x86>
      if(wait(0) != pid){
    4054:	4501                	li	a0,0
    4056:	00001097          	auipc	ra,0x1
    405a:	7fa080e7          	jalr	2042(ra) # 5850 <wait>
    405e:	02951863          	bne	a0,s1,408e <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4062:	397d                	addiw	s2,s2,-1
    4064:	fe0910e3          	bnez	s2,4044 <reparent+0x20>
  exit(0);
    4068:	4501                	li	a0,0
    406a:	00001097          	auipc	ra,0x1
    406e:	7de080e7          	jalr	2014(ra) # 5848 <exit>
      printf("%s: fork failed\n", s);
    4072:	85ce                	mv	a1,s3
    4074:	00003517          	auipc	a0,0x3
    4078:	84c50513          	addi	a0,a0,-1972 # 68c0 <malloc+0xc2a>
    407c:	00002097          	auipc	ra,0x2
    4080:	b5c080e7          	jalr	-1188(ra) # 5bd8 <printf>
      exit(1);
    4084:	4505                	li	a0,1
    4086:	00001097          	auipc	ra,0x1
    408a:	7c2080e7          	jalr	1986(ra) # 5848 <exit>
        printf("%s: wait wrong pid\n", s);
    408e:	85ce                	mv	a1,s3
    4090:	00003517          	auipc	a0,0x3
    4094:	9b850513          	addi	a0,a0,-1608 # 6a48 <malloc+0xdb2>
    4098:	00002097          	auipc	ra,0x2
    409c:	b40080e7          	jalr	-1216(ra) # 5bd8 <printf>
        exit(1);
    40a0:	4505                	li	a0,1
    40a2:	00001097          	auipc	ra,0x1
    40a6:	7a6080e7          	jalr	1958(ra) # 5848 <exit>
      int pid2 = fork();
    40aa:	00001097          	auipc	ra,0x1
    40ae:	796080e7          	jalr	1942(ra) # 5840 <fork>
      if(pid2 < 0){
    40b2:	00054763          	bltz	a0,40c0 <reparent+0x9c>
      exit(0);
    40b6:	4501                	li	a0,0
    40b8:	00001097          	auipc	ra,0x1
    40bc:	790080e7          	jalr	1936(ra) # 5848 <exit>
        kill(master_pid);
    40c0:	8552                	mv	a0,s4
    40c2:	00001097          	auipc	ra,0x1
    40c6:	7b6080e7          	jalr	1974(ra) # 5878 <kill>
        exit(1);
    40ca:	4505                	li	a0,1
    40cc:	00001097          	auipc	ra,0x1
    40d0:	77c080e7          	jalr	1916(ra) # 5848 <exit>

00000000000040d4 <mem>:
{
    40d4:	7139                	addi	sp,sp,-64
    40d6:	fc06                	sd	ra,56(sp)
    40d8:	f822                	sd	s0,48(sp)
    40da:	f426                	sd	s1,40(sp)
    40dc:	f04a                	sd	s2,32(sp)
    40de:	ec4e                	sd	s3,24(sp)
    40e0:	0080                	addi	s0,sp,64
    40e2:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    40e4:	00001097          	auipc	ra,0x1
    40e8:	75c080e7          	jalr	1884(ra) # 5840 <fork>
    m1 = 0;
    40ec:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    40ee:	6909                	lui	s2,0x2
    40f0:	71190913          	addi	s2,s2,1809 # 2711 <sbrkarg+0x15>
  if((pid = fork()) == 0){
    40f4:	ed39                	bnez	a0,4152 <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    40f6:	854a                	mv	a0,s2
    40f8:	00002097          	auipc	ra,0x2
    40fc:	b9e080e7          	jalr	-1122(ra) # 5c96 <malloc>
    4100:	c501                	beqz	a0,4108 <mem+0x34>
      *(char**)m2 = m1;
    4102:	e104                	sd	s1,0(a0)
      m1 = m2;
    4104:	84aa                	mv	s1,a0
    4106:	bfc5                	j	40f6 <mem+0x22>
    while(m1){
    4108:	c881                	beqz	s1,4118 <mem+0x44>
      m2 = *(char**)m1;
    410a:	8526                	mv	a0,s1
    410c:	6084                	ld	s1,0(s1)
      free(m1);
    410e:	00002097          	auipc	ra,0x2
    4112:	b00080e7          	jalr	-1280(ra) # 5c0e <free>
    while(m1){
    4116:	f8f5                	bnez	s1,410a <mem+0x36>
    m1 = malloc(1024*20);
    4118:	6515                	lui	a0,0x5
    411a:	00002097          	auipc	ra,0x2
    411e:	b7c080e7          	jalr	-1156(ra) # 5c96 <malloc>
    if(m1 == 0){
    4122:	c911                	beqz	a0,4136 <mem+0x62>
    free(m1);
    4124:	00002097          	auipc	ra,0x2
    4128:	aea080e7          	jalr	-1302(ra) # 5c0e <free>
    exit(0);
    412c:	4501                	li	a0,0
    412e:	00001097          	auipc	ra,0x1
    4132:	71a080e7          	jalr	1818(ra) # 5848 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4136:	85ce                	mv	a1,s3
    4138:	00004517          	auipc	a0,0x4
    413c:	a6050513          	addi	a0,a0,-1440 # 7b98 <malloc+0x1f02>
    4140:	00002097          	auipc	ra,0x2
    4144:	a98080e7          	jalr	-1384(ra) # 5bd8 <printf>
      exit(1);
    4148:	4505                	li	a0,1
    414a:	00001097          	auipc	ra,0x1
    414e:	6fe080e7          	jalr	1790(ra) # 5848 <exit>
    wait(&xstatus);
    4152:	fcc40513          	addi	a0,s0,-52
    4156:	00001097          	auipc	ra,0x1
    415a:	6fa080e7          	jalr	1786(ra) # 5850 <wait>
    if(xstatus == -1){
    415e:	fcc42503          	lw	a0,-52(s0)
    4162:	57fd                	li	a5,-1
    4164:	00f50663          	beq	a0,a5,4170 <mem+0x9c>
    exit(xstatus);
    4168:	00001097          	auipc	ra,0x1
    416c:	6e0080e7          	jalr	1760(ra) # 5848 <exit>
      exit(0);
    4170:	4501                	li	a0,0
    4172:	00001097          	auipc	ra,0x1
    4176:	6d6080e7          	jalr	1750(ra) # 5848 <exit>

000000000000417a <sharedfd>:
{
    417a:	7159                	addi	sp,sp,-112
    417c:	f486                	sd	ra,104(sp)
    417e:	f0a2                	sd	s0,96(sp)
    4180:	eca6                	sd	s1,88(sp)
    4182:	e8ca                	sd	s2,80(sp)
    4184:	e4ce                	sd	s3,72(sp)
    4186:	e0d2                	sd	s4,64(sp)
    4188:	fc56                	sd	s5,56(sp)
    418a:	f85a                	sd	s6,48(sp)
    418c:	f45e                	sd	s7,40(sp)
    418e:	1880                	addi	s0,sp,112
    4190:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4192:	00002517          	auipc	a0,0x2
    4196:	d8650513          	addi	a0,a0,-634 # 5f18 <malloc+0x282>
    419a:	00001097          	auipc	ra,0x1
    419e:	6fe080e7          	jalr	1790(ra) # 5898 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    41a2:	20200593          	li	a1,514
    41a6:	00002517          	auipc	a0,0x2
    41aa:	d7250513          	addi	a0,a0,-654 # 5f18 <malloc+0x282>
    41ae:	00001097          	auipc	ra,0x1
    41b2:	6da080e7          	jalr	1754(ra) # 5888 <open>
  if(fd < 0){
    41b6:	04054a63          	bltz	a0,420a <sharedfd+0x90>
    41ba:	892a                	mv	s2,a0
  pid = fork();
    41bc:	00001097          	auipc	ra,0x1
    41c0:	684080e7          	jalr	1668(ra) # 5840 <fork>
    41c4:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    41c6:	06300593          	li	a1,99
    41ca:	c119                	beqz	a0,41d0 <sharedfd+0x56>
    41cc:	07000593          	li	a1,112
    41d0:	4629                	li	a2,10
    41d2:	fa040513          	addi	a0,s0,-96
    41d6:	00001097          	auipc	ra,0x1
    41da:	46e080e7          	jalr	1134(ra) # 5644 <memset>
    41de:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    41e2:	4629                	li	a2,10
    41e4:	fa040593          	addi	a1,s0,-96
    41e8:	854a                	mv	a0,s2
    41ea:	00001097          	auipc	ra,0x1
    41ee:	67e080e7          	jalr	1662(ra) # 5868 <write>
    41f2:	47a9                	li	a5,10
    41f4:	02f51963          	bne	a0,a5,4226 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    41f8:	34fd                	addiw	s1,s1,-1
    41fa:	f4e5                	bnez	s1,41e2 <sharedfd+0x68>
  if(pid == 0) {
    41fc:	04099363          	bnez	s3,4242 <sharedfd+0xc8>
    exit(0);
    4200:	4501                	li	a0,0
    4202:	00001097          	auipc	ra,0x1
    4206:	646080e7          	jalr	1606(ra) # 5848 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    420a:	85d2                	mv	a1,s4
    420c:	00004517          	auipc	a0,0x4
    4210:	9ac50513          	addi	a0,a0,-1620 # 7bb8 <malloc+0x1f22>
    4214:	00002097          	auipc	ra,0x2
    4218:	9c4080e7          	jalr	-1596(ra) # 5bd8 <printf>
    exit(1);
    421c:	4505                	li	a0,1
    421e:	00001097          	auipc	ra,0x1
    4222:	62a080e7          	jalr	1578(ra) # 5848 <exit>
      printf("%s: write sharedfd failed\n", s);
    4226:	85d2                	mv	a1,s4
    4228:	00004517          	auipc	a0,0x4
    422c:	9b850513          	addi	a0,a0,-1608 # 7be0 <malloc+0x1f4a>
    4230:	00002097          	auipc	ra,0x2
    4234:	9a8080e7          	jalr	-1624(ra) # 5bd8 <printf>
      exit(1);
    4238:	4505                	li	a0,1
    423a:	00001097          	auipc	ra,0x1
    423e:	60e080e7          	jalr	1550(ra) # 5848 <exit>
    wait(&xstatus);
    4242:	f9c40513          	addi	a0,s0,-100
    4246:	00001097          	auipc	ra,0x1
    424a:	60a080e7          	jalr	1546(ra) # 5850 <wait>
    if(xstatus != 0)
    424e:	f9c42983          	lw	s3,-100(s0)
    4252:	00098763          	beqz	s3,4260 <sharedfd+0xe6>
      exit(xstatus);
    4256:	854e                	mv	a0,s3
    4258:	00001097          	auipc	ra,0x1
    425c:	5f0080e7          	jalr	1520(ra) # 5848 <exit>
  close(fd);
    4260:	854a                	mv	a0,s2
    4262:	00001097          	auipc	ra,0x1
    4266:	60e080e7          	jalr	1550(ra) # 5870 <close>
  fd = open("sharedfd", 0);
    426a:	4581                	li	a1,0
    426c:	00002517          	auipc	a0,0x2
    4270:	cac50513          	addi	a0,a0,-852 # 5f18 <malloc+0x282>
    4274:	00001097          	auipc	ra,0x1
    4278:	614080e7          	jalr	1556(ra) # 5888 <open>
    427c:	8baa                	mv	s7,a0
  nc = np = 0;
    427e:	8ace                	mv	s5,s3
  if(fd < 0){
    4280:	02054563          	bltz	a0,42aa <sharedfd+0x130>
    4284:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4288:	06300493          	li	s1,99
      if(buf[i] == 'p')
    428c:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4290:	4629                	li	a2,10
    4292:	fa040593          	addi	a1,s0,-96
    4296:	855e                	mv	a0,s7
    4298:	00001097          	auipc	ra,0x1
    429c:	5c8080e7          	jalr	1480(ra) # 5860 <read>
    42a0:	02a05f63          	blez	a0,42de <sharedfd+0x164>
    42a4:	fa040793          	addi	a5,s0,-96
    42a8:	a01d                	j	42ce <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    42aa:	85d2                	mv	a1,s4
    42ac:	00004517          	auipc	a0,0x4
    42b0:	95450513          	addi	a0,a0,-1708 # 7c00 <malloc+0x1f6a>
    42b4:	00002097          	auipc	ra,0x2
    42b8:	924080e7          	jalr	-1756(ra) # 5bd8 <printf>
    exit(1);
    42bc:	4505                	li	a0,1
    42be:	00001097          	auipc	ra,0x1
    42c2:	58a080e7          	jalr	1418(ra) # 5848 <exit>
        nc++;
    42c6:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    42c8:	0785                	addi	a5,a5,1
    42ca:	fd2783e3          	beq	a5,s2,4290 <sharedfd+0x116>
      if(buf[i] == 'c')
    42ce:	0007c703          	lbu	a4,0(a5)
    42d2:	fe970ae3          	beq	a4,s1,42c6 <sharedfd+0x14c>
      if(buf[i] == 'p')
    42d6:	ff6719e3          	bne	a4,s6,42c8 <sharedfd+0x14e>
        np++;
    42da:	2a85                	addiw	s5,s5,1
    42dc:	b7f5                	j	42c8 <sharedfd+0x14e>
  close(fd);
    42de:	855e                	mv	a0,s7
    42e0:	00001097          	auipc	ra,0x1
    42e4:	590080e7          	jalr	1424(ra) # 5870 <close>
  unlink("sharedfd");
    42e8:	00002517          	auipc	a0,0x2
    42ec:	c3050513          	addi	a0,a0,-976 # 5f18 <malloc+0x282>
    42f0:	00001097          	auipc	ra,0x1
    42f4:	5a8080e7          	jalr	1448(ra) # 5898 <unlink>
  if(nc == N*SZ && np == N*SZ){
    42f8:	6789                	lui	a5,0x2
    42fa:	71078793          	addi	a5,a5,1808 # 2710 <sbrkarg+0x14>
    42fe:	00f99763          	bne	s3,a5,430c <sharedfd+0x192>
    4302:	6789                	lui	a5,0x2
    4304:	71078793          	addi	a5,a5,1808 # 2710 <sbrkarg+0x14>
    4308:	02fa8063          	beq	s5,a5,4328 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    430c:	85d2                	mv	a1,s4
    430e:	00004517          	auipc	a0,0x4
    4312:	91a50513          	addi	a0,a0,-1766 # 7c28 <malloc+0x1f92>
    4316:	00002097          	auipc	ra,0x2
    431a:	8c2080e7          	jalr	-1854(ra) # 5bd8 <printf>
    exit(1);
    431e:	4505                	li	a0,1
    4320:	00001097          	auipc	ra,0x1
    4324:	528080e7          	jalr	1320(ra) # 5848 <exit>
    exit(0);
    4328:	4501                	li	a0,0
    432a:	00001097          	auipc	ra,0x1
    432e:	51e080e7          	jalr	1310(ra) # 5848 <exit>

0000000000004332 <fourfiles>:
{
    4332:	7171                	addi	sp,sp,-176
    4334:	f506                	sd	ra,168(sp)
    4336:	f122                	sd	s0,160(sp)
    4338:	ed26                	sd	s1,152(sp)
    433a:	e94a                	sd	s2,144(sp)
    433c:	e54e                	sd	s3,136(sp)
    433e:	e152                	sd	s4,128(sp)
    4340:	fcd6                	sd	s5,120(sp)
    4342:	f8da                	sd	s6,112(sp)
    4344:	f4de                	sd	s7,104(sp)
    4346:	f0e2                	sd	s8,96(sp)
    4348:	ece6                	sd	s9,88(sp)
    434a:	e8ea                	sd	s10,80(sp)
    434c:	e4ee                	sd	s11,72(sp)
    434e:	1900                	addi	s0,sp,176
    4350:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4352:	00002797          	auipc	a5,0x2
    4356:	a2e78793          	addi	a5,a5,-1490 # 5d80 <malloc+0xea>
    435a:	f6f43823          	sd	a5,-144(s0)
    435e:	00002797          	auipc	a5,0x2
    4362:	a2a78793          	addi	a5,a5,-1494 # 5d88 <malloc+0xf2>
    4366:	f6f43c23          	sd	a5,-136(s0)
    436a:	00002797          	auipc	a5,0x2
    436e:	a2678793          	addi	a5,a5,-1498 # 5d90 <malloc+0xfa>
    4372:	f8f43023          	sd	a5,-128(s0)
    4376:	00002797          	auipc	a5,0x2
    437a:	a2278793          	addi	a5,a5,-1502 # 5d98 <malloc+0x102>
    437e:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4382:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4386:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4388:	4481                	li	s1,0
    438a:	4a11                	li	s4,4
    fname = names[pi];
    438c:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4390:	854e                	mv	a0,s3
    4392:	00001097          	auipc	ra,0x1
    4396:	506080e7          	jalr	1286(ra) # 5898 <unlink>
    pid = fork();
    439a:	00001097          	auipc	ra,0x1
    439e:	4a6080e7          	jalr	1190(ra) # 5840 <fork>
    if(pid < 0){
    43a2:	04054563          	bltz	a0,43ec <fourfiles+0xba>
    if(pid == 0){
    43a6:	c12d                	beqz	a0,4408 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    43a8:	2485                	addiw	s1,s1,1
    43aa:	0921                	addi	s2,s2,8
    43ac:	ff4490e3          	bne	s1,s4,438c <fourfiles+0x5a>
    43b0:	4491                	li	s1,4
    wait(&xstatus);
    43b2:	f6c40513          	addi	a0,s0,-148
    43b6:	00001097          	auipc	ra,0x1
    43ba:	49a080e7          	jalr	1178(ra) # 5850 <wait>
    if(xstatus != 0)
    43be:	f6c42503          	lw	a0,-148(s0)
    43c2:	ed69                	bnez	a0,449c <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    43c4:	34fd                	addiw	s1,s1,-1
    43c6:	f4f5                	bnez	s1,43b2 <fourfiles+0x80>
    43c8:	03000b13          	li	s6,48
    total = 0;
    43cc:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    43d0:	00008a17          	auipc	s4,0x8
    43d4:	978a0a13          	addi	s4,s4,-1672 # bd48 <buf>
    43d8:	00008a97          	auipc	s5,0x8
    43dc:	971a8a93          	addi	s5,s5,-1679 # bd49 <buf+0x1>
    if(total != N*SZ){
    43e0:	6d05                	lui	s10,0x1
    43e2:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x196>
  for(i = 0; i < NCHILD; i++){
    43e6:	03400d93          	li	s11,52
    43ea:	a23d                	j	4518 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    43ec:	85e6                	mv	a1,s9
    43ee:	00003517          	auipc	a0,0x3
    43f2:	8da50513          	addi	a0,a0,-1830 # 6cc8 <malloc+0x1032>
    43f6:	00001097          	auipc	ra,0x1
    43fa:	7e2080e7          	jalr	2018(ra) # 5bd8 <printf>
      exit(1);
    43fe:	4505                	li	a0,1
    4400:	00001097          	auipc	ra,0x1
    4404:	448080e7          	jalr	1096(ra) # 5848 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4408:	20200593          	li	a1,514
    440c:	854e                	mv	a0,s3
    440e:	00001097          	auipc	ra,0x1
    4412:	47a080e7          	jalr	1146(ra) # 5888 <open>
    4416:	892a                	mv	s2,a0
      if(fd < 0){
    4418:	04054763          	bltz	a0,4466 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    441c:	1f400613          	li	a2,500
    4420:	0304859b          	addiw	a1,s1,48
    4424:	00008517          	auipc	a0,0x8
    4428:	92450513          	addi	a0,a0,-1756 # bd48 <buf>
    442c:	00001097          	auipc	ra,0x1
    4430:	218080e7          	jalr	536(ra) # 5644 <memset>
    4434:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4436:	00008997          	auipc	s3,0x8
    443a:	91298993          	addi	s3,s3,-1774 # bd48 <buf>
    443e:	1f400613          	li	a2,500
    4442:	85ce                	mv	a1,s3
    4444:	854a                	mv	a0,s2
    4446:	00001097          	auipc	ra,0x1
    444a:	422080e7          	jalr	1058(ra) # 5868 <write>
    444e:	85aa                	mv	a1,a0
    4450:	1f400793          	li	a5,500
    4454:	02f51763          	bne	a0,a5,4482 <fourfiles+0x150>
      for(i = 0; i < N; i++){
    4458:	34fd                	addiw	s1,s1,-1
    445a:	f0f5                	bnez	s1,443e <fourfiles+0x10c>
      exit(0);
    445c:	4501                	li	a0,0
    445e:	00001097          	auipc	ra,0x1
    4462:	3ea080e7          	jalr	1002(ra) # 5848 <exit>
        printf("create failed\n", s);
    4466:	85e6                	mv	a1,s9
    4468:	00003517          	auipc	a0,0x3
    446c:	7d850513          	addi	a0,a0,2008 # 7c40 <malloc+0x1faa>
    4470:	00001097          	auipc	ra,0x1
    4474:	768080e7          	jalr	1896(ra) # 5bd8 <printf>
        exit(1);
    4478:	4505                	li	a0,1
    447a:	00001097          	auipc	ra,0x1
    447e:	3ce080e7          	jalr	974(ra) # 5848 <exit>
          printf("write failed %d\n", n);
    4482:	00003517          	auipc	a0,0x3
    4486:	7ce50513          	addi	a0,a0,1998 # 7c50 <malloc+0x1fba>
    448a:	00001097          	auipc	ra,0x1
    448e:	74e080e7          	jalr	1870(ra) # 5bd8 <printf>
          exit(1);
    4492:	4505                	li	a0,1
    4494:	00001097          	auipc	ra,0x1
    4498:	3b4080e7          	jalr	948(ra) # 5848 <exit>
      exit(xstatus);
    449c:	00001097          	auipc	ra,0x1
    44a0:	3ac080e7          	jalr	940(ra) # 5848 <exit>
          printf("wrong char\n", s);
    44a4:	85e6                	mv	a1,s9
    44a6:	00003517          	auipc	a0,0x3
    44aa:	7c250513          	addi	a0,a0,1986 # 7c68 <malloc+0x1fd2>
    44ae:	00001097          	auipc	ra,0x1
    44b2:	72a080e7          	jalr	1834(ra) # 5bd8 <printf>
          exit(1);
    44b6:	4505                	li	a0,1
    44b8:	00001097          	auipc	ra,0x1
    44bc:	390080e7          	jalr	912(ra) # 5848 <exit>
      total += n;
    44c0:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    44c4:	660d                	lui	a2,0x3
    44c6:	85d2                	mv	a1,s4
    44c8:	854e                	mv	a0,s3
    44ca:	00001097          	auipc	ra,0x1
    44ce:	396080e7          	jalr	918(ra) # 5860 <read>
    44d2:	02a05363          	blez	a0,44f8 <fourfiles+0x1c6>
    44d6:	00008797          	auipc	a5,0x8
    44da:	87278793          	addi	a5,a5,-1934 # bd48 <buf>
    44de:	fff5069b          	addiw	a3,a0,-1
    44e2:	1682                	slli	a3,a3,0x20
    44e4:	9281                	srli	a3,a3,0x20
    44e6:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    44e8:	0007c703          	lbu	a4,0(a5)
    44ec:	fa971ce3          	bne	a4,s1,44a4 <fourfiles+0x172>
      for(j = 0; j < n; j++){
    44f0:	0785                	addi	a5,a5,1
    44f2:	fed79be3          	bne	a5,a3,44e8 <fourfiles+0x1b6>
    44f6:	b7e9                	j	44c0 <fourfiles+0x18e>
    close(fd);
    44f8:	854e                	mv	a0,s3
    44fa:	00001097          	auipc	ra,0x1
    44fe:	376080e7          	jalr	886(ra) # 5870 <close>
    if(total != N*SZ){
    4502:	03a91963          	bne	s2,s10,4534 <fourfiles+0x202>
    unlink(fname);
    4506:	8562                	mv	a0,s8
    4508:	00001097          	auipc	ra,0x1
    450c:	390080e7          	jalr	912(ra) # 5898 <unlink>
  for(i = 0; i < NCHILD; i++){
    4510:	0ba1                	addi	s7,s7,8
    4512:	2b05                	addiw	s6,s6,1
    4514:	03bb0e63          	beq	s6,s11,4550 <fourfiles+0x21e>
    fname = names[i];
    4518:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    451c:	4581                	li	a1,0
    451e:	8562                	mv	a0,s8
    4520:	00001097          	auipc	ra,0x1
    4524:	368080e7          	jalr	872(ra) # 5888 <open>
    4528:	89aa                	mv	s3,a0
    total = 0;
    452a:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    452e:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4532:	bf49                	j	44c4 <fourfiles+0x192>
      printf("wrong length %d\n", total);
    4534:	85ca                	mv	a1,s2
    4536:	00003517          	auipc	a0,0x3
    453a:	74250513          	addi	a0,a0,1858 # 7c78 <malloc+0x1fe2>
    453e:	00001097          	auipc	ra,0x1
    4542:	69a080e7          	jalr	1690(ra) # 5bd8 <printf>
      exit(1);
    4546:	4505                	li	a0,1
    4548:	00001097          	auipc	ra,0x1
    454c:	300080e7          	jalr	768(ra) # 5848 <exit>
}
    4550:	70aa                	ld	ra,168(sp)
    4552:	740a                	ld	s0,160(sp)
    4554:	64ea                	ld	s1,152(sp)
    4556:	694a                	ld	s2,144(sp)
    4558:	69aa                	ld	s3,136(sp)
    455a:	6a0a                	ld	s4,128(sp)
    455c:	7ae6                	ld	s5,120(sp)
    455e:	7b46                	ld	s6,112(sp)
    4560:	7ba6                	ld	s7,104(sp)
    4562:	7c06                	ld	s8,96(sp)
    4564:	6ce6                	ld	s9,88(sp)
    4566:	6d46                	ld	s10,80(sp)
    4568:	6da6                	ld	s11,72(sp)
    456a:	614d                	addi	sp,sp,176
    456c:	8082                	ret

000000000000456e <concreate>:
{
    456e:	7135                	addi	sp,sp,-160
    4570:	ed06                	sd	ra,152(sp)
    4572:	e922                	sd	s0,144(sp)
    4574:	e526                	sd	s1,136(sp)
    4576:	e14a                	sd	s2,128(sp)
    4578:	fcce                	sd	s3,120(sp)
    457a:	f8d2                	sd	s4,112(sp)
    457c:	f4d6                	sd	s5,104(sp)
    457e:	f0da                	sd	s6,96(sp)
    4580:	ecde                	sd	s7,88(sp)
    4582:	1100                	addi	s0,sp,160
    4584:	89aa                	mv	s3,a0
  file[0] = 'C';
    4586:	04300793          	li	a5,67
    458a:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    458e:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4592:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4594:	4b0d                	li	s6,3
    4596:	4a85                	li	s5,1
      link("C0", file);
    4598:	00003b97          	auipc	s7,0x3
    459c:	6f8b8b93          	addi	s7,s7,1784 # 7c90 <malloc+0x1ffa>
  for(i = 0; i < N; i++){
    45a0:	02800a13          	li	s4,40
    45a4:	acc1                	j	4874 <concreate+0x306>
      link("C0", file);
    45a6:	fa840593          	addi	a1,s0,-88
    45aa:	855e                	mv	a0,s7
    45ac:	00001097          	auipc	ra,0x1
    45b0:	2fc080e7          	jalr	764(ra) # 58a8 <link>
    if(pid == 0) {
    45b4:	a45d                	j	485a <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    45b6:	4795                	li	a5,5
    45b8:	02f9693b          	remw	s2,s2,a5
    45bc:	4785                	li	a5,1
    45be:	02f90b63          	beq	s2,a5,45f4 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    45c2:	20200593          	li	a1,514
    45c6:	fa840513          	addi	a0,s0,-88
    45ca:	00001097          	auipc	ra,0x1
    45ce:	2be080e7          	jalr	702(ra) # 5888 <open>
      if(fd < 0){
    45d2:	26055b63          	bgez	a0,4848 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    45d6:	fa840593          	addi	a1,s0,-88
    45da:	00003517          	auipc	a0,0x3
    45de:	6be50513          	addi	a0,a0,1726 # 7c98 <malloc+0x2002>
    45e2:	00001097          	auipc	ra,0x1
    45e6:	5f6080e7          	jalr	1526(ra) # 5bd8 <printf>
        exit(1);
    45ea:	4505                	li	a0,1
    45ec:	00001097          	auipc	ra,0x1
    45f0:	25c080e7          	jalr	604(ra) # 5848 <exit>
      link("C0", file);
    45f4:	fa840593          	addi	a1,s0,-88
    45f8:	00003517          	auipc	a0,0x3
    45fc:	69850513          	addi	a0,a0,1688 # 7c90 <malloc+0x1ffa>
    4600:	00001097          	auipc	ra,0x1
    4604:	2a8080e7          	jalr	680(ra) # 58a8 <link>
      exit(0);
    4608:	4501                	li	a0,0
    460a:	00001097          	auipc	ra,0x1
    460e:	23e080e7          	jalr	574(ra) # 5848 <exit>
        exit(1);
    4612:	4505                	li	a0,1
    4614:	00001097          	auipc	ra,0x1
    4618:	234080e7          	jalr	564(ra) # 5848 <exit>
  memset(fa, 0, sizeof(fa));
    461c:	02800613          	li	a2,40
    4620:	4581                	li	a1,0
    4622:	f8040513          	addi	a0,s0,-128
    4626:	00001097          	auipc	ra,0x1
    462a:	01e080e7          	jalr	30(ra) # 5644 <memset>
  fd = open(".", 0);
    462e:	4581                	li	a1,0
    4630:	00002517          	auipc	a0,0x2
    4634:	15850513          	addi	a0,a0,344 # 6788 <malloc+0xaf2>
    4638:	00001097          	auipc	ra,0x1
    463c:	250080e7          	jalr	592(ra) # 5888 <open>
    4640:	892a                	mv	s2,a0
  n = 0;
    4642:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4644:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4648:	02700b13          	li	s6,39
      fa[i] = 1;
    464c:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    464e:	a03d                	j	467c <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    4650:	f7240613          	addi	a2,s0,-142
    4654:	85ce                	mv	a1,s3
    4656:	00003517          	auipc	a0,0x3
    465a:	66250513          	addi	a0,a0,1634 # 7cb8 <malloc+0x2022>
    465e:	00001097          	auipc	ra,0x1
    4662:	57a080e7          	jalr	1402(ra) # 5bd8 <printf>
        exit(1);
    4666:	4505                	li	a0,1
    4668:	00001097          	auipc	ra,0x1
    466c:	1e0080e7          	jalr	480(ra) # 5848 <exit>
      fa[i] = 1;
    4670:	fb040793          	addi	a5,s0,-80
    4674:	973e                	add	a4,a4,a5
    4676:	fd770823          	sb	s7,-48(a4)
      n++;
    467a:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    467c:	4641                	li	a2,16
    467e:	f7040593          	addi	a1,s0,-144
    4682:	854a                	mv	a0,s2
    4684:	00001097          	auipc	ra,0x1
    4688:	1dc080e7          	jalr	476(ra) # 5860 <read>
    468c:	04a05a63          	blez	a0,46e0 <concreate+0x172>
    if(de.inum == 0)
    4690:	f7045783          	lhu	a5,-144(s0)
    4694:	d7e5                	beqz	a5,467c <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4696:	f7244783          	lbu	a5,-142(s0)
    469a:	ff4791e3          	bne	a5,s4,467c <concreate+0x10e>
    469e:	f7444783          	lbu	a5,-140(s0)
    46a2:	ffe9                	bnez	a5,467c <concreate+0x10e>
      i = de.name[1] - '0';
    46a4:	f7344783          	lbu	a5,-141(s0)
    46a8:	fd07879b          	addiw	a5,a5,-48
    46ac:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    46b0:	faeb60e3          	bltu	s6,a4,4650 <concreate+0xe2>
      if(fa[i]){
    46b4:	fb040793          	addi	a5,s0,-80
    46b8:	97ba                	add	a5,a5,a4
    46ba:	fd07c783          	lbu	a5,-48(a5)
    46be:	dbcd                	beqz	a5,4670 <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    46c0:	f7240613          	addi	a2,s0,-142
    46c4:	85ce                	mv	a1,s3
    46c6:	00003517          	auipc	a0,0x3
    46ca:	61250513          	addi	a0,a0,1554 # 7cd8 <malloc+0x2042>
    46ce:	00001097          	auipc	ra,0x1
    46d2:	50a080e7          	jalr	1290(ra) # 5bd8 <printf>
        exit(1);
    46d6:	4505                	li	a0,1
    46d8:	00001097          	auipc	ra,0x1
    46dc:	170080e7          	jalr	368(ra) # 5848 <exit>
  close(fd);
    46e0:	854a                	mv	a0,s2
    46e2:	00001097          	auipc	ra,0x1
    46e6:	18e080e7          	jalr	398(ra) # 5870 <close>
  if(n != N){
    46ea:	02800793          	li	a5,40
    46ee:	00fa9763          	bne	s5,a5,46fc <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    46f2:	4a8d                	li	s5,3
    46f4:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    46f6:	02800a13          	li	s4,40
    46fa:	a8c9                	j	47cc <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    46fc:	85ce                	mv	a1,s3
    46fe:	00003517          	auipc	a0,0x3
    4702:	60250513          	addi	a0,a0,1538 # 7d00 <malloc+0x206a>
    4706:	00001097          	auipc	ra,0x1
    470a:	4d2080e7          	jalr	1234(ra) # 5bd8 <printf>
    exit(1);
    470e:	4505                	li	a0,1
    4710:	00001097          	auipc	ra,0x1
    4714:	138080e7          	jalr	312(ra) # 5848 <exit>
      printf("%s: fork failed\n", s);
    4718:	85ce                	mv	a1,s3
    471a:	00002517          	auipc	a0,0x2
    471e:	1a650513          	addi	a0,a0,422 # 68c0 <malloc+0xc2a>
    4722:	00001097          	auipc	ra,0x1
    4726:	4b6080e7          	jalr	1206(ra) # 5bd8 <printf>
      exit(1);
    472a:	4505                	li	a0,1
    472c:	00001097          	auipc	ra,0x1
    4730:	11c080e7          	jalr	284(ra) # 5848 <exit>
      close(open(file, 0));
    4734:	4581                	li	a1,0
    4736:	fa840513          	addi	a0,s0,-88
    473a:	00001097          	auipc	ra,0x1
    473e:	14e080e7          	jalr	334(ra) # 5888 <open>
    4742:	00001097          	auipc	ra,0x1
    4746:	12e080e7          	jalr	302(ra) # 5870 <close>
      close(open(file, 0));
    474a:	4581                	li	a1,0
    474c:	fa840513          	addi	a0,s0,-88
    4750:	00001097          	auipc	ra,0x1
    4754:	138080e7          	jalr	312(ra) # 5888 <open>
    4758:	00001097          	auipc	ra,0x1
    475c:	118080e7          	jalr	280(ra) # 5870 <close>
      close(open(file, 0));
    4760:	4581                	li	a1,0
    4762:	fa840513          	addi	a0,s0,-88
    4766:	00001097          	auipc	ra,0x1
    476a:	122080e7          	jalr	290(ra) # 5888 <open>
    476e:	00001097          	auipc	ra,0x1
    4772:	102080e7          	jalr	258(ra) # 5870 <close>
      close(open(file, 0));
    4776:	4581                	li	a1,0
    4778:	fa840513          	addi	a0,s0,-88
    477c:	00001097          	auipc	ra,0x1
    4780:	10c080e7          	jalr	268(ra) # 5888 <open>
    4784:	00001097          	auipc	ra,0x1
    4788:	0ec080e7          	jalr	236(ra) # 5870 <close>
      close(open(file, 0));
    478c:	4581                	li	a1,0
    478e:	fa840513          	addi	a0,s0,-88
    4792:	00001097          	auipc	ra,0x1
    4796:	0f6080e7          	jalr	246(ra) # 5888 <open>
    479a:	00001097          	auipc	ra,0x1
    479e:	0d6080e7          	jalr	214(ra) # 5870 <close>
      close(open(file, 0));
    47a2:	4581                	li	a1,0
    47a4:	fa840513          	addi	a0,s0,-88
    47a8:	00001097          	auipc	ra,0x1
    47ac:	0e0080e7          	jalr	224(ra) # 5888 <open>
    47b0:	00001097          	auipc	ra,0x1
    47b4:	0c0080e7          	jalr	192(ra) # 5870 <close>
    if(pid == 0)
    47b8:	08090363          	beqz	s2,483e <concreate+0x2d0>
      wait(0);
    47bc:	4501                	li	a0,0
    47be:	00001097          	auipc	ra,0x1
    47c2:	092080e7          	jalr	146(ra) # 5850 <wait>
  for(i = 0; i < N; i++){
    47c6:	2485                	addiw	s1,s1,1
    47c8:	0f448563          	beq	s1,s4,48b2 <concreate+0x344>
    file[1] = '0' + i;
    47cc:	0304879b          	addiw	a5,s1,48
    47d0:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    47d4:	00001097          	auipc	ra,0x1
    47d8:	06c080e7          	jalr	108(ra) # 5840 <fork>
    47dc:	892a                	mv	s2,a0
    if(pid < 0){
    47de:	f2054de3          	bltz	a0,4718 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    47e2:	0354e73b          	remw	a4,s1,s5
    47e6:	00a767b3          	or	a5,a4,a0
    47ea:	2781                	sext.w	a5,a5
    47ec:	d7a1                	beqz	a5,4734 <concreate+0x1c6>
    47ee:	01671363          	bne	a4,s6,47f4 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    47f2:	f129                	bnez	a0,4734 <concreate+0x1c6>
      unlink(file);
    47f4:	fa840513          	addi	a0,s0,-88
    47f8:	00001097          	auipc	ra,0x1
    47fc:	0a0080e7          	jalr	160(ra) # 5898 <unlink>
      unlink(file);
    4800:	fa840513          	addi	a0,s0,-88
    4804:	00001097          	auipc	ra,0x1
    4808:	094080e7          	jalr	148(ra) # 5898 <unlink>
      unlink(file);
    480c:	fa840513          	addi	a0,s0,-88
    4810:	00001097          	auipc	ra,0x1
    4814:	088080e7          	jalr	136(ra) # 5898 <unlink>
      unlink(file);
    4818:	fa840513          	addi	a0,s0,-88
    481c:	00001097          	auipc	ra,0x1
    4820:	07c080e7          	jalr	124(ra) # 5898 <unlink>
      unlink(file);
    4824:	fa840513          	addi	a0,s0,-88
    4828:	00001097          	auipc	ra,0x1
    482c:	070080e7          	jalr	112(ra) # 5898 <unlink>
      unlink(file);
    4830:	fa840513          	addi	a0,s0,-88
    4834:	00001097          	auipc	ra,0x1
    4838:	064080e7          	jalr	100(ra) # 5898 <unlink>
    483c:	bfb5                	j	47b8 <concreate+0x24a>
      exit(0);
    483e:	4501                	li	a0,0
    4840:	00001097          	auipc	ra,0x1
    4844:	008080e7          	jalr	8(ra) # 5848 <exit>
      close(fd);
    4848:	00001097          	auipc	ra,0x1
    484c:	028080e7          	jalr	40(ra) # 5870 <close>
    if(pid == 0) {
    4850:	bb65                	j	4608 <concreate+0x9a>
      close(fd);
    4852:	00001097          	auipc	ra,0x1
    4856:	01e080e7          	jalr	30(ra) # 5870 <close>
      wait(&xstatus);
    485a:	f6c40513          	addi	a0,s0,-148
    485e:	00001097          	auipc	ra,0x1
    4862:	ff2080e7          	jalr	-14(ra) # 5850 <wait>
      if(xstatus != 0)
    4866:	f6c42483          	lw	s1,-148(s0)
    486a:	da0494e3          	bnez	s1,4612 <concreate+0xa4>
  for(i = 0; i < N; i++){
    486e:	2905                	addiw	s2,s2,1
    4870:	db4906e3          	beq	s2,s4,461c <concreate+0xae>
    file[1] = '0' + i;
    4874:	0309079b          	addiw	a5,s2,48
    4878:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    487c:	fa840513          	addi	a0,s0,-88
    4880:	00001097          	auipc	ra,0x1
    4884:	018080e7          	jalr	24(ra) # 5898 <unlink>
    pid = fork();
    4888:	00001097          	auipc	ra,0x1
    488c:	fb8080e7          	jalr	-72(ra) # 5840 <fork>
    if(pid && (i % 3) == 1){
    4890:	d20503e3          	beqz	a0,45b6 <concreate+0x48>
    4894:	036967bb          	remw	a5,s2,s6
    4898:	d15787e3          	beq	a5,s5,45a6 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    489c:	20200593          	li	a1,514
    48a0:	fa840513          	addi	a0,s0,-88
    48a4:	00001097          	auipc	ra,0x1
    48a8:	fe4080e7          	jalr	-28(ra) # 5888 <open>
      if(fd < 0){
    48ac:	fa0553e3          	bgez	a0,4852 <concreate+0x2e4>
    48b0:	b31d                	j	45d6 <concreate+0x68>
}
    48b2:	60ea                	ld	ra,152(sp)
    48b4:	644a                	ld	s0,144(sp)
    48b6:	64aa                	ld	s1,136(sp)
    48b8:	690a                	ld	s2,128(sp)
    48ba:	79e6                	ld	s3,120(sp)
    48bc:	7a46                	ld	s4,112(sp)
    48be:	7aa6                	ld	s5,104(sp)
    48c0:	7b06                	ld	s6,96(sp)
    48c2:	6be6                	ld	s7,88(sp)
    48c4:	610d                	addi	sp,sp,160
    48c6:	8082                	ret

00000000000048c8 <bigfile>:
{
    48c8:	7139                	addi	sp,sp,-64
    48ca:	fc06                	sd	ra,56(sp)
    48cc:	f822                	sd	s0,48(sp)
    48ce:	f426                	sd	s1,40(sp)
    48d0:	f04a                	sd	s2,32(sp)
    48d2:	ec4e                	sd	s3,24(sp)
    48d4:	e852                	sd	s4,16(sp)
    48d6:	e456                	sd	s5,8(sp)
    48d8:	0080                	addi	s0,sp,64
    48da:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    48dc:	00003517          	auipc	a0,0x3
    48e0:	45c50513          	addi	a0,a0,1116 # 7d38 <malloc+0x20a2>
    48e4:	00001097          	auipc	ra,0x1
    48e8:	fb4080e7          	jalr	-76(ra) # 5898 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    48ec:	20200593          	li	a1,514
    48f0:	00003517          	auipc	a0,0x3
    48f4:	44850513          	addi	a0,a0,1096 # 7d38 <malloc+0x20a2>
    48f8:	00001097          	auipc	ra,0x1
    48fc:	f90080e7          	jalr	-112(ra) # 5888 <open>
    4900:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4902:	4481                	li	s1,0
    memset(buf, i, SZ);
    4904:	00007917          	auipc	s2,0x7
    4908:	44490913          	addi	s2,s2,1092 # bd48 <buf>
  for(i = 0; i < N; i++){
    490c:	4a51                	li	s4,20
  if(fd < 0){
    490e:	0a054063          	bltz	a0,49ae <bigfile+0xe6>
    memset(buf, i, SZ);
    4912:	25800613          	li	a2,600
    4916:	85a6                	mv	a1,s1
    4918:	854a                	mv	a0,s2
    491a:	00001097          	auipc	ra,0x1
    491e:	d2a080e7          	jalr	-726(ra) # 5644 <memset>
    if(write(fd, buf, SZ) != SZ){
    4922:	25800613          	li	a2,600
    4926:	85ca                	mv	a1,s2
    4928:	854e                	mv	a0,s3
    492a:	00001097          	auipc	ra,0x1
    492e:	f3e080e7          	jalr	-194(ra) # 5868 <write>
    4932:	25800793          	li	a5,600
    4936:	08f51a63          	bne	a0,a5,49ca <bigfile+0x102>
  for(i = 0; i < N; i++){
    493a:	2485                	addiw	s1,s1,1
    493c:	fd449be3          	bne	s1,s4,4912 <bigfile+0x4a>
  close(fd);
    4940:	854e                	mv	a0,s3
    4942:	00001097          	auipc	ra,0x1
    4946:	f2e080e7          	jalr	-210(ra) # 5870 <close>
  fd = open("bigfile.dat", 0);
    494a:	4581                	li	a1,0
    494c:	00003517          	auipc	a0,0x3
    4950:	3ec50513          	addi	a0,a0,1004 # 7d38 <malloc+0x20a2>
    4954:	00001097          	auipc	ra,0x1
    4958:	f34080e7          	jalr	-204(ra) # 5888 <open>
    495c:	8a2a                	mv	s4,a0
  total = 0;
    495e:	4981                	li	s3,0
  for(i = 0; ; i++){
    4960:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4962:	00007917          	auipc	s2,0x7
    4966:	3e690913          	addi	s2,s2,998 # bd48 <buf>
  if(fd < 0){
    496a:	06054e63          	bltz	a0,49e6 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    496e:	12c00613          	li	a2,300
    4972:	85ca                	mv	a1,s2
    4974:	8552                	mv	a0,s4
    4976:	00001097          	auipc	ra,0x1
    497a:	eea080e7          	jalr	-278(ra) # 5860 <read>
    if(cc < 0){
    497e:	08054263          	bltz	a0,4a02 <bigfile+0x13a>
    if(cc == 0)
    4982:	c971                	beqz	a0,4a56 <bigfile+0x18e>
    if(cc != SZ/2){
    4984:	12c00793          	li	a5,300
    4988:	08f51b63          	bne	a0,a5,4a1e <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    498c:	01f4d79b          	srliw	a5,s1,0x1f
    4990:	9fa5                	addw	a5,a5,s1
    4992:	4017d79b          	sraiw	a5,a5,0x1
    4996:	00094703          	lbu	a4,0(s2)
    499a:	0af71063          	bne	a4,a5,4a3a <bigfile+0x172>
    499e:	12b94703          	lbu	a4,299(s2)
    49a2:	08f71c63          	bne	a4,a5,4a3a <bigfile+0x172>
    total += cc;
    49a6:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    49aa:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    49ac:	b7c9                	j	496e <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    49ae:	85d6                	mv	a1,s5
    49b0:	00003517          	auipc	a0,0x3
    49b4:	39850513          	addi	a0,a0,920 # 7d48 <malloc+0x20b2>
    49b8:	00001097          	auipc	ra,0x1
    49bc:	220080e7          	jalr	544(ra) # 5bd8 <printf>
    exit(1);
    49c0:	4505                	li	a0,1
    49c2:	00001097          	auipc	ra,0x1
    49c6:	e86080e7          	jalr	-378(ra) # 5848 <exit>
      printf("%s: write bigfile failed\n", s);
    49ca:	85d6                	mv	a1,s5
    49cc:	00003517          	auipc	a0,0x3
    49d0:	39c50513          	addi	a0,a0,924 # 7d68 <malloc+0x20d2>
    49d4:	00001097          	auipc	ra,0x1
    49d8:	204080e7          	jalr	516(ra) # 5bd8 <printf>
      exit(1);
    49dc:	4505                	li	a0,1
    49de:	00001097          	auipc	ra,0x1
    49e2:	e6a080e7          	jalr	-406(ra) # 5848 <exit>
    printf("%s: cannot open bigfile\n", s);
    49e6:	85d6                	mv	a1,s5
    49e8:	00003517          	auipc	a0,0x3
    49ec:	3a050513          	addi	a0,a0,928 # 7d88 <malloc+0x20f2>
    49f0:	00001097          	auipc	ra,0x1
    49f4:	1e8080e7          	jalr	488(ra) # 5bd8 <printf>
    exit(1);
    49f8:	4505                	li	a0,1
    49fa:	00001097          	auipc	ra,0x1
    49fe:	e4e080e7          	jalr	-434(ra) # 5848 <exit>
      printf("%s: read bigfile failed\n", s);
    4a02:	85d6                	mv	a1,s5
    4a04:	00003517          	auipc	a0,0x3
    4a08:	3a450513          	addi	a0,a0,932 # 7da8 <malloc+0x2112>
    4a0c:	00001097          	auipc	ra,0x1
    4a10:	1cc080e7          	jalr	460(ra) # 5bd8 <printf>
      exit(1);
    4a14:	4505                	li	a0,1
    4a16:	00001097          	auipc	ra,0x1
    4a1a:	e32080e7          	jalr	-462(ra) # 5848 <exit>
      printf("%s: short read bigfile\n", s);
    4a1e:	85d6                	mv	a1,s5
    4a20:	00003517          	auipc	a0,0x3
    4a24:	3a850513          	addi	a0,a0,936 # 7dc8 <malloc+0x2132>
    4a28:	00001097          	auipc	ra,0x1
    4a2c:	1b0080e7          	jalr	432(ra) # 5bd8 <printf>
      exit(1);
    4a30:	4505                	li	a0,1
    4a32:	00001097          	auipc	ra,0x1
    4a36:	e16080e7          	jalr	-490(ra) # 5848 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4a3a:	85d6                	mv	a1,s5
    4a3c:	00003517          	auipc	a0,0x3
    4a40:	3a450513          	addi	a0,a0,932 # 7de0 <malloc+0x214a>
    4a44:	00001097          	auipc	ra,0x1
    4a48:	194080e7          	jalr	404(ra) # 5bd8 <printf>
      exit(1);
    4a4c:	4505                	li	a0,1
    4a4e:	00001097          	auipc	ra,0x1
    4a52:	dfa080e7          	jalr	-518(ra) # 5848 <exit>
  close(fd);
    4a56:	8552                	mv	a0,s4
    4a58:	00001097          	auipc	ra,0x1
    4a5c:	e18080e7          	jalr	-488(ra) # 5870 <close>
  if(total != N*SZ){
    4a60:	678d                	lui	a5,0x3
    4a62:	ee078793          	addi	a5,a5,-288 # 2ee0 <dirtest+0x54>
    4a66:	02f99363          	bne	s3,a5,4a8c <bigfile+0x1c4>
  unlink("bigfile.dat");
    4a6a:	00003517          	auipc	a0,0x3
    4a6e:	2ce50513          	addi	a0,a0,718 # 7d38 <malloc+0x20a2>
    4a72:	00001097          	auipc	ra,0x1
    4a76:	e26080e7          	jalr	-474(ra) # 5898 <unlink>
}
    4a7a:	70e2                	ld	ra,56(sp)
    4a7c:	7442                	ld	s0,48(sp)
    4a7e:	74a2                	ld	s1,40(sp)
    4a80:	7902                	ld	s2,32(sp)
    4a82:	69e2                	ld	s3,24(sp)
    4a84:	6a42                	ld	s4,16(sp)
    4a86:	6aa2                	ld	s5,8(sp)
    4a88:	6121                	addi	sp,sp,64
    4a8a:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4a8c:	85d6                	mv	a1,s5
    4a8e:	00003517          	auipc	a0,0x3
    4a92:	37250513          	addi	a0,a0,882 # 7e00 <malloc+0x216a>
    4a96:	00001097          	auipc	ra,0x1
    4a9a:	142080e7          	jalr	322(ra) # 5bd8 <printf>
    exit(1);
    4a9e:	4505                	li	a0,1
    4aa0:	00001097          	auipc	ra,0x1
    4aa4:	da8080e7          	jalr	-600(ra) # 5848 <exit>

0000000000004aa8 <bigdir>:
{
    4aa8:	715d                	addi	sp,sp,-80
    4aaa:	e486                	sd	ra,72(sp)
    4aac:	e0a2                	sd	s0,64(sp)
    4aae:	fc26                	sd	s1,56(sp)
    4ab0:	f84a                	sd	s2,48(sp)
    4ab2:	f44e                	sd	s3,40(sp)
    4ab4:	f052                	sd	s4,32(sp)
    4ab6:	ec56                	sd	s5,24(sp)
    4ab8:	e85a                	sd	s6,16(sp)
    4aba:	0880                	addi	s0,sp,80
    4abc:	89aa                	mv	s3,a0
  unlink("bd");
    4abe:	00003517          	auipc	a0,0x3
    4ac2:	36250513          	addi	a0,a0,866 # 7e20 <malloc+0x218a>
    4ac6:	00001097          	auipc	ra,0x1
    4aca:	dd2080e7          	jalr	-558(ra) # 5898 <unlink>
  fd = open("bd", O_CREATE);
    4ace:	20000593          	li	a1,512
    4ad2:	00003517          	auipc	a0,0x3
    4ad6:	34e50513          	addi	a0,a0,846 # 7e20 <malloc+0x218a>
    4ada:	00001097          	auipc	ra,0x1
    4ade:	dae080e7          	jalr	-594(ra) # 5888 <open>
  if(fd < 0){
    4ae2:	0c054963          	bltz	a0,4bb4 <bigdir+0x10c>
  close(fd);
    4ae6:	00001097          	auipc	ra,0x1
    4aea:	d8a080e7          	jalr	-630(ra) # 5870 <close>
  for(i = 0; i < N; i++){
    4aee:	4901                	li	s2,0
    name[0] = 'x';
    4af0:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    4af4:	00003a17          	auipc	s4,0x3
    4af8:	32ca0a13          	addi	s4,s4,812 # 7e20 <malloc+0x218a>
  for(i = 0; i < N; i++){
    4afc:	1f400b13          	li	s6,500
    name[0] = 'x';
    4b00:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    4b04:	41f9579b          	sraiw	a5,s2,0x1f
    4b08:	01a7d71b          	srliw	a4,a5,0x1a
    4b0c:	012707bb          	addw	a5,a4,s2
    4b10:	4067d69b          	sraiw	a3,a5,0x6
    4b14:	0306869b          	addiw	a3,a3,48
    4b18:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    4b1c:	03f7f793          	andi	a5,a5,63
    4b20:	9f99                	subw	a5,a5,a4
    4b22:	0307879b          	addiw	a5,a5,48
    4b26:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    4b2a:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    4b2e:	fb040593          	addi	a1,s0,-80
    4b32:	8552                	mv	a0,s4
    4b34:	00001097          	auipc	ra,0x1
    4b38:	d74080e7          	jalr	-652(ra) # 58a8 <link>
    4b3c:	84aa                	mv	s1,a0
    4b3e:	e949                	bnez	a0,4bd0 <bigdir+0x128>
  for(i = 0; i < N; i++){
    4b40:	2905                	addiw	s2,s2,1
    4b42:	fb691fe3          	bne	s2,s6,4b00 <bigdir+0x58>
  unlink("bd");
    4b46:	00003517          	auipc	a0,0x3
    4b4a:	2da50513          	addi	a0,a0,730 # 7e20 <malloc+0x218a>
    4b4e:	00001097          	auipc	ra,0x1
    4b52:	d4a080e7          	jalr	-694(ra) # 5898 <unlink>
    name[0] = 'x';
    4b56:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    4b5a:	1f400a13          	li	s4,500
    name[0] = 'x';
    4b5e:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    4b62:	41f4d79b          	sraiw	a5,s1,0x1f
    4b66:	01a7d71b          	srliw	a4,a5,0x1a
    4b6a:	009707bb          	addw	a5,a4,s1
    4b6e:	4067d69b          	sraiw	a3,a5,0x6
    4b72:	0306869b          	addiw	a3,a3,48
    4b76:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    4b7a:	03f7f793          	andi	a5,a5,63
    4b7e:	9f99                	subw	a5,a5,a4
    4b80:	0307879b          	addiw	a5,a5,48
    4b84:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    4b88:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    4b8c:	fb040513          	addi	a0,s0,-80
    4b90:	00001097          	auipc	ra,0x1
    4b94:	d08080e7          	jalr	-760(ra) # 5898 <unlink>
    4b98:	ed21                	bnez	a0,4bf0 <bigdir+0x148>
  for(i = 0; i < N; i++){
    4b9a:	2485                	addiw	s1,s1,1
    4b9c:	fd4491e3          	bne	s1,s4,4b5e <bigdir+0xb6>
}
    4ba0:	60a6                	ld	ra,72(sp)
    4ba2:	6406                	ld	s0,64(sp)
    4ba4:	74e2                	ld	s1,56(sp)
    4ba6:	7942                	ld	s2,48(sp)
    4ba8:	79a2                	ld	s3,40(sp)
    4baa:	7a02                	ld	s4,32(sp)
    4bac:	6ae2                	ld	s5,24(sp)
    4bae:	6b42                	ld	s6,16(sp)
    4bb0:	6161                	addi	sp,sp,80
    4bb2:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    4bb4:	85ce                	mv	a1,s3
    4bb6:	00003517          	auipc	a0,0x3
    4bba:	27250513          	addi	a0,a0,626 # 7e28 <malloc+0x2192>
    4bbe:	00001097          	auipc	ra,0x1
    4bc2:	01a080e7          	jalr	26(ra) # 5bd8 <printf>
    exit(1);
    4bc6:	4505                	li	a0,1
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	c80080e7          	jalr	-896(ra) # 5848 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    4bd0:	fb040613          	addi	a2,s0,-80
    4bd4:	85ce                	mv	a1,s3
    4bd6:	00003517          	auipc	a0,0x3
    4bda:	27250513          	addi	a0,a0,626 # 7e48 <malloc+0x21b2>
    4bde:	00001097          	auipc	ra,0x1
    4be2:	ffa080e7          	jalr	-6(ra) # 5bd8 <printf>
      exit(1);
    4be6:	4505                	li	a0,1
    4be8:	00001097          	auipc	ra,0x1
    4bec:	c60080e7          	jalr	-928(ra) # 5848 <exit>
      printf("%s: bigdir unlink failed", s);
    4bf0:	85ce                	mv	a1,s3
    4bf2:	00003517          	auipc	a0,0x3
    4bf6:	27650513          	addi	a0,a0,630 # 7e68 <malloc+0x21d2>
    4bfa:	00001097          	auipc	ra,0x1
    4bfe:	fde080e7          	jalr	-34(ra) # 5bd8 <printf>
      exit(1);
    4c02:	4505                	li	a0,1
    4c04:	00001097          	auipc	ra,0x1
    4c08:	c44080e7          	jalr	-956(ra) # 5848 <exit>

0000000000004c0c <manywrites>:
{
    4c0c:	711d                	addi	sp,sp,-96
    4c0e:	ec86                	sd	ra,88(sp)
    4c10:	e8a2                	sd	s0,80(sp)
    4c12:	e4a6                	sd	s1,72(sp)
    4c14:	e0ca                	sd	s2,64(sp)
    4c16:	fc4e                	sd	s3,56(sp)
    4c18:	f852                	sd	s4,48(sp)
    4c1a:	f456                	sd	s5,40(sp)
    4c1c:	f05a                	sd	s6,32(sp)
    4c1e:	ec5e                	sd	s7,24(sp)
    4c20:	1080                	addi	s0,sp,96
    4c22:	8a2a                	mv	s4,a0
    int pid = fork();
    4c24:	00001097          	auipc	ra,0x1
    4c28:	c1c080e7          	jalr	-996(ra) # 5840 <fork>
    if(pid < 0){
    4c2c:	04054763          	bltz	a0,4c7a <manywrites+0x6e>
    4c30:	84aa                	mv	s1,a0
    if(pid == 0){
    4c32:	c135                	beqz	a0,4c96 <manywrites+0x8a>
    int pid = fork();
    4c34:	00001097          	auipc	ra,0x1
    4c38:	c0c080e7          	jalr	-1012(ra) # 5840 <fork>
    if(pid < 0){
    4c3c:	02054f63          	bltz	a0,4c7a <manywrites+0x6e>
    if(pid == 0){
    4c40:	c931                	beqz	a0,4c94 <manywrites+0x88>
    int st = 0;
    4c42:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    4c46:	fa840513          	addi	a0,s0,-88
    4c4a:	00001097          	auipc	ra,0x1
    4c4e:	c06080e7          	jalr	-1018(ra) # 5850 <wait>
    if(st != 0)
    4c52:	fa842503          	lw	a0,-88(s0)
    4c56:	10051763          	bnez	a0,4d64 <manywrites+0x158>
    int st = 0;
    4c5a:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    4c5e:	fa840513          	addi	a0,s0,-88
    4c62:	00001097          	auipc	ra,0x1
    4c66:	bee080e7          	jalr	-1042(ra) # 5850 <wait>
    if(st != 0)
    4c6a:	fa842503          	lw	a0,-88(s0)
    4c6e:	e97d                	bnez	a0,4d64 <manywrites+0x158>
  exit(0);
    4c70:	4501                	li	a0,0
    4c72:	00001097          	auipc	ra,0x1
    4c76:	bd6080e7          	jalr	-1066(ra) # 5848 <exit>
      printf("fork failed\n");
    4c7a:	00002517          	auipc	a0,0x2
    4c7e:	04e50513          	addi	a0,a0,78 # 6cc8 <malloc+0x1032>
    4c82:	00001097          	auipc	ra,0x1
    4c86:	f56080e7          	jalr	-170(ra) # 5bd8 <printf>
      exit(1);
    4c8a:	4505                	li	a0,1
    4c8c:	00001097          	auipc	ra,0x1
    4c90:	bbc080e7          	jalr	-1092(ra) # 5848 <exit>
  for(int ci = 0; ci < nchildren; ci++){
    4c94:	4485                	li	s1,1
      name[0] = 'b';
    4c96:	06200793          	li	a5,98
    4c9a:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    4c9e:	0614879b          	addiw	a5,s1,97
    4ca2:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    4ca6:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    4caa:	fa840513          	addi	a0,s0,-88
    4cae:	00001097          	auipc	ra,0x1
    4cb2:	bea080e7          	jalr	-1046(ra) # 5898 <unlink>
    4cb6:	4bd1                	li	s7,20
        for(int i = 0; i < ci+1; i++){
    4cb8:	4b01                	li	s6,0
          int cc = write(fd, buf, sz);
    4cba:	00007a97          	auipc	s5,0x7
    4cbe:	08ea8a93          	addi	s5,s5,142 # bd48 <buf>
        for(int i = 0; i < ci+1; i++){
    4cc2:	89da                	mv	s3,s6
          int fd = open(name, O_CREATE | O_RDWR);
    4cc4:	20200593          	li	a1,514
    4cc8:	fa840513          	addi	a0,s0,-88
    4ccc:	00001097          	auipc	ra,0x1
    4cd0:	bbc080e7          	jalr	-1092(ra) # 5888 <open>
    4cd4:	892a                	mv	s2,a0
          if(fd < 0){
    4cd6:	04054763          	bltz	a0,4d24 <manywrites+0x118>
          int cc = write(fd, buf, sz);
    4cda:	660d                	lui	a2,0x3
    4cdc:	85d6                	mv	a1,s5
    4cde:	00001097          	auipc	ra,0x1
    4ce2:	b8a080e7          	jalr	-1142(ra) # 5868 <write>
          if(cc != sz){
    4ce6:	678d                	lui	a5,0x3
    4ce8:	04f51e63          	bne	a0,a5,4d44 <manywrites+0x138>
          close(fd);
    4cec:	854a                	mv	a0,s2
    4cee:	00001097          	auipc	ra,0x1
    4cf2:	b82080e7          	jalr	-1150(ra) # 5870 <close>
        for(int i = 0; i < ci+1; i++){
    4cf6:	2985                	addiw	s3,s3,1
    4cf8:	fd34d6e3          	bge	s1,s3,4cc4 <manywrites+0xb8>
        unlink(name);
    4cfc:	fa840513          	addi	a0,s0,-88
    4d00:	00001097          	auipc	ra,0x1
    4d04:	b98080e7          	jalr	-1128(ra) # 5898 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    4d08:	3bfd                	addiw	s7,s7,-1
    4d0a:	fa0b9ce3          	bnez	s7,4cc2 <manywrites+0xb6>
      unlink(name);
    4d0e:	fa840513          	addi	a0,s0,-88
    4d12:	00001097          	auipc	ra,0x1
    4d16:	b86080e7          	jalr	-1146(ra) # 5898 <unlink>
      exit(0);
    4d1a:	4501                	li	a0,0
    4d1c:	00001097          	auipc	ra,0x1
    4d20:	b2c080e7          	jalr	-1236(ra) # 5848 <exit>
            printf("%s: cannot create %s\n", s, name);
    4d24:	fa840613          	addi	a2,s0,-88
    4d28:	85d2                	mv	a1,s4
    4d2a:	00003517          	auipc	a0,0x3
    4d2e:	15e50513          	addi	a0,a0,350 # 7e88 <malloc+0x21f2>
    4d32:	00001097          	auipc	ra,0x1
    4d36:	ea6080e7          	jalr	-346(ra) # 5bd8 <printf>
            exit(1);
    4d3a:	4505                	li	a0,1
    4d3c:	00001097          	auipc	ra,0x1
    4d40:	b0c080e7          	jalr	-1268(ra) # 5848 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    4d44:	86aa                	mv	a3,a0
    4d46:	660d                	lui	a2,0x3
    4d48:	85d2                	mv	a1,s4
    4d4a:	00001517          	auipc	a0,0x1
    4d4e:	46650513          	addi	a0,a0,1126 # 61b0 <malloc+0x51a>
    4d52:	00001097          	auipc	ra,0x1
    4d56:	e86080e7          	jalr	-378(ra) # 5bd8 <printf>
            exit(1);
    4d5a:	4505                	li	a0,1
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	aec080e7          	jalr	-1300(ra) # 5848 <exit>
      exit(st);
    4d64:	00001097          	auipc	ra,0x1
    4d68:	ae4080e7          	jalr	-1308(ra) # 5848 <exit>

0000000000004d6c <sbrkfail>:
{
    4d6c:	7119                	addi	sp,sp,-128
    4d6e:	fc86                	sd	ra,120(sp)
    4d70:	f8a2                	sd	s0,112(sp)
    4d72:	f4a6                	sd	s1,104(sp)
    4d74:	f0ca                	sd	s2,96(sp)
    4d76:	ecce                	sd	s3,88(sp)
    4d78:	e8d2                	sd	s4,80(sp)
    4d7a:	e4d6                	sd	s5,72(sp)
    4d7c:	0100                	addi	s0,sp,128
    4d7e:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    4d80:	fb040513          	addi	a0,s0,-80
    4d84:	00001097          	auipc	ra,0x1
    4d88:	ad4080e7          	jalr	-1324(ra) # 5858 <pipe>
    4d8c:	e901                	bnez	a0,4d9c <sbrkfail+0x30>
    4d8e:	f8040493          	addi	s1,s0,-128
    4d92:	fa840a13          	addi	s4,s0,-88
    4d96:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    4d98:	5afd                	li	s5,-1
    4d9a:	a08d                	j	4dfc <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    4d9c:	85ca                	mv	a1,s2
    4d9e:	00002517          	auipc	a0,0x2
    4da2:	c2a50513          	addi	a0,a0,-982 # 69c8 <malloc+0xd32>
    4da6:	00001097          	auipc	ra,0x1
    4daa:	e32080e7          	jalr	-462(ra) # 5bd8 <printf>
    exit(1);
    4dae:	4505                	li	a0,1
    4db0:	00001097          	auipc	ra,0x1
    4db4:	a98080e7          	jalr	-1384(ra) # 5848 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4db8:	4501                	li	a0,0
    4dba:	00001097          	auipc	ra,0x1
    4dbe:	b16080e7          	jalr	-1258(ra) # 58d0 <sbrk>
    4dc2:	064007b7          	lui	a5,0x6400
    4dc6:	40a7853b          	subw	a0,a5,a0
    4dca:	00001097          	auipc	ra,0x1
    4dce:	b06080e7          	jalr	-1274(ra) # 58d0 <sbrk>
      write(fds[1], "x", 1);
    4dd2:	4605                	li	a2,1
    4dd4:	00001597          	auipc	a1,0x1
    4dd8:	38c58593          	addi	a1,a1,908 # 6160 <malloc+0x4ca>
    4ddc:	fb442503          	lw	a0,-76(s0)
    4de0:	00001097          	auipc	ra,0x1
    4de4:	a88080e7          	jalr	-1400(ra) # 5868 <write>
      for(;;) sleep(1000);
    4de8:	3e800513          	li	a0,1000
    4dec:	00001097          	auipc	ra,0x1
    4df0:	aec080e7          	jalr	-1300(ra) # 58d8 <sleep>
    4df4:	bfd5                	j	4de8 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4df6:	0991                	addi	s3,s3,4
    4df8:	03498563          	beq	s3,s4,4e22 <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    4dfc:	00001097          	auipc	ra,0x1
    4e00:	a44080e7          	jalr	-1468(ra) # 5840 <fork>
    4e04:	00a9a023          	sw	a0,0(s3)
    4e08:	d945                	beqz	a0,4db8 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4e0a:	ff5506e3          	beq	a0,s5,4df6 <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    4e0e:	4605                	li	a2,1
    4e10:	faf40593          	addi	a1,s0,-81
    4e14:	fb042503          	lw	a0,-80(s0)
    4e18:	00001097          	auipc	ra,0x1
    4e1c:	a48080e7          	jalr	-1464(ra) # 5860 <read>
    4e20:	bfd9                	j	4df6 <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    4e22:	6505                	lui	a0,0x1
    4e24:	00001097          	auipc	ra,0x1
    4e28:	aac080e7          	jalr	-1364(ra) # 58d0 <sbrk>
    4e2c:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    4e2e:	5afd                	li	s5,-1
    4e30:	a021                	j	4e38 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4e32:	0491                	addi	s1,s1,4
    4e34:	01448f63          	beq	s1,s4,4e52 <sbrkfail+0xe6>
    if(pids[i] == -1)
    4e38:	4088                	lw	a0,0(s1)
    4e3a:	ff550ce3          	beq	a0,s5,4e32 <sbrkfail+0xc6>
    kill(pids[i]);
    4e3e:	00001097          	auipc	ra,0x1
    4e42:	a3a080e7          	jalr	-1478(ra) # 5878 <kill>
    wait(0);
    4e46:	4501                	li	a0,0
    4e48:	00001097          	auipc	ra,0x1
    4e4c:	a08080e7          	jalr	-1528(ra) # 5850 <wait>
    4e50:	b7cd                	j	4e32 <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    4e52:	57fd                	li	a5,-1
    4e54:	04f98163          	beq	s3,a5,4e96 <sbrkfail+0x12a>
  pid = fork();
    4e58:	00001097          	auipc	ra,0x1
    4e5c:	9e8080e7          	jalr	-1560(ra) # 5840 <fork>
    4e60:	84aa                	mv	s1,a0
  if(pid < 0){
    4e62:	04054863          	bltz	a0,4eb2 <sbrkfail+0x146>
  if(pid == 0){
    4e66:	c525                	beqz	a0,4ece <sbrkfail+0x162>
  wait(&xstatus);
    4e68:	fbc40513          	addi	a0,s0,-68
    4e6c:	00001097          	auipc	ra,0x1
    4e70:	9e4080e7          	jalr	-1564(ra) # 5850 <wait>
  if(xstatus != -1 && xstatus != 2)
    4e74:	fbc42783          	lw	a5,-68(s0)
    4e78:	577d                	li	a4,-1
    4e7a:	00e78563          	beq	a5,a4,4e84 <sbrkfail+0x118>
    4e7e:	4709                	li	a4,2
    4e80:	08e79d63          	bne	a5,a4,4f1a <sbrkfail+0x1ae>
}
    4e84:	70e6                	ld	ra,120(sp)
    4e86:	7446                	ld	s0,112(sp)
    4e88:	74a6                	ld	s1,104(sp)
    4e8a:	7906                	ld	s2,96(sp)
    4e8c:	69e6                	ld	s3,88(sp)
    4e8e:	6a46                	ld	s4,80(sp)
    4e90:	6aa6                	ld	s5,72(sp)
    4e92:	6109                	addi	sp,sp,128
    4e94:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4e96:	85ca                	mv	a1,s2
    4e98:	00003517          	auipc	a0,0x3
    4e9c:	00850513          	addi	a0,a0,8 # 7ea0 <malloc+0x220a>
    4ea0:	00001097          	auipc	ra,0x1
    4ea4:	d38080e7          	jalr	-712(ra) # 5bd8 <printf>
    exit(1);
    4ea8:	4505                	li	a0,1
    4eaa:	00001097          	auipc	ra,0x1
    4eae:	99e080e7          	jalr	-1634(ra) # 5848 <exit>
    printf("%s: fork failed\n", s);
    4eb2:	85ca                	mv	a1,s2
    4eb4:	00002517          	auipc	a0,0x2
    4eb8:	a0c50513          	addi	a0,a0,-1524 # 68c0 <malloc+0xc2a>
    4ebc:	00001097          	auipc	ra,0x1
    4ec0:	d1c080e7          	jalr	-740(ra) # 5bd8 <printf>
    exit(1);
    4ec4:	4505                	li	a0,1
    4ec6:	00001097          	auipc	ra,0x1
    4eca:	982080e7          	jalr	-1662(ra) # 5848 <exit>
    a = sbrk(0);
    4ece:	4501                	li	a0,0
    4ed0:	00001097          	auipc	ra,0x1
    4ed4:	a00080e7          	jalr	-1536(ra) # 58d0 <sbrk>
    4ed8:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    4eda:	3e800537          	lui	a0,0x3e800
    4ede:	00001097          	auipc	ra,0x1
    4ee2:	9f2080e7          	jalr	-1550(ra) # 58d0 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4ee6:	874e                	mv	a4,s3
    4ee8:	3e8007b7          	lui	a5,0x3e800
    4eec:	97ce                	add	a5,a5,s3
    4eee:	6685                	lui	a3,0x1
      n += *(a+i);
    4ef0:	00074603          	lbu	a2,0(a4)
    4ef4:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4ef6:	9736                	add	a4,a4,a3
    4ef8:	fef71ce3          	bne	a4,a5,4ef0 <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4efc:	8626                	mv	a2,s1
    4efe:	85ca                	mv	a1,s2
    4f00:	00003517          	auipc	a0,0x3
    4f04:	fc050513          	addi	a0,a0,-64 # 7ec0 <malloc+0x222a>
    4f08:	00001097          	auipc	ra,0x1
    4f0c:	cd0080e7          	jalr	-816(ra) # 5bd8 <printf>
    exit(1);
    4f10:	4505                	li	a0,1
    4f12:	00001097          	auipc	ra,0x1
    4f16:	936080e7          	jalr	-1738(ra) # 5848 <exit>
    exit(1);
    4f1a:	4505                	li	a0,1
    4f1c:	00001097          	auipc	ra,0x1
    4f20:	92c080e7          	jalr	-1748(ra) # 5848 <exit>

0000000000004f24 <fsfull>:
{
    4f24:	7171                	addi	sp,sp,-176
    4f26:	f506                	sd	ra,168(sp)
    4f28:	f122                	sd	s0,160(sp)
    4f2a:	ed26                	sd	s1,152(sp)
    4f2c:	e94a                	sd	s2,144(sp)
    4f2e:	e54e                	sd	s3,136(sp)
    4f30:	e152                	sd	s4,128(sp)
    4f32:	fcd6                	sd	s5,120(sp)
    4f34:	f8da                	sd	s6,112(sp)
    4f36:	f4de                	sd	s7,104(sp)
    4f38:	f0e2                	sd	s8,96(sp)
    4f3a:	ece6                	sd	s9,88(sp)
    4f3c:	e8ea                	sd	s10,80(sp)
    4f3e:	e4ee                	sd	s11,72(sp)
    4f40:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4f42:	00003517          	auipc	a0,0x3
    4f46:	fae50513          	addi	a0,a0,-82 # 7ef0 <malloc+0x225a>
    4f4a:	00001097          	auipc	ra,0x1
    4f4e:	c8e080e7          	jalr	-882(ra) # 5bd8 <printf>
  for(nfiles = 0; ; nfiles++){
    4f52:	4481                	li	s1,0
    name[0] = 'f';
    4f54:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4f58:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4f5c:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4f60:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4f62:	00003c97          	auipc	s9,0x3
    4f66:	f9ec8c93          	addi	s9,s9,-98 # 7f00 <malloc+0x226a>
    int total = 0;
    4f6a:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4f6c:	00007a17          	auipc	s4,0x7
    4f70:	ddca0a13          	addi	s4,s4,-548 # bd48 <buf>
    name[0] = 'f';
    4f74:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4f78:	0384c7bb          	divw	a5,s1,s8
    4f7c:	0307879b          	addiw	a5,a5,48
    4f80:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4f84:	0384e7bb          	remw	a5,s1,s8
    4f88:	0377c7bb          	divw	a5,a5,s7
    4f8c:	0307879b          	addiw	a5,a5,48
    4f90:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4f94:	0374e7bb          	remw	a5,s1,s7
    4f98:	0367c7bb          	divw	a5,a5,s6
    4f9c:	0307879b          	addiw	a5,a5,48
    4fa0:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4fa4:	0364e7bb          	remw	a5,s1,s6
    4fa8:	0307879b          	addiw	a5,a5,48
    4fac:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4fb0:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4fb4:	f5040593          	addi	a1,s0,-176
    4fb8:	8566                	mv	a0,s9
    4fba:	00001097          	auipc	ra,0x1
    4fbe:	c1e080e7          	jalr	-994(ra) # 5bd8 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4fc2:	20200593          	li	a1,514
    4fc6:	f5040513          	addi	a0,s0,-176
    4fca:	00001097          	auipc	ra,0x1
    4fce:	8be080e7          	jalr	-1858(ra) # 5888 <open>
    4fd2:	892a                	mv	s2,a0
    if(fd < 0){
    4fd4:	0a055663          	bgez	a0,5080 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4fd8:	f5040593          	addi	a1,s0,-176
    4fdc:	00003517          	auipc	a0,0x3
    4fe0:	f3450513          	addi	a0,a0,-204 # 7f10 <malloc+0x227a>
    4fe4:	00001097          	auipc	ra,0x1
    4fe8:	bf4080e7          	jalr	-1036(ra) # 5bd8 <printf>
  while(nfiles >= 0){
    4fec:	0604c363          	bltz	s1,5052 <fsfull+0x12e>
    name[0] = 'f';
    4ff0:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4ff4:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4ff8:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4ffc:	4929                	li	s2,10
  while(nfiles >= 0){
    4ffe:	5afd                	li	s5,-1
    name[0] = 'f';
    5000:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5004:	0344c7bb          	divw	a5,s1,s4
    5008:	0307879b          	addiw	a5,a5,48
    500c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5010:	0344e7bb          	remw	a5,s1,s4
    5014:	0337c7bb          	divw	a5,a5,s3
    5018:	0307879b          	addiw	a5,a5,48
    501c:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5020:	0334e7bb          	remw	a5,s1,s3
    5024:	0327c7bb          	divw	a5,a5,s2
    5028:	0307879b          	addiw	a5,a5,48
    502c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5030:	0324e7bb          	remw	a5,s1,s2
    5034:	0307879b          	addiw	a5,a5,48
    5038:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    503c:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    5040:	f5040513          	addi	a0,s0,-176
    5044:	00001097          	auipc	ra,0x1
    5048:	854080e7          	jalr	-1964(ra) # 5898 <unlink>
    nfiles--;
    504c:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    504e:	fb5499e3          	bne	s1,s5,5000 <fsfull+0xdc>
  printf("fsfull test finished\n");
    5052:	00003517          	auipc	a0,0x3
    5056:	ede50513          	addi	a0,a0,-290 # 7f30 <malloc+0x229a>
    505a:	00001097          	auipc	ra,0x1
    505e:	b7e080e7          	jalr	-1154(ra) # 5bd8 <printf>
}
    5062:	70aa                	ld	ra,168(sp)
    5064:	740a                	ld	s0,160(sp)
    5066:	64ea                	ld	s1,152(sp)
    5068:	694a                	ld	s2,144(sp)
    506a:	69aa                	ld	s3,136(sp)
    506c:	6a0a                	ld	s4,128(sp)
    506e:	7ae6                	ld	s5,120(sp)
    5070:	7b46                	ld	s6,112(sp)
    5072:	7ba6                	ld	s7,104(sp)
    5074:	7c06                	ld	s8,96(sp)
    5076:	6ce6                	ld	s9,88(sp)
    5078:	6d46                	ld	s10,80(sp)
    507a:	6da6                	ld	s11,72(sp)
    507c:	614d                	addi	sp,sp,176
    507e:	8082                	ret
    int total = 0;
    5080:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    5082:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    5086:	40000613          	li	a2,1024
    508a:	85d2                	mv	a1,s4
    508c:	854a                	mv	a0,s2
    508e:	00000097          	auipc	ra,0x0
    5092:	7da080e7          	jalr	2010(ra) # 5868 <write>
      if(cc < BSIZE)
    5096:	00aad563          	bge	s5,a0,50a0 <fsfull+0x17c>
      total += cc;
    509a:	00a989bb          	addw	s3,s3,a0
    while(1){
    509e:	b7e5                	j	5086 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    50a0:	85ce                	mv	a1,s3
    50a2:	00003517          	auipc	a0,0x3
    50a6:	e7e50513          	addi	a0,a0,-386 # 7f20 <malloc+0x228a>
    50aa:	00001097          	auipc	ra,0x1
    50ae:	b2e080e7          	jalr	-1234(ra) # 5bd8 <printf>
    close(fd);
    50b2:	854a                	mv	a0,s2
    50b4:	00000097          	auipc	ra,0x0
    50b8:	7bc080e7          	jalr	1980(ra) # 5870 <close>
    if(total == 0)
    50bc:	f20988e3          	beqz	s3,4fec <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    50c0:	2485                	addiw	s1,s1,1
    50c2:	bd4d                	j	4f74 <fsfull+0x50>

00000000000050c4 <badwrite>:
{
    50c4:	7179                	addi	sp,sp,-48
    50c6:	f406                	sd	ra,40(sp)
    50c8:	f022                	sd	s0,32(sp)
    50ca:	ec26                	sd	s1,24(sp)
    50cc:	e84a                	sd	s2,16(sp)
    50ce:	e44e                	sd	s3,8(sp)
    50d0:	e052                	sd	s4,0(sp)
    50d2:	1800                	addi	s0,sp,48
  unlink("junk");
    50d4:	00003517          	auipc	a0,0x3
    50d8:	e7450513          	addi	a0,a0,-396 # 7f48 <malloc+0x22b2>
    50dc:	00000097          	auipc	ra,0x0
    50e0:	7bc080e7          	jalr	1980(ra) # 5898 <unlink>
    50e4:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    50e8:	00003997          	auipc	s3,0x3
    50ec:	e6098993          	addi	s3,s3,-416 # 7f48 <malloc+0x22b2>
    write(fd, (char*)0xffffffffffL, 1);
    50f0:	5a7d                	li	s4,-1
    50f2:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    50f6:	20100593          	li	a1,513
    50fa:	854e                	mv	a0,s3
    50fc:	00000097          	auipc	ra,0x0
    5100:	78c080e7          	jalr	1932(ra) # 5888 <open>
    5104:	84aa                	mv	s1,a0
    if(fd < 0){
    5106:	06054b63          	bltz	a0,517c <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    510a:	4605                	li	a2,1
    510c:	85d2                	mv	a1,s4
    510e:	00000097          	auipc	ra,0x0
    5112:	75a080e7          	jalr	1882(ra) # 5868 <write>
    close(fd);
    5116:	8526                	mv	a0,s1
    5118:	00000097          	auipc	ra,0x0
    511c:	758080e7          	jalr	1880(ra) # 5870 <close>
    unlink("junk");
    5120:	854e                	mv	a0,s3
    5122:	00000097          	auipc	ra,0x0
    5126:	776080e7          	jalr	1910(ra) # 5898 <unlink>
  for(int i = 0; i < assumed_free; i++){
    512a:	397d                	addiw	s2,s2,-1
    512c:	fc0915e3          	bnez	s2,50f6 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    5130:	20100593          	li	a1,513
    5134:	00003517          	auipc	a0,0x3
    5138:	e1450513          	addi	a0,a0,-492 # 7f48 <malloc+0x22b2>
    513c:	00000097          	auipc	ra,0x0
    5140:	74c080e7          	jalr	1868(ra) # 5888 <open>
    5144:	84aa                	mv	s1,a0
  if(fd < 0){
    5146:	04054863          	bltz	a0,5196 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    514a:	4605                	li	a2,1
    514c:	00001597          	auipc	a1,0x1
    5150:	01458593          	addi	a1,a1,20 # 6160 <malloc+0x4ca>
    5154:	00000097          	auipc	ra,0x0
    5158:	714080e7          	jalr	1812(ra) # 5868 <write>
    515c:	4785                	li	a5,1
    515e:	04f50963          	beq	a0,a5,51b0 <badwrite+0xec>
    printf("write failed\n");
    5162:	00003517          	auipc	a0,0x3
    5166:	e0650513          	addi	a0,a0,-506 # 7f68 <malloc+0x22d2>
    516a:	00001097          	auipc	ra,0x1
    516e:	a6e080e7          	jalr	-1426(ra) # 5bd8 <printf>
    exit(1);
    5172:	4505                	li	a0,1
    5174:	00000097          	auipc	ra,0x0
    5178:	6d4080e7          	jalr	1748(ra) # 5848 <exit>
      printf("open junk failed\n");
    517c:	00003517          	auipc	a0,0x3
    5180:	dd450513          	addi	a0,a0,-556 # 7f50 <malloc+0x22ba>
    5184:	00001097          	auipc	ra,0x1
    5188:	a54080e7          	jalr	-1452(ra) # 5bd8 <printf>
      exit(1);
    518c:	4505                	li	a0,1
    518e:	00000097          	auipc	ra,0x0
    5192:	6ba080e7          	jalr	1722(ra) # 5848 <exit>
    printf("open junk failed\n");
    5196:	00003517          	auipc	a0,0x3
    519a:	dba50513          	addi	a0,a0,-582 # 7f50 <malloc+0x22ba>
    519e:	00001097          	auipc	ra,0x1
    51a2:	a3a080e7          	jalr	-1478(ra) # 5bd8 <printf>
    exit(1);
    51a6:	4505                	li	a0,1
    51a8:	00000097          	auipc	ra,0x0
    51ac:	6a0080e7          	jalr	1696(ra) # 5848 <exit>
  close(fd);
    51b0:	8526                	mv	a0,s1
    51b2:	00000097          	auipc	ra,0x0
    51b6:	6be080e7          	jalr	1726(ra) # 5870 <close>
  unlink("junk");
    51ba:	00003517          	auipc	a0,0x3
    51be:	d8e50513          	addi	a0,a0,-626 # 7f48 <malloc+0x22b2>
    51c2:	00000097          	auipc	ra,0x0
    51c6:	6d6080e7          	jalr	1750(ra) # 5898 <unlink>
  exit(0);
    51ca:	4501                	li	a0,0
    51cc:	00000097          	auipc	ra,0x0
    51d0:	67c080e7          	jalr	1660(ra) # 5848 <exit>

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
    51ea:	672080e7          	jalr	1650(ra) # 5858 <pipe>
    51ee:	06054863          	bltz	a0,525e <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    51f2:	00000097          	auipc	ra,0x0
    51f6:	64e080e7          	jalr	1614(ra) # 5840 <fork>

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
    5208:	66c080e7          	jalr	1644(ra) # 5870 <close>
    
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
    5214:	f5090913          	addi	s2,s2,-176 # 6160 <malloc+0x4ca>
      uint64 a = (uint64) sbrk(4096);
    5218:	6505                	lui	a0,0x1
    521a:	00000097          	auipc	ra,0x0
    521e:	6b6080e7          	jalr	1718(ra) # 58d0 <sbrk>
      if(a == 0xffffffffffffffff){
    5222:	06950863          	beq	a0,s1,5292 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    5226:	6785                	lui	a5,0x1
    5228:	953e                	add	a0,a0,a5
    522a:	ff350fa3          	sb	s3,-1(a0) # fff <pgbug+0x2f>
      if(write(fds[1], "x", 1) != 1){
    522e:	4605                	li	a2,1
    5230:	85ca                	mv	a1,s2
    5232:	fcc42503          	lw	a0,-52(s0)
    5236:	00000097          	auipc	ra,0x0
    523a:	632080e7          	jalr	1586(ra) # 5868 <write>
    523e:	4785                	li	a5,1
    5240:	fcf50ce3          	beq	a0,a5,5218 <countfree+0x44>
        printf("write() failed in countfree()\n");
    5244:	00003517          	auipc	a0,0x3
    5248:	d7450513          	addi	a0,a0,-652 # 7fb8 <malloc+0x2322>
    524c:	00001097          	auipc	ra,0x1
    5250:	98c080e7          	jalr	-1652(ra) # 5bd8 <printf>
        exit(1);
    5254:	4505                	li	a0,1
    5256:	00000097          	auipc	ra,0x0
    525a:	5f2080e7          	jalr	1522(ra) # 5848 <exit>
    printf("pipe() failed in countfree()\n");
    525e:	00003517          	auipc	a0,0x3
    5262:	d1a50513          	addi	a0,a0,-742 # 7f78 <malloc+0x22e2>
    5266:	00001097          	auipc	ra,0x1
    526a:	972080e7          	jalr	-1678(ra) # 5bd8 <printf>
    exit(1);
    526e:	4505                	li	a0,1
    5270:	00000097          	auipc	ra,0x0
    5274:	5d8080e7          	jalr	1496(ra) # 5848 <exit>
    printf("fork failed in countfree()\n");
    5278:	00003517          	auipc	a0,0x3
    527c:	d2050513          	addi	a0,a0,-736 # 7f98 <malloc+0x2302>
    5280:	00001097          	auipc	ra,0x1
    5284:	958080e7          	jalr	-1704(ra) # 5bd8 <printf>
    exit(1);
    5288:	4505                	li	a0,1
    528a:	00000097          	auipc	ra,0x0
    528e:	5be080e7          	jalr	1470(ra) # 5848 <exit>
      }
    }

    exit(0);
    5292:	4501                	li	a0,0
    5294:	00000097          	auipc	ra,0x0
    5298:	5b4080e7          	jalr	1460(ra) # 5848 <exit>
  }

  close(fds[1]);
    529c:	fcc42503          	lw	a0,-52(s0)
    52a0:	00000097          	auipc	ra,0x0
    52a4:	5d0080e7          	jalr	1488(ra) # 5870 <close>

  int n = 0;
    52a8:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    52aa:	4605                	li	a2,1
    52ac:	fc740593          	addi	a1,s0,-57
    52b0:	fc842503          	lw	a0,-56(s0)
    52b4:	00000097          	auipc	ra,0x0
    52b8:	5ac080e7          	jalr	1452(ra) # 5860 <read>
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
    52ca:	d1250513          	addi	a0,a0,-750 # 7fd8 <malloc+0x2342>
    52ce:	00001097          	auipc	ra,0x1
    52d2:	90a080e7          	jalr	-1782(ra) # 5bd8 <printf>
      exit(1);
    52d6:	4505                	li	a0,1
    52d8:	00000097          	auipc	ra,0x0
    52dc:	570080e7          	jalr	1392(ra) # 5848 <exit>
  }

  close(fds[0]);
    52e0:	fc842503          	lw	a0,-56(s0)
    52e4:	00000097          	auipc	ra,0x0
    52e8:	58c080e7          	jalr	1420(ra) # 5870 <close>
  wait((int*)0);
    52ec:	4501                	li	a0,0
    52ee:	00000097          	auipc	ra,0x0
    52f2:	562080e7          	jalr	1378(ra) # 5850 <wait>
  
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
    531a:	ce250513          	addi	a0,a0,-798 # 7ff8 <malloc+0x2362>
    531e:	00001097          	auipc	ra,0x1
    5322:	8ba080e7          	jalr	-1862(ra) # 5bd8 <printf>
  if((pid = fork()) < 0) {
    5326:	00000097          	auipc	ra,0x0
    532a:	51a080e7          	jalr	1306(ra) # 5840 <fork>
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
    533c:	518080e7          	jalr	1304(ra) # 5850 <wait>
    if(xstatus != 0) 
    5340:	fdc42783          	lw	a5,-36(s0)
    5344:	c7b9                	beqz	a5,5392 <run+0x8c>
      printf("FAILED\n");
    5346:	00003517          	auipc	a0,0x3
    534a:	cda50513          	addi	a0,a0,-806 # 8020 <malloc+0x238a>
    534e:	00001097          	auipc	ra,0x1
    5352:	88a080e7          	jalr	-1910(ra) # 5bd8 <printf>
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
    536e:	c9e50513          	addi	a0,a0,-866 # 8008 <malloc+0x2372>
    5372:	00001097          	auipc	ra,0x1
    5376:	866080e7          	jalr	-1946(ra) # 5bd8 <printf>
    exit(1);
    537a:	4505                	li	a0,1
    537c:	00000097          	auipc	ra,0x0
    5380:	4cc080e7          	jalr	1228(ra) # 5848 <exit>
    f(s);
    5384:	854a                	mv	a0,s2
    5386:	9482                	jalr	s1
    exit(0);
    5388:	4501                	li	a0,0
    538a:	00000097          	auipc	ra,0x0
    538e:	4be080e7          	jalr	1214(ra) # 5848 <exit>
      printf("OK\n");
    5392:	00003517          	auipc	a0,0x3
    5396:	c9650513          	addi	a0,a0,-874 # 8028 <malloc+0x2392>
    539a:	00001097          	auipc	ra,0x1
    539e:	83e080e7          	jalr	-1986(ra) # 5bd8 <printf>
    53a2:	bf55                	j	5356 <run+0x50>

00000000000053a4 <main>:

int
main(int argc, char *argv[])
{
    53a4:	c0010113          	addi	sp,sp,-1024
    53a8:	3e113c23          	sd	ra,1016(sp)
    53ac:	3e813823          	sd	s0,1008(sp)
    53b0:	3e913423          	sd	s1,1000(sp)
    53b4:	3f213023          	sd	s2,992(sp)
    53b8:	3d313c23          	sd	s3,984(sp)
    53bc:	3d413823          	sd	s4,976(sp)
    53c0:	3d513423          	sd	s5,968(sp)
    53c4:	3d613023          	sd	s6,960(sp)
    53c8:	40010413          	addi	s0,sp,1024
    53cc:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    53ce:	4789                	li	a5,2
    53d0:	08f50763          	beq	a0,a5,545e <main+0xba>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    53d4:	4785                	li	a5,1
  char *justone = 0;
    53d6:	4901                	li	s2,0
  } else if(argc > 1){
    53d8:	0ca7c163          	blt	a5,a0,549a <main+0xf6>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    53dc:	00003797          	auipc	a5,0x3
    53e0:	d6478793          	addi	a5,a5,-668 # 8140 <malloc+0x24aa>
    53e4:	c0040713          	addi	a4,s0,-1024
    53e8:	00003817          	auipc	a6,0x3
    53ec:	11880813          	addi	a6,a6,280 # 8500 <malloc+0x286a>
    53f0:	6388                	ld	a0,0(a5)
    53f2:	678c                	ld	a1,8(a5)
    53f4:	6b90                	ld	a2,16(a5)
    53f6:	6f94                	ld	a3,24(a5)
    53f8:	e308                	sd	a0,0(a4)
    53fa:	e70c                	sd	a1,8(a4)
    53fc:	eb10                	sd	a2,16(a4)
    53fe:	ef14                	sd	a3,24(a4)
    5400:	02078793          	addi	a5,a5,32
    5404:	02070713          	addi	a4,a4,32
    5408:	ff0794e3          	bne	a5,a6,53f0 <main+0x4c>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    540c:	00003517          	auipc	a0,0x3
    5410:	cd450513          	addi	a0,a0,-812 # 80e0 <malloc+0x244a>
    5414:	00000097          	auipc	ra,0x0
    5418:	7c4080e7          	jalr	1988(ra) # 5bd8 <printf>
  int free0 = countfree();
    541c:	00000097          	auipc	ra,0x0
    5420:	db8080e7          	jalr	-584(ra) # 51d4 <countfree>
    5424:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5426:	c0843503          	ld	a0,-1016(s0)
    542a:	c0040493          	addi	s1,s0,-1024
  int fail = 0;
    542e:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    5430:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    5432:	e55d                	bnez	a0,54e0 <main+0x13c>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5434:	00000097          	auipc	ra,0x0
    5438:	da0080e7          	jalr	-608(ra) # 51d4 <countfree>
    543c:	85aa                	mv	a1,a0
    543e:	0f455163          	bge	a0,s4,5520 <main+0x17c>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5442:	8652                	mv	a2,s4
    5444:	00003517          	auipc	a0,0x3
    5448:	c5450513          	addi	a0,a0,-940 # 8098 <malloc+0x2402>
    544c:	00000097          	auipc	ra,0x0
    5450:	78c080e7          	jalr	1932(ra) # 5bd8 <printf>
    exit(1);
    5454:	4505                	li	a0,1
    5456:	00000097          	auipc	ra,0x0
    545a:	3f2080e7          	jalr	1010(ra) # 5848 <exit>
    545e:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5460:	00003597          	auipc	a1,0x3
    5464:	bd058593          	addi	a1,a1,-1072 # 8030 <malloc+0x239a>
    5468:	6488                	ld	a0,8(s1)
    546a:	00000097          	auipc	ra,0x0
    546e:	184080e7          	jalr	388(ra) # 55ee <strcmp>
    5472:	10050563          	beqz	a0,557c <main+0x1d8>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5476:	00003597          	auipc	a1,0x3
    547a:	ca258593          	addi	a1,a1,-862 # 8118 <malloc+0x2482>
    547e:	6488                	ld	a0,8(s1)
    5480:	00000097          	auipc	ra,0x0
    5484:	16e080e7          	jalr	366(ra) # 55ee <strcmp>
    5488:	c97d                	beqz	a0,557e <main+0x1da>
  } else if(argc == 2 && argv[1][0] != '-'){
    548a:	0084b903          	ld	s2,8(s1)
    548e:	00094703          	lbu	a4,0(s2)
    5492:	02d00793          	li	a5,45
    5496:	f4f713e3          	bne	a4,a5,53dc <main+0x38>
    printf("Usage: usertests [-c] [testname]\n");
    549a:	00003517          	auipc	a0,0x3
    549e:	b9e50513          	addi	a0,a0,-1122 # 8038 <malloc+0x23a2>
    54a2:	00000097          	auipc	ra,0x0
    54a6:	736080e7          	jalr	1846(ra) # 5bd8 <printf>
    exit(1);
    54aa:	4505                	li	a0,1
    54ac:	00000097          	auipc	ra,0x0
    54b0:	39c080e7          	jalr	924(ra) # 5848 <exit>
          exit(1);
    54b4:	4505                	li	a0,1
    54b6:	00000097          	auipc	ra,0x0
    54ba:	392080e7          	jalr	914(ra) # 5848 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    54be:	40a905bb          	subw	a1,s2,a0
    54c2:	855a                	mv	a0,s6
    54c4:	00000097          	auipc	ra,0x0
    54c8:	714080e7          	jalr	1812(ra) # 5bd8 <printf>
        if(continuous != 2)
    54cc:	09498463          	beq	s3,s4,5554 <main+0x1b0>
          exit(1);
    54d0:	4505                	li	a0,1
    54d2:	00000097          	auipc	ra,0x0
    54d6:	376080e7          	jalr	886(ra) # 5848 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    54da:	04c1                	addi	s1,s1,16
    54dc:	6488                	ld	a0,8(s1)
    54de:	c115                	beqz	a0,5502 <main+0x15e>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    54e0:	00090863          	beqz	s2,54f0 <main+0x14c>
    54e4:	85ca                	mv	a1,s2
    54e6:	00000097          	auipc	ra,0x0
    54ea:	108080e7          	jalr	264(ra) # 55ee <strcmp>
    54ee:	f575                	bnez	a0,54da <main+0x136>
      if(!run(t->f, t->s))
    54f0:	648c                	ld	a1,8(s1)
    54f2:	6088                	ld	a0,0(s1)
    54f4:	00000097          	auipc	ra,0x0
    54f8:	e12080e7          	jalr	-494(ra) # 5306 <run>
    54fc:	fd79                	bnez	a0,54da <main+0x136>
        fail = 1;
    54fe:	89d6                	mv	s3,s5
    5500:	bfe9                	j	54da <main+0x136>
  if(fail){
    5502:	f20989e3          	beqz	s3,5434 <main+0x90>
    printf("SOME TESTS FAILED\n");
    5506:	00003517          	auipc	a0,0x3
    550a:	b7a50513          	addi	a0,a0,-1158 # 8080 <malloc+0x23ea>
    550e:	00000097          	auipc	ra,0x0
    5512:	6ca080e7          	jalr	1738(ra) # 5bd8 <printf>
    exit(1);
    5516:	4505                	li	a0,1
    5518:	00000097          	auipc	ra,0x0
    551c:	330080e7          	jalr	816(ra) # 5848 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5520:	00003517          	auipc	a0,0x3
    5524:	ba850513          	addi	a0,a0,-1112 # 80c8 <malloc+0x2432>
    5528:	00000097          	auipc	ra,0x0
    552c:	6b0080e7          	jalr	1712(ra) # 5bd8 <printf>
    exit(0);
    5530:	4501                	li	a0,0
    5532:	00000097          	auipc	ra,0x0
    5536:	316080e7          	jalr	790(ra) # 5848 <exit>
        printf("SOME TESTS FAILED\n");
    553a:	8556                	mv	a0,s5
    553c:	00000097          	auipc	ra,0x0
    5540:	69c080e7          	jalr	1692(ra) # 5bd8 <printf>
        if(continuous != 2)
    5544:	f74998e3          	bne	s3,s4,54b4 <main+0x110>
      int free1 = countfree();
    5548:	00000097          	auipc	ra,0x0
    554c:	c8c080e7          	jalr	-884(ra) # 51d4 <countfree>
      if(free1 < free0){
    5550:	f72547e3          	blt	a0,s2,54be <main+0x11a>
      int free0 = countfree();
    5554:	00000097          	auipc	ra,0x0
    5558:	c80080e7          	jalr	-896(ra) # 51d4 <countfree>
    555c:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    555e:	c0843583          	ld	a1,-1016(s0)
    5562:	d1fd                	beqz	a1,5548 <main+0x1a4>
    5564:	c0040493          	addi	s1,s0,-1024
        if(!run(t->f, t->s)){
    5568:	6088                	ld	a0,0(s1)
    556a:	00000097          	auipc	ra,0x0
    556e:	d9c080e7          	jalr	-612(ra) # 5306 <run>
    5572:	d561                	beqz	a0,553a <main+0x196>
      for (struct test *t = tests; t->s != 0; t++) {
    5574:	04c1                	addi	s1,s1,16
    5576:	648c                	ld	a1,8(s1)
    5578:	f9e5                	bnez	a1,5568 <main+0x1c4>
    557a:	b7f9                	j	5548 <main+0x1a4>
    continuous = 1;
    557c:	4985                	li	s3,1
  } tests[] = {
    557e:	00003797          	auipc	a5,0x3
    5582:	bc278793          	addi	a5,a5,-1086 # 8140 <malloc+0x24aa>
    5586:	c0040713          	addi	a4,s0,-1024
    558a:	00003817          	auipc	a6,0x3
    558e:	f7680813          	addi	a6,a6,-138 # 8500 <malloc+0x286a>
    5592:	6388                	ld	a0,0(a5)
    5594:	678c                	ld	a1,8(a5)
    5596:	6b90                	ld	a2,16(a5)
    5598:	6f94                	ld	a3,24(a5)
    559a:	e308                	sd	a0,0(a4)
    559c:	e70c                	sd	a1,8(a4)
    559e:	eb10                	sd	a2,16(a4)
    55a0:	ef14                	sd	a3,24(a4)
    55a2:	02078793          	addi	a5,a5,32
    55a6:	02070713          	addi	a4,a4,32
    55aa:	ff0794e3          	bne	a5,a6,5592 <main+0x1ee>
    printf("continuous usertests starting\n");
    55ae:	00003517          	auipc	a0,0x3
    55b2:	b4a50513          	addi	a0,a0,-1206 # 80f8 <malloc+0x2462>
    55b6:	00000097          	auipc	ra,0x0
    55ba:	622080e7          	jalr	1570(ra) # 5bd8 <printf>
        printf("SOME TESTS FAILED\n");
    55be:	00003a97          	auipc	s5,0x3
    55c2:	ac2a8a93          	addi	s5,s5,-1342 # 8080 <malloc+0x23ea>
        if(continuous != 2)
    55c6:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    55c8:	00003b17          	auipc	s6,0x3
    55cc:	a98b0b13          	addi	s6,s6,-1384 # 8060 <malloc+0x23ca>
    55d0:	b751                	j	5554 <main+0x1b0>

00000000000055d2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    55d2:	1141                	addi	sp,sp,-16
    55d4:	e422                	sd	s0,8(sp)
    55d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    55d8:	87aa                	mv	a5,a0
    55da:	0585                	addi	a1,a1,1
    55dc:	0785                	addi	a5,a5,1
    55de:	fff5c703          	lbu	a4,-1(a1)
    55e2:	fee78fa3          	sb	a4,-1(a5)
    55e6:	fb75                	bnez	a4,55da <strcpy+0x8>
    ;
  return os;
}
    55e8:	6422                	ld	s0,8(sp)
    55ea:	0141                	addi	sp,sp,16
    55ec:	8082                	ret

00000000000055ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
    55ee:	1141                	addi	sp,sp,-16
    55f0:	e422                	sd	s0,8(sp)
    55f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    55f4:	00054783          	lbu	a5,0(a0)
    55f8:	cb91                	beqz	a5,560c <strcmp+0x1e>
    55fa:	0005c703          	lbu	a4,0(a1)
    55fe:	00f71763          	bne	a4,a5,560c <strcmp+0x1e>
    p++, q++;
    5602:	0505                	addi	a0,a0,1
    5604:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5606:	00054783          	lbu	a5,0(a0)
    560a:	fbe5                	bnez	a5,55fa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    560c:	0005c503          	lbu	a0,0(a1)
}
    5610:	40a7853b          	subw	a0,a5,a0
    5614:	6422                	ld	s0,8(sp)
    5616:	0141                	addi	sp,sp,16
    5618:	8082                	ret

000000000000561a <strlen>:

uint
strlen(const char *s)
{
    561a:	1141                	addi	sp,sp,-16
    561c:	e422                	sd	s0,8(sp)
    561e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5620:	00054783          	lbu	a5,0(a0)
    5624:	cf91                	beqz	a5,5640 <strlen+0x26>
    5626:	0505                	addi	a0,a0,1
    5628:	87aa                	mv	a5,a0
    562a:	4685                	li	a3,1
    562c:	9e89                	subw	a3,a3,a0
    562e:	00f6853b          	addw	a0,a3,a5
    5632:	0785                	addi	a5,a5,1
    5634:	fff7c703          	lbu	a4,-1(a5)
    5638:	fb7d                	bnez	a4,562e <strlen+0x14>
    ;
  return n;
}
    563a:	6422                	ld	s0,8(sp)
    563c:	0141                	addi	sp,sp,16
    563e:	8082                	ret
  for(n = 0; s[n]; n++)
    5640:	4501                	li	a0,0
    5642:	bfe5                	j	563a <strlen+0x20>

0000000000005644 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5644:	1141                	addi	sp,sp,-16
    5646:	e422                	sd	s0,8(sp)
    5648:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    564a:	ce09                	beqz	a2,5664 <memset+0x20>
    564c:	87aa                	mv	a5,a0
    564e:	fff6071b          	addiw	a4,a2,-1
    5652:	1702                	slli	a4,a4,0x20
    5654:	9301                	srli	a4,a4,0x20
    5656:	0705                	addi	a4,a4,1
    5658:	972a                	add	a4,a4,a0
    cdst[i] = c;
    565a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    565e:	0785                	addi	a5,a5,1
    5660:	fee79de3          	bne	a5,a4,565a <memset+0x16>
  }
  return dst;
}
    5664:	6422                	ld	s0,8(sp)
    5666:	0141                	addi	sp,sp,16
    5668:	8082                	ret

000000000000566a <strchr>:

char*
strchr(const char *s, char c)
{
    566a:	1141                	addi	sp,sp,-16
    566c:	e422                	sd	s0,8(sp)
    566e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5670:	00054783          	lbu	a5,0(a0)
    5674:	cb99                	beqz	a5,568a <strchr+0x20>
    if(*s == c)
    5676:	00f58763          	beq	a1,a5,5684 <strchr+0x1a>
  for(; *s; s++)
    567a:	0505                	addi	a0,a0,1
    567c:	00054783          	lbu	a5,0(a0)
    5680:	fbfd                	bnez	a5,5676 <strchr+0xc>
      return (char*)s;
  return 0;
    5682:	4501                	li	a0,0
}
    5684:	6422                	ld	s0,8(sp)
    5686:	0141                	addi	sp,sp,16
    5688:	8082                	ret
  return 0;
    568a:	4501                	li	a0,0
    568c:	bfe5                	j	5684 <strchr+0x1a>

000000000000568e <gets>:

char*
gets(char *buf, int max)
{
    568e:	711d                	addi	sp,sp,-96
    5690:	ec86                	sd	ra,88(sp)
    5692:	e8a2                	sd	s0,80(sp)
    5694:	e4a6                	sd	s1,72(sp)
    5696:	e0ca                	sd	s2,64(sp)
    5698:	fc4e                	sd	s3,56(sp)
    569a:	f852                	sd	s4,48(sp)
    569c:	f456                	sd	s5,40(sp)
    569e:	f05a                	sd	s6,32(sp)
    56a0:	ec5e                	sd	s7,24(sp)
    56a2:	1080                	addi	s0,sp,96
    56a4:	8baa                	mv	s7,a0
    56a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    56a8:	892a                	mv	s2,a0
    56aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    56ac:	4aa9                	li	s5,10
    56ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    56b0:	89a6                	mv	s3,s1
    56b2:	2485                	addiw	s1,s1,1
    56b4:	0344d863          	bge	s1,s4,56e4 <gets+0x56>
    cc = read(0, &c, 1);
    56b8:	4605                	li	a2,1
    56ba:	faf40593          	addi	a1,s0,-81
    56be:	4501                	li	a0,0
    56c0:	00000097          	auipc	ra,0x0
    56c4:	1a0080e7          	jalr	416(ra) # 5860 <read>
    if(cc < 1)
    56c8:	00a05e63          	blez	a0,56e4 <gets+0x56>
    buf[i++] = c;
    56cc:	faf44783          	lbu	a5,-81(s0)
    56d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    56d4:	01578763          	beq	a5,s5,56e2 <gets+0x54>
    56d8:	0905                	addi	s2,s2,1
    56da:	fd679be3          	bne	a5,s6,56b0 <gets+0x22>
  for(i=0; i+1 < max; ){
    56de:	89a6                	mv	s3,s1
    56e0:	a011                	j	56e4 <gets+0x56>
    56e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    56e4:	99de                	add	s3,s3,s7
    56e6:	00098023          	sb	zero,0(s3)
  return buf;
}
    56ea:	855e                	mv	a0,s7
    56ec:	60e6                	ld	ra,88(sp)
    56ee:	6446                	ld	s0,80(sp)
    56f0:	64a6                	ld	s1,72(sp)
    56f2:	6906                	ld	s2,64(sp)
    56f4:	79e2                	ld	s3,56(sp)
    56f6:	7a42                	ld	s4,48(sp)
    56f8:	7aa2                	ld	s5,40(sp)
    56fa:	7b02                	ld	s6,32(sp)
    56fc:	6be2                	ld	s7,24(sp)
    56fe:	6125                	addi	sp,sp,96
    5700:	8082                	ret

0000000000005702 <stat>:

int
stat(const char *n, struct stat *st)
{
    5702:	1101                	addi	sp,sp,-32
    5704:	ec06                	sd	ra,24(sp)
    5706:	e822                	sd	s0,16(sp)
    5708:	e426                	sd	s1,8(sp)
    570a:	e04a                	sd	s2,0(sp)
    570c:	1000                	addi	s0,sp,32
    570e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5710:	4581                	li	a1,0
    5712:	00000097          	auipc	ra,0x0
    5716:	176080e7          	jalr	374(ra) # 5888 <open>
  if(fd < 0)
    571a:	02054563          	bltz	a0,5744 <stat+0x42>
    571e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5720:	85ca                	mv	a1,s2
    5722:	00000097          	auipc	ra,0x0
    5726:	17e080e7          	jalr	382(ra) # 58a0 <fstat>
    572a:	892a                	mv	s2,a0
  close(fd);
    572c:	8526                	mv	a0,s1
    572e:	00000097          	auipc	ra,0x0
    5732:	142080e7          	jalr	322(ra) # 5870 <close>
  return r;
}
    5736:	854a                	mv	a0,s2
    5738:	60e2                	ld	ra,24(sp)
    573a:	6442                	ld	s0,16(sp)
    573c:	64a2                	ld	s1,8(sp)
    573e:	6902                	ld	s2,0(sp)
    5740:	6105                	addi	sp,sp,32
    5742:	8082                	ret
    return -1;
    5744:	597d                	li	s2,-1
    5746:	bfc5                	j	5736 <stat+0x34>

0000000000005748 <atoi>:

int
atoi(const char *s)
{
    5748:	1141                	addi	sp,sp,-16
    574a:	e422                	sd	s0,8(sp)
    574c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    574e:	00054603          	lbu	a2,0(a0)
    5752:	fd06079b          	addiw	a5,a2,-48
    5756:	0ff7f793          	andi	a5,a5,255
    575a:	4725                	li	a4,9
    575c:	02f76963          	bltu	a4,a5,578e <atoi+0x46>
    5760:	86aa                	mv	a3,a0
  n = 0;
    5762:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5764:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5766:	0685                	addi	a3,a3,1
    5768:	0025179b          	slliw	a5,a0,0x2
    576c:	9fa9                	addw	a5,a5,a0
    576e:	0017979b          	slliw	a5,a5,0x1
    5772:	9fb1                	addw	a5,a5,a2
    5774:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5778:	0006c603          	lbu	a2,0(a3) # 1000 <pgbug+0x30>
    577c:	fd06071b          	addiw	a4,a2,-48
    5780:	0ff77713          	andi	a4,a4,255
    5784:	fee5f1e3          	bgeu	a1,a4,5766 <atoi+0x1e>
  return n;
}
    5788:	6422                	ld	s0,8(sp)
    578a:	0141                	addi	sp,sp,16
    578c:	8082                	ret
  n = 0;
    578e:	4501                	li	a0,0
    5790:	bfe5                	j	5788 <atoi+0x40>

0000000000005792 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5792:	1141                	addi	sp,sp,-16
    5794:	e422                	sd	s0,8(sp)
    5796:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5798:	02b57663          	bgeu	a0,a1,57c4 <memmove+0x32>
    while(n-- > 0)
    579c:	02c05163          	blez	a2,57be <memmove+0x2c>
    57a0:	fff6079b          	addiw	a5,a2,-1
    57a4:	1782                	slli	a5,a5,0x20
    57a6:	9381                	srli	a5,a5,0x20
    57a8:	0785                	addi	a5,a5,1
    57aa:	97aa                	add	a5,a5,a0
  dst = vdst;
    57ac:	872a                	mv	a4,a0
      *dst++ = *src++;
    57ae:	0585                	addi	a1,a1,1
    57b0:	0705                	addi	a4,a4,1
    57b2:	fff5c683          	lbu	a3,-1(a1)
    57b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    57ba:	fee79ae3          	bne	a5,a4,57ae <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    57be:	6422                	ld	s0,8(sp)
    57c0:	0141                	addi	sp,sp,16
    57c2:	8082                	ret
    dst += n;
    57c4:	00c50733          	add	a4,a0,a2
    src += n;
    57c8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    57ca:	fec05ae3          	blez	a2,57be <memmove+0x2c>
    57ce:	fff6079b          	addiw	a5,a2,-1
    57d2:	1782                	slli	a5,a5,0x20
    57d4:	9381                	srli	a5,a5,0x20
    57d6:	fff7c793          	not	a5,a5
    57da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    57dc:	15fd                	addi	a1,a1,-1
    57de:	177d                	addi	a4,a4,-1
    57e0:	0005c683          	lbu	a3,0(a1)
    57e4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    57e8:	fee79ae3          	bne	a5,a4,57dc <memmove+0x4a>
    57ec:	bfc9                	j	57be <memmove+0x2c>

00000000000057ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    57ee:	1141                	addi	sp,sp,-16
    57f0:	e422                	sd	s0,8(sp)
    57f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    57f4:	ca05                	beqz	a2,5824 <memcmp+0x36>
    57f6:	fff6069b          	addiw	a3,a2,-1
    57fa:	1682                	slli	a3,a3,0x20
    57fc:	9281                	srli	a3,a3,0x20
    57fe:	0685                	addi	a3,a3,1
    5800:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5802:	00054783          	lbu	a5,0(a0)
    5806:	0005c703          	lbu	a4,0(a1)
    580a:	00e79863          	bne	a5,a4,581a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    580e:	0505                	addi	a0,a0,1
    p2++;
    5810:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5812:	fed518e3          	bne	a0,a3,5802 <memcmp+0x14>
  }
  return 0;
    5816:	4501                	li	a0,0
    5818:	a019                	j	581e <memcmp+0x30>
      return *p1 - *p2;
    581a:	40e7853b          	subw	a0,a5,a4
}
    581e:	6422                	ld	s0,8(sp)
    5820:	0141                	addi	sp,sp,16
    5822:	8082                	ret
  return 0;
    5824:	4501                	li	a0,0
    5826:	bfe5                	j	581e <memcmp+0x30>

0000000000005828 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5828:	1141                	addi	sp,sp,-16
    582a:	e406                	sd	ra,8(sp)
    582c:	e022                	sd	s0,0(sp)
    582e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5830:	00000097          	auipc	ra,0x0
    5834:	f62080e7          	jalr	-158(ra) # 5792 <memmove>
}
    5838:	60a2                	ld	ra,8(sp)
    583a:	6402                	ld	s0,0(sp)
    583c:	0141                	addi	sp,sp,16
    583e:	8082                	ret

0000000000005840 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5840:	4885                	li	a7,1
 ecall
    5842:	00000073          	ecall
 ret
    5846:	8082                	ret

0000000000005848 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5848:	4889                	li	a7,2
 ecall
    584a:	00000073          	ecall
 ret
    584e:	8082                	ret

0000000000005850 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5850:	488d                	li	a7,3
 ecall
    5852:	00000073          	ecall
 ret
    5856:	8082                	ret

0000000000005858 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5858:	4891                	li	a7,4
 ecall
    585a:	00000073          	ecall
 ret
    585e:	8082                	ret

0000000000005860 <read>:
.global read
read:
 li a7, SYS_read
    5860:	4895                	li	a7,5
 ecall
    5862:	00000073          	ecall
 ret
    5866:	8082                	ret

0000000000005868 <write>:
.global write
write:
 li a7, SYS_write
    5868:	48c1                	li	a7,16
 ecall
    586a:	00000073          	ecall
 ret
    586e:	8082                	ret

0000000000005870 <close>:
.global close
close:
 li a7, SYS_close
    5870:	48d5                	li	a7,21
 ecall
    5872:	00000073          	ecall
 ret
    5876:	8082                	ret

0000000000005878 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5878:	4899                	li	a7,6
 ecall
    587a:	00000073          	ecall
 ret
    587e:	8082                	ret

0000000000005880 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5880:	489d                	li	a7,7
 ecall
    5882:	00000073          	ecall
 ret
    5886:	8082                	ret

0000000000005888 <open>:
.global open
open:
 li a7, SYS_open
    5888:	48bd                	li	a7,15
 ecall
    588a:	00000073          	ecall
 ret
    588e:	8082                	ret

0000000000005890 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5890:	48c5                	li	a7,17
 ecall
    5892:	00000073          	ecall
 ret
    5896:	8082                	ret

0000000000005898 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5898:	48c9                	li	a7,18
 ecall
    589a:	00000073          	ecall
 ret
    589e:	8082                	ret

00000000000058a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    58a0:	48a1                	li	a7,8
 ecall
    58a2:	00000073          	ecall
 ret
    58a6:	8082                	ret

00000000000058a8 <link>:
.global link
link:
 li a7, SYS_link
    58a8:	48cd                	li	a7,19
 ecall
    58aa:	00000073          	ecall
 ret
    58ae:	8082                	ret

00000000000058b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    58b0:	48d1                	li	a7,20
 ecall
    58b2:	00000073          	ecall
 ret
    58b6:	8082                	ret

00000000000058b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    58b8:	48a5                	li	a7,9
 ecall
    58ba:	00000073          	ecall
 ret
    58be:	8082                	ret

00000000000058c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
    58c0:	48a9                	li	a7,10
 ecall
    58c2:	00000073          	ecall
 ret
    58c6:	8082                	ret

00000000000058c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    58c8:	48ad                	li	a7,11
 ecall
    58ca:	00000073          	ecall
 ret
    58ce:	8082                	ret

00000000000058d0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    58d0:	48b1                	li	a7,12
 ecall
    58d2:	00000073          	ecall
 ret
    58d6:	8082                	ret

00000000000058d8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    58d8:	48b5                	li	a7,13
 ecall
    58da:	00000073          	ecall
 ret
    58de:	8082                	ret

00000000000058e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    58e0:	48b9                	li	a7,14
 ecall
    58e2:	00000073          	ecall
 ret
    58e6:	8082                	ret

00000000000058e8 <set_cpu>:
.global set_cpu
set_cpu:
 li a7, SYS_set_cpu
    58e8:	48d9                	li	a7,22
 ecall
    58ea:	00000073          	ecall
 ret
    58ee:	8082                	ret

00000000000058f0 <get_cpu>:
.global get_cpu
get_cpu:
 li a7, SYS_get_cpu
    58f0:	48dd                	li	a7,23
 ecall
    58f2:	00000073          	ecall
 ret
    58f6:	8082                	ret

00000000000058f8 <cpu_process_count>:
.global cpu_process_count
cpu_process_count:
 li a7, SYS_cpu_process_count
    58f8:	48e1                	li	a7,24
 ecall
    58fa:	00000073          	ecall
 ret
    58fe:	8082                	ret

0000000000005900 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5900:	1101                	addi	sp,sp,-32
    5902:	ec06                	sd	ra,24(sp)
    5904:	e822                	sd	s0,16(sp)
    5906:	1000                	addi	s0,sp,32
    5908:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    590c:	4605                	li	a2,1
    590e:	fef40593          	addi	a1,s0,-17
    5912:	00000097          	auipc	ra,0x0
    5916:	f56080e7          	jalr	-170(ra) # 5868 <write>
}
    591a:	60e2                	ld	ra,24(sp)
    591c:	6442                	ld	s0,16(sp)
    591e:	6105                	addi	sp,sp,32
    5920:	8082                	ret

0000000000005922 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5922:	7139                	addi	sp,sp,-64
    5924:	fc06                	sd	ra,56(sp)
    5926:	f822                	sd	s0,48(sp)
    5928:	f426                	sd	s1,40(sp)
    592a:	f04a                	sd	s2,32(sp)
    592c:	ec4e                	sd	s3,24(sp)
    592e:	0080                	addi	s0,sp,64
    5930:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5932:	c299                	beqz	a3,5938 <printint+0x16>
    5934:	0805c863          	bltz	a1,59c4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5938:	2581                	sext.w	a1,a1
  neg = 0;
    593a:	4881                	li	a7,0
    593c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5940:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5942:	2601                	sext.w	a2,a2
    5944:	00003517          	auipc	a0,0x3
    5948:	bc450513          	addi	a0,a0,-1084 # 8508 <digits>
    594c:	883a                	mv	a6,a4
    594e:	2705                	addiw	a4,a4,1
    5950:	02c5f7bb          	remuw	a5,a1,a2
    5954:	1782                	slli	a5,a5,0x20
    5956:	9381                	srli	a5,a5,0x20
    5958:	97aa                	add	a5,a5,a0
    595a:	0007c783          	lbu	a5,0(a5)
    595e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5962:	0005879b          	sext.w	a5,a1
    5966:	02c5d5bb          	divuw	a1,a1,a2
    596a:	0685                	addi	a3,a3,1
    596c:	fec7f0e3          	bgeu	a5,a2,594c <printint+0x2a>
  if(neg)
    5970:	00088b63          	beqz	a7,5986 <printint+0x64>
    buf[i++] = '-';
    5974:	fd040793          	addi	a5,s0,-48
    5978:	973e                	add	a4,a4,a5
    597a:	02d00793          	li	a5,45
    597e:	fef70823          	sb	a5,-16(a4)
    5982:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5986:	02e05863          	blez	a4,59b6 <printint+0x94>
    598a:	fc040793          	addi	a5,s0,-64
    598e:	00e78933          	add	s2,a5,a4
    5992:	fff78993          	addi	s3,a5,-1
    5996:	99ba                	add	s3,s3,a4
    5998:	377d                	addiw	a4,a4,-1
    599a:	1702                	slli	a4,a4,0x20
    599c:	9301                	srli	a4,a4,0x20
    599e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    59a2:	fff94583          	lbu	a1,-1(s2)
    59a6:	8526                	mv	a0,s1
    59a8:	00000097          	auipc	ra,0x0
    59ac:	f58080e7          	jalr	-168(ra) # 5900 <putc>
  while(--i >= 0)
    59b0:	197d                	addi	s2,s2,-1
    59b2:	ff3918e3          	bne	s2,s3,59a2 <printint+0x80>
}
    59b6:	70e2                	ld	ra,56(sp)
    59b8:	7442                	ld	s0,48(sp)
    59ba:	74a2                	ld	s1,40(sp)
    59bc:	7902                	ld	s2,32(sp)
    59be:	69e2                	ld	s3,24(sp)
    59c0:	6121                	addi	sp,sp,64
    59c2:	8082                	ret
    x = -xx;
    59c4:	40b005bb          	negw	a1,a1
    neg = 1;
    59c8:	4885                	li	a7,1
    x = -xx;
    59ca:	bf8d                	j	593c <printint+0x1a>

00000000000059cc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    59cc:	7119                	addi	sp,sp,-128
    59ce:	fc86                	sd	ra,120(sp)
    59d0:	f8a2                	sd	s0,112(sp)
    59d2:	f4a6                	sd	s1,104(sp)
    59d4:	f0ca                	sd	s2,96(sp)
    59d6:	ecce                	sd	s3,88(sp)
    59d8:	e8d2                	sd	s4,80(sp)
    59da:	e4d6                	sd	s5,72(sp)
    59dc:	e0da                	sd	s6,64(sp)
    59de:	fc5e                	sd	s7,56(sp)
    59e0:	f862                	sd	s8,48(sp)
    59e2:	f466                	sd	s9,40(sp)
    59e4:	f06a                	sd	s10,32(sp)
    59e6:	ec6e                	sd	s11,24(sp)
    59e8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    59ea:	0005c903          	lbu	s2,0(a1)
    59ee:	18090f63          	beqz	s2,5b8c <vprintf+0x1c0>
    59f2:	8aaa                	mv	s5,a0
    59f4:	8b32                	mv	s6,a2
    59f6:	00158493          	addi	s1,a1,1
  state = 0;
    59fa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    59fc:	02500a13          	li	s4,37
      if(c == 'd'){
    5a00:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5a04:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5a08:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5a0c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5a10:	00003b97          	auipc	s7,0x3
    5a14:	af8b8b93          	addi	s7,s7,-1288 # 8508 <digits>
    5a18:	a839                	j	5a36 <vprintf+0x6a>
        putc(fd, c);
    5a1a:	85ca                	mv	a1,s2
    5a1c:	8556                	mv	a0,s5
    5a1e:	00000097          	auipc	ra,0x0
    5a22:	ee2080e7          	jalr	-286(ra) # 5900 <putc>
    5a26:	a019                	j	5a2c <vprintf+0x60>
    } else if(state == '%'){
    5a28:	01498f63          	beq	s3,s4,5a46 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5a2c:	0485                	addi	s1,s1,1
    5a2e:	fff4c903          	lbu	s2,-1(s1)
    5a32:	14090d63          	beqz	s2,5b8c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5a36:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5a3a:	fe0997e3          	bnez	s3,5a28 <vprintf+0x5c>
      if(c == '%'){
    5a3e:	fd479ee3          	bne	a5,s4,5a1a <vprintf+0x4e>
        state = '%';
    5a42:	89be                	mv	s3,a5
    5a44:	b7e5                	j	5a2c <vprintf+0x60>
      if(c == 'd'){
    5a46:	05878063          	beq	a5,s8,5a86 <vprintf+0xba>
      } else if(c == 'l') {
    5a4a:	05978c63          	beq	a5,s9,5aa2 <vprintf+0xd6>
      } else if(c == 'x') {
    5a4e:	07a78863          	beq	a5,s10,5abe <vprintf+0xf2>
      } else if(c == 'p') {
    5a52:	09b78463          	beq	a5,s11,5ada <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5a56:	07300713          	li	a4,115
    5a5a:	0ce78663          	beq	a5,a4,5b26 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5a5e:	06300713          	li	a4,99
    5a62:	0ee78e63          	beq	a5,a4,5b5e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5a66:	11478863          	beq	a5,s4,5b76 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5a6a:	85d2                	mv	a1,s4
    5a6c:	8556                	mv	a0,s5
    5a6e:	00000097          	auipc	ra,0x0
    5a72:	e92080e7          	jalr	-366(ra) # 5900 <putc>
        putc(fd, c);
    5a76:	85ca                	mv	a1,s2
    5a78:	8556                	mv	a0,s5
    5a7a:	00000097          	auipc	ra,0x0
    5a7e:	e86080e7          	jalr	-378(ra) # 5900 <putc>
      }
      state = 0;
    5a82:	4981                	li	s3,0
    5a84:	b765                	j	5a2c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5a86:	008b0913          	addi	s2,s6,8
    5a8a:	4685                	li	a3,1
    5a8c:	4629                	li	a2,10
    5a8e:	000b2583          	lw	a1,0(s6)
    5a92:	8556                	mv	a0,s5
    5a94:	00000097          	auipc	ra,0x0
    5a98:	e8e080e7          	jalr	-370(ra) # 5922 <printint>
    5a9c:	8b4a                	mv	s6,s2
      state = 0;
    5a9e:	4981                	li	s3,0
    5aa0:	b771                	j	5a2c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5aa2:	008b0913          	addi	s2,s6,8
    5aa6:	4681                	li	a3,0
    5aa8:	4629                	li	a2,10
    5aaa:	000b2583          	lw	a1,0(s6)
    5aae:	8556                	mv	a0,s5
    5ab0:	00000097          	auipc	ra,0x0
    5ab4:	e72080e7          	jalr	-398(ra) # 5922 <printint>
    5ab8:	8b4a                	mv	s6,s2
      state = 0;
    5aba:	4981                	li	s3,0
    5abc:	bf85                	j	5a2c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5abe:	008b0913          	addi	s2,s6,8
    5ac2:	4681                	li	a3,0
    5ac4:	4641                	li	a2,16
    5ac6:	000b2583          	lw	a1,0(s6)
    5aca:	8556                	mv	a0,s5
    5acc:	00000097          	auipc	ra,0x0
    5ad0:	e56080e7          	jalr	-426(ra) # 5922 <printint>
    5ad4:	8b4a                	mv	s6,s2
      state = 0;
    5ad6:	4981                	li	s3,0
    5ad8:	bf91                	j	5a2c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5ada:	008b0793          	addi	a5,s6,8
    5ade:	f8f43423          	sd	a5,-120(s0)
    5ae2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5ae6:	03000593          	li	a1,48
    5aea:	8556                	mv	a0,s5
    5aec:	00000097          	auipc	ra,0x0
    5af0:	e14080e7          	jalr	-492(ra) # 5900 <putc>
  putc(fd, 'x');
    5af4:	85ea                	mv	a1,s10
    5af6:	8556                	mv	a0,s5
    5af8:	00000097          	auipc	ra,0x0
    5afc:	e08080e7          	jalr	-504(ra) # 5900 <putc>
    5b00:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5b02:	03c9d793          	srli	a5,s3,0x3c
    5b06:	97de                	add	a5,a5,s7
    5b08:	0007c583          	lbu	a1,0(a5)
    5b0c:	8556                	mv	a0,s5
    5b0e:	00000097          	auipc	ra,0x0
    5b12:	df2080e7          	jalr	-526(ra) # 5900 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5b16:	0992                	slli	s3,s3,0x4
    5b18:	397d                	addiw	s2,s2,-1
    5b1a:	fe0914e3          	bnez	s2,5b02 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5b1e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5b22:	4981                	li	s3,0
    5b24:	b721                	j	5a2c <vprintf+0x60>
        s = va_arg(ap, char*);
    5b26:	008b0993          	addi	s3,s6,8
    5b2a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5b2e:	02090163          	beqz	s2,5b50 <vprintf+0x184>
        while(*s != 0){
    5b32:	00094583          	lbu	a1,0(s2)
    5b36:	c9a1                	beqz	a1,5b86 <vprintf+0x1ba>
          putc(fd, *s);
    5b38:	8556                	mv	a0,s5
    5b3a:	00000097          	auipc	ra,0x0
    5b3e:	dc6080e7          	jalr	-570(ra) # 5900 <putc>
          s++;
    5b42:	0905                	addi	s2,s2,1
        while(*s != 0){
    5b44:	00094583          	lbu	a1,0(s2)
    5b48:	f9e5                	bnez	a1,5b38 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5b4a:	8b4e                	mv	s6,s3
      state = 0;
    5b4c:	4981                	li	s3,0
    5b4e:	bdf9                	j	5a2c <vprintf+0x60>
          s = "(null)";
    5b50:	00003917          	auipc	s2,0x3
    5b54:	9b090913          	addi	s2,s2,-1616 # 8500 <malloc+0x286a>
        while(*s != 0){
    5b58:	02800593          	li	a1,40
    5b5c:	bff1                	j	5b38 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5b5e:	008b0913          	addi	s2,s6,8
    5b62:	000b4583          	lbu	a1,0(s6)
    5b66:	8556                	mv	a0,s5
    5b68:	00000097          	auipc	ra,0x0
    5b6c:	d98080e7          	jalr	-616(ra) # 5900 <putc>
    5b70:	8b4a                	mv	s6,s2
      state = 0;
    5b72:	4981                	li	s3,0
    5b74:	bd65                	j	5a2c <vprintf+0x60>
        putc(fd, c);
    5b76:	85d2                	mv	a1,s4
    5b78:	8556                	mv	a0,s5
    5b7a:	00000097          	auipc	ra,0x0
    5b7e:	d86080e7          	jalr	-634(ra) # 5900 <putc>
      state = 0;
    5b82:	4981                	li	s3,0
    5b84:	b565                	j	5a2c <vprintf+0x60>
        s = va_arg(ap, char*);
    5b86:	8b4e                	mv	s6,s3
      state = 0;
    5b88:	4981                	li	s3,0
    5b8a:	b54d                	j	5a2c <vprintf+0x60>
    }
  }
}
    5b8c:	70e6                	ld	ra,120(sp)
    5b8e:	7446                	ld	s0,112(sp)
    5b90:	74a6                	ld	s1,104(sp)
    5b92:	7906                	ld	s2,96(sp)
    5b94:	69e6                	ld	s3,88(sp)
    5b96:	6a46                	ld	s4,80(sp)
    5b98:	6aa6                	ld	s5,72(sp)
    5b9a:	6b06                	ld	s6,64(sp)
    5b9c:	7be2                	ld	s7,56(sp)
    5b9e:	7c42                	ld	s8,48(sp)
    5ba0:	7ca2                	ld	s9,40(sp)
    5ba2:	7d02                	ld	s10,32(sp)
    5ba4:	6de2                	ld	s11,24(sp)
    5ba6:	6109                	addi	sp,sp,128
    5ba8:	8082                	ret

0000000000005baa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5baa:	715d                	addi	sp,sp,-80
    5bac:	ec06                	sd	ra,24(sp)
    5bae:	e822                	sd	s0,16(sp)
    5bb0:	1000                	addi	s0,sp,32
    5bb2:	e010                	sd	a2,0(s0)
    5bb4:	e414                	sd	a3,8(s0)
    5bb6:	e818                	sd	a4,16(s0)
    5bb8:	ec1c                	sd	a5,24(s0)
    5bba:	03043023          	sd	a6,32(s0)
    5bbe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5bc2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5bc6:	8622                	mv	a2,s0
    5bc8:	00000097          	auipc	ra,0x0
    5bcc:	e04080e7          	jalr	-508(ra) # 59cc <vprintf>
}
    5bd0:	60e2                	ld	ra,24(sp)
    5bd2:	6442                	ld	s0,16(sp)
    5bd4:	6161                	addi	sp,sp,80
    5bd6:	8082                	ret

0000000000005bd8 <printf>:

void
printf(const char *fmt, ...)
{
    5bd8:	711d                	addi	sp,sp,-96
    5bda:	ec06                	sd	ra,24(sp)
    5bdc:	e822                	sd	s0,16(sp)
    5bde:	1000                	addi	s0,sp,32
    5be0:	e40c                	sd	a1,8(s0)
    5be2:	e810                	sd	a2,16(s0)
    5be4:	ec14                	sd	a3,24(s0)
    5be6:	f018                	sd	a4,32(s0)
    5be8:	f41c                	sd	a5,40(s0)
    5bea:	03043823          	sd	a6,48(s0)
    5bee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5bf2:	00840613          	addi	a2,s0,8
    5bf6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5bfa:	85aa                	mv	a1,a0
    5bfc:	4505                	li	a0,1
    5bfe:	00000097          	auipc	ra,0x0
    5c02:	dce080e7          	jalr	-562(ra) # 59cc <vprintf>
}
    5c06:	60e2                	ld	ra,24(sp)
    5c08:	6442                	ld	s0,16(sp)
    5c0a:	6125                	addi	sp,sp,96
    5c0c:	8082                	ret

0000000000005c0e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5c0e:	1141                	addi	sp,sp,-16
    5c10:	e422                	sd	s0,8(sp)
    5c12:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5c14:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c18:	00003797          	auipc	a5,0x3
    5c1c:	9107b783          	ld	a5,-1776(a5) # 8528 <freep>
    5c20:	a805                	j	5c50 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5c22:	4618                	lw	a4,8(a2)
    5c24:	9db9                	addw	a1,a1,a4
    5c26:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5c2a:	6398                	ld	a4,0(a5)
    5c2c:	6318                	ld	a4,0(a4)
    5c2e:	fee53823          	sd	a4,-16(a0)
    5c32:	a091                	j	5c76 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5c34:	ff852703          	lw	a4,-8(a0)
    5c38:	9e39                	addw	a2,a2,a4
    5c3a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5c3c:	ff053703          	ld	a4,-16(a0)
    5c40:	e398                	sd	a4,0(a5)
    5c42:	a099                	j	5c88 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c44:	6398                	ld	a4,0(a5)
    5c46:	00e7e463          	bltu	a5,a4,5c4e <free+0x40>
    5c4a:	00e6ea63          	bltu	a3,a4,5c5e <free+0x50>
{
    5c4e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c50:	fed7fae3          	bgeu	a5,a3,5c44 <free+0x36>
    5c54:	6398                	ld	a4,0(a5)
    5c56:	00e6e463          	bltu	a3,a4,5c5e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c5a:	fee7eae3          	bltu	a5,a4,5c4e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5c5e:	ff852583          	lw	a1,-8(a0)
    5c62:	6390                	ld	a2,0(a5)
    5c64:	02059713          	slli	a4,a1,0x20
    5c68:	9301                	srli	a4,a4,0x20
    5c6a:	0712                	slli	a4,a4,0x4
    5c6c:	9736                	add	a4,a4,a3
    5c6e:	fae60ae3          	beq	a2,a4,5c22 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5c72:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5c76:	4790                	lw	a2,8(a5)
    5c78:	02061713          	slli	a4,a2,0x20
    5c7c:	9301                	srli	a4,a4,0x20
    5c7e:	0712                	slli	a4,a4,0x4
    5c80:	973e                	add	a4,a4,a5
    5c82:	fae689e3          	beq	a3,a4,5c34 <free+0x26>
  } else
    p->s.ptr = bp;
    5c86:	e394                	sd	a3,0(a5)
  freep = p;
    5c88:	00003717          	auipc	a4,0x3
    5c8c:	8af73023          	sd	a5,-1888(a4) # 8528 <freep>
}
    5c90:	6422                	ld	s0,8(sp)
    5c92:	0141                	addi	sp,sp,16
    5c94:	8082                	ret

0000000000005c96 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5c96:	7139                	addi	sp,sp,-64
    5c98:	fc06                	sd	ra,56(sp)
    5c9a:	f822                	sd	s0,48(sp)
    5c9c:	f426                	sd	s1,40(sp)
    5c9e:	f04a                	sd	s2,32(sp)
    5ca0:	ec4e                	sd	s3,24(sp)
    5ca2:	e852                	sd	s4,16(sp)
    5ca4:	e456                	sd	s5,8(sp)
    5ca6:	e05a                	sd	s6,0(sp)
    5ca8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5caa:	02051493          	slli	s1,a0,0x20
    5cae:	9081                	srli	s1,s1,0x20
    5cb0:	04bd                	addi	s1,s1,15
    5cb2:	8091                	srli	s1,s1,0x4
    5cb4:	0014899b          	addiw	s3,s1,1
    5cb8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5cba:	00003517          	auipc	a0,0x3
    5cbe:	86e53503          	ld	a0,-1938(a0) # 8528 <freep>
    5cc2:	c515                	beqz	a0,5cee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5cc4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5cc6:	4798                	lw	a4,8(a5)
    5cc8:	02977f63          	bgeu	a4,s1,5d06 <malloc+0x70>
    5ccc:	8a4e                	mv	s4,s3
    5cce:	0009871b          	sext.w	a4,s3
    5cd2:	6685                	lui	a3,0x1
    5cd4:	00d77363          	bgeu	a4,a3,5cda <malloc+0x44>
    5cd8:	6a05                	lui	s4,0x1
    5cda:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5cde:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5ce2:	00003917          	auipc	s2,0x3
    5ce6:	84690913          	addi	s2,s2,-1978 # 8528 <freep>
  if(p == (char*)-1)
    5cea:	5afd                	li	s5,-1
    5cec:	a88d                	j	5d5e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5cee:	00009797          	auipc	a5,0x9
    5cf2:	05a78793          	addi	a5,a5,90 # ed48 <base>
    5cf6:	00003717          	auipc	a4,0x3
    5cfa:	82f73923          	sd	a5,-1998(a4) # 8528 <freep>
    5cfe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5d00:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5d04:	b7e1                	j	5ccc <malloc+0x36>
      if(p->s.size == nunits)
    5d06:	02e48b63          	beq	s1,a4,5d3c <malloc+0xa6>
        p->s.size -= nunits;
    5d0a:	4137073b          	subw	a4,a4,s3
    5d0e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5d10:	1702                	slli	a4,a4,0x20
    5d12:	9301                	srli	a4,a4,0x20
    5d14:	0712                	slli	a4,a4,0x4
    5d16:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5d18:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5d1c:	00003717          	auipc	a4,0x3
    5d20:	80a73623          	sd	a0,-2036(a4) # 8528 <freep>
      return (void*)(p + 1);
    5d24:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5d28:	70e2                	ld	ra,56(sp)
    5d2a:	7442                	ld	s0,48(sp)
    5d2c:	74a2                	ld	s1,40(sp)
    5d2e:	7902                	ld	s2,32(sp)
    5d30:	69e2                	ld	s3,24(sp)
    5d32:	6a42                	ld	s4,16(sp)
    5d34:	6aa2                	ld	s5,8(sp)
    5d36:	6b02                	ld	s6,0(sp)
    5d38:	6121                	addi	sp,sp,64
    5d3a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5d3c:	6398                	ld	a4,0(a5)
    5d3e:	e118                	sd	a4,0(a0)
    5d40:	bff1                	j	5d1c <malloc+0x86>
  hp->s.size = nu;
    5d42:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5d46:	0541                	addi	a0,a0,16
    5d48:	00000097          	auipc	ra,0x0
    5d4c:	ec6080e7          	jalr	-314(ra) # 5c0e <free>
  return freep;
    5d50:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5d54:	d971                	beqz	a0,5d28 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5d56:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5d58:	4798                	lw	a4,8(a5)
    5d5a:	fa9776e3          	bgeu	a4,s1,5d06 <malloc+0x70>
    if(p == freep)
    5d5e:	00093703          	ld	a4,0(s2)
    5d62:	853e                	mv	a0,a5
    5d64:	fef719e3          	bne	a4,a5,5d56 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5d68:	8552                	mv	a0,s4
    5d6a:	00000097          	auipc	ra,0x0
    5d6e:	b66080e7          	jalr	-1178(ra) # 58d0 <sbrk>
  if(p == (char*)-1)
    5d72:	fd5518e3          	bne	a0,s5,5d42 <malloc+0xac>
        return 0;
    5d76:	4501                	li	a0,0
    5d78:	bf45                	j	5d28 <malloc+0x92>
