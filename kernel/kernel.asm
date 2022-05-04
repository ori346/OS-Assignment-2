
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	91013103          	ld	sp,-1776(sp) # 80008910 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	f2c78793          	addi	a5,a5,-212 # 80005f90 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de078793          	addi	a5,a5,-544 # 80000e8e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	7b6080e7          	jalr	1974(ra) # 800028e2 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78e080e7          	jalr	1934(ra) # 800008ca <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	addi	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a50080e7          	jalr	-1456(ra) # 80000be4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	addi	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	07290913          	addi	s2,s2,114 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405863          	blez	s4,80000224 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0x84>
      if(myproc()->killed){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	ba0080e7          	jalr	-1120(ra) # 80001d64 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	2ce080e7          	jalr	718(ra) # 800024a2 <sleep>
    while(cons.r == cons.w){
    800001dc:	0984a783          	lw	a5,152(s1)
    800001e0:	09c4a703          	lw	a4,156(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	08e4ac23          	sw	a4,152(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fe:	079c0663          	beq	s8,s9,8000026a <consoleread+0x106>
    cbuf = c;
    80000202:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	f8f40613          	addi	a2,s0,-113
    8000020c:	85d6                	mv	a1,s5
    8000020e:	855a                	mv	a0,s6
    80000210:	00002097          	auipc	ra,0x2
    80000214:	67c080e7          	jalr	1660(ra) # 8000288c <either_copyout>
    80000218:	01a50663          	beq	a0,s10,80000224 <consoleread+0xc0>
    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000220:	f9bc1ae3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000224:	00011517          	auipc	a0,0x11
    80000228:	f5c50513          	addi	a0,a0,-164 # 80011180 <cons>
    8000022c:	00001097          	auipc	ra,0x1
    80000230:	a6c080e7          	jalr	-1428(ra) # 80000c98 <release>

  return target - n;
    80000234:	414b853b          	subw	a0,s7,s4
    80000238:	a811                	j	8000024c <consoleread+0xe8>
        release(&cons.lock);
    8000023a:	00011517          	auipc	a0,0x11
    8000023e:	f4650513          	addi	a0,a0,-186 # 80011180 <cons>
    80000242:	00001097          	auipc	ra,0x1
    80000246:	a56080e7          	jalr	-1450(ra) # 80000c98 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
}
    8000024c:	70e6                	ld	ra,120(sp)
    8000024e:	7446                	ld	s0,112(sp)
    80000250:	74a6                	ld	s1,104(sp)
    80000252:	7906                	ld	s2,96(sp)
    80000254:	69e6                	ld	s3,88(sp)
    80000256:	6a46                	ld	s4,80(sp)
    80000258:	6aa6                	ld	s5,72(sp)
    8000025a:	6b06                	ld	s6,64(sp)
    8000025c:	7be2                	ld	s7,56(sp)
    8000025e:	7c42                	ld	s8,48(sp)
    80000260:	7ca2                	ld	s9,40(sp)
    80000262:	7d02                	ld	s10,32(sp)
    80000264:	6de2                	ld	s11,24(sp)
    80000266:	6109                	addi	sp,sp,128
    80000268:	8082                	ret
      if(n < target){
    8000026a:	000a071b          	sext.w	a4,s4
    8000026e:	fb777be3          	bgeu	a4,s7,80000224 <consoleread+0xc0>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	faf72323          	sw	a5,-90(a4) # 80011218 <cons+0x98>
    8000027a:	b76d                	j	80000224 <consoleread+0xc0>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	564080e7          	jalr	1380(ra) # 800007f0 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	552080e7          	jalr	1362(ra) # 800007f0 <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	546080e7          	jalr	1350(ra) # 800007f0 <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	53c080e7          	jalr	1340(ra) # 800007f0 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	eb450513          	addi	a0,a0,-332 # 80011180 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	910080e7          	jalr	-1776(ra) # 80000be4 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	646080e7          	jalr	1606(ra) # 80002938 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e8650513          	addi	a0,a0,-378 # 80011180 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	996080e7          	jalr	-1642(ra) # 80000c98 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	e6270713          	addi	a4,a4,-414 # 80011180 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	e3878793          	addi	a5,a5,-456 # 80011180 <cons>
    80000350:	0a07a703          	lw	a4,160(a5)
    80000354:	0017069b          	addiw	a3,a4,1
    80000358:	0006861b          	sext.w	a2,a3
    8000035c:	0ad7a023          	sw	a3,160(a5)
    80000360:	07f77713          	andi	a4,a4,127
    80000364:	97ba                	add	a5,a5,a4
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	ea27a783          	lw	a5,-350(a5) # 80011218 <cons+0x98>
    8000037e:	0807879b          	addiw	a5,a5,128
    80000382:	f6f61ce3          	bne	a2,a5,800002fa <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000386:	863e                	mv	a2,a5
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	df670713          	addi	a4,a4,-522 # 80011180 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	de648493          	addi	s1,s1,-538 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	daa70713          	addi	a4,a4,-598 # 80011180 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	e2f72a23          	sw	a5,-460(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	d6e78793          	addi	a5,a5,-658 # 80011180 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	dec7a323          	sw	a2,-538(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	dda50513          	addi	a0,a0,-550 # 80011218 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	1fa080e7          	jalr	506(ra) # 80002640 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	d2050513          	addi	a0,a0,-736 # 80011180 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6ec080e7          	jalr	1772(ra) # 80000b54 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	330080e7          	jalr	816(ra) # 800007a0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	7e078793          	addi	a5,a5,2016 # 80021c58 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	ce07ab23          	sw	zero,-778(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00009717          	auipc	a4,0x9
    80000582:	a8f72123          	sw	a5,-1406(a4) # 80009000 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00011d97          	auipc	s11,0x11
    800005be:	c86dad83          	lw	s11,-890(s11) # 80011240 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	16050263          	beqz	a0,8000073a <printf+0x1b2>
    800005da:	4481                	li	s1,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b13          	li	s6,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b97          	auipc	s7,0x8
    800005ea:	a5ab8b93          	addi	s7,s7,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00011517          	auipc	a0,0x11
    800005fc:	c3050513          	addi	a0,a0,-976 # 80011228 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5e4080e7          	jalr	1508(ra) # 80000be4 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2485                	addiw	s1,s1,1
    80000624:	009a07b3          	add	a5,s4,s1
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050763          	beqz	a0,8000073a <printf+0x1b2>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000642:	cfe5                	beqz	a5,8000073a <printf+0x1b2>
    switch(c){
    80000644:	05678a63          	beq	a5,s6,80000698 <printf+0x110>
    80000648:	02fb7663          	bgeu	s6,a5,80000674 <printf+0xec>
    8000064c:	09978963          	beq	a5,s9,800006de <printf+0x156>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79863          	bne	a5,a4,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	0b578263          	beq	a5,s5,80000718 <printf+0x190>
    80000678:	0b879663          	bne	a5,s8,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c9d793          	srli	a5,s3,0x3c
    800006c6:	97de                	add	a5,a5,s7
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0992                	slli	s3,s3,0x4
    800006d6:	397d                	addiw	s2,s2,-1
    800006d8:	fe0915e3          	bnez	s2,800006c2 <printf+0x13a>
    800006dc:	b799                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	0007b903          	ld	s2,0(a5)
    800006ee:	00090e63          	beqz	s2,8000070a <printf+0x182>
      for(; *s; s++)
    800006f2:	00094503          	lbu	a0,0(s2)
    800006f6:	d515                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b84080e7          	jalr	-1148(ra) # 8000027c <consputc>
      for(; *s; s++)
    80000700:	0905                	addi	s2,s2,1
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	f96d                	bnez	a0,800006f8 <printf+0x170>
    80000708:	bf29                	j	80000622 <printf+0x9a>
        s = "(null)";
    8000070a:	00008917          	auipc	s2,0x8
    8000070e:	91690913          	addi	s2,s2,-1770 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000712:	02800513          	li	a0,40
    80000716:	b7cd                	j	800006f8 <printf+0x170>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
      break;
    80000722:	b701                	j	80000622 <printf+0x9a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b56080e7          	jalr	-1194(ra) # 8000027c <consputc>
      consputc(c);
    8000072e:	854a                	mv	a0,s2
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b4c080e7          	jalr	-1204(ra) # 8000027c <consputc>
      break;
    80000738:	b5ed                	j	80000622 <printf+0x9a>
  if(locking)
    8000073a:	020d9163          	bnez	s11,8000075c <printf+0x1d4>
}
    8000073e:	70e6                	ld	ra,120(sp)
    80000740:	7446                	ld	s0,112(sp)
    80000742:	74a6                	ld	s1,104(sp)
    80000744:	7906                	ld	s2,96(sp)
    80000746:	69e6                	ld	s3,88(sp)
    80000748:	6a46                	ld	s4,80(sp)
    8000074a:	6aa6                	ld	s5,72(sp)
    8000074c:	6b06                	ld	s6,64(sp)
    8000074e:	7be2                	ld	s7,56(sp)
    80000750:	7c42                	ld	s8,48(sp)
    80000752:	7ca2                	ld	s9,40(sp)
    80000754:	7d02                	ld	s10,32(sp)
    80000756:	6de2                	ld	s11,24(sp)
    80000758:	6129                	addi	sp,sp,192
    8000075a:	8082                	ret
    release(&pr.lock);
    8000075c:	00011517          	auipc	a0,0x11
    80000760:	acc50513          	addi	a0,a0,-1332 # 80011228 <pr>
    80000764:	00000097          	auipc	ra,0x0
    80000768:	534080e7          	jalr	1332(ra) # 80000c98 <release>
}
    8000076c:	bfc9                	j	8000073e <printf+0x1b6>

000000008000076e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076e:	1101                	addi	sp,sp,-32
    80000770:	ec06                	sd	ra,24(sp)
    80000772:	e822                	sd	s0,16(sp)
    80000774:	e426                	sd	s1,8(sp)
    80000776:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000778:	00011497          	auipc	s1,0x11
    8000077c:	ab048493          	addi	s1,s1,-1360 # 80011228 <pr>
    80000780:	00008597          	auipc	a1,0x8
    80000784:	8b858593          	addi	a1,a1,-1864 # 80008038 <etext+0x38>
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	3ca080e7          	jalr	970(ra) # 80000b54 <initlock>
  pr.locking = 1;
    80000792:	4785                	li	a5,1
    80000794:	cc9c                	sw	a5,24(s1)
}
    80000796:	60e2                	ld	ra,24(sp)
    80000798:	6442                	ld	s0,16(sp)
    8000079a:	64a2                	ld	s1,8(sp)
    8000079c:	6105                	addi	sp,sp,32
    8000079e:	8082                	ret

00000000800007a0 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e406                	sd	ra,8(sp)
    800007a4:	e022                	sd	s0,0(sp)
    800007a6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a8:	100007b7          	lui	a5,0x10000
    800007ac:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b0:	f8000713          	li	a4,-128
    800007b4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b8:	470d                	li	a4,3
    800007ba:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c6:	469d                	li	a3,7
    800007c8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007cc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d0:	00008597          	auipc	a1,0x8
    800007d4:	88858593          	addi	a1,a1,-1912 # 80008058 <digits+0x18>
    800007d8:	00011517          	auipc	a0,0x11
    800007dc:	a7050513          	addi	a0,a0,-1424 # 80011248 <uart_tx_lock>
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	374080e7          	jalr	884(ra) # 80000b54 <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  push_off();
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	39c080e7          	jalr	924(ra) # 80000b98 <push_off>

  if(panicked){
    80000804:	00008797          	auipc	a5,0x8
    80000808:	7fc7a783          	lw	a5,2044(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	10000737          	lui	a4,0x10000
  if(panicked){
    80000810:	c391                	beqz	a5,80000814 <uartputc_sync+0x24>
    for(;;)
    80000812:	a001                	j	80000812 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000814:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000818:	0ff7f793          	andi	a5,a5,255
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dbf5                	beqz	a5,80000814 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f793          	andi	a5,s1,255
    80000826:	10000737          	lui	a4,0x10000
    8000082a:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	40a080e7          	jalr	1034(ra) # 80000c38 <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008717          	auipc	a4,0x8
    80000844:	7c873703          	ld	a4,1992(a4) # 80009008 <uart_tx_r>
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7c87b783          	ld	a5,1992(a5) # 80009010 <uart_tx_w>
    80000850:	06e78c63          	beq	a5,a4,800008c8 <uartstart+0x88>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086a:	00011a17          	auipc	s4,0x11
    8000086e:	9dea0a13          	addi	s4,s4,-1570 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79648493          	addi	s1,s1,1942 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008997          	auipc	s3,0x8
    8000087e:	79698993          	addi	s3,s3,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	c785                	beqz	a5,800008b6 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000890:	01f77793          	andi	a5,a4,31
    80000894:	97d2                	add	a5,a5,s4
    80000896:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000089a:	0705                	addi	a4,a4,1
    8000089c:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089e:	8526                	mv	a0,s1
    800008a0:	00002097          	auipc	ra,0x2
    800008a4:	da0080e7          	jalr	-608(ra) # 80002640 <wakeup>
    
    WriteReg(THR, c);
    800008a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ac:	6098                	ld	a4,0(s1)
    800008ae:	0009b783          	ld	a5,0(s3)
    800008b2:	fce798e3          	bne	a5,a4,80000882 <uartstart+0x42>
  }
}
    800008b6:	70e2                	ld	ra,56(sp)
    800008b8:	7442                	ld	s0,48(sp)
    800008ba:	74a2                	ld	s1,40(sp)
    800008bc:	7902                	ld	s2,32(sp)
    800008be:	69e2                	ld	s3,24(sp)
    800008c0:	6a42                	ld	s4,16(sp)
    800008c2:	6aa2                	ld	s5,8(sp)
    800008c4:	6121                	addi	sp,sp,64
    800008c6:	8082                	ret
    800008c8:	8082                	ret

00000000800008ca <uartputc>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
    800008da:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008dc:	00011517          	auipc	a0,0x11
    800008e0:	96c50513          	addi	a0,a0,-1684 # 80011248 <uart_tx_lock>
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if(panicked){
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	7147a783          	lw	a5,1812(a5) # 80009000 <panicked>
    800008f4:	c391                	beqz	a5,800008f8 <uartputc+0x2e>
    for(;;)
    800008f6:	a001                	j	800008f6 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008797          	auipc	a5,0x8
    800008fc:	7187b783          	ld	a5,1816(a5) # 80009010 <uart_tx_w>
    80000900:	00008717          	auipc	a4,0x8
    80000904:	70873703          	ld	a4,1800(a4) # 80009008 <uart_tx_r>
    80000908:	02070713          	addi	a4,a4,32
    8000090c:	02f71b63          	bne	a4,a5,80000942 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00011a17          	auipc	s4,0x11
    80000914:	938a0a13          	addi	s4,s4,-1736 # 80011248 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	6f048493          	addi	s1,s1,1776 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	6f090913          	addi	s2,s2,1776 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85d2                	mv	a1,s4
    8000092a:	8526                	mv	a0,s1
    8000092c:	00002097          	auipc	ra,0x2
    80000930:	b76080e7          	jalr	-1162(ra) # 800024a2 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093783          	ld	a5,0(s2)
    80000938:	6098                	ld	a4,0(s1)
    8000093a:	02070713          	addi	a4,a4,32
    8000093e:	fef705e3          	beq	a4,a5,80000928 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00011497          	auipc	s1,0x11
    80000946:	90648493          	addi	s1,s1,-1786 # 80011248 <uart_tx_lock>
    8000094a:	01f7f713          	andi	a4,a5,31
    8000094e:	9726                	add	a4,a4,s1
    80000950:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000954:	0785                	addi	a5,a5,1
    80000956:	00008717          	auipc	a4,0x8
    8000095a:	6af73d23          	sd	a5,1722(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee2080e7          	jalr	-286(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	330080e7          	jalr	816(ra) # 80000c98 <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret

0000000080000980 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000980:	1141                	addi	sp,sp,-16
    80000982:	e422                	sd	s0,8(sp)
    80000984:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098e:	8b85                	andi	a5,a5,1
    80000990:	cb91                	beqz	a5,800009a4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000099a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099e:	6422                	ld	s0,8(sp)
    800009a0:	0141                	addi	sp,sp,16
    800009a2:	8082                	ret
    return -1;
    800009a4:	557d                	li	a0,-1
    800009a6:	bfe5                	j	8000099e <uartgetc+0x1e>

00000000800009a8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b2:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fcc080e7          	jalr	-52(ra) # 80000980 <uartgetc>
    if(c == -1)
    800009bc:	00950763          	beq	a0,s1,800009ca <uartintr+0x22>
      break;
    consoleintr(c);
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	8fe080e7          	jalr	-1794(ra) # 800002be <consoleintr>
  while(1){
    800009c8:	b7f5                	j	800009b4 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ca:	00011497          	auipc	s1,0x11
    800009ce:	87e48493          	addi	s1,s1,-1922 # 80011248 <uart_tx_lock>
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	210080e7          	jalr	528(ra) # 80000be4 <acquire>
  uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	e64080e7          	jalr	-412(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	ebb9                	bnez	a5,80000a5e <kfree+0x66>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00025797          	auipc	a5,0x25
    80000a10:	5f478793          	addi	a5,a5,1524 # 80026000 <end>
    80000a14:	04f56563          	bltu	a0,a5,80000a5e <kfree+0x66>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	04f57163          	bgeu	a0,a5,80000a5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	2bc080e7          	jalr	700(ra) # 80000ce0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2c:	00011917          	auipc	s2,0x11
    80000a30:	85490913          	addi	s2,s2,-1964 # 80011280 <kmem>
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  r->next = kmem.freelist;
    80000a3e:	01893783          	ld	a5,24(s2)
    80000a42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24e080e7          	jalr	590(ra) # 80000c98 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6902                	ld	s2,0(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret
    panic("kfree");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	60250513          	addi	a0,a0,1538 # 80008060 <digits+0x20>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>

0000000080000a6e <freerange>:
{
    80000a6e:	7179                	addi	sp,sp,-48
    80000a70:	f406                	sd	ra,40(sp)
    80000a72:	f022                	sd	s0,32(sp)
    80000a74:	ec26                	sd	s1,24(sp)
    80000a76:	e84a                	sd	s2,16(sp)
    80000a78:	e44e                	sd	s3,8(sp)
    80000a7a:	e052                	sd	s4,0(sp)
    80000a7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a84:	94aa                	add	s1,s1,a0
    80000a86:	757d                	lui	a0,0xfffff
    80000a88:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8a:	94be                	add	s1,s1,a5
    80000a8c:	0095ee63          	bltu	a1,s1,80000aa8 <freerange+0x3a>
    80000a90:	892e                	mv	s2,a1
    kfree(p);
    80000a92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	6985                	lui	s3,0x1
    kfree(p);
    80000a96:	01448533          	add	a0,s1,s4
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f5e080e7          	jalr	-162(ra) # 800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa2:	94ce                	add	s1,s1,s3
    80000aa4:	fe9979e3          	bgeu	s2,s1,80000a96 <freerange+0x28>
}
    80000aa8:	70a2                	ld	ra,40(sp)
    80000aaa:	7402                	ld	s0,32(sp)
    80000aac:	64e2                	ld	s1,24(sp)
    80000aae:	6942                	ld	s2,16(sp)
    80000ab0:	69a2                	ld	s3,8(sp)
    80000ab2:	6a02                	ld	s4,0(sp)
    80000ab4:	6145                	addi	sp,sp,48
    80000ab6:	8082                	ret

0000000080000ab8 <kinit>:
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac0:	00007597          	auipc	a1,0x7
    80000ac4:	5a858593          	addi	a1,a1,1448 # 80008068 <digits+0x28>
    80000ac8:	00010517          	auipc	a0,0x10
    80000acc:	7b850513          	addi	a0,a0,1976 # 80011280 <kmem>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	084080e7          	jalr	132(ra) # 80000b54 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad8:	45c5                	li	a1,17
    80000ada:	05ee                	slli	a1,a1,0x1b
    80000adc:	00025517          	auipc	a0,0x25
    80000ae0:	52450513          	addi	a0,a0,1316 # 80026000 <end>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	f8a080e7          	jalr	-118(ra) # 80000a6e <freerange>
}
    80000aec:	60a2                	ld	ra,8(sp)
    80000aee:	6402                	ld	s0,0(sp)
    80000af0:	0141                	addi	sp,sp,16
    80000af2:	8082                	ret

0000000080000af4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af4:	1101                	addi	sp,sp,-32
    80000af6:	ec06                	sd	ra,24(sp)
    80000af8:	e822                	sd	s0,16(sp)
    80000afa:	e426                	sd	s1,8(sp)
    80000afc:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afe:	00010497          	auipc	s1,0x10
    80000b02:	78248493          	addi	s1,s1,1922 # 80011280 <kmem>
    80000b06:	8526                	mv	a0,s1
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	0dc080e7          	jalr	220(ra) # 80000be4 <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c885                	beqz	s1,80000b42 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	addi	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	178080e7          	jalr	376(ra) # 80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b28:	6605                	lui	a2,0x1
    80000b2a:	4595                	li	a1,5
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1b2080e7          	jalr	434(ra) # 80000ce0 <memset>
  return (void*)r;
}
    80000b36:	8526                	mv	a0,s1
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret
  release(&kmem.lock);
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	73e50513          	addi	a0,a0,1854 # 80011280 <kmem>
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	14e080e7          	jalr	334(ra) # 80000c98 <release>
  if(r)
    80000b52:	b7d5                	j	80000b36 <kalloc+0x42>

0000000080000b54 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b54:	1141                	addi	sp,sp,-16
    80000b56:	e422                	sd	s0,8(sp)
    80000b58:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b5a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b60:	00053823          	sd	zero,16(a0)
}
    80000b64:	6422                	ld	s0,8(sp)
    80000b66:	0141                	addi	sp,sp,16
    80000b68:	8082                	ret

0000000080000b6a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	411c                	lw	a5,0(a0)
    80000b6c:	e399                	bnez	a5,80000b72 <holding+0x8>
    80000b6e:	4501                	li	a0,0
  return r;
}
    80000b70:	8082                	ret
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7c:	6904                	ld	s1,16(a0)
    80000b7e:	00001097          	auipc	ra,0x1
    80000b82:	1c2080e7          	jalr	450(ra) # 80001d40 <mycpu>
    80000b86:	40a48533          	sub	a0,s1,a0
    80000b8a:	00153513          	seqz	a0,a0
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret

0000000080000b98 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b98:	1101                	addi	sp,sp,-32
    80000b9a:	ec06                	sd	ra,24(sp)
    80000b9c:	e822                	sd	s0,16(sp)
    80000b9e:	e426                	sd	s1,8(sp)
    80000ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba2:	100024f3          	csrr	s1,sstatus
    80000ba6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000baa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bac:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	190080e7          	jalr	400(ra) # 80001d40 <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	184080e7          	jalr	388(ra) # 80001d40 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	2785                	addiw	a5,a5,1
    80000bc8:	dd3c                	sw	a5,120(a0)
}
    80000bca:	60e2                	ld	ra,24(sp)
    80000bcc:	6442                	ld	s0,16(sp)
    80000bce:	64a2                	ld	s1,8(sp)
    80000bd0:	6105                	addi	sp,sp,32
    80000bd2:	8082                	ret
    mycpu()->intena = old;
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	16c080e7          	jalr	364(ra) # 80001d40 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8085                	srli	s1,s1,0x1
    80000bde:	8885                	andi	s1,s1,1
    80000be0:	dd64                	sw	s1,124(a0)
    80000be2:	bfe9                	j	80000bbc <push_off+0x24>

0000000080000be4 <acquire>:
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
    80000bee:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	fa8080e7          	jalr	-88(ra) # 80000b98 <push_off>
  if(holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	f70080e7          	jalr	-144(ra) # 80000b6a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c02:	4705                	li	a4,1
  if(holding(lk))
    80000c04:	e115                	bnez	a0,80000c28 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c06:	87ba                	mv	a5,a4
    80000c08:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0c:	2781                	sext.w	a5,a5
    80000c0e:	ffe5                	bnez	a5,80000c06 <acquire+0x22>
  __sync_synchronize();
    80000c10:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	12c080e7          	jalr	300(ra) # 80001d40 <mycpu>
    80000c1c:	e888                	sd	a0,16(s1)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    panic("acquire");
    80000c28:	00007517          	auipc	a0,0x7
    80000c2c:	44850513          	addi	a0,a0,1096 # 80008070 <digits+0x30>
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	100080e7          	jalr	256(ra) # 80001d40 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4e:	e78d                	bnez	a5,80000c78 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c50:	5d3c                	lw	a5,120(a0)
    80000c52:	02f05b63          	blez	a5,80000c88 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5e:	eb09                	bnez	a4,80000c70 <pop_off+0x38>
    80000c60:	5d7c                	lw	a5,124(a0)
    80000c62:	c799                	beqz	a5,80000c70 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret
    panic("pop_off - interruptible");
    80000c78:	00007517          	auipc	a0,0x7
    80000c7c:	40050513          	addi	a0,a0,1024 # 80008078 <digits+0x38>
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("pop_off");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	40850513          	addi	a0,a0,1032 # 80008090 <digits+0x50>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	ec6080e7          	jalr	-314(ra) # 80000b6a <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	f7a080e7          	jalr	-134(ra) # 80000c38 <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	3c850513          	addi	a0,a0,968 # 80008098 <digits+0x58>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>

0000000080000ce0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce6:	ce09                	beqz	a2,80000d00 <memset+0x20>
    80000ce8:	87aa                	mv	a5,a0
    80000cea:	fff6071b          	addiw	a4,a2,-1
    80000cee:	1702                	slli	a4,a4,0x20
    80000cf0:	9301                	srli	a4,a4,0x20
    80000cf2:	0705                	addi	a4,a4,1
    80000cf4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x16>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	ca0d                	beqz	a2,80000d78 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	00a5f963          	bgeu	a1,a0,80000d5a <memmove+0x1a>
    80000d4c:	02061693          	slli	a3,a2,0x20
    80000d50:	9281                	srli	a3,a3,0x20
    80000d52:	00d58733          	add	a4,a1,a3
    80000d56:	02e56463          	bltu	a0,a4,80000d7e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d5a:	fff6079b          	addiw	a5,a2,-1
    80000d5e:	1782                	slli	a5,a5,0x20
    80000d60:	9381                	srli	a5,a5,0x20
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	97ae                	add	a5,a5,a1
    80000d66:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d68:	0585                	addi	a1,a1,1
    80000d6a:	0705                	addi	a4,a4,1
    80000d6c:	fff5c683          	lbu	a3,-1(a1)
    80000d70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d74:	fef59ae3          	bne	a1,a5,80000d68 <memmove+0x28>

  return dst;
}
    80000d78:	6422                	ld	s0,8(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret
    d += n;
    80000d7e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d80:	fff6079b          	addiw	a5,a2,-1
    80000d84:	1782                	slli	a5,a5,0x20
    80000d86:	9381                	srli	a5,a5,0x20
    80000d88:	fff7c793          	not	a5,a5
    80000d8c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	16fd                	addi	a3,a3,-1
    80000d92:	00074603          	lbu	a2,0(a4)
    80000d96:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d9a:	fef71ae3          	bne	a4,a5,80000d8e <memmove+0x4e>
    80000d9e:	bfe9                	j	80000d78 <memmove+0x38>

0000000080000da0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
}
    80000db0:	60a2                	ld	ra,8(sp)
    80000db2:	6402                	ld	s0,0(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbe:	ce11                	beqz	a2,80000dda <strncmp+0x22>
    80000dc0:	00054783          	lbu	a5,0(a0)
    80000dc4:	cf89                	beqz	a5,80000dde <strncmp+0x26>
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00f71a63          	bne	a4,a5,80000dde <strncmp+0x26>
    n--, p++, q++;
    80000dce:	367d                	addiw	a2,a2,-1
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd4:	f675                	bnez	a2,80000dc0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a809                	j	80000dea <strncmp+0x32>
    80000dda:	4501                	li	a0,0
    80000ddc:	a039                	j	80000dea <strncmp+0x32>
  if(n == 0)
    80000dde:	ca09                	beqz	a2,80000df0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de0:	00054503          	lbu	a0,0(a0)
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	9d1d                	subw	a0,a0,a5
}
    80000dea:	6422                	ld	s0,8(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	bfe5                	j	80000dea <strncmp+0x32>

0000000080000df4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df4:	1141                	addi	sp,sp,-16
    80000df6:	e422                	sd	s0,8(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfa:	872a                	mv	a4,a0
    80000dfc:	8832                	mv	a6,a2
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	01005963          	blez	a6,80000e12 <strncpy+0x1e>
    80000e04:	0705                	addi	a4,a4,1
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	fef70fa3          	sb	a5,-1(a4)
    80000e0e:	0585                	addi	a1,a1,1
    80000e10:	f7f5                	bnez	a5,80000dfc <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e12:	00c05d63          	blez	a2,80000e2c <strncpy+0x38>
    80000e16:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e18:	0685                	addi	a3,a3,1
    80000e1a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1e:	fff6c793          	not	a5,a3
    80000e22:	9fb9                	addw	a5,a5,a4
    80000e24:	010787bb          	addw	a5,a5,a6
    80000e28:	fef048e3          	bgtz	a5,80000e18 <strncpy+0x24>
  return os;
}
    80000e2c:	6422                	ld	s0,8(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e38:	02c05363          	blez	a2,80000e5e <safestrcpy+0x2c>
    80000e3c:	fff6069b          	addiw	a3,a2,-1
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	96ae                	add	a3,a3,a1
    80000e46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e48:	00d58963          	beq	a1,a3,80000e5a <safestrcpy+0x28>
    80000e4c:	0585                	addi	a1,a1,1
    80000e4e:	0785                	addi	a5,a5,1
    80000e50:	fff5c703          	lbu	a4,-1(a1)
    80000e54:	fee78fa3          	sb	a4,-1(a5)
    80000e58:	fb65                	bnez	a4,80000e48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strlen>:

int
strlen(const char *s)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x26>
    80000e70:	0505                	addi	a0,a0,1
    80000e72:	87aa                	mv	a5,a0
    80000e74:	4685                	li	a3,1
    80000e76:	9e89                	subw	a3,a3,a0
    80000e78:	00f6853b          	addw	a0,a3,a5
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff7c703          	lbu	a4,-1(a5)
    80000e82:	fb7d                	bnez	a4,80000e78 <strlen+0x14>
    ;
  return n;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfe5                	j	80000e84 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	e9a080e7          	jalr	-358(ra) # 80001d30 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9e:	00008717          	auipc	a4,0x8
    80000ea2:	17a70713          	addi	a4,a4,378 # 80009018 <started>
  if(cpuid() == 0){
    80000ea6:	c139                	beqz	a0,80000eec <main+0x5e>
    while(started == 0)
    80000ea8:	431c                	lw	a5,0(a4)
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dff5                	beqz	a5,80000ea8 <main+0x1a>
      ;
    __sync_synchronize();
    80000eae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb2:	00001097          	auipc	ra,0x1
    80000eb6:	e7e080e7          	jalr	-386(ra) # 80001d30 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	1fc50513          	addi	a0,a0,508 # 800080b8 <digits+0x78>
    80000ec4:	fffff097          	auipc	ra,0xfffff
    80000ec8:	6c4080e7          	jalr	1732(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	0d8080e7          	jalr	216(ra) # 80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed4:	00002097          	auipc	ra,0x2
    80000ed8:	ba4080e7          	jalr	-1116(ra) # 80002a78 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	0f4080e7          	jalr	244(ra) # 80005fd0 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	3d6080e7          	jalr	982(ra) # 800022ba <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	1cc50513          	addi	a0,a0,460 # 800080c8 <digits+0x88>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	1ac50513          	addi	a0,a0,428 # 800080c8 <digits+0x88>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	664080e7          	jalr	1636(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	b8c080e7          	jalr	-1140(ra) # 80000ab8 <kinit>
    kvminit();       // create kernel page table
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	322080e7          	jalr	802(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	068080e7          	jalr	104(ra) # 80000fa4 <kvminithart>
    procinit();      // process table
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	c7e080e7          	jalr	-898(ra) # 80001bc2 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	b04080e7          	jalr	-1276(ra) # 80002a50 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	b24080e7          	jalr	-1244(ra) # 80002a78 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	05e080e7          	jalr	94(ra) # 80005fba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	06c080e7          	jalr	108(ra) # 80005fd0 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	24e080e7          	jalr	590(ra) # 800031ba <binit>
    iinit();         // inode table
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	8de080e7          	jalr	-1826(ra) # 80003852 <iinit>
    fileinit();      // file table
    80000f7c:	00004097          	auipc	ra,0x4
    80000f80:	888080e7          	jalr	-1912(ra) # 80004804 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	16e080e7          	jalr	366(ra) # 800060f2 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	0c0080e7          	jalr	192(ra) # 8000204c <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00008717          	auipc	a4,0x8
    80000f9e:	06f72f23          	sw	a5,126(a4) # 80009018 <started>
    80000fa2:	b789                	j	80000ee4 <main+0x56>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000faa:	00008797          	auipc	a5,0x8
    80000fae:	0767b783          	ld	a5,118(a5) # 80009020 <kernel_pagetable>
    80000fb2:	83b1                	srli	a5,a5,0xc
    80000fb4:	577d                	li	a4,-1
    80000fb6:	177e                	slli	a4,a4,0x3f
    80000fb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fba:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbe:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc2:	6422                	ld	s0,8(sp)
    80000fc4:	0141                	addi	sp,sp,16
    80000fc6:	8082                	ret

0000000080000fc8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc8:	7139                	addi	sp,sp,-64
    80000fca:	fc06                	sd	ra,56(sp)
    80000fcc:	f822                	sd	s0,48(sp)
    80000fce:	f426                	sd	s1,40(sp)
    80000fd0:	f04a                	sd	s2,32(sp)
    80000fd2:	ec4e                	sd	s3,24(sp)
    80000fd4:	e852                	sd	s4,16(sp)
    80000fd6:	e456                	sd	s5,8(sp)
    80000fd8:	e05a                	sd	s6,0(sp)
    80000fda:	0080                	addi	s0,sp,64
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	89ae                	mv	s3,a1
    80000fe0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe2:	57fd                	li	a5,-1
    80000fe4:	83e9                	srli	a5,a5,0x1a
    80000fe6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fea:	04b7f263          	bgeu	a5,a1,8000102e <walk+0x66>
    panic("walk");
    80000fee:	00007517          	auipc	a0,0x7
    80000ff2:	0e250513          	addi	a0,a0,226 # 800080d0 <digits+0x90>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8663          	beqz	s5,8000106a <walk+0xa2>
    80001002:	00000097          	auipc	ra,0x0
    80001006:	af2080e7          	jalr	-1294(ra) # 80000af4 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	c529                	beqz	a0,80001056 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	00000097          	auipc	ra,0x0
    80001016:	cce080e7          	jalr	-818(ra) # 80000ce0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001028:	3a5d                	addiw	s4,s4,-9
    8000102a:	036a0063          	beq	s4,s6,8000104a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102e:	0149d933          	srl	s2,s3,s4
    80001032:	1ff97913          	andi	s2,s2,511
    80001036:	090e                	slli	s2,s2,0x3
    80001038:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103a:	00093483          	ld	s1,0(s2)
    8000103e:	0014f793          	andi	a5,s1,1
    80001042:	dfd5                	beqz	a5,80000ffe <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001044:	80a9                	srli	s1,s1,0xa
    80001046:	04b2                	slli	s1,s1,0xc
    80001048:	b7c5                	j	80001028 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104a:	00c9d513          	srli	a0,s3,0xc
    8000104e:	1ff57513          	andi	a0,a0,511
    80001052:	050e                	slli	a0,a0,0x3
    80001054:	9526                	add	a0,a0,s1
}
    80001056:	70e2                	ld	ra,56(sp)
    80001058:	7442                	ld	s0,48(sp)
    8000105a:	74a2                	ld	s1,40(sp)
    8000105c:	7902                	ld	s2,32(sp)
    8000105e:	69e2                	ld	s3,24(sp)
    80001060:	6a42                	ld	s4,16(sp)
    80001062:	6aa2                	ld	s5,8(sp)
    80001064:	6b02                	ld	s6,0(sp)
    80001066:	6121                	addi	sp,sp,64
    80001068:	8082                	ret
        return 0;
    8000106a:	4501                	li	a0,0
    8000106c:	b7ed                	j	80001056 <walk+0x8e>

000000008000106e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	00b7f463          	bgeu	a5,a1,8000107a <walkaddr+0xc>
    return 0;
    80001076:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001078:	8082                	ret
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e406                	sd	ra,8(sp)
    8000107e:	e022                	sd	s0,0(sp)
    80001080:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001082:	4601                	li	a2,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	f44080e7          	jalr	-188(ra) # 80000fc8 <walk>
  if(pte == 0)
    8000108c:	c105                	beqz	a0,800010ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001090:	0117f693          	andi	a3,a5,17
    80001094:	4745                	li	a4,17
    return 0;
    80001096:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001098:	00e68663          	beq	a3,a4,800010a4 <walkaddr+0x36>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
  pa = PTE2PA(*pte);
    800010a4:	00a7d513          	srli	a0,a5,0xa
    800010a8:	0532                	slli	a0,a0,0xc
  return pa;
    800010aa:	bfcd                	j	8000109c <walkaddr+0x2e>
    return 0;
    800010ac:	4501                	li	a0,0
    800010ae:	b7fd                	j	8000109c <walkaddr+0x2e>

00000000800010b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b0:	715d                	addi	sp,sp,-80
    800010b2:	e486                	sd	ra,72(sp)
    800010b4:	e0a2                	sd	s0,64(sp)
    800010b6:	fc26                	sd	s1,56(sp)
    800010b8:	f84a                	sd	s2,48(sp)
    800010ba:	f44e                	sd	s3,40(sp)
    800010bc:	f052                	sd	s4,32(sp)
    800010be:	ec56                	sd	s5,24(sp)
    800010c0:	e85a                	sd	s6,16(sp)
    800010c2:	e45e                	sd	s7,8(sp)
    800010c4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c6:	c205                	beqz	a2,800010e6 <mappages+0x36>
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	15fd                	addi	a1,a1,-1
    800010d4:	00c589b3          	add	s3,a1,a2
    800010d8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010dc:	8952                	mv	s2,s4
    800010de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	a015                	j	80001108 <mappages+0x58>
    panic("mappages: size");
    800010e6:	00007517          	auipc	a0,0x7
    800010ea:	ff250513          	addi	a0,a0,-14 # 800080d8 <digits+0x98>
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	ff250513          	addi	a0,a0,-14 # 800080e8 <digits+0xa8>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
  for(;;){
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	00000097          	auipc	ra,0x0
    80001116:	eb6080e7          	jalr	-330(ra) # 80000fc8 <walk>
    8000111a:	cd19                	beqz	a0,80001138 <mappages+0x88>
    if(*pte & PTE_V)
    8000111c:	611c                	ld	a5,0(a0)
    8000111e:	8b85                	andi	a5,a5,1
    80001120:	fbf9                	bnez	a5,800010f6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001122:	80b1                	srli	s1,s1,0xc
    80001124:	04aa                	slli	s1,s1,0xa
    80001126:	0164e4b3          	or	s1,s1,s6
    8000112a:	0014e493          	ori	s1,s1,1
    8000112e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001130:	fd391be3          	bne	s2,s3,80001106 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	a011                	j	8000113a <mappages+0x8a>
      return -1;
    80001138:	557d                	li	a0,-1
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f52080e7          	jalr	-174(ra) # 800010b0 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x20>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f8850513          	addi	a0,a0,-120 # 800080f8 <digits+0xb8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	e04a                	sd	s2,0(sp)
    8000118a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	968080e7          	jalr	-1688(ra) # 80000af4 <kalloc>
    80001194:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001196:	6605                	lui	a2,0x1
    80001198:	4581                	li	a1,0
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	b46080e7          	jalr	-1210(ra) # 80000ce0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	6685                	lui	a3,0x1
    800011a6:	10000637          	lui	a2,0x10000
    800011aa:	100005b7          	lui	a1,0x10000
    800011ae:	8526                	mv	a0,s1
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	fa0080e7          	jalr	-96(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	6685                	lui	a3,0x1
    800011bc:	10001637          	lui	a2,0x10001
    800011c0:	100015b7          	lui	a1,0x10001
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f8a080e7          	jalr	-118(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ce:	4719                	li	a4,6
    800011d0:	004006b7          	lui	a3,0x400
    800011d4:	0c000637          	lui	a2,0xc000
    800011d8:	0c0005b7          	lui	a1,0xc000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f72080e7          	jalr	-142(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e6:	00007917          	auipc	s2,0x7
    800011ea:	e1a90913          	addi	s2,s2,-486 # 80008000 <etext>
    800011ee:	4729                	li	a4,10
    800011f0:	80007697          	auipc	a3,0x80007
    800011f4:	e1068693          	addi	a3,a3,-496 # 8000 <_entry-0x7fff8000>
    800011f8:	4605                	li	a2,1
    800011fa:	067e                	slli	a2,a2,0x1f
    800011fc:	85b2                	mv	a1,a2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f50080e7          	jalr	-176(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	46c5                	li	a3,17
    8000120c:	06ee                	slli	a3,a3,0x1b
    8000120e:	412686b3          	sub	a3,a3,s2
    80001212:	864a                	mv	a2,s2
    80001214:	85ca                	mv	a1,s2
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f38080e7          	jalr	-200(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001220:	4729                	li	a4,10
    80001222:	6685                	lui	a3,0x1
    80001224:	00006617          	auipc	a2,0x6
    80001228:	ddc60613          	addi	a2,a2,-548 # 80007000 <_trampoline>
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f1a080e7          	jalr	-230(ra) # 80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	00001097          	auipc	ra,0x1
    80001244:	8ec080e7          	jalr	-1812(ra) # 80001b2c <proc_mapstacks>
}
    80001248:	8526                	mv	a0,s1
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <kvminit>:
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f22080e7          	jalr	-222(ra) # 80001180 <kvmmake>
    80001266:	00008797          	auipc	a5,0x8
    8000126a:	daa7bd23          	sd	a0,-582(a5) # 80009020 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001276:	715d                	addi	sp,sp,-80
    80001278:	e486                	sd	ra,72(sp)
    8000127a:	e0a2                	sd	s0,64(sp)
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    8000128a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128c:	03459793          	slli	a5,a1,0x34
    80001290:	e795                	bnez	a5,800012bc <uvmunmap+0x46>
    80001292:	8a2a                	mv	s4,a0
    80001294:	892e                	mv	s2,a1
    80001296:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	0632                	slli	a2,a2,0xc
    8000129a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	6b05                	lui	s6,0x1
    800012a2:	0735e863          	bltu	a1,s3,80001312 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a6:	60a6                	ld	ra,72(sp)
    800012a8:	6406                	ld	s0,64(sp)
    800012aa:	74e2                	ld	s1,56(sp)
    800012ac:	7942                	ld	s2,48(sp)
    800012ae:	79a2                	ld	s3,40(sp)
    800012b0:	7a02                	ld	s4,32(sp)
    800012b2:	6ae2                	ld	s5,24(sp)
    800012b4:	6b42                	ld	s6,16(sp)
    800012b6:	6ba2                	ld	s7,8(sp)
    800012b8:	6161                	addi	sp,sp,80
    800012ba:	8082                	ret
    panic("uvmunmap: not aligned");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	27a080e7          	jalr	634(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4c50513          	addi	a0,a0,-436 # 80008118 <digits+0xd8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ec:	00007517          	auipc	a0,0x7
    800012f0:	e5450513          	addi	a0,a0,-428 # 80008140 <digits+0x100>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
      uint64 pa = PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	6f8080e7          	jalr	1784(ra) # 800009f8 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	995a                	add	s2,s2,s6
    8000130e:	f9397ce3          	bgeu	s2,s3,800012a6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cb0080e7          	jalr	-848(ra) # 80000fc8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d54d                	beqz	a0,800012cc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001324:	6108                	ld	a0,0(a0)
    80001326:	00157793          	andi	a5,a0,1
    8000132a:	dbcd                	beqz	a5,800012dc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff57793          	andi	a5,a0,1023
    80001330:	fb778ee3          	beq	a5,s7,800012ec <uvmunmap+0x76>
    if(do_free){
    80001334:	fc0a8ae3          	beqz	s5,80001308 <uvmunmap+0x92>
    80001338:	b7d1                	j	800012fc <uvmunmap+0x86>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7b0080e7          	jalr	1968(ra) # 80000af4 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	98c080e7          	jalr	-1652(ra) # 80000ce0 <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	770080e7          	jalr	1904(ra) # 80000af4 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	94e080e7          	jalr	-1714(ra) # 80000ce0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d0c080e7          	jalr	-756(ra) # 800010b0 <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	98e080e7          	jalr	-1650(ra) # 80000d40 <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d8e50513          	addi	a0,a0,-626 # 80008158 <digits+0x118>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e5e080e7          	jalr	-418(ra) # 80001276 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6a6080e7          	jalr	1702(ra) # 80000af4 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	882080e7          	jalr	-1918(ra) # 80000ce0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c40080e7          	jalr	-960(ra) # 800010b0 <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	54e080e7          	jalr	1358(ra) # 800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff3782e3          	beq	a5,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8905                	andi	a0,a0,1
    8000150a:	d57d                	beqz	a0,800014f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4da080e7          	jalr	1242(ra) # 800009f8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f86080e7          	jalr	-122(ra) # 800014cc <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6605                	lui	a2,0x1
    8000155a:	167d                	addi	a2,a2,-1
    8000155c:	962e                	add	a2,a2,a1
    8000155e:	4685                	li	a3,1
    80001560:	8231                	srli	a2,a2,0xc
    80001562:	4581                	li	a1,0
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d12080e7          	jalr	-750(ra) # 80001276 <uvmunmap>
    8000156c:	bfe1                	j	80001544 <uvmfree+0xe>

000000008000156e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	c679                	beqz	a2,8000163c <uvmcopy+0xce>
{
    80001570:	715d                	addi	sp,sp,-80
    80001572:	e486                	sd	ra,72(sp)
    80001574:	e0a2                	sd	s0,64(sp)
    80001576:	fc26                	sd	s1,56(sp)
    80001578:	f84a                	sd	s2,48(sp)
    8000157a:	f44e                	sd	s3,40(sp)
    8000157c:	f052                	sd	s4,32(sp)
    8000157e:	ec56                	sd	s5,24(sp)
    80001580:	e85a                	sd	s6,16(sp)
    80001582:	e45e                	sd	s7,8(sp)
    80001584:	0880                	addi	s0,sp,80
    80001586:	8b2a                	mv	s6,a0
    80001588:	8aae                	mv	s5,a1
    8000158a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158e:	4601                	li	a2,0
    80001590:	85ce                	mv	a1,s3
    80001592:	855a                	mv	a0,s6
    80001594:	00000097          	auipc	ra,0x0
    80001598:	a34080e7          	jalr	-1484(ra) # 80000fc8 <walk>
    8000159c:	c531                	beqz	a0,800015e8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159e:	6118                	ld	a4,0(a0)
    800015a0:	00177793          	andi	a5,a4,1
    800015a4:	cbb1                	beqz	a5,800015f8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a6:	00a75593          	srli	a1,a4,0xa
    800015aa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ae:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	542080e7          	jalr	1346(ra) # 80000af4 <kalloc>
    800015ba:	892a                	mv	s2,a0
    800015bc:	c939                	beqz	a0,80001612 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	85de                	mv	a1,s7
    800015c2:	fffff097          	auipc	ra,0xfffff
    800015c6:	77e080e7          	jalr	1918(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ca:	8726                	mv	a4,s1
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	adc080e7          	jalr	-1316(ra) # 800010b0 <mappages>
    800015dc:	e515                	bnez	a0,80001608 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015de:	6785                	lui	a5,0x1
    800015e0:	99be                	add	s3,s3,a5
    800015e2:	fb49e6e3          	bltu	s3,s4,8000158e <uvmcopy+0x20>
    800015e6:	a081                	j	80001626 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba050513          	addi	a0,a0,-1120 # 80008188 <digits+0x148>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f8:	00007517          	auipc	a0,0x7
    800015fc:	bb050513          	addi	a0,a0,-1104 # 800081a8 <digits+0x168>
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
      kfree(mem);
    80001608:	854a                	mv	a0,s2
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	3ee080e7          	jalr	1006(ra) # 800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001612:	4685                	li	a3,1
    80001614:	00c9d613          	srli	a2,s3,0xc
    80001618:	4581                	li	a1,0
    8000161a:	8556                	mv	a0,s5
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	c5a080e7          	jalr	-934(ra) # 80001276 <uvmunmap>
  return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	60a6                	ld	ra,72(sp)
    80001628:	6406                	ld	s0,64(sp)
    8000162a:	74e2                	ld	s1,56(sp)
    8000162c:	7942                	ld	s2,48(sp)
    8000162e:	79a2                	ld	s3,40(sp)
    80001630:	7a02                	ld	s4,32(sp)
    80001632:	6ae2                	ld	s5,24(sp)
    80001634:	6b42                	ld	s6,16(sp)
    80001636:	6ba2                	ld	s7,8(sp)
    80001638:	6161                	addi	sp,sp,80
    8000163a:	8082                	ret
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	8082                	ret

0000000080001640 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001640:	1141                	addi	sp,sp,-16
    80001642:	e406                	sd	ra,8(sp)
    80001644:	e022                	sd	s0,0(sp)
    80001646:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001648:	4601                	li	a2,0
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	97e080e7          	jalr	-1666(ra) # 80000fc8 <walk>
  if(pte == 0)
    80001652:	c901                	beqz	a0,80001662 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001654:	611c                	ld	a5,0(a0)
    80001656:	9bbd                	andi	a5,a5,-17
    80001658:	e11c                	sd	a5,0(a0)
}
    8000165a:	60a2                	ld	ra,8(sp)
    8000165c:	6402                	ld	s0,0(sp)
    8000165e:	0141                	addi	sp,sp,16
    80001660:	8082                	ret
    panic("uvmclear");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <digits+0x188>
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080001672 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001672:	c6bd                	beqz	a3,800016e0 <copyout+0x6e>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	e062                	sd	s8,0(sp)
    8000168a:	0880                	addi	s0,sp,80
    8000168c:	8b2a                	mv	s6,a0
    8000168e:	8c2e                	mv	s8,a1
    80001690:	8a32                	mv	s4,a2
    80001692:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001694:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001696:	6a85                	lui	s5,0x1
    80001698:	a015                	j	800016bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169a:	9562                	add	a0,a0,s8
    8000169c:	0004861b          	sext.w	a2,s1
    800016a0:	85d2                	mv	a1,s4
    800016a2:	41250533          	sub	a0,a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	69a080e7          	jalr	1690(ra) # 80000d40 <memmove>

    len -= n;
    800016ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b8:	02098263          	beqz	s3,800016dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	855a                	mv	a0,s6
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	9aa080e7          	jalr	-1622(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800016cc:	cd01                	beqz	a0,800016e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ce:	418904b3          	sub	s1,s2,s8
    800016d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d4:	fc99f3e3          	bgeu	s3,s1,8000169a <copyout+0x28>
    800016d8:	84ce                	mv	s1,s3
    800016da:	b7c1                	j	8000169a <copyout+0x28>
  }
  return 0;
    800016dc:	4501                	li	a0,0
    800016de:	a021                	j	800016e6 <copyout+0x74>
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret
      return -1;
    800016e4:	557d                	li	a0,-1
}
    800016e6:	60a6                	ld	ra,72(sp)
    800016e8:	6406                	ld	s0,64(sp)
    800016ea:	74e2                	ld	s1,56(sp)
    800016ec:	7942                	ld	s2,48(sp)
    800016ee:	79a2                	ld	s3,40(sp)
    800016f0:	7a02                	ld	s4,32(sp)
    800016f2:	6ae2                	ld	s5,24(sp)
    800016f4:	6b42                	ld	s6,16(sp)
    800016f6:	6ba2                	ld	s7,8(sp)
    800016f8:	6c02                	ld	s8,0(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret

00000000800016fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fe:	c6bd                	beqz	a3,8000176c <copyin+0x6e>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	e062                	sd	s8,0(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8a2e                	mv	s4,a1
    8000171c:	8c32                	mv	s8,a2
    8000171e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001720:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001722:	6a85                	lui	s5,0x1
    80001724:	a015                	j	80001748 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001726:	9562                	add	a0,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412505b3          	sub	a1,a0,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	60e080e7          	jalr	1550(ra) # 80000d40 <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	91e080e7          	jalr	-1762(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f3e3          	bgeu	s3,s1,80001726 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	b7c1                	j	80001726 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x74>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	88c080e7          	jalr	-1908(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <add>:
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

void add(struct headList * list , int new_proc){
    8000183e:	715d                	addi	sp,sp,-80
    80001840:	e486                	sd	ra,72(sp)
    80001842:	e0a2                	sd	s0,64(sp)
    80001844:	fc26                	sd	s1,56(sp)
    80001846:	f84a                	sd	s2,48(sp)
    80001848:	f44e                	sd	s3,40(sp)
    8000184a:	f052                	sd	s4,32(sp)
    8000184c:	ec56                	sd	s5,24(sp)
    8000184e:	e85a                	sd	s6,16(sp)
    80001850:	e45e                	sd	s7,8(sp)
    80001852:	0880                	addi	s0,sp,80
    80001854:	89aa                	mv	s3,a0
    80001856:	84ae                	mv	s1,a1
    //printf("try to add proc num: %d\n" , new_proc);
    acquire(&list->lock);
    80001858:	00850b13          	addi	s6,a0,8
    8000185c:	855a                	mv	a0,s6
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	386080e7          	jalr	902(ra) # 80000be4 <acquire>

    //case the queue is empty
    if(list->tail == -1){
    80001866:	0049a783          	lw	a5,4(s3) # 1004 <_entry-0x7fffeffc>
    8000186a:	577d                	li	a4,-1
    8000186c:	06e78163          	beq	a5,a4,800018ce <add+0x90>
      list->tail = new_proc;
      release(&list->lock);
      return;
    }
    struct proc *p = &proc[list->tail]; 
    acquire(&p->list_lock);
    80001870:	18800b93          	li	s7,392
    80001874:	03778933          	mul	s2,a5,s7
    80001878:	04090a93          	addi	s5,s2,64 # 1040 <_entry-0x7fffefc0>
    8000187c:	00010a17          	auipc	s4,0x10
    80001880:	f94a0a13          	addi	s4,s4,-108 # 80011810 <proc>
    80001884:	9ad2                	add	s5,s5,s4
    80001886:	8556                	mv	a0,s5
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	35c080e7          	jalr	860(ra) # 80000be4 <acquire>
    p->next = new_proc;
    80001890:	012a07b3          	add	a5,s4,s2
    80001894:	df84                	sw	s1,56(a5)
    list->tail = new_proc;
    80001896:	0099a223          	sw	s1,4(s3)
    proc[new_proc].next = -1 ; 
    8000189a:	037484b3          	mul	s1,s1,s7
    8000189e:	94d2                	add	s1,s1,s4
    800018a0:	57fd                	li	a5,-1
    800018a2:	dc9c                	sw	a5,56(s1)
    release(&p->list_lock);
    800018a4:	8556                	mv	a0,s5
    800018a6:	fffff097          	auipc	ra,0xfffff
    800018aa:	3f2080e7          	jalr	1010(ra) # 80000c98 <release>
    release(&list->lock);
    800018ae:	855a                	mv	a0,s6
    800018b0:	fffff097          	auipc	ra,0xfffff
    800018b4:	3e8080e7          	jalr	1000(ra) # 80000c98 <release>
    //printf("add proc num: %d succsesfuly\n" , new_proc);
}
    800018b8:	60a6                	ld	ra,72(sp)
    800018ba:	6406                	ld	s0,64(sp)
    800018bc:	74e2                	ld	s1,56(sp)
    800018be:	7942                	ld	s2,48(sp)
    800018c0:	79a2                	ld	s3,40(sp)
    800018c2:	7a02                	ld	s4,32(sp)
    800018c4:	6ae2                	ld	s5,24(sp)
    800018c6:	6b42                	ld	s6,16(sp)
    800018c8:	6ba2                	ld	s7,8(sp)
    800018ca:	6161                	addi	sp,sp,80
    800018cc:	8082                	ret
      list->head = new_proc;
    800018ce:	0099a023          	sw	s1,0(s3)
      list->tail = new_proc;
    800018d2:	0099a223          	sw	s1,4(s3)
      release(&list->lock);
    800018d6:	855a                	mv	a0,s6
    800018d8:	fffff097          	auipc	ra,0xfffff
    800018dc:	3c0080e7          	jalr	960(ra) # 80000c98 <release>
      return;
    800018e0:	bfe1                	j	800018b8 <add+0x7a>

00000000800018e2 <remove>:


struct proc* remove(struct headList *list){
    800018e2:	715d                	addi	sp,sp,-80
    800018e4:	e486                	sd	ra,72(sp)
    800018e6:	e0a2                	sd	s0,64(sp)
    800018e8:	fc26                	sd	s1,56(sp)
    800018ea:	f84a                	sd	s2,48(sp)
    800018ec:	f44e                	sd	s3,40(sp)
    800018ee:	f052                	sd	s4,32(sp)
    800018f0:	ec56                	sd	s5,24(sp)
    800018f2:	e85a                	sd	s6,16(sp)
    800018f4:	e45e                	sd	s7,8(sp)
    800018f6:	0880                	addi	s0,sp,80
    800018f8:	892a                	mv	s2,a0
  int offset = -1; 
  acquire(&list->lock);
    800018fa:	00850b93          	addi	s7,a0,8
    800018fe:	855e                	mv	a0,s7
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	2e4080e7          	jalr	740(ra) # 80000be4 <acquire>

  //case of empty quequ 
  if(list->head == -1){
    80001908:	00092483          	lw	s1,0(s2)
    8000190c:	57fd                	li	a5,-1
    8000190e:	06f48f63          	beq	s1,a5,8000198c <remove+0xaa>
    release(&list->lock);
    return 0;
  }

  struct proc *p = &proc[list->head]; 
  acquire(&p->list_lock);
    80001912:	18800a93          	li	s5,392
    80001916:	03548b33          	mul	s6,s1,s5
    8000191a:	040b0a13          	addi	s4,s6,64 # 1040 <_entry-0x7fffefc0>
    8000191e:	00010a97          	auipc	s5,0x10
    80001922:	ef2a8a93          	addi	s5,s5,-270 # 80011810 <proc>
    80001926:	9a56                	add	s4,s4,s5
    80001928:	8552                	mv	a0,s4
    8000192a:	fffff097          	auipc	ra,0xfffff
    8000192e:	2ba080e7          	jalr	698(ra) # 80000be4 <acquire>
  offset = list->head;
    80001932:	00092983          	lw	s3,0(s2)
  list->head = p->next; 
    80001936:	9ada                	add	s5,s5,s6
    80001938:	038aa783          	lw	a5,56(s5)
    8000193c:	00f92023          	sw	a5,0(s2)

  //case of removing the last element
  if(p->next == -1)
    80001940:	577d                	li	a4,-1
    80001942:	04e78c63          	beq	a5,a4,8000199a <remove+0xb8>
    list->tail = -1;
  p->next = -1;
    80001946:	00010917          	auipc	s2,0x10
    8000194a:	eca90913          	addi	s2,s2,-310 # 80011810 <proc>
    8000194e:	18800a93          	li	s5,392
    80001952:	035484b3          	mul	s1,s1,s5
    80001956:	94ca                	add	s1,s1,s2
    80001958:	57fd                	li	a5,-1
    8000195a:	dc9c                	sw	a5,56(s1)
  release(&p->list_lock);
    8000195c:	8552                	mv	a0,s4
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	33a080e7          	jalr	826(ra) # 80000c98 <release>
  release(&list->lock);
    80001966:	855e                	mv	a0,s7
    80001968:	fffff097          	auipc	ra,0xfffff
    8000196c:	330080e7          	jalr	816(ra) # 80000c98 <release>
  return &proc[offset];
    80001970:	03598533          	mul	a0,s3,s5
    80001974:	954a                	add	a0,a0,s2
}
    80001976:	60a6                	ld	ra,72(sp)
    80001978:	6406                	ld	s0,64(sp)
    8000197a:	74e2                	ld	s1,56(sp)
    8000197c:	7942                	ld	s2,48(sp)
    8000197e:	79a2                	ld	s3,40(sp)
    80001980:	7a02                	ld	s4,32(sp)
    80001982:	6ae2                	ld	s5,24(sp)
    80001984:	6b42                	ld	s6,16(sp)
    80001986:	6ba2                	ld	s7,8(sp)
    80001988:	6161                	addi	sp,sp,80
    8000198a:	8082                	ret
    release(&list->lock);
    8000198c:	855e                	mv	a0,s7
    8000198e:	fffff097          	auipc	ra,0xfffff
    80001992:	30a080e7          	jalr	778(ra) # 80000c98 <release>
    return 0;
    80001996:	4501                	li	a0,0
    80001998:	bff9                	j	80001976 <remove+0x94>
    list->tail = -1;
    8000199a:	57fd                	li	a5,-1
    8000199c:	00f92223          	sw	a5,4(s2)
    800019a0:	b75d                	j	80001946 <remove+0x64>

00000000800019a2 <remove_index>:

void remove_index(struct headList *list , int ind){
    800019a2:	7179                	addi	sp,sp,-48
    800019a4:	f406                	sd	ra,40(sp)
    800019a6:	f022                	sd	s0,32(sp)
    800019a8:	ec26                	sd	s1,24(sp)
    800019aa:	e84a                	sd	s2,16(sp)
    800019ac:	e44e                	sd	s3,8(sp)
    800019ae:	1800                	addi	s0,sp,48
    800019b0:	892a                	mv	s2,a0
  //TODO change the implimntion to not lock all the list
  if(ind == list->head){
    800019b2:	411c                	lw	a5,0(a0)
    800019b4:	04b78163          	beq	a5,a1,800019f6 <remove_index+0x54>
    800019b8:	84ae                	mv	s1,a1
    remove(list);
    return;  
  }
  acquire(&list->lock);
    800019ba:	00850993          	addi	s3,a0,8
    800019be:	854e                	mv	a0,s3
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	224080e7          	jalr	548(ra) # 80000be4 <acquire>
  if(list->head == -1){
    800019c8:	00092683          	lw	a3,0(s2)
    800019cc:	57fd                	li	a5,-1
    800019ce:	02f68963          	beq	a3,a5,80001a00 <remove_index+0x5e>
    release(&list->lock);
    return;
  }
  struct proc *prev = &proc[list->head] ;
    800019d2:	18800613          	li	a2,392
    800019d6:	02c686b3          	mul	a3,a3,a2
    800019da:	00010717          	auipc	a4,0x10
    800019de:	e3670713          	addi	a4,a4,-458 # 80011810 <proc>
    800019e2:	96ba                	add	a3,a3,a4
  struct proc *curr = &proc[prev->next] ; 
    800019e4:	5e9c                	lw	a5,56(a3)
    800019e6:	02c787b3          	mul	a5,a5,a2
    800019ea:	97ba                	add	a5,a5,a4
  while((curr->index != ind) || (curr->next == -1 )){
    800019ec:	557d                	li	a0,-1
    800019ee:	18800593          	li	a1,392
    prev = curr; 
    curr = &proc[curr->next];
    800019f2:	863a                	mv	a2,a4
  while((curr->index != ind) || (curr->next == -1 )){
    800019f4:	a015                	j	80001a18 <remove_index+0x76>
    remove(list);
    800019f6:	00000097          	auipc	ra,0x0
    800019fa:	eec080e7          	jalr	-276(ra) # 800018e2 <remove>
    return;  
    800019fe:	a081                	j	80001a3e <remove_index+0x9c>
    release(&list->lock);
    80001a00:	854e                	mv	a0,s3
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	296080e7          	jalr	662(ra) # 80000c98 <release>
    return;
    80001a0a:	a815                	j	80001a3e <remove_index+0x9c>
    curr = &proc[curr->next];
    80001a0c:	5f98                	lw	a4,56(a5)
    80001a0e:	02b70733          	mul	a4,a4,a1
    80001a12:	86be                	mv	a3,a5
    80001a14:	00e607b3          	add	a5,a2,a4
  while((curr->index != ind) || (curr->next == -1 )){
    80001a18:	5fd8                	lw	a4,60(a5)
    80001a1a:	fe9719e3          	bne	a4,s1,80001a0c <remove_index+0x6a>
    80001a1e:	5f98                	lw	a4,56(a5)
    80001a20:	fea706e3          	beq	a4,a0,80001a0c <remove_index+0x6a>
  }
  if(curr->index == ind){
    prev->next = curr->next;
    80001a24:	de98                	sw	a4,56(a3)
    if(curr->index == list->tail){
    80001a26:	5fd0                	lw	a2,60(a5)
    80001a28:	00492703          	lw	a4,4(s2)
    80001a2c:	02e60063          	beq	a2,a4,80001a4c <remove_index+0xaa>
      list->tail = prev->index;
    }
    curr->next = -1; 
    80001a30:	577d                	li	a4,-1
    80001a32:	df98                	sw	a4,56(a5)

  // if(curr->index == list->tail){
  //   list->tail = -1;
  // }
  // curr->next = -1;
  release(&list->lock);
    80001a34:	854e                	mv	a0,s3
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	262080e7          	jalr	610(ra) # 80000c98 <release>

}
    80001a3e:	70a2                	ld	ra,40(sp)
    80001a40:	7402                	ld	s0,32(sp)
    80001a42:	64e2                	ld	s1,24(sp)
    80001a44:	6942                	ld	s2,16(sp)
    80001a46:	69a2                	ld	s3,8(sp)
    80001a48:	6145                	addi	sp,sp,48
    80001a4a:	8082                	ret
      list->tail = prev->index;
    80001a4c:	5ed8                	lw	a4,60(a3)
    80001a4e:	00e92223          	sw	a4,4(s2)
    80001a52:	bff9                	j	80001a30 <remove_index+0x8e>

0000000080001a54 <printList>:

void printList(struct headList* list){
    80001a54:	7139                	addi	sp,sp,-64
    80001a56:	fc06                	sd	ra,56(sp)
    80001a58:	f822                	sd	s0,48(sp)
    80001a5a:	f426                	sd	s1,40(sp)
    80001a5c:	f04a                	sd	s2,32(sp)
    80001a5e:	ec4e                	sd	s3,24(sp)
    80001a60:	e852                	sd	s4,16(sp)
    80001a62:	e456                	sd	s5,8(sp)
    80001a64:	e05a                	sd	s6,0(sp)
    80001a66:	0080                	addi	s0,sp,64
    80001a68:	84aa                	mv	s1,a0
  acquire(&list->lock);
    80001a6a:	00850b13          	addi	s6,a0,8
    80001a6e:	855a                	mv	a0,s6
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	174080e7          	jalr	372(ra) # 80000be4 <acquire>
  printf("the list: ");
    80001a78:	00006517          	auipc	a0,0x6
    80001a7c:	76050513          	addi	a0,a0,1888 # 800081d8 <digits+0x198>
    80001a80:	fffff097          	auipc	ra,0xfffff
    80001a84:	b08080e7          	jalr	-1272(ra) # 80000588 <printf>
  if(list->head == -1){
    80001a88:	4084                	lw	s1,0(s1)
    80001a8a:	57fd                	li	a5,-1
    80001a8c:	06f48f63          	beq	s1,a5,80001b0a <printList+0xb6>
    printf("empty\n");
    return;
  }
  struct proc *p = &proc[list->head];
    80001a90:	18800793          	li	a5,392
    80001a94:	02f484b3          	mul	s1,s1,a5
    80001a98:	00010797          	auipc	a5,0x10
    80001a9c:	d7878793          	addi	a5,a5,-648 # 80011810 <proc>
    80001aa0:	94be                	add	s1,s1,a5
  while(p->next != -1 ){ 
    80001aa2:	5c98                	lw	a4,56(s1)
    80001aa4:	57fd                	li	a5,-1
    80001aa6:	02f70a63          	beq	a4,a5,80001ada <printList+0x86>
    printf("%d " , p->index); 
    80001aaa:	00006a97          	auipc	s5,0x6
    80001aae:	746a8a93          	addi	s5,s5,1862 # 800081f0 <digits+0x1b0>
    p = &proc[p->next];
    80001ab2:	18800a13          	li	s4,392
    80001ab6:	00010997          	auipc	s3,0x10
    80001aba:	d5a98993          	addi	s3,s3,-678 # 80011810 <proc>
  while(p->next != -1 ){ 
    80001abe:	597d                	li	s2,-1
    printf("%d " , p->index); 
    80001ac0:	5ccc                	lw	a1,60(s1)
    80001ac2:	8556                	mv	a0,s5
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	ac4080e7          	jalr	-1340(ra) # 80000588 <printf>
    p = &proc[p->next];
    80001acc:	5c84                	lw	s1,56(s1)
    80001ace:	034484b3          	mul	s1,s1,s4
    80001ad2:	94ce                	add	s1,s1,s3
  while(p->next != -1 ){ 
    80001ad4:	5c9c                	lw	a5,56(s1)
    80001ad6:	ff2795e3          	bne	a5,s2,80001ac0 <printList+0x6c>
  }

  printf("%d\n" , p->index); 
    80001ada:	5ccc                	lw	a1,60(s1)
    80001adc:	00007517          	auipc	a0,0x7
    80001ae0:	99450513          	addi	a0,a0,-1644 # 80008470 <states.1760+0x168>
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	aa4080e7          	jalr	-1372(ra) # 80000588 <printf>
  release(&list->lock);
    80001aec:	855a                	mv	a0,s6
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	1aa080e7          	jalr	426(ra) # 80000c98 <release>
  
}
    80001af6:	70e2                	ld	ra,56(sp)
    80001af8:	7442                	ld	s0,48(sp)
    80001afa:	74a2                	ld	s1,40(sp)
    80001afc:	7902                	ld	s2,32(sp)
    80001afe:	69e2                	ld	s3,24(sp)
    80001b00:	6a42                	ld	s4,16(sp)
    80001b02:	6aa2                	ld	s5,8(sp)
    80001b04:	6b02                	ld	s6,0(sp)
    80001b06:	6121                	addi	sp,sp,64
    80001b08:	8082                	ret
    printf("empty\n");
    80001b0a:	00006517          	auipc	a0,0x6
    80001b0e:	6de50513          	addi	a0,a0,1758 # 800081e8 <digits+0x1a8>
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	a76080e7          	jalr	-1418(ra) # 80000588 <printf>
    return;
    80001b1a:	bff1                	j	80001af6 <printList+0xa2>

0000000080001b1c <get_cpu>:
  if(p == 0)
    return -1;
  p->cpu = cpu_num; 
  return cpu_num;
}
int get_cpu(){
    80001b1c:	1141                	addi	sp,sp,-16
    80001b1e:	e422                	sd	s0,8(sp)
    80001b20:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b22:	8512                	mv	a0,tp
  return cpuid();
}
    80001b24:	2501                	sext.w	a0,a0
    80001b26:	6422                	ld	s0,8(sp)
    80001b28:	0141                	addi	sp,sp,16
    80001b2a:	8082                	ret

0000000080001b2c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001b2c:	7139                	addi	sp,sp,-64
    80001b2e:	fc06                	sd	ra,56(sp)
    80001b30:	f822                	sd	s0,48(sp)
    80001b32:	f426                	sd	s1,40(sp)
    80001b34:	f04a                	sd	s2,32(sp)
    80001b36:	ec4e                	sd	s3,24(sp)
    80001b38:	e852                	sd	s4,16(sp)
    80001b3a:	e456                	sd	s5,8(sp)
    80001b3c:	e05a                	sd	s6,0(sp)
    80001b3e:	0080                	addi	s0,sp,64
    80001b40:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b42:	00010497          	auipc	s1,0x10
    80001b46:	cce48493          	addi	s1,s1,-818 # 80011810 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001b4a:	8b26                	mv	s6,s1
    80001b4c:	00006a97          	auipc	s5,0x6
    80001b50:	4b4a8a93          	addi	s5,s5,1204 # 80008000 <etext>
    80001b54:	04000937          	lui	s2,0x4000
    80001b58:	197d                	addi	s2,s2,-1
    80001b5a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b5c:	00016a17          	auipc	s4,0x16
    80001b60:	eb4a0a13          	addi	s4,s4,-332 # 80017a10 <tickslock>
    char *pa = kalloc();
    80001b64:	fffff097          	auipc	ra,0xfffff
    80001b68:	f90080e7          	jalr	-112(ra) # 80000af4 <kalloc>
    80001b6c:	862a                	mv	a2,a0
    if(pa == 0)
    80001b6e:	c131                	beqz	a0,80001bb2 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001b70:	416485b3          	sub	a1,s1,s6
    80001b74:	858d                	srai	a1,a1,0x3
    80001b76:	000ab783          	ld	a5,0(s5)
    80001b7a:	02f585b3          	mul	a1,a1,a5
    80001b7e:	2585                	addiw	a1,a1,1
    80001b80:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b84:	4719                	li	a4,6
    80001b86:	6685                	lui	a3,0x1
    80001b88:	40b905b3          	sub	a1,s2,a1
    80001b8c:	854e                	mv	a0,s3
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	5c2080e7          	jalr	1474(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b96:	18848493          	addi	s1,s1,392
    80001b9a:	fd4495e3          	bne	s1,s4,80001b64 <proc_mapstacks+0x38>
  }
}
    80001b9e:	70e2                	ld	ra,56(sp)
    80001ba0:	7442                	ld	s0,48(sp)
    80001ba2:	74a2                	ld	s1,40(sp)
    80001ba4:	7902                	ld	s2,32(sp)
    80001ba6:	69e2                	ld	s3,24(sp)
    80001ba8:	6a42                	ld	s4,16(sp)
    80001baa:	6aa2                	ld	s5,8(sp)
    80001bac:	6b02                	ld	s6,0(sp)
    80001bae:	6121                	addi	sp,sp,64
    80001bb0:	8082                	ret
      panic("kalloc");
    80001bb2:	00006517          	auipc	a0,0x6
    80001bb6:	64650513          	addi	a0,a0,1606 # 800081f8 <digits+0x1b8>
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	984080e7          	jalr	-1660(ra) # 8000053e <panic>

0000000080001bc2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001bc2:	711d                	addi	sp,sp,-96
    80001bc4:	ec86                	sd	ra,88(sp)
    80001bc6:	e8a2                	sd	s0,80(sp)
    80001bc8:	e4a6                	sd	s1,72(sp)
    80001bca:	e0ca                	sd	s2,64(sp)
    80001bcc:	fc4e                	sd	s3,56(sp)
    80001bce:	f852                	sd	s4,48(sp)
    80001bd0:	f456                	sd	s5,40(sp)
    80001bd2:	f05a                	sd	s6,32(sp)
    80001bd4:	ec5e                	sd	s7,24(sp)
    80001bd6:	e862                	sd	s8,16(sp)
    80001bd8:	e466                	sd	s9,8(sp)
    80001bda:	1080                	addi	s0,sp,96
  struct proc *p;
  int i = 0; 
  for(int j = 0 ; j < NCPU ; j++){
    80001bdc:	0000f497          	auipc	s1,0xf
    80001be0:	6cc48493          	addi	s1,s1,1740 # 800112a8 <readyQueus+0x8>
    80001be4:	0000f997          	auipc	s3,0xf
    80001be8:	7bc98993          	addi	s3,s3,1980 # 800113a0 <cpus>
    80001bec:	4901                	li	s2,0
    readyQueus[j].head = -1; 
    80001bee:	5a7d                	li	s4,-1
    readyQueus[j].tail = -1; 
    initlock(&readyQueus[j].lock , "cpu");
    80001bf0:	00006b17          	auipc	s6,0x6
    80001bf4:	610b0b13          	addi	s6,s6,1552 # 80008200 <digits+0x1c0>
  for(int j = 0 ; j < NCPU ; j++){
    80001bf8:	4aa1                	li	s5,8
    readyQueus[j].head = -1; 
    80001bfa:	ff44ac23          	sw	s4,-8(s1)
    readyQueus[j].tail = -1; 
    80001bfe:	ff44ae23          	sw	s4,-4(s1)
    initlock(&readyQueus[j].lock , "cpu");
    80001c02:	85da                	mv	a1,s6
    80001c04:	8526                	mv	a0,s1
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	f4e080e7          	jalr	-178(ra) # 80000b54 <initlock>
    cpus[j].index = j ;
    80001c0e:	0929a023          	sw	s2,128(s3)
  for(int j = 0 ; j < NCPU ; j++){
    80001c12:	2905                	addiw	s2,s2,1
    80001c14:	02048493          	addi	s1,s1,32
    80001c18:	08898993          	addi	s3,s3,136
    80001c1c:	fd591fe3          	bne	s2,s5,80001bfa <procinit+0x38>
  }
  initlock(&zombies.lock , "zombies");
    80001c20:	00006597          	auipc	a1,0x6
    80001c24:	5e858593          	addi	a1,a1,1512 # 80008208 <digits+0x1c8>
    80001c28:	00007517          	auipc	a0,0x7
    80001c2c:	c5050513          	addi	a0,a0,-944 # 80008878 <zombies+0x8>
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	f24080e7          	jalr	-220(ra) # 80000b54 <initlock>
  initlock(&sleeping.lock , "sleepings;");
    80001c38:	00006597          	auipc	a1,0x6
    80001c3c:	5d858593          	addi	a1,a1,1496 # 80008210 <digits+0x1d0>
    80001c40:	00007517          	auipc	a0,0x7
    80001c44:	c5850513          	addi	a0,a0,-936 # 80008898 <sleeping+0x8>
    80001c48:	fffff097          	auipc	ra,0xfffff
    80001c4c:	f0c080e7          	jalr	-244(ra) # 80000b54 <initlock>
  initlock(&unusing.lock , "unsing");
    80001c50:	00006597          	auipc	a1,0x6
    80001c54:	5d058593          	addi	a1,a1,1488 # 80008220 <digits+0x1e0>
    80001c58:	00007517          	auipc	a0,0x7
    80001c5c:	c6050513          	addi	a0,a0,-928 # 800088b8 <unusing+0x8>
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	ef4080e7          	jalr	-268(ra) # 80000b54 <initlock>
  
  initlock(&pid_lock, "nextpid");
    80001c68:	00006597          	auipc	a1,0x6
    80001c6c:	5c058593          	addi	a1,a1,1472 # 80008228 <digits+0x1e8>
    80001c70:	00010517          	auipc	a0,0x10
    80001c74:	b7050513          	addi	a0,a0,-1168 # 800117e0 <pid_lock>
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	edc080e7          	jalr	-292(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c80:	00006597          	auipc	a1,0x6
    80001c84:	5b058593          	addi	a1,a1,1456 # 80008230 <digits+0x1f0>
    80001c88:	00010517          	auipc	a0,0x10
    80001c8c:	b7050513          	addi	a0,a0,-1168 # 800117f8 <wait_lock>
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ec4080e7          	jalr	-316(ra) # 80000b54 <initlock>
  int i = 0; 
    80001c98:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9a:	00010497          	auipc	s1,0x10
    80001c9e:	b7648493          	addi	s1,s1,-1162 # 80011810 <proc>
      initlock(&p->lock, "proc");
    80001ca2:	00006c97          	auipc	s9,0x6
    80001ca6:	59ec8c93          	addi	s9,s9,1438 # 80008240 <digits+0x200>
      p->kstack = KSTACK((int) (p - proc));
    80001caa:	8c26                	mv	s8,s1
    80001cac:	00006b97          	auipc	s7,0x6
    80001cb0:	354b8b93          	addi	s7,s7,852 # 80008000 <etext>
    80001cb4:	040009b7          	lui	s3,0x4000
    80001cb8:	19fd                	addi	s3,s3,-1
    80001cba:	09b2                	slli	s3,s3,0xc
      p->index = i++;
      p->next = -1;
    80001cbc:	5b7d                	li	s6,-1
      p->cpu = 0; 
      add(&unusing , p->index);
    80001cbe:	00007a97          	auipc	s5,0x7
    80001cc2:	bf2a8a93          	addi	s5,s5,-1038 # 800088b0 <unusing>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cc6:	00016a17          	auipc	s4,0x16
    80001cca:	d4aa0a13          	addi	s4,s4,-694 # 80017a10 <tickslock>
      initlock(&p->lock, "proc");
    80001cce:	85e6                	mv	a1,s9
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	e82080e7          	jalr	-382(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001cda:	418487b3          	sub	a5,s1,s8
    80001cde:	878d                	srai	a5,a5,0x3
    80001ce0:	000bb703          	ld	a4,0(s7)
    80001ce4:	02e787b3          	mul	a5,a5,a4
    80001ce8:	2785                	addiw	a5,a5,1
    80001cea:	00d7979b          	slliw	a5,a5,0xd
    80001cee:	40f987b3          	sub	a5,s3,a5
    80001cf2:	f0bc                	sd	a5,96(s1)
      p->index = i++;
    80001cf4:	85ca                	mv	a1,s2
    80001cf6:	0324ae23          	sw	s2,60(s1)
    80001cfa:	2905                	addiw	s2,s2,1
      p->next = -1;
    80001cfc:	0364ac23          	sw	s6,56(s1)
      p->cpu = 0; 
    80001d00:	0204aa23          	sw	zero,52(s1)
      add(&unusing , p->index);
    80001d04:	8556                	mv	a0,s5
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	b38080e7          	jalr	-1224(ra) # 8000183e <add>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0e:	18848493          	addi	s1,s1,392
    80001d12:	fb449ee3          	bne	s1,s4,80001cce <procinit+0x10c>
  }
}
    80001d16:	60e6                	ld	ra,88(sp)
    80001d18:	6446                	ld	s0,80(sp)
    80001d1a:	64a6                	ld	s1,72(sp)
    80001d1c:	6906                	ld	s2,64(sp)
    80001d1e:	79e2                	ld	s3,56(sp)
    80001d20:	7a42                	ld	s4,48(sp)
    80001d22:	7aa2                	ld	s5,40(sp)
    80001d24:	7b02                	ld	s6,32(sp)
    80001d26:	6be2                	ld	s7,24(sp)
    80001d28:	6c42                	ld	s8,16(sp)
    80001d2a:	6ca2                	ld	s9,8(sp)
    80001d2c:	6125                	addi	sp,sp,96
    80001d2e:	8082                	ret

0000000080001d30 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001d30:	1141                	addi	sp,sp,-16
    80001d32:	e422                	sd	s0,8(sp)
    80001d34:	0800                	addi	s0,sp,16
    80001d36:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d38:	2501                	sext.w	a0,a0
    80001d3a:	6422                	ld	s0,8(sp)
    80001d3c:	0141                	addi	sp,sp,16
    80001d3e:	8082                	ret

0000000080001d40 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001d40:	1141                	addi	sp,sp,-16
    80001d42:	e422                	sd	s0,8(sp)
    80001d44:	0800                	addi	s0,sp,16
    80001d46:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d48:	0007851b          	sext.w	a0,a5
    80001d4c:	00451793          	slli	a5,a0,0x4
    80001d50:	97aa                	add	a5,a5,a0
    80001d52:	078e                	slli	a5,a5,0x3
  return c;
}
    80001d54:	0000f517          	auipc	a0,0xf
    80001d58:	64c50513          	addi	a0,a0,1612 # 800113a0 <cpus>
    80001d5c:	953e                	add	a0,a0,a5
    80001d5e:	6422                	ld	s0,8(sp)
    80001d60:	0141                	addi	sp,sp,16
    80001d62:	8082                	ret

0000000080001d64 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001d64:	1101                	addi	sp,sp,-32
    80001d66:	ec06                	sd	ra,24(sp)
    80001d68:	e822                	sd	s0,16(sp)
    80001d6a:	e426                	sd	s1,8(sp)
    80001d6c:	1000                	addi	s0,sp,32
  push_off();
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	e2a080e7          	jalr	-470(ra) # 80000b98 <push_off>
    80001d76:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d78:	0007871b          	sext.w	a4,a5
    80001d7c:	00471793          	slli	a5,a4,0x4
    80001d80:	97ba                	add	a5,a5,a4
    80001d82:	078e                	slli	a5,a5,0x3
    80001d84:	0000f717          	auipc	a4,0xf
    80001d88:	51c70713          	addi	a4,a4,1308 # 800112a0 <readyQueus>
    80001d8c:	97ba                	add	a5,a5,a4
    80001d8e:	1007b483          	ld	s1,256(a5)
  pop_off();
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	ea6080e7          	jalr	-346(ra) # 80000c38 <pop_off>
  return p;
}
    80001d9a:	8526                	mv	a0,s1
    80001d9c:	60e2                	ld	ra,24(sp)
    80001d9e:	6442                	ld	s0,16(sp)
    80001da0:	64a2                	ld	s1,8(sp)
    80001da2:	6105                	addi	sp,sp,32
    80001da4:	8082                	ret

0000000080001da6 <set_cpu>:
int set_cpu(int cpu_num){
    80001da6:	1101                	addi	sp,sp,-32
    80001da8:	ec06                	sd	ra,24(sp)
    80001daa:	e822                	sd	s0,16(sp)
    80001dac:	e426                	sd	s1,8(sp)
    80001dae:	1000                	addi	s0,sp,32
    80001db0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	fb2080e7          	jalr	-78(ra) # 80001d64 <myproc>
  if(p == 0)
    80001dba:	c901                	beqz	a0,80001dca <set_cpu+0x24>
  p->cpu = cpu_num; 
    80001dbc:	d944                	sw	s1,52(a0)
  return cpu_num;
    80001dbe:	8526                	mv	a0,s1
}
    80001dc0:	60e2                	ld	ra,24(sp)
    80001dc2:	6442                	ld	s0,16(sp)
    80001dc4:	64a2                	ld	s1,8(sp)
    80001dc6:	6105                	addi	sp,sp,32
    80001dc8:	8082                	ret
    return -1;
    80001dca:	557d                	li	a0,-1
    80001dcc:	bfd5                	j	80001dc0 <set_cpu+0x1a>

0000000080001dce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001dce:	1141                	addi	sp,sp,-16
    80001dd0:	e406                	sd	ra,8(sp)
    80001dd2:	e022                	sd	s0,0(sp)
    80001dd4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	f8e080e7          	jalr	-114(ra) # 80001d64 <myproc>
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	eba080e7          	jalr	-326(ra) # 80000c98 <release>

  if (first) {
    80001de6:	00007797          	auipc	a5,0x7
    80001dea:	a7a7a783          	lw	a5,-1414(a5) # 80008860 <first.1723>
    80001dee:	eb89                	bnez	a5,80001e00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001df0:	00001097          	auipc	ra,0x1
    80001df4:	ca0080e7          	jalr	-864(ra) # 80002a90 <usertrapret>
}
    80001df8:	60a2                	ld	ra,8(sp)
    80001dfa:	6402                	ld	s0,0(sp)
    80001dfc:	0141                	addi	sp,sp,16
    80001dfe:	8082                	ret
    first = 0;
    80001e00:	00007797          	auipc	a5,0x7
    80001e04:	a607a023          	sw	zero,-1440(a5) # 80008860 <first.1723>
    fsinit(ROOTDEV);
    80001e08:	4505                	li	a0,1
    80001e0a:	00002097          	auipc	ra,0x2
    80001e0e:	9c8080e7          	jalr	-1592(ra) # 800037d2 <fsinit>
    80001e12:	bff9                	j	80001df0 <forkret+0x22>

0000000080001e14 <allocpid>:
allocpid() {
    80001e14:	1101                	addi	sp,sp,-32
    80001e16:	ec06                	sd	ra,24(sp)
    80001e18:	e822                	sd	s0,16(sp)
    80001e1a:	e426                	sd	s1,8(sp)
    80001e1c:	e04a                	sd	s2,0(sp)
    80001e1e:	1000                	addi	s0,sp,32
    pid = nextpid; 
    80001e20:	00007917          	auipc	s2,0x7
    80001e24:	a4490913          	addi	s2,s2,-1468 # 80008864 <nextpid>
    80001e28:	00092483          	lw	s1,0(s2)
  }while(cas(&nextpid , pid , pid + 1)); 
    80001e2c:	0014861b          	addiw	a2,s1,1
    80001e30:	85a6                	mv	a1,s1
    80001e32:	854a                	mv	a0,s2
    80001e34:	00004097          	auipc	ra,0x4
    80001e38:	7a2080e7          	jalr	1954(ra) # 800065d6 <cas>
    80001e3c:	f575                	bnez	a0,80001e28 <allocpid+0x14>
}
    80001e3e:	8526                	mv	a0,s1
    80001e40:	60e2                	ld	ra,24(sp)
    80001e42:	6442                	ld	s0,16(sp)
    80001e44:	64a2                	ld	s1,8(sp)
    80001e46:	6902                	ld	s2,0(sp)
    80001e48:	6105                	addi	sp,sp,32
    80001e4a:	8082                	ret

0000000080001e4c <proc_pagetable>:
{
    80001e4c:	1101                	addi	sp,sp,-32
    80001e4e:	ec06                	sd	ra,24(sp)
    80001e50:	e822                	sd	s0,16(sp)
    80001e52:	e426                	sd	s1,8(sp)
    80001e54:	e04a                	sd	s2,0(sp)
    80001e56:	1000                	addi	s0,sp,32
    80001e58:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	4e0080e7          	jalr	1248(ra) # 8000133a <uvmcreate>
    80001e62:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e64:	c121                	beqz	a0,80001ea4 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e66:	4729                	li	a4,10
    80001e68:	00005697          	auipc	a3,0x5
    80001e6c:	19868693          	addi	a3,a3,408 # 80007000 <_trampoline>
    80001e70:	6605                	lui	a2,0x1
    80001e72:	040005b7          	lui	a1,0x4000
    80001e76:	15fd                	addi	a1,a1,-1
    80001e78:	05b2                	slli	a1,a1,0xc
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	236080e7          	jalr	566(ra) # 800010b0 <mappages>
    80001e82:	02054863          	bltz	a0,80001eb2 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e86:	4719                	li	a4,6
    80001e88:	07893683          	ld	a3,120(s2)
    80001e8c:	6605                	lui	a2,0x1
    80001e8e:	020005b7          	lui	a1,0x2000
    80001e92:	15fd                	addi	a1,a1,-1
    80001e94:	05b6                	slli	a1,a1,0xd
    80001e96:	8526                	mv	a0,s1
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	218080e7          	jalr	536(ra) # 800010b0 <mappages>
    80001ea0:	02054163          	bltz	a0,80001ec2 <proc_pagetable+0x76>
}
    80001ea4:	8526                	mv	a0,s1
    80001ea6:	60e2                	ld	ra,24(sp)
    80001ea8:	6442                	ld	s0,16(sp)
    80001eaa:	64a2                	ld	s1,8(sp)
    80001eac:	6902                	ld	s2,0(sp)
    80001eae:	6105                	addi	sp,sp,32
    80001eb0:	8082                	ret
    uvmfree(pagetable, 0);
    80001eb2:	4581                	li	a1,0
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	680080e7          	jalr	1664(ra) # 80001536 <uvmfree>
    return 0;
    80001ebe:	4481                	li	s1,0
    80001ec0:	b7d5                	j	80001ea4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ec2:	4681                	li	a3,0
    80001ec4:	4605                	li	a2,1
    80001ec6:	040005b7          	lui	a1,0x4000
    80001eca:	15fd                	addi	a1,a1,-1
    80001ecc:	05b2                	slli	a1,a1,0xc
    80001ece:	8526                	mv	a0,s1
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	3a6080e7          	jalr	934(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ed8:	4581                	li	a1,0
    80001eda:	8526                	mv	a0,s1
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	65a080e7          	jalr	1626(ra) # 80001536 <uvmfree>
    return 0;
    80001ee4:	4481                	li	s1,0
    80001ee6:	bf7d                	j	80001ea4 <proc_pagetable+0x58>

0000000080001ee8 <proc_freepagetable>:
{
    80001ee8:	1101                	addi	sp,sp,-32
    80001eea:	ec06                	sd	ra,24(sp)
    80001eec:	e822                	sd	s0,16(sp)
    80001eee:	e426                	sd	s1,8(sp)
    80001ef0:	e04a                	sd	s2,0(sp)
    80001ef2:	1000                	addi	s0,sp,32
    80001ef4:	84aa                	mv	s1,a0
    80001ef6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ef8:	4681                	li	a3,0
    80001efa:	4605                	li	a2,1
    80001efc:	040005b7          	lui	a1,0x4000
    80001f00:	15fd                	addi	a1,a1,-1
    80001f02:	05b2                	slli	a1,a1,0xc
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	372080e7          	jalr	882(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f0c:	4681                	li	a3,0
    80001f0e:	4605                	li	a2,1
    80001f10:	020005b7          	lui	a1,0x2000
    80001f14:	15fd                	addi	a1,a1,-1
    80001f16:	05b6                	slli	a1,a1,0xd
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	35c080e7          	jalr	860(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f22:	85ca                	mv	a1,s2
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	610080e7          	jalr	1552(ra) # 80001536 <uvmfree>
}
    80001f2e:	60e2                	ld	ra,24(sp)
    80001f30:	6442                	ld	s0,16(sp)
    80001f32:	64a2                	ld	s1,8(sp)
    80001f34:	6902                	ld	s2,0(sp)
    80001f36:	6105                	addi	sp,sp,32
    80001f38:	8082                	ret

0000000080001f3a <freeproc>:
{
    80001f3a:	1101                	addi	sp,sp,-32
    80001f3c:	ec06                	sd	ra,24(sp)
    80001f3e:	e822                	sd	s0,16(sp)
    80001f40:	e426                	sd	s1,8(sp)
    80001f42:	1000                	addi	s0,sp,32
    80001f44:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f46:	7d28                	ld	a0,120(a0)
    80001f48:	c509                	beqz	a0,80001f52 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	aae080e7          	jalr	-1362(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001f52:	0604bc23          	sd	zero,120(s1)
  if(p->pagetable)
    80001f56:	78a8                	ld	a0,112(s1)
    80001f58:	c511                	beqz	a0,80001f64 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f5a:	74ac                	ld	a1,104(s1)
    80001f5c:	00000097          	auipc	ra,0x0
    80001f60:	f8c080e7          	jalr	-116(ra) # 80001ee8 <proc_freepagetable>
  p->pagetable = 0;
    80001f64:	0604b823          	sd	zero,112(s1)
  p->sz = 0;
    80001f68:	0604b423          	sd	zero,104(s1)
  p->pid = 0;
    80001f6c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001f70:	0404bc23          	sd	zero,88(s1)
  p->name[0] = 0;
    80001f74:	16048c23          	sb	zero,376(s1)
  p->chan = 0;
    80001f78:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001f7c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001f80:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001f84:	0004ac23          	sw	zero,24(s1)
}
    80001f88:	60e2                	ld	ra,24(sp)
    80001f8a:	6442                	ld	s0,16(sp)
    80001f8c:	64a2                	ld	s1,8(sp)
    80001f8e:	6105                	addi	sp,sp,32
    80001f90:	8082                	ret

0000000080001f92 <allocproc>:
{
    80001f92:	7179                	addi	sp,sp,-48
    80001f94:	f406                	sd	ra,40(sp)
    80001f96:	f022                	sd	s0,32(sp)
    80001f98:	ec26                	sd	s1,24(sp)
    80001f9a:	e84a                	sd	s2,16(sp)
    80001f9c:	e44e                	sd	s3,8(sp)
    80001f9e:	1800                	addi	s0,sp,48
  p = remove(&unusing);
    80001fa0:	00007517          	auipc	a0,0x7
    80001fa4:	91050513          	addi	a0,a0,-1776 # 800088b0 <unusing>
    80001fa8:	00000097          	auipc	ra,0x0
    80001fac:	93a080e7          	jalr	-1734(ra) # 800018e2 <remove>
    80001fb0:	84aa                	mv	s1,a0
  if(p == 0)
    80001fb2:	cd29                	beqz	a0,8000200c <allocproc+0x7a>
  acquire(&p->lock);
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	c30080e7          	jalr	-976(ra) # 80000be4 <acquire>
  p->pid = allocpid();
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	e58080e7          	jalr	-424(ra) # 80001e14 <allocpid>
    80001fc4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001fc6:	4785                	li	a5,1
    80001fc8:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	b2a080e7          	jalr	-1238(ra) # 80000af4 <kalloc>
    80001fd2:	892a                	mv	s2,a0
    80001fd4:	fca8                	sd	a0,120(s1)
    80001fd6:	c139                	beqz	a0,8000201c <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001fd8:	8526                	mv	a0,s1
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	e72080e7          	jalr	-398(ra) # 80001e4c <proc_pagetable>
    80001fe2:	892a                	mv	s2,a0
    80001fe4:	f8a8                	sd	a0,112(s1)
  if(p->pagetable == 0){
    80001fe6:	c539                	beqz	a0,80002034 <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001fe8:	07000613          	li	a2,112
    80001fec:	4581                	li	a1,0
    80001fee:	08048513          	addi	a0,s1,128
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	cee080e7          	jalr	-786(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80001ffa:	00000797          	auipc	a5,0x0
    80001ffe:	dd478793          	addi	a5,a5,-556 # 80001dce <forkret>
    80002002:	e0dc                	sd	a5,128(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002004:	70bc                	ld	a5,96(s1)
    80002006:	6705                	lui	a4,0x1
    80002008:	97ba                	add	a5,a5,a4
    8000200a:	e4dc                	sd	a5,136(s1)
}
    8000200c:	8526                	mv	a0,s1
    8000200e:	70a2                	ld	ra,40(sp)
    80002010:	7402                	ld	s0,32(sp)
    80002012:	64e2                	ld	s1,24(sp)
    80002014:	6942                	ld	s2,16(sp)
    80002016:	69a2                	ld	s3,8(sp)
    80002018:	6145                	addi	sp,sp,48
    8000201a:	8082                	ret
    freeproc(p);
    8000201c:	8526                	mv	a0,s1
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	f1c080e7          	jalr	-228(ra) # 80001f3a <freeproc>
    release(&p->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	c70080e7          	jalr	-912(ra) # 80000c98 <release>
    return 0;
    80002030:	84ca                	mv	s1,s2
    80002032:	bfe9                	j	8000200c <allocproc+0x7a>
    freeproc(p);
    80002034:	8526                	mv	a0,s1
    80002036:	00000097          	auipc	ra,0x0
    8000203a:	f04080e7          	jalr	-252(ra) # 80001f3a <freeproc>
    release(&p->lock);
    8000203e:	8526                	mv	a0,s1
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	c58080e7          	jalr	-936(ra) # 80000c98 <release>
    return 0;
    80002048:	84ca                	mv	s1,s2
    8000204a:	b7c9                	j	8000200c <allocproc+0x7a>

000000008000204c <userinit>:
{
    8000204c:	1101                	addi	sp,sp,-32
    8000204e:	ec06                	sd	ra,24(sp)
    80002050:	e822                	sd	s0,16(sp)
    80002052:	e426                	sd	s1,8(sp)
    80002054:	1000                	addi	s0,sp,32
  p = allocproc();
    80002056:	00000097          	auipc	ra,0x0
    8000205a:	f3c080e7          	jalr	-196(ra) # 80001f92 <allocproc>
    8000205e:	84aa                	mv	s1,a0
  initproc = p;
    80002060:	00007797          	auipc	a5,0x7
    80002064:	fca7b423          	sd	a0,-56(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002068:	03400613          	li	a2,52
    8000206c:	00007597          	auipc	a1,0x7
    80002070:	86458593          	addi	a1,a1,-1948 # 800088d0 <initcode>
    80002074:	7928                	ld	a0,112(a0)
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	2f2080e7          	jalr	754(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    8000207e:	6785                	lui	a5,0x1
    80002080:	f4bc                	sd	a5,104(s1)
  p->trapframe->epc = 0;      // user program counter
    80002082:	7cb8                	ld	a4,120(s1)
    80002084:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002088:	7cb8                	ld	a4,120(s1)
    8000208a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000208c:	4641                	li	a2,16
    8000208e:	00006597          	auipc	a1,0x6
    80002092:	1ba58593          	addi	a1,a1,442 # 80008248 <digits+0x208>
    80002096:	17848513          	addi	a0,s1,376
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	d98080e7          	jalr	-616(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    800020a2:	00006517          	auipc	a0,0x6
    800020a6:	1b650513          	addi	a0,a0,438 # 80008258 <digits+0x218>
    800020aa:	00002097          	auipc	ra,0x2
    800020ae:	156080e7          	jalr	342(ra) # 80004200 <namei>
    800020b2:	16a4b823          	sd	a0,368(s1)
  p->state = RUNNABLE;
    800020b6:	478d                	li	a5,3
    800020b8:	cc9c                	sw	a5,24(s1)
  add(&readyQueus[p->cpu] , p->index );
    800020ba:	58dc                	lw	a5,52(s1)
    800020bc:	0796                	slli	a5,a5,0x5
    800020be:	5ccc                	lw	a1,60(s1)
    800020c0:	0000f517          	auipc	a0,0xf
    800020c4:	1e050513          	addi	a0,a0,480 # 800112a0 <readyQueus>
    800020c8:	953e                	add	a0,a0,a5
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	774080e7          	jalr	1908(ra) # 8000183e <add>
  release(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	bc4080e7          	jalr	-1084(ra) # 80000c98 <release>
}
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <growproc>:
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	c70080e7          	jalr	-912(ra) # 80001d64 <myproc>
    800020fc:	892a                	mv	s2,a0
  sz = p->sz;
    800020fe:	752c                	ld	a1,104(a0)
    80002100:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002104:	00904f63          	bgtz	s1,80002122 <growproc+0x3c>
  } else if(n < 0){
    80002108:	0204cc63          	bltz	s1,80002140 <growproc+0x5a>
  p->sz = sz;
    8000210c:	1602                	slli	a2,a2,0x20
    8000210e:	9201                	srli	a2,a2,0x20
    80002110:	06c93423          	sd	a2,104(s2)
  return 0;
    80002114:	4501                	li	a0,0
}
    80002116:	60e2                	ld	ra,24(sp)
    80002118:	6442                	ld	s0,16(sp)
    8000211a:	64a2                	ld	s1,8(sp)
    8000211c:	6902                	ld	s2,0(sp)
    8000211e:	6105                	addi	sp,sp,32
    80002120:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002122:	9e25                	addw	a2,a2,s1
    80002124:	1602                	slli	a2,a2,0x20
    80002126:	9201                	srli	a2,a2,0x20
    80002128:	1582                	slli	a1,a1,0x20
    8000212a:	9181                	srli	a1,a1,0x20
    8000212c:	7928                	ld	a0,112(a0)
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	2f4080e7          	jalr	756(ra) # 80001422 <uvmalloc>
    80002136:	0005061b          	sext.w	a2,a0
    8000213a:	fa69                	bnez	a2,8000210c <growproc+0x26>
      return -1;
    8000213c:	557d                	li	a0,-1
    8000213e:	bfe1                	j	80002116 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002140:	9e25                	addw	a2,a2,s1
    80002142:	1602                	slli	a2,a2,0x20
    80002144:	9201                	srli	a2,a2,0x20
    80002146:	1582                	slli	a1,a1,0x20
    80002148:	9181                	srli	a1,a1,0x20
    8000214a:	7928                	ld	a0,112(a0)
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	28e080e7          	jalr	654(ra) # 800013da <uvmdealloc>
    80002154:	0005061b          	sext.w	a2,a0
    80002158:	bf55                	j	8000210c <growproc+0x26>

000000008000215a <fork>:
{
    8000215a:	7179                	addi	sp,sp,-48
    8000215c:	f406                	sd	ra,40(sp)
    8000215e:	f022                	sd	s0,32(sp)
    80002160:	ec26                	sd	s1,24(sp)
    80002162:	e84a                	sd	s2,16(sp)
    80002164:	e44e                	sd	s3,8(sp)
    80002166:	e052                	sd	s4,0(sp)
    80002168:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000216a:	00000097          	auipc	ra,0x0
    8000216e:	bfa080e7          	jalr	-1030(ra) # 80001d64 <myproc>
    80002172:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80002174:	00000097          	auipc	ra,0x0
    80002178:	e1e080e7          	jalr	-482(ra) # 80001f92 <allocproc>
    8000217c:	12050d63          	beqz	a0,800022b6 <fork+0x15c>
    80002180:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002182:	0689b603          	ld	a2,104(s3) # 4000068 <_entry-0x7bffff98>
    80002186:	792c                	ld	a1,112(a0)
    80002188:	0709b503          	ld	a0,112(s3)
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	3e2080e7          	jalr	994(ra) # 8000156e <uvmcopy>
    80002194:	04054a63          	bltz	a0,800021e8 <fork+0x8e>
  np->sz = p->sz;
    80002198:	0689b783          	ld	a5,104(s3)
    8000219c:	06f93423          	sd	a5,104(s2)
  np->cpu = p->cpu;
    800021a0:	0349a783          	lw	a5,52(s3)
    800021a4:	02f92a23          	sw	a5,52(s2)
  *(np->trapframe) = *(p->trapframe);
    800021a8:	0789b683          	ld	a3,120(s3)
    800021ac:	87b6                	mv	a5,a3
    800021ae:	07893703          	ld	a4,120(s2)
    800021b2:	12068693          	addi	a3,a3,288
    800021b6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800021ba:	6788                	ld	a0,8(a5)
    800021bc:	6b8c                	ld	a1,16(a5)
    800021be:	6f90                	ld	a2,24(a5)
    800021c0:	01073023          	sd	a6,0(a4)
    800021c4:	e708                	sd	a0,8(a4)
    800021c6:	eb0c                	sd	a1,16(a4)
    800021c8:	ef10                	sd	a2,24(a4)
    800021ca:	02078793          	addi	a5,a5,32
    800021ce:	02070713          	addi	a4,a4,32
    800021d2:	fed792e3          	bne	a5,a3,800021b6 <fork+0x5c>
  np->trapframe->a0 = 0;
    800021d6:	07893783          	ld	a5,120(s2)
    800021da:	0607b823          	sd	zero,112(a5)
    800021de:	0f000493          	li	s1,240
  for(i = 0; i < NOFILE; i++)
    800021e2:	17000a13          	li	s4,368
    800021e6:	a03d                	j	80002214 <fork+0xba>
    freeproc(np);
    800021e8:	854a                	mv	a0,s2
    800021ea:	00000097          	auipc	ra,0x0
    800021ee:	d50080e7          	jalr	-688(ra) # 80001f3a <freeproc>
    release(&np->lock);
    800021f2:	854a                	mv	a0,s2
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	aa4080e7          	jalr	-1372(ra) # 80000c98 <release>
    return -1;
    800021fc:	5a7d                	li	s4,-1
    800021fe:	a05d                	j	800022a4 <fork+0x14a>
      np->ofile[i] = filedup(p->ofile[i]);
    80002200:	00002097          	auipc	ra,0x2
    80002204:	696080e7          	jalr	1686(ra) # 80004896 <filedup>
    80002208:	009907b3          	add	a5,s2,s1
    8000220c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000220e:	04a1                	addi	s1,s1,8
    80002210:	01448763          	beq	s1,s4,8000221e <fork+0xc4>
    if(p->ofile[i])
    80002214:	009987b3          	add	a5,s3,s1
    80002218:	6388                	ld	a0,0(a5)
    8000221a:	f17d                	bnez	a0,80002200 <fork+0xa6>
    8000221c:	bfcd                	j	8000220e <fork+0xb4>
  np->cwd = idup(p->cwd);
    8000221e:	1709b503          	ld	a0,368(s3)
    80002222:	00001097          	auipc	ra,0x1
    80002226:	7ea080e7          	jalr	2026(ra) # 80003a0c <idup>
    8000222a:	16a93823          	sd	a0,368(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000222e:	4641                	li	a2,16
    80002230:	17898593          	addi	a1,s3,376
    80002234:	17890513          	addi	a0,s2,376
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	bfa080e7          	jalr	-1030(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80002240:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    80002244:	854a                	mv	a0,s2
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	a52080e7          	jalr	-1454(ra) # 80000c98 <release>
  acquire(&wait_lock);
    8000224e:	0000f497          	auipc	s1,0xf
    80002252:	5aa48493          	addi	s1,s1,1450 # 800117f8 <wait_lock>
    80002256:	8526                	mv	a0,s1
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	98c080e7          	jalr	-1652(ra) # 80000be4 <acquire>
  np->parent = p;
    80002260:	05393c23          	sd	s3,88(s2)
  release(&wait_lock);
    80002264:	8526                	mv	a0,s1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	a32080e7          	jalr	-1486(ra) # 80000c98 <release>
  acquire(&np->lock);
    8000226e:	854a                	mv	a0,s2
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	974080e7          	jalr	-1676(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80002278:	478d                	li	a5,3
    8000227a:	00f92c23          	sw	a5,24(s2)
  add(&readyQueus[np->cpu], np->index);
    8000227e:	03492783          	lw	a5,52(s2)
    80002282:	0796                	slli	a5,a5,0x5
    80002284:	03c92583          	lw	a1,60(s2)
    80002288:	0000f517          	auipc	a0,0xf
    8000228c:	01850513          	addi	a0,a0,24 # 800112a0 <readyQueus>
    80002290:	953e                	add	a0,a0,a5
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	5ac080e7          	jalr	1452(ra) # 8000183e <add>
  release(&np->lock);
    8000229a:	854a                	mv	a0,s2
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	9fc080e7          	jalr	-1540(ra) # 80000c98 <release>
}
    800022a4:	8552                	mv	a0,s4
    800022a6:	70a2                	ld	ra,40(sp)
    800022a8:	7402                	ld	s0,32(sp)
    800022aa:	64e2                	ld	s1,24(sp)
    800022ac:	6942                	ld	s2,16(sp)
    800022ae:	69a2                	ld	s3,8(sp)
    800022b0:	6a02                	ld	s4,0(sp)
    800022b2:	6145                	addi	sp,sp,48
    800022b4:	8082                	ret
    return -1;
    800022b6:	5a7d                	li	s4,-1
    800022b8:	b7f5                	j	800022a4 <fork+0x14a>

00000000800022ba <scheduler>:
{
    800022ba:	7139                	addi	sp,sp,-64
    800022bc:	fc06                	sd	ra,56(sp)
    800022be:	f822                	sd	s0,48(sp)
    800022c0:	f426                	sd	s1,40(sp)
    800022c2:	f04a                	sd	s2,32(sp)
    800022c4:	ec4e                	sd	s3,24(sp)
    800022c6:	e852                	sd	s4,16(sp)
    800022c8:	e456                	sd	s5,8(sp)
    800022ca:	0080                	addi	s0,sp,64
    800022cc:	8792                	mv	a5,tp
  int id = r_tp();
    800022ce:	2781                	sext.w	a5,a5
  c->proc = 0;
    800022d0:	00479713          	slli	a4,a5,0x4
    800022d4:	00f706b3          	add	a3,a4,a5
    800022d8:	00369613          	slli	a2,a3,0x3
    800022dc:	0000f697          	auipc	a3,0xf
    800022e0:	fc468693          	addi	a3,a3,-60 # 800112a0 <readyQueus>
    800022e4:	96b2                	add	a3,a3,a2
    800022e6:	1006b023          	sd	zero,256(a3)
    swtch(&c->context, &p->context);
    800022ea:	0000f717          	auipc	a4,0xf
    800022ee:	0be70713          	addi	a4,a4,190 # 800113a8 <cpus+0x8>
    800022f2:	00e60a33          	add	s4,a2,a4
    p = remove(&readyQueus[c->index]);
    800022f6:	0000f997          	auipc	s3,0xf
    800022fa:	faa98993          	addi	s3,s3,-86 # 800112a0 <readyQueus>
    800022fe:	8936                	mv	s2,a3
    p->state = RUNNING;
    80002300:	4a91                	li	s5,4
    80002302:	a815                	j	80002336 <scheduler+0x7c>
    acquire(&p->lock);
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	8e0080e7          	jalr	-1824(ra) # 80000be4 <acquire>
    p->state = RUNNING;
    8000230c:	0154ac23          	sw	s5,24(s1)
    p->cpu = c->index;
    80002310:	18092783          	lw	a5,384(s2)
    80002314:	d8dc                	sw	a5,52(s1)
    c->proc = p;
    80002316:	10993023          	sd	s1,256(s2)
    swtch(&c->context, &p->context);
    8000231a:	08048593          	addi	a1,s1,128
    8000231e:	8552                	mv	a0,s4
    80002320:	00000097          	auipc	ra,0x0
    80002324:	6c6080e7          	jalr	1734(ra) # 800029e6 <swtch>
    c->proc = 0;
    80002328:	10093023          	sd	zero,256(s2)
    release(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	96a080e7          	jalr	-1686(ra) # 80000c98 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002336:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000233a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000233e:	10079073          	csrw	sstatus,a5
    p = remove(&readyQueus[c->index]);
    80002342:	18092503          	lw	a0,384(s2)
    80002346:	0516                	slli	a0,a0,0x5
    80002348:	954e                	add	a0,a0,s3
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	598080e7          	jalr	1432(ra) # 800018e2 <remove>
    80002352:	84aa                	mv	s1,a0
    }while(p == 0);
    80002354:	f945                	bnez	a0,80002304 <scheduler+0x4a>
    80002356:	b7f5                	j	80002342 <scheduler+0x88>

0000000080002358 <sched>:
{
    80002358:	7179                	addi	sp,sp,-48
    8000235a:	f406                	sd	ra,40(sp)
    8000235c:	f022                	sd	s0,32(sp)
    8000235e:	ec26                	sd	s1,24(sp)
    80002360:	e84a                	sd	s2,16(sp)
    80002362:	e44e                	sd	s3,8(sp)
    80002364:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002366:	00000097          	auipc	ra,0x0
    8000236a:	9fe080e7          	jalr	-1538(ra) # 80001d64 <myproc>
    8000236e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002370:	ffffe097          	auipc	ra,0xffffe
    80002374:	7fa080e7          	jalr	2042(ra) # 80000b6a <holding>
    80002378:	c959                	beqz	a0,8000240e <sched+0xb6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000237a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000237c:	0007871b          	sext.w	a4,a5
    80002380:	00471793          	slli	a5,a4,0x4
    80002384:	97ba                	add	a5,a5,a4
    80002386:	078e                	slli	a5,a5,0x3
    80002388:	0000f717          	auipc	a4,0xf
    8000238c:	f1870713          	addi	a4,a4,-232 # 800112a0 <readyQueus>
    80002390:	97ba                	add	a5,a5,a4
    80002392:	1787a703          	lw	a4,376(a5)
    80002396:	4785                	li	a5,1
    80002398:	08f71363          	bne	a4,a5,8000241e <sched+0xc6>
  if(p->state == RUNNING)
    8000239c:	4c98                	lw	a4,24(s1)
    8000239e:	4791                	li	a5,4
    800023a0:	08f70763          	beq	a4,a5,8000242e <sched+0xd6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023a8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023aa:	ebd1                	bnez	a5,8000243e <sched+0xe6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023ac:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023ae:	0000f917          	auipc	s2,0xf
    800023b2:	ef290913          	addi	s2,s2,-270 # 800112a0 <readyQueus>
    800023b6:	0007871b          	sext.w	a4,a5
    800023ba:	00471793          	slli	a5,a4,0x4
    800023be:	97ba                	add	a5,a5,a4
    800023c0:	078e                	slli	a5,a5,0x3
    800023c2:	97ca                	add	a5,a5,s2
    800023c4:	17c7a983          	lw	s3,380(a5)
    800023c8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023ca:	0007859b          	sext.w	a1,a5
    800023ce:	00459793          	slli	a5,a1,0x4
    800023d2:	97ae                	add	a5,a5,a1
    800023d4:	078e                	slli	a5,a5,0x3
    800023d6:	0000f597          	auipc	a1,0xf
    800023da:	fd258593          	addi	a1,a1,-46 # 800113a8 <cpus+0x8>
    800023de:	95be                	add	a1,a1,a5
    800023e0:	08048513          	addi	a0,s1,128
    800023e4:	00000097          	auipc	ra,0x0
    800023e8:	602080e7          	jalr	1538(ra) # 800029e6 <swtch>
    800023ec:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023ee:	0007871b          	sext.w	a4,a5
    800023f2:	00471793          	slli	a5,a4,0x4
    800023f6:	97ba                	add	a5,a5,a4
    800023f8:	078e                	slli	a5,a5,0x3
    800023fa:	97ca                	add	a5,a5,s2
    800023fc:	1737ae23          	sw	s3,380(a5)
}
    80002400:	70a2                	ld	ra,40(sp)
    80002402:	7402                	ld	s0,32(sp)
    80002404:	64e2                	ld	s1,24(sp)
    80002406:	6942                	ld	s2,16(sp)
    80002408:	69a2                	ld	s3,8(sp)
    8000240a:	6145                	addi	sp,sp,48
    8000240c:	8082                	ret
    panic("sched p->lock");
    8000240e:	00006517          	auipc	a0,0x6
    80002412:	e5250513          	addi	a0,a0,-430 # 80008260 <digits+0x220>
    80002416:	ffffe097          	auipc	ra,0xffffe
    8000241a:	128080e7          	jalr	296(ra) # 8000053e <panic>
    panic("sched locks");
    8000241e:	00006517          	auipc	a0,0x6
    80002422:	e5250513          	addi	a0,a0,-430 # 80008270 <digits+0x230>
    80002426:	ffffe097          	auipc	ra,0xffffe
    8000242a:	118080e7          	jalr	280(ra) # 8000053e <panic>
    panic("sched running");
    8000242e:	00006517          	auipc	a0,0x6
    80002432:	e5250513          	addi	a0,a0,-430 # 80008280 <digits+0x240>
    80002436:	ffffe097          	auipc	ra,0xffffe
    8000243a:	108080e7          	jalr	264(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000243e:	00006517          	auipc	a0,0x6
    80002442:	e5250513          	addi	a0,a0,-430 # 80008290 <digits+0x250>
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	0f8080e7          	jalr	248(ra) # 8000053e <panic>

000000008000244e <yield>:
{
    8000244e:	1101                	addi	sp,sp,-32
    80002450:	ec06                	sd	ra,24(sp)
    80002452:	e822                	sd	s0,16(sp)
    80002454:	e426                	sd	s1,8(sp)
    80002456:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002458:	00000097          	auipc	ra,0x0
    8000245c:	90c080e7          	jalr	-1780(ra) # 80001d64 <myproc>
    80002460:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	782080e7          	jalr	1922(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    8000246a:	478d                	li	a5,3
    8000246c:	cc9c                	sw	a5,24(s1)
  add(&readyQueus[p->cpu] , p->index);
    8000246e:	58dc                	lw	a5,52(s1)
    80002470:	0796                	slli	a5,a5,0x5
    80002472:	5ccc                	lw	a1,60(s1)
    80002474:	0000f517          	auipc	a0,0xf
    80002478:	e2c50513          	addi	a0,a0,-468 # 800112a0 <readyQueus>
    8000247c:	953e                	add	a0,a0,a5
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	3c0080e7          	jalr	960(ra) # 8000183e <add>
  sched();
    80002486:	00000097          	auipc	ra,0x0
    8000248a:	ed2080e7          	jalr	-302(ra) # 80002358 <sched>
  release(&p->lock);
    8000248e:	8526                	mv	a0,s1
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	808080e7          	jalr	-2040(ra) # 80000c98 <release>
}
    80002498:	60e2                	ld	ra,24(sp)
    8000249a:	6442                	ld	s0,16(sp)
    8000249c:	64a2                	ld	s1,8(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret

00000000800024a2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800024a2:	7179                	addi	sp,sp,-48
    800024a4:	f406                	sd	ra,40(sp)
    800024a6:	f022                	sd	s0,32(sp)
    800024a8:	ec26                	sd	s1,24(sp)
    800024aa:	e84a                	sd	s2,16(sp)
    800024ac:	e44e                	sd	s3,8(sp)
    800024ae:	1800                	addi	s0,sp,48
    800024b0:	89aa                	mv	s3,a0
    800024b2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024b4:	00000097          	auipc	ra,0x0
    800024b8:	8b0080e7          	jalr	-1872(ra) # 80001d64 <myproc>
    800024bc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	726080e7          	jalr	1830(ra) # 80000be4 <acquire>
  release(lk);
    800024c6:	854a                	mv	a0,s2
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	7d0080e7          	jalr	2000(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    800024d0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024d4:	4789                	li	a5,2
    800024d6:	cc9c                	sw	a5,24(s1)

  add(&sleeping , p->index);
    800024d8:	5ccc                	lw	a1,60(s1)
    800024da:	00006517          	auipc	a0,0x6
    800024de:	3b650513          	addi	a0,a0,950 # 80008890 <sleeping>
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	35c080e7          	jalr	860(ra) # 8000183e <add>
  //printList(&sleeping);
  sched();
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	e6e080e7          	jalr	-402(ra) # 80002358 <sched>

  // Tidy up.
  p->chan = 0;
    800024f2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024f6:	8526                	mv	a0,s1
    800024f8:	ffffe097          	auipc	ra,0xffffe
    800024fc:	7a0080e7          	jalr	1952(ra) # 80000c98 <release>
  acquire(lk);
    80002500:	854a                	mv	a0,s2
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	6e2080e7          	jalr	1762(ra) # 80000be4 <acquire>
}
    8000250a:	70a2                	ld	ra,40(sp)
    8000250c:	7402                	ld	s0,32(sp)
    8000250e:	64e2                	ld	s1,24(sp)
    80002510:	6942                	ld	s2,16(sp)
    80002512:	69a2                	ld	s3,8(sp)
    80002514:	6145                	addi	sp,sp,48
    80002516:	8082                	ret

0000000080002518 <wait>:
{
    80002518:	715d                	addi	sp,sp,-80
    8000251a:	e486                	sd	ra,72(sp)
    8000251c:	e0a2                	sd	s0,64(sp)
    8000251e:	fc26                	sd	s1,56(sp)
    80002520:	f84a                	sd	s2,48(sp)
    80002522:	f44e                	sd	s3,40(sp)
    80002524:	f052                	sd	s4,32(sp)
    80002526:	ec56                	sd	s5,24(sp)
    80002528:	e85a                	sd	s6,16(sp)
    8000252a:	e45e                	sd	s7,8(sp)
    8000252c:	e062                	sd	s8,0(sp)
    8000252e:	0880                	addi	s0,sp,80
    80002530:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002532:	00000097          	auipc	ra,0x0
    80002536:	832080e7          	jalr	-1998(ra) # 80001d64 <myproc>
    8000253a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000253c:	0000f517          	auipc	a0,0xf
    80002540:	2bc50513          	addi	a0,a0,700 # 800117f8 <wait_lock>
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	6a0080e7          	jalr	1696(ra) # 80000be4 <acquire>
    havekids = 0;
    8000254c:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000254e:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002550:	00015997          	auipc	s3,0x15
    80002554:	4c098993          	addi	s3,s3,1216 # 80017a10 <tickslock>
        havekids = 1;
    80002558:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000255a:	0000fc17          	auipc	s8,0xf
    8000255e:	29ec0c13          	addi	s8,s8,670 # 800117f8 <wait_lock>
    havekids = 0;
    80002562:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002564:	0000f497          	auipc	s1,0xf
    80002568:	2ac48493          	addi	s1,s1,684 # 80011810 <proc>
    8000256c:	a0bd                	j	800025da <wait+0xc2>
          pid = np->pid;
    8000256e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002572:	000b0e63          	beqz	s6,8000258e <wait+0x76>
    80002576:	4691                	li	a3,4
    80002578:	02c48613          	addi	a2,s1,44
    8000257c:	85da                	mv	a1,s6
    8000257e:	07093503          	ld	a0,112(s2)
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	0f0080e7          	jalr	240(ra) # 80001672 <copyout>
    8000258a:	02054563          	bltz	a0,800025b4 <wait+0x9c>
          freeproc(np);
    8000258e:	8526                	mv	a0,s1
    80002590:	00000097          	auipc	ra,0x0
    80002594:	9aa080e7          	jalr	-1622(ra) # 80001f3a <freeproc>
          release(&np->lock);
    80002598:	8526                	mv	a0,s1
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	6fe080e7          	jalr	1790(ra) # 80000c98 <release>
          release(&wait_lock);
    800025a2:	0000f517          	auipc	a0,0xf
    800025a6:	25650513          	addi	a0,a0,598 # 800117f8 <wait_lock>
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	6ee080e7          	jalr	1774(ra) # 80000c98 <release>
          return pid;
    800025b2:	a09d                	j	80002618 <wait+0x100>
            release(&np->lock);
    800025b4:	8526                	mv	a0,s1
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	6e2080e7          	jalr	1762(ra) # 80000c98 <release>
            release(&wait_lock);
    800025be:	0000f517          	auipc	a0,0xf
    800025c2:	23a50513          	addi	a0,a0,570 # 800117f8 <wait_lock>
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	6d2080e7          	jalr	1746(ra) # 80000c98 <release>
            return -1;
    800025ce:	59fd                	li	s3,-1
    800025d0:	a0a1                	j	80002618 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800025d2:	18848493          	addi	s1,s1,392
    800025d6:	03348463          	beq	s1,s3,800025fe <wait+0xe6>
      if(np->parent == p){
    800025da:	6cbc                	ld	a5,88(s1)
    800025dc:	ff279be3          	bne	a5,s2,800025d2 <wait+0xba>
        acquire(&np->lock);
    800025e0:	8526                	mv	a0,s1
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	602080e7          	jalr	1538(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    800025ea:	4c9c                	lw	a5,24(s1)
    800025ec:	f94781e3          	beq	a5,s4,8000256e <wait+0x56>
        release(&np->lock);
    800025f0:	8526                	mv	a0,s1
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	6a6080e7          	jalr	1702(ra) # 80000c98 <release>
        havekids = 1;
    800025fa:	8756                	mv	a4,s5
    800025fc:	bfd9                	j	800025d2 <wait+0xba>
    if(!havekids || p->killed){
    800025fe:	c701                	beqz	a4,80002606 <wait+0xee>
    80002600:	02892783          	lw	a5,40(s2)
    80002604:	c79d                	beqz	a5,80002632 <wait+0x11a>
      release(&wait_lock);
    80002606:	0000f517          	auipc	a0,0xf
    8000260a:	1f250513          	addi	a0,a0,498 # 800117f8 <wait_lock>
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	68a080e7          	jalr	1674(ra) # 80000c98 <release>
      return -1;
    80002616:	59fd                	li	s3,-1
}
    80002618:	854e                	mv	a0,s3
    8000261a:	60a6                	ld	ra,72(sp)
    8000261c:	6406                	ld	s0,64(sp)
    8000261e:	74e2                	ld	s1,56(sp)
    80002620:	7942                	ld	s2,48(sp)
    80002622:	79a2                	ld	s3,40(sp)
    80002624:	7a02                	ld	s4,32(sp)
    80002626:	6ae2                	ld	s5,24(sp)
    80002628:	6b42                	ld	s6,16(sp)
    8000262a:	6ba2                	ld	s7,8(sp)
    8000262c:	6c02                	ld	s8,0(sp)
    8000262e:	6161                	addi	sp,sp,80
    80002630:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002632:	85e2                	mv	a1,s8
    80002634:	854a                	mv	a0,s2
    80002636:	00000097          	auipc	ra,0x0
    8000263a:	e6c080e7          	jalr	-404(ra) # 800024a2 <sleep>
    havekids = 0;
    8000263e:	b715                	j	80002562 <wait+0x4a>

0000000080002640 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002640:	7139                	addi	sp,sp,-64
    80002642:	fc06                	sd	ra,56(sp)
    80002644:	f822                	sd	s0,48(sp)
    80002646:	f426                	sd	s1,40(sp)
    80002648:	f04a                	sd	s2,32(sp)
    8000264a:	ec4e                	sd	s3,24(sp)
    8000264c:	e852                	sd	s4,16(sp)
    8000264e:	e456                	sd	s5,8(sp)
    80002650:	e05a                	sd	s6,0(sp)
    80002652:	0080                	addi	s0,sp,64
    80002654:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002656:	0000f497          	auipc	s1,0xf
    8000265a:	1ba48493          	addi	s1,s1,442 # 80011810 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000265e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002660:	4b0d                	li	s6,3
        add(&readyQueus[p->cpu] , p->index);
    80002662:	0000fa97          	auipc	s5,0xf
    80002666:	c3ea8a93          	addi	s5,s5,-962 # 800112a0 <readyQueus>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000266a:	00015917          	auipc	s2,0x15
    8000266e:	3a690913          	addi	s2,s2,934 # 80017a10 <tickslock>
    80002672:	a811                	j	80002686 <wakeup+0x46>
      }
      release(&p->lock);
    80002674:	8526                	mv	a0,s1
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	622080e7          	jalr	1570(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000267e:	18848493          	addi	s1,s1,392
    80002682:	03248e63          	beq	s1,s2,800026be <wakeup+0x7e>
    if(p != myproc()){
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	6de080e7          	jalr	1758(ra) # 80001d64 <myproc>
    8000268e:	fea488e3          	beq	s1,a0,8000267e <wakeup+0x3e>
      acquire(&p->lock);
    80002692:	8526                	mv	a0,s1
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	550080e7          	jalr	1360(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000269c:	4c9c                	lw	a5,24(s1)
    8000269e:	fd379be3          	bne	a5,s3,80002674 <wakeup+0x34>
    800026a2:	709c                	ld	a5,32(s1)
    800026a4:	fd4798e3          	bne	a5,s4,80002674 <wakeup+0x34>
        p->state = RUNNABLE;
    800026a8:	0164ac23          	sw	s6,24(s1)
        add(&readyQueus[p->cpu] , p->index);
    800026ac:	58c8                	lw	a0,52(s1)
    800026ae:	0516                	slli	a0,a0,0x5
    800026b0:	5ccc                	lw	a1,60(s1)
    800026b2:	9556                	add	a0,a0,s5
    800026b4:	fffff097          	auipc	ra,0xfffff
    800026b8:	18a080e7          	jalr	394(ra) # 8000183e <add>
    800026bc:	bf65                	j	80002674 <wakeup+0x34>
    }
  }
}
    800026be:	70e2                	ld	ra,56(sp)
    800026c0:	7442                	ld	s0,48(sp)
    800026c2:	74a2                	ld	s1,40(sp)
    800026c4:	7902                	ld	s2,32(sp)
    800026c6:	69e2                	ld	s3,24(sp)
    800026c8:	6a42                	ld	s4,16(sp)
    800026ca:	6aa2                	ld	s5,8(sp)
    800026cc:	6b02                	ld	s6,0(sp)
    800026ce:	6121                	addi	sp,sp,64
    800026d0:	8082                	ret

00000000800026d2 <reparent>:
{
    800026d2:	7179                	addi	sp,sp,-48
    800026d4:	f406                	sd	ra,40(sp)
    800026d6:	f022                	sd	s0,32(sp)
    800026d8:	ec26                	sd	s1,24(sp)
    800026da:	e84a                	sd	s2,16(sp)
    800026dc:	e44e                	sd	s3,8(sp)
    800026de:	e052                	sd	s4,0(sp)
    800026e0:	1800                	addi	s0,sp,48
    800026e2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026e4:	0000f497          	auipc	s1,0xf
    800026e8:	12c48493          	addi	s1,s1,300 # 80011810 <proc>
      pp->parent = initproc;
    800026ec:	00007a17          	auipc	s4,0x7
    800026f0:	93ca0a13          	addi	s4,s4,-1732 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026f4:	00015997          	auipc	s3,0x15
    800026f8:	31c98993          	addi	s3,s3,796 # 80017a10 <tickslock>
    800026fc:	a029                	j	80002706 <reparent+0x34>
    800026fe:	18848493          	addi	s1,s1,392
    80002702:	01348d63          	beq	s1,s3,8000271c <reparent+0x4a>
    if(pp->parent == p){
    80002706:	6cbc                	ld	a5,88(s1)
    80002708:	ff279be3          	bne	a5,s2,800026fe <reparent+0x2c>
      pp->parent = initproc;
    8000270c:	000a3503          	ld	a0,0(s4)
    80002710:	eca8                	sd	a0,88(s1)
      wakeup(initproc);
    80002712:	00000097          	auipc	ra,0x0
    80002716:	f2e080e7          	jalr	-210(ra) # 80002640 <wakeup>
    8000271a:	b7d5                	j	800026fe <reparent+0x2c>
}
    8000271c:	70a2                	ld	ra,40(sp)
    8000271e:	7402                	ld	s0,32(sp)
    80002720:	64e2                	ld	s1,24(sp)
    80002722:	6942                	ld	s2,16(sp)
    80002724:	69a2                	ld	s3,8(sp)
    80002726:	6a02                	ld	s4,0(sp)
    80002728:	6145                	addi	sp,sp,48
    8000272a:	8082                	ret

000000008000272c <exit>:
{
    8000272c:	7179                	addi	sp,sp,-48
    8000272e:	f406                	sd	ra,40(sp)
    80002730:	f022                	sd	s0,32(sp)
    80002732:	ec26                	sd	s1,24(sp)
    80002734:	e84a                	sd	s2,16(sp)
    80002736:	e44e                	sd	s3,8(sp)
    80002738:	e052                	sd	s4,0(sp)
    8000273a:	1800                	addi	s0,sp,48
    8000273c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000273e:	fffff097          	auipc	ra,0xfffff
    80002742:	626080e7          	jalr	1574(ra) # 80001d64 <myproc>
    80002746:	89aa                	mv	s3,a0
  if(p == initproc)
    80002748:	00007797          	auipc	a5,0x7
    8000274c:	8e07b783          	ld	a5,-1824(a5) # 80009028 <initproc>
    80002750:	0f050493          	addi	s1,a0,240
    80002754:	17050913          	addi	s2,a0,368
    80002758:	02a79363          	bne	a5,a0,8000277e <exit+0x52>
    panic("init exiting");
    8000275c:	00006517          	auipc	a0,0x6
    80002760:	b4c50513          	addi	a0,a0,-1204 # 800082a8 <digits+0x268>
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	dda080e7          	jalr	-550(ra) # 8000053e <panic>
      fileclose(f);
    8000276c:	00002097          	auipc	ra,0x2
    80002770:	17c080e7          	jalr	380(ra) # 800048e8 <fileclose>
      p->ofile[fd] = 0;
    80002774:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002778:	04a1                	addi	s1,s1,8
    8000277a:	01248563          	beq	s1,s2,80002784 <exit+0x58>
    if(p->ofile[fd]){
    8000277e:	6088                	ld	a0,0(s1)
    80002780:	f575                	bnez	a0,8000276c <exit+0x40>
    80002782:	bfdd                	j	80002778 <exit+0x4c>
  begin_op();
    80002784:	00002097          	auipc	ra,0x2
    80002788:	c98080e7          	jalr	-872(ra) # 8000441c <begin_op>
  iput(p->cwd);
    8000278c:	1709b503          	ld	a0,368(s3)
    80002790:	00001097          	auipc	ra,0x1
    80002794:	474080e7          	jalr	1140(ra) # 80003c04 <iput>
  end_op();
    80002798:	00002097          	auipc	ra,0x2
    8000279c:	d04080e7          	jalr	-764(ra) # 8000449c <end_op>
  p->cwd = 0;
    800027a0:	1609b823          	sd	zero,368(s3)
  acquire(&wait_lock);
    800027a4:	0000f497          	auipc	s1,0xf
    800027a8:	05448493          	addi	s1,s1,84 # 800117f8 <wait_lock>
    800027ac:	8526                	mv	a0,s1
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	436080e7          	jalr	1078(ra) # 80000be4 <acquire>
  reparent(p);
    800027b6:	854e                	mv	a0,s3
    800027b8:	00000097          	auipc	ra,0x0
    800027bc:	f1a080e7          	jalr	-230(ra) # 800026d2 <reparent>
  wakeup(p->parent);
    800027c0:	0589b503          	ld	a0,88(s3)
    800027c4:	00000097          	auipc	ra,0x0
    800027c8:	e7c080e7          	jalr	-388(ra) # 80002640 <wakeup>
  acquire(&p->lock);
    800027cc:	854e                	mv	a0,s3
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	416080e7          	jalr	1046(ra) # 80000be4 <acquire>
  p->xstate = status;
    800027d6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800027da:	4795                	li	a5,5
    800027dc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	4b6080e7          	jalr	1206(ra) # 80000c98 <release>
  sched();
    800027ea:	00000097          	auipc	ra,0x0
    800027ee:	b6e080e7          	jalr	-1170(ra) # 80002358 <sched>
  panic("zombie exit");
    800027f2:	00006517          	auipc	a0,0x6
    800027f6:	ac650513          	addi	a0,a0,-1338 # 800082b8 <digits+0x278>
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	d44080e7          	jalr	-700(ra) # 8000053e <panic>

0000000080002802 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002802:	7179                	addi	sp,sp,-48
    80002804:	f406                	sd	ra,40(sp)
    80002806:	f022                	sd	s0,32(sp)
    80002808:	ec26                	sd	s1,24(sp)
    8000280a:	e84a                	sd	s2,16(sp)
    8000280c:	e44e                	sd	s3,8(sp)
    8000280e:	1800                	addi	s0,sp,48
    80002810:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002812:	0000f497          	auipc	s1,0xf
    80002816:	ffe48493          	addi	s1,s1,-2 # 80011810 <proc>
    8000281a:	00015997          	auipc	s3,0x15
    8000281e:	1f698993          	addi	s3,s3,502 # 80017a10 <tickslock>
    acquire(&p->lock);
    80002822:	8526                	mv	a0,s1
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	3c0080e7          	jalr	960(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    8000282c:	589c                	lw	a5,48(s1)
    8000282e:	01278d63          	beq	a5,s2,80002848 <kill+0x46>
        add(&readyQueus[p->cpu] , p->index); 
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002832:	8526                	mv	a0,s1
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	464080e7          	jalr	1124(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000283c:	18848493          	addi	s1,s1,392
    80002840:	ff3491e3          	bne	s1,s3,80002822 <kill+0x20>
  }
  return -1;
    80002844:	557d                	li	a0,-1
    80002846:	a829                	j	80002860 <kill+0x5e>
      p->killed = 1;
    80002848:	4785                	li	a5,1
    8000284a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000284c:	4c98                	lw	a4,24(s1)
    8000284e:	4789                	li	a5,2
    80002850:	00f70f63          	beq	a4,a5,8000286e <kill+0x6c>
      release(&p->lock);
    80002854:	8526                	mv	a0,s1
    80002856:	ffffe097          	auipc	ra,0xffffe
    8000285a:	442080e7          	jalr	1090(ra) # 80000c98 <release>
      return 0;
    8000285e:	4501                	li	a0,0
}
    80002860:	70a2                	ld	ra,40(sp)
    80002862:	7402                	ld	s0,32(sp)
    80002864:	64e2                	ld	s1,24(sp)
    80002866:	6942                	ld	s2,16(sp)
    80002868:	69a2                	ld	s3,8(sp)
    8000286a:	6145                	addi	sp,sp,48
    8000286c:	8082                	ret
        p->state = RUNNABLE;
    8000286e:	478d                	li	a5,3
    80002870:	cc9c                	sw	a5,24(s1)
        add(&readyQueus[p->cpu] , p->index); 
    80002872:	58dc                	lw	a5,52(s1)
    80002874:	0796                	slli	a5,a5,0x5
    80002876:	5ccc                	lw	a1,60(s1)
    80002878:	0000f517          	auipc	a0,0xf
    8000287c:	a2850513          	addi	a0,a0,-1496 # 800112a0 <readyQueus>
    80002880:	953e                	add	a0,a0,a5
    80002882:	fffff097          	auipc	ra,0xfffff
    80002886:	fbc080e7          	jalr	-68(ra) # 8000183e <add>
    8000288a:	b7e9                	j	80002854 <kill+0x52>

000000008000288c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000288c:	7179                	addi	sp,sp,-48
    8000288e:	f406                	sd	ra,40(sp)
    80002890:	f022                	sd	s0,32(sp)
    80002892:	ec26                	sd	s1,24(sp)
    80002894:	e84a                	sd	s2,16(sp)
    80002896:	e44e                	sd	s3,8(sp)
    80002898:	e052                	sd	s4,0(sp)
    8000289a:	1800                	addi	s0,sp,48
    8000289c:	84aa                	mv	s1,a0
    8000289e:	892e                	mv	s2,a1
    800028a0:	89b2                	mv	s3,a2
    800028a2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028a4:	fffff097          	auipc	ra,0xfffff
    800028a8:	4c0080e7          	jalr	1216(ra) # 80001d64 <myproc>
  if(user_dst){
    800028ac:	c08d                	beqz	s1,800028ce <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028ae:	86d2                	mv	a3,s4
    800028b0:	864e                	mv	a2,s3
    800028b2:	85ca                	mv	a1,s2
    800028b4:	7928                	ld	a0,112(a0)
    800028b6:	fffff097          	auipc	ra,0xfffff
    800028ba:	dbc080e7          	jalr	-580(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028be:	70a2                	ld	ra,40(sp)
    800028c0:	7402                	ld	s0,32(sp)
    800028c2:	64e2                	ld	s1,24(sp)
    800028c4:	6942                	ld	s2,16(sp)
    800028c6:	69a2                	ld	s3,8(sp)
    800028c8:	6a02                	ld	s4,0(sp)
    800028ca:	6145                	addi	sp,sp,48
    800028cc:	8082                	ret
    memmove((char *)dst, src, len);
    800028ce:	000a061b          	sext.w	a2,s4
    800028d2:	85ce                	mv	a1,s3
    800028d4:	854a                	mv	a0,s2
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	46a080e7          	jalr	1130(ra) # 80000d40 <memmove>
    return 0;
    800028de:	8526                	mv	a0,s1
    800028e0:	bff9                	j	800028be <either_copyout+0x32>

00000000800028e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028e2:	7179                	addi	sp,sp,-48
    800028e4:	f406                	sd	ra,40(sp)
    800028e6:	f022                	sd	s0,32(sp)
    800028e8:	ec26                	sd	s1,24(sp)
    800028ea:	e84a                	sd	s2,16(sp)
    800028ec:	e44e                	sd	s3,8(sp)
    800028ee:	e052                	sd	s4,0(sp)
    800028f0:	1800                	addi	s0,sp,48
    800028f2:	892a                	mv	s2,a0
    800028f4:	84ae                	mv	s1,a1
    800028f6:	89b2                	mv	s3,a2
    800028f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028fa:	fffff097          	auipc	ra,0xfffff
    800028fe:	46a080e7          	jalr	1130(ra) # 80001d64 <myproc>
  if(user_src){
    80002902:	c08d                	beqz	s1,80002924 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002904:	86d2                	mv	a3,s4
    80002906:	864e                	mv	a2,s3
    80002908:	85ca                	mv	a1,s2
    8000290a:	7928                	ld	a0,112(a0)
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	df2080e7          	jalr	-526(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002914:	70a2                	ld	ra,40(sp)
    80002916:	7402                	ld	s0,32(sp)
    80002918:	64e2                	ld	s1,24(sp)
    8000291a:	6942                	ld	s2,16(sp)
    8000291c:	69a2                	ld	s3,8(sp)
    8000291e:	6a02                	ld	s4,0(sp)
    80002920:	6145                	addi	sp,sp,48
    80002922:	8082                	ret
    memmove(dst, (char*)src, len);
    80002924:	000a061b          	sext.w	a2,s4
    80002928:	85ce                	mv	a1,s3
    8000292a:	854a                	mv	a0,s2
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	414080e7          	jalr	1044(ra) # 80000d40 <memmove>
    return 0;
    80002934:	8526                	mv	a0,s1
    80002936:	bff9                	j	80002914 <either_copyin+0x32>

0000000080002938 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002938:	715d                	addi	sp,sp,-80
    8000293a:	e486                	sd	ra,72(sp)
    8000293c:	e0a2                	sd	s0,64(sp)
    8000293e:	fc26                	sd	s1,56(sp)
    80002940:	f84a                	sd	s2,48(sp)
    80002942:	f44e                	sd	s3,40(sp)
    80002944:	f052                	sd	s4,32(sp)
    80002946:	ec56                	sd	s5,24(sp)
    80002948:	e85a                	sd	s6,16(sp)
    8000294a:	e45e                	sd	s7,8(sp)
    8000294c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000294e:	00005517          	auipc	a0,0x5
    80002952:	77a50513          	addi	a0,a0,1914 # 800080c8 <digits+0x88>
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	c32080e7          	jalr	-974(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000295e:	0000f497          	auipc	s1,0xf
    80002962:	02a48493          	addi	s1,s1,42 # 80011988 <proc+0x178>
    80002966:	00015917          	auipc	s2,0x15
    8000296a:	22290913          	addi	s2,s2,546 # 80017b88 <bcache+0x160>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000296e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002970:	00006997          	auipc	s3,0x6
    80002974:	95898993          	addi	s3,s3,-1704 # 800082c8 <digits+0x288>
    printf("%d %s %s", p->pid, state, p->name);
    80002978:	00006a97          	auipc	s5,0x6
    8000297c:	958a8a93          	addi	s5,s5,-1704 # 800082d0 <digits+0x290>
    printf("\n");
    80002980:	00005a17          	auipc	s4,0x5
    80002984:	748a0a13          	addi	s4,s4,1864 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002988:	00006b97          	auipc	s7,0x6
    8000298c:	980b8b93          	addi	s7,s7,-1664 # 80008308 <states.1760>
    80002990:	a00d                	j	800029b2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002992:	eb86a583          	lw	a1,-328(a3)
    80002996:	8556                	mv	a0,s5
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	bf0080e7          	jalr	-1040(ra) # 80000588 <printf>
    printf("\n");
    800029a0:	8552                	mv	a0,s4
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	be6080e7          	jalr	-1050(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029aa:	18848493          	addi	s1,s1,392
    800029ae:	03248163          	beq	s1,s2,800029d0 <procdump+0x98>
    if(p->state == UNUSED)
    800029b2:	86a6                	mv	a3,s1
    800029b4:	ea04a783          	lw	a5,-352(s1)
    800029b8:	dbed                	beqz	a5,800029aa <procdump+0x72>
      state = "???";
    800029ba:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029bc:	fcfb6be3          	bltu	s6,a5,80002992 <procdump+0x5a>
    800029c0:	1782                	slli	a5,a5,0x20
    800029c2:	9381                	srli	a5,a5,0x20
    800029c4:	078e                	slli	a5,a5,0x3
    800029c6:	97de                	add	a5,a5,s7
    800029c8:	6390                	ld	a2,0(a5)
    800029ca:	f661                	bnez	a2,80002992 <procdump+0x5a>
      state = "???";
    800029cc:	864e                	mv	a2,s3
    800029ce:	b7d1                	j	80002992 <procdump+0x5a>
  }
}
    800029d0:	60a6                	ld	ra,72(sp)
    800029d2:	6406                	ld	s0,64(sp)
    800029d4:	74e2                	ld	s1,56(sp)
    800029d6:	7942                	ld	s2,48(sp)
    800029d8:	79a2                	ld	s3,40(sp)
    800029da:	7a02                	ld	s4,32(sp)
    800029dc:	6ae2                	ld	s5,24(sp)
    800029de:	6b42                	ld	s6,16(sp)
    800029e0:	6ba2                	ld	s7,8(sp)
    800029e2:	6161                	addi	sp,sp,80
    800029e4:	8082                	ret

00000000800029e6 <swtch>:
    800029e6:	00153023          	sd	ra,0(a0)
    800029ea:	00253423          	sd	sp,8(a0)
    800029ee:	e900                	sd	s0,16(a0)
    800029f0:	ed04                	sd	s1,24(a0)
    800029f2:	03253023          	sd	s2,32(a0)
    800029f6:	03353423          	sd	s3,40(a0)
    800029fa:	03453823          	sd	s4,48(a0)
    800029fe:	03553c23          	sd	s5,56(a0)
    80002a02:	05653023          	sd	s6,64(a0)
    80002a06:	05753423          	sd	s7,72(a0)
    80002a0a:	05853823          	sd	s8,80(a0)
    80002a0e:	05953c23          	sd	s9,88(a0)
    80002a12:	07a53023          	sd	s10,96(a0)
    80002a16:	07b53423          	sd	s11,104(a0)
    80002a1a:	0005b083          	ld	ra,0(a1)
    80002a1e:	0085b103          	ld	sp,8(a1)
    80002a22:	6980                	ld	s0,16(a1)
    80002a24:	6d84                	ld	s1,24(a1)
    80002a26:	0205b903          	ld	s2,32(a1)
    80002a2a:	0285b983          	ld	s3,40(a1)
    80002a2e:	0305ba03          	ld	s4,48(a1)
    80002a32:	0385ba83          	ld	s5,56(a1)
    80002a36:	0405bb03          	ld	s6,64(a1)
    80002a3a:	0485bb83          	ld	s7,72(a1)
    80002a3e:	0505bc03          	ld	s8,80(a1)
    80002a42:	0585bc83          	ld	s9,88(a1)
    80002a46:	0605bd03          	ld	s10,96(a1)
    80002a4a:	0685bd83          	ld	s11,104(a1)
    80002a4e:	8082                	ret

0000000080002a50 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a50:	1141                	addi	sp,sp,-16
    80002a52:	e406                	sd	ra,8(sp)
    80002a54:	e022                	sd	s0,0(sp)
    80002a56:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a58:	00006597          	auipc	a1,0x6
    80002a5c:	8e058593          	addi	a1,a1,-1824 # 80008338 <states.1760+0x30>
    80002a60:	00015517          	auipc	a0,0x15
    80002a64:	fb050513          	addi	a0,a0,-80 # 80017a10 <tickslock>
    80002a68:	ffffe097          	auipc	ra,0xffffe
    80002a6c:	0ec080e7          	jalr	236(ra) # 80000b54 <initlock>
}
    80002a70:	60a2                	ld	ra,8(sp)
    80002a72:	6402                	ld	s0,0(sp)
    80002a74:	0141                	addi	sp,sp,16
    80002a76:	8082                	ret

0000000080002a78 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a78:	1141                	addi	sp,sp,-16
    80002a7a:	e422                	sd	s0,8(sp)
    80002a7c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a7e:	00003797          	auipc	a5,0x3
    80002a82:	48278793          	addi	a5,a5,1154 # 80005f00 <kernelvec>
    80002a86:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a8a:	6422                	ld	s0,8(sp)
    80002a8c:	0141                	addi	sp,sp,16
    80002a8e:	8082                	ret

0000000080002a90 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a90:	1141                	addi	sp,sp,-16
    80002a92:	e406                	sd	ra,8(sp)
    80002a94:	e022                	sd	s0,0(sp)
    80002a96:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	2cc080e7          	jalr	716(ra) # 80001d64 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002aa4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aa6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002aaa:	00004617          	auipc	a2,0x4
    80002aae:	55660613          	addi	a2,a2,1366 # 80007000 <_trampoline>
    80002ab2:	00004697          	auipc	a3,0x4
    80002ab6:	54e68693          	addi	a3,a3,1358 # 80007000 <_trampoline>
    80002aba:	8e91                	sub	a3,a3,a2
    80002abc:	040007b7          	lui	a5,0x4000
    80002ac0:	17fd                	addi	a5,a5,-1
    80002ac2:	07b2                	slli	a5,a5,0xc
    80002ac4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ac6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002aca:	7d38                	ld	a4,120(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002acc:	180026f3          	csrr	a3,satp
    80002ad0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ad2:	7d38                	ld	a4,120(a0)
    80002ad4:	7134                	ld	a3,96(a0)
    80002ad6:	6585                	lui	a1,0x1
    80002ad8:	96ae                	add	a3,a3,a1
    80002ada:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002adc:	7d38                	ld	a4,120(a0)
    80002ade:	00000697          	auipc	a3,0x0
    80002ae2:	13868693          	addi	a3,a3,312 # 80002c16 <usertrap>
    80002ae6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ae8:	7d38                	ld	a4,120(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002aea:	8692                	mv	a3,tp
    80002aec:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aee:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002af2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002af6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002afa:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002afe:	7d38                	ld	a4,120(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b00:	6f18                	ld	a4,24(a4)
    80002b02:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b06:	792c                	ld	a1,112(a0)
    80002b08:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b0a:	00004717          	auipc	a4,0x4
    80002b0e:	58670713          	addi	a4,a4,1414 # 80007090 <userret>
    80002b12:	8f11                	sub	a4,a4,a2
    80002b14:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b16:	577d                	li	a4,-1
    80002b18:	177e                	slli	a4,a4,0x3f
    80002b1a:	8dd9                	or	a1,a1,a4
    80002b1c:	02000537          	lui	a0,0x2000
    80002b20:	157d                	addi	a0,a0,-1
    80002b22:	0536                	slli	a0,a0,0xd
    80002b24:	9782                	jalr	a5
}
    80002b26:	60a2                	ld	ra,8(sp)
    80002b28:	6402                	ld	s0,0(sp)
    80002b2a:	0141                	addi	sp,sp,16
    80002b2c:	8082                	ret

0000000080002b2e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b2e:	1101                	addi	sp,sp,-32
    80002b30:	ec06                	sd	ra,24(sp)
    80002b32:	e822                	sd	s0,16(sp)
    80002b34:	e426                	sd	s1,8(sp)
    80002b36:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b38:	00015497          	auipc	s1,0x15
    80002b3c:	ed848493          	addi	s1,s1,-296 # 80017a10 <tickslock>
    80002b40:	8526                	mv	a0,s1
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	0a2080e7          	jalr	162(ra) # 80000be4 <acquire>
  ticks++;
    80002b4a:	00006517          	auipc	a0,0x6
    80002b4e:	4e650513          	addi	a0,a0,1254 # 80009030 <ticks>
    80002b52:	411c                	lw	a5,0(a0)
    80002b54:	2785                	addiw	a5,a5,1
    80002b56:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b58:	00000097          	auipc	ra,0x0
    80002b5c:	ae8080e7          	jalr	-1304(ra) # 80002640 <wakeup>
  release(&tickslock);
    80002b60:	8526                	mv	a0,s1
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	136080e7          	jalr	310(ra) # 80000c98 <release>
}
    80002b6a:	60e2                	ld	ra,24(sp)
    80002b6c:	6442                	ld	s0,16(sp)
    80002b6e:	64a2                	ld	s1,8(sp)
    80002b70:	6105                	addi	sp,sp,32
    80002b72:	8082                	ret

0000000080002b74 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	e426                	sd	s1,8(sp)
    80002b7c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b7e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b82:	00074d63          	bltz	a4,80002b9c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b86:	57fd                	li	a5,-1
    80002b88:	17fe                	slli	a5,a5,0x3f
    80002b8a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b8c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b8e:	06f70363          	beq	a4,a5,80002bf4 <devintr+0x80>
  }
}
    80002b92:	60e2                	ld	ra,24(sp)
    80002b94:	6442                	ld	s0,16(sp)
    80002b96:	64a2                	ld	s1,8(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret
     (scause & 0xff) == 9){
    80002b9c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ba0:	46a5                	li	a3,9
    80002ba2:	fed792e3          	bne	a5,a3,80002b86 <devintr+0x12>
    int irq = plic_claim();
    80002ba6:	00003097          	auipc	ra,0x3
    80002baa:	462080e7          	jalr	1122(ra) # 80006008 <plic_claim>
    80002bae:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bb0:	47a9                	li	a5,10
    80002bb2:	02f50763          	beq	a0,a5,80002be0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002bb6:	4785                	li	a5,1
    80002bb8:	02f50963          	beq	a0,a5,80002bea <devintr+0x76>
    return 1;
    80002bbc:	4505                	li	a0,1
    } else if(irq){
    80002bbe:	d8f1                	beqz	s1,80002b92 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bc0:	85a6                	mv	a1,s1
    80002bc2:	00005517          	auipc	a0,0x5
    80002bc6:	77e50513          	addi	a0,a0,1918 # 80008340 <states.1760+0x38>
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	9be080e7          	jalr	-1602(ra) # 80000588 <printf>
      plic_complete(irq);
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	00003097          	auipc	ra,0x3
    80002bd8:	458080e7          	jalr	1112(ra) # 8000602c <plic_complete>
    return 1;
    80002bdc:	4505                	li	a0,1
    80002bde:	bf55                	j	80002b92 <devintr+0x1e>
      uartintr();
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	dc8080e7          	jalr	-568(ra) # 800009a8 <uartintr>
    80002be8:	b7ed                	j	80002bd2 <devintr+0x5e>
      virtio_disk_intr();
    80002bea:	00004097          	auipc	ra,0x4
    80002bee:	922080e7          	jalr	-1758(ra) # 8000650c <virtio_disk_intr>
    80002bf2:	b7c5                	j	80002bd2 <devintr+0x5e>
    if(cpuid() == 0){
    80002bf4:	fffff097          	auipc	ra,0xfffff
    80002bf8:	13c080e7          	jalr	316(ra) # 80001d30 <cpuid>
    80002bfc:	c901                	beqz	a0,80002c0c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bfe:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c04:	14479073          	csrw	sip,a5
    return 2;
    80002c08:	4509                	li	a0,2
    80002c0a:	b761                	j	80002b92 <devintr+0x1e>
      clockintr();
    80002c0c:	00000097          	auipc	ra,0x0
    80002c10:	f22080e7          	jalr	-222(ra) # 80002b2e <clockintr>
    80002c14:	b7ed                	j	80002bfe <devintr+0x8a>

0000000080002c16 <usertrap>:
{
    80002c16:	1101                	addi	sp,sp,-32
    80002c18:	ec06                	sd	ra,24(sp)
    80002c1a:	e822                	sd	s0,16(sp)
    80002c1c:	e426                	sd	s1,8(sp)
    80002c1e:	e04a                	sd	s2,0(sp)
    80002c20:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c22:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c26:	1007f793          	andi	a5,a5,256
    80002c2a:	e3ad                	bnez	a5,80002c8c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c2c:	00003797          	auipc	a5,0x3
    80002c30:	2d478793          	addi	a5,a5,724 # 80005f00 <kernelvec>
    80002c34:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	12c080e7          	jalr	300(ra) # 80001d64 <myproc>
    80002c40:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c42:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c44:	14102773          	csrr	a4,sepc
    80002c48:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c4e:	47a1                	li	a5,8
    80002c50:	04f71c63          	bne	a4,a5,80002ca8 <usertrap+0x92>
    if(p->killed)
    80002c54:	551c                	lw	a5,40(a0)
    80002c56:	e3b9                	bnez	a5,80002c9c <usertrap+0x86>
    p->trapframe->epc += 4;
    80002c58:	7cb8                	ld	a4,120(s1)
    80002c5a:	6f1c                	ld	a5,24(a4)
    80002c5c:	0791                	addi	a5,a5,4
    80002c5e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c68:	10079073          	csrw	sstatus,a5
    syscall();
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	2e0080e7          	jalr	736(ra) # 80002f4c <syscall>
  if(p->killed)
    80002c74:	549c                	lw	a5,40(s1)
    80002c76:	ebc1                	bnez	a5,80002d06 <usertrap+0xf0>
  usertrapret();
    80002c78:	00000097          	auipc	ra,0x0
    80002c7c:	e18080e7          	jalr	-488(ra) # 80002a90 <usertrapret>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6902                	ld	s2,0(sp)
    80002c88:	6105                	addi	sp,sp,32
    80002c8a:	8082                	ret
    panic("usertrap: not from user mode");
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	6d450513          	addi	a0,a0,1748 # 80008360 <states.1760+0x58>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	8aa080e7          	jalr	-1878(ra) # 8000053e <panic>
      exit(-1);
    80002c9c:	557d                	li	a0,-1
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	a8e080e7          	jalr	-1394(ra) # 8000272c <exit>
    80002ca6:	bf4d                	j	80002c58 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ca8:	00000097          	auipc	ra,0x0
    80002cac:	ecc080e7          	jalr	-308(ra) # 80002b74 <devintr>
    80002cb0:	892a                	mv	s2,a0
    80002cb2:	c501                	beqz	a0,80002cba <usertrap+0xa4>
  if(p->killed)
    80002cb4:	549c                	lw	a5,40(s1)
    80002cb6:	c3a1                	beqz	a5,80002cf6 <usertrap+0xe0>
    80002cb8:	a815                	j	80002cec <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cba:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cbe:	5890                	lw	a2,48(s1)
    80002cc0:	00005517          	auipc	a0,0x5
    80002cc4:	6c050513          	addi	a0,a0,1728 # 80008380 <states.1760+0x78>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	8c0080e7          	jalr	-1856(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cd4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cd8:	00005517          	auipc	a0,0x5
    80002cdc:	6d850513          	addi	a0,a0,1752 # 800083b0 <states.1760+0xa8>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	8a8080e7          	jalr	-1880(ra) # 80000588 <printf>
    p->killed = 1;
    80002ce8:	4785                	li	a5,1
    80002cea:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002cec:	557d                	li	a0,-1
    80002cee:	00000097          	auipc	ra,0x0
    80002cf2:	a3e080e7          	jalr	-1474(ra) # 8000272c <exit>
  if(which_dev == 2)
    80002cf6:	4789                	li	a5,2
    80002cf8:	f8f910e3          	bne	s2,a5,80002c78 <usertrap+0x62>
    yield();
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	752080e7          	jalr	1874(ra) # 8000244e <yield>
    80002d04:	bf95                	j	80002c78 <usertrap+0x62>
  int which_dev = 0;
    80002d06:	4901                	li	s2,0
    80002d08:	b7d5                	j	80002cec <usertrap+0xd6>

0000000080002d0a <kerneltrap>:
{
    80002d0a:	7179                	addi	sp,sp,-48
    80002d0c:	f406                	sd	ra,40(sp)
    80002d0e:	f022                	sd	s0,32(sp)
    80002d10:	ec26                	sd	s1,24(sp)
    80002d12:	e84a                	sd	s2,16(sp)
    80002d14:	e44e                	sd	s3,8(sp)
    80002d16:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d18:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d1c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d20:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d24:	1004f793          	andi	a5,s1,256
    80002d28:	cb85                	beqz	a5,80002d58 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d2e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d30:	ef85                	bnez	a5,80002d68 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	e42080e7          	jalr	-446(ra) # 80002b74 <devintr>
    80002d3a:	cd1d                	beqz	a0,80002d78 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d3c:	4789                	li	a5,2
    80002d3e:	06f50a63          	beq	a0,a5,80002db2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d42:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d46:	10049073          	csrw	sstatus,s1
}
    80002d4a:	70a2                	ld	ra,40(sp)
    80002d4c:	7402                	ld	s0,32(sp)
    80002d4e:	64e2                	ld	s1,24(sp)
    80002d50:	6942                	ld	s2,16(sp)
    80002d52:	69a2                	ld	s3,8(sp)
    80002d54:	6145                	addi	sp,sp,48
    80002d56:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d58:	00005517          	auipc	a0,0x5
    80002d5c:	67850513          	addi	a0,a0,1656 # 800083d0 <states.1760+0xc8>
    80002d60:	ffffd097          	auipc	ra,0xffffd
    80002d64:	7de080e7          	jalr	2014(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002d68:	00005517          	auipc	a0,0x5
    80002d6c:	69050513          	addi	a0,a0,1680 # 800083f8 <states.1760+0xf0>
    80002d70:	ffffd097          	auipc	ra,0xffffd
    80002d74:	7ce080e7          	jalr	1998(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002d78:	85ce                	mv	a1,s3
    80002d7a:	00005517          	auipc	a0,0x5
    80002d7e:	69e50513          	addi	a0,a0,1694 # 80008418 <states.1760+0x110>
    80002d82:	ffffe097          	auipc	ra,0xffffe
    80002d86:	806080e7          	jalr	-2042(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d8a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d8e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d92:	00005517          	auipc	a0,0x5
    80002d96:	69650513          	addi	a0,a0,1686 # 80008428 <states.1760+0x120>
    80002d9a:	ffffd097          	auipc	ra,0xffffd
    80002d9e:	7ee080e7          	jalr	2030(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002da2:	00005517          	auipc	a0,0x5
    80002da6:	69e50513          	addi	a0,a0,1694 # 80008440 <states.1760+0x138>
    80002daa:	ffffd097          	auipc	ra,0xffffd
    80002dae:	794080e7          	jalr	1940(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	fb2080e7          	jalr	-78(ra) # 80001d64 <myproc>
    80002dba:	d541                	beqz	a0,80002d42 <kerneltrap+0x38>
    80002dbc:	fffff097          	auipc	ra,0xfffff
    80002dc0:	fa8080e7          	jalr	-88(ra) # 80001d64 <myproc>
    80002dc4:	4d18                	lw	a4,24(a0)
    80002dc6:	4791                	li	a5,4
    80002dc8:	f6f71de3          	bne	a4,a5,80002d42 <kerneltrap+0x38>
    yield();
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	682080e7          	jalr	1666(ra) # 8000244e <yield>
    80002dd4:	b7bd                	j	80002d42 <kerneltrap+0x38>

0000000080002dd6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	1000                	addi	s0,sp,32
    80002de0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	f82080e7          	jalr	-126(ra) # 80001d64 <myproc>
  switch (n) {
    80002dea:	4795                	li	a5,5
    80002dec:	0497e163          	bltu	a5,s1,80002e2e <argraw+0x58>
    80002df0:	048a                	slli	s1,s1,0x2
    80002df2:	00005717          	auipc	a4,0x5
    80002df6:	68670713          	addi	a4,a4,1670 # 80008478 <states.1760+0x170>
    80002dfa:	94ba                	add	s1,s1,a4
    80002dfc:	409c                	lw	a5,0(s1)
    80002dfe:	97ba                	add	a5,a5,a4
    80002e00:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e02:	7d3c                	ld	a5,120(a0)
    80002e04:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e06:	60e2                	ld	ra,24(sp)
    80002e08:	6442                	ld	s0,16(sp)
    80002e0a:	64a2                	ld	s1,8(sp)
    80002e0c:	6105                	addi	sp,sp,32
    80002e0e:	8082                	ret
    return p->trapframe->a1;
    80002e10:	7d3c                	ld	a5,120(a0)
    80002e12:	7fa8                	ld	a0,120(a5)
    80002e14:	bfcd                	j	80002e06 <argraw+0x30>
    return p->trapframe->a2;
    80002e16:	7d3c                	ld	a5,120(a0)
    80002e18:	63c8                	ld	a0,128(a5)
    80002e1a:	b7f5                	j	80002e06 <argraw+0x30>
    return p->trapframe->a3;
    80002e1c:	7d3c                	ld	a5,120(a0)
    80002e1e:	67c8                	ld	a0,136(a5)
    80002e20:	b7dd                	j	80002e06 <argraw+0x30>
    return p->trapframe->a4;
    80002e22:	7d3c                	ld	a5,120(a0)
    80002e24:	6bc8                	ld	a0,144(a5)
    80002e26:	b7c5                	j	80002e06 <argraw+0x30>
    return p->trapframe->a5;
    80002e28:	7d3c                	ld	a5,120(a0)
    80002e2a:	6fc8                	ld	a0,152(a5)
    80002e2c:	bfe9                	j	80002e06 <argraw+0x30>
  panic("argraw");
    80002e2e:	00005517          	auipc	a0,0x5
    80002e32:	62250513          	addi	a0,a0,1570 # 80008450 <states.1760+0x148>
    80002e36:	ffffd097          	auipc	ra,0xffffd
    80002e3a:	708080e7          	jalr	1800(ra) # 8000053e <panic>

0000000080002e3e <fetchaddr>:
{
    80002e3e:	1101                	addi	sp,sp,-32
    80002e40:	ec06                	sd	ra,24(sp)
    80002e42:	e822                	sd	s0,16(sp)
    80002e44:	e426                	sd	s1,8(sp)
    80002e46:	e04a                	sd	s2,0(sp)
    80002e48:	1000                	addi	s0,sp,32
    80002e4a:	84aa                	mv	s1,a0
    80002e4c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	f16080e7          	jalr	-234(ra) # 80001d64 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e56:	753c                	ld	a5,104(a0)
    80002e58:	02f4f863          	bgeu	s1,a5,80002e88 <fetchaddr+0x4a>
    80002e5c:	00848713          	addi	a4,s1,8
    80002e60:	02e7e663          	bltu	a5,a4,80002e8c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e64:	46a1                	li	a3,8
    80002e66:	8626                	mv	a2,s1
    80002e68:	85ca                	mv	a1,s2
    80002e6a:	7928                	ld	a0,112(a0)
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	892080e7          	jalr	-1902(ra) # 800016fe <copyin>
    80002e74:	00a03533          	snez	a0,a0
    80002e78:	40a00533          	neg	a0,a0
}
    80002e7c:	60e2                	ld	ra,24(sp)
    80002e7e:	6442                	ld	s0,16(sp)
    80002e80:	64a2                	ld	s1,8(sp)
    80002e82:	6902                	ld	s2,0(sp)
    80002e84:	6105                	addi	sp,sp,32
    80002e86:	8082                	ret
    return -1;
    80002e88:	557d                	li	a0,-1
    80002e8a:	bfcd                	j	80002e7c <fetchaddr+0x3e>
    80002e8c:	557d                	li	a0,-1
    80002e8e:	b7fd                	j	80002e7c <fetchaddr+0x3e>

0000000080002e90 <fetchstr>:
{
    80002e90:	7179                	addi	sp,sp,-48
    80002e92:	f406                	sd	ra,40(sp)
    80002e94:	f022                	sd	s0,32(sp)
    80002e96:	ec26                	sd	s1,24(sp)
    80002e98:	e84a                	sd	s2,16(sp)
    80002e9a:	e44e                	sd	s3,8(sp)
    80002e9c:	1800                	addi	s0,sp,48
    80002e9e:	892a                	mv	s2,a0
    80002ea0:	84ae                	mv	s1,a1
    80002ea2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	ec0080e7          	jalr	-320(ra) # 80001d64 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002eac:	86ce                	mv	a3,s3
    80002eae:	864a                	mv	a2,s2
    80002eb0:	85a6                	mv	a1,s1
    80002eb2:	7928                	ld	a0,112(a0)
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	8d6080e7          	jalr	-1834(ra) # 8000178a <copyinstr>
  if(err < 0)
    80002ebc:	00054763          	bltz	a0,80002eca <fetchstr+0x3a>
  return strlen(buf);
    80002ec0:	8526                	mv	a0,s1
    80002ec2:	ffffe097          	auipc	ra,0xffffe
    80002ec6:	fa2080e7          	jalr	-94(ra) # 80000e64 <strlen>
}
    80002eca:	70a2                	ld	ra,40(sp)
    80002ecc:	7402                	ld	s0,32(sp)
    80002ece:	64e2                	ld	s1,24(sp)
    80002ed0:	6942                	ld	s2,16(sp)
    80002ed2:	69a2                	ld	s3,8(sp)
    80002ed4:	6145                	addi	sp,sp,48
    80002ed6:	8082                	ret

0000000080002ed8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ed8:	1101                	addi	sp,sp,-32
    80002eda:	ec06                	sd	ra,24(sp)
    80002edc:	e822                	sd	s0,16(sp)
    80002ede:	e426                	sd	s1,8(sp)
    80002ee0:	1000                	addi	s0,sp,32
    80002ee2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	ef2080e7          	jalr	-270(ra) # 80002dd6 <argraw>
    80002eec:	c088                	sw	a0,0(s1)
  return 0;
}
    80002eee:	4501                	li	a0,0
    80002ef0:	60e2                	ld	ra,24(sp)
    80002ef2:	6442                	ld	s0,16(sp)
    80002ef4:	64a2                	ld	s1,8(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret

0000000080002efa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002efa:	1101                	addi	sp,sp,-32
    80002efc:	ec06                	sd	ra,24(sp)
    80002efe:	e822                	sd	s0,16(sp)
    80002f00:	e426                	sd	s1,8(sp)
    80002f02:	1000                	addi	s0,sp,32
    80002f04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f06:	00000097          	auipc	ra,0x0
    80002f0a:	ed0080e7          	jalr	-304(ra) # 80002dd6 <argraw>
    80002f0e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f10:	4501                	li	a0,0
    80002f12:	60e2                	ld	ra,24(sp)
    80002f14:	6442                	ld	s0,16(sp)
    80002f16:	64a2                	ld	s1,8(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret

0000000080002f1c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f1c:	1101                	addi	sp,sp,-32
    80002f1e:	ec06                	sd	ra,24(sp)
    80002f20:	e822                	sd	s0,16(sp)
    80002f22:	e426                	sd	s1,8(sp)
    80002f24:	e04a                	sd	s2,0(sp)
    80002f26:	1000                	addi	s0,sp,32
    80002f28:	84ae                	mv	s1,a1
    80002f2a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	eaa080e7          	jalr	-342(ra) # 80002dd6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f34:	864a                	mv	a2,s2
    80002f36:	85a6                	mv	a1,s1
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	f58080e7          	jalr	-168(ra) # 80002e90 <fetchstr>
}
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	64a2                	ld	s1,8(sp)
    80002f46:	6902                	ld	s2,0(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002f4c:	1101                	addi	sp,sp,-32
    80002f4e:	ec06                	sd	ra,24(sp)
    80002f50:	e822                	sd	s0,16(sp)
    80002f52:	e426                	sd	s1,8(sp)
    80002f54:	e04a                	sd	s2,0(sp)
    80002f56:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	e0c080e7          	jalr	-500(ra) # 80001d64 <myproc>
    80002f60:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f62:	07853903          	ld	s2,120(a0)
    80002f66:	0a893783          	ld	a5,168(s2)
    80002f6a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f6e:	37fd                	addiw	a5,a5,-1
    80002f70:	4751                	li	a4,20
    80002f72:	00f76f63          	bltu	a4,a5,80002f90 <syscall+0x44>
    80002f76:	00369713          	slli	a4,a3,0x3
    80002f7a:	00005797          	auipc	a5,0x5
    80002f7e:	51678793          	addi	a5,a5,1302 # 80008490 <syscalls>
    80002f82:	97ba                	add	a5,a5,a4
    80002f84:	639c                	ld	a5,0(a5)
    80002f86:	c789                	beqz	a5,80002f90 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f88:	9782                	jalr	a5
    80002f8a:	06a93823          	sd	a0,112(s2)
    80002f8e:	a839                	j	80002fac <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f90:	17848613          	addi	a2,s1,376
    80002f94:	588c                	lw	a1,48(s1)
    80002f96:	00005517          	auipc	a0,0x5
    80002f9a:	4c250513          	addi	a0,a0,1218 # 80008458 <states.1760+0x150>
    80002f9e:	ffffd097          	auipc	ra,0xffffd
    80002fa2:	5ea080e7          	jalr	1514(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002fa6:	7cbc                	ld	a5,120(s1)
    80002fa8:	577d                	li	a4,-1
    80002faa:	fbb8                	sd	a4,112(a5)
  }
}
    80002fac:	60e2                	ld	ra,24(sp)
    80002fae:	6442                	ld	s0,16(sp)
    80002fb0:	64a2                	ld	s1,8(sp)
    80002fb2:	6902                	ld	s2,0(sp)
    80002fb4:	6105                	addi	sp,sp,32
    80002fb6:	8082                	ret

0000000080002fb8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002fb8:	1101                	addi	sp,sp,-32
    80002fba:	ec06                	sd	ra,24(sp)
    80002fbc:	e822                	sd	s0,16(sp)
    80002fbe:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002fc0:	fec40593          	addi	a1,s0,-20
    80002fc4:	4501                	li	a0,0
    80002fc6:	00000097          	auipc	ra,0x0
    80002fca:	f12080e7          	jalr	-238(ra) # 80002ed8 <argint>
    return -1;
    80002fce:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fd0:	00054963          	bltz	a0,80002fe2 <sys_exit+0x2a>
  exit(n);
    80002fd4:	fec42503          	lw	a0,-20(s0)
    80002fd8:	fffff097          	auipc	ra,0xfffff
    80002fdc:	754080e7          	jalr	1876(ra) # 8000272c <exit>
  return 0;  // not reached
    80002fe0:	4781                	li	a5,0
}
    80002fe2:	853e                	mv	a0,a5
    80002fe4:	60e2                	ld	ra,24(sp)
    80002fe6:	6442                	ld	s0,16(sp)
    80002fe8:	6105                	addi	sp,sp,32
    80002fea:	8082                	ret

0000000080002fec <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fec:	1141                	addi	sp,sp,-16
    80002fee:	e406                	sd	ra,8(sp)
    80002ff0:	e022                	sd	s0,0(sp)
    80002ff2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ff4:	fffff097          	auipc	ra,0xfffff
    80002ff8:	d70080e7          	jalr	-656(ra) # 80001d64 <myproc>
}
    80002ffc:	5908                	lw	a0,48(a0)
    80002ffe:	60a2                	ld	ra,8(sp)
    80003000:	6402                	ld	s0,0(sp)
    80003002:	0141                	addi	sp,sp,16
    80003004:	8082                	ret

0000000080003006 <sys_fork>:

uint64
sys_fork(void)
{
    80003006:	1141                	addi	sp,sp,-16
    80003008:	e406                	sd	ra,8(sp)
    8000300a:	e022                	sd	s0,0(sp)
    8000300c:	0800                	addi	s0,sp,16
  return fork();
    8000300e:	fffff097          	auipc	ra,0xfffff
    80003012:	14c080e7          	jalr	332(ra) # 8000215a <fork>
}
    80003016:	60a2                	ld	ra,8(sp)
    80003018:	6402                	ld	s0,0(sp)
    8000301a:	0141                	addi	sp,sp,16
    8000301c:	8082                	ret

000000008000301e <sys_wait>:

uint64
sys_wait(void)
{
    8000301e:	1101                	addi	sp,sp,-32
    80003020:	ec06                	sd	ra,24(sp)
    80003022:	e822                	sd	s0,16(sp)
    80003024:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003026:	fe840593          	addi	a1,s0,-24
    8000302a:	4501                	li	a0,0
    8000302c:	00000097          	auipc	ra,0x0
    80003030:	ece080e7          	jalr	-306(ra) # 80002efa <argaddr>
    80003034:	87aa                	mv	a5,a0
    return -1;
    80003036:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003038:	0007c863          	bltz	a5,80003048 <sys_wait+0x2a>
  return wait(p);
    8000303c:	fe843503          	ld	a0,-24(s0)
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	4d8080e7          	jalr	1240(ra) # 80002518 <wait>
}
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	6105                	addi	sp,sp,32
    8000304e:	8082                	ret

0000000080003050 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003050:	7179                	addi	sp,sp,-48
    80003052:	f406                	sd	ra,40(sp)
    80003054:	f022                	sd	s0,32(sp)
    80003056:	ec26                	sd	s1,24(sp)
    80003058:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000305a:	fdc40593          	addi	a1,s0,-36
    8000305e:	4501                	li	a0,0
    80003060:	00000097          	auipc	ra,0x0
    80003064:	e78080e7          	jalr	-392(ra) # 80002ed8 <argint>
    80003068:	87aa                	mv	a5,a0
    return -1;
    8000306a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    8000306c:	0207c063          	bltz	a5,8000308c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003070:	fffff097          	auipc	ra,0xfffff
    80003074:	cf4080e7          	jalr	-780(ra) # 80001d64 <myproc>
    80003078:	5524                	lw	s1,104(a0)
  if(growproc(n) < 0)
    8000307a:	fdc42503          	lw	a0,-36(s0)
    8000307e:	fffff097          	auipc	ra,0xfffff
    80003082:	068080e7          	jalr	104(ra) # 800020e6 <growproc>
    80003086:	00054863          	bltz	a0,80003096 <sys_sbrk+0x46>
    return -1;
  return addr;
    8000308a:	8526                	mv	a0,s1
}
    8000308c:	70a2                	ld	ra,40(sp)
    8000308e:	7402                	ld	s0,32(sp)
    80003090:	64e2                	ld	s1,24(sp)
    80003092:	6145                	addi	sp,sp,48
    80003094:	8082                	ret
    return -1;
    80003096:	557d                	li	a0,-1
    80003098:	bfd5                	j	8000308c <sys_sbrk+0x3c>

000000008000309a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000309a:	7139                	addi	sp,sp,-64
    8000309c:	fc06                	sd	ra,56(sp)
    8000309e:	f822                	sd	s0,48(sp)
    800030a0:	f426                	sd	s1,40(sp)
    800030a2:	f04a                	sd	s2,32(sp)
    800030a4:	ec4e                	sd	s3,24(sp)
    800030a6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800030a8:	fcc40593          	addi	a1,s0,-52
    800030ac:	4501                	li	a0,0
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	e2a080e7          	jalr	-470(ra) # 80002ed8 <argint>
    return -1;
    800030b6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800030b8:	06054563          	bltz	a0,80003122 <sys_sleep+0x88>
  acquire(&tickslock);
    800030bc:	00015517          	auipc	a0,0x15
    800030c0:	95450513          	addi	a0,a0,-1708 # 80017a10 <tickslock>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	b20080e7          	jalr	-1248(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    800030cc:	00006917          	auipc	s2,0x6
    800030d0:	f6492903          	lw	s2,-156(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800030d4:	fcc42783          	lw	a5,-52(s0)
    800030d8:	cf85                	beqz	a5,80003110 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030da:	00015997          	auipc	s3,0x15
    800030de:	93698993          	addi	s3,s3,-1738 # 80017a10 <tickslock>
    800030e2:	00006497          	auipc	s1,0x6
    800030e6:	f4e48493          	addi	s1,s1,-178 # 80009030 <ticks>
    if(myproc()->killed){
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	c7a080e7          	jalr	-902(ra) # 80001d64 <myproc>
    800030f2:	551c                	lw	a5,40(a0)
    800030f4:	ef9d                	bnez	a5,80003132 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800030f6:	85ce                	mv	a1,s3
    800030f8:	8526                	mv	a0,s1
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	3a8080e7          	jalr	936(ra) # 800024a2 <sleep>
  while(ticks - ticks0 < n){
    80003102:	409c                	lw	a5,0(s1)
    80003104:	412787bb          	subw	a5,a5,s2
    80003108:	fcc42703          	lw	a4,-52(s0)
    8000310c:	fce7efe3          	bltu	a5,a4,800030ea <sys_sleep+0x50>
  }
  release(&tickslock);
    80003110:	00015517          	auipc	a0,0x15
    80003114:	90050513          	addi	a0,a0,-1792 # 80017a10 <tickslock>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	b80080e7          	jalr	-1152(ra) # 80000c98 <release>
  return 0;
    80003120:	4781                	li	a5,0
}
    80003122:	853e                	mv	a0,a5
    80003124:	70e2                	ld	ra,56(sp)
    80003126:	7442                	ld	s0,48(sp)
    80003128:	74a2                	ld	s1,40(sp)
    8000312a:	7902                	ld	s2,32(sp)
    8000312c:	69e2                	ld	s3,24(sp)
    8000312e:	6121                	addi	sp,sp,64
    80003130:	8082                	ret
      release(&tickslock);
    80003132:	00015517          	auipc	a0,0x15
    80003136:	8de50513          	addi	a0,a0,-1826 # 80017a10 <tickslock>
    8000313a:	ffffe097          	auipc	ra,0xffffe
    8000313e:	b5e080e7          	jalr	-1186(ra) # 80000c98 <release>
      return -1;
    80003142:	57fd                	li	a5,-1
    80003144:	bff9                	j	80003122 <sys_sleep+0x88>

0000000080003146 <sys_kill>:

uint64
sys_kill(void)
{
    80003146:	1101                	addi	sp,sp,-32
    80003148:	ec06                	sd	ra,24(sp)
    8000314a:	e822                	sd	s0,16(sp)
    8000314c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000314e:	fec40593          	addi	a1,s0,-20
    80003152:	4501                	li	a0,0
    80003154:	00000097          	auipc	ra,0x0
    80003158:	d84080e7          	jalr	-636(ra) # 80002ed8 <argint>
    8000315c:	87aa                	mv	a5,a0
    return -1;
    8000315e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003160:	0007c863          	bltz	a5,80003170 <sys_kill+0x2a>
  return kill(pid);
    80003164:	fec42503          	lw	a0,-20(s0)
    80003168:	fffff097          	auipc	ra,0xfffff
    8000316c:	69a080e7          	jalr	1690(ra) # 80002802 <kill>
}
    80003170:	60e2                	ld	ra,24(sp)
    80003172:	6442                	ld	s0,16(sp)
    80003174:	6105                	addi	sp,sp,32
    80003176:	8082                	ret

0000000080003178 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003178:	1101                	addi	sp,sp,-32
    8000317a:	ec06                	sd	ra,24(sp)
    8000317c:	e822                	sd	s0,16(sp)
    8000317e:	e426                	sd	s1,8(sp)
    80003180:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003182:	00015517          	auipc	a0,0x15
    80003186:	88e50513          	addi	a0,a0,-1906 # 80017a10 <tickslock>
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	a5a080e7          	jalr	-1446(ra) # 80000be4 <acquire>
  xticks = ticks;
    80003192:	00006497          	auipc	s1,0x6
    80003196:	e9e4a483          	lw	s1,-354(s1) # 80009030 <ticks>
  release(&tickslock);
    8000319a:	00015517          	auipc	a0,0x15
    8000319e:	87650513          	addi	a0,a0,-1930 # 80017a10 <tickslock>
    800031a2:	ffffe097          	auipc	ra,0xffffe
    800031a6:	af6080e7          	jalr	-1290(ra) # 80000c98 <release>
  return xticks;
}
    800031aa:	02049513          	slli	a0,s1,0x20
    800031ae:	9101                	srli	a0,a0,0x20
    800031b0:	60e2                	ld	ra,24(sp)
    800031b2:	6442                	ld	s0,16(sp)
    800031b4:	64a2                	ld	s1,8(sp)
    800031b6:	6105                	addi	sp,sp,32
    800031b8:	8082                	ret

00000000800031ba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800031ba:	7179                	addi	sp,sp,-48
    800031bc:	f406                	sd	ra,40(sp)
    800031be:	f022                	sd	s0,32(sp)
    800031c0:	ec26                	sd	s1,24(sp)
    800031c2:	e84a                	sd	s2,16(sp)
    800031c4:	e44e                	sd	s3,8(sp)
    800031c6:	e052                	sd	s4,0(sp)
    800031c8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800031ca:	00005597          	auipc	a1,0x5
    800031ce:	37658593          	addi	a1,a1,886 # 80008540 <syscalls+0xb0>
    800031d2:	00015517          	auipc	a0,0x15
    800031d6:	85650513          	addi	a0,a0,-1962 # 80017a28 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	97a080e7          	jalr	-1670(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800031e2:	0001d797          	auipc	a5,0x1d
    800031e6:	84678793          	addi	a5,a5,-1978 # 8001fa28 <bcache+0x8000>
    800031ea:	0001d717          	auipc	a4,0x1d
    800031ee:	aa670713          	addi	a4,a4,-1370 # 8001fc90 <bcache+0x8268>
    800031f2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800031f6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031fa:	00015497          	auipc	s1,0x15
    800031fe:	84648493          	addi	s1,s1,-1978 # 80017a40 <bcache+0x18>
    b->next = bcache.head.next;
    80003202:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003204:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003206:	00005a17          	auipc	s4,0x5
    8000320a:	342a0a13          	addi	s4,s4,834 # 80008548 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000320e:	2b893783          	ld	a5,696(s2)
    80003212:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003214:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003218:	85d2                	mv	a1,s4
    8000321a:	01048513          	addi	a0,s1,16
    8000321e:	00001097          	auipc	ra,0x1
    80003222:	4bc080e7          	jalr	1212(ra) # 800046da <initsleeplock>
    bcache.head.next->prev = b;
    80003226:	2b893783          	ld	a5,696(s2)
    8000322a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000322c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003230:	45848493          	addi	s1,s1,1112
    80003234:	fd349de3          	bne	s1,s3,8000320e <binit+0x54>
  }
}
    80003238:	70a2                	ld	ra,40(sp)
    8000323a:	7402                	ld	s0,32(sp)
    8000323c:	64e2                	ld	s1,24(sp)
    8000323e:	6942                	ld	s2,16(sp)
    80003240:	69a2                	ld	s3,8(sp)
    80003242:	6a02                	ld	s4,0(sp)
    80003244:	6145                	addi	sp,sp,48
    80003246:	8082                	ret

0000000080003248 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003248:	7179                	addi	sp,sp,-48
    8000324a:	f406                	sd	ra,40(sp)
    8000324c:	f022                	sd	s0,32(sp)
    8000324e:	ec26                	sd	s1,24(sp)
    80003250:	e84a                	sd	s2,16(sp)
    80003252:	e44e                	sd	s3,8(sp)
    80003254:	1800                	addi	s0,sp,48
    80003256:	89aa                	mv	s3,a0
    80003258:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000325a:	00014517          	auipc	a0,0x14
    8000325e:	7ce50513          	addi	a0,a0,1998 # 80017a28 <bcache>
    80003262:	ffffe097          	auipc	ra,0xffffe
    80003266:	982080e7          	jalr	-1662(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000326a:	0001d497          	auipc	s1,0x1d
    8000326e:	a764b483          	ld	s1,-1418(s1) # 8001fce0 <bcache+0x82b8>
    80003272:	0001d797          	auipc	a5,0x1d
    80003276:	a1e78793          	addi	a5,a5,-1506 # 8001fc90 <bcache+0x8268>
    8000327a:	02f48f63          	beq	s1,a5,800032b8 <bread+0x70>
    8000327e:	873e                	mv	a4,a5
    80003280:	a021                	j	80003288 <bread+0x40>
    80003282:	68a4                	ld	s1,80(s1)
    80003284:	02e48a63          	beq	s1,a4,800032b8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003288:	449c                	lw	a5,8(s1)
    8000328a:	ff379ce3          	bne	a5,s3,80003282 <bread+0x3a>
    8000328e:	44dc                	lw	a5,12(s1)
    80003290:	ff2799e3          	bne	a5,s2,80003282 <bread+0x3a>
      b->refcnt++;
    80003294:	40bc                	lw	a5,64(s1)
    80003296:	2785                	addiw	a5,a5,1
    80003298:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000329a:	00014517          	auipc	a0,0x14
    8000329e:	78e50513          	addi	a0,a0,1934 # 80017a28 <bcache>
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	9f6080e7          	jalr	-1546(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    800032aa:	01048513          	addi	a0,s1,16
    800032ae:	00001097          	auipc	ra,0x1
    800032b2:	466080e7          	jalr	1126(ra) # 80004714 <acquiresleep>
      return b;
    800032b6:	a8b9                	j	80003314 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032b8:	0001d497          	auipc	s1,0x1d
    800032bc:	a204b483          	ld	s1,-1504(s1) # 8001fcd8 <bcache+0x82b0>
    800032c0:	0001d797          	auipc	a5,0x1d
    800032c4:	9d078793          	addi	a5,a5,-1584 # 8001fc90 <bcache+0x8268>
    800032c8:	00f48863          	beq	s1,a5,800032d8 <bread+0x90>
    800032cc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800032ce:	40bc                	lw	a5,64(s1)
    800032d0:	cf81                	beqz	a5,800032e8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032d2:	64a4                	ld	s1,72(s1)
    800032d4:	fee49de3          	bne	s1,a4,800032ce <bread+0x86>
  panic("bget: no buffers");
    800032d8:	00005517          	auipc	a0,0x5
    800032dc:	27850513          	addi	a0,a0,632 # 80008550 <syscalls+0xc0>
    800032e0:	ffffd097          	auipc	ra,0xffffd
    800032e4:	25e080e7          	jalr	606(ra) # 8000053e <panic>
      b->dev = dev;
    800032e8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800032ec:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800032f0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032f4:	4785                	li	a5,1
    800032f6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032f8:	00014517          	auipc	a0,0x14
    800032fc:	73050513          	addi	a0,a0,1840 # 80017a28 <bcache>
    80003300:	ffffe097          	auipc	ra,0xffffe
    80003304:	998080e7          	jalr	-1640(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003308:	01048513          	addi	a0,s1,16
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	408080e7          	jalr	1032(ra) # 80004714 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003314:	409c                	lw	a5,0(s1)
    80003316:	cb89                	beqz	a5,80003328 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003318:	8526                	mv	a0,s1
    8000331a:	70a2                	ld	ra,40(sp)
    8000331c:	7402                	ld	s0,32(sp)
    8000331e:	64e2                	ld	s1,24(sp)
    80003320:	6942                	ld	s2,16(sp)
    80003322:	69a2                	ld	s3,8(sp)
    80003324:	6145                	addi	sp,sp,48
    80003326:	8082                	ret
    virtio_disk_rw(b, 0);
    80003328:	4581                	li	a1,0
    8000332a:	8526                	mv	a0,s1
    8000332c:	00003097          	auipc	ra,0x3
    80003330:	f0a080e7          	jalr	-246(ra) # 80006236 <virtio_disk_rw>
    b->valid = 1;
    80003334:	4785                	li	a5,1
    80003336:	c09c                	sw	a5,0(s1)
  return b;
    80003338:	b7c5                	j	80003318 <bread+0xd0>

000000008000333a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	e426                	sd	s1,8(sp)
    80003342:	1000                	addi	s0,sp,32
    80003344:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003346:	0541                	addi	a0,a0,16
    80003348:	00001097          	auipc	ra,0x1
    8000334c:	466080e7          	jalr	1126(ra) # 800047ae <holdingsleep>
    80003350:	cd01                	beqz	a0,80003368 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003352:	4585                	li	a1,1
    80003354:	8526                	mv	a0,s1
    80003356:	00003097          	auipc	ra,0x3
    8000335a:	ee0080e7          	jalr	-288(ra) # 80006236 <virtio_disk_rw>
}
    8000335e:	60e2                	ld	ra,24(sp)
    80003360:	6442                	ld	s0,16(sp)
    80003362:	64a2                	ld	s1,8(sp)
    80003364:	6105                	addi	sp,sp,32
    80003366:	8082                	ret
    panic("bwrite");
    80003368:	00005517          	auipc	a0,0x5
    8000336c:	20050513          	addi	a0,a0,512 # 80008568 <syscalls+0xd8>
    80003370:	ffffd097          	auipc	ra,0xffffd
    80003374:	1ce080e7          	jalr	462(ra) # 8000053e <panic>

0000000080003378 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003378:	1101                	addi	sp,sp,-32
    8000337a:	ec06                	sd	ra,24(sp)
    8000337c:	e822                	sd	s0,16(sp)
    8000337e:	e426                	sd	s1,8(sp)
    80003380:	e04a                	sd	s2,0(sp)
    80003382:	1000                	addi	s0,sp,32
    80003384:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003386:	01050913          	addi	s2,a0,16
    8000338a:	854a                	mv	a0,s2
    8000338c:	00001097          	auipc	ra,0x1
    80003390:	422080e7          	jalr	1058(ra) # 800047ae <holdingsleep>
    80003394:	c92d                	beqz	a0,80003406 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003396:	854a                	mv	a0,s2
    80003398:	00001097          	auipc	ra,0x1
    8000339c:	3d2080e7          	jalr	978(ra) # 8000476a <releasesleep>

  acquire(&bcache.lock);
    800033a0:	00014517          	auipc	a0,0x14
    800033a4:	68850513          	addi	a0,a0,1672 # 80017a28 <bcache>
    800033a8:	ffffe097          	auipc	ra,0xffffe
    800033ac:	83c080e7          	jalr	-1988(ra) # 80000be4 <acquire>
  b->refcnt--;
    800033b0:	40bc                	lw	a5,64(s1)
    800033b2:	37fd                	addiw	a5,a5,-1
    800033b4:	0007871b          	sext.w	a4,a5
    800033b8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800033ba:	eb05                	bnez	a4,800033ea <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800033bc:	68bc                	ld	a5,80(s1)
    800033be:	64b8                	ld	a4,72(s1)
    800033c0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800033c2:	64bc                	ld	a5,72(s1)
    800033c4:	68b8                	ld	a4,80(s1)
    800033c6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800033c8:	0001c797          	auipc	a5,0x1c
    800033cc:	66078793          	addi	a5,a5,1632 # 8001fa28 <bcache+0x8000>
    800033d0:	2b87b703          	ld	a4,696(a5)
    800033d4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800033d6:	0001d717          	auipc	a4,0x1d
    800033da:	8ba70713          	addi	a4,a4,-1862 # 8001fc90 <bcache+0x8268>
    800033de:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800033e0:	2b87b703          	ld	a4,696(a5)
    800033e4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800033e6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800033ea:	00014517          	auipc	a0,0x14
    800033ee:	63e50513          	addi	a0,a0,1598 # 80017a28 <bcache>
    800033f2:	ffffe097          	auipc	ra,0xffffe
    800033f6:	8a6080e7          	jalr	-1882(ra) # 80000c98 <release>
}
    800033fa:	60e2                	ld	ra,24(sp)
    800033fc:	6442                	ld	s0,16(sp)
    800033fe:	64a2                	ld	s1,8(sp)
    80003400:	6902                	ld	s2,0(sp)
    80003402:	6105                	addi	sp,sp,32
    80003404:	8082                	ret
    panic("brelse");
    80003406:	00005517          	auipc	a0,0x5
    8000340a:	16a50513          	addi	a0,a0,362 # 80008570 <syscalls+0xe0>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	130080e7          	jalr	304(ra) # 8000053e <panic>

0000000080003416 <bpin>:

void
bpin(struct buf *b) {
    80003416:	1101                	addi	sp,sp,-32
    80003418:	ec06                	sd	ra,24(sp)
    8000341a:	e822                	sd	s0,16(sp)
    8000341c:	e426                	sd	s1,8(sp)
    8000341e:	1000                	addi	s0,sp,32
    80003420:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003422:	00014517          	auipc	a0,0x14
    80003426:	60650513          	addi	a0,a0,1542 # 80017a28 <bcache>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	7ba080e7          	jalr	1978(ra) # 80000be4 <acquire>
  b->refcnt++;
    80003432:	40bc                	lw	a5,64(s1)
    80003434:	2785                	addiw	a5,a5,1
    80003436:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003438:	00014517          	auipc	a0,0x14
    8000343c:	5f050513          	addi	a0,a0,1520 # 80017a28 <bcache>
    80003440:	ffffe097          	auipc	ra,0xffffe
    80003444:	858080e7          	jalr	-1960(ra) # 80000c98 <release>
}
    80003448:	60e2                	ld	ra,24(sp)
    8000344a:	6442                	ld	s0,16(sp)
    8000344c:	64a2                	ld	s1,8(sp)
    8000344e:	6105                	addi	sp,sp,32
    80003450:	8082                	ret

0000000080003452 <bunpin>:

void
bunpin(struct buf *b) {
    80003452:	1101                	addi	sp,sp,-32
    80003454:	ec06                	sd	ra,24(sp)
    80003456:	e822                	sd	s0,16(sp)
    80003458:	e426                	sd	s1,8(sp)
    8000345a:	1000                	addi	s0,sp,32
    8000345c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000345e:	00014517          	auipc	a0,0x14
    80003462:	5ca50513          	addi	a0,a0,1482 # 80017a28 <bcache>
    80003466:	ffffd097          	auipc	ra,0xffffd
    8000346a:	77e080e7          	jalr	1918(ra) # 80000be4 <acquire>
  b->refcnt--;
    8000346e:	40bc                	lw	a5,64(s1)
    80003470:	37fd                	addiw	a5,a5,-1
    80003472:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003474:	00014517          	auipc	a0,0x14
    80003478:	5b450513          	addi	a0,a0,1460 # 80017a28 <bcache>
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	81c080e7          	jalr	-2020(ra) # 80000c98 <release>
}
    80003484:	60e2                	ld	ra,24(sp)
    80003486:	6442                	ld	s0,16(sp)
    80003488:	64a2                	ld	s1,8(sp)
    8000348a:	6105                	addi	sp,sp,32
    8000348c:	8082                	ret

000000008000348e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000348e:	1101                	addi	sp,sp,-32
    80003490:	ec06                	sd	ra,24(sp)
    80003492:	e822                	sd	s0,16(sp)
    80003494:	e426                	sd	s1,8(sp)
    80003496:	e04a                	sd	s2,0(sp)
    80003498:	1000                	addi	s0,sp,32
    8000349a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000349c:	00d5d59b          	srliw	a1,a1,0xd
    800034a0:	0001d797          	auipc	a5,0x1d
    800034a4:	c647a783          	lw	a5,-924(a5) # 80020104 <sb+0x1c>
    800034a8:	9dbd                	addw	a1,a1,a5
    800034aa:	00000097          	auipc	ra,0x0
    800034ae:	d9e080e7          	jalr	-610(ra) # 80003248 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800034b2:	0074f713          	andi	a4,s1,7
    800034b6:	4785                	li	a5,1
    800034b8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800034bc:	14ce                	slli	s1,s1,0x33
    800034be:	90d9                	srli	s1,s1,0x36
    800034c0:	00950733          	add	a4,a0,s1
    800034c4:	05874703          	lbu	a4,88(a4)
    800034c8:	00e7f6b3          	and	a3,a5,a4
    800034cc:	c69d                	beqz	a3,800034fa <bfree+0x6c>
    800034ce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800034d0:	94aa                	add	s1,s1,a0
    800034d2:	fff7c793          	not	a5,a5
    800034d6:	8ff9                	and	a5,a5,a4
    800034d8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800034dc:	00001097          	auipc	ra,0x1
    800034e0:	118080e7          	jalr	280(ra) # 800045f4 <log_write>
  brelse(bp);
    800034e4:	854a                	mv	a0,s2
    800034e6:	00000097          	auipc	ra,0x0
    800034ea:	e92080e7          	jalr	-366(ra) # 80003378 <brelse>
}
    800034ee:	60e2                	ld	ra,24(sp)
    800034f0:	6442                	ld	s0,16(sp)
    800034f2:	64a2                	ld	s1,8(sp)
    800034f4:	6902                	ld	s2,0(sp)
    800034f6:	6105                	addi	sp,sp,32
    800034f8:	8082                	ret
    panic("freeing free block");
    800034fa:	00005517          	auipc	a0,0x5
    800034fe:	07e50513          	addi	a0,a0,126 # 80008578 <syscalls+0xe8>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	03c080e7          	jalr	60(ra) # 8000053e <panic>

000000008000350a <balloc>:
{
    8000350a:	711d                	addi	sp,sp,-96
    8000350c:	ec86                	sd	ra,88(sp)
    8000350e:	e8a2                	sd	s0,80(sp)
    80003510:	e4a6                	sd	s1,72(sp)
    80003512:	e0ca                	sd	s2,64(sp)
    80003514:	fc4e                	sd	s3,56(sp)
    80003516:	f852                	sd	s4,48(sp)
    80003518:	f456                	sd	s5,40(sp)
    8000351a:	f05a                	sd	s6,32(sp)
    8000351c:	ec5e                	sd	s7,24(sp)
    8000351e:	e862                	sd	s8,16(sp)
    80003520:	e466                	sd	s9,8(sp)
    80003522:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003524:	0001d797          	auipc	a5,0x1d
    80003528:	bc87a783          	lw	a5,-1080(a5) # 800200ec <sb+0x4>
    8000352c:	cbd1                	beqz	a5,800035c0 <balloc+0xb6>
    8000352e:	8baa                	mv	s7,a0
    80003530:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003532:	0001db17          	auipc	s6,0x1d
    80003536:	bb6b0b13          	addi	s6,s6,-1098 # 800200e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000353a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000353c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000353e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003540:	6c89                	lui	s9,0x2
    80003542:	a831                	j	8000355e <balloc+0x54>
    brelse(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	e32080e7          	jalr	-462(ra) # 80003378 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000354e:	015c87bb          	addw	a5,s9,s5
    80003552:	00078a9b          	sext.w	s5,a5
    80003556:	004b2703          	lw	a4,4(s6)
    8000355a:	06eaf363          	bgeu	s5,a4,800035c0 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000355e:	41fad79b          	sraiw	a5,s5,0x1f
    80003562:	0137d79b          	srliw	a5,a5,0x13
    80003566:	015787bb          	addw	a5,a5,s5
    8000356a:	40d7d79b          	sraiw	a5,a5,0xd
    8000356e:	01cb2583          	lw	a1,28(s6)
    80003572:	9dbd                	addw	a1,a1,a5
    80003574:	855e                	mv	a0,s7
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	cd2080e7          	jalr	-814(ra) # 80003248 <bread>
    8000357e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003580:	004b2503          	lw	a0,4(s6)
    80003584:	000a849b          	sext.w	s1,s5
    80003588:	8662                	mv	a2,s8
    8000358a:	faa4fde3          	bgeu	s1,a0,80003544 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000358e:	41f6579b          	sraiw	a5,a2,0x1f
    80003592:	01d7d69b          	srliw	a3,a5,0x1d
    80003596:	00c6873b          	addw	a4,a3,a2
    8000359a:	00777793          	andi	a5,a4,7
    8000359e:	9f95                	subw	a5,a5,a3
    800035a0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035a4:	4037571b          	sraiw	a4,a4,0x3
    800035a8:	00e906b3          	add	a3,s2,a4
    800035ac:	0586c683          	lbu	a3,88(a3)
    800035b0:	00d7f5b3          	and	a1,a5,a3
    800035b4:	cd91                	beqz	a1,800035d0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b6:	2605                	addiw	a2,a2,1
    800035b8:	2485                	addiw	s1,s1,1
    800035ba:	fd4618e3          	bne	a2,s4,8000358a <balloc+0x80>
    800035be:	b759                	j	80003544 <balloc+0x3a>
  panic("balloc: out of blocks");
    800035c0:	00005517          	auipc	a0,0x5
    800035c4:	fd050513          	addi	a0,a0,-48 # 80008590 <syscalls+0x100>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	f76080e7          	jalr	-138(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035d0:	974a                	add	a4,a4,s2
    800035d2:	8fd5                	or	a5,a5,a3
    800035d4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800035d8:	854a                	mv	a0,s2
    800035da:	00001097          	auipc	ra,0x1
    800035de:	01a080e7          	jalr	26(ra) # 800045f4 <log_write>
        brelse(bp);
    800035e2:	854a                	mv	a0,s2
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	d94080e7          	jalr	-620(ra) # 80003378 <brelse>
  bp = bread(dev, bno);
    800035ec:	85a6                	mv	a1,s1
    800035ee:	855e                	mv	a0,s7
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	c58080e7          	jalr	-936(ra) # 80003248 <bread>
    800035f8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035fa:	40000613          	li	a2,1024
    800035fe:	4581                	li	a1,0
    80003600:	05850513          	addi	a0,a0,88
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	6dc080e7          	jalr	1756(ra) # 80000ce0 <memset>
  log_write(bp);
    8000360c:	854a                	mv	a0,s2
    8000360e:	00001097          	auipc	ra,0x1
    80003612:	fe6080e7          	jalr	-26(ra) # 800045f4 <log_write>
  brelse(bp);
    80003616:	854a                	mv	a0,s2
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	d60080e7          	jalr	-672(ra) # 80003378 <brelse>
}
    80003620:	8526                	mv	a0,s1
    80003622:	60e6                	ld	ra,88(sp)
    80003624:	6446                	ld	s0,80(sp)
    80003626:	64a6                	ld	s1,72(sp)
    80003628:	6906                	ld	s2,64(sp)
    8000362a:	79e2                	ld	s3,56(sp)
    8000362c:	7a42                	ld	s4,48(sp)
    8000362e:	7aa2                	ld	s5,40(sp)
    80003630:	7b02                	ld	s6,32(sp)
    80003632:	6be2                	ld	s7,24(sp)
    80003634:	6c42                	ld	s8,16(sp)
    80003636:	6ca2                	ld	s9,8(sp)
    80003638:	6125                	addi	sp,sp,96
    8000363a:	8082                	ret

000000008000363c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000363c:	7179                	addi	sp,sp,-48
    8000363e:	f406                	sd	ra,40(sp)
    80003640:	f022                	sd	s0,32(sp)
    80003642:	ec26                	sd	s1,24(sp)
    80003644:	e84a                	sd	s2,16(sp)
    80003646:	e44e                	sd	s3,8(sp)
    80003648:	e052                	sd	s4,0(sp)
    8000364a:	1800                	addi	s0,sp,48
    8000364c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000364e:	47ad                	li	a5,11
    80003650:	04b7fe63          	bgeu	a5,a1,800036ac <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003654:	ff45849b          	addiw	s1,a1,-12
    80003658:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000365c:	0ff00793          	li	a5,255
    80003660:	0ae7e363          	bltu	a5,a4,80003706 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003664:	08052583          	lw	a1,128(a0)
    80003668:	c5ad                	beqz	a1,800036d2 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000366a:	00092503          	lw	a0,0(s2)
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	bda080e7          	jalr	-1062(ra) # 80003248 <bread>
    80003676:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003678:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000367c:	02049593          	slli	a1,s1,0x20
    80003680:	9181                	srli	a1,a1,0x20
    80003682:	058a                	slli	a1,a1,0x2
    80003684:	00b784b3          	add	s1,a5,a1
    80003688:	0004a983          	lw	s3,0(s1)
    8000368c:	04098d63          	beqz	s3,800036e6 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003690:	8552                	mv	a0,s4
    80003692:	00000097          	auipc	ra,0x0
    80003696:	ce6080e7          	jalr	-794(ra) # 80003378 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000369a:	854e                	mv	a0,s3
    8000369c:	70a2                	ld	ra,40(sp)
    8000369e:	7402                	ld	s0,32(sp)
    800036a0:	64e2                	ld	s1,24(sp)
    800036a2:	6942                	ld	s2,16(sp)
    800036a4:	69a2                	ld	s3,8(sp)
    800036a6:	6a02                	ld	s4,0(sp)
    800036a8:	6145                	addi	sp,sp,48
    800036aa:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800036ac:	02059493          	slli	s1,a1,0x20
    800036b0:	9081                	srli	s1,s1,0x20
    800036b2:	048a                	slli	s1,s1,0x2
    800036b4:	94aa                	add	s1,s1,a0
    800036b6:	0504a983          	lw	s3,80(s1)
    800036ba:	fe0990e3          	bnez	s3,8000369a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800036be:	4108                	lw	a0,0(a0)
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	e4a080e7          	jalr	-438(ra) # 8000350a <balloc>
    800036c8:	0005099b          	sext.w	s3,a0
    800036cc:	0534a823          	sw	s3,80(s1)
    800036d0:	b7e9                	j	8000369a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800036d2:	4108                	lw	a0,0(a0)
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	e36080e7          	jalr	-458(ra) # 8000350a <balloc>
    800036dc:	0005059b          	sext.w	a1,a0
    800036e0:	08b92023          	sw	a1,128(s2)
    800036e4:	b759                	j	8000366a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800036e6:	00092503          	lw	a0,0(s2)
    800036ea:	00000097          	auipc	ra,0x0
    800036ee:	e20080e7          	jalr	-480(ra) # 8000350a <balloc>
    800036f2:	0005099b          	sext.w	s3,a0
    800036f6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800036fa:	8552                	mv	a0,s4
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	ef8080e7          	jalr	-264(ra) # 800045f4 <log_write>
    80003704:	b771                	j	80003690 <bmap+0x54>
  panic("bmap: out of range");
    80003706:	00005517          	auipc	a0,0x5
    8000370a:	ea250513          	addi	a0,a0,-350 # 800085a8 <syscalls+0x118>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	e30080e7          	jalr	-464(ra) # 8000053e <panic>

0000000080003716 <iget>:
{
    80003716:	7179                	addi	sp,sp,-48
    80003718:	f406                	sd	ra,40(sp)
    8000371a:	f022                	sd	s0,32(sp)
    8000371c:	ec26                	sd	s1,24(sp)
    8000371e:	e84a                	sd	s2,16(sp)
    80003720:	e44e                	sd	s3,8(sp)
    80003722:	e052                	sd	s4,0(sp)
    80003724:	1800                	addi	s0,sp,48
    80003726:	89aa                	mv	s3,a0
    80003728:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000372a:	0001d517          	auipc	a0,0x1d
    8000372e:	9de50513          	addi	a0,a0,-1570 # 80020108 <itable>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	4b2080e7          	jalr	1202(ra) # 80000be4 <acquire>
  empty = 0;
    8000373a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000373c:	0001d497          	auipc	s1,0x1d
    80003740:	9e448493          	addi	s1,s1,-1564 # 80020120 <itable+0x18>
    80003744:	0001e697          	auipc	a3,0x1e
    80003748:	46c68693          	addi	a3,a3,1132 # 80021bb0 <log>
    8000374c:	a039                	j	8000375a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000374e:	02090b63          	beqz	s2,80003784 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003752:	08848493          	addi	s1,s1,136
    80003756:	02d48a63          	beq	s1,a3,8000378a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000375a:	449c                	lw	a5,8(s1)
    8000375c:	fef059e3          	blez	a5,8000374e <iget+0x38>
    80003760:	4098                	lw	a4,0(s1)
    80003762:	ff3716e3          	bne	a4,s3,8000374e <iget+0x38>
    80003766:	40d8                	lw	a4,4(s1)
    80003768:	ff4713e3          	bne	a4,s4,8000374e <iget+0x38>
      ip->ref++;
    8000376c:	2785                	addiw	a5,a5,1
    8000376e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003770:	0001d517          	auipc	a0,0x1d
    80003774:	99850513          	addi	a0,a0,-1640 # 80020108 <itable>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	520080e7          	jalr	1312(ra) # 80000c98 <release>
      return ip;
    80003780:	8926                	mv	s2,s1
    80003782:	a03d                	j	800037b0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003784:	f7f9                	bnez	a5,80003752 <iget+0x3c>
    80003786:	8926                	mv	s2,s1
    80003788:	b7e9                	j	80003752 <iget+0x3c>
  if(empty == 0)
    8000378a:	02090c63          	beqz	s2,800037c2 <iget+0xac>
  ip->dev = dev;
    8000378e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003792:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003796:	4785                	li	a5,1
    80003798:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000379c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800037a0:	0001d517          	auipc	a0,0x1d
    800037a4:	96850513          	addi	a0,a0,-1688 # 80020108 <itable>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	4f0080e7          	jalr	1264(ra) # 80000c98 <release>
}
    800037b0:	854a                	mv	a0,s2
    800037b2:	70a2                	ld	ra,40(sp)
    800037b4:	7402                	ld	s0,32(sp)
    800037b6:	64e2                	ld	s1,24(sp)
    800037b8:	6942                	ld	s2,16(sp)
    800037ba:	69a2                	ld	s3,8(sp)
    800037bc:	6a02                	ld	s4,0(sp)
    800037be:	6145                	addi	sp,sp,48
    800037c0:	8082                	ret
    panic("iget: no inodes");
    800037c2:	00005517          	auipc	a0,0x5
    800037c6:	dfe50513          	addi	a0,a0,-514 # 800085c0 <syscalls+0x130>
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	d74080e7          	jalr	-652(ra) # 8000053e <panic>

00000000800037d2 <fsinit>:
fsinit(int dev) {
    800037d2:	7179                	addi	sp,sp,-48
    800037d4:	f406                	sd	ra,40(sp)
    800037d6:	f022                	sd	s0,32(sp)
    800037d8:	ec26                	sd	s1,24(sp)
    800037da:	e84a                	sd	s2,16(sp)
    800037dc:	e44e                	sd	s3,8(sp)
    800037de:	1800                	addi	s0,sp,48
    800037e0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037e2:	4585                	li	a1,1
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	a64080e7          	jalr	-1436(ra) # 80003248 <bread>
    800037ec:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037ee:	0001d997          	auipc	s3,0x1d
    800037f2:	8fa98993          	addi	s3,s3,-1798 # 800200e8 <sb>
    800037f6:	02000613          	li	a2,32
    800037fa:	05850593          	addi	a1,a0,88
    800037fe:	854e                	mv	a0,s3
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	540080e7          	jalr	1344(ra) # 80000d40 <memmove>
  brelse(bp);
    80003808:	8526                	mv	a0,s1
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	b6e080e7          	jalr	-1170(ra) # 80003378 <brelse>
  if(sb.magic != FSMAGIC)
    80003812:	0009a703          	lw	a4,0(s3)
    80003816:	102037b7          	lui	a5,0x10203
    8000381a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000381e:	02f71263          	bne	a4,a5,80003842 <fsinit+0x70>
  initlog(dev, &sb);
    80003822:	0001d597          	auipc	a1,0x1d
    80003826:	8c658593          	addi	a1,a1,-1850 # 800200e8 <sb>
    8000382a:	854a                	mv	a0,s2
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	b4c080e7          	jalr	-1204(ra) # 80004378 <initlog>
}
    80003834:	70a2                	ld	ra,40(sp)
    80003836:	7402                	ld	s0,32(sp)
    80003838:	64e2                	ld	s1,24(sp)
    8000383a:	6942                	ld	s2,16(sp)
    8000383c:	69a2                	ld	s3,8(sp)
    8000383e:	6145                	addi	sp,sp,48
    80003840:	8082                	ret
    panic("invalid file system");
    80003842:	00005517          	auipc	a0,0x5
    80003846:	d8e50513          	addi	a0,a0,-626 # 800085d0 <syscalls+0x140>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	cf4080e7          	jalr	-780(ra) # 8000053e <panic>

0000000080003852 <iinit>:
{
    80003852:	7179                	addi	sp,sp,-48
    80003854:	f406                	sd	ra,40(sp)
    80003856:	f022                	sd	s0,32(sp)
    80003858:	ec26                	sd	s1,24(sp)
    8000385a:	e84a                	sd	s2,16(sp)
    8000385c:	e44e                	sd	s3,8(sp)
    8000385e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003860:	00005597          	auipc	a1,0x5
    80003864:	d8858593          	addi	a1,a1,-632 # 800085e8 <syscalls+0x158>
    80003868:	0001d517          	auipc	a0,0x1d
    8000386c:	8a050513          	addi	a0,a0,-1888 # 80020108 <itable>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	2e4080e7          	jalr	740(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003878:	0001d497          	auipc	s1,0x1d
    8000387c:	8b848493          	addi	s1,s1,-1864 # 80020130 <itable+0x28>
    80003880:	0001e997          	auipc	s3,0x1e
    80003884:	34098993          	addi	s3,s3,832 # 80021bc0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003888:	00005917          	auipc	s2,0x5
    8000388c:	d6890913          	addi	s2,s2,-664 # 800085f0 <syscalls+0x160>
    80003890:	85ca                	mv	a1,s2
    80003892:	8526                	mv	a0,s1
    80003894:	00001097          	auipc	ra,0x1
    80003898:	e46080e7          	jalr	-442(ra) # 800046da <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000389c:	08848493          	addi	s1,s1,136
    800038a0:	ff3498e3          	bne	s1,s3,80003890 <iinit+0x3e>
}
    800038a4:	70a2                	ld	ra,40(sp)
    800038a6:	7402                	ld	s0,32(sp)
    800038a8:	64e2                	ld	s1,24(sp)
    800038aa:	6942                	ld	s2,16(sp)
    800038ac:	69a2                	ld	s3,8(sp)
    800038ae:	6145                	addi	sp,sp,48
    800038b0:	8082                	ret

00000000800038b2 <ialloc>:
{
    800038b2:	715d                	addi	sp,sp,-80
    800038b4:	e486                	sd	ra,72(sp)
    800038b6:	e0a2                	sd	s0,64(sp)
    800038b8:	fc26                	sd	s1,56(sp)
    800038ba:	f84a                	sd	s2,48(sp)
    800038bc:	f44e                	sd	s3,40(sp)
    800038be:	f052                	sd	s4,32(sp)
    800038c0:	ec56                	sd	s5,24(sp)
    800038c2:	e85a                	sd	s6,16(sp)
    800038c4:	e45e                	sd	s7,8(sp)
    800038c6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800038c8:	0001d717          	auipc	a4,0x1d
    800038cc:	82c72703          	lw	a4,-2004(a4) # 800200f4 <sb+0xc>
    800038d0:	4785                	li	a5,1
    800038d2:	04e7fa63          	bgeu	a5,a4,80003926 <ialloc+0x74>
    800038d6:	8aaa                	mv	s5,a0
    800038d8:	8bae                	mv	s7,a1
    800038da:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038dc:	0001da17          	auipc	s4,0x1d
    800038e0:	80ca0a13          	addi	s4,s4,-2036 # 800200e8 <sb>
    800038e4:	00048b1b          	sext.w	s6,s1
    800038e8:	0044d593          	srli	a1,s1,0x4
    800038ec:	018a2783          	lw	a5,24(s4)
    800038f0:	9dbd                	addw	a1,a1,a5
    800038f2:	8556                	mv	a0,s5
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	954080e7          	jalr	-1708(ra) # 80003248 <bread>
    800038fc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038fe:	05850993          	addi	s3,a0,88
    80003902:	00f4f793          	andi	a5,s1,15
    80003906:	079a                	slli	a5,a5,0x6
    80003908:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000390a:	00099783          	lh	a5,0(s3)
    8000390e:	c785                	beqz	a5,80003936 <ialloc+0x84>
    brelse(bp);
    80003910:	00000097          	auipc	ra,0x0
    80003914:	a68080e7          	jalr	-1432(ra) # 80003378 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003918:	0485                	addi	s1,s1,1
    8000391a:	00ca2703          	lw	a4,12(s4)
    8000391e:	0004879b          	sext.w	a5,s1
    80003922:	fce7e1e3          	bltu	a5,a4,800038e4 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003926:	00005517          	auipc	a0,0x5
    8000392a:	cd250513          	addi	a0,a0,-814 # 800085f8 <syscalls+0x168>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	c10080e7          	jalr	-1008(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    80003936:	04000613          	li	a2,64
    8000393a:	4581                	li	a1,0
    8000393c:	854e                	mv	a0,s3
    8000393e:	ffffd097          	auipc	ra,0xffffd
    80003942:	3a2080e7          	jalr	930(ra) # 80000ce0 <memset>
      dip->type = type;
    80003946:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000394a:	854a                	mv	a0,s2
    8000394c:	00001097          	auipc	ra,0x1
    80003950:	ca8080e7          	jalr	-856(ra) # 800045f4 <log_write>
      brelse(bp);
    80003954:	854a                	mv	a0,s2
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	a22080e7          	jalr	-1502(ra) # 80003378 <brelse>
      return iget(dev, inum);
    8000395e:	85da                	mv	a1,s6
    80003960:	8556                	mv	a0,s5
    80003962:	00000097          	auipc	ra,0x0
    80003966:	db4080e7          	jalr	-588(ra) # 80003716 <iget>
}
    8000396a:	60a6                	ld	ra,72(sp)
    8000396c:	6406                	ld	s0,64(sp)
    8000396e:	74e2                	ld	s1,56(sp)
    80003970:	7942                	ld	s2,48(sp)
    80003972:	79a2                	ld	s3,40(sp)
    80003974:	7a02                	ld	s4,32(sp)
    80003976:	6ae2                	ld	s5,24(sp)
    80003978:	6b42                	ld	s6,16(sp)
    8000397a:	6ba2                	ld	s7,8(sp)
    8000397c:	6161                	addi	sp,sp,80
    8000397e:	8082                	ret

0000000080003980 <iupdate>:
{
    80003980:	1101                	addi	sp,sp,-32
    80003982:	ec06                	sd	ra,24(sp)
    80003984:	e822                	sd	s0,16(sp)
    80003986:	e426                	sd	s1,8(sp)
    80003988:	e04a                	sd	s2,0(sp)
    8000398a:	1000                	addi	s0,sp,32
    8000398c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000398e:	415c                	lw	a5,4(a0)
    80003990:	0047d79b          	srliw	a5,a5,0x4
    80003994:	0001c597          	auipc	a1,0x1c
    80003998:	76c5a583          	lw	a1,1900(a1) # 80020100 <sb+0x18>
    8000399c:	9dbd                	addw	a1,a1,a5
    8000399e:	4108                	lw	a0,0(a0)
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	8a8080e7          	jalr	-1880(ra) # 80003248 <bread>
    800039a8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039aa:	05850793          	addi	a5,a0,88
    800039ae:	40c8                	lw	a0,4(s1)
    800039b0:	893d                	andi	a0,a0,15
    800039b2:	051a                	slli	a0,a0,0x6
    800039b4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800039b6:	04449703          	lh	a4,68(s1)
    800039ba:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800039be:	04649703          	lh	a4,70(s1)
    800039c2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800039c6:	04849703          	lh	a4,72(s1)
    800039ca:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800039ce:	04a49703          	lh	a4,74(s1)
    800039d2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800039d6:	44f8                	lw	a4,76(s1)
    800039d8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039da:	03400613          	li	a2,52
    800039de:	05048593          	addi	a1,s1,80
    800039e2:	0531                	addi	a0,a0,12
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	35c080e7          	jalr	860(ra) # 80000d40 <memmove>
  log_write(bp);
    800039ec:	854a                	mv	a0,s2
    800039ee:	00001097          	auipc	ra,0x1
    800039f2:	c06080e7          	jalr	-1018(ra) # 800045f4 <log_write>
  brelse(bp);
    800039f6:	854a                	mv	a0,s2
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	980080e7          	jalr	-1664(ra) # 80003378 <brelse>
}
    80003a00:	60e2                	ld	ra,24(sp)
    80003a02:	6442                	ld	s0,16(sp)
    80003a04:	64a2                	ld	s1,8(sp)
    80003a06:	6902                	ld	s2,0(sp)
    80003a08:	6105                	addi	sp,sp,32
    80003a0a:	8082                	ret

0000000080003a0c <idup>:
{
    80003a0c:	1101                	addi	sp,sp,-32
    80003a0e:	ec06                	sd	ra,24(sp)
    80003a10:	e822                	sd	s0,16(sp)
    80003a12:	e426                	sd	s1,8(sp)
    80003a14:	1000                	addi	s0,sp,32
    80003a16:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a18:	0001c517          	auipc	a0,0x1c
    80003a1c:	6f050513          	addi	a0,a0,1776 # 80020108 <itable>
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	1c4080e7          	jalr	452(ra) # 80000be4 <acquire>
  ip->ref++;
    80003a28:	449c                	lw	a5,8(s1)
    80003a2a:	2785                	addiw	a5,a5,1
    80003a2c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a2e:	0001c517          	auipc	a0,0x1c
    80003a32:	6da50513          	addi	a0,a0,1754 # 80020108 <itable>
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	262080e7          	jalr	610(ra) # 80000c98 <release>
}
    80003a3e:	8526                	mv	a0,s1
    80003a40:	60e2                	ld	ra,24(sp)
    80003a42:	6442                	ld	s0,16(sp)
    80003a44:	64a2                	ld	s1,8(sp)
    80003a46:	6105                	addi	sp,sp,32
    80003a48:	8082                	ret

0000000080003a4a <ilock>:
{
    80003a4a:	1101                	addi	sp,sp,-32
    80003a4c:	ec06                	sd	ra,24(sp)
    80003a4e:	e822                	sd	s0,16(sp)
    80003a50:	e426                	sd	s1,8(sp)
    80003a52:	e04a                	sd	s2,0(sp)
    80003a54:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a56:	c115                	beqz	a0,80003a7a <ilock+0x30>
    80003a58:	84aa                	mv	s1,a0
    80003a5a:	451c                	lw	a5,8(a0)
    80003a5c:	00f05f63          	blez	a5,80003a7a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a60:	0541                	addi	a0,a0,16
    80003a62:	00001097          	auipc	ra,0x1
    80003a66:	cb2080e7          	jalr	-846(ra) # 80004714 <acquiresleep>
  if(ip->valid == 0){
    80003a6a:	40bc                	lw	a5,64(s1)
    80003a6c:	cf99                	beqz	a5,80003a8a <ilock+0x40>
}
    80003a6e:	60e2                	ld	ra,24(sp)
    80003a70:	6442                	ld	s0,16(sp)
    80003a72:	64a2                	ld	s1,8(sp)
    80003a74:	6902                	ld	s2,0(sp)
    80003a76:	6105                	addi	sp,sp,32
    80003a78:	8082                	ret
    panic("ilock");
    80003a7a:	00005517          	auipc	a0,0x5
    80003a7e:	b9650513          	addi	a0,a0,-1130 # 80008610 <syscalls+0x180>
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	abc080e7          	jalr	-1348(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a8a:	40dc                	lw	a5,4(s1)
    80003a8c:	0047d79b          	srliw	a5,a5,0x4
    80003a90:	0001c597          	auipc	a1,0x1c
    80003a94:	6705a583          	lw	a1,1648(a1) # 80020100 <sb+0x18>
    80003a98:	9dbd                	addw	a1,a1,a5
    80003a9a:	4088                	lw	a0,0(s1)
    80003a9c:	fffff097          	auipc	ra,0xfffff
    80003aa0:	7ac080e7          	jalr	1964(ra) # 80003248 <bread>
    80003aa4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003aa6:	05850593          	addi	a1,a0,88
    80003aaa:	40dc                	lw	a5,4(s1)
    80003aac:	8bbd                	andi	a5,a5,15
    80003aae:	079a                	slli	a5,a5,0x6
    80003ab0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ab2:	00059783          	lh	a5,0(a1)
    80003ab6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003aba:	00259783          	lh	a5,2(a1)
    80003abe:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ac2:	00459783          	lh	a5,4(a1)
    80003ac6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003aca:	00659783          	lh	a5,6(a1)
    80003ace:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003ad2:	459c                	lw	a5,8(a1)
    80003ad4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ad6:	03400613          	li	a2,52
    80003ada:	05b1                	addi	a1,a1,12
    80003adc:	05048513          	addi	a0,s1,80
    80003ae0:	ffffd097          	auipc	ra,0xffffd
    80003ae4:	260080e7          	jalr	608(ra) # 80000d40 <memmove>
    brelse(bp);
    80003ae8:	854a                	mv	a0,s2
    80003aea:	00000097          	auipc	ra,0x0
    80003aee:	88e080e7          	jalr	-1906(ra) # 80003378 <brelse>
    ip->valid = 1;
    80003af2:	4785                	li	a5,1
    80003af4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003af6:	04449783          	lh	a5,68(s1)
    80003afa:	fbb5                	bnez	a5,80003a6e <ilock+0x24>
      panic("ilock: no type");
    80003afc:	00005517          	auipc	a0,0x5
    80003b00:	b1c50513          	addi	a0,a0,-1252 # 80008618 <syscalls+0x188>
    80003b04:	ffffd097          	auipc	ra,0xffffd
    80003b08:	a3a080e7          	jalr	-1478(ra) # 8000053e <panic>

0000000080003b0c <iunlock>:
{
    80003b0c:	1101                	addi	sp,sp,-32
    80003b0e:	ec06                	sd	ra,24(sp)
    80003b10:	e822                	sd	s0,16(sp)
    80003b12:	e426                	sd	s1,8(sp)
    80003b14:	e04a                	sd	s2,0(sp)
    80003b16:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b18:	c905                	beqz	a0,80003b48 <iunlock+0x3c>
    80003b1a:	84aa                	mv	s1,a0
    80003b1c:	01050913          	addi	s2,a0,16
    80003b20:	854a                	mv	a0,s2
    80003b22:	00001097          	auipc	ra,0x1
    80003b26:	c8c080e7          	jalr	-884(ra) # 800047ae <holdingsleep>
    80003b2a:	cd19                	beqz	a0,80003b48 <iunlock+0x3c>
    80003b2c:	449c                	lw	a5,8(s1)
    80003b2e:	00f05d63          	blez	a5,80003b48 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b32:	854a                	mv	a0,s2
    80003b34:	00001097          	auipc	ra,0x1
    80003b38:	c36080e7          	jalr	-970(ra) # 8000476a <releasesleep>
}
    80003b3c:	60e2                	ld	ra,24(sp)
    80003b3e:	6442                	ld	s0,16(sp)
    80003b40:	64a2                	ld	s1,8(sp)
    80003b42:	6902                	ld	s2,0(sp)
    80003b44:	6105                	addi	sp,sp,32
    80003b46:	8082                	ret
    panic("iunlock");
    80003b48:	00005517          	auipc	a0,0x5
    80003b4c:	ae050513          	addi	a0,a0,-1312 # 80008628 <syscalls+0x198>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	9ee080e7          	jalr	-1554(ra) # 8000053e <panic>

0000000080003b58 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b58:	7179                	addi	sp,sp,-48
    80003b5a:	f406                	sd	ra,40(sp)
    80003b5c:	f022                	sd	s0,32(sp)
    80003b5e:	ec26                	sd	s1,24(sp)
    80003b60:	e84a                	sd	s2,16(sp)
    80003b62:	e44e                	sd	s3,8(sp)
    80003b64:	e052                	sd	s4,0(sp)
    80003b66:	1800                	addi	s0,sp,48
    80003b68:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b6a:	05050493          	addi	s1,a0,80
    80003b6e:	08050913          	addi	s2,a0,128
    80003b72:	a021                	j	80003b7a <itrunc+0x22>
    80003b74:	0491                	addi	s1,s1,4
    80003b76:	01248d63          	beq	s1,s2,80003b90 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b7a:	408c                	lw	a1,0(s1)
    80003b7c:	dde5                	beqz	a1,80003b74 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b7e:	0009a503          	lw	a0,0(s3)
    80003b82:	00000097          	auipc	ra,0x0
    80003b86:	90c080e7          	jalr	-1780(ra) # 8000348e <bfree>
      ip->addrs[i] = 0;
    80003b8a:	0004a023          	sw	zero,0(s1)
    80003b8e:	b7dd                	j	80003b74 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b90:	0809a583          	lw	a1,128(s3)
    80003b94:	e185                	bnez	a1,80003bb4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b96:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b9a:	854e                	mv	a0,s3
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	de4080e7          	jalr	-540(ra) # 80003980 <iupdate>
}
    80003ba4:	70a2                	ld	ra,40(sp)
    80003ba6:	7402                	ld	s0,32(sp)
    80003ba8:	64e2                	ld	s1,24(sp)
    80003baa:	6942                	ld	s2,16(sp)
    80003bac:	69a2                	ld	s3,8(sp)
    80003bae:	6a02                	ld	s4,0(sp)
    80003bb0:	6145                	addi	sp,sp,48
    80003bb2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003bb4:	0009a503          	lw	a0,0(s3)
    80003bb8:	fffff097          	auipc	ra,0xfffff
    80003bbc:	690080e7          	jalr	1680(ra) # 80003248 <bread>
    80003bc0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003bc2:	05850493          	addi	s1,a0,88
    80003bc6:	45850913          	addi	s2,a0,1112
    80003bca:	a811                	j	80003bde <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003bcc:	0009a503          	lw	a0,0(s3)
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	8be080e7          	jalr	-1858(ra) # 8000348e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003bd8:	0491                	addi	s1,s1,4
    80003bda:	01248563          	beq	s1,s2,80003be4 <itrunc+0x8c>
      if(a[j])
    80003bde:	408c                	lw	a1,0(s1)
    80003be0:	dde5                	beqz	a1,80003bd8 <itrunc+0x80>
    80003be2:	b7ed                	j	80003bcc <itrunc+0x74>
    brelse(bp);
    80003be4:	8552                	mv	a0,s4
    80003be6:	fffff097          	auipc	ra,0xfffff
    80003bea:	792080e7          	jalr	1938(ra) # 80003378 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003bee:	0809a583          	lw	a1,128(s3)
    80003bf2:	0009a503          	lw	a0,0(s3)
    80003bf6:	00000097          	auipc	ra,0x0
    80003bfa:	898080e7          	jalr	-1896(ra) # 8000348e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bfe:	0809a023          	sw	zero,128(s3)
    80003c02:	bf51                	j	80003b96 <itrunc+0x3e>

0000000080003c04 <iput>:
{
    80003c04:	1101                	addi	sp,sp,-32
    80003c06:	ec06                	sd	ra,24(sp)
    80003c08:	e822                	sd	s0,16(sp)
    80003c0a:	e426                	sd	s1,8(sp)
    80003c0c:	e04a                	sd	s2,0(sp)
    80003c0e:	1000                	addi	s0,sp,32
    80003c10:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c12:	0001c517          	auipc	a0,0x1c
    80003c16:	4f650513          	addi	a0,a0,1270 # 80020108 <itable>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	fca080e7          	jalr	-54(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c22:	4498                	lw	a4,8(s1)
    80003c24:	4785                	li	a5,1
    80003c26:	02f70363          	beq	a4,a5,80003c4c <iput+0x48>
  ip->ref--;
    80003c2a:	449c                	lw	a5,8(s1)
    80003c2c:	37fd                	addiw	a5,a5,-1
    80003c2e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c30:	0001c517          	auipc	a0,0x1c
    80003c34:	4d850513          	addi	a0,a0,1240 # 80020108 <itable>
    80003c38:	ffffd097          	auipc	ra,0xffffd
    80003c3c:	060080e7          	jalr	96(ra) # 80000c98 <release>
}
    80003c40:	60e2                	ld	ra,24(sp)
    80003c42:	6442                	ld	s0,16(sp)
    80003c44:	64a2                	ld	s1,8(sp)
    80003c46:	6902                	ld	s2,0(sp)
    80003c48:	6105                	addi	sp,sp,32
    80003c4a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c4c:	40bc                	lw	a5,64(s1)
    80003c4e:	dff1                	beqz	a5,80003c2a <iput+0x26>
    80003c50:	04a49783          	lh	a5,74(s1)
    80003c54:	fbf9                	bnez	a5,80003c2a <iput+0x26>
    acquiresleep(&ip->lock);
    80003c56:	01048913          	addi	s2,s1,16
    80003c5a:	854a                	mv	a0,s2
    80003c5c:	00001097          	auipc	ra,0x1
    80003c60:	ab8080e7          	jalr	-1352(ra) # 80004714 <acquiresleep>
    release(&itable.lock);
    80003c64:	0001c517          	auipc	a0,0x1c
    80003c68:	4a450513          	addi	a0,a0,1188 # 80020108 <itable>
    80003c6c:	ffffd097          	auipc	ra,0xffffd
    80003c70:	02c080e7          	jalr	44(ra) # 80000c98 <release>
    itrunc(ip);
    80003c74:	8526                	mv	a0,s1
    80003c76:	00000097          	auipc	ra,0x0
    80003c7a:	ee2080e7          	jalr	-286(ra) # 80003b58 <itrunc>
    ip->type = 0;
    80003c7e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c82:	8526                	mv	a0,s1
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	cfc080e7          	jalr	-772(ra) # 80003980 <iupdate>
    ip->valid = 0;
    80003c8c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c90:	854a                	mv	a0,s2
    80003c92:	00001097          	auipc	ra,0x1
    80003c96:	ad8080e7          	jalr	-1320(ra) # 8000476a <releasesleep>
    acquire(&itable.lock);
    80003c9a:	0001c517          	auipc	a0,0x1c
    80003c9e:	46e50513          	addi	a0,a0,1134 # 80020108 <itable>
    80003ca2:	ffffd097          	auipc	ra,0xffffd
    80003ca6:	f42080e7          	jalr	-190(ra) # 80000be4 <acquire>
    80003caa:	b741                	j	80003c2a <iput+0x26>

0000000080003cac <iunlockput>:
{
    80003cac:	1101                	addi	sp,sp,-32
    80003cae:	ec06                	sd	ra,24(sp)
    80003cb0:	e822                	sd	s0,16(sp)
    80003cb2:	e426                	sd	s1,8(sp)
    80003cb4:	1000                	addi	s0,sp,32
    80003cb6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	e54080e7          	jalr	-428(ra) # 80003b0c <iunlock>
  iput(ip);
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	f42080e7          	jalr	-190(ra) # 80003c04 <iput>
}
    80003cca:	60e2                	ld	ra,24(sp)
    80003ccc:	6442                	ld	s0,16(sp)
    80003cce:	64a2                	ld	s1,8(sp)
    80003cd0:	6105                	addi	sp,sp,32
    80003cd2:	8082                	ret

0000000080003cd4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003cd4:	1141                	addi	sp,sp,-16
    80003cd6:	e422                	sd	s0,8(sp)
    80003cd8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003cda:	411c                	lw	a5,0(a0)
    80003cdc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003cde:	415c                	lw	a5,4(a0)
    80003ce0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ce2:	04451783          	lh	a5,68(a0)
    80003ce6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003cea:	04a51783          	lh	a5,74(a0)
    80003cee:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003cf2:	04c56783          	lwu	a5,76(a0)
    80003cf6:	e99c                	sd	a5,16(a1)
}
    80003cf8:	6422                	ld	s0,8(sp)
    80003cfa:	0141                	addi	sp,sp,16
    80003cfc:	8082                	ret

0000000080003cfe <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cfe:	457c                	lw	a5,76(a0)
    80003d00:	0ed7e963          	bltu	a5,a3,80003df2 <readi+0xf4>
{
    80003d04:	7159                	addi	sp,sp,-112
    80003d06:	f486                	sd	ra,104(sp)
    80003d08:	f0a2                	sd	s0,96(sp)
    80003d0a:	eca6                	sd	s1,88(sp)
    80003d0c:	e8ca                	sd	s2,80(sp)
    80003d0e:	e4ce                	sd	s3,72(sp)
    80003d10:	e0d2                	sd	s4,64(sp)
    80003d12:	fc56                	sd	s5,56(sp)
    80003d14:	f85a                	sd	s6,48(sp)
    80003d16:	f45e                	sd	s7,40(sp)
    80003d18:	f062                	sd	s8,32(sp)
    80003d1a:	ec66                	sd	s9,24(sp)
    80003d1c:	e86a                	sd	s10,16(sp)
    80003d1e:	e46e                	sd	s11,8(sp)
    80003d20:	1880                	addi	s0,sp,112
    80003d22:	8baa                	mv	s7,a0
    80003d24:	8c2e                	mv	s8,a1
    80003d26:	8ab2                	mv	s5,a2
    80003d28:	84b6                	mv	s1,a3
    80003d2a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d2c:	9f35                	addw	a4,a4,a3
    return 0;
    80003d2e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d30:	0ad76063          	bltu	a4,a3,80003dd0 <readi+0xd2>
  if(off + n > ip->size)
    80003d34:	00e7f463          	bgeu	a5,a4,80003d3c <readi+0x3e>
    n = ip->size - off;
    80003d38:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d3c:	0a0b0963          	beqz	s6,80003dee <readi+0xf0>
    80003d40:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d42:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d46:	5cfd                	li	s9,-1
    80003d48:	a82d                	j	80003d82 <readi+0x84>
    80003d4a:	020a1d93          	slli	s11,s4,0x20
    80003d4e:	020ddd93          	srli	s11,s11,0x20
    80003d52:	05890613          	addi	a2,s2,88
    80003d56:	86ee                	mv	a3,s11
    80003d58:	963a                	add	a2,a2,a4
    80003d5a:	85d6                	mv	a1,s5
    80003d5c:	8562                	mv	a0,s8
    80003d5e:	fffff097          	auipc	ra,0xfffff
    80003d62:	b2e080e7          	jalr	-1234(ra) # 8000288c <either_copyout>
    80003d66:	05950d63          	beq	a0,s9,80003dc0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	60c080e7          	jalr	1548(ra) # 80003378 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d74:	013a09bb          	addw	s3,s4,s3
    80003d78:	009a04bb          	addw	s1,s4,s1
    80003d7c:	9aee                	add	s5,s5,s11
    80003d7e:	0569f763          	bgeu	s3,s6,80003dcc <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d82:	000ba903          	lw	s2,0(s7)
    80003d86:	00a4d59b          	srliw	a1,s1,0xa
    80003d8a:	855e                	mv	a0,s7
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	8b0080e7          	jalr	-1872(ra) # 8000363c <bmap>
    80003d94:	0005059b          	sext.w	a1,a0
    80003d98:	854a                	mv	a0,s2
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	4ae080e7          	jalr	1198(ra) # 80003248 <bread>
    80003da2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da4:	3ff4f713          	andi	a4,s1,1023
    80003da8:	40ed07bb          	subw	a5,s10,a4
    80003dac:	413b06bb          	subw	a3,s6,s3
    80003db0:	8a3e                	mv	s4,a5
    80003db2:	2781                	sext.w	a5,a5
    80003db4:	0006861b          	sext.w	a2,a3
    80003db8:	f8f679e3          	bgeu	a2,a5,80003d4a <readi+0x4c>
    80003dbc:	8a36                	mv	s4,a3
    80003dbe:	b771                	j	80003d4a <readi+0x4c>
      brelse(bp);
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	fffff097          	auipc	ra,0xfffff
    80003dc6:	5b6080e7          	jalr	1462(ra) # 80003378 <brelse>
      tot = -1;
    80003dca:	59fd                	li	s3,-1
  }
  return tot;
    80003dcc:	0009851b          	sext.w	a0,s3
}
    80003dd0:	70a6                	ld	ra,104(sp)
    80003dd2:	7406                	ld	s0,96(sp)
    80003dd4:	64e6                	ld	s1,88(sp)
    80003dd6:	6946                	ld	s2,80(sp)
    80003dd8:	69a6                	ld	s3,72(sp)
    80003dda:	6a06                	ld	s4,64(sp)
    80003ddc:	7ae2                	ld	s5,56(sp)
    80003dde:	7b42                	ld	s6,48(sp)
    80003de0:	7ba2                	ld	s7,40(sp)
    80003de2:	7c02                	ld	s8,32(sp)
    80003de4:	6ce2                	ld	s9,24(sp)
    80003de6:	6d42                	ld	s10,16(sp)
    80003de8:	6da2                	ld	s11,8(sp)
    80003dea:	6165                	addi	sp,sp,112
    80003dec:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dee:	89da                	mv	s3,s6
    80003df0:	bff1                	j	80003dcc <readi+0xce>
    return 0;
    80003df2:	4501                	li	a0,0
}
    80003df4:	8082                	ret

0000000080003df6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003df6:	457c                	lw	a5,76(a0)
    80003df8:	10d7e863          	bltu	a5,a3,80003f08 <writei+0x112>
{
    80003dfc:	7159                	addi	sp,sp,-112
    80003dfe:	f486                	sd	ra,104(sp)
    80003e00:	f0a2                	sd	s0,96(sp)
    80003e02:	eca6                	sd	s1,88(sp)
    80003e04:	e8ca                	sd	s2,80(sp)
    80003e06:	e4ce                	sd	s3,72(sp)
    80003e08:	e0d2                	sd	s4,64(sp)
    80003e0a:	fc56                	sd	s5,56(sp)
    80003e0c:	f85a                	sd	s6,48(sp)
    80003e0e:	f45e                	sd	s7,40(sp)
    80003e10:	f062                	sd	s8,32(sp)
    80003e12:	ec66                	sd	s9,24(sp)
    80003e14:	e86a                	sd	s10,16(sp)
    80003e16:	e46e                	sd	s11,8(sp)
    80003e18:	1880                	addi	s0,sp,112
    80003e1a:	8b2a                	mv	s6,a0
    80003e1c:	8c2e                	mv	s8,a1
    80003e1e:	8ab2                	mv	s5,a2
    80003e20:	8936                	mv	s2,a3
    80003e22:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003e24:	00e687bb          	addw	a5,a3,a4
    80003e28:	0ed7e263          	bltu	a5,a3,80003f0c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e2c:	00043737          	lui	a4,0x43
    80003e30:	0ef76063          	bltu	a4,a5,80003f10 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e34:	0c0b8863          	beqz	s7,80003f04 <writei+0x10e>
    80003e38:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e3a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e3e:	5cfd                	li	s9,-1
    80003e40:	a091                	j	80003e84 <writei+0x8e>
    80003e42:	02099d93          	slli	s11,s3,0x20
    80003e46:	020ddd93          	srli	s11,s11,0x20
    80003e4a:	05848513          	addi	a0,s1,88
    80003e4e:	86ee                	mv	a3,s11
    80003e50:	8656                	mv	a2,s5
    80003e52:	85e2                	mv	a1,s8
    80003e54:	953a                	add	a0,a0,a4
    80003e56:	fffff097          	auipc	ra,0xfffff
    80003e5a:	a8c080e7          	jalr	-1396(ra) # 800028e2 <either_copyin>
    80003e5e:	07950263          	beq	a0,s9,80003ec2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e62:	8526                	mv	a0,s1
    80003e64:	00000097          	auipc	ra,0x0
    80003e68:	790080e7          	jalr	1936(ra) # 800045f4 <log_write>
    brelse(bp);
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	fffff097          	auipc	ra,0xfffff
    80003e72:	50a080e7          	jalr	1290(ra) # 80003378 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e76:	01498a3b          	addw	s4,s3,s4
    80003e7a:	0129893b          	addw	s2,s3,s2
    80003e7e:	9aee                	add	s5,s5,s11
    80003e80:	057a7663          	bgeu	s4,s7,80003ecc <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e84:	000b2483          	lw	s1,0(s6)
    80003e88:	00a9559b          	srliw	a1,s2,0xa
    80003e8c:	855a                	mv	a0,s6
    80003e8e:	fffff097          	auipc	ra,0xfffff
    80003e92:	7ae080e7          	jalr	1966(ra) # 8000363c <bmap>
    80003e96:	0005059b          	sext.w	a1,a0
    80003e9a:	8526                	mv	a0,s1
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	3ac080e7          	jalr	940(ra) # 80003248 <bread>
    80003ea4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ea6:	3ff97713          	andi	a4,s2,1023
    80003eaa:	40ed07bb          	subw	a5,s10,a4
    80003eae:	414b86bb          	subw	a3,s7,s4
    80003eb2:	89be                	mv	s3,a5
    80003eb4:	2781                	sext.w	a5,a5
    80003eb6:	0006861b          	sext.w	a2,a3
    80003eba:	f8f674e3          	bgeu	a2,a5,80003e42 <writei+0x4c>
    80003ebe:	89b6                	mv	s3,a3
    80003ec0:	b749                	j	80003e42 <writei+0x4c>
      brelse(bp);
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	4b4080e7          	jalr	1204(ra) # 80003378 <brelse>
  }

  if(off > ip->size)
    80003ecc:	04cb2783          	lw	a5,76(s6)
    80003ed0:	0127f463          	bgeu	a5,s2,80003ed8 <writei+0xe2>
    ip->size = off;
    80003ed4:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ed8:	855a                	mv	a0,s6
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	aa6080e7          	jalr	-1370(ra) # 80003980 <iupdate>

  return tot;
    80003ee2:	000a051b          	sext.w	a0,s4
}
    80003ee6:	70a6                	ld	ra,104(sp)
    80003ee8:	7406                	ld	s0,96(sp)
    80003eea:	64e6                	ld	s1,88(sp)
    80003eec:	6946                	ld	s2,80(sp)
    80003eee:	69a6                	ld	s3,72(sp)
    80003ef0:	6a06                	ld	s4,64(sp)
    80003ef2:	7ae2                	ld	s5,56(sp)
    80003ef4:	7b42                	ld	s6,48(sp)
    80003ef6:	7ba2                	ld	s7,40(sp)
    80003ef8:	7c02                	ld	s8,32(sp)
    80003efa:	6ce2                	ld	s9,24(sp)
    80003efc:	6d42                	ld	s10,16(sp)
    80003efe:	6da2                	ld	s11,8(sp)
    80003f00:	6165                	addi	sp,sp,112
    80003f02:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f04:	8a5e                	mv	s4,s7
    80003f06:	bfc9                	j	80003ed8 <writei+0xe2>
    return -1;
    80003f08:	557d                	li	a0,-1
}
    80003f0a:	8082                	ret
    return -1;
    80003f0c:	557d                	li	a0,-1
    80003f0e:	bfe1                	j	80003ee6 <writei+0xf0>
    return -1;
    80003f10:	557d                	li	a0,-1
    80003f12:	bfd1                	j	80003ee6 <writei+0xf0>

0000000080003f14 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f14:	1141                	addi	sp,sp,-16
    80003f16:	e406                	sd	ra,8(sp)
    80003f18:	e022                	sd	s0,0(sp)
    80003f1a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f1c:	4639                	li	a2,14
    80003f1e:	ffffd097          	auipc	ra,0xffffd
    80003f22:	e9a080e7          	jalr	-358(ra) # 80000db8 <strncmp>
}
    80003f26:	60a2                	ld	ra,8(sp)
    80003f28:	6402                	ld	s0,0(sp)
    80003f2a:	0141                	addi	sp,sp,16
    80003f2c:	8082                	ret

0000000080003f2e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f2e:	7139                	addi	sp,sp,-64
    80003f30:	fc06                	sd	ra,56(sp)
    80003f32:	f822                	sd	s0,48(sp)
    80003f34:	f426                	sd	s1,40(sp)
    80003f36:	f04a                	sd	s2,32(sp)
    80003f38:	ec4e                	sd	s3,24(sp)
    80003f3a:	e852                	sd	s4,16(sp)
    80003f3c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f3e:	04451703          	lh	a4,68(a0)
    80003f42:	4785                	li	a5,1
    80003f44:	00f71a63          	bne	a4,a5,80003f58 <dirlookup+0x2a>
    80003f48:	892a                	mv	s2,a0
    80003f4a:	89ae                	mv	s3,a1
    80003f4c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f4e:	457c                	lw	a5,76(a0)
    80003f50:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f52:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f54:	e79d                	bnez	a5,80003f82 <dirlookup+0x54>
    80003f56:	a8a5                	j	80003fce <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f58:	00004517          	auipc	a0,0x4
    80003f5c:	6d850513          	addi	a0,a0,1752 # 80008630 <syscalls+0x1a0>
    80003f60:	ffffc097          	auipc	ra,0xffffc
    80003f64:	5de080e7          	jalr	1502(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003f68:	00004517          	auipc	a0,0x4
    80003f6c:	6e050513          	addi	a0,a0,1760 # 80008648 <syscalls+0x1b8>
    80003f70:	ffffc097          	auipc	ra,0xffffc
    80003f74:	5ce080e7          	jalr	1486(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f78:	24c1                	addiw	s1,s1,16
    80003f7a:	04c92783          	lw	a5,76(s2)
    80003f7e:	04f4f763          	bgeu	s1,a5,80003fcc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f82:	4741                	li	a4,16
    80003f84:	86a6                	mv	a3,s1
    80003f86:	fc040613          	addi	a2,s0,-64
    80003f8a:	4581                	li	a1,0
    80003f8c:	854a                	mv	a0,s2
    80003f8e:	00000097          	auipc	ra,0x0
    80003f92:	d70080e7          	jalr	-656(ra) # 80003cfe <readi>
    80003f96:	47c1                	li	a5,16
    80003f98:	fcf518e3          	bne	a0,a5,80003f68 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f9c:	fc045783          	lhu	a5,-64(s0)
    80003fa0:	dfe1                	beqz	a5,80003f78 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003fa2:	fc240593          	addi	a1,s0,-62
    80003fa6:	854e                	mv	a0,s3
    80003fa8:	00000097          	auipc	ra,0x0
    80003fac:	f6c080e7          	jalr	-148(ra) # 80003f14 <namecmp>
    80003fb0:	f561                	bnez	a0,80003f78 <dirlookup+0x4a>
      if(poff)
    80003fb2:	000a0463          	beqz	s4,80003fba <dirlookup+0x8c>
        *poff = off;
    80003fb6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003fba:	fc045583          	lhu	a1,-64(s0)
    80003fbe:	00092503          	lw	a0,0(s2)
    80003fc2:	fffff097          	auipc	ra,0xfffff
    80003fc6:	754080e7          	jalr	1876(ra) # 80003716 <iget>
    80003fca:	a011                	j	80003fce <dirlookup+0xa0>
  return 0;
    80003fcc:	4501                	li	a0,0
}
    80003fce:	70e2                	ld	ra,56(sp)
    80003fd0:	7442                	ld	s0,48(sp)
    80003fd2:	74a2                	ld	s1,40(sp)
    80003fd4:	7902                	ld	s2,32(sp)
    80003fd6:	69e2                	ld	s3,24(sp)
    80003fd8:	6a42                	ld	s4,16(sp)
    80003fda:	6121                	addi	sp,sp,64
    80003fdc:	8082                	ret

0000000080003fde <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fde:	711d                	addi	sp,sp,-96
    80003fe0:	ec86                	sd	ra,88(sp)
    80003fe2:	e8a2                	sd	s0,80(sp)
    80003fe4:	e4a6                	sd	s1,72(sp)
    80003fe6:	e0ca                	sd	s2,64(sp)
    80003fe8:	fc4e                	sd	s3,56(sp)
    80003fea:	f852                	sd	s4,48(sp)
    80003fec:	f456                	sd	s5,40(sp)
    80003fee:	f05a                	sd	s6,32(sp)
    80003ff0:	ec5e                	sd	s7,24(sp)
    80003ff2:	e862                	sd	s8,16(sp)
    80003ff4:	e466                	sd	s9,8(sp)
    80003ff6:	1080                	addi	s0,sp,96
    80003ff8:	84aa                	mv	s1,a0
    80003ffa:	8b2e                	mv	s6,a1
    80003ffc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ffe:	00054703          	lbu	a4,0(a0)
    80004002:	02f00793          	li	a5,47
    80004006:	02f70363          	beq	a4,a5,8000402c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000400a:	ffffe097          	auipc	ra,0xffffe
    8000400e:	d5a080e7          	jalr	-678(ra) # 80001d64 <myproc>
    80004012:	17053503          	ld	a0,368(a0)
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	9f6080e7          	jalr	-1546(ra) # 80003a0c <idup>
    8000401e:	89aa                	mv	s3,a0
  while(*path == '/')
    80004020:	02f00913          	li	s2,47
  len = path - s;
    80004024:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004026:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004028:	4c05                	li	s8,1
    8000402a:	a865                	j	800040e2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000402c:	4585                	li	a1,1
    8000402e:	4505                	li	a0,1
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	6e6080e7          	jalr	1766(ra) # 80003716 <iget>
    80004038:	89aa                	mv	s3,a0
    8000403a:	b7dd                	j	80004020 <namex+0x42>
      iunlockput(ip);
    8000403c:	854e                	mv	a0,s3
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	c6e080e7          	jalr	-914(ra) # 80003cac <iunlockput>
      return 0;
    80004046:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004048:	854e                	mv	a0,s3
    8000404a:	60e6                	ld	ra,88(sp)
    8000404c:	6446                	ld	s0,80(sp)
    8000404e:	64a6                	ld	s1,72(sp)
    80004050:	6906                	ld	s2,64(sp)
    80004052:	79e2                	ld	s3,56(sp)
    80004054:	7a42                	ld	s4,48(sp)
    80004056:	7aa2                	ld	s5,40(sp)
    80004058:	7b02                	ld	s6,32(sp)
    8000405a:	6be2                	ld	s7,24(sp)
    8000405c:	6c42                	ld	s8,16(sp)
    8000405e:	6ca2                	ld	s9,8(sp)
    80004060:	6125                	addi	sp,sp,96
    80004062:	8082                	ret
      iunlock(ip);
    80004064:	854e                	mv	a0,s3
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	aa6080e7          	jalr	-1370(ra) # 80003b0c <iunlock>
      return ip;
    8000406e:	bfe9                	j	80004048 <namex+0x6a>
      iunlockput(ip);
    80004070:	854e                	mv	a0,s3
    80004072:	00000097          	auipc	ra,0x0
    80004076:	c3a080e7          	jalr	-966(ra) # 80003cac <iunlockput>
      return 0;
    8000407a:	89d2                	mv	s3,s4
    8000407c:	b7f1                	j	80004048 <namex+0x6a>
  len = path - s;
    8000407e:	40b48633          	sub	a2,s1,a1
    80004082:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004086:	094cd463          	bge	s9,s4,8000410e <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000408a:	4639                	li	a2,14
    8000408c:	8556                	mv	a0,s5
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	cb2080e7          	jalr	-846(ra) # 80000d40 <memmove>
  while(*path == '/')
    80004096:	0004c783          	lbu	a5,0(s1)
    8000409a:	01279763          	bne	a5,s2,800040a8 <namex+0xca>
    path++;
    8000409e:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040a0:	0004c783          	lbu	a5,0(s1)
    800040a4:	ff278de3          	beq	a5,s2,8000409e <namex+0xc0>
    ilock(ip);
    800040a8:	854e                	mv	a0,s3
    800040aa:	00000097          	auipc	ra,0x0
    800040ae:	9a0080e7          	jalr	-1632(ra) # 80003a4a <ilock>
    if(ip->type != T_DIR){
    800040b2:	04499783          	lh	a5,68(s3)
    800040b6:	f98793e3          	bne	a5,s8,8000403c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800040ba:	000b0563          	beqz	s6,800040c4 <namex+0xe6>
    800040be:	0004c783          	lbu	a5,0(s1)
    800040c2:	d3cd                	beqz	a5,80004064 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040c4:	865e                	mv	a2,s7
    800040c6:	85d6                	mv	a1,s5
    800040c8:	854e                	mv	a0,s3
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	e64080e7          	jalr	-412(ra) # 80003f2e <dirlookup>
    800040d2:	8a2a                	mv	s4,a0
    800040d4:	dd51                	beqz	a0,80004070 <namex+0x92>
    iunlockput(ip);
    800040d6:	854e                	mv	a0,s3
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	bd4080e7          	jalr	-1068(ra) # 80003cac <iunlockput>
    ip = next;
    800040e0:	89d2                	mv	s3,s4
  while(*path == '/')
    800040e2:	0004c783          	lbu	a5,0(s1)
    800040e6:	05279763          	bne	a5,s2,80004134 <namex+0x156>
    path++;
    800040ea:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040ec:	0004c783          	lbu	a5,0(s1)
    800040f0:	ff278de3          	beq	a5,s2,800040ea <namex+0x10c>
  if(*path == 0)
    800040f4:	c79d                	beqz	a5,80004122 <namex+0x144>
    path++;
    800040f6:	85a6                	mv	a1,s1
  len = path - s;
    800040f8:	8a5e                	mv	s4,s7
    800040fa:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800040fc:	01278963          	beq	a5,s2,8000410e <namex+0x130>
    80004100:	dfbd                	beqz	a5,8000407e <namex+0xa0>
    path++;
    80004102:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004104:	0004c783          	lbu	a5,0(s1)
    80004108:	ff279ce3          	bne	a5,s2,80004100 <namex+0x122>
    8000410c:	bf8d                	j	8000407e <namex+0xa0>
    memmove(name, s, len);
    8000410e:	2601                	sext.w	a2,a2
    80004110:	8556                	mv	a0,s5
    80004112:	ffffd097          	auipc	ra,0xffffd
    80004116:	c2e080e7          	jalr	-978(ra) # 80000d40 <memmove>
    name[len] = 0;
    8000411a:	9a56                	add	s4,s4,s5
    8000411c:	000a0023          	sb	zero,0(s4)
    80004120:	bf9d                	j	80004096 <namex+0xb8>
  if(nameiparent){
    80004122:	f20b03e3          	beqz	s6,80004048 <namex+0x6a>
    iput(ip);
    80004126:	854e                	mv	a0,s3
    80004128:	00000097          	auipc	ra,0x0
    8000412c:	adc080e7          	jalr	-1316(ra) # 80003c04 <iput>
    return 0;
    80004130:	4981                	li	s3,0
    80004132:	bf19                	j	80004048 <namex+0x6a>
  if(*path == 0)
    80004134:	d7fd                	beqz	a5,80004122 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004136:	0004c783          	lbu	a5,0(s1)
    8000413a:	85a6                	mv	a1,s1
    8000413c:	b7d1                	j	80004100 <namex+0x122>

000000008000413e <dirlink>:
{
    8000413e:	7139                	addi	sp,sp,-64
    80004140:	fc06                	sd	ra,56(sp)
    80004142:	f822                	sd	s0,48(sp)
    80004144:	f426                	sd	s1,40(sp)
    80004146:	f04a                	sd	s2,32(sp)
    80004148:	ec4e                	sd	s3,24(sp)
    8000414a:	e852                	sd	s4,16(sp)
    8000414c:	0080                	addi	s0,sp,64
    8000414e:	892a                	mv	s2,a0
    80004150:	8a2e                	mv	s4,a1
    80004152:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004154:	4601                	li	a2,0
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	dd8080e7          	jalr	-552(ra) # 80003f2e <dirlookup>
    8000415e:	e93d                	bnez	a0,800041d4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004160:	04c92483          	lw	s1,76(s2)
    80004164:	c49d                	beqz	s1,80004192 <dirlink+0x54>
    80004166:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004168:	4741                	li	a4,16
    8000416a:	86a6                	mv	a3,s1
    8000416c:	fc040613          	addi	a2,s0,-64
    80004170:	4581                	li	a1,0
    80004172:	854a                	mv	a0,s2
    80004174:	00000097          	auipc	ra,0x0
    80004178:	b8a080e7          	jalr	-1142(ra) # 80003cfe <readi>
    8000417c:	47c1                	li	a5,16
    8000417e:	06f51163          	bne	a0,a5,800041e0 <dirlink+0xa2>
    if(de.inum == 0)
    80004182:	fc045783          	lhu	a5,-64(s0)
    80004186:	c791                	beqz	a5,80004192 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004188:	24c1                	addiw	s1,s1,16
    8000418a:	04c92783          	lw	a5,76(s2)
    8000418e:	fcf4ede3          	bltu	s1,a5,80004168 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004192:	4639                	li	a2,14
    80004194:	85d2                	mv	a1,s4
    80004196:	fc240513          	addi	a0,s0,-62
    8000419a:	ffffd097          	auipc	ra,0xffffd
    8000419e:	c5a080e7          	jalr	-934(ra) # 80000df4 <strncpy>
  de.inum = inum;
    800041a2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041a6:	4741                	li	a4,16
    800041a8:	86a6                	mv	a3,s1
    800041aa:	fc040613          	addi	a2,s0,-64
    800041ae:	4581                	li	a1,0
    800041b0:	854a                	mv	a0,s2
    800041b2:	00000097          	auipc	ra,0x0
    800041b6:	c44080e7          	jalr	-956(ra) # 80003df6 <writei>
    800041ba:	872a                	mv	a4,a0
    800041bc:	47c1                	li	a5,16
  return 0;
    800041be:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041c0:	02f71863          	bne	a4,a5,800041f0 <dirlink+0xb2>
}
    800041c4:	70e2                	ld	ra,56(sp)
    800041c6:	7442                	ld	s0,48(sp)
    800041c8:	74a2                	ld	s1,40(sp)
    800041ca:	7902                	ld	s2,32(sp)
    800041cc:	69e2                	ld	s3,24(sp)
    800041ce:	6a42                	ld	s4,16(sp)
    800041d0:	6121                	addi	sp,sp,64
    800041d2:	8082                	ret
    iput(ip);
    800041d4:	00000097          	auipc	ra,0x0
    800041d8:	a30080e7          	jalr	-1488(ra) # 80003c04 <iput>
    return -1;
    800041dc:	557d                	li	a0,-1
    800041de:	b7dd                	j	800041c4 <dirlink+0x86>
      panic("dirlink read");
    800041e0:	00004517          	auipc	a0,0x4
    800041e4:	47850513          	addi	a0,a0,1144 # 80008658 <syscalls+0x1c8>
    800041e8:	ffffc097          	auipc	ra,0xffffc
    800041ec:	356080e7          	jalr	854(ra) # 8000053e <panic>
    panic("dirlink");
    800041f0:	00004517          	auipc	a0,0x4
    800041f4:	57850513          	addi	a0,a0,1400 # 80008768 <syscalls+0x2d8>
    800041f8:	ffffc097          	auipc	ra,0xffffc
    800041fc:	346080e7          	jalr	838(ra) # 8000053e <panic>

0000000080004200 <namei>:

struct inode*
namei(char *path)
{
    80004200:	1101                	addi	sp,sp,-32
    80004202:	ec06                	sd	ra,24(sp)
    80004204:	e822                	sd	s0,16(sp)
    80004206:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004208:	fe040613          	addi	a2,s0,-32
    8000420c:	4581                	li	a1,0
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	dd0080e7          	jalr	-560(ra) # 80003fde <namex>
}
    80004216:	60e2                	ld	ra,24(sp)
    80004218:	6442                	ld	s0,16(sp)
    8000421a:	6105                	addi	sp,sp,32
    8000421c:	8082                	ret

000000008000421e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000421e:	1141                	addi	sp,sp,-16
    80004220:	e406                	sd	ra,8(sp)
    80004222:	e022                	sd	s0,0(sp)
    80004224:	0800                	addi	s0,sp,16
    80004226:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004228:	4585                	li	a1,1
    8000422a:	00000097          	auipc	ra,0x0
    8000422e:	db4080e7          	jalr	-588(ra) # 80003fde <namex>
}
    80004232:	60a2                	ld	ra,8(sp)
    80004234:	6402                	ld	s0,0(sp)
    80004236:	0141                	addi	sp,sp,16
    80004238:	8082                	ret

000000008000423a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000423a:	1101                	addi	sp,sp,-32
    8000423c:	ec06                	sd	ra,24(sp)
    8000423e:	e822                	sd	s0,16(sp)
    80004240:	e426                	sd	s1,8(sp)
    80004242:	e04a                	sd	s2,0(sp)
    80004244:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004246:	0001e917          	auipc	s2,0x1e
    8000424a:	96a90913          	addi	s2,s2,-1686 # 80021bb0 <log>
    8000424e:	01892583          	lw	a1,24(s2)
    80004252:	02892503          	lw	a0,40(s2)
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	ff2080e7          	jalr	-14(ra) # 80003248 <bread>
    8000425e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004260:	02c92683          	lw	a3,44(s2)
    80004264:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004266:	02d05763          	blez	a3,80004294 <write_head+0x5a>
    8000426a:	0001e797          	auipc	a5,0x1e
    8000426e:	97678793          	addi	a5,a5,-1674 # 80021be0 <log+0x30>
    80004272:	05c50713          	addi	a4,a0,92
    80004276:	36fd                	addiw	a3,a3,-1
    80004278:	1682                	slli	a3,a3,0x20
    8000427a:	9281                	srli	a3,a3,0x20
    8000427c:	068a                	slli	a3,a3,0x2
    8000427e:	0001e617          	auipc	a2,0x1e
    80004282:	96660613          	addi	a2,a2,-1690 # 80021be4 <log+0x34>
    80004286:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004288:	4390                	lw	a2,0(a5)
    8000428a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000428c:	0791                	addi	a5,a5,4
    8000428e:	0711                	addi	a4,a4,4
    80004290:	fed79ce3          	bne	a5,a3,80004288 <write_head+0x4e>
  }
  bwrite(buf);
    80004294:	8526                	mv	a0,s1
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	0a4080e7          	jalr	164(ra) # 8000333a <bwrite>
  brelse(buf);
    8000429e:	8526                	mv	a0,s1
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	0d8080e7          	jalr	216(ra) # 80003378 <brelse>
}
    800042a8:	60e2                	ld	ra,24(sp)
    800042aa:	6442                	ld	s0,16(sp)
    800042ac:	64a2                	ld	s1,8(sp)
    800042ae:	6902                	ld	s2,0(sp)
    800042b0:	6105                	addi	sp,sp,32
    800042b2:	8082                	ret

00000000800042b4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b4:	0001e797          	auipc	a5,0x1e
    800042b8:	9287a783          	lw	a5,-1752(a5) # 80021bdc <log+0x2c>
    800042bc:	0af05d63          	blez	a5,80004376 <install_trans+0xc2>
{
    800042c0:	7139                	addi	sp,sp,-64
    800042c2:	fc06                	sd	ra,56(sp)
    800042c4:	f822                	sd	s0,48(sp)
    800042c6:	f426                	sd	s1,40(sp)
    800042c8:	f04a                	sd	s2,32(sp)
    800042ca:	ec4e                	sd	s3,24(sp)
    800042cc:	e852                	sd	s4,16(sp)
    800042ce:	e456                	sd	s5,8(sp)
    800042d0:	e05a                	sd	s6,0(sp)
    800042d2:	0080                	addi	s0,sp,64
    800042d4:	8b2a                	mv	s6,a0
    800042d6:	0001ea97          	auipc	s5,0x1e
    800042da:	90aa8a93          	addi	s5,s5,-1782 # 80021be0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042de:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042e0:	0001e997          	auipc	s3,0x1e
    800042e4:	8d098993          	addi	s3,s3,-1840 # 80021bb0 <log>
    800042e8:	a035                	j	80004314 <install_trans+0x60>
      bunpin(dbuf);
    800042ea:	8526                	mv	a0,s1
    800042ec:	fffff097          	auipc	ra,0xfffff
    800042f0:	166080e7          	jalr	358(ra) # 80003452 <bunpin>
    brelse(lbuf);
    800042f4:	854a                	mv	a0,s2
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	082080e7          	jalr	130(ra) # 80003378 <brelse>
    brelse(dbuf);
    800042fe:	8526                	mv	a0,s1
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	078080e7          	jalr	120(ra) # 80003378 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004308:	2a05                	addiw	s4,s4,1
    8000430a:	0a91                	addi	s5,s5,4
    8000430c:	02c9a783          	lw	a5,44(s3)
    80004310:	04fa5963          	bge	s4,a5,80004362 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004314:	0189a583          	lw	a1,24(s3)
    80004318:	014585bb          	addw	a1,a1,s4
    8000431c:	2585                	addiw	a1,a1,1
    8000431e:	0289a503          	lw	a0,40(s3)
    80004322:	fffff097          	auipc	ra,0xfffff
    80004326:	f26080e7          	jalr	-218(ra) # 80003248 <bread>
    8000432a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000432c:	000aa583          	lw	a1,0(s5)
    80004330:	0289a503          	lw	a0,40(s3)
    80004334:	fffff097          	auipc	ra,0xfffff
    80004338:	f14080e7          	jalr	-236(ra) # 80003248 <bread>
    8000433c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000433e:	40000613          	li	a2,1024
    80004342:	05890593          	addi	a1,s2,88
    80004346:	05850513          	addi	a0,a0,88
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	9f6080e7          	jalr	-1546(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004352:	8526                	mv	a0,s1
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	fe6080e7          	jalr	-26(ra) # 8000333a <bwrite>
    if(recovering == 0)
    8000435c:	f80b1ce3          	bnez	s6,800042f4 <install_trans+0x40>
    80004360:	b769                	j	800042ea <install_trans+0x36>
}
    80004362:	70e2                	ld	ra,56(sp)
    80004364:	7442                	ld	s0,48(sp)
    80004366:	74a2                	ld	s1,40(sp)
    80004368:	7902                	ld	s2,32(sp)
    8000436a:	69e2                	ld	s3,24(sp)
    8000436c:	6a42                	ld	s4,16(sp)
    8000436e:	6aa2                	ld	s5,8(sp)
    80004370:	6b02                	ld	s6,0(sp)
    80004372:	6121                	addi	sp,sp,64
    80004374:	8082                	ret
    80004376:	8082                	ret

0000000080004378 <initlog>:
{
    80004378:	7179                	addi	sp,sp,-48
    8000437a:	f406                	sd	ra,40(sp)
    8000437c:	f022                	sd	s0,32(sp)
    8000437e:	ec26                	sd	s1,24(sp)
    80004380:	e84a                	sd	s2,16(sp)
    80004382:	e44e                	sd	s3,8(sp)
    80004384:	1800                	addi	s0,sp,48
    80004386:	892a                	mv	s2,a0
    80004388:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000438a:	0001e497          	auipc	s1,0x1e
    8000438e:	82648493          	addi	s1,s1,-2010 # 80021bb0 <log>
    80004392:	00004597          	auipc	a1,0x4
    80004396:	2d658593          	addi	a1,a1,726 # 80008668 <syscalls+0x1d8>
    8000439a:	8526                	mv	a0,s1
    8000439c:	ffffc097          	auipc	ra,0xffffc
    800043a0:	7b8080e7          	jalr	1976(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    800043a4:	0149a583          	lw	a1,20(s3)
    800043a8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800043aa:	0109a783          	lw	a5,16(s3)
    800043ae:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800043b0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043b4:	854a                	mv	a0,s2
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	e92080e7          	jalr	-366(ra) # 80003248 <bread>
  log.lh.n = lh->n;
    800043be:	4d3c                	lw	a5,88(a0)
    800043c0:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800043c2:	02f05563          	blez	a5,800043ec <initlog+0x74>
    800043c6:	05c50713          	addi	a4,a0,92
    800043ca:	0001e697          	auipc	a3,0x1e
    800043ce:	81668693          	addi	a3,a3,-2026 # 80021be0 <log+0x30>
    800043d2:	37fd                	addiw	a5,a5,-1
    800043d4:	1782                	slli	a5,a5,0x20
    800043d6:	9381                	srli	a5,a5,0x20
    800043d8:	078a                	slli	a5,a5,0x2
    800043da:	06050613          	addi	a2,a0,96
    800043de:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800043e0:	4310                	lw	a2,0(a4)
    800043e2:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800043e4:	0711                	addi	a4,a4,4
    800043e6:	0691                	addi	a3,a3,4
    800043e8:	fef71ce3          	bne	a4,a5,800043e0 <initlog+0x68>
  brelse(buf);
    800043ec:	fffff097          	auipc	ra,0xfffff
    800043f0:	f8c080e7          	jalr	-116(ra) # 80003378 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043f4:	4505                	li	a0,1
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	ebe080e7          	jalr	-322(ra) # 800042b4 <install_trans>
  log.lh.n = 0;
    800043fe:	0001d797          	auipc	a5,0x1d
    80004402:	7c07af23          	sw	zero,2014(a5) # 80021bdc <log+0x2c>
  write_head(); // clear the log
    80004406:	00000097          	auipc	ra,0x0
    8000440a:	e34080e7          	jalr	-460(ra) # 8000423a <write_head>
}
    8000440e:	70a2                	ld	ra,40(sp)
    80004410:	7402                	ld	s0,32(sp)
    80004412:	64e2                	ld	s1,24(sp)
    80004414:	6942                	ld	s2,16(sp)
    80004416:	69a2                	ld	s3,8(sp)
    80004418:	6145                	addi	sp,sp,48
    8000441a:	8082                	ret

000000008000441c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000441c:	1101                	addi	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	e426                	sd	s1,8(sp)
    80004424:	e04a                	sd	s2,0(sp)
    80004426:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004428:	0001d517          	auipc	a0,0x1d
    8000442c:	78850513          	addi	a0,a0,1928 # 80021bb0 <log>
    80004430:	ffffc097          	auipc	ra,0xffffc
    80004434:	7b4080e7          	jalr	1972(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    80004438:	0001d497          	auipc	s1,0x1d
    8000443c:	77848493          	addi	s1,s1,1912 # 80021bb0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004440:	4979                	li	s2,30
    80004442:	a039                	j	80004450 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004444:	85a6                	mv	a1,s1
    80004446:	8526                	mv	a0,s1
    80004448:	ffffe097          	auipc	ra,0xffffe
    8000444c:	05a080e7          	jalr	90(ra) # 800024a2 <sleep>
    if(log.committing){
    80004450:	50dc                	lw	a5,36(s1)
    80004452:	fbed                	bnez	a5,80004444 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004454:	509c                	lw	a5,32(s1)
    80004456:	0017871b          	addiw	a4,a5,1
    8000445a:	0007069b          	sext.w	a3,a4
    8000445e:	0027179b          	slliw	a5,a4,0x2
    80004462:	9fb9                	addw	a5,a5,a4
    80004464:	0017979b          	slliw	a5,a5,0x1
    80004468:	54d8                	lw	a4,44(s1)
    8000446a:	9fb9                	addw	a5,a5,a4
    8000446c:	00f95963          	bge	s2,a5,8000447e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004470:	85a6                	mv	a1,s1
    80004472:	8526                	mv	a0,s1
    80004474:	ffffe097          	auipc	ra,0xffffe
    80004478:	02e080e7          	jalr	46(ra) # 800024a2 <sleep>
    8000447c:	bfd1                	j	80004450 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000447e:	0001d517          	auipc	a0,0x1d
    80004482:	73250513          	addi	a0,a0,1842 # 80021bb0 <log>
    80004486:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004488:	ffffd097          	auipc	ra,0xffffd
    8000448c:	810080e7          	jalr	-2032(ra) # 80000c98 <release>
      break;
    }
  }
}
    80004490:	60e2                	ld	ra,24(sp)
    80004492:	6442                	ld	s0,16(sp)
    80004494:	64a2                	ld	s1,8(sp)
    80004496:	6902                	ld	s2,0(sp)
    80004498:	6105                	addi	sp,sp,32
    8000449a:	8082                	ret

000000008000449c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000449c:	7139                	addi	sp,sp,-64
    8000449e:	fc06                	sd	ra,56(sp)
    800044a0:	f822                	sd	s0,48(sp)
    800044a2:	f426                	sd	s1,40(sp)
    800044a4:	f04a                	sd	s2,32(sp)
    800044a6:	ec4e                	sd	s3,24(sp)
    800044a8:	e852                	sd	s4,16(sp)
    800044aa:	e456                	sd	s5,8(sp)
    800044ac:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044ae:	0001d497          	auipc	s1,0x1d
    800044b2:	70248493          	addi	s1,s1,1794 # 80021bb0 <log>
    800044b6:	8526                	mv	a0,s1
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	72c080e7          	jalr	1836(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    800044c0:	509c                	lw	a5,32(s1)
    800044c2:	37fd                	addiw	a5,a5,-1
    800044c4:	0007891b          	sext.w	s2,a5
    800044c8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800044ca:	50dc                	lw	a5,36(s1)
    800044cc:	efb9                	bnez	a5,8000452a <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800044ce:	06091663          	bnez	s2,8000453a <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800044d2:	0001d497          	auipc	s1,0x1d
    800044d6:	6de48493          	addi	s1,s1,1758 # 80021bb0 <log>
    800044da:	4785                	li	a5,1
    800044dc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044de:	8526                	mv	a0,s1
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	7b8080e7          	jalr	1976(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044e8:	54dc                	lw	a5,44(s1)
    800044ea:	06f04763          	bgtz	a5,80004558 <end_op+0xbc>
    acquire(&log.lock);
    800044ee:	0001d497          	auipc	s1,0x1d
    800044f2:	6c248493          	addi	s1,s1,1730 # 80021bb0 <log>
    800044f6:	8526                	mv	a0,s1
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	6ec080e7          	jalr	1772(ra) # 80000be4 <acquire>
    log.committing = 0;
    80004500:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004504:	8526                	mv	a0,s1
    80004506:	ffffe097          	auipc	ra,0xffffe
    8000450a:	13a080e7          	jalr	314(ra) # 80002640 <wakeup>
    release(&log.lock);
    8000450e:	8526                	mv	a0,s1
    80004510:	ffffc097          	auipc	ra,0xffffc
    80004514:	788080e7          	jalr	1928(ra) # 80000c98 <release>
}
    80004518:	70e2                	ld	ra,56(sp)
    8000451a:	7442                	ld	s0,48(sp)
    8000451c:	74a2                	ld	s1,40(sp)
    8000451e:	7902                	ld	s2,32(sp)
    80004520:	69e2                	ld	s3,24(sp)
    80004522:	6a42                	ld	s4,16(sp)
    80004524:	6aa2                	ld	s5,8(sp)
    80004526:	6121                	addi	sp,sp,64
    80004528:	8082                	ret
    panic("log.committing");
    8000452a:	00004517          	auipc	a0,0x4
    8000452e:	14650513          	addi	a0,a0,326 # 80008670 <syscalls+0x1e0>
    80004532:	ffffc097          	auipc	ra,0xffffc
    80004536:	00c080e7          	jalr	12(ra) # 8000053e <panic>
    wakeup(&log);
    8000453a:	0001d497          	auipc	s1,0x1d
    8000453e:	67648493          	addi	s1,s1,1654 # 80021bb0 <log>
    80004542:	8526                	mv	a0,s1
    80004544:	ffffe097          	auipc	ra,0xffffe
    80004548:	0fc080e7          	jalr	252(ra) # 80002640 <wakeup>
  release(&log.lock);
    8000454c:	8526                	mv	a0,s1
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	74a080e7          	jalr	1866(ra) # 80000c98 <release>
  if(do_commit){
    80004556:	b7c9                	j	80004518 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004558:	0001da97          	auipc	s5,0x1d
    8000455c:	688a8a93          	addi	s5,s5,1672 # 80021be0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004560:	0001da17          	auipc	s4,0x1d
    80004564:	650a0a13          	addi	s4,s4,1616 # 80021bb0 <log>
    80004568:	018a2583          	lw	a1,24(s4)
    8000456c:	012585bb          	addw	a1,a1,s2
    80004570:	2585                	addiw	a1,a1,1
    80004572:	028a2503          	lw	a0,40(s4)
    80004576:	fffff097          	auipc	ra,0xfffff
    8000457a:	cd2080e7          	jalr	-814(ra) # 80003248 <bread>
    8000457e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004580:	000aa583          	lw	a1,0(s5)
    80004584:	028a2503          	lw	a0,40(s4)
    80004588:	fffff097          	auipc	ra,0xfffff
    8000458c:	cc0080e7          	jalr	-832(ra) # 80003248 <bread>
    80004590:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004592:	40000613          	li	a2,1024
    80004596:	05850593          	addi	a1,a0,88
    8000459a:	05848513          	addi	a0,s1,88
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	7a2080e7          	jalr	1954(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    800045a6:	8526                	mv	a0,s1
    800045a8:	fffff097          	auipc	ra,0xfffff
    800045ac:	d92080e7          	jalr	-622(ra) # 8000333a <bwrite>
    brelse(from);
    800045b0:	854e                	mv	a0,s3
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	dc6080e7          	jalr	-570(ra) # 80003378 <brelse>
    brelse(to);
    800045ba:	8526                	mv	a0,s1
    800045bc:	fffff097          	auipc	ra,0xfffff
    800045c0:	dbc080e7          	jalr	-580(ra) # 80003378 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045c4:	2905                	addiw	s2,s2,1
    800045c6:	0a91                	addi	s5,s5,4
    800045c8:	02ca2783          	lw	a5,44(s4)
    800045cc:	f8f94ee3          	blt	s2,a5,80004568 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	c6a080e7          	jalr	-918(ra) # 8000423a <write_head>
    install_trans(0); // Now install writes to home locations
    800045d8:	4501                	li	a0,0
    800045da:	00000097          	auipc	ra,0x0
    800045de:	cda080e7          	jalr	-806(ra) # 800042b4 <install_trans>
    log.lh.n = 0;
    800045e2:	0001d797          	auipc	a5,0x1d
    800045e6:	5e07ad23          	sw	zero,1530(a5) # 80021bdc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	c50080e7          	jalr	-944(ra) # 8000423a <write_head>
    800045f2:	bdf5                	j	800044ee <end_op+0x52>

00000000800045f4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045f4:	1101                	addi	sp,sp,-32
    800045f6:	ec06                	sd	ra,24(sp)
    800045f8:	e822                	sd	s0,16(sp)
    800045fa:	e426                	sd	s1,8(sp)
    800045fc:	e04a                	sd	s2,0(sp)
    800045fe:	1000                	addi	s0,sp,32
    80004600:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004602:	0001d917          	auipc	s2,0x1d
    80004606:	5ae90913          	addi	s2,s2,1454 # 80021bb0 <log>
    8000460a:	854a                	mv	a0,s2
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	5d8080e7          	jalr	1496(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004614:	02c92603          	lw	a2,44(s2)
    80004618:	47f5                	li	a5,29
    8000461a:	06c7c563          	blt	a5,a2,80004684 <log_write+0x90>
    8000461e:	0001d797          	auipc	a5,0x1d
    80004622:	5ae7a783          	lw	a5,1454(a5) # 80021bcc <log+0x1c>
    80004626:	37fd                	addiw	a5,a5,-1
    80004628:	04f65e63          	bge	a2,a5,80004684 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000462c:	0001d797          	auipc	a5,0x1d
    80004630:	5a47a783          	lw	a5,1444(a5) # 80021bd0 <log+0x20>
    80004634:	06f05063          	blez	a5,80004694 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004638:	4781                	li	a5,0
    8000463a:	06c05563          	blez	a2,800046a4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000463e:	44cc                	lw	a1,12(s1)
    80004640:	0001d717          	auipc	a4,0x1d
    80004644:	5a070713          	addi	a4,a4,1440 # 80021be0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004648:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000464a:	4314                	lw	a3,0(a4)
    8000464c:	04b68c63          	beq	a3,a1,800046a4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004650:	2785                	addiw	a5,a5,1
    80004652:	0711                	addi	a4,a4,4
    80004654:	fef61be3          	bne	a2,a5,8000464a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004658:	0621                	addi	a2,a2,8
    8000465a:	060a                	slli	a2,a2,0x2
    8000465c:	0001d797          	auipc	a5,0x1d
    80004660:	55478793          	addi	a5,a5,1364 # 80021bb0 <log>
    80004664:	963e                	add	a2,a2,a5
    80004666:	44dc                	lw	a5,12(s1)
    80004668:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000466a:	8526                	mv	a0,s1
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	daa080e7          	jalr	-598(ra) # 80003416 <bpin>
    log.lh.n++;
    80004674:	0001d717          	auipc	a4,0x1d
    80004678:	53c70713          	addi	a4,a4,1340 # 80021bb0 <log>
    8000467c:	575c                	lw	a5,44(a4)
    8000467e:	2785                	addiw	a5,a5,1
    80004680:	d75c                	sw	a5,44(a4)
    80004682:	a835                	j	800046be <log_write+0xca>
    panic("too big a transaction");
    80004684:	00004517          	auipc	a0,0x4
    80004688:	ffc50513          	addi	a0,a0,-4 # 80008680 <syscalls+0x1f0>
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	eb2080e7          	jalr	-334(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004694:	00004517          	auipc	a0,0x4
    80004698:	00450513          	addi	a0,a0,4 # 80008698 <syscalls+0x208>
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	ea2080e7          	jalr	-350(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800046a4:	00878713          	addi	a4,a5,8
    800046a8:	00271693          	slli	a3,a4,0x2
    800046ac:	0001d717          	auipc	a4,0x1d
    800046b0:	50470713          	addi	a4,a4,1284 # 80021bb0 <log>
    800046b4:	9736                	add	a4,a4,a3
    800046b6:	44d4                	lw	a3,12(s1)
    800046b8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800046ba:	faf608e3          	beq	a2,a5,8000466a <log_write+0x76>
  }
  release(&log.lock);
    800046be:	0001d517          	auipc	a0,0x1d
    800046c2:	4f250513          	addi	a0,a0,1266 # 80021bb0 <log>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	5d2080e7          	jalr	1490(ra) # 80000c98 <release>
}
    800046ce:	60e2                	ld	ra,24(sp)
    800046d0:	6442                	ld	s0,16(sp)
    800046d2:	64a2                	ld	s1,8(sp)
    800046d4:	6902                	ld	s2,0(sp)
    800046d6:	6105                	addi	sp,sp,32
    800046d8:	8082                	ret

00000000800046da <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800046da:	1101                	addi	sp,sp,-32
    800046dc:	ec06                	sd	ra,24(sp)
    800046de:	e822                	sd	s0,16(sp)
    800046e0:	e426                	sd	s1,8(sp)
    800046e2:	e04a                	sd	s2,0(sp)
    800046e4:	1000                	addi	s0,sp,32
    800046e6:	84aa                	mv	s1,a0
    800046e8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046ea:	00004597          	auipc	a1,0x4
    800046ee:	fce58593          	addi	a1,a1,-50 # 800086b8 <syscalls+0x228>
    800046f2:	0521                	addi	a0,a0,8
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	460080e7          	jalr	1120(ra) # 80000b54 <initlock>
  lk->name = name;
    800046fc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004700:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004704:	0204a423          	sw	zero,40(s1)
}
    80004708:	60e2                	ld	ra,24(sp)
    8000470a:	6442                	ld	s0,16(sp)
    8000470c:	64a2                	ld	s1,8(sp)
    8000470e:	6902                	ld	s2,0(sp)
    80004710:	6105                	addi	sp,sp,32
    80004712:	8082                	ret

0000000080004714 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004714:	1101                	addi	sp,sp,-32
    80004716:	ec06                	sd	ra,24(sp)
    80004718:	e822                	sd	s0,16(sp)
    8000471a:	e426                	sd	s1,8(sp)
    8000471c:	e04a                	sd	s2,0(sp)
    8000471e:	1000                	addi	s0,sp,32
    80004720:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004722:	00850913          	addi	s2,a0,8
    80004726:	854a                	mv	a0,s2
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	4bc080e7          	jalr	1212(ra) # 80000be4 <acquire>
  while (lk->locked) {
    80004730:	409c                	lw	a5,0(s1)
    80004732:	cb89                	beqz	a5,80004744 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004734:	85ca                	mv	a1,s2
    80004736:	8526                	mv	a0,s1
    80004738:	ffffe097          	auipc	ra,0xffffe
    8000473c:	d6a080e7          	jalr	-662(ra) # 800024a2 <sleep>
  while (lk->locked) {
    80004740:	409c                	lw	a5,0(s1)
    80004742:	fbed                	bnez	a5,80004734 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004744:	4785                	li	a5,1
    80004746:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004748:	ffffd097          	auipc	ra,0xffffd
    8000474c:	61c080e7          	jalr	1564(ra) # 80001d64 <myproc>
    80004750:	591c                	lw	a5,48(a0)
    80004752:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004754:	854a                	mv	a0,s2
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	542080e7          	jalr	1346(ra) # 80000c98 <release>
}
    8000475e:	60e2                	ld	ra,24(sp)
    80004760:	6442                	ld	s0,16(sp)
    80004762:	64a2                	ld	s1,8(sp)
    80004764:	6902                	ld	s2,0(sp)
    80004766:	6105                	addi	sp,sp,32
    80004768:	8082                	ret

000000008000476a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000476a:	1101                	addi	sp,sp,-32
    8000476c:	ec06                	sd	ra,24(sp)
    8000476e:	e822                	sd	s0,16(sp)
    80004770:	e426                	sd	s1,8(sp)
    80004772:	e04a                	sd	s2,0(sp)
    80004774:	1000                	addi	s0,sp,32
    80004776:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004778:	00850913          	addi	s2,a0,8
    8000477c:	854a                	mv	a0,s2
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	466080e7          	jalr	1126(ra) # 80000be4 <acquire>
  lk->locked = 0;
    80004786:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000478a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000478e:	8526                	mv	a0,s1
    80004790:	ffffe097          	auipc	ra,0xffffe
    80004794:	eb0080e7          	jalr	-336(ra) # 80002640 <wakeup>
  release(&lk->lk);
    80004798:	854a                	mv	a0,s2
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	4fe080e7          	jalr	1278(ra) # 80000c98 <release>
}
    800047a2:	60e2                	ld	ra,24(sp)
    800047a4:	6442                	ld	s0,16(sp)
    800047a6:	64a2                	ld	s1,8(sp)
    800047a8:	6902                	ld	s2,0(sp)
    800047aa:	6105                	addi	sp,sp,32
    800047ac:	8082                	ret

00000000800047ae <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800047ae:	7179                	addi	sp,sp,-48
    800047b0:	f406                	sd	ra,40(sp)
    800047b2:	f022                	sd	s0,32(sp)
    800047b4:	ec26                	sd	s1,24(sp)
    800047b6:	e84a                	sd	s2,16(sp)
    800047b8:	e44e                	sd	s3,8(sp)
    800047ba:	1800                	addi	s0,sp,48
    800047bc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800047be:	00850913          	addi	s2,a0,8
    800047c2:	854a                	mv	a0,s2
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	420080e7          	jalr	1056(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800047cc:	409c                	lw	a5,0(s1)
    800047ce:	ef99                	bnez	a5,800047ec <holdingsleep+0x3e>
    800047d0:	4481                	li	s1,0
  release(&lk->lk);
    800047d2:	854a                	mv	a0,s2
    800047d4:	ffffc097          	auipc	ra,0xffffc
    800047d8:	4c4080e7          	jalr	1220(ra) # 80000c98 <release>
  return r;
}
    800047dc:	8526                	mv	a0,s1
    800047de:	70a2                	ld	ra,40(sp)
    800047e0:	7402                	ld	s0,32(sp)
    800047e2:	64e2                	ld	s1,24(sp)
    800047e4:	6942                	ld	s2,16(sp)
    800047e6:	69a2                	ld	s3,8(sp)
    800047e8:	6145                	addi	sp,sp,48
    800047ea:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800047ec:	0284a983          	lw	s3,40(s1)
    800047f0:	ffffd097          	auipc	ra,0xffffd
    800047f4:	574080e7          	jalr	1396(ra) # 80001d64 <myproc>
    800047f8:	5904                	lw	s1,48(a0)
    800047fa:	413484b3          	sub	s1,s1,s3
    800047fe:	0014b493          	seqz	s1,s1
    80004802:	bfc1                	j	800047d2 <holdingsleep+0x24>

0000000080004804 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004804:	1141                	addi	sp,sp,-16
    80004806:	e406                	sd	ra,8(sp)
    80004808:	e022                	sd	s0,0(sp)
    8000480a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000480c:	00004597          	auipc	a1,0x4
    80004810:	ebc58593          	addi	a1,a1,-324 # 800086c8 <syscalls+0x238>
    80004814:	0001d517          	auipc	a0,0x1d
    80004818:	4e450513          	addi	a0,a0,1252 # 80021cf8 <ftable>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	338080e7          	jalr	824(ra) # 80000b54 <initlock>
}
    80004824:	60a2                	ld	ra,8(sp)
    80004826:	6402                	ld	s0,0(sp)
    80004828:	0141                	addi	sp,sp,16
    8000482a:	8082                	ret

000000008000482c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000482c:	1101                	addi	sp,sp,-32
    8000482e:	ec06                	sd	ra,24(sp)
    80004830:	e822                	sd	s0,16(sp)
    80004832:	e426                	sd	s1,8(sp)
    80004834:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004836:	0001d517          	auipc	a0,0x1d
    8000483a:	4c250513          	addi	a0,a0,1218 # 80021cf8 <ftable>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	3a6080e7          	jalr	934(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004846:	0001d497          	auipc	s1,0x1d
    8000484a:	4ca48493          	addi	s1,s1,1226 # 80021d10 <ftable+0x18>
    8000484e:	0001e717          	auipc	a4,0x1e
    80004852:	46270713          	addi	a4,a4,1122 # 80022cb0 <ftable+0xfb8>
    if(f->ref == 0){
    80004856:	40dc                	lw	a5,4(s1)
    80004858:	cf99                	beqz	a5,80004876 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000485a:	02848493          	addi	s1,s1,40
    8000485e:	fee49ce3          	bne	s1,a4,80004856 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004862:	0001d517          	auipc	a0,0x1d
    80004866:	49650513          	addi	a0,a0,1174 # 80021cf8 <ftable>
    8000486a:	ffffc097          	auipc	ra,0xffffc
    8000486e:	42e080e7          	jalr	1070(ra) # 80000c98 <release>
  return 0;
    80004872:	4481                	li	s1,0
    80004874:	a819                	j	8000488a <filealloc+0x5e>
      f->ref = 1;
    80004876:	4785                	li	a5,1
    80004878:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000487a:	0001d517          	auipc	a0,0x1d
    8000487e:	47e50513          	addi	a0,a0,1150 # 80021cf8 <ftable>
    80004882:	ffffc097          	auipc	ra,0xffffc
    80004886:	416080e7          	jalr	1046(ra) # 80000c98 <release>
}
    8000488a:	8526                	mv	a0,s1
    8000488c:	60e2                	ld	ra,24(sp)
    8000488e:	6442                	ld	s0,16(sp)
    80004890:	64a2                	ld	s1,8(sp)
    80004892:	6105                	addi	sp,sp,32
    80004894:	8082                	ret

0000000080004896 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004896:	1101                	addi	sp,sp,-32
    80004898:	ec06                	sd	ra,24(sp)
    8000489a:	e822                	sd	s0,16(sp)
    8000489c:	e426                	sd	s1,8(sp)
    8000489e:	1000                	addi	s0,sp,32
    800048a0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048a2:	0001d517          	auipc	a0,0x1d
    800048a6:	45650513          	addi	a0,a0,1110 # 80021cf8 <ftable>
    800048aa:	ffffc097          	auipc	ra,0xffffc
    800048ae:	33a080e7          	jalr	826(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    800048b2:	40dc                	lw	a5,4(s1)
    800048b4:	02f05263          	blez	a5,800048d8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800048b8:	2785                	addiw	a5,a5,1
    800048ba:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800048bc:	0001d517          	auipc	a0,0x1d
    800048c0:	43c50513          	addi	a0,a0,1084 # 80021cf8 <ftable>
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	3d4080e7          	jalr	980(ra) # 80000c98 <release>
  return f;
}
    800048cc:	8526                	mv	a0,s1
    800048ce:	60e2                	ld	ra,24(sp)
    800048d0:	6442                	ld	s0,16(sp)
    800048d2:	64a2                	ld	s1,8(sp)
    800048d4:	6105                	addi	sp,sp,32
    800048d6:	8082                	ret
    panic("filedup");
    800048d8:	00004517          	auipc	a0,0x4
    800048dc:	df850513          	addi	a0,a0,-520 # 800086d0 <syscalls+0x240>
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	c5e080e7          	jalr	-930(ra) # 8000053e <panic>

00000000800048e8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048e8:	7139                	addi	sp,sp,-64
    800048ea:	fc06                	sd	ra,56(sp)
    800048ec:	f822                	sd	s0,48(sp)
    800048ee:	f426                	sd	s1,40(sp)
    800048f0:	f04a                	sd	s2,32(sp)
    800048f2:	ec4e                	sd	s3,24(sp)
    800048f4:	e852                	sd	s4,16(sp)
    800048f6:	e456                	sd	s5,8(sp)
    800048f8:	0080                	addi	s0,sp,64
    800048fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048fc:	0001d517          	auipc	a0,0x1d
    80004900:	3fc50513          	addi	a0,a0,1020 # 80021cf8 <ftable>
    80004904:	ffffc097          	auipc	ra,0xffffc
    80004908:	2e0080e7          	jalr	736(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    8000490c:	40dc                	lw	a5,4(s1)
    8000490e:	06f05163          	blez	a5,80004970 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004912:	37fd                	addiw	a5,a5,-1
    80004914:	0007871b          	sext.w	a4,a5
    80004918:	c0dc                	sw	a5,4(s1)
    8000491a:	06e04363          	bgtz	a4,80004980 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000491e:	0004a903          	lw	s2,0(s1)
    80004922:	0094ca83          	lbu	s5,9(s1)
    80004926:	0104ba03          	ld	s4,16(s1)
    8000492a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000492e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004932:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004936:	0001d517          	auipc	a0,0x1d
    8000493a:	3c250513          	addi	a0,a0,962 # 80021cf8 <ftable>
    8000493e:	ffffc097          	auipc	ra,0xffffc
    80004942:	35a080e7          	jalr	858(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    80004946:	4785                	li	a5,1
    80004948:	04f90d63          	beq	s2,a5,800049a2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000494c:	3979                	addiw	s2,s2,-2
    8000494e:	4785                	li	a5,1
    80004950:	0527e063          	bltu	a5,s2,80004990 <fileclose+0xa8>
    begin_op();
    80004954:	00000097          	auipc	ra,0x0
    80004958:	ac8080e7          	jalr	-1336(ra) # 8000441c <begin_op>
    iput(ff.ip);
    8000495c:	854e                	mv	a0,s3
    8000495e:	fffff097          	auipc	ra,0xfffff
    80004962:	2a6080e7          	jalr	678(ra) # 80003c04 <iput>
    end_op();
    80004966:	00000097          	auipc	ra,0x0
    8000496a:	b36080e7          	jalr	-1226(ra) # 8000449c <end_op>
    8000496e:	a00d                	j	80004990 <fileclose+0xa8>
    panic("fileclose");
    80004970:	00004517          	auipc	a0,0x4
    80004974:	d6850513          	addi	a0,a0,-664 # 800086d8 <syscalls+0x248>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	bc6080e7          	jalr	-1082(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004980:	0001d517          	auipc	a0,0x1d
    80004984:	37850513          	addi	a0,a0,888 # 80021cf8 <ftable>
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	310080e7          	jalr	784(ra) # 80000c98 <release>
  }
}
    80004990:	70e2                	ld	ra,56(sp)
    80004992:	7442                	ld	s0,48(sp)
    80004994:	74a2                	ld	s1,40(sp)
    80004996:	7902                	ld	s2,32(sp)
    80004998:	69e2                	ld	s3,24(sp)
    8000499a:	6a42                	ld	s4,16(sp)
    8000499c:	6aa2                	ld	s5,8(sp)
    8000499e:	6121                	addi	sp,sp,64
    800049a0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049a2:	85d6                	mv	a1,s5
    800049a4:	8552                	mv	a0,s4
    800049a6:	00000097          	auipc	ra,0x0
    800049aa:	34c080e7          	jalr	844(ra) # 80004cf2 <pipeclose>
    800049ae:	b7cd                	j	80004990 <fileclose+0xa8>

00000000800049b0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049b0:	715d                	addi	sp,sp,-80
    800049b2:	e486                	sd	ra,72(sp)
    800049b4:	e0a2                	sd	s0,64(sp)
    800049b6:	fc26                	sd	s1,56(sp)
    800049b8:	f84a                	sd	s2,48(sp)
    800049ba:	f44e                	sd	s3,40(sp)
    800049bc:	0880                	addi	s0,sp,80
    800049be:	84aa                	mv	s1,a0
    800049c0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049c2:	ffffd097          	auipc	ra,0xffffd
    800049c6:	3a2080e7          	jalr	930(ra) # 80001d64 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800049ca:	409c                	lw	a5,0(s1)
    800049cc:	37f9                	addiw	a5,a5,-2
    800049ce:	4705                	li	a4,1
    800049d0:	04f76763          	bltu	a4,a5,80004a1e <filestat+0x6e>
    800049d4:	892a                	mv	s2,a0
    ilock(f->ip);
    800049d6:	6c88                	ld	a0,24(s1)
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	072080e7          	jalr	114(ra) # 80003a4a <ilock>
    stati(f->ip, &st);
    800049e0:	fb840593          	addi	a1,s0,-72
    800049e4:	6c88                	ld	a0,24(s1)
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	2ee080e7          	jalr	750(ra) # 80003cd4 <stati>
    iunlock(f->ip);
    800049ee:	6c88                	ld	a0,24(s1)
    800049f0:	fffff097          	auipc	ra,0xfffff
    800049f4:	11c080e7          	jalr	284(ra) # 80003b0c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049f8:	46e1                	li	a3,24
    800049fa:	fb840613          	addi	a2,s0,-72
    800049fe:	85ce                	mv	a1,s3
    80004a00:	07093503          	ld	a0,112(s2)
    80004a04:	ffffd097          	auipc	ra,0xffffd
    80004a08:	c6e080e7          	jalr	-914(ra) # 80001672 <copyout>
    80004a0c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a10:	60a6                	ld	ra,72(sp)
    80004a12:	6406                	ld	s0,64(sp)
    80004a14:	74e2                	ld	s1,56(sp)
    80004a16:	7942                	ld	s2,48(sp)
    80004a18:	79a2                	ld	s3,40(sp)
    80004a1a:	6161                	addi	sp,sp,80
    80004a1c:	8082                	ret
  return -1;
    80004a1e:	557d                	li	a0,-1
    80004a20:	bfc5                	j	80004a10 <filestat+0x60>

0000000080004a22 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a22:	7179                	addi	sp,sp,-48
    80004a24:	f406                	sd	ra,40(sp)
    80004a26:	f022                	sd	s0,32(sp)
    80004a28:	ec26                	sd	s1,24(sp)
    80004a2a:	e84a                	sd	s2,16(sp)
    80004a2c:	e44e                	sd	s3,8(sp)
    80004a2e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a30:	00854783          	lbu	a5,8(a0)
    80004a34:	c3d5                	beqz	a5,80004ad8 <fileread+0xb6>
    80004a36:	84aa                	mv	s1,a0
    80004a38:	89ae                	mv	s3,a1
    80004a3a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a3c:	411c                	lw	a5,0(a0)
    80004a3e:	4705                	li	a4,1
    80004a40:	04e78963          	beq	a5,a4,80004a92 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a44:	470d                	li	a4,3
    80004a46:	04e78d63          	beq	a5,a4,80004aa0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a4a:	4709                	li	a4,2
    80004a4c:	06e79e63          	bne	a5,a4,80004ac8 <fileread+0xa6>
    ilock(f->ip);
    80004a50:	6d08                	ld	a0,24(a0)
    80004a52:	fffff097          	auipc	ra,0xfffff
    80004a56:	ff8080e7          	jalr	-8(ra) # 80003a4a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a5a:	874a                	mv	a4,s2
    80004a5c:	5094                	lw	a3,32(s1)
    80004a5e:	864e                	mv	a2,s3
    80004a60:	4585                	li	a1,1
    80004a62:	6c88                	ld	a0,24(s1)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	29a080e7          	jalr	666(ra) # 80003cfe <readi>
    80004a6c:	892a                	mv	s2,a0
    80004a6e:	00a05563          	blez	a0,80004a78 <fileread+0x56>
      f->off += r;
    80004a72:	509c                	lw	a5,32(s1)
    80004a74:	9fa9                	addw	a5,a5,a0
    80004a76:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a78:	6c88                	ld	a0,24(s1)
    80004a7a:	fffff097          	auipc	ra,0xfffff
    80004a7e:	092080e7          	jalr	146(ra) # 80003b0c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a82:	854a                	mv	a0,s2
    80004a84:	70a2                	ld	ra,40(sp)
    80004a86:	7402                	ld	s0,32(sp)
    80004a88:	64e2                	ld	s1,24(sp)
    80004a8a:	6942                	ld	s2,16(sp)
    80004a8c:	69a2                	ld	s3,8(sp)
    80004a8e:	6145                	addi	sp,sp,48
    80004a90:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a92:	6908                	ld	a0,16(a0)
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	3c8080e7          	jalr	968(ra) # 80004e5c <piperead>
    80004a9c:	892a                	mv	s2,a0
    80004a9e:	b7d5                	j	80004a82 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004aa0:	02451783          	lh	a5,36(a0)
    80004aa4:	03079693          	slli	a3,a5,0x30
    80004aa8:	92c1                	srli	a3,a3,0x30
    80004aaa:	4725                	li	a4,9
    80004aac:	02d76863          	bltu	a4,a3,80004adc <fileread+0xba>
    80004ab0:	0792                	slli	a5,a5,0x4
    80004ab2:	0001d717          	auipc	a4,0x1d
    80004ab6:	1a670713          	addi	a4,a4,422 # 80021c58 <devsw>
    80004aba:	97ba                	add	a5,a5,a4
    80004abc:	639c                	ld	a5,0(a5)
    80004abe:	c38d                	beqz	a5,80004ae0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ac0:	4505                	li	a0,1
    80004ac2:	9782                	jalr	a5
    80004ac4:	892a                	mv	s2,a0
    80004ac6:	bf75                	j	80004a82 <fileread+0x60>
    panic("fileread");
    80004ac8:	00004517          	auipc	a0,0x4
    80004acc:	c2050513          	addi	a0,a0,-992 # 800086e8 <syscalls+0x258>
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	a6e080e7          	jalr	-1426(ra) # 8000053e <panic>
    return -1;
    80004ad8:	597d                	li	s2,-1
    80004ada:	b765                	j	80004a82 <fileread+0x60>
      return -1;
    80004adc:	597d                	li	s2,-1
    80004ade:	b755                	j	80004a82 <fileread+0x60>
    80004ae0:	597d                	li	s2,-1
    80004ae2:	b745                	j	80004a82 <fileread+0x60>

0000000080004ae4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ae4:	715d                	addi	sp,sp,-80
    80004ae6:	e486                	sd	ra,72(sp)
    80004ae8:	e0a2                	sd	s0,64(sp)
    80004aea:	fc26                	sd	s1,56(sp)
    80004aec:	f84a                	sd	s2,48(sp)
    80004aee:	f44e                	sd	s3,40(sp)
    80004af0:	f052                	sd	s4,32(sp)
    80004af2:	ec56                	sd	s5,24(sp)
    80004af4:	e85a                	sd	s6,16(sp)
    80004af6:	e45e                	sd	s7,8(sp)
    80004af8:	e062                	sd	s8,0(sp)
    80004afa:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004afc:	00954783          	lbu	a5,9(a0)
    80004b00:	10078663          	beqz	a5,80004c0c <filewrite+0x128>
    80004b04:	892a                	mv	s2,a0
    80004b06:	8aae                	mv	s5,a1
    80004b08:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b0a:	411c                	lw	a5,0(a0)
    80004b0c:	4705                	li	a4,1
    80004b0e:	02e78263          	beq	a5,a4,80004b32 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b12:	470d                	li	a4,3
    80004b14:	02e78663          	beq	a5,a4,80004b40 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b18:	4709                	li	a4,2
    80004b1a:	0ee79163          	bne	a5,a4,80004bfc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b1e:	0ac05d63          	blez	a2,80004bd8 <filewrite+0xf4>
    int i = 0;
    80004b22:	4981                	li	s3,0
    80004b24:	6b05                	lui	s6,0x1
    80004b26:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004b2a:	6b85                	lui	s7,0x1
    80004b2c:	c00b8b9b          	addiw	s7,s7,-1024
    80004b30:	a861                	j	80004bc8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b32:	6908                	ld	a0,16(a0)
    80004b34:	00000097          	auipc	ra,0x0
    80004b38:	22e080e7          	jalr	558(ra) # 80004d62 <pipewrite>
    80004b3c:	8a2a                	mv	s4,a0
    80004b3e:	a045                	j	80004bde <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b40:	02451783          	lh	a5,36(a0)
    80004b44:	03079693          	slli	a3,a5,0x30
    80004b48:	92c1                	srli	a3,a3,0x30
    80004b4a:	4725                	li	a4,9
    80004b4c:	0cd76263          	bltu	a4,a3,80004c10 <filewrite+0x12c>
    80004b50:	0792                	slli	a5,a5,0x4
    80004b52:	0001d717          	auipc	a4,0x1d
    80004b56:	10670713          	addi	a4,a4,262 # 80021c58 <devsw>
    80004b5a:	97ba                	add	a5,a5,a4
    80004b5c:	679c                	ld	a5,8(a5)
    80004b5e:	cbdd                	beqz	a5,80004c14 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004b60:	4505                	li	a0,1
    80004b62:	9782                	jalr	a5
    80004b64:	8a2a                	mv	s4,a0
    80004b66:	a8a5                	j	80004bde <filewrite+0xfa>
    80004b68:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b6c:	00000097          	auipc	ra,0x0
    80004b70:	8b0080e7          	jalr	-1872(ra) # 8000441c <begin_op>
      ilock(f->ip);
    80004b74:	01893503          	ld	a0,24(s2)
    80004b78:	fffff097          	auipc	ra,0xfffff
    80004b7c:	ed2080e7          	jalr	-302(ra) # 80003a4a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b80:	8762                	mv	a4,s8
    80004b82:	02092683          	lw	a3,32(s2)
    80004b86:	01598633          	add	a2,s3,s5
    80004b8a:	4585                	li	a1,1
    80004b8c:	01893503          	ld	a0,24(s2)
    80004b90:	fffff097          	auipc	ra,0xfffff
    80004b94:	266080e7          	jalr	614(ra) # 80003df6 <writei>
    80004b98:	84aa                	mv	s1,a0
    80004b9a:	00a05763          	blez	a0,80004ba8 <filewrite+0xc4>
        f->off += r;
    80004b9e:	02092783          	lw	a5,32(s2)
    80004ba2:	9fa9                	addw	a5,a5,a0
    80004ba4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ba8:	01893503          	ld	a0,24(s2)
    80004bac:	fffff097          	auipc	ra,0xfffff
    80004bb0:	f60080e7          	jalr	-160(ra) # 80003b0c <iunlock>
      end_op();
    80004bb4:	00000097          	auipc	ra,0x0
    80004bb8:	8e8080e7          	jalr	-1816(ra) # 8000449c <end_op>

      if(r != n1){
    80004bbc:	009c1f63          	bne	s8,s1,80004bda <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004bc0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004bc4:	0149db63          	bge	s3,s4,80004bda <filewrite+0xf6>
      int n1 = n - i;
    80004bc8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004bcc:	84be                	mv	s1,a5
    80004bce:	2781                	sext.w	a5,a5
    80004bd0:	f8fb5ce3          	bge	s6,a5,80004b68 <filewrite+0x84>
    80004bd4:	84de                	mv	s1,s7
    80004bd6:	bf49                	j	80004b68 <filewrite+0x84>
    int i = 0;
    80004bd8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004bda:	013a1f63          	bne	s4,s3,80004bf8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bde:	8552                	mv	a0,s4
    80004be0:	60a6                	ld	ra,72(sp)
    80004be2:	6406                	ld	s0,64(sp)
    80004be4:	74e2                	ld	s1,56(sp)
    80004be6:	7942                	ld	s2,48(sp)
    80004be8:	79a2                	ld	s3,40(sp)
    80004bea:	7a02                	ld	s4,32(sp)
    80004bec:	6ae2                	ld	s5,24(sp)
    80004bee:	6b42                	ld	s6,16(sp)
    80004bf0:	6ba2                	ld	s7,8(sp)
    80004bf2:	6c02                	ld	s8,0(sp)
    80004bf4:	6161                	addi	sp,sp,80
    80004bf6:	8082                	ret
    ret = (i == n ? n : -1);
    80004bf8:	5a7d                	li	s4,-1
    80004bfa:	b7d5                	j	80004bde <filewrite+0xfa>
    panic("filewrite");
    80004bfc:	00004517          	auipc	a0,0x4
    80004c00:	afc50513          	addi	a0,a0,-1284 # 800086f8 <syscalls+0x268>
    80004c04:	ffffc097          	auipc	ra,0xffffc
    80004c08:	93a080e7          	jalr	-1734(ra) # 8000053e <panic>
    return -1;
    80004c0c:	5a7d                	li	s4,-1
    80004c0e:	bfc1                	j	80004bde <filewrite+0xfa>
      return -1;
    80004c10:	5a7d                	li	s4,-1
    80004c12:	b7f1                	j	80004bde <filewrite+0xfa>
    80004c14:	5a7d                	li	s4,-1
    80004c16:	b7e1                	j	80004bde <filewrite+0xfa>

0000000080004c18 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c18:	7179                	addi	sp,sp,-48
    80004c1a:	f406                	sd	ra,40(sp)
    80004c1c:	f022                	sd	s0,32(sp)
    80004c1e:	ec26                	sd	s1,24(sp)
    80004c20:	e84a                	sd	s2,16(sp)
    80004c22:	e44e                	sd	s3,8(sp)
    80004c24:	e052                	sd	s4,0(sp)
    80004c26:	1800                	addi	s0,sp,48
    80004c28:	84aa                	mv	s1,a0
    80004c2a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c2c:	0005b023          	sd	zero,0(a1)
    80004c30:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c34:	00000097          	auipc	ra,0x0
    80004c38:	bf8080e7          	jalr	-1032(ra) # 8000482c <filealloc>
    80004c3c:	e088                	sd	a0,0(s1)
    80004c3e:	c551                	beqz	a0,80004cca <pipealloc+0xb2>
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	bec080e7          	jalr	-1044(ra) # 8000482c <filealloc>
    80004c48:	00aa3023          	sd	a0,0(s4)
    80004c4c:	c92d                	beqz	a0,80004cbe <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	ea6080e7          	jalr	-346(ra) # 80000af4 <kalloc>
    80004c56:	892a                	mv	s2,a0
    80004c58:	c125                	beqz	a0,80004cb8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c5a:	4985                	li	s3,1
    80004c5c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c60:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c64:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c68:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c6c:	00004597          	auipc	a1,0x4
    80004c70:	a9c58593          	addi	a1,a1,-1380 # 80008708 <syscalls+0x278>
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	ee0080e7          	jalr	-288(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004c7c:	609c                	ld	a5,0(s1)
    80004c7e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c82:	609c                	ld	a5,0(s1)
    80004c84:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c88:	609c                	ld	a5,0(s1)
    80004c8a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c8e:	609c                	ld	a5,0(s1)
    80004c90:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c94:	000a3783          	ld	a5,0(s4)
    80004c98:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c9c:	000a3783          	ld	a5,0(s4)
    80004ca0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ca4:	000a3783          	ld	a5,0(s4)
    80004ca8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004cac:	000a3783          	ld	a5,0(s4)
    80004cb0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cb4:	4501                	li	a0,0
    80004cb6:	a025                	j	80004cde <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004cb8:	6088                	ld	a0,0(s1)
    80004cba:	e501                	bnez	a0,80004cc2 <pipealloc+0xaa>
    80004cbc:	a039                	j	80004cca <pipealloc+0xb2>
    80004cbe:	6088                	ld	a0,0(s1)
    80004cc0:	c51d                	beqz	a0,80004cee <pipealloc+0xd6>
    fileclose(*f0);
    80004cc2:	00000097          	auipc	ra,0x0
    80004cc6:	c26080e7          	jalr	-986(ra) # 800048e8 <fileclose>
  if(*f1)
    80004cca:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cce:	557d                	li	a0,-1
  if(*f1)
    80004cd0:	c799                	beqz	a5,80004cde <pipealloc+0xc6>
    fileclose(*f1);
    80004cd2:	853e                	mv	a0,a5
    80004cd4:	00000097          	auipc	ra,0x0
    80004cd8:	c14080e7          	jalr	-1004(ra) # 800048e8 <fileclose>
  return -1;
    80004cdc:	557d                	li	a0,-1
}
    80004cde:	70a2                	ld	ra,40(sp)
    80004ce0:	7402                	ld	s0,32(sp)
    80004ce2:	64e2                	ld	s1,24(sp)
    80004ce4:	6942                	ld	s2,16(sp)
    80004ce6:	69a2                	ld	s3,8(sp)
    80004ce8:	6a02                	ld	s4,0(sp)
    80004cea:	6145                	addi	sp,sp,48
    80004cec:	8082                	ret
  return -1;
    80004cee:	557d                	li	a0,-1
    80004cf0:	b7fd                	j	80004cde <pipealloc+0xc6>

0000000080004cf2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cf2:	1101                	addi	sp,sp,-32
    80004cf4:	ec06                	sd	ra,24(sp)
    80004cf6:	e822                	sd	s0,16(sp)
    80004cf8:	e426                	sd	s1,8(sp)
    80004cfa:	e04a                	sd	s2,0(sp)
    80004cfc:	1000                	addi	s0,sp,32
    80004cfe:	84aa                	mv	s1,a0
    80004d00:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	ee2080e7          	jalr	-286(ra) # 80000be4 <acquire>
  if(writable){
    80004d0a:	02090d63          	beqz	s2,80004d44 <pipeclose+0x52>
    pi->writeopen = 0;
    80004d0e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d12:	21848513          	addi	a0,s1,536
    80004d16:	ffffe097          	auipc	ra,0xffffe
    80004d1a:	92a080e7          	jalr	-1750(ra) # 80002640 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d1e:	2204b783          	ld	a5,544(s1)
    80004d22:	eb95                	bnez	a5,80004d56 <pipeclose+0x64>
    release(&pi->lock);
    80004d24:	8526                	mv	a0,s1
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	f72080e7          	jalr	-142(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	cc8080e7          	jalr	-824(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80004d38:	60e2                	ld	ra,24(sp)
    80004d3a:	6442                	ld	s0,16(sp)
    80004d3c:	64a2                	ld	s1,8(sp)
    80004d3e:	6902                	ld	s2,0(sp)
    80004d40:	6105                	addi	sp,sp,32
    80004d42:	8082                	ret
    pi->readopen = 0;
    80004d44:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d48:	21c48513          	addi	a0,s1,540
    80004d4c:	ffffe097          	auipc	ra,0xffffe
    80004d50:	8f4080e7          	jalr	-1804(ra) # 80002640 <wakeup>
    80004d54:	b7e9                	j	80004d1e <pipeclose+0x2c>
    release(&pi->lock);
    80004d56:	8526                	mv	a0,s1
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	f40080e7          	jalr	-192(ra) # 80000c98 <release>
}
    80004d60:	bfe1                	j	80004d38 <pipeclose+0x46>

0000000080004d62 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d62:	7159                	addi	sp,sp,-112
    80004d64:	f486                	sd	ra,104(sp)
    80004d66:	f0a2                	sd	s0,96(sp)
    80004d68:	eca6                	sd	s1,88(sp)
    80004d6a:	e8ca                	sd	s2,80(sp)
    80004d6c:	e4ce                	sd	s3,72(sp)
    80004d6e:	e0d2                	sd	s4,64(sp)
    80004d70:	fc56                	sd	s5,56(sp)
    80004d72:	f85a                	sd	s6,48(sp)
    80004d74:	f45e                	sd	s7,40(sp)
    80004d76:	f062                	sd	s8,32(sp)
    80004d78:	ec66                	sd	s9,24(sp)
    80004d7a:	1880                	addi	s0,sp,112
    80004d7c:	84aa                	mv	s1,a0
    80004d7e:	8aae                	mv	s5,a1
    80004d80:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d82:	ffffd097          	auipc	ra,0xffffd
    80004d86:	fe2080e7          	jalr	-30(ra) # 80001d64 <myproc>
    80004d8a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d8c:	8526                	mv	a0,s1
    80004d8e:	ffffc097          	auipc	ra,0xffffc
    80004d92:	e56080e7          	jalr	-426(ra) # 80000be4 <acquire>
  while(i < n){
    80004d96:	0d405163          	blez	s4,80004e58 <pipewrite+0xf6>
    80004d9a:	8ba6                	mv	s7,s1
  int i = 0;
    80004d9c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d9e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004da0:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004da4:	21c48c13          	addi	s8,s1,540
    80004da8:	a08d                	j	80004e0a <pipewrite+0xa8>
      release(&pi->lock);
    80004daa:	8526                	mv	a0,s1
    80004dac:	ffffc097          	auipc	ra,0xffffc
    80004db0:	eec080e7          	jalr	-276(ra) # 80000c98 <release>
      return -1;
    80004db4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004db6:	854a                	mv	a0,s2
    80004db8:	70a6                	ld	ra,104(sp)
    80004dba:	7406                	ld	s0,96(sp)
    80004dbc:	64e6                	ld	s1,88(sp)
    80004dbe:	6946                	ld	s2,80(sp)
    80004dc0:	69a6                	ld	s3,72(sp)
    80004dc2:	6a06                	ld	s4,64(sp)
    80004dc4:	7ae2                	ld	s5,56(sp)
    80004dc6:	7b42                	ld	s6,48(sp)
    80004dc8:	7ba2                	ld	s7,40(sp)
    80004dca:	7c02                	ld	s8,32(sp)
    80004dcc:	6ce2                	ld	s9,24(sp)
    80004dce:	6165                	addi	sp,sp,112
    80004dd0:	8082                	ret
      wakeup(&pi->nread);
    80004dd2:	8566                	mv	a0,s9
    80004dd4:	ffffe097          	auipc	ra,0xffffe
    80004dd8:	86c080e7          	jalr	-1940(ra) # 80002640 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ddc:	85de                	mv	a1,s7
    80004dde:	8562                	mv	a0,s8
    80004de0:	ffffd097          	auipc	ra,0xffffd
    80004de4:	6c2080e7          	jalr	1730(ra) # 800024a2 <sleep>
    80004de8:	a839                	j	80004e06 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004dea:	21c4a783          	lw	a5,540(s1)
    80004dee:	0017871b          	addiw	a4,a5,1
    80004df2:	20e4ae23          	sw	a4,540(s1)
    80004df6:	1ff7f793          	andi	a5,a5,511
    80004dfa:	97a6                	add	a5,a5,s1
    80004dfc:	f9f44703          	lbu	a4,-97(s0)
    80004e00:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e04:	2905                	addiw	s2,s2,1
  while(i < n){
    80004e06:	03495d63          	bge	s2,s4,80004e40 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004e0a:	2204a783          	lw	a5,544(s1)
    80004e0e:	dfd1                	beqz	a5,80004daa <pipewrite+0x48>
    80004e10:	0289a783          	lw	a5,40(s3)
    80004e14:	fbd9                	bnez	a5,80004daa <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e16:	2184a783          	lw	a5,536(s1)
    80004e1a:	21c4a703          	lw	a4,540(s1)
    80004e1e:	2007879b          	addiw	a5,a5,512
    80004e22:	faf708e3          	beq	a4,a5,80004dd2 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e26:	4685                	li	a3,1
    80004e28:	01590633          	add	a2,s2,s5
    80004e2c:	f9f40593          	addi	a1,s0,-97
    80004e30:	0709b503          	ld	a0,112(s3)
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	8ca080e7          	jalr	-1846(ra) # 800016fe <copyin>
    80004e3c:	fb6517e3          	bne	a0,s6,80004dea <pipewrite+0x88>
  wakeup(&pi->nread);
    80004e40:	21848513          	addi	a0,s1,536
    80004e44:	ffffd097          	auipc	ra,0xffffd
    80004e48:	7fc080e7          	jalr	2044(ra) # 80002640 <wakeup>
  release(&pi->lock);
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	ffffc097          	auipc	ra,0xffffc
    80004e52:	e4a080e7          	jalr	-438(ra) # 80000c98 <release>
  return i;
    80004e56:	b785                	j	80004db6 <pipewrite+0x54>
  int i = 0;
    80004e58:	4901                	li	s2,0
    80004e5a:	b7dd                	j	80004e40 <pipewrite+0xde>

0000000080004e5c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e5c:	715d                	addi	sp,sp,-80
    80004e5e:	e486                	sd	ra,72(sp)
    80004e60:	e0a2                	sd	s0,64(sp)
    80004e62:	fc26                	sd	s1,56(sp)
    80004e64:	f84a                	sd	s2,48(sp)
    80004e66:	f44e                	sd	s3,40(sp)
    80004e68:	f052                	sd	s4,32(sp)
    80004e6a:	ec56                	sd	s5,24(sp)
    80004e6c:	e85a                	sd	s6,16(sp)
    80004e6e:	0880                	addi	s0,sp,80
    80004e70:	84aa                	mv	s1,a0
    80004e72:	892e                	mv	s2,a1
    80004e74:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e76:	ffffd097          	auipc	ra,0xffffd
    80004e7a:	eee080e7          	jalr	-274(ra) # 80001d64 <myproc>
    80004e7e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e80:	8b26                	mv	s6,s1
    80004e82:	8526                	mv	a0,s1
    80004e84:	ffffc097          	auipc	ra,0xffffc
    80004e88:	d60080e7          	jalr	-672(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e8c:	2184a703          	lw	a4,536(s1)
    80004e90:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e94:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e98:	02f71463          	bne	a4,a5,80004ec0 <piperead+0x64>
    80004e9c:	2244a783          	lw	a5,548(s1)
    80004ea0:	c385                	beqz	a5,80004ec0 <piperead+0x64>
    if(pr->killed){
    80004ea2:	028a2783          	lw	a5,40(s4)
    80004ea6:	ebc1                	bnez	a5,80004f36 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ea8:	85da                	mv	a1,s6
    80004eaa:	854e                	mv	a0,s3
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	5f6080e7          	jalr	1526(ra) # 800024a2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004eb4:	2184a703          	lw	a4,536(s1)
    80004eb8:	21c4a783          	lw	a5,540(s1)
    80004ebc:	fef700e3          	beq	a4,a5,80004e9c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ec0:	09505263          	blez	s5,80004f44 <piperead+0xe8>
    80004ec4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ec6:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004ec8:	2184a783          	lw	a5,536(s1)
    80004ecc:	21c4a703          	lw	a4,540(s1)
    80004ed0:	02f70d63          	beq	a4,a5,80004f0a <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ed4:	0017871b          	addiw	a4,a5,1
    80004ed8:	20e4ac23          	sw	a4,536(s1)
    80004edc:	1ff7f793          	andi	a5,a5,511
    80004ee0:	97a6                	add	a5,a5,s1
    80004ee2:	0187c783          	lbu	a5,24(a5)
    80004ee6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eea:	4685                	li	a3,1
    80004eec:	fbf40613          	addi	a2,s0,-65
    80004ef0:	85ca                	mv	a1,s2
    80004ef2:	070a3503          	ld	a0,112(s4)
    80004ef6:	ffffc097          	auipc	ra,0xffffc
    80004efa:	77c080e7          	jalr	1916(ra) # 80001672 <copyout>
    80004efe:	01650663          	beq	a0,s6,80004f0a <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f02:	2985                	addiw	s3,s3,1
    80004f04:	0905                	addi	s2,s2,1
    80004f06:	fd3a91e3          	bne	s5,s3,80004ec8 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f0a:	21c48513          	addi	a0,s1,540
    80004f0e:	ffffd097          	auipc	ra,0xffffd
    80004f12:	732080e7          	jalr	1842(ra) # 80002640 <wakeup>
  release(&pi->lock);
    80004f16:	8526                	mv	a0,s1
    80004f18:	ffffc097          	auipc	ra,0xffffc
    80004f1c:	d80080e7          	jalr	-640(ra) # 80000c98 <release>
  return i;
}
    80004f20:	854e                	mv	a0,s3
    80004f22:	60a6                	ld	ra,72(sp)
    80004f24:	6406                	ld	s0,64(sp)
    80004f26:	74e2                	ld	s1,56(sp)
    80004f28:	7942                	ld	s2,48(sp)
    80004f2a:	79a2                	ld	s3,40(sp)
    80004f2c:	7a02                	ld	s4,32(sp)
    80004f2e:	6ae2                	ld	s5,24(sp)
    80004f30:	6b42                	ld	s6,16(sp)
    80004f32:	6161                	addi	sp,sp,80
    80004f34:	8082                	ret
      release(&pi->lock);
    80004f36:	8526                	mv	a0,s1
    80004f38:	ffffc097          	auipc	ra,0xffffc
    80004f3c:	d60080e7          	jalr	-672(ra) # 80000c98 <release>
      return -1;
    80004f40:	59fd                	li	s3,-1
    80004f42:	bff9                	j	80004f20 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f44:	4981                	li	s3,0
    80004f46:	b7d1                	j	80004f0a <piperead+0xae>

0000000080004f48 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004f48:	df010113          	addi	sp,sp,-528
    80004f4c:	20113423          	sd	ra,520(sp)
    80004f50:	20813023          	sd	s0,512(sp)
    80004f54:	ffa6                	sd	s1,504(sp)
    80004f56:	fbca                	sd	s2,496(sp)
    80004f58:	f7ce                	sd	s3,488(sp)
    80004f5a:	f3d2                	sd	s4,480(sp)
    80004f5c:	efd6                	sd	s5,472(sp)
    80004f5e:	ebda                	sd	s6,464(sp)
    80004f60:	e7de                	sd	s7,456(sp)
    80004f62:	e3e2                	sd	s8,448(sp)
    80004f64:	ff66                	sd	s9,440(sp)
    80004f66:	fb6a                	sd	s10,432(sp)
    80004f68:	f76e                	sd	s11,424(sp)
    80004f6a:	0c00                	addi	s0,sp,528
    80004f6c:	84aa                	mv	s1,a0
    80004f6e:	dea43c23          	sd	a0,-520(s0)
    80004f72:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	dee080e7          	jalr	-530(ra) # 80001d64 <myproc>
    80004f7e:	892a                	mv	s2,a0

  begin_op();
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	49c080e7          	jalr	1180(ra) # 8000441c <begin_op>

  if((ip = namei(path)) == 0){
    80004f88:	8526                	mv	a0,s1
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	276080e7          	jalr	630(ra) # 80004200 <namei>
    80004f92:	c92d                	beqz	a0,80005004 <exec+0xbc>
    80004f94:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f96:	fffff097          	auipc	ra,0xfffff
    80004f9a:	ab4080e7          	jalr	-1356(ra) # 80003a4a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f9e:	04000713          	li	a4,64
    80004fa2:	4681                	li	a3,0
    80004fa4:	e5040613          	addi	a2,s0,-432
    80004fa8:	4581                	li	a1,0
    80004faa:	8526                	mv	a0,s1
    80004fac:	fffff097          	auipc	ra,0xfffff
    80004fb0:	d52080e7          	jalr	-686(ra) # 80003cfe <readi>
    80004fb4:	04000793          	li	a5,64
    80004fb8:	00f51a63          	bne	a0,a5,80004fcc <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004fbc:	e5042703          	lw	a4,-432(s0)
    80004fc0:	464c47b7          	lui	a5,0x464c4
    80004fc4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fc8:	04f70463          	beq	a4,a5,80005010 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004fcc:	8526                	mv	a0,s1
    80004fce:	fffff097          	auipc	ra,0xfffff
    80004fd2:	cde080e7          	jalr	-802(ra) # 80003cac <iunlockput>
    end_op();
    80004fd6:	fffff097          	auipc	ra,0xfffff
    80004fda:	4c6080e7          	jalr	1222(ra) # 8000449c <end_op>
  }
  return -1;
    80004fde:	557d                	li	a0,-1
}
    80004fe0:	20813083          	ld	ra,520(sp)
    80004fe4:	20013403          	ld	s0,512(sp)
    80004fe8:	74fe                	ld	s1,504(sp)
    80004fea:	795e                	ld	s2,496(sp)
    80004fec:	79be                	ld	s3,488(sp)
    80004fee:	7a1e                	ld	s4,480(sp)
    80004ff0:	6afe                	ld	s5,472(sp)
    80004ff2:	6b5e                	ld	s6,464(sp)
    80004ff4:	6bbe                	ld	s7,456(sp)
    80004ff6:	6c1e                	ld	s8,448(sp)
    80004ff8:	7cfa                	ld	s9,440(sp)
    80004ffa:	7d5a                	ld	s10,432(sp)
    80004ffc:	7dba                	ld	s11,424(sp)
    80004ffe:	21010113          	addi	sp,sp,528
    80005002:	8082                	ret
    end_op();
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	498080e7          	jalr	1176(ra) # 8000449c <end_op>
    return -1;
    8000500c:	557d                	li	a0,-1
    8000500e:	bfc9                	j	80004fe0 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005010:	854a                	mv	a0,s2
    80005012:	ffffd097          	auipc	ra,0xffffd
    80005016:	e3a080e7          	jalr	-454(ra) # 80001e4c <proc_pagetable>
    8000501a:	8baa                	mv	s7,a0
    8000501c:	d945                	beqz	a0,80004fcc <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000501e:	e7042983          	lw	s3,-400(s0)
    80005022:	e8845783          	lhu	a5,-376(s0)
    80005026:	c7ad                	beqz	a5,80005090 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005028:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000502a:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    8000502c:	6c85                	lui	s9,0x1
    8000502e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005032:	def43823          	sd	a5,-528(s0)
    80005036:	a42d                	j	80005260 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005038:	00003517          	auipc	a0,0x3
    8000503c:	6d850513          	addi	a0,a0,1752 # 80008710 <syscalls+0x280>
    80005040:	ffffb097          	auipc	ra,0xffffb
    80005044:	4fe080e7          	jalr	1278(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005048:	8756                	mv	a4,s5
    8000504a:	012d86bb          	addw	a3,s11,s2
    8000504e:	4581                	li	a1,0
    80005050:	8526                	mv	a0,s1
    80005052:	fffff097          	auipc	ra,0xfffff
    80005056:	cac080e7          	jalr	-852(ra) # 80003cfe <readi>
    8000505a:	2501                	sext.w	a0,a0
    8000505c:	1aaa9963          	bne	s5,a0,8000520e <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80005060:	6785                	lui	a5,0x1
    80005062:	0127893b          	addw	s2,a5,s2
    80005066:	77fd                	lui	a5,0xfffff
    80005068:	01478a3b          	addw	s4,a5,s4
    8000506c:	1f897163          	bgeu	s2,s8,8000524e <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80005070:	02091593          	slli	a1,s2,0x20
    80005074:	9181                	srli	a1,a1,0x20
    80005076:	95ea                	add	a1,a1,s10
    80005078:	855e                	mv	a0,s7
    8000507a:	ffffc097          	auipc	ra,0xffffc
    8000507e:	ff4080e7          	jalr	-12(ra) # 8000106e <walkaddr>
    80005082:	862a                	mv	a2,a0
    if(pa == 0)
    80005084:	d955                	beqz	a0,80005038 <exec+0xf0>
      n = PGSIZE;
    80005086:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005088:	fd9a70e3          	bgeu	s4,s9,80005048 <exec+0x100>
      n = sz - i;
    8000508c:	8ad2                	mv	s5,s4
    8000508e:	bf6d                	j	80005048 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005090:	4901                	li	s2,0
  iunlockput(ip);
    80005092:	8526                	mv	a0,s1
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	c18080e7          	jalr	-1000(ra) # 80003cac <iunlockput>
  end_op();
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	400080e7          	jalr	1024(ra) # 8000449c <end_op>
  p = myproc();
    800050a4:	ffffd097          	auipc	ra,0xffffd
    800050a8:	cc0080e7          	jalr	-832(ra) # 80001d64 <myproc>
    800050ac:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800050ae:	06853d03          	ld	s10,104(a0)
  sz = PGROUNDUP(sz);
    800050b2:	6785                	lui	a5,0x1
    800050b4:	17fd                	addi	a5,a5,-1
    800050b6:	993e                	add	s2,s2,a5
    800050b8:	757d                	lui	a0,0xfffff
    800050ba:	00a977b3          	and	a5,s2,a0
    800050be:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050c2:	6609                	lui	a2,0x2
    800050c4:	963e                	add	a2,a2,a5
    800050c6:	85be                	mv	a1,a5
    800050c8:	855e                	mv	a0,s7
    800050ca:	ffffc097          	auipc	ra,0xffffc
    800050ce:	358080e7          	jalr	856(ra) # 80001422 <uvmalloc>
    800050d2:	8b2a                	mv	s6,a0
  ip = 0;
    800050d4:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050d6:	12050c63          	beqz	a0,8000520e <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050da:	75f9                	lui	a1,0xffffe
    800050dc:	95aa                	add	a1,a1,a0
    800050de:	855e                	mv	a0,s7
    800050e0:	ffffc097          	auipc	ra,0xffffc
    800050e4:	560080e7          	jalr	1376(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    800050e8:	7c7d                	lui	s8,0xfffff
    800050ea:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800050ec:	e0043783          	ld	a5,-512(s0)
    800050f0:	6388                	ld	a0,0(a5)
    800050f2:	c535                	beqz	a0,8000515e <exec+0x216>
    800050f4:	e9040993          	addi	s3,s0,-368
    800050f8:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050fc:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800050fe:	ffffc097          	auipc	ra,0xffffc
    80005102:	d66080e7          	jalr	-666(ra) # 80000e64 <strlen>
    80005106:	2505                	addiw	a0,a0,1
    80005108:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000510c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005110:	13896363          	bltu	s2,s8,80005236 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005114:	e0043d83          	ld	s11,-512(s0)
    80005118:	000dba03          	ld	s4,0(s11)
    8000511c:	8552                	mv	a0,s4
    8000511e:	ffffc097          	auipc	ra,0xffffc
    80005122:	d46080e7          	jalr	-698(ra) # 80000e64 <strlen>
    80005126:	0015069b          	addiw	a3,a0,1
    8000512a:	8652                	mv	a2,s4
    8000512c:	85ca                	mv	a1,s2
    8000512e:	855e                	mv	a0,s7
    80005130:	ffffc097          	auipc	ra,0xffffc
    80005134:	542080e7          	jalr	1346(ra) # 80001672 <copyout>
    80005138:	10054363          	bltz	a0,8000523e <exec+0x2f6>
    ustack[argc] = sp;
    8000513c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005140:	0485                	addi	s1,s1,1
    80005142:	008d8793          	addi	a5,s11,8
    80005146:	e0f43023          	sd	a5,-512(s0)
    8000514a:	008db503          	ld	a0,8(s11)
    8000514e:	c911                	beqz	a0,80005162 <exec+0x21a>
    if(argc >= MAXARG)
    80005150:	09a1                	addi	s3,s3,8
    80005152:	fb3c96e3          	bne	s9,s3,800050fe <exec+0x1b6>
  sz = sz1;
    80005156:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000515a:	4481                	li	s1,0
    8000515c:	a84d                	j	8000520e <exec+0x2c6>
  sp = sz;
    8000515e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005160:	4481                	li	s1,0
  ustack[argc] = 0;
    80005162:	00349793          	slli	a5,s1,0x3
    80005166:	f9040713          	addi	a4,s0,-112
    8000516a:	97ba                	add	a5,a5,a4
    8000516c:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005170:	00148693          	addi	a3,s1,1
    80005174:	068e                	slli	a3,a3,0x3
    80005176:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000517a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000517e:	01897663          	bgeu	s2,s8,8000518a <exec+0x242>
  sz = sz1;
    80005182:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005186:	4481                	li	s1,0
    80005188:	a059                	j	8000520e <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000518a:	e9040613          	addi	a2,s0,-368
    8000518e:	85ca                	mv	a1,s2
    80005190:	855e                	mv	a0,s7
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	4e0080e7          	jalr	1248(ra) # 80001672 <copyout>
    8000519a:	0a054663          	bltz	a0,80005246 <exec+0x2fe>
  p->trapframe->a1 = sp;
    8000519e:	078ab783          	ld	a5,120(s5)
    800051a2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051a6:	df843783          	ld	a5,-520(s0)
    800051aa:	0007c703          	lbu	a4,0(a5)
    800051ae:	cf11                	beqz	a4,800051ca <exec+0x282>
    800051b0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800051b2:	02f00693          	li	a3,47
    800051b6:	a039                	j	800051c4 <exec+0x27c>
      last = s+1;
    800051b8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051bc:	0785                	addi	a5,a5,1
    800051be:	fff7c703          	lbu	a4,-1(a5)
    800051c2:	c701                	beqz	a4,800051ca <exec+0x282>
    if(*s == '/')
    800051c4:	fed71ce3          	bne	a4,a3,800051bc <exec+0x274>
    800051c8:	bfc5                	j	800051b8 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800051ca:	4641                	li	a2,16
    800051cc:	df843583          	ld	a1,-520(s0)
    800051d0:	178a8513          	addi	a0,s5,376
    800051d4:	ffffc097          	auipc	ra,0xffffc
    800051d8:	c5e080e7          	jalr	-930(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    800051dc:	070ab503          	ld	a0,112(s5)
  p->pagetable = pagetable;
    800051e0:	077ab823          	sd	s7,112(s5)
  p->sz = sz;
    800051e4:	076ab423          	sd	s6,104(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051e8:	078ab783          	ld	a5,120(s5)
    800051ec:	e6843703          	ld	a4,-408(s0)
    800051f0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051f2:	078ab783          	ld	a5,120(s5)
    800051f6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051fa:	85ea                	mv	a1,s10
    800051fc:	ffffd097          	auipc	ra,0xffffd
    80005200:	cec080e7          	jalr	-788(ra) # 80001ee8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005204:	0004851b          	sext.w	a0,s1
    80005208:	bbe1                	j	80004fe0 <exec+0x98>
    8000520a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000520e:	e0843583          	ld	a1,-504(s0)
    80005212:	855e                	mv	a0,s7
    80005214:	ffffd097          	auipc	ra,0xffffd
    80005218:	cd4080e7          	jalr	-812(ra) # 80001ee8 <proc_freepagetable>
  if(ip){
    8000521c:	da0498e3          	bnez	s1,80004fcc <exec+0x84>
  return -1;
    80005220:	557d                	li	a0,-1
    80005222:	bb7d                	j	80004fe0 <exec+0x98>
    80005224:	e1243423          	sd	s2,-504(s0)
    80005228:	b7dd                	j	8000520e <exec+0x2c6>
    8000522a:	e1243423          	sd	s2,-504(s0)
    8000522e:	b7c5                	j	8000520e <exec+0x2c6>
    80005230:	e1243423          	sd	s2,-504(s0)
    80005234:	bfe9                	j	8000520e <exec+0x2c6>
  sz = sz1;
    80005236:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000523a:	4481                	li	s1,0
    8000523c:	bfc9                	j	8000520e <exec+0x2c6>
  sz = sz1;
    8000523e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005242:	4481                	li	s1,0
    80005244:	b7e9                	j	8000520e <exec+0x2c6>
  sz = sz1;
    80005246:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000524a:	4481                	li	s1,0
    8000524c:	b7c9                	j	8000520e <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000524e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005252:	2b05                	addiw	s6,s6,1
    80005254:	0389899b          	addiw	s3,s3,56
    80005258:	e8845783          	lhu	a5,-376(s0)
    8000525c:	e2fb5be3          	bge	s6,a5,80005092 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005260:	2981                	sext.w	s3,s3
    80005262:	03800713          	li	a4,56
    80005266:	86ce                	mv	a3,s3
    80005268:	e1840613          	addi	a2,s0,-488
    8000526c:	4581                	li	a1,0
    8000526e:	8526                	mv	a0,s1
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	a8e080e7          	jalr	-1394(ra) # 80003cfe <readi>
    80005278:	03800793          	li	a5,56
    8000527c:	f8f517e3          	bne	a0,a5,8000520a <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005280:	e1842783          	lw	a5,-488(s0)
    80005284:	4705                	li	a4,1
    80005286:	fce796e3          	bne	a5,a4,80005252 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    8000528a:	e4043603          	ld	a2,-448(s0)
    8000528e:	e3843783          	ld	a5,-456(s0)
    80005292:	f8f669e3          	bltu	a2,a5,80005224 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005296:	e2843783          	ld	a5,-472(s0)
    8000529a:	963e                	add	a2,a2,a5
    8000529c:	f8f667e3          	bltu	a2,a5,8000522a <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052a0:	85ca                	mv	a1,s2
    800052a2:	855e                	mv	a0,s7
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	17e080e7          	jalr	382(ra) # 80001422 <uvmalloc>
    800052ac:	e0a43423          	sd	a0,-504(s0)
    800052b0:	d141                	beqz	a0,80005230 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    800052b2:	e2843d03          	ld	s10,-472(s0)
    800052b6:	df043783          	ld	a5,-528(s0)
    800052ba:	00fd77b3          	and	a5,s10,a5
    800052be:	fba1                	bnez	a5,8000520e <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052c0:	e2042d83          	lw	s11,-480(s0)
    800052c4:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052c8:	f80c03e3          	beqz	s8,8000524e <exec+0x306>
    800052cc:	8a62                	mv	s4,s8
    800052ce:	4901                	li	s2,0
    800052d0:	b345                	j	80005070 <exec+0x128>

00000000800052d2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052d2:	7179                	addi	sp,sp,-48
    800052d4:	f406                	sd	ra,40(sp)
    800052d6:	f022                	sd	s0,32(sp)
    800052d8:	ec26                	sd	s1,24(sp)
    800052da:	e84a                	sd	s2,16(sp)
    800052dc:	1800                	addi	s0,sp,48
    800052de:	892e                	mv	s2,a1
    800052e0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800052e2:	fdc40593          	addi	a1,s0,-36
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	bf2080e7          	jalr	-1038(ra) # 80002ed8 <argint>
    800052ee:	04054063          	bltz	a0,8000532e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052f2:	fdc42703          	lw	a4,-36(s0)
    800052f6:	47bd                	li	a5,15
    800052f8:	02e7ed63          	bltu	a5,a4,80005332 <argfd+0x60>
    800052fc:	ffffd097          	auipc	ra,0xffffd
    80005300:	a68080e7          	jalr	-1432(ra) # 80001d64 <myproc>
    80005304:	fdc42703          	lw	a4,-36(s0)
    80005308:	01e70793          	addi	a5,a4,30
    8000530c:	078e                	slli	a5,a5,0x3
    8000530e:	953e                	add	a0,a0,a5
    80005310:	611c                	ld	a5,0(a0)
    80005312:	c395                	beqz	a5,80005336 <argfd+0x64>
    return -1;
  if(pfd)
    80005314:	00090463          	beqz	s2,8000531c <argfd+0x4a>
    *pfd = fd;
    80005318:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000531c:	4501                	li	a0,0
  if(pf)
    8000531e:	c091                	beqz	s1,80005322 <argfd+0x50>
    *pf = f;
    80005320:	e09c                	sd	a5,0(s1)
}
    80005322:	70a2                	ld	ra,40(sp)
    80005324:	7402                	ld	s0,32(sp)
    80005326:	64e2                	ld	s1,24(sp)
    80005328:	6942                	ld	s2,16(sp)
    8000532a:	6145                	addi	sp,sp,48
    8000532c:	8082                	ret
    return -1;
    8000532e:	557d                	li	a0,-1
    80005330:	bfcd                	j	80005322 <argfd+0x50>
    return -1;
    80005332:	557d                	li	a0,-1
    80005334:	b7fd                	j	80005322 <argfd+0x50>
    80005336:	557d                	li	a0,-1
    80005338:	b7ed                	j	80005322 <argfd+0x50>

000000008000533a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000533a:	1101                	addi	sp,sp,-32
    8000533c:	ec06                	sd	ra,24(sp)
    8000533e:	e822                	sd	s0,16(sp)
    80005340:	e426                	sd	s1,8(sp)
    80005342:	1000                	addi	s0,sp,32
    80005344:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005346:	ffffd097          	auipc	ra,0xffffd
    8000534a:	a1e080e7          	jalr	-1506(ra) # 80001d64 <myproc>
    8000534e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005350:	0f050793          	addi	a5,a0,240 # fffffffffffff0f0 <end+0xffffffff7ffd90f0>
    80005354:	4501                	li	a0,0
    80005356:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005358:	6398                	ld	a4,0(a5)
    8000535a:	cb19                	beqz	a4,80005370 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000535c:	2505                	addiw	a0,a0,1
    8000535e:	07a1                	addi	a5,a5,8
    80005360:	fed51ce3          	bne	a0,a3,80005358 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005364:	557d                	li	a0,-1
}
    80005366:	60e2                	ld	ra,24(sp)
    80005368:	6442                	ld	s0,16(sp)
    8000536a:	64a2                	ld	s1,8(sp)
    8000536c:	6105                	addi	sp,sp,32
    8000536e:	8082                	ret
      p->ofile[fd] = f;
    80005370:	01e50793          	addi	a5,a0,30
    80005374:	078e                	slli	a5,a5,0x3
    80005376:	963e                	add	a2,a2,a5
    80005378:	e204                	sd	s1,0(a2)
      return fd;
    8000537a:	b7f5                	j	80005366 <fdalloc+0x2c>

000000008000537c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000537c:	715d                	addi	sp,sp,-80
    8000537e:	e486                	sd	ra,72(sp)
    80005380:	e0a2                	sd	s0,64(sp)
    80005382:	fc26                	sd	s1,56(sp)
    80005384:	f84a                	sd	s2,48(sp)
    80005386:	f44e                	sd	s3,40(sp)
    80005388:	f052                	sd	s4,32(sp)
    8000538a:	ec56                	sd	s5,24(sp)
    8000538c:	0880                	addi	s0,sp,80
    8000538e:	89ae                	mv	s3,a1
    80005390:	8ab2                	mv	s5,a2
    80005392:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005394:	fb040593          	addi	a1,s0,-80
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	e86080e7          	jalr	-378(ra) # 8000421e <nameiparent>
    800053a0:	892a                	mv	s2,a0
    800053a2:	12050f63          	beqz	a0,800054e0 <create+0x164>
    return 0;

  ilock(dp);
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	6a4080e7          	jalr	1700(ra) # 80003a4a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053ae:	4601                	li	a2,0
    800053b0:	fb040593          	addi	a1,s0,-80
    800053b4:	854a                	mv	a0,s2
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	b78080e7          	jalr	-1160(ra) # 80003f2e <dirlookup>
    800053be:	84aa                	mv	s1,a0
    800053c0:	c921                	beqz	a0,80005410 <create+0x94>
    iunlockput(dp);
    800053c2:	854a                	mv	a0,s2
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	8e8080e7          	jalr	-1816(ra) # 80003cac <iunlockput>
    ilock(ip);
    800053cc:	8526                	mv	a0,s1
    800053ce:	ffffe097          	auipc	ra,0xffffe
    800053d2:	67c080e7          	jalr	1660(ra) # 80003a4a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053d6:	2981                	sext.w	s3,s3
    800053d8:	4789                	li	a5,2
    800053da:	02f99463          	bne	s3,a5,80005402 <create+0x86>
    800053de:	0444d783          	lhu	a5,68(s1)
    800053e2:	37f9                	addiw	a5,a5,-2
    800053e4:	17c2                	slli	a5,a5,0x30
    800053e6:	93c1                	srli	a5,a5,0x30
    800053e8:	4705                	li	a4,1
    800053ea:	00f76c63          	bltu	a4,a5,80005402 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800053ee:	8526                	mv	a0,s1
    800053f0:	60a6                	ld	ra,72(sp)
    800053f2:	6406                	ld	s0,64(sp)
    800053f4:	74e2                	ld	s1,56(sp)
    800053f6:	7942                	ld	s2,48(sp)
    800053f8:	79a2                	ld	s3,40(sp)
    800053fa:	7a02                	ld	s4,32(sp)
    800053fc:	6ae2                	ld	s5,24(sp)
    800053fe:	6161                	addi	sp,sp,80
    80005400:	8082                	ret
    iunlockput(ip);
    80005402:	8526                	mv	a0,s1
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	8a8080e7          	jalr	-1880(ra) # 80003cac <iunlockput>
    return 0;
    8000540c:	4481                	li	s1,0
    8000540e:	b7c5                	j	800053ee <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005410:	85ce                	mv	a1,s3
    80005412:	00092503          	lw	a0,0(s2)
    80005416:	ffffe097          	auipc	ra,0xffffe
    8000541a:	49c080e7          	jalr	1180(ra) # 800038b2 <ialloc>
    8000541e:	84aa                	mv	s1,a0
    80005420:	c529                	beqz	a0,8000546a <create+0xee>
  ilock(ip);
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	628080e7          	jalr	1576(ra) # 80003a4a <ilock>
  ip->major = major;
    8000542a:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000542e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005432:	4785                	li	a5,1
    80005434:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005438:	8526                	mv	a0,s1
    8000543a:	ffffe097          	auipc	ra,0xffffe
    8000543e:	546080e7          	jalr	1350(ra) # 80003980 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005442:	2981                	sext.w	s3,s3
    80005444:	4785                	li	a5,1
    80005446:	02f98a63          	beq	s3,a5,8000547a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000544a:	40d0                	lw	a2,4(s1)
    8000544c:	fb040593          	addi	a1,s0,-80
    80005450:	854a                	mv	a0,s2
    80005452:	fffff097          	auipc	ra,0xfffff
    80005456:	cec080e7          	jalr	-788(ra) # 8000413e <dirlink>
    8000545a:	06054b63          	bltz	a0,800054d0 <create+0x154>
  iunlockput(dp);
    8000545e:	854a                	mv	a0,s2
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	84c080e7          	jalr	-1972(ra) # 80003cac <iunlockput>
  return ip;
    80005468:	b759                	j	800053ee <create+0x72>
    panic("create: ialloc");
    8000546a:	00003517          	auipc	a0,0x3
    8000546e:	2c650513          	addi	a0,a0,710 # 80008730 <syscalls+0x2a0>
    80005472:	ffffb097          	auipc	ra,0xffffb
    80005476:	0cc080e7          	jalr	204(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    8000547a:	04a95783          	lhu	a5,74(s2)
    8000547e:	2785                	addiw	a5,a5,1
    80005480:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005484:	854a                	mv	a0,s2
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	4fa080e7          	jalr	1274(ra) # 80003980 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000548e:	40d0                	lw	a2,4(s1)
    80005490:	00003597          	auipc	a1,0x3
    80005494:	2b058593          	addi	a1,a1,688 # 80008740 <syscalls+0x2b0>
    80005498:	8526                	mv	a0,s1
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	ca4080e7          	jalr	-860(ra) # 8000413e <dirlink>
    800054a2:	00054f63          	bltz	a0,800054c0 <create+0x144>
    800054a6:	00492603          	lw	a2,4(s2)
    800054aa:	00003597          	auipc	a1,0x3
    800054ae:	29e58593          	addi	a1,a1,670 # 80008748 <syscalls+0x2b8>
    800054b2:	8526                	mv	a0,s1
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	c8a080e7          	jalr	-886(ra) # 8000413e <dirlink>
    800054bc:	f80557e3          	bgez	a0,8000544a <create+0xce>
      panic("create dots");
    800054c0:	00003517          	auipc	a0,0x3
    800054c4:	29050513          	addi	a0,a0,656 # 80008750 <syscalls+0x2c0>
    800054c8:	ffffb097          	auipc	ra,0xffffb
    800054cc:	076080e7          	jalr	118(ra) # 8000053e <panic>
    panic("create: dirlink");
    800054d0:	00003517          	auipc	a0,0x3
    800054d4:	29050513          	addi	a0,a0,656 # 80008760 <syscalls+0x2d0>
    800054d8:	ffffb097          	auipc	ra,0xffffb
    800054dc:	066080e7          	jalr	102(ra) # 8000053e <panic>
    return 0;
    800054e0:	84aa                	mv	s1,a0
    800054e2:	b731                	j	800053ee <create+0x72>

00000000800054e4 <sys_dup>:
{
    800054e4:	7179                	addi	sp,sp,-48
    800054e6:	f406                	sd	ra,40(sp)
    800054e8:	f022                	sd	s0,32(sp)
    800054ea:	ec26                	sd	s1,24(sp)
    800054ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054ee:	fd840613          	addi	a2,s0,-40
    800054f2:	4581                	li	a1,0
    800054f4:	4501                	li	a0,0
    800054f6:	00000097          	auipc	ra,0x0
    800054fa:	ddc080e7          	jalr	-548(ra) # 800052d2 <argfd>
    return -1;
    800054fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005500:	02054363          	bltz	a0,80005526 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005504:	fd843503          	ld	a0,-40(s0)
    80005508:	00000097          	auipc	ra,0x0
    8000550c:	e32080e7          	jalr	-462(ra) # 8000533a <fdalloc>
    80005510:	84aa                	mv	s1,a0
    return -1;
    80005512:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005514:	00054963          	bltz	a0,80005526 <sys_dup+0x42>
  filedup(f);
    80005518:	fd843503          	ld	a0,-40(s0)
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	37a080e7          	jalr	890(ra) # 80004896 <filedup>
  return fd;
    80005524:	87a6                	mv	a5,s1
}
    80005526:	853e                	mv	a0,a5
    80005528:	70a2                	ld	ra,40(sp)
    8000552a:	7402                	ld	s0,32(sp)
    8000552c:	64e2                	ld	s1,24(sp)
    8000552e:	6145                	addi	sp,sp,48
    80005530:	8082                	ret

0000000080005532 <sys_read>:
{
    80005532:	7179                	addi	sp,sp,-48
    80005534:	f406                	sd	ra,40(sp)
    80005536:	f022                	sd	s0,32(sp)
    80005538:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000553a:	fe840613          	addi	a2,s0,-24
    8000553e:	4581                	li	a1,0
    80005540:	4501                	li	a0,0
    80005542:	00000097          	auipc	ra,0x0
    80005546:	d90080e7          	jalr	-624(ra) # 800052d2 <argfd>
    return -1;
    8000554a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000554c:	04054163          	bltz	a0,8000558e <sys_read+0x5c>
    80005550:	fe440593          	addi	a1,s0,-28
    80005554:	4509                	li	a0,2
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	982080e7          	jalr	-1662(ra) # 80002ed8 <argint>
    return -1;
    8000555e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005560:	02054763          	bltz	a0,8000558e <sys_read+0x5c>
    80005564:	fd840593          	addi	a1,s0,-40
    80005568:	4505                	li	a0,1
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	990080e7          	jalr	-1648(ra) # 80002efa <argaddr>
    return -1;
    80005572:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005574:	00054d63          	bltz	a0,8000558e <sys_read+0x5c>
  return fileread(f, p, n);
    80005578:	fe442603          	lw	a2,-28(s0)
    8000557c:	fd843583          	ld	a1,-40(s0)
    80005580:	fe843503          	ld	a0,-24(s0)
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	49e080e7          	jalr	1182(ra) # 80004a22 <fileread>
    8000558c:	87aa                	mv	a5,a0
}
    8000558e:	853e                	mv	a0,a5
    80005590:	70a2                	ld	ra,40(sp)
    80005592:	7402                	ld	s0,32(sp)
    80005594:	6145                	addi	sp,sp,48
    80005596:	8082                	ret

0000000080005598 <sys_write>:
{
    80005598:	7179                	addi	sp,sp,-48
    8000559a:	f406                	sd	ra,40(sp)
    8000559c:	f022                	sd	s0,32(sp)
    8000559e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055a0:	fe840613          	addi	a2,s0,-24
    800055a4:	4581                	li	a1,0
    800055a6:	4501                	li	a0,0
    800055a8:	00000097          	auipc	ra,0x0
    800055ac:	d2a080e7          	jalr	-726(ra) # 800052d2 <argfd>
    return -1;
    800055b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055b2:	04054163          	bltz	a0,800055f4 <sys_write+0x5c>
    800055b6:	fe440593          	addi	a1,s0,-28
    800055ba:	4509                	li	a0,2
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	91c080e7          	jalr	-1764(ra) # 80002ed8 <argint>
    return -1;
    800055c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055c6:	02054763          	bltz	a0,800055f4 <sys_write+0x5c>
    800055ca:	fd840593          	addi	a1,s0,-40
    800055ce:	4505                	li	a0,1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	92a080e7          	jalr	-1750(ra) # 80002efa <argaddr>
    return -1;
    800055d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055da:	00054d63          	bltz	a0,800055f4 <sys_write+0x5c>
  return filewrite(f, p, n);
    800055de:	fe442603          	lw	a2,-28(s0)
    800055e2:	fd843583          	ld	a1,-40(s0)
    800055e6:	fe843503          	ld	a0,-24(s0)
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	4fa080e7          	jalr	1274(ra) # 80004ae4 <filewrite>
    800055f2:	87aa                	mv	a5,a0
}
    800055f4:	853e                	mv	a0,a5
    800055f6:	70a2                	ld	ra,40(sp)
    800055f8:	7402                	ld	s0,32(sp)
    800055fa:	6145                	addi	sp,sp,48
    800055fc:	8082                	ret

00000000800055fe <sys_close>:
{
    800055fe:	1101                	addi	sp,sp,-32
    80005600:	ec06                	sd	ra,24(sp)
    80005602:	e822                	sd	s0,16(sp)
    80005604:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005606:	fe040613          	addi	a2,s0,-32
    8000560a:	fec40593          	addi	a1,s0,-20
    8000560e:	4501                	li	a0,0
    80005610:	00000097          	auipc	ra,0x0
    80005614:	cc2080e7          	jalr	-830(ra) # 800052d2 <argfd>
    return -1;
    80005618:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000561a:	02054463          	bltz	a0,80005642 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000561e:	ffffc097          	auipc	ra,0xffffc
    80005622:	746080e7          	jalr	1862(ra) # 80001d64 <myproc>
    80005626:	fec42783          	lw	a5,-20(s0)
    8000562a:	07f9                	addi	a5,a5,30
    8000562c:	078e                	slli	a5,a5,0x3
    8000562e:	97aa                	add	a5,a5,a0
    80005630:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005634:	fe043503          	ld	a0,-32(s0)
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	2b0080e7          	jalr	688(ra) # 800048e8 <fileclose>
  return 0;
    80005640:	4781                	li	a5,0
}
    80005642:	853e                	mv	a0,a5
    80005644:	60e2                	ld	ra,24(sp)
    80005646:	6442                	ld	s0,16(sp)
    80005648:	6105                	addi	sp,sp,32
    8000564a:	8082                	ret

000000008000564c <sys_fstat>:
{
    8000564c:	1101                	addi	sp,sp,-32
    8000564e:	ec06                	sd	ra,24(sp)
    80005650:	e822                	sd	s0,16(sp)
    80005652:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005654:	fe840613          	addi	a2,s0,-24
    80005658:	4581                	li	a1,0
    8000565a:	4501                	li	a0,0
    8000565c:	00000097          	auipc	ra,0x0
    80005660:	c76080e7          	jalr	-906(ra) # 800052d2 <argfd>
    return -1;
    80005664:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005666:	02054563          	bltz	a0,80005690 <sys_fstat+0x44>
    8000566a:	fe040593          	addi	a1,s0,-32
    8000566e:	4505                	li	a0,1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	88a080e7          	jalr	-1910(ra) # 80002efa <argaddr>
    return -1;
    80005678:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000567a:	00054b63          	bltz	a0,80005690 <sys_fstat+0x44>
  return filestat(f, st);
    8000567e:	fe043583          	ld	a1,-32(s0)
    80005682:	fe843503          	ld	a0,-24(s0)
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	32a080e7          	jalr	810(ra) # 800049b0 <filestat>
    8000568e:	87aa                	mv	a5,a0
}
    80005690:	853e                	mv	a0,a5
    80005692:	60e2                	ld	ra,24(sp)
    80005694:	6442                	ld	s0,16(sp)
    80005696:	6105                	addi	sp,sp,32
    80005698:	8082                	ret

000000008000569a <sys_link>:
{
    8000569a:	7169                	addi	sp,sp,-304
    8000569c:	f606                	sd	ra,296(sp)
    8000569e:	f222                	sd	s0,288(sp)
    800056a0:	ee26                	sd	s1,280(sp)
    800056a2:	ea4a                	sd	s2,272(sp)
    800056a4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a6:	08000613          	li	a2,128
    800056aa:	ed040593          	addi	a1,s0,-304
    800056ae:	4501                	li	a0,0
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	86c080e7          	jalr	-1940(ra) # 80002f1c <argstr>
    return -1;
    800056b8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ba:	10054e63          	bltz	a0,800057d6 <sys_link+0x13c>
    800056be:	08000613          	li	a2,128
    800056c2:	f5040593          	addi	a1,s0,-176
    800056c6:	4505                	li	a0,1
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	854080e7          	jalr	-1964(ra) # 80002f1c <argstr>
    return -1;
    800056d0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056d2:	10054263          	bltz	a0,800057d6 <sys_link+0x13c>
  begin_op();
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	d46080e7          	jalr	-698(ra) # 8000441c <begin_op>
  if((ip = namei(old)) == 0){
    800056de:	ed040513          	addi	a0,s0,-304
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	b1e080e7          	jalr	-1250(ra) # 80004200 <namei>
    800056ea:	84aa                	mv	s1,a0
    800056ec:	c551                	beqz	a0,80005778 <sys_link+0xde>
  ilock(ip);
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	35c080e7          	jalr	860(ra) # 80003a4a <ilock>
  if(ip->type == T_DIR){
    800056f6:	04449703          	lh	a4,68(s1)
    800056fa:	4785                	li	a5,1
    800056fc:	08f70463          	beq	a4,a5,80005784 <sys_link+0xea>
  ip->nlink++;
    80005700:	04a4d783          	lhu	a5,74(s1)
    80005704:	2785                	addiw	a5,a5,1
    80005706:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	274080e7          	jalr	628(ra) # 80003980 <iupdate>
  iunlock(ip);
    80005714:	8526                	mv	a0,s1
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	3f6080e7          	jalr	1014(ra) # 80003b0c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000571e:	fd040593          	addi	a1,s0,-48
    80005722:	f5040513          	addi	a0,s0,-176
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	af8080e7          	jalr	-1288(ra) # 8000421e <nameiparent>
    8000572e:	892a                	mv	s2,a0
    80005730:	c935                	beqz	a0,800057a4 <sys_link+0x10a>
  ilock(dp);
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	318080e7          	jalr	792(ra) # 80003a4a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000573a:	00092703          	lw	a4,0(s2)
    8000573e:	409c                	lw	a5,0(s1)
    80005740:	04f71d63          	bne	a4,a5,8000579a <sys_link+0x100>
    80005744:	40d0                	lw	a2,4(s1)
    80005746:	fd040593          	addi	a1,s0,-48
    8000574a:	854a                	mv	a0,s2
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	9f2080e7          	jalr	-1550(ra) # 8000413e <dirlink>
    80005754:	04054363          	bltz	a0,8000579a <sys_link+0x100>
  iunlockput(dp);
    80005758:	854a                	mv	a0,s2
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	552080e7          	jalr	1362(ra) # 80003cac <iunlockput>
  iput(ip);
    80005762:	8526                	mv	a0,s1
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	4a0080e7          	jalr	1184(ra) # 80003c04 <iput>
  end_op();
    8000576c:	fffff097          	auipc	ra,0xfffff
    80005770:	d30080e7          	jalr	-720(ra) # 8000449c <end_op>
  return 0;
    80005774:	4781                	li	a5,0
    80005776:	a085                	j	800057d6 <sys_link+0x13c>
    end_op();
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	d24080e7          	jalr	-732(ra) # 8000449c <end_op>
    return -1;
    80005780:	57fd                	li	a5,-1
    80005782:	a891                	j	800057d6 <sys_link+0x13c>
    iunlockput(ip);
    80005784:	8526                	mv	a0,s1
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	526080e7          	jalr	1318(ra) # 80003cac <iunlockput>
    end_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	d0e080e7          	jalr	-754(ra) # 8000449c <end_op>
    return -1;
    80005796:	57fd                	li	a5,-1
    80005798:	a83d                	j	800057d6 <sys_link+0x13c>
    iunlockput(dp);
    8000579a:	854a                	mv	a0,s2
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	510080e7          	jalr	1296(ra) # 80003cac <iunlockput>
  ilock(ip);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	2a4080e7          	jalr	676(ra) # 80003a4a <ilock>
  ip->nlink--;
    800057ae:	04a4d783          	lhu	a5,74(s1)
    800057b2:	37fd                	addiw	a5,a5,-1
    800057b4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	1c6080e7          	jalr	454(ra) # 80003980 <iupdate>
  iunlockput(ip);
    800057c2:	8526                	mv	a0,s1
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	4e8080e7          	jalr	1256(ra) # 80003cac <iunlockput>
  end_op();
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	cd0080e7          	jalr	-816(ra) # 8000449c <end_op>
  return -1;
    800057d4:	57fd                	li	a5,-1
}
    800057d6:	853e                	mv	a0,a5
    800057d8:	70b2                	ld	ra,296(sp)
    800057da:	7412                	ld	s0,288(sp)
    800057dc:	64f2                	ld	s1,280(sp)
    800057de:	6952                	ld	s2,272(sp)
    800057e0:	6155                	addi	sp,sp,304
    800057e2:	8082                	ret

00000000800057e4 <sys_unlink>:
{
    800057e4:	7151                	addi	sp,sp,-240
    800057e6:	f586                	sd	ra,232(sp)
    800057e8:	f1a2                	sd	s0,224(sp)
    800057ea:	eda6                	sd	s1,216(sp)
    800057ec:	e9ca                	sd	s2,208(sp)
    800057ee:	e5ce                	sd	s3,200(sp)
    800057f0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057f2:	08000613          	li	a2,128
    800057f6:	f3040593          	addi	a1,s0,-208
    800057fa:	4501                	li	a0,0
    800057fc:	ffffd097          	auipc	ra,0xffffd
    80005800:	720080e7          	jalr	1824(ra) # 80002f1c <argstr>
    80005804:	18054163          	bltz	a0,80005986 <sys_unlink+0x1a2>
  begin_op();
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	c14080e7          	jalr	-1004(ra) # 8000441c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005810:	fb040593          	addi	a1,s0,-80
    80005814:	f3040513          	addi	a0,s0,-208
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	a06080e7          	jalr	-1530(ra) # 8000421e <nameiparent>
    80005820:	84aa                	mv	s1,a0
    80005822:	c979                	beqz	a0,800058f8 <sys_unlink+0x114>
  ilock(dp);
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	226080e7          	jalr	550(ra) # 80003a4a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000582c:	00003597          	auipc	a1,0x3
    80005830:	f1458593          	addi	a1,a1,-236 # 80008740 <syscalls+0x2b0>
    80005834:	fb040513          	addi	a0,s0,-80
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	6dc080e7          	jalr	1756(ra) # 80003f14 <namecmp>
    80005840:	14050a63          	beqz	a0,80005994 <sys_unlink+0x1b0>
    80005844:	00003597          	auipc	a1,0x3
    80005848:	f0458593          	addi	a1,a1,-252 # 80008748 <syscalls+0x2b8>
    8000584c:	fb040513          	addi	a0,s0,-80
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	6c4080e7          	jalr	1732(ra) # 80003f14 <namecmp>
    80005858:	12050e63          	beqz	a0,80005994 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000585c:	f2c40613          	addi	a2,s0,-212
    80005860:	fb040593          	addi	a1,s0,-80
    80005864:	8526                	mv	a0,s1
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	6c8080e7          	jalr	1736(ra) # 80003f2e <dirlookup>
    8000586e:	892a                	mv	s2,a0
    80005870:	12050263          	beqz	a0,80005994 <sys_unlink+0x1b0>
  ilock(ip);
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	1d6080e7          	jalr	470(ra) # 80003a4a <ilock>
  if(ip->nlink < 1)
    8000587c:	04a91783          	lh	a5,74(s2)
    80005880:	08f05263          	blez	a5,80005904 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005884:	04491703          	lh	a4,68(s2)
    80005888:	4785                	li	a5,1
    8000588a:	08f70563          	beq	a4,a5,80005914 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000588e:	4641                	li	a2,16
    80005890:	4581                	li	a1,0
    80005892:	fc040513          	addi	a0,s0,-64
    80005896:	ffffb097          	auipc	ra,0xffffb
    8000589a:	44a080e7          	jalr	1098(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000589e:	4741                	li	a4,16
    800058a0:	f2c42683          	lw	a3,-212(s0)
    800058a4:	fc040613          	addi	a2,s0,-64
    800058a8:	4581                	li	a1,0
    800058aa:	8526                	mv	a0,s1
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	54a080e7          	jalr	1354(ra) # 80003df6 <writei>
    800058b4:	47c1                	li	a5,16
    800058b6:	0af51563          	bne	a0,a5,80005960 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058ba:	04491703          	lh	a4,68(s2)
    800058be:	4785                	li	a5,1
    800058c0:	0af70863          	beq	a4,a5,80005970 <sys_unlink+0x18c>
  iunlockput(dp);
    800058c4:	8526                	mv	a0,s1
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	3e6080e7          	jalr	998(ra) # 80003cac <iunlockput>
  ip->nlink--;
    800058ce:	04a95783          	lhu	a5,74(s2)
    800058d2:	37fd                	addiw	a5,a5,-1
    800058d4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058d8:	854a                	mv	a0,s2
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	0a6080e7          	jalr	166(ra) # 80003980 <iupdate>
  iunlockput(ip);
    800058e2:	854a                	mv	a0,s2
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	3c8080e7          	jalr	968(ra) # 80003cac <iunlockput>
  end_op();
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	bb0080e7          	jalr	-1104(ra) # 8000449c <end_op>
  return 0;
    800058f4:	4501                	li	a0,0
    800058f6:	a84d                	j	800059a8 <sys_unlink+0x1c4>
    end_op();
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	ba4080e7          	jalr	-1116(ra) # 8000449c <end_op>
    return -1;
    80005900:	557d                	li	a0,-1
    80005902:	a05d                	j	800059a8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005904:	00003517          	auipc	a0,0x3
    80005908:	e6c50513          	addi	a0,a0,-404 # 80008770 <syscalls+0x2e0>
    8000590c:	ffffb097          	auipc	ra,0xffffb
    80005910:	c32080e7          	jalr	-974(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005914:	04c92703          	lw	a4,76(s2)
    80005918:	02000793          	li	a5,32
    8000591c:	f6e7f9e3          	bgeu	a5,a4,8000588e <sys_unlink+0xaa>
    80005920:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005924:	4741                	li	a4,16
    80005926:	86ce                	mv	a3,s3
    80005928:	f1840613          	addi	a2,s0,-232
    8000592c:	4581                	li	a1,0
    8000592e:	854a                	mv	a0,s2
    80005930:	ffffe097          	auipc	ra,0xffffe
    80005934:	3ce080e7          	jalr	974(ra) # 80003cfe <readi>
    80005938:	47c1                	li	a5,16
    8000593a:	00f51b63          	bne	a0,a5,80005950 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000593e:	f1845783          	lhu	a5,-232(s0)
    80005942:	e7a1                	bnez	a5,8000598a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005944:	29c1                	addiw	s3,s3,16
    80005946:	04c92783          	lw	a5,76(s2)
    8000594a:	fcf9ede3          	bltu	s3,a5,80005924 <sys_unlink+0x140>
    8000594e:	b781                	j	8000588e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005950:	00003517          	auipc	a0,0x3
    80005954:	e3850513          	addi	a0,a0,-456 # 80008788 <syscalls+0x2f8>
    80005958:	ffffb097          	auipc	ra,0xffffb
    8000595c:	be6080e7          	jalr	-1050(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005960:	00003517          	auipc	a0,0x3
    80005964:	e4050513          	addi	a0,a0,-448 # 800087a0 <syscalls+0x310>
    80005968:	ffffb097          	auipc	ra,0xffffb
    8000596c:	bd6080e7          	jalr	-1066(ra) # 8000053e <panic>
    dp->nlink--;
    80005970:	04a4d783          	lhu	a5,74(s1)
    80005974:	37fd                	addiw	a5,a5,-1
    80005976:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000597a:	8526                	mv	a0,s1
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	004080e7          	jalr	4(ra) # 80003980 <iupdate>
    80005984:	b781                	j	800058c4 <sys_unlink+0xe0>
    return -1;
    80005986:	557d                	li	a0,-1
    80005988:	a005                	j	800059a8 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000598a:	854a                	mv	a0,s2
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	320080e7          	jalr	800(ra) # 80003cac <iunlockput>
  iunlockput(dp);
    80005994:	8526                	mv	a0,s1
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	316080e7          	jalr	790(ra) # 80003cac <iunlockput>
  end_op();
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	afe080e7          	jalr	-1282(ra) # 8000449c <end_op>
  return -1;
    800059a6:	557d                	li	a0,-1
}
    800059a8:	70ae                	ld	ra,232(sp)
    800059aa:	740e                	ld	s0,224(sp)
    800059ac:	64ee                	ld	s1,216(sp)
    800059ae:	694e                	ld	s2,208(sp)
    800059b0:	69ae                	ld	s3,200(sp)
    800059b2:	616d                	addi	sp,sp,240
    800059b4:	8082                	ret

00000000800059b6 <sys_open>:

uint64
sys_open(void)
{
    800059b6:	7131                	addi	sp,sp,-192
    800059b8:	fd06                	sd	ra,184(sp)
    800059ba:	f922                	sd	s0,176(sp)
    800059bc:	f526                	sd	s1,168(sp)
    800059be:	f14a                	sd	s2,160(sp)
    800059c0:	ed4e                	sd	s3,152(sp)
    800059c2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059c4:	08000613          	li	a2,128
    800059c8:	f5040593          	addi	a1,s0,-176
    800059cc:	4501                	li	a0,0
    800059ce:	ffffd097          	auipc	ra,0xffffd
    800059d2:	54e080e7          	jalr	1358(ra) # 80002f1c <argstr>
    return -1;
    800059d6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059d8:	0c054163          	bltz	a0,80005a9a <sys_open+0xe4>
    800059dc:	f4c40593          	addi	a1,s0,-180
    800059e0:	4505                	li	a0,1
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	4f6080e7          	jalr	1270(ra) # 80002ed8 <argint>
    800059ea:	0a054863          	bltz	a0,80005a9a <sys_open+0xe4>

  begin_op();
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	a2e080e7          	jalr	-1490(ra) # 8000441c <begin_op>

  if(omode & O_CREATE){
    800059f6:	f4c42783          	lw	a5,-180(s0)
    800059fa:	2007f793          	andi	a5,a5,512
    800059fe:	cbdd                	beqz	a5,80005ab4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a00:	4681                	li	a3,0
    80005a02:	4601                	li	a2,0
    80005a04:	4589                	li	a1,2
    80005a06:	f5040513          	addi	a0,s0,-176
    80005a0a:	00000097          	auipc	ra,0x0
    80005a0e:	972080e7          	jalr	-1678(ra) # 8000537c <create>
    80005a12:	892a                	mv	s2,a0
    if(ip == 0){
    80005a14:	c959                	beqz	a0,80005aaa <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a16:	04491703          	lh	a4,68(s2)
    80005a1a:	478d                	li	a5,3
    80005a1c:	00f71763          	bne	a4,a5,80005a2a <sys_open+0x74>
    80005a20:	04695703          	lhu	a4,70(s2)
    80005a24:	47a5                	li	a5,9
    80005a26:	0ce7ec63          	bltu	a5,a4,80005afe <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a2a:	fffff097          	auipc	ra,0xfffff
    80005a2e:	e02080e7          	jalr	-510(ra) # 8000482c <filealloc>
    80005a32:	89aa                	mv	s3,a0
    80005a34:	10050263          	beqz	a0,80005b38 <sys_open+0x182>
    80005a38:	00000097          	auipc	ra,0x0
    80005a3c:	902080e7          	jalr	-1790(ra) # 8000533a <fdalloc>
    80005a40:	84aa                	mv	s1,a0
    80005a42:	0e054663          	bltz	a0,80005b2e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a46:	04491703          	lh	a4,68(s2)
    80005a4a:	478d                	li	a5,3
    80005a4c:	0cf70463          	beq	a4,a5,80005b14 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a50:	4789                	li	a5,2
    80005a52:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a56:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a5a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a5e:	f4c42783          	lw	a5,-180(s0)
    80005a62:	0017c713          	xori	a4,a5,1
    80005a66:	8b05                	andi	a4,a4,1
    80005a68:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a6c:	0037f713          	andi	a4,a5,3
    80005a70:	00e03733          	snez	a4,a4
    80005a74:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a78:	4007f793          	andi	a5,a5,1024
    80005a7c:	c791                	beqz	a5,80005a88 <sys_open+0xd2>
    80005a7e:	04491703          	lh	a4,68(s2)
    80005a82:	4789                	li	a5,2
    80005a84:	08f70f63          	beq	a4,a5,80005b22 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a88:	854a                	mv	a0,s2
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	082080e7          	jalr	130(ra) # 80003b0c <iunlock>
  end_op();
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	a0a080e7          	jalr	-1526(ra) # 8000449c <end_op>

  return fd;
}
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	70ea                	ld	ra,184(sp)
    80005a9e:	744a                	ld	s0,176(sp)
    80005aa0:	74aa                	ld	s1,168(sp)
    80005aa2:	790a                	ld	s2,160(sp)
    80005aa4:	69ea                	ld	s3,152(sp)
    80005aa6:	6129                	addi	sp,sp,192
    80005aa8:	8082                	ret
      end_op();
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	9f2080e7          	jalr	-1550(ra) # 8000449c <end_op>
      return -1;
    80005ab2:	b7e5                	j	80005a9a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ab4:	f5040513          	addi	a0,s0,-176
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	748080e7          	jalr	1864(ra) # 80004200 <namei>
    80005ac0:	892a                	mv	s2,a0
    80005ac2:	c905                	beqz	a0,80005af2 <sys_open+0x13c>
    ilock(ip);
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	f86080e7          	jalr	-122(ra) # 80003a4a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005acc:	04491703          	lh	a4,68(s2)
    80005ad0:	4785                	li	a5,1
    80005ad2:	f4f712e3          	bne	a4,a5,80005a16 <sys_open+0x60>
    80005ad6:	f4c42783          	lw	a5,-180(s0)
    80005ada:	dba1                	beqz	a5,80005a2a <sys_open+0x74>
      iunlockput(ip);
    80005adc:	854a                	mv	a0,s2
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	1ce080e7          	jalr	462(ra) # 80003cac <iunlockput>
      end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	9b6080e7          	jalr	-1610(ra) # 8000449c <end_op>
      return -1;
    80005aee:	54fd                	li	s1,-1
    80005af0:	b76d                	j	80005a9a <sys_open+0xe4>
      end_op();
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	9aa080e7          	jalr	-1622(ra) # 8000449c <end_op>
      return -1;
    80005afa:	54fd                	li	s1,-1
    80005afc:	bf79                	j	80005a9a <sys_open+0xe4>
    iunlockput(ip);
    80005afe:	854a                	mv	a0,s2
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	1ac080e7          	jalr	428(ra) # 80003cac <iunlockput>
    end_op();
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	994080e7          	jalr	-1644(ra) # 8000449c <end_op>
    return -1;
    80005b10:	54fd                	li	s1,-1
    80005b12:	b761                	j	80005a9a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b14:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b18:	04691783          	lh	a5,70(s2)
    80005b1c:	02f99223          	sh	a5,36(s3)
    80005b20:	bf2d                	j	80005a5a <sys_open+0xa4>
    itrunc(ip);
    80005b22:	854a                	mv	a0,s2
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	034080e7          	jalr	52(ra) # 80003b58 <itrunc>
    80005b2c:	bfb1                	j	80005a88 <sys_open+0xd2>
      fileclose(f);
    80005b2e:	854e                	mv	a0,s3
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	db8080e7          	jalr	-584(ra) # 800048e8 <fileclose>
    iunlockput(ip);
    80005b38:	854a                	mv	a0,s2
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	172080e7          	jalr	370(ra) # 80003cac <iunlockput>
    end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	95a080e7          	jalr	-1702(ra) # 8000449c <end_op>
    return -1;
    80005b4a:	54fd                	li	s1,-1
    80005b4c:	b7b9                	j	80005a9a <sys_open+0xe4>

0000000080005b4e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b4e:	7175                	addi	sp,sp,-144
    80005b50:	e506                	sd	ra,136(sp)
    80005b52:	e122                	sd	s0,128(sp)
    80005b54:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	8c6080e7          	jalr	-1850(ra) # 8000441c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b5e:	08000613          	li	a2,128
    80005b62:	f7040593          	addi	a1,s0,-144
    80005b66:	4501                	li	a0,0
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	3b4080e7          	jalr	948(ra) # 80002f1c <argstr>
    80005b70:	02054963          	bltz	a0,80005ba2 <sys_mkdir+0x54>
    80005b74:	4681                	li	a3,0
    80005b76:	4601                	li	a2,0
    80005b78:	4585                	li	a1,1
    80005b7a:	f7040513          	addi	a0,s0,-144
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	7fe080e7          	jalr	2046(ra) # 8000537c <create>
    80005b86:	cd11                	beqz	a0,80005ba2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	124080e7          	jalr	292(ra) # 80003cac <iunlockput>
  end_op();
    80005b90:	fffff097          	auipc	ra,0xfffff
    80005b94:	90c080e7          	jalr	-1780(ra) # 8000449c <end_op>
  return 0;
    80005b98:	4501                	li	a0,0
}
    80005b9a:	60aa                	ld	ra,136(sp)
    80005b9c:	640a                	ld	s0,128(sp)
    80005b9e:	6149                	addi	sp,sp,144
    80005ba0:	8082                	ret
    end_op();
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	8fa080e7          	jalr	-1798(ra) # 8000449c <end_op>
    return -1;
    80005baa:	557d                	li	a0,-1
    80005bac:	b7fd                	j	80005b9a <sys_mkdir+0x4c>

0000000080005bae <sys_mknod>:

uint64
sys_mknod(void)
{
    80005bae:	7135                	addi	sp,sp,-160
    80005bb0:	ed06                	sd	ra,152(sp)
    80005bb2:	e922                	sd	s0,144(sp)
    80005bb4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	866080e7          	jalr	-1946(ra) # 8000441c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bbe:	08000613          	li	a2,128
    80005bc2:	f7040593          	addi	a1,s0,-144
    80005bc6:	4501                	li	a0,0
    80005bc8:	ffffd097          	auipc	ra,0xffffd
    80005bcc:	354080e7          	jalr	852(ra) # 80002f1c <argstr>
    80005bd0:	04054a63          	bltz	a0,80005c24 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005bd4:	f6c40593          	addi	a1,s0,-148
    80005bd8:	4505                	li	a0,1
    80005bda:	ffffd097          	auipc	ra,0xffffd
    80005bde:	2fe080e7          	jalr	766(ra) # 80002ed8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005be2:	04054163          	bltz	a0,80005c24 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005be6:	f6840593          	addi	a1,s0,-152
    80005bea:	4509                	li	a0,2
    80005bec:	ffffd097          	auipc	ra,0xffffd
    80005bf0:	2ec080e7          	jalr	748(ra) # 80002ed8 <argint>
     argint(1, &major) < 0 ||
    80005bf4:	02054863          	bltz	a0,80005c24 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bf8:	f6841683          	lh	a3,-152(s0)
    80005bfc:	f6c41603          	lh	a2,-148(s0)
    80005c00:	458d                	li	a1,3
    80005c02:	f7040513          	addi	a0,s0,-144
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	776080e7          	jalr	1910(ra) # 8000537c <create>
     argint(2, &minor) < 0 ||
    80005c0e:	c919                	beqz	a0,80005c24 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	09c080e7          	jalr	156(ra) # 80003cac <iunlockput>
  end_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	884080e7          	jalr	-1916(ra) # 8000449c <end_op>
  return 0;
    80005c20:	4501                	li	a0,0
    80005c22:	a031                	j	80005c2e <sys_mknod+0x80>
    end_op();
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	878080e7          	jalr	-1928(ra) # 8000449c <end_op>
    return -1;
    80005c2c:	557d                	li	a0,-1
}
    80005c2e:	60ea                	ld	ra,152(sp)
    80005c30:	644a                	ld	s0,144(sp)
    80005c32:	610d                	addi	sp,sp,160
    80005c34:	8082                	ret

0000000080005c36 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c36:	7135                	addi	sp,sp,-160
    80005c38:	ed06                	sd	ra,152(sp)
    80005c3a:	e922                	sd	s0,144(sp)
    80005c3c:	e526                	sd	s1,136(sp)
    80005c3e:	e14a                	sd	s2,128(sp)
    80005c40:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c42:	ffffc097          	auipc	ra,0xffffc
    80005c46:	122080e7          	jalr	290(ra) # 80001d64 <myproc>
    80005c4a:	892a                	mv	s2,a0
  
  begin_op();
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	7d0080e7          	jalr	2000(ra) # 8000441c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c54:	08000613          	li	a2,128
    80005c58:	f6040593          	addi	a1,s0,-160
    80005c5c:	4501                	li	a0,0
    80005c5e:	ffffd097          	auipc	ra,0xffffd
    80005c62:	2be080e7          	jalr	702(ra) # 80002f1c <argstr>
    80005c66:	04054b63          	bltz	a0,80005cbc <sys_chdir+0x86>
    80005c6a:	f6040513          	addi	a0,s0,-160
    80005c6e:	ffffe097          	auipc	ra,0xffffe
    80005c72:	592080e7          	jalr	1426(ra) # 80004200 <namei>
    80005c76:	84aa                	mv	s1,a0
    80005c78:	c131                	beqz	a0,80005cbc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c7a:	ffffe097          	auipc	ra,0xffffe
    80005c7e:	dd0080e7          	jalr	-560(ra) # 80003a4a <ilock>
  if(ip->type != T_DIR){
    80005c82:	04449703          	lh	a4,68(s1)
    80005c86:	4785                	li	a5,1
    80005c88:	04f71063          	bne	a4,a5,80005cc8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c8c:	8526                	mv	a0,s1
    80005c8e:	ffffe097          	auipc	ra,0xffffe
    80005c92:	e7e080e7          	jalr	-386(ra) # 80003b0c <iunlock>
  iput(p->cwd);
    80005c96:	17093503          	ld	a0,368(s2)
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	f6a080e7          	jalr	-150(ra) # 80003c04 <iput>
  end_op();
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	7fa080e7          	jalr	2042(ra) # 8000449c <end_op>
  p->cwd = ip;
    80005caa:	16993823          	sd	s1,368(s2)
  return 0;
    80005cae:	4501                	li	a0,0
}
    80005cb0:	60ea                	ld	ra,152(sp)
    80005cb2:	644a                	ld	s0,144(sp)
    80005cb4:	64aa                	ld	s1,136(sp)
    80005cb6:	690a                	ld	s2,128(sp)
    80005cb8:	610d                	addi	sp,sp,160
    80005cba:	8082                	ret
    end_op();
    80005cbc:	ffffe097          	auipc	ra,0xffffe
    80005cc0:	7e0080e7          	jalr	2016(ra) # 8000449c <end_op>
    return -1;
    80005cc4:	557d                	li	a0,-1
    80005cc6:	b7ed                	j	80005cb0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005cc8:	8526                	mv	a0,s1
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	fe2080e7          	jalr	-30(ra) # 80003cac <iunlockput>
    end_op();
    80005cd2:	ffffe097          	auipc	ra,0xffffe
    80005cd6:	7ca080e7          	jalr	1994(ra) # 8000449c <end_op>
    return -1;
    80005cda:	557d                	li	a0,-1
    80005cdc:	bfd1                	j	80005cb0 <sys_chdir+0x7a>

0000000080005cde <sys_exec>:

uint64
sys_exec(void)
{
    80005cde:	7145                	addi	sp,sp,-464
    80005ce0:	e786                	sd	ra,456(sp)
    80005ce2:	e3a2                	sd	s0,448(sp)
    80005ce4:	ff26                	sd	s1,440(sp)
    80005ce6:	fb4a                	sd	s2,432(sp)
    80005ce8:	f74e                	sd	s3,424(sp)
    80005cea:	f352                	sd	s4,416(sp)
    80005cec:	ef56                	sd	s5,408(sp)
    80005cee:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005cf0:	08000613          	li	a2,128
    80005cf4:	f4040593          	addi	a1,s0,-192
    80005cf8:	4501                	li	a0,0
    80005cfa:	ffffd097          	auipc	ra,0xffffd
    80005cfe:	222080e7          	jalr	546(ra) # 80002f1c <argstr>
    return -1;
    80005d02:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d04:	0c054a63          	bltz	a0,80005dd8 <sys_exec+0xfa>
    80005d08:	e3840593          	addi	a1,s0,-456
    80005d0c:	4505                	li	a0,1
    80005d0e:	ffffd097          	auipc	ra,0xffffd
    80005d12:	1ec080e7          	jalr	492(ra) # 80002efa <argaddr>
    80005d16:	0c054163          	bltz	a0,80005dd8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d1a:	10000613          	li	a2,256
    80005d1e:	4581                	li	a1,0
    80005d20:	e4040513          	addi	a0,s0,-448
    80005d24:	ffffb097          	auipc	ra,0xffffb
    80005d28:	fbc080e7          	jalr	-68(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d2c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d30:	89a6                	mv	s3,s1
    80005d32:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d34:	02000a13          	li	s4,32
    80005d38:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d3c:	00391513          	slli	a0,s2,0x3
    80005d40:	e3040593          	addi	a1,s0,-464
    80005d44:	e3843783          	ld	a5,-456(s0)
    80005d48:	953e                	add	a0,a0,a5
    80005d4a:	ffffd097          	auipc	ra,0xffffd
    80005d4e:	0f4080e7          	jalr	244(ra) # 80002e3e <fetchaddr>
    80005d52:	02054a63          	bltz	a0,80005d86 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005d56:	e3043783          	ld	a5,-464(s0)
    80005d5a:	c3b9                	beqz	a5,80005da0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d5c:	ffffb097          	auipc	ra,0xffffb
    80005d60:	d98080e7          	jalr	-616(ra) # 80000af4 <kalloc>
    80005d64:	85aa                	mv	a1,a0
    80005d66:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d6a:	cd11                	beqz	a0,80005d86 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d6c:	6605                	lui	a2,0x1
    80005d6e:	e3043503          	ld	a0,-464(s0)
    80005d72:	ffffd097          	auipc	ra,0xffffd
    80005d76:	11e080e7          	jalr	286(ra) # 80002e90 <fetchstr>
    80005d7a:	00054663          	bltz	a0,80005d86 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005d7e:	0905                	addi	s2,s2,1
    80005d80:	09a1                	addi	s3,s3,8
    80005d82:	fb491be3          	bne	s2,s4,80005d38 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d86:	10048913          	addi	s2,s1,256
    80005d8a:	6088                	ld	a0,0(s1)
    80005d8c:	c529                	beqz	a0,80005dd6 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d8e:	ffffb097          	auipc	ra,0xffffb
    80005d92:	c6a080e7          	jalr	-918(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d96:	04a1                	addi	s1,s1,8
    80005d98:	ff2499e3          	bne	s1,s2,80005d8a <sys_exec+0xac>
  return -1;
    80005d9c:	597d                	li	s2,-1
    80005d9e:	a82d                	j	80005dd8 <sys_exec+0xfa>
      argv[i] = 0;
    80005da0:	0a8e                	slli	s5,s5,0x3
    80005da2:	fc040793          	addi	a5,s0,-64
    80005da6:	9abe                	add	s5,s5,a5
    80005da8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005dac:	e4040593          	addi	a1,s0,-448
    80005db0:	f4040513          	addi	a0,s0,-192
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	194080e7          	jalr	404(ra) # 80004f48 <exec>
    80005dbc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dbe:	10048993          	addi	s3,s1,256
    80005dc2:	6088                	ld	a0,0(s1)
    80005dc4:	c911                	beqz	a0,80005dd8 <sys_exec+0xfa>
    kfree(argv[i]);
    80005dc6:	ffffb097          	auipc	ra,0xffffb
    80005dca:	c32080e7          	jalr	-974(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dce:	04a1                	addi	s1,s1,8
    80005dd0:	ff3499e3          	bne	s1,s3,80005dc2 <sys_exec+0xe4>
    80005dd4:	a011                	j	80005dd8 <sys_exec+0xfa>
  return -1;
    80005dd6:	597d                	li	s2,-1
}
    80005dd8:	854a                	mv	a0,s2
    80005dda:	60be                	ld	ra,456(sp)
    80005ddc:	641e                	ld	s0,448(sp)
    80005dde:	74fa                	ld	s1,440(sp)
    80005de0:	795a                	ld	s2,432(sp)
    80005de2:	79ba                	ld	s3,424(sp)
    80005de4:	7a1a                	ld	s4,416(sp)
    80005de6:	6afa                	ld	s5,408(sp)
    80005de8:	6179                	addi	sp,sp,464
    80005dea:	8082                	ret

0000000080005dec <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dec:	7139                	addi	sp,sp,-64
    80005dee:	fc06                	sd	ra,56(sp)
    80005df0:	f822                	sd	s0,48(sp)
    80005df2:	f426                	sd	s1,40(sp)
    80005df4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005df6:	ffffc097          	auipc	ra,0xffffc
    80005dfa:	f6e080e7          	jalr	-146(ra) # 80001d64 <myproc>
    80005dfe:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e00:	fd840593          	addi	a1,s0,-40
    80005e04:	4501                	li	a0,0
    80005e06:	ffffd097          	auipc	ra,0xffffd
    80005e0a:	0f4080e7          	jalr	244(ra) # 80002efa <argaddr>
    return -1;
    80005e0e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e10:	0e054063          	bltz	a0,80005ef0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005e14:	fc840593          	addi	a1,s0,-56
    80005e18:	fd040513          	addi	a0,s0,-48
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	dfc080e7          	jalr	-516(ra) # 80004c18 <pipealloc>
    return -1;
    80005e24:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e26:	0c054563          	bltz	a0,80005ef0 <sys_pipe+0x104>
  fd0 = -1;
    80005e2a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e2e:	fd043503          	ld	a0,-48(s0)
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	508080e7          	jalr	1288(ra) # 8000533a <fdalloc>
    80005e3a:	fca42223          	sw	a0,-60(s0)
    80005e3e:	08054c63          	bltz	a0,80005ed6 <sys_pipe+0xea>
    80005e42:	fc843503          	ld	a0,-56(s0)
    80005e46:	fffff097          	auipc	ra,0xfffff
    80005e4a:	4f4080e7          	jalr	1268(ra) # 8000533a <fdalloc>
    80005e4e:	fca42023          	sw	a0,-64(s0)
    80005e52:	06054863          	bltz	a0,80005ec2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e56:	4691                	li	a3,4
    80005e58:	fc440613          	addi	a2,s0,-60
    80005e5c:	fd843583          	ld	a1,-40(s0)
    80005e60:	78a8                	ld	a0,112(s1)
    80005e62:	ffffc097          	auipc	ra,0xffffc
    80005e66:	810080e7          	jalr	-2032(ra) # 80001672 <copyout>
    80005e6a:	02054063          	bltz	a0,80005e8a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e6e:	4691                	li	a3,4
    80005e70:	fc040613          	addi	a2,s0,-64
    80005e74:	fd843583          	ld	a1,-40(s0)
    80005e78:	0591                	addi	a1,a1,4
    80005e7a:	78a8                	ld	a0,112(s1)
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	7f6080e7          	jalr	2038(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e84:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e86:	06055563          	bgez	a0,80005ef0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005e8a:	fc442783          	lw	a5,-60(s0)
    80005e8e:	07f9                	addi	a5,a5,30
    80005e90:	078e                	slli	a5,a5,0x3
    80005e92:	97a6                	add	a5,a5,s1
    80005e94:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e98:	fc042503          	lw	a0,-64(s0)
    80005e9c:	0579                	addi	a0,a0,30
    80005e9e:	050e                	slli	a0,a0,0x3
    80005ea0:	9526                	add	a0,a0,s1
    80005ea2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ea6:	fd043503          	ld	a0,-48(s0)
    80005eaa:	fffff097          	auipc	ra,0xfffff
    80005eae:	a3e080e7          	jalr	-1474(ra) # 800048e8 <fileclose>
    fileclose(wf);
    80005eb2:	fc843503          	ld	a0,-56(s0)
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	a32080e7          	jalr	-1486(ra) # 800048e8 <fileclose>
    return -1;
    80005ebe:	57fd                	li	a5,-1
    80005ec0:	a805                	j	80005ef0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005ec2:	fc442783          	lw	a5,-60(s0)
    80005ec6:	0007c863          	bltz	a5,80005ed6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005eca:	01e78513          	addi	a0,a5,30
    80005ece:	050e                	slli	a0,a0,0x3
    80005ed0:	9526                	add	a0,a0,s1
    80005ed2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ed6:	fd043503          	ld	a0,-48(s0)
    80005eda:	fffff097          	auipc	ra,0xfffff
    80005ede:	a0e080e7          	jalr	-1522(ra) # 800048e8 <fileclose>
    fileclose(wf);
    80005ee2:	fc843503          	ld	a0,-56(s0)
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	a02080e7          	jalr	-1534(ra) # 800048e8 <fileclose>
    return -1;
    80005eee:	57fd                	li	a5,-1
}
    80005ef0:	853e                	mv	a0,a5
    80005ef2:	70e2                	ld	ra,56(sp)
    80005ef4:	7442                	ld	s0,48(sp)
    80005ef6:	74a2                	ld	s1,40(sp)
    80005ef8:	6121                	addi	sp,sp,64
    80005efa:	8082                	ret
    80005efc:	0000                	unimp
	...

0000000080005f00 <kernelvec>:
    80005f00:	7111                	addi	sp,sp,-256
    80005f02:	e006                	sd	ra,0(sp)
    80005f04:	e40a                	sd	sp,8(sp)
    80005f06:	e80e                	sd	gp,16(sp)
    80005f08:	ec12                	sd	tp,24(sp)
    80005f0a:	f016                	sd	t0,32(sp)
    80005f0c:	f41a                	sd	t1,40(sp)
    80005f0e:	f81e                	sd	t2,48(sp)
    80005f10:	fc22                	sd	s0,56(sp)
    80005f12:	e0a6                	sd	s1,64(sp)
    80005f14:	e4aa                	sd	a0,72(sp)
    80005f16:	e8ae                	sd	a1,80(sp)
    80005f18:	ecb2                	sd	a2,88(sp)
    80005f1a:	f0b6                	sd	a3,96(sp)
    80005f1c:	f4ba                	sd	a4,104(sp)
    80005f1e:	f8be                	sd	a5,112(sp)
    80005f20:	fcc2                	sd	a6,120(sp)
    80005f22:	e146                	sd	a7,128(sp)
    80005f24:	e54a                	sd	s2,136(sp)
    80005f26:	e94e                	sd	s3,144(sp)
    80005f28:	ed52                	sd	s4,152(sp)
    80005f2a:	f156                	sd	s5,160(sp)
    80005f2c:	f55a                	sd	s6,168(sp)
    80005f2e:	f95e                	sd	s7,176(sp)
    80005f30:	fd62                	sd	s8,184(sp)
    80005f32:	e1e6                	sd	s9,192(sp)
    80005f34:	e5ea                	sd	s10,200(sp)
    80005f36:	e9ee                	sd	s11,208(sp)
    80005f38:	edf2                	sd	t3,216(sp)
    80005f3a:	f1f6                	sd	t4,224(sp)
    80005f3c:	f5fa                	sd	t5,232(sp)
    80005f3e:	f9fe                	sd	t6,240(sp)
    80005f40:	dcbfc0ef          	jal	ra,80002d0a <kerneltrap>
    80005f44:	6082                	ld	ra,0(sp)
    80005f46:	6122                	ld	sp,8(sp)
    80005f48:	61c2                	ld	gp,16(sp)
    80005f4a:	7282                	ld	t0,32(sp)
    80005f4c:	7322                	ld	t1,40(sp)
    80005f4e:	73c2                	ld	t2,48(sp)
    80005f50:	7462                	ld	s0,56(sp)
    80005f52:	6486                	ld	s1,64(sp)
    80005f54:	6526                	ld	a0,72(sp)
    80005f56:	65c6                	ld	a1,80(sp)
    80005f58:	6666                	ld	a2,88(sp)
    80005f5a:	7686                	ld	a3,96(sp)
    80005f5c:	7726                	ld	a4,104(sp)
    80005f5e:	77c6                	ld	a5,112(sp)
    80005f60:	7866                	ld	a6,120(sp)
    80005f62:	688a                	ld	a7,128(sp)
    80005f64:	692a                	ld	s2,136(sp)
    80005f66:	69ca                	ld	s3,144(sp)
    80005f68:	6a6a                	ld	s4,152(sp)
    80005f6a:	7a8a                	ld	s5,160(sp)
    80005f6c:	7b2a                	ld	s6,168(sp)
    80005f6e:	7bca                	ld	s7,176(sp)
    80005f70:	7c6a                	ld	s8,184(sp)
    80005f72:	6c8e                	ld	s9,192(sp)
    80005f74:	6d2e                	ld	s10,200(sp)
    80005f76:	6dce                	ld	s11,208(sp)
    80005f78:	6e6e                	ld	t3,216(sp)
    80005f7a:	7e8e                	ld	t4,224(sp)
    80005f7c:	7f2e                	ld	t5,232(sp)
    80005f7e:	7fce                	ld	t6,240(sp)
    80005f80:	6111                	addi	sp,sp,256
    80005f82:	10200073          	sret
    80005f86:	00000013          	nop
    80005f8a:	00000013          	nop
    80005f8e:	0001                	nop

0000000080005f90 <timervec>:
    80005f90:	34051573          	csrrw	a0,mscratch,a0
    80005f94:	e10c                	sd	a1,0(a0)
    80005f96:	e510                	sd	a2,8(a0)
    80005f98:	e914                	sd	a3,16(a0)
    80005f9a:	6d0c                	ld	a1,24(a0)
    80005f9c:	7110                	ld	a2,32(a0)
    80005f9e:	6194                	ld	a3,0(a1)
    80005fa0:	96b2                	add	a3,a3,a2
    80005fa2:	e194                	sd	a3,0(a1)
    80005fa4:	4589                	li	a1,2
    80005fa6:	14459073          	csrw	sip,a1
    80005faa:	6914                	ld	a3,16(a0)
    80005fac:	6510                	ld	a2,8(a0)
    80005fae:	610c                	ld	a1,0(a0)
    80005fb0:	34051573          	csrrw	a0,mscratch,a0
    80005fb4:	30200073          	mret
	...

0000000080005fba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005fba:	1141                	addi	sp,sp,-16
    80005fbc:	e422                	sd	s0,8(sp)
    80005fbe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fc0:	0c0007b7          	lui	a5,0xc000
    80005fc4:	4705                	li	a4,1
    80005fc6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fc8:	c3d8                	sw	a4,4(a5)
}
    80005fca:	6422                	ld	s0,8(sp)
    80005fcc:	0141                	addi	sp,sp,16
    80005fce:	8082                	ret

0000000080005fd0 <plicinithart>:

void
plicinithart(void)
{
    80005fd0:	1141                	addi	sp,sp,-16
    80005fd2:	e406                	sd	ra,8(sp)
    80005fd4:	e022                	sd	s0,0(sp)
    80005fd6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fd8:	ffffc097          	auipc	ra,0xffffc
    80005fdc:	d58080e7          	jalr	-680(ra) # 80001d30 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fe0:	0085171b          	slliw	a4,a0,0x8
    80005fe4:	0c0027b7          	lui	a5,0xc002
    80005fe8:	97ba                	add	a5,a5,a4
    80005fea:	40200713          	li	a4,1026
    80005fee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ff2:	00d5151b          	slliw	a0,a0,0xd
    80005ff6:	0c2017b7          	lui	a5,0xc201
    80005ffa:	953e                	add	a0,a0,a5
    80005ffc:	00052023          	sw	zero,0(a0)
}
    80006000:	60a2                	ld	ra,8(sp)
    80006002:	6402                	ld	s0,0(sp)
    80006004:	0141                	addi	sp,sp,16
    80006006:	8082                	ret

0000000080006008 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006008:	1141                	addi	sp,sp,-16
    8000600a:	e406                	sd	ra,8(sp)
    8000600c:	e022                	sd	s0,0(sp)
    8000600e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006010:	ffffc097          	auipc	ra,0xffffc
    80006014:	d20080e7          	jalr	-736(ra) # 80001d30 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006018:	00d5179b          	slliw	a5,a0,0xd
    8000601c:	0c201537          	lui	a0,0xc201
    80006020:	953e                	add	a0,a0,a5
  return irq;
}
    80006022:	4148                	lw	a0,4(a0)
    80006024:	60a2                	ld	ra,8(sp)
    80006026:	6402                	ld	s0,0(sp)
    80006028:	0141                	addi	sp,sp,16
    8000602a:	8082                	ret

000000008000602c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000602c:	1101                	addi	sp,sp,-32
    8000602e:	ec06                	sd	ra,24(sp)
    80006030:	e822                	sd	s0,16(sp)
    80006032:	e426                	sd	s1,8(sp)
    80006034:	1000                	addi	s0,sp,32
    80006036:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	cf8080e7          	jalr	-776(ra) # 80001d30 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006040:	00d5151b          	slliw	a0,a0,0xd
    80006044:	0c2017b7          	lui	a5,0xc201
    80006048:	97aa                	add	a5,a5,a0
    8000604a:	c3c4                	sw	s1,4(a5)
}
    8000604c:	60e2                	ld	ra,24(sp)
    8000604e:	6442                	ld	s0,16(sp)
    80006050:	64a2                	ld	s1,8(sp)
    80006052:	6105                	addi	sp,sp,32
    80006054:	8082                	ret

0000000080006056 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006056:	1141                	addi	sp,sp,-16
    80006058:	e406                	sd	ra,8(sp)
    8000605a:	e022                	sd	s0,0(sp)
    8000605c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000605e:	479d                	li	a5,7
    80006060:	06a7c963          	blt	a5,a0,800060d2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006064:	0001d797          	auipc	a5,0x1d
    80006068:	f9c78793          	addi	a5,a5,-100 # 80023000 <disk>
    8000606c:	00a78733          	add	a4,a5,a0
    80006070:	6789                	lui	a5,0x2
    80006072:	97ba                	add	a5,a5,a4
    80006074:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006078:	e7ad                	bnez	a5,800060e2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000607a:	00451793          	slli	a5,a0,0x4
    8000607e:	0001f717          	auipc	a4,0x1f
    80006082:	f8270713          	addi	a4,a4,-126 # 80025000 <disk+0x2000>
    80006086:	6314                	ld	a3,0(a4)
    80006088:	96be                	add	a3,a3,a5
    8000608a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000608e:	6314                	ld	a3,0(a4)
    80006090:	96be                	add	a3,a3,a5
    80006092:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006096:	6314                	ld	a3,0(a4)
    80006098:	96be                	add	a3,a3,a5
    8000609a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000609e:	6318                	ld	a4,0(a4)
    800060a0:	97ba                	add	a5,a5,a4
    800060a2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800060a6:	0001d797          	auipc	a5,0x1d
    800060aa:	f5a78793          	addi	a5,a5,-166 # 80023000 <disk>
    800060ae:	97aa                	add	a5,a5,a0
    800060b0:	6509                	lui	a0,0x2
    800060b2:	953e                	add	a0,a0,a5
    800060b4:	4785                	li	a5,1
    800060b6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800060ba:	0001f517          	auipc	a0,0x1f
    800060be:	f5e50513          	addi	a0,a0,-162 # 80025018 <disk+0x2018>
    800060c2:	ffffc097          	auipc	ra,0xffffc
    800060c6:	57e080e7          	jalr	1406(ra) # 80002640 <wakeup>
}
    800060ca:	60a2                	ld	ra,8(sp)
    800060cc:	6402                	ld	s0,0(sp)
    800060ce:	0141                	addi	sp,sp,16
    800060d0:	8082                	ret
    panic("free_desc 1");
    800060d2:	00002517          	auipc	a0,0x2
    800060d6:	6de50513          	addi	a0,a0,1758 # 800087b0 <syscalls+0x320>
    800060da:	ffffa097          	auipc	ra,0xffffa
    800060de:	464080e7          	jalr	1124(ra) # 8000053e <panic>
    panic("free_desc 2");
    800060e2:	00002517          	auipc	a0,0x2
    800060e6:	6de50513          	addi	a0,a0,1758 # 800087c0 <syscalls+0x330>
    800060ea:	ffffa097          	auipc	ra,0xffffa
    800060ee:	454080e7          	jalr	1108(ra) # 8000053e <panic>

00000000800060f2 <virtio_disk_init>:
{
    800060f2:	1101                	addi	sp,sp,-32
    800060f4:	ec06                	sd	ra,24(sp)
    800060f6:	e822                	sd	s0,16(sp)
    800060f8:	e426                	sd	s1,8(sp)
    800060fa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060fc:	00002597          	auipc	a1,0x2
    80006100:	6d458593          	addi	a1,a1,1748 # 800087d0 <syscalls+0x340>
    80006104:	0001f517          	auipc	a0,0x1f
    80006108:	02450513          	addi	a0,a0,36 # 80025128 <disk+0x2128>
    8000610c:	ffffb097          	auipc	ra,0xffffb
    80006110:	a48080e7          	jalr	-1464(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006114:	100017b7          	lui	a5,0x10001
    80006118:	4398                	lw	a4,0(a5)
    8000611a:	2701                	sext.w	a4,a4
    8000611c:	747277b7          	lui	a5,0x74727
    80006120:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006124:	0ef71163          	bne	a4,a5,80006206 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	43dc                	lw	a5,4(a5)
    8000612e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006130:	4705                	li	a4,1
    80006132:	0ce79a63          	bne	a5,a4,80006206 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006136:	100017b7          	lui	a5,0x10001
    8000613a:	479c                	lw	a5,8(a5)
    8000613c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000613e:	4709                	li	a4,2
    80006140:	0ce79363          	bne	a5,a4,80006206 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006144:	100017b7          	lui	a5,0x10001
    80006148:	47d8                	lw	a4,12(a5)
    8000614a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000614c:	554d47b7          	lui	a5,0x554d4
    80006150:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006154:	0af71963          	bne	a4,a5,80006206 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	4705                	li	a4,1
    8000615e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006160:	470d                	li	a4,3
    80006162:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006164:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006166:	c7ffe737          	lui	a4,0xc7ffe
    8000616a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000616e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006170:	2701                	sext.w	a4,a4
    80006172:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006174:	472d                	li	a4,11
    80006176:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006178:	473d                	li	a4,15
    8000617a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000617c:	6705                	lui	a4,0x1
    8000617e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006180:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006184:	5bdc                	lw	a5,52(a5)
    80006186:	2781                	sext.w	a5,a5
  if(max == 0)
    80006188:	c7d9                	beqz	a5,80006216 <virtio_disk_init+0x124>
  if(max < NUM)
    8000618a:	471d                	li	a4,7
    8000618c:	08f77d63          	bgeu	a4,a5,80006226 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006190:	100014b7          	lui	s1,0x10001
    80006194:	47a1                	li	a5,8
    80006196:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006198:	6609                	lui	a2,0x2
    8000619a:	4581                	li	a1,0
    8000619c:	0001d517          	auipc	a0,0x1d
    800061a0:	e6450513          	addi	a0,a0,-412 # 80023000 <disk>
    800061a4:	ffffb097          	auipc	ra,0xffffb
    800061a8:	b3c080e7          	jalr	-1220(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800061ac:	0001d717          	auipc	a4,0x1d
    800061b0:	e5470713          	addi	a4,a4,-428 # 80023000 <disk>
    800061b4:	00c75793          	srli	a5,a4,0xc
    800061b8:	2781                	sext.w	a5,a5
    800061ba:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800061bc:	0001f797          	auipc	a5,0x1f
    800061c0:	e4478793          	addi	a5,a5,-444 # 80025000 <disk+0x2000>
    800061c4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800061c6:	0001d717          	auipc	a4,0x1d
    800061ca:	eba70713          	addi	a4,a4,-326 # 80023080 <disk+0x80>
    800061ce:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800061d0:	0001e717          	auipc	a4,0x1e
    800061d4:	e3070713          	addi	a4,a4,-464 # 80024000 <disk+0x1000>
    800061d8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800061da:	4705                	li	a4,1
    800061dc:	00e78c23          	sb	a4,24(a5)
    800061e0:	00e78ca3          	sb	a4,25(a5)
    800061e4:	00e78d23          	sb	a4,26(a5)
    800061e8:	00e78da3          	sb	a4,27(a5)
    800061ec:	00e78e23          	sb	a4,28(a5)
    800061f0:	00e78ea3          	sb	a4,29(a5)
    800061f4:	00e78f23          	sb	a4,30(a5)
    800061f8:	00e78fa3          	sb	a4,31(a5)
}
    800061fc:	60e2                	ld	ra,24(sp)
    800061fe:	6442                	ld	s0,16(sp)
    80006200:	64a2                	ld	s1,8(sp)
    80006202:	6105                	addi	sp,sp,32
    80006204:	8082                	ret
    panic("could not find virtio disk");
    80006206:	00002517          	auipc	a0,0x2
    8000620a:	5da50513          	addi	a0,a0,1498 # 800087e0 <syscalls+0x350>
    8000620e:	ffffa097          	auipc	ra,0xffffa
    80006212:	330080e7          	jalr	816(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006216:	00002517          	auipc	a0,0x2
    8000621a:	5ea50513          	addi	a0,a0,1514 # 80008800 <syscalls+0x370>
    8000621e:	ffffa097          	auipc	ra,0xffffa
    80006222:	320080e7          	jalr	800(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006226:	00002517          	auipc	a0,0x2
    8000622a:	5fa50513          	addi	a0,a0,1530 # 80008820 <syscalls+0x390>
    8000622e:	ffffa097          	auipc	ra,0xffffa
    80006232:	310080e7          	jalr	784(ra) # 8000053e <panic>

0000000080006236 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006236:	7159                	addi	sp,sp,-112
    80006238:	f486                	sd	ra,104(sp)
    8000623a:	f0a2                	sd	s0,96(sp)
    8000623c:	eca6                	sd	s1,88(sp)
    8000623e:	e8ca                	sd	s2,80(sp)
    80006240:	e4ce                	sd	s3,72(sp)
    80006242:	e0d2                	sd	s4,64(sp)
    80006244:	fc56                	sd	s5,56(sp)
    80006246:	f85a                	sd	s6,48(sp)
    80006248:	f45e                	sd	s7,40(sp)
    8000624a:	f062                	sd	s8,32(sp)
    8000624c:	ec66                	sd	s9,24(sp)
    8000624e:	e86a                	sd	s10,16(sp)
    80006250:	1880                	addi	s0,sp,112
    80006252:	892a                	mv	s2,a0
    80006254:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006256:	00c52c83          	lw	s9,12(a0)
    8000625a:	001c9c9b          	slliw	s9,s9,0x1
    8000625e:	1c82                	slli	s9,s9,0x20
    80006260:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006264:	0001f517          	auipc	a0,0x1f
    80006268:	ec450513          	addi	a0,a0,-316 # 80025128 <disk+0x2128>
    8000626c:	ffffb097          	auipc	ra,0xffffb
    80006270:	978080e7          	jalr	-1672(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    80006274:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006276:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006278:	0001db97          	auipc	s7,0x1d
    8000627c:	d88b8b93          	addi	s7,s7,-632 # 80023000 <disk>
    80006280:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006282:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006284:	8a4e                	mv	s4,s3
    80006286:	a051                	j	8000630a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006288:	00fb86b3          	add	a3,s7,a5
    8000628c:	96da                	add	a3,a3,s6
    8000628e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006292:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006294:	0207c563          	bltz	a5,800062be <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006298:	2485                	addiw	s1,s1,1
    8000629a:	0711                	addi	a4,a4,4
    8000629c:	25548063          	beq	s1,s5,800064dc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    800062a0:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800062a2:	0001f697          	auipc	a3,0x1f
    800062a6:	d7668693          	addi	a3,a3,-650 # 80025018 <disk+0x2018>
    800062aa:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800062ac:	0006c583          	lbu	a1,0(a3)
    800062b0:	fde1                	bnez	a1,80006288 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800062b2:	2785                	addiw	a5,a5,1
    800062b4:	0685                	addi	a3,a3,1
    800062b6:	ff879be3          	bne	a5,s8,800062ac <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800062ba:	57fd                	li	a5,-1
    800062bc:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800062be:	02905a63          	blez	s1,800062f2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800062c2:	f9042503          	lw	a0,-112(s0)
    800062c6:	00000097          	auipc	ra,0x0
    800062ca:	d90080e7          	jalr	-624(ra) # 80006056 <free_desc>
      for(int j = 0; j < i; j++)
    800062ce:	4785                	li	a5,1
    800062d0:	0297d163          	bge	a5,s1,800062f2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800062d4:	f9442503          	lw	a0,-108(s0)
    800062d8:	00000097          	auipc	ra,0x0
    800062dc:	d7e080e7          	jalr	-642(ra) # 80006056 <free_desc>
      for(int j = 0; j < i; j++)
    800062e0:	4789                	li	a5,2
    800062e2:	0097d863          	bge	a5,s1,800062f2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800062e6:	f9842503          	lw	a0,-104(s0)
    800062ea:	00000097          	auipc	ra,0x0
    800062ee:	d6c080e7          	jalr	-660(ra) # 80006056 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062f2:	0001f597          	auipc	a1,0x1f
    800062f6:	e3658593          	addi	a1,a1,-458 # 80025128 <disk+0x2128>
    800062fa:	0001f517          	auipc	a0,0x1f
    800062fe:	d1e50513          	addi	a0,a0,-738 # 80025018 <disk+0x2018>
    80006302:	ffffc097          	auipc	ra,0xffffc
    80006306:	1a0080e7          	jalr	416(ra) # 800024a2 <sleep>
  for(int i = 0; i < 3; i++){
    8000630a:	f9040713          	addi	a4,s0,-112
    8000630e:	84ce                	mv	s1,s3
    80006310:	bf41                	j	800062a0 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006312:	20058713          	addi	a4,a1,512
    80006316:	00471693          	slli	a3,a4,0x4
    8000631a:	0001d717          	auipc	a4,0x1d
    8000631e:	ce670713          	addi	a4,a4,-794 # 80023000 <disk>
    80006322:	9736                	add	a4,a4,a3
    80006324:	4685                	li	a3,1
    80006326:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000632a:	20058713          	addi	a4,a1,512
    8000632e:	00471693          	slli	a3,a4,0x4
    80006332:	0001d717          	auipc	a4,0x1d
    80006336:	cce70713          	addi	a4,a4,-818 # 80023000 <disk>
    8000633a:	9736                	add	a4,a4,a3
    8000633c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006340:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006344:	7679                	lui	a2,0xffffe
    80006346:	963e                	add	a2,a2,a5
    80006348:	0001f697          	auipc	a3,0x1f
    8000634c:	cb868693          	addi	a3,a3,-840 # 80025000 <disk+0x2000>
    80006350:	6298                	ld	a4,0(a3)
    80006352:	9732                	add	a4,a4,a2
    80006354:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006356:	6298                	ld	a4,0(a3)
    80006358:	9732                	add	a4,a4,a2
    8000635a:	4541                	li	a0,16
    8000635c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000635e:	6298                	ld	a4,0(a3)
    80006360:	9732                	add	a4,a4,a2
    80006362:	4505                	li	a0,1
    80006364:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006368:	f9442703          	lw	a4,-108(s0)
    8000636c:	6288                	ld	a0,0(a3)
    8000636e:	962a                	add	a2,a2,a0
    80006370:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006374:	0712                	slli	a4,a4,0x4
    80006376:	6290                	ld	a2,0(a3)
    80006378:	963a                	add	a2,a2,a4
    8000637a:	05890513          	addi	a0,s2,88
    8000637e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006380:	6294                	ld	a3,0(a3)
    80006382:	96ba                	add	a3,a3,a4
    80006384:	40000613          	li	a2,1024
    80006388:	c690                	sw	a2,8(a3)
  if(write)
    8000638a:	140d0063          	beqz	s10,800064ca <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000638e:	0001f697          	auipc	a3,0x1f
    80006392:	c726b683          	ld	a3,-910(a3) # 80025000 <disk+0x2000>
    80006396:	96ba                	add	a3,a3,a4
    80006398:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000639c:	0001d817          	auipc	a6,0x1d
    800063a0:	c6480813          	addi	a6,a6,-924 # 80023000 <disk>
    800063a4:	0001f517          	auipc	a0,0x1f
    800063a8:	c5c50513          	addi	a0,a0,-932 # 80025000 <disk+0x2000>
    800063ac:	6114                	ld	a3,0(a0)
    800063ae:	96ba                	add	a3,a3,a4
    800063b0:	00c6d603          	lhu	a2,12(a3)
    800063b4:	00166613          	ori	a2,a2,1
    800063b8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800063bc:	f9842683          	lw	a3,-104(s0)
    800063c0:	6110                	ld	a2,0(a0)
    800063c2:	9732                	add	a4,a4,a2
    800063c4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063c8:	20058613          	addi	a2,a1,512
    800063cc:	0612                	slli	a2,a2,0x4
    800063ce:	9642                	add	a2,a2,a6
    800063d0:	577d                	li	a4,-1
    800063d2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063d6:	00469713          	slli	a4,a3,0x4
    800063da:	6114                	ld	a3,0(a0)
    800063dc:	96ba                	add	a3,a3,a4
    800063de:	03078793          	addi	a5,a5,48
    800063e2:	97c2                	add	a5,a5,a6
    800063e4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800063e6:	611c                	ld	a5,0(a0)
    800063e8:	97ba                	add	a5,a5,a4
    800063ea:	4685                	li	a3,1
    800063ec:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063ee:	611c                	ld	a5,0(a0)
    800063f0:	97ba                	add	a5,a5,a4
    800063f2:	4809                	li	a6,2
    800063f4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800063f8:	611c                	ld	a5,0(a0)
    800063fa:	973e                	add	a4,a4,a5
    800063fc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006400:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006404:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006408:	6518                	ld	a4,8(a0)
    8000640a:	00275783          	lhu	a5,2(a4)
    8000640e:	8b9d                	andi	a5,a5,7
    80006410:	0786                	slli	a5,a5,0x1
    80006412:	97ba                	add	a5,a5,a4
    80006414:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006418:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000641c:	6518                	ld	a4,8(a0)
    8000641e:	00275783          	lhu	a5,2(a4)
    80006422:	2785                	addiw	a5,a5,1
    80006424:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006428:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000642c:	100017b7          	lui	a5,0x10001
    80006430:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006434:	00492703          	lw	a4,4(s2)
    80006438:	4785                	li	a5,1
    8000643a:	02f71163          	bne	a4,a5,8000645c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000643e:	0001f997          	auipc	s3,0x1f
    80006442:	cea98993          	addi	s3,s3,-790 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006446:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006448:	85ce                	mv	a1,s3
    8000644a:	854a                	mv	a0,s2
    8000644c:	ffffc097          	auipc	ra,0xffffc
    80006450:	056080e7          	jalr	86(ra) # 800024a2 <sleep>
  while(b->disk == 1) {
    80006454:	00492783          	lw	a5,4(s2)
    80006458:	fe9788e3          	beq	a5,s1,80006448 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000645c:	f9042903          	lw	s2,-112(s0)
    80006460:	20090793          	addi	a5,s2,512
    80006464:	00479713          	slli	a4,a5,0x4
    80006468:	0001d797          	auipc	a5,0x1d
    8000646c:	b9878793          	addi	a5,a5,-1128 # 80023000 <disk>
    80006470:	97ba                	add	a5,a5,a4
    80006472:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006476:	0001f997          	auipc	s3,0x1f
    8000647a:	b8a98993          	addi	s3,s3,-1142 # 80025000 <disk+0x2000>
    8000647e:	00491713          	slli	a4,s2,0x4
    80006482:	0009b783          	ld	a5,0(s3)
    80006486:	97ba                	add	a5,a5,a4
    80006488:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000648c:	854a                	mv	a0,s2
    8000648e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006492:	00000097          	auipc	ra,0x0
    80006496:	bc4080e7          	jalr	-1084(ra) # 80006056 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000649a:	8885                	andi	s1,s1,1
    8000649c:	f0ed                	bnez	s1,8000647e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000649e:	0001f517          	auipc	a0,0x1f
    800064a2:	c8a50513          	addi	a0,a0,-886 # 80025128 <disk+0x2128>
    800064a6:	ffffa097          	auipc	ra,0xffffa
    800064aa:	7f2080e7          	jalr	2034(ra) # 80000c98 <release>
}
    800064ae:	70a6                	ld	ra,104(sp)
    800064b0:	7406                	ld	s0,96(sp)
    800064b2:	64e6                	ld	s1,88(sp)
    800064b4:	6946                	ld	s2,80(sp)
    800064b6:	69a6                	ld	s3,72(sp)
    800064b8:	6a06                	ld	s4,64(sp)
    800064ba:	7ae2                	ld	s5,56(sp)
    800064bc:	7b42                	ld	s6,48(sp)
    800064be:	7ba2                	ld	s7,40(sp)
    800064c0:	7c02                	ld	s8,32(sp)
    800064c2:	6ce2                	ld	s9,24(sp)
    800064c4:	6d42                	ld	s10,16(sp)
    800064c6:	6165                	addi	sp,sp,112
    800064c8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800064ca:	0001f697          	auipc	a3,0x1f
    800064ce:	b366b683          	ld	a3,-1226(a3) # 80025000 <disk+0x2000>
    800064d2:	96ba                	add	a3,a3,a4
    800064d4:	4609                	li	a2,2
    800064d6:	00c69623          	sh	a2,12(a3)
    800064da:	b5c9                	j	8000639c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064dc:	f9042583          	lw	a1,-112(s0)
    800064e0:	20058793          	addi	a5,a1,512
    800064e4:	0792                	slli	a5,a5,0x4
    800064e6:	0001d517          	auipc	a0,0x1d
    800064ea:	bc250513          	addi	a0,a0,-1086 # 800230a8 <disk+0xa8>
    800064ee:	953e                	add	a0,a0,a5
  if(write)
    800064f0:	e20d11e3          	bnez	s10,80006312 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800064f4:	20058713          	addi	a4,a1,512
    800064f8:	00471693          	slli	a3,a4,0x4
    800064fc:	0001d717          	auipc	a4,0x1d
    80006500:	b0470713          	addi	a4,a4,-1276 # 80023000 <disk>
    80006504:	9736                	add	a4,a4,a3
    80006506:	0a072423          	sw	zero,168(a4)
    8000650a:	b505                	j	8000632a <virtio_disk_rw+0xf4>

000000008000650c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000650c:	1101                	addi	sp,sp,-32
    8000650e:	ec06                	sd	ra,24(sp)
    80006510:	e822                	sd	s0,16(sp)
    80006512:	e426                	sd	s1,8(sp)
    80006514:	e04a                	sd	s2,0(sp)
    80006516:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006518:	0001f517          	auipc	a0,0x1f
    8000651c:	c1050513          	addi	a0,a0,-1008 # 80025128 <disk+0x2128>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	6c4080e7          	jalr	1732(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006528:	10001737          	lui	a4,0x10001
    8000652c:	533c                	lw	a5,96(a4)
    8000652e:	8b8d                	andi	a5,a5,3
    80006530:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006532:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006536:	0001f797          	auipc	a5,0x1f
    8000653a:	aca78793          	addi	a5,a5,-1334 # 80025000 <disk+0x2000>
    8000653e:	6b94                	ld	a3,16(a5)
    80006540:	0207d703          	lhu	a4,32(a5)
    80006544:	0026d783          	lhu	a5,2(a3)
    80006548:	06f70163          	beq	a4,a5,800065aa <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000654c:	0001d917          	auipc	s2,0x1d
    80006550:	ab490913          	addi	s2,s2,-1356 # 80023000 <disk>
    80006554:	0001f497          	auipc	s1,0x1f
    80006558:	aac48493          	addi	s1,s1,-1364 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000655c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006560:	6898                	ld	a4,16(s1)
    80006562:	0204d783          	lhu	a5,32(s1)
    80006566:	8b9d                	andi	a5,a5,7
    80006568:	078e                	slli	a5,a5,0x3
    8000656a:	97ba                	add	a5,a5,a4
    8000656c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000656e:	20078713          	addi	a4,a5,512
    80006572:	0712                	slli	a4,a4,0x4
    80006574:	974a                	add	a4,a4,s2
    80006576:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000657a:	e731                	bnez	a4,800065c6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000657c:	20078793          	addi	a5,a5,512
    80006580:	0792                	slli	a5,a5,0x4
    80006582:	97ca                	add	a5,a5,s2
    80006584:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006586:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000658a:	ffffc097          	auipc	ra,0xffffc
    8000658e:	0b6080e7          	jalr	182(ra) # 80002640 <wakeup>

    disk.used_idx += 1;
    80006592:	0204d783          	lhu	a5,32(s1)
    80006596:	2785                	addiw	a5,a5,1
    80006598:	17c2                	slli	a5,a5,0x30
    8000659a:	93c1                	srli	a5,a5,0x30
    8000659c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065a0:	6898                	ld	a4,16(s1)
    800065a2:	00275703          	lhu	a4,2(a4)
    800065a6:	faf71be3          	bne	a4,a5,8000655c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800065aa:	0001f517          	auipc	a0,0x1f
    800065ae:	b7e50513          	addi	a0,a0,-1154 # 80025128 <disk+0x2128>
    800065b2:	ffffa097          	auipc	ra,0xffffa
    800065b6:	6e6080e7          	jalr	1766(ra) # 80000c98 <release>
}
    800065ba:	60e2                	ld	ra,24(sp)
    800065bc:	6442                	ld	s0,16(sp)
    800065be:	64a2                	ld	s1,8(sp)
    800065c0:	6902                	ld	s2,0(sp)
    800065c2:	6105                	addi	sp,sp,32
    800065c4:	8082                	ret
      panic("virtio_disk_intr status");
    800065c6:	00002517          	auipc	a0,0x2
    800065ca:	27a50513          	addi	a0,a0,634 # 80008840 <syscalls+0x3b0>
    800065ce:	ffffa097          	auipc	ra,0xffffa
    800065d2:	f70080e7          	jalr	-144(ra) # 8000053e <panic>

00000000800065d6 <cas>:
    800065d6:	100522af          	lr.w	t0,(a0)
    800065da:	00b29563          	bne	t0,a1,800065e4 <fail>
    800065de:	18c5252f          	sc.w	a0,a2,(a0)
    800065e2:	8082                	ret

00000000800065e4 <fail>:
    800065e4:	4505                	li	a0,1
    800065e6:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...