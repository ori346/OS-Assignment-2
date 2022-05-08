
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	90013103          	ld	sp,-1792(sp) # 80008900 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000068:	01c78793          	addi	a5,a5,28 # 80006080 <timervec>
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
    80000130:	8a4080e7          	jalr	-1884(ra) # 800029d0 <either_copyin>
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
    800001c8:	bec080e7          	jalr	-1044(ra) # 80001db0 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	33a080e7          	jalr	826(ra) # 8000250e <sleep>
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
    80000214:	76a080e7          	jalr	1898(ra) # 8000297a <either_copyout>
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
    800002f6:	734080e7          	jalr	1844(ra) # 80002a26 <procdump>
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
    8000044a:	2c8080e7          	jalr	712(ra) # 8000270e <wakeup>
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
    80000570:	c7450513          	addi	a0,a0,-908 # 800081e0 <digits+0x1a0>
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
    800008a4:	e6e080e7          	jalr	-402(ra) # 8000270e <wakeup>
    
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
    80000930:	be2080e7          	jalr	-1054(ra) # 8000250e <sleep>
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
    80000b82:	20e080e7          	jalr	526(ra) # 80001d8c <mycpu>
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
    80000bb4:	1dc080e7          	jalr	476(ra) # 80001d8c <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	1d0080e7          	jalr	464(ra) # 80001d8c <mycpu>
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
    80000bd8:	1b8080e7          	jalr	440(ra) # 80001d8c <mycpu>
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
    80000c18:	178080e7          	jalr	376(ra) # 80001d8c <mycpu>
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
    80000c44:	14c080e7          	jalr	332(ra) # 80001d8c <mycpu>
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
    80000e9a:	ee6080e7          	jalr	-282(ra) # 80001d7c <cpuid>
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
    80000eb6:	eca080e7          	jalr	-310(ra) # 80001d7c <cpuid>
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
    80000ed8:	c92080e7          	jalr	-878(ra) # 80002b66 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	1e4080e7          	jalr	484(ra) # 800060c0 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	436080e7          	jalr	1078(ra) # 8000231a <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	2e450513          	addi	a0,a0,740 # 800081e0 <digits+0x1a0>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	2c450513          	addi	a0,a0,708 # 800081e0 <digits+0x1a0>
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
    80000f48:	cd2080e7          	jalr	-814(ra) # 80001c16 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	bf2080e7          	jalr	-1038(ra) # 80002b3e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	c12080e7          	jalr	-1006(ra) # 80002b66 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	14e080e7          	jalr	334(ra) # 800060aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	15c080e7          	jalr	348(ra) # 800060c0 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	33c080e7          	jalr	828(ra) # 800032a8 <binit>
    iinit();         // inode table
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	9cc080e7          	jalr	-1588(ra) # 80003940 <iinit>
    fileinit();      // file table
    80000f7c:	00004097          	auipc	ra,0x4
    80000f80:	976080e7          	jalr	-1674(ra) # 800048f2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	25e080e7          	jalr	606(ra) # 800061e2 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	114080e7          	jalr	276(ra) # 800020a0 <userinit>
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
    80001244:	940080e7          	jalr	-1728(ra) # 80001b80 <proc_mapstacks>
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

000000008000183e <add2>:
    release(&p->list_lock);
    release(&list->lock);
    //printf("add proc num: %d succsesfuly\n" , new_proc);
}*/

void add2(struct headList * list , int new_proc_id){
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	84aa                	mv	s1,a0
    80001854:	8a2e                	mv	s4,a1
    //printf("try to add proc num: %d\n" , new_proc);
    printf("dding %d\n" , new_proc_id);
    80001856:	00007517          	auipc	a0,0x7
    8000185a:	98250513          	addi	a0,a0,-1662 # 800081d8 <digits+0x198>
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	d2a080e7          	jalr	-726(ra) # 80000588 <printf>

    struct proc *new_proc = &proc[new_proc_id];
    80001866:	19000793          	li	a5,400
    8000186a:	02fa07b3          	mul	a5,s4,a5
    8000186e:	00010997          	auipc	s3,0x10
    80001872:	05a98993          	addi	s3,s3,90 # 800118c8 <proc>
    80001876:	01378b33          	add	s6,a5,s3
    acquire(&new_proc->list_lock);
    8000187a:	04878793          	addi	a5,a5,72
    8000187e:	99be                	add	s3,s3,a5
    80001880:	854e                	mv	a0,s3
    80001882:	fffff097          	auipc	ra,0xfffff
    80001886:	362080e7          	jalr	866(ra) # 80000be4 <acquire>
    acquire(&list->lock);
    8000188a:	01048a93          	addi	s5,s1,16
    8000188e:	8556                	mv	a0,s5
    80001890:	fffff097          	auipc	ra,0xfffff
    80001894:	354080e7          	jalr	852(ra) # 80000be4 <acquire>
    //case the queue is empty
    if(list->head == 0){
    80001898:	0004b903          	ld	s2,0(s1)
    8000189c:	02090263          	beqz	s2,800018c0 <add2+0x82>
      return;
    }
    else{
      //printf("bla2\n");
      struct proc *p1 = list->head;
      release(&list->lock);
    800018a0:	8556                	mv	a0,s5
    800018a2:	fffff097          	auipc	ra,0xfffff
    800018a6:	3f6080e7          	jalr	1014(ra) # 80000c98 <release>
      struct proc *p2;

      acquire(&p1->list_lock);
    800018aa:	04890513          	addi	a0,s2,72 # 1048 <_entry-0x7fffefb8>
    800018ae:	fffff097          	auipc	ra,0xfffff
    800018b2:	336080e7          	jalr	822(ra) # 80000be4 <acquire>
      while (p1->next != 0)
    800018b6:	03893483          	ld	s1,56(s2)
    800018ba:	e09d                	bnez	s1,800018e0 <add2+0xa2>
      struct proc *p1 = list->head;
    800018bc:	84ca                	mv	s1,s2
    800018be:	a081                	j	800018fe <add2+0xc0>
      list->head = new_proc;
    800018c0:	0164b023          	sd	s6,0(s1)
      release(&list->lock);
    800018c4:	8556                	mv	a0,s5
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	3d2080e7          	jalr	978(ra) # 80000c98 <release>
      new_proc->next = 0;
    800018ce:	020b3c23          	sd	zero,56(s6) # 1038 <_entry-0x7fffefc8>
      release(&new_proc->list_lock);
    800018d2:	854e                	mv	a0,s3
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	3c4080e7          	jalr	964(ra) # 80000c98 <release>
      return;
    800018dc:	a835                	j	80001918 <add2+0xda>
      while (p1->next != 0)
    800018de:	84be                	mv	s1,a5
      {
        //printf("loop\n");
        p2 = p1->next;
        acquire(&p2->list_lock);
    800018e0:	04848513          	addi	a0,s1,72
    800018e4:	fffff097          	auipc	ra,0xfffff
    800018e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
        release(&p1->list_lock);
    800018ec:	04890513          	addi	a0,s2,72
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	3a8080e7          	jalr	936(ra) # 80000c98 <release>
      while (p1->next != 0)
    800018f8:	7c9c                	ld	a5,56(s1)
    800018fa:	8926                	mv	s2,s1
    800018fc:	f3ed                	bnez	a5,800018de <add2+0xa0>
        p1 = p2;
      }
      
      
      p1->next = new_proc;
    800018fe:	0364bc23          	sd	s6,56(s1)
      release(&p1->list_lock);
    80001902:	04848513          	addi	a0,s1,72
    80001906:	fffff097          	auipc	ra,0xfffff
    8000190a:	392080e7          	jalr	914(ra) # 80000c98 <release>
      release(&new_proc->list_lock);
    8000190e:	854e                	mv	a0,s3
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	388080e7          	jalr	904(ra) # 80000c98 <release>
      //printf("add proc num: %d succsesfuly\n" , new_proc);
    }
}
    80001918:	70e2                	ld	ra,56(sp)
    8000191a:	7442                	ld	s0,48(sp)
    8000191c:	74a2                	ld	s1,40(sp)
    8000191e:	7902                	ld	s2,32(sp)
    80001920:	69e2                	ld	s3,24(sp)
    80001922:	6a42                	ld	s4,16(sp)
    80001924:	6aa2                	ld	s5,8(sp)
    80001926:	6b02                	ld	s6,0(sp)
    80001928:	6121                	addi	sp,sp,64
    8000192a:	8082                	ret

000000008000192c <remove2>:
  release(&p->list_lock);
  release(&list->lock);
  return &proc[offset];
}*/

struct proc* remove2(struct headList * list){
    8000192c:	7179                	addi	sp,sp,-48
    8000192e:	f406                	sd	ra,40(sp)
    80001930:	f022                	sd	s0,32(sp)
    80001932:	ec26                	sd	s1,24(sp)
    80001934:	e84a                	sd	s2,16(sp)
    80001936:	e44e                	sd	s3,8(sp)
    80001938:	e052                	sd	s4,0(sp)
    8000193a:	1800                	addi	s0,sp,48
    8000193c:	892a                	mv	s2,a0
   
  struct proc* to_remove;
  acquire(&list->lock);
    8000193e:	01050993          	addi	s3,a0,16
    80001942:	854e                	mv	a0,s3
    80001944:	fffff097          	auipc	ra,0xfffff
    80001948:	2a0080e7          	jalr	672(ra) # 80000be4 <acquire>
  //case of empty queue 
  if(list->head == 0){
    8000194c:	00093483          	ld	s1,0(s2)
    80001950:	c4bd                	beqz	s1,800019be <remove2+0x92>
    release(&list->lock);
    return 0;
  }
  
  to_remove = list->head;
  printf("remove %d\n" , to_remove->index); 
    80001952:	40ac                	lw	a1,64(s1)
    80001954:	00007517          	auipc	a0,0x7
    80001958:	89450513          	addi	a0,a0,-1900 # 800081e8 <digits+0x1a8>
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	c2c080e7          	jalr	-980(ra) # 80000588 <printf>
  acquire(&to_remove->list_lock);
    80001964:	04848a13          	addi	s4,s1,72
    80001968:	8552                	mv	a0,s4
    8000196a:	fffff097          	auipc	ra,0xfffff
    8000196e:	27a080e7          	jalr	634(ra) # 80000be4 <acquire>
  if(to_remove->next == 0){
    80001972:	7c88                	ld	a0,56(s1)
    80001974:	c939                	beqz	a0,800019ca <remove2+0x9e>
    list->head = 0;
  }
  else{
    acquire(&to_remove->next->list_lock);
    80001976:	04850513          	addi	a0,a0,72
    8000197a:	fffff097          	auipc	ra,0xfffff
    8000197e:	26a080e7          	jalr	618(ra) # 80000be4 <acquire>
    list->head = to_remove->next;
    80001982:	7c88                	ld	a0,56(s1)
    80001984:	00a93023          	sd	a0,0(s2)
    release(&to_remove->next->list_lock);
    80001988:	04850513          	addi	a0,a0,72
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	30c080e7          	jalr	780(ra) # 80000c98 <release>
  }
  
  release(&list->lock);
    80001994:	854e                	mv	a0,s3
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	302080e7          	jalr	770(ra) # 80000c98 <release>
  
  to_remove->next = 0;
    8000199e:	0204bc23          	sd	zero,56(s1)
  release(&to_remove->list_lock);
    800019a2:	8552                	mv	a0,s4
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	2f4080e7          	jalr	756(ra) # 80000c98 <release>
  return to_remove;
}
    800019ac:	8526                	mv	a0,s1
    800019ae:	70a2                	ld	ra,40(sp)
    800019b0:	7402                	ld	s0,32(sp)
    800019b2:	64e2                	ld	s1,24(sp)
    800019b4:	6942                	ld	s2,16(sp)
    800019b6:	69a2                	ld	s3,8(sp)
    800019b8:	6a02                	ld	s4,0(sp)
    800019ba:	6145                	addi	sp,sp,48
    800019bc:	8082                	ret
    release(&list->lock);
    800019be:	854e                	mv	a0,s3
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	2d8080e7          	jalr	728(ra) # 80000c98 <release>
    return 0;
    800019c8:	b7d5                	j	800019ac <remove2+0x80>
    list->head = 0;
    800019ca:	00093023          	sd	zero,0(s2)
    800019ce:	b7d9                	j	80001994 <remove2+0x68>

00000000800019d0 <remove_index2>:
  // curr->next = -1;
  release(&list->lock);

}*/

struct proc* remove_index2(struct headList *list , int ind){
    800019d0:	7179                	addi	sp,sp,-48
    800019d2:	f406                	sd	ra,40(sp)
    800019d4:	f022                	sd	s0,32(sp)
    800019d6:	ec26                	sd	s1,24(sp)
    800019d8:	e84a                	sd	s2,16(sp)
    800019da:	e44e                	sd	s3,8(sp)
    800019dc:	e052                	sd	s4,0(sp)
    800019de:	1800                	addi	s0,sp,48
    800019e0:	89aa                	mv	s3,a0
    800019e2:	892e                	mv	s2,a1
  //TODO change the implimntion to not lock all the list
  
  struct proc* to_remove;
  acquire(&list->lock);
    800019e4:	01050a13          	addi	s4,a0,16
    800019e8:	8552                	mv	a0,s4
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	1fa080e7          	jalr	506(ra) # 80000be4 <acquire>
  if(list->head == 0){
    800019f2:	0009b483          	ld	s1,0(s3)
    800019f6:	cca5                	beqz	s1,80001a6e <remove_index2+0x9e>
      release(&list->lock);
      return 0;
  }
  else if(&proc[ind] == list->head){
    800019f8:	19000793          	li	a5,400
    800019fc:	02f907b3          	mul	a5,s2,a5
    80001a00:	00010717          	auipc	a4,0x10
    80001a04:	ec870713          	addi	a4,a4,-312 # 800118c8 <proc>
    80001a08:	97ba                	add	a5,a5,a4
    80001a0a:	06f48863          	beq	s1,a5,80001a7a <remove_index2+0xaa>
    release(&to_remove->list_lock);
    return to_remove;      
  }

  struct proc *prev = list->head;
  release(&list->lock);
    80001a0e:	8552                	mv	a0,s4
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	288080e7          	jalr	648(ra) # 80000c98 <release>
  struct proc *curr = prev;

  acquire(&prev->list_lock);
    80001a18:	04848513          	addi	a0,s1,72
    80001a1c:	fffff097          	auipc	ra,0xfffff
    80001a20:	1c8080e7          	jalr	456(ra) # 80000be4 <acquire>
  while (prev->next != 0){
    80001a24:	7c88                	ld	a0,56(s1)
    80001a26:	c505                	beqz	a0,80001a4e <remove_index2+0x7e>
    acquire(&prev->next->list_lock);
    80001a28:	04850513          	addi	a0,a0,72
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	1b8080e7          	jalr	440(ra) # 80000be4 <acquire>
    curr = prev->next;
    80001a34:	8526                	mv	a0,s1
    80001a36:	7c84                	ld	s1,56(s1)
    if(curr->index == ind){
    80001a38:	40bc                	lw	a5,64(s1)
    80001a3a:	09278863          	beq	a5,s2,80001aca <remove_index2+0xfa>
      release(&prev->list_lock);
      curr->next = 0;
      release(&curr->list_lock);
      return curr;
    }
    release(&prev->list_lock);
    80001a3e:	04850513          	addi	a0,a0,72
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	256080e7          	jalr	598(ra) # 80000c98 <release>
  while (prev->next != 0){
    80001a4a:	7c88                	ld	a0,56(s1)
    80001a4c:	fd71                	bnez	a0,80001a28 <remove_index2+0x58>
    prev = curr;
  }
  release(&curr->list_lock);
    80001a4e:	04848513          	addi	a0,s1,72
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	246080e7          	jalr	582(ra) # 80000c98 <release>
  return 0;
    80001a5a:	4481                	li	s1,0
  
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	70a2                	ld	ra,40(sp)
    80001a60:	7402                	ld	s0,32(sp)
    80001a62:	64e2                	ld	s1,24(sp)
    80001a64:	6942                	ld	s2,16(sp)
    80001a66:	69a2                	ld	s3,8(sp)
    80001a68:	6a02                	ld	s4,0(sp)
    80001a6a:	6145                	addi	sp,sp,48
    80001a6c:	8082                	ret
      release(&list->lock);
    80001a6e:	8552                	mv	a0,s4
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	228080e7          	jalr	552(ra) # 80000c98 <release>
      return 0;
    80001a78:	b7d5                	j	80001a5c <remove_index2+0x8c>
    acquire(&to_remove->list_lock);
    80001a7a:	04848913          	addi	s2,s1,72
    80001a7e:	854a                	mv	a0,s2
    80001a80:	fffff097          	auipc	ra,0xfffff
    80001a84:	164080e7          	jalr	356(ra) # 80000be4 <acquire>
    if(to_remove->next == 0){
    80001a88:	7c88                	ld	a0,56(s1)
    80001a8a:	cd0d                	beqz	a0,80001ac4 <remove_index2+0xf4>
      acquire(&to_remove->next->list_lock);
    80001a8c:	04850513          	addi	a0,a0,72
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	154080e7          	jalr	340(ra) # 80000be4 <acquire>
      list->head = to_remove->next;
    80001a98:	7c88                	ld	a0,56(s1)
    80001a9a:	00a9b023          	sd	a0,0(s3)
      release(&to_remove->next->list_lock);
    80001a9e:	04850513          	addi	a0,a0,72
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	1f6080e7          	jalr	502(ra) # 80000c98 <release>
    release(&list->lock);
    80001aaa:	8552                	mv	a0,s4
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	1ec080e7          	jalr	492(ra) # 80000c98 <release>
    to_remove->next = 0;
    80001ab4:	0204bc23          	sd	zero,56(s1)
    release(&to_remove->list_lock);
    80001ab8:	854a                	mv	a0,s2
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	1de080e7          	jalr	478(ra) # 80000c98 <release>
    return to_remove;      
    80001ac2:	bf69                	j	80001a5c <remove_index2+0x8c>
      list->head = 0;
    80001ac4:	0009b023          	sd	zero,0(s3)
    80001ac8:	b7cd                	j	80001aaa <remove_index2+0xda>
      prev->next = curr->next;
    80001aca:	7c9c                	ld	a5,56(s1)
    80001acc:	fd1c                	sd	a5,56(a0)
      release(&prev->list_lock);
    80001ace:	04850513          	addi	a0,a0,72
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	1c6080e7          	jalr	454(ra) # 80000c98 <release>
      curr->next = 0;
    80001ada:	0204bc23          	sd	zero,56(s1)
      release(&curr->list_lock);
    80001ade:	04848513          	addi	a0,s1,72
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	1b6080e7          	jalr	438(ra) # 80000c98 <release>
      return curr;
    80001aea:	bf8d                	j	80001a5c <remove_index2+0x8c>

0000000080001aec <printList>:

void printList(struct headList* list){
    80001aec:	7179                	addi	sp,sp,-48
    80001aee:	f406                	sd	ra,40(sp)
    80001af0:	f022                	sd	s0,32(sp)
    80001af2:	ec26                	sd	s1,24(sp)
    80001af4:	e84a                	sd	s2,16(sp)
    80001af6:	e44e                	sd	s3,8(sp)
    80001af8:	1800                	addi	s0,sp,48
    80001afa:	84aa                	mv	s1,a0
  acquire(&list->lock);
    80001afc:	01050993          	addi	s3,a0,16
    80001b00:	854e                	mv	a0,s3
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	0e2080e7          	jalr	226(ra) # 80000be4 <acquire>
  printf("the list: ");
    80001b0a:	00006517          	auipc	a0,0x6
    80001b0e:	6ee50513          	addi	a0,a0,1774 # 800081f8 <digits+0x1b8>
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	a76080e7          	jalr	-1418(ra) # 80000588 <printf>
  if(list->head == 0){
    80001b1a:	6084                	ld	s1,0(s1)
    printf("empty\n");
    return;
  }
  struct proc *p = list->head;
  while(p != 0 ){ 
    printf("%d " , p->index); 
    80001b1c:	00006917          	auipc	s2,0x6
    80001b20:	6f490913          	addi	s2,s2,1780 # 80008210 <digits+0x1d0>
  if(list->head == 0){
    80001b24:	cc8d                	beqz	s1,80001b5e <printList+0x72>
    printf("%d " , p->index); 
    80001b26:	40ac                	lw	a1,64(s1)
    80001b28:	854a                	mv	a0,s2
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	a5e080e7          	jalr	-1442(ra) # 80000588 <printf>
    p = p->next;
    80001b32:	7c84                	ld	s1,56(s1)
  while(p != 0 ){ 
    80001b34:	f8ed                	bnez	s1,80001b26 <printList+0x3a>
  }

  printf("\n"); 
    80001b36:	00006517          	auipc	a0,0x6
    80001b3a:	6aa50513          	addi	a0,a0,1706 # 800081e0 <digits+0x1a0>
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	a4a080e7          	jalr	-1462(ra) # 80000588 <printf>
  release(&list->lock); 
    80001b46:	854e                	mv	a0,s3
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	150080e7          	jalr	336(ra) # 80000c98 <release>
}
    80001b50:	70a2                	ld	ra,40(sp)
    80001b52:	7402                	ld	s0,32(sp)
    80001b54:	64e2                	ld	s1,24(sp)
    80001b56:	6942                	ld	s2,16(sp)
    80001b58:	69a2                	ld	s3,8(sp)
    80001b5a:	6145                	addi	sp,sp,48
    80001b5c:	8082                	ret
    printf("empty\n");
    80001b5e:	00006517          	auipc	a0,0x6
    80001b62:	6aa50513          	addi	a0,a0,1706 # 80008208 <digits+0x1c8>
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	a22080e7          	jalr	-1502(ra) # 80000588 <printf>
    return;
    80001b6e:	b7cd                	j	80001b50 <printList+0x64>

0000000080001b70 <get_cpu>:
  if(p == 0)
    return -1;
  p->cpu = cpu_num; 
  return cpu_num;
}
int get_cpu(){
    80001b70:	1141                	addi	sp,sp,-16
    80001b72:	e422                	sd	s0,8(sp)
    80001b74:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b76:	8512                	mv	a0,tp
  return cpuid();
}
    80001b78:	2501                	sext.w	a0,a0
    80001b7a:	6422                	ld	s0,8(sp)
    80001b7c:	0141                	addi	sp,sp,16
    80001b7e:	8082                	ret

0000000080001b80 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001b80:	7139                	addi	sp,sp,-64
    80001b82:	fc06                	sd	ra,56(sp)
    80001b84:	f822                	sd	s0,48(sp)
    80001b86:	f426                	sd	s1,40(sp)
    80001b88:	f04a                	sd	s2,32(sp)
    80001b8a:	ec4e                	sd	s3,24(sp)
    80001b8c:	e852                	sd	s4,16(sp)
    80001b8e:	e456                	sd	s5,8(sp)
    80001b90:	e05a                	sd	s6,0(sp)
    80001b92:	0080                	addi	s0,sp,64
    80001b94:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b96:	00010497          	auipc	s1,0x10
    80001b9a:	d3248493          	addi	s1,s1,-718 # 800118c8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001b9e:	8b26                	mv	s6,s1
    80001ba0:	00006a97          	auipc	s5,0x6
    80001ba4:	460a8a93          	addi	s5,s5,1120 # 80008000 <etext>
    80001ba8:	04000937          	lui	s2,0x4000
    80001bac:	197d                	addi	s2,s2,-1
    80001bae:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb0:	00016a17          	auipc	s4,0x16
    80001bb4:	118a0a13          	addi	s4,s4,280 # 80017cc8 <tickslock>
    char *pa = kalloc();
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	f3c080e7          	jalr	-196(ra) # 80000af4 <kalloc>
    80001bc0:	862a                	mv	a2,a0
    if(pa == 0)
    80001bc2:	c131                	beqz	a0,80001c06 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001bc4:	416485b3          	sub	a1,s1,s6
    80001bc8:	8591                	srai	a1,a1,0x4
    80001bca:	000ab783          	ld	a5,0(s5)
    80001bce:	02f585b3          	mul	a1,a1,a5
    80001bd2:	2585                	addiw	a1,a1,1
    80001bd4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bd8:	4719                	li	a4,6
    80001bda:	6685                	lui	a3,0x1
    80001bdc:	40b905b3          	sub	a1,s2,a1
    80001be0:	854e                	mv	a0,s3
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	56e080e7          	jalr	1390(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	19048493          	addi	s1,s1,400
    80001bee:	fd4495e3          	bne	s1,s4,80001bb8 <proc_mapstacks+0x38>
  }
}
    80001bf2:	70e2                	ld	ra,56(sp)
    80001bf4:	7442                	ld	s0,48(sp)
    80001bf6:	74a2                	ld	s1,40(sp)
    80001bf8:	7902                	ld	s2,32(sp)
    80001bfa:	69e2                	ld	s3,24(sp)
    80001bfc:	6a42                	ld	s4,16(sp)
    80001bfe:	6aa2                	ld	s5,8(sp)
    80001c00:	6b02                	ld	s6,0(sp)
    80001c02:	6121                	addi	sp,sp,64
    80001c04:	8082                	ret
      panic("kalloc");
    80001c06:	00006517          	auipc	a0,0x6
    80001c0a:	61250513          	addi	a0,a0,1554 # 80008218 <digits+0x1d8>
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	930080e7          	jalr	-1744(ra) # 8000053e <panic>

0000000080001c16 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001c16:	715d                	addi	sp,sp,-80
    80001c18:	e486                	sd	ra,72(sp)
    80001c1a:	e0a2                	sd	s0,64(sp)
    80001c1c:	fc26                	sd	s1,56(sp)
    80001c1e:	f84a                	sd	s2,48(sp)
    80001c20:	f44e                	sd	s3,40(sp)
    80001c22:	f052                	sd	s4,32(sp)
    80001c24:	ec56                	sd	s5,24(sp)
    80001c26:	e85a                	sd	s6,16(sp)
    80001c28:	e45e                	sd	s7,8(sp)
    80001c2a:	e062                	sd	s8,0(sp)
    80001c2c:	0880                	addi	s0,sp,80
  struct proc *p;
  int i = 0; 
  for(int j = 0 ; j < NCPU ; j++){
    80001c2e:	0000f497          	auipc	s1,0xf
    80001c32:	68248493          	addi	s1,s1,1666 # 800112b0 <readyQueus+0x10>
    80001c36:	0000f997          	auipc	s3,0xf
    80001c3a:	7aa98993          	addi	s3,s3,1962 # 800113e0 <cpus>
    80001c3e:	4901                	li	s2,0
    readyQueus[j].head = 0; 
    readyQueus[j].tail = 0; 
    initlock(&readyQueus[j].lock , "cpu");
    80001c40:	00006a97          	auipc	s5,0x6
    80001c44:	5e0a8a93          	addi	s5,s5,1504 # 80008220 <digits+0x1e0>
  for(int j = 0 ; j < NCPU ; j++){
    80001c48:	4a21                	li	s4,8
    readyQueus[j].head = 0; 
    80001c4a:	fe04b823          	sd	zero,-16(s1)
    readyQueus[j].tail = 0; 
    80001c4e:	fe04bc23          	sd	zero,-8(s1)
    initlock(&readyQueus[j].lock , "cpu");
    80001c52:	85d6                	mv	a1,s5
    80001c54:	8526                	mv	a0,s1
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	efe080e7          	jalr	-258(ra) # 80000b54 <initlock>
    cpus[j].index = j ;
    80001c5e:	0929a023          	sw	s2,128(s3)
  for(int j = 0 ; j < NCPU ; j++){
    80001c62:	2905                	addiw	s2,s2,1
    80001c64:	02848493          	addi	s1,s1,40
    80001c68:	08898993          	addi	s3,s3,136
    80001c6c:	fd491fe3          	bne	s2,s4,80001c4a <procinit+0x34>
  }
  initlock(&zombies.lock , "zombies");
    80001c70:	00006597          	auipc	a1,0x6
    80001c74:	5b858593          	addi	a1,a1,1464 # 80008228 <digits+0x1e8>
    80001c78:	00010517          	auipc	a0,0x10
    80001c7c:	bb850513          	addi	a0,a0,-1096 # 80011830 <zombies+0x10>
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	ed4080e7          	jalr	-300(ra) # 80000b54 <initlock>
  initlock(&sleeping.lock , "sleepings;");
    80001c88:	00006597          	auipc	a1,0x6
    80001c8c:	5a858593          	addi	a1,a1,1448 # 80008230 <digits+0x1f0>
    80001c90:	00010517          	auipc	a0,0x10
    80001c94:	bc850513          	addi	a0,a0,-1080 # 80011858 <sleeping+0x10>
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	ebc080e7          	jalr	-324(ra) # 80000b54 <initlock>
  initlock(&unusing.lock , "unsing");
    80001ca0:	00006597          	auipc	a1,0x6
    80001ca4:	5a058593          	addi	a1,a1,1440 # 80008240 <digits+0x200>
    80001ca8:	00010517          	auipc	a0,0x10
    80001cac:	bd850513          	addi	a0,a0,-1064 # 80011880 <unusing+0x10>
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	ea4080e7          	jalr	-348(ra) # 80000b54 <initlock>
  
  initlock(&pid_lock, "nextpid");
    80001cb8:	00006597          	auipc	a1,0x6
    80001cbc:	59058593          	addi	a1,a1,1424 # 80008248 <digits+0x208>
    80001cc0:	00010517          	auipc	a0,0x10
    80001cc4:	bd850513          	addi	a0,a0,-1064 # 80011898 <pid_lock>
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	e8c080e7          	jalr	-372(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001cd0:	00006597          	auipc	a1,0x6
    80001cd4:	58058593          	addi	a1,a1,1408 # 80008250 <digits+0x210>
    80001cd8:	00010517          	auipc	a0,0x10
    80001cdc:	bd850513          	addi	a0,a0,-1064 # 800118b0 <wait_lock>
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	e74080e7          	jalr	-396(ra) # 80000b54 <initlock>
  int i = 0; 
    80001ce8:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cea:	00010497          	auipc	s1,0x10
    80001cee:	bde48493          	addi	s1,s1,-1058 # 800118c8 <proc>
      initlock(&p->lock, "proc");
    80001cf2:	00006c17          	auipc	s8,0x6
    80001cf6:	56ec0c13          	addi	s8,s8,1390 # 80008260 <digits+0x220>
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
      add2(&unusing , p->index);
    80001d0c:	00010a97          	auipc	s5,0x10
    80001d10:	b64a8a93          	addi	s5,s5,-1180 # 80011870 <unusing>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d14:	00016a17          	auipc	s4,0x16
    80001d18:	fb4a0a13          	addi	s4,s4,-76 # 80017cc8 <tickslock>
      initlock(&p->lock, "proc");
    80001d1c:	85e2                	mv	a1,s8
    80001d1e:	8526                	mv	a0,s1
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	e34080e7          	jalr	-460(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001d28:	417487b3          	sub	a5,s1,s7
    80001d2c:	8791                	srai	a5,a5,0x4
    80001d2e:	000b3703          	ld	a4,0(s6)
    80001d32:	02e787b3          	mul	a5,a5,a4
    80001d36:	2785                	addiw	a5,a5,1
    80001d38:	00d7979b          	slliw	a5,a5,0xd
    80001d3c:	40f987b3          	sub	a5,s3,a5
    80001d40:	f4bc                	sd	a5,104(s1)
      p->index = i++;
    80001d42:	85ca                	mv	a1,s2
    80001d44:	0524a023          	sw	s2,64(s1)
    80001d48:	2905                	addiw	s2,s2,1
      p->next = 0;
    80001d4a:	0204bc23          	sd	zero,56(s1)
      p->cpu = 0; 
    80001d4e:	0204aa23          	sw	zero,52(s1)
      add2(&unusing , p->index);
    80001d52:	8556                	mv	a0,s5
    80001d54:	00000097          	auipc	ra,0x0
    80001d58:	aea080e7          	jalr	-1302(ra) # 8000183e <add2>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	19048493          	addi	s1,s1,400
    80001d60:	fb449ee3          	bne	s1,s4,80001d1c <procinit+0x106>
      
  }

}
    80001d64:	60a6                	ld	ra,72(sp)
    80001d66:	6406                	ld	s0,64(sp)
    80001d68:	74e2                	ld	s1,56(sp)
    80001d6a:	7942                	ld	s2,48(sp)
    80001d6c:	79a2                	ld	s3,40(sp)
    80001d6e:	7a02                	ld	s4,32(sp)
    80001d70:	6ae2                	ld	s5,24(sp)
    80001d72:	6b42                	ld	s6,16(sp)
    80001d74:	6ba2                	ld	s7,8(sp)
    80001d76:	6c02                	ld	s8,0(sp)
    80001d78:	6161                	addi	sp,sp,80
    80001d7a:	8082                	ret

0000000080001d7c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001d7c:	1141                	addi	sp,sp,-16
    80001d7e:	e422                	sd	s0,8(sp)
    80001d80:	0800                	addi	s0,sp,16
    80001d82:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d84:	2501                	sext.w	a0,a0
    80001d86:	6422                	ld	s0,8(sp)
    80001d88:	0141                	addi	sp,sp,16
    80001d8a:	8082                	ret

0000000080001d8c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001d8c:	1141                	addi	sp,sp,-16
    80001d8e:	e422                	sd	s0,8(sp)
    80001d90:	0800                	addi	s0,sp,16
    80001d92:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d94:	0007851b          	sext.w	a0,a5
    80001d98:	00451793          	slli	a5,a0,0x4
    80001d9c:	97aa                	add	a5,a5,a0
    80001d9e:	078e                	slli	a5,a5,0x3
  return c;
}
    80001da0:	0000f517          	auipc	a0,0xf
    80001da4:	64050513          	addi	a0,a0,1600 # 800113e0 <cpus>
    80001da8:	953e                	add	a0,a0,a5
    80001daa:	6422                	ld	s0,8(sp)
    80001dac:	0141                	addi	sp,sp,16
    80001dae:	8082                	ret

0000000080001db0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001db0:	1101                	addi	sp,sp,-32
    80001db2:	ec06                	sd	ra,24(sp)
    80001db4:	e822                	sd	s0,16(sp)
    80001db6:	e426                	sd	s1,8(sp)
    80001db8:	1000                	addi	s0,sp,32
  push_off();
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	dde080e7          	jalr	-546(ra) # 80000b98 <push_off>
    80001dc2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001dc4:	0007871b          	sext.w	a4,a5
    80001dc8:	00471793          	slli	a5,a4,0x4
    80001dcc:	97ba                	add	a5,a5,a4
    80001dce:	078e                	slli	a5,a5,0x3
    80001dd0:	0000f717          	auipc	a4,0xf
    80001dd4:	4d070713          	addi	a4,a4,1232 # 800112a0 <readyQueus>
    80001dd8:	97ba                	add	a5,a5,a4
    80001dda:	1407b483          	ld	s1,320(a5)
  pop_off();
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	e5a080e7          	jalr	-422(ra) # 80000c38 <pop_off>
  return p;
}
    80001de6:	8526                	mv	a0,s1
    80001de8:	60e2                	ld	ra,24(sp)
    80001dea:	6442                	ld	s0,16(sp)
    80001dec:	64a2                	ld	s1,8(sp)
    80001dee:	6105                	addi	sp,sp,32
    80001df0:	8082                	ret

0000000080001df2 <set_cpu>:
int set_cpu(int cpu_num){
    80001df2:	1101                	addi	sp,sp,-32
    80001df4:	ec06                	sd	ra,24(sp)
    80001df6:	e822                	sd	s0,16(sp)
    80001df8:	e426                	sd	s1,8(sp)
    80001dfa:	1000                	addi	s0,sp,32
    80001dfc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dfe:	00000097          	auipc	ra,0x0
    80001e02:	fb2080e7          	jalr	-78(ra) # 80001db0 <myproc>
  if(p == 0)
    80001e06:	c901                	beqz	a0,80001e16 <set_cpu+0x24>
  p->cpu = cpu_num; 
    80001e08:	d944                	sw	s1,52(a0)
  return cpu_num;
    80001e0a:	8526                	mv	a0,s1
}
    80001e0c:	60e2                	ld	ra,24(sp)
    80001e0e:	6442                	ld	s0,16(sp)
    80001e10:	64a2                	ld	s1,8(sp)
    80001e12:	6105                	addi	sp,sp,32
    80001e14:	8082                	ret
    return -1;
    80001e16:	557d                	li	a0,-1
    80001e18:	bfd5                	j	80001e0c <set_cpu+0x1a>

0000000080001e1a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001e1a:	1141                	addi	sp,sp,-16
    80001e1c:	e406                	sd	ra,8(sp)
    80001e1e:	e022                	sd	s0,0(sp)
    80001e20:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	f8e080e7          	jalr	-114(ra) # 80001db0 <myproc>
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	e6e080e7          	jalr	-402(ra) # 80000c98 <release>

  if (first) {
    80001e32:	00007797          	auipc	a5,0x7
    80001e36:	a7e7a783          	lw	a5,-1410(a5) # 800088b0 <first.1728>
    80001e3a:	eb89                	bnez	a5,80001e4c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001e3c:	00001097          	auipc	ra,0x1
    80001e40:	d42080e7          	jalr	-702(ra) # 80002b7e <usertrapret>
}
    80001e44:	60a2                	ld	ra,8(sp)
    80001e46:	6402                	ld	s0,0(sp)
    80001e48:	0141                	addi	sp,sp,16
    80001e4a:	8082                	ret
    first = 0;
    80001e4c:	00007797          	auipc	a5,0x7
    80001e50:	a607a223          	sw	zero,-1436(a5) # 800088b0 <first.1728>
    fsinit(ROOTDEV);
    80001e54:	4505                	li	a0,1
    80001e56:	00002097          	auipc	ra,0x2
    80001e5a:	a6a080e7          	jalr	-1430(ra) # 800038c0 <fsinit>
    80001e5e:	bff9                	j	80001e3c <forkret+0x22>

0000000080001e60 <allocpid>:
allocpid() {
    80001e60:	1101                	addi	sp,sp,-32
    80001e62:	ec06                	sd	ra,24(sp)
    80001e64:	e822                	sd	s0,16(sp)
    80001e66:	e426                	sd	s1,8(sp)
    80001e68:	e04a                	sd	s2,0(sp)
    80001e6a:	1000                	addi	s0,sp,32
    pid = nextpid; 
    80001e6c:	00007917          	auipc	s2,0x7
    80001e70:	a4890913          	addi	s2,s2,-1464 # 800088b4 <nextpid>
    80001e74:	00092483          	lw	s1,0(s2)
  }while(cas(&nextpid , pid , pid + 1)); 
    80001e78:	0014861b          	addiw	a2,s1,1
    80001e7c:	85a6                	mv	a1,s1
    80001e7e:	854a                	mv	a0,s2
    80001e80:	00005097          	auipc	ra,0x5
    80001e84:	846080e7          	jalr	-1978(ra) # 800066c6 <cas>
    80001e88:	f575                	bnez	a0,80001e74 <allocpid+0x14>
}
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	60e2                	ld	ra,24(sp)
    80001e8e:	6442                	ld	s0,16(sp)
    80001e90:	64a2                	ld	s1,8(sp)
    80001e92:	6902                	ld	s2,0(sp)
    80001e94:	6105                	addi	sp,sp,32
    80001e96:	8082                	ret

0000000080001e98 <proc_pagetable>:
{
    80001e98:	1101                	addi	sp,sp,-32
    80001e9a:	ec06                	sd	ra,24(sp)
    80001e9c:	e822                	sd	s0,16(sp)
    80001e9e:	e426                	sd	s1,8(sp)
    80001ea0:	e04a                	sd	s2,0(sp)
    80001ea2:	1000                	addi	s0,sp,32
    80001ea4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	494080e7          	jalr	1172(ra) # 8000133a <uvmcreate>
    80001eae:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001eb0:	c121                	beqz	a0,80001ef0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001eb2:	4729                	li	a4,10
    80001eb4:	00005697          	auipc	a3,0x5
    80001eb8:	14c68693          	addi	a3,a3,332 # 80007000 <_trampoline>
    80001ebc:	6605                	lui	a2,0x1
    80001ebe:	040005b7          	lui	a1,0x4000
    80001ec2:	15fd                	addi	a1,a1,-1
    80001ec4:	05b2                	slli	a1,a1,0xc
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	1ea080e7          	jalr	490(ra) # 800010b0 <mappages>
    80001ece:	02054863          	bltz	a0,80001efe <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ed2:	4719                	li	a4,6
    80001ed4:	08093683          	ld	a3,128(s2)
    80001ed8:	6605                	lui	a2,0x1
    80001eda:	020005b7          	lui	a1,0x2000
    80001ede:	15fd                	addi	a1,a1,-1
    80001ee0:	05b6                	slli	a1,a1,0xd
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	1cc080e7          	jalr	460(ra) # 800010b0 <mappages>
    80001eec:	02054163          	bltz	a0,80001f0e <proc_pagetable+0x76>
}
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	60e2                	ld	ra,24(sp)
    80001ef4:	6442                	ld	s0,16(sp)
    80001ef6:	64a2                	ld	s1,8(sp)
    80001ef8:	6902                	ld	s2,0(sp)
    80001efa:	6105                	addi	sp,sp,32
    80001efc:	8082                	ret
    uvmfree(pagetable, 0);
    80001efe:	4581                	li	a1,0
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	634080e7          	jalr	1588(ra) # 80001536 <uvmfree>
    return 0;
    80001f0a:	4481                	li	s1,0
    80001f0c:	b7d5                	j	80001ef0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f0e:	4681                	li	a3,0
    80001f10:	4605                	li	a2,1
    80001f12:	040005b7          	lui	a1,0x4000
    80001f16:	15fd                	addi	a1,a1,-1
    80001f18:	05b2                	slli	a1,a1,0xc
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	35a080e7          	jalr	858(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f24:	4581                	li	a1,0
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	60e080e7          	jalr	1550(ra) # 80001536 <uvmfree>
    return 0;
    80001f30:	4481                	li	s1,0
    80001f32:	bf7d                	j	80001ef0 <proc_pagetable+0x58>

0000000080001f34 <proc_freepagetable>:
{
    80001f34:	1101                	addi	sp,sp,-32
    80001f36:	ec06                	sd	ra,24(sp)
    80001f38:	e822                	sd	s0,16(sp)
    80001f3a:	e426                	sd	s1,8(sp)
    80001f3c:	e04a                	sd	s2,0(sp)
    80001f3e:	1000                	addi	s0,sp,32
    80001f40:	84aa                	mv	s1,a0
    80001f42:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f44:	4681                	li	a3,0
    80001f46:	4605                	li	a2,1
    80001f48:	040005b7          	lui	a1,0x4000
    80001f4c:	15fd                	addi	a1,a1,-1
    80001f4e:	05b2                	slli	a1,a1,0xc
    80001f50:	fffff097          	auipc	ra,0xfffff
    80001f54:	326080e7          	jalr	806(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f58:	4681                	li	a3,0
    80001f5a:	4605                	li	a2,1
    80001f5c:	020005b7          	lui	a1,0x2000
    80001f60:	15fd                	addi	a1,a1,-1
    80001f62:	05b6                	slli	a1,a1,0xd
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	310080e7          	jalr	784(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f6e:	85ca                	mv	a1,s2
    80001f70:	8526                	mv	a0,s1
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	5c4080e7          	jalr	1476(ra) # 80001536 <uvmfree>
}
    80001f7a:	60e2                	ld	ra,24(sp)
    80001f7c:	6442                	ld	s0,16(sp)
    80001f7e:	64a2                	ld	s1,8(sp)
    80001f80:	6902                	ld	s2,0(sp)
    80001f82:	6105                	addi	sp,sp,32
    80001f84:	8082                	ret

0000000080001f86 <freeproc>:
{
    80001f86:	1101                	addi	sp,sp,-32
    80001f88:	ec06                	sd	ra,24(sp)
    80001f8a:	e822                	sd	s0,16(sp)
    80001f8c:	e426                	sd	s1,8(sp)
    80001f8e:	1000                	addi	s0,sp,32
    80001f90:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f92:	6148                	ld	a0,128(a0)
    80001f94:	c509                	beqz	a0,80001f9e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	a62080e7          	jalr	-1438(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001f9e:	0804b023          	sd	zero,128(s1)
  if(p->pagetable)
    80001fa2:	7ca8                	ld	a0,120(s1)
    80001fa4:	c511                	beqz	a0,80001fb0 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001fa6:	78ac                	ld	a1,112(s1)
    80001fa8:	00000097          	auipc	ra,0x0
    80001fac:	f8c080e7          	jalr	-116(ra) # 80001f34 <proc_freepagetable>
  p->pagetable = 0;
    80001fb0:	0604bc23          	sd	zero,120(s1)
  p->sz = 0;
    80001fb4:	0604b823          	sd	zero,112(s1)
  p->pid = 0;
    80001fb8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001fbc:	0604b023          	sd	zero,96(s1)
  p->name[0] = 0;
    80001fc0:	18048023          	sb	zero,384(s1)
  p->chan = 0;
    80001fc4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001fc8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001fcc:	0204a623          	sw	zero,44(s1)
  p->next = 0;
    80001fd0:	0204bc23          	sd	zero,56(s1)
  p->cpu = 0;
    80001fd4:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001fd8:	0004ac23          	sw	zero,24(s1)
}
    80001fdc:	60e2                	ld	ra,24(sp)
    80001fde:	6442                	ld	s0,16(sp)
    80001fe0:	64a2                	ld	s1,8(sp)
    80001fe2:	6105                	addi	sp,sp,32
    80001fe4:	8082                	ret

0000000080001fe6 <allocproc>:
{
    80001fe6:	7179                	addi	sp,sp,-48
    80001fe8:	f406                	sd	ra,40(sp)
    80001fea:	f022                	sd	s0,32(sp)
    80001fec:	ec26                	sd	s1,24(sp)
    80001fee:	e84a                	sd	s2,16(sp)
    80001ff0:	e44e                	sd	s3,8(sp)
    80001ff2:	1800                	addi	s0,sp,48
  p = remove2(&unusing);
    80001ff4:	00010517          	auipc	a0,0x10
    80001ff8:	87c50513          	addi	a0,a0,-1924 # 80011870 <unusing>
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	930080e7          	jalr	-1744(ra) # 8000192c <remove2>
    80002004:	84aa                	mv	s1,a0
  if(p == 0)
    80002006:	cd29                	beqz	a0,80002060 <allocproc+0x7a>
  acquire(&p->lock);
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	bdc080e7          	jalr	-1060(ra) # 80000be4 <acquire>
  p->pid = allocpid();
    80002010:	00000097          	auipc	ra,0x0
    80002014:	e50080e7          	jalr	-432(ra) # 80001e60 <allocpid>
    80002018:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000201a:	4785                	li	a5,1
    8000201c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	ad6080e7          	jalr	-1322(ra) # 80000af4 <kalloc>
    80002026:	892a                	mv	s2,a0
    80002028:	e0c8                	sd	a0,128(s1)
    8000202a:	c139                	beqz	a0,80002070 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    8000202c:	8526                	mv	a0,s1
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	e6a080e7          	jalr	-406(ra) # 80001e98 <proc_pagetable>
    80002036:	892a                	mv	s2,a0
    80002038:	fca8                	sd	a0,120(s1)
  if(p->pagetable == 0){
    8000203a:	c539                	beqz	a0,80002088 <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    8000203c:	07000613          	li	a2,112
    80002040:	4581                	li	a1,0
    80002042:	08848513          	addi	a0,s1,136
    80002046:	fffff097          	auipc	ra,0xfffff
    8000204a:	c9a080e7          	jalr	-870(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    8000204e:	00000797          	auipc	a5,0x0
    80002052:	dcc78793          	addi	a5,a5,-564 # 80001e1a <forkret>
    80002056:	e4dc                	sd	a5,136(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002058:	74bc                	ld	a5,104(s1)
    8000205a:	6705                	lui	a4,0x1
    8000205c:	97ba                	add	a5,a5,a4
    8000205e:	e8dc                	sd	a5,144(s1)
}
    80002060:	8526                	mv	a0,s1
    80002062:	70a2                	ld	ra,40(sp)
    80002064:	7402                	ld	s0,32(sp)
    80002066:	64e2                	ld	s1,24(sp)
    80002068:	6942                	ld	s2,16(sp)
    8000206a:	69a2                	ld	s3,8(sp)
    8000206c:	6145                	addi	sp,sp,48
    8000206e:	8082                	ret
    freeproc(p);
    80002070:	8526                	mv	a0,s1
    80002072:	00000097          	auipc	ra,0x0
    80002076:	f14080e7          	jalr	-236(ra) # 80001f86 <freeproc>
    release(&p->lock);
    8000207a:	8526                	mv	a0,s1
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	c1c080e7          	jalr	-996(ra) # 80000c98 <release>
    return 0;
    80002084:	84ca                	mv	s1,s2
    80002086:	bfe9                	j	80002060 <allocproc+0x7a>
    freeproc(p);
    80002088:	8526                	mv	a0,s1
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	efc080e7          	jalr	-260(ra) # 80001f86 <freeproc>
    release(&p->lock);
    80002092:	8526                	mv	a0,s1
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	c04080e7          	jalr	-1020(ra) # 80000c98 <release>
    return 0;
    8000209c:	84ca                	mv	s1,s2
    8000209e:	b7c9                	j	80002060 <allocproc+0x7a>

00000000800020a0 <userinit>:
{
    800020a0:	1101                	addi	sp,sp,-32
    800020a2:	ec06                	sd	ra,24(sp)
    800020a4:	e822                	sd	s0,16(sp)
    800020a6:	e426                	sd	s1,8(sp)
    800020a8:	1000                	addi	s0,sp,32
  p = allocproc();
    800020aa:	00000097          	auipc	ra,0x0
    800020ae:	f3c080e7          	jalr	-196(ra) # 80001fe6 <allocproc>
    800020b2:	84aa                	mv	s1,a0
  initproc = p;
    800020b4:	00007797          	auipc	a5,0x7
    800020b8:	f6a7ba23          	sd	a0,-140(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800020bc:	03400613          	li	a2,52
    800020c0:	00007597          	auipc	a1,0x7
    800020c4:	80058593          	addi	a1,a1,-2048 # 800088c0 <initcode>
    800020c8:	7d28                	ld	a0,120(a0)
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	29e080e7          	jalr	670(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    800020d2:	6785                	lui	a5,0x1
    800020d4:	f8bc                	sd	a5,112(s1)
  p->trapframe->epc = 0;      // user program counter
    800020d6:	60d8                	ld	a4,128(s1)
    800020d8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800020dc:	60d8                	ld	a4,128(s1)
    800020de:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800020e0:	4641                	li	a2,16
    800020e2:	00006597          	auipc	a1,0x6
    800020e6:	18658593          	addi	a1,a1,390 # 80008268 <digits+0x228>
    800020ea:	18048513          	addi	a0,s1,384
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	d44080e7          	jalr	-700(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    800020f6:	00006517          	auipc	a0,0x6
    800020fa:	18250513          	addi	a0,a0,386 # 80008278 <digits+0x238>
    800020fe:	00002097          	auipc	ra,0x2
    80002102:	1f0080e7          	jalr	496(ra) # 800042ee <namei>
    80002106:	16a4bc23          	sd	a0,376(s1)
  p->state = RUNNABLE;
    8000210a:	478d                	li	a5,3
    8000210c:	cc9c                	sw	a5,24(s1)
  add2(&readyQueus[p->cpu] , p->index );
    8000210e:	58c8                	lw	a0,52(s1)
    80002110:	00251793          	slli	a5,a0,0x2
    80002114:	97aa                	add	a5,a5,a0
    80002116:	078e                	slli	a5,a5,0x3
    80002118:	40ac                	lw	a1,64(s1)
    8000211a:	0000f517          	auipc	a0,0xf
    8000211e:	18650513          	addi	a0,a0,390 # 800112a0 <readyQueus>
    80002122:	953e                	add	a0,a0,a5
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	71a080e7          	jalr	1818(ra) # 8000183e <add2>
  release(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	b6a080e7          	jalr	-1174(ra) # 80000c98 <release>
}
    80002136:	60e2                	ld	ra,24(sp)
    80002138:	6442                	ld	s0,16(sp)
    8000213a:	64a2                	ld	s1,8(sp)
    8000213c:	6105                	addi	sp,sp,32
    8000213e:	8082                	ret

0000000080002140 <growproc>:
{
    80002140:	1101                	addi	sp,sp,-32
    80002142:	ec06                	sd	ra,24(sp)
    80002144:	e822                	sd	s0,16(sp)
    80002146:	e426                	sd	s1,8(sp)
    80002148:	e04a                	sd	s2,0(sp)
    8000214a:	1000                	addi	s0,sp,32
    8000214c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	c62080e7          	jalr	-926(ra) # 80001db0 <myproc>
    80002156:	892a                	mv	s2,a0
  sz = p->sz;
    80002158:	792c                	ld	a1,112(a0)
    8000215a:	0005861b          	sext.w	a2,a1
  if(n > 0){
    8000215e:	00904f63          	bgtz	s1,8000217c <growproc+0x3c>
  } else if(n < 0){
    80002162:	0204cc63          	bltz	s1,8000219a <growproc+0x5a>
  p->sz = sz;
    80002166:	1602                	slli	a2,a2,0x20
    80002168:	9201                	srli	a2,a2,0x20
    8000216a:	06c93823          	sd	a2,112(s2)
  return 0;
    8000216e:	4501                	li	a0,0
}
    80002170:	60e2                	ld	ra,24(sp)
    80002172:	6442                	ld	s0,16(sp)
    80002174:	64a2                	ld	s1,8(sp)
    80002176:	6902                	ld	s2,0(sp)
    80002178:	6105                	addi	sp,sp,32
    8000217a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000217c:	9e25                	addw	a2,a2,s1
    8000217e:	1602                	slli	a2,a2,0x20
    80002180:	9201                	srli	a2,a2,0x20
    80002182:	1582                	slli	a1,a1,0x20
    80002184:	9181                	srli	a1,a1,0x20
    80002186:	7d28                	ld	a0,120(a0)
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	29a080e7          	jalr	666(ra) # 80001422 <uvmalloc>
    80002190:	0005061b          	sext.w	a2,a0
    80002194:	fa69                	bnez	a2,80002166 <growproc+0x26>
      return -1;
    80002196:	557d                	li	a0,-1
    80002198:	bfe1                	j	80002170 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000219a:	9e25                	addw	a2,a2,s1
    8000219c:	1602                	slli	a2,a2,0x20
    8000219e:	9201                	srli	a2,a2,0x20
    800021a0:	1582                	slli	a1,a1,0x20
    800021a2:	9181                	srli	a1,a1,0x20
    800021a4:	7d28                	ld	a0,120(a0)
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	234080e7          	jalr	564(ra) # 800013da <uvmdealloc>
    800021ae:	0005061b          	sext.w	a2,a0
    800021b2:	bf55                	j	80002166 <growproc+0x26>

00000000800021b4 <fork>:
{
    800021b4:	7179                	addi	sp,sp,-48
    800021b6:	f406                	sd	ra,40(sp)
    800021b8:	f022                	sd	s0,32(sp)
    800021ba:	ec26                	sd	s1,24(sp)
    800021bc:	e84a                	sd	s2,16(sp)
    800021be:	e44e                	sd	s3,8(sp)
    800021c0:	e052                	sd	s4,0(sp)
    800021c2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	bec080e7          	jalr	-1044(ra) # 80001db0 <myproc>
    800021cc:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    800021ce:	00000097          	auipc	ra,0x0
    800021d2:	e18080e7          	jalr	-488(ra) # 80001fe6 <allocproc>
    800021d6:	14050063          	beqz	a0,80002316 <fork+0x162>
    800021da:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800021dc:	0709b603          	ld	a2,112(s3) # 4000070 <_entry-0x7bffff90>
    800021e0:	7d2c                	ld	a1,120(a0)
    800021e2:	0789b503          	ld	a0,120(s3)
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	388080e7          	jalr	904(ra) # 8000156e <uvmcopy>
    800021ee:	04054a63          	bltz	a0,80002242 <fork+0x8e>
  np->sz = p->sz;
    800021f2:	0709b783          	ld	a5,112(s3)
    800021f6:	06f93823          	sd	a5,112(s2)
  np->cpu = p->cpu;
    800021fa:	0349a783          	lw	a5,52(s3)
    800021fe:	02f92a23          	sw	a5,52(s2)
  *(np->trapframe) = *(p->trapframe);
    80002202:	0809b683          	ld	a3,128(s3)
    80002206:	87b6                	mv	a5,a3
    80002208:	08093703          	ld	a4,128(s2)
    8000220c:	12068693          	addi	a3,a3,288
    80002210:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002214:	6788                	ld	a0,8(a5)
    80002216:	6b8c                	ld	a1,16(a5)
    80002218:	6f90                	ld	a2,24(a5)
    8000221a:	01073023          	sd	a6,0(a4)
    8000221e:	e708                	sd	a0,8(a4)
    80002220:	eb0c                	sd	a1,16(a4)
    80002222:	ef10                	sd	a2,24(a4)
    80002224:	02078793          	addi	a5,a5,32
    80002228:	02070713          	addi	a4,a4,32
    8000222c:	fed792e3          	bne	a5,a3,80002210 <fork+0x5c>
  np->trapframe->a0 = 0;
    80002230:	08093783          	ld	a5,128(s2)
    80002234:	0607b823          	sd	zero,112(a5)
    80002238:	0f800493          	li	s1,248
  for(i = 0; i < NOFILE; i++)
    8000223c:	17800a13          	li	s4,376
    80002240:	a03d                	j	8000226e <fork+0xba>
    freeproc(np);
    80002242:	854a                	mv	a0,s2
    80002244:	00000097          	auipc	ra,0x0
    80002248:	d42080e7          	jalr	-702(ra) # 80001f86 <freeproc>
    release(&np->lock);
    8000224c:	854a                	mv	a0,s2
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	a4a080e7          	jalr	-1462(ra) # 80000c98 <release>
    return -1;
    80002256:	5a7d                	li	s4,-1
    80002258:	a075                	j	80002304 <fork+0x150>
      np->ofile[i] = filedup(p->ofile[i]);
    8000225a:	00002097          	auipc	ra,0x2
    8000225e:	72a080e7          	jalr	1834(ra) # 80004984 <filedup>
    80002262:	009907b3          	add	a5,s2,s1
    80002266:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002268:	04a1                	addi	s1,s1,8
    8000226a:	01448763          	beq	s1,s4,80002278 <fork+0xc4>
    if(p->ofile[i])
    8000226e:	009987b3          	add	a5,s3,s1
    80002272:	6388                	ld	a0,0(a5)
    80002274:	f17d                	bnez	a0,8000225a <fork+0xa6>
    80002276:	bfcd                	j	80002268 <fork+0xb4>
  np->cwd = idup(p->cwd);
    80002278:	1789b503          	ld	a0,376(s3)
    8000227c:	00002097          	auipc	ra,0x2
    80002280:	87e080e7          	jalr	-1922(ra) # 80003afa <idup>
    80002284:	16a93c23          	sd	a0,376(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002288:	4641                	li	a2,16
    8000228a:	18098593          	addi	a1,s3,384
    8000228e:	18090513          	addi	a0,s2,384
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	ba0080e7          	jalr	-1120(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    8000229a:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    8000229e:	854a                	mv	a0,s2
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	9f8080e7          	jalr	-1544(ra) # 80000c98 <release>
  acquire(&wait_lock);
    800022a8:	0000f497          	auipc	s1,0xf
    800022ac:	60848493          	addi	s1,s1,1544 # 800118b0 <wait_lock>
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	932080e7          	jalr	-1742(ra) # 80000be4 <acquire>
  np->parent = p;
    800022ba:	07393023          	sd	s3,96(s2)
  release(&wait_lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	9d8080e7          	jalr	-1576(ra) # 80000c98 <release>
  acquire(&np->lock);
    800022c8:	854a                	mv	a0,s2
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	91a080e7          	jalr	-1766(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    800022d2:	478d                	li	a5,3
    800022d4:	00f92c23          	sw	a5,24(s2)
  add2(&readyQueus[np->cpu], np->index);
    800022d8:	03492503          	lw	a0,52(s2)
    800022dc:	00251793          	slli	a5,a0,0x2
    800022e0:	97aa                	add	a5,a5,a0
    800022e2:	078e                	slli	a5,a5,0x3
    800022e4:	04092583          	lw	a1,64(s2)
    800022e8:	0000f517          	auipc	a0,0xf
    800022ec:	fb850513          	addi	a0,a0,-72 # 800112a0 <readyQueus>
    800022f0:	953e                	add	a0,a0,a5
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	54c080e7          	jalr	1356(ra) # 8000183e <add2>
  release(&np->lock);
    800022fa:	854a                	mv	a0,s2
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	99c080e7          	jalr	-1636(ra) # 80000c98 <release>
}
    80002304:	8552                	mv	a0,s4
    80002306:	70a2                	ld	ra,40(sp)
    80002308:	7402                	ld	s0,32(sp)
    8000230a:	64e2                	ld	s1,24(sp)
    8000230c:	6942                	ld	s2,16(sp)
    8000230e:	69a2                	ld	s3,8(sp)
    80002310:	6a02                	ld	s4,0(sp)
    80002312:	6145                	addi	sp,sp,48
    80002314:	8082                	ret
    return -1;
    80002316:	5a7d                	li	s4,-1
    80002318:	b7f5                	j	80002304 <fork+0x150>

000000008000231a <scheduler>:
{
    8000231a:	7139                	addi	sp,sp,-64
    8000231c:	fc06                	sd	ra,56(sp)
    8000231e:	f822                	sd	s0,48(sp)
    80002320:	f426                	sd	s1,40(sp)
    80002322:	f04a                	sd	s2,32(sp)
    80002324:	ec4e                	sd	s3,24(sp)
    80002326:	e852                	sd	s4,16(sp)
    80002328:	e456                	sd	s5,8(sp)
    8000232a:	0080                	addi	s0,sp,64
    8000232c:	8792                	mv	a5,tp
  int id = r_tp();
    8000232e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002330:	00479713          	slli	a4,a5,0x4
    80002334:	00f706b3          	add	a3,a4,a5
    80002338:	00369613          	slli	a2,a3,0x3
    8000233c:	0000f697          	auipc	a3,0xf
    80002340:	f6468693          	addi	a3,a3,-156 # 800112a0 <readyQueus>
    80002344:	96b2                	add	a3,a3,a2
    80002346:	1406b023          	sd	zero,320(a3)
    swtch(&c->context, &p->context);
    8000234a:	0000f717          	auipc	a4,0xf
    8000234e:	09e70713          	addi	a4,a4,158 # 800113e8 <cpus+0x8>
    80002352:	00e60a33          	add	s4,a2,a4
    p = remove2(&readyQueus[c->index]);
    80002356:	0000f997          	auipc	s3,0xf
    8000235a:	f4a98993          	addi	s3,s3,-182 # 800112a0 <readyQueus>
    8000235e:	8936                	mv	s2,a3
    p->state = RUNNING;
    80002360:	4a91                	li	s5,4
    80002362:	a815                	j	80002396 <scheduler+0x7c>
    acquire(&p->lock);
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	880080e7          	jalr	-1920(ra) # 80000be4 <acquire>
    p->state = RUNNING;
    8000236c:	0154ac23          	sw	s5,24(s1)
    p->cpu = c->index;
    80002370:	1c092783          	lw	a5,448(s2)
    80002374:	d8dc                	sw	a5,52(s1)
    c->proc = p;
    80002376:	14993023          	sd	s1,320(s2)
    swtch(&c->context, &p->context);
    8000237a:	08848593          	addi	a1,s1,136
    8000237e:	8552                	mv	a0,s4
    80002380:	00000097          	auipc	ra,0x0
    80002384:	754080e7          	jalr	1876(ra) # 80002ad4 <swtch>
    c->proc = 0;
    80002388:	14093023          	sd	zero,320(s2)
    release(&p->lock);
    8000238c:	8526                	mv	a0,s1
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	90a080e7          	jalr	-1782(ra) # 80000c98 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002396:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000239a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000239e:	10079073          	csrw	sstatus,a5
    p = remove2(&readyQueus[c->index]);
    800023a2:	1c092783          	lw	a5,448(s2)
    800023a6:	00279513          	slli	a0,a5,0x2
    800023aa:	953e                	add	a0,a0,a5
    800023ac:	050e                	slli	a0,a0,0x3
    800023ae:	954e                	add	a0,a0,s3
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	57c080e7          	jalr	1404(ra) # 8000192c <remove2>
    800023b8:	84aa                	mv	s1,a0
    }while(p == 0);
    800023ba:	f54d                	bnez	a0,80002364 <scheduler+0x4a>
    800023bc:	b7dd                	j	800023a2 <scheduler+0x88>

00000000800023be <sched>:
{
    800023be:	7179                	addi	sp,sp,-48
    800023c0:	f406                	sd	ra,40(sp)
    800023c2:	f022                	sd	s0,32(sp)
    800023c4:	ec26                	sd	s1,24(sp)
    800023c6:	e84a                	sd	s2,16(sp)
    800023c8:	e44e                	sd	s3,8(sp)
    800023ca:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023cc:	00000097          	auipc	ra,0x0
    800023d0:	9e4080e7          	jalr	-1564(ra) # 80001db0 <myproc>
    800023d4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	794080e7          	jalr	1940(ra) # 80000b6a <holding>
    800023de:	c959                	beqz	a0,80002474 <sched+0xb6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023e0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023e2:	0007871b          	sext.w	a4,a5
    800023e6:	00471793          	slli	a5,a4,0x4
    800023ea:	97ba                	add	a5,a5,a4
    800023ec:	078e                	slli	a5,a5,0x3
    800023ee:	0000f717          	auipc	a4,0xf
    800023f2:	eb270713          	addi	a4,a4,-334 # 800112a0 <readyQueus>
    800023f6:	97ba                	add	a5,a5,a4
    800023f8:	1b87a703          	lw	a4,440(a5)
    800023fc:	4785                	li	a5,1
    800023fe:	08f71363          	bne	a4,a5,80002484 <sched+0xc6>
  if(p->state == RUNNING)
    80002402:	4c98                	lw	a4,24(s1)
    80002404:	4791                	li	a5,4
    80002406:	08f70763          	beq	a4,a5,80002494 <sched+0xd6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000240e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002410:	ebd1                	bnez	a5,800024a4 <sched+0xe6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002412:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002414:	0000f917          	auipc	s2,0xf
    80002418:	e8c90913          	addi	s2,s2,-372 # 800112a0 <readyQueus>
    8000241c:	0007871b          	sext.w	a4,a5
    80002420:	00471793          	slli	a5,a4,0x4
    80002424:	97ba                	add	a5,a5,a4
    80002426:	078e                	slli	a5,a5,0x3
    80002428:	97ca                	add	a5,a5,s2
    8000242a:	1bc7a983          	lw	s3,444(a5)
    8000242e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002430:	0007859b          	sext.w	a1,a5
    80002434:	00459793          	slli	a5,a1,0x4
    80002438:	97ae                	add	a5,a5,a1
    8000243a:	078e                	slli	a5,a5,0x3
    8000243c:	0000f597          	auipc	a1,0xf
    80002440:	fac58593          	addi	a1,a1,-84 # 800113e8 <cpus+0x8>
    80002444:	95be                	add	a1,a1,a5
    80002446:	08848513          	addi	a0,s1,136
    8000244a:	00000097          	auipc	ra,0x0
    8000244e:	68a080e7          	jalr	1674(ra) # 80002ad4 <swtch>
    80002452:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002454:	0007871b          	sext.w	a4,a5
    80002458:	00471793          	slli	a5,a4,0x4
    8000245c:	97ba                	add	a5,a5,a4
    8000245e:	078e                	slli	a5,a5,0x3
    80002460:	97ca                	add	a5,a5,s2
    80002462:	1b37ae23          	sw	s3,444(a5)
}
    80002466:	70a2                	ld	ra,40(sp)
    80002468:	7402                	ld	s0,32(sp)
    8000246a:	64e2                	ld	s1,24(sp)
    8000246c:	6942                	ld	s2,16(sp)
    8000246e:	69a2                	ld	s3,8(sp)
    80002470:	6145                	addi	sp,sp,48
    80002472:	8082                	ret
    panic("sched p->lock");
    80002474:	00006517          	auipc	a0,0x6
    80002478:	e0c50513          	addi	a0,a0,-500 # 80008280 <digits+0x240>
    8000247c:	ffffe097          	auipc	ra,0xffffe
    80002480:	0c2080e7          	jalr	194(ra) # 8000053e <panic>
    panic("sched locks");
    80002484:	00006517          	auipc	a0,0x6
    80002488:	e0c50513          	addi	a0,a0,-500 # 80008290 <digits+0x250>
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	0b2080e7          	jalr	178(ra) # 8000053e <panic>
    panic("sched running");
    80002494:	00006517          	auipc	a0,0x6
    80002498:	e0c50513          	addi	a0,a0,-500 # 800082a0 <digits+0x260>
    8000249c:	ffffe097          	auipc	ra,0xffffe
    800024a0:	0a2080e7          	jalr	162(ra) # 8000053e <panic>
    panic("sched interruptible");
    800024a4:	00006517          	auipc	a0,0x6
    800024a8:	e0c50513          	addi	a0,a0,-500 # 800082b0 <digits+0x270>
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	092080e7          	jalr	146(ra) # 8000053e <panic>

00000000800024b4 <yield>:
{
    800024b4:	1101                	addi	sp,sp,-32
    800024b6:	ec06                	sd	ra,24(sp)
    800024b8:	e822                	sd	s0,16(sp)
    800024ba:	e426                	sd	s1,8(sp)
    800024bc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024be:	00000097          	auipc	ra,0x0
    800024c2:	8f2080e7          	jalr	-1806(ra) # 80001db0 <myproc>
    800024c6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	71c080e7          	jalr	1820(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    800024d0:	478d                	li	a5,3
    800024d2:	cc9c                	sw	a5,24(s1)
  add2(&readyQueus[p->cpu] , p->index);
    800024d4:	58c8                	lw	a0,52(s1)
    800024d6:	00251793          	slli	a5,a0,0x2
    800024da:	97aa                	add	a5,a5,a0
    800024dc:	078e                	slli	a5,a5,0x3
    800024de:	40ac                	lw	a1,64(s1)
    800024e0:	0000f517          	auipc	a0,0xf
    800024e4:	dc050513          	addi	a0,a0,-576 # 800112a0 <readyQueus>
    800024e8:	953e                	add	a0,a0,a5
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	354080e7          	jalr	852(ra) # 8000183e <add2>
  sched();
    800024f2:	00000097          	auipc	ra,0x0
    800024f6:	ecc080e7          	jalr	-308(ra) # 800023be <sched>
  release(&p->lock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	79c080e7          	jalr	1948(ra) # 80000c98 <release>
}
    80002504:	60e2                	ld	ra,24(sp)
    80002506:	6442                	ld	s0,16(sp)
    80002508:	64a2                	ld	s1,8(sp)
    8000250a:	6105                	addi	sp,sp,32
    8000250c:	8082                	ret

000000008000250e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000250e:	7179                	addi	sp,sp,-48
    80002510:	f406                	sd	ra,40(sp)
    80002512:	f022                	sd	s0,32(sp)
    80002514:	ec26                	sd	s1,24(sp)
    80002516:	e84a                	sd	s2,16(sp)
    80002518:	e44e                	sd	s3,8(sp)
    8000251a:	1800                	addi	s0,sp,48
    8000251c:	89aa                	mv	s3,a0
    8000251e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002520:	00000097          	auipc	ra,0x0
    80002524:	890080e7          	jalr	-1904(ra) # 80001db0 <myproc>
    80002528:	84aa                	mv	s1,a0
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  printf("B\n");
    8000252a:	00006517          	auipc	a0,0x6
    8000252e:	d9e50513          	addi	a0,a0,-610 # 800082c8 <digits+0x288>
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	056080e7          	jalr	86(ra) # 80000588 <printf>
  acquire(&p->lock);  //DOC: sleeplock1
    8000253a:	8526                	mv	a0,s1
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	6a8080e7          	jalr	1704(ra) # 80000be4 <acquire>
  release(lk);
    80002544:	854a                	mv	a0,s2
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	752080e7          	jalr	1874(ra) # 80000c98 <release>
printf("E\n");
    8000254e:	00006517          	auipc	a0,0x6
    80002552:	d8250513          	addi	a0,a0,-638 # 800082d0 <digits+0x290>
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	032080e7          	jalr	50(ra) # 80000588 <printf>
  // Go to sleep.
  p->chan = chan;
    8000255e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002562:	4789                	li	a5,2
    80002564:	cc9c                	sw	a5,24(s1)
printf("F\n");
    80002566:	00006517          	auipc	a0,0x6
    8000256a:	d7250513          	addi	a0,a0,-654 # 800082d8 <digits+0x298>
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	01a080e7          	jalr	26(ra) # 80000588 <printf>
  add2(&sleeping , p->index);
    80002576:	40ac                	lw	a1,64(s1)
    80002578:	0000f517          	auipc	a0,0xf
    8000257c:	2d050513          	addi	a0,a0,720 # 80011848 <sleeping>
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	2be080e7          	jalr	702(ra) # 8000183e <add2>
  //printList(&sleeping);
  printf("C\n");
    80002588:	00006517          	auipc	a0,0x6
    8000258c:	d5850513          	addi	a0,a0,-680 # 800082e0 <digits+0x2a0>
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	ff8080e7          	jalr	-8(ra) # 80000588 <printf>
  sched();
    80002598:	00000097          	auipc	ra,0x0
    8000259c:	e26080e7          	jalr	-474(ra) # 800023be <sched>
  printf("D\n");
    800025a0:	00006517          	auipc	a0,0x6
    800025a4:	d4850513          	addi	a0,a0,-696 # 800082e8 <digits+0x2a8>
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	fe0080e7          	jalr	-32(ra) # 80000588 <printf>
  // Tidy up.
  p->chan = 0;
    800025b0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800025b4:	8526                	mv	a0,s1
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	6e2080e7          	jalr	1762(ra) # 80000c98 <release>
  printf("A\n");
    800025be:	00006517          	auipc	a0,0x6
    800025c2:	d3250513          	addi	a0,a0,-718 # 800082f0 <digits+0x2b0>
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	fc2080e7          	jalr	-62(ra) # 80000588 <printf>
  acquire(lk);
    800025ce:	854a                	mv	a0,s2
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	614080e7          	jalr	1556(ra) # 80000be4 <acquire>
  
}
    800025d8:	70a2                	ld	ra,40(sp)
    800025da:	7402                	ld	s0,32(sp)
    800025dc:	64e2                	ld	s1,24(sp)
    800025de:	6942                	ld	s2,16(sp)
    800025e0:	69a2                	ld	s3,8(sp)
    800025e2:	6145                	addi	sp,sp,48
    800025e4:	8082                	ret

00000000800025e6 <wait>:
{
    800025e6:	715d                	addi	sp,sp,-80
    800025e8:	e486                	sd	ra,72(sp)
    800025ea:	e0a2                	sd	s0,64(sp)
    800025ec:	fc26                	sd	s1,56(sp)
    800025ee:	f84a                	sd	s2,48(sp)
    800025f0:	f44e                	sd	s3,40(sp)
    800025f2:	f052                	sd	s4,32(sp)
    800025f4:	ec56                	sd	s5,24(sp)
    800025f6:	e85a                	sd	s6,16(sp)
    800025f8:	e45e                	sd	s7,8(sp)
    800025fa:	e062                	sd	s8,0(sp)
    800025fc:	0880                	addi	s0,sp,80
    800025fe:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002600:	fffff097          	auipc	ra,0xfffff
    80002604:	7b0080e7          	jalr	1968(ra) # 80001db0 <myproc>
    80002608:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000260a:	0000f517          	auipc	a0,0xf
    8000260e:	2a650513          	addi	a0,a0,678 # 800118b0 <wait_lock>
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	5d2080e7          	jalr	1490(ra) # 80000be4 <acquire>
    havekids = 0;
    8000261a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000261c:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    8000261e:	00015997          	auipc	s3,0x15
    80002622:	6aa98993          	addi	s3,s3,1706 # 80017cc8 <tickslock>
        havekids = 1;
    80002626:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002628:	0000fc17          	auipc	s8,0xf
    8000262c:	288c0c13          	addi	s8,s8,648 # 800118b0 <wait_lock>
    havekids = 0;
    80002630:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002632:	0000f497          	auipc	s1,0xf
    80002636:	29648493          	addi	s1,s1,662 # 800118c8 <proc>
    8000263a:	a0bd                	j	800026a8 <wait+0xc2>
          pid = np->pid;
    8000263c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002640:	000b0e63          	beqz	s6,8000265c <wait+0x76>
    80002644:	4691                	li	a3,4
    80002646:	02c48613          	addi	a2,s1,44
    8000264a:	85da                	mv	a1,s6
    8000264c:	07893503          	ld	a0,120(s2)
    80002650:	fffff097          	auipc	ra,0xfffff
    80002654:	022080e7          	jalr	34(ra) # 80001672 <copyout>
    80002658:	02054563          	bltz	a0,80002682 <wait+0x9c>
          freeproc(np);
    8000265c:	8526                	mv	a0,s1
    8000265e:	00000097          	auipc	ra,0x0
    80002662:	928080e7          	jalr	-1752(ra) # 80001f86 <freeproc>
          release(&np->lock);
    80002666:	8526                	mv	a0,s1
    80002668:	ffffe097          	auipc	ra,0xffffe
    8000266c:	630080e7          	jalr	1584(ra) # 80000c98 <release>
          release(&wait_lock);
    80002670:	0000f517          	auipc	a0,0xf
    80002674:	24050513          	addi	a0,a0,576 # 800118b0 <wait_lock>
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	620080e7          	jalr	1568(ra) # 80000c98 <release>
          return pid;
    80002680:	a09d                	j	800026e6 <wait+0x100>
            release(&np->lock);
    80002682:	8526                	mv	a0,s1
    80002684:	ffffe097          	auipc	ra,0xffffe
    80002688:	614080e7          	jalr	1556(ra) # 80000c98 <release>
            release(&wait_lock);
    8000268c:	0000f517          	auipc	a0,0xf
    80002690:	22450513          	addi	a0,a0,548 # 800118b0 <wait_lock>
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	604080e7          	jalr	1540(ra) # 80000c98 <release>
            return -1;
    8000269c:	59fd                	li	s3,-1
    8000269e:	a0a1                	j	800026e6 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800026a0:	19048493          	addi	s1,s1,400
    800026a4:	03348463          	beq	s1,s3,800026cc <wait+0xe6>
      if(np->parent == p){
    800026a8:	70bc                	ld	a5,96(s1)
    800026aa:	ff279be3          	bne	a5,s2,800026a0 <wait+0xba>
        acquire(&np->lock);
    800026ae:	8526                	mv	a0,s1
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	534080e7          	jalr	1332(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    800026b8:	4c9c                	lw	a5,24(s1)
    800026ba:	f94781e3          	beq	a5,s4,8000263c <wait+0x56>
        release(&np->lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	5d8080e7          	jalr	1496(ra) # 80000c98 <release>
        havekids = 1;
    800026c8:	8756                	mv	a4,s5
    800026ca:	bfd9                	j	800026a0 <wait+0xba>
    if(!havekids || p->killed){
    800026cc:	c701                	beqz	a4,800026d4 <wait+0xee>
    800026ce:	02892783          	lw	a5,40(s2)
    800026d2:	c79d                	beqz	a5,80002700 <wait+0x11a>
      release(&wait_lock);
    800026d4:	0000f517          	auipc	a0,0xf
    800026d8:	1dc50513          	addi	a0,a0,476 # 800118b0 <wait_lock>
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	5bc080e7          	jalr	1468(ra) # 80000c98 <release>
      return -1;
    800026e4:	59fd                	li	s3,-1
}
    800026e6:	854e                	mv	a0,s3
    800026e8:	60a6                	ld	ra,72(sp)
    800026ea:	6406                	ld	s0,64(sp)
    800026ec:	74e2                	ld	s1,56(sp)
    800026ee:	7942                	ld	s2,48(sp)
    800026f0:	79a2                	ld	s3,40(sp)
    800026f2:	7a02                	ld	s4,32(sp)
    800026f4:	6ae2                	ld	s5,24(sp)
    800026f6:	6b42                	ld	s6,16(sp)
    800026f8:	6ba2                	ld	s7,8(sp)
    800026fa:	6c02                	ld	s8,0(sp)
    800026fc:	6161                	addi	sp,sp,80
    800026fe:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002700:	85e2                	mv	a1,s8
    80002702:	854a                	mv	a0,s2
    80002704:	00000097          	auipc	ra,0x0
    80002708:	e0a080e7          	jalr	-502(ra) # 8000250e <sleep>
    havekids = 0;
    8000270c:	b715                	j	80002630 <wait+0x4a>

000000008000270e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000270e:	7139                	addi	sp,sp,-64
    80002710:	fc06                	sd	ra,56(sp)
    80002712:	f822                	sd	s0,48(sp)
    80002714:	f426                	sd	s1,40(sp)
    80002716:	f04a                	sd	s2,32(sp)
    80002718:	ec4e                	sd	s3,24(sp)
    8000271a:	e852                	sd	s4,16(sp)
    8000271c:	e456                	sd	s5,8(sp)
    8000271e:	e05a                	sd	s6,0(sp)
    80002720:	0080                	addi	s0,sp,64
    80002722:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002724:	0000f497          	auipc	s1,0xf
    80002728:	1a448493          	addi	s1,s1,420 # 800118c8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000272c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000272e:	4b0d                	li	s6,3
        add2(&readyQueus[p->cpu] , p->index);
    80002730:	0000fa97          	auipc	s5,0xf
    80002734:	b70a8a93          	addi	s5,s5,-1168 # 800112a0 <readyQueus>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002738:	00015917          	auipc	s2,0x15
    8000273c:	59090913          	addi	s2,s2,1424 # 80017cc8 <tickslock>
    80002740:	a811                	j	80002754 <wakeup+0x46>
      }
      release(&p->lock);
    80002742:	8526                	mv	a0,s1
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	554080e7          	jalr	1364(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000274c:	19048493          	addi	s1,s1,400
    80002750:	05248163          	beq	s1,s2,80002792 <wakeup+0x84>
    if(p != myproc()){
    80002754:	fffff097          	auipc	ra,0xfffff
    80002758:	65c080e7          	jalr	1628(ra) # 80001db0 <myproc>
    8000275c:	fea488e3          	beq	s1,a0,8000274c <wakeup+0x3e>
      acquire(&p->lock);
    80002760:	8526                	mv	a0,s1
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	482080e7          	jalr	1154(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000276a:	4c9c                	lw	a5,24(s1)
    8000276c:	fd379be3          	bne	a5,s3,80002742 <wakeup+0x34>
    80002770:	709c                	ld	a5,32(s1)
    80002772:	fd4798e3          	bne	a5,s4,80002742 <wakeup+0x34>
        p->state = RUNNABLE;
    80002776:	0164ac23          	sw	s6,24(s1)
        add2(&readyQueus[p->cpu] , p->index);
    8000277a:	58dc                	lw	a5,52(s1)
    8000277c:	00279513          	slli	a0,a5,0x2
    80002780:	953e                	add	a0,a0,a5
    80002782:	050e                	slli	a0,a0,0x3
    80002784:	40ac                	lw	a1,64(s1)
    80002786:	9556                	add	a0,a0,s5
    80002788:	fffff097          	auipc	ra,0xfffff
    8000278c:	0b6080e7          	jalr	182(ra) # 8000183e <add2>
    80002790:	bf4d                	j	80002742 <wakeup+0x34>
    }
  }
}
    80002792:	70e2                	ld	ra,56(sp)
    80002794:	7442                	ld	s0,48(sp)
    80002796:	74a2                	ld	s1,40(sp)
    80002798:	7902                	ld	s2,32(sp)
    8000279a:	69e2                	ld	s3,24(sp)
    8000279c:	6a42                	ld	s4,16(sp)
    8000279e:	6aa2                	ld	s5,8(sp)
    800027a0:	6b02                	ld	s6,0(sp)
    800027a2:	6121                	addi	sp,sp,64
    800027a4:	8082                	ret

00000000800027a6 <reparent>:
{
    800027a6:	7179                	addi	sp,sp,-48
    800027a8:	f406                	sd	ra,40(sp)
    800027aa:	f022                	sd	s0,32(sp)
    800027ac:	ec26                	sd	s1,24(sp)
    800027ae:	e84a                	sd	s2,16(sp)
    800027b0:	e44e                	sd	s3,8(sp)
    800027b2:	e052                	sd	s4,0(sp)
    800027b4:	1800                	addi	s0,sp,48
    800027b6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027b8:	0000f497          	auipc	s1,0xf
    800027bc:	11048493          	addi	s1,s1,272 # 800118c8 <proc>
      pp->parent = initproc;
    800027c0:	00007a17          	auipc	s4,0x7
    800027c4:	868a0a13          	addi	s4,s4,-1944 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027c8:	00015997          	auipc	s3,0x15
    800027cc:	50098993          	addi	s3,s3,1280 # 80017cc8 <tickslock>
    800027d0:	a029                	j	800027da <reparent+0x34>
    800027d2:	19048493          	addi	s1,s1,400
    800027d6:	01348d63          	beq	s1,s3,800027f0 <reparent+0x4a>
    if(pp->parent == p){
    800027da:	70bc                	ld	a5,96(s1)
    800027dc:	ff279be3          	bne	a5,s2,800027d2 <reparent+0x2c>
      pp->parent = initproc;
    800027e0:	000a3503          	ld	a0,0(s4)
    800027e4:	f0a8                	sd	a0,96(s1)
      wakeup(initproc);
    800027e6:	00000097          	auipc	ra,0x0
    800027ea:	f28080e7          	jalr	-216(ra) # 8000270e <wakeup>
    800027ee:	b7d5                	j	800027d2 <reparent+0x2c>
}
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	69a2                	ld	s3,8(sp)
    800027fa:	6a02                	ld	s4,0(sp)
    800027fc:	6145                	addi	sp,sp,48
    800027fe:	8082                	ret

0000000080002800 <exit>:
{
    80002800:	7179                	addi	sp,sp,-48
    80002802:	f406                	sd	ra,40(sp)
    80002804:	f022                	sd	s0,32(sp)
    80002806:	ec26                	sd	s1,24(sp)
    80002808:	e84a                	sd	s2,16(sp)
    8000280a:	e44e                	sd	s3,8(sp)
    8000280c:	e052                	sd	s4,0(sp)
    8000280e:	1800                	addi	s0,sp,48
    80002810:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	59e080e7          	jalr	1438(ra) # 80001db0 <myproc>
    8000281a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000281c:	00007797          	auipc	a5,0x7
    80002820:	80c7b783          	ld	a5,-2036(a5) # 80009028 <initproc>
    80002824:	0f850493          	addi	s1,a0,248
    80002828:	17850913          	addi	s2,a0,376
    8000282c:	02a79363          	bne	a5,a0,80002852 <exit+0x52>
    panic("init exiting");
    80002830:	00006517          	auipc	a0,0x6
    80002834:	ac850513          	addi	a0,a0,-1336 # 800082f8 <digits+0x2b8>
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	d06080e7          	jalr	-762(ra) # 8000053e <panic>
      fileclose(f);
    80002840:	00002097          	auipc	ra,0x2
    80002844:	196080e7          	jalr	406(ra) # 800049d6 <fileclose>
      p->ofile[fd] = 0;
    80002848:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000284c:	04a1                	addi	s1,s1,8
    8000284e:	01248563          	beq	s1,s2,80002858 <exit+0x58>
    if(p->ofile[fd]){
    80002852:	6088                	ld	a0,0(s1)
    80002854:	f575                	bnez	a0,80002840 <exit+0x40>
    80002856:	bfdd                	j	8000284c <exit+0x4c>
  begin_op();
    80002858:	00002097          	auipc	ra,0x2
    8000285c:	cb2080e7          	jalr	-846(ra) # 8000450a <begin_op>
  iput(p->cwd);
    80002860:	1789b503          	ld	a0,376(s3)
    80002864:	00001097          	auipc	ra,0x1
    80002868:	48e080e7          	jalr	1166(ra) # 80003cf2 <iput>
  end_op();
    8000286c:	00002097          	auipc	ra,0x2
    80002870:	d1e080e7          	jalr	-738(ra) # 8000458a <end_op>
  p->cwd = 0;
    80002874:	1609bc23          	sd	zero,376(s3)
  acquire(&wait_lock);
    80002878:	0000f497          	auipc	s1,0xf
    8000287c:	03848493          	addi	s1,s1,56 # 800118b0 <wait_lock>
    80002880:	8526                	mv	a0,s1
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	362080e7          	jalr	866(ra) # 80000be4 <acquire>
  reparent(p);
    8000288a:	854e                	mv	a0,s3
    8000288c:	00000097          	auipc	ra,0x0
    80002890:	f1a080e7          	jalr	-230(ra) # 800027a6 <reparent>
  wakeup(p->parent);
    80002894:	0609b503          	ld	a0,96(s3)
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	e76080e7          	jalr	-394(ra) # 8000270e <wakeup>
  acquire(&p->lock);
    800028a0:	854e                	mv	a0,s3
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	342080e7          	jalr	834(ra) # 80000be4 <acquire>
  p->xstate = status;
    800028aa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800028ae:	4795                	li	a5,5
    800028b0:	00f9ac23          	sw	a5,24(s3)
  add2(&zombies , p->index); 
    800028b4:	0409a583          	lw	a1,64(s3)
    800028b8:	0000f517          	auipc	a0,0xf
    800028bc:	f6850513          	addi	a0,a0,-152 # 80011820 <zombies>
    800028c0:	fffff097          	auipc	ra,0xfffff
    800028c4:	f7e080e7          	jalr	-130(ra) # 8000183e <add2>
  release(&wait_lock);
    800028c8:	8526                	mv	a0,s1
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	3ce080e7          	jalr	974(ra) # 80000c98 <release>
  sched();
    800028d2:	00000097          	auipc	ra,0x0
    800028d6:	aec080e7          	jalr	-1300(ra) # 800023be <sched>
  panic("zombie exit");
    800028da:	00006517          	auipc	a0,0x6
    800028de:	a2e50513          	addi	a0,a0,-1490 # 80008308 <digits+0x2c8>
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	c5c080e7          	jalr	-932(ra) # 8000053e <panic>

00000000800028ea <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800028ea:	7179                	addi	sp,sp,-48
    800028ec:	f406                	sd	ra,40(sp)
    800028ee:	f022                	sd	s0,32(sp)
    800028f0:	ec26                	sd	s1,24(sp)
    800028f2:	e84a                	sd	s2,16(sp)
    800028f4:	e44e                	sd	s3,8(sp)
    800028f6:	1800                	addi	s0,sp,48
    800028f8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800028fa:	0000f497          	auipc	s1,0xf
    800028fe:	fce48493          	addi	s1,s1,-50 # 800118c8 <proc>
    80002902:	00015997          	auipc	s3,0x15
    80002906:	3c698993          	addi	s3,s3,966 # 80017cc8 <tickslock>
    acquire(&p->lock);
    8000290a:	8526                	mv	a0,s1
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	2d8080e7          	jalr	728(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    80002914:	589c                	lw	a5,48(s1)
    80002916:	01278d63          	beq	a5,s2,80002930 <kill+0x46>
        add2(&readyQueus[p->cpu] , p->index); 
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000291a:	8526                	mv	a0,s1
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	37c080e7          	jalr	892(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002924:	19048493          	addi	s1,s1,400
    80002928:	ff3491e3          	bne	s1,s3,8000290a <kill+0x20>
  }
  return -1;
    8000292c:	557d                	li	a0,-1
    8000292e:	a829                	j	80002948 <kill+0x5e>
      p->killed = 1;
    80002930:	4785                	li	a5,1
    80002932:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002934:	4c98                	lw	a4,24(s1)
    80002936:	4789                	li	a5,2
    80002938:	00f70f63          	beq	a4,a5,80002956 <kill+0x6c>
      release(&p->lock);
    8000293c:	8526                	mv	a0,s1
    8000293e:	ffffe097          	auipc	ra,0xffffe
    80002942:	35a080e7          	jalr	858(ra) # 80000c98 <release>
      return 0;
    80002946:	4501                	li	a0,0
}
    80002948:	70a2                	ld	ra,40(sp)
    8000294a:	7402                	ld	s0,32(sp)
    8000294c:	64e2                	ld	s1,24(sp)
    8000294e:	6942                	ld	s2,16(sp)
    80002950:	69a2                	ld	s3,8(sp)
    80002952:	6145                	addi	sp,sp,48
    80002954:	8082                	ret
        p->state = RUNNABLE;
    80002956:	478d                	li	a5,3
    80002958:	cc9c                	sw	a5,24(s1)
        add2(&readyQueus[p->cpu] , p->index); 
    8000295a:	58d8                	lw	a4,52(s1)
    8000295c:	00271793          	slli	a5,a4,0x2
    80002960:	97ba                	add	a5,a5,a4
    80002962:	078e                	slli	a5,a5,0x3
    80002964:	40ac                	lw	a1,64(s1)
    80002966:	0000f517          	auipc	a0,0xf
    8000296a:	93a50513          	addi	a0,a0,-1734 # 800112a0 <readyQueus>
    8000296e:	953e                	add	a0,a0,a5
    80002970:	fffff097          	auipc	ra,0xfffff
    80002974:	ece080e7          	jalr	-306(ra) # 8000183e <add2>
    80002978:	b7d1                	j	8000293c <kill+0x52>

000000008000297a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000297a:	7179                	addi	sp,sp,-48
    8000297c:	f406                	sd	ra,40(sp)
    8000297e:	f022                	sd	s0,32(sp)
    80002980:	ec26                	sd	s1,24(sp)
    80002982:	e84a                	sd	s2,16(sp)
    80002984:	e44e                	sd	s3,8(sp)
    80002986:	e052                	sd	s4,0(sp)
    80002988:	1800                	addi	s0,sp,48
    8000298a:	84aa                	mv	s1,a0
    8000298c:	892e                	mv	s2,a1
    8000298e:	89b2                	mv	s3,a2
    80002990:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002992:	fffff097          	auipc	ra,0xfffff
    80002996:	41e080e7          	jalr	1054(ra) # 80001db0 <myproc>
  if(user_dst){
    8000299a:	c08d                	beqz	s1,800029bc <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000299c:	86d2                	mv	a3,s4
    8000299e:	864e                	mv	a2,s3
    800029a0:	85ca                	mv	a1,s2
    800029a2:	7d28                	ld	a0,120(a0)
    800029a4:	fffff097          	auipc	ra,0xfffff
    800029a8:	cce080e7          	jalr	-818(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800029ac:	70a2                	ld	ra,40(sp)
    800029ae:	7402                	ld	s0,32(sp)
    800029b0:	64e2                	ld	s1,24(sp)
    800029b2:	6942                	ld	s2,16(sp)
    800029b4:	69a2                	ld	s3,8(sp)
    800029b6:	6a02                	ld	s4,0(sp)
    800029b8:	6145                	addi	sp,sp,48
    800029ba:	8082                	ret
    memmove((char *)dst, src, len);
    800029bc:	000a061b          	sext.w	a2,s4
    800029c0:	85ce                	mv	a1,s3
    800029c2:	854a                	mv	a0,s2
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	37c080e7          	jalr	892(ra) # 80000d40 <memmove>
    return 0;
    800029cc:	8526                	mv	a0,s1
    800029ce:	bff9                	j	800029ac <either_copyout+0x32>

00000000800029d0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029d0:	7179                	addi	sp,sp,-48
    800029d2:	f406                	sd	ra,40(sp)
    800029d4:	f022                	sd	s0,32(sp)
    800029d6:	ec26                	sd	s1,24(sp)
    800029d8:	e84a                	sd	s2,16(sp)
    800029da:	e44e                	sd	s3,8(sp)
    800029dc:	e052                	sd	s4,0(sp)
    800029de:	1800                	addi	s0,sp,48
    800029e0:	892a                	mv	s2,a0
    800029e2:	84ae                	mv	s1,a1
    800029e4:	89b2                	mv	s3,a2
    800029e6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029e8:	fffff097          	auipc	ra,0xfffff
    800029ec:	3c8080e7          	jalr	968(ra) # 80001db0 <myproc>
  if(user_src){
    800029f0:	c08d                	beqz	s1,80002a12 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800029f2:	86d2                	mv	a3,s4
    800029f4:	864e                	mv	a2,s3
    800029f6:	85ca                	mv	a1,s2
    800029f8:	7d28                	ld	a0,120(a0)
    800029fa:	fffff097          	auipc	ra,0xfffff
    800029fe:	d04080e7          	jalr	-764(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a02:	70a2                	ld	ra,40(sp)
    80002a04:	7402                	ld	s0,32(sp)
    80002a06:	64e2                	ld	s1,24(sp)
    80002a08:	6942                	ld	s2,16(sp)
    80002a0a:	69a2                	ld	s3,8(sp)
    80002a0c:	6a02                	ld	s4,0(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    memmove(dst, (char*)src, len);
    80002a12:	000a061b          	sext.w	a2,s4
    80002a16:	85ce                	mv	a1,s3
    80002a18:	854a                	mv	a0,s2
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	326080e7          	jalr	806(ra) # 80000d40 <memmove>
    return 0;
    80002a22:	8526                	mv	a0,s1
    80002a24:	bff9                	j	80002a02 <either_copyin+0x32>

0000000080002a26 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002a26:	715d                	addi	sp,sp,-80
    80002a28:	e486                	sd	ra,72(sp)
    80002a2a:	e0a2                	sd	s0,64(sp)
    80002a2c:	fc26                	sd	s1,56(sp)
    80002a2e:	f84a                	sd	s2,48(sp)
    80002a30:	f44e                	sd	s3,40(sp)
    80002a32:	f052                	sd	s4,32(sp)
    80002a34:	ec56                	sd	s5,24(sp)
    80002a36:	e85a                	sd	s6,16(sp)
    80002a38:	e45e                	sd	s7,8(sp)
    80002a3a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002a3c:	00005517          	auipc	a0,0x5
    80002a40:	7a450513          	addi	a0,a0,1956 # 800081e0 <digits+0x1a0>
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	b44080e7          	jalr	-1212(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a4c:	0000f497          	auipc	s1,0xf
    80002a50:	ffc48493          	addi	s1,s1,-4 # 80011a48 <proc+0x180>
    80002a54:	00015917          	auipc	s2,0x15
    80002a58:	3f490913          	addi	s2,s2,1012 # 80017e48 <bcache+0x168>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a5c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a5e:	00006997          	auipc	s3,0x6
    80002a62:	8ba98993          	addi	s3,s3,-1862 # 80008318 <digits+0x2d8>
    printf("%d %s %s", p->pid, state, p->name);
    80002a66:	00006a97          	auipc	s5,0x6
    80002a6a:	8baa8a93          	addi	s5,s5,-1862 # 80008320 <digits+0x2e0>
    printf("\n");
    80002a6e:	00005a17          	auipc	s4,0x5
    80002a72:	772a0a13          	addi	s4,s4,1906 # 800081e0 <digits+0x1a0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a76:	00006b97          	auipc	s7,0x6
    80002a7a:	8e2b8b93          	addi	s7,s7,-1822 # 80008358 <states.1765>
    80002a7e:	a00d                	j	80002aa0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002a80:	eb06a583          	lw	a1,-336(a3)
    80002a84:	8556                	mv	a0,s5
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	b02080e7          	jalr	-1278(ra) # 80000588 <printf>
    printf("\n");
    80002a8e:	8552                	mv	a0,s4
    80002a90:	ffffe097          	auipc	ra,0xffffe
    80002a94:	af8080e7          	jalr	-1288(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a98:	19048493          	addi	s1,s1,400
    80002a9c:	03248163          	beq	s1,s2,80002abe <procdump+0x98>
    if(p->state == UNUSED)
    80002aa0:	86a6                	mv	a3,s1
    80002aa2:	e984a783          	lw	a5,-360(s1)
    80002aa6:	dbed                	beqz	a5,80002a98 <procdump+0x72>
      state = "???";
    80002aa8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002aaa:	fcfb6be3          	bltu	s6,a5,80002a80 <procdump+0x5a>
    80002aae:	1782                	slli	a5,a5,0x20
    80002ab0:	9381                	srli	a5,a5,0x20
    80002ab2:	078e                	slli	a5,a5,0x3
    80002ab4:	97de                	add	a5,a5,s7
    80002ab6:	6390                	ld	a2,0(a5)
    80002ab8:	f661                	bnez	a2,80002a80 <procdump+0x5a>
      state = "???";
    80002aba:	864e                	mv	a2,s3
    80002abc:	b7d1                	j	80002a80 <procdump+0x5a>
  }
}
    80002abe:	60a6                	ld	ra,72(sp)
    80002ac0:	6406                	ld	s0,64(sp)
    80002ac2:	74e2                	ld	s1,56(sp)
    80002ac4:	7942                	ld	s2,48(sp)
    80002ac6:	79a2                	ld	s3,40(sp)
    80002ac8:	7a02                	ld	s4,32(sp)
    80002aca:	6ae2                	ld	s5,24(sp)
    80002acc:	6b42                	ld	s6,16(sp)
    80002ace:	6ba2                	ld	s7,8(sp)
    80002ad0:	6161                	addi	sp,sp,80
    80002ad2:	8082                	ret

0000000080002ad4 <swtch>:
    80002ad4:	00153023          	sd	ra,0(a0)
    80002ad8:	00253423          	sd	sp,8(a0)
    80002adc:	e900                	sd	s0,16(a0)
    80002ade:	ed04                	sd	s1,24(a0)
    80002ae0:	03253023          	sd	s2,32(a0)
    80002ae4:	03353423          	sd	s3,40(a0)
    80002ae8:	03453823          	sd	s4,48(a0)
    80002aec:	03553c23          	sd	s5,56(a0)
    80002af0:	05653023          	sd	s6,64(a0)
    80002af4:	05753423          	sd	s7,72(a0)
    80002af8:	05853823          	sd	s8,80(a0)
    80002afc:	05953c23          	sd	s9,88(a0)
    80002b00:	07a53023          	sd	s10,96(a0)
    80002b04:	07b53423          	sd	s11,104(a0)
    80002b08:	0005b083          	ld	ra,0(a1)
    80002b0c:	0085b103          	ld	sp,8(a1)
    80002b10:	6980                	ld	s0,16(a1)
    80002b12:	6d84                	ld	s1,24(a1)
    80002b14:	0205b903          	ld	s2,32(a1)
    80002b18:	0285b983          	ld	s3,40(a1)
    80002b1c:	0305ba03          	ld	s4,48(a1)
    80002b20:	0385ba83          	ld	s5,56(a1)
    80002b24:	0405bb03          	ld	s6,64(a1)
    80002b28:	0485bb83          	ld	s7,72(a1)
    80002b2c:	0505bc03          	ld	s8,80(a1)
    80002b30:	0585bc83          	ld	s9,88(a1)
    80002b34:	0605bd03          	ld	s10,96(a1)
    80002b38:	0685bd83          	ld	s11,104(a1)
    80002b3c:	8082                	ret

0000000080002b3e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b3e:	1141                	addi	sp,sp,-16
    80002b40:	e406                	sd	ra,8(sp)
    80002b42:	e022                	sd	s0,0(sp)
    80002b44:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b46:	00006597          	auipc	a1,0x6
    80002b4a:	84258593          	addi	a1,a1,-1982 # 80008388 <states.1765+0x30>
    80002b4e:	00015517          	auipc	a0,0x15
    80002b52:	17a50513          	addi	a0,a0,378 # 80017cc8 <tickslock>
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	ffe080e7          	jalr	-2(ra) # 80000b54 <initlock>
}
    80002b5e:	60a2                	ld	ra,8(sp)
    80002b60:	6402                	ld	s0,0(sp)
    80002b62:	0141                	addi	sp,sp,16
    80002b64:	8082                	ret

0000000080002b66 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b66:	1141                	addi	sp,sp,-16
    80002b68:	e422                	sd	s0,8(sp)
    80002b6a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b6c:	00003797          	auipc	a5,0x3
    80002b70:	48478793          	addi	a5,a5,1156 # 80005ff0 <kernelvec>
    80002b74:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b78:	6422                	ld	s0,8(sp)
    80002b7a:	0141                	addi	sp,sp,16
    80002b7c:	8082                	ret

0000000080002b7e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b7e:	1141                	addi	sp,sp,-16
    80002b80:	e406                	sd	ra,8(sp)
    80002b82:	e022                	sd	s0,0(sp)
    80002b84:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b86:	fffff097          	auipc	ra,0xfffff
    80002b8a:	22a080e7          	jalr	554(ra) # 80001db0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b8e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b92:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b94:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b98:	00004617          	auipc	a2,0x4
    80002b9c:	46860613          	addi	a2,a2,1128 # 80007000 <_trampoline>
    80002ba0:	00004697          	auipc	a3,0x4
    80002ba4:	46068693          	addi	a3,a3,1120 # 80007000 <_trampoline>
    80002ba8:	8e91                	sub	a3,a3,a2
    80002baa:	040007b7          	lui	a5,0x4000
    80002bae:	17fd                	addi	a5,a5,-1
    80002bb0:	07b2                	slli	a5,a5,0xc
    80002bb2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bb4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002bb8:	6158                	ld	a4,128(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002bba:	180026f3          	csrr	a3,satp
    80002bbe:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002bc0:	6158                	ld	a4,128(a0)
    80002bc2:	7534                	ld	a3,104(a0)
    80002bc4:	6585                	lui	a1,0x1
    80002bc6:	96ae                	add	a3,a3,a1
    80002bc8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002bca:	6158                	ld	a4,128(a0)
    80002bcc:	00000697          	auipc	a3,0x0
    80002bd0:	13868693          	addi	a3,a3,312 # 80002d04 <usertrap>
    80002bd4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002bd6:	6158                	ld	a4,128(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002bd8:	8692                	mv	a3,tp
    80002bda:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bdc:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002be0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002be4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002bec:	6158                	ld	a4,128(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bee:	6f18                	ld	a4,24(a4)
    80002bf0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bf4:	7d2c                	ld	a1,120(a0)
    80002bf6:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002bf8:	00004717          	auipc	a4,0x4
    80002bfc:	49870713          	addi	a4,a4,1176 # 80007090 <userret>
    80002c00:	8f11                	sub	a4,a4,a2
    80002c02:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002c04:	577d                	li	a4,-1
    80002c06:	177e                	slli	a4,a4,0x3f
    80002c08:	8dd9                	or	a1,a1,a4
    80002c0a:	02000537          	lui	a0,0x2000
    80002c0e:	157d                	addi	a0,a0,-1
    80002c10:	0536                	slli	a0,a0,0xd
    80002c12:	9782                	jalr	a5
}
    80002c14:	60a2                	ld	ra,8(sp)
    80002c16:	6402                	ld	s0,0(sp)
    80002c18:	0141                	addi	sp,sp,16
    80002c1a:	8082                	ret

0000000080002c1c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	e426                	sd	s1,8(sp)
    80002c24:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c26:	00015497          	auipc	s1,0x15
    80002c2a:	0a248493          	addi	s1,s1,162 # 80017cc8 <tickslock>
    80002c2e:	8526                	mv	a0,s1
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	fb4080e7          	jalr	-76(ra) # 80000be4 <acquire>
  ticks++;
    80002c38:	00006517          	auipc	a0,0x6
    80002c3c:	3f850513          	addi	a0,a0,1016 # 80009030 <ticks>
    80002c40:	411c                	lw	a5,0(a0)
    80002c42:	2785                	addiw	a5,a5,1
    80002c44:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	ac8080e7          	jalr	-1336(ra) # 8000270e <wakeup>
  release(&tickslock);
    80002c4e:	8526                	mv	a0,s1
    80002c50:	ffffe097          	auipc	ra,0xffffe
    80002c54:	048080e7          	jalr	72(ra) # 80000c98 <release>
}
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	64a2                	ld	s1,8(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret

0000000080002c62 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c62:	1101                	addi	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	e426                	sd	s1,8(sp)
    80002c6a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c70:	00074d63          	bltz	a4,80002c8a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c74:	57fd                	li	a5,-1
    80002c76:	17fe                	slli	a5,a5,0x3f
    80002c78:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c7a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c7c:	06f70363          	beq	a4,a5,80002ce2 <devintr+0x80>
  }
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6105                	addi	sp,sp,32
    80002c88:	8082                	ret
     (scause & 0xff) == 9){
    80002c8a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c8e:	46a5                	li	a3,9
    80002c90:	fed792e3          	bne	a5,a3,80002c74 <devintr+0x12>
    int irq = plic_claim();
    80002c94:	00003097          	auipc	ra,0x3
    80002c98:	464080e7          	jalr	1124(ra) # 800060f8 <plic_claim>
    80002c9c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c9e:	47a9                	li	a5,10
    80002ca0:	02f50763          	beq	a0,a5,80002cce <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002ca4:	4785                	li	a5,1
    80002ca6:	02f50963          	beq	a0,a5,80002cd8 <devintr+0x76>
    return 1;
    80002caa:	4505                	li	a0,1
    } else if(irq){
    80002cac:	d8f1                	beqz	s1,80002c80 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cae:	85a6                	mv	a1,s1
    80002cb0:	00005517          	auipc	a0,0x5
    80002cb4:	6e050513          	addi	a0,a0,1760 # 80008390 <states.1765+0x38>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	8d0080e7          	jalr	-1840(ra) # 80000588 <printf>
      plic_complete(irq);
    80002cc0:	8526                	mv	a0,s1
    80002cc2:	00003097          	auipc	ra,0x3
    80002cc6:	45a080e7          	jalr	1114(ra) # 8000611c <plic_complete>
    return 1;
    80002cca:	4505                	li	a0,1
    80002ccc:	bf55                	j	80002c80 <devintr+0x1e>
      uartintr();
    80002cce:	ffffe097          	auipc	ra,0xffffe
    80002cd2:	cda080e7          	jalr	-806(ra) # 800009a8 <uartintr>
    80002cd6:	b7ed                	j	80002cc0 <devintr+0x5e>
      virtio_disk_intr();
    80002cd8:	00004097          	auipc	ra,0x4
    80002cdc:	924080e7          	jalr	-1756(ra) # 800065fc <virtio_disk_intr>
    80002ce0:	b7c5                	j	80002cc0 <devintr+0x5e>
    if(cpuid() == 0){
    80002ce2:	fffff097          	auipc	ra,0xfffff
    80002ce6:	09a080e7          	jalr	154(ra) # 80001d7c <cpuid>
    80002cea:	c901                	beqz	a0,80002cfa <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002cec:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002cf0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002cf2:	14479073          	csrw	sip,a5
    return 2;
    80002cf6:	4509                	li	a0,2
    80002cf8:	b761                	j	80002c80 <devintr+0x1e>
      clockintr();
    80002cfa:	00000097          	auipc	ra,0x0
    80002cfe:	f22080e7          	jalr	-222(ra) # 80002c1c <clockintr>
    80002d02:	b7ed                	j	80002cec <devintr+0x8a>

0000000080002d04 <usertrap>:
{
    80002d04:	1101                	addi	sp,sp,-32
    80002d06:	ec06                	sd	ra,24(sp)
    80002d08:	e822                	sd	s0,16(sp)
    80002d0a:	e426                	sd	s1,8(sp)
    80002d0c:	e04a                	sd	s2,0(sp)
    80002d0e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d10:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d14:	1007f793          	andi	a5,a5,256
    80002d18:	e3ad                	bnez	a5,80002d7a <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d1a:	00003797          	auipc	a5,0x3
    80002d1e:	2d678793          	addi	a5,a5,726 # 80005ff0 <kernelvec>
    80002d22:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	08a080e7          	jalr	138(ra) # 80001db0 <myproc>
    80002d2e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d30:	615c                	ld	a5,128(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d32:	14102773          	csrr	a4,sepc
    80002d36:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d38:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d3c:	47a1                	li	a5,8
    80002d3e:	04f71c63          	bne	a4,a5,80002d96 <usertrap+0x92>
    if(p->killed)
    80002d42:	551c                	lw	a5,40(a0)
    80002d44:	e3b9                	bnez	a5,80002d8a <usertrap+0x86>
    p->trapframe->epc += 4;
    80002d46:	60d8                	ld	a4,128(s1)
    80002d48:	6f1c                	ld	a5,24(a4)
    80002d4a:	0791                	addi	a5,a5,4
    80002d4c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d4e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d52:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d56:	10079073          	csrw	sstatus,a5
    syscall();
    80002d5a:	00000097          	auipc	ra,0x0
    80002d5e:	2e0080e7          	jalr	736(ra) # 8000303a <syscall>
  if(p->killed)
    80002d62:	549c                	lw	a5,40(s1)
    80002d64:	ebc1                	bnez	a5,80002df4 <usertrap+0xf0>
  usertrapret();
    80002d66:	00000097          	auipc	ra,0x0
    80002d6a:	e18080e7          	jalr	-488(ra) # 80002b7e <usertrapret>
}
    80002d6e:	60e2                	ld	ra,24(sp)
    80002d70:	6442                	ld	s0,16(sp)
    80002d72:	64a2                	ld	s1,8(sp)
    80002d74:	6902                	ld	s2,0(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret
    panic("usertrap: not from user mode");
    80002d7a:	00005517          	auipc	a0,0x5
    80002d7e:	63650513          	addi	a0,a0,1590 # 800083b0 <states.1765+0x58>
    80002d82:	ffffd097          	auipc	ra,0xffffd
    80002d86:	7bc080e7          	jalr	1980(ra) # 8000053e <panic>
      exit(-1);
    80002d8a:	557d                	li	a0,-1
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	a74080e7          	jalr	-1420(ra) # 80002800 <exit>
    80002d94:	bf4d                	j	80002d46 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	ecc080e7          	jalr	-308(ra) # 80002c62 <devintr>
    80002d9e:	892a                	mv	s2,a0
    80002da0:	c501                	beqz	a0,80002da8 <usertrap+0xa4>
  if(p->killed)
    80002da2:	549c                	lw	a5,40(s1)
    80002da4:	c3a1                	beqz	a5,80002de4 <usertrap+0xe0>
    80002da6:	a815                	j	80002dda <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002da8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002dac:	5890                	lw	a2,48(s1)
    80002dae:	00005517          	auipc	a0,0x5
    80002db2:	62250513          	addi	a0,a0,1570 # 800083d0 <states.1765+0x78>
    80002db6:	ffffd097          	auipc	ra,0xffffd
    80002dba:	7d2080e7          	jalr	2002(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dbe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dc2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dc6:	00005517          	auipc	a0,0x5
    80002dca:	63a50513          	addi	a0,a0,1594 # 80008400 <states.1765+0xa8>
    80002dce:	ffffd097          	auipc	ra,0xffffd
    80002dd2:	7ba080e7          	jalr	1978(ra) # 80000588 <printf>
    p->killed = 1;
    80002dd6:	4785                	li	a5,1
    80002dd8:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002dda:	557d                	li	a0,-1
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	a24080e7          	jalr	-1500(ra) # 80002800 <exit>
  if(which_dev == 2)
    80002de4:	4789                	li	a5,2
    80002de6:	f8f910e3          	bne	s2,a5,80002d66 <usertrap+0x62>
    yield();
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	6ca080e7          	jalr	1738(ra) # 800024b4 <yield>
    80002df2:	bf95                	j	80002d66 <usertrap+0x62>
  int which_dev = 0;
    80002df4:	4901                	li	s2,0
    80002df6:	b7d5                	j	80002dda <usertrap+0xd6>

0000000080002df8 <kerneltrap>:
{
    80002df8:	7179                	addi	sp,sp,-48
    80002dfa:	f406                	sd	ra,40(sp)
    80002dfc:	f022                	sd	s0,32(sp)
    80002dfe:	ec26                	sd	s1,24(sp)
    80002e00:	e84a                	sd	s2,16(sp)
    80002e02:	e44e                	sd	s3,8(sp)
    80002e04:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e06:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e0a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e0e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e12:	1004f793          	andi	a5,s1,256
    80002e16:	cb85                	beqz	a5,80002e46 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e18:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e1c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e1e:	ef85                	bnez	a5,80002e56 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002e20:	00000097          	auipc	ra,0x0
    80002e24:	e42080e7          	jalr	-446(ra) # 80002c62 <devintr>
    80002e28:	cd1d                	beqz	a0,80002e66 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e2a:	4789                	li	a5,2
    80002e2c:	06f50a63          	beq	a0,a5,80002ea0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e30:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e34:	10049073          	csrw	sstatus,s1
}
    80002e38:	70a2                	ld	ra,40(sp)
    80002e3a:	7402                	ld	s0,32(sp)
    80002e3c:	64e2                	ld	s1,24(sp)
    80002e3e:	6942                	ld	s2,16(sp)
    80002e40:	69a2                	ld	s3,8(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e46:	00005517          	auipc	a0,0x5
    80002e4a:	5da50513          	addi	a0,a0,1498 # 80008420 <states.1765+0xc8>
    80002e4e:	ffffd097          	auipc	ra,0xffffd
    80002e52:	6f0080e7          	jalr	1776(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002e56:	00005517          	auipc	a0,0x5
    80002e5a:	5f250513          	addi	a0,a0,1522 # 80008448 <states.1765+0xf0>
    80002e5e:	ffffd097          	auipc	ra,0xffffd
    80002e62:	6e0080e7          	jalr	1760(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002e66:	85ce                	mv	a1,s3
    80002e68:	00005517          	auipc	a0,0x5
    80002e6c:	60050513          	addi	a0,a0,1536 # 80008468 <states.1765+0x110>
    80002e70:	ffffd097          	auipc	ra,0xffffd
    80002e74:	718080e7          	jalr	1816(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e78:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e7c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e80:	00005517          	auipc	a0,0x5
    80002e84:	5f850513          	addi	a0,a0,1528 # 80008478 <states.1765+0x120>
    80002e88:	ffffd097          	auipc	ra,0xffffd
    80002e8c:	700080e7          	jalr	1792(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002e90:	00005517          	auipc	a0,0x5
    80002e94:	60050513          	addi	a0,a0,1536 # 80008490 <states.1765+0x138>
    80002e98:	ffffd097          	auipc	ra,0xffffd
    80002e9c:	6a6080e7          	jalr	1702(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	f10080e7          	jalr	-240(ra) # 80001db0 <myproc>
    80002ea8:	d541                	beqz	a0,80002e30 <kerneltrap+0x38>
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	f06080e7          	jalr	-250(ra) # 80001db0 <myproc>
    80002eb2:	4d18                	lw	a4,24(a0)
    80002eb4:	4791                	li	a5,4
    80002eb6:	f6f71de3          	bne	a4,a5,80002e30 <kerneltrap+0x38>
    yield();
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	5fa080e7          	jalr	1530(ra) # 800024b4 <yield>
    80002ec2:	b7bd                	j	80002e30 <kerneltrap+0x38>

0000000080002ec4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ec4:	1101                	addi	sp,sp,-32
    80002ec6:	ec06                	sd	ra,24(sp)
    80002ec8:	e822                	sd	s0,16(sp)
    80002eca:	e426                	sd	s1,8(sp)
    80002ecc:	1000                	addi	s0,sp,32
    80002ece:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	ee0080e7          	jalr	-288(ra) # 80001db0 <myproc>
  switch (n) {
    80002ed8:	4795                	li	a5,5
    80002eda:	0497e163          	bltu	a5,s1,80002f1c <argraw+0x58>
    80002ede:	048a                	slli	s1,s1,0x2
    80002ee0:	00005717          	auipc	a4,0x5
    80002ee4:	5e870713          	addi	a4,a4,1512 # 800084c8 <states.1765+0x170>
    80002ee8:	94ba                	add	s1,s1,a4
    80002eea:	409c                	lw	a5,0(s1)
    80002eec:	97ba                	add	a5,a5,a4
    80002eee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ef0:	615c                	ld	a5,128(a0)
    80002ef2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ef4:	60e2                	ld	ra,24(sp)
    80002ef6:	6442                	ld	s0,16(sp)
    80002ef8:	64a2                	ld	s1,8(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret
    return p->trapframe->a1;
    80002efe:	615c                	ld	a5,128(a0)
    80002f00:	7fa8                	ld	a0,120(a5)
    80002f02:	bfcd                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a2;
    80002f04:	615c                	ld	a5,128(a0)
    80002f06:	63c8                	ld	a0,128(a5)
    80002f08:	b7f5                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a3;
    80002f0a:	615c                	ld	a5,128(a0)
    80002f0c:	67c8                	ld	a0,136(a5)
    80002f0e:	b7dd                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a4;
    80002f10:	615c                	ld	a5,128(a0)
    80002f12:	6bc8                	ld	a0,144(a5)
    80002f14:	b7c5                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a5;
    80002f16:	615c                	ld	a5,128(a0)
    80002f18:	6fc8                	ld	a0,152(a5)
    80002f1a:	bfe9                	j	80002ef4 <argraw+0x30>
  panic("argraw");
    80002f1c:	00005517          	auipc	a0,0x5
    80002f20:	58450513          	addi	a0,a0,1412 # 800084a0 <states.1765+0x148>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	61a080e7          	jalr	1562(ra) # 8000053e <panic>

0000000080002f2c <fetchaddr>:
{
    80002f2c:	1101                	addi	sp,sp,-32
    80002f2e:	ec06                	sd	ra,24(sp)
    80002f30:	e822                	sd	s0,16(sp)
    80002f32:	e426                	sd	s1,8(sp)
    80002f34:	e04a                	sd	s2,0(sp)
    80002f36:	1000                	addi	s0,sp,32
    80002f38:	84aa                	mv	s1,a0
    80002f3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	e74080e7          	jalr	-396(ra) # 80001db0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002f44:	793c                	ld	a5,112(a0)
    80002f46:	02f4f863          	bgeu	s1,a5,80002f76 <fetchaddr+0x4a>
    80002f4a:	00848713          	addi	a4,s1,8
    80002f4e:	02e7e663          	bltu	a5,a4,80002f7a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f52:	46a1                	li	a3,8
    80002f54:	8626                	mv	a2,s1
    80002f56:	85ca                	mv	a1,s2
    80002f58:	7d28                	ld	a0,120(a0)
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	7a4080e7          	jalr	1956(ra) # 800016fe <copyin>
    80002f62:	00a03533          	snez	a0,a0
    80002f66:	40a00533          	neg	a0,a0
}
    80002f6a:	60e2                	ld	ra,24(sp)
    80002f6c:	6442                	ld	s0,16(sp)
    80002f6e:	64a2                	ld	s1,8(sp)
    80002f70:	6902                	ld	s2,0(sp)
    80002f72:	6105                	addi	sp,sp,32
    80002f74:	8082                	ret
    return -1;
    80002f76:	557d                	li	a0,-1
    80002f78:	bfcd                	j	80002f6a <fetchaddr+0x3e>
    80002f7a:	557d                	li	a0,-1
    80002f7c:	b7fd                	j	80002f6a <fetchaddr+0x3e>

0000000080002f7e <fetchstr>:
{
    80002f7e:	7179                	addi	sp,sp,-48
    80002f80:	f406                	sd	ra,40(sp)
    80002f82:	f022                	sd	s0,32(sp)
    80002f84:	ec26                	sd	s1,24(sp)
    80002f86:	e84a                	sd	s2,16(sp)
    80002f88:	e44e                	sd	s3,8(sp)
    80002f8a:	1800                	addi	s0,sp,48
    80002f8c:	892a                	mv	s2,a0
    80002f8e:	84ae                	mv	s1,a1
    80002f90:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	e1e080e7          	jalr	-482(ra) # 80001db0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002f9a:	86ce                	mv	a3,s3
    80002f9c:	864a                	mv	a2,s2
    80002f9e:	85a6                	mv	a1,s1
    80002fa0:	7d28                	ld	a0,120(a0)
    80002fa2:	ffffe097          	auipc	ra,0xffffe
    80002fa6:	7e8080e7          	jalr	2024(ra) # 8000178a <copyinstr>
  if(err < 0)
    80002faa:	00054763          	bltz	a0,80002fb8 <fetchstr+0x3a>
  return strlen(buf);
    80002fae:	8526                	mv	a0,s1
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	eb4080e7          	jalr	-332(ra) # 80000e64 <strlen>
}
    80002fb8:	70a2                	ld	ra,40(sp)
    80002fba:	7402                	ld	s0,32(sp)
    80002fbc:	64e2                	ld	s1,24(sp)
    80002fbe:	6942                	ld	s2,16(sp)
    80002fc0:	69a2                	ld	s3,8(sp)
    80002fc2:	6145                	addi	sp,sp,48
    80002fc4:	8082                	ret

0000000080002fc6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002fc6:	1101                	addi	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	e426                	sd	s1,8(sp)
    80002fce:	1000                	addi	s0,sp,32
    80002fd0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	ef2080e7          	jalr	-270(ra) # 80002ec4 <argraw>
    80002fda:	c088                	sw	a0,0(s1)
  return 0;
}
    80002fdc:	4501                	li	a0,0
    80002fde:	60e2                	ld	ra,24(sp)
    80002fe0:	6442                	ld	s0,16(sp)
    80002fe2:	64a2                	ld	s1,8(sp)
    80002fe4:	6105                	addi	sp,sp,32
    80002fe6:	8082                	ret

0000000080002fe8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	1000                	addi	s0,sp,32
    80002ff2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ff4:	00000097          	auipc	ra,0x0
    80002ff8:	ed0080e7          	jalr	-304(ra) # 80002ec4 <argraw>
    80002ffc:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ffe:	4501                	li	a0,0
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret

000000008000300a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000300a:	1101                	addi	sp,sp,-32
    8000300c:	ec06                	sd	ra,24(sp)
    8000300e:	e822                	sd	s0,16(sp)
    80003010:	e426                	sd	s1,8(sp)
    80003012:	e04a                	sd	s2,0(sp)
    80003014:	1000                	addi	s0,sp,32
    80003016:	84ae                	mv	s1,a1
    80003018:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000301a:	00000097          	auipc	ra,0x0
    8000301e:	eaa080e7          	jalr	-342(ra) # 80002ec4 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003022:	864a                	mv	a2,s2
    80003024:	85a6                	mv	a1,s1
    80003026:	00000097          	auipc	ra,0x0
    8000302a:	f58080e7          	jalr	-168(ra) # 80002f7e <fetchstr>
}
    8000302e:	60e2                	ld	ra,24(sp)
    80003030:	6442                	ld	s0,16(sp)
    80003032:	64a2                	ld	s1,8(sp)
    80003034:	6902                	ld	s2,0(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000303a:	1101                	addi	sp,sp,-32
    8000303c:	ec06                	sd	ra,24(sp)
    8000303e:	e822                	sd	s0,16(sp)
    80003040:	e426                	sd	s1,8(sp)
    80003042:	e04a                	sd	s2,0(sp)
    80003044:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003046:	fffff097          	auipc	ra,0xfffff
    8000304a:	d6a080e7          	jalr	-662(ra) # 80001db0 <myproc>
    8000304e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003050:	08053903          	ld	s2,128(a0)
    80003054:	0a893783          	ld	a5,168(s2)
    80003058:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000305c:	37fd                	addiw	a5,a5,-1
    8000305e:	4751                	li	a4,20
    80003060:	00f76f63          	bltu	a4,a5,8000307e <syscall+0x44>
    80003064:	00369713          	slli	a4,a3,0x3
    80003068:	00005797          	auipc	a5,0x5
    8000306c:	47878793          	addi	a5,a5,1144 # 800084e0 <syscalls>
    80003070:	97ba                	add	a5,a5,a4
    80003072:	639c                	ld	a5,0(a5)
    80003074:	c789                	beqz	a5,8000307e <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003076:	9782                	jalr	a5
    80003078:	06a93823          	sd	a0,112(s2)
    8000307c:	a839                	j	8000309a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000307e:	18048613          	addi	a2,s1,384
    80003082:	588c                	lw	a1,48(s1)
    80003084:	00005517          	auipc	a0,0x5
    80003088:	42450513          	addi	a0,a0,1060 # 800084a8 <states.1765+0x150>
    8000308c:	ffffd097          	auipc	ra,0xffffd
    80003090:	4fc080e7          	jalr	1276(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003094:	60dc                	ld	a5,128(s1)
    80003096:	577d                	li	a4,-1
    80003098:	fbb8                	sd	a4,112(a5)
  }
}
    8000309a:	60e2                	ld	ra,24(sp)
    8000309c:	6442                	ld	s0,16(sp)
    8000309e:	64a2                	ld	s1,8(sp)
    800030a0:	6902                	ld	s2,0(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret

00000000800030a6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800030a6:	1101                	addi	sp,sp,-32
    800030a8:	ec06                	sd	ra,24(sp)
    800030aa:	e822                	sd	s0,16(sp)
    800030ac:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800030ae:	fec40593          	addi	a1,s0,-20
    800030b2:	4501                	li	a0,0
    800030b4:	00000097          	auipc	ra,0x0
    800030b8:	f12080e7          	jalr	-238(ra) # 80002fc6 <argint>
    return -1;
    800030bc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800030be:	00054963          	bltz	a0,800030d0 <sys_exit+0x2a>
  exit(n);
    800030c2:	fec42503          	lw	a0,-20(s0)
    800030c6:	fffff097          	auipc	ra,0xfffff
    800030ca:	73a080e7          	jalr	1850(ra) # 80002800 <exit>
  return 0;  // not reached
    800030ce:	4781                	li	a5,0
}
    800030d0:	853e                	mv	a0,a5
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	6105                	addi	sp,sp,32
    800030d8:	8082                	ret

00000000800030da <sys_getpid>:

uint64
sys_getpid(void)
{
    800030da:	1141                	addi	sp,sp,-16
    800030dc:	e406                	sd	ra,8(sp)
    800030de:	e022                	sd	s0,0(sp)
    800030e0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800030e2:	fffff097          	auipc	ra,0xfffff
    800030e6:	cce080e7          	jalr	-818(ra) # 80001db0 <myproc>
}
    800030ea:	5908                	lw	a0,48(a0)
    800030ec:	60a2                	ld	ra,8(sp)
    800030ee:	6402                	ld	s0,0(sp)
    800030f0:	0141                	addi	sp,sp,16
    800030f2:	8082                	ret

00000000800030f4 <sys_fork>:

uint64
sys_fork(void)
{
    800030f4:	1141                	addi	sp,sp,-16
    800030f6:	e406                	sd	ra,8(sp)
    800030f8:	e022                	sd	s0,0(sp)
    800030fa:	0800                	addi	s0,sp,16
  return fork();
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	0b8080e7          	jalr	184(ra) # 800021b4 <fork>
}
    80003104:	60a2                	ld	ra,8(sp)
    80003106:	6402                	ld	s0,0(sp)
    80003108:	0141                	addi	sp,sp,16
    8000310a:	8082                	ret

000000008000310c <sys_wait>:

uint64
sys_wait(void)
{
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003114:	fe840593          	addi	a1,s0,-24
    80003118:	4501                	li	a0,0
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	ece080e7          	jalr	-306(ra) # 80002fe8 <argaddr>
    80003122:	87aa                	mv	a5,a0
    return -1;
    80003124:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003126:	0007c863          	bltz	a5,80003136 <sys_wait+0x2a>
  return wait(p);
    8000312a:	fe843503          	ld	a0,-24(s0)
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	4b8080e7          	jalr	1208(ra) # 800025e6 <wait>
}
    80003136:	60e2                	ld	ra,24(sp)
    80003138:	6442                	ld	s0,16(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret

000000008000313e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000313e:	7179                	addi	sp,sp,-48
    80003140:	f406                	sd	ra,40(sp)
    80003142:	f022                	sd	s0,32(sp)
    80003144:	ec26                	sd	s1,24(sp)
    80003146:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003148:	fdc40593          	addi	a1,s0,-36
    8000314c:	4501                	li	a0,0
    8000314e:	00000097          	auipc	ra,0x0
    80003152:	e78080e7          	jalr	-392(ra) # 80002fc6 <argint>
    80003156:	87aa                	mv	a5,a0
    return -1;
    80003158:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    8000315a:	0207c063          	bltz	a5,8000317a <sys_sbrk+0x3c>
  addr = myproc()->sz;
    8000315e:	fffff097          	auipc	ra,0xfffff
    80003162:	c52080e7          	jalr	-942(ra) # 80001db0 <myproc>
    80003166:	5924                	lw	s1,112(a0)
  if(growproc(n) < 0)
    80003168:	fdc42503          	lw	a0,-36(s0)
    8000316c:	fffff097          	auipc	ra,0xfffff
    80003170:	fd4080e7          	jalr	-44(ra) # 80002140 <growproc>
    80003174:	00054863          	bltz	a0,80003184 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003178:	8526                	mv	a0,s1
}
    8000317a:	70a2                	ld	ra,40(sp)
    8000317c:	7402                	ld	s0,32(sp)
    8000317e:	64e2                	ld	s1,24(sp)
    80003180:	6145                	addi	sp,sp,48
    80003182:	8082                	ret
    return -1;
    80003184:	557d                	li	a0,-1
    80003186:	bfd5                	j	8000317a <sys_sbrk+0x3c>

0000000080003188 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003188:	7139                	addi	sp,sp,-64
    8000318a:	fc06                	sd	ra,56(sp)
    8000318c:	f822                	sd	s0,48(sp)
    8000318e:	f426                	sd	s1,40(sp)
    80003190:	f04a                	sd	s2,32(sp)
    80003192:	ec4e                	sd	s3,24(sp)
    80003194:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003196:	fcc40593          	addi	a1,s0,-52
    8000319a:	4501                	li	a0,0
    8000319c:	00000097          	auipc	ra,0x0
    800031a0:	e2a080e7          	jalr	-470(ra) # 80002fc6 <argint>
    return -1;
    800031a4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031a6:	06054563          	bltz	a0,80003210 <sys_sleep+0x88>
  acquire(&tickslock);
    800031aa:	00015517          	auipc	a0,0x15
    800031ae:	b1e50513          	addi	a0,a0,-1250 # 80017cc8 <tickslock>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	a32080e7          	jalr	-1486(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    800031ba:	00006917          	auipc	s2,0x6
    800031be:	e7692903          	lw	s2,-394(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800031c2:	fcc42783          	lw	a5,-52(s0)
    800031c6:	cf85                	beqz	a5,800031fe <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800031c8:	00015997          	auipc	s3,0x15
    800031cc:	b0098993          	addi	s3,s3,-1280 # 80017cc8 <tickslock>
    800031d0:	00006497          	auipc	s1,0x6
    800031d4:	e6048493          	addi	s1,s1,-416 # 80009030 <ticks>
    if(myproc()->killed){
    800031d8:	fffff097          	auipc	ra,0xfffff
    800031dc:	bd8080e7          	jalr	-1064(ra) # 80001db0 <myproc>
    800031e0:	551c                	lw	a5,40(a0)
    800031e2:	ef9d                	bnez	a5,80003220 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800031e4:	85ce                	mv	a1,s3
    800031e6:	8526                	mv	a0,s1
    800031e8:	fffff097          	auipc	ra,0xfffff
    800031ec:	326080e7          	jalr	806(ra) # 8000250e <sleep>
  while(ticks - ticks0 < n){
    800031f0:	409c                	lw	a5,0(s1)
    800031f2:	412787bb          	subw	a5,a5,s2
    800031f6:	fcc42703          	lw	a4,-52(s0)
    800031fa:	fce7efe3          	bltu	a5,a4,800031d8 <sys_sleep+0x50>
  }
  release(&tickslock);
    800031fe:	00015517          	auipc	a0,0x15
    80003202:	aca50513          	addi	a0,a0,-1334 # 80017cc8 <tickslock>
    80003206:	ffffe097          	auipc	ra,0xffffe
    8000320a:	a92080e7          	jalr	-1390(ra) # 80000c98 <release>
  return 0;
    8000320e:	4781                	li	a5,0
}
    80003210:	853e                	mv	a0,a5
    80003212:	70e2                	ld	ra,56(sp)
    80003214:	7442                	ld	s0,48(sp)
    80003216:	74a2                	ld	s1,40(sp)
    80003218:	7902                	ld	s2,32(sp)
    8000321a:	69e2                	ld	s3,24(sp)
    8000321c:	6121                	addi	sp,sp,64
    8000321e:	8082                	ret
      release(&tickslock);
    80003220:	00015517          	auipc	a0,0x15
    80003224:	aa850513          	addi	a0,a0,-1368 # 80017cc8 <tickslock>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	a70080e7          	jalr	-1424(ra) # 80000c98 <release>
      return -1;
    80003230:	57fd                	li	a5,-1
    80003232:	bff9                	j	80003210 <sys_sleep+0x88>

0000000080003234 <sys_kill>:

uint64
sys_kill(void)
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000323c:	fec40593          	addi	a1,s0,-20
    80003240:	4501                	li	a0,0
    80003242:	00000097          	auipc	ra,0x0
    80003246:	d84080e7          	jalr	-636(ra) # 80002fc6 <argint>
    8000324a:	87aa                	mv	a5,a0
    return -1;
    8000324c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000324e:	0007c863          	bltz	a5,8000325e <sys_kill+0x2a>
  return kill(pid);
    80003252:	fec42503          	lw	a0,-20(s0)
    80003256:	fffff097          	auipc	ra,0xfffff
    8000325a:	694080e7          	jalr	1684(ra) # 800028ea <kill>
}
    8000325e:	60e2                	ld	ra,24(sp)
    80003260:	6442                	ld	s0,16(sp)
    80003262:	6105                	addi	sp,sp,32
    80003264:	8082                	ret

0000000080003266 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003266:	1101                	addi	sp,sp,-32
    80003268:	ec06                	sd	ra,24(sp)
    8000326a:	e822                	sd	s0,16(sp)
    8000326c:	e426                	sd	s1,8(sp)
    8000326e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003270:	00015517          	auipc	a0,0x15
    80003274:	a5850513          	addi	a0,a0,-1448 # 80017cc8 <tickslock>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	96c080e7          	jalr	-1684(ra) # 80000be4 <acquire>
  xticks = ticks;
    80003280:	00006497          	auipc	s1,0x6
    80003284:	db04a483          	lw	s1,-592(s1) # 80009030 <ticks>
  release(&tickslock);
    80003288:	00015517          	auipc	a0,0x15
    8000328c:	a4050513          	addi	a0,a0,-1472 # 80017cc8 <tickslock>
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	a08080e7          	jalr	-1528(ra) # 80000c98 <release>
  return xticks;
}
    80003298:	02049513          	slli	a0,s1,0x20
    8000329c:	9101                	srli	a0,a0,0x20
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	64a2                	ld	s1,8(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret

00000000800032a8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032a8:	7179                	addi	sp,sp,-48
    800032aa:	f406                	sd	ra,40(sp)
    800032ac:	f022                	sd	s0,32(sp)
    800032ae:	ec26                	sd	s1,24(sp)
    800032b0:	e84a                	sd	s2,16(sp)
    800032b2:	e44e                	sd	s3,8(sp)
    800032b4:	e052                	sd	s4,0(sp)
    800032b6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032b8:	00005597          	auipc	a1,0x5
    800032bc:	2d858593          	addi	a1,a1,728 # 80008590 <syscalls+0xb0>
    800032c0:	00015517          	auipc	a0,0x15
    800032c4:	a2050513          	addi	a0,a0,-1504 # 80017ce0 <bcache>
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	88c080e7          	jalr	-1908(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032d0:	0001d797          	auipc	a5,0x1d
    800032d4:	a1078793          	addi	a5,a5,-1520 # 8001fce0 <bcache+0x8000>
    800032d8:	0001d717          	auipc	a4,0x1d
    800032dc:	c7070713          	addi	a4,a4,-912 # 8001ff48 <bcache+0x8268>
    800032e0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032e4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032e8:	00015497          	auipc	s1,0x15
    800032ec:	a1048493          	addi	s1,s1,-1520 # 80017cf8 <bcache+0x18>
    b->next = bcache.head.next;
    800032f0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032f2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032f4:	00005a17          	auipc	s4,0x5
    800032f8:	2a4a0a13          	addi	s4,s4,676 # 80008598 <syscalls+0xb8>
    b->next = bcache.head.next;
    800032fc:	2b893783          	ld	a5,696(s2)
    80003300:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003302:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003306:	85d2                	mv	a1,s4
    80003308:	01048513          	addi	a0,s1,16
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	4bc080e7          	jalr	1212(ra) # 800047c8 <initsleeplock>
    bcache.head.next->prev = b;
    80003314:	2b893783          	ld	a5,696(s2)
    80003318:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000331a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000331e:	45848493          	addi	s1,s1,1112
    80003322:	fd349de3          	bne	s1,s3,800032fc <binit+0x54>
  }
}
    80003326:	70a2                	ld	ra,40(sp)
    80003328:	7402                	ld	s0,32(sp)
    8000332a:	64e2                	ld	s1,24(sp)
    8000332c:	6942                	ld	s2,16(sp)
    8000332e:	69a2                	ld	s3,8(sp)
    80003330:	6a02                	ld	s4,0(sp)
    80003332:	6145                	addi	sp,sp,48
    80003334:	8082                	ret

0000000080003336 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003336:	7179                	addi	sp,sp,-48
    80003338:	f406                	sd	ra,40(sp)
    8000333a:	f022                	sd	s0,32(sp)
    8000333c:	ec26                	sd	s1,24(sp)
    8000333e:	e84a                	sd	s2,16(sp)
    80003340:	e44e                	sd	s3,8(sp)
    80003342:	1800                	addi	s0,sp,48
    80003344:	89aa                	mv	s3,a0
    80003346:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003348:	00015517          	auipc	a0,0x15
    8000334c:	99850513          	addi	a0,a0,-1640 # 80017ce0 <bcache>
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	894080e7          	jalr	-1900(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003358:	0001d497          	auipc	s1,0x1d
    8000335c:	c404b483          	ld	s1,-960(s1) # 8001ff98 <bcache+0x82b8>
    80003360:	0001d797          	auipc	a5,0x1d
    80003364:	be878793          	addi	a5,a5,-1048 # 8001ff48 <bcache+0x8268>
    80003368:	02f48f63          	beq	s1,a5,800033a6 <bread+0x70>
    8000336c:	873e                	mv	a4,a5
    8000336e:	a021                	j	80003376 <bread+0x40>
    80003370:	68a4                	ld	s1,80(s1)
    80003372:	02e48a63          	beq	s1,a4,800033a6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003376:	449c                	lw	a5,8(s1)
    80003378:	ff379ce3          	bne	a5,s3,80003370 <bread+0x3a>
    8000337c:	44dc                	lw	a5,12(s1)
    8000337e:	ff2799e3          	bne	a5,s2,80003370 <bread+0x3a>
      b->refcnt++;
    80003382:	40bc                	lw	a5,64(s1)
    80003384:	2785                	addiw	a5,a5,1
    80003386:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003388:	00015517          	auipc	a0,0x15
    8000338c:	95850513          	addi	a0,a0,-1704 # 80017ce0 <bcache>
    80003390:	ffffe097          	auipc	ra,0xffffe
    80003394:	908080e7          	jalr	-1784(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003398:	01048513          	addi	a0,s1,16
    8000339c:	00001097          	auipc	ra,0x1
    800033a0:	466080e7          	jalr	1126(ra) # 80004802 <acquiresleep>
      return b;
    800033a4:	a8b9                	j	80003402 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033a6:	0001d497          	auipc	s1,0x1d
    800033aa:	bea4b483          	ld	s1,-1046(s1) # 8001ff90 <bcache+0x82b0>
    800033ae:	0001d797          	auipc	a5,0x1d
    800033b2:	b9a78793          	addi	a5,a5,-1126 # 8001ff48 <bcache+0x8268>
    800033b6:	00f48863          	beq	s1,a5,800033c6 <bread+0x90>
    800033ba:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033bc:	40bc                	lw	a5,64(s1)
    800033be:	cf81                	beqz	a5,800033d6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033c0:	64a4                	ld	s1,72(s1)
    800033c2:	fee49de3          	bne	s1,a4,800033bc <bread+0x86>
  panic("bget: no buffers");
    800033c6:	00005517          	auipc	a0,0x5
    800033ca:	1da50513          	addi	a0,a0,474 # 800085a0 <syscalls+0xc0>
    800033ce:	ffffd097          	auipc	ra,0xffffd
    800033d2:	170080e7          	jalr	368(ra) # 8000053e <panic>
      b->dev = dev;
    800033d6:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800033da:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800033de:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033e2:	4785                	li	a5,1
    800033e4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033e6:	00015517          	auipc	a0,0x15
    800033ea:	8fa50513          	addi	a0,a0,-1798 # 80017ce0 <bcache>
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	8aa080e7          	jalr	-1878(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    800033f6:	01048513          	addi	a0,s1,16
    800033fa:	00001097          	auipc	ra,0x1
    800033fe:	408080e7          	jalr	1032(ra) # 80004802 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003402:	409c                	lw	a5,0(s1)
    80003404:	cb89                	beqz	a5,80003416 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003406:	8526                	mv	a0,s1
    80003408:	70a2                	ld	ra,40(sp)
    8000340a:	7402                	ld	s0,32(sp)
    8000340c:	64e2                	ld	s1,24(sp)
    8000340e:	6942                	ld	s2,16(sp)
    80003410:	69a2                	ld	s3,8(sp)
    80003412:	6145                	addi	sp,sp,48
    80003414:	8082                	ret
    virtio_disk_rw(b, 0);
    80003416:	4581                	li	a1,0
    80003418:	8526                	mv	a0,s1
    8000341a:	00003097          	auipc	ra,0x3
    8000341e:	f0c080e7          	jalr	-244(ra) # 80006326 <virtio_disk_rw>
    b->valid = 1;
    80003422:	4785                	li	a5,1
    80003424:	c09c                	sw	a5,0(s1)
  return b;
    80003426:	b7c5                	j	80003406 <bread+0xd0>

0000000080003428 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003428:	1101                	addi	sp,sp,-32
    8000342a:	ec06                	sd	ra,24(sp)
    8000342c:	e822                	sd	s0,16(sp)
    8000342e:	e426                	sd	s1,8(sp)
    80003430:	1000                	addi	s0,sp,32
    80003432:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003434:	0541                	addi	a0,a0,16
    80003436:	00001097          	auipc	ra,0x1
    8000343a:	466080e7          	jalr	1126(ra) # 8000489c <holdingsleep>
    8000343e:	cd01                	beqz	a0,80003456 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003440:	4585                	li	a1,1
    80003442:	8526                	mv	a0,s1
    80003444:	00003097          	auipc	ra,0x3
    80003448:	ee2080e7          	jalr	-286(ra) # 80006326 <virtio_disk_rw>
}
    8000344c:	60e2                	ld	ra,24(sp)
    8000344e:	6442                	ld	s0,16(sp)
    80003450:	64a2                	ld	s1,8(sp)
    80003452:	6105                	addi	sp,sp,32
    80003454:	8082                	ret
    panic("bwrite");
    80003456:	00005517          	auipc	a0,0x5
    8000345a:	16250513          	addi	a0,a0,354 # 800085b8 <syscalls+0xd8>
    8000345e:	ffffd097          	auipc	ra,0xffffd
    80003462:	0e0080e7          	jalr	224(ra) # 8000053e <panic>

0000000080003466 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003466:	1101                	addi	sp,sp,-32
    80003468:	ec06                	sd	ra,24(sp)
    8000346a:	e822                	sd	s0,16(sp)
    8000346c:	e426                	sd	s1,8(sp)
    8000346e:	e04a                	sd	s2,0(sp)
    80003470:	1000                	addi	s0,sp,32
    80003472:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003474:	01050913          	addi	s2,a0,16
    80003478:	854a                	mv	a0,s2
    8000347a:	00001097          	auipc	ra,0x1
    8000347e:	422080e7          	jalr	1058(ra) # 8000489c <holdingsleep>
    80003482:	c92d                	beqz	a0,800034f4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003484:	854a                	mv	a0,s2
    80003486:	00001097          	auipc	ra,0x1
    8000348a:	3d2080e7          	jalr	978(ra) # 80004858 <releasesleep>

  acquire(&bcache.lock);
    8000348e:	00015517          	auipc	a0,0x15
    80003492:	85250513          	addi	a0,a0,-1966 # 80017ce0 <bcache>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	74e080e7          	jalr	1870(ra) # 80000be4 <acquire>
  b->refcnt--;
    8000349e:	40bc                	lw	a5,64(s1)
    800034a0:	37fd                	addiw	a5,a5,-1
    800034a2:	0007871b          	sext.w	a4,a5
    800034a6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034a8:	eb05                	bnez	a4,800034d8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034aa:	68bc                	ld	a5,80(s1)
    800034ac:	64b8                	ld	a4,72(s1)
    800034ae:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034b0:	64bc                	ld	a5,72(s1)
    800034b2:	68b8                	ld	a4,80(s1)
    800034b4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034b6:	0001d797          	auipc	a5,0x1d
    800034ba:	82a78793          	addi	a5,a5,-2006 # 8001fce0 <bcache+0x8000>
    800034be:	2b87b703          	ld	a4,696(a5)
    800034c2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034c4:	0001d717          	auipc	a4,0x1d
    800034c8:	a8470713          	addi	a4,a4,-1404 # 8001ff48 <bcache+0x8268>
    800034cc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034ce:	2b87b703          	ld	a4,696(a5)
    800034d2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034d4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034d8:	00015517          	auipc	a0,0x15
    800034dc:	80850513          	addi	a0,a0,-2040 # 80017ce0 <bcache>
    800034e0:	ffffd097          	auipc	ra,0xffffd
    800034e4:	7b8080e7          	jalr	1976(ra) # 80000c98 <release>
}
    800034e8:	60e2                	ld	ra,24(sp)
    800034ea:	6442                	ld	s0,16(sp)
    800034ec:	64a2                	ld	s1,8(sp)
    800034ee:	6902                	ld	s2,0(sp)
    800034f0:	6105                	addi	sp,sp,32
    800034f2:	8082                	ret
    panic("brelse");
    800034f4:	00005517          	auipc	a0,0x5
    800034f8:	0cc50513          	addi	a0,a0,204 # 800085c0 <syscalls+0xe0>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	042080e7          	jalr	66(ra) # 8000053e <panic>

0000000080003504 <bpin>:

void
bpin(struct buf *b) {
    80003504:	1101                	addi	sp,sp,-32
    80003506:	ec06                	sd	ra,24(sp)
    80003508:	e822                	sd	s0,16(sp)
    8000350a:	e426                	sd	s1,8(sp)
    8000350c:	1000                	addi	s0,sp,32
    8000350e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003510:	00014517          	auipc	a0,0x14
    80003514:	7d050513          	addi	a0,a0,2000 # 80017ce0 <bcache>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	6cc080e7          	jalr	1740(ra) # 80000be4 <acquire>
  b->refcnt++;
    80003520:	40bc                	lw	a5,64(s1)
    80003522:	2785                	addiw	a5,a5,1
    80003524:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003526:	00014517          	auipc	a0,0x14
    8000352a:	7ba50513          	addi	a0,a0,1978 # 80017ce0 <bcache>
    8000352e:	ffffd097          	auipc	ra,0xffffd
    80003532:	76a080e7          	jalr	1898(ra) # 80000c98 <release>
}
    80003536:	60e2                	ld	ra,24(sp)
    80003538:	6442                	ld	s0,16(sp)
    8000353a:	64a2                	ld	s1,8(sp)
    8000353c:	6105                	addi	sp,sp,32
    8000353e:	8082                	ret

0000000080003540 <bunpin>:

void
bunpin(struct buf *b) {
    80003540:	1101                	addi	sp,sp,-32
    80003542:	ec06                	sd	ra,24(sp)
    80003544:	e822                	sd	s0,16(sp)
    80003546:	e426                	sd	s1,8(sp)
    80003548:	1000                	addi	s0,sp,32
    8000354a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000354c:	00014517          	auipc	a0,0x14
    80003550:	79450513          	addi	a0,a0,1940 # 80017ce0 <bcache>
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	690080e7          	jalr	1680(ra) # 80000be4 <acquire>
  b->refcnt--;
    8000355c:	40bc                	lw	a5,64(s1)
    8000355e:	37fd                	addiw	a5,a5,-1
    80003560:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003562:	00014517          	auipc	a0,0x14
    80003566:	77e50513          	addi	a0,a0,1918 # 80017ce0 <bcache>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	72e080e7          	jalr	1838(ra) # 80000c98 <release>
}
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6105                	addi	sp,sp,32
    8000357a:	8082                	ret

000000008000357c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	e04a                	sd	s2,0(sp)
    80003586:	1000                	addi	s0,sp,32
    80003588:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000358a:	00d5d59b          	srliw	a1,a1,0xd
    8000358e:	0001d797          	auipc	a5,0x1d
    80003592:	e2e7a783          	lw	a5,-466(a5) # 800203bc <sb+0x1c>
    80003596:	9dbd                	addw	a1,a1,a5
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	d9e080e7          	jalr	-610(ra) # 80003336 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035a0:	0074f713          	andi	a4,s1,7
    800035a4:	4785                	li	a5,1
    800035a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035aa:	14ce                	slli	s1,s1,0x33
    800035ac:	90d9                	srli	s1,s1,0x36
    800035ae:	00950733          	add	a4,a0,s1
    800035b2:	05874703          	lbu	a4,88(a4)
    800035b6:	00e7f6b3          	and	a3,a5,a4
    800035ba:	c69d                	beqz	a3,800035e8 <bfree+0x6c>
    800035bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035be:	94aa                	add	s1,s1,a0
    800035c0:	fff7c793          	not	a5,a5
    800035c4:	8ff9                	and	a5,a5,a4
    800035c6:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	118080e7          	jalr	280(ra) # 800046e2 <log_write>
  brelse(bp);
    800035d2:	854a                	mv	a0,s2
    800035d4:	00000097          	auipc	ra,0x0
    800035d8:	e92080e7          	jalr	-366(ra) # 80003466 <brelse>
}
    800035dc:	60e2                	ld	ra,24(sp)
    800035de:	6442                	ld	s0,16(sp)
    800035e0:	64a2                	ld	s1,8(sp)
    800035e2:	6902                	ld	s2,0(sp)
    800035e4:	6105                	addi	sp,sp,32
    800035e6:	8082                	ret
    panic("freeing free block");
    800035e8:	00005517          	auipc	a0,0x5
    800035ec:	fe050513          	addi	a0,a0,-32 # 800085c8 <syscalls+0xe8>
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>

00000000800035f8 <balloc>:
{
    800035f8:	711d                	addi	sp,sp,-96
    800035fa:	ec86                	sd	ra,88(sp)
    800035fc:	e8a2                	sd	s0,80(sp)
    800035fe:	e4a6                	sd	s1,72(sp)
    80003600:	e0ca                	sd	s2,64(sp)
    80003602:	fc4e                	sd	s3,56(sp)
    80003604:	f852                	sd	s4,48(sp)
    80003606:	f456                	sd	s5,40(sp)
    80003608:	f05a                	sd	s6,32(sp)
    8000360a:	ec5e                	sd	s7,24(sp)
    8000360c:	e862                	sd	s8,16(sp)
    8000360e:	e466                	sd	s9,8(sp)
    80003610:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003612:	0001d797          	auipc	a5,0x1d
    80003616:	d927a783          	lw	a5,-622(a5) # 800203a4 <sb+0x4>
    8000361a:	cbd1                	beqz	a5,800036ae <balloc+0xb6>
    8000361c:	8baa                	mv	s7,a0
    8000361e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003620:	0001db17          	auipc	s6,0x1d
    80003624:	d80b0b13          	addi	s6,s6,-640 # 800203a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003628:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000362a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000362c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000362e:	6c89                	lui	s9,0x2
    80003630:	a831                	j	8000364c <balloc+0x54>
    brelse(bp);
    80003632:	854a                	mv	a0,s2
    80003634:	00000097          	auipc	ra,0x0
    80003638:	e32080e7          	jalr	-462(ra) # 80003466 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000363c:	015c87bb          	addw	a5,s9,s5
    80003640:	00078a9b          	sext.w	s5,a5
    80003644:	004b2703          	lw	a4,4(s6)
    80003648:	06eaf363          	bgeu	s5,a4,800036ae <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000364c:	41fad79b          	sraiw	a5,s5,0x1f
    80003650:	0137d79b          	srliw	a5,a5,0x13
    80003654:	015787bb          	addw	a5,a5,s5
    80003658:	40d7d79b          	sraiw	a5,a5,0xd
    8000365c:	01cb2583          	lw	a1,28(s6)
    80003660:	9dbd                	addw	a1,a1,a5
    80003662:	855e                	mv	a0,s7
    80003664:	00000097          	auipc	ra,0x0
    80003668:	cd2080e7          	jalr	-814(ra) # 80003336 <bread>
    8000366c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000366e:	004b2503          	lw	a0,4(s6)
    80003672:	000a849b          	sext.w	s1,s5
    80003676:	8662                	mv	a2,s8
    80003678:	faa4fde3          	bgeu	s1,a0,80003632 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000367c:	41f6579b          	sraiw	a5,a2,0x1f
    80003680:	01d7d69b          	srliw	a3,a5,0x1d
    80003684:	00c6873b          	addw	a4,a3,a2
    80003688:	00777793          	andi	a5,a4,7
    8000368c:	9f95                	subw	a5,a5,a3
    8000368e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003692:	4037571b          	sraiw	a4,a4,0x3
    80003696:	00e906b3          	add	a3,s2,a4
    8000369a:	0586c683          	lbu	a3,88(a3)
    8000369e:	00d7f5b3          	and	a1,a5,a3
    800036a2:	cd91                	beqz	a1,800036be <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036a4:	2605                	addiw	a2,a2,1
    800036a6:	2485                	addiw	s1,s1,1
    800036a8:	fd4618e3          	bne	a2,s4,80003678 <balloc+0x80>
    800036ac:	b759                	j	80003632 <balloc+0x3a>
  panic("balloc: out of blocks");
    800036ae:	00005517          	auipc	a0,0x5
    800036b2:	f3250513          	addi	a0,a0,-206 # 800085e0 <syscalls+0x100>
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	e88080e7          	jalr	-376(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036be:	974a                	add	a4,a4,s2
    800036c0:	8fd5                	or	a5,a5,a3
    800036c2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036c6:	854a                	mv	a0,s2
    800036c8:	00001097          	auipc	ra,0x1
    800036cc:	01a080e7          	jalr	26(ra) # 800046e2 <log_write>
        brelse(bp);
    800036d0:	854a                	mv	a0,s2
    800036d2:	00000097          	auipc	ra,0x0
    800036d6:	d94080e7          	jalr	-620(ra) # 80003466 <brelse>
  bp = bread(dev, bno);
    800036da:	85a6                	mv	a1,s1
    800036dc:	855e                	mv	a0,s7
    800036de:	00000097          	auipc	ra,0x0
    800036e2:	c58080e7          	jalr	-936(ra) # 80003336 <bread>
    800036e6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036e8:	40000613          	li	a2,1024
    800036ec:	4581                	li	a1,0
    800036ee:	05850513          	addi	a0,a0,88
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	5ee080e7          	jalr	1518(ra) # 80000ce0 <memset>
  log_write(bp);
    800036fa:	854a                	mv	a0,s2
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	fe6080e7          	jalr	-26(ra) # 800046e2 <log_write>
  brelse(bp);
    80003704:	854a                	mv	a0,s2
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	d60080e7          	jalr	-672(ra) # 80003466 <brelse>
}
    8000370e:	8526                	mv	a0,s1
    80003710:	60e6                	ld	ra,88(sp)
    80003712:	6446                	ld	s0,80(sp)
    80003714:	64a6                	ld	s1,72(sp)
    80003716:	6906                	ld	s2,64(sp)
    80003718:	79e2                	ld	s3,56(sp)
    8000371a:	7a42                	ld	s4,48(sp)
    8000371c:	7aa2                	ld	s5,40(sp)
    8000371e:	7b02                	ld	s6,32(sp)
    80003720:	6be2                	ld	s7,24(sp)
    80003722:	6c42                	ld	s8,16(sp)
    80003724:	6ca2                	ld	s9,8(sp)
    80003726:	6125                	addi	sp,sp,96
    80003728:	8082                	ret

000000008000372a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000372a:	7179                	addi	sp,sp,-48
    8000372c:	f406                	sd	ra,40(sp)
    8000372e:	f022                	sd	s0,32(sp)
    80003730:	ec26                	sd	s1,24(sp)
    80003732:	e84a                	sd	s2,16(sp)
    80003734:	e44e                	sd	s3,8(sp)
    80003736:	e052                	sd	s4,0(sp)
    80003738:	1800                	addi	s0,sp,48
    8000373a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000373c:	47ad                	li	a5,11
    8000373e:	04b7fe63          	bgeu	a5,a1,8000379a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003742:	ff45849b          	addiw	s1,a1,-12
    80003746:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000374a:	0ff00793          	li	a5,255
    8000374e:	0ae7e363          	bltu	a5,a4,800037f4 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003752:	08052583          	lw	a1,128(a0)
    80003756:	c5ad                	beqz	a1,800037c0 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003758:	00092503          	lw	a0,0(s2)
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	bda080e7          	jalr	-1062(ra) # 80003336 <bread>
    80003764:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003766:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000376a:	02049593          	slli	a1,s1,0x20
    8000376e:	9181                	srli	a1,a1,0x20
    80003770:	058a                	slli	a1,a1,0x2
    80003772:	00b784b3          	add	s1,a5,a1
    80003776:	0004a983          	lw	s3,0(s1)
    8000377a:	04098d63          	beqz	s3,800037d4 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000377e:	8552                	mv	a0,s4
    80003780:	00000097          	auipc	ra,0x0
    80003784:	ce6080e7          	jalr	-794(ra) # 80003466 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003788:	854e                	mv	a0,s3
    8000378a:	70a2                	ld	ra,40(sp)
    8000378c:	7402                	ld	s0,32(sp)
    8000378e:	64e2                	ld	s1,24(sp)
    80003790:	6942                	ld	s2,16(sp)
    80003792:	69a2                	ld	s3,8(sp)
    80003794:	6a02                	ld	s4,0(sp)
    80003796:	6145                	addi	sp,sp,48
    80003798:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000379a:	02059493          	slli	s1,a1,0x20
    8000379e:	9081                	srli	s1,s1,0x20
    800037a0:	048a                	slli	s1,s1,0x2
    800037a2:	94aa                	add	s1,s1,a0
    800037a4:	0504a983          	lw	s3,80(s1)
    800037a8:	fe0990e3          	bnez	s3,80003788 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800037ac:	4108                	lw	a0,0(a0)
    800037ae:	00000097          	auipc	ra,0x0
    800037b2:	e4a080e7          	jalr	-438(ra) # 800035f8 <balloc>
    800037b6:	0005099b          	sext.w	s3,a0
    800037ba:	0534a823          	sw	s3,80(s1)
    800037be:	b7e9                	j	80003788 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800037c0:	4108                	lw	a0,0(a0)
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	e36080e7          	jalr	-458(ra) # 800035f8 <balloc>
    800037ca:	0005059b          	sext.w	a1,a0
    800037ce:	08b92023          	sw	a1,128(s2)
    800037d2:	b759                	j	80003758 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800037d4:	00092503          	lw	a0,0(s2)
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	e20080e7          	jalr	-480(ra) # 800035f8 <balloc>
    800037e0:	0005099b          	sext.w	s3,a0
    800037e4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800037e8:	8552                	mv	a0,s4
    800037ea:	00001097          	auipc	ra,0x1
    800037ee:	ef8080e7          	jalr	-264(ra) # 800046e2 <log_write>
    800037f2:	b771                	j	8000377e <bmap+0x54>
  panic("bmap: out of range");
    800037f4:	00005517          	auipc	a0,0x5
    800037f8:	e0450513          	addi	a0,a0,-508 # 800085f8 <syscalls+0x118>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	d42080e7          	jalr	-702(ra) # 8000053e <panic>

0000000080003804 <iget>:
{
    80003804:	7179                	addi	sp,sp,-48
    80003806:	f406                	sd	ra,40(sp)
    80003808:	f022                	sd	s0,32(sp)
    8000380a:	ec26                	sd	s1,24(sp)
    8000380c:	e84a                	sd	s2,16(sp)
    8000380e:	e44e                	sd	s3,8(sp)
    80003810:	e052                	sd	s4,0(sp)
    80003812:	1800                	addi	s0,sp,48
    80003814:	89aa                	mv	s3,a0
    80003816:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003818:	0001d517          	auipc	a0,0x1d
    8000381c:	ba850513          	addi	a0,a0,-1112 # 800203c0 <itable>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	3c4080e7          	jalr	964(ra) # 80000be4 <acquire>
  empty = 0;
    80003828:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000382a:	0001d497          	auipc	s1,0x1d
    8000382e:	bae48493          	addi	s1,s1,-1106 # 800203d8 <itable+0x18>
    80003832:	0001e697          	auipc	a3,0x1e
    80003836:	63668693          	addi	a3,a3,1590 # 80021e68 <log>
    8000383a:	a039                	j	80003848 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000383c:	02090b63          	beqz	s2,80003872 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003840:	08848493          	addi	s1,s1,136
    80003844:	02d48a63          	beq	s1,a3,80003878 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003848:	449c                	lw	a5,8(s1)
    8000384a:	fef059e3          	blez	a5,8000383c <iget+0x38>
    8000384e:	4098                	lw	a4,0(s1)
    80003850:	ff3716e3          	bne	a4,s3,8000383c <iget+0x38>
    80003854:	40d8                	lw	a4,4(s1)
    80003856:	ff4713e3          	bne	a4,s4,8000383c <iget+0x38>
      ip->ref++;
    8000385a:	2785                	addiw	a5,a5,1
    8000385c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000385e:	0001d517          	auipc	a0,0x1d
    80003862:	b6250513          	addi	a0,a0,-1182 # 800203c0 <itable>
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	432080e7          	jalr	1074(ra) # 80000c98 <release>
      return ip;
    8000386e:	8926                	mv	s2,s1
    80003870:	a03d                	j	8000389e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003872:	f7f9                	bnez	a5,80003840 <iget+0x3c>
    80003874:	8926                	mv	s2,s1
    80003876:	b7e9                	j	80003840 <iget+0x3c>
  if(empty == 0)
    80003878:	02090c63          	beqz	s2,800038b0 <iget+0xac>
  ip->dev = dev;
    8000387c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003880:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003884:	4785                	li	a5,1
    80003886:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000388a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000388e:	0001d517          	auipc	a0,0x1d
    80003892:	b3250513          	addi	a0,a0,-1230 # 800203c0 <itable>
    80003896:	ffffd097          	auipc	ra,0xffffd
    8000389a:	402080e7          	jalr	1026(ra) # 80000c98 <release>
}
    8000389e:	854a                	mv	a0,s2
    800038a0:	70a2                	ld	ra,40(sp)
    800038a2:	7402                	ld	s0,32(sp)
    800038a4:	64e2                	ld	s1,24(sp)
    800038a6:	6942                	ld	s2,16(sp)
    800038a8:	69a2                	ld	s3,8(sp)
    800038aa:	6a02                	ld	s4,0(sp)
    800038ac:	6145                	addi	sp,sp,48
    800038ae:	8082                	ret
    panic("iget: no inodes");
    800038b0:	00005517          	auipc	a0,0x5
    800038b4:	d6050513          	addi	a0,a0,-672 # 80008610 <syscalls+0x130>
    800038b8:	ffffd097          	auipc	ra,0xffffd
    800038bc:	c86080e7          	jalr	-890(ra) # 8000053e <panic>

00000000800038c0 <fsinit>:
fsinit(int dev) {
    800038c0:	7179                	addi	sp,sp,-48
    800038c2:	f406                	sd	ra,40(sp)
    800038c4:	f022                	sd	s0,32(sp)
    800038c6:	ec26                	sd	s1,24(sp)
    800038c8:	e84a                	sd	s2,16(sp)
    800038ca:	e44e                	sd	s3,8(sp)
    800038cc:	1800                	addi	s0,sp,48
    800038ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038d0:	4585                	li	a1,1
    800038d2:	00000097          	auipc	ra,0x0
    800038d6:	a64080e7          	jalr	-1436(ra) # 80003336 <bread>
    800038da:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038dc:	0001d997          	auipc	s3,0x1d
    800038e0:	ac498993          	addi	s3,s3,-1340 # 800203a0 <sb>
    800038e4:	02000613          	li	a2,32
    800038e8:	05850593          	addi	a1,a0,88
    800038ec:	854e                	mv	a0,s3
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	452080e7          	jalr	1106(ra) # 80000d40 <memmove>
  brelse(bp);
    800038f6:	8526                	mv	a0,s1
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	b6e080e7          	jalr	-1170(ra) # 80003466 <brelse>
  if(sb.magic != FSMAGIC)
    80003900:	0009a703          	lw	a4,0(s3)
    80003904:	102037b7          	lui	a5,0x10203
    80003908:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000390c:	02f71263          	bne	a4,a5,80003930 <fsinit+0x70>
  initlog(dev, &sb);
    80003910:	0001d597          	auipc	a1,0x1d
    80003914:	a9058593          	addi	a1,a1,-1392 # 800203a0 <sb>
    80003918:	854a                	mv	a0,s2
    8000391a:	00001097          	auipc	ra,0x1
    8000391e:	b4c080e7          	jalr	-1204(ra) # 80004466 <initlog>
}
    80003922:	70a2                	ld	ra,40(sp)
    80003924:	7402                	ld	s0,32(sp)
    80003926:	64e2                	ld	s1,24(sp)
    80003928:	6942                	ld	s2,16(sp)
    8000392a:	69a2                	ld	s3,8(sp)
    8000392c:	6145                	addi	sp,sp,48
    8000392e:	8082                	ret
    panic("invalid file system");
    80003930:	00005517          	auipc	a0,0x5
    80003934:	cf050513          	addi	a0,a0,-784 # 80008620 <syscalls+0x140>
    80003938:	ffffd097          	auipc	ra,0xffffd
    8000393c:	c06080e7          	jalr	-1018(ra) # 8000053e <panic>

0000000080003940 <iinit>:
{
    80003940:	7179                	addi	sp,sp,-48
    80003942:	f406                	sd	ra,40(sp)
    80003944:	f022                	sd	s0,32(sp)
    80003946:	ec26                	sd	s1,24(sp)
    80003948:	e84a                	sd	s2,16(sp)
    8000394a:	e44e                	sd	s3,8(sp)
    8000394c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000394e:	00005597          	auipc	a1,0x5
    80003952:	cea58593          	addi	a1,a1,-790 # 80008638 <syscalls+0x158>
    80003956:	0001d517          	auipc	a0,0x1d
    8000395a:	a6a50513          	addi	a0,a0,-1430 # 800203c0 <itable>
    8000395e:	ffffd097          	auipc	ra,0xffffd
    80003962:	1f6080e7          	jalr	502(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003966:	0001d497          	auipc	s1,0x1d
    8000396a:	a8248493          	addi	s1,s1,-1406 # 800203e8 <itable+0x28>
    8000396e:	0001e997          	auipc	s3,0x1e
    80003972:	50a98993          	addi	s3,s3,1290 # 80021e78 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003976:	00005917          	auipc	s2,0x5
    8000397a:	cca90913          	addi	s2,s2,-822 # 80008640 <syscalls+0x160>
    8000397e:	85ca                	mv	a1,s2
    80003980:	8526                	mv	a0,s1
    80003982:	00001097          	auipc	ra,0x1
    80003986:	e46080e7          	jalr	-442(ra) # 800047c8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000398a:	08848493          	addi	s1,s1,136
    8000398e:	ff3498e3          	bne	s1,s3,8000397e <iinit+0x3e>
}
    80003992:	70a2                	ld	ra,40(sp)
    80003994:	7402                	ld	s0,32(sp)
    80003996:	64e2                	ld	s1,24(sp)
    80003998:	6942                	ld	s2,16(sp)
    8000399a:	69a2                	ld	s3,8(sp)
    8000399c:	6145                	addi	sp,sp,48
    8000399e:	8082                	ret

00000000800039a0 <ialloc>:
{
    800039a0:	715d                	addi	sp,sp,-80
    800039a2:	e486                	sd	ra,72(sp)
    800039a4:	e0a2                	sd	s0,64(sp)
    800039a6:	fc26                	sd	s1,56(sp)
    800039a8:	f84a                	sd	s2,48(sp)
    800039aa:	f44e                	sd	s3,40(sp)
    800039ac:	f052                	sd	s4,32(sp)
    800039ae:	ec56                	sd	s5,24(sp)
    800039b0:	e85a                	sd	s6,16(sp)
    800039b2:	e45e                	sd	s7,8(sp)
    800039b4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039b6:	0001d717          	auipc	a4,0x1d
    800039ba:	9f672703          	lw	a4,-1546(a4) # 800203ac <sb+0xc>
    800039be:	4785                	li	a5,1
    800039c0:	04e7fa63          	bgeu	a5,a4,80003a14 <ialloc+0x74>
    800039c4:	8aaa                	mv	s5,a0
    800039c6:	8bae                	mv	s7,a1
    800039c8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039ca:	0001da17          	auipc	s4,0x1d
    800039ce:	9d6a0a13          	addi	s4,s4,-1578 # 800203a0 <sb>
    800039d2:	00048b1b          	sext.w	s6,s1
    800039d6:	0044d593          	srli	a1,s1,0x4
    800039da:	018a2783          	lw	a5,24(s4)
    800039de:	9dbd                	addw	a1,a1,a5
    800039e0:	8556                	mv	a0,s5
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	954080e7          	jalr	-1708(ra) # 80003336 <bread>
    800039ea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800039ec:	05850993          	addi	s3,a0,88
    800039f0:	00f4f793          	andi	a5,s1,15
    800039f4:	079a                	slli	a5,a5,0x6
    800039f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039f8:	00099783          	lh	a5,0(s3)
    800039fc:	c785                	beqz	a5,80003a24 <ialloc+0x84>
    brelse(bp);
    800039fe:	00000097          	auipc	ra,0x0
    80003a02:	a68080e7          	jalr	-1432(ra) # 80003466 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a06:	0485                	addi	s1,s1,1
    80003a08:	00ca2703          	lw	a4,12(s4)
    80003a0c:	0004879b          	sext.w	a5,s1
    80003a10:	fce7e1e3          	bltu	a5,a4,800039d2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003a14:	00005517          	auipc	a0,0x5
    80003a18:	c3450513          	addi	a0,a0,-972 # 80008648 <syscalls+0x168>
    80003a1c:	ffffd097          	auipc	ra,0xffffd
    80003a20:	b22080e7          	jalr	-1246(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    80003a24:	04000613          	li	a2,64
    80003a28:	4581                	li	a1,0
    80003a2a:	854e                	mv	a0,s3
    80003a2c:	ffffd097          	auipc	ra,0xffffd
    80003a30:	2b4080e7          	jalr	692(ra) # 80000ce0 <memset>
      dip->type = type;
    80003a34:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a38:	854a                	mv	a0,s2
    80003a3a:	00001097          	auipc	ra,0x1
    80003a3e:	ca8080e7          	jalr	-856(ra) # 800046e2 <log_write>
      brelse(bp);
    80003a42:	854a                	mv	a0,s2
    80003a44:	00000097          	auipc	ra,0x0
    80003a48:	a22080e7          	jalr	-1502(ra) # 80003466 <brelse>
      return iget(dev, inum);
    80003a4c:	85da                	mv	a1,s6
    80003a4e:	8556                	mv	a0,s5
    80003a50:	00000097          	auipc	ra,0x0
    80003a54:	db4080e7          	jalr	-588(ra) # 80003804 <iget>
}
    80003a58:	60a6                	ld	ra,72(sp)
    80003a5a:	6406                	ld	s0,64(sp)
    80003a5c:	74e2                	ld	s1,56(sp)
    80003a5e:	7942                	ld	s2,48(sp)
    80003a60:	79a2                	ld	s3,40(sp)
    80003a62:	7a02                	ld	s4,32(sp)
    80003a64:	6ae2                	ld	s5,24(sp)
    80003a66:	6b42                	ld	s6,16(sp)
    80003a68:	6ba2                	ld	s7,8(sp)
    80003a6a:	6161                	addi	sp,sp,80
    80003a6c:	8082                	ret

0000000080003a6e <iupdate>:
{
    80003a6e:	1101                	addi	sp,sp,-32
    80003a70:	ec06                	sd	ra,24(sp)
    80003a72:	e822                	sd	s0,16(sp)
    80003a74:	e426                	sd	s1,8(sp)
    80003a76:	e04a                	sd	s2,0(sp)
    80003a78:	1000                	addi	s0,sp,32
    80003a7a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a7c:	415c                	lw	a5,4(a0)
    80003a7e:	0047d79b          	srliw	a5,a5,0x4
    80003a82:	0001d597          	auipc	a1,0x1d
    80003a86:	9365a583          	lw	a1,-1738(a1) # 800203b8 <sb+0x18>
    80003a8a:	9dbd                	addw	a1,a1,a5
    80003a8c:	4108                	lw	a0,0(a0)
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	8a8080e7          	jalr	-1880(ra) # 80003336 <bread>
    80003a96:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a98:	05850793          	addi	a5,a0,88
    80003a9c:	40c8                	lw	a0,4(s1)
    80003a9e:	893d                	andi	a0,a0,15
    80003aa0:	051a                	slli	a0,a0,0x6
    80003aa2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003aa4:	04449703          	lh	a4,68(s1)
    80003aa8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003aac:	04649703          	lh	a4,70(s1)
    80003ab0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ab4:	04849703          	lh	a4,72(s1)
    80003ab8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003abc:	04a49703          	lh	a4,74(s1)
    80003ac0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ac4:	44f8                	lw	a4,76(s1)
    80003ac6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ac8:	03400613          	li	a2,52
    80003acc:	05048593          	addi	a1,s1,80
    80003ad0:	0531                	addi	a0,a0,12
    80003ad2:	ffffd097          	auipc	ra,0xffffd
    80003ad6:	26e080e7          	jalr	622(ra) # 80000d40 <memmove>
  log_write(bp);
    80003ada:	854a                	mv	a0,s2
    80003adc:	00001097          	auipc	ra,0x1
    80003ae0:	c06080e7          	jalr	-1018(ra) # 800046e2 <log_write>
  brelse(bp);
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	980080e7          	jalr	-1664(ra) # 80003466 <brelse>
}
    80003aee:	60e2                	ld	ra,24(sp)
    80003af0:	6442                	ld	s0,16(sp)
    80003af2:	64a2                	ld	s1,8(sp)
    80003af4:	6902                	ld	s2,0(sp)
    80003af6:	6105                	addi	sp,sp,32
    80003af8:	8082                	ret

0000000080003afa <idup>:
{
    80003afa:	1101                	addi	sp,sp,-32
    80003afc:	ec06                	sd	ra,24(sp)
    80003afe:	e822                	sd	s0,16(sp)
    80003b00:	e426                	sd	s1,8(sp)
    80003b02:	1000                	addi	s0,sp,32
    80003b04:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b06:	0001d517          	auipc	a0,0x1d
    80003b0a:	8ba50513          	addi	a0,a0,-1862 # 800203c0 <itable>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	0d6080e7          	jalr	214(ra) # 80000be4 <acquire>
  ip->ref++;
    80003b16:	449c                	lw	a5,8(s1)
    80003b18:	2785                	addiw	a5,a5,1
    80003b1a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b1c:	0001d517          	auipc	a0,0x1d
    80003b20:	8a450513          	addi	a0,a0,-1884 # 800203c0 <itable>
    80003b24:	ffffd097          	auipc	ra,0xffffd
    80003b28:	174080e7          	jalr	372(ra) # 80000c98 <release>
}
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	64a2                	ld	s1,8(sp)
    80003b34:	6105                	addi	sp,sp,32
    80003b36:	8082                	ret

0000000080003b38 <ilock>:
{
    80003b38:	1101                	addi	sp,sp,-32
    80003b3a:	ec06                	sd	ra,24(sp)
    80003b3c:	e822                	sd	s0,16(sp)
    80003b3e:	e426                	sd	s1,8(sp)
    80003b40:	e04a                	sd	s2,0(sp)
    80003b42:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b44:	c115                	beqz	a0,80003b68 <ilock+0x30>
    80003b46:	84aa                	mv	s1,a0
    80003b48:	451c                	lw	a5,8(a0)
    80003b4a:	00f05f63          	blez	a5,80003b68 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b4e:	0541                	addi	a0,a0,16
    80003b50:	00001097          	auipc	ra,0x1
    80003b54:	cb2080e7          	jalr	-846(ra) # 80004802 <acquiresleep>
  if(ip->valid == 0){
    80003b58:	40bc                	lw	a5,64(s1)
    80003b5a:	cf99                	beqz	a5,80003b78 <ilock+0x40>
}
    80003b5c:	60e2                	ld	ra,24(sp)
    80003b5e:	6442                	ld	s0,16(sp)
    80003b60:	64a2                	ld	s1,8(sp)
    80003b62:	6902                	ld	s2,0(sp)
    80003b64:	6105                	addi	sp,sp,32
    80003b66:	8082                	ret
    panic("ilock");
    80003b68:	00005517          	auipc	a0,0x5
    80003b6c:	af850513          	addi	a0,a0,-1288 # 80008660 <syscalls+0x180>
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	9ce080e7          	jalr	-1586(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b78:	40dc                	lw	a5,4(s1)
    80003b7a:	0047d79b          	srliw	a5,a5,0x4
    80003b7e:	0001d597          	auipc	a1,0x1d
    80003b82:	83a5a583          	lw	a1,-1990(a1) # 800203b8 <sb+0x18>
    80003b86:	9dbd                	addw	a1,a1,a5
    80003b88:	4088                	lw	a0,0(s1)
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	7ac080e7          	jalr	1964(ra) # 80003336 <bread>
    80003b92:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b94:	05850593          	addi	a1,a0,88
    80003b98:	40dc                	lw	a5,4(s1)
    80003b9a:	8bbd                	andi	a5,a5,15
    80003b9c:	079a                	slli	a5,a5,0x6
    80003b9e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ba0:	00059783          	lh	a5,0(a1)
    80003ba4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ba8:	00259783          	lh	a5,2(a1)
    80003bac:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003bb0:	00459783          	lh	a5,4(a1)
    80003bb4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003bb8:	00659783          	lh	a5,6(a1)
    80003bbc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bc0:	459c                	lw	a5,8(a1)
    80003bc2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bc4:	03400613          	li	a2,52
    80003bc8:	05b1                	addi	a1,a1,12
    80003bca:	05048513          	addi	a0,s1,80
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	172080e7          	jalr	370(ra) # 80000d40 <memmove>
    brelse(bp);
    80003bd6:	854a                	mv	a0,s2
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	88e080e7          	jalr	-1906(ra) # 80003466 <brelse>
    ip->valid = 1;
    80003be0:	4785                	li	a5,1
    80003be2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003be4:	04449783          	lh	a5,68(s1)
    80003be8:	fbb5                	bnez	a5,80003b5c <ilock+0x24>
      panic("ilock: no type");
    80003bea:	00005517          	auipc	a0,0x5
    80003bee:	a7e50513          	addi	a0,a0,-1410 # 80008668 <syscalls+0x188>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	94c080e7          	jalr	-1716(ra) # 8000053e <panic>

0000000080003bfa <iunlock>:
{
    80003bfa:	1101                	addi	sp,sp,-32
    80003bfc:	ec06                	sd	ra,24(sp)
    80003bfe:	e822                	sd	s0,16(sp)
    80003c00:	e426                	sd	s1,8(sp)
    80003c02:	e04a                	sd	s2,0(sp)
    80003c04:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c06:	c905                	beqz	a0,80003c36 <iunlock+0x3c>
    80003c08:	84aa                	mv	s1,a0
    80003c0a:	01050913          	addi	s2,a0,16
    80003c0e:	854a                	mv	a0,s2
    80003c10:	00001097          	auipc	ra,0x1
    80003c14:	c8c080e7          	jalr	-884(ra) # 8000489c <holdingsleep>
    80003c18:	cd19                	beqz	a0,80003c36 <iunlock+0x3c>
    80003c1a:	449c                	lw	a5,8(s1)
    80003c1c:	00f05d63          	blez	a5,80003c36 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c20:	854a                	mv	a0,s2
    80003c22:	00001097          	auipc	ra,0x1
    80003c26:	c36080e7          	jalr	-970(ra) # 80004858 <releasesleep>
}
    80003c2a:	60e2                	ld	ra,24(sp)
    80003c2c:	6442                	ld	s0,16(sp)
    80003c2e:	64a2                	ld	s1,8(sp)
    80003c30:	6902                	ld	s2,0(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret
    panic("iunlock");
    80003c36:	00005517          	auipc	a0,0x5
    80003c3a:	a4250513          	addi	a0,a0,-1470 # 80008678 <syscalls+0x198>
    80003c3e:	ffffd097          	auipc	ra,0xffffd
    80003c42:	900080e7          	jalr	-1792(ra) # 8000053e <panic>

0000000080003c46 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c46:	7179                	addi	sp,sp,-48
    80003c48:	f406                	sd	ra,40(sp)
    80003c4a:	f022                	sd	s0,32(sp)
    80003c4c:	ec26                	sd	s1,24(sp)
    80003c4e:	e84a                	sd	s2,16(sp)
    80003c50:	e44e                	sd	s3,8(sp)
    80003c52:	e052                	sd	s4,0(sp)
    80003c54:	1800                	addi	s0,sp,48
    80003c56:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c58:	05050493          	addi	s1,a0,80
    80003c5c:	08050913          	addi	s2,a0,128
    80003c60:	a021                	j	80003c68 <itrunc+0x22>
    80003c62:	0491                	addi	s1,s1,4
    80003c64:	01248d63          	beq	s1,s2,80003c7e <itrunc+0x38>
    if(ip->addrs[i]){
    80003c68:	408c                	lw	a1,0(s1)
    80003c6a:	dde5                	beqz	a1,80003c62 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c6c:	0009a503          	lw	a0,0(s3)
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	90c080e7          	jalr	-1780(ra) # 8000357c <bfree>
      ip->addrs[i] = 0;
    80003c78:	0004a023          	sw	zero,0(s1)
    80003c7c:	b7dd                	j	80003c62 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c7e:	0809a583          	lw	a1,128(s3)
    80003c82:	e185                	bnez	a1,80003ca2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c84:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c88:	854e                	mv	a0,s3
    80003c8a:	00000097          	auipc	ra,0x0
    80003c8e:	de4080e7          	jalr	-540(ra) # 80003a6e <iupdate>
}
    80003c92:	70a2                	ld	ra,40(sp)
    80003c94:	7402                	ld	s0,32(sp)
    80003c96:	64e2                	ld	s1,24(sp)
    80003c98:	6942                	ld	s2,16(sp)
    80003c9a:	69a2                	ld	s3,8(sp)
    80003c9c:	6a02                	ld	s4,0(sp)
    80003c9e:	6145                	addi	sp,sp,48
    80003ca0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ca2:	0009a503          	lw	a0,0(s3)
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	690080e7          	jalr	1680(ra) # 80003336 <bread>
    80003cae:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003cb0:	05850493          	addi	s1,a0,88
    80003cb4:	45850913          	addi	s2,a0,1112
    80003cb8:	a811                	j	80003ccc <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003cba:	0009a503          	lw	a0,0(s3)
    80003cbe:	00000097          	auipc	ra,0x0
    80003cc2:	8be080e7          	jalr	-1858(ra) # 8000357c <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003cc6:	0491                	addi	s1,s1,4
    80003cc8:	01248563          	beq	s1,s2,80003cd2 <itrunc+0x8c>
      if(a[j])
    80003ccc:	408c                	lw	a1,0(s1)
    80003cce:	dde5                	beqz	a1,80003cc6 <itrunc+0x80>
    80003cd0:	b7ed                	j	80003cba <itrunc+0x74>
    brelse(bp);
    80003cd2:	8552                	mv	a0,s4
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	792080e7          	jalr	1938(ra) # 80003466 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003cdc:	0809a583          	lw	a1,128(s3)
    80003ce0:	0009a503          	lw	a0,0(s3)
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	898080e7          	jalr	-1896(ra) # 8000357c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003cec:	0809a023          	sw	zero,128(s3)
    80003cf0:	bf51                	j	80003c84 <itrunc+0x3e>

0000000080003cf2 <iput>:
{
    80003cf2:	1101                	addi	sp,sp,-32
    80003cf4:	ec06                	sd	ra,24(sp)
    80003cf6:	e822                	sd	s0,16(sp)
    80003cf8:	e426                	sd	s1,8(sp)
    80003cfa:	e04a                	sd	s2,0(sp)
    80003cfc:	1000                	addi	s0,sp,32
    80003cfe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d00:	0001c517          	auipc	a0,0x1c
    80003d04:	6c050513          	addi	a0,a0,1728 # 800203c0 <itable>
    80003d08:	ffffd097          	auipc	ra,0xffffd
    80003d0c:	edc080e7          	jalr	-292(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d10:	4498                	lw	a4,8(s1)
    80003d12:	4785                	li	a5,1
    80003d14:	02f70363          	beq	a4,a5,80003d3a <iput+0x48>
  ip->ref--;
    80003d18:	449c                	lw	a5,8(s1)
    80003d1a:	37fd                	addiw	a5,a5,-1
    80003d1c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d1e:	0001c517          	auipc	a0,0x1c
    80003d22:	6a250513          	addi	a0,a0,1698 # 800203c0 <itable>
    80003d26:	ffffd097          	auipc	ra,0xffffd
    80003d2a:	f72080e7          	jalr	-142(ra) # 80000c98 <release>
}
    80003d2e:	60e2                	ld	ra,24(sp)
    80003d30:	6442                	ld	s0,16(sp)
    80003d32:	64a2                	ld	s1,8(sp)
    80003d34:	6902                	ld	s2,0(sp)
    80003d36:	6105                	addi	sp,sp,32
    80003d38:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d3a:	40bc                	lw	a5,64(s1)
    80003d3c:	dff1                	beqz	a5,80003d18 <iput+0x26>
    80003d3e:	04a49783          	lh	a5,74(s1)
    80003d42:	fbf9                	bnez	a5,80003d18 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d44:	01048913          	addi	s2,s1,16
    80003d48:	854a                	mv	a0,s2
    80003d4a:	00001097          	auipc	ra,0x1
    80003d4e:	ab8080e7          	jalr	-1352(ra) # 80004802 <acquiresleep>
    release(&itable.lock);
    80003d52:	0001c517          	auipc	a0,0x1c
    80003d56:	66e50513          	addi	a0,a0,1646 # 800203c0 <itable>
    80003d5a:	ffffd097          	auipc	ra,0xffffd
    80003d5e:	f3e080e7          	jalr	-194(ra) # 80000c98 <release>
    itrunc(ip);
    80003d62:	8526                	mv	a0,s1
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	ee2080e7          	jalr	-286(ra) # 80003c46 <itrunc>
    ip->type = 0;
    80003d6c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d70:	8526                	mv	a0,s1
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	cfc080e7          	jalr	-772(ra) # 80003a6e <iupdate>
    ip->valid = 0;
    80003d7a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d7e:	854a                	mv	a0,s2
    80003d80:	00001097          	auipc	ra,0x1
    80003d84:	ad8080e7          	jalr	-1320(ra) # 80004858 <releasesleep>
    acquire(&itable.lock);
    80003d88:	0001c517          	auipc	a0,0x1c
    80003d8c:	63850513          	addi	a0,a0,1592 # 800203c0 <itable>
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	e54080e7          	jalr	-428(ra) # 80000be4 <acquire>
    80003d98:	b741                	j	80003d18 <iput+0x26>

0000000080003d9a <iunlockput>:
{
    80003d9a:	1101                	addi	sp,sp,-32
    80003d9c:	ec06                	sd	ra,24(sp)
    80003d9e:	e822                	sd	s0,16(sp)
    80003da0:	e426                	sd	s1,8(sp)
    80003da2:	1000                	addi	s0,sp,32
    80003da4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	e54080e7          	jalr	-428(ra) # 80003bfa <iunlock>
  iput(ip);
    80003dae:	8526                	mv	a0,s1
    80003db0:	00000097          	auipc	ra,0x0
    80003db4:	f42080e7          	jalr	-190(ra) # 80003cf2 <iput>
}
    80003db8:	60e2                	ld	ra,24(sp)
    80003dba:	6442                	ld	s0,16(sp)
    80003dbc:	64a2                	ld	s1,8(sp)
    80003dbe:	6105                	addi	sp,sp,32
    80003dc0:	8082                	ret

0000000080003dc2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003dc2:	1141                	addi	sp,sp,-16
    80003dc4:	e422                	sd	s0,8(sp)
    80003dc6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003dc8:	411c                	lw	a5,0(a0)
    80003dca:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dcc:	415c                	lw	a5,4(a0)
    80003dce:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003dd0:	04451783          	lh	a5,68(a0)
    80003dd4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003dd8:	04a51783          	lh	a5,74(a0)
    80003ddc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003de0:	04c56783          	lwu	a5,76(a0)
    80003de4:	e99c                	sd	a5,16(a1)
}
    80003de6:	6422                	ld	s0,8(sp)
    80003de8:	0141                	addi	sp,sp,16
    80003dea:	8082                	ret

0000000080003dec <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dec:	457c                	lw	a5,76(a0)
    80003dee:	0ed7e963          	bltu	a5,a3,80003ee0 <readi+0xf4>
{
    80003df2:	7159                	addi	sp,sp,-112
    80003df4:	f486                	sd	ra,104(sp)
    80003df6:	f0a2                	sd	s0,96(sp)
    80003df8:	eca6                	sd	s1,88(sp)
    80003dfa:	e8ca                	sd	s2,80(sp)
    80003dfc:	e4ce                	sd	s3,72(sp)
    80003dfe:	e0d2                	sd	s4,64(sp)
    80003e00:	fc56                	sd	s5,56(sp)
    80003e02:	f85a                	sd	s6,48(sp)
    80003e04:	f45e                	sd	s7,40(sp)
    80003e06:	f062                	sd	s8,32(sp)
    80003e08:	ec66                	sd	s9,24(sp)
    80003e0a:	e86a                	sd	s10,16(sp)
    80003e0c:	e46e                	sd	s11,8(sp)
    80003e0e:	1880                	addi	s0,sp,112
    80003e10:	8baa                	mv	s7,a0
    80003e12:	8c2e                	mv	s8,a1
    80003e14:	8ab2                	mv	s5,a2
    80003e16:	84b6                	mv	s1,a3
    80003e18:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e1a:	9f35                	addw	a4,a4,a3
    return 0;
    80003e1c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e1e:	0ad76063          	bltu	a4,a3,80003ebe <readi+0xd2>
  if(off + n > ip->size)
    80003e22:	00e7f463          	bgeu	a5,a4,80003e2a <readi+0x3e>
    n = ip->size - off;
    80003e26:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e2a:	0a0b0963          	beqz	s6,80003edc <readi+0xf0>
    80003e2e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e30:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e34:	5cfd                	li	s9,-1
    80003e36:	a82d                	j	80003e70 <readi+0x84>
    80003e38:	020a1d93          	slli	s11,s4,0x20
    80003e3c:	020ddd93          	srli	s11,s11,0x20
    80003e40:	05890613          	addi	a2,s2,88
    80003e44:	86ee                	mv	a3,s11
    80003e46:	963a                	add	a2,a2,a4
    80003e48:	85d6                	mv	a1,s5
    80003e4a:	8562                	mv	a0,s8
    80003e4c:	fffff097          	auipc	ra,0xfffff
    80003e50:	b2e080e7          	jalr	-1234(ra) # 8000297a <either_copyout>
    80003e54:	05950d63          	beq	a0,s9,80003eae <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e58:	854a                	mv	a0,s2
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	60c080e7          	jalr	1548(ra) # 80003466 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e62:	013a09bb          	addw	s3,s4,s3
    80003e66:	009a04bb          	addw	s1,s4,s1
    80003e6a:	9aee                	add	s5,s5,s11
    80003e6c:	0569f763          	bgeu	s3,s6,80003eba <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e70:	000ba903          	lw	s2,0(s7)
    80003e74:	00a4d59b          	srliw	a1,s1,0xa
    80003e78:	855e                	mv	a0,s7
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	8b0080e7          	jalr	-1872(ra) # 8000372a <bmap>
    80003e82:	0005059b          	sext.w	a1,a0
    80003e86:	854a                	mv	a0,s2
    80003e88:	fffff097          	auipc	ra,0xfffff
    80003e8c:	4ae080e7          	jalr	1198(ra) # 80003336 <bread>
    80003e90:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e92:	3ff4f713          	andi	a4,s1,1023
    80003e96:	40ed07bb          	subw	a5,s10,a4
    80003e9a:	413b06bb          	subw	a3,s6,s3
    80003e9e:	8a3e                	mv	s4,a5
    80003ea0:	2781                	sext.w	a5,a5
    80003ea2:	0006861b          	sext.w	a2,a3
    80003ea6:	f8f679e3          	bgeu	a2,a5,80003e38 <readi+0x4c>
    80003eaa:	8a36                	mv	s4,a3
    80003eac:	b771                	j	80003e38 <readi+0x4c>
      brelse(bp);
    80003eae:	854a                	mv	a0,s2
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	5b6080e7          	jalr	1462(ra) # 80003466 <brelse>
      tot = -1;
    80003eb8:	59fd                	li	s3,-1
  }
  return tot;
    80003eba:	0009851b          	sext.w	a0,s3
}
    80003ebe:	70a6                	ld	ra,104(sp)
    80003ec0:	7406                	ld	s0,96(sp)
    80003ec2:	64e6                	ld	s1,88(sp)
    80003ec4:	6946                	ld	s2,80(sp)
    80003ec6:	69a6                	ld	s3,72(sp)
    80003ec8:	6a06                	ld	s4,64(sp)
    80003eca:	7ae2                	ld	s5,56(sp)
    80003ecc:	7b42                	ld	s6,48(sp)
    80003ece:	7ba2                	ld	s7,40(sp)
    80003ed0:	7c02                	ld	s8,32(sp)
    80003ed2:	6ce2                	ld	s9,24(sp)
    80003ed4:	6d42                	ld	s10,16(sp)
    80003ed6:	6da2                	ld	s11,8(sp)
    80003ed8:	6165                	addi	sp,sp,112
    80003eda:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003edc:	89da                	mv	s3,s6
    80003ede:	bff1                	j	80003eba <readi+0xce>
    return 0;
    80003ee0:	4501                	li	a0,0
}
    80003ee2:	8082                	ret

0000000080003ee4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ee4:	457c                	lw	a5,76(a0)
    80003ee6:	10d7e863          	bltu	a5,a3,80003ff6 <writei+0x112>
{
    80003eea:	7159                	addi	sp,sp,-112
    80003eec:	f486                	sd	ra,104(sp)
    80003eee:	f0a2                	sd	s0,96(sp)
    80003ef0:	eca6                	sd	s1,88(sp)
    80003ef2:	e8ca                	sd	s2,80(sp)
    80003ef4:	e4ce                	sd	s3,72(sp)
    80003ef6:	e0d2                	sd	s4,64(sp)
    80003ef8:	fc56                	sd	s5,56(sp)
    80003efa:	f85a                	sd	s6,48(sp)
    80003efc:	f45e                	sd	s7,40(sp)
    80003efe:	f062                	sd	s8,32(sp)
    80003f00:	ec66                	sd	s9,24(sp)
    80003f02:	e86a                	sd	s10,16(sp)
    80003f04:	e46e                	sd	s11,8(sp)
    80003f06:	1880                	addi	s0,sp,112
    80003f08:	8b2a                	mv	s6,a0
    80003f0a:	8c2e                	mv	s8,a1
    80003f0c:	8ab2                	mv	s5,a2
    80003f0e:	8936                	mv	s2,a3
    80003f10:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003f12:	00e687bb          	addw	a5,a3,a4
    80003f16:	0ed7e263          	bltu	a5,a3,80003ffa <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f1a:	00043737          	lui	a4,0x43
    80003f1e:	0ef76063          	bltu	a4,a5,80003ffe <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f22:	0c0b8863          	beqz	s7,80003ff2 <writei+0x10e>
    80003f26:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f28:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f2c:	5cfd                	li	s9,-1
    80003f2e:	a091                	j	80003f72 <writei+0x8e>
    80003f30:	02099d93          	slli	s11,s3,0x20
    80003f34:	020ddd93          	srli	s11,s11,0x20
    80003f38:	05848513          	addi	a0,s1,88
    80003f3c:	86ee                	mv	a3,s11
    80003f3e:	8656                	mv	a2,s5
    80003f40:	85e2                	mv	a1,s8
    80003f42:	953a                	add	a0,a0,a4
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	a8c080e7          	jalr	-1396(ra) # 800029d0 <either_copyin>
    80003f4c:	07950263          	beq	a0,s9,80003fb0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f50:	8526                	mv	a0,s1
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	790080e7          	jalr	1936(ra) # 800046e2 <log_write>
    brelse(bp);
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	50a080e7          	jalr	1290(ra) # 80003466 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f64:	01498a3b          	addw	s4,s3,s4
    80003f68:	0129893b          	addw	s2,s3,s2
    80003f6c:	9aee                	add	s5,s5,s11
    80003f6e:	057a7663          	bgeu	s4,s7,80003fba <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f72:	000b2483          	lw	s1,0(s6)
    80003f76:	00a9559b          	srliw	a1,s2,0xa
    80003f7a:	855a                	mv	a0,s6
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	7ae080e7          	jalr	1966(ra) # 8000372a <bmap>
    80003f84:	0005059b          	sext.w	a1,a0
    80003f88:	8526                	mv	a0,s1
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	3ac080e7          	jalr	940(ra) # 80003336 <bread>
    80003f92:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f94:	3ff97713          	andi	a4,s2,1023
    80003f98:	40ed07bb          	subw	a5,s10,a4
    80003f9c:	414b86bb          	subw	a3,s7,s4
    80003fa0:	89be                	mv	s3,a5
    80003fa2:	2781                	sext.w	a5,a5
    80003fa4:	0006861b          	sext.w	a2,a3
    80003fa8:	f8f674e3          	bgeu	a2,a5,80003f30 <writei+0x4c>
    80003fac:	89b6                	mv	s3,a3
    80003fae:	b749                	j	80003f30 <writei+0x4c>
      brelse(bp);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	4b4080e7          	jalr	1204(ra) # 80003466 <brelse>
  }

  if(off > ip->size)
    80003fba:	04cb2783          	lw	a5,76(s6)
    80003fbe:	0127f463          	bgeu	a5,s2,80003fc6 <writei+0xe2>
    ip->size = off;
    80003fc2:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fc6:	855a                	mv	a0,s6
    80003fc8:	00000097          	auipc	ra,0x0
    80003fcc:	aa6080e7          	jalr	-1370(ra) # 80003a6e <iupdate>

  return tot;
    80003fd0:	000a051b          	sext.w	a0,s4
}
    80003fd4:	70a6                	ld	ra,104(sp)
    80003fd6:	7406                	ld	s0,96(sp)
    80003fd8:	64e6                	ld	s1,88(sp)
    80003fda:	6946                	ld	s2,80(sp)
    80003fdc:	69a6                	ld	s3,72(sp)
    80003fde:	6a06                	ld	s4,64(sp)
    80003fe0:	7ae2                	ld	s5,56(sp)
    80003fe2:	7b42                	ld	s6,48(sp)
    80003fe4:	7ba2                	ld	s7,40(sp)
    80003fe6:	7c02                	ld	s8,32(sp)
    80003fe8:	6ce2                	ld	s9,24(sp)
    80003fea:	6d42                	ld	s10,16(sp)
    80003fec:	6da2                	ld	s11,8(sp)
    80003fee:	6165                	addi	sp,sp,112
    80003ff0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ff2:	8a5e                	mv	s4,s7
    80003ff4:	bfc9                	j	80003fc6 <writei+0xe2>
    return -1;
    80003ff6:	557d                	li	a0,-1
}
    80003ff8:	8082                	ret
    return -1;
    80003ffa:	557d                	li	a0,-1
    80003ffc:	bfe1                	j	80003fd4 <writei+0xf0>
    return -1;
    80003ffe:	557d                	li	a0,-1
    80004000:	bfd1                	j	80003fd4 <writei+0xf0>

0000000080004002 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004002:	1141                	addi	sp,sp,-16
    80004004:	e406                	sd	ra,8(sp)
    80004006:	e022                	sd	s0,0(sp)
    80004008:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000400a:	4639                	li	a2,14
    8000400c:	ffffd097          	auipc	ra,0xffffd
    80004010:	dac080e7          	jalr	-596(ra) # 80000db8 <strncmp>
}
    80004014:	60a2                	ld	ra,8(sp)
    80004016:	6402                	ld	s0,0(sp)
    80004018:	0141                	addi	sp,sp,16
    8000401a:	8082                	ret

000000008000401c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000401c:	7139                	addi	sp,sp,-64
    8000401e:	fc06                	sd	ra,56(sp)
    80004020:	f822                	sd	s0,48(sp)
    80004022:	f426                	sd	s1,40(sp)
    80004024:	f04a                	sd	s2,32(sp)
    80004026:	ec4e                	sd	s3,24(sp)
    80004028:	e852                	sd	s4,16(sp)
    8000402a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000402c:	04451703          	lh	a4,68(a0)
    80004030:	4785                	li	a5,1
    80004032:	00f71a63          	bne	a4,a5,80004046 <dirlookup+0x2a>
    80004036:	892a                	mv	s2,a0
    80004038:	89ae                	mv	s3,a1
    8000403a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000403c:	457c                	lw	a5,76(a0)
    8000403e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004040:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004042:	e79d                	bnez	a5,80004070 <dirlookup+0x54>
    80004044:	a8a5                	j	800040bc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004046:	00004517          	auipc	a0,0x4
    8000404a:	63a50513          	addi	a0,a0,1594 # 80008680 <syscalls+0x1a0>
    8000404e:	ffffc097          	auipc	ra,0xffffc
    80004052:	4f0080e7          	jalr	1264(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004056:	00004517          	auipc	a0,0x4
    8000405a:	64250513          	addi	a0,a0,1602 # 80008698 <syscalls+0x1b8>
    8000405e:	ffffc097          	auipc	ra,0xffffc
    80004062:	4e0080e7          	jalr	1248(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004066:	24c1                	addiw	s1,s1,16
    80004068:	04c92783          	lw	a5,76(s2)
    8000406c:	04f4f763          	bgeu	s1,a5,800040ba <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004070:	4741                	li	a4,16
    80004072:	86a6                	mv	a3,s1
    80004074:	fc040613          	addi	a2,s0,-64
    80004078:	4581                	li	a1,0
    8000407a:	854a                	mv	a0,s2
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	d70080e7          	jalr	-656(ra) # 80003dec <readi>
    80004084:	47c1                	li	a5,16
    80004086:	fcf518e3          	bne	a0,a5,80004056 <dirlookup+0x3a>
    if(de.inum == 0)
    8000408a:	fc045783          	lhu	a5,-64(s0)
    8000408e:	dfe1                	beqz	a5,80004066 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004090:	fc240593          	addi	a1,s0,-62
    80004094:	854e                	mv	a0,s3
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	f6c080e7          	jalr	-148(ra) # 80004002 <namecmp>
    8000409e:	f561                	bnez	a0,80004066 <dirlookup+0x4a>
      if(poff)
    800040a0:	000a0463          	beqz	s4,800040a8 <dirlookup+0x8c>
        *poff = off;
    800040a4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040a8:	fc045583          	lhu	a1,-64(s0)
    800040ac:	00092503          	lw	a0,0(s2)
    800040b0:	fffff097          	auipc	ra,0xfffff
    800040b4:	754080e7          	jalr	1876(ra) # 80003804 <iget>
    800040b8:	a011                	j	800040bc <dirlookup+0xa0>
  return 0;
    800040ba:	4501                	li	a0,0
}
    800040bc:	70e2                	ld	ra,56(sp)
    800040be:	7442                	ld	s0,48(sp)
    800040c0:	74a2                	ld	s1,40(sp)
    800040c2:	7902                	ld	s2,32(sp)
    800040c4:	69e2                	ld	s3,24(sp)
    800040c6:	6a42                	ld	s4,16(sp)
    800040c8:	6121                	addi	sp,sp,64
    800040ca:	8082                	ret

00000000800040cc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040cc:	711d                	addi	sp,sp,-96
    800040ce:	ec86                	sd	ra,88(sp)
    800040d0:	e8a2                	sd	s0,80(sp)
    800040d2:	e4a6                	sd	s1,72(sp)
    800040d4:	e0ca                	sd	s2,64(sp)
    800040d6:	fc4e                	sd	s3,56(sp)
    800040d8:	f852                	sd	s4,48(sp)
    800040da:	f456                	sd	s5,40(sp)
    800040dc:	f05a                	sd	s6,32(sp)
    800040de:	ec5e                	sd	s7,24(sp)
    800040e0:	e862                	sd	s8,16(sp)
    800040e2:	e466                	sd	s9,8(sp)
    800040e4:	1080                	addi	s0,sp,96
    800040e6:	84aa                	mv	s1,a0
    800040e8:	8b2e                	mv	s6,a1
    800040ea:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040ec:	00054703          	lbu	a4,0(a0)
    800040f0:	02f00793          	li	a5,47
    800040f4:	02f70363          	beq	a4,a5,8000411a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040f8:	ffffe097          	auipc	ra,0xffffe
    800040fc:	cb8080e7          	jalr	-840(ra) # 80001db0 <myproc>
    80004100:	17853503          	ld	a0,376(a0)
    80004104:	00000097          	auipc	ra,0x0
    80004108:	9f6080e7          	jalr	-1546(ra) # 80003afa <idup>
    8000410c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000410e:	02f00913          	li	s2,47
  len = path - s;
    80004112:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004114:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004116:	4c05                	li	s8,1
    80004118:	a865                	j	800041d0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000411a:	4585                	li	a1,1
    8000411c:	4505                	li	a0,1
    8000411e:	fffff097          	auipc	ra,0xfffff
    80004122:	6e6080e7          	jalr	1766(ra) # 80003804 <iget>
    80004126:	89aa                	mv	s3,a0
    80004128:	b7dd                	j	8000410e <namex+0x42>
      iunlockput(ip);
    8000412a:	854e                	mv	a0,s3
    8000412c:	00000097          	auipc	ra,0x0
    80004130:	c6e080e7          	jalr	-914(ra) # 80003d9a <iunlockput>
      return 0;
    80004134:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004136:	854e                	mv	a0,s3
    80004138:	60e6                	ld	ra,88(sp)
    8000413a:	6446                	ld	s0,80(sp)
    8000413c:	64a6                	ld	s1,72(sp)
    8000413e:	6906                	ld	s2,64(sp)
    80004140:	79e2                	ld	s3,56(sp)
    80004142:	7a42                	ld	s4,48(sp)
    80004144:	7aa2                	ld	s5,40(sp)
    80004146:	7b02                	ld	s6,32(sp)
    80004148:	6be2                	ld	s7,24(sp)
    8000414a:	6c42                	ld	s8,16(sp)
    8000414c:	6ca2                	ld	s9,8(sp)
    8000414e:	6125                	addi	sp,sp,96
    80004150:	8082                	ret
      iunlock(ip);
    80004152:	854e                	mv	a0,s3
    80004154:	00000097          	auipc	ra,0x0
    80004158:	aa6080e7          	jalr	-1370(ra) # 80003bfa <iunlock>
      return ip;
    8000415c:	bfe9                	j	80004136 <namex+0x6a>
      iunlockput(ip);
    8000415e:	854e                	mv	a0,s3
    80004160:	00000097          	auipc	ra,0x0
    80004164:	c3a080e7          	jalr	-966(ra) # 80003d9a <iunlockput>
      return 0;
    80004168:	89d2                	mv	s3,s4
    8000416a:	b7f1                	j	80004136 <namex+0x6a>
  len = path - s;
    8000416c:	40b48633          	sub	a2,s1,a1
    80004170:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004174:	094cd463          	bge	s9,s4,800041fc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004178:	4639                	li	a2,14
    8000417a:	8556                	mv	a0,s5
    8000417c:	ffffd097          	auipc	ra,0xffffd
    80004180:	bc4080e7          	jalr	-1084(ra) # 80000d40 <memmove>
  while(*path == '/')
    80004184:	0004c783          	lbu	a5,0(s1)
    80004188:	01279763          	bne	a5,s2,80004196 <namex+0xca>
    path++;
    8000418c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000418e:	0004c783          	lbu	a5,0(s1)
    80004192:	ff278de3          	beq	a5,s2,8000418c <namex+0xc0>
    ilock(ip);
    80004196:	854e                	mv	a0,s3
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	9a0080e7          	jalr	-1632(ra) # 80003b38 <ilock>
    if(ip->type != T_DIR){
    800041a0:	04499783          	lh	a5,68(s3)
    800041a4:	f98793e3          	bne	a5,s8,8000412a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800041a8:	000b0563          	beqz	s6,800041b2 <namex+0xe6>
    800041ac:	0004c783          	lbu	a5,0(s1)
    800041b0:	d3cd                	beqz	a5,80004152 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041b2:	865e                	mv	a2,s7
    800041b4:	85d6                	mv	a1,s5
    800041b6:	854e                	mv	a0,s3
    800041b8:	00000097          	auipc	ra,0x0
    800041bc:	e64080e7          	jalr	-412(ra) # 8000401c <dirlookup>
    800041c0:	8a2a                	mv	s4,a0
    800041c2:	dd51                	beqz	a0,8000415e <namex+0x92>
    iunlockput(ip);
    800041c4:	854e                	mv	a0,s3
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	bd4080e7          	jalr	-1068(ra) # 80003d9a <iunlockput>
    ip = next;
    800041ce:	89d2                	mv	s3,s4
  while(*path == '/')
    800041d0:	0004c783          	lbu	a5,0(s1)
    800041d4:	05279763          	bne	a5,s2,80004222 <namex+0x156>
    path++;
    800041d8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041da:	0004c783          	lbu	a5,0(s1)
    800041de:	ff278de3          	beq	a5,s2,800041d8 <namex+0x10c>
  if(*path == 0)
    800041e2:	c79d                	beqz	a5,80004210 <namex+0x144>
    path++;
    800041e4:	85a6                	mv	a1,s1
  len = path - s;
    800041e6:	8a5e                	mv	s4,s7
    800041e8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800041ea:	01278963          	beq	a5,s2,800041fc <namex+0x130>
    800041ee:	dfbd                	beqz	a5,8000416c <namex+0xa0>
    path++;
    800041f0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800041f2:	0004c783          	lbu	a5,0(s1)
    800041f6:	ff279ce3          	bne	a5,s2,800041ee <namex+0x122>
    800041fa:	bf8d                	j	8000416c <namex+0xa0>
    memmove(name, s, len);
    800041fc:	2601                	sext.w	a2,a2
    800041fe:	8556                	mv	a0,s5
    80004200:	ffffd097          	auipc	ra,0xffffd
    80004204:	b40080e7          	jalr	-1216(ra) # 80000d40 <memmove>
    name[len] = 0;
    80004208:	9a56                	add	s4,s4,s5
    8000420a:	000a0023          	sb	zero,0(s4)
    8000420e:	bf9d                	j	80004184 <namex+0xb8>
  if(nameiparent){
    80004210:	f20b03e3          	beqz	s6,80004136 <namex+0x6a>
    iput(ip);
    80004214:	854e                	mv	a0,s3
    80004216:	00000097          	auipc	ra,0x0
    8000421a:	adc080e7          	jalr	-1316(ra) # 80003cf2 <iput>
    return 0;
    8000421e:	4981                	li	s3,0
    80004220:	bf19                	j	80004136 <namex+0x6a>
  if(*path == 0)
    80004222:	d7fd                	beqz	a5,80004210 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004224:	0004c783          	lbu	a5,0(s1)
    80004228:	85a6                	mv	a1,s1
    8000422a:	b7d1                	j	800041ee <namex+0x122>

000000008000422c <dirlink>:
{
    8000422c:	7139                	addi	sp,sp,-64
    8000422e:	fc06                	sd	ra,56(sp)
    80004230:	f822                	sd	s0,48(sp)
    80004232:	f426                	sd	s1,40(sp)
    80004234:	f04a                	sd	s2,32(sp)
    80004236:	ec4e                	sd	s3,24(sp)
    80004238:	e852                	sd	s4,16(sp)
    8000423a:	0080                	addi	s0,sp,64
    8000423c:	892a                	mv	s2,a0
    8000423e:	8a2e                	mv	s4,a1
    80004240:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004242:	4601                	li	a2,0
    80004244:	00000097          	auipc	ra,0x0
    80004248:	dd8080e7          	jalr	-552(ra) # 8000401c <dirlookup>
    8000424c:	e93d                	bnez	a0,800042c2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000424e:	04c92483          	lw	s1,76(s2)
    80004252:	c49d                	beqz	s1,80004280 <dirlink+0x54>
    80004254:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004256:	4741                	li	a4,16
    80004258:	86a6                	mv	a3,s1
    8000425a:	fc040613          	addi	a2,s0,-64
    8000425e:	4581                	li	a1,0
    80004260:	854a                	mv	a0,s2
    80004262:	00000097          	auipc	ra,0x0
    80004266:	b8a080e7          	jalr	-1142(ra) # 80003dec <readi>
    8000426a:	47c1                	li	a5,16
    8000426c:	06f51163          	bne	a0,a5,800042ce <dirlink+0xa2>
    if(de.inum == 0)
    80004270:	fc045783          	lhu	a5,-64(s0)
    80004274:	c791                	beqz	a5,80004280 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004276:	24c1                	addiw	s1,s1,16
    80004278:	04c92783          	lw	a5,76(s2)
    8000427c:	fcf4ede3          	bltu	s1,a5,80004256 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004280:	4639                	li	a2,14
    80004282:	85d2                	mv	a1,s4
    80004284:	fc240513          	addi	a0,s0,-62
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	b6c080e7          	jalr	-1172(ra) # 80000df4 <strncpy>
  de.inum = inum;
    80004290:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004294:	4741                	li	a4,16
    80004296:	86a6                	mv	a3,s1
    80004298:	fc040613          	addi	a2,s0,-64
    8000429c:	4581                	li	a1,0
    8000429e:	854a                	mv	a0,s2
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	c44080e7          	jalr	-956(ra) # 80003ee4 <writei>
    800042a8:	872a                	mv	a4,a0
    800042aa:	47c1                	li	a5,16
  return 0;
    800042ac:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ae:	02f71863          	bne	a4,a5,800042de <dirlink+0xb2>
}
    800042b2:	70e2                	ld	ra,56(sp)
    800042b4:	7442                	ld	s0,48(sp)
    800042b6:	74a2                	ld	s1,40(sp)
    800042b8:	7902                	ld	s2,32(sp)
    800042ba:	69e2                	ld	s3,24(sp)
    800042bc:	6a42                	ld	s4,16(sp)
    800042be:	6121                	addi	sp,sp,64
    800042c0:	8082                	ret
    iput(ip);
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	a30080e7          	jalr	-1488(ra) # 80003cf2 <iput>
    return -1;
    800042ca:	557d                	li	a0,-1
    800042cc:	b7dd                	j	800042b2 <dirlink+0x86>
      panic("dirlink read");
    800042ce:	00004517          	auipc	a0,0x4
    800042d2:	3da50513          	addi	a0,a0,986 # 800086a8 <syscalls+0x1c8>
    800042d6:	ffffc097          	auipc	ra,0xffffc
    800042da:	268080e7          	jalr	616(ra) # 8000053e <panic>
    panic("dirlink");
    800042de:	00004517          	auipc	a0,0x4
    800042e2:	4da50513          	addi	a0,a0,1242 # 800087b8 <syscalls+0x2d8>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	258080e7          	jalr	600(ra) # 8000053e <panic>

00000000800042ee <namei>:

struct inode*
namei(char *path)
{
    800042ee:	1101                	addi	sp,sp,-32
    800042f0:	ec06                	sd	ra,24(sp)
    800042f2:	e822                	sd	s0,16(sp)
    800042f4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042f6:	fe040613          	addi	a2,s0,-32
    800042fa:	4581                	li	a1,0
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	dd0080e7          	jalr	-560(ra) # 800040cc <namex>
}
    80004304:	60e2                	ld	ra,24(sp)
    80004306:	6442                	ld	s0,16(sp)
    80004308:	6105                	addi	sp,sp,32
    8000430a:	8082                	ret

000000008000430c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000430c:	1141                	addi	sp,sp,-16
    8000430e:	e406                	sd	ra,8(sp)
    80004310:	e022                	sd	s0,0(sp)
    80004312:	0800                	addi	s0,sp,16
    80004314:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004316:	4585                	li	a1,1
    80004318:	00000097          	auipc	ra,0x0
    8000431c:	db4080e7          	jalr	-588(ra) # 800040cc <namex>
}
    80004320:	60a2                	ld	ra,8(sp)
    80004322:	6402                	ld	s0,0(sp)
    80004324:	0141                	addi	sp,sp,16
    80004326:	8082                	ret

0000000080004328 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004328:	1101                	addi	sp,sp,-32
    8000432a:	ec06                	sd	ra,24(sp)
    8000432c:	e822                	sd	s0,16(sp)
    8000432e:	e426                	sd	s1,8(sp)
    80004330:	e04a                	sd	s2,0(sp)
    80004332:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004334:	0001e917          	auipc	s2,0x1e
    80004338:	b3490913          	addi	s2,s2,-1228 # 80021e68 <log>
    8000433c:	01892583          	lw	a1,24(s2)
    80004340:	02892503          	lw	a0,40(s2)
    80004344:	fffff097          	auipc	ra,0xfffff
    80004348:	ff2080e7          	jalr	-14(ra) # 80003336 <bread>
    8000434c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000434e:	02c92683          	lw	a3,44(s2)
    80004352:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004354:	02d05763          	blez	a3,80004382 <write_head+0x5a>
    80004358:	0001e797          	auipc	a5,0x1e
    8000435c:	b4078793          	addi	a5,a5,-1216 # 80021e98 <log+0x30>
    80004360:	05c50713          	addi	a4,a0,92
    80004364:	36fd                	addiw	a3,a3,-1
    80004366:	1682                	slli	a3,a3,0x20
    80004368:	9281                	srli	a3,a3,0x20
    8000436a:	068a                	slli	a3,a3,0x2
    8000436c:	0001e617          	auipc	a2,0x1e
    80004370:	b3060613          	addi	a2,a2,-1232 # 80021e9c <log+0x34>
    80004374:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004376:	4390                	lw	a2,0(a5)
    80004378:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000437a:	0791                	addi	a5,a5,4
    8000437c:	0711                	addi	a4,a4,4
    8000437e:	fed79ce3          	bne	a5,a3,80004376 <write_head+0x4e>
  }
  bwrite(buf);
    80004382:	8526                	mv	a0,s1
    80004384:	fffff097          	auipc	ra,0xfffff
    80004388:	0a4080e7          	jalr	164(ra) # 80003428 <bwrite>
  brelse(buf);
    8000438c:	8526                	mv	a0,s1
    8000438e:	fffff097          	auipc	ra,0xfffff
    80004392:	0d8080e7          	jalr	216(ra) # 80003466 <brelse>
}
    80004396:	60e2                	ld	ra,24(sp)
    80004398:	6442                	ld	s0,16(sp)
    8000439a:	64a2                	ld	s1,8(sp)
    8000439c:	6902                	ld	s2,0(sp)
    8000439e:	6105                	addi	sp,sp,32
    800043a0:	8082                	ret

00000000800043a2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043a2:	0001e797          	auipc	a5,0x1e
    800043a6:	af27a783          	lw	a5,-1294(a5) # 80021e94 <log+0x2c>
    800043aa:	0af05d63          	blez	a5,80004464 <install_trans+0xc2>
{
    800043ae:	7139                	addi	sp,sp,-64
    800043b0:	fc06                	sd	ra,56(sp)
    800043b2:	f822                	sd	s0,48(sp)
    800043b4:	f426                	sd	s1,40(sp)
    800043b6:	f04a                	sd	s2,32(sp)
    800043b8:	ec4e                	sd	s3,24(sp)
    800043ba:	e852                	sd	s4,16(sp)
    800043bc:	e456                	sd	s5,8(sp)
    800043be:	e05a                	sd	s6,0(sp)
    800043c0:	0080                	addi	s0,sp,64
    800043c2:	8b2a                	mv	s6,a0
    800043c4:	0001ea97          	auipc	s5,0x1e
    800043c8:	ad4a8a93          	addi	s5,s5,-1324 # 80021e98 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043cc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043ce:	0001e997          	auipc	s3,0x1e
    800043d2:	a9a98993          	addi	s3,s3,-1382 # 80021e68 <log>
    800043d6:	a035                	j	80004402 <install_trans+0x60>
      bunpin(dbuf);
    800043d8:	8526                	mv	a0,s1
    800043da:	fffff097          	auipc	ra,0xfffff
    800043de:	166080e7          	jalr	358(ra) # 80003540 <bunpin>
    brelse(lbuf);
    800043e2:	854a                	mv	a0,s2
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	082080e7          	jalr	130(ra) # 80003466 <brelse>
    brelse(dbuf);
    800043ec:	8526                	mv	a0,s1
    800043ee:	fffff097          	auipc	ra,0xfffff
    800043f2:	078080e7          	jalr	120(ra) # 80003466 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f6:	2a05                	addiw	s4,s4,1
    800043f8:	0a91                	addi	s5,s5,4
    800043fa:	02c9a783          	lw	a5,44(s3)
    800043fe:	04fa5963          	bge	s4,a5,80004450 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004402:	0189a583          	lw	a1,24(s3)
    80004406:	014585bb          	addw	a1,a1,s4
    8000440a:	2585                	addiw	a1,a1,1
    8000440c:	0289a503          	lw	a0,40(s3)
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	f26080e7          	jalr	-218(ra) # 80003336 <bread>
    80004418:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000441a:	000aa583          	lw	a1,0(s5)
    8000441e:	0289a503          	lw	a0,40(s3)
    80004422:	fffff097          	auipc	ra,0xfffff
    80004426:	f14080e7          	jalr	-236(ra) # 80003336 <bread>
    8000442a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000442c:	40000613          	li	a2,1024
    80004430:	05890593          	addi	a1,s2,88
    80004434:	05850513          	addi	a0,a0,88
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	908080e7          	jalr	-1784(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004440:	8526                	mv	a0,s1
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	fe6080e7          	jalr	-26(ra) # 80003428 <bwrite>
    if(recovering == 0)
    8000444a:	f80b1ce3          	bnez	s6,800043e2 <install_trans+0x40>
    8000444e:	b769                	j	800043d8 <install_trans+0x36>
}
    80004450:	70e2                	ld	ra,56(sp)
    80004452:	7442                	ld	s0,48(sp)
    80004454:	74a2                	ld	s1,40(sp)
    80004456:	7902                	ld	s2,32(sp)
    80004458:	69e2                	ld	s3,24(sp)
    8000445a:	6a42                	ld	s4,16(sp)
    8000445c:	6aa2                	ld	s5,8(sp)
    8000445e:	6b02                	ld	s6,0(sp)
    80004460:	6121                	addi	sp,sp,64
    80004462:	8082                	ret
    80004464:	8082                	ret

0000000080004466 <initlog>:
{
    80004466:	7179                	addi	sp,sp,-48
    80004468:	f406                	sd	ra,40(sp)
    8000446a:	f022                	sd	s0,32(sp)
    8000446c:	ec26                	sd	s1,24(sp)
    8000446e:	e84a                	sd	s2,16(sp)
    80004470:	e44e                	sd	s3,8(sp)
    80004472:	1800                	addi	s0,sp,48
    80004474:	892a                	mv	s2,a0
    80004476:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004478:	0001e497          	auipc	s1,0x1e
    8000447c:	9f048493          	addi	s1,s1,-1552 # 80021e68 <log>
    80004480:	00004597          	auipc	a1,0x4
    80004484:	23858593          	addi	a1,a1,568 # 800086b8 <syscalls+0x1d8>
    80004488:	8526                	mv	a0,s1
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	6ca080e7          	jalr	1738(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    80004492:	0149a583          	lw	a1,20(s3)
    80004496:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004498:	0109a783          	lw	a5,16(s3)
    8000449c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000449e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044a2:	854a                	mv	a0,s2
    800044a4:	fffff097          	auipc	ra,0xfffff
    800044a8:	e92080e7          	jalr	-366(ra) # 80003336 <bread>
  log.lh.n = lh->n;
    800044ac:	4d3c                	lw	a5,88(a0)
    800044ae:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044b0:	02f05563          	blez	a5,800044da <initlog+0x74>
    800044b4:	05c50713          	addi	a4,a0,92
    800044b8:	0001e697          	auipc	a3,0x1e
    800044bc:	9e068693          	addi	a3,a3,-1568 # 80021e98 <log+0x30>
    800044c0:	37fd                	addiw	a5,a5,-1
    800044c2:	1782                	slli	a5,a5,0x20
    800044c4:	9381                	srli	a5,a5,0x20
    800044c6:	078a                	slli	a5,a5,0x2
    800044c8:	06050613          	addi	a2,a0,96
    800044cc:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800044ce:	4310                	lw	a2,0(a4)
    800044d0:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800044d2:	0711                	addi	a4,a4,4
    800044d4:	0691                	addi	a3,a3,4
    800044d6:	fef71ce3          	bne	a4,a5,800044ce <initlog+0x68>
  brelse(buf);
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	f8c080e7          	jalr	-116(ra) # 80003466 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044e2:	4505                	li	a0,1
    800044e4:	00000097          	auipc	ra,0x0
    800044e8:	ebe080e7          	jalr	-322(ra) # 800043a2 <install_trans>
  log.lh.n = 0;
    800044ec:	0001e797          	auipc	a5,0x1e
    800044f0:	9a07a423          	sw	zero,-1624(a5) # 80021e94 <log+0x2c>
  write_head(); // clear the log
    800044f4:	00000097          	auipc	ra,0x0
    800044f8:	e34080e7          	jalr	-460(ra) # 80004328 <write_head>
}
    800044fc:	70a2                	ld	ra,40(sp)
    800044fe:	7402                	ld	s0,32(sp)
    80004500:	64e2                	ld	s1,24(sp)
    80004502:	6942                	ld	s2,16(sp)
    80004504:	69a2                	ld	s3,8(sp)
    80004506:	6145                	addi	sp,sp,48
    80004508:	8082                	ret

000000008000450a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000450a:	1101                	addi	sp,sp,-32
    8000450c:	ec06                	sd	ra,24(sp)
    8000450e:	e822                	sd	s0,16(sp)
    80004510:	e426                	sd	s1,8(sp)
    80004512:	e04a                	sd	s2,0(sp)
    80004514:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004516:	0001e517          	auipc	a0,0x1e
    8000451a:	95250513          	addi	a0,a0,-1710 # 80021e68 <log>
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	6c6080e7          	jalr	1734(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    80004526:	0001e497          	auipc	s1,0x1e
    8000452a:	94248493          	addi	s1,s1,-1726 # 80021e68 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000452e:	4979                	li	s2,30
    80004530:	a039                	j	8000453e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004532:	85a6                	mv	a1,s1
    80004534:	8526                	mv	a0,s1
    80004536:	ffffe097          	auipc	ra,0xffffe
    8000453a:	fd8080e7          	jalr	-40(ra) # 8000250e <sleep>
    if(log.committing){
    8000453e:	50dc                	lw	a5,36(s1)
    80004540:	fbed                	bnez	a5,80004532 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004542:	509c                	lw	a5,32(s1)
    80004544:	0017871b          	addiw	a4,a5,1
    80004548:	0007069b          	sext.w	a3,a4
    8000454c:	0027179b          	slliw	a5,a4,0x2
    80004550:	9fb9                	addw	a5,a5,a4
    80004552:	0017979b          	slliw	a5,a5,0x1
    80004556:	54d8                	lw	a4,44(s1)
    80004558:	9fb9                	addw	a5,a5,a4
    8000455a:	00f95963          	bge	s2,a5,8000456c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000455e:	85a6                	mv	a1,s1
    80004560:	8526                	mv	a0,s1
    80004562:	ffffe097          	auipc	ra,0xffffe
    80004566:	fac080e7          	jalr	-84(ra) # 8000250e <sleep>
    8000456a:	bfd1                	j	8000453e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000456c:	0001e517          	auipc	a0,0x1e
    80004570:	8fc50513          	addi	a0,a0,-1796 # 80021e68 <log>
    80004574:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	722080e7          	jalr	1826(ra) # 80000c98 <release>
      break;
    }
  }
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6902                	ld	s2,0(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret

000000008000458a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000458a:	7139                	addi	sp,sp,-64
    8000458c:	fc06                	sd	ra,56(sp)
    8000458e:	f822                	sd	s0,48(sp)
    80004590:	f426                	sd	s1,40(sp)
    80004592:	f04a                	sd	s2,32(sp)
    80004594:	ec4e                	sd	s3,24(sp)
    80004596:	e852                	sd	s4,16(sp)
    80004598:	e456                	sd	s5,8(sp)
    8000459a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000459c:	0001e497          	auipc	s1,0x1e
    800045a0:	8cc48493          	addi	s1,s1,-1844 # 80021e68 <log>
    800045a4:	8526                	mv	a0,s1
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	63e080e7          	jalr	1598(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    800045ae:	509c                	lw	a5,32(s1)
    800045b0:	37fd                	addiw	a5,a5,-1
    800045b2:	0007891b          	sext.w	s2,a5
    800045b6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045b8:	50dc                	lw	a5,36(s1)
    800045ba:	efb9                	bnez	a5,80004618 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045bc:	06091663          	bnez	s2,80004628 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800045c0:	0001e497          	auipc	s1,0x1e
    800045c4:	8a848493          	addi	s1,s1,-1880 # 80021e68 <log>
    800045c8:	4785                	li	a5,1
    800045ca:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045cc:	8526                	mv	a0,s1
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	6ca080e7          	jalr	1738(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045d6:	54dc                	lw	a5,44(s1)
    800045d8:	06f04763          	bgtz	a5,80004646 <end_op+0xbc>
    acquire(&log.lock);
    800045dc:	0001e497          	auipc	s1,0x1e
    800045e0:	88c48493          	addi	s1,s1,-1908 # 80021e68 <log>
    800045e4:	8526                	mv	a0,s1
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	5fe080e7          	jalr	1534(ra) # 80000be4 <acquire>
    log.committing = 0;
    800045ee:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045f2:	8526                	mv	a0,s1
    800045f4:	ffffe097          	auipc	ra,0xffffe
    800045f8:	11a080e7          	jalr	282(ra) # 8000270e <wakeup>
    release(&log.lock);
    800045fc:	8526                	mv	a0,s1
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	69a080e7          	jalr	1690(ra) # 80000c98 <release>
}
    80004606:	70e2                	ld	ra,56(sp)
    80004608:	7442                	ld	s0,48(sp)
    8000460a:	74a2                	ld	s1,40(sp)
    8000460c:	7902                	ld	s2,32(sp)
    8000460e:	69e2                	ld	s3,24(sp)
    80004610:	6a42                	ld	s4,16(sp)
    80004612:	6aa2                	ld	s5,8(sp)
    80004614:	6121                	addi	sp,sp,64
    80004616:	8082                	ret
    panic("log.committing");
    80004618:	00004517          	auipc	a0,0x4
    8000461c:	0a850513          	addi	a0,a0,168 # 800086c0 <syscalls+0x1e0>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	f1e080e7          	jalr	-226(ra) # 8000053e <panic>
    wakeup(&log);
    80004628:	0001e497          	auipc	s1,0x1e
    8000462c:	84048493          	addi	s1,s1,-1984 # 80021e68 <log>
    80004630:	8526                	mv	a0,s1
    80004632:	ffffe097          	auipc	ra,0xffffe
    80004636:	0dc080e7          	jalr	220(ra) # 8000270e <wakeup>
  release(&log.lock);
    8000463a:	8526                	mv	a0,s1
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	65c080e7          	jalr	1628(ra) # 80000c98 <release>
  if(do_commit){
    80004644:	b7c9                	j	80004606 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004646:	0001ea97          	auipc	s5,0x1e
    8000464a:	852a8a93          	addi	s5,s5,-1966 # 80021e98 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000464e:	0001ea17          	auipc	s4,0x1e
    80004652:	81aa0a13          	addi	s4,s4,-2022 # 80021e68 <log>
    80004656:	018a2583          	lw	a1,24(s4)
    8000465a:	012585bb          	addw	a1,a1,s2
    8000465e:	2585                	addiw	a1,a1,1
    80004660:	028a2503          	lw	a0,40(s4)
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	cd2080e7          	jalr	-814(ra) # 80003336 <bread>
    8000466c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000466e:	000aa583          	lw	a1,0(s5)
    80004672:	028a2503          	lw	a0,40(s4)
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	cc0080e7          	jalr	-832(ra) # 80003336 <bread>
    8000467e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004680:	40000613          	li	a2,1024
    80004684:	05850593          	addi	a1,a0,88
    80004688:	05848513          	addi	a0,s1,88
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	6b4080e7          	jalr	1716(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    80004694:	8526                	mv	a0,s1
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	d92080e7          	jalr	-622(ra) # 80003428 <bwrite>
    brelse(from);
    8000469e:	854e                	mv	a0,s3
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	dc6080e7          	jalr	-570(ra) # 80003466 <brelse>
    brelse(to);
    800046a8:	8526                	mv	a0,s1
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	dbc080e7          	jalr	-580(ra) # 80003466 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046b2:	2905                	addiw	s2,s2,1
    800046b4:	0a91                	addi	s5,s5,4
    800046b6:	02ca2783          	lw	a5,44(s4)
    800046ba:	f8f94ee3          	blt	s2,a5,80004656 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046be:	00000097          	auipc	ra,0x0
    800046c2:	c6a080e7          	jalr	-918(ra) # 80004328 <write_head>
    install_trans(0); // Now install writes to home locations
    800046c6:	4501                	li	a0,0
    800046c8:	00000097          	auipc	ra,0x0
    800046cc:	cda080e7          	jalr	-806(ra) # 800043a2 <install_trans>
    log.lh.n = 0;
    800046d0:	0001d797          	auipc	a5,0x1d
    800046d4:	7c07a223          	sw	zero,1988(a5) # 80021e94 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	c50080e7          	jalr	-944(ra) # 80004328 <write_head>
    800046e0:	bdf5                	j	800045dc <end_op+0x52>

00000000800046e2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046e2:	1101                	addi	sp,sp,-32
    800046e4:	ec06                	sd	ra,24(sp)
    800046e6:	e822                	sd	s0,16(sp)
    800046e8:	e426                	sd	s1,8(sp)
    800046ea:	e04a                	sd	s2,0(sp)
    800046ec:	1000                	addi	s0,sp,32
    800046ee:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046f0:	0001d917          	auipc	s2,0x1d
    800046f4:	77890913          	addi	s2,s2,1912 # 80021e68 <log>
    800046f8:	854a                	mv	a0,s2
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	4ea080e7          	jalr	1258(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004702:	02c92603          	lw	a2,44(s2)
    80004706:	47f5                	li	a5,29
    80004708:	06c7c563          	blt	a5,a2,80004772 <log_write+0x90>
    8000470c:	0001d797          	auipc	a5,0x1d
    80004710:	7787a783          	lw	a5,1912(a5) # 80021e84 <log+0x1c>
    80004714:	37fd                	addiw	a5,a5,-1
    80004716:	04f65e63          	bge	a2,a5,80004772 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000471a:	0001d797          	auipc	a5,0x1d
    8000471e:	76e7a783          	lw	a5,1902(a5) # 80021e88 <log+0x20>
    80004722:	06f05063          	blez	a5,80004782 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004726:	4781                	li	a5,0
    80004728:	06c05563          	blez	a2,80004792 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000472c:	44cc                	lw	a1,12(s1)
    8000472e:	0001d717          	auipc	a4,0x1d
    80004732:	76a70713          	addi	a4,a4,1898 # 80021e98 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004736:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004738:	4314                	lw	a3,0(a4)
    8000473a:	04b68c63          	beq	a3,a1,80004792 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000473e:	2785                	addiw	a5,a5,1
    80004740:	0711                	addi	a4,a4,4
    80004742:	fef61be3          	bne	a2,a5,80004738 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004746:	0621                	addi	a2,a2,8
    80004748:	060a                	slli	a2,a2,0x2
    8000474a:	0001d797          	auipc	a5,0x1d
    8000474e:	71e78793          	addi	a5,a5,1822 # 80021e68 <log>
    80004752:	963e                	add	a2,a2,a5
    80004754:	44dc                	lw	a5,12(s1)
    80004756:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004758:	8526                	mv	a0,s1
    8000475a:	fffff097          	auipc	ra,0xfffff
    8000475e:	daa080e7          	jalr	-598(ra) # 80003504 <bpin>
    log.lh.n++;
    80004762:	0001d717          	auipc	a4,0x1d
    80004766:	70670713          	addi	a4,a4,1798 # 80021e68 <log>
    8000476a:	575c                	lw	a5,44(a4)
    8000476c:	2785                	addiw	a5,a5,1
    8000476e:	d75c                	sw	a5,44(a4)
    80004770:	a835                	j	800047ac <log_write+0xca>
    panic("too big a transaction");
    80004772:	00004517          	auipc	a0,0x4
    80004776:	f5e50513          	addi	a0,a0,-162 # 800086d0 <syscalls+0x1f0>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	dc4080e7          	jalr	-572(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004782:	00004517          	auipc	a0,0x4
    80004786:	f6650513          	addi	a0,a0,-154 # 800086e8 <syscalls+0x208>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	db4080e7          	jalr	-588(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004792:	00878713          	addi	a4,a5,8
    80004796:	00271693          	slli	a3,a4,0x2
    8000479a:	0001d717          	auipc	a4,0x1d
    8000479e:	6ce70713          	addi	a4,a4,1742 # 80021e68 <log>
    800047a2:	9736                	add	a4,a4,a3
    800047a4:	44d4                	lw	a3,12(s1)
    800047a6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047a8:	faf608e3          	beq	a2,a5,80004758 <log_write+0x76>
  }
  release(&log.lock);
    800047ac:	0001d517          	auipc	a0,0x1d
    800047b0:	6bc50513          	addi	a0,a0,1724 # 80021e68 <log>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	4e4080e7          	jalr	1252(ra) # 80000c98 <release>
}
    800047bc:	60e2                	ld	ra,24(sp)
    800047be:	6442                	ld	s0,16(sp)
    800047c0:	64a2                	ld	s1,8(sp)
    800047c2:	6902                	ld	s2,0(sp)
    800047c4:	6105                	addi	sp,sp,32
    800047c6:	8082                	ret

00000000800047c8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047c8:	1101                	addi	sp,sp,-32
    800047ca:	ec06                	sd	ra,24(sp)
    800047cc:	e822                	sd	s0,16(sp)
    800047ce:	e426                	sd	s1,8(sp)
    800047d0:	e04a                	sd	s2,0(sp)
    800047d2:	1000                	addi	s0,sp,32
    800047d4:	84aa                	mv	s1,a0
    800047d6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047d8:	00004597          	auipc	a1,0x4
    800047dc:	f3058593          	addi	a1,a1,-208 # 80008708 <syscalls+0x228>
    800047e0:	0521                	addi	a0,a0,8
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	372080e7          	jalr	882(ra) # 80000b54 <initlock>
  lk->name = name;
    800047ea:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047ee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047f2:	0204a423          	sw	zero,40(s1)
}
    800047f6:	60e2                	ld	ra,24(sp)
    800047f8:	6442                	ld	s0,16(sp)
    800047fa:	64a2                	ld	s1,8(sp)
    800047fc:	6902                	ld	s2,0(sp)
    800047fe:	6105                	addi	sp,sp,32
    80004800:	8082                	ret

0000000080004802 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004802:	1101                	addi	sp,sp,-32
    80004804:	ec06                	sd	ra,24(sp)
    80004806:	e822                	sd	s0,16(sp)
    80004808:	e426                	sd	s1,8(sp)
    8000480a:	e04a                	sd	s2,0(sp)
    8000480c:	1000                	addi	s0,sp,32
    8000480e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004810:	00850913          	addi	s2,a0,8
    80004814:	854a                	mv	a0,s2
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	3ce080e7          	jalr	974(ra) # 80000be4 <acquire>
  while (lk->locked) {
    8000481e:	409c                	lw	a5,0(s1)
    80004820:	cb89                	beqz	a5,80004832 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004822:	85ca                	mv	a1,s2
    80004824:	8526                	mv	a0,s1
    80004826:	ffffe097          	auipc	ra,0xffffe
    8000482a:	ce8080e7          	jalr	-792(ra) # 8000250e <sleep>
  while (lk->locked) {
    8000482e:	409c                	lw	a5,0(s1)
    80004830:	fbed                	bnez	a5,80004822 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004832:	4785                	li	a5,1
    80004834:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004836:	ffffd097          	auipc	ra,0xffffd
    8000483a:	57a080e7          	jalr	1402(ra) # 80001db0 <myproc>
    8000483e:	591c                	lw	a5,48(a0)
    80004840:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004842:	854a                	mv	a0,s2
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	454080e7          	jalr	1108(ra) # 80000c98 <release>
}
    8000484c:	60e2                	ld	ra,24(sp)
    8000484e:	6442                	ld	s0,16(sp)
    80004850:	64a2                	ld	s1,8(sp)
    80004852:	6902                	ld	s2,0(sp)
    80004854:	6105                	addi	sp,sp,32
    80004856:	8082                	ret

0000000080004858 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	e426                	sd	s1,8(sp)
    80004860:	e04a                	sd	s2,0(sp)
    80004862:	1000                	addi	s0,sp,32
    80004864:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004866:	00850913          	addi	s2,a0,8
    8000486a:	854a                	mv	a0,s2
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	378080e7          	jalr	888(ra) # 80000be4 <acquire>
  lk->locked = 0;
    80004874:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004878:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000487c:	8526                	mv	a0,s1
    8000487e:	ffffe097          	auipc	ra,0xffffe
    80004882:	e90080e7          	jalr	-368(ra) # 8000270e <wakeup>
  release(&lk->lk);
    80004886:	854a                	mv	a0,s2
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	410080e7          	jalr	1040(ra) # 80000c98 <release>
}
    80004890:	60e2                	ld	ra,24(sp)
    80004892:	6442                	ld	s0,16(sp)
    80004894:	64a2                	ld	s1,8(sp)
    80004896:	6902                	ld	s2,0(sp)
    80004898:	6105                	addi	sp,sp,32
    8000489a:	8082                	ret

000000008000489c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000489c:	7179                	addi	sp,sp,-48
    8000489e:	f406                	sd	ra,40(sp)
    800048a0:	f022                	sd	s0,32(sp)
    800048a2:	ec26                	sd	s1,24(sp)
    800048a4:	e84a                	sd	s2,16(sp)
    800048a6:	e44e                	sd	s3,8(sp)
    800048a8:	1800                	addi	s0,sp,48
    800048aa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048ac:	00850913          	addi	s2,a0,8
    800048b0:	854a                	mv	a0,s2
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	332080e7          	jalr	818(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ba:	409c                	lw	a5,0(s1)
    800048bc:	ef99                	bnez	a5,800048da <holdingsleep+0x3e>
    800048be:	4481                	li	s1,0
  release(&lk->lk);
    800048c0:	854a                	mv	a0,s2
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	3d6080e7          	jalr	982(ra) # 80000c98 <release>
  return r;
}
    800048ca:	8526                	mv	a0,s1
    800048cc:	70a2                	ld	ra,40(sp)
    800048ce:	7402                	ld	s0,32(sp)
    800048d0:	64e2                	ld	s1,24(sp)
    800048d2:	6942                	ld	s2,16(sp)
    800048d4:	69a2                	ld	s3,8(sp)
    800048d6:	6145                	addi	sp,sp,48
    800048d8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048da:	0284a983          	lw	s3,40(s1)
    800048de:	ffffd097          	auipc	ra,0xffffd
    800048e2:	4d2080e7          	jalr	1234(ra) # 80001db0 <myproc>
    800048e6:	5904                	lw	s1,48(a0)
    800048e8:	413484b3          	sub	s1,s1,s3
    800048ec:	0014b493          	seqz	s1,s1
    800048f0:	bfc1                	j	800048c0 <holdingsleep+0x24>

00000000800048f2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048f2:	1141                	addi	sp,sp,-16
    800048f4:	e406                	sd	ra,8(sp)
    800048f6:	e022                	sd	s0,0(sp)
    800048f8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048fa:	00004597          	auipc	a1,0x4
    800048fe:	e1e58593          	addi	a1,a1,-482 # 80008718 <syscalls+0x238>
    80004902:	0001d517          	auipc	a0,0x1d
    80004906:	6ae50513          	addi	a0,a0,1710 # 80021fb0 <ftable>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	24a080e7          	jalr	586(ra) # 80000b54 <initlock>
}
    80004912:	60a2                	ld	ra,8(sp)
    80004914:	6402                	ld	s0,0(sp)
    80004916:	0141                	addi	sp,sp,16
    80004918:	8082                	ret

000000008000491a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000491a:	1101                	addi	sp,sp,-32
    8000491c:	ec06                	sd	ra,24(sp)
    8000491e:	e822                	sd	s0,16(sp)
    80004920:	e426                	sd	s1,8(sp)
    80004922:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004924:	0001d517          	auipc	a0,0x1d
    80004928:	68c50513          	addi	a0,a0,1676 # 80021fb0 <ftable>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	2b8080e7          	jalr	696(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004934:	0001d497          	auipc	s1,0x1d
    80004938:	69448493          	addi	s1,s1,1684 # 80021fc8 <ftable+0x18>
    8000493c:	0001e717          	auipc	a4,0x1e
    80004940:	62c70713          	addi	a4,a4,1580 # 80022f68 <ftable+0xfb8>
    if(f->ref == 0){
    80004944:	40dc                	lw	a5,4(s1)
    80004946:	cf99                	beqz	a5,80004964 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004948:	02848493          	addi	s1,s1,40
    8000494c:	fee49ce3          	bne	s1,a4,80004944 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004950:	0001d517          	auipc	a0,0x1d
    80004954:	66050513          	addi	a0,a0,1632 # 80021fb0 <ftable>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	340080e7          	jalr	832(ra) # 80000c98 <release>
  return 0;
    80004960:	4481                	li	s1,0
    80004962:	a819                	j	80004978 <filealloc+0x5e>
      f->ref = 1;
    80004964:	4785                	li	a5,1
    80004966:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004968:	0001d517          	auipc	a0,0x1d
    8000496c:	64850513          	addi	a0,a0,1608 # 80021fb0 <ftable>
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	328080e7          	jalr	808(ra) # 80000c98 <release>
}
    80004978:	8526                	mv	a0,s1
    8000497a:	60e2                	ld	ra,24(sp)
    8000497c:	6442                	ld	s0,16(sp)
    8000497e:	64a2                	ld	s1,8(sp)
    80004980:	6105                	addi	sp,sp,32
    80004982:	8082                	ret

0000000080004984 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004984:	1101                	addi	sp,sp,-32
    80004986:	ec06                	sd	ra,24(sp)
    80004988:	e822                	sd	s0,16(sp)
    8000498a:	e426                	sd	s1,8(sp)
    8000498c:	1000                	addi	s0,sp,32
    8000498e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004990:	0001d517          	auipc	a0,0x1d
    80004994:	62050513          	addi	a0,a0,1568 # 80021fb0 <ftable>
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	24c080e7          	jalr	588(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    800049a0:	40dc                	lw	a5,4(s1)
    800049a2:	02f05263          	blez	a5,800049c6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049a6:	2785                	addiw	a5,a5,1
    800049a8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049aa:	0001d517          	auipc	a0,0x1d
    800049ae:	60650513          	addi	a0,a0,1542 # 80021fb0 <ftable>
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	2e6080e7          	jalr	742(ra) # 80000c98 <release>
  return f;
}
    800049ba:	8526                	mv	a0,s1
    800049bc:	60e2                	ld	ra,24(sp)
    800049be:	6442                	ld	s0,16(sp)
    800049c0:	64a2                	ld	s1,8(sp)
    800049c2:	6105                	addi	sp,sp,32
    800049c4:	8082                	ret
    panic("filedup");
    800049c6:	00004517          	auipc	a0,0x4
    800049ca:	d5a50513          	addi	a0,a0,-678 # 80008720 <syscalls+0x240>
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	b70080e7          	jalr	-1168(ra) # 8000053e <panic>

00000000800049d6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049d6:	7139                	addi	sp,sp,-64
    800049d8:	fc06                	sd	ra,56(sp)
    800049da:	f822                	sd	s0,48(sp)
    800049dc:	f426                	sd	s1,40(sp)
    800049de:	f04a                	sd	s2,32(sp)
    800049e0:	ec4e                	sd	s3,24(sp)
    800049e2:	e852                	sd	s4,16(sp)
    800049e4:	e456                	sd	s5,8(sp)
    800049e6:	0080                	addi	s0,sp,64
    800049e8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049ea:	0001d517          	auipc	a0,0x1d
    800049ee:	5c650513          	addi	a0,a0,1478 # 80021fb0 <ftable>
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	1f2080e7          	jalr	498(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    800049fa:	40dc                	lw	a5,4(s1)
    800049fc:	06f05163          	blez	a5,80004a5e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a00:	37fd                	addiw	a5,a5,-1
    80004a02:	0007871b          	sext.w	a4,a5
    80004a06:	c0dc                	sw	a5,4(s1)
    80004a08:	06e04363          	bgtz	a4,80004a6e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a0c:	0004a903          	lw	s2,0(s1)
    80004a10:	0094ca83          	lbu	s5,9(s1)
    80004a14:	0104ba03          	ld	s4,16(s1)
    80004a18:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a1c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a20:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a24:	0001d517          	auipc	a0,0x1d
    80004a28:	58c50513          	addi	a0,a0,1420 # 80021fb0 <ftable>
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	26c080e7          	jalr	620(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    80004a34:	4785                	li	a5,1
    80004a36:	04f90d63          	beq	s2,a5,80004a90 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a3a:	3979                	addiw	s2,s2,-2
    80004a3c:	4785                	li	a5,1
    80004a3e:	0527e063          	bltu	a5,s2,80004a7e <fileclose+0xa8>
    begin_op();
    80004a42:	00000097          	auipc	ra,0x0
    80004a46:	ac8080e7          	jalr	-1336(ra) # 8000450a <begin_op>
    iput(ff.ip);
    80004a4a:	854e                	mv	a0,s3
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	2a6080e7          	jalr	678(ra) # 80003cf2 <iput>
    end_op();
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	b36080e7          	jalr	-1226(ra) # 8000458a <end_op>
    80004a5c:	a00d                	j	80004a7e <fileclose+0xa8>
    panic("fileclose");
    80004a5e:	00004517          	auipc	a0,0x4
    80004a62:	cca50513          	addi	a0,a0,-822 # 80008728 <syscalls+0x248>
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004a6e:	0001d517          	auipc	a0,0x1d
    80004a72:	54250513          	addi	a0,a0,1346 # 80021fb0 <ftable>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	222080e7          	jalr	546(ra) # 80000c98 <release>
  }
}
    80004a7e:	70e2                	ld	ra,56(sp)
    80004a80:	7442                	ld	s0,48(sp)
    80004a82:	74a2                	ld	s1,40(sp)
    80004a84:	7902                	ld	s2,32(sp)
    80004a86:	69e2                	ld	s3,24(sp)
    80004a88:	6a42                	ld	s4,16(sp)
    80004a8a:	6aa2                	ld	s5,8(sp)
    80004a8c:	6121                	addi	sp,sp,64
    80004a8e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a90:	85d6                	mv	a1,s5
    80004a92:	8552                	mv	a0,s4
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	34c080e7          	jalr	844(ra) # 80004de0 <pipeclose>
    80004a9c:	b7cd                	j	80004a7e <fileclose+0xa8>

0000000080004a9e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a9e:	715d                	addi	sp,sp,-80
    80004aa0:	e486                	sd	ra,72(sp)
    80004aa2:	e0a2                	sd	s0,64(sp)
    80004aa4:	fc26                	sd	s1,56(sp)
    80004aa6:	f84a                	sd	s2,48(sp)
    80004aa8:	f44e                	sd	s3,40(sp)
    80004aaa:	0880                	addi	s0,sp,80
    80004aac:	84aa                	mv	s1,a0
    80004aae:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ab0:	ffffd097          	auipc	ra,0xffffd
    80004ab4:	300080e7          	jalr	768(ra) # 80001db0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ab8:	409c                	lw	a5,0(s1)
    80004aba:	37f9                	addiw	a5,a5,-2
    80004abc:	4705                	li	a4,1
    80004abe:	04f76763          	bltu	a4,a5,80004b0c <filestat+0x6e>
    80004ac2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ac4:	6c88                	ld	a0,24(s1)
    80004ac6:	fffff097          	auipc	ra,0xfffff
    80004aca:	072080e7          	jalr	114(ra) # 80003b38 <ilock>
    stati(f->ip, &st);
    80004ace:	fb840593          	addi	a1,s0,-72
    80004ad2:	6c88                	ld	a0,24(s1)
    80004ad4:	fffff097          	auipc	ra,0xfffff
    80004ad8:	2ee080e7          	jalr	750(ra) # 80003dc2 <stati>
    iunlock(f->ip);
    80004adc:	6c88                	ld	a0,24(s1)
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	11c080e7          	jalr	284(ra) # 80003bfa <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ae6:	46e1                	li	a3,24
    80004ae8:	fb840613          	addi	a2,s0,-72
    80004aec:	85ce                	mv	a1,s3
    80004aee:	07893503          	ld	a0,120(s2)
    80004af2:	ffffd097          	auipc	ra,0xffffd
    80004af6:	b80080e7          	jalr	-1152(ra) # 80001672 <copyout>
    80004afa:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004afe:	60a6                	ld	ra,72(sp)
    80004b00:	6406                	ld	s0,64(sp)
    80004b02:	74e2                	ld	s1,56(sp)
    80004b04:	7942                	ld	s2,48(sp)
    80004b06:	79a2                	ld	s3,40(sp)
    80004b08:	6161                	addi	sp,sp,80
    80004b0a:	8082                	ret
  return -1;
    80004b0c:	557d                	li	a0,-1
    80004b0e:	bfc5                	j	80004afe <filestat+0x60>

0000000080004b10 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b10:	7179                	addi	sp,sp,-48
    80004b12:	f406                	sd	ra,40(sp)
    80004b14:	f022                	sd	s0,32(sp)
    80004b16:	ec26                	sd	s1,24(sp)
    80004b18:	e84a                	sd	s2,16(sp)
    80004b1a:	e44e                	sd	s3,8(sp)
    80004b1c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b1e:	00854783          	lbu	a5,8(a0)
    80004b22:	c3d5                	beqz	a5,80004bc6 <fileread+0xb6>
    80004b24:	84aa                	mv	s1,a0
    80004b26:	89ae                	mv	s3,a1
    80004b28:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b2a:	411c                	lw	a5,0(a0)
    80004b2c:	4705                	li	a4,1
    80004b2e:	04e78963          	beq	a5,a4,80004b80 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b32:	470d                	li	a4,3
    80004b34:	04e78d63          	beq	a5,a4,80004b8e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b38:	4709                	li	a4,2
    80004b3a:	06e79e63          	bne	a5,a4,80004bb6 <fileread+0xa6>
    ilock(f->ip);
    80004b3e:	6d08                	ld	a0,24(a0)
    80004b40:	fffff097          	auipc	ra,0xfffff
    80004b44:	ff8080e7          	jalr	-8(ra) # 80003b38 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b48:	874a                	mv	a4,s2
    80004b4a:	5094                	lw	a3,32(s1)
    80004b4c:	864e                	mv	a2,s3
    80004b4e:	4585                	li	a1,1
    80004b50:	6c88                	ld	a0,24(s1)
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	29a080e7          	jalr	666(ra) # 80003dec <readi>
    80004b5a:	892a                	mv	s2,a0
    80004b5c:	00a05563          	blez	a0,80004b66 <fileread+0x56>
      f->off += r;
    80004b60:	509c                	lw	a5,32(s1)
    80004b62:	9fa9                	addw	a5,a5,a0
    80004b64:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b66:	6c88                	ld	a0,24(s1)
    80004b68:	fffff097          	auipc	ra,0xfffff
    80004b6c:	092080e7          	jalr	146(ra) # 80003bfa <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b70:	854a                	mv	a0,s2
    80004b72:	70a2                	ld	ra,40(sp)
    80004b74:	7402                	ld	s0,32(sp)
    80004b76:	64e2                	ld	s1,24(sp)
    80004b78:	6942                	ld	s2,16(sp)
    80004b7a:	69a2                	ld	s3,8(sp)
    80004b7c:	6145                	addi	sp,sp,48
    80004b7e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b80:	6908                	ld	a0,16(a0)
    80004b82:	00000097          	auipc	ra,0x0
    80004b86:	3c8080e7          	jalr	968(ra) # 80004f4a <piperead>
    80004b8a:	892a                	mv	s2,a0
    80004b8c:	b7d5                	j	80004b70 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b8e:	02451783          	lh	a5,36(a0)
    80004b92:	03079693          	slli	a3,a5,0x30
    80004b96:	92c1                	srli	a3,a3,0x30
    80004b98:	4725                	li	a4,9
    80004b9a:	02d76863          	bltu	a4,a3,80004bca <fileread+0xba>
    80004b9e:	0792                	slli	a5,a5,0x4
    80004ba0:	0001d717          	auipc	a4,0x1d
    80004ba4:	37070713          	addi	a4,a4,880 # 80021f10 <devsw>
    80004ba8:	97ba                	add	a5,a5,a4
    80004baa:	639c                	ld	a5,0(a5)
    80004bac:	c38d                	beqz	a5,80004bce <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004bae:	4505                	li	a0,1
    80004bb0:	9782                	jalr	a5
    80004bb2:	892a                	mv	s2,a0
    80004bb4:	bf75                	j	80004b70 <fileread+0x60>
    panic("fileread");
    80004bb6:	00004517          	auipc	a0,0x4
    80004bba:	b8250513          	addi	a0,a0,-1150 # 80008738 <syscalls+0x258>
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	980080e7          	jalr	-1664(ra) # 8000053e <panic>
    return -1;
    80004bc6:	597d                	li	s2,-1
    80004bc8:	b765                	j	80004b70 <fileread+0x60>
      return -1;
    80004bca:	597d                	li	s2,-1
    80004bcc:	b755                	j	80004b70 <fileread+0x60>
    80004bce:	597d                	li	s2,-1
    80004bd0:	b745                	j	80004b70 <fileread+0x60>

0000000080004bd2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004bd2:	715d                	addi	sp,sp,-80
    80004bd4:	e486                	sd	ra,72(sp)
    80004bd6:	e0a2                	sd	s0,64(sp)
    80004bd8:	fc26                	sd	s1,56(sp)
    80004bda:	f84a                	sd	s2,48(sp)
    80004bdc:	f44e                	sd	s3,40(sp)
    80004bde:	f052                	sd	s4,32(sp)
    80004be0:	ec56                	sd	s5,24(sp)
    80004be2:	e85a                	sd	s6,16(sp)
    80004be4:	e45e                	sd	s7,8(sp)
    80004be6:	e062                	sd	s8,0(sp)
    80004be8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004bea:	00954783          	lbu	a5,9(a0)
    80004bee:	10078663          	beqz	a5,80004cfa <filewrite+0x128>
    80004bf2:	892a                	mv	s2,a0
    80004bf4:	8aae                	mv	s5,a1
    80004bf6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bf8:	411c                	lw	a5,0(a0)
    80004bfa:	4705                	li	a4,1
    80004bfc:	02e78263          	beq	a5,a4,80004c20 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c00:	470d                	li	a4,3
    80004c02:	02e78663          	beq	a5,a4,80004c2e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c06:	4709                	li	a4,2
    80004c08:	0ee79163          	bne	a5,a4,80004cea <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c0c:	0ac05d63          	blez	a2,80004cc6 <filewrite+0xf4>
    int i = 0;
    80004c10:	4981                	li	s3,0
    80004c12:	6b05                	lui	s6,0x1
    80004c14:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c18:	6b85                	lui	s7,0x1
    80004c1a:	c00b8b9b          	addiw	s7,s7,-1024
    80004c1e:	a861                	j	80004cb6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c20:	6908                	ld	a0,16(a0)
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	22e080e7          	jalr	558(ra) # 80004e50 <pipewrite>
    80004c2a:	8a2a                	mv	s4,a0
    80004c2c:	a045                	j	80004ccc <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c2e:	02451783          	lh	a5,36(a0)
    80004c32:	03079693          	slli	a3,a5,0x30
    80004c36:	92c1                	srli	a3,a3,0x30
    80004c38:	4725                	li	a4,9
    80004c3a:	0cd76263          	bltu	a4,a3,80004cfe <filewrite+0x12c>
    80004c3e:	0792                	slli	a5,a5,0x4
    80004c40:	0001d717          	auipc	a4,0x1d
    80004c44:	2d070713          	addi	a4,a4,720 # 80021f10 <devsw>
    80004c48:	97ba                	add	a5,a5,a4
    80004c4a:	679c                	ld	a5,8(a5)
    80004c4c:	cbdd                	beqz	a5,80004d02 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c4e:	4505                	li	a0,1
    80004c50:	9782                	jalr	a5
    80004c52:	8a2a                	mv	s4,a0
    80004c54:	a8a5                	j	80004ccc <filewrite+0xfa>
    80004c56:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c5a:	00000097          	auipc	ra,0x0
    80004c5e:	8b0080e7          	jalr	-1872(ra) # 8000450a <begin_op>
      ilock(f->ip);
    80004c62:	01893503          	ld	a0,24(s2)
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	ed2080e7          	jalr	-302(ra) # 80003b38 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c6e:	8762                	mv	a4,s8
    80004c70:	02092683          	lw	a3,32(s2)
    80004c74:	01598633          	add	a2,s3,s5
    80004c78:	4585                	li	a1,1
    80004c7a:	01893503          	ld	a0,24(s2)
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	266080e7          	jalr	614(ra) # 80003ee4 <writei>
    80004c86:	84aa                	mv	s1,a0
    80004c88:	00a05763          	blez	a0,80004c96 <filewrite+0xc4>
        f->off += r;
    80004c8c:	02092783          	lw	a5,32(s2)
    80004c90:	9fa9                	addw	a5,a5,a0
    80004c92:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c96:	01893503          	ld	a0,24(s2)
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	f60080e7          	jalr	-160(ra) # 80003bfa <iunlock>
      end_op();
    80004ca2:	00000097          	auipc	ra,0x0
    80004ca6:	8e8080e7          	jalr	-1816(ra) # 8000458a <end_op>

      if(r != n1){
    80004caa:	009c1f63          	bne	s8,s1,80004cc8 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004cae:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004cb2:	0149db63          	bge	s3,s4,80004cc8 <filewrite+0xf6>
      int n1 = n - i;
    80004cb6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004cba:	84be                	mv	s1,a5
    80004cbc:	2781                	sext.w	a5,a5
    80004cbe:	f8fb5ce3          	bge	s6,a5,80004c56 <filewrite+0x84>
    80004cc2:	84de                	mv	s1,s7
    80004cc4:	bf49                	j	80004c56 <filewrite+0x84>
    int i = 0;
    80004cc6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cc8:	013a1f63          	bne	s4,s3,80004ce6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ccc:	8552                	mv	a0,s4
    80004cce:	60a6                	ld	ra,72(sp)
    80004cd0:	6406                	ld	s0,64(sp)
    80004cd2:	74e2                	ld	s1,56(sp)
    80004cd4:	7942                	ld	s2,48(sp)
    80004cd6:	79a2                	ld	s3,40(sp)
    80004cd8:	7a02                	ld	s4,32(sp)
    80004cda:	6ae2                	ld	s5,24(sp)
    80004cdc:	6b42                	ld	s6,16(sp)
    80004cde:	6ba2                	ld	s7,8(sp)
    80004ce0:	6c02                	ld	s8,0(sp)
    80004ce2:	6161                	addi	sp,sp,80
    80004ce4:	8082                	ret
    ret = (i == n ? n : -1);
    80004ce6:	5a7d                	li	s4,-1
    80004ce8:	b7d5                	j	80004ccc <filewrite+0xfa>
    panic("filewrite");
    80004cea:	00004517          	auipc	a0,0x4
    80004cee:	a5e50513          	addi	a0,a0,-1442 # 80008748 <syscalls+0x268>
    80004cf2:	ffffc097          	auipc	ra,0xffffc
    80004cf6:	84c080e7          	jalr	-1972(ra) # 8000053e <panic>
    return -1;
    80004cfa:	5a7d                	li	s4,-1
    80004cfc:	bfc1                	j	80004ccc <filewrite+0xfa>
      return -1;
    80004cfe:	5a7d                	li	s4,-1
    80004d00:	b7f1                	j	80004ccc <filewrite+0xfa>
    80004d02:	5a7d                	li	s4,-1
    80004d04:	b7e1                	j	80004ccc <filewrite+0xfa>

0000000080004d06 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d06:	7179                	addi	sp,sp,-48
    80004d08:	f406                	sd	ra,40(sp)
    80004d0a:	f022                	sd	s0,32(sp)
    80004d0c:	ec26                	sd	s1,24(sp)
    80004d0e:	e84a                	sd	s2,16(sp)
    80004d10:	e44e                	sd	s3,8(sp)
    80004d12:	e052                	sd	s4,0(sp)
    80004d14:	1800                	addi	s0,sp,48
    80004d16:	84aa                	mv	s1,a0
    80004d18:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d1a:	0005b023          	sd	zero,0(a1)
    80004d1e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	bf8080e7          	jalr	-1032(ra) # 8000491a <filealloc>
    80004d2a:	e088                	sd	a0,0(s1)
    80004d2c:	c551                	beqz	a0,80004db8 <pipealloc+0xb2>
    80004d2e:	00000097          	auipc	ra,0x0
    80004d32:	bec080e7          	jalr	-1044(ra) # 8000491a <filealloc>
    80004d36:	00aa3023          	sd	a0,0(s4)
    80004d3a:	c92d                	beqz	a0,80004dac <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	db8080e7          	jalr	-584(ra) # 80000af4 <kalloc>
    80004d44:	892a                	mv	s2,a0
    80004d46:	c125                	beqz	a0,80004da6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d48:	4985                	li	s3,1
    80004d4a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d4e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d52:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d56:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d5a:	00004597          	auipc	a1,0x4
    80004d5e:	9fe58593          	addi	a1,a1,-1538 # 80008758 <syscalls+0x278>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	df2080e7          	jalr	-526(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004d6a:	609c                	ld	a5,0(s1)
    80004d6c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d70:	609c                	ld	a5,0(s1)
    80004d72:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d76:	609c                	ld	a5,0(s1)
    80004d78:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d7c:	609c                	ld	a5,0(s1)
    80004d7e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d82:	000a3783          	ld	a5,0(s4)
    80004d86:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d8a:	000a3783          	ld	a5,0(s4)
    80004d8e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d92:	000a3783          	ld	a5,0(s4)
    80004d96:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d9a:	000a3783          	ld	a5,0(s4)
    80004d9e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004da2:	4501                	li	a0,0
    80004da4:	a025                	j	80004dcc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004da6:	6088                	ld	a0,0(s1)
    80004da8:	e501                	bnez	a0,80004db0 <pipealloc+0xaa>
    80004daa:	a039                	j	80004db8 <pipealloc+0xb2>
    80004dac:	6088                	ld	a0,0(s1)
    80004dae:	c51d                	beqz	a0,80004ddc <pipealloc+0xd6>
    fileclose(*f0);
    80004db0:	00000097          	auipc	ra,0x0
    80004db4:	c26080e7          	jalr	-986(ra) # 800049d6 <fileclose>
  if(*f1)
    80004db8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dbc:	557d                	li	a0,-1
  if(*f1)
    80004dbe:	c799                	beqz	a5,80004dcc <pipealloc+0xc6>
    fileclose(*f1);
    80004dc0:	853e                	mv	a0,a5
    80004dc2:	00000097          	auipc	ra,0x0
    80004dc6:	c14080e7          	jalr	-1004(ra) # 800049d6 <fileclose>
  return -1;
    80004dca:	557d                	li	a0,-1
}
    80004dcc:	70a2                	ld	ra,40(sp)
    80004dce:	7402                	ld	s0,32(sp)
    80004dd0:	64e2                	ld	s1,24(sp)
    80004dd2:	6942                	ld	s2,16(sp)
    80004dd4:	69a2                	ld	s3,8(sp)
    80004dd6:	6a02                	ld	s4,0(sp)
    80004dd8:	6145                	addi	sp,sp,48
    80004dda:	8082                	ret
  return -1;
    80004ddc:	557d                	li	a0,-1
    80004dde:	b7fd                	j	80004dcc <pipealloc+0xc6>

0000000080004de0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004de0:	1101                	addi	sp,sp,-32
    80004de2:	ec06                	sd	ra,24(sp)
    80004de4:	e822                	sd	s0,16(sp)
    80004de6:	e426                	sd	s1,8(sp)
    80004de8:	e04a                	sd	s2,0(sp)
    80004dea:	1000                	addi	s0,sp,32
    80004dec:	84aa                	mv	s1,a0
    80004dee:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	df4080e7          	jalr	-524(ra) # 80000be4 <acquire>
  if(writable){
    80004df8:	02090d63          	beqz	s2,80004e32 <pipeclose+0x52>
    pi->writeopen = 0;
    80004dfc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e00:	21848513          	addi	a0,s1,536
    80004e04:	ffffe097          	auipc	ra,0xffffe
    80004e08:	90a080e7          	jalr	-1782(ra) # 8000270e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e0c:	2204b783          	ld	a5,544(s1)
    80004e10:	eb95                	bnez	a5,80004e44 <pipeclose+0x64>
    release(&pi->lock);
    80004e12:	8526                	mv	a0,s1
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	e84080e7          	jalr	-380(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	bda080e7          	jalr	-1062(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80004e26:	60e2                	ld	ra,24(sp)
    80004e28:	6442                	ld	s0,16(sp)
    80004e2a:	64a2                	ld	s1,8(sp)
    80004e2c:	6902                	ld	s2,0(sp)
    80004e2e:	6105                	addi	sp,sp,32
    80004e30:	8082                	ret
    pi->readopen = 0;
    80004e32:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e36:	21c48513          	addi	a0,s1,540
    80004e3a:	ffffe097          	auipc	ra,0xffffe
    80004e3e:	8d4080e7          	jalr	-1836(ra) # 8000270e <wakeup>
    80004e42:	b7e9                	j	80004e0c <pipeclose+0x2c>
    release(&pi->lock);
    80004e44:	8526                	mv	a0,s1
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	e52080e7          	jalr	-430(ra) # 80000c98 <release>
}
    80004e4e:	bfe1                	j	80004e26 <pipeclose+0x46>

0000000080004e50 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e50:	7159                	addi	sp,sp,-112
    80004e52:	f486                	sd	ra,104(sp)
    80004e54:	f0a2                	sd	s0,96(sp)
    80004e56:	eca6                	sd	s1,88(sp)
    80004e58:	e8ca                	sd	s2,80(sp)
    80004e5a:	e4ce                	sd	s3,72(sp)
    80004e5c:	e0d2                	sd	s4,64(sp)
    80004e5e:	fc56                	sd	s5,56(sp)
    80004e60:	f85a                	sd	s6,48(sp)
    80004e62:	f45e                	sd	s7,40(sp)
    80004e64:	f062                	sd	s8,32(sp)
    80004e66:	ec66                	sd	s9,24(sp)
    80004e68:	1880                	addi	s0,sp,112
    80004e6a:	84aa                	mv	s1,a0
    80004e6c:	8aae                	mv	s5,a1
    80004e6e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e70:	ffffd097          	auipc	ra,0xffffd
    80004e74:	f40080e7          	jalr	-192(ra) # 80001db0 <myproc>
    80004e78:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e7a:	8526                	mv	a0,s1
    80004e7c:	ffffc097          	auipc	ra,0xffffc
    80004e80:	d68080e7          	jalr	-664(ra) # 80000be4 <acquire>
  while(i < n){
    80004e84:	0d405163          	blez	s4,80004f46 <pipewrite+0xf6>
    80004e88:	8ba6                	mv	s7,s1
  int i = 0;
    80004e8a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e8c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e8e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e92:	21c48c13          	addi	s8,s1,540
    80004e96:	a08d                	j	80004ef8 <pipewrite+0xa8>
      release(&pi->lock);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	dfe080e7          	jalr	-514(ra) # 80000c98 <release>
      return -1;
    80004ea2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ea4:	854a                	mv	a0,s2
    80004ea6:	70a6                	ld	ra,104(sp)
    80004ea8:	7406                	ld	s0,96(sp)
    80004eaa:	64e6                	ld	s1,88(sp)
    80004eac:	6946                	ld	s2,80(sp)
    80004eae:	69a6                	ld	s3,72(sp)
    80004eb0:	6a06                	ld	s4,64(sp)
    80004eb2:	7ae2                	ld	s5,56(sp)
    80004eb4:	7b42                	ld	s6,48(sp)
    80004eb6:	7ba2                	ld	s7,40(sp)
    80004eb8:	7c02                	ld	s8,32(sp)
    80004eba:	6ce2                	ld	s9,24(sp)
    80004ebc:	6165                	addi	sp,sp,112
    80004ebe:	8082                	ret
      wakeup(&pi->nread);
    80004ec0:	8566                	mv	a0,s9
    80004ec2:	ffffe097          	auipc	ra,0xffffe
    80004ec6:	84c080e7          	jalr	-1972(ra) # 8000270e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004eca:	85de                	mv	a1,s7
    80004ecc:	8562                	mv	a0,s8
    80004ece:	ffffd097          	auipc	ra,0xffffd
    80004ed2:	640080e7          	jalr	1600(ra) # 8000250e <sleep>
    80004ed6:	a839                	j	80004ef4 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ed8:	21c4a783          	lw	a5,540(s1)
    80004edc:	0017871b          	addiw	a4,a5,1
    80004ee0:	20e4ae23          	sw	a4,540(s1)
    80004ee4:	1ff7f793          	andi	a5,a5,511
    80004ee8:	97a6                	add	a5,a5,s1
    80004eea:	f9f44703          	lbu	a4,-97(s0)
    80004eee:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ef2:	2905                	addiw	s2,s2,1
  while(i < n){
    80004ef4:	03495d63          	bge	s2,s4,80004f2e <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004ef8:	2204a783          	lw	a5,544(s1)
    80004efc:	dfd1                	beqz	a5,80004e98 <pipewrite+0x48>
    80004efe:	0289a783          	lw	a5,40(s3)
    80004f02:	fbd9                	bnez	a5,80004e98 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f04:	2184a783          	lw	a5,536(s1)
    80004f08:	21c4a703          	lw	a4,540(s1)
    80004f0c:	2007879b          	addiw	a5,a5,512
    80004f10:	faf708e3          	beq	a4,a5,80004ec0 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f14:	4685                	li	a3,1
    80004f16:	01590633          	add	a2,s2,s5
    80004f1a:	f9f40593          	addi	a1,s0,-97
    80004f1e:	0789b503          	ld	a0,120(s3)
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	7dc080e7          	jalr	2012(ra) # 800016fe <copyin>
    80004f2a:	fb6517e3          	bne	a0,s6,80004ed8 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004f2e:	21848513          	addi	a0,s1,536
    80004f32:	ffffd097          	auipc	ra,0xffffd
    80004f36:	7dc080e7          	jalr	2012(ra) # 8000270e <wakeup>
  release(&pi->lock);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	ffffc097          	auipc	ra,0xffffc
    80004f40:	d5c080e7          	jalr	-676(ra) # 80000c98 <release>
  return i;
    80004f44:	b785                	j	80004ea4 <pipewrite+0x54>
  int i = 0;
    80004f46:	4901                	li	s2,0
    80004f48:	b7dd                	j	80004f2e <pipewrite+0xde>

0000000080004f4a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f4a:	715d                	addi	sp,sp,-80
    80004f4c:	e486                	sd	ra,72(sp)
    80004f4e:	e0a2                	sd	s0,64(sp)
    80004f50:	fc26                	sd	s1,56(sp)
    80004f52:	f84a                	sd	s2,48(sp)
    80004f54:	f44e                	sd	s3,40(sp)
    80004f56:	f052                	sd	s4,32(sp)
    80004f58:	ec56                	sd	s5,24(sp)
    80004f5a:	e85a                	sd	s6,16(sp)
    80004f5c:	0880                	addi	s0,sp,80
    80004f5e:	84aa                	mv	s1,a0
    80004f60:	892e                	mv	s2,a1
    80004f62:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	e4c080e7          	jalr	-436(ra) # 80001db0 <myproc>
    80004f6c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f6e:	8b26                	mv	s6,s1
    80004f70:	8526                	mv	a0,s1
    80004f72:	ffffc097          	auipc	ra,0xffffc
    80004f76:	c72080e7          	jalr	-910(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f7a:	2184a703          	lw	a4,536(s1)
    80004f7e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f82:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f86:	02f71463          	bne	a4,a5,80004fae <piperead+0x64>
    80004f8a:	2244a783          	lw	a5,548(s1)
    80004f8e:	c385                	beqz	a5,80004fae <piperead+0x64>
    if(pr->killed){
    80004f90:	028a2783          	lw	a5,40(s4)
    80004f94:	ebc1                	bnez	a5,80005024 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f96:	85da                	mv	a1,s6
    80004f98:	854e                	mv	a0,s3
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	574080e7          	jalr	1396(ra) # 8000250e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fa2:	2184a703          	lw	a4,536(s1)
    80004fa6:	21c4a783          	lw	a5,540(s1)
    80004faa:	fef700e3          	beq	a4,a5,80004f8a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fae:	09505263          	blez	s5,80005032 <piperead+0xe8>
    80004fb2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fb4:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004fb6:	2184a783          	lw	a5,536(s1)
    80004fba:	21c4a703          	lw	a4,540(s1)
    80004fbe:	02f70d63          	beq	a4,a5,80004ff8 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fc2:	0017871b          	addiw	a4,a5,1
    80004fc6:	20e4ac23          	sw	a4,536(s1)
    80004fca:	1ff7f793          	andi	a5,a5,511
    80004fce:	97a6                	add	a5,a5,s1
    80004fd0:	0187c783          	lbu	a5,24(a5)
    80004fd4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fd8:	4685                	li	a3,1
    80004fda:	fbf40613          	addi	a2,s0,-65
    80004fde:	85ca                	mv	a1,s2
    80004fe0:	078a3503          	ld	a0,120(s4)
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	68e080e7          	jalr	1678(ra) # 80001672 <copyout>
    80004fec:	01650663          	beq	a0,s6,80004ff8 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ff0:	2985                	addiw	s3,s3,1
    80004ff2:	0905                	addi	s2,s2,1
    80004ff4:	fd3a91e3          	bne	s5,s3,80004fb6 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ff8:	21c48513          	addi	a0,s1,540
    80004ffc:	ffffd097          	auipc	ra,0xffffd
    80005000:	712080e7          	jalr	1810(ra) # 8000270e <wakeup>
  release(&pi->lock);
    80005004:	8526                	mv	a0,s1
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	c92080e7          	jalr	-878(ra) # 80000c98 <release>
  return i;
}
    8000500e:	854e                	mv	a0,s3
    80005010:	60a6                	ld	ra,72(sp)
    80005012:	6406                	ld	s0,64(sp)
    80005014:	74e2                	ld	s1,56(sp)
    80005016:	7942                	ld	s2,48(sp)
    80005018:	79a2                	ld	s3,40(sp)
    8000501a:	7a02                	ld	s4,32(sp)
    8000501c:	6ae2                	ld	s5,24(sp)
    8000501e:	6b42                	ld	s6,16(sp)
    80005020:	6161                	addi	sp,sp,80
    80005022:	8082                	ret
      release(&pi->lock);
    80005024:	8526                	mv	a0,s1
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	c72080e7          	jalr	-910(ra) # 80000c98 <release>
      return -1;
    8000502e:	59fd                	li	s3,-1
    80005030:	bff9                	j	8000500e <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005032:	4981                	li	s3,0
    80005034:	b7d1                	j	80004ff8 <piperead+0xae>

0000000080005036 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005036:	df010113          	addi	sp,sp,-528
    8000503a:	20113423          	sd	ra,520(sp)
    8000503e:	20813023          	sd	s0,512(sp)
    80005042:	ffa6                	sd	s1,504(sp)
    80005044:	fbca                	sd	s2,496(sp)
    80005046:	f7ce                	sd	s3,488(sp)
    80005048:	f3d2                	sd	s4,480(sp)
    8000504a:	efd6                	sd	s5,472(sp)
    8000504c:	ebda                	sd	s6,464(sp)
    8000504e:	e7de                	sd	s7,456(sp)
    80005050:	e3e2                	sd	s8,448(sp)
    80005052:	ff66                	sd	s9,440(sp)
    80005054:	fb6a                	sd	s10,432(sp)
    80005056:	f76e                	sd	s11,424(sp)
    80005058:	0c00                	addi	s0,sp,528
    8000505a:	84aa                	mv	s1,a0
    8000505c:	dea43c23          	sd	a0,-520(s0)
    80005060:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005064:	ffffd097          	auipc	ra,0xffffd
    80005068:	d4c080e7          	jalr	-692(ra) # 80001db0 <myproc>
    8000506c:	892a                	mv	s2,a0

  begin_op();
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	49c080e7          	jalr	1180(ra) # 8000450a <begin_op>

  if((ip = namei(path)) == 0){
    80005076:	8526                	mv	a0,s1
    80005078:	fffff097          	auipc	ra,0xfffff
    8000507c:	276080e7          	jalr	630(ra) # 800042ee <namei>
    80005080:	c92d                	beqz	a0,800050f2 <exec+0xbc>
    80005082:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	ab4080e7          	jalr	-1356(ra) # 80003b38 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000508c:	04000713          	li	a4,64
    80005090:	4681                	li	a3,0
    80005092:	e5040613          	addi	a2,s0,-432
    80005096:	4581                	li	a1,0
    80005098:	8526                	mv	a0,s1
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	d52080e7          	jalr	-686(ra) # 80003dec <readi>
    800050a2:	04000793          	li	a5,64
    800050a6:	00f51a63          	bne	a0,a5,800050ba <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800050aa:	e5042703          	lw	a4,-432(s0)
    800050ae:	464c47b7          	lui	a5,0x464c4
    800050b2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050b6:	04f70463          	beq	a4,a5,800050fe <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050ba:	8526                	mv	a0,s1
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	cde080e7          	jalr	-802(ra) # 80003d9a <iunlockput>
    end_op();
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	4c6080e7          	jalr	1222(ra) # 8000458a <end_op>
  }
  return -1;
    800050cc:	557d                	li	a0,-1
}
    800050ce:	20813083          	ld	ra,520(sp)
    800050d2:	20013403          	ld	s0,512(sp)
    800050d6:	74fe                	ld	s1,504(sp)
    800050d8:	795e                	ld	s2,496(sp)
    800050da:	79be                	ld	s3,488(sp)
    800050dc:	7a1e                	ld	s4,480(sp)
    800050de:	6afe                	ld	s5,472(sp)
    800050e0:	6b5e                	ld	s6,464(sp)
    800050e2:	6bbe                	ld	s7,456(sp)
    800050e4:	6c1e                	ld	s8,448(sp)
    800050e6:	7cfa                	ld	s9,440(sp)
    800050e8:	7d5a                	ld	s10,432(sp)
    800050ea:	7dba                	ld	s11,424(sp)
    800050ec:	21010113          	addi	sp,sp,528
    800050f0:	8082                	ret
    end_op();
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	498080e7          	jalr	1176(ra) # 8000458a <end_op>
    return -1;
    800050fa:	557d                	li	a0,-1
    800050fc:	bfc9                	j	800050ce <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800050fe:	854a                	mv	a0,s2
    80005100:	ffffd097          	auipc	ra,0xffffd
    80005104:	d98080e7          	jalr	-616(ra) # 80001e98 <proc_pagetable>
    80005108:	8baa                	mv	s7,a0
    8000510a:	d945                	beqz	a0,800050ba <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000510c:	e7042983          	lw	s3,-400(s0)
    80005110:	e8845783          	lhu	a5,-376(s0)
    80005114:	c7ad                	beqz	a5,8000517e <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005116:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005118:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    8000511a:	6c85                	lui	s9,0x1
    8000511c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005120:	def43823          	sd	a5,-528(s0)
    80005124:	a42d                	j	8000534e <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005126:	00003517          	auipc	a0,0x3
    8000512a:	63a50513          	addi	a0,a0,1594 # 80008760 <syscalls+0x280>
    8000512e:	ffffb097          	auipc	ra,0xffffb
    80005132:	410080e7          	jalr	1040(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005136:	8756                	mv	a4,s5
    80005138:	012d86bb          	addw	a3,s11,s2
    8000513c:	4581                	li	a1,0
    8000513e:	8526                	mv	a0,s1
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	cac080e7          	jalr	-852(ra) # 80003dec <readi>
    80005148:	2501                	sext.w	a0,a0
    8000514a:	1aaa9963          	bne	s5,a0,800052fc <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    8000514e:	6785                	lui	a5,0x1
    80005150:	0127893b          	addw	s2,a5,s2
    80005154:	77fd                	lui	a5,0xfffff
    80005156:	01478a3b          	addw	s4,a5,s4
    8000515a:	1f897163          	bgeu	s2,s8,8000533c <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    8000515e:	02091593          	slli	a1,s2,0x20
    80005162:	9181                	srli	a1,a1,0x20
    80005164:	95ea                	add	a1,a1,s10
    80005166:	855e                	mv	a0,s7
    80005168:	ffffc097          	auipc	ra,0xffffc
    8000516c:	f06080e7          	jalr	-250(ra) # 8000106e <walkaddr>
    80005170:	862a                	mv	a2,a0
    if(pa == 0)
    80005172:	d955                	beqz	a0,80005126 <exec+0xf0>
      n = PGSIZE;
    80005174:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005176:	fd9a70e3          	bgeu	s4,s9,80005136 <exec+0x100>
      n = sz - i;
    8000517a:	8ad2                	mv	s5,s4
    8000517c:	bf6d                	j	80005136 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000517e:	4901                	li	s2,0
  iunlockput(ip);
    80005180:	8526                	mv	a0,s1
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	c18080e7          	jalr	-1000(ra) # 80003d9a <iunlockput>
  end_op();
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	400080e7          	jalr	1024(ra) # 8000458a <end_op>
  p = myproc();
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	c1e080e7          	jalr	-994(ra) # 80001db0 <myproc>
    8000519a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000519c:	07053d03          	ld	s10,112(a0)
  sz = PGROUNDUP(sz);
    800051a0:	6785                	lui	a5,0x1
    800051a2:	17fd                	addi	a5,a5,-1
    800051a4:	993e                	add	s2,s2,a5
    800051a6:	757d                	lui	a0,0xfffff
    800051a8:	00a977b3          	and	a5,s2,a0
    800051ac:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800051b0:	6609                	lui	a2,0x2
    800051b2:	963e                	add	a2,a2,a5
    800051b4:	85be                	mv	a1,a5
    800051b6:	855e                	mv	a0,s7
    800051b8:	ffffc097          	auipc	ra,0xffffc
    800051bc:	26a080e7          	jalr	618(ra) # 80001422 <uvmalloc>
    800051c0:	8b2a                	mv	s6,a0
  ip = 0;
    800051c2:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800051c4:	12050c63          	beqz	a0,800052fc <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051c8:	75f9                	lui	a1,0xffffe
    800051ca:	95aa                	add	a1,a1,a0
    800051cc:	855e                	mv	a0,s7
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	472080e7          	jalr	1138(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    800051d6:	7c7d                	lui	s8,0xfffff
    800051d8:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800051da:	e0043783          	ld	a5,-512(s0)
    800051de:	6388                	ld	a0,0(a5)
    800051e0:	c535                	beqz	a0,8000524c <exec+0x216>
    800051e2:	e9040993          	addi	s3,s0,-368
    800051e6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800051ea:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800051ec:	ffffc097          	auipc	ra,0xffffc
    800051f0:	c78080e7          	jalr	-904(ra) # 80000e64 <strlen>
    800051f4:	2505                	addiw	a0,a0,1
    800051f6:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051fa:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800051fe:	13896363          	bltu	s2,s8,80005324 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005202:	e0043d83          	ld	s11,-512(s0)
    80005206:	000dba03          	ld	s4,0(s11)
    8000520a:	8552                	mv	a0,s4
    8000520c:	ffffc097          	auipc	ra,0xffffc
    80005210:	c58080e7          	jalr	-936(ra) # 80000e64 <strlen>
    80005214:	0015069b          	addiw	a3,a0,1
    80005218:	8652                	mv	a2,s4
    8000521a:	85ca                	mv	a1,s2
    8000521c:	855e                	mv	a0,s7
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	454080e7          	jalr	1108(ra) # 80001672 <copyout>
    80005226:	10054363          	bltz	a0,8000532c <exec+0x2f6>
    ustack[argc] = sp;
    8000522a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000522e:	0485                	addi	s1,s1,1
    80005230:	008d8793          	addi	a5,s11,8
    80005234:	e0f43023          	sd	a5,-512(s0)
    80005238:	008db503          	ld	a0,8(s11)
    8000523c:	c911                	beqz	a0,80005250 <exec+0x21a>
    if(argc >= MAXARG)
    8000523e:	09a1                	addi	s3,s3,8
    80005240:	fb3c96e3          	bne	s9,s3,800051ec <exec+0x1b6>
  sz = sz1;
    80005244:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005248:	4481                	li	s1,0
    8000524a:	a84d                	j	800052fc <exec+0x2c6>
  sp = sz;
    8000524c:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000524e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005250:	00349793          	slli	a5,s1,0x3
    80005254:	f9040713          	addi	a4,s0,-112
    80005258:	97ba                	add	a5,a5,a4
    8000525a:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    8000525e:	00148693          	addi	a3,s1,1
    80005262:	068e                	slli	a3,a3,0x3
    80005264:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005268:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000526c:	01897663          	bgeu	s2,s8,80005278 <exec+0x242>
  sz = sz1;
    80005270:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005274:	4481                	li	s1,0
    80005276:	a059                	j	800052fc <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005278:	e9040613          	addi	a2,s0,-368
    8000527c:	85ca                	mv	a1,s2
    8000527e:	855e                	mv	a0,s7
    80005280:	ffffc097          	auipc	ra,0xffffc
    80005284:	3f2080e7          	jalr	1010(ra) # 80001672 <copyout>
    80005288:	0a054663          	bltz	a0,80005334 <exec+0x2fe>
  p->trapframe->a1 = sp;
    8000528c:	080ab783          	ld	a5,128(s5)
    80005290:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005294:	df843783          	ld	a5,-520(s0)
    80005298:	0007c703          	lbu	a4,0(a5)
    8000529c:	cf11                	beqz	a4,800052b8 <exec+0x282>
    8000529e:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052a0:	02f00693          	li	a3,47
    800052a4:	a039                	j	800052b2 <exec+0x27c>
      last = s+1;
    800052a6:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800052aa:	0785                	addi	a5,a5,1
    800052ac:	fff7c703          	lbu	a4,-1(a5)
    800052b0:	c701                	beqz	a4,800052b8 <exec+0x282>
    if(*s == '/')
    800052b2:	fed71ce3          	bne	a4,a3,800052aa <exec+0x274>
    800052b6:	bfc5                	j	800052a6 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800052b8:	4641                	li	a2,16
    800052ba:	df843583          	ld	a1,-520(s0)
    800052be:	180a8513          	addi	a0,s5,384
    800052c2:	ffffc097          	auipc	ra,0xffffc
    800052c6:	b70080e7          	jalr	-1168(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    800052ca:	078ab503          	ld	a0,120(s5)
  p->pagetable = pagetable;
    800052ce:	077abc23          	sd	s7,120(s5)
  p->sz = sz;
    800052d2:	076ab823          	sd	s6,112(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052d6:	080ab783          	ld	a5,128(s5)
    800052da:	e6843703          	ld	a4,-408(s0)
    800052de:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052e0:	080ab783          	ld	a5,128(s5)
    800052e4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052e8:	85ea                	mv	a1,s10
    800052ea:	ffffd097          	auipc	ra,0xffffd
    800052ee:	c4a080e7          	jalr	-950(ra) # 80001f34 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052f2:	0004851b          	sext.w	a0,s1
    800052f6:	bbe1                	j	800050ce <exec+0x98>
    800052f8:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800052fc:	e0843583          	ld	a1,-504(s0)
    80005300:	855e                	mv	a0,s7
    80005302:	ffffd097          	auipc	ra,0xffffd
    80005306:	c32080e7          	jalr	-974(ra) # 80001f34 <proc_freepagetable>
  if(ip){
    8000530a:	da0498e3          	bnez	s1,800050ba <exec+0x84>
  return -1;
    8000530e:	557d                	li	a0,-1
    80005310:	bb7d                	j	800050ce <exec+0x98>
    80005312:	e1243423          	sd	s2,-504(s0)
    80005316:	b7dd                	j	800052fc <exec+0x2c6>
    80005318:	e1243423          	sd	s2,-504(s0)
    8000531c:	b7c5                	j	800052fc <exec+0x2c6>
    8000531e:	e1243423          	sd	s2,-504(s0)
    80005322:	bfe9                	j	800052fc <exec+0x2c6>
  sz = sz1;
    80005324:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005328:	4481                	li	s1,0
    8000532a:	bfc9                	j	800052fc <exec+0x2c6>
  sz = sz1;
    8000532c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005330:	4481                	li	s1,0
    80005332:	b7e9                	j	800052fc <exec+0x2c6>
  sz = sz1;
    80005334:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005338:	4481                	li	s1,0
    8000533a:	b7c9                	j	800052fc <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000533c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005340:	2b05                	addiw	s6,s6,1
    80005342:	0389899b          	addiw	s3,s3,56
    80005346:	e8845783          	lhu	a5,-376(s0)
    8000534a:	e2fb5be3          	bge	s6,a5,80005180 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000534e:	2981                	sext.w	s3,s3
    80005350:	03800713          	li	a4,56
    80005354:	86ce                	mv	a3,s3
    80005356:	e1840613          	addi	a2,s0,-488
    8000535a:	4581                	li	a1,0
    8000535c:	8526                	mv	a0,s1
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	a8e080e7          	jalr	-1394(ra) # 80003dec <readi>
    80005366:	03800793          	li	a5,56
    8000536a:	f8f517e3          	bne	a0,a5,800052f8 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    8000536e:	e1842783          	lw	a5,-488(s0)
    80005372:	4705                	li	a4,1
    80005374:	fce796e3          	bne	a5,a4,80005340 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005378:	e4043603          	ld	a2,-448(s0)
    8000537c:	e3843783          	ld	a5,-456(s0)
    80005380:	f8f669e3          	bltu	a2,a5,80005312 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005384:	e2843783          	ld	a5,-472(s0)
    80005388:	963e                	add	a2,a2,a5
    8000538a:	f8f667e3          	bltu	a2,a5,80005318 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000538e:	85ca                	mv	a1,s2
    80005390:	855e                	mv	a0,s7
    80005392:	ffffc097          	auipc	ra,0xffffc
    80005396:	090080e7          	jalr	144(ra) # 80001422 <uvmalloc>
    8000539a:	e0a43423          	sd	a0,-504(s0)
    8000539e:	d141                	beqz	a0,8000531e <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    800053a0:	e2843d03          	ld	s10,-472(s0)
    800053a4:	df043783          	ld	a5,-528(s0)
    800053a8:	00fd77b3          	and	a5,s10,a5
    800053ac:	fba1                	bnez	a5,800052fc <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053ae:	e2042d83          	lw	s11,-480(s0)
    800053b2:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053b6:	f80c03e3          	beqz	s8,8000533c <exec+0x306>
    800053ba:	8a62                	mv	s4,s8
    800053bc:	4901                	li	s2,0
    800053be:	b345                	j	8000515e <exec+0x128>

00000000800053c0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053c0:	7179                	addi	sp,sp,-48
    800053c2:	f406                	sd	ra,40(sp)
    800053c4:	f022                	sd	s0,32(sp)
    800053c6:	ec26                	sd	s1,24(sp)
    800053c8:	e84a                	sd	s2,16(sp)
    800053ca:	1800                	addi	s0,sp,48
    800053cc:	892e                	mv	s2,a1
    800053ce:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800053d0:	fdc40593          	addi	a1,s0,-36
    800053d4:	ffffe097          	auipc	ra,0xffffe
    800053d8:	bf2080e7          	jalr	-1038(ra) # 80002fc6 <argint>
    800053dc:	04054063          	bltz	a0,8000541c <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053e0:	fdc42703          	lw	a4,-36(s0)
    800053e4:	47bd                	li	a5,15
    800053e6:	02e7ed63          	bltu	a5,a4,80005420 <argfd+0x60>
    800053ea:	ffffd097          	auipc	ra,0xffffd
    800053ee:	9c6080e7          	jalr	-1594(ra) # 80001db0 <myproc>
    800053f2:	fdc42703          	lw	a4,-36(s0)
    800053f6:	01e70793          	addi	a5,a4,30
    800053fa:	078e                	slli	a5,a5,0x3
    800053fc:	953e                	add	a0,a0,a5
    800053fe:	651c                	ld	a5,8(a0)
    80005400:	c395                	beqz	a5,80005424 <argfd+0x64>
    return -1;
  if(pfd)
    80005402:	00090463          	beqz	s2,8000540a <argfd+0x4a>
    *pfd = fd;
    80005406:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000540a:	4501                	li	a0,0
  if(pf)
    8000540c:	c091                	beqz	s1,80005410 <argfd+0x50>
    *pf = f;
    8000540e:	e09c                	sd	a5,0(s1)
}
    80005410:	70a2                	ld	ra,40(sp)
    80005412:	7402                	ld	s0,32(sp)
    80005414:	64e2                	ld	s1,24(sp)
    80005416:	6942                	ld	s2,16(sp)
    80005418:	6145                	addi	sp,sp,48
    8000541a:	8082                	ret
    return -1;
    8000541c:	557d                	li	a0,-1
    8000541e:	bfcd                	j	80005410 <argfd+0x50>
    return -1;
    80005420:	557d                	li	a0,-1
    80005422:	b7fd                	j	80005410 <argfd+0x50>
    80005424:	557d                	li	a0,-1
    80005426:	b7ed                	j	80005410 <argfd+0x50>

0000000080005428 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005428:	1101                	addi	sp,sp,-32
    8000542a:	ec06                	sd	ra,24(sp)
    8000542c:	e822                	sd	s0,16(sp)
    8000542e:	e426                	sd	s1,8(sp)
    80005430:	1000                	addi	s0,sp,32
    80005432:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005434:	ffffd097          	auipc	ra,0xffffd
    80005438:	97c080e7          	jalr	-1668(ra) # 80001db0 <myproc>
    8000543c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000543e:	0f850793          	addi	a5,a0,248 # fffffffffffff0f8 <end+0xffffffff7ffd90f8>
    80005442:	4501                	li	a0,0
    80005444:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005446:	6398                	ld	a4,0(a5)
    80005448:	cb19                	beqz	a4,8000545e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000544a:	2505                	addiw	a0,a0,1
    8000544c:	07a1                	addi	a5,a5,8
    8000544e:	fed51ce3          	bne	a0,a3,80005446 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005452:	557d                	li	a0,-1
}
    80005454:	60e2                	ld	ra,24(sp)
    80005456:	6442                	ld	s0,16(sp)
    80005458:	64a2                	ld	s1,8(sp)
    8000545a:	6105                	addi	sp,sp,32
    8000545c:	8082                	ret
      p->ofile[fd] = f;
    8000545e:	01e50793          	addi	a5,a0,30
    80005462:	078e                	slli	a5,a5,0x3
    80005464:	963e                	add	a2,a2,a5
    80005466:	e604                	sd	s1,8(a2)
      return fd;
    80005468:	b7f5                	j	80005454 <fdalloc+0x2c>

000000008000546a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000546a:	715d                	addi	sp,sp,-80
    8000546c:	e486                	sd	ra,72(sp)
    8000546e:	e0a2                	sd	s0,64(sp)
    80005470:	fc26                	sd	s1,56(sp)
    80005472:	f84a                	sd	s2,48(sp)
    80005474:	f44e                	sd	s3,40(sp)
    80005476:	f052                	sd	s4,32(sp)
    80005478:	ec56                	sd	s5,24(sp)
    8000547a:	0880                	addi	s0,sp,80
    8000547c:	89ae                	mv	s3,a1
    8000547e:	8ab2                	mv	s5,a2
    80005480:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005482:	fb040593          	addi	a1,s0,-80
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	e86080e7          	jalr	-378(ra) # 8000430c <nameiparent>
    8000548e:	892a                	mv	s2,a0
    80005490:	12050f63          	beqz	a0,800055ce <create+0x164>
    return 0;

  ilock(dp);
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	6a4080e7          	jalr	1700(ra) # 80003b38 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000549c:	4601                	li	a2,0
    8000549e:	fb040593          	addi	a1,s0,-80
    800054a2:	854a                	mv	a0,s2
    800054a4:	fffff097          	auipc	ra,0xfffff
    800054a8:	b78080e7          	jalr	-1160(ra) # 8000401c <dirlookup>
    800054ac:	84aa                	mv	s1,a0
    800054ae:	c921                	beqz	a0,800054fe <create+0x94>
    iunlockput(dp);
    800054b0:	854a                	mv	a0,s2
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	8e8080e7          	jalr	-1816(ra) # 80003d9a <iunlockput>
    ilock(ip);
    800054ba:	8526                	mv	a0,s1
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	67c080e7          	jalr	1660(ra) # 80003b38 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054c4:	2981                	sext.w	s3,s3
    800054c6:	4789                	li	a5,2
    800054c8:	02f99463          	bne	s3,a5,800054f0 <create+0x86>
    800054cc:	0444d783          	lhu	a5,68(s1)
    800054d0:	37f9                	addiw	a5,a5,-2
    800054d2:	17c2                	slli	a5,a5,0x30
    800054d4:	93c1                	srli	a5,a5,0x30
    800054d6:	4705                	li	a4,1
    800054d8:	00f76c63          	bltu	a4,a5,800054f0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800054dc:	8526                	mv	a0,s1
    800054de:	60a6                	ld	ra,72(sp)
    800054e0:	6406                	ld	s0,64(sp)
    800054e2:	74e2                	ld	s1,56(sp)
    800054e4:	7942                	ld	s2,48(sp)
    800054e6:	79a2                	ld	s3,40(sp)
    800054e8:	7a02                	ld	s4,32(sp)
    800054ea:	6ae2                	ld	s5,24(sp)
    800054ec:	6161                	addi	sp,sp,80
    800054ee:	8082                	ret
    iunlockput(ip);
    800054f0:	8526                	mv	a0,s1
    800054f2:	fffff097          	auipc	ra,0xfffff
    800054f6:	8a8080e7          	jalr	-1880(ra) # 80003d9a <iunlockput>
    return 0;
    800054fa:	4481                	li	s1,0
    800054fc:	b7c5                	j	800054dc <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800054fe:	85ce                	mv	a1,s3
    80005500:	00092503          	lw	a0,0(s2)
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	49c080e7          	jalr	1180(ra) # 800039a0 <ialloc>
    8000550c:	84aa                	mv	s1,a0
    8000550e:	c529                	beqz	a0,80005558 <create+0xee>
  ilock(ip);
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	628080e7          	jalr	1576(ra) # 80003b38 <ilock>
  ip->major = major;
    80005518:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000551c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005520:	4785                	li	a5,1
    80005522:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005526:	8526                	mv	a0,s1
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	546080e7          	jalr	1350(ra) # 80003a6e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005530:	2981                	sext.w	s3,s3
    80005532:	4785                	li	a5,1
    80005534:	02f98a63          	beq	s3,a5,80005568 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005538:	40d0                	lw	a2,4(s1)
    8000553a:	fb040593          	addi	a1,s0,-80
    8000553e:	854a                	mv	a0,s2
    80005540:	fffff097          	auipc	ra,0xfffff
    80005544:	cec080e7          	jalr	-788(ra) # 8000422c <dirlink>
    80005548:	06054b63          	bltz	a0,800055be <create+0x154>
  iunlockput(dp);
    8000554c:	854a                	mv	a0,s2
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	84c080e7          	jalr	-1972(ra) # 80003d9a <iunlockput>
  return ip;
    80005556:	b759                	j	800054dc <create+0x72>
    panic("create: ialloc");
    80005558:	00003517          	auipc	a0,0x3
    8000555c:	22850513          	addi	a0,a0,552 # 80008780 <syscalls+0x2a0>
    80005560:	ffffb097          	auipc	ra,0xffffb
    80005564:	fde080e7          	jalr	-34(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    80005568:	04a95783          	lhu	a5,74(s2)
    8000556c:	2785                	addiw	a5,a5,1
    8000556e:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005572:	854a                	mv	a0,s2
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	4fa080e7          	jalr	1274(ra) # 80003a6e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000557c:	40d0                	lw	a2,4(s1)
    8000557e:	00003597          	auipc	a1,0x3
    80005582:	21258593          	addi	a1,a1,530 # 80008790 <syscalls+0x2b0>
    80005586:	8526                	mv	a0,s1
    80005588:	fffff097          	auipc	ra,0xfffff
    8000558c:	ca4080e7          	jalr	-860(ra) # 8000422c <dirlink>
    80005590:	00054f63          	bltz	a0,800055ae <create+0x144>
    80005594:	00492603          	lw	a2,4(s2)
    80005598:	00003597          	auipc	a1,0x3
    8000559c:	20058593          	addi	a1,a1,512 # 80008798 <syscalls+0x2b8>
    800055a0:	8526                	mv	a0,s1
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	c8a080e7          	jalr	-886(ra) # 8000422c <dirlink>
    800055aa:	f80557e3          	bgez	a0,80005538 <create+0xce>
      panic("create dots");
    800055ae:	00003517          	auipc	a0,0x3
    800055b2:	1f250513          	addi	a0,a0,498 # 800087a0 <syscalls+0x2c0>
    800055b6:	ffffb097          	auipc	ra,0xffffb
    800055ba:	f88080e7          	jalr	-120(ra) # 8000053e <panic>
    panic("create: dirlink");
    800055be:	00003517          	auipc	a0,0x3
    800055c2:	1f250513          	addi	a0,a0,498 # 800087b0 <syscalls+0x2d0>
    800055c6:	ffffb097          	auipc	ra,0xffffb
    800055ca:	f78080e7          	jalr	-136(ra) # 8000053e <panic>
    return 0;
    800055ce:	84aa                	mv	s1,a0
    800055d0:	b731                	j	800054dc <create+0x72>

00000000800055d2 <sys_dup>:
{
    800055d2:	7179                	addi	sp,sp,-48
    800055d4:	f406                	sd	ra,40(sp)
    800055d6:	f022                	sd	s0,32(sp)
    800055d8:	ec26                	sd	s1,24(sp)
    800055da:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055dc:	fd840613          	addi	a2,s0,-40
    800055e0:	4581                	li	a1,0
    800055e2:	4501                	li	a0,0
    800055e4:	00000097          	auipc	ra,0x0
    800055e8:	ddc080e7          	jalr	-548(ra) # 800053c0 <argfd>
    return -1;
    800055ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055ee:	02054363          	bltz	a0,80005614 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055f2:	fd843503          	ld	a0,-40(s0)
    800055f6:	00000097          	auipc	ra,0x0
    800055fa:	e32080e7          	jalr	-462(ra) # 80005428 <fdalloc>
    800055fe:	84aa                	mv	s1,a0
    return -1;
    80005600:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005602:	00054963          	bltz	a0,80005614 <sys_dup+0x42>
  filedup(f);
    80005606:	fd843503          	ld	a0,-40(s0)
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	37a080e7          	jalr	890(ra) # 80004984 <filedup>
  return fd;
    80005612:	87a6                	mv	a5,s1
}
    80005614:	853e                	mv	a0,a5
    80005616:	70a2                	ld	ra,40(sp)
    80005618:	7402                	ld	s0,32(sp)
    8000561a:	64e2                	ld	s1,24(sp)
    8000561c:	6145                	addi	sp,sp,48
    8000561e:	8082                	ret

0000000080005620 <sys_read>:
{
    80005620:	7179                	addi	sp,sp,-48
    80005622:	f406                	sd	ra,40(sp)
    80005624:	f022                	sd	s0,32(sp)
    80005626:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005628:	fe840613          	addi	a2,s0,-24
    8000562c:	4581                	li	a1,0
    8000562e:	4501                	li	a0,0
    80005630:	00000097          	auipc	ra,0x0
    80005634:	d90080e7          	jalr	-624(ra) # 800053c0 <argfd>
    return -1;
    80005638:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000563a:	04054163          	bltz	a0,8000567c <sys_read+0x5c>
    8000563e:	fe440593          	addi	a1,s0,-28
    80005642:	4509                	li	a0,2
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	982080e7          	jalr	-1662(ra) # 80002fc6 <argint>
    return -1;
    8000564c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000564e:	02054763          	bltz	a0,8000567c <sys_read+0x5c>
    80005652:	fd840593          	addi	a1,s0,-40
    80005656:	4505                	li	a0,1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	990080e7          	jalr	-1648(ra) # 80002fe8 <argaddr>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005662:	00054d63          	bltz	a0,8000567c <sys_read+0x5c>
  return fileread(f, p, n);
    80005666:	fe442603          	lw	a2,-28(s0)
    8000566a:	fd843583          	ld	a1,-40(s0)
    8000566e:	fe843503          	ld	a0,-24(s0)
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	49e080e7          	jalr	1182(ra) # 80004b10 <fileread>
    8000567a:	87aa                	mv	a5,a0
}
    8000567c:	853e                	mv	a0,a5
    8000567e:	70a2                	ld	ra,40(sp)
    80005680:	7402                	ld	s0,32(sp)
    80005682:	6145                	addi	sp,sp,48
    80005684:	8082                	ret

0000000080005686 <sys_write>:
{
    80005686:	7179                	addi	sp,sp,-48
    80005688:	f406                	sd	ra,40(sp)
    8000568a:	f022                	sd	s0,32(sp)
    8000568c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000568e:	fe840613          	addi	a2,s0,-24
    80005692:	4581                	li	a1,0
    80005694:	4501                	li	a0,0
    80005696:	00000097          	auipc	ra,0x0
    8000569a:	d2a080e7          	jalr	-726(ra) # 800053c0 <argfd>
    return -1;
    8000569e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056a0:	04054163          	bltz	a0,800056e2 <sys_write+0x5c>
    800056a4:	fe440593          	addi	a1,s0,-28
    800056a8:	4509                	li	a0,2
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	91c080e7          	jalr	-1764(ra) # 80002fc6 <argint>
    return -1;
    800056b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056b4:	02054763          	bltz	a0,800056e2 <sys_write+0x5c>
    800056b8:	fd840593          	addi	a1,s0,-40
    800056bc:	4505                	li	a0,1
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	92a080e7          	jalr	-1750(ra) # 80002fe8 <argaddr>
    return -1;
    800056c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056c8:	00054d63          	bltz	a0,800056e2 <sys_write+0x5c>
  return filewrite(f, p, n);
    800056cc:	fe442603          	lw	a2,-28(s0)
    800056d0:	fd843583          	ld	a1,-40(s0)
    800056d4:	fe843503          	ld	a0,-24(s0)
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	4fa080e7          	jalr	1274(ra) # 80004bd2 <filewrite>
    800056e0:	87aa                	mv	a5,a0
}
    800056e2:	853e                	mv	a0,a5
    800056e4:	70a2                	ld	ra,40(sp)
    800056e6:	7402                	ld	s0,32(sp)
    800056e8:	6145                	addi	sp,sp,48
    800056ea:	8082                	ret

00000000800056ec <sys_close>:
{
    800056ec:	1101                	addi	sp,sp,-32
    800056ee:	ec06                	sd	ra,24(sp)
    800056f0:	e822                	sd	s0,16(sp)
    800056f2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056f4:	fe040613          	addi	a2,s0,-32
    800056f8:	fec40593          	addi	a1,s0,-20
    800056fc:	4501                	li	a0,0
    800056fe:	00000097          	auipc	ra,0x0
    80005702:	cc2080e7          	jalr	-830(ra) # 800053c0 <argfd>
    return -1;
    80005706:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005708:	02054463          	bltz	a0,80005730 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000570c:	ffffc097          	auipc	ra,0xffffc
    80005710:	6a4080e7          	jalr	1700(ra) # 80001db0 <myproc>
    80005714:	fec42783          	lw	a5,-20(s0)
    80005718:	07f9                	addi	a5,a5,30
    8000571a:	078e                	slli	a5,a5,0x3
    8000571c:	97aa                	add	a5,a5,a0
    8000571e:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005722:	fe043503          	ld	a0,-32(s0)
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	2b0080e7          	jalr	688(ra) # 800049d6 <fileclose>
  return 0;
    8000572e:	4781                	li	a5,0
}
    80005730:	853e                	mv	a0,a5
    80005732:	60e2                	ld	ra,24(sp)
    80005734:	6442                	ld	s0,16(sp)
    80005736:	6105                	addi	sp,sp,32
    80005738:	8082                	ret

000000008000573a <sys_fstat>:
{
    8000573a:	1101                	addi	sp,sp,-32
    8000573c:	ec06                	sd	ra,24(sp)
    8000573e:	e822                	sd	s0,16(sp)
    80005740:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005742:	fe840613          	addi	a2,s0,-24
    80005746:	4581                	li	a1,0
    80005748:	4501                	li	a0,0
    8000574a:	00000097          	auipc	ra,0x0
    8000574e:	c76080e7          	jalr	-906(ra) # 800053c0 <argfd>
    return -1;
    80005752:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005754:	02054563          	bltz	a0,8000577e <sys_fstat+0x44>
    80005758:	fe040593          	addi	a1,s0,-32
    8000575c:	4505                	li	a0,1
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	88a080e7          	jalr	-1910(ra) # 80002fe8 <argaddr>
    return -1;
    80005766:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005768:	00054b63          	bltz	a0,8000577e <sys_fstat+0x44>
  return filestat(f, st);
    8000576c:	fe043583          	ld	a1,-32(s0)
    80005770:	fe843503          	ld	a0,-24(s0)
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	32a080e7          	jalr	810(ra) # 80004a9e <filestat>
    8000577c:	87aa                	mv	a5,a0
}
    8000577e:	853e                	mv	a0,a5
    80005780:	60e2                	ld	ra,24(sp)
    80005782:	6442                	ld	s0,16(sp)
    80005784:	6105                	addi	sp,sp,32
    80005786:	8082                	ret

0000000080005788 <sys_link>:
{
    80005788:	7169                	addi	sp,sp,-304
    8000578a:	f606                	sd	ra,296(sp)
    8000578c:	f222                	sd	s0,288(sp)
    8000578e:	ee26                	sd	s1,280(sp)
    80005790:	ea4a                	sd	s2,272(sp)
    80005792:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005794:	08000613          	li	a2,128
    80005798:	ed040593          	addi	a1,s0,-304
    8000579c:	4501                	li	a0,0
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	86c080e7          	jalr	-1940(ra) # 8000300a <argstr>
    return -1;
    800057a6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057a8:	10054e63          	bltz	a0,800058c4 <sys_link+0x13c>
    800057ac:	08000613          	li	a2,128
    800057b0:	f5040593          	addi	a1,s0,-176
    800057b4:	4505                	li	a0,1
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	854080e7          	jalr	-1964(ra) # 8000300a <argstr>
    return -1;
    800057be:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057c0:	10054263          	bltz	a0,800058c4 <sys_link+0x13c>
  begin_op();
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	d46080e7          	jalr	-698(ra) # 8000450a <begin_op>
  if((ip = namei(old)) == 0){
    800057cc:	ed040513          	addi	a0,s0,-304
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	b1e080e7          	jalr	-1250(ra) # 800042ee <namei>
    800057d8:	84aa                	mv	s1,a0
    800057da:	c551                	beqz	a0,80005866 <sys_link+0xde>
  ilock(ip);
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	35c080e7          	jalr	860(ra) # 80003b38 <ilock>
  if(ip->type == T_DIR){
    800057e4:	04449703          	lh	a4,68(s1)
    800057e8:	4785                	li	a5,1
    800057ea:	08f70463          	beq	a4,a5,80005872 <sys_link+0xea>
  ip->nlink++;
    800057ee:	04a4d783          	lhu	a5,74(s1)
    800057f2:	2785                	addiw	a5,a5,1
    800057f4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057f8:	8526                	mv	a0,s1
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	274080e7          	jalr	628(ra) # 80003a6e <iupdate>
  iunlock(ip);
    80005802:	8526                	mv	a0,s1
    80005804:	ffffe097          	auipc	ra,0xffffe
    80005808:	3f6080e7          	jalr	1014(ra) # 80003bfa <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000580c:	fd040593          	addi	a1,s0,-48
    80005810:	f5040513          	addi	a0,s0,-176
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	af8080e7          	jalr	-1288(ra) # 8000430c <nameiparent>
    8000581c:	892a                	mv	s2,a0
    8000581e:	c935                	beqz	a0,80005892 <sys_link+0x10a>
  ilock(dp);
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	318080e7          	jalr	792(ra) # 80003b38 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005828:	00092703          	lw	a4,0(s2)
    8000582c:	409c                	lw	a5,0(s1)
    8000582e:	04f71d63          	bne	a4,a5,80005888 <sys_link+0x100>
    80005832:	40d0                	lw	a2,4(s1)
    80005834:	fd040593          	addi	a1,s0,-48
    80005838:	854a                	mv	a0,s2
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	9f2080e7          	jalr	-1550(ra) # 8000422c <dirlink>
    80005842:	04054363          	bltz	a0,80005888 <sys_link+0x100>
  iunlockput(dp);
    80005846:	854a                	mv	a0,s2
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	552080e7          	jalr	1362(ra) # 80003d9a <iunlockput>
  iput(ip);
    80005850:	8526                	mv	a0,s1
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	4a0080e7          	jalr	1184(ra) # 80003cf2 <iput>
  end_op();
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	d30080e7          	jalr	-720(ra) # 8000458a <end_op>
  return 0;
    80005862:	4781                	li	a5,0
    80005864:	a085                	j	800058c4 <sys_link+0x13c>
    end_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	d24080e7          	jalr	-732(ra) # 8000458a <end_op>
    return -1;
    8000586e:	57fd                	li	a5,-1
    80005870:	a891                	j	800058c4 <sys_link+0x13c>
    iunlockput(ip);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	526080e7          	jalr	1318(ra) # 80003d9a <iunlockput>
    end_op();
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	d0e080e7          	jalr	-754(ra) # 8000458a <end_op>
    return -1;
    80005884:	57fd                	li	a5,-1
    80005886:	a83d                	j	800058c4 <sys_link+0x13c>
    iunlockput(dp);
    80005888:	854a                	mv	a0,s2
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	510080e7          	jalr	1296(ra) # 80003d9a <iunlockput>
  ilock(ip);
    80005892:	8526                	mv	a0,s1
    80005894:	ffffe097          	auipc	ra,0xffffe
    80005898:	2a4080e7          	jalr	676(ra) # 80003b38 <ilock>
  ip->nlink--;
    8000589c:	04a4d783          	lhu	a5,74(s1)
    800058a0:	37fd                	addiw	a5,a5,-1
    800058a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	1c6080e7          	jalr	454(ra) # 80003a6e <iupdate>
  iunlockput(ip);
    800058b0:	8526                	mv	a0,s1
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	4e8080e7          	jalr	1256(ra) # 80003d9a <iunlockput>
  end_op();
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	cd0080e7          	jalr	-816(ra) # 8000458a <end_op>
  return -1;
    800058c2:	57fd                	li	a5,-1
}
    800058c4:	853e                	mv	a0,a5
    800058c6:	70b2                	ld	ra,296(sp)
    800058c8:	7412                	ld	s0,288(sp)
    800058ca:	64f2                	ld	s1,280(sp)
    800058cc:	6952                	ld	s2,272(sp)
    800058ce:	6155                	addi	sp,sp,304
    800058d0:	8082                	ret

00000000800058d2 <sys_unlink>:
{
    800058d2:	7151                	addi	sp,sp,-240
    800058d4:	f586                	sd	ra,232(sp)
    800058d6:	f1a2                	sd	s0,224(sp)
    800058d8:	eda6                	sd	s1,216(sp)
    800058da:	e9ca                	sd	s2,208(sp)
    800058dc:	e5ce                	sd	s3,200(sp)
    800058de:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058e0:	08000613          	li	a2,128
    800058e4:	f3040593          	addi	a1,s0,-208
    800058e8:	4501                	li	a0,0
    800058ea:	ffffd097          	auipc	ra,0xffffd
    800058ee:	720080e7          	jalr	1824(ra) # 8000300a <argstr>
    800058f2:	18054163          	bltz	a0,80005a74 <sys_unlink+0x1a2>
  begin_op();
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	c14080e7          	jalr	-1004(ra) # 8000450a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058fe:	fb040593          	addi	a1,s0,-80
    80005902:	f3040513          	addi	a0,s0,-208
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	a06080e7          	jalr	-1530(ra) # 8000430c <nameiparent>
    8000590e:	84aa                	mv	s1,a0
    80005910:	c979                	beqz	a0,800059e6 <sys_unlink+0x114>
  ilock(dp);
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	226080e7          	jalr	550(ra) # 80003b38 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000591a:	00003597          	auipc	a1,0x3
    8000591e:	e7658593          	addi	a1,a1,-394 # 80008790 <syscalls+0x2b0>
    80005922:	fb040513          	addi	a0,s0,-80
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	6dc080e7          	jalr	1756(ra) # 80004002 <namecmp>
    8000592e:	14050a63          	beqz	a0,80005a82 <sys_unlink+0x1b0>
    80005932:	00003597          	auipc	a1,0x3
    80005936:	e6658593          	addi	a1,a1,-410 # 80008798 <syscalls+0x2b8>
    8000593a:	fb040513          	addi	a0,s0,-80
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	6c4080e7          	jalr	1732(ra) # 80004002 <namecmp>
    80005946:	12050e63          	beqz	a0,80005a82 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000594a:	f2c40613          	addi	a2,s0,-212
    8000594e:	fb040593          	addi	a1,s0,-80
    80005952:	8526                	mv	a0,s1
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	6c8080e7          	jalr	1736(ra) # 8000401c <dirlookup>
    8000595c:	892a                	mv	s2,a0
    8000595e:	12050263          	beqz	a0,80005a82 <sys_unlink+0x1b0>
  ilock(ip);
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	1d6080e7          	jalr	470(ra) # 80003b38 <ilock>
  if(ip->nlink < 1)
    8000596a:	04a91783          	lh	a5,74(s2)
    8000596e:	08f05263          	blez	a5,800059f2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005972:	04491703          	lh	a4,68(s2)
    80005976:	4785                	li	a5,1
    80005978:	08f70563          	beq	a4,a5,80005a02 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000597c:	4641                	li	a2,16
    8000597e:	4581                	li	a1,0
    80005980:	fc040513          	addi	a0,s0,-64
    80005984:	ffffb097          	auipc	ra,0xffffb
    80005988:	35c080e7          	jalr	860(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000598c:	4741                	li	a4,16
    8000598e:	f2c42683          	lw	a3,-212(s0)
    80005992:	fc040613          	addi	a2,s0,-64
    80005996:	4581                	li	a1,0
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	54a080e7          	jalr	1354(ra) # 80003ee4 <writei>
    800059a2:	47c1                	li	a5,16
    800059a4:	0af51563          	bne	a0,a5,80005a4e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059a8:	04491703          	lh	a4,68(s2)
    800059ac:	4785                	li	a5,1
    800059ae:	0af70863          	beq	a4,a5,80005a5e <sys_unlink+0x18c>
  iunlockput(dp);
    800059b2:	8526                	mv	a0,s1
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	3e6080e7          	jalr	998(ra) # 80003d9a <iunlockput>
  ip->nlink--;
    800059bc:	04a95783          	lhu	a5,74(s2)
    800059c0:	37fd                	addiw	a5,a5,-1
    800059c2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059c6:	854a                	mv	a0,s2
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	0a6080e7          	jalr	166(ra) # 80003a6e <iupdate>
  iunlockput(ip);
    800059d0:	854a                	mv	a0,s2
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	3c8080e7          	jalr	968(ra) # 80003d9a <iunlockput>
  end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	bb0080e7          	jalr	-1104(ra) # 8000458a <end_op>
  return 0;
    800059e2:	4501                	li	a0,0
    800059e4:	a84d                	j	80005a96 <sys_unlink+0x1c4>
    end_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	ba4080e7          	jalr	-1116(ra) # 8000458a <end_op>
    return -1;
    800059ee:	557d                	li	a0,-1
    800059f0:	a05d                	j	80005a96 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800059f2:	00003517          	auipc	a0,0x3
    800059f6:	dce50513          	addi	a0,a0,-562 # 800087c0 <syscalls+0x2e0>
    800059fa:	ffffb097          	auipc	ra,0xffffb
    800059fe:	b44080e7          	jalr	-1212(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a02:	04c92703          	lw	a4,76(s2)
    80005a06:	02000793          	li	a5,32
    80005a0a:	f6e7f9e3          	bgeu	a5,a4,8000597c <sys_unlink+0xaa>
    80005a0e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a12:	4741                	li	a4,16
    80005a14:	86ce                	mv	a3,s3
    80005a16:	f1840613          	addi	a2,s0,-232
    80005a1a:	4581                	li	a1,0
    80005a1c:	854a                	mv	a0,s2
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	3ce080e7          	jalr	974(ra) # 80003dec <readi>
    80005a26:	47c1                	li	a5,16
    80005a28:	00f51b63          	bne	a0,a5,80005a3e <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a2c:	f1845783          	lhu	a5,-232(s0)
    80005a30:	e7a1                	bnez	a5,80005a78 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a32:	29c1                	addiw	s3,s3,16
    80005a34:	04c92783          	lw	a5,76(s2)
    80005a38:	fcf9ede3          	bltu	s3,a5,80005a12 <sys_unlink+0x140>
    80005a3c:	b781                	j	8000597c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a3e:	00003517          	auipc	a0,0x3
    80005a42:	d9a50513          	addi	a0,a0,-614 # 800087d8 <syscalls+0x2f8>
    80005a46:	ffffb097          	auipc	ra,0xffffb
    80005a4a:	af8080e7          	jalr	-1288(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005a4e:	00003517          	auipc	a0,0x3
    80005a52:	da250513          	addi	a0,a0,-606 # 800087f0 <syscalls+0x310>
    80005a56:	ffffb097          	auipc	ra,0xffffb
    80005a5a:	ae8080e7          	jalr	-1304(ra) # 8000053e <panic>
    dp->nlink--;
    80005a5e:	04a4d783          	lhu	a5,74(s1)
    80005a62:	37fd                	addiw	a5,a5,-1
    80005a64:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a68:	8526                	mv	a0,s1
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	004080e7          	jalr	4(ra) # 80003a6e <iupdate>
    80005a72:	b781                	j	800059b2 <sys_unlink+0xe0>
    return -1;
    80005a74:	557d                	li	a0,-1
    80005a76:	a005                	j	80005a96 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a78:	854a                	mv	a0,s2
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	320080e7          	jalr	800(ra) # 80003d9a <iunlockput>
  iunlockput(dp);
    80005a82:	8526                	mv	a0,s1
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	316080e7          	jalr	790(ra) # 80003d9a <iunlockput>
  end_op();
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	afe080e7          	jalr	-1282(ra) # 8000458a <end_op>
  return -1;
    80005a94:	557d                	li	a0,-1
}
    80005a96:	70ae                	ld	ra,232(sp)
    80005a98:	740e                	ld	s0,224(sp)
    80005a9a:	64ee                	ld	s1,216(sp)
    80005a9c:	694e                	ld	s2,208(sp)
    80005a9e:	69ae                	ld	s3,200(sp)
    80005aa0:	616d                	addi	sp,sp,240
    80005aa2:	8082                	ret

0000000080005aa4 <sys_open>:

uint64
sys_open(void)
{
    80005aa4:	7131                	addi	sp,sp,-192
    80005aa6:	fd06                	sd	ra,184(sp)
    80005aa8:	f922                	sd	s0,176(sp)
    80005aaa:	f526                	sd	s1,168(sp)
    80005aac:	f14a                	sd	s2,160(sp)
    80005aae:	ed4e                	sd	s3,152(sp)
    80005ab0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ab2:	08000613          	li	a2,128
    80005ab6:	f5040593          	addi	a1,s0,-176
    80005aba:	4501                	li	a0,0
    80005abc:	ffffd097          	auipc	ra,0xffffd
    80005ac0:	54e080e7          	jalr	1358(ra) # 8000300a <argstr>
    return -1;
    80005ac4:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ac6:	0c054163          	bltz	a0,80005b88 <sys_open+0xe4>
    80005aca:	f4c40593          	addi	a1,s0,-180
    80005ace:	4505                	li	a0,1
    80005ad0:	ffffd097          	auipc	ra,0xffffd
    80005ad4:	4f6080e7          	jalr	1270(ra) # 80002fc6 <argint>
    80005ad8:	0a054863          	bltz	a0,80005b88 <sys_open+0xe4>

  begin_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	a2e080e7          	jalr	-1490(ra) # 8000450a <begin_op>

  if(omode & O_CREATE){
    80005ae4:	f4c42783          	lw	a5,-180(s0)
    80005ae8:	2007f793          	andi	a5,a5,512
    80005aec:	cbdd                	beqz	a5,80005ba2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005aee:	4681                	li	a3,0
    80005af0:	4601                	li	a2,0
    80005af2:	4589                	li	a1,2
    80005af4:	f5040513          	addi	a0,s0,-176
    80005af8:	00000097          	auipc	ra,0x0
    80005afc:	972080e7          	jalr	-1678(ra) # 8000546a <create>
    80005b00:	892a                	mv	s2,a0
    if(ip == 0){
    80005b02:	c959                	beqz	a0,80005b98 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b04:	04491703          	lh	a4,68(s2)
    80005b08:	478d                	li	a5,3
    80005b0a:	00f71763          	bne	a4,a5,80005b18 <sys_open+0x74>
    80005b0e:	04695703          	lhu	a4,70(s2)
    80005b12:	47a5                	li	a5,9
    80005b14:	0ce7ec63          	bltu	a5,a4,80005bec <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	e02080e7          	jalr	-510(ra) # 8000491a <filealloc>
    80005b20:	89aa                	mv	s3,a0
    80005b22:	10050263          	beqz	a0,80005c26 <sys_open+0x182>
    80005b26:	00000097          	auipc	ra,0x0
    80005b2a:	902080e7          	jalr	-1790(ra) # 80005428 <fdalloc>
    80005b2e:	84aa                	mv	s1,a0
    80005b30:	0e054663          	bltz	a0,80005c1c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b34:	04491703          	lh	a4,68(s2)
    80005b38:	478d                	li	a5,3
    80005b3a:	0cf70463          	beq	a4,a5,80005c02 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b3e:	4789                	li	a5,2
    80005b40:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b44:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b48:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b4c:	f4c42783          	lw	a5,-180(s0)
    80005b50:	0017c713          	xori	a4,a5,1
    80005b54:	8b05                	andi	a4,a4,1
    80005b56:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b5a:	0037f713          	andi	a4,a5,3
    80005b5e:	00e03733          	snez	a4,a4
    80005b62:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b66:	4007f793          	andi	a5,a5,1024
    80005b6a:	c791                	beqz	a5,80005b76 <sys_open+0xd2>
    80005b6c:	04491703          	lh	a4,68(s2)
    80005b70:	4789                	li	a5,2
    80005b72:	08f70f63          	beq	a4,a5,80005c10 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b76:	854a                	mv	a0,s2
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	082080e7          	jalr	130(ra) # 80003bfa <iunlock>
  end_op();
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	a0a080e7          	jalr	-1526(ra) # 8000458a <end_op>

  return fd;
}
    80005b88:	8526                	mv	a0,s1
    80005b8a:	70ea                	ld	ra,184(sp)
    80005b8c:	744a                	ld	s0,176(sp)
    80005b8e:	74aa                	ld	s1,168(sp)
    80005b90:	790a                	ld	s2,160(sp)
    80005b92:	69ea                	ld	s3,152(sp)
    80005b94:	6129                	addi	sp,sp,192
    80005b96:	8082                	ret
      end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	9f2080e7          	jalr	-1550(ra) # 8000458a <end_op>
      return -1;
    80005ba0:	b7e5                	j	80005b88 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ba2:	f5040513          	addi	a0,s0,-176
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	748080e7          	jalr	1864(ra) # 800042ee <namei>
    80005bae:	892a                	mv	s2,a0
    80005bb0:	c905                	beqz	a0,80005be0 <sys_open+0x13c>
    ilock(ip);
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	f86080e7          	jalr	-122(ra) # 80003b38 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bba:	04491703          	lh	a4,68(s2)
    80005bbe:	4785                	li	a5,1
    80005bc0:	f4f712e3          	bne	a4,a5,80005b04 <sys_open+0x60>
    80005bc4:	f4c42783          	lw	a5,-180(s0)
    80005bc8:	dba1                	beqz	a5,80005b18 <sys_open+0x74>
      iunlockput(ip);
    80005bca:	854a                	mv	a0,s2
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	1ce080e7          	jalr	462(ra) # 80003d9a <iunlockput>
      end_op();
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	9b6080e7          	jalr	-1610(ra) # 8000458a <end_op>
      return -1;
    80005bdc:	54fd                	li	s1,-1
    80005bde:	b76d                	j	80005b88 <sys_open+0xe4>
      end_op();
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	9aa080e7          	jalr	-1622(ra) # 8000458a <end_op>
      return -1;
    80005be8:	54fd                	li	s1,-1
    80005bea:	bf79                	j	80005b88 <sys_open+0xe4>
    iunlockput(ip);
    80005bec:	854a                	mv	a0,s2
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	1ac080e7          	jalr	428(ra) # 80003d9a <iunlockput>
    end_op();
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	994080e7          	jalr	-1644(ra) # 8000458a <end_op>
    return -1;
    80005bfe:	54fd                	li	s1,-1
    80005c00:	b761                	j	80005b88 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c02:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c06:	04691783          	lh	a5,70(s2)
    80005c0a:	02f99223          	sh	a5,36(s3)
    80005c0e:	bf2d                	j	80005b48 <sys_open+0xa4>
    itrunc(ip);
    80005c10:	854a                	mv	a0,s2
    80005c12:	ffffe097          	auipc	ra,0xffffe
    80005c16:	034080e7          	jalr	52(ra) # 80003c46 <itrunc>
    80005c1a:	bfb1                	j	80005b76 <sys_open+0xd2>
      fileclose(f);
    80005c1c:	854e                	mv	a0,s3
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	db8080e7          	jalr	-584(ra) # 800049d6 <fileclose>
    iunlockput(ip);
    80005c26:	854a                	mv	a0,s2
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	172080e7          	jalr	370(ra) # 80003d9a <iunlockput>
    end_op();
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	95a080e7          	jalr	-1702(ra) # 8000458a <end_op>
    return -1;
    80005c38:	54fd                	li	s1,-1
    80005c3a:	b7b9                	j	80005b88 <sys_open+0xe4>

0000000080005c3c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c3c:	7175                	addi	sp,sp,-144
    80005c3e:	e506                	sd	ra,136(sp)
    80005c40:	e122                	sd	s0,128(sp)
    80005c42:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	8c6080e7          	jalr	-1850(ra) # 8000450a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c4c:	08000613          	li	a2,128
    80005c50:	f7040593          	addi	a1,s0,-144
    80005c54:	4501                	li	a0,0
    80005c56:	ffffd097          	auipc	ra,0xffffd
    80005c5a:	3b4080e7          	jalr	948(ra) # 8000300a <argstr>
    80005c5e:	02054963          	bltz	a0,80005c90 <sys_mkdir+0x54>
    80005c62:	4681                	li	a3,0
    80005c64:	4601                	li	a2,0
    80005c66:	4585                	li	a1,1
    80005c68:	f7040513          	addi	a0,s0,-144
    80005c6c:	fffff097          	auipc	ra,0xfffff
    80005c70:	7fe080e7          	jalr	2046(ra) # 8000546a <create>
    80005c74:	cd11                	beqz	a0,80005c90 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	124080e7          	jalr	292(ra) # 80003d9a <iunlockput>
  end_op();
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	90c080e7          	jalr	-1780(ra) # 8000458a <end_op>
  return 0;
    80005c86:	4501                	li	a0,0
}
    80005c88:	60aa                	ld	ra,136(sp)
    80005c8a:	640a                	ld	s0,128(sp)
    80005c8c:	6149                	addi	sp,sp,144
    80005c8e:	8082                	ret
    end_op();
    80005c90:	fffff097          	auipc	ra,0xfffff
    80005c94:	8fa080e7          	jalr	-1798(ra) # 8000458a <end_op>
    return -1;
    80005c98:	557d                	li	a0,-1
    80005c9a:	b7fd                	j	80005c88 <sys_mkdir+0x4c>

0000000080005c9c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c9c:	7135                	addi	sp,sp,-160
    80005c9e:	ed06                	sd	ra,152(sp)
    80005ca0:	e922                	sd	s0,144(sp)
    80005ca2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ca4:	fffff097          	auipc	ra,0xfffff
    80005ca8:	866080e7          	jalr	-1946(ra) # 8000450a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cac:	08000613          	li	a2,128
    80005cb0:	f7040593          	addi	a1,s0,-144
    80005cb4:	4501                	li	a0,0
    80005cb6:	ffffd097          	auipc	ra,0xffffd
    80005cba:	354080e7          	jalr	852(ra) # 8000300a <argstr>
    80005cbe:	04054a63          	bltz	a0,80005d12 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005cc2:	f6c40593          	addi	a1,s0,-148
    80005cc6:	4505                	li	a0,1
    80005cc8:	ffffd097          	auipc	ra,0xffffd
    80005ccc:	2fe080e7          	jalr	766(ra) # 80002fc6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cd0:	04054163          	bltz	a0,80005d12 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005cd4:	f6840593          	addi	a1,s0,-152
    80005cd8:	4509                	li	a0,2
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	2ec080e7          	jalr	748(ra) # 80002fc6 <argint>
     argint(1, &major) < 0 ||
    80005ce2:	02054863          	bltz	a0,80005d12 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ce6:	f6841683          	lh	a3,-152(s0)
    80005cea:	f6c41603          	lh	a2,-148(s0)
    80005cee:	458d                	li	a1,3
    80005cf0:	f7040513          	addi	a0,s0,-144
    80005cf4:	fffff097          	auipc	ra,0xfffff
    80005cf8:	776080e7          	jalr	1910(ra) # 8000546a <create>
     argint(2, &minor) < 0 ||
    80005cfc:	c919                	beqz	a0,80005d12 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cfe:	ffffe097          	auipc	ra,0xffffe
    80005d02:	09c080e7          	jalr	156(ra) # 80003d9a <iunlockput>
  end_op();
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	884080e7          	jalr	-1916(ra) # 8000458a <end_op>
  return 0;
    80005d0e:	4501                	li	a0,0
    80005d10:	a031                	j	80005d1c <sys_mknod+0x80>
    end_op();
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	878080e7          	jalr	-1928(ra) # 8000458a <end_op>
    return -1;
    80005d1a:	557d                	li	a0,-1
}
    80005d1c:	60ea                	ld	ra,152(sp)
    80005d1e:	644a                	ld	s0,144(sp)
    80005d20:	610d                	addi	sp,sp,160
    80005d22:	8082                	ret

0000000080005d24 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d24:	7135                	addi	sp,sp,-160
    80005d26:	ed06                	sd	ra,152(sp)
    80005d28:	e922                	sd	s0,144(sp)
    80005d2a:	e526                	sd	s1,136(sp)
    80005d2c:	e14a                	sd	s2,128(sp)
    80005d2e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d30:	ffffc097          	auipc	ra,0xffffc
    80005d34:	080080e7          	jalr	128(ra) # 80001db0 <myproc>
    80005d38:	892a                	mv	s2,a0
  
  begin_op();
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	7d0080e7          	jalr	2000(ra) # 8000450a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d42:	08000613          	li	a2,128
    80005d46:	f6040593          	addi	a1,s0,-160
    80005d4a:	4501                	li	a0,0
    80005d4c:	ffffd097          	auipc	ra,0xffffd
    80005d50:	2be080e7          	jalr	702(ra) # 8000300a <argstr>
    80005d54:	04054b63          	bltz	a0,80005daa <sys_chdir+0x86>
    80005d58:	f6040513          	addi	a0,s0,-160
    80005d5c:	ffffe097          	auipc	ra,0xffffe
    80005d60:	592080e7          	jalr	1426(ra) # 800042ee <namei>
    80005d64:	84aa                	mv	s1,a0
    80005d66:	c131                	beqz	a0,80005daa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	dd0080e7          	jalr	-560(ra) # 80003b38 <ilock>
  if(ip->type != T_DIR){
    80005d70:	04449703          	lh	a4,68(s1)
    80005d74:	4785                	li	a5,1
    80005d76:	04f71063          	bne	a4,a5,80005db6 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d7a:	8526                	mv	a0,s1
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	e7e080e7          	jalr	-386(ra) # 80003bfa <iunlock>
  iput(p->cwd);
    80005d84:	17893503          	ld	a0,376(s2)
    80005d88:	ffffe097          	auipc	ra,0xffffe
    80005d8c:	f6a080e7          	jalr	-150(ra) # 80003cf2 <iput>
  end_op();
    80005d90:	ffffe097          	auipc	ra,0xffffe
    80005d94:	7fa080e7          	jalr	2042(ra) # 8000458a <end_op>
  p->cwd = ip;
    80005d98:	16993c23          	sd	s1,376(s2)
  return 0;
    80005d9c:	4501                	li	a0,0
}
    80005d9e:	60ea                	ld	ra,152(sp)
    80005da0:	644a                	ld	s0,144(sp)
    80005da2:	64aa                	ld	s1,136(sp)
    80005da4:	690a                	ld	s2,128(sp)
    80005da6:	610d                	addi	sp,sp,160
    80005da8:	8082                	ret
    end_op();
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	7e0080e7          	jalr	2016(ra) # 8000458a <end_op>
    return -1;
    80005db2:	557d                	li	a0,-1
    80005db4:	b7ed                	j	80005d9e <sys_chdir+0x7a>
    iunlockput(ip);
    80005db6:	8526                	mv	a0,s1
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	fe2080e7          	jalr	-30(ra) # 80003d9a <iunlockput>
    end_op();
    80005dc0:	ffffe097          	auipc	ra,0xffffe
    80005dc4:	7ca080e7          	jalr	1994(ra) # 8000458a <end_op>
    return -1;
    80005dc8:	557d                	li	a0,-1
    80005dca:	bfd1                	j	80005d9e <sys_chdir+0x7a>

0000000080005dcc <sys_exec>:

uint64
sys_exec(void)
{
    80005dcc:	7145                	addi	sp,sp,-464
    80005dce:	e786                	sd	ra,456(sp)
    80005dd0:	e3a2                	sd	s0,448(sp)
    80005dd2:	ff26                	sd	s1,440(sp)
    80005dd4:	fb4a                	sd	s2,432(sp)
    80005dd6:	f74e                	sd	s3,424(sp)
    80005dd8:	f352                	sd	s4,416(sp)
    80005dda:	ef56                	sd	s5,408(sp)
    80005ddc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005dde:	08000613          	li	a2,128
    80005de2:	f4040593          	addi	a1,s0,-192
    80005de6:	4501                	li	a0,0
    80005de8:	ffffd097          	auipc	ra,0xffffd
    80005dec:	222080e7          	jalr	546(ra) # 8000300a <argstr>
    return -1;
    80005df0:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005df2:	0c054a63          	bltz	a0,80005ec6 <sys_exec+0xfa>
    80005df6:	e3840593          	addi	a1,s0,-456
    80005dfa:	4505                	li	a0,1
    80005dfc:	ffffd097          	auipc	ra,0xffffd
    80005e00:	1ec080e7          	jalr	492(ra) # 80002fe8 <argaddr>
    80005e04:	0c054163          	bltz	a0,80005ec6 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e08:	10000613          	li	a2,256
    80005e0c:	4581                	li	a1,0
    80005e0e:	e4040513          	addi	a0,s0,-448
    80005e12:	ffffb097          	auipc	ra,0xffffb
    80005e16:	ece080e7          	jalr	-306(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e1a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e1e:	89a6                	mv	s3,s1
    80005e20:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e22:	02000a13          	li	s4,32
    80005e26:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e2a:	00391513          	slli	a0,s2,0x3
    80005e2e:	e3040593          	addi	a1,s0,-464
    80005e32:	e3843783          	ld	a5,-456(s0)
    80005e36:	953e                	add	a0,a0,a5
    80005e38:	ffffd097          	auipc	ra,0xffffd
    80005e3c:	0f4080e7          	jalr	244(ra) # 80002f2c <fetchaddr>
    80005e40:	02054a63          	bltz	a0,80005e74 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005e44:	e3043783          	ld	a5,-464(s0)
    80005e48:	c3b9                	beqz	a5,80005e8e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e4a:	ffffb097          	auipc	ra,0xffffb
    80005e4e:	caa080e7          	jalr	-854(ra) # 80000af4 <kalloc>
    80005e52:	85aa                	mv	a1,a0
    80005e54:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e58:	cd11                	beqz	a0,80005e74 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e5a:	6605                	lui	a2,0x1
    80005e5c:	e3043503          	ld	a0,-464(s0)
    80005e60:	ffffd097          	auipc	ra,0xffffd
    80005e64:	11e080e7          	jalr	286(ra) # 80002f7e <fetchstr>
    80005e68:	00054663          	bltz	a0,80005e74 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005e6c:	0905                	addi	s2,s2,1
    80005e6e:	09a1                	addi	s3,s3,8
    80005e70:	fb491be3          	bne	s2,s4,80005e26 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e74:	10048913          	addi	s2,s1,256
    80005e78:	6088                	ld	a0,0(s1)
    80005e7a:	c529                	beqz	a0,80005ec4 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	b7c080e7          	jalr	-1156(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e84:	04a1                	addi	s1,s1,8
    80005e86:	ff2499e3          	bne	s1,s2,80005e78 <sys_exec+0xac>
  return -1;
    80005e8a:	597d                	li	s2,-1
    80005e8c:	a82d                	j	80005ec6 <sys_exec+0xfa>
      argv[i] = 0;
    80005e8e:	0a8e                	slli	s5,s5,0x3
    80005e90:	fc040793          	addi	a5,s0,-64
    80005e94:	9abe                	add	s5,s5,a5
    80005e96:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e9a:	e4040593          	addi	a1,s0,-448
    80005e9e:	f4040513          	addi	a0,s0,-192
    80005ea2:	fffff097          	auipc	ra,0xfffff
    80005ea6:	194080e7          	jalr	404(ra) # 80005036 <exec>
    80005eaa:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eac:	10048993          	addi	s3,s1,256
    80005eb0:	6088                	ld	a0,0(s1)
    80005eb2:	c911                	beqz	a0,80005ec6 <sys_exec+0xfa>
    kfree(argv[i]);
    80005eb4:	ffffb097          	auipc	ra,0xffffb
    80005eb8:	b44080e7          	jalr	-1212(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ebc:	04a1                	addi	s1,s1,8
    80005ebe:	ff3499e3          	bne	s1,s3,80005eb0 <sys_exec+0xe4>
    80005ec2:	a011                	j	80005ec6 <sys_exec+0xfa>
  return -1;
    80005ec4:	597d                	li	s2,-1
}
    80005ec6:	854a                	mv	a0,s2
    80005ec8:	60be                	ld	ra,456(sp)
    80005eca:	641e                	ld	s0,448(sp)
    80005ecc:	74fa                	ld	s1,440(sp)
    80005ece:	795a                	ld	s2,432(sp)
    80005ed0:	79ba                	ld	s3,424(sp)
    80005ed2:	7a1a                	ld	s4,416(sp)
    80005ed4:	6afa                	ld	s5,408(sp)
    80005ed6:	6179                	addi	sp,sp,464
    80005ed8:	8082                	ret

0000000080005eda <sys_pipe>:

uint64
sys_pipe(void)
{
    80005eda:	7139                	addi	sp,sp,-64
    80005edc:	fc06                	sd	ra,56(sp)
    80005ede:	f822                	sd	s0,48(sp)
    80005ee0:	f426                	sd	s1,40(sp)
    80005ee2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ee4:	ffffc097          	auipc	ra,0xffffc
    80005ee8:	ecc080e7          	jalr	-308(ra) # 80001db0 <myproc>
    80005eec:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005eee:	fd840593          	addi	a1,s0,-40
    80005ef2:	4501                	li	a0,0
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	0f4080e7          	jalr	244(ra) # 80002fe8 <argaddr>
    return -1;
    80005efc:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005efe:	0e054063          	bltz	a0,80005fde <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005f02:	fc840593          	addi	a1,s0,-56
    80005f06:	fd040513          	addi	a0,s0,-48
    80005f0a:	fffff097          	auipc	ra,0xfffff
    80005f0e:	dfc080e7          	jalr	-516(ra) # 80004d06 <pipealloc>
    return -1;
    80005f12:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f14:	0c054563          	bltz	a0,80005fde <sys_pipe+0x104>
  fd0 = -1;
    80005f18:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f1c:	fd043503          	ld	a0,-48(s0)
    80005f20:	fffff097          	auipc	ra,0xfffff
    80005f24:	508080e7          	jalr	1288(ra) # 80005428 <fdalloc>
    80005f28:	fca42223          	sw	a0,-60(s0)
    80005f2c:	08054c63          	bltz	a0,80005fc4 <sys_pipe+0xea>
    80005f30:	fc843503          	ld	a0,-56(s0)
    80005f34:	fffff097          	auipc	ra,0xfffff
    80005f38:	4f4080e7          	jalr	1268(ra) # 80005428 <fdalloc>
    80005f3c:	fca42023          	sw	a0,-64(s0)
    80005f40:	06054863          	bltz	a0,80005fb0 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f44:	4691                	li	a3,4
    80005f46:	fc440613          	addi	a2,s0,-60
    80005f4a:	fd843583          	ld	a1,-40(s0)
    80005f4e:	7ca8                	ld	a0,120(s1)
    80005f50:	ffffb097          	auipc	ra,0xffffb
    80005f54:	722080e7          	jalr	1826(ra) # 80001672 <copyout>
    80005f58:	02054063          	bltz	a0,80005f78 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f5c:	4691                	li	a3,4
    80005f5e:	fc040613          	addi	a2,s0,-64
    80005f62:	fd843583          	ld	a1,-40(s0)
    80005f66:	0591                	addi	a1,a1,4
    80005f68:	7ca8                	ld	a0,120(s1)
    80005f6a:	ffffb097          	auipc	ra,0xffffb
    80005f6e:	708080e7          	jalr	1800(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f72:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f74:	06055563          	bgez	a0,80005fde <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f78:	fc442783          	lw	a5,-60(s0)
    80005f7c:	07f9                	addi	a5,a5,30
    80005f7e:	078e                	slli	a5,a5,0x3
    80005f80:	97a6                	add	a5,a5,s1
    80005f82:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f86:	fc042503          	lw	a0,-64(s0)
    80005f8a:	0579                	addi	a0,a0,30
    80005f8c:	050e                	slli	a0,a0,0x3
    80005f8e:	9526                	add	a0,a0,s1
    80005f90:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005f94:	fd043503          	ld	a0,-48(s0)
    80005f98:	fffff097          	auipc	ra,0xfffff
    80005f9c:	a3e080e7          	jalr	-1474(ra) # 800049d6 <fileclose>
    fileclose(wf);
    80005fa0:	fc843503          	ld	a0,-56(s0)
    80005fa4:	fffff097          	auipc	ra,0xfffff
    80005fa8:	a32080e7          	jalr	-1486(ra) # 800049d6 <fileclose>
    return -1;
    80005fac:	57fd                	li	a5,-1
    80005fae:	a805                	j	80005fde <sys_pipe+0x104>
    if(fd0 >= 0)
    80005fb0:	fc442783          	lw	a5,-60(s0)
    80005fb4:	0007c863          	bltz	a5,80005fc4 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005fb8:	01e78513          	addi	a0,a5,30
    80005fbc:	050e                	slli	a0,a0,0x3
    80005fbe:	9526                	add	a0,a0,s1
    80005fc0:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005fc4:	fd043503          	ld	a0,-48(s0)
    80005fc8:	fffff097          	auipc	ra,0xfffff
    80005fcc:	a0e080e7          	jalr	-1522(ra) # 800049d6 <fileclose>
    fileclose(wf);
    80005fd0:	fc843503          	ld	a0,-56(s0)
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	a02080e7          	jalr	-1534(ra) # 800049d6 <fileclose>
    return -1;
    80005fdc:	57fd                	li	a5,-1
}
    80005fde:	853e                	mv	a0,a5
    80005fe0:	70e2                	ld	ra,56(sp)
    80005fe2:	7442                	ld	s0,48(sp)
    80005fe4:	74a2                	ld	s1,40(sp)
    80005fe6:	6121                	addi	sp,sp,64
    80005fe8:	8082                	ret
    80005fea:	0000                	unimp
    80005fec:	0000                	unimp
	...

0000000080005ff0 <kernelvec>:
    80005ff0:	7111                	addi	sp,sp,-256
    80005ff2:	e006                	sd	ra,0(sp)
    80005ff4:	e40a                	sd	sp,8(sp)
    80005ff6:	e80e                	sd	gp,16(sp)
    80005ff8:	ec12                	sd	tp,24(sp)
    80005ffa:	f016                	sd	t0,32(sp)
    80005ffc:	f41a                	sd	t1,40(sp)
    80005ffe:	f81e                	sd	t2,48(sp)
    80006000:	fc22                	sd	s0,56(sp)
    80006002:	e0a6                	sd	s1,64(sp)
    80006004:	e4aa                	sd	a0,72(sp)
    80006006:	e8ae                	sd	a1,80(sp)
    80006008:	ecb2                	sd	a2,88(sp)
    8000600a:	f0b6                	sd	a3,96(sp)
    8000600c:	f4ba                	sd	a4,104(sp)
    8000600e:	f8be                	sd	a5,112(sp)
    80006010:	fcc2                	sd	a6,120(sp)
    80006012:	e146                	sd	a7,128(sp)
    80006014:	e54a                	sd	s2,136(sp)
    80006016:	e94e                	sd	s3,144(sp)
    80006018:	ed52                	sd	s4,152(sp)
    8000601a:	f156                	sd	s5,160(sp)
    8000601c:	f55a                	sd	s6,168(sp)
    8000601e:	f95e                	sd	s7,176(sp)
    80006020:	fd62                	sd	s8,184(sp)
    80006022:	e1e6                	sd	s9,192(sp)
    80006024:	e5ea                	sd	s10,200(sp)
    80006026:	e9ee                	sd	s11,208(sp)
    80006028:	edf2                	sd	t3,216(sp)
    8000602a:	f1f6                	sd	t4,224(sp)
    8000602c:	f5fa                	sd	t5,232(sp)
    8000602e:	f9fe                	sd	t6,240(sp)
    80006030:	dc9fc0ef          	jal	ra,80002df8 <kerneltrap>
    80006034:	6082                	ld	ra,0(sp)
    80006036:	6122                	ld	sp,8(sp)
    80006038:	61c2                	ld	gp,16(sp)
    8000603a:	7282                	ld	t0,32(sp)
    8000603c:	7322                	ld	t1,40(sp)
    8000603e:	73c2                	ld	t2,48(sp)
    80006040:	7462                	ld	s0,56(sp)
    80006042:	6486                	ld	s1,64(sp)
    80006044:	6526                	ld	a0,72(sp)
    80006046:	65c6                	ld	a1,80(sp)
    80006048:	6666                	ld	a2,88(sp)
    8000604a:	7686                	ld	a3,96(sp)
    8000604c:	7726                	ld	a4,104(sp)
    8000604e:	77c6                	ld	a5,112(sp)
    80006050:	7866                	ld	a6,120(sp)
    80006052:	688a                	ld	a7,128(sp)
    80006054:	692a                	ld	s2,136(sp)
    80006056:	69ca                	ld	s3,144(sp)
    80006058:	6a6a                	ld	s4,152(sp)
    8000605a:	7a8a                	ld	s5,160(sp)
    8000605c:	7b2a                	ld	s6,168(sp)
    8000605e:	7bca                	ld	s7,176(sp)
    80006060:	7c6a                	ld	s8,184(sp)
    80006062:	6c8e                	ld	s9,192(sp)
    80006064:	6d2e                	ld	s10,200(sp)
    80006066:	6dce                	ld	s11,208(sp)
    80006068:	6e6e                	ld	t3,216(sp)
    8000606a:	7e8e                	ld	t4,224(sp)
    8000606c:	7f2e                	ld	t5,232(sp)
    8000606e:	7fce                	ld	t6,240(sp)
    80006070:	6111                	addi	sp,sp,256
    80006072:	10200073          	sret
    80006076:	00000013          	nop
    8000607a:	00000013          	nop
    8000607e:	0001                	nop

0000000080006080 <timervec>:
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	e10c                	sd	a1,0(a0)
    80006086:	e510                	sd	a2,8(a0)
    80006088:	e914                	sd	a3,16(a0)
    8000608a:	6d0c                	ld	a1,24(a0)
    8000608c:	7110                	ld	a2,32(a0)
    8000608e:	6194                	ld	a3,0(a1)
    80006090:	96b2                	add	a3,a3,a2
    80006092:	e194                	sd	a3,0(a1)
    80006094:	4589                	li	a1,2
    80006096:	14459073          	csrw	sip,a1
    8000609a:	6914                	ld	a3,16(a0)
    8000609c:	6510                	ld	a2,8(a0)
    8000609e:	610c                	ld	a1,0(a0)
    800060a0:	34051573          	csrrw	a0,mscratch,a0
    800060a4:	30200073          	mret
	...

00000000800060aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060aa:	1141                	addi	sp,sp,-16
    800060ac:	e422                	sd	s0,8(sp)
    800060ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060b0:	0c0007b7          	lui	a5,0xc000
    800060b4:	4705                	li	a4,1
    800060b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060b8:	c3d8                	sw	a4,4(a5)
}
    800060ba:	6422                	ld	s0,8(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <plicinithart>:

void
plicinithart(void)
{
    800060c0:	1141                	addi	sp,sp,-16
    800060c2:	e406                	sd	ra,8(sp)
    800060c4:	e022                	sd	s0,0(sp)
    800060c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	cb4080e7          	jalr	-844(ra) # 80001d7c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060d0:	0085171b          	slliw	a4,a0,0x8
    800060d4:	0c0027b7          	lui	a5,0xc002
    800060d8:	97ba                	add	a5,a5,a4
    800060da:	40200713          	li	a4,1026
    800060de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060e2:	00d5151b          	slliw	a0,a0,0xd
    800060e6:	0c2017b7          	lui	a5,0xc201
    800060ea:	953e                	add	a0,a0,a5
    800060ec:	00052023          	sw	zero,0(a0)
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060f8:	1141                	addi	sp,sp,-16
    800060fa:	e406                	sd	ra,8(sp)
    800060fc:	e022                	sd	s0,0(sp)
    800060fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006100:	ffffc097          	auipc	ra,0xffffc
    80006104:	c7c080e7          	jalr	-900(ra) # 80001d7c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006108:	00d5179b          	slliw	a5,a0,0xd
    8000610c:	0c201537          	lui	a0,0xc201
    80006110:	953e                	add	a0,a0,a5
  return irq;
}
    80006112:	4148                	lw	a0,4(a0)
    80006114:	60a2                	ld	ra,8(sp)
    80006116:	6402                	ld	s0,0(sp)
    80006118:	0141                	addi	sp,sp,16
    8000611a:	8082                	ret

000000008000611c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000611c:	1101                	addi	sp,sp,-32
    8000611e:	ec06                	sd	ra,24(sp)
    80006120:	e822                	sd	s0,16(sp)
    80006122:	e426                	sd	s1,8(sp)
    80006124:	1000                	addi	s0,sp,32
    80006126:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	c54080e7          	jalr	-940(ra) # 80001d7c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006130:	00d5151b          	slliw	a0,a0,0xd
    80006134:	0c2017b7          	lui	a5,0xc201
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	c3c4                	sw	s1,4(a5)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret

0000000080006146 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006146:	1141                	addi	sp,sp,-16
    80006148:	e406                	sd	ra,8(sp)
    8000614a:	e022                	sd	s0,0(sp)
    8000614c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000614e:	479d                	li	a5,7
    80006150:	06a7c963          	blt	a5,a0,800061c2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006154:	0001d797          	auipc	a5,0x1d
    80006158:	eac78793          	addi	a5,a5,-340 # 80023000 <disk>
    8000615c:	00a78733          	add	a4,a5,a0
    80006160:	6789                	lui	a5,0x2
    80006162:	97ba                	add	a5,a5,a4
    80006164:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006168:	e7ad                	bnez	a5,800061d2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000616a:	00451793          	slli	a5,a0,0x4
    8000616e:	0001f717          	auipc	a4,0x1f
    80006172:	e9270713          	addi	a4,a4,-366 # 80025000 <disk+0x2000>
    80006176:	6314                	ld	a3,0(a4)
    80006178:	96be                	add	a3,a3,a5
    8000617a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000617e:	6314                	ld	a3,0(a4)
    80006180:	96be                	add	a3,a3,a5
    80006182:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006186:	6314                	ld	a3,0(a4)
    80006188:	96be                	add	a3,a3,a5
    8000618a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000618e:	6318                	ld	a4,0(a4)
    80006190:	97ba                	add	a5,a5,a4
    80006192:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006196:	0001d797          	auipc	a5,0x1d
    8000619a:	e6a78793          	addi	a5,a5,-406 # 80023000 <disk>
    8000619e:	97aa                	add	a5,a5,a0
    800061a0:	6509                	lui	a0,0x2
    800061a2:	953e                	add	a0,a0,a5
    800061a4:	4785                	li	a5,1
    800061a6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800061aa:	0001f517          	auipc	a0,0x1f
    800061ae:	e6e50513          	addi	a0,a0,-402 # 80025018 <disk+0x2018>
    800061b2:	ffffc097          	auipc	ra,0xffffc
    800061b6:	55c080e7          	jalr	1372(ra) # 8000270e <wakeup>
}
    800061ba:	60a2                	ld	ra,8(sp)
    800061bc:	6402                	ld	s0,0(sp)
    800061be:	0141                	addi	sp,sp,16
    800061c0:	8082                	ret
    panic("free_desc 1");
    800061c2:	00002517          	auipc	a0,0x2
    800061c6:	63e50513          	addi	a0,a0,1598 # 80008800 <syscalls+0x320>
    800061ca:	ffffa097          	auipc	ra,0xffffa
    800061ce:	374080e7          	jalr	884(ra) # 8000053e <panic>
    panic("free_desc 2");
    800061d2:	00002517          	auipc	a0,0x2
    800061d6:	63e50513          	addi	a0,a0,1598 # 80008810 <syscalls+0x330>
    800061da:	ffffa097          	auipc	ra,0xffffa
    800061de:	364080e7          	jalr	868(ra) # 8000053e <panic>

00000000800061e2 <virtio_disk_init>:
{
    800061e2:	1101                	addi	sp,sp,-32
    800061e4:	ec06                	sd	ra,24(sp)
    800061e6:	e822                	sd	s0,16(sp)
    800061e8:	e426                	sd	s1,8(sp)
    800061ea:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061ec:	00002597          	auipc	a1,0x2
    800061f0:	63458593          	addi	a1,a1,1588 # 80008820 <syscalls+0x340>
    800061f4:	0001f517          	auipc	a0,0x1f
    800061f8:	f3450513          	addi	a0,a0,-204 # 80025128 <disk+0x2128>
    800061fc:	ffffb097          	auipc	ra,0xffffb
    80006200:	958080e7          	jalr	-1704(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006204:	100017b7          	lui	a5,0x10001
    80006208:	4398                	lw	a4,0(a5)
    8000620a:	2701                	sext.w	a4,a4
    8000620c:	747277b7          	lui	a5,0x74727
    80006210:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006214:	0ef71163          	bne	a4,a5,800062f6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006218:	100017b7          	lui	a5,0x10001
    8000621c:	43dc                	lw	a5,4(a5)
    8000621e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006220:	4705                	li	a4,1
    80006222:	0ce79a63          	bne	a5,a4,800062f6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006226:	100017b7          	lui	a5,0x10001
    8000622a:	479c                	lw	a5,8(a5)
    8000622c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000622e:	4709                	li	a4,2
    80006230:	0ce79363          	bne	a5,a4,800062f6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006234:	100017b7          	lui	a5,0x10001
    80006238:	47d8                	lw	a4,12(a5)
    8000623a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000623c:	554d47b7          	lui	a5,0x554d4
    80006240:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006244:	0af71963          	bne	a4,a5,800062f6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006248:	100017b7          	lui	a5,0x10001
    8000624c:	4705                	li	a4,1
    8000624e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006250:	470d                	li	a4,3
    80006252:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006254:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006256:	c7ffe737          	lui	a4,0xc7ffe
    8000625a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000625e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006260:	2701                	sext.w	a4,a4
    80006262:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006264:	472d                	li	a4,11
    80006266:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006268:	473d                	li	a4,15
    8000626a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000626c:	6705                	lui	a4,0x1
    8000626e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006270:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006274:	5bdc                	lw	a5,52(a5)
    80006276:	2781                	sext.w	a5,a5
  if(max == 0)
    80006278:	c7d9                	beqz	a5,80006306 <virtio_disk_init+0x124>
  if(max < NUM)
    8000627a:	471d                	li	a4,7
    8000627c:	08f77d63          	bgeu	a4,a5,80006316 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006280:	100014b7          	lui	s1,0x10001
    80006284:	47a1                	li	a5,8
    80006286:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006288:	6609                	lui	a2,0x2
    8000628a:	4581                	li	a1,0
    8000628c:	0001d517          	auipc	a0,0x1d
    80006290:	d7450513          	addi	a0,a0,-652 # 80023000 <disk>
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	a4c080e7          	jalr	-1460(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000629c:	0001d717          	auipc	a4,0x1d
    800062a0:	d6470713          	addi	a4,a4,-668 # 80023000 <disk>
    800062a4:	00c75793          	srli	a5,a4,0xc
    800062a8:	2781                	sext.w	a5,a5
    800062aa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800062ac:	0001f797          	auipc	a5,0x1f
    800062b0:	d5478793          	addi	a5,a5,-684 # 80025000 <disk+0x2000>
    800062b4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800062b6:	0001d717          	auipc	a4,0x1d
    800062ba:	dca70713          	addi	a4,a4,-566 # 80023080 <disk+0x80>
    800062be:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800062c0:	0001e717          	auipc	a4,0x1e
    800062c4:	d4070713          	addi	a4,a4,-704 # 80024000 <disk+0x1000>
    800062c8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800062ca:	4705                	li	a4,1
    800062cc:	00e78c23          	sb	a4,24(a5)
    800062d0:	00e78ca3          	sb	a4,25(a5)
    800062d4:	00e78d23          	sb	a4,26(a5)
    800062d8:	00e78da3          	sb	a4,27(a5)
    800062dc:	00e78e23          	sb	a4,28(a5)
    800062e0:	00e78ea3          	sb	a4,29(a5)
    800062e4:	00e78f23          	sb	a4,30(a5)
    800062e8:	00e78fa3          	sb	a4,31(a5)
}
    800062ec:	60e2                	ld	ra,24(sp)
    800062ee:	6442                	ld	s0,16(sp)
    800062f0:	64a2                	ld	s1,8(sp)
    800062f2:	6105                	addi	sp,sp,32
    800062f4:	8082                	ret
    panic("could not find virtio disk");
    800062f6:	00002517          	auipc	a0,0x2
    800062fa:	53a50513          	addi	a0,a0,1338 # 80008830 <syscalls+0x350>
    800062fe:	ffffa097          	auipc	ra,0xffffa
    80006302:	240080e7          	jalr	576(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006306:	00002517          	auipc	a0,0x2
    8000630a:	54a50513          	addi	a0,a0,1354 # 80008850 <syscalls+0x370>
    8000630e:	ffffa097          	auipc	ra,0xffffa
    80006312:	230080e7          	jalr	560(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006316:	00002517          	auipc	a0,0x2
    8000631a:	55a50513          	addi	a0,a0,1370 # 80008870 <syscalls+0x390>
    8000631e:	ffffa097          	auipc	ra,0xffffa
    80006322:	220080e7          	jalr	544(ra) # 8000053e <panic>

0000000080006326 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006326:	7159                	addi	sp,sp,-112
    80006328:	f486                	sd	ra,104(sp)
    8000632a:	f0a2                	sd	s0,96(sp)
    8000632c:	eca6                	sd	s1,88(sp)
    8000632e:	e8ca                	sd	s2,80(sp)
    80006330:	e4ce                	sd	s3,72(sp)
    80006332:	e0d2                	sd	s4,64(sp)
    80006334:	fc56                	sd	s5,56(sp)
    80006336:	f85a                	sd	s6,48(sp)
    80006338:	f45e                	sd	s7,40(sp)
    8000633a:	f062                	sd	s8,32(sp)
    8000633c:	ec66                	sd	s9,24(sp)
    8000633e:	e86a                	sd	s10,16(sp)
    80006340:	1880                	addi	s0,sp,112
    80006342:	892a                	mv	s2,a0
    80006344:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006346:	00c52c83          	lw	s9,12(a0)
    8000634a:	001c9c9b          	slliw	s9,s9,0x1
    8000634e:	1c82                	slli	s9,s9,0x20
    80006350:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006354:	0001f517          	auipc	a0,0x1f
    80006358:	dd450513          	addi	a0,a0,-556 # 80025128 <disk+0x2128>
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	888080e7          	jalr	-1912(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    80006364:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006366:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006368:	0001db97          	auipc	s7,0x1d
    8000636c:	c98b8b93          	addi	s7,s7,-872 # 80023000 <disk>
    80006370:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006372:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006374:	8a4e                	mv	s4,s3
    80006376:	a051                	j	800063fa <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006378:	00fb86b3          	add	a3,s7,a5
    8000637c:	96da                	add	a3,a3,s6
    8000637e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006382:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006384:	0207c563          	bltz	a5,800063ae <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006388:	2485                	addiw	s1,s1,1
    8000638a:	0711                	addi	a4,a4,4
    8000638c:	25548063          	beq	s1,s5,800065cc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006390:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006392:	0001f697          	auipc	a3,0x1f
    80006396:	c8668693          	addi	a3,a3,-890 # 80025018 <disk+0x2018>
    8000639a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000639c:	0006c583          	lbu	a1,0(a3)
    800063a0:	fde1                	bnez	a1,80006378 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800063a2:	2785                	addiw	a5,a5,1
    800063a4:	0685                	addi	a3,a3,1
    800063a6:	ff879be3          	bne	a5,s8,8000639c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800063aa:	57fd                	li	a5,-1
    800063ac:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800063ae:	02905a63          	blez	s1,800063e2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800063b2:	f9042503          	lw	a0,-112(s0)
    800063b6:	00000097          	auipc	ra,0x0
    800063ba:	d90080e7          	jalr	-624(ra) # 80006146 <free_desc>
      for(int j = 0; j < i; j++)
    800063be:	4785                	li	a5,1
    800063c0:	0297d163          	bge	a5,s1,800063e2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800063c4:	f9442503          	lw	a0,-108(s0)
    800063c8:	00000097          	auipc	ra,0x0
    800063cc:	d7e080e7          	jalr	-642(ra) # 80006146 <free_desc>
      for(int j = 0; j < i; j++)
    800063d0:	4789                	li	a5,2
    800063d2:	0097d863          	bge	a5,s1,800063e2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800063d6:	f9842503          	lw	a0,-104(s0)
    800063da:	00000097          	auipc	ra,0x0
    800063de:	d6c080e7          	jalr	-660(ra) # 80006146 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063e2:	0001f597          	auipc	a1,0x1f
    800063e6:	d4658593          	addi	a1,a1,-698 # 80025128 <disk+0x2128>
    800063ea:	0001f517          	auipc	a0,0x1f
    800063ee:	c2e50513          	addi	a0,a0,-978 # 80025018 <disk+0x2018>
    800063f2:	ffffc097          	auipc	ra,0xffffc
    800063f6:	11c080e7          	jalr	284(ra) # 8000250e <sleep>
  for(int i = 0; i < 3; i++){
    800063fa:	f9040713          	addi	a4,s0,-112
    800063fe:	84ce                	mv	s1,s3
    80006400:	bf41                	j	80006390 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006402:	20058713          	addi	a4,a1,512
    80006406:	00471693          	slli	a3,a4,0x4
    8000640a:	0001d717          	auipc	a4,0x1d
    8000640e:	bf670713          	addi	a4,a4,-1034 # 80023000 <disk>
    80006412:	9736                	add	a4,a4,a3
    80006414:	4685                	li	a3,1
    80006416:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000641a:	20058713          	addi	a4,a1,512
    8000641e:	00471693          	slli	a3,a4,0x4
    80006422:	0001d717          	auipc	a4,0x1d
    80006426:	bde70713          	addi	a4,a4,-1058 # 80023000 <disk>
    8000642a:	9736                	add	a4,a4,a3
    8000642c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006430:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006434:	7679                	lui	a2,0xffffe
    80006436:	963e                	add	a2,a2,a5
    80006438:	0001f697          	auipc	a3,0x1f
    8000643c:	bc868693          	addi	a3,a3,-1080 # 80025000 <disk+0x2000>
    80006440:	6298                	ld	a4,0(a3)
    80006442:	9732                	add	a4,a4,a2
    80006444:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006446:	6298                	ld	a4,0(a3)
    80006448:	9732                	add	a4,a4,a2
    8000644a:	4541                	li	a0,16
    8000644c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000644e:	6298                	ld	a4,0(a3)
    80006450:	9732                	add	a4,a4,a2
    80006452:	4505                	li	a0,1
    80006454:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006458:	f9442703          	lw	a4,-108(s0)
    8000645c:	6288                	ld	a0,0(a3)
    8000645e:	962a                	add	a2,a2,a0
    80006460:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006464:	0712                	slli	a4,a4,0x4
    80006466:	6290                	ld	a2,0(a3)
    80006468:	963a                	add	a2,a2,a4
    8000646a:	05890513          	addi	a0,s2,88
    8000646e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006470:	6294                	ld	a3,0(a3)
    80006472:	96ba                	add	a3,a3,a4
    80006474:	40000613          	li	a2,1024
    80006478:	c690                	sw	a2,8(a3)
  if(write)
    8000647a:	140d0063          	beqz	s10,800065ba <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000647e:	0001f697          	auipc	a3,0x1f
    80006482:	b826b683          	ld	a3,-1150(a3) # 80025000 <disk+0x2000>
    80006486:	96ba                	add	a3,a3,a4
    80006488:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000648c:	0001d817          	auipc	a6,0x1d
    80006490:	b7480813          	addi	a6,a6,-1164 # 80023000 <disk>
    80006494:	0001f517          	auipc	a0,0x1f
    80006498:	b6c50513          	addi	a0,a0,-1172 # 80025000 <disk+0x2000>
    8000649c:	6114                	ld	a3,0(a0)
    8000649e:	96ba                	add	a3,a3,a4
    800064a0:	00c6d603          	lhu	a2,12(a3)
    800064a4:	00166613          	ori	a2,a2,1
    800064a8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800064ac:	f9842683          	lw	a3,-104(s0)
    800064b0:	6110                	ld	a2,0(a0)
    800064b2:	9732                	add	a4,a4,a2
    800064b4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064b8:	20058613          	addi	a2,a1,512
    800064bc:	0612                	slli	a2,a2,0x4
    800064be:	9642                	add	a2,a2,a6
    800064c0:	577d                	li	a4,-1
    800064c2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064c6:	00469713          	slli	a4,a3,0x4
    800064ca:	6114                	ld	a3,0(a0)
    800064cc:	96ba                	add	a3,a3,a4
    800064ce:	03078793          	addi	a5,a5,48
    800064d2:	97c2                	add	a5,a5,a6
    800064d4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800064d6:	611c                	ld	a5,0(a0)
    800064d8:	97ba                	add	a5,a5,a4
    800064da:	4685                	li	a3,1
    800064dc:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064de:	611c                	ld	a5,0(a0)
    800064e0:	97ba                	add	a5,a5,a4
    800064e2:	4809                	li	a6,2
    800064e4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800064e8:	611c                	ld	a5,0(a0)
    800064ea:	973e                	add	a4,a4,a5
    800064ec:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064f0:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    800064f4:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064f8:	6518                	ld	a4,8(a0)
    800064fa:	00275783          	lhu	a5,2(a4)
    800064fe:	8b9d                	andi	a5,a5,7
    80006500:	0786                	slli	a5,a5,0x1
    80006502:	97ba                	add	a5,a5,a4
    80006504:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006508:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000650c:	6518                	ld	a4,8(a0)
    8000650e:	00275783          	lhu	a5,2(a4)
    80006512:	2785                	addiw	a5,a5,1
    80006514:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006518:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000651c:	100017b7          	lui	a5,0x10001
    80006520:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006524:	00492703          	lw	a4,4(s2)
    80006528:	4785                	li	a5,1
    8000652a:	02f71163          	bne	a4,a5,8000654c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000652e:	0001f997          	auipc	s3,0x1f
    80006532:	bfa98993          	addi	s3,s3,-1030 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006536:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006538:	85ce                	mv	a1,s3
    8000653a:	854a                	mv	a0,s2
    8000653c:	ffffc097          	auipc	ra,0xffffc
    80006540:	fd2080e7          	jalr	-46(ra) # 8000250e <sleep>
  while(b->disk == 1) {
    80006544:	00492783          	lw	a5,4(s2)
    80006548:	fe9788e3          	beq	a5,s1,80006538 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000654c:	f9042903          	lw	s2,-112(s0)
    80006550:	20090793          	addi	a5,s2,512
    80006554:	00479713          	slli	a4,a5,0x4
    80006558:	0001d797          	auipc	a5,0x1d
    8000655c:	aa878793          	addi	a5,a5,-1368 # 80023000 <disk>
    80006560:	97ba                	add	a5,a5,a4
    80006562:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006566:	0001f997          	auipc	s3,0x1f
    8000656a:	a9a98993          	addi	s3,s3,-1382 # 80025000 <disk+0x2000>
    8000656e:	00491713          	slli	a4,s2,0x4
    80006572:	0009b783          	ld	a5,0(s3)
    80006576:	97ba                	add	a5,a5,a4
    80006578:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000657c:	854a                	mv	a0,s2
    8000657e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006582:	00000097          	auipc	ra,0x0
    80006586:	bc4080e7          	jalr	-1084(ra) # 80006146 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000658a:	8885                	andi	s1,s1,1
    8000658c:	f0ed                	bnez	s1,8000656e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000658e:	0001f517          	auipc	a0,0x1f
    80006592:	b9a50513          	addi	a0,a0,-1126 # 80025128 <disk+0x2128>
    80006596:	ffffa097          	auipc	ra,0xffffa
    8000659a:	702080e7          	jalr	1794(ra) # 80000c98 <release>
}
    8000659e:	70a6                	ld	ra,104(sp)
    800065a0:	7406                	ld	s0,96(sp)
    800065a2:	64e6                	ld	s1,88(sp)
    800065a4:	6946                	ld	s2,80(sp)
    800065a6:	69a6                	ld	s3,72(sp)
    800065a8:	6a06                	ld	s4,64(sp)
    800065aa:	7ae2                	ld	s5,56(sp)
    800065ac:	7b42                	ld	s6,48(sp)
    800065ae:	7ba2                	ld	s7,40(sp)
    800065b0:	7c02                	ld	s8,32(sp)
    800065b2:	6ce2                	ld	s9,24(sp)
    800065b4:	6d42                	ld	s10,16(sp)
    800065b6:	6165                	addi	sp,sp,112
    800065b8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800065ba:	0001f697          	auipc	a3,0x1f
    800065be:	a466b683          	ld	a3,-1466(a3) # 80025000 <disk+0x2000>
    800065c2:	96ba                	add	a3,a3,a4
    800065c4:	4609                	li	a2,2
    800065c6:	00c69623          	sh	a2,12(a3)
    800065ca:	b5c9                	j	8000648c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065cc:	f9042583          	lw	a1,-112(s0)
    800065d0:	20058793          	addi	a5,a1,512
    800065d4:	0792                	slli	a5,a5,0x4
    800065d6:	0001d517          	auipc	a0,0x1d
    800065da:	ad250513          	addi	a0,a0,-1326 # 800230a8 <disk+0xa8>
    800065de:	953e                	add	a0,a0,a5
  if(write)
    800065e0:	e20d11e3          	bnez	s10,80006402 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800065e4:	20058713          	addi	a4,a1,512
    800065e8:	00471693          	slli	a3,a4,0x4
    800065ec:	0001d717          	auipc	a4,0x1d
    800065f0:	a1470713          	addi	a4,a4,-1516 # 80023000 <disk>
    800065f4:	9736                	add	a4,a4,a3
    800065f6:	0a072423          	sw	zero,168(a4)
    800065fa:	b505                	j	8000641a <virtio_disk_rw+0xf4>

00000000800065fc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065fc:	1101                	addi	sp,sp,-32
    800065fe:	ec06                	sd	ra,24(sp)
    80006600:	e822                	sd	s0,16(sp)
    80006602:	e426                	sd	s1,8(sp)
    80006604:	e04a                	sd	s2,0(sp)
    80006606:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006608:	0001f517          	auipc	a0,0x1f
    8000660c:	b2050513          	addi	a0,a0,-1248 # 80025128 <disk+0x2128>
    80006610:	ffffa097          	auipc	ra,0xffffa
    80006614:	5d4080e7          	jalr	1492(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006618:	10001737          	lui	a4,0x10001
    8000661c:	533c                	lw	a5,96(a4)
    8000661e:	8b8d                	andi	a5,a5,3
    80006620:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006622:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006626:	0001f797          	auipc	a5,0x1f
    8000662a:	9da78793          	addi	a5,a5,-1574 # 80025000 <disk+0x2000>
    8000662e:	6b94                	ld	a3,16(a5)
    80006630:	0207d703          	lhu	a4,32(a5)
    80006634:	0026d783          	lhu	a5,2(a3)
    80006638:	06f70163          	beq	a4,a5,8000669a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000663c:	0001d917          	auipc	s2,0x1d
    80006640:	9c490913          	addi	s2,s2,-1596 # 80023000 <disk>
    80006644:	0001f497          	auipc	s1,0x1f
    80006648:	9bc48493          	addi	s1,s1,-1604 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000664c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006650:	6898                	ld	a4,16(s1)
    80006652:	0204d783          	lhu	a5,32(s1)
    80006656:	8b9d                	andi	a5,a5,7
    80006658:	078e                	slli	a5,a5,0x3
    8000665a:	97ba                	add	a5,a5,a4
    8000665c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000665e:	20078713          	addi	a4,a5,512
    80006662:	0712                	slli	a4,a4,0x4
    80006664:	974a                	add	a4,a4,s2
    80006666:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000666a:	e731                	bnez	a4,800066b6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000666c:	20078793          	addi	a5,a5,512
    80006670:	0792                	slli	a5,a5,0x4
    80006672:	97ca                	add	a5,a5,s2
    80006674:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006676:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000667a:	ffffc097          	auipc	ra,0xffffc
    8000667e:	094080e7          	jalr	148(ra) # 8000270e <wakeup>

    disk.used_idx += 1;
    80006682:	0204d783          	lhu	a5,32(s1)
    80006686:	2785                	addiw	a5,a5,1
    80006688:	17c2                	slli	a5,a5,0x30
    8000668a:	93c1                	srli	a5,a5,0x30
    8000668c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006690:	6898                	ld	a4,16(s1)
    80006692:	00275703          	lhu	a4,2(a4)
    80006696:	faf71be3          	bne	a4,a5,8000664c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000669a:	0001f517          	auipc	a0,0x1f
    8000669e:	a8e50513          	addi	a0,a0,-1394 # 80025128 <disk+0x2128>
    800066a2:	ffffa097          	auipc	ra,0xffffa
    800066a6:	5f6080e7          	jalr	1526(ra) # 80000c98 <release>
}
    800066aa:	60e2                	ld	ra,24(sp)
    800066ac:	6442                	ld	s0,16(sp)
    800066ae:	64a2                	ld	s1,8(sp)
    800066b0:	6902                	ld	s2,0(sp)
    800066b2:	6105                	addi	sp,sp,32
    800066b4:	8082                	ret
      panic("virtio_disk_intr status");
    800066b6:	00002517          	auipc	a0,0x2
    800066ba:	1da50513          	addi	a0,a0,474 # 80008890 <syscalls+0x3b0>
    800066be:	ffffa097          	auipc	ra,0xffffa
    800066c2:	e80080e7          	jalr	-384(ra) # 8000053e <panic>

00000000800066c6 <cas>:
    800066c6:	100522af          	lr.w	t0,(a0)
    800066ca:	00b29563          	bne	t0,a1,800066d4 <fail>
    800066ce:	18c5252f          	sc.w	a0,a2,(a0)
    800066d2:	8082                	ret

00000000800066d4 <fail>:
    800066d4:	4505                	li	a0,1
    800066d6:	8082                	ret
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
