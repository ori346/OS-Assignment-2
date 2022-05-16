
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000068:	1ec78793          	addi	a5,a5,492 # 80006250 <timervec>
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
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	9f2080e7          	jalr	-1550(ra) # 80002b1e <either_copyin>
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
    800001c8:	bfc080e7          	jalr	-1028(ra) # 80001dc0 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	492080e7          	jalr	1170(ra) # 80002666 <sleep>
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
    80000210:	00003097          	auipc	ra,0x3
    80000214:	8b8080e7          	jalr	-1864(ra) # 80002ac8 <either_copyout>
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
    800002f2:	00003097          	auipc	ra,0x3
    800002f6:	882080e7          	jalr	-1918(ra) # 80002b74 <procdump>
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
    8000044a:	3be080e7          	jalr	958(ra) # 80002804 <wakeup>
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
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	a9878793          	addi	a5,a5,-1384 # 80021f10 <devsw>
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
    800008a4:	f64080e7          	jalr	-156(ra) # 80002804 <wakeup>
    
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
    80000930:	d3a080e7          	jalr	-710(ra) # 80002666 <sleep>
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
    80000b82:	21e080e7          	jalr	542(ra) # 80001d9c <mycpu>
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
    80000bb4:	1ec080e7          	jalr	492(ra) # 80001d9c <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	1e0080e7          	jalr	480(ra) # 80001d9c <mycpu>
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
    80000bd8:	1c8080e7          	jalr	456(ra) # 80001d9c <mycpu>
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
    80000c18:	188080e7          	jalr	392(ra) # 80001d9c <mycpu>
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
    80000c44:	15c080e7          	jalr	348(ra) # 80001d9c <mycpu>
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
    80000e9a:	ef6080e7          	jalr	-266(ra) # 80001d8c <cpuid>
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
    80000eb6:	eda080e7          	jalr	-294(ra) # 80001d8c <cpuid>
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
    80000ed8:	de0080e7          	jalr	-544(ra) # 80002cb4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	3b4080e7          	jalr	948(ra) # 80006290 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	4a6080e7          	jalr	1190(ra) # 8000238a <scheduler>
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
    80000f48:	cc4080e7          	jalr	-828(ra) # 80001c08 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	d40080e7          	jalr	-704(ra) # 80002c8c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	d60080e7          	jalr	-672(ra) # 80002cb4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	31e080e7          	jalr	798(ra) # 8000627a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	32c080e7          	jalr	812(ra) # 80006290 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	506080e7          	jalr	1286(ra) # 80003472 <binit>
    iinit();         // inode table
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	b96080e7          	jalr	-1130(ra) # 80003b0a <iinit>
    fileinit();      // file table
    80000f7c:	00004097          	auipc	ra,0x4
    80000f80:	b40080e7          	jalr	-1216(ra) # 80004abc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	42e080e7          	jalr	1070(ra) # 800063b2 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	11a080e7          	jalr	282(ra) # 800020a6 <userinit>
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
    80001244:	932080e7          	jalr	-1742(ra) # 80001b72 <proc_mapstacks>
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
extern void forkret(void);
static void freeproc(struct proc *p);


//add a proccess to the end of the list
void add(struct headList * list , struct proc * new_proc){
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	0080                	addi	s0,sp,64
    80001850:	84aa                	mv	s1,a0
    80001852:	892e                	mv	s2,a1
    //printf("try to add proc num: %d\n" , new_proc);
    acquire(&list->lock);
    80001854:	01050a13          	addi	s4,a0,16
    80001858:	8552                	mv	a0,s4
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	38a080e7          	jalr	906(ra) # 80000be4 <acquire>

    //case the queue is empty
    if(list->tail == 0){
    80001862:	0084b983          	ld	s3,8(s1)
    80001866:	04098263          	beqz	s3,800018aa <add+0x6c>
      list->tail = new_proc;
      release(&list->lock);
      return;
    }
    struct proc *p = list->tail; 
    acquire(&p->list_lock);
    8000186a:	04898a93          	addi	s5,s3,72 # 1048 <_entry-0x7fffefb8>
    8000186e:	8556                	mv	a0,s5
    80001870:	fffff097          	auipc	ra,0xfffff
    80001874:	374080e7          	jalr	884(ra) # 80000be4 <acquire>
    release(&list->lock);
    80001878:	8552                	mv	a0,s4
    8000187a:	fffff097          	auipc	ra,0xfffff
    8000187e:	41e080e7          	jalr	1054(ra) # 80000c98 <release>
    p->next = new_proc;
    80001882:	0329bc23          	sd	s2,56(s3)
    list->tail = new_proc;
    80001886:	0124b423          	sd	s2,8(s1)
    new_proc->next = 0 ; 
    8000188a:	02093c23          	sd	zero,56(s2) # 1038 <_entry-0x7fffefc8>
    release(&p->list_lock);
    8000188e:	8556                	mv	a0,s5
    80001890:	fffff097          	auipc	ra,0xfffff
    80001894:	408080e7          	jalr	1032(ra) # 80000c98 <release>
    
    //printf("add proc num: %d succsesfuly\n" , new_proc);
}
    80001898:	70e2                	ld	ra,56(sp)
    8000189a:	7442                	ld	s0,48(sp)
    8000189c:	74a2                	ld	s1,40(sp)
    8000189e:	7902                	ld	s2,32(sp)
    800018a0:	69e2                	ld	s3,24(sp)
    800018a2:	6a42                	ld	s4,16(sp)
    800018a4:	6aa2                	ld	s5,8(sp)
    800018a6:	6121                	addi	sp,sp,64
    800018a8:	8082                	ret
      list->head = new_proc;
    800018aa:	0124b023          	sd	s2,0(s1)
      list->tail = new_proc;
    800018ae:	0124b423          	sd	s2,8(s1)
      release(&list->lock);
    800018b2:	8552                	mv	a0,s4
    800018b4:	fffff097          	auipc	ra,0xfffff
    800018b8:	3e4080e7          	jalr	996(ra) # 80000c98 <release>
      return;
    800018bc:	bff1                	j	80001898 <add+0x5a>

00000000800018be <remove>:

//remove the first element from the list 
struct proc* remove(struct headList *list){
    800018be:	7139                	addi	sp,sp,-64
    800018c0:	fc06                	sd	ra,56(sp)
    800018c2:	f822                	sd	s0,48(sp)
    800018c4:	f426                	sd	s1,40(sp)
    800018c6:	f04a                	sd	s2,32(sp)
    800018c8:	ec4e                	sd	s3,24(sp)
    800018ca:	e852                	sd	s4,16(sp)
    800018cc:	e456                	sd	s5,8(sp)
    800018ce:	0080                	addi	s0,sp,64
    800018d0:	84aa                	mv	s1,a0
  struct proc* output = 0; 
  acquire(&list->lock);
    800018d2:	01050993          	addi	s3,a0,16
    800018d6:	854e                	mv	a0,s3
    800018d8:	fffff097          	auipc	ra,0xfffff
    800018dc:	30c080e7          	jalr	780(ra) # 80000be4 <acquire>

  //case of empty quequ 
  if(list->head == 0){
    800018e0:	0004b903          	ld	s2,0(s1)
    800018e4:	04090563          	beqz	s2,8000192e <remove+0x70>
    release(&list->lock);
    return 0;
  }

  struct proc *p = list->head; 
  acquire(&p->list_lock);
    800018e8:	04890a13          	addi	s4,s2,72
    800018ec:	8552                	mv	a0,s4
    800018ee:	fffff097          	auipc	ra,0xfffff
    800018f2:	2f6080e7          	jalr	758(ra) # 80000be4 <acquire>
  output = list->head;
    800018f6:	0004ba83          	ld	s5,0(s1)
  list->head = p->next; 
    800018fa:	03893783          	ld	a5,56(s2)
    800018fe:	e09c                	sd	a5,0(s1)

  //case of removing the last element
  if(p->next == 0)
    80001900:	cf95                	beqz	a5,8000193c <remove+0x7e>
    list->tail = 0;

  p->next = 0;
    80001902:	02093c23          	sd	zero,56(s2)
  release(&p->list_lock);
    80001906:	8552                	mv	a0,s4
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	390080e7          	jalr	912(ra) # 80000c98 <release>
  release(&list->lock);
    80001910:	854e                	mv	a0,s3
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	386080e7          	jalr	902(ra) # 80000c98 <release>

  return output;
} 
    8000191a:	8556                	mv	a0,s5
    8000191c:	70e2                	ld	ra,56(sp)
    8000191e:	7442                	ld	s0,48(sp)
    80001920:	74a2                	ld	s1,40(sp)
    80001922:	7902                	ld	s2,32(sp)
    80001924:	69e2                	ld	s3,24(sp)
    80001926:	6a42                	ld	s4,16(sp)
    80001928:	6aa2                	ld	s5,8(sp)
    8000192a:	6121                	addi	sp,sp,64
    8000192c:	8082                	ret
    release(&list->lock);
    8000192e:	854e                	mv	a0,s3
    80001930:	fffff097          	auipc	ra,0xfffff
    80001934:	368080e7          	jalr	872(ra) # 80000c98 <release>
    return 0;
    80001938:	8aca                	mv	s5,s2
    8000193a:	b7c5                	j	8000191a <remove+0x5c>
    list->tail = 0;
    8000193c:	0004b423          	sd	zero,8(s1)
    80001940:	b7c9                	j	80001902 <remove+0x44>

0000000080001942 <remove_index1>:

//remove procces with  specifec index
 void remove_index1(struct headList *list , int ind){
    80001942:	7179                	addi	sp,sp,-48
    80001944:	f406                	sd	ra,40(sp)
    80001946:	f022                	sd	s0,32(sp)
    80001948:	ec26                	sd	s1,24(sp)
    8000194a:	e84a                	sd	s2,16(sp)
    8000194c:	e44e                	sd	s3,8(sp)
    8000194e:	1800                	addi	s0,sp,48
    80001950:	892a                	mv	s2,a0
    80001952:	84ae                	mv	s1,a1
  //TODO change the implimntion to not lock all the list
  acquire(&list->lock);
    80001954:	01050993          	addi	s3,a0,16
    80001958:	854e                	mv	a0,s3
    8000195a:	fffff097          	auipc	ra,0xfffff
    8000195e:	28a080e7          	jalr	650(ra) # 80000be4 <acquire>
  if(list->head == 0){
    80001962:	00093783          	ld	a5,0(s2)
    release(&list->lock);
    return;
  }
    
  struct proc *prev = 0;
    80001966:	4681                	li	a3,0
  if(list->head == 0){
    80001968:	eb89                	bnez	a5,8000197a <remove_index1+0x38>
    release(&list->lock);
    8000196a:	854e                	mv	a0,s3
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	32c080e7          	jalr	812(ra) # 80000c98 <release>
    return;
    80001974:	a805                	j	800019a4 <remove_index1+0x62>
 void remove_index1(struct headList *list , int ind){
    80001976:	86be                	mv	a3,a5
    80001978:	87ba                	mv	a5,a4
  struct proc *curr = list->head; 
  while((curr->next != 0 ) || (curr->index != ind) ){
    8000197a:	7f98                	ld	a4,56(a5)
    8000197c:	ff6d                	bnez	a4,80001976 <remove_index1+0x34>
    8000197e:	43b0                	lw	a2,64(a5)
    80001980:	fe961be3          	bne	a2,s1,80001976 <remove_index1+0x34>
    prev = curr; 
    curr = curr->next;
  }
  if(curr->index == ind){
    if(prev == 0){
    80001984:	c69d                	beqz	a3,800019b2 <remove_index1+0x70>
      list->head = curr->next; 
    }
    else{
    prev->next = curr->next;
    80001986:	0206bc23          	sd	zero,56(a3) # 1038 <_entry-0x7fffefc8>
    }
    if(curr->index == list->tail->index){
    8000198a:	00893703          	ld	a4,8(s2)
    8000198e:	43b0                	lw	a2,64(a5)
    80001990:	4338                	lw	a4,64(a4)
    80001992:	02e60363          	beq	a2,a4,800019b8 <remove_index1+0x76>
      list->tail = prev;
    }
    curr->next = 0; 
    80001996:	0207bc23          	sd	zero,56(a5)
    }
  release(&list->lock);
    8000199a:	854e                	mv	a0,s3
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	2fc080e7          	jalr	764(ra) # 80000c98 <release>

}
    800019a4:	70a2                	ld	ra,40(sp)
    800019a6:	7402                	ld	s0,32(sp)
    800019a8:	64e2                	ld	s1,24(sp)
    800019aa:	6942                	ld	s2,16(sp)
    800019ac:	69a2                	ld	s3,8(sp)
    800019ae:	6145                	addi	sp,sp,48
    800019b0:	8082                	ret
      list->head = curr->next; 
    800019b2:	00093023          	sd	zero,0(s2)
    800019b6:	bfd1                	j	8000198a <remove_index1+0x48>
      list->tail = prev;
    800019b8:	00d93423          	sd	a3,8(s2)
    800019bc:	bfe9                	j	80001996 <remove_index1+0x54>

00000000800019be <remove_index>:

 void remove_index(struct headList *list , int ind){
    800019be:	715d                	addi	sp,sp,-80
    800019c0:	e486                	sd	ra,72(sp)
    800019c2:	e0a2                	sd	s0,64(sp)
    800019c4:	fc26                	sd	s1,56(sp)
    800019c6:	f84a                	sd	s2,48(sp)
    800019c8:	f44e                	sd	s3,40(sp)
    800019ca:	f052                	sd	s4,32(sp)
    800019cc:	ec56                	sd	s5,24(sp)
    800019ce:	e85a                	sd	s6,16(sp)
    800019d0:	e45e                	sd	s7,8(sp)
    800019d2:	0880                	addi	s0,sp,80
    800019d4:	8baa                	mv	s7,a0
    800019d6:	8b2e                	mv	s6,a1
  //TODO change the implimntion to not lock all the list
  struct spinlock * l1 = &list->lock; 
    800019d8:	01050a93          	addi	s5,a0,16
  
  acquire(l1);
    800019dc:	8556                	mv	a0,s5
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	206080e7          	jalr	518(ra) # 80000be4 <acquire>
  if(list->head == 0){
    800019e6:	000bb483          	ld	s1,0(s7) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800019ea:	c4a1                	beqz	s1,80001a32 <remove_index+0x74>
  }

 
  struct proc *prev = 0;
  struct proc *curr = list->head; 
  struct spinlock * l2 = &curr->list_lock;
    800019ec:	04848a13          	addi	s4,s1,72
  acquire(l2);
    800019f0:	8552                	mv	a0,s4
    800019f2:	fffff097          	auipc	ra,0xfffff
    800019f6:	1f2080e7          	jalr	498(ra) # 80000be4 <acquire>

  while(curr->next != 0 && curr->index != ind){
    800019fa:	7c9c                	ld	a5,56(s1)
  struct proc *prev = 0;
    800019fc:	4681                	li	a3,0
  while(curr->next != 0 && curr->index != ind){
    800019fe:	cbbd                	beqz	a5,80001a74 <remove_index+0xb6>
    80001a00:	40b8                	lw	a4,64(s1)
    80001a02:	05670c63          	beq	a4,s6,80001a5a <remove_index+0x9c>
    release(l1); 
    80001a06:	8556                	mv	a0,s5
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	290080e7          	jalr	656(ra) # 80000c98 <release>
    l1 = l2; 
    prev = curr; 
    curr = curr->next;
    80001a10:	0384b903          	ld	s2,56(s1)
    l2 = &curr->list_lock;
    80001a14:	04890993          	addi	s3,s2,72
    acquire(l2); 
    80001a18:	854e                	mv	a0,s3
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	1ca080e7          	jalr	458(ra) # 80000be4 <acquire>
  while(curr->next != 0 && curr->index != ind){
    80001a22:	03893783          	ld	a5,56(s2)
    80001a26:	8ad2                	mv	s5,s4
    80001a28:	86a6                	mv	a3,s1
    80001a2a:	cbb9                	beqz	a5,80001a80 <remove_index+0xc2>
    l2 = &curr->list_lock;
    80001a2c:	8a4e                	mv	s4,s3
    curr = curr->next;
    80001a2e:	84ca                	mv	s1,s2
    80001a30:	bfc1                	j	80001a00 <remove_index+0x42>
    release(l1);
    80001a32:	8556                	mv	a0,s5
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	264080e7          	jalr	612(ra) # 80000c98 <release>
    return;
    80001a3c:	a085                	j	80001a9c <remove_index+0xde>
  struct proc *prev = 0;
    80001a3e:	86be                	mv	a3,a5
  }

  if(curr->index == ind){

    if(prev == 0){
      list->head = curr->next;  
    80001a40:	00fbb023          	sd	a5,0(s7)
    80001a44:	89d2                	mv	s3,s4
    80001a46:	8a56                	mv	s4,s5
    80001a48:	a829                	j	80001a62 <remove_index+0xa4>
  if(curr->index == ind){
    80001a4a:	86a6                	mv	a3,s1
    curr = curr->next;
    80001a4c:	84ca                	mv	s1,s2
  if(curr->index == ind){
    80001a4e:	8ad2                	mv	s5,s4
    l2 = &curr->list_lock;
    80001a50:	8a4e                	mv	s4,s3
    80001a52:	a029                	j	80001a5c <remove_index+0x9e>
    else{
      prev->next = curr->next;
    }

    if(curr->index == list->tail->index){
      list->tail = prev;
    80001a54:	00dbb423          	sd	a3,8(s7)
    80001a58:	a819                	j	80001a6e <remove_index+0xb0>
    if(prev == 0){
    80001a5a:	d2fd                	beqz	a3,80001a40 <remove_index+0x82>
      prev->next = curr->next;
    80001a5c:	fe9c                	sd	a5,56(a3)
    80001a5e:	89d2                	mv	s3,s4
    80001a60:	8a56                	mv	s4,s5
    if(curr->index == list->tail->index){
    80001a62:	008bb783          	ld	a5,8(s7)
    80001a66:	40b8                	lw	a4,64(s1)
    80001a68:	43bc                	lw	a5,64(a5)
    80001a6a:	fef705e3          	beq	a4,a5,80001a54 <remove_index+0x96>
    }
  
    curr->next = 0;
    80001a6e:	0204bc23          	sd	zero,56(s1)
    80001a72:	a819                	j	80001a88 <remove_index+0xca>
  if(curr->index == ind){
    80001a74:	40b8                	lw	a4,64(s1)
    80001a76:	fd6704e3          	beq	a4,s6,80001a3e <remove_index+0x80>
  struct spinlock * l2 = &curr->list_lock;
    80001a7a:	89d2                	mv	s3,s4
  struct spinlock * l1 = &list->lock; 
    80001a7c:	8a56                	mv	s4,s5
    80001a7e:	a029                	j	80001a88 <remove_index+0xca>
  if(curr->index == ind){
    80001a80:	04092703          	lw	a4,64(s2)
    80001a84:	fd6703e3          	beq	a4,s6,80001a4a <remove_index+0x8c>
  }
    release(l1);
    80001a88:	8552                	mv	a0,s4
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	20e080e7          	jalr	526(ra) # 80000c98 <release>
    release(l2);
    80001a92:	854e                	mv	a0,s3
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	204080e7          	jalr	516(ra) # 80000c98 <release>
}
    80001a9c:	60a6                	ld	ra,72(sp)
    80001a9e:	6406                	ld	s0,64(sp)
    80001aa0:	74e2                	ld	s1,56(sp)
    80001aa2:	7942                	ld	s2,48(sp)
    80001aa4:	79a2                	ld	s3,40(sp)
    80001aa6:	7a02                	ld	s4,32(sp)
    80001aa8:	6ae2                	ld	s5,24(sp)
    80001aaa:	6b42                	ld	s6,16(sp)
    80001aac:	6ba2                	ld	s7,8(sp)
    80001aae:	6161                	addi	sp,sp,80
    80001ab0:	8082                	ret

0000000080001ab2 <printList>:
  release(&list->lock);
  return to_remove;
}
*/

void printList(struct headList* list){
    80001ab2:	7179                	addi	sp,sp,-48
    80001ab4:	f406                	sd	ra,40(sp)
    80001ab6:	f022                	sd	s0,32(sp)
    80001ab8:	ec26                	sd	s1,24(sp)
    80001aba:	e84a                	sd	s2,16(sp)
    80001abc:	e44e                	sd	s3,8(sp)
    80001abe:	1800                	addi	s0,sp,48
    80001ac0:	84aa                	mv	s1,a0
  acquire(&list->lock);
    80001ac2:	01050993          	addi	s3,a0,16
    80001ac6:	854e                	mv	a0,s3
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	11c080e7          	jalr	284(ra) # 80000be4 <acquire>
  printf("the list: ");
    80001ad0:	00006517          	auipc	a0,0x6
    80001ad4:	70850513          	addi	a0,a0,1800 # 800081d8 <digits+0x198>
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	ab0080e7          	jalr	-1360(ra) # 80000588 <printf>
  if(list->head == 0){
    80001ae0:	6084                	ld	s1,0(s1)
    printf("empty\n");
    return;
  }
  struct proc *p = list->head;
  while(p != 0 ){ 
    printf("%d " , p->index); 
    80001ae2:	00006917          	auipc	s2,0x6
    80001ae6:	70e90913          	addi	s2,s2,1806 # 800081f0 <digits+0x1b0>
  if(list->head == 0){
    80001aea:	cc8d                	beqz	s1,80001b24 <printList+0x72>
    printf("%d " , p->index); 
    80001aec:	40ac                	lw	a1,64(s1)
    80001aee:	854a                	mv	a0,s2
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	a98080e7          	jalr	-1384(ra) # 80000588 <printf>
    p = p->next;
    80001af8:	7c84                	ld	s1,56(s1)
  while(p != 0 ){ 
    80001afa:	f8ed                	bnez	s1,80001aec <printList+0x3a>
  }

  printf("\n"); 
    80001afc:	00006517          	auipc	a0,0x6
    80001b00:	5cc50513          	addi	a0,a0,1484 # 800080c8 <digits+0x88>
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	a84080e7          	jalr	-1404(ra) # 80000588 <printf>
  release(&list->lock);
    80001b0c:	854e                	mv	a0,s3
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	18a080e7          	jalr	394(ra) # 80000c98 <release>
  
}
    80001b16:	70a2                	ld	ra,40(sp)
    80001b18:	7402                	ld	s0,32(sp)
    80001b1a:	64e2                	ld	s1,24(sp)
    80001b1c:	6942                	ld	s2,16(sp)
    80001b1e:	69a2                	ld	s3,8(sp)
    80001b20:	6145                	addi	sp,sp,48
    80001b22:	8082                	ret
    printf("empty\n");
    80001b24:	00006517          	auipc	a0,0x6
    80001b28:	6c450513          	addi	a0,a0,1732 # 800081e8 <digits+0x1a8>
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	a5c080e7          	jalr	-1444(ra) # 80000588 <printf>
    return;
    80001b34:	b7cd                	j	80001b16 <printList+0x64>

0000000080001b36 <get_cpu>:
  release(&p->lock);
  yield();
  return cpu_num;
}

int get_cpu(){
    80001b36:	1141                	addi	sp,sp,-16
    80001b38:	e422                	sd	s0,8(sp)
    80001b3a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b3c:	8512                	mv	a0,tp
  return cpuid();
}
    80001b3e:	2501                	sext.w	a0,a0
    80001b40:	6422                	ld	s0,8(sp)
    80001b42:	0141                	addi	sp,sp,16
    80001b44:	8082                	ret

0000000080001b46 <cpu_process_count>:

int cpu_process_count(int cpu_num){
    80001b46:	1141                	addi	sp,sp,-16
    80001b48:	e422                	sd	s0,8(sp)
    80001b4a:	0800                	addi	s0,sp,16
  if(cpu_num > CPUS || cpu_num < 0)
    80001b4c:	478d                	li	a5,3
    80001b4e:	02a7e063          	bltu	a5,a0,80001b6e <cpu_process_count+0x28>
    return -1;
  return cpus[cpu_num].n_proc;
    80001b52:	00451793          	slli	a5,a0,0x4
    80001b56:	97aa                	add	a5,a5,a0
    80001b58:	078e                	slli	a5,a5,0x3
    80001b5a:	0000f717          	auipc	a4,0xf
    80001b5e:	74670713          	addi	a4,a4,1862 # 800112a0 <cpus>
    80001b62:	97ba                	add	a5,a5,a4
    80001b64:	0847a503          	lw	a0,132(a5)
}
    80001b68:	6422                	ld	s0,8(sp)
    80001b6a:	0141                	addi	sp,sp,16
    80001b6c:	8082                	ret
    return -1;
    80001b6e:	557d                	li	a0,-1
    80001b70:	bfe5                	j	80001b68 <cpu_process_count+0x22>

0000000080001b72 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001b72:	7139                	addi	sp,sp,-64
    80001b74:	fc06                	sd	ra,56(sp)
    80001b76:	f822                	sd	s0,48(sp)
    80001b78:	f426                	sd	s1,40(sp)
    80001b7a:	f04a                	sd	s2,32(sp)
    80001b7c:	ec4e                	sd	s3,24(sp)
    80001b7e:	e852                	sd	s4,16(sp)
    80001b80:	e456                	sd	s5,8(sp)
    80001b82:	e05a                	sd	s6,0(sp)
    80001b84:	0080                	addi	s0,sp,64
    80001b86:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b88:	00010497          	auipc	s1,0x10
    80001b8c:	d4048493          	addi	s1,s1,-704 # 800118c8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001b90:	8b26                	mv	s6,s1
    80001b92:	00006a97          	auipc	s5,0x6
    80001b96:	46ea8a93          	addi	s5,s5,1134 # 80008000 <etext>
    80001b9a:	04000937          	lui	s2,0x4000
    80001b9e:	197d                	addi	s2,s2,-1
    80001ba0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ba2:	00016a17          	auipc	s4,0x16
    80001ba6:	126a0a13          	addi	s4,s4,294 # 80017cc8 <tickslock>
    char *pa = kalloc();
    80001baa:	fffff097          	auipc	ra,0xfffff
    80001bae:	f4a080e7          	jalr	-182(ra) # 80000af4 <kalloc>
    80001bb2:	862a                	mv	a2,a0
    if(pa == 0)
    80001bb4:	c131                	beqz	a0,80001bf8 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001bb6:	416485b3          	sub	a1,s1,s6
    80001bba:	8591                	srai	a1,a1,0x4
    80001bbc:	000ab783          	ld	a5,0(s5)
    80001bc0:	02f585b3          	mul	a1,a1,a5
    80001bc4:	2585                	addiw	a1,a1,1
    80001bc6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bca:	4719                	li	a4,6
    80001bcc:	6685                	lui	a3,0x1
    80001bce:	40b905b3          	sub	a1,s2,a1
    80001bd2:	854e                	mv	a0,s3
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	57c080e7          	jalr	1404(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	19048493          	addi	s1,s1,400
    80001be0:	fd4495e3          	bne	s1,s4,80001baa <proc_mapstacks+0x38>
  }
}
    80001be4:	70e2                	ld	ra,56(sp)
    80001be6:	7442                	ld	s0,48(sp)
    80001be8:	74a2                	ld	s1,40(sp)
    80001bea:	7902                	ld	s2,32(sp)
    80001bec:	69e2                	ld	s3,24(sp)
    80001bee:	6a42                	ld	s4,16(sp)
    80001bf0:	6aa2                	ld	s5,8(sp)
    80001bf2:	6b02                	ld	s6,0(sp)
    80001bf4:	6121                	addi	sp,sp,64
    80001bf6:	8082                	ret
      panic("kalloc");
    80001bf8:	00006517          	auipc	a0,0x6
    80001bfc:	60050513          	addi	a0,a0,1536 # 800081f8 <digits+0x1b8>
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	93e080e7          	jalr	-1730(ra) # 8000053e <panic>

0000000080001c08 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001c08:	711d                	addi	sp,sp,-96
    80001c0a:	ec86                	sd	ra,88(sp)
    80001c0c:	e8a2                	sd	s0,80(sp)
    80001c0e:	e4a6                	sd	s1,72(sp)
    80001c10:	e0ca                	sd	s2,64(sp)
    80001c12:	fc4e                	sd	s3,56(sp)
    80001c14:	f852                	sd	s4,48(sp)
    80001c16:	f456                	sd	s5,40(sp)
    80001c18:	f05a                	sd	s6,32(sp)
    80001c1a:	ec5e                	sd	s7,24(sp)
    80001c1c:	e862                	sd	s8,16(sp)
    80001c1e:	e466                	sd	s9,8(sp)
    80001c20:	1080                	addi	s0,sp,96
  struct proc *p;
  int i = 0; 
  for(int j = 0 ; j < NCPU ; j++){
    80001c22:	00010497          	auipc	s1,0x10
    80001c26:	ace48493          	addi	s1,s1,-1330 # 800116f0 <readyQueus+0x10>
    80001c2a:	0000f997          	auipc	s3,0xf
    80001c2e:	67698993          	addi	s3,s3,1654 # 800112a0 <cpus>
    80001c32:	4901                	li	s2,0
    readyQueus[j].head = 0; 
    readyQueus[j].tail = 0;
    initlock(&readyQueus[j].lock , "cpu");
    80001c34:	00006a97          	auipc	s5,0x6
    80001c38:	5cca8a93          	addi	s5,s5,1484 # 80008200 <digits+0x1c0>
  for(int j = 0 ; j < NCPU ; j++){
    80001c3c:	4a21                	li	s4,8
    readyQueus[j].head = 0; 
    80001c3e:	fe04b823          	sd	zero,-16(s1)
    readyQueus[j].tail = 0;
    80001c42:	fe04bc23          	sd	zero,-8(s1)
    initlock(&readyQueus[j].lock , "cpu");
    80001c46:	85d6                	mv	a1,s5
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	f0a080e7          	jalr	-246(ra) # 80000b54 <initlock>
    cpus[j].index = j ;
    80001c52:	0929a023          	sw	s2,128(s3)
    cpus[j].n_proc = 0 ;
    80001c56:	0809a223          	sw	zero,132(s3)
  for(int j = 0 ; j < NCPU ; j++){
    80001c5a:	2905                	addiw	s2,s2,1
    80001c5c:	02848493          	addi	s1,s1,40
    80001c60:	08898993          	addi	s3,s3,136
    80001c64:	fd491de3          	bne	s2,s4,80001c3e <procinit+0x36>
  }
  initlock(&zombies.lock , "zombies");
    80001c68:	00006597          	auipc	a1,0x6
    80001c6c:	5a058593          	addi	a1,a1,1440 # 80008208 <digits+0x1c8>
    80001c70:	00010517          	auipc	a0,0x10
    80001c74:	bc050513          	addi	a0,a0,-1088 # 80011830 <zombies+0x10>
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	edc080e7          	jalr	-292(ra) # 80000b54 <initlock>
  initlock(&sleeping.lock , "sleepings;");
    80001c80:	00006597          	auipc	a1,0x6
    80001c84:	59058593          	addi	a1,a1,1424 # 80008210 <digits+0x1d0>
    80001c88:	00010517          	auipc	a0,0x10
    80001c8c:	bd050513          	addi	a0,a0,-1072 # 80011858 <sleeping+0x10>
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ec4080e7          	jalr	-316(ra) # 80000b54 <initlock>
  initlock(&unusing.lock , "unsing");
    80001c98:	00006597          	auipc	a1,0x6
    80001c9c:	58858593          	addi	a1,a1,1416 # 80008220 <digits+0x1e0>
    80001ca0:	00010517          	auipc	a0,0x10
    80001ca4:	be050513          	addi	a0,a0,-1056 # 80011880 <unusing+0x10>
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	eac080e7          	jalr	-340(ra) # 80000b54 <initlock>
  
  initlock(&pid_lock, "nextpid");
    80001cb0:	00006597          	auipc	a1,0x6
    80001cb4:	57858593          	addi	a1,a1,1400 # 80008228 <digits+0x1e8>
    80001cb8:	00010517          	auipc	a0,0x10
    80001cbc:	be050513          	addi	a0,a0,-1056 # 80011898 <pid_lock>
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	e94080e7          	jalr	-364(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001cc8:	00006597          	auipc	a1,0x6
    80001ccc:	56858593          	addi	a1,a1,1384 # 80008230 <digits+0x1f0>
    80001cd0:	00010517          	auipc	a0,0x10
    80001cd4:	be050513          	addi	a0,a0,-1056 # 800118b0 <wait_lock>
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	e7c080e7          	jalr	-388(ra) # 80000b54 <initlock>
  int i = 0; 
    80001ce0:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce2:	00010497          	auipc	s1,0x10
    80001ce6:	be648493          	addi	s1,s1,-1050 # 800118c8 <proc>
      initlock(&p->lock, "proc");
    80001cea:	00006c97          	auipc	s9,0x6
    80001cee:	556c8c93          	addi	s9,s9,1366 # 80008240 <digits+0x200>
      initlock(&p->list_lock, "list_lock");
    80001cf2:	00006c17          	auipc	s8,0x6
    80001cf6:	556c0c13          	addi	s8,s8,1366 # 80008248 <digits+0x208>
      p->kstack = KSTACK((int) (p - proc));
    80001cfa:	8ba6                	mv	s7,s1
    80001cfc:	00006b17          	auipc	s6,0x6
    80001d00:	304b0b13          	addi	s6,s6,772 # 80008000 <etext>
    80001d04:	040009b7          	lui	s3,0x4000
    80001d08:	19fd                	addi	s3,s3,-1
    80001d0a:	09b2                	slli	s3,s3,0xc
      p->index = i++;
      p->next = 0;
      p->cpu = 0; 
      add(&unusing , p);
    80001d0c:	00010a97          	auipc	s5,0x10
    80001d10:	b64a8a93          	addi	s5,s5,-1180 # 80011870 <unusing>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d14:	00016a17          	auipc	s4,0x16
    80001d18:	fb4a0a13          	addi	s4,s4,-76 # 80017cc8 <tickslock>
      initlock(&p->lock, "proc");
    80001d1c:	85e6                	mv	a1,s9
    80001d1e:	8526                	mv	a0,s1
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	e34080e7          	jalr	-460(ra) # 80000b54 <initlock>
      initlock(&p->list_lock, "list_lock");
    80001d28:	85e2                	mv	a1,s8
    80001d2a:	04848513          	addi	a0,s1,72
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	e26080e7          	jalr	-474(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001d36:	417487b3          	sub	a5,s1,s7
    80001d3a:	8791                	srai	a5,a5,0x4
    80001d3c:	000b3703          	ld	a4,0(s6)
    80001d40:	02e787b3          	mul	a5,a5,a4
    80001d44:	2785                	addiw	a5,a5,1
    80001d46:	00d7979b          	slliw	a5,a5,0xd
    80001d4a:	40f987b3          	sub	a5,s3,a5
    80001d4e:	f4bc                	sd	a5,104(s1)
      p->index = i++;
    80001d50:	0524a023          	sw	s2,64(s1)
    80001d54:	2905                	addiw	s2,s2,1
      p->next = 0;
    80001d56:	0204bc23          	sd	zero,56(s1)
      p->cpu = 0; 
    80001d5a:	0204aa23          	sw	zero,52(s1)
      add(&unusing , p);
    80001d5e:	85a6                	mv	a1,s1
    80001d60:	8556                	mv	a0,s5
    80001d62:	00000097          	auipc	ra,0x0
    80001d66:	adc080e7          	jalr	-1316(ra) # 8000183e <add>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d6a:	19048493          	addi	s1,s1,400
    80001d6e:	fb4497e3          	bne	s1,s4,80001d1c <procinit+0x114>
  }   

}
    80001d72:	60e6                	ld	ra,88(sp)
    80001d74:	6446                	ld	s0,80(sp)
    80001d76:	64a6                	ld	s1,72(sp)
    80001d78:	6906                	ld	s2,64(sp)
    80001d7a:	79e2                	ld	s3,56(sp)
    80001d7c:	7a42                	ld	s4,48(sp)
    80001d7e:	7aa2                	ld	s5,40(sp)
    80001d80:	7b02                	ld	s6,32(sp)
    80001d82:	6be2                	ld	s7,24(sp)
    80001d84:	6c42                	ld	s8,16(sp)
    80001d86:	6ca2                	ld	s9,8(sp)
    80001d88:	6125                	addi	sp,sp,96
    80001d8a:	8082                	ret

0000000080001d8c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001d8c:	1141                	addi	sp,sp,-16
    80001d8e:	e422                	sd	s0,8(sp)
    80001d90:	0800                	addi	s0,sp,16
    80001d92:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d94:	2501                	sext.w	a0,a0
    80001d96:	6422                	ld	s0,8(sp)
    80001d98:	0141                	addi	sp,sp,16
    80001d9a:	8082                	ret

0000000080001d9c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu* 
mycpu(void) {
    80001d9c:	1141                	addi	sp,sp,-16
    80001d9e:	e422                	sd	s0,8(sp)
    80001da0:	0800                	addi	s0,sp,16
    80001da2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001da4:	0007851b          	sext.w	a0,a5
    80001da8:	00451793          	slli	a5,a0,0x4
    80001dac:	97aa                	add	a5,a5,a0
    80001dae:	078e                	slli	a5,a5,0x3
  return c;
}
    80001db0:	0000f517          	auipc	a0,0xf
    80001db4:	4f050513          	addi	a0,a0,1264 # 800112a0 <cpus>
    80001db8:	953e                	add	a0,a0,a5
    80001dba:	6422                	ld	s0,8(sp)
    80001dbc:	0141                	addi	sp,sp,16
    80001dbe:	8082                	ret

0000000080001dc0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001dc0:	1101                	addi	sp,sp,-32
    80001dc2:	ec06                	sd	ra,24(sp)
    80001dc4:	e822                	sd	s0,16(sp)
    80001dc6:	e426                	sd	s1,8(sp)
    80001dc8:	1000                	addi	s0,sp,32
  push_off();
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	dce080e7          	jalr	-562(ra) # 80000b98 <push_off>
    80001dd2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001dd4:	0007871b          	sext.w	a4,a5
    80001dd8:	00471793          	slli	a5,a4,0x4
    80001ddc:	97ba                	add	a5,a5,a4
    80001dde:	078e                	slli	a5,a5,0x3
    80001de0:	0000f717          	auipc	a4,0xf
    80001de4:	4c070713          	addi	a4,a4,1216 # 800112a0 <cpus>
    80001de8:	97ba                	add	a5,a5,a4
    80001dea:	6384                	ld	s1,0(a5)
  pop_off();
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	e4c080e7          	jalr	-436(ra) # 80000c38 <pop_off>
  return p;
}
    80001df4:	8526                	mv	a0,s1
    80001df6:	60e2                	ld	ra,24(sp)
    80001df8:	6442                	ld	s0,16(sp)
    80001dfa:	64a2                	ld	s1,8(sp)
    80001dfc:	6105                	addi	sp,sp,32
    80001dfe:	8082                	ret

0000000080001e00 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001e00:	1141                	addi	sp,sp,-16
    80001e02:	e406                	sd	ra,8(sp)
    80001e04:	e022                	sd	s0,0(sp)
    80001e06:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001e08:	00000097          	auipc	ra,0x0
    80001e0c:	fb8080e7          	jalr	-72(ra) # 80001dc0 <myproc>
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	e88080e7          	jalr	-376(ra) # 80000c98 <release>

  if (first) {
    80001e18:	00007797          	auipc	a5,0x7
    80001e1c:	a687a783          	lw	a5,-1432(a5) # 80008880 <first.1759>
    80001e20:	eb89                	bnez	a5,80001e32 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001e22:	00001097          	auipc	ra,0x1
    80001e26:	eaa080e7          	jalr	-342(ra) # 80002ccc <usertrapret>
}
    80001e2a:	60a2                	ld	ra,8(sp)
    80001e2c:	6402                	ld	s0,0(sp)
    80001e2e:	0141                	addi	sp,sp,16
    80001e30:	8082                	ret
    first = 0;
    80001e32:	00007797          	auipc	a5,0x7
    80001e36:	a407a723          	sw	zero,-1458(a5) # 80008880 <first.1759>
    fsinit(ROOTDEV);
    80001e3a:	4505                	li	a0,1
    80001e3c:	00002097          	auipc	ra,0x2
    80001e40:	c4e080e7          	jalr	-946(ra) # 80003a8a <fsinit>
    80001e44:	bff9                	j	80001e22 <forkret+0x22>

0000000080001e46 <allocpid>:
allocpid() {
    80001e46:	1101                	addi	sp,sp,-32
    80001e48:	ec06                	sd	ra,24(sp)
    80001e4a:	e822                	sd	s0,16(sp)
    80001e4c:	e426                	sd	s1,8(sp)
    80001e4e:	e04a                	sd	s2,0(sp)
    80001e50:	1000                	addi	s0,sp,32
    pid = nextpid; 
    80001e52:	00007917          	auipc	s2,0x7
    80001e56:	a3290913          	addi	s2,s2,-1486 # 80008884 <nextpid>
    80001e5a:	00092483          	lw	s1,0(s2)
  }while(cas(&nextpid , pid , pid + 1)); 
    80001e5e:	0014861b          	addiw	a2,s1,1
    80001e62:	85a6                	mv	a1,s1
    80001e64:	854a                	mv	a0,s2
    80001e66:	00005097          	auipc	ra,0x5
    80001e6a:	a30080e7          	jalr	-1488(ra) # 80006896 <cas>
    80001e6e:	f575                	bnez	a0,80001e5a <allocpid+0x14>
}
    80001e70:	8526                	mv	a0,s1
    80001e72:	60e2                	ld	ra,24(sp)
    80001e74:	6442                	ld	s0,16(sp)
    80001e76:	64a2                	ld	s1,8(sp)
    80001e78:	6902                	ld	s2,0(sp)
    80001e7a:	6105                	addi	sp,sp,32
    80001e7c:	8082                	ret

0000000080001e7e <proc_pagetable>:
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	e04a                	sd	s2,0(sp)
    80001e88:	1000                	addi	s0,sp,32
    80001e8a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	4ae080e7          	jalr	1198(ra) # 8000133a <uvmcreate>
    80001e94:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e96:	c121                	beqz	a0,80001ed6 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e98:	4729                	li	a4,10
    80001e9a:	00005697          	auipc	a3,0x5
    80001e9e:	16668693          	addi	a3,a3,358 # 80007000 <_trampoline>
    80001ea2:	6605                	lui	a2,0x1
    80001ea4:	040005b7          	lui	a1,0x4000
    80001ea8:	15fd                	addi	a1,a1,-1
    80001eaa:	05b2                	slli	a1,a1,0xc
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	204080e7          	jalr	516(ra) # 800010b0 <mappages>
    80001eb4:	02054863          	bltz	a0,80001ee4 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001eb8:	4719                	li	a4,6
    80001eba:	08093683          	ld	a3,128(s2)
    80001ebe:	6605                	lui	a2,0x1
    80001ec0:	020005b7          	lui	a1,0x2000
    80001ec4:	15fd                	addi	a1,a1,-1
    80001ec6:	05b6                	slli	a1,a1,0xd
    80001ec8:	8526                	mv	a0,s1
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	1e6080e7          	jalr	486(ra) # 800010b0 <mappages>
    80001ed2:	02054163          	bltz	a0,80001ef4 <proc_pagetable+0x76>
}
    80001ed6:	8526                	mv	a0,s1
    80001ed8:	60e2                	ld	ra,24(sp)
    80001eda:	6442                	ld	s0,16(sp)
    80001edc:	64a2                	ld	s1,8(sp)
    80001ede:	6902                	ld	s2,0(sp)
    80001ee0:	6105                	addi	sp,sp,32
    80001ee2:	8082                	ret
    uvmfree(pagetable, 0);
    80001ee4:	4581                	li	a1,0
    80001ee6:	8526                	mv	a0,s1
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	64e080e7          	jalr	1614(ra) # 80001536 <uvmfree>
    return 0;
    80001ef0:	4481                	li	s1,0
    80001ef2:	b7d5                	j	80001ed6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ef4:	4681                	li	a3,0
    80001ef6:	4605                	li	a2,1
    80001ef8:	040005b7          	lui	a1,0x4000
    80001efc:	15fd                	addi	a1,a1,-1
    80001efe:	05b2                	slli	a1,a1,0xc
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	374080e7          	jalr	884(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f0a:	4581                	li	a1,0
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	628080e7          	jalr	1576(ra) # 80001536 <uvmfree>
    return 0;
    80001f16:	4481                	li	s1,0
    80001f18:	bf7d                	j	80001ed6 <proc_pagetable+0x58>

0000000080001f1a <proc_freepagetable>:
{
    80001f1a:	1101                	addi	sp,sp,-32
    80001f1c:	ec06                	sd	ra,24(sp)
    80001f1e:	e822                	sd	s0,16(sp)
    80001f20:	e426                	sd	s1,8(sp)
    80001f22:	e04a                	sd	s2,0(sp)
    80001f24:	1000                	addi	s0,sp,32
    80001f26:	84aa                	mv	s1,a0
    80001f28:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f2a:	4681                	li	a3,0
    80001f2c:	4605                	li	a2,1
    80001f2e:	040005b7          	lui	a1,0x4000
    80001f32:	15fd                	addi	a1,a1,-1
    80001f34:	05b2                	slli	a1,a1,0xc
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	340080e7          	jalr	832(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f3e:	4681                	li	a3,0
    80001f40:	4605                	li	a2,1
    80001f42:	020005b7          	lui	a1,0x2000
    80001f46:	15fd                	addi	a1,a1,-1
    80001f48:	05b6                	slli	a1,a1,0xd
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	32a080e7          	jalr	810(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f54:	85ca                	mv	a1,s2
    80001f56:	8526                	mv	a0,s1
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	5de080e7          	jalr	1502(ra) # 80001536 <uvmfree>
}
    80001f60:	60e2                	ld	ra,24(sp)
    80001f62:	6442                	ld	s0,16(sp)
    80001f64:	64a2                	ld	s1,8(sp)
    80001f66:	6902                	ld	s2,0(sp)
    80001f68:	6105                	addi	sp,sp,32
    80001f6a:	8082                	ret

0000000080001f6c <freeproc>:
{
    80001f6c:	1101                	addi	sp,sp,-32
    80001f6e:	ec06                	sd	ra,24(sp)
    80001f70:	e822                	sd	s0,16(sp)
    80001f72:	e426                	sd	s1,8(sp)
    80001f74:	1000                	addi	s0,sp,32
    80001f76:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f78:	6148                	ld	a0,128(a0)
    80001f7a:	c509                	beqz	a0,80001f84 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	a7c080e7          	jalr	-1412(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001f84:	0804b023          	sd	zero,128(s1)
  if(p->pagetable)
    80001f88:	7ca8                	ld	a0,120(s1)
    80001f8a:	c511                	beqz	a0,80001f96 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f8c:	78ac                	ld	a1,112(s1)
    80001f8e:	00000097          	auipc	ra,0x0
    80001f92:	f8c080e7          	jalr	-116(ra) # 80001f1a <proc_freepagetable>
  remove_index(&zombies , p->index);
    80001f96:	40ac                	lw	a1,64(s1)
    80001f98:	00010517          	auipc	a0,0x10
    80001f9c:	88850513          	addi	a0,a0,-1912 # 80011820 <zombies>
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	a1e080e7          	jalr	-1506(ra) # 800019be <remove_index>
  p->pagetable = 0;
    80001fa8:	0604bc23          	sd	zero,120(s1)
  p->sz = 0;
    80001fac:	0604b823          	sd	zero,112(s1)
  p->pid = 0;
    80001fb0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001fb4:	0604b023          	sd	zero,96(s1)
  p->name[0] = 0;
    80001fb8:	18048023          	sb	zero,384(s1)
  p->chan = 0;
    80001fbc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001fc0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001fc4:	0204a623          	sw	zero,44(s1)
  p->next = 0; 
    80001fc8:	0204bc23          	sd	zero,56(s1)
  p->state = UNUSED;
    80001fcc:	0004ac23          	sw	zero,24(s1)
  add(&unusing , p); 
    80001fd0:	85a6                	mv	a1,s1
    80001fd2:	00010517          	auipc	a0,0x10
    80001fd6:	89e50513          	addi	a0,a0,-1890 # 80011870 <unusing>
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	864080e7          	jalr	-1948(ra) # 8000183e <add>
}
    80001fe2:	60e2                	ld	ra,24(sp)
    80001fe4:	6442                	ld	s0,16(sp)
    80001fe6:	64a2                	ld	s1,8(sp)
    80001fe8:	6105                	addi	sp,sp,32
    80001fea:	8082                	ret

0000000080001fec <allocproc>:
{
    80001fec:	7179                	addi	sp,sp,-48
    80001fee:	f406                	sd	ra,40(sp)
    80001ff0:	f022                	sd	s0,32(sp)
    80001ff2:	ec26                	sd	s1,24(sp)
    80001ff4:	e84a                	sd	s2,16(sp)
    80001ff6:	e44e                	sd	s3,8(sp)
    80001ff8:	1800                	addi	s0,sp,48
  p = remove(&unusing);
    80001ffa:	00010517          	auipc	a0,0x10
    80001ffe:	87650513          	addi	a0,a0,-1930 # 80011870 <unusing>
    80002002:	00000097          	auipc	ra,0x0
    80002006:	8bc080e7          	jalr	-1860(ra) # 800018be <remove>
    8000200a:	84aa                	mv	s1,a0
  if(p == 0)
    8000200c:	cd29                	beqz	a0,80002066 <allocproc+0x7a>
  acquire(&p->lock);
    8000200e:	fffff097          	auipc	ra,0xfffff
    80002012:	bd6080e7          	jalr	-1066(ra) # 80000be4 <acquire>
  p->pid = allocpid();
    80002016:	00000097          	auipc	ra,0x0
    8000201a:	e30080e7          	jalr	-464(ra) # 80001e46 <allocpid>
    8000201e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002020:	4785                	li	a5,1
    80002022:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	ad0080e7          	jalr	-1328(ra) # 80000af4 <kalloc>
    8000202c:	892a                	mv	s2,a0
    8000202e:	e0c8                	sd	a0,128(s1)
    80002030:	c139                	beqz	a0,80002076 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80002032:	8526                	mv	a0,s1
    80002034:	00000097          	auipc	ra,0x0
    80002038:	e4a080e7          	jalr	-438(ra) # 80001e7e <proc_pagetable>
    8000203c:	892a                	mv	s2,a0
    8000203e:	fca8                	sd	a0,120(s1)
  if(p->pagetable == 0){
    80002040:	c539                	beqz	a0,8000208e <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80002042:	07000613          	li	a2,112
    80002046:	4581                	li	a1,0
    80002048:	08848513          	addi	a0,s1,136
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	c94080e7          	jalr	-876(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80002054:	00000797          	auipc	a5,0x0
    80002058:	dac78793          	addi	a5,a5,-596 # 80001e00 <forkret>
    8000205c:	e4dc                	sd	a5,136(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000205e:	74bc                	ld	a5,104(s1)
    80002060:	6705                	lui	a4,0x1
    80002062:	97ba                	add	a5,a5,a4
    80002064:	e8dc                	sd	a5,144(s1)
}
    80002066:	8526                	mv	a0,s1
    80002068:	70a2                	ld	ra,40(sp)
    8000206a:	7402                	ld	s0,32(sp)
    8000206c:	64e2                	ld	s1,24(sp)
    8000206e:	6942                	ld	s2,16(sp)
    80002070:	69a2                	ld	s3,8(sp)
    80002072:	6145                	addi	sp,sp,48
    80002074:	8082                	ret
    freeproc(p);
    80002076:	8526                	mv	a0,s1
    80002078:	00000097          	auipc	ra,0x0
    8000207c:	ef4080e7          	jalr	-268(ra) # 80001f6c <freeproc>
    release(&p->lock);
    80002080:	8526                	mv	a0,s1
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	c16080e7          	jalr	-1002(ra) # 80000c98 <release>
    return 0;
    8000208a:	84ca                	mv	s1,s2
    8000208c:	bfe9                	j	80002066 <allocproc+0x7a>
    freeproc(p);
    8000208e:	8526                	mv	a0,s1
    80002090:	00000097          	auipc	ra,0x0
    80002094:	edc080e7          	jalr	-292(ra) # 80001f6c <freeproc>
    release(&p->lock);
    80002098:	8526                	mv	a0,s1
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	bfe080e7          	jalr	-1026(ra) # 80000c98 <release>
    return 0;
    800020a2:	84ca                	mv	s1,s2
    800020a4:	b7c9                	j	80002066 <allocproc+0x7a>

00000000800020a6 <userinit>:
{
    800020a6:	1101                	addi	sp,sp,-32
    800020a8:	ec06                	sd	ra,24(sp)
    800020aa:	e822                	sd	s0,16(sp)
    800020ac:	e426                	sd	s1,8(sp)
    800020ae:	1000                	addi	s0,sp,32
  p = allocproc();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	f3c080e7          	jalr	-196(ra) # 80001fec <allocproc>
    800020b8:	84aa                	mv	s1,a0
  initproc = p;
    800020ba:	00007797          	auipc	a5,0x7
    800020be:	f6a7b723          	sd	a0,-146(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800020c2:	03400613          	li	a2,52
    800020c6:	00006597          	auipc	a1,0x6
    800020ca:	7ca58593          	addi	a1,a1,1994 # 80008890 <initcode>
    800020ce:	7d28                	ld	a0,120(a0)
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	298080e7          	jalr	664(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    800020d8:	6785                	lui	a5,0x1
    800020da:	f8bc                	sd	a5,112(s1)
  p->trapframe->epc = 0;      // user program counter
    800020dc:	60d8                	ld	a4,128(s1)
    800020de:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800020e2:	60d8                	ld	a4,128(s1)
    800020e4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800020e6:	4641                	li	a2,16
    800020e8:	00006597          	auipc	a1,0x6
    800020ec:	17058593          	addi	a1,a1,368 # 80008258 <digits+0x218>
    800020f0:	18048513          	addi	a0,s1,384
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	d3e080e7          	jalr	-706(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    800020fc:	00006517          	auipc	a0,0x6
    80002100:	16c50513          	addi	a0,a0,364 # 80008268 <digits+0x228>
    80002104:	00002097          	auipc	ra,0x2
    80002108:	3b4080e7          	jalr	948(ra) # 800044b8 <namei>
    8000210c:	16a4bc23          	sd	a0,376(s1)
  p->state = RUNNABLE;
    80002110:	478d                	li	a5,3
    80002112:	cc9c                	sw	a5,24(s1)
  add(&readyQueus[0] , p );
    80002114:	85a6                	mv	a1,s1
    80002116:	0000f517          	auipc	a0,0xf
    8000211a:	5ca50513          	addi	a0,a0,1482 # 800116e0 <readyQueus>
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	720080e7          	jalr	1824(ra) # 8000183e <add>
  release(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	b70080e7          	jalr	-1168(ra) # 80000c98 <release>
}
    80002130:	60e2                	ld	ra,24(sp)
    80002132:	6442                	ld	s0,16(sp)
    80002134:	64a2                	ld	s1,8(sp)
    80002136:	6105                	addi	sp,sp,32
    80002138:	8082                	ret

000000008000213a <growproc>:
{
    8000213a:	1101                	addi	sp,sp,-32
    8000213c:	ec06                	sd	ra,24(sp)
    8000213e:	e822                	sd	s0,16(sp)
    80002140:	e426                	sd	s1,8(sp)
    80002142:	e04a                	sd	s2,0(sp)
    80002144:	1000                	addi	s0,sp,32
    80002146:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	c78080e7          	jalr	-904(ra) # 80001dc0 <myproc>
    80002150:	892a                	mv	s2,a0
  sz = p->sz;
    80002152:	792c                	ld	a1,112(a0)
    80002154:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002158:	00904f63          	bgtz	s1,80002176 <growproc+0x3c>
  } else if(n < 0){
    8000215c:	0204cc63          	bltz	s1,80002194 <growproc+0x5a>
  p->sz = sz;
    80002160:	1602                	slli	a2,a2,0x20
    80002162:	9201                	srli	a2,a2,0x20
    80002164:	06c93823          	sd	a2,112(s2)
  return 0;
    80002168:	4501                	li	a0,0
}
    8000216a:	60e2                	ld	ra,24(sp)
    8000216c:	6442                	ld	s0,16(sp)
    8000216e:	64a2                	ld	s1,8(sp)
    80002170:	6902                	ld	s2,0(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002176:	9e25                	addw	a2,a2,s1
    80002178:	1602                	slli	a2,a2,0x20
    8000217a:	9201                	srli	a2,a2,0x20
    8000217c:	1582                	slli	a1,a1,0x20
    8000217e:	9181                	srli	a1,a1,0x20
    80002180:	7d28                	ld	a0,120(a0)
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	2a0080e7          	jalr	672(ra) # 80001422 <uvmalloc>
    8000218a:	0005061b          	sext.w	a2,a0
    8000218e:	fa69                	bnez	a2,80002160 <growproc+0x26>
      return -1;
    80002190:	557d                	li	a0,-1
    80002192:	bfe1                	j	8000216a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002194:	9e25                	addw	a2,a2,s1
    80002196:	1602                	slli	a2,a2,0x20
    80002198:	9201                	srli	a2,a2,0x20
    8000219a:	1582                	slli	a1,a1,0x20
    8000219c:	9181                	srli	a1,a1,0x20
    8000219e:	7d28                	ld	a0,120(a0)
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	23a080e7          	jalr	570(ra) # 800013da <uvmdealloc>
    800021a8:	0005061b          	sext.w	a2,a0
    800021ac:	bf55                	j	80002160 <growproc+0x26>

00000000800021ae <min_cpu>:
int min_cpu(){
    800021ae:	1141                	addi	sp,sp,-16
    800021b0:	e422                	sd	s0,8(sp)
    800021b2:	0800                	addi	s0,sp,16
  for( c = cpus ; c < &cpus[CPUS] ; c++ ){
    800021b4:	0000f797          	auipc	a5,0xf
    800021b8:	0ec78793          	addi	a5,a5,236 # 800112a0 <cpus>
  struct cpu * output = cpus , *c ;
    800021bc:	873e                	mv	a4,a5
  for( c = cpus ; c < &cpus[CPUS] ; c++ ){
    800021be:	0000f597          	auipc	a1,0xf
    800021c2:	27a58593          	addi	a1,a1,634 # 80011438 <cpus+0x198>
    800021c6:	a029                	j	800021d0 <min_cpu+0x22>
    800021c8:	08878793          	addi	a5,a5,136
    800021cc:	00b78a63          	beq	a5,a1,800021e0 <min_cpu+0x32>
    if(c->n_proc < output->n_proc)
    800021d0:	0847a603          	lw	a2,132(a5)
    800021d4:	08472683          	lw	a3,132(a4)
    800021d8:	fed658e3          	bge	a2,a3,800021c8 <min_cpu+0x1a>
    800021dc:	873e                	mv	a4,a5
    800021de:	b7ed                	j	800021c8 <min_cpu+0x1a>
}
    800021e0:	08072503          	lw	a0,128(a4)
    800021e4:	6422                	ld	s0,8(sp)
    800021e6:	0141                	addi	sp,sp,16
    800021e8:	8082                	ret

00000000800021ea <fork>:
{
    800021ea:	7179                	addi	sp,sp,-48
    800021ec:	f406                	sd	ra,40(sp)
    800021ee:	f022                	sd	s0,32(sp)
    800021f0:	ec26                	sd	s1,24(sp)
    800021f2:	e84a                	sd	s2,16(sp)
    800021f4:	e44e                	sd	s3,8(sp)
    800021f6:	e052                	sd	s4,0(sp)
    800021f8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	bc6080e7          	jalr	-1082(ra) # 80001dc0 <myproc>
    80002202:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80002204:	00000097          	auipc	ra,0x0
    80002208:	de8080e7          	jalr	-536(ra) # 80001fec <allocproc>
    8000220c:	16050d63          	beqz	a0,80002386 <fork+0x19c>
    80002210:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002212:	0709b603          	ld	a2,112(s3) # 4000070 <_entry-0x7bffff90>
    80002216:	7d2c                	ld	a1,120(a0)
    80002218:	0789b503          	ld	a0,120(s3)
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	352080e7          	jalr	850(ra) # 8000156e <uvmcopy>
    80002224:	08054863          	bltz	a0,800022b4 <fork+0xca>
  np->sz = p->sz;
    80002228:	0709b783          	ld	a5,112(s3)
    8000222c:	06f93823          	sd	a5,112(s2)
  int cpu_index = min_cpu();
    80002230:	00000097          	auipc	ra,0x0
    80002234:	f7e080e7          	jalr	-130(ra) # 800021ae <min_cpu>
  np->cpu = cpu_index; 
    80002238:	02a92a23          	sw	a0,52(s2)
  }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1)); 
    8000223c:	00451493          	slli	s1,a0,0x4
    80002240:	94aa                	add	s1,s1,a0
    80002242:	048e                	slli	s1,s1,0x3
    80002244:	0000f797          	auipc	a5,0xf
    80002248:	0e078793          	addi	a5,a5,224 # 80011324 <cpus+0x84>
    8000224c:	94be                	add	s1,s1,a5
    prev = cpus[cpu_index].n_proc; 
    8000224e:	00451a13          	slli	s4,a0,0x4
    80002252:	9552                	add	a0,a0,s4
    80002254:	050e                	slli	a0,a0,0x3
    80002256:	0000fa17          	auipc	s4,0xf
    8000225a:	04aa0a13          	addi	s4,s4,74 # 800112a0 <cpus>
    8000225e:	9a2a                	add	s4,s4,a0
    80002260:	084a2583          	lw	a1,132(s4)
  }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1)); 
    80002264:	0015861b          	addiw	a2,a1,1
    80002268:	8526                	mv	a0,s1
    8000226a:	00004097          	auipc	ra,0x4
    8000226e:	62c080e7          	jalr	1580(ra) # 80006896 <cas>
    80002272:	f57d                	bnez	a0,80002260 <fork+0x76>
  *(np->trapframe) = *(p->trapframe);
    80002274:	0809b683          	ld	a3,128(s3)
    80002278:	87b6                	mv	a5,a3
    8000227a:	08093703          	ld	a4,128(s2)
    8000227e:	12068693          	addi	a3,a3,288
    80002282:	0007b803          	ld	a6,0(a5)
    80002286:	6788                	ld	a0,8(a5)
    80002288:	6b8c                	ld	a1,16(a5)
    8000228a:	6f90                	ld	a2,24(a5)
    8000228c:	01073023          	sd	a6,0(a4)
    80002290:	e708                	sd	a0,8(a4)
    80002292:	eb0c                	sd	a1,16(a4)
    80002294:	ef10                	sd	a2,24(a4)
    80002296:	02078793          	addi	a5,a5,32
    8000229a:	02070713          	addi	a4,a4,32
    8000229e:	fed792e3          	bne	a5,a3,80002282 <fork+0x98>
  np->trapframe->a0 = 0;
    800022a2:	08093783          	ld	a5,128(s2)
    800022a6:	0607b823          	sd	zero,112(a5)
    800022aa:	0f800493          	li	s1,248
  for(i = 0; i < NOFILE; i++)
    800022ae:	17800a13          	li	s4,376
    800022b2:	a03d                	j	800022e0 <fork+0xf6>
    freeproc(np);
    800022b4:	854a                	mv	a0,s2
    800022b6:	00000097          	auipc	ra,0x0
    800022ba:	cb6080e7          	jalr	-842(ra) # 80001f6c <freeproc>
    release(&np->lock);
    800022be:	854a                	mv	a0,s2
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	9d8080e7          	jalr	-1576(ra) # 80000c98 <release>
    return -1;
    800022c8:	5a7d                	li	s4,-1
    800022ca:	a06d                	j	80002374 <fork+0x18a>
      np->ofile[i] = filedup(p->ofile[i]);
    800022cc:	00003097          	auipc	ra,0x3
    800022d0:	882080e7          	jalr	-1918(ra) # 80004b4e <filedup>
    800022d4:	009907b3          	add	a5,s2,s1
    800022d8:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800022da:	04a1                	addi	s1,s1,8
    800022dc:	01448763          	beq	s1,s4,800022ea <fork+0x100>
    if(p->ofile[i])
    800022e0:	009987b3          	add	a5,s3,s1
    800022e4:	6388                	ld	a0,0(a5)
    800022e6:	f17d                	bnez	a0,800022cc <fork+0xe2>
    800022e8:	bfcd                	j	800022da <fork+0xf0>
  np->cwd = idup(p->cwd);
    800022ea:	1789b503          	ld	a0,376(s3)
    800022ee:	00002097          	auipc	ra,0x2
    800022f2:	9d6080e7          	jalr	-1578(ra) # 80003cc4 <idup>
    800022f6:	16a93c23          	sd	a0,376(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800022fa:	4641                	li	a2,16
    800022fc:	18098593          	addi	a1,s3,384
    80002300:	18090513          	addi	a0,s2,384
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	b2e080e7          	jalr	-1234(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    8000230c:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    80002310:	854a                	mv	a0,s2
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	986080e7          	jalr	-1658(ra) # 80000c98 <release>
  acquire(&wait_lock);
    8000231a:	0000f497          	auipc	s1,0xf
    8000231e:	59648493          	addi	s1,s1,1430 # 800118b0 <wait_lock>
    80002322:	8526                	mv	a0,s1
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	8c0080e7          	jalr	-1856(ra) # 80000be4 <acquire>
  np->parent = p;
    8000232c:	07393023          	sd	s3,96(s2)
  release(&wait_lock);
    80002330:	8526                	mv	a0,s1
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	966080e7          	jalr	-1690(ra) # 80000c98 <release>
  acquire(&np->lock);
    8000233a:	854a                	mv	a0,s2
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	8a8080e7          	jalr	-1880(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80002344:	478d                	li	a5,3
    80002346:	00f92c23          	sw	a5,24(s2)
  add(&readyQueus[np->cpu], np);
    8000234a:	03492503          	lw	a0,52(s2)
    8000234e:	00251793          	slli	a5,a0,0x2
    80002352:	97aa                	add	a5,a5,a0
    80002354:	078e                	slli	a5,a5,0x3
    80002356:	85ca                	mv	a1,s2
    80002358:	0000f517          	auipc	a0,0xf
    8000235c:	38850513          	addi	a0,a0,904 # 800116e0 <readyQueus>
    80002360:	953e                	add	a0,a0,a5
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	4dc080e7          	jalr	1244(ra) # 8000183e <add>
  release(&np->lock);
    8000236a:	854a                	mv	a0,s2
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	92c080e7          	jalr	-1748(ra) # 80000c98 <release>
}
    80002374:	8552                	mv	a0,s4
    80002376:	70a2                	ld	ra,40(sp)
    80002378:	7402                	ld	s0,32(sp)
    8000237a:	64e2                	ld	s1,24(sp)
    8000237c:	6942                	ld	s2,16(sp)
    8000237e:	69a2                	ld	s3,8(sp)
    80002380:	6a02                	ld	s4,0(sp)
    80002382:	6145                	addi	sp,sp,48
    80002384:	8082                	ret
    return -1;
    80002386:	5a7d                	li	s4,-1
    80002388:	b7f5                	j	80002374 <fork+0x18a>

000000008000238a <scheduler>:
{
    8000238a:	715d                	addi	sp,sp,-80
    8000238c:	e486                	sd	ra,72(sp)
    8000238e:	e0a2                	sd	s0,64(sp)
    80002390:	fc26                	sd	s1,56(sp)
    80002392:	f84a                	sd	s2,48(sp)
    80002394:	f44e                	sd	s3,40(sp)
    80002396:	f052                	sd	s4,32(sp)
    80002398:	ec56                	sd	s5,24(sp)
    8000239a:	e85a                	sd	s6,16(sp)
    8000239c:	e45e                	sd	s7,8(sp)
    8000239e:	e062                	sd	s8,0(sp)
    800023a0:	0880                	addi	s0,sp,80
    800023a2:	8712                	mv	a4,tp
  int id = r_tp();
    800023a4:	2701                	sext.w	a4,a4
  c->proc = 0;
    800023a6:	0000fb97          	auipc	s7,0xf
    800023aa:	efab8b93          	addi	s7,s7,-262 # 800112a0 <cpus>
    800023ae:	00471793          	slli	a5,a4,0x4
    800023b2:	00e786b3          	add	a3,a5,a4
    800023b6:	068e                	slli	a3,a3,0x3
    800023b8:	96de                	add	a3,a3,s7
    800023ba:	0006b023          	sd	zero,0(a3)
    swtch(&c->context, &p->context);
    800023be:	97ba                	add	a5,a5,a4
    800023c0:	078e                	slli	a5,a5,0x3
    800023c2:	07a1                	addi	a5,a5,8
    800023c4:	9bbe                	add	s7,s7,a5
    for(int i = c->index ; ; i = (i + 1) % CPUS ){
    800023c6:	0000fb17          	auipc	s6,0xf
    800023ca:	edab0b13          	addi	s6,s6,-294 # 800112a0 <cpus>
    800023ce:	8ab6                	mv	s5,a3
       p = remove(&readyQueus[i]); 
    800023d0:	0000f997          	auipc	s3,0xf
    800023d4:	31098993          	addi	s3,s3,784 # 800116e0 <readyQueus>
    for(int i = c->index ; ; i = (i + 1) % CPUS ){
    800023d8:	4a0d                	li	s4,3
    p->state = RUNNING;
    800023da:	4c11                	li	s8,4
    800023dc:	a89d                	j	80002452 <scheduler+0xc8>
    if(p->cpu != c->index){
    800023de:	5958                	lw	a4,52(a0)
    800023e0:	080aa783          	lw	a5,128(s5)
    800023e4:	02f70863          	beq	a4,a5,80002414 <scheduler+0x8a>
        prev = cpus[c->index].n_proc; 
    800023e8:	080aa503          	lw	a0,128(s5)
    800023ec:	00451793          	slli	a5,a0,0x4
    800023f0:	00a78733          	add	a4,a5,a0
    800023f4:	070e                	slli	a4,a4,0x3
    800023f6:	975a                	add	a4,a4,s6
    800023f8:	08472583          	lw	a1,132(a4)
      }while(cas(&(cpus[c->index].n_proc) , prev , prev + 1));
    800023fc:	953e                	add	a0,a0,a5
    800023fe:	050e                	slli	a0,a0,0x3
    80002400:	08450513          	addi	a0,a0,132
    80002404:	0015861b          	addiw	a2,a1,1
    80002408:	955a                	add	a0,a0,s6
    8000240a:	00004097          	auipc	ra,0x4
    8000240e:	48c080e7          	jalr	1164(ra) # 80006896 <cas>
    80002412:	f979                	bnez	a0,800023e8 <scheduler+0x5e>
    p->cpu = c->index ; 
    80002414:	080aa783          	lw	a5,128(s5)
    80002418:	02f92a23          	sw	a5,52(s2)
    acquire(&p->lock);
    8000241c:	854a                	mv	a0,s2
    8000241e:	ffffe097          	auipc	ra,0xffffe
    80002422:	7c6080e7          	jalr	1990(ra) # 80000be4 <acquire>
    p->state = RUNNING;
    80002426:	01892c23          	sw	s8,24(s2)
    p->cpu = c->index;
    8000242a:	080aa783          	lw	a5,128(s5)
    8000242e:	02f92a23          	sw	a5,52(s2)
    c->proc = p;
    80002432:	012ab023          	sd	s2,0(s5)
    swtch(&c->context, &p->context);
    80002436:	08890593          	addi	a1,s2,136
    8000243a:	855e                	mv	a0,s7
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	7e6080e7          	jalr	2022(ra) # 80002c22 <swtch>
    c->proc = 0;
    80002444:	000ab023          	sd	zero,0(s5)
    release(&p->lock);
    80002448:	854a                	mv	a0,s2
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	84e080e7          	jalr	-1970(ra) # 80000c98 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002452:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002456:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000245a:	10079073          	csrw	sstatus,a5
    for(int i = c->index ; ; i = (i + 1) % CPUS ){
    8000245e:	080aa483          	lw	s1,128(s5)
       p = remove(&readyQueus[i]); 
    80002462:	00249513          	slli	a0,s1,0x2
    80002466:	9526                	add	a0,a0,s1
    80002468:	050e                	slli	a0,a0,0x3
    8000246a:	954e                	add	a0,a0,s3
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	452080e7          	jalr	1106(ra) # 800018be <remove>
    80002474:	892a                	mv	s2,a0
        if(p != 0)
    80002476:	f525                	bnez	a0,800023de <scheduler+0x54>
    for(int i = c->index ; ; i = (i + 1) % CPUS ){
    80002478:	2485                	addiw	s1,s1,1
    8000247a:	0344e4bb          	remw	s1,s1,s4
       p = remove(&readyQueus[i]); 
    8000247e:	b7d5                	j	80002462 <scheduler+0xd8>

0000000080002480 <sched>:
{
    80002480:	7179                	addi	sp,sp,-48
    80002482:	f406                	sd	ra,40(sp)
    80002484:	f022                	sd	s0,32(sp)
    80002486:	ec26                	sd	s1,24(sp)
    80002488:	e84a                	sd	s2,16(sp)
    8000248a:	e44e                	sd	s3,8(sp)
    8000248c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000248e:	00000097          	auipc	ra,0x0
    80002492:	932080e7          	jalr	-1742(ra) # 80001dc0 <myproc>
    80002496:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	6d2080e7          	jalr	1746(ra) # 80000b6a <holding>
    800024a0:	c559                	beqz	a0,8000252e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800024a2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800024a4:	0007871b          	sext.w	a4,a5
    800024a8:	00471793          	slli	a5,a4,0x4
    800024ac:	97ba                	add	a5,a5,a4
    800024ae:	078e                	slli	a5,a5,0x3
    800024b0:	0000f717          	auipc	a4,0xf
    800024b4:	df070713          	addi	a4,a4,-528 # 800112a0 <cpus>
    800024b8:	97ba                	add	a5,a5,a4
    800024ba:	5fb8                	lw	a4,120(a5)
    800024bc:	4785                	li	a5,1
    800024be:	08f71063          	bne	a4,a5,8000253e <sched+0xbe>
  if(p->state == RUNNING)
    800024c2:	4c98                	lw	a4,24(s1)
    800024c4:	4791                	li	a5,4
    800024c6:	08f70463          	beq	a4,a5,8000254e <sched+0xce>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024ca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800024ce:	8b89                	andi	a5,a5,2
  if(intr_get())
    800024d0:	e7d9                	bnez	a5,8000255e <sched+0xde>
  asm volatile("mv %0, tp" : "=r" (x) );
    800024d2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800024d4:	0000f917          	auipc	s2,0xf
    800024d8:	dcc90913          	addi	s2,s2,-564 # 800112a0 <cpus>
    800024dc:	0007871b          	sext.w	a4,a5
    800024e0:	00471793          	slli	a5,a4,0x4
    800024e4:	97ba                	add	a5,a5,a4
    800024e6:	078e                	slli	a5,a5,0x3
    800024e8:	97ca                	add	a5,a5,s2
    800024ea:	07c7a983          	lw	s3,124(a5)
    800024ee:	8592                	mv	a1,tp
  swtch(&p->context, &mycpu()->context);
    800024f0:	0005879b          	sext.w	a5,a1
    800024f4:	00479593          	slli	a1,a5,0x4
    800024f8:	95be                	add	a1,a1,a5
    800024fa:	058e                	slli	a1,a1,0x3
    800024fc:	05a1                	addi	a1,a1,8
    800024fe:	95ca                	add	a1,a1,s2
    80002500:	08848513          	addi	a0,s1,136
    80002504:	00000097          	auipc	ra,0x0
    80002508:	71e080e7          	jalr	1822(ra) # 80002c22 <swtch>
    8000250c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000250e:	0007871b          	sext.w	a4,a5
    80002512:	00471793          	slli	a5,a4,0x4
    80002516:	97ba                	add	a5,a5,a4
    80002518:	078e                	slli	a5,a5,0x3
    8000251a:	993e                	add	s2,s2,a5
    8000251c:	07392e23          	sw	s3,124(s2)
}
    80002520:	70a2                	ld	ra,40(sp)
    80002522:	7402                	ld	s0,32(sp)
    80002524:	64e2                	ld	s1,24(sp)
    80002526:	6942                	ld	s2,16(sp)
    80002528:	69a2                	ld	s3,8(sp)
    8000252a:	6145                	addi	sp,sp,48
    8000252c:	8082                	ret
    panic("sched p->lock");
    8000252e:	00006517          	auipc	a0,0x6
    80002532:	d4250513          	addi	a0,a0,-702 # 80008270 <digits+0x230>
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	008080e7          	jalr	8(ra) # 8000053e <panic>
    panic("sched locks");
    8000253e:	00006517          	auipc	a0,0x6
    80002542:	d4250513          	addi	a0,a0,-702 # 80008280 <digits+0x240>
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	ff8080e7          	jalr	-8(ra) # 8000053e <panic>
    panic("sched running");
    8000254e:	00006517          	auipc	a0,0x6
    80002552:	d4250513          	addi	a0,a0,-702 # 80008290 <digits+0x250>
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	fe8080e7          	jalr	-24(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000255e:	00006517          	auipc	a0,0x6
    80002562:	d4250513          	addi	a0,a0,-702 # 800082a0 <digits+0x260>
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	fd8080e7          	jalr	-40(ra) # 8000053e <panic>

000000008000256e <yield>:
{
    8000256e:	1101                	addi	sp,sp,-32
    80002570:	ec06                	sd	ra,24(sp)
    80002572:	e822                	sd	s0,16(sp)
    80002574:	e426                	sd	s1,8(sp)
    80002576:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002578:	00000097          	auipc	ra,0x0
    8000257c:	848080e7          	jalr	-1976(ra) # 80001dc0 <myproc>
    80002580:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	662080e7          	jalr	1634(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    8000258a:	478d                	li	a5,3
    8000258c:	cc9c                	sw	a5,24(s1)
  add(&readyQueus[p->cpu] , p);
    8000258e:	58c8                	lw	a0,52(s1)
    80002590:	00251793          	slli	a5,a0,0x2
    80002594:	97aa                	add	a5,a5,a0
    80002596:	078e                	slli	a5,a5,0x3
    80002598:	85a6                	mv	a1,s1
    8000259a:	0000f517          	auipc	a0,0xf
    8000259e:	14650513          	addi	a0,a0,326 # 800116e0 <readyQueus>
    800025a2:	953e                	add	a0,a0,a5
    800025a4:	fffff097          	auipc	ra,0xfffff
    800025a8:	29a080e7          	jalr	666(ra) # 8000183e <add>
  sched();
    800025ac:	00000097          	auipc	ra,0x0
    800025b0:	ed4080e7          	jalr	-300(ra) # 80002480 <sched>
  release(&p->lock);
    800025b4:	8526                	mv	a0,s1
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	6e2080e7          	jalr	1762(ra) # 80000c98 <release>
}
    800025be:	60e2                	ld	ra,24(sp)
    800025c0:	6442                	ld	s0,16(sp)
    800025c2:	64a2                	ld	s1,8(sp)
    800025c4:	6105                	addi	sp,sp,32
    800025c6:	8082                	ret

00000000800025c8 <set_cpu>:
int set_cpu(int cpu_num){
    800025c8:	7179                	addi	sp,sp,-48
    800025ca:	f406                	sd	ra,40(sp)
    800025cc:	f022                	sd	s0,32(sp)
    800025ce:	ec26                	sd	s1,24(sp)
    800025d0:	e84a                	sd	s2,16(sp)
    800025d2:	e44e                	sd	s3,8(sp)
    800025d4:	1800                	addi	s0,sp,48
    800025d6:	84aa                	mv	s1,a0
  acquire(&myproc()->lock);
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	7e8080e7          	jalr	2024(ra) # 80001dc0 <myproc>
    800025e0:	ffffe097          	auipc	ra,0xffffe
    800025e4:	604080e7          	jalr	1540(ra) # 80000be4 <acquire>
  struct proc *p = myproc();
    800025e8:	fffff097          	auipc	ra,0xfffff
    800025ec:	7d8080e7          	jalr	2008(ra) # 80001dc0 <myproc>
    800025f0:	892a                	mv	s2,a0
  if(p == 0 || cpu_num > CPUS || cpu_num < 0){
    800025f2:	c13d                	beqz	a0,80002658 <set_cpu+0x90>
    800025f4:	0004879b          	sext.w	a5,s1
    800025f8:	470d                	li	a4,3
    800025fa:	04f76f63          	bltu	a4,a5,80002658 <set_cpu+0x90>
  remove_index(&readyQueus[p->cpu], p->index);
    800025fe:	0000f997          	auipc	s3,0xf
    80002602:	0e298993          	addi	s3,s3,226 # 800116e0 <readyQueus>
    80002606:	595c                	lw	a5,52(a0)
    80002608:	00279513          	slli	a0,a5,0x2
    8000260c:	953e                	add	a0,a0,a5
    8000260e:	050e                	slli	a0,a0,0x3
    80002610:	04092583          	lw	a1,64(s2)
    80002614:	954e                	add	a0,a0,s3
    80002616:	fffff097          	auipc	ra,0xfffff
    8000261a:	3a8080e7          	jalr	936(ra) # 800019be <remove_index>
  p->cpu = cpu_num;
    8000261e:	02992a23          	sw	s1,52(s2)
  add(&readyQueus[cpu_num], p);
    80002622:	00249513          	slli	a0,s1,0x2
    80002626:	9526                	add	a0,a0,s1
    80002628:	050e                	slli	a0,a0,0x3
    8000262a:	85ca                	mv	a1,s2
    8000262c:	954e                	add	a0,a0,s3
    8000262e:	fffff097          	auipc	ra,0xfffff
    80002632:	210080e7          	jalr	528(ra) # 8000183e <add>
  release(&p->lock);
    80002636:	854a                	mv	a0,s2
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	660080e7          	jalr	1632(ra) # 80000c98 <release>
  yield();
    80002640:	00000097          	auipc	ra,0x0
    80002644:	f2e080e7          	jalr	-210(ra) # 8000256e <yield>
  return cpu_num;
    80002648:	8526                	mv	a0,s1
}
    8000264a:	70a2                	ld	ra,40(sp)
    8000264c:	7402                	ld	s0,32(sp)
    8000264e:	64e2                	ld	s1,24(sp)
    80002650:	6942                	ld	s2,16(sp)
    80002652:	69a2                	ld	s3,8(sp)
    80002654:	6145                	addi	sp,sp,48
    80002656:	8082                	ret
    release(&p->lock);
    80002658:	854a                	mv	a0,s2
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	63e080e7          	jalr	1598(ra) # 80000c98 <release>
    return -1;
    80002662:	557d                	li	a0,-1
    80002664:	b7dd                	j	8000264a <set_cpu+0x82>

0000000080002666 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002666:	7179                	addi	sp,sp,-48
    80002668:	f406                	sd	ra,40(sp)
    8000266a:	f022                	sd	s0,32(sp)
    8000266c:	ec26                	sd	s1,24(sp)
    8000266e:	e84a                	sd	s2,16(sp)
    80002670:	e44e                	sd	s3,8(sp)
    80002672:	1800                	addi	s0,sp,48
    80002674:	89aa                	mv	s3,a0
    80002676:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002678:	fffff097          	auipc	ra,0xfffff
    8000267c:	748080e7          	jalr	1864(ra) # 80001dc0 <myproc>
    80002680:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	562080e7          	jalr	1378(ra) # 80000be4 <acquire>
  add(&sleeping , p);
    8000268a:	85a6                	mv	a1,s1
    8000268c:	0000f517          	auipc	a0,0xf
    80002690:	1bc50513          	addi	a0,a0,444 # 80011848 <sleeping>
    80002694:	fffff097          	auipc	ra,0xfffff
    80002698:	1aa080e7          	jalr	426(ra) # 8000183e <add>
  release(lk);
    8000269c:	854a                	mv	a0,s2
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	5fa080e7          	jalr	1530(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    800026a6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800026aa:	4789                	li	a5,2
    800026ac:	cc9c                	sw	a5,24(s1)

  
  //printList(&sleeping);
  sched();
    800026ae:	00000097          	auipc	ra,0x0
    800026b2:	dd2080e7          	jalr	-558(ra) # 80002480 <sched>

  // Tidy up.
  p->chan = 0;
    800026b6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	5dc080e7          	jalr	1500(ra) # 80000c98 <release>
  acquire(lk);
    800026c4:	854a                	mv	a0,s2
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	51e080e7          	jalr	1310(ra) # 80000be4 <acquire>
}
    800026ce:	70a2                	ld	ra,40(sp)
    800026d0:	7402                	ld	s0,32(sp)
    800026d2:	64e2                	ld	s1,24(sp)
    800026d4:	6942                	ld	s2,16(sp)
    800026d6:	69a2                	ld	s3,8(sp)
    800026d8:	6145                	addi	sp,sp,48
    800026da:	8082                	ret

00000000800026dc <wait>:
{
    800026dc:	715d                	addi	sp,sp,-80
    800026de:	e486                	sd	ra,72(sp)
    800026e0:	e0a2                	sd	s0,64(sp)
    800026e2:	fc26                	sd	s1,56(sp)
    800026e4:	f84a                	sd	s2,48(sp)
    800026e6:	f44e                	sd	s3,40(sp)
    800026e8:	f052                	sd	s4,32(sp)
    800026ea:	ec56                	sd	s5,24(sp)
    800026ec:	e85a                	sd	s6,16(sp)
    800026ee:	e45e                	sd	s7,8(sp)
    800026f0:	e062                	sd	s8,0(sp)
    800026f2:	0880                	addi	s0,sp,80
    800026f4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	6ca080e7          	jalr	1738(ra) # 80001dc0 <myproc>
    800026fe:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002700:	0000f517          	auipc	a0,0xf
    80002704:	1b050513          	addi	a0,a0,432 # 800118b0 <wait_lock>
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	4dc080e7          	jalr	1244(ra) # 80000be4 <acquire>
    havekids = 0;
    80002710:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002712:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002714:	00015997          	auipc	s3,0x15
    80002718:	5b498993          	addi	s3,s3,1460 # 80017cc8 <tickslock>
        havekids = 1;
    8000271c:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000271e:	0000fc17          	auipc	s8,0xf
    80002722:	192c0c13          	addi	s8,s8,402 # 800118b0 <wait_lock>
    havekids = 0;
    80002726:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002728:	0000f497          	auipc	s1,0xf
    8000272c:	1a048493          	addi	s1,s1,416 # 800118c8 <proc>
    80002730:	a0bd                	j	8000279e <wait+0xc2>
          pid = np->pid;
    80002732:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002736:	000b0e63          	beqz	s6,80002752 <wait+0x76>
    8000273a:	4691                	li	a3,4
    8000273c:	02c48613          	addi	a2,s1,44
    80002740:	85da                	mv	a1,s6
    80002742:	07893503          	ld	a0,120(s2)
    80002746:	fffff097          	auipc	ra,0xfffff
    8000274a:	f2c080e7          	jalr	-212(ra) # 80001672 <copyout>
    8000274e:	02054563          	bltz	a0,80002778 <wait+0x9c>
          freeproc(np);
    80002752:	8526                	mv	a0,s1
    80002754:	00000097          	auipc	ra,0x0
    80002758:	818080e7          	jalr	-2024(ra) # 80001f6c <freeproc>
          release(&np->lock);
    8000275c:	8526                	mv	a0,s1
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	53a080e7          	jalr	1338(ra) # 80000c98 <release>
          release(&wait_lock);
    80002766:	0000f517          	auipc	a0,0xf
    8000276a:	14a50513          	addi	a0,a0,330 # 800118b0 <wait_lock>
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	52a080e7          	jalr	1322(ra) # 80000c98 <release>
          return pid;
    80002776:	a09d                	j	800027dc <wait+0x100>
            release(&np->lock);
    80002778:	8526                	mv	a0,s1
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	51e080e7          	jalr	1310(ra) # 80000c98 <release>
            release(&wait_lock);
    80002782:	0000f517          	auipc	a0,0xf
    80002786:	12e50513          	addi	a0,a0,302 # 800118b0 <wait_lock>
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	50e080e7          	jalr	1294(ra) # 80000c98 <release>
            return -1;
    80002792:	59fd                	li	s3,-1
    80002794:	a0a1                	j	800027dc <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002796:	19048493          	addi	s1,s1,400
    8000279a:	03348463          	beq	s1,s3,800027c2 <wait+0xe6>
      if(np->parent == p){
    8000279e:	70bc                	ld	a5,96(s1)
    800027a0:	ff279be3          	bne	a5,s2,80002796 <wait+0xba>
        acquire(&np->lock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	43e080e7          	jalr	1086(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    800027ae:	4c9c                	lw	a5,24(s1)
    800027b0:	f94781e3          	beq	a5,s4,80002732 <wait+0x56>
        release(&np->lock);
    800027b4:	8526                	mv	a0,s1
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	4e2080e7          	jalr	1250(ra) # 80000c98 <release>
        havekids = 1;
    800027be:	8756                	mv	a4,s5
    800027c0:	bfd9                	j	80002796 <wait+0xba>
    if(!havekids || p->killed){
    800027c2:	c701                	beqz	a4,800027ca <wait+0xee>
    800027c4:	02892783          	lw	a5,40(s2)
    800027c8:	c79d                	beqz	a5,800027f6 <wait+0x11a>
      release(&wait_lock);
    800027ca:	0000f517          	auipc	a0,0xf
    800027ce:	0e650513          	addi	a0,a0,230 # 800118b0 <wait_lock>
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	4c6080e7          	jalr	1222(ra) # 80000c98 <release>
      return -1;
    800027da:	59fd                	li	s3,-1
}
    800027dc:	854e                	mv	a0,s3
    800027de:	60a6                	ld	ra,72(sp)
    800027e0:	6406                	ld	s0,64(sp)
    800027e2:	74e2                	ld	s1,56(sp)
    800027e4:	7942                	ld	s2,48(sp)
    800027e6:	79a2                	ld	s3,40(sp)
    800027e8:	7a02                	ld	s4,32(sp)
    800027ea:	6ae2                	ld	s5,24(sp)
    800027ec:	6b42                	ld	s6,16(sp)
    800027ee:	6ba2                	ld	s7,8(sp)
    800027f0:	6c02                	ld	s8,0(sp)
    800027f2:	6161                	addi	sp,sp,80
    800027f4:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027f6:	85e2                	mv	a1,s8
    800027f8:	854a                	mv	a0,s2
    800027fa:	00000097          	auipc	ra,0x0
    800027fe:	e6c080e7          	jalr	-404(ra) # 80002666 <sleep>
    havekids = 0;
    80002802:	b715                	j	80002726 <wait+0x4a>

0000000080002804 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002804:	711d                	addi	sp,sp,-96
    80002806:	ec86                	sd	ra,88(sp)
    80002808:	e8a2                	sd	s0,80(sp)
    8000280a:	e4a6                	sd	s1,72(sp)
    8000280c:	e0ca                	sd	s2,64(sp)
    8000280e:	fc4e                	sd	s3,56(sp)
    80002810:	f852                	sd	s4,48(sp)
    80002812:	f456                	sd	s5,40(sp)
    80002814:	f05a                	sd	s6,32(sp)
    80002816:	ec5e                	sd	s7,24(sp)
    80002818:	e862                	sd	s8,16(sp)
    8000281a:	e466                	sd	s9,8(sp)
    8000281c:	e06a                	sd	s10,0(sp)
    8000281e:	1080                	addi	s0,sp,96
  struct proc *p;
  //printList(&sleeping);
  for(p = sleeping.head; p != 0; p = p->next) {
    80002820:	0000f497          	auipc	s1,0xf
    80002824:	0284b483          	ld	s1,40(s1) # 80011848 <sleeping>
    80002828:	c8cd                	beqz	s1,800028da <wakeup+0xd6>
    8000282a:	8a2a                	mv	s4,a0
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000282c:	4989                	li	s3,2
        remove_index(&sleeping , p->index);
    8000282e:	0000fa97          	auipc	s5,0xf
    80002832:	a72a8a93          	addi	s5,s5,-1422 # 800112a0 <cpus>
    80002836:	0000fc17          	auipc	s8,0xf
    8000283a:	012c0c13          	addi	s8,s8,18 # 80011848 <sleeping>
        p->state = RUNNABLE;
    8000283e:	4b8d                	li	s7,3
        p->cpu = cpu_index; 
        do{
          prev = cpus[cpu_index].n_proc; 
        }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1));
        #endif 
        add(&readyQueus[p->cpu] , p);     
    80002840:	0000fb17          	auipc	s6,0xf
    80002844:	ea0b0b13          	addi	s6,s6,-352 # 800116e0 <readyQueus>
    80002848:	a801                	j	80002858 <wakeup+0x54>
      }
      release(&p->lock);
    8000284a:	854a                	mv	a0,s2
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	44c080e7          	jalr	1100(ra) # 80000c98 <release>
  for(p = sleeping.head; p != 0; p = p->next) {
    80002854:	7c84                	ld	s1,56(s1)
    80002856:	c0d1                	beqz	s1,800028da <wakeup+0xd6>
    if(p != myproc()){
    80002858:	fffff097          	auipc	ra,0xfffff
    8000285c:	568080e7          	jalr	1384(ra) # 80001dc0 <myproc>
    80002860:	fea48ae3          	beq	s1,a0,80002854 <wakeup+0x50>
      acquire(&p->lock);
    80002864:	8926                	mv	s2,s1
    80002866:	8526                	mv	a0,s1
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	37c080e7          	jalr	892(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002870:	4c9c                	lw	a5,24(s1)
    80002872:	fd379ce3          	bne	a5,s3,8000284a <wakeup+0x46>
    80002876:	709c                	ld	a5,32(s1)
    80002878:	fd4799e3          	bne	a5,s4,8000284a <wakeup+0x46>
        remove_index(&sleeping , p->index);
    8000287c:	40ac                	lw	a1,64(s1)
    8000287e:	8562                	mv	a0,s8
    80002880:	fffff097          	auipc	ra,0xfffff
    80002884:	13e080e7          	jalr	318(ra) # 800019be <remove_index>
        p->state = RUNNABLE;
    80002888:	0174ac23          	sw	s7,24(s1)
        int cpu_index = min_cpu();
    8000288c:	00000097          	auipc	ra,0x0
    80002890:	922080e7          	jalr	-1758(ra) # 800021ae <min_cpu>
        p->cpu = cpu_index; 
    80002894:	d8c8                	sw	a0,52(s1)
        }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1));
    80002896:	00451c93          	slli	s9,a0,0x4
    8000289a:	9caa                	add	s9,s9,a0
    8000289c:	0c8e                	slli	s9,s9,0x3
    8000289e:	084c8c93          	addi	s9,s9,132
    800028a2:	9cd6                	add	s9,s9,s5
          prev = cpus[cpu_index].n_proc; 
    800028a4:	00451d13          	slli	s10,a0,0x4
    800028a8:	9d2a                	add	s10,s10,a0
    800028aa:	0d0e                	slli	s10,s10,0x3
    800028ac:	9d56                	add	s10,s10,s5
    800028ae:	084d2583          	lw	a1,132(s10)
        }while(cas(&(cpus[cpu_index].n_proc) , prev , prev + 1));
    800028b2:	0015861b          	addiw	a2,a1,1
    800028b6:	8566                	mv	a0,s9
    800028b8:	00004097          	auipc	ra,0x4
    800028bc:	fde080e7          	jalr	-34(ra) # 80006896 <cas>
    800028c0:	f57d                	bnez	a0,800028ae <wakeup+0xaa>
        add(&readyQueus[p->cpu] , p);     
    800028c2:	58dc                	lw	a5,52(s1)
    800028c4:	00279513          	slli	a0,a5,0x2
    800028c8:	953e                	add	a0,a0,a5
    800028ca:	050e                	slli	a0,a0,0x3
    800028cc:	85a6                	mv	a1,s1
    800028ce:	955a                	add	a0,a0,s6
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	f6e080e7          	jalr	-146(ra) # 8000183e <add>
    800028d8:	bf8d                	j	8000284a <wakeup+0x46>
    }
  }
  //printList(&sleeping);
}
    800028da:	60e6                	ld	ra,88(sp)
    800028dc:	6446                	ld	s0,80(sp)
    800028de:	64a6                	ld	s1,72(sp)
    800028e0:	6906                	ld	s2,64(sp)
    800028e2:	79e2                	ld	s3,56(sp)
    800028e4:	7a42                	ld	s4,48(sp)
    800028e6:	7aa2                	ld	s5,40(sp)
    800028e8:	7b02                	ld	s6,32(sp)
    800028ea:	6be2                	ld	s7,24(sp)
    800028ec:	6c42                	ld	s8,16(sp)
    800028ee:	6ca2                	ld	s9,8(sp)
    800028f0:	6d02                	ld	s10,0(sp)
    800028f2:	6125                	addi	sp,sp,96
    800028f4:	8082                	ret

00000000800028f6 <reparent>:
{
    800028f6:	7179                	addi	sp,sp,-48
    800028f8:	f406                	sd	ra,40(sp)
    800028fa:	f022                	sd	s0,32(sp)
    800028fc:	ec26                	sd	s1,24(sp)
    800028fe:	e84a                	sd	s2,16(sp)
    80002900:	e44e                	sd	s3,8(sp)
    80002902:	e052                	sd	s4,0(sp)
    80002904:	1800                	addi	s0,sp,48
    80002906:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002908:	0000f497          	auipc	s1,0xf
    8000290c:	fc048493          	addi	s1,s1,-64 # 800118c8 <proc>
      pp->parent = initproc;
    80002910:	00006a17          	auipc	s4,0x6
    80002914:	718a0a13          	addi	s4,s4,1816 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002918:	00015997          	auipc	s3,0x15
    8000291c:	3b098993          	addi	s3,s3,944 # 80017cc8 <tickslock>
    80002920:	a029                	j	8000292a <reparent+0x34>
    80002922:	19048493          	addi	s1,s1,400
    80002926:	01348d63          	beq	s1,s3,80002940 <reparent+0x4a>
    if(pp->parent == p){
    8000292a:	70bc                	ld	a5,96(s1)
    8000292c:	ff279be3          	bne	a5,s2,80002922 <reparent+0x2c>
      pp->parent = initproc;
    80002930:	000a3503          	ld	a0,0(s4)
    80002934:	f0a8                	sd	a0,96(s1)
      wakeup(initproc);
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	ece080e7          	jalr	-306(ra) # 80002804 <wakeup>
    8000293e:	b7d5                	j	80002922 <reparent+0x2c>
}
    80002940:	70a2                	ld	ra,40(sp)
    80002942:	7402                	ld	s0,32(sp)
    80002944:	64e2                	ld	s1,24(sp)
    80002946:	6942                	ld	s2,16(sp)
    80002948:	69a2                	ld	s3,8(sp)
    8000294a:	6a02                	ld	s4,0(sp)
    8000294c:	6145                	addi	sp,sp,48
    8000294e:	8082                	ret

0000000080002950 <exit>:
{
    80002950:	7179                	addi	sp,sp,-48
    80002952:	f406                	sd	ra,40(sp)
    80002954:	f022                	sd	s0,32(sp)
    80002956:	ec26                	sd	s1,24(sp)
    80002958:	e84a                	sd	s2,16(sp)
    8000295a:	e44e                	sd	s3,8(sp)
    8000295c:	e052                	sd	s4,0(sp)
    8000295e:	1800                	addi	s0,sp,48
    80002960:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002962:	fffff097          	auipc	ra,0xfffff
    80002966:	45e080e7          	jalr	1118(ra) # 80001dc0 <myproc>
    8000296a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000296c:	00006797          	auipc	a5,0x6
    80002970:	6bc7b783          	ld	a5,1724(a5) # 80009028 <initproc>
    80002974:	0f850493          	addi	s1,a0,248
    80002978:	17850913          	addi	s2,a0,376
    8000297c:	02a79363          	bne	a5,a0,800029a2 <exit+0x52>
    panic("init exiting");
    80002980:	00006517          	auipc	a0,0x6
    80002984:	93850513          	addi	a0,a0,-1736 # 800082b8 <digits+0x278>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	bb6080e7          	jalr	-1098(ra) # 8000053e <panic>
      fileclose(f);
    80002990:	00002097          	auipc	ra,0x2
    80002994:	210080e7          	jalr	528(ra) # 80004ba0 <fileclose>
      p->ofile[fd] = 0;
    80002998:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000299c:	04a1                	addi	s1,s1,8
    8000299e:	01248563          	beq	s1,s2,800029a8 <exit+0x58>
    if(p->ofile[fd]){
    800029a2:	6088                	ld	a0,0(s1)
    800029a4:	f575                	bnez	a0,80002990 <exit+0x40>
    800029a6:	bfdd                	j	8000299c <exit+0x4c>
  begin_op();
    800029a8:	00002097          	auipc	ra,0x2
    800029ac:	d2c080e7          	jalr	-724(ra) # 800046d4 <begin_op>
  iput(p->cwd);
    800029b0:	1789b503          	ld	a0,376(s3)
    800029b4:	00001097          	auipc	ra,0x1
    800029b8:	508080e7          	jalr	1288(ra) # 80003ebc <iput>
  end_op();
    800029bc:	00002097          	auipc	ra,0x2
    800029c0:	d98080e7          	jalr	-616(ra) # 80004754 <end_op>
  p->cwd = 0;
    800029c4:	1609bc23          	sd	zero,376(s3)
  acquire(&wait_lock);
    800029c8:	0000f497          	auipc	s1,0xf
    800029cc:	ee848493          	addi	s1,s1,-280 # 800118b0 <wait_lock>
    800029d0:	8526                	mv	a0,s1
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	212080e7          	jalr	530(ra) # 80000be4 <acquire>
  reparent(p);
    800029da:	854e                	mv	a0,s3
    800029dc:	00000097          	auipc	ra,0x0
    800029e0:	f1a080e7          	jalr	-230(ra) # 800028f6 <reparent>
  wakeup(p->parent);
    800029e4:	0609b503          	ld	a0,96(s3)
    800029e8:	00000097          	auipc	ra,0x0
    800029ec:	e1c080e7          	jalr	-484(ra) # 80002804 <wakeup>
  acquire(&p->lock);
    800029f0:	854e                	mv	a0,s3
    800029f2:	ffffe097          	auipc	ra,0xffffe
    800029f6:	1f2080e7          	jalr	498(ra) # 80000be4 <acquire>
  p->xstate = status;
    800029fa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800029fe:	4795                	li	a5,5
    80002a00:	00f9ac23          	sw	a5,24(s3)
  add(&zombies , p); 
    80002a04:	85ce                	mv	a1,s3
    80002a06:	0000f517          	auipc	a0,0xf
    80002a0a:	e1a50513          	addi	a0,a0,-486 # 80011820 <zombies>
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	e30080e7          	jalr	-464(ra) # 8000183e <add>
  release(&wait_lock);
    80002a16:	8526                	mv	a0,s1
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	280080e7          	jalr	640(ra) # 80000c98 <release>
  sched();
    80002a20:	00000097          	auipc	ra,0x0
    80002a24:	a60080e7          	jalr	-1440(ra) # 80002480 <sched>
  panic("zombie exit");
    80002a28:	00006517          	auipc	a0,0x6
    80002a2c:	8a050513          	addi	a0,a0,-1888 # 800082c8 <digits+0x288>
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	b0e080e7          	jalr	-1266(ra) # 8000053e <panic>

0000000080002a38 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002a38:	7179                	addi	sp,sp,-48
    80002a3a:	f406                	sd	ra,40(sp)
    80002a3c:	f022                	sd	s0,32(sp)
    80002a3e:	ec26                	sd	s1,24(sp)
    80002a40:	e84a                	sd	s2,16(sp)
    80002a42:	e44e                	sd	s3,8(sp)
    80002a44:	1800                	addi	s0,sp,48
    80002a46:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a48:	0000f497          	auipc	s1,0xf
    80002a4c:	e8048493          	addi	s1,s1,-384 # 800118c8 <proc>
    80002a50:	00015997          	auipc	s3,0x15
    80002a54:	27898993          	addi	s3,s3,632 # 80017cc8 <tickslock>
    acquire(&p->lock);
    80002a58:	8526                	mv	a0,s1
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	18a080e7          	jalr	394(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    80002a62:	589c                	lw	a5,48(s1)
    80002a64:	01278d63          	beq	a5,s2,80002a7e <kill+0x46>
        add(&readyQueus[p->cpu] , p); 
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a68:	8526                	mv	a0,s1
    80002a6a:	ffffe097          	auipc	ra,0xffffe
    80002a6e:	22e080e7          	jalr	558(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a72:	19048493          	addi	s1,s1,400
    80002a76:	ff3491e3          	bne	s1,s3,80002a58 <kill+0x20>
  }
  return -1;
    80002a7a:	557d                	li	a0,-1
    80002a7c:	a829                	j	80002a96 <kill+0x5e>
      p->killed = 1;
    80002a7e:	4785                	li	a5,1
    80002a80:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002a82:	4c98                	lw	a4,24(s1)
    80002a84:	4789                	li	a5,2
    80002a86:	00f70f63          	beq	a4,a5,80002aa4 <kill+0x6c>
      release(&p->lock);
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	20c080e7          	jalr	524(ra) # 80000c98 <release>
      return 0;
    80002a94:	4501                	li	a0,0
}
    80002a96:	70a2                	ld	ra,40(sp)
    80002a98:	7402                	ld	s0,32(sp)
    80002a9a:	64e2                	ld	s1,24(sp)
    80002a9c:	6942                	ld	s2,16(sp)
    80002a9e:	69a2                	ld	s3,8(sp)
    80002aa0:	6145                	addi	sp,sp,48
    80002aa2:	8082                	ret
        p->state = RUNNABLE;
    80002aa4:	478d                	li	a5,3
    80002aa6:	cc9c                	sw	a5,24(s1)
        add(&readyQueus[p->cpu] , p); 
    80002aa8:	58d8                	lw	a4,52(s1)
    80002aaa:	00271793          	slli	a5,a4,0x2
    80002aae:	97ba                	add	a5,a5,a4
    80002ab0:	078e                	slli	a5,a5,0x3
    80002ab2:	85a6                	mv	a1,s1
    80002ab4:	0000f517          	auipc	a0,0xf
    80002ab8:	c2c50513          	addi	a0,a0,-980 # 800116e0 <readyQueus>
    80002abc:	953e                	add	a0,a0,a5
    80002abe:	fffff097          	auipc	ra,0xfffff
    80002ac2:	d80080e7          	jalr	-640(ra) # 8000183e <add>
    80002ac6:	b7d1                	j	80002a8a <kill+0x52>

0000000080002ac8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002ac8:	7179                	addi	sp,sp,-48
    80002aca:	f406                	sd	ra,40(sp)
    80002acc:	f022                	sd	s0,32(sp)
    80002ace:	ec26                	sd	s1,24(sp)
    80002ad0:	e84a                	sd	s2,16(sp)
    80002ad2:	e44e                	sd	s3,8(sp)
    80002ad4:	e052                	sd	s4,0(sp)
    80002ad6:	1800                	addi	s0,sp,48
    80002ad8:	84aa                	mv	s1,a0
    80002ada:	892e                	mv	s2,a1
    80002adc:	89b2                	mv	s3,a2
    80002ade:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002ae0:	fffff097          	auipc	ra,0xfffff
    80002ae4:	2e0080e7          	jalr	736(ra) # 80001dc0 <myproc>
  if(user_dst){
    80002ae8:	c08d                	beqz	s1,80002b0a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002aea:	86d2                	mv	a3,s4
    80002aec:	864e                	mv	a2,s3
    80002aee:	85ca                	mv	a1,s2
    80002af0:	7d28                	ld	a0,120(a0)
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	b80080e7          	jalr	-1152(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002afa:	70a2                	ld	ra,40(sp)
    80002afc:	7402                	ld	s0,32(sp)
    80002afe:	64e2                	ld	s1,24(sp)
    80002b00:	6942                	ld	s2,16(sp)
    80002b02:	69a2                	ld	s3,8(sp)
    80002b04:	6a02                	ld	s4,0(sp)
    80002b06:	6145                	addi	sp,sp,48
    80002b08:	8082                	ret
    memmove((char *)dst, src, len);
    80002b0a:	000a061b          	sext.w	a2,s4
    80002b0e:	85ce                	mv	a1,s3
    80002b10:	854a                	mv	a0,s2
    80002b12:	ffffe097          	auipc	ra,0xffffe
    80002b16:	22e080e7          	jalr	558(ra) # 80000d40 <memmove>
    return 0;
    80002b1a:	8526                	mv	a0,s1
    80002b1c:	bff9                	j	80002afa <either_copyout+0x32>

0000000080002b1e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b1e:	7179                	addi	sp,sp,-48
    80002b20:	f406                	sd	ra,40(sp)
    80002b22:	f022                	sd	s0,32(sp)
    80002b24:	ec26                	sd	s1,24(sp)
    80002b26:	e84a                	sd	s2,16(sp)
    80002b28:	e44e                	sd	s3,8(sp)
    80002b2a:	e052                	sd	s4,0(sp)
    80002b2c:	1800                	addi	s0,sp,48
    80002b2e:	892a                	mv	s2,a0
    80002b30:	84ae                	mv	s1,a1
    80002b32:	89b2                	mv	s3,a2
    80002b34:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b36:	fffff097          	auipc	ra,0xfffff
    80002b3a:	28a080e7          	jalr	650(ra) # 80001dc0 <myproc>
  if(user_src){
    80002b3e:	c08d                	beqz	s1,80002b60 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002b40:	86d2                	mv	a3,s4
    80002b42:	864e                	mv	a2,s3
    80002b44:	85ca                	mv	a1,s2
    80002b46:	7d28                	ld	a0,120(a0)
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	bb6080e7          	jalr	-1098(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b50:	70a2                	ld	ra,40(sp)
    80002b52:	7402                	ld	s0,32(sp)
    80002b54:	64e2                	ld	s1,24(sp)
    80002b56:	6942                	ld	s2,16(sp)
    80002b58:	69a2                	ld	s3,8(sp)
    80002b5a:	6a02                	ld	s4,0(sp)
    80002b5c:	6145                	addi	sp,sp,48
    80002b5e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b60:	000a061b          	sext.w	a2,s4
    80002b64:	85ce                	mv	a1,s3
    80002b66:	854a                	mv	a0,s2
    80002b68:	ffffe097          	auipc	ra,0xffffe
    80002b6c:	1d8080e7          	jalr	472(ra) # 80000d40 <memmove>
    return 0;
    80002b70:	8526                	mv	a0,s1
    80002b72:	bff9                	j	80002b50 <either_copyin+0x32>

0000000080002b74 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b74:	715d                	addi	sp,sp,-80
    80002b76:	e486                	sd	ra,72(sp)
    80002b78:	e0a2                	sd	s0,64(sp)
    80002b7a:	fc26                	sd	s1,56(sp)
    80002b7c:	f84a                	sd	s2,48(sp)
    80002b7e:	f44e                	sd	s3,40(sp)
    80002b80:	f052                	sd	s4,32(sp)
    80002b82:	ec56                	sd	s5,24(sp)
    80002b84:	e85a                	sd	s6,16(sp)
    80002b86:	e45e                	sd	s7,8(sp)
    80002b88:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002b8a:	00005517          	auipc	a0,0x5
    80002b8e:	53e50513          	addi	a0,a0,1342 # 800080c8 <digits+0x88>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	9f6080e7          	jalr	-1546(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b9a:	0000f497          	auipc	s1,0xf
    80002b9e:	eae48493          	addi	s1,s1,-338 # 80011a48 <proc+0x180>
    80002ba2:	00015917          	auipc	s2,0x15
    80002ba6:	2a690913          	addi	s2,s2,678 # 80017e48 <bcache+0x168>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002baa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002bac:	00005997          	auipc	s3,0x5
    80002bb0:	72c98993          	addi	s3,s3,1836 # 800082d8 <digits+0x298>
    printf("%d %s %s", p->pid, state, p->name);
    80002bb4:	00005a97          	auipc	s5,0x5
    80002bb8:	72ca8a93          	addi	s5,s5,1836 # 800082e0 <digits+0x2a0>
    printf("\n");
    80002bbc:	00005a17          	auipc	s4,0x5
    80002bc0:	50ca0a13          	addi	s4,s4,1292 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bc4:	00005b97          	auipc	s7,0x5
    80002bc8:	754b8b93          	addi	s7,s7,1876 # 80008318 <states.1800>
    80002bcc:	a00d                	j	80002bee <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002bce:	eb06a583          	lw	a1,-336(a3)
    80002bd2:	8556                	mv	a0,s5
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	9b4080e7          	jalr	-1612(ra) # 80000588 <printf>
    printf("\n");
    80002bdc:	8552                	mv	a0,s4
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	9aa080e7          	jalr	-1622(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002be6:	19048493          	addi	s1,s1,400
    80002bea:	03248163          	beq	s1,s2,80002c0c <procdump+0x98>
    if(p->state == UNUSED)
    80002bee:	86a6                	mv	a3,s1
    80002bf0:	e984a783          	lw	a5,-360(s1)
    80002bf4:	dbed                	beqz	a5,80002be6 <procdump+0x72>
      state = "???";
    80002bf6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bf8:	fcfb6be3          	bltu	s6,a5,80002bce <procdump+0x5a>
    80002bfc:	1782                	slli	a5,a5,0x20
    80002bfe:	9381                	srli	a5,a5,0x20
    80002c00:	078e                	slli	a5,a5,0x3
    80002c02:	97de                	add	a5,a5,s7
    80002c04:	6390                	ld	a2,0(a5)
    80002c06:	f661                	bnez	a2,80002bce <procdump+0x5a>
      state = "???";
    80002c08:	864e                	mv	a2,s3
    80002c0a:	b7d1                	j	80002bce <procdump+0x5a>
  }
}
    80002c0c:	60a6                	ld	ra,72(sp)
    80002c0e:	6406                	ld	s0,64(sp)
    80002c10:	74e2                	ld	s1,56(sp)
    80002c12:	7942                	ld	s2,48(sp)
    80002c14:	79a2                	ld	s3,40(sp)
    80002c16:	7a02                	ld	s4,32(sp)
    80002c18:	6ae2                	ld	s5,24(sp)
    80002c1a:	6b42                	ld	s6,16(sp)
    80002c1c:	6ba2                	ld	s7,8(sp)
    80002c1e:	6161                	addi	sp,sp,80
    80002c20:	8082                	ret

0000000080002c22 <swtch>:
    80002c22:	00153023          	sd	ra,0(a0)
    80002c26:	00253423          	sd	sp,8(a0)
    80002c2a:	e900                	sd	s0,16(a0)
    80002c2c:	ed04                	sd	s1,24(a0)
    80002c2e:	03253023          	sd	s2,32(a0)
    80002c32:	03353423          	sd	s3,40(a0)
    80002c36:	03453823          	sd	s4,48(a0)
    80002c3a:	03553c23          	sd	s5,56(a0)
    80002c3e:	05653023          	sd	s6,64(a0)
    80002c42:	05753423          	sd	s7,72(a0)
    80002c46:	05853823          	sd	s8,80(a0)
    80002c4a:	05953c23          	sd	s9,88(a0)
    80002c4e:	07a53023          	sd	s10,96(a0)
    80002c52:	07b53423          	sd	s11,104(a0)
    80002c56:	0005b083          	ld	ra,0(a1)
    80002c5a:	0085b103          	ld	sp,8(a1)
    80002c5e:	6980                	ld	s0,16(a1)
    80002c60:	6d84                	ld	s1,24(a1)
    80002c62:	0205b903          	ld	s2,32(a1)
    80002c66:	0285b983          	ld	s3,40(a1)
    80002c6a:	0305ba03          	ld	s4,48(a1)
    80002c6e:	0385ba83          	ld	s5,56(a1)
    80002c72:	0405bb03          	ld	s6,64(a1)
    80002c76:	0485bb83          	ld	s7,72(a1)
    80002c7a:	0505bc03          	ld	s8,80(a1)
    80002c7e:	0585bc83          	ld	s9,88(a1)
    80002c82:	0605bd03          	ld	s10,96(a1)
    80002c86:	0685bd83          	ld	s11,104(a1)
    80002c8a:	8082                	ret

0000000080002c8c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c8c:	1141                	addi	sp,sp,-16
    80002c8e:	e406                	sd	ra,8(sp)
    80002c90:	e022                	sd	s0,0(sp)
    80002c92:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c94:	00005597          	auipc	a1,0x5
    80002c98:	6b458593          	addi	a1,a1,1716 # 80008348 <states.1800+0x30>
    80002c9c:	00015517          	auipc	a0,0x15
    80002ca0:	02c50513          	addi	a0,a0,44 # 80017cc8 <tickslock>
    80002ca4:	ffffe097          	auipc	ra,0xffffe
    80002ca8:	eb0080e7          	jalr	-336(ra) # 80000b54 <initlock>
}
    80002cac:	60a2                	ld	ra,8(sp)
    80002cae:	6402                	ld	s0,0(sp)
    80002cb0:	0141                	addi	sp,sp,16
    80002cb2:	8082                	ret

0000000080002cb4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002cb4:	1141                	addi	sp,sp,-16
    80002cb6:	e422                	sd	s0,8(sp)
    80002cb8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cba:	00003797          	auipc	a5,0x3
    80002cbe:	50678793          	addi	a5,a5,1286 # 800061c0 <kernelvec>
    80002cc2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002cc6:	6422                	ld	s0,8(sp)
    80002cc8:	0141                	addi	sp,sp,16
    80002cca:	8082                	ret

0000000080002ccc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002ccc:	1141                	addi	sp,sp,-16
    80002cce:	e406                	sd	ra,8(sp)
    80002cd0:	e022                	sd	s0,0(sp)
    80002cd2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002cd4:	fffff097          	auipc	ra,0xfffff
    80002cd8:	0ec080e7          	jalr	236(ra) # 80001dc0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cdc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ce0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ce2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ce6:	00004617          	auipc	a2,0x4
    80002cea:	31a60613          	addi	a2,a2,794 # 80007000 <_trampoline>
    80002cee:	00004697          	auipc	a3,0x4
    80002cf2:	31268693          	addi	a3,a3,786 # 80007000 <_trampoline>
    80002cf6:	8e91                	sub	a3,a3,a2
    80002cf8:	040007b7          	lui	a5,0x4000
    80002cfc:	17fd                	addi	a5,a5,-1
    80002cfe:	07b2                	slli	a5,a5,0xc
    80002d00:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d02:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d06:	6158                	ld	a4,128(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d08:	180026f3          	csrr	a3,satp
    80002d0c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d0e:	6158                	ld	a4,128(a0)
    80002d10:	7534                	ld	a3,104(a0)
    80002d12:	6585                	lui	a1,0x1
    80002d14:	96ae                	add	a3,a3,a1
    80002d16:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d18:	6158                	ld	a4,128(a0)
    80002d1a:	00000697          	auipc	a3,0x0
    80002d1e:	13868693          	addi	a3,a3,312 # 80002e52 <usertrap>
    80002d22:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d24:	6158                	ld	a4,128(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d26:	8692                	mv	a3,tp
    80002d28:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d2a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d2e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d32:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d36:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d3a:	6158                	ld	a4,128(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d3c:	6f18                	ld	a4,24(a4)
    80002d3e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d42:	7d2c                	ld	a1,120(a0)
    80002d44:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002d46:	00004717          	auipc	a4,0x4
    80002d4a:	34a70713          	addi	a4,a4,842 # 80007090 <userret>
    80002d4e:	8f11                	sub	a4,a4,a2
    80002d50:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002d52:	577d                	li	a4,-1
    80002d54:	177e                	slli	a4,a4,0x3f
    80002d56:	8dd9                	or	a1,a1,a4
    80002d58:	02000537          	lui	a0,0x2000
    80002d5c:	157d                	addi	a0,a0,-1
    80002d5e:	0536                	slli	a0,a0,0xd
    80002d60:	9782                	jalr	a5
}
    80002d62:	60a2                	ld	ra,8(sp)
    80002d64:	6402                	ld	s0,0(sp)
    80002d66:	0141                	addi	sp,sp,16
    80002d68:	8082                	ret

0000000080002d6a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d74:	00015497          	auipc	s1,0x15
    80002d78:	f5448493          	addi	s1,s1,-172 # 80017cc8 <tickslock>
    80002d7c:	8526                	mv	a0,s1
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	e66080e7          	jalr	-410(ra) # 80000be4 <acquire>
  ticks++;
    80002d86:	00006517          	auipc	a0,0x6
    80002d8a:	2aa50513          	addi	a0,a0,682 # 80009030 <ticks>
    80002d8e:	411c                	lw	a5,0(a0)
    80002d90:	2785                	addiw	a5,a5,1
    80002d92:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	a70080e7          	jalr	-1424(ra) # 80002804 <wakeup>
  release(&tickslock);
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	efa080e7          	jalr	-262(ra) # 80000c98 <release>
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dba:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002dbe:	00074d63          	bltz	a4,80002dd8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002dc2:	57fd                	li	a5,-1
    80002dc4:	17fe                	slli	a5,a5,0x3f
    80002dc6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002dc8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002dca:	06f70363          	beq	a4,a5,80002e30 <devintr+0x80>
  }
}
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	64a2                	ld	s1,8(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret
     (scause & 0xff) == 9){
    80002dd8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ddc:	46a5                	li	a3,9
    80002dde:	fed792e3          	bne	a5,a3,80002dc2 <devintr+0x12>
    int irq = plic_claim();
    80002de2:	00003097          	auipc	ra,0x3
    80002de6:	4e6080e7          	jalr	1254(ra) # 800062c8 <plic_claim>
    80002dea:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002dec:	47a9                	li	a5,10
    80002dee:	02f50763          	beq	a0,a5,80002e1c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002df2:	4785                	li	a5,1
    80002df4:	02f50963          	beq	a0,a5,80002e26 <devintr+0x76>
    return 1;
    80002df8:	4505                	li	a0,1
    } else if(irq){
    80002dfa:	d8f1                	beqz	s1,80002dce <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002dfc:	85a6                	mv	a1,s1
    80002dfe:	00005517          	auipc	a0,0x5
    80002e02:	55250513          	addi	a0,a0,1362 # 80008350 <states.1800+0x38>
    80002e06:	ffffd097          	auipc	ra,0xffffd
    80002e0a:	782080e7          	jalr	1922(ra) # 80000588 <printf>
      plic_complete(irq);
    80002e0e:	8526                	mv	a0,s1
    80002e10:	00003097          	auipc	ra,0x3
    80002e14:	4dc080e7          	jalr	1244(ra) # 800062ec <plic_complete>
    return 1;
    80002e18:	4505                	li	a0,1
    80002e1a:	bf55                	j	80002dce <devintr+0x1e>
      uartintr();
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	b8c080e7          	jalr	-1140(ra) # 800009a8 <uartintr>
    80002e24:	b7ed                	j	80002e0e <devintr+0x5e>
      virtio_disk_intr();
    80002e26:	00004097          	auipc	ra,0x4
    80002e2a:	9a6080e7          	jalr	-1626(ra) # 800067cc <virtio_disk_intr>
    80002e2e:	b7c5                	j	80002e0e <devintr+0x5e>
    if(cpuid() == 0){
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	f5c080e7          	jalr	-164(ra) # 80001d8c <cpuid>
    80002e38:	c901                	beqz	a0,80002e48 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e3a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e3e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e40:	14479073          	csrw	sip,a5
    return 2;
    80002e44:	4509                	li	a0,2
    80002e46:	b761                	j	80002dce <devintr+0x1e>
      clockintr();
    80002e48:	00000097          	auipc	ra,0x0
    80002e4c:	f22080e7          	jalr	-222(ra) # 80002d6a <clockintr>
    80002e50:	b7ed                	j	80002e3a <devintr+0x8a>

0000000080002e52 <usertrap>:
{
    80002e52:	1101                	addi	sp,sp,-32
    80002e54:	ec06                	sd	ra,24(sp)
    80002e56:	e822                	sd	s0,16(sp)
    80002e58:	e426                	sd	s1,8(sp)
    80002e5a:	e04a                	sd	s2,0(sp)
    80002e5c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e5e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e62:	1007f793          	andi	a5,a5,256
    80002e66:	e3ad                	bnez	a5,80002ec8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e68:	00003797          	auipc	a5,0x3
    80002e6c:	35878793          	addi	a5,a5,856 # 800061c0 <kernelvec>
    80002e70:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	f4c080e7          	jalr	-180(ra) # 80001dc0 <myproc>
    80002e7c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e7e:	615c                	ld	a5,128(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e80:	14102773          	csrr	a4,sepc
    80002e84:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e86:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e8a:	47a1                	li	a5,8
    80002e8c:	04f71c63          	bne	a4,a5,80002ee4 <usertrap+0x92>
    if(p->killed)
    80002e90:	551c                	lw	a5,40(a0)
    80002e92:	e3b9                	bnez	a5,80002ed8 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002e94:	60d8                	ld	a4,128(s1)
    80002e96:	6f1c                	ld	a5,24(a4)
    80002e98:	0791                	addi	a5,a5,4
    80002e9a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ea0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ea4:	10079073          	csrw	sstatus,a5
    syscall();
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	2e0080e7          	jalr	736(ra) # 80003188 <syscall>
  if(p->killed)
    80002eb0:	549c                	lw	a5,40(s1)
    80002eb2:	ebc1                	bnez	a5,80002f42 <usertrap+0xf0>
  usertrapret();
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	e18080e7          	jalr	-488(ra) # 80002ccc <usertrapret>
}
    80002ebc:	60e2                	ld	ra,24(sp)
    80002ebe:	6442                	ld	s0,16(sp)
    80002ec0:	64a2                	ld	s1,8(sp)
    80002ec2:	6902                	ld	s2,0(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret
    panic("usertrap: not from user mode");
    80002ec8:	00005517          	auipc	a0,0x5
    80002ecc:	4a850513          	addi	a0,a0,1192 # 80008370 <states.1800+0x58>
    80002ed0:	ffffd097          	auipc	ra,0xffffd
    80002ed4:	66e080e7          	jalr	1646(ra) # 8000053e <panic>
      exit(-1);
    80002ed8:	557d                	li	a0,-1
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	a76080e7          	jalr	-1418(ra) # 80002950 <exit>
    80002ee2:	bf4d                	j	80002e94 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	ecc080e7          	jalr	-308(ra) # 80002db0 <devintr>
    80002eec:	892a                	mv	s2,a0
    80002eee:	c501                	beqz	a0,80002ef6 <usertrap+0xa4>
  if(p->killed)
    80002ef0:	549c                	lw	a5,40(s1)
    80002ef2:	c3a1                	beqz	a5,80002f32 <usertrap+0xe0>
    80002ef4:	a815                	j	80002f28 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ef6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002efa:	5890                	lw	a2,48(s1)
    80002efc:	00005517          	auipc	a0,0x5
    80002f00:	49450513          	addi	a0,a0,1172 # 80008390 <states.1800+0x78>
    80002f04:	ffffd097          	auipc	ra,0xffffd
    80002f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f0c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f10:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f14:	00005517          	auipc	a0,0x5
    80002f18:	4ac50513          	addi	a0,a0,1196 # 800083c0 <states.1800+0xa8>
    80002f1c:	ffffd097          	auipc	ra,0xffffd
    80002f20:	66c080e7          	jalr	1644(ra) # 80000588 <printf>
    p->killed = 1;
    80002f24:	4785                	li	a5,1
    80002f26:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002f28:	557d                	li	a0,-1
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	a26080e7          	jalr	-1498(ra) # 80002950 <exit>
  if(which_dev == 2)
    80002f32:	4789                	li	a5,2
    80002f34:	f8f910e3          	bne	s2,a5,80002eb4 <usertrap+0x62>
    yield();
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	636080e7          	jalr	1590(ra) # 8000256e <yield>
    80002f40:	bf95                	j	80002eb4 <usertrap+0x62>
  int which_dev = 0;
    80002f42:	4901                	li	s2,0
    80002f44:	b7d5                	j	80002f28 <usertrap+0xd6>

0000000080002f46 <kerneltrap>:
{
    80002f46:	7179                	addi	sp,sp,-48
    80002f48:	f406                	sd	ra,40(sp)
    80002f4a:	f022                	sd	s0,32(sp)
    80002f4c:	ec26                	sd	s1,24(sp)
    80002f4e:	e84a                	sd	s2,16(sp)
    80002f50:	e44e                	sd	s3,8(sp)
    80002f52:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f54:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f58:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f5c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f60:	1004f793          	andi	a5,s1,256
    80002f64:	cb85                	beqz	a5,80002f94 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f6a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f6c:	ef85                	bnez	a5,80002fa4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f6e:	00000097          	auipc	ra,0x0
    80002f72:	e42080e7          	jalr	-446(ra) # 80002db0 <devintr>
    80002f76:	cd1d                	beqz	a0,80002fb4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f78:	4789                	li	a5,2
    80002f7a:	06f50a63          	beq	a0,a5,80002fee <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f7e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f82:	10049073          	csrw	sstatus,s1
}
    80002f86:	70a2                	ld	ra,40(sp)
    80002f88:	7402                	ld	s0,32(sp)
    80002f8a:	64e2                	ld	s1,24(sp)
    80002f8c:	6942                	ld	s2,16(sp)
    80002f8e:	69a2                	ld	s3,8(sp)
    80002f90:	6145                	addi	sp,sp,48
    80002f92:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f94:	00005517          	auipc	a0,0x5
    80002f98:	44c50513          	addi	a0,a0,1100 # 800083e0 <states.1800+0xc8>
    80002f9c:	ffffd097          	auipc	ra,0xffffd
    80002fa0:	5a2080e7          	jalr	1442(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002fa4:	00005517          	auipc	a0,0x5
    80002fa8:	46450513          	addi	a0,a0,1124 # 80008408 <states.1800+0xf0>
    80002fac:	ffffd097          	auipc	ra,0xffffd
    80002fb0:	592080e7          	jalr	1426(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002fb4:	85ce                	mv	a1,s3
    80002fb6:	00005517          	auipc	a0,0x5
    80002fba:	47250513          	addi	a0,a0,1138 # 80008428 <states.1800+0x110>
    80002fbe:	ffffd097          	auipc	ra,0xffffd
    80002fc2:	5ca080e7          	jalr	1482(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fc6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fca:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fce:	00005517          	auipc	a0,0x5
    80002fd2:	46a50513          	addi	a0,a0,1130 # 80008438 <states.1800+0x120>
    80002fd6:	ffffd097          	auipc	ra,0xffffd
    80002fda:	5b2080e7          	jalr	1458(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002fde:	00005517          	auipc	a0,0x5
    80002fe2:	47250513          	addi	a0,a0,1138 # 80008450 <states.1800+0x138>
    80002fe6:	ffffd097          	auipc	ra,0xffffd
    80002fea:	558080e7          	jalr	1368(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fee:	fffff097          	auipc	ra,0xfffff
    80002ff2:	dd2080e7          	jalr	-558(ra) # 80001dc0 <myproc>
    80002ff6:	d541                	beqz	a0,80002f7e <kerneltrap+0x38>
    80002ff8:	fffff097          	auipc	ra,0xfffff
    80002ffc:	dc8080e7          	jalr	-568(ra) # 80001dc0 <myproc>
    80003000:	4d18                	lw	a4,24(a0)
    80003002:	4791                	li	a5,4
    80003004:	f6f71de3          	bne	a4,a5,80002f7e <kerneltrap+0x38>
    yield();
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	566080e7          	jalr	1382(ra) # 8000256e <yield>
    80003010:	b7bd                	j	80002f7e <kerneltrap+0x38>

0000000080003012 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003012:	1101                	addi	sp,sp,-32
    80003014:	ec06                	sd	ra,24(sp)
    80003016:	e822                	sd	s0,16(sp)
    80003018:	e426                	sd	s1,8(sp)
    8000301a:	1000                	addi	s0,sp,32
    8000301c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	da2080e7          	jalr	-606(ra) # 80001dc0 <myproc>
  switch (n) {
    80003026:	4795                	li	a5,5
    80003028:	0497e163          	bltu	a5,s1,8000306a <argraw+0x58>
    8000302c:	048a                	slli	s1,s1,0x2
    8000302e:	00005717          	auipc	a4,0x5
    80003032:	45a70713          	addi	a4,a4,1114 # 80008488 <states.1800+0x170>
    80003036:	94ba                	add	s1,s1,a4
    80003038:	409c                	lw	a5,0(s1)
    8000303a:	97ba                	add	a5,a5,a4
    8000303c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000303e:	615c                	ld	a5,128(a0)
    80003040:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret
    return p->trapframe->a1;
    8000304c:	615c                	ld	a5,128(a0)
    8000304e:	7fa8                	ld	a0,120(a5)
    80003050:	bfcd                	j	80003042 <argraw+0x30>
    return p->trapframe->a2;
    80003052:	615c                	ld	a5,128(a0)
    80003054:	63c8                	ld	a0,128(a5)
    80003056:	b7f5                	j	80003042 <argraw+0x30>
    return p->trapframe->a3;
    80003058:	615c                	ld	a5,128(a0)
    8000305a:	67c8                	ld	a0,136(a5)
    8000305c:	b7dd                	j	80003042 <argraw+0x30>
    return p->trapframe->a4;
    8000305e:	615c                	ld	a5,128(a0)
    80003060:	6bc8                	ld	a0,144(a5)
    80003062:	b7c5                	j	80003042 <argraw+0x30>
    return p->trapframe->a5;
    80003064:	615c                	ld	a5,128(a0)
    80003066:	6fc8                	ld	a0,152(a5)
    80003068:	bfe9                	j	80003042 <argraw+0x30>
  panic("argraw");
    8000306a:	00005517          	auipc	a0,0x5
    8000306e:	3f650513          	addi	a0,a0,1014 # 80008460 <states.1800+0x148>
    80003072:	ffffd097          	auipc	ra,0xffffd
    80003076:	4cc080e7          	jalr	1228(ra) # 8000053e <panic>

000000008000307a <fetchaddr>:
{
    8000307a:	1101                	addi	sp,sp,-32
    8000307c:	ec06                	sd	ra,24(sp)
    8000307e:	e822                	sd	s0,16(sp)
    80003080:	e426                	sd	s1,8(sp)
    80003082:	e04a                	sd	s2,0(sp)
    80003084:	1000                	addi	s0,sp,32
    80003086:	84aa                	mv	s1,a0
    80003088:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000308a:	fffff097          	auipc	ra,0xfffff
    8000308e:	d36080e7          	jalr	-714(ra) # 80001dc0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003092:	793c                	ld	a5,112(a0)
    80003094:	02f4f863          	bgeu	s1,a5,800030c4 <fetchaddr+0x4a>
    80003098:	00848713          	addi	a4,s1,8
    8000309c:	02e7e663          	bltu	a5,a4,800030c8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030a0:	46a1                	li	a3,8
    800030a2:	8626                	mv	a2,s1
    800030a4:	85ca                	mv	a1,s2
    800030a6:	7d28                	ld	a0,120(a0)
    800030a8:	ffffe097          	auipc	ra,0xffffe
    800030ac:	656080e7          	jalr	1622(ra) # 800016fe <copyin>
    800030b0:	00a03533          	snez	a0,a0
    800030b4:	40a00533          	neg	a0,a0
}
    800030b8:	60e2                	ld	ra,24(sp)
    800030ba:	6442                	ld	s0,16(sp)
    800030bc:	64a2                	ld	s1,8(sp)
    800030be:	6902                	ld	s2,0(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret
    return -1;
    800030c4:	557d                	li	a0,-1
    800030c6:	bfcd                	j	800030b8 <fetchaddr+0x3e>
    800030c8:	557d                	li	a0,-1
    800030ca:	b7fd                	j	800030b8 <fetchaddr+0x3e>

00000000800030cc <fetchstr>:
{
    800030cc:	7179                	addi	sp,sp,-48
    800030ce:	f406                	sd	ra,40(sp)
    800030d0:	f022                	sd	s0,32(sp)
    800030d2:	ec26                	sd	s1,24(sp)
    800030d4:	e84a                	sd	s2,16(sp)
    800030d6:	e44e                	sd	s3,8(sp)
    800030d8:	1800                	addi	s0,sp,48
    800030da:	892a                	mv	s2,a0
    800030dc:	84ae                	mv	s1,a1
    800030de:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030e0:	fffff097          	auipc	ra,0xfffff
    800030e4:	ce0080e7          	jalr	-800(ra) # 80001dc0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800030e8:	86ce                	mv	a3,s3
    800030ea:	864a                	mv	a2,s2
    800030ec:	85a6                	mv	a1,s1
    800030ee:	7d28                	ld	a0,120(a0)
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	69a080e7          	jalr	1690(ra) # 8000178a <copyinstr>
  if(err < 0)
    800030f8:	00054763          	bltz	a0,80003106 <fetchstr+0x3a>
  return strlen(buf);
    800030fc:	8526                	mv	a0,s1
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	d66080e7          	jalr	-666(ra) # 80000e64 <strlen>
}
    80003106:	70a2                	ld	ra,40(sp)
    80003108:	7402                	ld	s0,32(sp)
    8000310a:	64e2                	ld	s1,24(sp)
    8000310c:	6942                	ld	s2,16(sp)
    8000310e:	69a2                	ld	s3,8(sp)
    80003110:	6145                	addi	sp,sp,48
    80003112:	8082                	ret

0000000080003114 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003114:	1101                	addi	sp,sp,-32
    80003116:	ec06                	sd	ra,24(sp)
    80003118:	e822                	sd	s0,16(sp)
    8000311a:	e426                	sd	s1,8(sp)
    8000311c:	1000                	addi	s0,sp,32
    8000311e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003120:	00000097          	auipc	ra,0x0
    80003124:	ef2080e7          	jalr	-270(ra) # 80003012 <argraw>
    80003128:	c088                	sw	a0,0(s1)
  return 0;
}
    8000312a:	4501                	li	a0,0
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6105                	addi	sp,sp,32
    80003134:	8082                	ret

0000000080003136 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003136:	1101                	addi	sp,sp,-32
    80003138:	ec06                	sd	ra,24(sp)
    8000313a:	e822                	sd	s0,16(sp)
    8000313c:	e426                	sd	s1,8(sp)
    8000313e:	1000                	addi	s0,sp,32
    80003140:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003142:	00000097          	auipc	ra,0x0
    80003146:	ed0080e7          	jalr	-304(ra) # 80003012 <argraw>
    8000314a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000314c:	4501                	li	a0,0
    8000314e:	60e2                	ld	ra,24(sp)
    80003150:	6442                	ld	s0,16(sp)
    80003152:	64a2                	ld	s1,8(sp)
    80003154:	6105                	addi	sp,sp,32
    80003156:	8082                	ret

0000000080003158 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003158:	1101                	addi	sp,sp,-32
    8000315a:	ec06                	sd	ra,24(sp)
    8000315c:	e822                	sd	s0,16(sp)
    8000315e:	e426                	sd	s1,8(sp)
    80003160:	e04a                	sd	s2,0(sp)
    80003162:	1000                	addi	s0,sp,32
    80003164:	84ae                	mv	s1,a1
    80003166:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003168:	00000097          	auipc	ra,0x0
    8000316c:	eaa080e7          	jalr	-342(ra) # 80003012 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003170:	864a                	mv	a2,s2
    80003172:	85a6                	mv	a1,s1
    80003174:	00000097          	auipc	ra,0x0
    80003178:	f58080e7          	jalr	-168(ra) # 800030cc <fetchstr>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6902                	ld	s2,0(sp)
    80003184:	6105                	addi	sp,sp,32
    80003186:	8082                	ret

0000000080003188 <syscall>:
[SYS_cpu_process_count] sys_cpu_process_count,
};

void
syscall(void)
{
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	e426                	sd	s1,8(sp)
    80003190:	e04a                	sd	s2,0(sp)
    80003192:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	c2c080e7          	jalr	-980(ra) # 80001dc0 <myproc>
    8000319c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000319e:	08053903          	ld	s2,128(a0)
    800031a2:	0a893783          	ld	a5,168(s2)
    800031a6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800031aa:	37fd                	addiw	a5,a5,-1
    800031ac:	475d                	li	a4,23
    800031ae:	00f76f63          	bltu	a4,a5,800031cc <syscall+0x44>
    800031b2:	00369713          	slli	a4,a3,0x3
    800031b6:	00005797          	auipc	a5,0x5
    800031ba:	2ea78793          	addi	a5,a5,746 # 800084a0 <syscalls>
    800031be:	97ba                	add	a5,a5,a4
    800031c0:	639c                	ld	a5,0(a5)
    800031c2:	c789                	beqz	a5,800031cc <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800031c4:	9782                	jalr	a5
    800031c6:	06a93823          	sd	a0,112(s2)
    800031ca:	a839                	j	800031e8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031cc:	18048613          	addi	a2,s1,384
    800031d0:	588c                	lw	a1,48(s1)
    800031d2:	00005517          	auipc	a0,0x5
    800031d6:	29650513          	addi	a0,a0,662 # 80008468 <states.1800+0x150>
    800031da:	ffffd097          	auipc	ra,0xffffd
    800031de:	3ae080e7          	jalr	942(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031e2:	60dc                	ld	a5,128(s1)
    800031e4:	577d                	li	a4,-1
    800031e6:	fbb8                	sd	a4,112(a5)
  }
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6902                	ld	s2,0(sp)
    800031f0:	6105                	addi	sp,sp,32
    800031f2:	8082                	ret

00000000800031f4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031fc:	fec40593          	addi	a1,s0,-20
    80003200:	4501                	li	a0,0
    80003202:	00000097          	auipc	ra,0x0
    80003206:	f12080e7          	jalr	-238(ra) # 80003114 <argint>
    return -1;
    8000320a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000320c:	00054963          	bltz	a0,8000321e <sys_exit+0x2a>
  exit(n);
    80003210:	fec42503          	lw	a0,-20(s0)
    80003214:	fffff097          	auipc	ra,0xfffff
    80003218:	73c080e7          	jalr	1852(ra) # 80002950 <exit>
  return 0;  // not reached
    8000321c:	4781                	li	a5,0
}
    8000321e:	853e                	mv	a0,a5
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	6105                	addi	sp,sp,32
    80003226:	8082                	ret

0000000080003228 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003228:	1141                	addi	sp,sp,-16
    8000322a:	e406                	sd	ra,8(sp)
    8000322c:	e022                	sd	s0,0(sp)
    8000322e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003230:	fffff097          	auipc	ra,0xfffff
    80003234:	b90080e7          	jalr	-1136(ra) # 80001dc0 <myproc>
}
    80003238:	5908                	lw	a0,48(a0)
    8000323a:	60a2                	ld	ra,8(sp)
    8000323c:	6402                	ld	s0,0(sp)
    8000323e:	0141                	addi	sp,sp,16
    80003240:	8082                	ret

0000000080003242 <sys_fork>:

uint64
sys_fork(void)
{
    80003242:	1141                	addi	sp,sp,-16
    80003244:	e406                	sd	ra,8(sp)
    80003246:	e022                	sd	s0,0(sp)
    80003248:	0800                	addi	s0,sp,16
  return fork();
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	fa0080e7          	jalr	-96(ra) # 800021ea <fork>
}
    80003252:	60a2                	ld	ra,8(sp)
    80003254:	6402                	ld	s0,0(sp)
    80003256:	0141                	addi	sp,sp,16
    80003258:	8082                	ret

000000008000325a <sys_wait>:

uint64
sys_wait(void)
{
    8000325a:	1101                	addi	sp,sp,-32
    8000325c:	ec06                	sd	ra,24(sp)
    8000325e:	e822                	sd	s0,16(sp)
    80003260:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003262:	fe840593          	addi	a1,s0,-24
    80003266:	4501                	li	a0,0
    80003268:	00000097          	auipc	ra,0x0
    8000326c:	ece080e7          	jalr	-306(ra) # 80003136 <argaddr>
    80003270:	87aa                	mv	a5,a0
    return -1;
    80003272:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003274:	0007c863          	bltz	a5,80003284 <sys_wait+0x2a>
  return wait(p);
    80003278:	fe843503          	ld	a0,-24(s0)
    8000327c:	fffff097          	auipc	ra,0xfffff
    80003280:	460080e7          	jalr	1120(ra) # 800026dc <wait>
}
    80003284:	60e2                	ld	ra,24(sp)
    80003286:	6442                	ld	s0,16(sp)
    80003288:	6105                	addi	sp,sp,32
    8000328a:	8082                	ret

000000008000328c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000328c:	7179                	addi	sp,sp,-48
    8000328e:	f406                	sd	ra,40(sp)
    80003290:	f022                	sd	s0,32(sp)
    80003292:	ec26                	sd	s1,24(sp)
    80003294:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003296:	fdc40593          	addi	a1,s0,-36
    8000329a:	4501                	li	a0,0
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	e78080e7          	jalr	-392(ra) # 80003114 <argint>
    800032a4:	87aa                	mv	a5,a0
    return -1;
    800032a6:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800032a8:	0207c063          	bltz	a5,800032c8 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    800032ac:	fffff097          	auipc	ra,0xfffff
    800032b0:	b14080e7          	jalr	-1260(ra) # 80001dc0 <myproc>
    800032b4:	5924                	lw	s1,112(a0)
  if(growproc(n) < 0)
    800032b6:	fdc42503          	lw	a0,-36(s0)
    800032ba:	fffff097          	auipc	ra,0xfffff
    800032be:	e80080e7          	jalr	-384(ra) # 8000213a <growproc>
    800032c2:	00054863          	bltz	a0,800032d2 <sys_sbrk+0x46>
    return -1;
  return addr;
    800032c6:	8526                	mv	a0,s1
}
    800032c8:	70a2                	ld	ra,40(sp)
    800032ca:	7402                	ld	s0,32(sp)
    800032cc:	64e2                	ld	s1,24(sp)
    800032ce:	6145                	addi	sp,sp,48
    800032d0:	8082                	ret
    return -1;
    800032d2:	557d                	li	a0,-1
    800032d4:	bfd5                	j	800032c8 <sys_sbrk+0x3c>

00000000800032d6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032d6:	7139                	addi	sp,sp,-64
    800032d8:	fc06                	sd	ra,56(sp)
    800032da:	f822                	sd	s0,48(sp)
    800032dc:	f426                	sd	s1,40(sp)
    800032de:	f04a                	sd	s2,32(sp)
    800032e0:	ec4e                	sd	s3,24(sp)
    800032e2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800032e4:	fcc40593          	addi	a1,s0,-52
    800032e8:	4501                	li	a0,0
    800032ea:	00000097          	auipc	ra,0x0
    800032ee:	e2a080e7          	jalr	-470(ra) # 80003114 <argint>
    return -1;
    800032f2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032f4:	06054563          	bltz	a0,8000335e <sys_sleep+0x88>
  acquire(&tickslock);
    800032f8:	00015517          	auipc	a0,0x15
    800032fc:	9d050513          	addi	a0,a0,-1584 # 80017cc8 <tickslock>
    80003300:	ffffe097          	auipc	ra,0xffffe
    80003304:	8e4080e7          	jalr	-1820(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    80003308:	00006917          	auipc	s2,0x6
    8000330c:	d2892903          	lw	s2,-728(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003310:	fcc42783          	lw	a5,-52(s0)
    80003314:	cf85                	beqz	a5,8000334c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003316:	00015997          	auipc	s3,0x15
    8000331a:	9b298993          	addi	s3,s3,-1614 # 80017cc8 <tickslock>
    8000331e:	00006497          	auipc	s1,0x6
    80003322:	d1248493          	addi	s1,s1,-750 # 80009030 <ticks>
    if(myproc()->killed){
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	a9a080e7          	jalr	-1382(ra) # 80001dc0 <myproc>
    8000332e:	551c                	lw	a5,40(a0)
    80003330:	ef9d                	bnez	a5,8000336e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003332:	85ce                	mv	a1,s3
    80003334:	8526                	mv	a0,s1
    80003336:	fffff097          	auipc	ra,0xfffff
    8000333a:	330080e7          	jalr	816(ra) # 80002666 <sleep>
  while(ticks - ticks0 < n){
    8000333e:	409c                	lw	a5,0(s1)
    80003340:	412787bb          	subw	a5,a5,s2
    80003344:	fcc42703          	lw	a4,-52(s0)
    80003348:	fce7efe3          	bltu	a5,a4,80003326 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000334c:	00015517          	auipc	a0,0x15
    80003350:	97c50513          	addi	a0,a0,-1668 # 80017cc8 <tickslock>
    80003354:	ffffe097          	auipc	ra,0xffffe
    80003358:	944080e7          	jalr	-1724(ra) # 80000c98 <release>
  return 0;
    8000335c:	4781                	li	a5,0
}
    8000335e:	853e                	mv	a0,a5
    80003360:	70e2                	ld	ra,56(sp)
    80003362:	7442                	ld	s0,48(sp)
    80003364:	74a2                	ld	s1,40(sp)
    80003366:	7902                	ld	s2,32(sp)
    80003368:	69e2                	ld	s3,24(sp)
    8000336a:	6121                	addi	sp,sp,64
    8000336c:	8082                	ret
      release(&tickslock);
    8000336e:	00015517          	auipc	a0,0x15
    80003372:	95a50513          	addi	a0,a0,-1702 # 80017cc8 <tickslock>
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	922080e7          	jalr	-1758(ra) # 80000c98 <release>
      return -1;
    8000337e:	57fd                	li	a5,-1
    80003380:	bff9                	j	8000335e <sys_sleep+0x88>

0000000080003382 <sys_set_cpu>:

uint64
sys_set_cpu(void)
{
    80003382:	1101                	addi	sp,sp,-32
    80003384:	ec06                	sd	ra,24(sp)
    80003386:	e822                	sd	s0,16(sp)
    80003388:	1000                	addi	s0,sp,32
  int cpu_id;
  if(argint(0, &cpu_id) < 0)
    8000338a:	fec40593          	addi	a1,s0,-20
    8000338e:	4501                	li	a0,0
    80003390:	00000097          	auipc	ra,0x0
    80003394:	d84080e7          	jalr	-636(ra) # 80003114 <argint>
    80003398:	87aa                	mv	a5,a0
    return -1;
    8000339a:	557d                	li	a0,-1
  if(argint(0, &cpu_id) < 0)
    8000339c:	0007c863          	bltz	a5,800033ac <sys_set_cpu+0x2a>
  return set_cpu(cpu_id);
    800033a0:	fec42503          	lw	a0,-20(s0)
    800033a4:	fffff097          	auipc	ra,0xfffff
    800033a8:	224080e7          	jalr	548(ra) # 800025c8 <set_cpu>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	6105                	addi	sp,sp,32
    800033b2:	8082                	ret

00000000800033b4 <sys_get_cpu>:

uint64
sys_get_cpu(void)
{
    800033b4:	1141                	addi	sp,sp,-16
    800033b6:	e406                	sd	ra,8(sp)
    800033b8:	e022                	sd	s0,0(sp)
    800033ba:	0800                	addi	s0,sp,16
  return get_cpu();
    800033bc:	ffffe097          	auipc	ra,0xffffe
    800033c0:	77a080e7          	jalr	1914(ra) # 80001b36 <get_cpu>
}
    800033c4:	60a2                	ld	ra,8(sp)
    800033c6:	6402                	ld	s0,0(sp)
    800033c8:	0141                	addi	sp,sp,16
    800033ca:	8082                	ret

00000000800033cc <sys_cpu_process_count>:

uint64
sys_cpu_process_count(int cpu_num){
    800033cc:	1101                	addi	sp,sp,-32
    800033ce:	ec06                	sd	ra,24(sp)
    800033d0:	e822                	sd	s0,16(sp)
    800033d2:	1000                	addi	s0,sp,32
  int cpu_id;
  if(argint(0, &cpu_id) < 0)
    800033d4:	fec40593          	addi	a1,s0,-20
    800033d8:	4501                	li	a0,0
    800033da:	00000097          	auipc	ra,0x0
    800033de:	d3a080e7          	jalr	-710(ra) # 80003114 <argint>
    800033e2:	87aa                	mv	a5,a0
    return -1;
    800033e4:	557d                	li	a0,-1
  if(argint(0, &cpu_id) < 0)
    800033e6:	0007c863          	bltz	a5,800033f6 <sys_cpu_process_count+0x2a>
  return cpu_process_count(cpu_id);
    800033ea:	fec42503          	lw	a0,-20(s0)
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	758080e7          	jalr	1880(ra) # 80001b46 <cpu_process_count>
}
    800033f6:	60e2                	ld	ra,24(sp)
    800033f8:	6442                	ld	s0,16(sp)
    800033fa:	6105                	addi	sp,sp,32
    800033fc:	8082                	ret

00000000800033fe <sys_kill>:

uint64
sys_kill(void)
{
    800033fe:	1101                	addi	sp,sp,-32
    80003400:	ec06                	sd	ra,24(sp)
    80003402:	e822                	sd	s0,16(sp)
    80003404:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003406:	fec40593          	addi	a1,s0,-20
    8000340a:	4501                	li	a0,0
    8000340c:	00000097          	auipc	ra,0x0
    80003410:	d08080e7          	jalr	-760(ra) # 80003114 <argint>
    80003414:	87aa                	mv	a5,a0
    return -1;
    80003416:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003418:	0007c863          	bltz	a5,80003428 <sys_kill+0x2a>
  return kill(pid);
    8000341c:	fec42503          	lw	a0,-20(s0)
    80003420:	fffff097          	auipc	ra,0xfffff
    80003424:	618080e7          	jalr	1560(ra) # 80002a38 <kill>
}
    80003428:	60e2                	ld	ra,24(sp)
    8000342a:	6442                	ld	s0,16(sp)
    8000342c:	6105                	addi	sp,sp,32
    8000342e:	8082                	ret

0000000080003430 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000343a:	00015517          	auipc	a0,0x15
    8000343e:	88e50513          	addi	a0,a0,-1906 # 80017cc8 <tickslock>
    80003442:	ffffd097          	auipc	ra,0xffffd
    80003446:	7a2080e7          	jalr	1954(ra) # 80000be4 <acquire>
  xticks = ticks;
    8000344a:	00006497          	auipc	s1,0x6
    8000344e:	be64a483          	lw	s1,-1050(s1) # 80009030 <ticks>
  release(&tickslock);
    80003452:	00015517          	auipc	a0,0x15
    80003456:	87650513          	addi	a0,a0,-1930 # 80017cc8 <tickslock>
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	83e080e7          	jalr	-1986(ra) # 80000c98 <release>
  return xticks;
}
    80003462:	02049513          	slli	a0,s1,0x20
    80003466:	9101                	srli	a0,a0,0x20
    80003468:	60e2                	ld	ra,24(sp)
    8000346a:	6442                	ld	s0,16(sp)
    8000346c:	64a2                	ld	s1,8(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret

0000000080003472 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	e052                	sd	s4,0(sp)
    80003480:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003482:	00005597          	auipc	a1,0x5
    80003486:	0e658593          	addi	a1,a1,230 # 80008568 <syscalls+0xc8>
    8000348a:	00015517          	auipc	a0,0x15
    8000348e:	85650513          	addi	a0,a0,-1962 # 80017ce0 <bcache>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	6c2080e7          	jalr	1730(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000349a:	0001d797          	auipc	a5,0x1d
    8000349e:	84678793          	addi	a5,a5,-1978 # 8001fce0 <bcache+0x8000>
    800034a2:	0001d717          	auipc	a4,0x1d
    800034a6:	aa670713          	addi	a4,a4,-1370 # 8001ff48 <bcache+0x8268>
    800034aa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034ae:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034b2:	00015497          	auipc	s1,0x15
    800034b6:	84648493          	addi	s1,s1,-1978 # 80017cf8 <bcache+0x18>
    b->next = bcache.head.next;
    800034ba:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034bc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034be:	00005a17          	auipc	s4,0x5
    800034c2:	0b2a0a13          	addi	s4,s4,178 # 80008570 <syscalls+0xd0>
    b->next = bcache.head.next;
    800034c6:	2b893783          	ld	a5,696(s2)
    800034ca:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034cc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034d0:	85d2                	mv	a1,s4
    800034d2:	01048513          	addi	a0,s1,16
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	4bc080e7          	jalr	1212(ra) # 80004992 <initsleeplock>
    bcache.head.next->prev = b;
    800034de:	2b893783          	ld	a5,696(s2)
    800034e2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034e4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034e8:	45848493          	addi	s1,s1,1112
    800034ec:	fd349de3          	bne	s1,s3,800034c6 <binit+0x54>
  }
}
    800034f0:	70a2                	ld	ra,40(sp)
    800034f2:	7402                	ld	s0,32(sp)
    800034f4:	64e2                	ld	s1,24(sp)
    800034f6:	6942                	ld	s2,16(sp)
    800034f8:	69a2                	ld	s3,8(sp)
    800034fa:	6a02                	ld	s4,0(sp)
    800034fc:	6145                	addi	sp,sp,48
    800034fe:	8082                	ret

0000000080003500 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003500:	7179                	addi	sp,sp,-48
    80003502:	f406                	sd	ra,40(sp)
    80003504:	f022                	sd	s0,32(sp)
    80003506:	ec26                	sd	s1,24(sp)
    80003508:	e84a                	sd	s2,16(sp)
    8000350a:	e44e                	sd	s3,8(sp)
    8000350c:	1800                	addi	s0,sp,48
    8000350e:	89aa                	mv	s3,a0
    80003510:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003512:	00014517          	auipc	a0,0x14
    80003516:	7ce50513          	addi	a0,a0,1998 # 80017ce0 <bcache>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	6ca080e7          	jalr	1738(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003522:	0001d497          	auipc	s1,0x1d
    80003526:	a764b483          	ld	s1,-1418(s1) # 8001ff98 <bcache+0x82b8>
    8000352a:	0001d797          	auipc	a5,0x1d
    8000352e:	a1e78793          	addi	a5,a5,-1506 # 8001ff48 <bcache+0x8268>
    80003532:	02f48f63          	beq	s1,a5,80003570 <bread+0x70>
    80003536:	873e                	mv	a4,a5
    80003538:	a021                	j	80003540 <bread+0x40>
    8000353a:	68a4                	ld	s1,80(s1)
    8000353c:	02e48a63          	beq	s1,a4,80003570 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003540:	449c                	lw	a5,8(s1)
    80003542:	ff379ce3          	bne	a5,s3,8000353a <bread+0x3a>
    80003546:	44dc                	lw	a5,12(s1)
    80003548:	ff2799e3          	bne	a5,s2,8000353a <bread+0x3a>
      b->refcnt++;
    8000354c:	40bc                	lw	a5,64(s1)
    8000354e:	2785                	addiw	a5,a5,1
    80003550:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003552:	00014517          	auipc	a0,0x14
    80003556:	78e50513          	addi	a0,a0,1934 # 80017ce0 <bcache>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	73e080e7          	jalr	1854(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003562:	01048513          	addi	a0,s1,16
    80003566:	00001097          	auipc	ra,0x1
    8000356a:	466080e7          	jalr	1126(ra) # 800049cc <acquiresleep>
      return b;
    8000356e:	a8b9                	j	800035cc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003570:	0001d497          	auipc	s1,0x1d
    80003574:	a204b483          	ld	s1,-1504(s1) # 8001ff90 <bcache+0x82b0>
    80003578:	0001d797          	auipc	a5,0x1d
    8000357c:	9d078793          	addi	a5,a5,-1584 # 8001ff48 <bcache+0x8268>
    80003580:	00f48863          	beq	s1,a5,80003590 <bread+0x90>
    80003584:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003586:	40bc                	lw	a5,64(s1)
    80003588:	cf81                	beqz	a5,800035a0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000358a:	64a4                	ld	s1,72(s1)
    8000358c:	fee49de3          	bne	s1,a4,80003586 <bread+0x86>
  panic("bget: no buffers");
    80003590:	00005517          	auipc	a0,0x5
    80003594:	fe850513          	addi	a0,a0,-24 # 80008578 <syscalls+0xd8>
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	fa6080e7          	jalr	-90(ra) # 8000053e <panic>
      b->dev = dev;
    800035a0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800035a4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800035a8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035ac:	4785                	li	a5,1
    800035ae:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035b0:	00014517          	auipc	a0,0x14
    800035b4:	73050513          	addi	a0,a0,1840 # 80017ce0 <bcache>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	6e0080e7          	jalr	1760(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    800035c0:	01048513          	addi	a0,s1,16
    800035c4:	00001097          	auipc	ra,0x1
    800035c8:	408080e7          	jalr	1032(ra) # 800049cc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035cc:	409c                	lw	a5,0(s1)
    800035ce:	cb89                	beqz	a5,800035e0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035d0:	8526                	mv	a0,s1
    800035d2:	70a2                	ld	ra,40(sp)
    800035d4:	7402                	ld	s0,32(sp)
    800035d6:	64e2                	ld	s1,24(sp)
    800035d8:	6942                	ld	s2,16(sp)
    800035da:	69a2                	ld	s3,8(sp)
    800035dc:	6145                	addi	sp,sp,48
    800035de:	8082                	ret
    virtio_disk_rw(b, 0);
    800035e0:	4581                	li	a1,0
    800035e2:	8526                	mv	a0,s1
    800035e4:	00003097          	auipc	ra,0x3
    800035e8:	f12080e7          	jalr	-238(ra) # 800064f6 <virtio_disk_rw>
    b->valid = 1;
    800035ec:	4785                	li	a5,1
    800035ee:	c09c                	sw	a5,0(s1)
  return b;
    800035f0:	b7c5                	j	800035d0 <bread+0xd0>

00000000800035f2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035f2:	1101                	addi	sp,sp,-32
    800035f4:	ec06                	sd	ra,24(sp)
    800035f6:	e822                	sd	s0,16(sp)
    800035f8:	e426                	sd	s1,8(sp)
    800035fa:	1000                	addi	s0,sp,32
    800035fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035fe:	0541                	addi	a0,a0,16
    80003600:	00001097          	auipc	ra,0x1
    80003604:	466080e7          	jalr	1126(ra) # 80004a66 <holdingsleep>
    80003608:	cd01                	beqz	a0,80003620 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000360a:	4585                	li	a1,1
    8000360c:	8526                	mv	a0,s1
    8000360e:	00003097          	auipc	ra,0x3
    80003612:	ee8080e7          	jalr	-280(ra) # 800064f6 <virtio_disk_rw>
}
    80003616:	60e2                	ld	ra,24(sp)
    80003618:	6442                	ld	s0,16(sp)
    8000361a:	64a2                	ld	s1,8(sp)
    8000361c:	6105                	addi	sp,sp,32
    8000361e:	8082                	ret
    panic("bwrite");
    80003620:	00005517          	auipc	a0,0x5
    80003624:	f7050513          	addi	a0,a0,-144 # 80008590 <syscalls+0xf0>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	f16080e7          	jalr	-234(ra) # 8000053e <panic>

0000000080003630 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003630:	1101                	addi	sp,sp,-32
    80003632:	ec06                	sd	ra,24(sp)
    80003634:	e822                	sd	s0,16(sp)
    80003636:	e426                	sd	s1,8(sp)
    80003638:	e04a                	sd	s2,0(sp)
    8000363a:	1000                	addi	s0,sp,32
    8000363c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000363e:	01050913          	addi	s2,a0,16
    80003642:	854a                	mv	a0,s2
    80003644:	00001097          	auipc	ra,0x1
    80003648:	422080e7          	jalr	1058(ra) # 80004a66 <holdingsleep>
    8000364c:	c92d                	beqz	a0,800036be <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000364e:	854a                	mv	a0,s2
    80003650:	00001097          	auipc	ra,0x1
    80003654:	3d2080e7          	jalr	978(ra) # 80004a22 <releasesleep>

  acquire(&bcache.lock);
    80003658:	00014517          	auipc	a0,0x14
    8000365c:	68850513          	addi	a0,a0,1672 # 80017ce0 <bcache>
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	584080e7          	jalr	1412(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003668:	40bc                	lw	a5,64(s1)
    8000366a:	37fd                	addiw	a5,a5,-1
    8000366c:	0007871b          	sext.w	a4,a5
    80003670:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003672:	eb05                	bnez	a4,800036a2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003674:	68bc                	ld	a5,80(s1)
    80003676:	64b8                	ld	a4,72(s1)
    80003678:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000367a:	64bc                	ld	a5,72(s1)
    8000367c:	68b8                	ld	a4,80(s1)
    8000367e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003680:	0001c797          	auipc	a5,0x1c
    80003684:	66078793          	addi	a5,a5,1632 # 8001fce0 <bcache+0x8000>
    80003688:	2b87b703          	ld	a4,696(a5)
    8000368c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000368e:	0001d717          	auipc	a4,0x1d
    80003692:	8ba70713          	addi	a4,a4,-1862 # 8001ff48 <bcache+0x8268>
    80003696:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003698:	2b87b703          	ld	a4,696(a5)
    8000369c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000369e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036a2:	00014517          	auipc	a0,0x14
    800036a6:	63e50513          	addi	a0,a0,1598 # 80017ce0 <bcache>
    800036aa:	ffffd097          	auipc	ra,0xffffd
    800036ae:	5ee080e7          	jalr	1518(ra) # 80000c98 <release>
}
    800036b2:	60e2                	ld	ra,24(sp)
    800036b4:	6442                	ld	s0,16(sp)
    800036b6:	64a2                	ld	s1,8(sp)
    800036b8:	6902                	ld	s2,0(sp)
    800036ba:	6105                	addi	sp,sp,32
    800036bc:	8082                	ret
    panic("brelse");
    800036be:	00005517          	auipc	a0,0x5
    800036c2:	eda50513          	addi	a0,a0,-294 # 80008598 <syscalls+0xf8>
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	e78080e7          	jalr	-392(ra) # 8000053e <panic>

00000000800036ce <bpin>:

void
bpin(struct buf *b) {
    800036ce:	1101                	addi	sp,sp,-32
    800036d0:	ec06                	sd	ra,24(sp)
    800036d2:	e822                	sd	s0,16(sp)
    800036d4:	e426                	sd	s1,8(sp)
    800036d6:	1000                	addi	s0,sp,32
    800036d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036da:	00014517          	auipc	a0,0x14
    800036de:	60650513          	addi	a0,a0,1542 # 80017ce0 <bcache>
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	502080e7          	jalr	1282(ra) # 80000be4 <acquire>
  b->refcnt++;
    800036ea:	40bc                	lw	a5,64(s1)
    800036ec:	2785                	addiw	a5,a5,1
    800036ee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036f0:	00014517          	auipc	a0,0x14
    800036f4:	5f050513          	addi	a0,a0,1520 # 80017ce0 <bcache>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	5a0080e7          	jalr	1440(ra) # 80000c98 <release>
}
    80003700:	60e2                	ld	ra,24(sp)
    80003702:	6442                	ld	s0,16(sp)
    80003704:	64a2                	ld	s1,8(sp)
    80003706:	6105                	addi	sp,sp,32
    80003708:	8082                	ret

000000008000370a <bunpin>:

void
bunpin(struct buf *b) {
    8000370a:	1101                	addi	sp,sp,-32
    8000370c:	ec06                	sd	ra,24(sp)
    8000370e:	e822                	sd	s0,16(sp)
    80003710:	e426                	sd	s1,8(sp)
    80003712:	1000                	addi	s0,sp,32
    80003714:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003716:	00014517          	auipc	a0,0x14
    8000371a:	5ca50513          	addi	a0,a0,1482 # 80017ce0 <bcache>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	4c6080e7          	jalr	1222(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003726:	40bc                	lw	a5,64(s1)
    80003728:	37fd                	addiw	a5,a5,-1
    8000372a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000372c:	00014517          	auipc	a0,0x14
    80003730:	5b450513          	addi	a0,a0,1460 # 80017ce0 <bcache>
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	564080e7          	jalr	1380(ra) # 80000c98 <release>
}
    8000373c:	60e2                	ld	ra,24(sp)
    8000373e:	6442                	ld	s0,16(sp)
    80003740:	64a2                	ld	s1,8(sp)
    80003742:	6105                	addi	sp,sp,32
    80003744:	8082                	ret

0000000080003746 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	e04a                	sd	s2,0(sp)
    80003750:	1000                	addi	s0,sp,32
    80003752:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003754:	00d5d59b          	srliw	a1,a1,0xd
    80003758:	0001d797          	auipc	a5,0x1d
    8000375c:	c647a783          	lw	a5,-924(a5) # 800203bc <sb+0x1c>
    80003760:	9dbd                	addw	a1,a1,a5
    80003762:	00000097          	auipc	ra,0x0
    80003766:	d9e080e7          	jalr	-610(ra) # 80003500 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000376a:	0074f713          	andi	a4,s1,7
    8000376e:	4785                	li	a5,1
    80003770:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003774:	14ce                	slli	s1,s1,0x33
    80003776:	90d9                	srli	s1,s1,0x36
    80003778:	00950733          	add	a4,a0,s1
    8000377c:	05874703          	lbu	a4,88(a4)
    80003780:	00e7f6b3          	and	a3,a5,a4
    80003784:	c69d                	beqz	a3,800037b2 <bfree+0x6c>
    80003786:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003788:	94aa                	add	s1,s1,a0
    8000378a:	fff7c793          	not	a5,a5
    8000378e:	8ff9                	and	a5,a5,a4
    80003790:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003794:	00001097          	auipc	ra,0x1
    80003798:	118080e7          	jalr	280(ra) # 800048ac <log_write>
  brelse(bp);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	e92080e7          	jalr	-366(ra) # 80003630 <brelse>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6902                	ld	s2,0(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret
    panic("freeing free block");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	dee50513          	addi	a0,a0,-530 # 800085a0 <syscalls+0x100>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	d84080e7          	jalr	-636(ra) # 8000053e <panic>

00000000800037c2 <balloc>:
{
    800037c2:	711d                	addi	sp,sp,-96
    800037c4:	ec86                	sd	ra,88(sp)
    800037c6:	e8a2                	sd	s0,80(sp)
    800037c8:	e4a6                	sd	s1,72(sp)
    800037ca:	e0ca                	sd	s2,64(sp)
    800037cc:	fc4e                	sd	s3,56(sp)
    800037ce:	f852                	sd	s4,48(sp)
    800037d0:	f456                	sd	s5,40(sp)
    800037d2:	f05a                	sd	s6,32(sp)
    800037d4:	ec5e                	sd	s7,24(sp)
    800037d6:	e862                	sd	s8,16(sp)
    800037d8:	e466                	sd	s9,8(sp)
    800037da:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037dc:	0001d797          	auipc	a5,0x1d
    800037e0:	bc87a783          	lw	a5,-1080(a5) # 800203a4 <sb+0x4>
    800037e4:	cbd1                	beqz	a5,80003878 <balloc+0xb6>
    800037e6:	8baa                	mv	s7,a0
    800037e8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037ea:	0001db17          	auipc	s6,0x1d
    800037ee:	bb6b0b13          	addi	s6,s6,-1098 # 800203a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037f4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037f8:	6c89                	lui	s9,0x2
    800037fa:	a831                	j	80003816 <balloc+0x54>
    brelse(bp);
    800037fc:	854a                	mv	a0,s2
    800037fe:	00000097          	auipc	ra,0x0
    80003802:	e32080e7          	jalr	-462(ra) # 80003630 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003806:	015c87bb          	addw	a5,s9,s5
    8000380a:	00078a9b          	sext.w	s5,a5
    8000380e:	004b2703          	lw	a4,4(s6)
    80003812:	06eaf363          	bgeu	s5,a4,80003878 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003816:	41fad79b          	sraiw	a5,s5,0x1f
    8000381a:	0137d79b          	srliw	a5,a5,0x13
    8000381e:	015787bb          	addw	a5,a5,s5
    80003822:	40d7d79b          	sraiw	a5,a5,0xd
    80003826:	01cb2583          	lw	a1,28(s6)
    8000382a:	9dbd                	addw	a1,a1,a5
    8000382c:	855e                	mv	a0,s7
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	cd2080e7          	jalr	-814(ra) # 80003500 <bread>
    80003836:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003838:	004b2503          	lw	a0,4(s6)
    8000383c:	000a849b          	sext.w	s1,s5
    80003840:	8662                	mv	a2,s8
    80003842:	faa4fde3          	bgeu	s1,a0,800037fc <balloc+0x3a>
      m = 1 << (bi % 8);
    80003846:	41f6579b          	sraiw	a5,a2,0x1f
    8000384a:	01d7d69b          	srliw	a3,a5,0x1d
    8000384e:	00c6873b          	addw	a4,a3,a2
    80003852:	00777793          	andi	a5,a4,7
    80003856:	9f95                	subw	a5,a5,a3
    80003858:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000385c:	4037571b          	sraiw	a4,a4,0x3
    80003860:	00e906b3          	add	a3,s2,a4
    80003864:	0586c683          	lbu	a3,88(a3)
    80003868:	00d7f5b3          	and	a1,a5,a3
    8000386c:	cd91                	beqz	a1,80003888 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000386e:	2605                	addiw	a2,a2,1
    80003870:	2485                	addiw	s1,s1,1
    80003872:	fd4618e3          	bne	a2,s4,80003842 <balloc+0x80>
    80003876:	b759                	j	800037fc <balloc+0x3a>
  panic("balloc: out of blocks");
    80003878:	00005517          	auipc	a0,0x5
    8000387c:	d4050513          	addi	a0,a0,-704 # 800085b8 <syscalls+0x118>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	cbe080e7          	jalr	-834(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003888:	974a                	add	a4,a4,s2
    8000388a:	8fd5                	or	a5,a5,a3
    8000388c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003890:	854a                	mv	a0,s2
    80003892:	00001097          	auipc	ra,0x1
    80003896:	01a080e7          	jalr	26(ra) # 800048ac <log_write>
        brelse(bp);
    8000389a:	854a                	mv	a0,s2
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	d94080e7          	jalr	-620(ra) # 80003630 <brelse>
  bp = bread(dev, bno);
    800038a4:	85a6                	mv	a1,s1
    800038a6:	855e                	mv	a0,s7
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	c58080e7          	jalr	-936(ra) # 80003500 <bread>
    800038b0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038b2:	40000613          	li	a2,1024
    800038b6:	4581                	li	a1,0
    800038b8:	05850513          	addi	a0,a0,88
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	424080e7          	jalr	1060(ra) # 80000ce0 <memset>
  log_write(bp);
    800038c4:	854a                	mv	a0,s2
    800038c6:	00001097          	auipc	ra,0x1
    800038ca:	fe6080e7          	jalr	-26(ra) # 800048ac <log_write>
  brelse(bp);
    800038ce:	854a                	mv	a0,s2
    800038d0:	00000097          	auipc	ra,0x0
    800038d4:	d60080e7          	jalr	-672(ra) # 80003630 <brelse>
}
    800038d8:	8526                	mv	a0,s1
    800038da:	60e6                	ld	ra,88(sp)
    800038dc:	6446                	ld	s0,80(sp)
    800038de:	64a6                	ld	s1,72(sp)
    800038e0:	6906                	ld	s2,64(sp)
    800038e2:	79e2                	ld	s3,56(sp)
    800038e4:	7a42                	ld	s4,48(sp)
    800038e6:	7aa2                	ld	s5,40(sp)
    800038e8:	7b02                	ld	s6,32(sp)
    800038ea:	6be2                	ld	s7,24(sp)
    800038ec:	6c42                	ld	s8,16(sp)
    800038ee:	6ca2                	ld	s9,8(sp)
    800038f0:	6125                	addi	sp,sp,96
    800038f2:	8082                	ret

00000000800038f4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800038f4:	7179                	addi	sp,sp,-48
    800038f6:	f406                	sd	ra,40(sp)
    800038f8:	f022                	sd	s0,32(sp)
    800038fa:	ec26                	sd	s1,24(sp)
    800038fc:	e84a                	sd	s2,16(sp)
    800038fe:	e44e                	sd	s3,8(sp)
    80003900:	e052                	sd	s4,0(sp)
    80003902:	1800                	addi	s0,sp,48
    80003904:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003906:	47ad                	li	a5,11
    80003908:	04b7fe63          	bgeu	a5,a1,80003964 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000390c:	ff45849b          	addiw	s1,a1,-12
    80003910:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003914:	0ff00793          	li	a5,255
    80003918:	0ae7e363          	bltu	a5,a4,800039be <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000391c:	08052583          	lw	a1,128(a0)
    80003920:	c5ad                	beqz	a1,8000398a <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003922:	00092503          	lw	a0,0(s2)
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	bda080e7          	jalr	-1062(ra) # 80003500 <bread>
    8000392e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003930:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003934:	02049593          	slli	a1,s1,0x20
    80003938:	9181                	srli	a1,a1,0x20
    8000393a:	058a                	slli	a1,a1,0x2
    8000393c:	00b784b3          	add	s1,a5,a1
    80003940:	0004a983          	lw	s3,0(s1)
    80003944:	04098d63          	beqz	s3,8000399e <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003948:	8552                	mv	a0,s4
    8000394a:	00000097          	auipc	ra,0x0
    8000394e:	ce6080e7          	jalr	-794(ra) # 80003630 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003952:	854e                	mv	a0,s3
    80003954:	70a2                	ld	ra,40(sp)
    80003956:	7402                	ld	s0,32(sp)
    80003958:	64e2                	ld	s1,24(sp)
    8000395a:	6942                	ld	s2,16(sp)
    8000395c:	69a2                	ld	s3,8(sp)
    8000395e:	6a02                	ld	s4,0(sp)
    80003960:	6145                	addi	sp,sp,48
    80003962:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003964:	02059493          	slli	s1,a1,0x20
    80003968:	9081                	srli	s1,s1,0x20
    8000396a:	048a                	slli	s1,s1,0x2
    8000396c:	94aa                	add	s1,s1,a0
    8000396e:	0504a983          	lw	s3,80(s1)
    80003972:	fe0990e3          	bnez	s3,80003952 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003976:	4108                	lw	a0,0(a0)
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	e4a080e7          	jalr	-438(ra) # 800037c2 <balloc>
    80003980:	0005099b          	sext.w	s3,a0
    80003984:	0534a823          	sw	s3,80(s1)
    80003988:	b7e9                	j	80003952 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000398a:	4108                	lw	a0,0(a0)
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	e36080e7          	jalr	-458(ra) # 800037c2 <balloc>
    80003994:	0005059b          	sext.w	a1,a0
    80003998:	08b92023          	sw	a1,128(s2)
    8000399c:	b759                	j	80003922 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000399e:	00092503          	lw	a0,0(s2)
    800039a2:	00000097          	auipc	ra,0x0
    800039a6:	e20080e7          	jalr	-480(ra) # 800037c2 <balloc>
    800039aa:	0005099b          	sext.w	s3,a0
    800039ae:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800039b2:	8552                	mv	a0,s4
    800039b4:	00001097          	auipc	ra,0x1
    800039b8:	ef8080e7          	jalr	-264(ra) # 800048ac <log_write>
    800039bc:	b771                	j	80003948 <bmap+0x54>
  panic("bmap: out of range");
    800039be:	00005517          	auipc	a0,0x5
    800039c2:	c1250513          	addi	a0,a0,-1006 # 800085d0 <syscalls+0x130>
    800039c6:	ffffd097          	auipc	ra,0xffffd
    800039ca:	b78080e7          	jalr	-1160(ra) # 8000053e <panic>

00000000800039ce <iget>:
{
    800039ce:	7179                	addi	sp,sp,-48
    800039d0:	f406                	sd	ra,40(sp)
    800039d2:	f022                	sd	s0,32(sp)
    800039d4:	ec26                	sd	s1,24(sp)
    800039d6:	e84a                	sd	s2,16(sp)
    800039d8:	e44e                	sd	s3,8(sp)
    800039da:	e052                	sd	s4,0(sp)
    800039dc:	1800                	addi	s0,sp,48
    800039de:	89aa                	mv	s3,a0
    800039e0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039e2:	0001d517          	auipc	a0,0x1d
    800039e6:	9de50513          	addi	a0,a0,-1570 # 800203c0 <itable>
    800039ea:	ffffd097          	auipc	ra,0xffffd
    800039ee:	1fa080e7          	jalr	506(ra) # 80000be4 <acquire>
  empty = 0;
    800039f2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039f4:	0001d497          	auipc	s1,0x1d
    800039f8:	9e448493          	addi	s1,s1,-1564 # 800203d8 <itable+0x18>
    800039fc:	0001e697          	auipc	a3,0x1e
    80003a00:	46c68693          	addi	a3,a3,1132 # 80021e68 <log>
    80003a04:	a039                	j	80003a12 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a06:	02090b63          	beqz	s2,80003a3c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a0a:	08848493          	addi	s1,s1,136
    80003a0e:	02d48a63          	beq	s1,a3,80003a42 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a12:	449c                	lw	a5,8(s1)
    80003a14:	fef059e3          	blez	a5,80003a06 <iget+0x38>
    80003a18:	4098                	lw	a4,0(s1)
    80003a1a:	ff3716e3          	bne	a4,s3,80003a06 <iget+0x38>
    80003a1e:	40d8                	lw	a4,4(s1)
    80003a20:	ff4713e3          	bne	a4,s4,80003a06 <iget+0x38>
      ip->ref++;
    80003a24:	2785                	addiw	a5,a5,1
    80003a26:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a28:	0001d517          	auipc	a0,0x1d
    80003a2c:	99850513          	addi	a0,a0,-1640 # 800203c0 <itable>
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	268080e7          	jalr	616(ra) # 80000c98 <release>
      return ip;
    80003a38:	8926                	mv	s2,s1
    80003a3a:	a03d                	j	80003a68 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a3c:	f7f9                	bnez	a5,80003a0a <iget+0x3c>
    80003a3e:	8926                	mv	s2,s1
    80003a40:	b7e9                	j	80003a0a <iget+0x3c>
  if(empty == 0)
    80003a42:	02090c63          	beqz	s2,80003a7a <iget+0xac>
  ip->dev = dev;
    80003a46:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a4a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a4e:	4785                	li	a5,1
    80003a50:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a54:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a58:	0001d517          	auipc	a0,0x1d
    80003a5c:	96850513          	addi	a0,a0,-1688 # 800203c0 <itable>
    80003a60:	ffffd097          	auipc	ra,0xffffd
    80003a64:	238080e7          	jalr	568(ra) # 80000c98 <release>
}
    80003a68:	854a                	mv	a0,s2
    80003a6a:	70a2                	ld	ra,40(sp)
    80003a6c:	7402                	ld	s0,32(sp)
    80003a6e:	64e2                	ld	s1,24(sp)
    80003a70:	6942                	ld	s2,16(sp)
    80003a72:	69a2                	ld	s3,8(sp)
    80003a74:	6a02                	ld	s4,0(sp)
    80003a76:	6145                	addi	sp,sp,48
    80003a78:	8082                	ret
    panic("iget: no inodes");
    80003a7a:	00005517          	auipc	a0,0x5
    80003a7e:	b6e50513          	addi	a0,a0,-1170 # 800085e8 <syscalls+0x148>
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	abc080e7          	jalr	-1348(ra) # 8000053e <panic>

0000000080003a8a <fsinit>:
fsinit(int dev) {
    80003a8a:	7179                	addi	sp,sp,-48
    80003a8c:	f406                	sd	ra,40(sp)
    80003a8e:	f022                	sd	s0,32(sp)
    80003a90:	ec26                	sd	s1,24(sp)
    80003a92:	e84a                	sd	s2,16(sp)
    80003a94:	e44e                	sd	s3,8(sp)
    80003a96:	1800                	addi	s0,sp,48
    80003a98:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a9a:	4585                	li	a1,1
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	a64080e7          	jalr	-1436(ra) # 80003500 <bread>
    80003aa4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003aa6:	0001d997          	auipc	s3,0x1d
    80003aaa:	8fa98993          	addi	s3,s3,-1798 # 800203a0 <sb>
    80003aae:	02000613          	li	a2,32
    80003ab2:	05850593          	addi	a1,a0,88
    80003ab6:	854e                	mv	a0,s3
    80003ab8:	ffffd097          	auipc	ra,0xffffd
    80003abc:	288080e7          	jalr	648(ra) # 80000d40 <memmove>
  brelse(bp);
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	b6e080e7          	jalr	-1170(ra) # 80003630 <brelse>
  if(sb.magic != FSMAGIC)
    80003aca:	0009a703          	lw	a4,0(s3)
    80003ace:	102037b7          	lui	a5,0x10203
    80003ad2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ad6:	02f71263          	bne	a4,a5,80003afa <fsinit+0x70>
  initlog(dev, &sb);
    80003ada:	0001d597          	auipc	a1,0x1d
    80003ade:	8c658593          	addi	a1,a1,-1850 # 800203a0 <sb>
    80003ae2:	854a                	mv	a0,s2
    80003ae4:	00001097          	auipc	ra,0x1
    80003ae8:	b4c080e7          	jalr	-1204(ra) # 80004630 <initlog>
}
    80003aec:	70a2                	ld	ra,40(sp)
    80003aee:	7402                	ld	s0,32(sp)
    80003af0:	64e2                	ld	s1,24(sp)
    80003af2:	6942                	ld	s2,16(sp)
    80003af4:	69a2                	ld	s3,8(sp)
    80003af6:	6145                	addi	sp,sp,48
    80003af8:	8082                	ret
    panic("invalid file system");
    80003afa:	00005517          	auipc	a0,0x5
    80003afe:	afe50513          	addi	a0,a0,-1282 # 800085f8 <syscalls+0x158>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	a3c080e7          	jalr	-1476(ra) # 8000053e <panic>

0000000080003b0a <iinit>:
{
    80003b0a:	7179                	addi	sp,sp,-48
    80003b0c:	f406                	sd	ra,40(sp)
    80003b0e:	f022                	sd	s0,32(sp)
    80003b10:	ec26                	sd	s1,24(sp)
    80003b12:	e84a                	sd	s2,16(sp)
    80003b14:	e44e                	sd	s3,8(sp)
    80003b16:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b18:	00005597          	auipc	a1,0x5
    80003b1c:	af858593          	addi	a1,a1,-1288 # 80008610 <syscalls+0x170>
    80003b20:	0001d517          	auipc	a0,0x1d
    80003b24:	8a050513          	addi	a0,a0,-1888 # 800203c0 <itable>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	02c080e7          	jalr	44(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b30:	0001d497          	auipc	s1,0x1d
    80003b34:	8b848493          	addi	s1,s1,-1864 # 800203e8 <itable+0x28>
    80003b38:	0001e997          	auipc	s3,0x1e
    80003b3c:	34098993          	addi	s3,s3,832 # 80021e78 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b40:	00005917          	auipc	s2,0x5
    80003b44:	ad890913          	addi	s2,s2,-1320 # 80008618 <syscalls+0x178>
    80003b48:	85ca                	mv	a1,s2
    80003b4a:	8526                	mv	a0,s1
    80003b4c:	00001097          	auipc	ra,0x1
    80003b50:	e46080e7          	jalr	-442(ra) # 80004992 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b54:	08848493          	addi	s1,s1,136
    80003b58:	ff3498e3          	bne	s1,s3,80003b48 <iinit+0x3e>
}
    80003b5c:	70a2                	ld	ra,40(sp)
    80003b5e:	7402                	ld	s0,32(sp)
    80003b60:	64e2                	ld	s1,24(sp)
    80003b62:	6942                	ld	s2,16(sp)
    80003b64:	69a2                	ld	s3,8(sp)
    80003b66:	6145                	addi	sp,sp,48
    80003b68:	8082                	ret

0000000080003b6a <ialloc>:
{
    80003b6a:	715d                	addi	sp,sp,-80
    80003b6c:	e486                	sd	ra,72(sp)
    80003b6e:	e0a2                	sd	s0,64(sp)
    80003b70:	fc26                	sd	s1,56(sp)
    80003b72:	f84a                	sd	s2,48(sp)
    80003b74:	f44e                	sd	s3,40(sp)
    80003b76:	f052                	sd	s4,32(sp)
    80003b78:	ec56                	sd	s5,24(sp)
    80003b7a:	e85a                	sd	s6,16(sp)
    80003b7c:	e45e                	sd	s7,8(sp)
    80003b7e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b80:	0001d717          	auipc	a4,0x1d
    80003b84:	82c72703          	lw	a4,-2004(a4) # 800203ac <sb+0xc>
    80003b88:	4785                	li	a5,1
    80003b8a:	04e7fa63          	bgeu	a5,a4,80003bde <ialloc+0x74>
    80003b8e:	8aaa                	mv	s5,a0
    80003b90:	8bae                	mv	s7,a1
    80003b92:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b94:	0001da17          	auipc	s4,0x1d
    80003b98:	80ca0a13          	addi	s4,s4,-2036 # 800203a0 <sb>
    80003b9c:	00048b1b          	sext.w	s6,s1
    80003ba0:	0044d593          	srli	a1,s1,0x4
    80003ba4:	018a2783          	lw	a5,24(s4)
    80003ba8:	9dbd                	addw	a1,a1,a5
    80003baa:	8556                	mv	a0,s5
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	954080e7          	jalr	-1708(ra) # 80003500 <bread>
    80003bb4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bb6:	05850993          	addi	s3,a0,88
    80003bba:	00f4f793          	andi	a5,s1,15
    80003bbe:	079a                	slli	a5,a5,0x6
    80003bc0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003bc2:	00099783          	lh	a5,0(s3)
    80003bc6:	c785                	beqz	a5,80003bee <ialloc+0x84>
    brelse(bp);
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	a68080e7          	jalr	-1432(ra) # 80003630 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bd0:	0485                	addi	s1,s1,1
    80003bd2:	00ca2703          	lw	a4,12(s4)
    80003bd6:	0004879b          	sext.w	a5,s1
    80003bda:	fce7e1e3          	bltu	a5,a4,80003b9c <ialloc+0x32>
  panic("ialloc: no inodes");
    80003bde:	00005517          	auipc	a0,0x5
    80003be2:	a4250513          	addi	a0,a0,-1470 # 80008620 <syscalls+0x180>
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	958080e7          	jalr	-1704(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    80003bee:	04000613          	li	a2,64
    80003bf2:	4581                	li	a1,0
    80003bf4:	854e                	mv	a0,s3
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	0ea080e7          	jalr	234(ra) # 80000ce0 <memset>
      dip->type = type;
    80003bfe:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c02:	854a                	mv	a0,s2
    80003c04:	00001097          	auipc	ra,0x1
    80003c08:	ca8080e7          	jalr	-856(ra) # 800048ac <log_write>
      brelse(bp);
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	a22080e7          	jalr	-1502(ra) # 80003630 <brelse>
      return iget(dev, inum);
    80003c16:	85da                	mv	a1,s6
    80003c18:	8556                	mv	a0,s5
    80003c1a:	00000097          	auipc	ra,0x0
    80003c1e:	db4080e7          	jalr	-588(ra) # 800039ce <iget>
}
    80003c22:	60a6                	ld	ra,72(sp)
    80003c24:	6406                	ld	s0,64(sp)
    80003c26:	74e2                	ld	s1,56(sp)
    80003c28:	7942                	ld	s2,48(sp)
    80003c2a:	79a2                	ld	s3,40(sp)
    80003c2c:	7a02                	ld	s4,32(sp)
    80003c2e:	6ae2                	ld	s5,24(sp)
    80003c30:	6b42                	ld	s6,16(sp)
    80003c32:	6ba2                	ld	s7,8(sp)
    80003c34:	6161                	addi	sp,sp,80
    80003c36:	8082                	ret

0000000080003c38 <iupdate>:
{
    80003c38:	1101                	addi	sp,sp,-32
    80003c3a:	ec06                	sd	ra,24(sp)
    80003c3c:	e822                	sd	s0,16(sp)
    80003c3e:	e426                	sd	s1,8(sp)
    80003c40:	e04a                	sd	s2,0(sp)
    80003c42:	1000                	addi	s0,sp,32
    80003c44:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c46:	415c                	lw	a5,4(a0)
    80003c48:	0047d79b          	srliw	a5,a5,0x4
    80003c4c:	0001c597          	auipc	a1,0x1c
    80003c50:	76c5a583          	lw	a1,1900(a1) # 800203b8 <sb+0x18>
    80003c54:	9dbd                	addw	a1,a1,a5
    80003c56:	4108                	lw	a0,0(a0)
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	8a8080e7          	jalr	-1880(ra) # 80003500 <bread>
    80003c60:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c62:	05850793          	addi	a5,a0,88
    80003c66:	40c8                	lw	a0,4(s1)
    80003c68:	893d                	andi	a0,a0,15
    80003c6a:	051a                	slli	a0,a0,0x6
    80003c6c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c6e:	04449703          	lh	a4,68(s1)
    80003c72:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c76:	04649703          	lh	a4,70(s1)
    80003c7a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c7e:	04849703          	lh	a4,72(s1)
    80003c82:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c86:	04a49703          	lh	a4,74(s1)
    80003c8a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c8e:	44f8                	lw	a4,76(s1)
    80003c90:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c92:	03400613          	li	a2,52
    80003c96:	05048593          	addi	a1,s1,80
    80003c9a:	0531                	addi	a0,a0,12
    80003c9c:	ffffd097          	auipc	ra,0xffffd
    80003ca0:	0a4080e7          	jalr	164(ra) # 80000d40 <memmove>
  log_write(bp);
    80003ca4:	854a                	mv	a0,s2
    80003ca6:	00001097          	auipc	ra,0x1
    80003caa:	c06080e7          	jalr	-1018(ra) # 800048ac <log_write>
  brelse(bp);
    80003cae:	854a                	mv	a0,s2
    80003cb0:	00000097          	auipc	ra,0x0
    80003cb4:	980080e7          	jalr	-1664(ra) # 80003630 <brelse>
}
    80003cb8:	60e2                	ld	ra,24(sp)
    80003cba:	6442                	ld	s0,16(sp)
    80003cbc:	64a2                	ld	s1,8(sp)
    80003cbe:	6902                	ld	s2,0(sp)
    80003cc0:	6105                	addi	sp,sp,32
    80003cc2:	8082                	ret

0000000080003cc4 <idup>:
{
    80003cc4:	1101                	addi	sp,sp,-32
    80003cc6:	ec06                	sd	ra,24(sp)
    80003cc8:	e822                	sd	s0,16(sp)
    80003cca:	e426                	sd	s1,8(sp)
    80003ccc:	1000                	addi	s0,sp,32
    80003cce:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cd0:	0001c517          	auipc	a0,0x1c
    80003cd4:	6f050513          	addi	a0,a0,1776 # 800203c0 <itable>
    80003cd8:	ffffd097          	auipc	ra,0xffffd
    80003cdc:	f0c080e7          	jalr	-244(ra) # 80000be4 <acquire>
  ip->ref++;
    80003ce0:	449c                	lw	a5,8(s1)
    80003ce2:	2785                	addiw	a5,a5,1
    80003ce4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ce6:	0001c517          	auipc	a0,0x1c
    80003cea:	6da50513          	addi	a0,a0,1754 # 800203c0 <itable>
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	faa080e7          	jalr	-86(ra) # 80000c98 <release>
}
    80003cf6:	8526                	mv	a0,s1
    80003cf8:	60e2                	ld	ra,24(sp)
    80003cfa:	6442                	ld	s0,16(sp)
    80003cfc:	64a2                	ld	s1,8(sp)
    80003cfe:	6105                	addi	sp,sp,32
    80003d00:	8082                	ret

0000000080003d02 <ilock>:
{
    80003d02:	1101                	addi	sp,sp,-32
    80003d04:	ec06                	sd	ra,24(sp)
    80003d06:	e822                	sd	s0,16(sp)
    80003d08:	e426                	sd	s1,8(sp)
    80003d0a:	e04a                	sd	s2,0(sp)
    80003d0c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d0e:	c115                	beqz	a0,80003d32 <ilock+0x30>
    80003d10:	84aa                	mv	s1,a0
    80003d12:	451c                	lw	a5,8(a0)
    80003d14:	00f05f63          	blez	a5,80003d32 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d18:	0541                	addi	a0,a0,16
    80003d1a:	00001097          	auipc	ra,0x1
    80003d1e:	cb2080e7          	jalr	-846(ra) # 800049cc <acquiresleep>
  if(ip->valid == 0){
    80003d22:	40bc                	lw	a5,64(s1)
    80003d24:	cf99                	beqz	a5,80003d42 <ilock+0x40>
}
    80003d26:	60e2                	ld	ra,24(sp)
    80003d28:	6442                	ld	s0,16(sp)
    80003d2a:	64a2                	ld	s1,8(sp)
    80003d2c:	6902                	ld	s2,0(sp)
    80003d2e:	6105                	addi	sp,sp,32
    80003d30:	8082                	ret
    panic("ilock");
    80003d32:	00005517          	auipc	a0,0x5
    80003d36:	90650513          	addi	a0,a0,-1786 # 80008638 <syscalls+0x198>
    80003d3a:	ffffd097          	auipc	ra,0xffffd
    80003d3e:	804080e7          	jalr	-2044(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d42:	40dc                	lw	a5,4(s1)
    80003d44:	0047d79b          	srliw	a5,a5,0x4
    80003d48:	0001c597          	auipc	a1,0x1c
    80003d4c:	6705a583          	lw	a1,1648(a1) # 800203b8 <sb+0x18>
    80003d50:	9dbd                	addw	a1,a1,a5
    80003d52:	4088                	lw	a0,0(s1)
    80003d54:	fffff097          	auipc	ra,0xfffff
    80003d58:	7ac080e7          	jalr	1964(ra) # 80003500 <bread>
    80003d5c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d5e:	05850593          	addi	a1,a0,88
    80003d62:	40dc                	lw	a5,4(s1)
    80003d64:	8bbd                	andi	a5,a5,15
    80003d66:	079a                	slli	a5,a5,0x6
    80003d68:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d6a:	00059783          	lh	a5,0(a1)
    80003d6e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d72:	00259783          	lh	a5,2(a1)
    80003d76:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d7a:	00459783          	lh	a5,4(a1)
    80003d7e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d82:	00659783          	lh	a5,6(a1)
    80003d86:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d8a:	459c                	lw	a5,8(a1)
    80003d8c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d8e:	03400613          	li	a2,52
    80003d92:	05b1                	addi	a1,a1,12
    80003d94:	05048513          	addi	a0,s1,80
    80003d98:	ffffd097          	auipc	ra,0xffffd
    80003d9c:	fa8080e7          	jalr	-88(ra) # 80000d40 <memmove>
    brelse(bp);
    80003da0:	854a                	mv	a0,s2
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	88e080e7          	jalr	-1906(ra) # 80003630 <brelse>
    ip->valid = 1;
    80003daa:	4785                	li	a5,1
    80003dac:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003dae:	04449783          	lh	a5,68(s1)
    80003db2:	fbb5                	bnez	a5,80003d26 <ilock+0x24>
      panic("ilock: no type");
    80003db4:	00005517          	auipc	a0,0x5
    80003db8:	88c50513          	addi	a0,a0,-1908 # 80008640 <syscalls+0x1a0>
    80003dbc:	ffffc097          	auipc	ra,0xffffc
    80003dc0:	782080e7          	jalr	1922(ra) # 8000053e <panic>

0000000080003dc4 <iunlock>:
{
    80003dc4:	1101                	addi	sp,sp,-32
    80003dc6:	ec06                	sd	ra,24(sp)
    80003dc8:	e822                	sd	s0,16(sp)
    80003dca:	e426                	sd	s1,8(sp)
    80003dcc:	e04a                	sd	s2,0(sp)
    80003dce:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003dd0:	c905                	beqz	a0,80003e00 <iunlock+0x3c>
    80003dd2:	84aa                	mv	s1,a0
    80003dd4:	01050913          	addi	s2,a0,16
    80003dd8:	854a                	mv	a0,s2
    80003dda:	00001097          	auipc	ra,0x1
    80003dde:	c8c080e7          	jalr	-884(ra) # 80004a66 <holdingsleep>
    80003de2:	cd19                	beqz	a0,80003e00 <iunlock+0x3c>
    80003de4:	449c                	lw	a5,8(s1)
    80003de6:	00f05d63          	blez	a5,80003e00 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003dea:	854a                	mv	a0,s2
    80003dec:	00001097          	auipc	ra,0x1
    80003df0:	c36080e7          	jalr	-970(ra) # 80004a22 <releasesleep>
}
    80003df4:	60e2                	ld	ra,24(sp)
    80003df6:	6442                	ld	s0,16(sp)
    80003df8:	64a2                	ld	s1,8(sp)
    80003dfa:	6902                	ld	s2,0(sp)
    80003dfc:	6105                	addi	sp,sp,32
    80003dfe:	8082                	ret
    panic("iunlock");
    80003e00:	00005517          	auipc	a0,0x5
    80003e04:	85050513          	addi	a0,a0,-1968 # 80008650 <syscalls+0x1b0>
    80003e08:	ffffc097          	auipc	ra,0xffffc
    80003e0c:	736080e7          	jalr	1846(ra) # 8000053e <panic>

0000000080003e10 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e10:	7179                	addi	sp,sp,-48
    80003e12:	f406                	sd	ra,40(sp)
    80003e14:	f022                	sd	s0,32(sp)
    80003e16:	ec26                	sd	s1,24(sp)
    80003e18:	e84a                	sd	s2,16(sp)
    80003e1a:	e44e                	sd	s3,8(sp)
    80003e1c:	e052                	sd	s4,0(sp)
    80003e1e:	1800                	addi	s0,sp,48
    80003e20:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e22:	05050493          	addi	s1,a0,80
    80003e26:	08050913          	addi	s2,a0,128
    80003e2a:	a021                	j	80003e32 <itrunc+0x22>
    80003e2c:	0491                	addi	s1,s1,4
    80003e2e:	01248d63          	beq	s1,s2,80003e48 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e32:	408c                	lw	a1,0(s1)
    80003e34:	dde5                	beqz	a1,80003e2c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e36:	0009a503          	lw	a0,0(s3)
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	90c080e7          	jalr	-1780(ra) # 80003746 <bfree>
      ip->addrs[i] = 0;
    80003e42:	0004a023          	sw	zero,0(s1)
    80003e46:	b7dd                	j	80003e2c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e48:	0809a583          	lw	a1,128(s3)
    80003e4c:	e185                	bnez	a1,80003e6c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e4e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e52:	854e                	mv	a0,s3
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	de4080e7          	jalr	-540(ra) # 80003c38 <iupdate>
}
    80003e5c:	70a2                	ld	ra,40(sp)
    80003e5e:	7402                	ld	s0,32(sp)
    80003e60:	64e2                	ld	s1,24(sp)
    80003e62:	6942                	ld	s2,16(sp)
    80003e64:	69a2                	ld	s3,8(sp)
    80003e66:	6a02                	ld	s4,0(sp)
    80003e68:	6145                	addi	sp,sp,48
    80003e6a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e6c:	0009a503          	lw	a0,0(s3)
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	690080e7          	jalr	1680(ra) # 80003500 <bread>
    80003e78:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e7a:	05850493          	addi	s1,a0,88
    80003e7e:	45850913          	addi	s2,a0,1112
    80003e82:	a811                	j	80003e96 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003e84:	0009a503          	lw	a0,0(s3)
    80003e88:	00000097          	auipc	ra,0x0
    80003e8c:	8be080e7          	jalr	-1858(ra) # 80003746 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003e90:	0491                	addi	s1,s1,4
    80003e92:	01248563          	beq	s1,s2,80003e9c <itrunc+0x8c>
      if(a[j])
    80003e96:	408c                	lw	a1,0(s1)
    80003e98:	dde5                	beqz	a1,80003e90 <itrunc+0x80>
    80003e9a:	b7ed                	j	80003e84 <itrunc+0x74>
    brelse(bp);
    80003e9c:	8552                	mv	a0,s4
    80003e9e:	fffff097          	auipc	ra,0xfffff
    80003ea2:	792080e7          	jalr	1938(ra) # 80003630 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ea6:	0809a583          	lw	a1,128(s3)
    80003eaa:	0009a503          	lw	a0,0(s3)
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	898080e7          	jalr	-1896(ra) # 80003746 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003eb6:	0809a023          	sw	zero,128(s3)
    80003eba:	bf51                	j	80003e4e <itrunc+0x3e>

0000000080003ebc <iput>:
{
    80003ebc:	1101                	addi	sp,sp,-32
    80003ebe:	ec06                	sd	ra,24(sp)
    80003ec0:	e822                	sd	s0,16(sp)
    80003ec2:	e426                	sd	s1,8(sp)
    80003ec4:	e04a                	sd	s2,0(sp)
    80003ec6:	1000                	addi	s0,sp,32
    80003ec8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003eca:	0001c517          	auipc	a0,0x1c
    80003ece:	4f650513          	addi	a0,a0,1270 # 800203c0 <itable>
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	d12080e7          	jalr	-750(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eda:	4498                	lw	a4,8(s1)
    80003edc:	4785                	li	a5,1
    80003ede:	02f70363          	beq	a4,a5,80003f04 <iput+0x48>
  ip->ref--;
    80003ee2:	449c                	lw	a5,8(s1)
    80003ee4:	37fd                	addiw	a5,a5,-1
    80003ee6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ee8:	0001c517          	auipc	a0,0x1c
    80003eec:	4d850513          	addi	a0,a0,1240 # 800203c0 <itable>
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	da8080e7          	jalr	-600(ra) # 80000c98 <release>
}
    80003ef8:	60e2                	ld	ra,24(sp)
    80003efa:	6442                	ld	s0,16(sp)
    80003efc:	64a2                	ld	s1,8(sp)
    80003efe:	6902                	ld	s2,0(sp)
    80003f00:	6105                	addi	sp,sp,32
    80003f02:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f04:	40bc                	lw	a5,64(s1)
    80003f06:	dff1                	beqz	a5,80003ee2 <iput+0x26>
    80003f08:	04a49783          	lh	a5,74(s1)
    80003f0c:	fbf9                	bnez	a5,80003ee2 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f0e:	01048913          	addi	s2,s1,16
    80003f12:	854a                	mv	a0,s2
    80003f14:	00001097          	auipc	ra,0x1
    80003f18:	ab8080e7          	jalr	-1352(ra) # 800049cc <acquiresleep>
    release(&itable.lock);
    80003f1c:	0001c517          	auipc	a0,0x1c
    80003f20:	4a450513          	addi	a0,a0,1188 # 800203c0 <itable>
    80003f24:	ffffd097          	auipc	ra,0xffffd
    80003f28:	d74080e7          	jalr	-652(ra) # 80000c98 <release>
    itrunc(ip);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	ee2080e7          	jalr	-286(ra) # 80003e10 <itrunc>
    ip->type = 0;
    80003f36:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	cfc080e7          	jalr	-772(ra) # 80003c38 <iupdate>
    ip->valid = 0;
    80003f44:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f48:	854a                	mv	a0,s2
    80003f4a:	00001097          	auipc	ra,0x1
    80003f4e:	ad8080e7          	jalr	-1320(ra) # 80004a22 <releasesleep>
    acquire(&itable.lock);
    80003f52:	0001c517          	auipc	a0,0x1c
    80003f56:	46e50513          	addi	a0,a0,1134 # 800203c0 <itable>
    80003f5a:	ffffd097          	auipc	ra,0xffffd
    80003f5e:	c8a080e7          	jalr	-886(ra) # 80000be4 <acquire>
    80003f62:	b741                	j	80003ee2 <iput+0x26>

0000000080003f64 <iunlockput>:
{
    80003f64:	1101                	addi	sp,sp,-32
    80003f66:	ec06                	sd	ra,24(sp)
    80003f68:	e822                	sd	s0,16(sp)
    80003f6a:	e426                	sd	s1,8(sp)
    80003f6c:	1000                	addi	s0,sp,32
    80003f6e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f70:	00000097          	auipc	ra,0x0
    80003f74:	e54080e7          	jalr	-428(ra) # 80003dc4 <iunlock>
  iput(ip);
    80003f78:	8526                	mv	a0,s1
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	f42080e7          	jalr	-190(ra) # 80003ebc <iput>
}
    80003f82:	60e2                	ld	ra,24(sp)
    80003f84:	6442                	ld	s0,16(sp)
    80003f86:	64a2                	ld	s1,8(sp)
    80003f88:	6105                	addi	sp,sp,32
    80003f8a:	8082                	ret

0000000080003f8c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f8c:	1141                	addi	sp,sp,-16
    80003f8e:	e422                	sd	s0,8(sp)
    80003f90:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f92:	411c                	lw	a5,0(a0)
    80003f94:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f96:	415c                	lw	a5,4(a0)
    80003f98:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f9a:	04451783          	lh	a5,68(a0)
    80003f9e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fa2:	04a51783          	lh	a5,74(a0)
    80003fa6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003faa:	04c56783          	lwu	a5,76(a0)
    80003fae:	e99c                	sd	a5,16(a1)
}
    80003fb0:	6422                	ld	s0,8(sp)
    80003fb2:	0141                	addi	sp,sp,16
    80003fb4:	8082                	ret

0000000080003fb6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fb6:	457c                	lw	a5,76(a0)
    80003fb8:	0ed7e963          	bltu	a5,a3,800040aa <readi+0xf4>
{
    80003fbc:	7159                	addi	sp,sp,-112
    80003fbe:	f486                	sd	ra,104(sp)
    80003fc0:	f0a2                	sd	s0,96(sp)
    80003fc2:	eca6                	sd	s1,88(sp)
    80003fc4:	e8ca                	sd	s2,80(sp)
    80003fc6:	e4ce                	sd	s3,72(sp)
    80003fc8:	e0d2                	sd	s4,64(sp)
    80003fca:	fc56                	sd	s5,56(sp)
    80003fcc:	f85a                	sd	s6,48(sp)
    80003fce:	f45e                	sd	s7,40(sp)
    80003fd0:	f062                	sd	s8,32(sp)
    80003fd2:	ec66                	sd	s9,24(sp)
    80003fd4:	e86a                	sd	s10,16(sp)
    80003fd6:	e46e                	sd	s11,8(sp)
    80003fd8:	1880                	addi	s0,sp,112
    80003fda:	8baa                	mv	s7,a0
    80003fdc:	8c2e                	mv	s8,a1
    80003fde:	8ab2                	mv	s5,a2
    80003fe0:	84b6                	mv	s1,a3
    80003fe2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fe4:	9f35                	addw	a4,a4,a3
    return 0;
    80003fe6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fe8:	0ad76063          	bltu	a4,a3,80004088 <readi+0xd2>
  if(off + n > ip->size)
    80003fec:	00e7f463          	bgeu	a5,a4,80003ff4 <readi+0x3e>
    n = ip->size - off;
    80003ff0:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ff4:	0a0b0963          	beqz	s6,800040a6 <readi+0xf0>
    80003ff8:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ffa:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ffe:	5cfd                	li	s9,-1
    80004000:	a82d                	j	8000403a <readi+0x84>
    80004002:	020a1d93          	slli	s11,s4,0x20
    80004006:	020ddd93          	srli	s11,s11,0x20
    8000400a:	05890613          	addi	a2,s2,88
    8000400e:	86ee                	mv	a3,s11
    80004010:	963a                	add	a2,a2,a4
    80004012:	85d6                	mv	a1,s5
    80004014:	8562                	mv	a0,s8
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	ab2080e7          	jalr	-1358(ra) # 80002ac8 <either_copyout>
    8000401e:	05950d63          	beq	a0,s9,80004078 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004022:	854a                	mv	a0,s2
    80004024:	fffff097          	auipc	ra,0xfffff
    80004028:	60c080e7          	jalr	1548(ra) # 80003630 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000402c:	013a09bb          	addw	s3,s4,s3
    80004030:	009a04bb          	addw	s1,s4,s1
    80004034:	9aee                	add	s5,s5,s11
    80004036:	0569f763          	bgeu	s3,s6,80004084 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000403a:	000ba903          	lw	s2,0(s7)
    8000403e:	00a4d59b          	srliw	a1,s1,0xa
    80004042:	855e                	mv	a0,s7
    80004044:	00000097          	auipc	ra,0x0
    80004048:	8b0080e7          	jalr	-1872(ra) # 800038f4 <bmap>
    8000404c:	0005059b          	sext.w	a1,a0
    80004050:	854a                	mv	a0,s2
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	4ae080e7          	jalr	1198(ra) # 80003500 <bread>
    8000405a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405c:	3ff4f713          	andi	a4,s1,1023
    80004060:	40ed07bb          	subw	a5,s10,a4
    80004064:	413b06bb          	subw	a3,s6,s3
    80004068:	8a3e                	mv	s4,a5
    8000406a:	2781                	sext.w	a5,a5
    8000406c:	0006861b          	sext.w	a2,a3
    80004070:	f8f679e3          	bgeu	a2,a5,80004002 <readi+0x4c>
    80004074:	8a36                	mv	s4,a3
    80004076:	b771                	j	80004002 <readi+0x4c>
      brelse(bp);
    80004078:	854a                	mv	a0,s2
    8000407a:	fffff097          	auipc	ra,0xfffff
    8000407e:	5b6080e7          	jalr	1462(ra) # 80003630 <brelse>
      tot = -1;
    80004082:	59fd                	li	s3,-1
  }
  return tot;
    80004084:	0009851b          	sext.w	a0,s3
}
    80004088:	70a6                	ld	ra,104(sp)
    8000408a:	7406                	ld	s0,96(sp)
    8000408c:	64e6                	ld	s1,88(sp)
    8000408e:	6946                	ld	s2,80(sp)
    80004090:	69a6                	ld	s3,72(sp)
    80004092:	6a06                	ld	s4,64(sp)
    80004094:	7ae2                	ld	s5,56(sp)
    80004096:	7b42                	ld	s6,48(sp)
    80004098:	7ba2                	ld	s7,40(sp)
    8000409a:	7c02                	ld	s8,32(sp)
    8000409c:	6ce2                	ld	s9,24(sp)
    8000409e:	6d42                	ld	s10,16(sp)
    800040a0:	6da2                	ld	s11,8(sp)
    800040a2:	6165                	addi	sp,sp,112
    800040a4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040a6:	89da                	mv	s3,s6
    800040a8:	bff1                	j	80004084 <readi+0xce>
    return 0;
    800040aa:	4501                	li	a0,0
}
    800040ac:	8082                	ret

00000000800040ae <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040ae:	457c                	lw	a5,76(a0)
    800040b0:	10d7e863          	bltu	a5,a3,800041c0 <writei+0x112>
{
    800040b4:	7159                	addi	sp,sp,-112
    800040b6:	f486                	sd	ra,104(sp)
    800040b8:	f0a2                	sd	s0,96(sp)
    800040ba:	eca6                	sd	s1,88(sp)
    800040bc:	e8ca                	sd	s2,80(sp)
    800040be:	e4ce                	sd	s3,72(sp)
    800040c0:	e0d2                	sd	s4,64(sp)
    800040c2:	fc56                	sd	s5,56(sp)
    800040c4:	f85a                	sd	s6,48(sp)
    800040c6:	f45e                	sd	s7,40(sp)
    800040c8:	f062                	sd	s8,32(sp)
    800040ca:	ec66                	sd	s9,24(sp)
    800040cc:	e86a                	sd	s10,16(sp)
    800040ce:	e46e                	sd	s11,8(sp)
    800040d0:	1880                	addi	s0,sp,112
    800040d2:	8b2a                	mv	s6,a0
    800040d4:	8c2e                	mv	s8,a1
    800040d6:	8ab2                	mv	s5,a2
    800040d8:	8936                	mv	s2,a3
    800040da:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800040dc:	00e687bb          	addw	a5,a3,a4
    800040e0:	0ed7e263          	bltu	a5,a3,800041c4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040e4:	00043737          	lui	a4,0x43
    800040e8:	0ef76063          	bltu	a4,a5,800041c8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040ec:	0c0b8863          	beqz	s7,800041bc <writei+0x10e>
    800040f0:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040f2:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040f6:	5cfd                	li	s9,-1
    800040f8:	a091                	j	8000413c <writei+0x8e>
    800040fa:	02099d93          	slli	s11,s3,0x20
    800040fe:	020ddd93          	srli	s11,s11,0x20
    80004102:	05848513          	addi	a0,s1,88
    80004106:	86ee                	mv	a3,s11
    80004108:	8656                	mv	a2,s5
    8000410a:	85e2                	mv	a1,s8
    8000410c:	953a                	add	a0,a0,a4
    8000410e:	fffff097          	auipc	ra,0xfffff
    80004112:	a10080e7          	jalr	-1520(ra) # 80002b1e <either_copyin>
    80004116:	07950263          	beq	a0,s9,8000417a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000411a:	8526                	mv	a0,s1
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	790080e7          	jalr	1936(ra) # 800048ac <log_write>
    brelse(bp);
    80004124:	8526                	mv	a0,s1
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	50a080e7          	jalr	1290(ra) # 80003630 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000412e:	01498a3b          	addw	s4,s3,s4
    80004132:	0129893b          	addw	s2,s3,s2
    80004136:	9aee                	add	s5,s5,s11
    80004138:	057a7663          	bgeu	s4,s7,80004184 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000413c:	000b2483          	lw	s1,0(s6)
    80004140:	00a9559b          	srliw	a1,s2,0xa
    80004144:	855a                	mv	a0,s6
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	7ae080e7          	jalr	1966(ra) # 800038f4 <bmap>
    8000414e:	0005059b          	sext.w	a1,a0
    80004152:	8526                	mv	a0,s1
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	3ac080e7          	jalr	940(ra) # 80003500 <bread>
    8000415c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000415e:	3ff97713          	andi	a4,s2,1023
    80004162:	40ed07bb          	subw	a5,s10,a4
    80004166:	414b86bb          	subw	a3,s7,s4
    8000416a:	89be                	mv	s3,a5
    8000416c:	2781                	sext.w	a5,a5
    8000416e:	0006861b          	sext.w	a2,a3
    80004172:	f8f674e3          	bgeu	a2,a5,800040fa <writei+0x4c>
    80004176:	89b6                	mv	s3,a3
    80004178:	b749                	j	800040fa <writei+0x4c>
      brelse(bp);
    8000417a:	8526                	mv	a0,s1
    8000417c:	fffff097          	auipc	ra,0xfffff
    80004180:	4b4080e7          	jalr	1204(ra) # 80003630 <brelse>
  }

  if(off > ip->size)
    80004184:	04cb2783          	lw	a5,76(s6)
    80004188:	0127f463          	bgeu	a5,s2,80004190 <writei+0xe2>
    ip->size = off;
    8000418c:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004190:	855a                	mv	a0,s6
    80004192:	00000097          	auipc	ra,0x0
    80004196:	aa6080e7          	jalr	-1370(ra) # 80003c38 <iupdate>

  return tot;
    8000419a:	000a051b          	sext.w	a0,s4
}
    8000419e:	70a6                	ld	ra,104(sp)
    800041a0:	7406                	ld	s0,96(sp)
    800041a2:	64e6                	ld	s1,88(sp)
    800041a4:	6946                	ld	s2,80(sp)
    800041a6:	69a6                	ld	s3,72(sp)
    800041a8:	6a06                	ld	s4,64(sp)
    800041aa:	7ae2                	ld	s5,56(sp)
    800041ac:	7b42                	ld	s6,48(sp)
    800041ae:	7ba2                	ld	s7,40(sp)
    800041b0:	7c02                	ld	s8,32(sp)
    800041b2:	6ce2                	ld	s9,24(sp)
    800041b4:	6d42                	ld	s10,16(sp)
    800041b6:	6da2                	ld	s11,8(sp)
    800041b8:	6165                	addi	sp,sp,112
    800041ba:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041bc:	8a5e                	mv	s4,s7
    800041be:	bfc9                	j	80004190 <writei+0xe2>
    return -1;
    800041c0:	557d                	li	a0,-1
}
    800041c2:	8082                	ret
    return -1;
    800041c4:	557d                	li	a0,-1
    800041c6:	bfe1                	j	8000419e <writei+0xf0>
    return -1;
    800041c8:	557d                	li	a0,-1
    800041ca:	bfd1                	j	8000419e <writei+0xf0>

00000000800041cc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041cc:	1141                	addi	sp,sp,-16
    800041ce:	e406                	sd	ra,8(sp)
    800041d0:	e022                	sd	s0,0(sp)
    800041d2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041d4:	4639                	li	a2,14
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	be2080e7          	jalr	-1054(ra) # 80000db8 <strncmp>
}
    800041de:	60a2                	ld	ra,8(sp)
    800041e0:	6402                	ld	s0,0(sp)
    800041e2:	0141                	addi	sp,sp,16
    800041e4:	8082                	ret

00000000800041e6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041e6:	7139                	addi	sp,sp,-64
    800041e8:	fc06                	sd	ra,56(sp)
    800041ea:	f822                	sd	s0,48(sp)
    800041ec:	f426                	sd	s1,40(sp)
    800041ee:	f04a                	sd	s2,32(sp)
    800041f0:	ec4e                	sd	s3,24(sp)
    800041f2:	e852                	sd	s4,16(sp)
    800041f4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041f6:	04451703          	lh	a4,68(a0)
    800041fa:	4785                	li	a5,1
    800041fc:	00f71a63          	bne	a4,a5,80004210 <dirlookup+0x2a>
    80004200:	892a                	mv	s2,a0
    80004202:	89ae                	mv	s3,a1
    80004204:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004206:	457c                	lw	a5,76(a0)
    80004208:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000420a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000420c:	e79d                	bnez	a5,8000423a <dirlookup+0x54>
    8000420e:	a8a5                	j	80004286 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004210:	00004517          	auipc	a0,0x4
    80004214:	44850513          	addi	a0,a0,1096 # 80008658 <syscalls+0x1b8>
    80004218:	ffffc097          	auipc	ra,0xffffc
    8000421c:	326080e7          	jalr	806(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004220:	00004517          	auipc	a0,0x4
    80004224:	45050513          	addi	a0,a0,1104 # 80008670 <syscalls+0x1d0>
    80004228:	ffffc097          	auipc	ra,0xffffc
    8000422c:	316080e7          	jalr	790(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004230:	24c1                	addiw	s1,s1,16
    80004232:	04c92783          	lw	a5,76(s2)
    80004236:	04f4f763          	bgeu	s1,a5,80004284 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000423a:	4741                	li	a4,16
    8000423c:	86a6                	mv	a3,s1
    8000423e:	fc040613          	addi	a2,s0,-64
    80004242:	4581                	li	a1,0
    80004244:	854a                	mv	a0,s2
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	d70080e7          	jalr	-656(ra) # 80003fb6 <readi>
    8000424e:	47c1                	li	a5,16
    80004250:	fcf518e3          	bne	a0,a5,80004220 <dirlookup+0x3a>
    if(de.inum == 0)
    80004254:	fc045783          	lhu	a5,-64(s0)
    80004258:	dfe1                	beqz	a5,80004230 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000425a:	fc240593          	addi	a1,s0,-62
    8000425e:	854e                	mv	a0,s3
    80004260:	00000097          	auipc	ra,0x0
    80004264:	f6c080e7          	jalr	-148(ra) # 800041cc <namecmp>
    80004268:	f561                	bnez	a0,80004230 <dirlookup+0x4a>
      if(poff)
    8000426a:	000a0463          	beqz	s4,80004272 <dirlookup+0x8c>
        *poff = off;
    8000426e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004272:	fc045583          	lhu	a1,-64(s0)
    80004276:	00092503          	lw	a0,0(s2)
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	754080e7          	jalr	1876(ra) # 800039ce <iget>
    80004282:	a011                	j	80004286 <dirlookup+0xa0>
  return 0;
    80004284:	4501                	li	a0,0
}
    80004286:	70e2                	ld	ra,56(sp)
    80004288:	7442                	ld	s0,48(sp)
    8000428a:	74a2                	ld	s1,40(sp)
    8000428c:	7902                	ld	s2,32(sp)
    8000428e:	69e2                	ld	s3,24(sp)
    80004290:	6a42                	ld	s4,16(sp)
    80004292:	6121                	addi	sp,sp,64
    80004294:	8082                	ret

0000000080004296 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004296:	711d                	addi	sp,sp,-96
    80004298:	ec86                	sd	ra,88(sp)
    8000429a:	e8a2                	sd	s0,80(sp)
    8000429c:	e4a6                	sd	s1,72(sp)
    8000429e:	e0ca                	sd	s2,64(sp)
    800042a0:	fc4e                	sd	s3,56(sp)
    800042a2:	f852                	sd	s4,48(sp)
    800042a4:	f456                	sd	s5,40(sp)
    800042a6:	f05a                	sd	s6,32(sp)
    800042a8:	ec5e                	sd	s7,24(sp)
    800042aa:	e862                	sd	s8,16(sp)
    800042ac:	e466                	sd	s9,8(sp)
    800042ae:	1080                	addi	s0,sp,96
    800042b0:	84aa                	mv	s1,a0
    800042b2:	8b2e                	mv	s6,a1
    800042b4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042b6:	00054703          	lbu	a4,0(a0)
    800042ba:	02f00793          	li	a5,47
    800042be:	02f70363          	beq	a4,a5,800042e4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042c2:	ffffe097          	auipc	ra,0xffffe
    800042c6:	afe080e7          	jalr	-1282(ra) # 80001dc0 <myproc>
    800042ca:	17853503          	ld	a0,376(a0)
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	9f6080e7          	jalr	-1546(ra) # 80003cc4 <idup>
    800042d6:	89aa                	mv	s3,a0
  while(*path == '/')
    800042d8:	02f00913          	li	s2,47
  len = path - s;
    800042dc:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800042de:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042e0:	4c05                	li	s8,1
    800042e2:	a865                	j	8000439a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042e4:	4585                	li	a1,1
    800042e6:	4505                	li	a0,1
    800042e8:	fffff097          	auipc	ra,0xfffff
    800042ec:	6e6080e7          	jalr	1766(ra) # 800039ce <iget>
    800042f0:	89aa                	mv	s3,a0
    800042f2:	b7dd                	j	800042d8 <namex+0x42>
      iunlockput(ip);
    800042f4:	854e                	mv	a0,s3
    800042f6:	00000097          	auipc	ra,0x0
    800042fa:	c6e080e7          	jalr	-914(ra) # 80003f64 <iunlockput>
      return 0;
    800042fe:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004300:	854e                	mv	a0,s3
    80004302:	60e6                	ld	ra,88(sp)
    80004304:	6446                	ld	s0,80(sp)
    80004306:	64a6                	ld	s1,72(sp)
    80004308:	6906                	ld	s2,64(sp)
    8000430a:	79e2                	ld	s3,56(sp)
    8000430c:	7a42                	ld	s4,48(sp)
    8000430e:	7aa2                	ld	s5,40(sp)
    80004310:	7b02                	ld	s6,32(sp)
    80004312:	6be2                	ld	s7,24(sp)
    80004314:	6c42                	ld	s8,16(sp)
    80004316:	6ca2                	ld	s9,8(sp)
    80004318:	6125                	addi	sp,sp,96
    8000431a:	8082                	ret
      iunlock(ip);
    8000431c:	854e                	mv	a0,s3
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	aa6080e7          	jalr	-1370(ra) # 80003dc4 <iunlock>
      return ip;
    80004326:	bfe9                	j	80004300 <namex+0x6a>
      iunlockput(ip);
    80004328:	854e                	mv	a0,s3
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	c3a080e7          	jalr	-966(ra) # 80003f64 <iunlockput>
      return 0;
    80004332:	89d2                	mv	s3,s4
    80004334:	b7f1                	j	80004300 <namex+0x6a>
  len = path - s;
    80004336:	40b48633          	sub	a2,s1,a1
    8000433a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000433e:	094cd463          	bge	s9,s4,800043c6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004342:	4639                	li	a2,14
    80004344:	8556                	mv	a0,s5
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	9fa080e7          	jalr	-1542(ra) # 80000d40 <memmove>
  while(*path == '/')
    8000434e:	0004c783          	lbu	a5,0(s1)
    80004352:	01279763          	bne	a5,s2,80004360 <namex+0xca>
    path++;
    80004356:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004358:	0004c783          	lbu	a5,0(s1)
    8000435c:	ff278de3          	beq	a5,s2,80004356 <namex+0xc0>
    ilock(ip);
    80004360:	854e                	mv	a0,s3
    80004362:	00000097          	auipc	ra,0x0
    80004366:	9a0080e7          	jalr	-1632(ra) # 80003d02 <ilock>
    if(ip->type != T_DIR){
    8000436a:	04499783          	lh	a5,68(s3)
    8000436e:	f98793e3          	bne	a5,s8,800042f4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004372:	000b0563          	beqz	s6,8000437c <namex+0xe6>
    80004376:	0004c783          	lbu	a5,0(s1)
    8000437a:	d3cd                	beqz	a5,8000431c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000437c:	865e                	mv	a2,s7
    8000437e:	85d6                	mv	a1,s5
    80004380:	854e                	mv	a0,s3
    80004382:	00000097          	auipc	ra,0x0
    80004386:	e64080e7          	jalr	-412(ra) # 800041e6 <dirlookup>
    8000438a:	8a2a                	mv	s4,a0
    8000438c:	dd51                	beqz	a0,80004328 <namex+0x92>
    iunlockput(ip);
    8000438e:	854e                	mv	a0,s3
    80004390:	00000097          	auipc	ra,0x0
    80004394:	bd4080e7          	jalr	-1068(ra) # 80003f64 <iunlockput>
    ip = next;
    80004398:	89d2                	mv	s3,s4
  while(*path == '/')
    8000439a:	0004c783          	lbu	a5,0(s1)
    8000439e:	05279763          	bne	a5,s2,800043ec <namex+0x156>
    path++;
    800043a2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043a4:	0004c783          	lbu	a5,0(s1)
    800043a8:	ff278de3          	beq	a5,s2,800043a2 <namex+0x10c>
  if(*path == 0)
    800043ac:	c79d                	beqz	a5,800043da <namex+0x144>
    path++;
    800043ae:	85a6                	mv	a1,s1
  len = path - s;
    800043b0:	8a5e                	mv	s4,s7
    800043b2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800043b4:	01278963          	beq	a5,s2,800043c6 <namex+0x130>
    800043b8:	dfbd                	beqz	a5,80004336 <namex+0xa0>
    path++;
    800043ba:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043bc:	0004c783          	lbu	a5,0(s1)
    800043c0:	ff279ce3          	bne	a5,s2,800043b8 <namex+0x122>
    800043c4:	bf8d                	j	80004336 <namex+0xa0>
    memmove(name, s, len);
    800043c6:	2601                	sext.w	a2,a2
    800043c8:	8556                	mv	a0,s5
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	976080e7          	jalr	-1674(ra) # 80000d40 <memmove>
    name[len] = 0;
    800043d2:	9a56                	add	s4,s4,s5
    800043d4:	000a0023          	sb	zero,0(s4)
    800043d8:	bf9d                	j	8000434e <namex+0xb8>
  if(nameiparent){
    800043da:	f20b03e3          	beqz	s6,80004300 <namex+0x6a>
    iput(ip);
    800043de:	854e                	mv	a0,s3
    800043e0:	00000097          	auipc	ra,0x0
    800043e4:	adc080e7          	jalr	-1316(ra) # 80003ebc <iput>
    return 0;
    800043e8:	4981                	li	s3,0
    800043ea:	bf19                	j	80004300 <namex+0x6a>
  if(*path == 0)
    800043ec:	d7fd                	beqz	a5,800043da <namex+0x144>
  while(*path != '/' && *path != 0)
    800043ee:	0004c783          	lbu	a5,0(s1)
    800043f2:	85a6                	mv	a1,s1
    800043f4:	b7d1                	j	800043b8 <namex+0x122>

00000000800043f6 <dirlink>:
{
    800043f6:	7139                	addi	sp,sp,-64
    800043f8:	fc06                	sd	ra,56(sp)
    800043fa:	f822                	sd	s0,48(sp)
    800043fc:	f426                	sd	s1,40(sp)
    800043fe:	f04a                	sd	s2,32(sp)
    80004400:	ec4e                	sd	s3,24(sp)
    80004402:	e852                	sd	s4,16(sp)
    80004404:	0080                	addi	s0,sp,64
    80004406:	892a                	mv	s2,a0
    80004408:	8a2e                	mv	s4,a1
    8000440a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000440c:	4601                	li	a2,0
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	dd8080e7          	jalr	-552(ra) # 800041e6 <dirlookup>
    80004416:	e93d                	bnez	a0,8000448c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004418:	04c92483          	lw	s1,76(s2)
    8000441c:	c49d                	beqz	s1,8000444a <dirlink+0x54>
    8000441e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004420:	4741                	li	a4,16
    80004422:	86a6                	mv	a3,s1
    80004424:	fc040613          	addi	a2,s0,-64
    80004428:	4581                	li	a1,0
    8000442a:	854a                	mv	a0,s2
    8000442c:	00000097          	auipc	ra,0x0
    80004430:	b8a080e7          	jalr	-1142(ra) # 80003fb6 <readi>
    80004434:	47c1                	li	a5,16
    80004436:	06f51163          	bne	a0,a5,80004498 <dirlink+0xa2>
    if(de.inum == 0)
    8000443a:	fc045783          	lhu	a5,-64(s0)
    8000443e:	c791                	beqz	a5,8000444a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004440:	24c1                	addiw	s1,s1,16
    80004442:	04c92783          	lw	a5,76(s2)
    80004446:	fcf4ede3          	bltu	s1,a5,80004420 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000444a:	4639                	li	a2,14
    8000444c:	85d2                	mv	a1,s4
    8000444e:	fc240513          	addi	a0,s0,-62
    80004452:	ffffd097          	auipc	ra,0xffffd
    80004456:	9a2080e7          	jalr	-1630(ra) # 80000df4 <strncpy>
  de.inum = inum;
    8000445a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000445e:	4741                	li	a4,16
    80004460:	86a6                	mv	a3,s1
    80004462:	fc040613          	addi	a2,s0,-64
    80004466:	4581                	li	a1,0
    80004468:	854a                	mv	a0,s2
    8000446a:	00000097          	auipc	ra,0x0
    8000446e:	c44080e7          	jalr	-956(ra) # 800040ae <writei>
    80004472:	872a                	mv	a4,a0
    80004474:	47c1                	li	a5,16
  return 0;
    80004476:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004478:	02f71863          	bne	a4,a5,800044a8 <dirlink+0xb2>
}
    8000447c:	70e2                	ld	ra,56(sp)
    8000447e:	7442                	ld	s0,48(sp)
    80004480:	74a2                	ld	s1,40(sp)
    80004482:	7902                	ld	s2,32(sp)
    80004484:	69e2                	ld	s3,24(sp)
    80004486:	6a42                	ld	s4,16(sp)
    80004488:	6121                	addi	sp,sp,64
    8000448a:	8082                	ret
    iput(ip);
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	a30080e7          	jalr	-1488(ra) # 80003ebc <iput>
    return -1;
    80004494:	557d                	li	a0,-1
    80004496:	b7dd                	j	8000447c <dirlink+0x86>
      panic("dirlink read");
    80004498:	00004517          	auipc	a0,0x4
    8000449c:	1e850513          	addi	a0,a0,488 # 80008680 <syscalls+0x1e0>
    800044a0:	ffffc097          	auipc	ra,0xffffc
    800044a4:	09e080e7          	jalr	158(ra) # 8000053e <panic>
    panic("dirlink");
    800044a8:	00004517          	auipc	a0,0x4
    800044ac:	2e850513          	addi	a0,a0,744 # 80008790 <syscalls+0x2f0>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	08e080e7          	jalr	142(ra) # 8000053e <panic>

00000000800044b8 <namei>:

struct inode*
namei(char *path)
{
    800044b8:	1101                	addi	sp,sp,-32
    800044ba:	ec06                	sd	ra,24(sp)
    800044bc:	e822                	sd	s0,16(sp)
    800044be:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044c0:	fe040613          	addi	a2,s0,-32
    800044c4:	4581                	li	a1,0
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	dd0080e7          	jalr	-560(ra) # 80004296 <namex>
}
    800044ce:	60e2                	ld	ra,24(sp)
    800044d0:	6442                	ld	s0,16(sp)
    800044d2:	6105                	addi	sp,sp,32
    800044d4:	8082                	ret

00000000800044d6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044d6:	1141                	addi	sp,sp,-16
    800044d8:	e406                	sd	ra,8(sp)
    800044da:	e022                	sd	s0,0(sp)
    800044dc:	0800                	addi	s0,sp,16
    800044de:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044e0:	4585                	li	a1,1
    800044e2:	00000097          	auipc	ra,0x0
    800044e6:	db4080e7          	jalr	-588(ra) # 80004296 <namex>
}
    800044ea:	60a2                	ld	ra,8(sp)
    800044ec:	6402                	ld	s0,0(sp)
    800044ee:	0141                	addi	sp,sp,16
    800044f0:	8082                	ret

00000000800044f2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044f2:	1101                	addi	sp,sp,-32
    800044f4:	ec06                	sd	ra,24(sp)
    800044f6:	e822                	sd	s0,16(sp)
    800044f8:	e426                	sd	s1,8(sp)
    800044fa:	e04a                	sd	s2,0(sp)
    800044fc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044fe:	0001e917          	auipc	s2,0x1e
    80004502:	96a90913          	addi	s2,s2,-1686 # 80021e68 <log>
    80004506:	01892583          	lw	a1,24(s2)
    8000450a:	02892503          	lw	a0,40(s2)
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	ff2080e7          	jalr	-14(ra) # 80003500 <bread>
    80004516:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004518:	02c92683          	lw	a3,44(s2)
    8000451c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000451e:	02d05763          	blez	a3,8000454c <write_head+0x5a>
    80004522:	0001e797          	auipc	a5,0x1e
    80004526:	97678793          	addi	a5,a5,-1674 # 80021e98 <log+0x30>
    8000452a:	05c50713          	addi	a4,a0,92
    8000452e:	36fd                	addiw	a3,a3,-1
    80004530:	1682                	slli	a3,a3,0x20
    80004532:	9281                	srli	a3,a3,0x20
    80004534:	068a                	slli	a3,a3,0x2
    80004536:	0001e617          	auipc	a2,0x1e
    8000453a:	96660613          	addi	a2,a2,-1690 # 80021e9c <log+0x34>
    8000453e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004540:	4390                	lw	a2,0(a5)
    80004542:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004544:	0791                	addi	a5,a5,4
    80004546:	0711                	addi	a4,a4,4
    80004548:	fed79ce3          	bne	a5,a3,80004540 <write_head+0x4e>
  }
  bwrite(buf);
    8000454c:	8526                	mv	a0,s1
    8000454e:	fffff097          	auipc	ra,0xfffff
    80004552:	0a4080e7          	jalr	164(ra) # 800035f2 <bwrite>
  brelse(buf);
    80004556:	8526                	mv	a0,s1
    80004558:	fffff097          	auipc	ra,0xfffff
    8000455c:	0d8080e7          	jalr	216(ra) # 80003630 <brelse>
}
    80004560:	60e2                	ld	ra,24(sp)
    80004562:	6442                	ld	s0,16(sp)
    80004564:	64a2                	ld	s1,8(sp)
    80004566:	6902                	ld	s2,0(sp)
    80004568:	6105                	addi	sp,sp,32
    8000456a:	8082                	ret

000000008000456c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456c:	0001e797          	auipc	a5,0x1e
    80004570:	9287a783          	lw	a5,-1752(a5) # 80021e94 <log+0x2c>
    80004574:	0af05d63          	blez	a5,8000462e <install_trans+0xc2>
{
    80004578:	7139                	addi	sp,sp,-64
    8000457a:	fc06                	sd	ra,56(sp)
    8000457c:	f822                	sd	s0,48(sp)
    8000457e:	f426                	sd	s1,40(sp)
    80004580:	f04a                	sd	s2,32(sp)
    80004582:	ec4e                	sd	s3,24(sp)
    80004584:	e852                	sd	s4,16(sp)
    80004586:	e456                	sd	s5,8(sp)
    80004588:	e05a                	sd	s6,0(sp)
    8000458a:	0080                	addi	s0,sp,64
    8000458c:	8b2a                	mv	s6,a0
    8000458e:	0001ea97          	auipc	s5,0x1e
    80004592:	90aa8a93          	addi	s5,s5,-1782 # 80021e98 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004596:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004598:	0001e997          	auipc	s3,0x1e
    8000459c:	8d098993          	addi	s3,s3,-1840 # 80021e68 <log>
    800045a0:	a035                	j	800045cc <install_trans+0x60>
      bunpin(dbuf);
    800045a2:	8526                	mv	a0,s1
    800045a4:	fffff097          	auipc	ra,0xfffff
    800045a8:	166080e7          	jalr	358(ra) # 8000370a <bunpin>
    brelse(lbuf);
    800045ac:	854a                	mv	a0,s2
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	082080e7          	jalr	130(ra) # 80003630 <brelse>
    brelse(dbuf);
    800045b6:	8526                	mv	a0,s1
    800045b8:	fffff097          	auipc	ra,0xfffff
    800045bc:	078080e7          	jalr	120(ra) # 80003630 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045c0:	2a05                	addiw	s4,s4,1
    800045c2:	0a91                	addi	s5,s5,4
    800045c4:	02c9a783          	lw	a5,44(s3)
    800045c8:	04fa5963          	bge	s4,a5,8000461a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045cc:	0189a583          	lw	a1,24(s3)
    800045d0:	014585bb          	addw	a1,a1,s4
    800045d4:	2585                	addiw	a1,a1,1
    800045d6:	0289a503          	lw	a0,40(s3)
    800045da:	fffff097          	auipc	ra,0xfffff
    800045de:	f26080e7          	jalr	-218(ra) # 80003500 <bread>
    800045e2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045e4:	000aa583          	lw	a1,0(s5)
    800045e8:	0289a503          	lw	a0,40(s3)
    800045ec:	fffff097          	auipc	ra,0xfffff
    800045f0:	f14080e7          	jalr	-236(ra) # 80003500 <bread>
    800045f4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045f6:	40000613          	li	a2,1024
    800045fa:	05890593          	addi	a1,s2,88
    800045fe:	05850513          	addi	a0,a0,88
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	73e080e7          	jalr	1854(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000460a:	8526                	mv	a0,s1
    8000460c:	fffff097          	auipc	ra,0xfffff
    80004610:	fe6080e7          	jalr	-26(ra) # 800035f2 <bwrite>
    if(recovering == 0)
    80004614:	f80b1ce3          	bnez	s6,800045ac <install_trans+0x40>
    80004618:	b769                	j	800045a2 <install_trans+0x36>
}
    8000461a:	70e2                	ld	ra,56(sp)
    8000461c:	7442                	ld	s0,48(sp)
    8000461e:	74a2                	ld	s1,40(sp)
    80004620:	7902                	ld	s2,32(sp)
    80004622:	69e2                	ld	s3,24(sp)
    80004624:	6a42                	ld	s4,16(sp)
    80004626:	6aa2                	ld	s5,8(sp)
    80004628:	6b02                	ld	s6,0(sp)
    8000462a:	6121                	addi	sp,sp,64
    8000462c:	8082                	ret
    8000462e:	8082                	ret

0000000080004630 <initlog>:
{
    80004630:	7179                	addi	sp,sp,-48
    80004632:	f406                	sd	ra,40(sp)
    80004634:	f022                	sd	s0,32(sp)
    80004636:	ec26                	sd	s1,24(sp)
    80004638:	e84a                	sd	s2,16(sp)
    8000463a:	e44e                	sd	s3,8(sp)
    8000463c:	1800                	addi	s0,sp,48
    8000463e:	892a                	mv	s2,a0
    80004640:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004642:	0001e497          	auipc	s1,0x1e
    80004646:	82648493          	addi	s1,s1,-2010 # 80021e68 <log>
    8000464a:	00004597          	auipc	a1,0x4
    8000464e:	04658593          	addi	a1,a1,70 # 80008690 <syscalls+0x1f0>
    80004652:	8526                	mv	a0,s1
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	500080e7          	jalr	1280(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    8000465c:	0149a583          	lw	a1,20(s3)
    80004660:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004662:	0109a783          	lw	a5,16(s3)
    80004666:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004668:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000466c:	854a                	mv	a0,s2
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	e92080e7          	jalr	-366(ra) # 80003500 <bread>
  log.lh.n = lh->n;
    80004676:	4d3c                	lw	a5,88(a0)
    80004678:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000467a:	02f05563          	blez	a5,800046a4 <initlog+0x74>
    8000467e:	05c50713          	addi	a4,a0,92
    80004682:	0001e697          	auipc	a3,0x1e
    80004686:	81668693          	addi	a3,a3,-2026 # 80021e98 <log+0x30>
    8000468a:	37fd                	addiw	a5,a5,-1
    8000468c:	1782                	slli	a5,a5,0x20
    8000468e:	9381                	srli	a5,a5,0x20
    80004690:	078a                	slli	a5,a5,0x2
    80004692:	06050613          	addi	a2,a0,96
    80004696:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004698:	4310                	lw	a2,0(a4)
    8000469a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000469c:	0711                	addi	a4,a4,4
    8000469e:	0691                	addi	a3,a3,4
    800046a0:	fef71ce3          	bne	a4,a5,80004698 <initlog+0x68>
  brelse(buf);
    800046a4:	fffff097          	auipc	ra,0xfffff
    800046a8:	f8c080e7          	jalr	-116(ra) # 80003630 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046ac:	4505                	li	a0,1
    800046ae:	00000097          	auipc	ra,0x0
    800046b2:	ebe080e7          	jalr	-322(ra) # 8000456c <install_trans>
  log.lh.n = 0;
    800046b6:	0001d797          	auipc	a5,0x1d
    800046ba:	7c07af23          	sw	zero,2014(a5) # 80021e94 <log+0x2c>
  write_head(); // clear the log
    800046be:	00000097          	auipc	ra,0x0
    800046c2:	e34080e7          	jalr	-460(ra) # 800044f2 <write_head>
}
    800046c6:	70a2                	ld	ra,40(sp)
    800046c8:	7402                	ld	s0,32(sp)
    800046ca:	64e2                	ld	s1,24(sp)
    800046cc:	6942                	ld	s2,16(sp)
    800046ce:	69a2                	ld	s3,8(sp)
    800046d0:	6145                	addi	sp,sp,48
    800046d2:	8082                	ret

00000000800046d4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046d4:	1101                	addi	sp,sp,-32
    800046d6:	ec06                	sd	ra,24(sp)
    800046d8:	e822                	sd	s0,16(sp)
    800046da:	e426                	sd	s1,8(sp)
    800046dc:	e04a                	sd	s2,0(sp)
    800046de:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046e0:	0001d517          	auipc	a0,0x1d
    800046e4:	78850513          	addi	a0,a0,1928 # 80021e68 <log>
    800046e8:	ffffc097          	auipc	ra,0xffffc
    800046ec:	4fc080e7          	jalr	1276(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    800046f0:	0001d497          	auipc	s1,0x1d
    800046f4:	77848493          	addi	s1,s1,1912 # 80021e68 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046f8:	4979                	li	s2,30
    800046fa:	a039                	j	80004708 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046fc:	85a6                	mv	a1,s1
    800046fe:	8526                	mv	a0,s1
    80004700:	ffffe097          	auipc	ra,0xffffe
    80004704:	f66080e7          	jalr	-154(ra) # 80002666 <sleep>
    if(log.committing){
    80004708:	50dc                	lw	a5,36(s1)
    8000470a:	fbed                	bnez	a5,800046fc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000470c:	509c                	lw	a5,32(s1)
    8000470e:	0017871b          	addiw	a4,a5,1
    80004712:	0007069b          	sext.w	a3,a4
    80004716:	0027179b          	slliw	a5,a4,0x2
    8000471a:	9fb9                	addw	a5,a5,a4
    8000471c:	0017979b          	slliw	a5,a5,0x1
    80004720:	54d8                	lw	a4,44(s1)
    80004722:	9fb9                	addw	a5,a5,a4
    80004724:	00f95963          	bge	s2,a5,80004736 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004728:	85a6                	mv	a1,s1
    8000472a:	8526                	mv	a0,s1
    8000472c:	ffffe097          	auipc	ra,0xffffe
    80004730:	f3a080e7          	jalr	-198(ra) # 80002666 <sleep>
    80004734:	bfd1                	j	80004708 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004736:	0001d517          	auipc	a0,0x1d
    8000473a:	73250513          	addi	a0,a0,1842 # 80021e68 <log>
    8000473e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004740:	ffffc097          	auipc	ra,0xffffc
    80004744:	558080e7          	jalr	1368(ra) # 80000c98 <release>
      break;
    }
  }
}
    80004748:	60e2                	ld	ra,24(sp)
    8000474a:	6442                	ld	s0,16(sp)
    8000474c:	64a2                	ld	s1,8(sp)
    8000474e:	6902                	ld	s2,0(sp)
    80004750:	6105                	addi	sp,sp,32
    80004752:	8082                	ret

0000000080004754 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004754:	7139                	addi	sp,sp,-64
    80004756:	fc06                	sd	ra,56(sp)
    80004758:	f822                	sd	s0,48(sp)
    8000475a:	f426                	sd	s1,40(sp)
    8000475c:	f04a                	sd	s2,32(sp)
    8000475e:	ec4e                	sd	s3,24(sp)
    80004760:	e852                	sd	s4,16(sp)
    80004762:	e456                	sd	s5,8(sp)
    80004764:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004766:	0001d497          	auipc	s1,0x1d
    8000476a:	70248493          	addi	s1,s1,1794 # 80021e68 <log>
    8000476e:	8526                	mv	a0,s1
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	474080e7          	jalr	1140(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    80004778:	509c                	lw	a5,32(s1)
    8000477a:	37fd                	addiw	a5,a5,-1
    8000477c:	0007891b          	sext.w	s2,a5
    80004780:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004782:	50dc                	lw	a5,36(s1)
    80004784:	efb9                	bnez	a5,800047e2 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004786:	06091663          	bnez	s2,800047f2 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000478a:	0001d497          	auipc	s1,0x1d
    8000478e:	6de48493          	addi	s1,s1,1758 # 80021e68 <log>
    80004792:	4785                	li	a5,1
    80004794:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004796:	8526                	mv	a0,s1
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	500080e7          	jalr	1280(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047a0:	54dc                	lw	a5,44(s1)
    800047a2:	06f04763          	bgtz	a5,80004810 <end_op+0xbc>
    acquire(&log.lock);
    800047a6:	0001d497          	auipc	s1,0x1d
    800047aa:	6c248493          	addi	s1,s1,1730 # 80021e68 <log>
    800047ae:	8526                	mv	a0,s1
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	434080e7          	jalr	1076(ra) # 80000be4 <acquire>
    log.committing = 0;
    800047b8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047bc:	8526                	mv	a0,s1
    800047be:	ffffe097          	auipc	ra,0xffffe
    800047c2:	046080e7          	jalr	70(ra) # 80002804 <wakeup>
    release(&log.lock);
    800047c6:	8526                	mv	a0,s1
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	4d0080e7          	jalr	1232(ra) # 80000c98 <release>
}
    800047d0:	70e2                	ld	ra,56(sp)
    800047d2:	7442                	ld	s0,48(sp)
    800047d4:	74a2                	ld	s1,40(sp)
    800047d6:	7902                	ld	s2,32(sp)
    800047d8:	69e2                	ld	s3,24(sp)
    800047da:	6a42                	ld	s4,16(sp)
    800047dc:	6aa2                	ld	s5,8(sp)
    800047de:	6121                	addi	sp,sp,64
    800047e0:	8082                	ret
    panic("log.committing");
    800047e2:	00004517          	auipc	a0,0x4
    800047e6:	eb650513          	addi	a0,a0,-330 # 80008698 <syscalls+0x1f8>
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	d54080e7          	jalr	-684(ra) # 8000053e <panic>
    wakeup(&log);
    800047f2:	0001d497          	auipc	s1,0x1d
    800047f6:	67648493          	addi	s1,s1,1654 # 80021e68 <log>
    800047fa:	8526                	mv	a0,s1
    800047fc:	ffffe097          	auipc	ra,0xffffe
    80004800:	008080e7          	jalr	8(ra) # 80002804 <wakeup>
  release(&log.lock);
    80004804:	8526                	mv	a0,s1
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	492080e7          	jalr	1170(ra) # 80000c98 <release>
  if(do_commit){
    8000480e:	b7c9                	j	800047d0 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004810:	0001da97          	auipc	s5,0x1d
    80004814:	688a8a93          	addi	s5,s5,1672 # 80021e98 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004818:	0001da17          	auipc	s4,0x1d
    8000481c:	650a0a13          	addi	s4,s4,1616 # 80021e68 <log>
    80004820:	018a2583          	lw	a1,24(s4)
    80004824:	012585bb          	addw	a1,a1,s2
    80004828:	2585                	addiw	a1,a1,1
    8000482a:	028a2503          	lw	a0,40(s4)
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	cd2080e7          	jalr	-814(ra) # 80003500 <bread>
    80004836:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004838:	000aa583          	lw	a1,0(s5)
    8000483c:	028a2503          	lw	a0,40(s4)
    80004840:	fffff097          	auipc	ra,0xfffff
    80004844:	cc0080e7          	jalr	-832(ra) # 80003500 <bread>
    80004848:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000484a:	40000613          	li	a2,1024
    8000484e:	05850593          	addi	a1,a0,88
    80004852:	05848513          	addi	a0,s1,88
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	4ea080e7          	jalr	1258(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    8000485e:	8526                	mv	a0,s1
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	d92080e7          	jalr	-622(ra) # 800035f2 <bwrite>
    brelse(from);
    80004868:	854e                	mv	a0,s3
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	dc6080e7          	jalr	-570(ra) # 80003630 <brelse>
    brelse(to);
    80004872:	8526                	mv	a0,s1
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	dbc080e7          	jalr	-580(ra) # 80003630 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000487c:	2905                	addiw	s2,s2,1
    8000487e:	0a91                	addi	s5,s5,4
    80004880:	02ca2783          	lw	a5,44(s4)
    80004884:	f8f94ee3          	blt	s2,a5,80004820 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004888:	00000097          	auipc	ra,0x0
    8000488c:	c6a080e7          	jalr	-918(ra) # 800044f2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004890:	4501                	li	a0,0
    80004892:	00000097          	auipc	ra,0x0
    80004896:	cda080e7          	jalr	-806(ra) # 8000456c <install_trans>
    log.lh.n = 0;
    8000489a:	0001d797          	auipc	a5,0x1d
    8000489e:	5e07ad23          	sw	zero,1530(a5) # 80021e94 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	c50080e7          	jalr	-944(ra) # 800044f2 <write_head>
    800048aa:	bdf5                	j	800047a6 <end_op+0x52>

00000000800048ac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048ac:	1101                	addi	sp,sp,-32
    800048ae:	ec06                	sd	ra,24(sp)
    800048b0:	e822                	sd	s0,16(sp)
    800048b2:	e426                	sd	s1,8(sp)
    800048b4:	e04a                	sd	s2,0(sp)
    800048b6:	1000                	addi	s0,sp,32
    800048b8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048ba:	0001d917          	auipc	s2,0x1d
    800048be:	5ae90913          	addi	s2,s2,1454 # 80021e68 <log>
    800048c2:	854a                	mv	a0,s2
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	320080e7          	jalr	800(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048cc:	02c92603          	lw	a2,44(s2)
    800048d0:	47f5                	li	a5,29
    800048d2:	06c7c563          	blt	a5,a2,8000493c <log_write+0x90>
    800048d6:	0001d797          	auipc	a5,0x1d
    800048da:	5ae7a783          	lw	a5,1454(a5) # 80021e84 <log+0x1c>
    800048de:	37fd                	addiw	a5,a5,-1
    800048e0:	04f65e63          	bge	a2,a5,8000493c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048e4:	0001d797          	auipc	a5,0x1d
    800048e8:	5a47a783          	lw	a5,1444(a5) # 80021e88 <log+0x20>
    800048ec:	06f05063          	blez	a5,8000494c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048f0:	4781                	li	a5,0
    800048f2:	06c05563          	blez	a2,8000495c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048f6:	44cc                	lw	a1,12(s1)
    800048f8:	0001d717          	auipc	a4,0x1d
    800048fc:	5a070713          	addi	a4,a4,1440 # 80021e98 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004900:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004902:	4314                	lw	a3,0(a4)
    80004904:	04b68c63          	beq	a3,a1,8000495c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004908:	2785                	addiw	a5,a5,1
    8000490a:	0711                	addi	a4,a4,4
    8000490c:	fef61be3          	bne	a2,a5,80004902 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004910:	0621                	addi	a2,a2,8
    80004912:	060a                	slli	a2,a2,0x2
    80004914:	0001d797          	auipc	a5,0x1d
    80004918:	55478793          	addi	a5,a5,1364 # 80021e68 <log>
    8000491c:	963e                	add	a2,a2,a5
    8000491e:	44dc                	lw	a5,12(s1)
    80004920:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004922:	8526                	mv	a0,s1
    80004924:	fffff097          	auipc	ra,0xfffff
    80004928:	daa080e7          	jalr	-598(ra) # 800036ce <bpin>
    log.lh.n++;
    8000492c:	0001d717          	auipc	a4,0x1d
    80004930:	53c70713          	addi	a4,a4,1340 # 80021e68 <log>
    80004934:	575c                	lw	a5,44(a4)
    80004936:	2785                	addiw	a5,a5,1
    80004938:	d75c                	sw	a5,44(a4)
    8000493a:	a835                	j	80004976 <log_write+0xca>
    panic("too big a transaction");
    8000493c:	00004517          	auipc	a0,0x4
    80004940:	d6c50513          	addi	a0,a0,-660 # 800086a8 <syscalls+0x208>
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	bfa080e7          	jalr	-1030(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000494c:	00004517          	auipc	a0,0x4
    80004950:	d7450513          	addi	a0,a0,-652 # 800086c0 <syscalls+0x220>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	bea080e7          	jalr	-1046(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000495c:	00878713          	addi	a4,a5,8
    80004960:	00271693          	slli	a3,a4,0x2
    80004964:	0001d717          	auipc	a4,0x1d
    80004968:	50470713          	addi	a4,a4,1284 # 80021e68 <log>
    8000496c:	9736                	add	a4,a4,a3
    8000496e:	44d4                	lw	a3,12(s1)
    80004970:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004972:	faf608e3          	beq	a2,a5,80004922 <log_write+0x76>
  }
  release(&log.lock);
    80004976:	0001d517          	auipc	a0,0x1d
    8000497a:	4f250513          	addi	a0,a0,1266 # 80021e68 <log>
    8000497e:	ffffc097          	auipc	ra,0xffffc
    80004982:	31a080e7          	jalr	794(ra) # 80000c98 <release>
}
    80004986:	60e2                	ld	ra,24(sp)
    80004988:	6442                	ld	s0,16(sp)
    8000498a:	64a2                	ld	s1,8(sp)
    8000498c:	6902                	ld	s2,0(sp)
    8000498e:	6105                	addi	sp,sp,32
    80004990:	8082                	ret

0000000080004992 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004992:	1101                	addi	sp,sp,-32
    80004994:	ec06                	sd	ra,24(sp)
    80004996:	e822                	sd	s0,16(sp)
    80004998:	e426                	sd	s1,8(sp)
    8000499a:	e04a                	sd	s2,0(sp)
    8000499c:	1000                	addi	s0,sp,32
    8000499e:	84aa                	mv	s1,a0
    800049a0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049a2:	00004597          	auipc	a1,0x4
    800049a6:	d3e58593          	addi	a1,a1,-706 # 800086e0 <syscalls+0x240>
    800049aa:	0521                	addi	a0,a0,8
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	1a8080e7          	jalr	424(ra) # 80000b54 <initlock>
  lk->name = name;
    800049b4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049b8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049bc:	0204a423          	sw	zero,40(s1)
}
    800049c0:	60e2                	ld	ra,24(sp)
    800049c2:	6442                	ld	s0,16(sp)
    800049c4:	64a2                	ld	s1,8(sp)
    800049c6:	6902                	ld	s2,0(sp)
    800049c8:	6105                	addi	sp,sp,32
    800049ca:	8082                	ret

00000000800049cc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049cc:	1101                	addi	sp,sp,-32
    800049ce:	ec06                	sd	ra,24(sp)
    800049d0:	e822                	sd	s0,16(sp)
    800049d2:	e426                	sd	s1,8(sp)
    800049d4:	e04a                	sd	s2,0(sp)
    800049d6:	1000                	addi	s0,sp,32
    800049d8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049da:	00850913          	addi	s2,a0,8
    800049de:	854a                	mv	a0,s2
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	204080e7          	jalr	516(ra) # 80000be4 <acquire>
  while (lk->locked) {
    800049e8:	409c                	lw	a5,0(s1)
    800049ea:	cb89                	beqz	a5,800049fc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049ec:	85ca                	mv	a1,s2
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffe097          	auipc	ra,0xffffe
    800049f4:	c76080e7          	jalr	-906(ra) # 80002666 <sleep>
  while (lk->locked) {
    800049f8:	409c                	lw	a5,0(s1)
    800049fa:	fbed                	bnez	a5,800049ec <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049fc:	4785                	li	a5,1
    800049fe:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a00:	ffffd097          	auipc	ra,0xffffd
    80004a04:	3c0080e7          	jalr	960(ra) # 80001dc0 <myproc>
    80004a08:	591c                	lw	a5,48(a0)
    80004a0a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a0c:	854a                	mv	a0,s2
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	28a080e7          	jalr	650(ra) # 80000c98 <release>
}
    80004a16:	60e2                	ld	ra,24(sp)
    80004a18:	6442                	ld	s0,16(sp)
    80004a1a:	64a2                	ld	s1,8(sp)
    80004a1c:	6902                	ld	s2,0(sp)
    80004a1e:	6105                	addi	sp,sp,32
    80004a20:	8082                	ret

0000000080004a22 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a22:	1101                	addi	sp,sp,-32
    80004a24:	ec06                	sd	ra,24(sp)
    80004a26:	e822                	sd	s0,16(sp)
    80004a28:	e426                	sd	s1,8(sp)
    80004a2a:	e04a                	sd	s2,0(sp)
    80004a2c:	1000                	addi	s0,sp,32
    80004a2e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a30:	00850913          	addi	s2,a0,8
    80004a34:	854a                	mv	a0,s2
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  lk->locked = 0;
    80004a3e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a42:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ffffe097          	auipc	ra,0xffffe
    80004a4c:	dbc080e7          	jalr	-580(ra) # 80002804 <wakeup>
  release(&lk->lk);
    80004a50:	854a                	mv	a0,s2
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	246080e7          	jalr	582(ra) # 80000c98 <release>
}
    80004a5a:	60e2                	ld	ra,24(sp)
    80004a5c:	6442                	ld	s0,16(sp)
    80004a5e:	64a2                	ld	s1,8(sp)
    80004a60:	6902                	ld	s2,0(sp)
    80004a62:	6105                	addi	sp,sp,32
    80004a64:	8082                	ret

0000000080004a66 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a66:	7179                	addi	sp,sp,-48
    80004a68:	f406                	sd	ra,40(sp)
    80004a6a:	f022                	sd	s0,32(sp)
    80004a6c:	ec26                	sd	s1,24(sp)
    80004a6e:	e84a                	sd	s2,16(sp)
    80004a70:	e44e                	sd	s3,8(sp)
    80004a72:	1800                	addi	s0,sp,48
    80004a74:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a76:	00850913          	addi	s2,a0,8
    80004a7a:	854a                	mv	a0,s2
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	168080e7          	jalr	360(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a84:	409c                	lw	a5,0(s1)
    80004a86:	ef99                	bnez	a5,80004aa4 <holdingsleep+0x3e>
    80004a88:	4481                	li	s1,0
  release(&lk->lk);
    80004a8a:	854a                	mv	a0,s2
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	20c080e7          	jalr	524(ra) # 80000c98 <release>
  return r;
}
    80004a94:	8526                	mv	a0,s1
    80004a96:	70a2                	ld	ra,40(sp)
    80004a98:	7402                	ld	s0,32(sp)
    80004a9a:	64e2                	ld	s1,24(sp)
    80004a9c:	6942                	ld	s2,16(sp)
    80004a9e:	69a2                	ld	s3,8(sp)
    80004aa0:	6145                	addi	sp,sp,48
    80004aa2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aa4:	0284a983          	lw	s3,40(s1)
    80004aa8:	ffffd097          	auipc	ra,0xffffd
    80004aac:	318080e7          	jalr	792(ra) # 80001dc0 <myproc>
    80004ab0:	5904                	lw	s1,48(a0)
    80004ab2:	413484b3          	sub	s1,s1,s3
    80004ab6:	0014b493          	seqz	s1,s1
    80004aba:	bfc1                	j	80004a8a <holdingsleep+0x24>

0000000080004abc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004abc:	1141                	addi	sp,sp,-16
    80004abe:	e406                	sd	ra,8(sp)
    80004ac0:	e022                	sd	s0,0(sp)
    80004ac2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ac4:	00004597          	auipc	a1,0x4
    80004ac8:	c2c58593          	addi	a1,a1,-980 # 800086f0 <syscalls+0x250>
    80004acc:	0001d517          	auipc	a0,0x1d
    80004ad0:	4e450513          	addi	a0,a0,1252 # 80021fb0 <ftable>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	080080e7          	jalr	128(ra) # 80000b54 <initlock>
}
    80004adc:	60a2                	ld	ra,8(sp)
    80004ade:	6402                	ld	s0,0(sp)
    80004ae0:	0141                	addi	sp,sp,16
    80004ae2:	8082                	ret

0000000080004ae4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ae4:	1101                	addi	sp,sp,-32
    80004ae6:	ec06                	sd	ra,24(sp)
    80004ae8:	e822                	sd	s0,16(sp)
    80004aea:	e426                	sd	s1,8(sp)
    80004aec:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004aee:	0001d517          	auipc	a0,0x1d
    80004af2:	4c250513          	addi	a0,a0,1218 # 80021fb0 <ftable>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	0ee080e7          	jalr	238(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004afe:	0001d497          	auipc	s1,0x1d
    80004b02:	4ca48493          	addi	s1,s1,1226 # 80021fc8 <ftable+0x18>
    80004b06:	0001e717          	auipc	a4,0x1e
    80004b0a:	46270713          	addi	a4,a4,1122 # 80022f68 <ftable+0xfb8>
    if(f->ref == 0){
    80004b0e:	40dc                	lw	a5,4(s1)
    80004b10:	cf99                	beqz	a5,80004b2e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b12:	02848493          	addi	s1,s1,40
    80004b16:	fee49ce3          	bne	s1,a4,80004b0e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b1a:	0001d517          	auipc	a0,0x1d
    80004b1e:	49650513          	addi	a0,a0,1174 # 80021fb0 <ftable>
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	176080e7          	jalr	374(ra) # 80000c98 <release>
  return 0;
    80004b2a:	4481                	li	s1,0
    80004b2c:	a819                	j	80004b42 <filealloc+0x5e>
      f->ref = 1;
    80004b2e:	4785                	li	a5,1
    80004b30:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b32:	0001d517          	auipc	a0,0x1d
    80004b36:	47e50513          	addi	a0,a0,1150 # 80021fb0 <ftable>
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	15e080e7          	jalr	350(ra) # 80000c98 <release>
}
    80004b42:	8526                	mv	a0,s1
    80004b44:	60e2                	ld	ra,24(sp)
    80004b46:	6442                	ld	s0,16(sp)
    80004b48:	64a2                	ld	s1,8(sp)
    80004b4a:	6105                	addi	sp,sp,32
    80004b4c:	8082                	ret

0000000080004b4e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b4e:	1101                	addi	sp,sp,-32
    80004b50:	ec06                	sd	ra,24(sp)
    80004b52:	e822                	sd	s0,16(sp)
    80004b54:	e426                	sd	s1,8(sp)
    80004b56:	1000                	addi	s0,sp,32
    80004b58:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b5a:	0001d517          	auipc	a0,0x1d
    80004b5e:	45650513          	addi	a0,a0,1110 # 80021fb0 <ftable>
    80004b62:	ffffc097          	auipc	ra,0xffffc
    80004b66:	082080e7          	jalr	130(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004b6a:	40dc                	lw	a5,4(s1)
    80004b6c:	02f05263          	blez	a5,80004b90 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b70:	2785                	addiw	a5,a5,1
    80004b72:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b74:	0001d517          	auipc	a0,0x1d
    80004b78:	43c50513          	addi	a0,a0,1084 # 80021fb0 <ftable>
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	11c080e7          	jalr	284(ra) # 80000c98 <release>
  return f;
}
    80004b84:	8526                	mv	a0,s1
    80004b86:	60e2                	ld	ra,24(sp)
    80004b88:	6442                	ld	s0,16(sp)
    80004b8a:	64a2                	ld	s1,8(sp)
    80004b8c:	6105                	addi	sp,sp,32
    80004b8e:	8082                	ret
    panic("filedup");
    80004b90:	00004517          	auipc	a0,0x4
    80004b94:	b6850513          	addi	a0,a0,-1176 # 800086f8 <syscalls+0x258>
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	9a6080e7          	jalr	-1626(ra) # 8000053e <panic>

0000000080004ba0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ba0:	7139                	addi	sp,sp,-64
    80004ba2:	fc06                	sd	ra,56(sp)
    80004ba4:	f822                	sd	s0,48(sp)
    80004ba6:	f426                	sd	s1,40(sp)
    80004ba8:	f04a                	sd	s2,32(sp)
    80004baa:	ec4e                	sd	s3,24(sp)
    80004bac:	e852                	sd	s4,16(sp)
    80004bae:	e456                	sd	s5,8(sp)
    80004bb0:	0080                	addi	s0,sp,64
    80004bb2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bb4:	0001d517          	auipc	a0,0x1d
    80004bb8:	3fc50513          	addi	a0,a0,1020 # 80021fb0 <ftable>
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	028080e7          	jalr	40(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004bc4:	40dc                	lw	a5,4(s1)
    80004bc6:	06f05163          	blez	a5,80004c28 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bca:	37fd                	addiw	a5,a5,-1
    80004bcc:	0007871b          	sext.w	a4,a5
    80004bd0:	c0dc                	sw	a5,4(s1)
    80004bd2:	06e04363          	bgtz	a4,80004c38 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bd6:	0004a903          	lw	s2,0(s1)
    80004bda:	0094ca83          	lbu	s5,9(s1)
    80004bde:	0104ba03          	ld	s4,16(s1)
    80004be2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004be6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bea:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bee:	0001d517          	auipc	a0,0x1d
    80004bf2:	3c250513          	addi	a0,a0,962 # 80021fb0 <ftable>
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	0a2080e7          	jalr	162(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    80004bfe:	4785                	li	a5,1
    80004c00:	04f90d63          	beq	s2,a5,80004c5a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c04:	3979                	addiw	s2,s2,-2
    80004c06:	4785                	li	a5,1
    80004c08:	0527e063          	bltu	a5,s2,80004c48 <fileclose+0xa8>
    begin_op();
    80004c0c:	00000097          	auipc	ra,0x0
    80004c10:	ac8080e7          	jalr	-1336(ra) # 800046d4 <begin_op>
    iput(ff.ip);
    80004c14:	854e                	mv	a0,s3
    80004c16:	fffff097          	auipc	ra,0xfffff
    80004c1a:	2a6080e7          	jalr	678(ra) # 80003ebc <iput>
    end_op();
    80004c1e:	00000097          	auipc	ra,0x0
    80004c22:	b36080e7          	jalr	-1226(ra) # 80004754 <end_op>
    80004c26:	a00d                	j	80004c48 <fileclose+0xa8>
    panic("fileclose");
    80004c28:	00004517          	auipc	a0,0x4
    80004c2c:	ad850513          	addi	a0,a0,-1320 # 80008700 <syscalls+0x260>
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004c38:	0001d517          	auipc	a0,0x1d
    80004c3c:	37850513          	addi	a0,a0,888 # 80021fb0 <ftable>
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	058080e7          	jalr	88(ra) # 80000c98 <release>
  }
}
    80004c48:	70e2                	ld	ra,56(sp)
    80004c4a:	7442                	ld	s0,48(sp)
    80004c4c:	74a2                	ld	s1,40(sp)
    80004c4e:	7902                	ld	s2,32(sp)
    80004c50:	69e2                	ld	s3,24(sp)
    80004c52:	6a42                	ld	s4,16(sp)
    80004c54:	6aa2                	ld	s5,8(sp)
    80004c56:	6121                	addi	sp,sp,64
    80004c58:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c5a:	85d6                	mv	a1,s5
    80004c5c:	8552                	mv	a0,s4
    80004c5e:	00000097          	auipc	ra,0x0
    80004c62:	34c080e7          	jalr	844(ra) # 80004faa <pipeclose>
    80004c66:	b7cd                	j	80004c48 <fileclose+0xa8>

0000000080004c68 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c68:	715d                	addi	sp,sp,-80
    80004c6a:	e486                	sd	ra,72(sp)
    80004c6c:	e0a2                	sd	s0,64(sp)
    80004c6e:	fc26                	sd	s1,56(sp)
    80004c70:	f84a                	sd	s2,48(sp)
    80004c72:	f44e                	sd	s3,40(sp)
    80004c74:	0880                	addi	s0,sp,80
    80004c76:	84aa                	mv	s1,a0
    80004c78:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	146080e7          	jalr	326(ra) # 80001dc0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c82:	409c                	lw	a5,0(s1)
    80004c84:	37f9                	addiw	a5,a5,-2
    80004c86:	4705                	li	a4,1
    80004c88:	04f76763          	bltu	a4,a5,80004cd6 <filestat+0x6e>
    80004c8c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c8e:	6c88                	ld	a0,24(s1)
    80004c90:	fffff097          	auipc	ra,0xfffff
    80004c94:	072080e7          	jalr	114(ra) # 80003d02 <ilock>
    stati(f->ip, &st);
    80004c98:	fb840593          	addi	a1,s0,-72
    80004c9c:	6c88                	ld	a0,24(s1)
    80004c9e:	fffff097          	auipc	ra,0xfffff
    80004ca2:	2ee080e7          	jalr	750(ra) # 80003f8c <stati>
    iunlock(f->ip);
    80004ca6:	6c88                	ld	a0,24(s1)
    80004ca8:	fffff097          	auipc	ra,0xfffff
    80004cac:	11c080e7          	jalr	284(ra) # 80003dc4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cb0:	46e1                	li	a3,24
    80004cb2:	fb840613          	addi	a2,s0,-72
    80004cb6:	85ce                	mv	a1,s3
    80004cb8:	07893503          	ld	a0,120(s2)
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	9b6080e7          	jalr	-1610(ra) # 80001672 <copyout>
    80004cc4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004cc8:	60a6                	ld	ra,72(sp)
    80004cca:	6406                	ld	s0,64(sp)
    80004ccc:	74e2                	ld	s1,56(sp)
    80004cce:	7942                	ld	s2,48(sp)
    80004cd0:	79a2                	ld	s3,40(sp)
    80004cd2:	6161                	addi	sp,sp,80
    80004cd4:	8082                	ret
  return -1;
    80004cd6:	557d                	li	a0,-1
    80004cd8:	bfc5                	j	80004cc8 <filestat+0x60>

0000000080004cda <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cda:	7179                	addi	sp,sp,-48
    80004cdc:	f406                	sd	ra,40(sp)
    80004cde:	f022                	sd	s0,32(sp)
    80004ce0:	ec26                	sd	s1,24(sp)
    80004ce2:	e84a                	sd	s2,16(sp)
    80004ce4:	e44e                	sd	s3,8(sp)
    80004ce6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ce8:	00854783          	lbu	a5,8(a0)
    80004cec:	c3d5                	beqz	a5,80004d90 <fileread+0xb6>
    80004cee:	84aa                	mv	s1,a0
    80004cf0:	89ae                	mv	s3,a1
    80004cf2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cf4:	411c                	lw	a5,0(a0)
    80004cf6:	4705                	li	a4,1
    80004cf8:	04e78963          	beq	a5,a4,80004d4a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cfc:	470d                	li	a4,3
    80004cfe:	04e78d63          	beq	a5,a4,80004d58 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d02:	4709                	li	a4,2
    80004d04:	06e79e63          	bne	a5,a4,80004d80 <fileread+0xa6>
    ilock(f->ip);
    80004d08:	6d08                	ld	a0,24(a0)
    80004d0a:	fffff097          	auipc	ra,0xfffff
    80004d0e:	ff8080e7          	jalr	-8(ra) # 80003d02 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d12:	874a                	mv	a4,s2
    80004d14:	5094                	lw	a3,32(s1)
    80004d16:	864e                	mv	a2,s3
    80004d18:	4585                	li	a1,1
    80004d1a:	6c88                	ld	a0,24(s1)
    80004d1c:	fffff097          	auipc	ra,0xfffff
    80004d20:	29a080e7          	jalr	666(ra) # 80003fb6 <readi>
    80004d24:	892a                	mv	s2,a0
    80004d26:	00a05563          	blez	a0,80004d30 <fileread+0x56>
      f->off += r;
    80004d2a:	509c                	lw	a5,32(s1)
    80004d2c:	9fa9                	addw	a5,a5,a0
    80004d2e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d30:	6c88                	ld	a0,24(s1)
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	092080e7          	jalr	146(ra) # 80003dc4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d3a:	854a                	mv	a0,s2
    80004d3c:	70a2                	ld	ra,40(sp)
    80004d3e:	7402                	ld	s0,32(sp)
    80004d40:	64e2                	ld	s1,24(sp)
    80004d42:	6942                	ld	s2,16(sp)
    80004d44:	69a2                	ld	s3,8(sp)
    80004d46:	6145                	addi	sp,sp,48
    80004d48:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d4a:	6908                	ld	a0,16(a0)
    80004d4c:	00000097          	auipc	ra,0x0
    80004d50:	3c8080e7          	jalr	968(ra) # 80005114 <piperead>
    80004d54:	892a                	mv	s2,a0
    80004d56:	b7d5                	j	80004d3a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d58:	02451783          	lh	a5,36(a0)
    80004d5c:	03079693          	slli	a3,a5,0x30
    80004d60:	92c1                	srli	a3,a3,0x30
    80004d62:	4725                	li	a4,9
    80004d64:	02d76863          	bltu	a4,a3,80004d94 <fileread+0xba>
    80004d68:	0792                	slli	a5,a5,0x4
    80004d6a:	0001d717          	auipc	a4,0x1d
    80004d6e:	1a670713          	addi	a4,a4,422 # 80021f10 <devsw>
    80004d72:	97ba                	add	a5,a5,a4
    80004d74:	639c                	ld	a5,0(a5)
    80004d76:	c38d                	beqz	a5,80004d98 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d78:	4505                	li	a0,1
    80004d7a:	9782                	jalr	a5
    80004d7c:	892a                	mv	s2,a0
    80004d7e:	bf75                	j	80004d3a <fileread+0x60>
    panic("fileread");
    80004d80:	00004517          	auipc	a0,0x4
    80004d84:	99050513          	addi	a0,a0,-1648 # 80008710 <syscalls+0x270>
    80004d88:	ffffb097          	auipc	ra,0xffffb
    80004d8c:	7b6080e7          	jalr	1974(ra) # 8000053e <panic>
    return -1;
    80004d90:	597d                	li	s2,-1
    80004d92:	b765                	j	80004d3a <fileread+0x60>
      return -1;
    80004d94:	597d                	li	s2,-1
    80004d96:	b755                	j	80004d3a <fileread+0x60>
    80004d98:	597d                	li	s2,-1
    80004d9a:	b745                	j	80004d3a <fileread+0x60>

0000000080004d9c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d9c:	715d                	addi	sp,sp,-80
    80004d9e:	e486                	sd	ra,72(sp)
    80004da0:	e0a2                	sd	s0,64(sp)
    80004da2:	fc26                	sd	s1,56(sp)
    80004da4:	f84a                	sd	s2,48(sp)
    80004da6:	f44e                	sd	s3,40(sp)
    80004da8:	f052                	sd	s4,32(sp)
    80004daa:	ec56                	sd	s5,24(sp)
    80004dac:	e85a                	sd	s6,16(sp)
    80004dae:	e45e                	sd	s7,8(sp)
    80004db0:	e062                	sd	s8,0(sp)
    80004db2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004db4:	00954783          	lbu	a5,9(a0)
    80004db8:	10078663          	beqz	a5,80004ec4 <filewrite+0x128>
    80004dbc:	892a                	mv	s2,a0
    80004dbe:	8aae                	mv	s5,a1
    80004dc0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dc2:	411c                	lw	a5,0(a0)
    80004dc4:	4705                	li	a4,1
    80004dc6:	02e78263          	beq	a5,a4,80004dea <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dca:	470d                	li	a4,3
    80004dcc:	02e78663          	beq	a5,a4,80004df8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dd0:	4709                	li	a4,2
    80004dd2:	0ee79163          	bne	a5,a4,80004eb4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dd6:	0ac05d63          	blez	a2,80004e90 <filewrite+0xf4>
    int i = 0;
    80004dda:	4981                	li	s3,0
    80004ddc:	6b05                	lui	s6,0x1
    80004dde:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004de2:	6b85                	lui	s7,0x1
    80004de4:	c00b8b9b          	addiw	s7,s7,-1024
    80004de8:	a861                	j	80004e80 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dea:	6908                	ld	a0,16(a0)
    80004dec:	00000097          	auipc	ra,0x0
    80004df0:	22e080e7          	jalr	558(ra) # 8000501a <pipewrite>
    80004df4:	8a2a                	mv	s4,a0
    80004df6:	a045                	j	80004e96 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004df8:	02451783          	lh	a5,36(a0)
    80004dfc:	03079693          	slli	a3,a5,0x30
    80004e00:	92c1                	srli	a3,a3,0x30
    80004e02:	4725                	li	a4,9
    80004e04:	0cd76263          	bltu	a4,a3,80004ec8 <filewrite+0x12c>
    80004e08:	0792                	slli	a5,a5,0x4
    80004e0a:	0001d717          	auipc	a4,0x1d
    80004e0e:	10670713          	addi	a4,a4,262 # 80021f10 <devsw>
    80004e12:	97ba                	add	a5,a5,a4
    80004e14:	679c                	ld	a5,8(a5)
    80004e16:	cbdd                	beqz	a5,80004ecc <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e18:	4505                	li	a0,1
    80004e1a:	9782                	jalr	a5
    80004e1c:	8a2a                	mv	s4,a0
    80004e1e:	a8a5                	j	80004e96 <filewrite+0xfa>
    80004e20:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e24:	00000097          	auipc	ra,0x0
    80004e28:	8b0080e7          	jalr	-1872(ra) # 800046d4 <begin_op>
      ilock(f->ip);
    80004e2c:	01893503          	ld	a0,24(s2)
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	ed2080e7          	jalr	-302(ra) # 80003d02 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e38:	8762                	mv	a4,s8
    80004e3a:	02092683          	lw	a3,32(s2)
    80004e3e:	01598633          	add	a2,s3,s5
    80004e42:	4585                	li	a1,1
    80004e44:	01893503          	ld	a0,24(s2)
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	266080e7          	jalr	614(ra) # 800040ae <writei>
    80004e50:	84aa                	mv	s1,a0
    80004e52:	00a05763          	blez	a0,80004e60 <filewrite+0xc4>
        f->off += r;
    80004e56:	02092783          	lw	a5,32(s2)
    80004e5a:	9fa9                	addw	a5,a5,a0
    80004e5c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e60:	01893503          	ld	a0,24(s2)
    80004e64:	fffff097          	auipc	ra,0xfffff
    80004e68:	f60080e7          	jalr	-160(ra) # 80003dc4 <iunlock>
      end_op();
    80004e6c:	00000097          	auipc	ra,0x0
    80004e70:	8e8080e7          	jalr	-1816(ra) # 80004754 <end_op>

      if(r != n1){
    80004e74:	009c1f63          	bne	s8,s1,80004e92 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e78:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e7c:	0149db63          	bge	s3,s4,80004e92 <filewrite+0xf6>
      int n1 = n - i;
    80004e80:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e84:	84be                	mv	s1,a5
    80004e86:	2781                	sext.w	a5,a5
    80004e88:	f8fb5ce3          	bge	s6,a5,80004e20 <filewrite+0x84>
    80004e8c:	84de                	mv	s1,s7
    80004e8e:	bf49                	j	80004e20 <filewrite+0x84>
    int i = 0;
    80004e90:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e92:	013a1f63          	bne	s4,s3,80004eb0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e96:	8552                	mv	a0,s4
    80004e98:	60a6                	ld	ra,72(sp)
    80004e9a:	6406                	ld	s0,64(sp)
    80004e9c:	74e2                	ld	s1,56(sp)
    80004e9e:	7942                	ld	s2,48(sp)
    80004ea0:	79a2                	ld	s3,40(sp)
    80004ea2:	7a02                	ld	s4,32(sp)
    80004ea4:	6ae2                	ld	s5,24(sp)
    80004ea6:	6b42                	ld	s6,16(sp)
    80004ea8:	6ba2                	ld	s7,8(sp)
    80004eaa:	6c02                	ld	s8,0(sp)
    80004eac:	6161                	addi	sp,sp,80
    80004eae:	8082                	ret
    ret = (i == n ? n : -1);
    80004eb0:	5a7d                	li	s4,-1
    80004eb2:	b7d5                	j	80004e96 <filewrite+0xfa>
    panic("filewrite");
    80004eb4:	00004517          	auipc	a0,0x4
    80004eb8:	86c50513          	addi	a0,a0,-1940 # 80008720 <syscalls+0x280>
    80004ebc:	ffffb097          	auipc	ra,0xffffb
    80004ec0:	682080e7          	jalr	1666(ra) # 8000053e <panic>
    return -1;
    80004ec4:	5a7d                	li	s4,-1
    80004ec6:	bfc1                	j	80004e96 <filewrite+0xfa>
      return -1;
    80004ec8:	5a7d                	li	s4,-1
    80004eca:	b7f1                	j	80004e96 <filewrite+0xfa>
    80004ecc:	5a7d                	li	s4,-1
    80004ece:	b7e1                	j	80004e96 <filewrite+0xfa>

0000000080004ed0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ed0:	7179                	addi	sp,sp,-48
    80004ed2:	f406                	sd	ra,40(sp)
    80004ed4:	f022                	sd	s0,32(sp)
    80004ed6:	ec26                	sd	s1,24(sp)
    80004ed8:	e84a                	sd	s2,16(sp)
    80004eda:	e44e                	sd	s3,8(sp)
    80004edc:	e052                	sd	s4,0(sp)
    80004ede:	1800                	addi	s0,sp,48
    80004ee0:	84aa                	mv	s1,a0
    80004ee2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ee4:	0005b023          	sd	zero,0(a1)
    80004ee8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	bf8080e7          	jalr	-1032(ra) # 80004ae4 <filealloc>
    80004ef4:	e088                	sd	a0,0(s1)
    80004ef6:	c551                	beqz	a0,80004f82 <pipealloc+0xb2>
    80004ef8:	00000097          	auipc	ra,0x0
    80004efc:	bec080e7          	jalr	-1044(ra) # 80004ae4 <filealloc>
    80004f00:	00aa3023          	sd	a0,0(s4)
    80004f04:	c92d                	beqz	a0,80004f76 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f06:	ffffc097          	auipc	ra,0xffffc
    80004f0a:	bee080e7          	jalr	-1042(ra) # 80000af4 <kalloc>
    80004f0e:	892a                	mv	s2,a0
    80004f10:	c125                	beqz	a0,80004f70 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f12:	4985                	li	s3,1
    80004f14:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f18:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f1c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f20:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f24:	00004597          	auipc	a1,0x4
    80004f28:	80c58593          	addi	a1,a1,-2036 # 80008730 <syscalls+0x290>
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	c28080e7          	jalr	-984(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004f34:	609c                	ld	a5,0(s1)
    80004f36:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f3a:	609c                	ld	a5,0(s1)
    80004f3c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f40:	609c                	ld	a5,0(s1)
    80004f42:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f46:	609c                	ld	a5,0(s1)
    80004f48:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f4c:	000a3783          	ld	a5,0(s4)
    80004f50:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f54:	000a3783          	ld	a5,0(s4)
    80004f58:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f5c:	000a3783          	ld	a5,0(s4)
    80004f60:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f64:	000a3783          	ld	a5,0(s4)
    80004f68:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f6c:	4501                	li	a0,0
    80004f6e:	a025                	j	80004f96 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f70:	6088                	ld	a0,0(s1)
    80004f72:	e501                	bnez	a0,80004f7a <pipealloc+0xaa>
    80004f74:	a039                	j	80004f82 <pipealloc+0xb2>
    80004f76:	6088                	ld	a0,0(s1)
    80004f78:	c51d                	beqz	a0,80004fa6 <pipealloc+0xd6>
    fileclose(*f0);
    80004f7a:	00000097          	auipc	ra,0x0
    80004f7e:	c26080e7          	jalr	-986(ra) # 80004ba0 <fileclose>
  if(*f1)
    80004f82:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f86:	557d                	li	a0,-1
  if(*f1)
    80004f88:	c799                	beqz	a5,80004f96 <pipealloc+0xc6>
    fileclose(*f1);
    80004f8a:	853e                	mv	a0,a5
    80004f8c:	00000097          	auipc	ra,0x0
    80004f90:	c14080e7          	jalr	-1004(ra) # 80004ba0 <fileclose>
  return -1;
    80004f94:	557d                	li	a0,-1
}
    80004f96:	70a2                	ld	ra,40(sp)
    80004f98:	7402                	ld	s0,32(sp)
    80004f9a:	64e2                	ld	s1,24(sp)
    80004f9c:	6942                	ld	s2,16(sp)
    80004f9e:	69a2                	ld	s3,8(sp)
    80004fa0:	6a02                	ld	s4,0(sp)
    80004fa2:	6145                	addi	sp,sp,48
    80004fa4:	8082                	ret
  return -1;
    80004fa6:	557d                	li	a0,-1
    80004fa8:	b7fd                	j	80004f96 <pipealloc+0xc6>

0000000080004faa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004faa:	1101                	addi	sp,sp,-32
    80004fac:	ec06                	sd	ra,24(sp)
    80004fae:	e822                	sd	s0,16(sp)
    80004fb0:	e426                	sd	s1,8(sp)
    80004fb2:	e04a                	sd	s2,0(sp)
    80004fb4:	1000                	addi	s0,sp,32
    80004fb6:	84aa                	mv	s1,a0
    80004fb8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fba:	ffffc097          	auipc	ra,0xffffc
    80004fbe:	c2a080e7          	jalr	-982(ra) # 80000be4 <acquire>
  if(writable){
    80004fc2:	02090d63          	beqz	s2,80004ffc <pipeclose+0x52>
    pi->writeopen = 0;
    80004fc6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fca:	21848513          	addi	a0,s1,536
    80004fce:	ffffe097          	auipc	ra,0xffffe
    80004fd2:	836080e7          	jalr	-1994(ra) # 80002804 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fd6:	2204b783          	ld	a5,544(s1)
    80004fda:	eb95                	bnez	a5,8000500e <pipeclose+0x64>
    release(&pi->lock);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	cba080e7          	jalr	-838(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	a10080e7          	jalr	-1520(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80004ff0:	60e2                	ld	ra,24(sp)
    80004ff2:	6442                	ld	s0,16(sp)
    80004ff4:	64a2                	ld	s1,8(sp)
    80004ff6:	6902                	ld	s2,0(sp)
    80004ff8:	6105                	addi	sp,sp,32
    80004ffa:	8082                	ret
    pi->readopen = 0;
    80004ffc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005000:	21c48513          	addi	a0,s1,540
    80005004:	ffffe097          	auipc	ra,0xffffe
    80005008:	800080e7          	jalr	-2048(ra) # 80002804 <wakeup>
    8000500c:	b7e9                	j	80004fd6 <pipeclose+0x2c>
    release(&pi->lock);
    8000500e:	8526                	mv	a0,s1
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	c88080e7          	jalr	-888(ra) # 80000c98 <release>
}
    80005018:	bfe1                	j	80004ff0 <pipeclose+0x46>

000000008000501a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000501a:	7159                	addi	sp,sp,-112
    8000501c:	f486                	sd	ra,104(sp)
    8000501e:	f0a2                	sd	s0,96(sp)
    80005020:	eca6                	sd	s1,88(sp)
    80005022:	e8ca                	sd	s2,80(sp)
    80005024:	e4ce                	sd	s3,72(sp)
    80005026:	e0d2                	sd	s4,64(sp)
    80005028:	fc56                	sd	s5,56(sp)
    8000502a:	f85a                	sd	s6,48(sp)
    8000502c:	f45e                	sd	s7,40(sp)
    8000502e:	f062                	sd	s8,32(sp)
    80005030:	ec66                	sd	s9,24(sp)
    80005032:	1880                	addi	s0,sp,112
    80005034:	84aa                	mv	s1,a0
    80005036:	8aae                	mv	s5,a1
    80005038:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000503a:	ffffd097          	auipc	ra,0xffffd
    8000503e:	d86080e7          	jalr	-634(ra) # 80001dc0 <myproc>
    80005042:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005044:	8526                	mv	a0,s1
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	b9e080e7          	jalr	-1122(ra) # 80000be4 <acquire>
  while(i < n){
    8000504e:	0d405163          	blez	s4,80005110 <pipewrite+0xf6>
    80005052:	8ba6                	mv	s7,s1
  int i = 0;
    80005054:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005056:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005058:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000505c:	21c48c13          	addi	s8,s1,540
    80005060:	a08d                	j	800050c2 <pipewrite+0xa8>
      release(&pi->lock);
    80005062:	8526                	mv	a0,s1
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	c34080e7          	jalr	-972(ra) # 80000c98 <release>
      return -1;
    8000506c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000506e:	854a                	mv	a0,s2
    80005070:	70a6                	ld	ra,104(sp)
    80005072:	7406                	ld	s0,96(sp)
    80005074:	64e6                	ld	s1,88(sp)
    80005076:	6946                	ld	s2,80(sp)
    80005078:	69a6                	ld	s3,72(sp)
    8000507a:	6a06                	ld	s4,64(sp)
    8000507c:	7ae2                	ld	s5,56(sp)
    8000507e:	7b42                	ld	s6,48(sp)
    80005080:	7ba2                	ld	s7,40(sp)
    80005082:	7c02                	ld	s8,32(sp)
    80005084:	6ce2                	ld	s9,24(sp)
    80005086:	6165                	addi	sp,sp,112
    80005088:	8082                	ret
      wakeup(&pi->nread);
    8000508a:	8566                	mv	a0,s9
    8000508c:	ffffd097          	auipc	ra,0xffffd
    80005090:	778080e7          	jalr	1912(ra) # 80002804 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005094:	85de                	mv	a1,s7
    80005096:	8562                	mv	a0,s8
    80005098:	ffffd097          	auipc	ra,0xffffd
    8000509c:	5ce080e7          	jalr	1486(ra) # 80002666 <sleep>
    800050a0:	a839                	j	800050be <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050a2:	21c4a783          	lw	a5,540(s1)
    800050a6:	0017871b          	addiw	a4,a5,1
    800050aa:	20e4ae23          	sw	a4,540(s1)
    800050ae:	1ff7f793          	andi	a5,a5,511
    800050b2:	97a6                	add	a5,a5,s1
    800050b4:	f9f44703          	lbu	a4,-97(s0)
    800050b8:	00e78c23          	sb	a4,24(a5)
      i++;
    800050bc:	2905                	addiw	s2,s2,1
  while(i < n){
    800050be:	03495d63          	bge	s2,s4,800050f8 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    800050c2:	2204a783          	lw	a5,544(s1)
    800050c6:	dfd1                	beqz	a5,80005062 <pipewrite+0x48>
    800050c8:	0289a783          	lw	a5,40(s3)
    800050cc:	fbd9                	bnez	a5,80005062 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050ce:	2184a783          	lw	a5,536(s1)
    800050d2:	21c4a703          	lw	a4,540(s1)
    800050d6:	2007879b          	addiw	a5,a5,512
    800050da:	faf708e3          	beq	a4,a5,8000508a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050de:	4685                	li	a3,1
    800050e0:	01590633          	add	a2,s2,s5
    800050e4:	f9f40593          	addi	a1,s0,-97
    800050e8:	0789b503          	ld	a0,120(s3)
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	612080e7          	jalr	1554(ra) # 800016fe <copyin>
    800050f4:	fb6517e3          	bne	a0,s6,800050a2 <pipewrite+0x88>
  wakeup(&pi->nread);
    800050f8:	21848513          	addi	a0,s1,536
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	708080e7          	jalr	1800(ra) # 80002804 <wakeup>
  release(&pi->lock);
    80005104:	8526                	mv	a0,s1
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	b92080e7          	jalr	-1134(ra) # 80000c98 <release>
  return i;
    8000510e:	b785                	j	8000506e <pipewrite+0x54>
  int i = 0;
    80005110:	4901                	li	s2,0
    80005112:	b7dd                	j	800050f8 <pipewrite+0xde>

0000000080005114 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005114:	715d                	addi	sp,sp,-80
    80005116:	e486                	sd	ra,72(sp)
    80005118:	e0a2                	sd	s0,64(sp)
    8000511a:	fc26                	sd	s1,56(sp)
    8000511c:	f84a                	sd	s2,48(sp)
    8000511e:	f44e                	sd	s3,40(sp)
    80005120:	f052                	sd	s4,32(sp)
    80005122:	ec56                	sd	s5,24(sp)
    80005124:	e85a                	sd	s6,16(sp)
    80005126:	0880                	addi	s0,sp,80
    80005128:	84aa                	mv	s1,a0
    8000512a:	892e                	mv	s2,a1
    8000512c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	c92080e7          	jalr	-878(ra) # 80001dc0 <myproc>
    80005136:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005138:	8b26                	mv	s6,s1
    8000513a:	8526                	mv	a0,s1
    8000513c:	ffffc097          	auipc	ra,0xffffc
    80005140:	aa8080e7          	jalr	-1368(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005144:	2184a703          	lw	a4,536(s1)
    80005148:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000514c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005150:	02f71463          	bne	a4,a5,80005178 <piperead+0x64>
    80005154:	2244a783          	lw	a5,548(s1)
    80005158:	c385                	beqz	a5,80005178 <piperead+0x64>
    if(pr->killed){
    8000515a:	028a2783          	lw	a5,40(s4)
    8000515e:	ebc1                	bnez	a5,800051ee <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005160:	85da                	mv	a1,s6
    80005162:	854e                	mv	a0,s3
    80005164:	ffffd097          	auipc	ra,0xffffd
    80005168:	502080e7          	jalr	1282(ra) # 80002666 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000516c:	2184a703          	lw	a4,536(s1)
    80005170:	21c4a783          	lw	a5,540(s1)
    80005174:	fef700e3          	beq	a4,a5,80005154 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005178:	09505263          	blez	s5,800051fc <piperead+0xe8>
    8000517c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000517e:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005180:	2184a783          	lw	a5,536(s1)
    80005184:	21c4a703          	lw	a4,540(s1)
    80005188:	02f70d63          	beq	a4,a5,800051c2 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000518c:	0017871b          	addiw	a4,a5,1
    80005190:	20e4ac23          	sw	a4,536(s1)
    80005194:	1ff7f793          	andi	a5,a5,511
    80005198:	97a6                	add	a5,a5,s1
    8000519a:	0187c783          	lbu	a5,24(a5)
    8000519e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051a2:	4685                	li	a3,1
    800051a4:	fbf40613          	addi	a2,s0,-65
    800051a8:	85ca                	mv	a1,s2
    800051aa:	078a3503          	ld	a0,120(s4)
    800051ae:	ffffc097          	auipc	ra,0xffffc
    800051b2:	4c4080e7          	jalr	1220(ra) # 80001672 <copyout>
    800051b6:	01650663          	beq	a0,s6,800051c2 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051ba:	2985                	addiw	s3,s3,1
    800051bc:	0905                	addi	s2,s2,1
    800051be:	fd3a91e3          	bne	s5,s3,80005180 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051c2:	21c48513          	addi	a0,s1,540
    800051c6:	ffffd097          	auipc	ra,0xffffd
    800051ca:	63e080e7          	jalr	1598(ra) # 80002804 <wakeup>
  release(&pi->lock);
    800051ce:	8526                	mv	a0,s1
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	ac8080e7          	jalr	-1336(ra) # 80000c98 <release>
  return i;
}
    800051d8:	854e                	mv	a0,s3
    800051da:	60a6                	ld	ra,72(sp)
    800051dc:	6406                	ld	s0,64(sp)
    800051de:	74e2                	ld	s1,56(sp)
    800051e0:	7942                	ld	s2,48(sp)
    800051e2:	79a2                	ld	s3,40(sp)
    800051e4:	7a02                	ld	s4,32(sp)
    800051e6:	6ae2                	ld	s5,24(sp)
    800051e8:	6b42                	ld	s6,16(sp)
    800051ea:	6161                	addi	sp,sp,80
    800051ec:	8082                	ret
      release(&pi->lock);
    800051ee:	8526                	mv	a0,s1
    800051f0:	ffffc097          	auipc	ra,0xffffc
    800051f4:	aa8080e7          	jalr	-1368(ra) # 80000c98 <release>
      return -1;
    800051f8:	59fd                	li	s3,-1
    800051fa:	bff9                	j	800051d8 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051fc:	4981                	li	s3,0
    800051fe:	b7d1                	j	800051c2 <piperead+0xae>

0000000080005200 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005200:	df010113          	addi	sp,sp,-528
    80005204:	20113423          	sd	ra,520(sp)
    80005208:	20813023          	sd	s0,512(sp)
    8000520c:	ffa6                	sd	s1,504(sp)
    8000520e:	fbca                	sd	s2,496(sp)
    80005210:	f7ce                	sd	s3,488(sp)
    80005212:	f3d2                	sd	s4,480(sp)
    80005214:	efd6                	sd	s5,472(sp)
    80005216:	ebda                	sd	s6,464(sp)
    80005218:	e7de                	sd	s7,456(sp)
    8000521a:	e3e2                	sd	s8,448(sp)
    8000521c:	ff66                	sd	s9,440(sp)
    8000521e:	fb6a                	sd	s10,432(sp)
    80005220:	f76e                	sd	s11,424(sp)
    80005222:	0c00                	addi	s0,sp,528
    80005224:	84aa                	mv	s1,a0
    80005226:	dea43c23          	sd	a0,-520(s0)
    8000522a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000522e:	ffffd097          	auipc	ra,0xffffd
    80005232:	b92080e7          	jalr	-1134(ra) # 80001dc0 <myproc>
    80005236:	892a                	mv	s2,a0

  begin_op();
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	49c080e7          	jalr	1180(ra) # 800046d4 <begin_op>

  if((ip = namei(path)) == 0){
    80005240:	8526                	mv	a0,s1
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	276080e7          	jalr	630(ra) # 800044b8 <namei>
    8000524a:	c92d                	beqz	a0,800052bc <exec+0xbc>
    8000524c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000524e:	fffff097          	auipc	ra,0xfffff
    80005252:	ab4080e7          	jalr	-1356(ra) # 80003d02 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005256:	04000713          	li	a4,64
    8000525a:	4681                	li	a3,0
    8000525c:	e5040613          	addi	a2,s0,-432
    80005260:	4581                	li	a1,0
    80005262:	8526                	mv	a0,s1
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	d52080e7          	jalr	-686(ra) # 80003fb6 <readi>
    8000526c:	04000793          	li	a5,64
    80005270:	00f51a63          	bne	a0,a5,80005284 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005274:	e5042703          	lw	a4,-432(s0)
    80005278:	464c47b7          	lui	a5,0x464c4
    8000527c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005280:	04f70463          	beq	a4,a5,800052c8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005284:	8526                	mv	a0,s1
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	cde080e7          	jalr	-802(ra) # 80003f64 <iunlockput>
    end_op();
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	4c6080e7          	jalr	1222(ra) # 80004754 <end_op>
  }
  return -1;
    80005296:	557d                	li	a0,-1
}
    80005298:	20813083          	ld	ra,520(sp)
    8000529c:	20013403          	ld	s0,512(sp)
    800052a0:	74fe                	ld	s1,504(sp)
    800052a2:	795e                	ld	s2,496(sp)
    800052a4:	79be                	ld	s3,488(sp)
    800052a6:	7a1e                	ld	s4,480(sp)
    800052a8:	6afe                	ld	s5,472(sp)
    800052aa:	6b5e                	ld	s6,464(sp)
    800052ac:	6bbe                	ld	s7,456(sp)
    800052ae:	6c1e                	ld	s8,448(sp)
    800052b0:	7cfa                	ld	s9,440(sp)
    800052b2:	7d5a                	ld	s10,432(sp)
    800052b4:	7dba                	ld	s11,424(sp)
    800052b6:	21010113          	addi	sp,sp,528
    800052ba:	8082                	ret
    end_op();
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	498080e7          	jalr	1176(ra) # 80004754 <end_op>
    return -1;
    800052c4:	557d                	li	a0,-1
    800052c6:	bfc9                	j	80005298 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800052c8:	854a                	mv	a0,s2
    800052ca:	ffffd097          	auipc	ra,0xffffd
    800052ce:	bb4080e7          	jalr	-1100(ra) # 80001e7e <proc_pagetable>
    800052d2:	8baa                	mv	s7,a0
    800052d4:	d945                	beqz	a0,80005284 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052d6:	e7042983          	lw	s3,-400(s0)
    800052da:	e8845783          	lhu	a5,-376(s0)
    800052de:	c7ad                	beqz	a5,80005348 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052e0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052e2:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    800052e4:	6c85                	lui	s9,0x1
    800052e6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800052ea:	def43823          	sd	a5,-528(s0)
    800052ee:	a42d                	j	80005518 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052f0:	00003517          	auipc	a0,0x3
    800052f4:	44850513          	addi	a0,a0,1096 # 80008738 <syscalls+0x298>
    800052f8:	ffffb097          	auipc	ra,0xffffb
    800052fc:	246080e7          	jalr	582(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005300:	8756                	mv	a4,s5
    80005302:	012d86bb          	addw	a3,s11,s2
    80005306:	4581                	li	a1,0
    80005308:	8526                	mv	a0,s1
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	cac080e7          	jalr	-852(ra) # 80003fb6 <readi>
    80005312:	2501                	sext.w	a0,a0
    80005314:	1aaa9963          	bne	s5,a0,800054c6 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80005318:	6785                	lui	a5,0x1
    8000531a:	0127893b          	addw	s2,a5,s2
    8000531e:	77fd                	lui	a5,0xfffff
    80005320:	01478a3b          	addw	s4,a5,s4
    80005324:	1f897163          	bgeu	s2,s8,80005506 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80005328:	02091593          	slli	a1,s2,0x20
    8000532c:	9181                	srli	a1,a1,0x20
    8000532e:	95ea                	add	a1,a1,s10
    80005330:	855e                	mv	a0,s7
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	d3c080e7          	jalr	-708(ra) # 8000106e <walkaddr>
    8000533a:	862a                	mv	a2,a0
    if(pa == 0)
    8000533c:	d955                	beqz	a0,800052f0 <exec+0xf0>
      n = PGSIZE;
    8000533e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005340:	fd9a70e3          	bgeu	s4,s9,80005300 <exec+0x100>
      n = sz - i;
    80005344:	8ad2                	mv	s5,s4
    80005346:	bf6d                	j	80005300 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005348:	4901                	li	s2,0
  iunlockput(ip);
    8000534a:	8526                	mv	a0,s1
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	c18080e7          	jalr	-1000(ra) # 80003f64 <iunlockput>
  end_op();
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	400080e7          	jalr	1024(ra) # 80004754 <end_op>
  p = myproc();
    8000535c:	ffffd097          	auipc	ra,0xffffd
    80005360:	a64080e7          	jalr	-1436(ra) # 80001dc0 <myproc>
    80005364:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005366:	07053d03          	ld	s10,112(a0)
  sz = PGROUNDUP(sz);
    8000536a:	6785                	lui	a5,0x1
    8000536c:	17fd                	addi	a5,a5,-1
    8000536e:	993e                	add	s2,s2,a5
    80005370:	757d                	lui	a0,0xfffff
    80005372:	00a977b3          	and	a5,s2,a0
    80005376:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000537a:	6609                	lui	a2,0x2
    8000537c:	963e                	add	a2,a2,a5
    8000537e:	85be                	mv	a1,a5
    80005380:	855e                	mv	a0,s7
    80005382:	ffffc097          	auipc	ra,0xffffc
    80005386:	0a0080e7          	jalr	160(ra) # 80001422 <uvmalloc>
    8000538a:	8b2a                	mv	s6,a0
  ip = 0;
    8000538c:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000538e:	12050c63          	beqz	a0,800054c6 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005392:	75f9                	lui	a1,0xffffe
    80005394:	95aa                	add	a1,a1,a0
    80005396:	855e                	mv	a0,s7
    80005398:	ffffc097          	auipc	ra,0xffffc
    8000539c:	2a8080e7          	jalr	680(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    800053a0:	7c7d                	lui	s8,0xfffff
    800053a2:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800053a4:	e0043783          	ld	a5,-512(s0)
    800053a8:	6388                	ld	a0,0(a5)
    800053aa:	c535                	beqz	a0,80005416 <exec+0x216>
    800053ac:	e9040993          	addi	s3,s0,-368
    800053b0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800053b4:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800053b6:	ffffc097          	auipc	ra,0xffffc
    800053ba:	aae080e7          	jalr	-1362(ra) # 80000e64 <strlen>
    800053be:	2505                	addiw	a0,a0,1
    800053c0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053c4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053c8:	13896363          	bltu	s2,s8,800054ee <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053cc:	e0043d83          	ld	s11,-512(s0)
    800053d0:	000dba03          	ld	s4,0(s11)
    800053d4:	8552                	mv	a0,s4
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	a8e080e7          	jalr	-1394(ra) # 80000e64 <strlen>
    800053de:	0015069b          	addiw	a3,a0,1
    800053e2:	8652                	mv	a2,s4
    800053e4:	85ca                	mv	a1,s2
    800053e6:	855e                	mv	a0,s7
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	28a080e7          	jalr	650(ra) # 80001672 <copyout>
    800053f0:	10054363          	bltz	a0,800054f6 <exec+0x2f6>
    ustack[argc] = sp;
    800053f4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053f8:	0485                	addi	s1,s1,1
    800053fa:	008d8793          	addi	a5,s11,8
    800053fe:	e0f43023          	sd	a5,-512(s0)
    80005402:	008db503          	ld	a0,8(s11)
    80005406:	c911                	beqz	a0,8000541a <exec+0x21a>
    if(argc >= MAXARG)
    80005408:	09a1                	addi	s3,s3,8
    8000540a:	fb3c96e3          	bne	s9,s3,800053b6 <exec+0x1b6>
  sz = sz1;
    8000540e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005412:	4481                	li	s1,0
    80005414:	a84d                	j	800054c6 <exec+0x2c6>
  sp = sz;
    80005416:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005418:	4481                	li	s1,0
  ustack[argc] = 0;
    8000541a:	00349793          	slli	a5,s1,0x3
    8000541e:	f9040713          	addi	a4,s0,-112
    80005422:	97ba                	add	a5,a5,a4
    80005424:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005428:	00148693          	addi	a3,s1,1
    8000542c:	068e                	slli	a3,a3,0x3
    8000542e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005432:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005436:	01897663          	bgeu	s2,s8,80005442 <exec+0x242>
  sz = sz1;
    8000543a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000543e:	4481                	li	s1,0
    80005440:	a059                	j	800054c6 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005442:	e9040613          	addi	a2,s0,-368
    80005446:	85ca                	mv	a1,s2
    80005448:	855e                	mv	a0,s7
    8000544a:	ffffc097          	auipc	ra,0xffffc
    8000544e:	228080e7          	jalr	552(ra) # 80001672 <copyout>
    80005452:	0a054663          	bltz	a0,800054fe <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005456:	080ab783          	ld	a5,128(s5)
    8000545a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000545e:	df843783          	ld	a5,-520(s0)
    80005462:	0007c703          	lbu	a4,0(a5)
    80005466:	cf11                	beqz	a4,80005482 <exec+0x282>
    80005468:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000546a:	02f00693          	li	a3,47
    8000546e:	a039                	j	8000547c <exec+0x27c>
      last = s+1;
    80005470:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005474:	0785                	addi	a5,a5,1
    80005476:	fff7c703          	lbu	a4,-1(a5)
    8000547a:	c701                	beqz	a4,80005482 <exec+0x282>
    if(*s == '/')
    8000547c:	fed71ce3          	bne	a4,a3,80005474 <exec+0x274>
    80005480:	bfc5                	j	80005470 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005482:	4641                	li	a2,16
    80005484:	df843583          	ld	a1,-520(s0)
    80005488:	180a8513          	addi	a0,s5,384
    8000548c:	ffffc097          	auipc	ra,0xffffc
    80005490:	9a6080e7          	jalr	-1626(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    80005494:	078ab503          	ld	a0,120(s5)
  p->pagetable = pagetable;
    80005498:	077abc23          	sd	s7,120(s5)
  p->sz = sz;
    8000549c:	076ab823          	sd	s6,112(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054a0:	080ab783          	ld	a5,128(s5)
    800054a4:	e6843703          	ld	a4,-408(s0)
    800054a8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054aa:	080ab783          	ld	a5,128(s5)
    800054ae:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054b2:	85ea                	mv	a1,s10
    800054b4:	ffffd097          	auipc	ra,0xffffd
    800054b8:	a66080e7          	jalr	-1434(ra) # 80001f1a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054bc:	0004851b          	sext.w	a0,s1
    800054c0:	bbe1                	j	80005298 <exec+0x98>
    800054c2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800054c6:	e0843583          	ld	a1,-504(s0)
    800054ca:	855e                	mv	a0,s7
    800054cc:	ffffd097          	auipc	ra,0xffffd
    800054d0:	a4e080e7          	jalr	-1458(ra) # 80001f1a <proc_freepagetable>
  if(ip){
    800054d4:	da0498e3          	bnez	s1,80005284 <exec+0x84>
  return -1;
    800054d8:	557d                	li	a0,-1
    800054da:	bb7d                	j	80005298 <exec+0x98>
    800054dc:	e1243423          	sd	s2,-504(s0)
    800054e0:	b7dd                	j	800054c6 <exec+0x2c6>
    800054e2:	e1243423          	sd	s2,-504(s0)
    800054e6:	b7c5                	j	800054c6 <exec+0x2c6>
    800054e8:	e1243423          	sd	s2,-504(s0)
    800054ec:	bfe9                	j	800054c6 <exec+0x2c6>
  sz = sz1;
    800054ee:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054f2:	4481                	li	s1,0
    800054f4:	bfc9                	j	800054c6 <exec+0x2c6>
  sz = sz1;
    800054f6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054fa:	4481                	li	s1,0
    800054fc:	b7e9                	j	800054c6 <exec+0x2c6>
  sz = sz1;
    800054fe:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005502:	4481                	li	s1,0
    80005504:	b7c9                	j	800054c6 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005506:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000550a:	2b05                	addiw	s6,s6,1
    8000550c:	0389899b          	addiw	s3,s3,56
    80005510:	e8845783          	lhu	a5,-376(s0)
    80005514:	e2fb5be3          	bge	s6,a5,8000534a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005518:	2981                	sext.w	s3,s3
    8000551a:	03800713          	li	a4,56
    8000551e:	86ce                	mv	a3,s3
    80005520:	e1840613          	addi	a2,s0,-488
    80005524:	4581                	li	a1,0
    80005526:	8526                	mv	a0,s1
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	a8e080e7          	jalr	-1394(ra) # 80003fb6 <readi>
    80005530:	03800793          	li	a5,56
    80005534:	f8f517e3          	bne	a0,a5,800054c2 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005538:	e1842783          	lw	a5,-488(s0)
    8000553c:	4705                	li	a4,1
    8000553e:	fce796e3          	bne	a5,a4,8000550a <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005542:	e4043603          	ld	a2,-448(s0)
    80005546:	e3843783          	ld	a5,-456(s0)
    8000554a:	f8f669e3          	bltu	a2,a5,800054dc <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000554e:	e2843783          	ld	a5,-472(s0)
    80005552:	963e                	add	a2,a2,a5
    80005554:	f8f667e3          	bltu	a2,a5,800054e2 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005558:	85ca                	mv	a1,s2
    8000555a:	855e                	mv	a0,s7
    8000555c:	ffffc097          	auipc	ra,0xffffc
    80005560:	ec6080e7          	jalr	-314(ra) # 80001422 <uvmalloc>
    80005564:	e0a43423          	sd	a0,-504(s0)
    80005568:	d141                	beqz	a0,800054e8 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    8000556a:	e2843d03          	ld	s10,-472(s0)
    8000556e:	df043783          	ld	a5,-528(s0)
    80005572:	00fd77b3          	and	a5,s10,a5
    80005576:	fba1                	bnez	a5,800054c6 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005578:	e2042d83          	lw	s11,-480(s0)
    8000557c:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005580:	f80c03e3          	beqz	s8,80005506 <exec+0x306>
    80005584:	8a62                	mv	s4,s8
    80005586:	4901                	li	s2,0
    80005588:	b345                	j	80005328 <exec+0x128>

000000008000558a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000558a:	7179                	addi	sp,sp,-48
    8000558c:	f406                	sd	ra,40(sp)
    8000558e:	f022                	sd	s0,32(sp)
    80005590:	ec26                	sd	s1,24(sp)
    80005592:	e84a                	sd	s2,16(sp)
    80005594:	1800                	addi	s0,sp,48
    80005596:	892e                	mv	s2,a1
    80005598:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000559a:	fdc40593          	addi	a1,s0,-36
    8000559e:	ffffe097          	auipc	ra,0xffffe
    800055a2:	b76080e7          	jalr	-1162(ra) # 80003114 <argint>
    800055a6:	04054063          	bltz	a0,800055e6 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055aa:	fdc42703          	lw	a4,-36(s0)
    800055ae:	47bd                	li	a5,15
    800055b0:	02e7ed63          	bltu	a5,a4,800055ea <argfd+0x60>
    800055b4:	ffffd097          	auipc	ra,0xffffd
    800055b8:	80c080e7          	jalr	-2036(ra) # 80001dc0 <myproc>
    800055bc:	fdc42703          	lw	a4,-36(s0)
    800055c0:	01e70793          	addi	a5,a4,30
    800055c4:	078e                	slli	a5,a5,0x3
    800055c6:	953e                	add	a0,a0,a5
    800055c8:	651c                	ld	a5,8(a0)
    800055ca:	c395                	beqz	a5,800055ee <argfd+0x64>
    return -1;
  if(pfd)
    800055cc:	00090463          	beqz	s2,800055d4 <argfd+0x4a>
    *pfd = fd;
    800055d0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055d4:	4501                	li	a0,0
  if(pf)
    800055d6:	c091                	beqz	s1,800055da <argfd+0x50>
    *pf = f;
    800055d8:	e09c                	sd	a5,0(s1)
}
    800055da:	70a2                	ld	ra,40(sp)
    800055dc:	7402                	ld	s0,32(sp)
    800055de:	64e2                	ld	s1,24(sp)
    800055e0:	6942                	ld	s2,16(sp)
    800055e2:	6145                	addi	sp,sp,48
    800055e4:	8082                	ret
    return -1;
    800055e6:	557d                	li	a0,-1
    800055e8:	bfcd                	j	800055da <argfd+0x50>
    return -1;
    800055ea:	557d                	li	a0,-1
    800055ec:	b7fd                	j	800055da <argfd+0x50>
    800055ee:	557d                	li	a0,-1
    800055f0:	b7ed                	j	800055da <argfd+0x50>

00000000800055f2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055f2:	1101                	addi	sp,sp,-32
    800055f4:	ec06                	sd	ra,24(sp)
    800055f6:	e822                	sd	s0,16(sp)
    800055f8:	e426                	sd	s1,8(sp)
    800055fa:	1000                	addi	s0,sp,32
    800055fc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055fe:	ffffc097          	auipc	ra,0xffffc
    80005602:	7c2080e7          	jalr	1986(ra) # 80001dc0 <myproc>
    80005606:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005608:	0f850793          	addi	a5,a0,248 # fffffffffffff0f8 <end+0xffffffff7ffd90f8>
    8000560c:	4501                	li	a0,0
    8000560e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005610:	6398                	ld	a4,0(a5)
    80005612:	cb19                	beqz	a4,80005628 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005614:	2505                	addiw	a0,a0,1
    80005616:	07a1                	addi	a5,a5,8
    80005618:	fed51ce3          	bne	a0,a3,80005610 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000561c:	557d                	li	a0,-1
}
    8000561e:	60e2                	ld	ra,24(sp)
    80005620:	6442                	ld	s0,16(sp)
    80005622:	64a2                	ld	s1,8(sp)
    80005624:	6105                	addi	sp,sp,32
    80005626:	8082                	ret
      p->ofile[fd] = f;
    80005628:	01e50793          	addi	a5,a0,30
    8000562c:	078e                	slli	a5,a5,0x3
    8000562e:	963e                	add	a2,a2,a5
    80005630:	e604                	sd	s1,8(a2)
      return fd;
    80005632:	b7f5                	j	8000561e <fdalloc+0x2c>

0000000080005634 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005634:	715d                	addi	sp,sp,-80
    80005636:	e486                	sd	ra,72(sp)
    80005638:	e0a2                	sd	s0,64(sp)
    8000563a:	fc26                	sd	s1,56(sp)
    8000563c:	f84a                	sd	s2,48(sp)
    8000563e:	f44e                	sd	s3,40(sp)
    80005640:	f052                	sd	s4,32(sp)
    80005642:	ec56                	sd	s5,24(sp)
    80005644:	0880                	addi	s0,sp,80
    80005646:	89ae                	mv	s3,a1
    80005648:	8ab2                	mv	s5,a2
    8000564a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000564c:	fb040593          	addi	a1,s0,-80
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	e86080e7          	jalr	-378(ra) # 800044d6 <nameiparent>
    80005658:	892a                	mv	s2,a0
    8000565a:	12050f63          	beqz	a0,80005798 <create+0x164>
    return 0;

  ilock(dp);
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	6a4080e7          	jalr	1700(ra) # 80003d02 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005666:	4601                	li	a2,0
    80005668:	fb040593          	addi	a1,s0,-80
    8000566c:	854a                	mv	a0,s2
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	b78080e7          	jalr	-1160(ra) # 800041e6 <dirlookup>
    80005676:	84aa                	mv	s1,a0
    80005678:	c921                	beqz	a0,800056c8 <create+0x94>
    iunlockput(dp);
    8000567a:	854a                	mv	a0,s2
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	8e8080e7          	jalr	-1816(ra) # 80003f64 <iunlockput>
    ilock(ip);
    80005684:	8526                	mv	a0,s1
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	67c080e7          	jalr	1660(ra) # 80003d02 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000568e:	2981                	sext.w	s3,s3
    80005690:	4789                	li	a5,2
    80005692:	02f99463          	bne	s3,a5,800056ba <create+0x86>
    80005696:	0444d783          	lhu	a5,68(s1)
    8000569a:	37f9                	addiw	a5,a5,-2
    8000569c:	17c2                	slli	a5,a5,0x30
    8000569e:	93c1                	srli	a5,a5,0x30
    800056a0:	4705                	li	a4,1
    800056a2:	00f76c63          	bltu	a4,a5,800056ba <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800056a6:	8526                	mv	a0,s1
    800056a8:	60a6                	ld	ra,72(sp)
    800056aa:	6406                	ld	s0,64(sp)
    800056ac:	74e2                	ld	s1,56(sp)
    800056ae:	7942                	ld	s2,48(sp)
    800056b0:	79a2                	ld	s3,40(sp)
    800056b2:	7a02                	ld	s4,32(sp)
    800056b4:	6ae2                	ld	s5,24(sp)
    800056b6:	6161                	addi	sp,sp,80
    800056b8:	8082                	ret
    iunlockput(ip);
    800056ba:	8526                	mv	a0,s1
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	8a8080e7          	jalr	-1880(ra) # 80003f64 <iunlockput>
    return 0;
    800056c4:	4481                	li	s1,0
    800056c6:	b7c5                	j	800056a6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800056c8:	85ce                	mv	a1,s3
    800056ca:	00092503          	lw	a0,0(s2)
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	49c080e7          	jalr	1180(ra) # 80003b6a <ialloc>
    800056d6:	84aa                	mv	s1,a0
    800056d8:	c529                	beqz	a0,80005722 <create+0xee>
  ilock(ip);
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	628080e7          	jalr	1576(ra) # 80003d02 <ilock>
  ip->major = major;
    800056e2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800056e6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800056ea:	4785                	li	a5,1
    800056ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056f0:	8526                	mv	a0,s1
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	546080e7          	jalr	1350(ra) # 80003c38 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056fa:	2981                	sext.w	s3,s3
    800056fc:	4785                	li	a5,1
    800056fe:	02f98a63          	beq	s3,a5,80005732 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005702:	40d0                	lw	a2,4(s1)
    80005704:	fb040593          	addi	a1,s0,-80
    80005708:	854a                	mv	a0,s2
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	cec080e7          	jalr	-788(ra) # 800043f6 <dirlink>
    80005712:	06054b63          	bltz	a0,80005788 <create+0x154>
  iunlockput(dp);
    80005716:	854a                	mv	a0,s2
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	84c080e7          	jalr	-1972(ra) # 80003f64 <iunlockput>
  return ip;
    80005720:	b759                	j	800056a6 <create+0x72>
    panic("create: ialloc");
    80005722:	00003517          	auipc	a0,0x3
    80005726:	03650513          	addi	a0,a0,54 # 80008758 <syscalls+0x2b8>
    8000572a:	ffffb097          	auipc	ra,0xffffb
    8000572e:	e14080e7          	jalr	-492(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    80005732:	04a95783          	lhu	a5,74(s2)
    80005736:	2785                	addiw	a5,a5,1
    80005738:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000573c:	854a                	mv	a0,s2
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	4fa080e7          	jalr	1274(ra) # 80003c38 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005746:	40d0                	lw	a2,4(s1)
    80005748:	00003597          	auipc	a1,0x3
    8000574c:	02058593          	addi	a1,a1,32 # 80008768 <syscalls+0x2c8>
    80005750:	8526                	mv	a0,s1
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	ca4080e7          	jalr	-860(ra) # 800043f6 <dirlink>
    8000575a:	00054f63          	bltz	a0,80005778 <create+0x144>
    8000575e:	00492603          	lw	a2,4(s2)
    80005762:	00003597          	auipc	a1,0x3
    80005766:	00e58593          	addi	a1,a1,14 # 80008770 <syscalls+0x2d0>
    8000576a:	8526                	mv	a0,s1
    8000576c:	fffff097          	auipc	ra,0xfffff
    80005770:	c8a080e7          	jalr	-886(ra) # 800043f6 <dirlink>
    80005774:	f80557e3          	bgez	a0,80005702 <create+0xce>
      panic("create dots");
    80005778:	00003517          	auipc	a0,0x3
    8000577c:	00050513          	mv	a0,a0
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	dbe080e7          	jalr	-578(ra) # 8000053e <panic>
    panic("create: dirlink");
    80005788:	00003517          	auipc	a0,0x3
    8000578c:	00050513          	mv	a0,a0
    80005790:	ffffb097          	auipc	ra,0xffffb
    80005794:	dae080e7          	jalr	-594(ra) # 8000053e <panic>
    return 0;
    80005798:	84aa                	mv	s1,a0
    8000579a:	b731                	j	800056a6 <create+0x72>

000000008000579c <sys_dup>:
{
    8000579c:	7179                	addi	sp,sp,-48
    8000579e:	f406                	sd	ra,40(sp)
    800057a0:	f022                	sd	s0,32(sp)
    800057a2:	ec26                	sd	s1,24(sp)
    800057a4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057a6:	fd840613          	addi	a2,s0,-40
    800057aa:	4581                	li	a1,0
    800057ac:	4501                	li	a0,0
    800057ae:	00000097          	auipc	ra,0x0
    800057b2:	ddc080e7          	jalr	-548(ra) # 8000558a <argfd>
    return -1;
    800057b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057b8:	02054363          	bltz	a0,800057de <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057bc:	fd843503          	ld	a0,-40(s0)
    800057c0:	00000097          	auipc	ra,0x0
    800057c4:	e32080e7          	jalr	-462(ra) # 800055f2 <fdalloc>
    800057c8:	84aa                	mv	s1,a0
    return -1;
    800057ca:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057cc:	00054963          	bltz	a0,800057de <sys_dup+0x42>
  filedup(f);
    800057d0:	fd843503          	ld	a0,-40(s0)
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	37a080e7          	jalr	890(ra) # 80004b4e <filedup>
  return fd;
    800057dc:	87a6                	mv	a5,s1
}
    800057de:	853e                	mv	a0,a5
    800057e0:	70a2                	ld	ra,40(sp)
    800057e2:	7402                	ld	s0,32(sp)
    800057e4:	64e2                	ld	s1,24(sp)
    800057e6:	6145                	addi	sp,sp,48
    800057e8:	8082                	ret

00000000800057ea <sys_read>:
{
    800057ea:	7179                	addi	sp,sp,-48
    800057ec:	f406                	sd	ra,40(sp)
    800057ee:	f022                	sd	s0,32(sp)
    800057f0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057f2:	fe840613          	addi	a2,s0,-24
    800057f6:	4581                	li	a1,0
    800057f8:	4501                	li	a0,0
    800057fa:	00000097          	auipc	ra,0x0
    800057fe:	d90080e7          	jalr	-624(ra) # 8000558a <argfd>
    return -1;
    80005802:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005804:	04054163          	bltz	a0,80005846 <sys_read+0x5c>
    80005808:	fe440593          	addi	a1,s0,-28
    8000580c:	4509                	li	a0,2
    8000580e:	ffffe097          	auipc	ra,0xffffe
    80005812:	906080e7          	jalr	-1786(ra) # 80003114 <argint>
    return -1;
    80005816:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005818:	02054763          	bltz	a0,80005846 <sys_read+0x5c>
    8000581c:	fd840593          	addi	a1,s0,-40
    80005820:	4505                	li	a0,1
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	914080e7          	jalr	-1772(ra) # 80003136 <argaddr>
    return -1;
    8000582a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000582c:	00054d63          	bltz	a0,80005846 <sys_read+0x5c>
  return fileread(f, p, n);
    80005830:	fe442603          	lw	a2,-28(s0)
    80005834:	fd843583          	ld	a1,-40(s0)
    80005838:	fe843503          	ld	a0,-24(s0)
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	49e080e7          	jalr	1182(ra) # 80004cda <fileread>
    80005844:	87aa                	mv	a5,a0
}
    80005846:	853e                	mv	a0,a5
    80005848:	70a2                	ld	ra,40(sp)
    8000584a:	7402                	ld	s0,32(sp)
    8000584c:	6145                	addi	sp,sp,48
    8000584e:	8082                	ret

0000000080005850 <sys_write>:
{
    80005850:	7179                	addi	sp,sp,-48
    80005852:	f406                	sd	ra,40(sp)
    80005854:	f022                	sd	s0,32(sp)
    80005856:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005858:	fe840613          	addi	a2,s0,-24
    8000585c:	4581                	li	a1,0
    8000585e:	4501                	li	a0,0
    80005860:	00000097          	auipc	ra,0x0
    80005864:	d2a080e7          	jalr	-726(ra) # 8000558a <argfd>
    return -1;
    80005868:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000586a:	04054163          	bltz	a0,800058ac <sys_write+0x5c>
    8000586e:	fe440593          	addi	a1,s0,-28
    80005872:	4509                	li	a0,2
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	8a0080e7          	jalr	-1888(ra) # 80003114 <argint>
    return -1;
    8000587c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000587e:	02054763          	bltz	a0,800058ac <sys_write+0x5c>
    80005882:	fd840593          	addi	a1,s0,-40
    80005886:	4505                	li	a0,1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	8ae080e7          	jalr	-1874(ra) # 80003136 <argaddr>
    return -1;
    80005890:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005892:	00054d63          	bltz	a0,800058ac <sys_write+0x5c>
  return filewrite(f, p, n);
    80005896:	fe442603          	lw	a2,-28(s0)
    8000589a:	fd843583          	ld	a1,-40(s0)
    8000589e:	fe843503          	ld	a0,-24(s0)
    800058a2:	fffff097          	auipc	ra,0xfffff
    800058a6:	4fa080e7          	jalr	1274(ra) # 80004d9c <filewrite>
    800058aa:	87aa                	mv	a5,a0
}
    800058ac:	853e                	mv	a0,a5
    800058ae:	70a2                	ld	ra,40(sp)
    800058b0:	7402                	ld	s0,32(sp)
    800058b2:	6145                	addi	sp,sp,48
    800058b4:	8082                	ret

00000000800058b6 <sys_close>:
{
    800058b6:	1101                	addi	sp,sp,-32
    800058b8:	ec06                	sd	ra,24(sp)
    800058ba:	e822                	sd	s0,16(sp)
    800058bc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058be:	fe040613          	addi	a2,s0,-32
    800058c2:	fec40593          	addi	a1,s0,-20
    800058c6:	4501                	li	a0,0
    800058c8:	00000097          	auipc	ra,0x0
    800058cc:	cc2080e7          	jalr	-830(ra) # 8000558a <argfd>
    return -1;
    800058d0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058d2:	02054463          	bltz	a0,800058fa <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058d6:	ffffc097          	auipc	ra,0xffffc
    800058da:	4ea080e7          	jalr	1258(ra) # 80001dc0 <myproc>
    800058de:	fec42783          	lw	a5,-20(s0)
    800058e2:	07f9                	addi	a5,a5,30
    800058e4:	078e                	slli	a5,a5,0x3
    800058e6:	97aa                	add	a5,a5,a0
    800058e8:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800058ec:	fe043503          	ld	a0,-32(s0)
    800058f0:	fffff097          	auipc	ra,0xfffff
    800058f4:	2b0080e7          	jalr	688(ra) # 80004ba0 <fileclose>
  return 0;
    800058f8:	4781                	li	a5,0
}
    800058fa:	853e                	mv	a0,a5
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	6105                	addi	sp,sp,32
    80005902:	8082                	ret

0000000080005904 <sys_fstat>:
{
    80005904:	1101                	addi	sp,sp,-32
    80005906:	ec06                	sd	ra,24(sp)
    80005908:	e822                	sd	s0,16(sp)
    8000590a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000590c:	fe840613          	addi	a2,s0,-24
    80005910:	4581                	li	a1,0
    80005912:	4501                	li	a0,0
    80005914:	00000097          	auipc	ra,0x0
    80005918:	c76080e7          	jalr	-906(ra) # 8000558a <argfd>
    return -1;
    8000591c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000591e:	02054563          	bltz	a0,80005948 <sys_fstat+0x44>
    80005922:	fe040593          	addi	a1,s0,-32
    80005926:	4505                	li	a0,1
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	80e080e7          	jalr	-2034(ra) # 80003136 <argaddr>
    return -1;
    80005930:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005932:	00054b63          	bltz	a0,80005948 <sys_fstat+0x44>
  return filestat(f, st);
    80005936:	fe043583          	ld	a1,-32(s0)
    8000593a:	fe843503          	ld	a0,-24(s0)
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	32a080e7          	jalr	810(ra) # 80004c68 <filestat>
    80005946:	87aa                	mv	a5,a0
}
    80005948:	853e                	mv	a0,a5
    8000594a:	60e2                	ld	ra,24(sp)
    8000594c:	6442                	ld	s0,16(sp)
    8000594e:	6105                	addi	sp,sp,32
    80005950:	8082                	ret

0000000080005952 <sys_link>:
{
    80005952:	7169                	addi	sp,sp,-304
    80005954:	f606                	sd	ra,296(sp)
    80005956:	f222                	sd	s0,288(sp)
    80005958:	ee26                	sd	s1,280(sp)
    8000595a:	ea4a                	sd	s2,272(sp)
    8000595c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000595e:	08000613          	li	a2,128
    80005962:	ed040593          	addi	a1,s0,-304
    80005966:	4501                	li	a0,0
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	7f0080e7          	jalr	2032(ra) # 80003158 <argstr>
    return -1;
    80005970:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005972:	10054e63          	bltz	a0,80005a8e <sys_link+0x13c>
    80005976:	08000613          	li	a2,128
    8000597a:	f5040593          	addi	a1,s0,-176
    8000597e:	4505                	li	a0,1
    80005980:	ffffd097          	auipc	ra,0xffffd
    80005984:	7d8080e7          	jalr	2008(ra) # 80003158 <argstr>
    return -1;
    80005988:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000598a:	10054263          	bltz	a0,80005a8e <sys_link+0x13c>
  begin_op();
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	d46080e7          	jalr	-698(ra) # 800046d4 <begin_op>
  if((ip = namei(old)) == 0){
    80005996:	ed040513          	addi	a0,s0,-304
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	b1e080e7          	jalr	-1250(ra) # 800044b8 <namei>
    800059a2:	84aa                	mv	s1,a0
    800059a4:	c551                	beqz	a0,80005a30 <sys_link+0xde>
  ilock(ip);
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	35c080e7          	jalr	860(ra) # 80003d02 <ilock>
  if(ip->type == T_DIR){
    800059ae:	04449703          	lh	a4,68(s1)
    800059b2:	4785                	li	a5,1
    800059b4:	08f70463          	beq	a4,a5,80005a3c <sys_link+0xea>
  ip->nlink++;
    800059b8:	04a4d783          	lhu	a5,74(s1)
    800059bc:	2785                	addiw	a5,a5,1
    800059be:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059c2:	8526                	mv	a0,s1
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	274080e7          	jalr	628(ra) # 80003c38 <iupdate>
  iunlock(ip);
    800059cc:	8526                	mv	a0,s1
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	3f6080e7          	jalr	1014(ra) # 80003dc4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059d6:	fd040593          	addi	a1,s0,-48
    800059da:	f5040513          	addi	a0,s0,-176
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	af8080e7          	jalr	-1288(ra) # 800044d6 <nameiparent>
    800059e6:	892a                	mv	s2,a0
    800059e8:	c935                	beqz	a0,80005a5c <sys_link+0x10a>
  ilock(dp);
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	318080e7          	jalr	792(ra) # 80003d02 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059f2:	00092703          	lw	a4,0(s2)
    800059f6:	409c                	lw	a5,0(s1)
    800059f8:	04f71d63          	bne	a4,a5,80005a52 <sys_link+0x100>
    800059fc:	40d0                	lw	a2,4(s1)
    800059fe:	fd040593          	addi	a1,s0,-48
    80005a02:	854a                	mv	a0,s2
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	9f2080e7          	jalr	-1550(ra) # 800043f6 <dirlink>
    80005a0c:	04054363          	bltz	a0,80005a52 <sys_link+0x100>
  iunlockput(dp);
    80005a10:	854a                	mv	a0,s2
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	552080e7          	jalr	1362(ra) # 80003f64 <iunlockput>
  iput(ip);
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	4a0080e7          	jalr	1184(ra) # 80003ebc <iput>
  end_op();
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	d30080e7          	jalr	-720(ra) # 80004754 <end_op>
  return 0;
    80005a2c:	4781                	li	a5,0
    80005a2e:	a085                	j	80005a8e <sys_link+0x13c>
    end_op();
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	d24080e7          	jalr	-732(ra) # 80004754 <end_op>
    return -1;
    80005a38:	57fd                	li	a5,-1
    80005a3a:	a891                	j	80005a8e <sys_link+0x13c>
    iunlockput(ip);
    80005a3c:	8526                	mv	a0,s1
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	526080e7          	jalr	1318(ra) # 80003f64 <iunlockput>
    end_op();
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	d0e080e7          	jalr	-754(ra) # 80004754 <end_op>
    return -1;
    80005a4e:	57fd                	li	a5,-1
    80005a50:	a83d                	j	80005a8e <sys_link+0x13c>
    iunlockput(dp);
    80005a52:	854a                	mv	a0,s2
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	510080e7          	jalr	1296(ra) # 80003f64 <iunlockput>
  ilock(ip);
    80005a5c:	8526                	mv	a0,s1
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	2a4080e7          	jalr	676(ra) # 80003d02 <ilock>
  ip->nlink--;
    80005a66:	04a4d783          	lhu	a5,74(s1)
    80005a6a:	37fd                	addiw	a5,a5,-1
    80005a6c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a70:	8526                	mv	a0,s1
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	1c6080e7          	jalr	454(ra) # 80003c38 <iupdate>
  iunlockput(ip);
    80005a7a:	8526                	mv	a0,s1
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	4e8080e7          	jalr	1256(ra) # 80003f64 <iunlockput>
  end_op();
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	cd0080e7          	jalr	-816(ra) # 80004754 <end_op>
  return -1;
    80005a8c:	57fd                	li	a5,-1
}
    80005a8e:	853e                	mv	a0,a5
    80005a90:	70b2                	ld	ra,296(sp)
    80005a92:	7412                	ld	s0,288(sp)
    80005a94:	64f2                	ld	s1,280(sp)
    80005a96:	6952                	ld	s2,272(sp)
    80005a98:	6155                	addi	sp,sp,304
    80005a9a:	8082                	ret

0000000080005a9c <sys_unlink>:
{
    80005a9c:	7151                	addi	sp,sp,-240
    80005a9e:	f586                	sd	ra,232(sp)
    80005aa0:	f1a2                	sd	s0,224(sp)
    80005aa2:	eda6                	sd	s1,216(sp)
    80005aa4:	e9ca                	sd	s2,208(sp)
    80005aa6:	e5ce                	sd	s3,200(sp)
    80005aa8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005aaa:	08000613          	li	a2,128
    80005aae:	f3040593          	addi	a1,s0,-208
    80005ab2:	4501                	li	a0,0
    80005ab4:	ffffd097          	auipc	ra,0xffffd
    80005ab8:	6a4080e7          	jalr	1700(ra) # 80003158 <argstr>
    80005abc:	18054163          	bltz	a0,80005c3e <sys_unlink+0x1a2>
  begin_op();
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	c14080e7          	jalr	-1004(ra) # 800046d4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ac8:	fb040593          	addi	a1,s0,-80
    80005acc:	f3040513          	addi	a0,s0,-208
    80005ad0:	fffff097          	auipc	ra,0xfffff
    80005ad4:	a06080e7          	jalr	-1530(ra) # 800044d6 <nameiparent>
    80005ad8:	84aa                	mv	s1,a0
    80005ada:	c979                	beqz	a0,80005bb0 <sys_unlink+0x114>
  ilock(dp);
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	226080e7          	jalr	550(ra) # 80003d02 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ae4:	00003597          	auipc	a1,0x3
    80005ae8:	c8458593          	addi	a1,a1,-892 # 80008768 <syscalls+0x2c8>
    80005aec:	fb040513          	addi	a0,s0,-80
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	6dc080e7          	jalr	1756(ra) # 800041cc <namecmp>
    80005af8:	14050a63          	beqz	a0,80005c4c <sys_unlink+0x1b0>
    80005afc:	00003597          	auipc	a1,0x3
    80005b00:	c7458593          	addi	a1,a1,-908 # 80008770 <syscalls+0x2d0>
    80005b04:	fb040513          	addi	a0,s0,-80
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	6c4080e7          	jalr	1732(ra) # 800041cc <namecmp>
    80005b10:	12050e63          	beqz	a0,80005c4c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b14:	f2c40613          	addi	a2,s0,-212
    80005b18:	fb040593          	addi	a1,s0,-80
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	6c8080e7          	jalr	1736(ra) # 800041e6 <dirlookup>
    80005b26:	892a                	mv	s2,a0
    80005b28:	12050263          	beqz	a0,80005c4c <sys_unlink+0x1b0>
  ilock(ip);
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	1d6080e7          	jalr	470(ra) # 80003d02 <ilock>
  if(ip->nlink < 1)
    80005b34:	04a91783          	lh	a5,74(s2)
    80005b38:	08f05263          	blez	a5,80005bbc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b3c:	04491703          	lh	a4,68(s2)
    80005b40:	4785                	li	a5,1
    80005b42:	08f70563          	beq	a4,a5,80005bcc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b46:	4641                	li	a2,16
    80005b48:	4581                	li	a1,0
    80005b4a:	fc040513          	addi	a0,s0,-64
    80005b4e:	ffffb097          	auipc	ra,0xffffb
    80005b52:	192080e7          	jalr	402(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b56:	4741                	li	a4,16
    80005b58:	f2c42683          	lw	a3,-212(s0)
    80005b5c:	fc040613          	addi	a2,s0,-64
    80005b60:	4581                	li	a1,0
    80005b62:	8526                	mv	a0,s1
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	54a080e7          	jalr	1354(ra) # 800040ae <writei>
    80005b6c:	47c1                	li	a5,16
    80005b6e:	0af51563          	bne	a0,a5,80005c18 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b72:	04491703          	lh	a4,68(s2)
    80005b76:	4785                	li	a5,1
    80005b78:	0af70863          	beq	a4,a5,80005c28 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b7c:	8526                	mv	a0,s1
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	3e6080e7          	jalr	998(ra) # 80003f64 <iunlockput>
  ip->nlink--;
    80005b86:	04a95783          	lhu	a5,74(s2)
    80005b8a:	37fd                	addiw	a5,a5,-1
    80005b8c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b90:	854a                	mv	a0,s2
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	0a6080e7          	jalr	166(ra) # 80003c38 <iupdate>
  iunlockput(ip);
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	3c8080e7          	jalr	968(ra) # 80003f64 <iunlockput>
  end_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	bb0080e7          	jalr	-1104(ra) # 80004754 <end_op>
  return 0;
    80005bac:	4501                	li	a0,0
    80005bae:	a84d                	j	80005c60 <sys_unlink+0x1c4>
    end_op();
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	ba4080e7          	jalr	-1116(ra) # 80004754 <end_op>
    return -1;
    80005bb8:	557d                	li	a0,-1
    80005bba:	a05d                	j	80005c60 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005bbc:	00003517          	auipc	a0,0x3
    80005bc0:	bdc50513          	addi	a0,a0,-1060 # 80008798 <syscalls+0x2f8>
    80005bc4:	ffffb097          	auipc	ra,0xffffb
    80005bc8:	97a080e7          	jalr	-1670(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bcc:	04c92703          	lw	a4,76(s2)
    80005bd0:	02000793          	li	a5,32
    80005bd4:	f6e7f9e3          	bgeu	a5,a4,80005b46 <sys_unlink+0xaa>
    80005bd8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bdc:	4741                	li	a4,16
    80005bde:	86ce                	mv	a3,s3
    80005be0:	f1840613          	addi	a2,s0,-232
    80005be4:	4581                	li	a1,0
    80005be6:	854a                	mv	a0,s2
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	3ce080e7          	jalr	974(ra) # 80003fb6 <readi>
    80005bf0:	47c1                	li	a5,16
    80005bf2:	00f51b63          	bne	a0,a5,80005c08 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bf6:	f1845783          	lhu	a5,-232(s0)
    80005bfa:	e7a1                	bnez	a5,80005c42 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bfc:	29c1                	addiw	s3,s3,16
    80005bfe:	04c92783          	lw	a5,76(s2)
    80005c02:	fcf9ede3          	bltu	s3,a5,80005bdc <sys_unlink+0x140>
    80005c06:	b781                	j	80005b46 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c08:	00003517          	auipc	a0,0x3
    80005c0c:	ba850513          	addi	a0,a0,-1112 # 800087b0 <syscalls+0x310>
    80005c10:	ffffb097          	auipc	ra,0xffffb
    80005c14:	92e080e7          	jalr	-1746(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005c18:	00003517          	auipc	a0,0x3
    80005c1c:	bb050513          	addi	a0,a0,-1104 # 800087c8 <syscalls+0x328>
    80005c20:	ffffb097          	auipc	ra,0xffffb
    80005c24:	91e080e7          	jalr	-1762(ra) # 8000053e <panic>
    dp->nlink--;
    80005c28:	04a4d783          	lhu	a5,74(s1)
    80005c2c:	37fd                	addiw	a5,a5,-1
    80005c2e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c32:	8526                	mv	a0,s1
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	004080e7          	jalr	4(ra) # 80003c38 <iupdate>
    80005c3c:	b781                	j	80005b7c <sys_unlink+0xe0>
    return -1;
    80005c3e:	557d                	li	a0,-1
    80005c40:	a005                	j	80005c60 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c42:	854a                	mv	a0,s2
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	320080e7          	jalr	800(ra) # 80003f64 <iunlockput>
  iunlockput(dp);
    80005c4c:	8526                	mv	a0,s1
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	316080e7          	jalr	790(ra) # 80003f64 <iunlockput>
  end_op();
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	afe080e7          	jalr	-1282(ra) # 80004754 <end_op>
  return -1;
    80005c5e:	557d                	li	a0,-1
}
    80005c60:	70ae                	ld	ra,232(sp)
    80005c62:	740e                	ld	s0,224(sp)
    80005c64:	64ee                	ld	s1,216(sp)
    80005c66:	694e                	ld	s2,208(sp)
    80005c68:	69ae                	ld	s3,200(sp)
    80005c6a:	616d                	addi	sp,sp,240
    80005c6c:	8082                	ret

0000000080005c6e <sys_open>:

uint64
sys_open(void)
{
    80005c6e:	7131                	addi	sp,sp,-192
    80005c70:	fd06                	sd	ra,184(sp)
    80005c72:	f922                	sd	s0,176(sp)
    80005c74:	f526                	sd	s1,168(sp)
    80005c76:	f14a                	sd	s2,160(sp)
    80005c78:	ed4e                	sd	s3,152(sp)
    80005c7a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c7c:	08000613          	li	a2,128
    80005c80:	f5040593          	addi	a1,s0,-176
    80005c84:	4501                	li	a0,0
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	4d2080e7          	jalr	1234(ra) # 80003158 <argstr>
    return -1;
    80005c8e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c90:	0c054163          	bltz	a0,80005d52 <sys_open+0xe4>
    80005c94:	f4c40593          	addi	a1,s0,-180
    80005c98:	4505                	li	a0,1
    80005c9a:	ffffd097          	auipc	ra,0xffffd
    80005c9e:	47a080e7          	jalr	1146(ra) # 80003114 <argint>
    80005ca2:	0a054863          	bltz	a0,80005d52 <sys_open+0xe4>

  begin_op();
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	a2e080e7          	jalr	-1490(ra) # 800046d4 <begin_op>

  if(omode & O_CREATE){
    80005cae:	f4c42783          	lw	a5,-180(s0)
    80005cb2:	2007f793          	andi	a5,a5,512
    80005cb6:	cbdd                	beqz	a5,80005d6c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cb8:	4681                	li	a3,0
    80005cba:	4601                	li	a2,0
    80005cbc:	4589                	li	a1,2
    80005cbe:	f5040513          	addi	a0,s0,-176
    80005cc2:	00000097          	auipc	ra,0x0
    80005cc6:	972080e7          	jalr	-1678(ra) # 80005634 <create>
    80005cca:	892a                	mv	s2,a0
    if(ip == 0){
    80005ccc:	c959                	beqz	a0,80005d62 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cce:	04491703          	lh	a4,68(s2)
    80005cd2:	478d                	li	a5,3
    80005cd4:	00f71763          	bne	a4,a5,80005ce2 <sys_open+0x74>
    80005cd8:	04695703          	lhu	a4,70(s2)
    80005cdc:	47a5                	li	a5,9
    80005cde:	0ce7ec63          	bltu	a5,a4,80005db6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ce2:	fffff097          	auipc	ra,0xfffff
    80005ce6:	e02080e7          	jalr	-510(ra) # 80004ae4 <filealloc>
    80005cea:	89aa                	mv	s3,a0
    80005cec:	10050263          	beqz	a0,80005df0 <sys_open+0x182>
    80005cf0:	00000097          	auipc	ra,0x0
    80005cf4:	902080e7          	jalr	-1790(ra) # 800055f2 <fdalloc>
    80005cf8:	84aa                	mv	s1,a0
    80005cfa:	0e054663          	bltz	a0,80005de6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cfe:	04491703          	lh	a4,68(s2)
    80005d02:	478d                	li	a5,3
    80005d04:	0cf70463          	beq	a4,a5,80005dcc <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d08:	4789                	li	a5,2
    80005d0a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d0e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d12:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d16:	f4c42783          	lw	a5,-180(s0)
    80005d1a:	0017c713          	xori	a4,a5,1
    80005d1e:	8b05                	andi	a4,a4,1
    80005d20:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d24:	0037f713          	andi	a4,a5,3
    80005d28:	00e03733          	snez	a4,a4
    80005d2c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d30:	4007f793          	andi	a5,a5,1024
    80005d34:	c791                	beqz	a5,80005d40 <sys_open+0xd2>
    80005d36:	04491703          	lh	a4,68(s2)
    80005d3a:	4789                	li	a5,2
    80005d3c:	08f70f63          	beq	a4,a5,80005dda <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d40:	854a                	mv	a0,s2
    80005d42:	ffffe097          	auipc	ra,0xffffe
    80005d46:	082080e7          	jalr	130(ra) # 80003dc4 <iunlock>
  end_op();
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	a0a080e7          	jalr	-1526(ra) # 80004754 <end_op>

  return fd;
}
    80005d52:	8526                	mv	a0,s1
    80005d54:	70ea                	ld	ra,184(sp)
    80005d56:	744a                	ld	s0,176(sp)
    80005d58:	74aa                	ld	s1,168(sp)
    80005d5a:	790a                	ld	s2,160(sp)
    80005d5c:	69ea                	ld	s3,152(sp)
    80005d5e:	6129                	addi	sp,sp,192
    80005d60:	8082                	ret
      end_op();
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	9f2080e7          	jalr	-1550(ra) # 80004754 <end_op>
      return -1;
    80005d6a:	b7e5                	j	80005d52 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d6c:	f5040513          	addi	a0,s0,-176
    80005d70:	ffffe097          	auipc	ra,0xffffe
    80005d74:	748080e7          	jalr	1864(ra) # 800044b8 <namei>
    80005d78:	892a                	mv	s2,a0
    80005d7a:	c905                	beqz	a0,80005daa <sys_open+0x13c>
    ilock(ip);
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	f86080e7          	jalr	-122(ra) # 80003d02 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d84:	04491703          	lh	a4,68(s2)
    80005d88:	4785                	li	a5,1
    80005d8a:	f4f712e3          	bne	a4,a5,80005cce <sys_open+0x60>
    80005d8e:	f4c42783          	lw	a5,-180(s0)
    80005d92:	dba1                	beqz	a5,80005ce2 <sys_open+0x74>
      iunlockput(ip);
    80005d94:	854a                	mv	a0,s2
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	1ce080e7          	jalr	462(ra) # 80003f64 <iunlockput>
      end_op();
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	9b6080e7          	jalr	-1610(ra) # 80004754 <end_op>
      return -1;
    80005da6:	54fd                	li	s1,-1
    80005da8:	b76d                	j	80005d52 <sys_open+0xe4>
      end_op();
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	9aa080e7          	jalr	-1622(ra) # 80004754 <end_op>
      return -1;
    80005db2:	54fd                	li	s1,-1
    80005db4:	bf79                	j	80005d52 <sys_open+0xe4>
    iunlockput(ip);
    80005db6:	854a                	mv	a0,s2
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	1ac080e7          	jalr	428(ra) # 80003f64 <iunlockput>
    end_op();
    80005dc0:	fffff097          	auipc	ra,0xfffff
    80005dc4:	994080e7          	jalr	-1644(ra) # 80004754 <end_op>
    return -1;
    80005dc8:	54fd                	li	s1,-1
    80005dca:	b761                	j	80005d52 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005dcc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005dd0:	04691783          	lh	a5,70(s2)
    80005dd4:	02f99223          	sh	a5,36(s3)
    80005dd8:	bf2d                	j	80005d12 <sys_open+0xa4>
    itrunc(ip);
    80005dda:	854a                	mv	a0,s2
    80005ddc:	ffffe097          	auipc	ra,0xffffe
    80005de0:	034080e7          	jalr	52(ra) # 80003e10 <itrunc>
    80005de4:	bfb1                	j	80005d40 <sys_open+0xd2>
      fileclose(f);
    80005de6:	854e                	mv	a0,s3
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	db8080e7          	jalr	-584(ra) # 80004ba0 <fileclose>
    iunlockput(ip);
    80005df0:	854a                	mv	a0,s2
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	172080e7          	jalr	370(ra) # 80003f64 <iunlockput>
    end_op();
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	95a080e7          	jalr	-1702(ra) # 80004754 <end_op>
    return -1;
    80005e02:	54fd                	li	s1,-1
    80005e04:	b7b9                	j	80005d52 <sys_open+0xe4>

0000000080005e06 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e06:	7175                	addi	sp,sp,-144
    80005e08:	e506                	sd	ra,136(sp)
    80005e0a:	e122                	sd	s0,128(sp)
    80005e0c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e0e:	fffff097          	auipc	ra,0xfffff
    80005e12:	8c6080e7          	jalr	-1850(ra) # 800046d4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e16:	08000613          	li	a2,128
    80005e1a:	f7040593          	addi	a1,s0,-144
    80005e1e:	4501                	li	a0,0
    80005e20:	ffffd097          	auipc	ra,0xffffd
    80005e24:	338080e7          	jalr	824(ra) # 80003158 <argstr>
    80005e28:	02054963          	bltz	a0,80005e5a <sys_mkdir+0x54>
    80005e2c:	4681                	li	a3,0
    80005e2e:	4601                	li	a2,0
    80005e30:	4585                	li	a1,1
    80005e32:	f7040513          	addi	a0,s0,-144
    80005e36:	fffff097          	auipc	ra,0xfffff
    80005e3a:	7fe080e7          	jalr	2046(ra) # 80005634 <create>
    80005e3e:	cd11                	beqz	a0,80005e5a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e40:	ffffe097          	auipc	ra,0xffffe
    80005e44:	124080e7          	jalr	292(ra) # 80003f64 <iunlockput>
  end_op();
    80005e48:	fffff097          	auipc	ra,0xfffff
    80005e4c:	90c080e7          	jalr	-1780(ra) # 80004754 <end_op>
  return 0;
    80005e50:	4501                	li	a0,0
}
    80005e52:	60aa                	ld	ra,136(sp)
    80005e54:	640a                	ld	s0,128(sp)
    80005e56:	6149                	addi	sp,sp,144
    80005e58:	8082                	ret
    end_op();
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	8fa080e7          	jalr	-1798(ra) # 80004754 <end_op>
    return -1;
    80005e62:	557d                	li	a0,-1
    80005e64:	b7fd                	j	80005e52 <sys_mkdir+0x4c>

0000000080005e66 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e66:	7135                	addi	sp,sp,-160
    80005e68:	ed06                	sd	ra,152(sp)
    80005e6a:	e922                	sd	s0,144(sp)
    80005e6c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	866080e7          	jalr	-1946(ra) # 800046d4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e76:	08000613          	li	a2,128
    80005e7a:	f7040593          	addi	a1,s0,-144
    80005e7e:	4501                	li	a0,0
    80005e80:	ffffd097          	auipc	ra,0xffffd
    80005e84:	2d8080e7          	jalr	728(ra) # 80003158 <argstr>
    80005e88:	04054a63          	bltz	a0,80005edc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e8c:	f6c40593          	addi	a1,s0,-148
    80005e90:	4505                	li	a0,1
    80005e92:	ffffd097          	auipc	ra,0xffffd
    80005e96:	282080e7          	jalr	642(ra) # 80003114 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e9a:	04054163          	bltz	a0,80005edc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e9e:	f6840593          	addi	a1,s0,-152
    80005ea2:	4509                	li	a0,2
    80005ea4:	ffffd097          	auipc	ra,0xffffd
    80005ea8:	270080e7          	jalr	624(ra) # 80003114 <argint>
     argint(1, &major) < 0 ||
    80005eac:	02054863          	bltz	a0,80005edc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005eb0:	f6841683          	lh	a3,-152(s0)
    80005eb4:	f6c41603          	lh	a2,-148(s0)
    80005eb8:	458d                	li	a1,3
    80005eba:	f7040513          	addi	a0,s0,-144
    80005ebe:	fffff097          	auipc	ra,0xfffff
    80005ec2:	776080e7          	jalr	1910(ra) # 80005634 <create>
     argint(2, &minor) < 0 ||
    80005ec6:	c919                	beqz	a0,80005edc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	09c080e7          	jalr	156(ra) # 80003f64 <iunlockput>
  end_op();
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	884080e7          	jalr	-1916(ra) # 80004754 <end_op>
  return 0;
    80005ed8:	4501                	li	a0,0
    80005eda:	a031                	j	80005ee6 <sys_mknod+0x80>
    end_op();
    80005edc:	fffff097          	auipc	ra,0xfffff
    80005ee0:	878080e7          	jalr	-1928(ra) # 80004754 <end_op>
    return -1;
    80005ee4:	557d                	li	a0,-1
}
    80005ee6:	60ea                	ld	ra,152(sp)
    80005ee8:	644a                	ld	s0,144(sp)
    80005eea:	610d                	addi	sp,sp,160
    80005eec:	8082                	ret

0000000080005eee <sys_chdir>:

uint64
sys_chdir(void)
{
    80005eee:	7135                	addi	sp,sp,-160
    80005ef0:	ed06                	sd	ra,152(sp)
    80005ef2:	e922                	sd	s0,144(sp)
    80005ef4:	e526                	sd	s1,136(sp)
    80005ef6:	e14a                	sd	s2,128(sp)
    80005ef8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005efa:	ffffc097          	auipc	ra,0xffffc
    80005efe:	ec6080e7          	jalr	-314(ra) # 80001dc0 <myproc>
    80005f02:	892a                	mv	s2,a0
  
  begin_op();
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	7d0080e7          	jalr	2000(ra) # 800046d4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f0c:	08000613          	li	a2,128
    80005f10:	f6040593          	addi	a1,s0,-160
    80005f14:	4501                	li	a0,0
    80005f16:	ffffd097          	auipc	ra,0xffffd
    80005f1a:	242080e7          	jalr	578(ra) # 80003158 <argstr>
    80005f1e:	04054b63          	bltz	a0,80005f74 <sys_chdir+0x86>
    80005f22:	f6040513          	addi	a0,s0,-160
    80005f26:	ffffe097          	auipc	ra,0xffffe
    80005f2a:	592080e7          	jalr	1426(ra) # 800044b8 <namei>
    80005f2e:	84aa                	mv	s1,a0
    80005f30:	c131                	beqz	a0,80005f74 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f32:	ffffe097          	auipc	ra,0xffffe
    80005f36:	dd0080e7          	jalr	-560(ra) # 80003d02 <ilock>
  if(ip->type != T_DIR){
    80005f3a:	04449703          	lh	a4,68(s1)
    80005f3e:	4785                	li	a5,1
    80005f40:	04f71063          	bne	a4,a5,80005f80 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f44:	8526                	mv	a0,s1
    80005f46:	ffffe097          	auipc	ra,0xffffe
    80005f4a:	e7e080e7          	jalr	-386(ra) # 80003dc4 <iunlock>
  iput(p->cwd);
    80005f4e:	17893503          	ld	a0,376(s2)
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	f6a080e7          	jalr	-150(ra) # 80003ebc <iput>
  end_op();
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	7fa080e7          	jalr	2042(ra) # 80004754 <end_op>
  p->cwd = ip;
    80005f62:	16993c23          	sd	s1,376(s2)
  return 0;
    80005f66:	4501                	li	a0,0
}
    80005f68:	60ea                	ld	ra,152(sp)
    80005f6a:	644a                	ld	s0,144(sp)
    80005f6c:	64aa                	ld	s1,136(sp)
    80005f6e:	690a                	ld	s2,128(sp)
    80005f70:	610d                	addi	sp,sp,160
    80005f72:	8082                	ret
    end_op();
    80005f74:	ffffe097          	auipc	ra,0xffffe
    80005f78:	7e0080e7          	jalr	2016(ra) # 80004754 <end_op>
    return -1;
    80005f7c:	557d                	li	a0,-1
    80005f7e:	b7ed                	j	80005f68 <sys_chdir+0x7a>
    iunlockput(ip);
    80005f80:	8526                	mv	a0,s1
    80005f82:	ffffe097          	auipc	ra,0xffffe
    80005f86:	fe2080e7          	jalr	-30(ra) # 80003f64 <iunlockput>
    end_op();
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	7ca080e7          	jalr	1994(ra) # 80004754 <end_op>
    return -1;
    80005f92:	557d                	li	a0,-1
    80005f94:	bfd1                	j	80005f68 <sys_chdir+0x7a>

0000000080005f96 <sys_exec>:

uint64
sys_exec(void)
{
    80005f96:	7145                	addi	sp,sp,-464
    80005f98:	e786                	sd	ra,456(sp)
    80005f9a:	e3a2                	sd	s0,448(sp)
    80005f9c:	ff26                	sd	s1,440(sp)
    80005f9e:	fb4a                	sd	s2,432(sp)
    80005fa0:	f74e                	sd	s3,424(sp)
    80005fa2:	f352                	sd	s4,416(sp)
    80005fa4:	ef56                	sd	s5,408(sp)
    80005fa6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fa8:	08000613          	li	a2,128
    80005fac:	f4040593          	addi	a1,s0,-192
    80005fb0:	4501                	li	a0,0
    80005fb2:	ffffd097          	auipc	ra,0xffffd
    80005fb6:	1a6080e7          	jalr	422(ra) # 80003158 <argstr>
    return -1;
    80005fba:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fbc:	0c054a63          	bltz	a0,80006090 <sys_exec+0xfa>
    80005fc0:	e3840593          	addi	a1,s0,-456
    80005fc4:	4505                	li	a0,1
    80005fc6:	ffffd097          	auipc	ra,0xffffd
    80005fca:	170080e7          	jalr	368(ra) # 80003136 <argaddr>
    80005fce:	0c054163          	bltz	a0,80006090 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005fd2:	10000613          	li	a2,256
    80005fd6:	4581                	li	a1,0
    80005fd8:	e4040513          	addi	a0,s0,-448
    80005fdc:	ffffb097          	auipc	ra,0xffffb
    80005fe0:	d04080e7          	jalr	-764(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005fe4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005fe8:	89a6                	mv	s3,s1
    80005fea:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fec:	02000a13          	li	s4,32
    80005ff0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ff4:	00391513          	slli	a0,s2,0x3
    80005ff8:	e3040593          	addi	a1,s0,-464
    80005ffc:	e3843783          	ld	a5,-456(s0)
    80006000:	953e                	add	a0,a0,a5
    80006002:	ffffd097          	auipc	ra,0xffffd
    80006006:	078080e7          	jalr	120(ra) # 8000307a <fetchaddr>
    8000600a:	02054a63          	bltz	a0,8000603e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000600e:	e3043783          	ld	a5,-464(s0)
    80006012:	c3b9                	beqz	a5,80006058 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006014:	ffffb097          	auipc	ra,0xffffb
    80006018:	ae0080e7          	jalr	-1312(ra) # 80000af4 <kalloc>
    8000601c:	85aa                	mv	a1,a0
    8000601e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006022:	cd11                	beqz	a0,8000603e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006024:	6605                	lui	a2,0x1
    80006026:	e3043503          	ld	a0,-464(s0)
    8000602a:	ffffd097          	auipc	ra,0xffffd
    8000602e:	0a2080e7          	jalr	162(ra) # 800030cc <fetchstr>
    80006032:	00054663          	bltz	a0,8000603e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006036:	0905                	addi	s2,s2,1
    80006038:	09a1                	addi	s3,s3,8
    8000603a:	fb491be3          	bne	s2,s4,80005ff0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000603e:	10048913          	addi	s2,s1,256
    80006042:	6088                	ld	a0,0(s1)
    80006044:	c529                	beqz	a0,8000608e <sys_exec+0xf8>
    kfree(argv[i]);
    80006046:	ffffb097          	auipc	ra,0xffffb
    8000604a:	9b2080e7          	jalr	-1614(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000604e:	04a1                	addi	s1,s1,8
    80006050:	ff2499e3          	bne	s1,s2,80006042 <sys_exec+0xac>
  return -1;
    80006054:	597d                	li	s2,-1
    80006056:	a82d                	j	80006090 <sys_exec+0xfa>
      argv[i] = 0;
    80006058:	0a8e                	slli	s5,s5,0x3
    8000605a:	fc040793          	addi	a5,s0,-64
    8000605e:	9abe                	add	s5,s5,a5
    80006060:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006064:	e4040593          	addi	a1,s0,-448
    80006068:	f4040513          	addi	a0,s0,-192
    8000606c:	fffff097          	auipc	ra,0xfffff
    80006070:	194080e7          	jalr	404(ra) # 80005200 <exec>
    80006074:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006076:	10048993          	addi	s3,s1,256
    8000607a:	6088                	ld	a0,0(s1)
    8000607c:	c911                	beqz	a0,80006090 <sys_exec+0xfa>
    kfree(argv[i]);
    8000607e:	ffffb097          	auipc	ra,0xffffb
    80006082:	97a080e7          	jalr	-1670(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006086:	04a1                	addi	s1,s1,8
    80006088:	ff3499e3          	bne	s1,s3,8000607a <sys_exec+0xe4>
    8000608c:	a011                	j	80006090 <sys_exec+0xfa>
  return -1;
    8000608e:	597d                	li	s2,-1
}
    80006090:	854a                	mv	a0,s2
    80006092:	60be                	ld	ra,456(sp)
    80006094:	641e                	ld	s0,448(sp)
    80006096:	74fa                	ld	s1,440(sp)
    80006098:	795a                	ld	s2,432(sp)
    8000609a:	79ba                	ld	s3,424(sp)
    8000609c:	7a1a                	ld	s4,416(sp)
    8000609e:	6afa                	ld	s5,408(sp)
    800060a0:	6179                	addi	sp,sp,464
    800060a2:	8082                	ret

00000000800060a4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060a4:	7139                	addi	sp,sp,-64
    800060a6:	fc06                	sd	ra,56(sp)
    800060a8:	f822                	sd	s0,48(sp)
    800060aa:	f426                	sd	s1,40(sp)
    800060ac:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060ae:	ffffc097          	auipc	ra,0xffffc
    800060b2:	d12080e7          	jalr	-750(ra) # 80001dc0 <myproc>
    800060b6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800060b8:	fd840593          	addi	a1,s0,-40
    800060bc:	4501                	li	a0,0
    800060be:	ffffd097          	auipc	ra,0xffffd
    800060c2:	078080e7          	jalr	120(ra) # 80003136 <argaddr>
    return -1;
    800060c6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800060c8:	0e054063          	bltz	a0,800061a8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800060cc:	fc840593          	addi	a1,s0,-56
    800060d0:	fd040513          	addi	a0,s0,-48
    800060d4:	fffff097          	auipc	ra,0xfffff
    800060d8:	dfc080e7          	jalr	-516(ra) # 80004ed0 <pipealloc>
    return -1;
    800060dc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060de:	0c054563          	bltz	a0,800061a8 <sys_pipe+0x104>
  fd0 = -1;
    800060e2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060e6:	fd043503          	ld	a0,-48(s0)
    800060ea:	fffff097          	auipc	ra,0xfffff
    800060ee:	508080e7          	jalr	1288(ra) # 800055f2 <fdalloc>
    800060f2:	fca42223          	sw	a0,-60(s0)
    800060f6:	08054c63          	bltz	a0,8000618e <sys_pipe+0xea>
    800060fa:	fc843503          	ld	a0,-56(s0)
    800060fe:	fffff097          	auipc	ra,0xfffff
    80006102:	4f4080e7          	jalr	1268(ra) # 800055f2 <fdalloc>
    80006106:	fca42023          	sw	a0,-64(s0)
    8000610a:	06054863          	bltz	a0,8000617a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000610e:	4691                	li	a3,4
    80006110:	fc440613          	addi	a2,s0,-60
    80006114:	fd843583          	ld	a1,-40(s0)
    80006118:	7ca8                	ld	a0,120(s1)
    8000611a:	ffffb097          	auipc	ra,0xffffb
    8000611e:	558080e7          	jalr	1368(ra) # 80001672 <copyout>
    80006122:	02054063          	bltz	a0,80006142 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006126:	4691                	li	a3,4
    80006128:	fc040613          	addi	a2,s0,-64
    8000612c:	fd843583          	ld	a1,-40(s0)
    80006130:	0591                	addi	a1,a1,4
    80006132:	7ca8                	ld	a0,120(s1)
    80006134:	ffffb097          	auipc	ra,0xffffb
    80006138:	53e080e7          	jalr	1342(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000613c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000613e:	06055563          	bgez	a0,800061a8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006142:	fc442783          	lw	a5,-60(s0)
    80006146:	07f9                	addi	a5,a5,30
    80006148:	078e                	slli	a5,a5,0x3
    8000614a:	97a6                	add	a5,a5,s1
    8000614c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006150:	fc042503          	lw	a0,-64(s0)
    80006154:	0579                	addi	a0,a0,30
    80006156:	050e                	slli	a0,a0,0x3
    80006158:	9526                	add	a0,a0,s1
    8000615a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000615e:	fd043503          	ld	a0,-48(s0)
    80006162:	fffff097          	auipc	ra,0xfffff
    80006166:	a3e080e7          	jalr	-1474(ra) # 80004ba0 <fileclose>
    fileclose(wf);
    8000616a:	fc843503          	ld	a0,-56(s0)
    8000616e:	fffff097          	auipc	ra,0xfffff
    80006172:	a32080e7          	jalr	-1486(ra) # 80004ba0 <fileclose>
    return -1;
    80006176:	57fd                	li	a5,-1
    80006178:	a805                	j	800061a8 <sys_pipe+0x104>
    if(fd0 >= 0)
    8000617a:	fc442783          	lw	a5,-60(s0)
    8000617e:	0007c863          	bltz	a5,8000618e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006182:	01e78513          	addi	a0,a5,30
    80006186:	050e                	slli	a0,a0,0x3
    80006188:	9526                	add	a0,a0,s1
    8000618a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000618e:	fd043503          	ld	a0,-48(s0)
    80006192:	fffff097          	auipc	ra,0xfffff
    80006196:	a0e080e7          	jalr	-1522(ra) # 80004ba0 <fileclose>
    fileclose(wf);
    8000619a:	fc843503          	ld	a0,-56(s0)
    8000619e:	fffff097          	auipc	ra,0xfffff
    800061a2:	a02080e7          	jalr	-1534(ra) # 80004ba0 <fileclose>
    return -1;
    800061a6:	57fd                	li	a5,-1
}
    800061a8:	853e                	mv	a0,a5
    800061aa:	70e2                	ld	ra,56(sp)
    800061ac:	7442                	ld	s0,48(sp)
    800061ae:	74a2                	ld	s1,40(sp)
    800061b0:	6121                	addi	sp,sp,64
    800061b2:	8082                	ret
	...

00000000800061c0 <kernelvec>:
    800061c0:	7111                	addi	sp,sp,-256
    800061c2:	e006                	sd	ra,0(sp)
    800061c4:	e40a                	sd	sp,8(sp)
    800061c6:	e80e                	sd	gp,16(sp)
    800061c8:	ec12                	sd	tp,24(sp)
    800061ca:	f016                	sd	t0,32(sp)
    800061cc:	f41a                	sd	t1,40(sp)
    800061ce:	f81e                	sd	t2,48(sp)
    800061d0:	fc22                	sd	s0,56(sp)
    800061d2:	e0a6                	sd	s1,64(sp)
    800061d4:	e4aa                	sd	a0,72(sp)
    800061d6:	e8ae                	sd	a1,80(sp)
    800061d8:	ecb2                	sd	a2,88(sp)
    800061da:	f0b6                	sd	a3,96(sp)
    800061dc:	f4ba                	sd	a4,104(sp)
    800061de:	f8be                	sd	a5,112(sp)
    800061e0:	fcc2                	sd	a6,120(sp)
    800061e2:	e146                	sd	a7,128(sp)
    800061e4:	e54a                	sd	s2,136(sp)
    800061e6:	e94e                	sd	s3,144(sp)
    800061e8:	ed52                	sd	s4,152(sp)
    800061ea:	f156                	sd	s5,160(sp)
    800061ec:	f55a                	sd	s6,168(sp)
    800061ee:	f95e                	sd	s7,176(sp)
    800061f0:	fd62                	sd	s8,184(sp)
    800061f2:	e1e6                	sd	s9,192(sp)
    800061f4:	e5ea                	sd	s10,200(sp)
    800061f6:	e9ee                	sd	s11,208(sp)
    800061f8:	edf2                	sd	t3,216(sp)
    800061fa:	f1f6                	sd	t4,224(sp)
    800061fc:	f5fa                	sd	t5,232(sp)
    800061fe:	f9fe                	sd	t6,240(sp)
    80006200:	d47fc0ef          	jal	ra,80002f46 <kerneltrap>
    80006204:	6082                	ld	ra,0(sp)
    80006206:	6122                	ld	sp,8(sp)
    80006208:	61c2                	ld	gp,16(sp)
    8000620a:	7282                	ld	t0,32(sp)
    8000620c:	7322                	ld	t1,40(sp)
    8000620e:	73c2                	ld	t2,48(sp)
    80006210:	7462                	ld	s0,56(sp)
    80006212:	6486                	ld	s1,64(sp)
    80006214:	6526                	ld	a0,72(sp)
    80006216:	65c6                	ld	a1,80(sp)
    80006218:	6666                	ld	a2,88(sp)
    8000621a:	7686                	ld	a3,96(sp)
    8000621c:	7726                	ld	a4,104(sp)
    8000621e:	77c6                	ld	a5,112(sp)
    80006220:	7866                	ld	a6,120(sp)
    80006222:	688a                	ld	a7,128(sp)
    80006224:	692a                	ld	s2,136(sp)
    80006226:	69ca                	ld	s3,144(sp)
    80006228:	6a6a                	ld	s4,152(sp)
    8000622a:	7a8a                	ld	s5,160(sp)
    8000622c:	7b2a                	ld	s6,168(sp)
    8000622e:	7bca                	ld	s7,176(sp)
    80006230:	7c6a                	ld	s8,184(sp)
    80006232:	6c8e                	ld	s9,192(sp)
    80006234:	6d2e                	ld	s10,200(sp)
    80006236:	6dce                	ld	s11,208(sp)
    80006238:	6e6e                	ld	t3,216(sp)
    8000623a:	7e8e                	ld	t4,224(sp)
    8000623c:	7f2e                	ld	t5,232(sp)
    8000623e:	7fce                	ld	t6,240(sp)
    80006240:	6111                	addi	sp,sp,256
    80006242:	10200073          	sret
    80006246:	00000013          	nop
    8000624a:	00000013          	nop
    8000624e:	0001                	nop

0000000080006250 <timervec>:
    80006250:	34051573          	csrrw	a0,mscratch,a0
    80006254:	e10c                	sd	a1,0(a0)
    80006256:	e510                	sd	a2,8(a0)
    80006258:	e914                	sd	a3,16(a0)
    8000625a:	6d0c                	ld	a1,24(a0)
    8000625c:	7110                	ld	a2,32(a0)
    8000625e:	6194                	ld	a3,0(a1)
    80006260:	96b2                	add	a3,a3,a2
    80006262:	e194                	sd	a3,0(a1)
    80006264:	4589                	li	a1,2
    80006266:	14459073          	csrw	sip,a1
    8000626a:	6914                	ld	a3,16(a0)
    8000626c:	6510                	ld	a2,8(a0)
    8000626e:	610c                	ld	a1,0(a0)
    80006270:	34051573          	csrrw	a0,mscratch,a0
    80006274:	30200073          	mret
	...

000000008000627a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000627a:	1141                	addi	sp,sp,-16
    8000627c:	e422                	sd	s0,8(sp)
    8000627e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006280:	0c0007b7          	lui	a5,0xc000
    80006284:	4705                	li	a4,1
    80006286:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006288:	c3d8                	sw	a4,4(a5)
}
    8000628a:	6422                	ld	s0,8(sp)
    8000628c:	0141                	addi	sp,sp,16
    8000628e:	8082                	ret

0000000080006290 <plicinithart>:

void
plicinithart(void)
{
    80006290:	1141                	addi	sp,sp,-16
    80006292:	e406                	sd	ra,8(sp)
    80006294:	e022                	sd	s0,0(sp)
    80006296:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006298:	ffffc097          	auipc	ra,0xffffc
    8000629c:	af4080e7          	jalr	-1292(ra) # 80001d8c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062a0:	0085171b          	slliw	a4,a0,0x8
    800062a4:	0c0027b7          	lui	a5,0xc002
    800062a8:	97ba                	add	a5,a5,a4
    800062aa:	40200713          	li	a4,1026
    800062ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062b2:	00d5151b          	slliw	a0,a0,0xd
    800062b6:	0c2017b7          	lui	a5,0xc201
    800062ba:	953e                	add	a0,a0,a5
    800062bc:	00052023          	sw	zero,0(a0)
}
    800062c0:	60a2                	ld	ra,8(sp)
    800062c2:	6402                	ld	s0,0(sp)
    800062c4:	0141                	addi	sp,sp,16
    800062c6:	8082                	ret

00000000800062c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062c8:	1141                	addi	sp,sp,-16
    800062ca:	e406                	sd	ra,8(sp)
    800062cc:	e022                	sd	s0,0(sp)
    800062ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062d0:	ffffc097          	auipc	ra,0xffffc
    800062d4:	abc080e7          	jalr	-1348(ra) # 80001d8c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062d8:	00d5179b          	slliw	a5,a0,0xd
    800062dc:	0c201537          	lui	a0,0xc201
    800062e0:	953e                	add	a0,a0,a5
  return irq;
}
    800062e2:	4148                	lw	a0,4(a0)
    800062e4:	60a2                	ld	ra,8(sp)
    800062e6:	6402                	ld	s0,0(sp)
    800062e8:	0141                	addi	sp,sp,16
    800062ea:	8082                	ret

00000000800062ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062ec:	1101                	addi	sp,sp,-32
    800062ee:	ec06                	sd	ra,24(sp)
    800062f0:	e822                	sd	s0,16(sp)
    800062f2:	e426                	sd	s1,8(sp)
    800062f4:	1000                	addi	s0,sp,32
    800062f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062f8:	ffffc097          	auipc	ra,0xffffc
    800062fc:	a94080e7          	jalr	-1388(ra) # 80001d8c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006300:	00d5151b          	slliw	a0,a0,0xd
    80006304:	0c2017b7          	lui	a5,0xc201
    80006308:	97aa                	add	a5,a5,a0
    8000630a:	c3c4                	sw	s1,4(a5)
}
    8000630c:	60e2                	ld	ra,24(sp)
    8000630e:	6442                	ld	s0,16(sp)
    80006310:	64a2                	ld	s1,8(sp)
    80006312:	6105                	addi	sp,sp,32
    80006314:	8082                	ret

0000000080006316 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006316:	1141                	addi	sp,sp,-16
    80006318:	e406                	sd	ra,8(sp)
    8000631a:	e022                	sd	s0,0(sp)
    8000631c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000631e:	479d                	li	a5,7
    80006320:	06a7c963          	blt	a5,a0,80006392 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006324:	0001d797          	auipc	a5,0x1d
    80006328:	cdc78793          	addi	a5,a5,-804 # 80023000 <disk>
    8000632c:	00a78733          	add	a4,a5,a0
    80006330:	6789                	lui	a5,0x2
    80006332:	97ba                	add	a5,a5,a4
    80006334:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006338:	e7ad                	bnez	a5,800063a2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000633a:	00451793          	slli	a5,a0,0x4
    8000633e:	0001f717          	auipc	a4,0x1f
    80006342:	cc270713          	addi	a4,a4,-830 # 80025000 <disk+0x2000>
    80006346:	6314                	ld	a3,0(a4)
    80006348:	96be                	add	a3,a3,a5
    8000634a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000634e:	6314                	ld	a3,0(a4)
    80006350:	96be                	add	a3,a3,a5
    80006352:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006356:	6314                	ld	a3,0(a4)
    80006358:	96be                	add	a3,a3,a5
    8000635a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000635e:	6318                	ld	a4,0(a4)
    80006360:	97ba                	add	a5,a5,a4
    80006362:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006366:	0001d797          	auipc	a5,0x1d
    8000636a:	c9a78793          	addi	a5,a5,-870 # 80023000 <disk>
    8000636e:	97aa                	add	a5,a5,a0
    80006370:	6509                	lui	a0,0x2
    80006372:	953e                	add	a0,a0,a5
    80006374:	4785                	li	a5,1
    80006376:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000637a:	0001f517          	auipc	a0,0x1f
    8000637e:	c9e50513          	addi	a0,a0,-866 # 80025018 <disk+0x2018>
    80006382:	ffffc097          	auipc	ra,0xffffc
    80006386:	482080e7          	jalr	1154(ra) # 80002804 <wakeup>
}
    8000638a:	60a2                	ld	ra,8(sp)
    8000638c:	6402                	ld	s0,0(sp)
    8000638e:	0141                	addi	sp,sp,16
    80006390:	8082                	ret
    panic("free_desc 1");
    80006392:	00002517          	auipc	a0,0x2
    80006396:	44650513          	addi	a0,a0,1094 # 800087d8 <syscalls+0x338>
    8000639a:	ffffa097          	auipc	ra,0xffffa
    8000639e:	1a4080e7          	jalr	420(ra) # 8000053e <panic>
    panic("free_desc 2");
    800063a2:	00002517          	auipc	a0,0x2
    800063a6:	44650513          	addi	a0,a0,1094 # 800087e8 <syscalls+0x348>
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	194080e7          	jalr	404(ra) # 8000053e <panic>

00000000800063b2 <virtio_disk_init>:
{
    800063b2:	1101                	addi	sp,sp,-32
    800063b4:	ec06                	sd	ra,24(sp)
    800063b6:	e822                	sd	s0,16(sp)
    800063b8:	e426                	sd	s1,8(sp)
    800063ba:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063bc:	00002597          	auipc	a1,0x2
    800063c0:	43c58593          	addi	a1,a1,1084 # 800087f8 <syscalls+0x358>
    800063c4:	0001f517          	auipc	a0,0x1f
    800063c8:	d6450513          	addi	a0,a0,-668 # 80025128 <disk+0x2128>
    800063cc:	ffffa097          	auipc	ra,0xffffa
    800063d0:	788080e7          	jalr	1928(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063d4:	100017b7          	lui	a5,0x10001
    800063d8:	4398                	lw	a4,0(a5)
    800063da:	2701                	sext.w	a4,a4
    800063dc:	747277b7          	lui	a5,0x74727
    800063e0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063e4:	0ef71163          	bne	a4,a5,800064c6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063e8:	100017b7          	lui	a5,0x10001
    800063ec:	43dc                	lw	a5,4(a5)
    800063ee:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063f0:	4705                	li	a4,1
    800063f2:	0ce79a63          	bne	a5,a4,800064c6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063f6:	100017b7          	lui	a5,0x10001
    800063fa:	479c                	lw	a5,8(a5)
    800063fc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063fe:	4709                	li	a4,2
    80006400:	0ce79363          	bne	a5,a4,800064c6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006404:	100017b7          	lui	a5,0x10001
    80006408:	47d8                	lw	a4,12(a5)
    8000640a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000640c:	554d47b7          	lui	a5,0x554d4
    80006410:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006414:	0af71963          	bne	a4,a5,800064c6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006418:	100017b7          	lui	a5,0x10001
    8000641c:	4705                	li	a4,1
    8000641e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006420:	470d                	li	a4,3
    80006422:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006424:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006426:	c7ffe737          	lui	a4,0xc7ffe
    8000642a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000642e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006430:	2701                	sext.w	a4,a4
    80006432:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006434:	472d                	li	a4,11
    80006436:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006438:	473d                	li	a4,15
    8000643a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000643c:	6705                	lui	a4,0x1
    8000643e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006440:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006444:	5bdc                	lw	a5,52(a5)
    80006446:	2781                	sext.w	a5,a5
  if(max == 0)
    80006448:	c7d9                	beqz	a5,800064d6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000644a:	471d                	li	a4,7
    8000644c:	08f77d63          	bgeu	a4,a5,800064e6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006450:	100014b7          	lui	s1,0x10001
    80006454:	47a1                	li	a5,8
    80006456:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006458:	6609                	lui	a2,0x2
    8000645a:	4581                	li	a1,0
    8000645c:	0001d517          	auipc	a0,0x1d
    80006460:	ba450513          	addi	a0,a0,-1116 # 80023000 <disk>
    80006464:	ffffb097          	auipc	ra,0xffffb
    80006468:	87c080e7          	jalr	-1924(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000646c:	0001d717          	auipc	a4,0x1d
    80006470:	b9470713          	addi	a4,a4,-1132 # 80023000 <disk>
    80006474:	00c75793          	srli	a5,a4,0xc
    80006478:	2781                	sext.w	a5,a5
    8000647a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000647c:	0001f797          	auipc	a5,0x1f
    80006480:	b8478793          	addi	a5,a5,-1148 # 80025000 <disk+0x2000>
    80006484:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006486:	0001d717          	auipc	a4,0x1d
    8000648a:	bfa70713          	addi	a4,a4,-1030 # 80023080 <disk+0x80>
    8000648e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006490:	0001e717          	auipc	a4,0x1e
    80006494:	b7070713          	addi	a4,a4,-1168 # 80024000 <disk+0x1000>
    80006498:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000649a:	4705                	li	a4,1
    8000649c:	00e78c23          	sb	a4,24(a5)
    800064a0:	00e78ca3          	sb	a4,25(a5)
    800064a4:	00e78d23          	sb	a4,26(a5)
    800064a8:	00e78da3          	sb	a4,27(a5)
    800064ac:	00e78e23          	sb	a4,28(a5)
    800064b0:	00e78ea3          	sb	a4,29(a5)
    800064b4:	00e78f23          	sb	a4,30(a5)
    800064b8:	00e78fa3          	sb	a4,31(a5)
}
    800064bc:	60e2                	ld	ra,24(sp)
    800064be:	6442                	ld	s0,16(sp)
    800064c0:	64a2                	ld	s1,8(sp)
    800064c2:	6105                	addi	sp,sp,32
    800064c4:	8082                	ret
    panic("could not find virtio disk");
    800064c6:	00002517          	auipc	a0,0x2
    800064ca:	34250513          	addi	a0,a0,834 # 80008808 <syscalls+0x368>
    800064ce:	ffffa097          	auipc	ra,0xffffa
    800064d2:	070080e7          	jalr	112(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800064d6:	00002517          	auipc	a0,0x2
    800064da:	35250513          	addi	a0,a0,850 # 80008828 <syscalls+0x388>
    800064de:	ffffa097          	auipc	ra,0xffffa
    800064e2:	060080e7          	jalr	96(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800064e6:	00002517          	auipc	a0,0x2
    800064ea:	36250513          	addi	a0,a0,866 # 80008848 <syscalls+0x3a8>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	050080e7          	jalr	80(ra) # 8000053e <panic>

00000000800064f6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064f6:	7159                	addi	sp,sp,-112
    800064f8:	f486                	sd	ra,104(sp)
    800064fa:	f0a2                	sd	s0,96(sp)
    800064fc:	eca6                	sd	s1,88(sp)
    800064fe:	e8ca                	sd	s2,80(sp)
    80006500:	e4ce                	sd	s3,72(sp)
    80006502:	e0d2                	sd	s4,64(sp)
    80006504:	fc56                	sd	s5,56(sp)
    80006506:	f85a                	sd	s6,48(sp)
    80006508:	f45e                	sd	s7,40(sp)
    8000650a:	f062                	sd	s8,32(sp)
    8000650c:	ec66                	sd	s9,24(sp)
    8000650e:	e86a                	sd	s10,16(sp)
    80006510:	1880                	addi	s0,sp,112
    80006512:	892a                	mv	s2,a0
    80006514:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006516:	00c52c83          	lw	s9,12(a0)
    8000651a:	001c9c9b          	slliw	s9,s9,0x1
    8000651e:	1c82                	slli	s9,s9,0x20
    80006520:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006524:	0001f517          	auipc	a0,0x1f
    80006528:	c0450513          	addi	a0,a0,-1020 # 80025128 <disk+0x2128>
    8000652c:	ffffa097          	auipc	ra,0xffffa
    80006530:	6b8080e7          	jalr	1720(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    80006534:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006536:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006538:	0001db97          	auipc	s7,0x1d
    8000653c:	ac8b8b93          	addi	s7,s7,-1336 # 80023000 <disk>
    80006540:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006542:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006544:	8a4e                	mv	s4,s3
    80006546:	a051                	j	800065ca <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006548:	00fb86b3          	add	a3,s7,a5
    8000654c:	96da                	add	a3,a3,s6
    8000654e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006552:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006554:	0207c563          	bltz	a5,8000657e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006558:	2485                	addiw	s1,s1,1
    8000655a:	0711                	addi	a4,a4,4
    8000655c:	25548063          	beq	s1,s5,8000679c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006560:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006562:	0001f697          	auipc	a3,0x1f
    80006566:	ab668693          	addi	a3,a3,-1354 # 80025018 <disk+0x2018>
    8000656a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000656c:	0006c583          	lbu	a1,0(a3)
    80006570:	fde1                	bnez	a1,80006548 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006572:	2785                	addiw	a5,a5,1
    80006574:	0685                	addi	a3,a3,1
    80006576:	ff879be3          	bne	a5,s8,8000656c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000657a:	57fd                	li	a5,-1
    8000657c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000657e:	02905a63          	blez	s1,800065b2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006582:	f9042503          	lw	a0,-112(s0)
    80006586:	00000097          	auipc	ra,0x0
    8000658a:	d90080e7          	jalr	-624(ra) # 80006316 <free_desc>
      for(int j = 0; j < i; j++)
    8000658e:	4785                	li	a5,1
    80006590:	0297d163          	bge	a5,s1,800065b2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006594:	f9442503          	lw	a0,-108(s0)
    80006598:	00000097          	auipc	ra,0x0
    8000659c:	d7e080e7          	jalr	-642(ra) # 80006316 <free_desc>
      for(int j = 0; j < i; j++)
    800065a0:	4789                	li	a5,2
    800065a2:	0097d863          	bge	a5,s1,800065b2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800065a6:	f9842503          	lw	a0,-104(s0)
    800065aa:	00000097          	auipc	ra,0x0
    800065ae:	d6c080e7          	jalr	-660(ra) # 80006316 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065b2:	0001f597          	auipc	a1,0x1f
    800065b6:	b7658593          	addi	a1,a1,-1162 # 80025128 <disk+0x2128>
    800065ba:	0001f517          	auipc	a0,0x1f
    800065be:	a5e50513          	addi	a0,a0,-1442 # 80025018 <disk+0x2018>
    800065c2:	ffffc097          	auipc	ra,0xffffc
    800065c6:	0a4080e7          	jalr	164(ra) # 80002666 <sleep>
  for(int i = 0; i < 3; i++){
    800065ca:	f9040713          	addi	a4,s0,-112
    800065ce:	84ce                	mv	s1,s3
    800065d0:	bf41                	j	80006560 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800065d2:	20058713          	addi	a4,a1,512
    800065d6:	00471693          	slli	a3,a4,0x4
    800065da:	0001d717          	auipc	a4,0x1d
    800065de:	a2670713          	addi	a4,a4,-1498 # 80023000 <disk>
    800065e2:	9736                	add	a4,a4,a3
    800065e4:	4685                	li	a3,1
    800065e6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800065ea:	20058713          	addi	a4,a1,512
    800065ee:	00471693          	slli	a3,a4,0x4
    800065f2:	0001d717          	auipc	a4,0x1d
    800065f6:	a0e70713          	addi	a4,a4,-1522 # 80023000 <disk>
    800065fa:	9736                	add	a4,a4,a3
    800065fc:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006600:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006604:	7679                	lui	a2,0xffffe
    80006606:	963e                	add	a2,a2,a5
    80006608:	0001f697          	auipc	a3,0x1f
    8000660c:	9f868693          	addi	a3,a3,-1544 # 80025000 <disk+0x2000>
    80006610:	6298                	ld	a4,0(a3)
    80006612:	9732                	add	a4,a4,a2
    80006614:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006616:	6298                	ld	a4,0(a3)
    80006618:	9732                	add	a4,a4,a2
    8000661a:	4541                	li	a0,16
    8000661c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000661e:	6298                	ld	a4,0(a3)
    80006620:	9732                	add	a4,a4,a2
    80006622:	4505                	li	a0,1
    80006624:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006628:	f9442703          	lw	a4,-108(s0)
    8000662c:	6288                	ld	a0,0(a3)
    8000662e:	962a                	add	a2,a2,a0
    80006630:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006634:	0712                	slli	a4,a4,0x4
    80006636:	6290                	ld	a2,0(a3)
    80006638:	963a                	add	a2,a2,a4
    8000663a:	05890513          	addi	a0,s2,88
    8000663e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006640:	6294                	ld	a3,0(a3)
    80006642:	96ba                	add	a3,a3,a4
    80006644:	40000613          	li	a2,1024
    80006648:	c690                	sw	a2,8(a3)
  if(write)
    8000664a:	140d0063          	beqz	s10,8000678a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000664e:	0001f697          	auipc	a3,0x1f
    80006652:	9b26b683          	ld	a3,-1614(a3) # 80025000 <disk+0x2000>
    80006656:	96ba                	add	a3,a3,a4
    80006658:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000665c:	0001d817          	auipc	a6,0x1d
    80006660:	9a480813          	addi	a6,a6,-1628 # 80023000 <disk>
    80006664:	0001f517          	auipc	a0,0x1f
    80006668:	99c50513          	addi	a0,a0,-1636 # 80025000 <disk+0x2000>
    8000666c:	6114                	ld	a3,0(a0)
    8000666e:	96ba                	add	a3,a3,a4
    80006670:	00c6d603          	lhu	a2,12(a3)
    80006674:	00166613          	ori	a2,a2,1
    80006678:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000667c:	f9842683          	lw	a3,-104(s0)
    80006680:	6110                	ld	a2,0(a0)
    80006682:	9732                	add	a4,a4,a2
    80006684:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006688:	20058613          	addi	a2,a1,512
    8000668c:	0612                	slli	a2,a2,0x4
    8000668e:	9642                	add	a2,a2,a6
    80006690:	577d                	li	a4,-1
    80006692:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006696:	00469713          	slli	a4,a3,0x4
    8000669a:	6114                	ld	a3,0(a0)
    8000669c:	96ba                	add	a3,a3,a4
    8000669e:	03078793          	addi	a5,a5,48
    800066a2:	97c2                	add	a5,a5,a6
    800066a4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800066a6:	611c                	ld	a5,0(a0)
    800066a8:	97ba                	add	a5,a5,a4
    800066aa:	4685                	li	a3,1
    800066ac:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066ae:	611c                	ld	a5,0(a0)
    800066b0:	97ba                	add	a5,a5,a4
    800066b2:	4809                	li	a6,2
    800066b4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800066b8:	611c                	ld	a5,0(a0)
    800066ba:	973e                	add	a4,a4,a5
    800066bc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066c0:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    800066c4:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066c8:	6518                	ld	a4,8(a0)
    800066ca:	00275783          	lhu	a5,2(a4)
    800066ce:	8b9d                	andi	a5,a5,7
    800066d0:	0786                	slli	a5,a5,0x1
    800066d2:	97ba                	add	a5,a5,a4
    800066d4:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800066d8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066dc:	6518                	ld	a4,8(a0)
    800066de:	00275783          	lhu	a5,2(a4)
    800066e2:	2785                	addiw	a5,a5,1
    800066e4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066e8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066ec:	100017b7          	lui	a5,0x10001
    800066f0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066f4:	00492703          	lw	a4,4(s2)
    800066f8:	4785                	li	a5,1
    800066fa:	02f71163          	bne	a4,a5,8000671c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800066fe:	0001f997          	auipc	s3,0x1f
    80006702:	a2a98993          	addi	s3,s3,-1494 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006706:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006708:	85ce                	mv	a1,s3
    8000670a:	854a                	mv	a0,s2
    8000670c:	ffffc097          	auipc	ra,0xffffc
    80006710:	f5a080e7          	jalr	-166(ra) # 80002666 <sleep>
  while(b->disk == 1) {
    80006714:	00492783          	lw	a5,4(s2)
    80006718:	fe9788e3          	beq	a5,s1,80006708 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000671c:	f9042903          	lw	s2,-112(s0)
    80006720:	20090793          	addi	a5,s2,512
    80006724:	00479713          	slli	a4,a5,0x4
    80006728:	0001d797          	auipc	a5,0x1d
    8000672c:	8d878793          	addi	a5,a5,-1832 # 80023000 <disk>
    80006730:	97ba                	add	a5,a5,a4
    80006732:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006736:	0001f997          	auipc	s3,0x1f
    8000673a:	8ca98993          	addi	s3,s3,-1846 # 80025000 <disk+0x2000>
    8000673e:	00491713          	slli	a4,s2,0x4
    80006742:	0009b783          	ld	a5,0(s3)
    80006746:	97ba                	add	a5,a5,a4
    80006748:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000674c:	854a                	mv	a0,s2
    8000674e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006752:	00000097          	auipc	ra,0x0
    80006756:	bc4080e7          	jalr	-1084(ra) # 80006316 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000675a:	8885                	andi	s1,s1,1
    8000675c:	f0ed                	bnez	s1,8000673e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000675e:	0001f517          	auipc	a0,0x1f
    80006762:	9ca50513          	addi	a0,a0,-1590 # 80025128 <disk+0x2128>
    80006766:	ffffa097          	auipc	ra,0xffffa
    8000676a:	532080e7          	jalr	1330(ra) # 80000c98 <release>
}
    8000676e:	70a6                	ld	ra,104(sp)
    80006770:	7406                	ld	s0,96(sp)
    80006772:	64e6                	ld	s1,88(sp)
    80006774:	6946                	ld	s2,80(sp)
    80006776:	69a6                	ld	s3,72(sp)
    80006778:	6a06                	ld	s4,64(sp)
    8000677a:	7ae2                	ld	s5,56(sp)
    8000677c:	7b42                	ld	s6,48(sp)
    8000677e:	7ba2                	ld	s7,40(sp)
    80006780:	7c02                	ld	s8,32(sp)
    80006782:	6ce2                	ld	s9,24(sp)
    80006784:	6d42                	ld	s10,16(sp)
    80006786:	6165                	addi	sp,sp,112
    80006788:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000678a:	0001f697          	auipc	a3,0x1f
    8000678e:	8766b683          	ld	a3,-1930(a3) # 80025000 <disk+0x2000>
    80006792:	96ba                	add	a3,a3,a4
    80006794:	4609                	li	a2,2
    80006796:	00c69623          	sh	a2,12(a3)
    8000679a:	b5c9                	j	8000665c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000679c:	f9042583          	lw	a1,-112(s0)
    800067a0:	20058793          	addi	a5,a1,512
    800067a4:	0792                	slli	a5,a5,0x4
    800067a6:	0001d517          	auipc	a0,0x1d
    800067aa:	90250513          	addi	a0,a0,-1790 # 800230a8 <disk+0xa8>
    800067ae:	953e                	add	a0,a0,a5
  if(write)
    800067b0:	e20d11e3          	bnez	s10,800065d2 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800067b4:	20058713          	addi	a4,a1,512
    800067b8:	00471693          	slli	a3,a4,0x4
    800067bc:	0001d717          	auipc	a4,0x1d
    800067c0:	84470713          	addi	a4,a4,-1980 # 80023000 <disk>
    800067c4:	9736                	add	a4,a4,a3
    800067c6:	0a072423          	sw	zero,168(a4)
    800067ca:	b505                	j	800065ea <virtio_disk_rw+0xf4>

00000000800067cc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067cc:	1101                	addi	sp,sp,-32
    800067ce:	ec06                	sd	ra,24(sp)
    800067d0:	e822                	sd	s0,16(sp)
    800067d2:	e426                	sd	s1,8(sp)
    800067d4:	e04a                	sd	s2,0(sp)
    800067d6:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067d8:	0001f517          	auipc	a0,0x1f
    800067dc:	95050513          	addi	a0,a0,-1712 # 80025128 <disk+0x2128>
    800067e0:	ffffa097          	auipc	ra,0xffffa
    800067e4:	404080e7          	jalr	1028(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067e8:	10001737          	lui	a4,0x10001
    800067ec:	533c                	lw	a5,96(a4)
    800067ee:	8b8d                	andi	a5,a5,3
    800067f0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067f2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067f6:	0001f797          	auipc	a5,0x1f
    800067fa:	80a78793          	addi	a5,a5,-2038 # 80025000 <disk+0x2000>
    800067fe:	6b94                	ld	a3,16(a5)
    80006800:	0207d703          	lhu	a4,32(a5)
    80006804:	0026d783          	lhu	a5,2(a3)
    80006808:	06f70163          	beq	a4,a5,8000686a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000680c:	0001c917          	auipc	s2,0x1c
    80006810:	7f490913          	addi	s2,s2,2036 # 80023000 <disk>
    80006814:	0001e497          	auipc	s1,0x1e
    80006818:	7ec48493          	addi	s1,s1,2028 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000681c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006820:	6898                	ld	a4,16(s1)
    80006822:	0204d783          	lhu	a5,32(s1)
    80006826:	8b9d                	andi	a5,a5,7
    80006828:	078e                	slli	a5,a5,0x3
    8000682a:	97ba                	add	a5,a5,a4
    8000682c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000682e:	20078713          	addi	a4,a5,512
    80006832:	0712                	slli	a4,a4,0x4
    80006834:	974a                	add	a4,a4,s2
    80006836:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000683a:	e731                	bnez	a4,80006886 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000683c:	20078793          	addi	a5,a5,512
    80006840:	0792                	slli	a5,a5,0x4
    80006842:	97ca                	add	a5,a5,s2
    80006844:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006846:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000684a:	ffffc097          	auipc	ra,0xffffc
    8000684e:	fba080e7          	jalr	-70(ra) # 80002804 <wakeup>

    disk.used_idx += 1;
    80006852:	0204d783          	lhu	a5,32(s1)
    80006856:	2785                	addiw	a5,a5,1
    80006858:	17c2                	slli	a5,a5,0x30
    8000685a:	93c1                	srli	a5,a5,0x30
    8000685c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006860:	6898                	ld	a4,16(s1)
    80006862:	00275703          	lhu	a4,2(a4)
    80006866:	faf71be3          	bne	a4,a5,8000681c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000686a:	0001f517          	auipc	a0,0x1f
    8000686e:	8be50513          	addi	a0,a0,-1858 # 80025128 <disk+0x2128>
    80006872:	ffffa097          	auipc	ra,0xffffa
    80006876:	426080e7          	jalr	1062(ra) # 80000c98 <release>
}
    8000687a:	60e2                	ld	ra,24(sp)
    8000687c:	6442                	ld	s0,16(sp)
    8000687e:	64a2                	ld	s1,8(sp)
    80006880:	6902                	ld	s2,0(sp)
    80006882:	6105                	addi	sp,sp,32
    80006884:	8082                	ret
      panic("virtio_disk_intr status");
    80006886:	00002517          	auipc	a0,0x2
    8000688a:	fe250513          	addi	a0,a0,-30 # 80008868 <syscalls+0x3c8>
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	cb0080e7          	jalr	-848(ra) # 8000053e <panic>

0000000080006896 <cas>:
    80006896:	100522af          	lr.w	t0,(a0)
    8000689a:	00b29563          	bne	t0,a1,800068a4 <fail>
    8000689e:	18c5252f          	sc.w	a0,a2,(a0)
    800068a2:	8082                	ret

00000000800068a4 <fail>:
    800068a4:	4505                	li	a0,1
    800068a6:	8082                	ret
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
