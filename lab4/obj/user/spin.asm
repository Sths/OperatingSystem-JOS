
obj/user/spin:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 87 00 00 00       	call   8000b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 a0 0f 80 00       	push   $0x800fa0
  800040:	e8 67 01 00 00       	call   8001ac <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 96 0c 00 00       	call   800ce0 <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 18 10 80 00       	push   $0x801018
  80005b:	e8 4c 01 00 00       	call   8001ac <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 c8 0f 80 00       	push   $0x800fc8
  80006d:	e8 3a 01 00 00       	call   8001ac <cprintf>
	sys_yield();
  800072:	e8 46 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  800077:	e8 41 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  80007c:	e8 3c 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  800081:	e8 37 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  800086:	e8 32 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  80008b:	e8 2d 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  800090:	e8 28 0b 00 00       	call   800bbd <sys_yield>
	sys_yield();
  800095:	e8 23 0b 00 00       	call   800bbd <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 f0 0f 80 00 	movl   $0x800ff0,(%esp)
  8000a1:	e8 06 01 00 00       	call   8001ac <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 c9 0a 00 00       	call   800b77 <sys_env_destroy>
  8000ae:	83 c4 10             	add    $0x10,%esp
}
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c3:	e8 d1 0a 00 00       	call   800b99 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d4:	c1 e0 07             	shl    $0x7,%eax
  8000d7:	29 d0                	sub    %edx,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 f6                	test   %esi,%esi
  8000e5:	7e 07                	jle    8000ee <libmain+0x36>
		binaryname = argv[0];
  8000e7:	8b 03                	mov    (%ebx),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	53                   	push   %ebx
  8000f2:	56                   	push   %esi
  8000f3:	e8 3c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0b 00 00 00       	call   800108 <exit>
  8000fd:	83 c4 10             	add    $0x10,%esp
}
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010e:	6a 00                	push   $0x0
  800110:	e8 62 0a 00 00       	call   800b77 <sys_env_destroy>
  800115:	83 c4 10             	add    $0x10,%esp
}
  800118:	c9                   	leave  
  800119:	c3                   	ret    
	...

0080011c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	53                   	push   %ebx
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012f:	40                   	inc    %eax
  800130:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800132:	3d ff 00 00 00       	cmp    $0xff,%eax
  800137:	75 1a                	jne    800153 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	68 ff 00 00 00       	push   $0xff
  800141:	8d 43 08             	lea    0x8(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	e8 e3 09 00 00       	call   800b2d <sys_cputs>
		b->idx = 0;
  80014a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800150:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800153:	ff 43 04             	incl   0x4(%ebx)
}
  800156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800164:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016b:	00 00 00 
	b.cnt = 0;
  80016e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800175:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	68 1c 01 80 00       	push   $0x80011c
  80018a:	e8 82 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	83 c4 08             	add    $0x8,%esp
  800192:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800198:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 89 09 00 00       	call   800b2d <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	e8 9d ff ff ff       	call   80015b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 2c             	sub    $0x2c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001ed:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001f0:	72 0c                	jb     8001fe <printnum+0x3e>
  8001f2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001f5:	76 07                	jbe    8001fe <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	4b                   	dec    %ebx
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7f 31                	jg     80022d <printnum+0x6d>
  8001fc:	eb 3f                	jmp    80023d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	57                   	push   %edi
  800202:	4b                   	dec    %ebx
  800203:	53                   	push   %ebx
  800204:	50                   	push   %eax
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 d4             	pushl  -0x2c(%ebp)
  80020b:	ff 75 d0             	pushl  -0x30(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 3f 0b 00 00       	call   800d58 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800223:	e8 98 ff ff ff       	call   8001c0 <printnum>
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	eb 10                	jmp    80023d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	57                   	push   %edi
  800232:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800235:	4b                   	dec    %ebx
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	85 db                	test   %ebx,%ebx
  80023b:	7f f0                	jg     80022d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	56                   	push   %esi
  800241:	83 ec 04             	sub    $0x4,%esp
  800244:	ff 75 d4             	pushl  -0x2c(%ebp)
  800247:	ff 75 d0             	pushl  -0x30(%ebp)
  80024a:	ff 75 dc             	pushl  -0x24(%ebp)
  80024d:	ff 75 d8             	pushl  -0x28(%ebp)
  800250:	e8 1f 0c 00 00       	call   800e74 <__umoddi3>
  800255:	83 c4 14             	add    $0x14,%esp
  800258:	0f be 80 40 10 80 00 	movsbl 0x801040(%eax),%eax
  80025f:	50                   	push   %eax
  800260:	ff 55 e4             	call   *-0x1c(%ebp)
  800263:	83 c4 10             	add    $0x10,%esp
}
  800266:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5f                   	pop    %edi
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800271:	83 fa 01             	cmp    $0x1,%edx
  800274:	7e 0e                	jle    800284 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800276:	8b 10                	mov    (%eax),%edx
  800278:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 02                	mov    (%edx),%eax
  80027f:	8b 52 04             	mov    0x4(%edx),%edx
  800282:	eb 22                	jmp    8002a6 <getuint+0x38>
	else if (lflag)
  800284:	85 d2                	test   %edx,%edx
  800286:	74 10                	je     800298 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	ba 00 00 00 00       	mov    $0x0,%edx
  800296:	eb 0e                	jmp    8002a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ab:	83 fa 01             	cmp    $0x1,%edx
  8002ae:	7e 0e                	jle    8002be <getint+0x16>
		return va_arg(*ap, long long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	8b 52 04             	mov    0x4(%edx),%edx
  8002bc:	eb 1a                	jmp    8002d8 <getint+0x30>
	else if (lflag)
  8002be:	85 d2                	test   %edx,%edx
  8002c0:	74 0c                	je     8002ce <getint+0x26>
		return va_arg(*ap, long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	99                   	cltd   
  8002cc:	eb 0a                	jmp    8002d8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	99                   	cltd   
}
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e8:	73 08                	jae    8002f2 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ed:	88 0a                	mov    %cl,(%edx)
  8002ef:	42                   	inc    %edx
  8002f0:	89 10                	mov    %edx,(%eax)
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fd:	50                   	push   %eax
  8002fe:	ff 75 10             	pushl  0x10(%ebp)
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	ff 75 08             	pushl  0x8(%ebp)
  800307:	e8 05 00 00 00       	call   800311 <vprintfmt>
	va_end(ap);
  80030c:	83 c4 10             	add    $0x10,%esp
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
  800317:	83 ec 2c             	sub    $0x2c,%esp
  80031a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80031d:	8b 75 10             	mov    0x10(%ebp),%esi
  800320:	eb 13                	jmp    800335 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800322:	85 c0                	test   %eax,%eax
  800324:	0f 84 6d 03 00 00    	je     800697 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	57                   	push   %edi
  80032e:	50                   	push   %eax
  80032f:	ff 55 08             	call   *0x8(%ebp)
  800332:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800335:	0f b6 06             	movzbl (%esi),%eax
  800338:	46                   	inc    %esi
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e4                	jne    800322 <vprintfmt+0x11>
  80033e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800342:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800349:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800350:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035c:	eb 28                	jmp    800386 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800364:	eb 20                	jmp    800386 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80036c:	eb 18                	jmp    800386 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800370:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800377:	eb 0d                	jmp    800386 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800379:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80037c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8a 06                	mov    (%esi),%al
  800388:	0f b6 d0             	movzbl %al,%edx
  80038b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80038e:	83 e8 23             	sub    $0x23,%eax
  800391:	3c 55                	cmp    $0x55,%al
  800393:	0f 87 e0 02 00 00    	ja     800679 <vprintfmt+0x368>
  800399:	0f b6 c0             	movzbl %al,%eax
  80039c:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a3:	83 ea 30             	sub    $0x30,%edx
  8003a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003a9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003ac:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003af:	83 fa 09             	cmp    $0x9,%edx
  8003b2:	77 44                	ja     8003f8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	89 de                	mov    %ebx,%esi
  8003b6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ba:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003bd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003c7:	83 fb 09             	cmp    $0x9,%ebx
  8003ca:	76 ed                	jbe    8003b9 <vprintfmt+0xa8>
  8003cc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003cf:	eb 29                	jmp    8003fa <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e1:	eb 17                	jmp    8003fa <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e7:	78 85                	js     80036e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	89 de                	mov    %ebx,%esi
  8003eb:	eb 99                	jmp    800386 <vprintfmt+0x75>
  8003ed:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ef:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003f6:	eb 8e                	jmp    800386 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fe:	79 86                	jns    800386 <vprintfmt+0x75>
  800400:	e9 74 ff ff ff       	jmp    800379 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800405:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 de                	mov    %ebx,%esi
  800408:	e9 79 ff ff ff       	jmp    800386 <vprintfmt+0x75>
  80040d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	57                   	push   %edi
  80041d:	ff 30                	pushl  (%eax)
  80041f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800422:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800428:	e9 08 ff ff ff       	jmp    800335 <vprintfmt+0x24>
  80042d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	85 c0                	test   %eax,%eax
  80043d:	79 02                	jns    800441 <vprintfmt+0x130>
  80043f:	f7 d8                	neg    %eax
  800441:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 08             	cmp    $0x8,%eax
  800446:	7f 0b                	jg     800453 <vprintfmt+0x142>
  800448:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  80044f:	85 c0                	test   %eax,%eax
  800451:	75 1a                	jne    80046d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800453:	52                   	push   %edx
  800454:	68 58 10 80 00       	push   $0x801058
  800459:	57                   	push   %edi
  80045a:	ff 75 08             	pushl  0x8(%ebp)
  80045d:	e8 92 fe ff ff       	call   8002f4 <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800468:	e9 c8 fe ff ff       	jmp    800335 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80046d:	50                   	push   %eax
  80046e:	68 61 10 80 00       	push   $0x801061
  800473:	57                   	push   %edi
  800474:	ff 75 08             	pushl  0x8(%ebp)
  800477:	e8 78 fe ff ff       	call   8002f4 <printfmt>
  80047c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800482:	e9 ae fe ff ff       	jmp    800335 <vprintfmt+0x24>
  800487:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80048a:	89 de                	mov    %ebx,%esi
  80048c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80048f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	75 07                	jne    8004ab <vprintfmt+0x19a>
				p = "(null)";
  8004a4:	c7 45 d0 51 10 80 00 	movl   $0x801051,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004ab:	85 db                	test   %ebx,%ebx
  8004ad:	7e 42                	jle    8004f1 <vprintfmt+0x1e0>
  8004af:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004b3:	74 3c                	je     8004f1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	51                   	push   %ecx
  8004b9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bc:	e8 6f 02 00 00       	call   800730 <strnlen>
  8004c1:	29 c3                	sub    %eax,%ebx
  8004c3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 db                	test   %ebx,%ebx
  8004cb:	7e 24                	jle    8004f1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004cd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004d1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	57                   	push   %edi
  8004db:	53                   	push   %ebx
  8004dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	4e                   	dec    %esi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 f6                	test   %esi,%esi
  8004e5:	7f f0                	jg     8004d7 <vprintfmt+0x1c6>
  8004e7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004f4:	0f be 02             	movsbl (%edx),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 47                	jne    800542 <vprintfmt+0x231>
  8004fb:	eb 37                	jmp    800534 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800501:	74 16                	je     800519 <vprintfmt+0x208>
  800503:	8d 50 e0             	lea    -0x20(%eax),%edx
  800506:	83 fa 5e             	cmp    $0x5e,%edx
  800509:	76 0e                	jbe    800519 <vprintfmt+0x208>
					putch('?', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	57                   	push   %edi
  80050f:	6a 3f                	push   $0x3f
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb 0b                	jmp    800524 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	57                   	push   %edi
  80051d:	50                   	push   %eax
  80051e:	ff 55 08             	call   *0x8(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800524:	ff 4d e4             	decl   -0x1c(%ebp)
  800527:	0f be 03             	movsbl (%ebx),%eax
  80052a:	85 c0                	test   %eax,%eax
  80052c:	74 03                	je     800531 <vprintfmt+0x220>
  80052e:	43                   	inc    %ebx
  80052f:	eb 1b                	jmp    80054c <vprintfmt+0x23b>
  800531:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800534:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800538:	7f 1e                	jg     800558 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80053d:	e9 f3 fd ff ff       	jmp    800335 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800542:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800545:	43                   	inc    %ebx
  800546:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800549:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80054c:	85 f6                	test   %esi,%esi
  80054e:	78 ad                	js     8004fd <vprintfmt+0x1ec>
  800550:	4e                   	dec    %esi
  800551:	79 aa                	jns    8004fd <vprintfmt+0x1ec>
  800553:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800556:	eb dc                	jmp    800534 <vprintfmt+0x223>
  800558:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	57                   	push   %edi
  80055f:	6a 20                	push   $0x20
  800561:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800564:	4b                   	dec    %ebx
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	85 db                	test   %ebx,%ebx
  80056a:	7f ef                	jg     80055b <vprintfmt+0x24a>
  80056c:	e9 c4 fd ff ff       	jmp    800335 <vprintfmt+0x24>
  800571:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800574:	89 ca                	mov    %ecx,%edx
  800576:	8d 45 14             	lea    0x14(%ebp),%eax
  800579:	e8 2a fd ff ff       	call   8002a8 <getint>
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800582:	85 d2                	test   %edx,%edx
  800584:	78 0a                	js     800590 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058b:	e9 b0 00 00 00       	jmp    800640 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	57                   	push   %edi
  800594:	6a 2d                	push   $0x2d
  800596:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800599:	f7 db                	neg    %ebx
  80059b:	83 d6 00             	adc    $0x0,%esi
  80059e:	f7 de                	neg    %esi
  8005a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 93 00 00 00       	jmp    800640 <vprintfmt+0x32f>
  8005ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b0:	89 ca                	mov    %ecx,%edx
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	e8 b4 fc ff ff       	call   80026e <getuint>
  8005ba:	89 c3                	mov    %eax,%ebx
  8005bc:	89 d6                	mov    %edx,%esi
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c3:	eb 7b                	jmp    800640 <vprintfmt+0x32f>
  8005c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005c8:	89 ca                	mov    %ecx,%edx
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 d6 fc ff ff       	call   8002a8 <getint>
  8005d2:	89 c3                	mov    %eax,%ebx
  8005d4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	78 07                	js     8005e1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005da:	b8 08 00 00 00       	mov    $0x8,%eax
  8005df:	eb 5f                	jmp    800640 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	57                   	push   %edi
  8005e5:	6a 2d                	push   $0x2d
  8005e7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005ea:	f7 db                	neg    %ebx
  8005ec:	83 d6 00             	adc    $0x0,%esi
  8005ef:	f7 de                	neg    %esi
  8005f1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f9:	eb 45                	jmp    800640 <vprintfmt+0x32f>
  8005fb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	57                   	push   %edi
  800602:	6a 30                	push   $0x30
  800604:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	57                   	push   %edi
  80060b:	6a 78                	push   $0x78
  80060d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800619:	8b 18                	mov    (%eax),%ebx
  80061b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800620:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800623:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800628:	eb 16                	jmp    800640 <vprintfmt+0x32f>
  80062a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062d:	89 ca                	mov    %ecx,%edx
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 37 fc ff ff       	call   80026e <getuint>
  800637:	89 c3                	mov    %eax,%ebx
  800639:	89 d6                	mov    %edx,%esi
			base = 16;
  80063b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800647:	52                   	push   %edx
  800648:	ff 75 e4             	pushl  -0x1c(%ebp)
  80064b:	50                   	push   %eax
  80064c:	56                   	push   %esi
  80064d:	53                   	push   %ebx
  80064e:	89 fa                	mov    %edi,%edx
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	e8 68 fb ff ff       	call   8001c0 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065e:	e9 d2 fc ff ff       	jmp    800335 <vprintfmt+0x24>
  800663:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	57                   	push   %edi
  80066a:	52                   	push   %edx
  80066b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800674:	e9 bc fc ff ff       	jmp    800335 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	57                   	push   %edi
  80067d:	6a 25                	push   $0x25
  80067f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800682:	83 c4 10             	add    $0x10,%esp
  800685:	eb 02                	jmp    800689 <vprintfmt+0x378>
  800687:	89 c6                	mov    %eax,%esi
  800689:	8d 46 ff             	lea    -0x1(%esi),%eax
  80068c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800690:	75 f5                	jne    800687 <vprintfmt+0x376>
  800692:	e9 9e fc ff ff       	jmp    800335 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800697:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069a:	5b                   	pop    %ebx
  80069b:	5e                   	pop    %esi
  80069c:	5f                   	pop    %edi
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	83 ec 18             	sub    $0x18,%esp
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 26                	je     8006e6 <vsnprintf+0x47>
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	7e 29                	jle    8006ed <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c4:	ff 75 14             	pushl  0x14(%ebp)
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	68 da 02 80 00       	push   $0x8002da
  8006d3:	e8 39 fc ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 0c                	jmp    8006f2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006eb:	eb 05                	jmp    8006f2 <vsnprintf+0x53>
  8006ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fd:	50                   	push   %eax
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 93 ff ff ff       	call   80069f <vsnprintf>
	va_end(ap);

	return rc;
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    
	...

00800710 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	80 3a 00             	cmpb   $0x0,(%edx)
  800719:	74 0e                	je     800729 <strlen+0x19>
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800720:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800721:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800725:	75 f9                	jne    800720 <strlen+0x10>
  800727:	eb 05                	jmp    80072e <strlen+0x1e>
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800739:	85 d2                	test   %edx,%edx
  80073b:	74 17                	je     800754 <strnlen+0x24>
  80073d:	80 39 00             	cmpb   $0x0,(%ecx)
  800740:	74 19                	je     80075b <strnlen+0x2b>
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800747:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800748:	39 d0                	cmp    %edx,%eax
  80074a:	74 14                	je     800760 <strnlen+0x30>
  80074c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800750:	75 f5                	jne    800747 <strnlen+0x17>
  800752:	eb 0c                	jmp    800760 <strnlen+0x30>
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	eb 05                	jmp    800760 <strnlen+0x30>
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	53                   	push   %ebx
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076c:	ba 00 00 00 00       	mov    $0x0,%edx
  800771:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800774:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800777:	42                   	inc    %edx
  800778:	84 c9                	test   %cl,%cl
  80077a:	75 f5                	jne    800771 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077c:	5b                   	pop    %ebx
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800786:	53                   	push   %ebx
  800787:	e8 84 ff ff ff       	call   800710 <strlen>
  80078c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800795:	50                   	push   %eax
  800796:	e8 c7 ff ff ff       	call   800762 <strcpy>
	return dst;
}
  80079b:	89 d8                	mov    %ebx,%eax
  80079d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	56                   	push   %esi
  8007a6:	53                   	push   %ebx
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b0:	85 f6                	test   %esi,%esi
  8007b2:	74 15                	je     8007c9 <strncpy+0x27>
  8007b4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007b9:	8a 1a                	mov    (%edx),%bl
  8007bb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007be:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	41                   	inc    %ecx
  8007c5:	39 ce                	cmp    %ecx,%esi
  8007c7:	77 f0                	ja     8007b9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	57                   	push   %edi
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007dc:	85 f6                	test   %esi,%esi
  8007de:	74 32                	je     800812 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007e0:	83 fe 01             	cmp    $0x1,%esi
  8007e3:	74 22                	je     800807 <strlcpy+0x3a>
  8007e5:	8a 0b                	mov    (%ebx),%cl
  8007e7:	84 c9                	test   %cl,%cl
  8007e9:	74 20                	je     80080b <strlcpy+0x3e>
  8007eb:	89 f8                	mov    %edi,%eax
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007f2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f5:	88 08                	mov    %cl,(%eax)
  8007f7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f8:	39 f2                	cmp    %esi,%edx
  8007fa:	74 11                	je     80080d <strlcpy+0x40>
  8007fc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800800:	42                   	inc    %edx
  800801:	84 c9                	test   %cl,%cl
  800803:	75 f0                	jne    8007f5 <strlcpy+0x28>
  800805:	eb 06                	jmp    80080d <strlcpy+0x40>
  800807:	89 f8                	mov    %edi,%eax
  800809:	eb 02                	jmp    80080d <strlcpy+0x40>
  80080b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80080d:	c6 00 00             	movb   $0x0,(%eax)
  800810:	eb 02                	jmp    800814 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800812:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800814:	29 f8                	sub    %edi,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5f                   	pop    %edi
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800824:	8a 01                	mov    (%ecx),%al
  800826:	84 c0                	test   %al,%al
  800828:	74 10                	je     80083a <strcmp+0x1f>
  80082a:	3a 02                	cmp    (%edx),%al
  80082c:	75 0c                	jne    80083a <strcmp+0x1f>
		p++, q++;
  80082e:	41                   	inc    %ecx
  80082f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800830:	8a 01                	mov    (%ecx),%al
  800832:	84 c0                	test   %al,%al
  800834:	74 04                	je     80083a <strcmp+0x1f>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	74 f4                	je     80082e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 c0             	movzbl %al,%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
}
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 55 08             	mov    0x8(%ebp),%edx
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800851:	85 c0                	test   %eax,%eax
  800853:	74 1b                	je     800870 <strncmp+0x2c>
  800855:	8a 1a                	mov    (%edx),%bl
  800857:	84 db                	test   %bl,%bl
  800859:	74 24                	je     80087f <strncmp+0x3b>
  80085b:	3a 19                	cmp    (%ecx),%bl
  80085d:	75 20                	jne    80087f <strncmp+0x3b>
  80085f:	48                   	dec    %eax
  800860:	74 15                	je     800877 <strncmp+0x33>
		n--, p++, q++;
  800862:	42                   	inc    %edx
  800863:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800864:	8a 1a                	mov    (%edx),%bl
  800866:	84 db                	test   %bl,%bl
  800868:	74 15                	je     80087f <strncmp+0x3b>
  80086a:	3a 19                	cmp    (%ecx),%bl
  80086c:	74 f1                	je     80085f <strncmp+0x1b>
  80086e:	eb 0f                	jmp    80087f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	eb 05                	jmp    80087c <strncmp+0x38>
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087c:	5b                   	pop    %ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 02             	movzbl (%edx),%eax
  800882:	0f b6 11             	movzbl (%ecx),%edx
  800885:	29 d0                	sub    %edx,%eax
  800887:	eb f3                	jmp    80087c <strncmp+0x38>

00800889 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	74 18                	je     8008b0 <strchr+0x27>
		if (*s == c)
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	75 06                	jne    8008a2 <strchr+0x19>
  80089c:	eb 17                	jmp    8008b5 <strchr+0x2c>
  80089e:	38 ca                	cmp    %cl,%dl
  8008a0:	74 13                	je     8008b5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a2:	40                   	inc    %eax
  8008a3:	8a 10                	mov    (%eax),%dl
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	75 f5                	jne    80089e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ae:	eb 05                	jmp    8008b5 <strchr+0x2c>
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c0:	8a 10                	mov    (%eax),%dl
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	74 11                	je     8008d7 <strfind+0x20>
		if (*s == c)
  8008c6:	38 ca                	cmp    %cl,%dl
  8008c8:	75 06                	jne    8008d0 <strfind+0x19>
  8008ca:	eb 0b                	jmp    8008d7 <strfind+0x20>
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 07                	je     8008d7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	40                   	inc    %eax
  8008d1:	8a 10                	mov    (%eax),%dl
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f5                	jne    8008cc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    

008008d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 30                	je     80091c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 25                	jne    800919 <memset+0x40>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 20                	jne    800919 <memset+0x40>
		c &= 0xFF;
  8008f9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d3                	mov    %edx,%ebx
  8008fe:	c1 e3 08             	shl    $0x8,%ebx
  800901:	89 d6                	mov    %edx,%esi
  800903:	c1 e6 18             	shl    $0x18,%esi
  800906:	89 d0                	mov    %edx,%eax
  800908:	c1 e0 10             	shl    $0x10,%eax
  80090b:	09 f0                	or     %esi,%eax
  80090d:	09 d0                	or     %edx,%eax
  80090f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800911:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800914:	fc                   	cld    
  800915:	f3 ab                	rep stos %eax,%es:(%edi)
  800917:	eb 03                	jmp    80091c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800919:	fc                   	cld    
  80091a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091c:	89 f8                	mov    %edi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800931:	39 c6                	cmp    %eax,%esi
  800933:	73 34                	jae    800969 <memmove+0x46>
  800935:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800938:	39 d0                	cmp    %edx,%eax
  80093a:	73 2d                	jae    800969 <memmove+0x46>
		s += n;
		d += n;
  80093c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	f6 c2 03             	test   $0x3,%dl
  800942:	75 1b                	jne    80095f <memmove+0x3c>
  800944:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094a:	75 13                	jne    80095f <memmove+0x3c>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 0e                	jne    80095f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800951:	83 ef 04             	sub    $0x4,%edi
  800954:	8d 72 fc             	lea    -0x4(%edx),%esi
  800957:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095a:	fd                   	std    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 07                	jmp    800966 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095f:	4f                   	dec    %edi
  800960:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800963:	fd                   	std    
  800964:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800966:	fc                   	cld    
  800967:	eb 20                	jmp    800989 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096f:	75 13                	jne    800984 <memmove+0x61>
  800971:	a8 03                	test   $0x3,%al
  800973:	75 0f                	jne    800984 <memmove+0x61>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 0a                	jne    800984 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 05                	jmp    800989 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 85 ff ff ff       	call   800923 <memmove>
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ac:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	85 ff                	test   %edi,%edi
  8009b1:	74 32                	je     8009e5 <memcmp+0x45>
		if (*s1 != *s2)
  8009b3:	8a 03                	mov    (%ebx),%al
  8009b5:	8a 0e                	mov    (%esi),%cl
  8009b7:	38 c8                	cmp    %cl,%al
  8009b9:	74 19                	je     8009d4 <memcmp+0x34>
  8009bb:	eb 0d                	jmp    8009ca <memcmp+0x2a>
  8009bd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009c1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009c5:	42                   	inc    %edx
  8009c6:	38 c8                	cmp    %cl,%al
  8009c8:	74 10                	je     8009da <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	0f b6 c9             	movzbl %cl,%ecx
  8009d0:	29 c8                	sub    %ecx,%eax
  8009d2:	eb 16                	jmp    8009ea <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d4:	4f                   	dec    %edi
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	39 fa                	cmp    %edi,%edx
  8009dc:	75 df                	jne    8009bd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e3:	eb 05                	jmp    8009ea <memcmp+0x4a>
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	73 12                	jae    800a10 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fe:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	75 06                	jne    800a0b <memfind+0x1c>
  800a05:	eb 09                	jmp    800a10 <memfind+0x21>
  800a07:	38 08                	cmp    %cl,(%eax)
  800a09:	74 05                	je     800a10 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	40                   	inc    %eax
  800a0c:	39 c2                	cmp    %eax,%edx
  800a0e:	77 f7                	ja     800a07 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1e:	eb 01                	jmp    800a21 <strtol+0xf>
		s++;
  800a20:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	8a 02                	mov    (%edx),%al
  800a23:	3c 20                	cmp    $0x20,%al
  800a25:	74 f9                	je     800a20 <strtol+0xe>
  800a27:	3c 09                	cmp    $0x9,%al
  800a29:	74 f5                	je     800a20 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2b:	3c 2b                	cmp    $0x2b,%al
  800a2d:	75 08                	jne    800a37 <strtol+0x25>
		s++;
  800a2f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
  800a35:	eb 13                	jmp    800a4a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a37:	3c 2d                	cmp    $0x2d,%al
  800a39:	75 0a                	jne    800a45 <strtol+0x33>
		s++, neg = 1;
  800a3b:	8d 52 01             	lea    0x1(%edx),%edx
  800a3e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a43:	eb 05                	jmp    800a4a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	74 05                	je     800a53 <strtol+0x41>
  800a4e:	83 fb 10             	cmp    $0x10,%ebx
  800a51:	75 28                	jne    800a7b <strtol+0x69>
  800a53:	8a 02                	mov    (%edx),%al
  800a55:	3c 30                	cmp    $0x30,%al
  800a57:	75 10                	jne    800a69 <strtol+0x57>
  800a59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a5d:	75 0a                	jne    800a69 <strtol+0x57>
		s += 2, base = 16;
  800a5f:	83 c2 02             	add    $0x2,%edx
  800a62:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a67:	eb 12                	jmp    800a7b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	75 0e                	jne    800a7b <strtol+0x69>
  800a6d:	3c 30                	cmp    $0x30,%al
  800a6f:	75 05                	jne    800a76 <strtol+0x64>
		s++, base = 8;
  800a71:	42                   	inc    %edx
  800a72:	b3 08                	mov    $0x8,%bl
  800a74:	eb 05                	jmp    800a7b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a76:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a82:	8a 0a                	mov    (%edx),%cl
  800a84:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a87:	80 fb 09             	cmp    $0x9,%bl
  800a8a:	77 08                	ja     800a94 <strtol+0x82>
			dig = *s - '0';
  800a8c:	0f be c9             	movsbl %cl,%ecx
  800a8f:	83 e9 30             	sub    $0x30,%ecx
  800a92:	eb 1e                	jmp    800ab2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a94:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 08                	ja     800aa4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a9c:	0f be c9             	movsbl %cl,%ecx
  800a9f:	83 e9 57             	sub    $0x57,%ecx
  800aa2:	eb 0e                	jmp    800ab2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aa4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 13                	ja     800abf <strtol+0xad>
			dig = *s - 'A' + 10;
  800aac:	0f be c9             	movsbl %cl,%ecx
  800aaf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab2:	39 f1                	cmp    %esi,%ecx
  800ab4:	7d 0d                	jge    800ac3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ab6:	42                   	inc    %edx
  800ab7:	0f af c6             	imul   %esi,%eax
  800aba:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800abd:	eb c3                	jmp    800a82 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	89 c1                	mov    %eax,%ecx
  800ac1:	eb 02                	jmp    800ac5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac9:	74 05                	je     800ad0 <strtol+0xbe>
		*endptr = (char *) s;
  800acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ace:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ad0:	85 ff                	test   %edi,%edi
  800ad2:	74 04                	je     800ad8 <strtol+0xc6>
  800ad4:	89 c8                	mov    %ecx,%eax
  800ad6:	f7 d8                	neg    %eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    
  800add:	00 00                	add    %al,(%eax)
	...

00800ae0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	83 ec 1c             	sub    $0x1c,%esp
  800ae9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aec:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aef:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	8b 75 14             	mov    0x14(%ebp),%esi
  800af4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800af7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afd:	cd 30                	int    $0x30
  800aff:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b01:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b05:	74 1c                	je     800b23 <syscall+0x43>
  800b07:	85 c0                	test   %eax,%eax
  800b09:	7e 18                	jle    800b23 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	50                   	push   %eax
  800b0f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b12:	68 84 12 80 00       	push   $0x801284
  800b17:	6a 42                	push   $0x42
  800b19:	68 a1 12 80 00       	push   $0x8012a1
  800b1e:	e8 ed 01 00 00       	call   800d10 <_panic>

	return ret;
}
  800b23:	89 d0                	mov    %edx,%eax
  800b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	6a 00                	push   $0x0
  800b39:	ff 75 0c             	pushl  0xc(%ebp)
  800b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
  800b49:	e8 92 ff ff ff       	call   800ae0 <syscall>
  800b4e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	6a 00                	push   $0x0
  800b5f:	6a 00                	push   $0x0
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b70:	e8 6b ff ff ff       	call   800ae0 <syscall>
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b88:	ba 01 00 00 00       	mov    $0x1,%edx
  800b8d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b92:	e8 49 ff ff ff       	call   800ae0 <syscall>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b9f:	6a 00                	push   $0x0
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb6:	e8 25 ff ff ff       	call   800ae0 <syscall>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_yield>:

void
sys_yield(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bda:	e8 01 ff ff ff       	call   800ae0 <syscall>
  800bdf:	83 c4 10             	add    $0x10,%esp
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bea:	6a 00                	push   $0x0
  800bec:	6a 00                	push   $0x0
  800bee:	ff 75 10             	pushl  0x10(%ebp)
  800bf1:	ff 75 0c             	pushl  0xc(%ebp)
  800bf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfc:	b8 04 00 00 00       	mov    $0x4,%eax
  800c01:	e8 da fe ff ff       	call   800ae0 <syscall>
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c0e:	ff 75 18             	pushl  0x18(%ebp)
  800c11:	ff 75 14             	pushl  0x14(%ebp)
  800c14:	ff 75 10             	pushl  0x10(%ebp)
  800c17:	ff 75 0c             	pushl  0xc(%ebp)
  800c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c22:	b8 05 00 00 00       	mov    $0x5,%eax
  800c27:	e8 b4 fe ff ff       	call   800ae0 <syscall>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c34:	6a 00                	push   $0x0
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 0c             	pushl  0xc(%ebp)
  800c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c40:	ba 01 00 00 00       	mov    $0x1,%edx
  800c45:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4a:	e8 91 fe ff ff       	call   800ae0 <syscall>
}
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    

00800c51 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	6a 00                	push   $0x0
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c63:	ba 01 00 00 00       	mov    $0x1,%edx
  800c68:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6d:	e8 6e fe ff ff       	call   800ae0 <syscall>
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c7a:	6a 00                	push   $0x0
  800c7c:	6a 00                	push   $0x0
  800c7e:	6a 00                	push   $0x0
  800c80:	ff 75 0c             	pushl  0xc(%ebp)
  800c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c86:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c90:	e8 4b fe ff ff       	call   800ae0 <syscall>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c9d:	6a 00                	push   $0x0
  800c9f:	ff 75 14             	pushl  0x14(%ebp)
  800ca2:	ff 75 10             	pushl  0x10(%ebp)
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb5:	e8 26 fe ff ff       	call   800ae0 <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cc2:	6a 00                	push   $0x0
  800cc4:	6a 00                	push   $0x0
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccd:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd7:	e8 04 fe ff ff       	call   800ae0 <syscall>
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    
	...

00800ce0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800ce6:	68 bb 12 80 00       	push   $0x8012bb
  800ceb:	6a 52                	push   $0x52
  800ced:	68 af 12 80 00       	push   $0x8012af
  800cf2:	e8 19 00 00 00       	call   800d10 <_panic>

00800cf7 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800cfd:	68 ba 12 80 00       	push   $0x8012ba
  800d02:	6a 59                	push   $0x59
  800d04:	68 af 12 80 00       	push   $0x8012af
  800d09:	e8 02 00 00 00       	call   800d10 <_panic>
	...

00800d10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d15:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d18:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d1e:	e8 76 fe ff ff       	call   800b99 <sys_getenvid>
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	ff 75 0c             	pushl  0xc(%ebp)
  800d29:	ff 75 08             	pushl  0x8(%ebp)
  800d2c:	53                   	push   %ebx
  800d2d:	50                   	push   %eax
  800d2e:	68 d0 12 80 00       	push   $0x8012d0
  800d33:	e8 74 f4 ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d38:	83 c4 18             	add    $0x18,%esp
  800d3b:	56                   	push   %esi
  800d3c:	ff 75 10             	pushl  0x10(%ebp)
  800d3f:	e8 17 f4 ff ff       	call   80015b <vcprintf>
	cprintf("\n");
  800d44:	c7 04 24 34 10 80 00 	movl   $0x801034,(%esp)
  800d4b:	e8 5c f4 ff ff       	call   8001ac <cprintf>
  800d50:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d53:	cc                   	int3   
  800d54:	eb fd                	jmp    800d53 <_panic+0x43>
	...

00800d58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	83 ec 10             	sub    $0x10,%esp
  800d60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d66:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	75 2e                	jne    800da4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d76:	39 f1                	cmp    %esi,%ecx
  800d78:	77 5a                	ja     800dd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d7a:	85 c9                	test   %ecx,%ecx
  800d7c:	75 0b                	jne    800d89 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d83:	31 d2                	xor    %edx,%edx
  800d85:	f7 f1                	div    %ecx
  800d87:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d89:	31 d2                	xor    %edx,%edx
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	f7 f1                	div    %ecx
  800d8f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d91:	89 f8                	mov    %edi,%eax
  800d93:	f7 f1                	div    %ecx
  800d95:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d97:	89 f8                	mov    %edi,%eax
  800d99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    
  800da2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800da4:	39 f0                	cmp    %esi,%eax
  800da6:	77 1c                	ja     800dc4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800da8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800dab:	83 f7 1f             	xor    $0x1f,%edi
  800dae:	75 3c                	jne    800dec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db0:	39 f0                	cmp    %esi,%eax
  800db2:	0f 82 90 00 00 00    	jb     800e48 <__udivdi3+0xf0>
  800db8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dbb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dbe:	0f 86 84 00 00 00    	jbe    800e48 <__udivdi3+0xf0>
  800dc4:	31 f6                	xor    %esi,%esi
  800dc6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc8:	89 f8                	mov    %edi,%eax
  800dca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    
  800dd3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd4:	89 f2                	mov    %esi,%edx
  800dd6:	89 f8                	mov    %edi,%eax
  800dd8:	f7 f1                	div    %ecx
  800dda:	89 c7                	mov    %eax,%edi
  800ddc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dde:	89 f8                	mov    %edi,%eax
  800de0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    
  800de9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dec:	89 f9                	mov    %edi,%ecx
  800dee:	d3 e0                	shl    %cl,%eax
  800df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800df3:	b8 20 00 00 00       	mov    $0x20,%eax
  800df8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dfd:	88 c1                	mov    %al,%cl
  800dff:	d3 ea                	shr    %cl,%edx
  800e01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e04:	09 ca                	or     %ecx,%edx
  800e06:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e0c:	89 f9                	mov    %edi,%ecx
  800e0e:	d3 e2                	shl    %cl,%edx
  800e10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e13:	89 f2                	mov    %esi,%edx
  800e15:	88 c1                	mov    %al,%cl
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e1c:	89 f2                	mov    %esi,%edx
  800e1e:	89 f9                	mov    %edi,%ecx
  800e20:	d3 e2                	shl    %cl,%edx
  800e22:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e25:	88 c1                	mov    %al,%cl
  800e27:	d3 ee                	shr    %cl,%esi
  800e29:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e2e:	89 f0                	mov    %esi,%eax
  800e30:	89 ca                	mov    %ecx,%edx
  800e32:	f7 75 ec             	divl   -0x14(%ebp)
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e39:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e3c:	39 d1                	cmp    %edx,%ecx
  800e3e:	72 28                	jb     800e68 <__udivdi3+0x110>
  800e40:	74 1a                	je     800e5c <__udivdi3+0x104>
  800e42:	89 f7                	mov    %esi,%edi
  800e44:	31 f6                	xor    %esi,%esi
  800e46:	eb 80                	jmp    800dc8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e48:	31 f6                	xor    %esi,%esi
  800e4a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    
  800e5a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e5f:	89 f9                	mov    %edi,%ecx
  800e61:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e63:	39 c2                	cmp    %eax,%edx
  800e65:	73 db                	jae    800e42 <__udivdi3+0xea>
  800e67:	90                   	nop
		{
		  q0--;
  800e68:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e6b:	31 f6                	xor    %esi,%esi
  800e6d:	e9 56 ff ff ff       	jmp    800dc8 <__udivdi3+0x70>
	...

00800e74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	83 ec 20             	sub    $0x20,%esp
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e91:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e93:	85 ff                	test   %edi,%edi
  800e95:	75 15                	jne    800eac <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e97:	39 f1                	cmp    %esi,%ecx
  800e99:	0f 86 99 00 00 00    	jbe    800f38 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e9f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ea1:	89 d0                	mov    %edx,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea5:	83 c4 20             	add    $0x20,%esp
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eac:	39 f7                	cmp    %esi,%edi
  800eae:	0f 87 a4 00 00 00    	ja     800f58 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eb4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800eb7:	83 f0 1f             	xor    $0x1f,%eax
  800eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ebd:	0f 84 a1 00 00 00    	je     800f64 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec3:	89 f8                	mov    %edi,%eax
  800ec5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ec8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800eca:	bf 20 00 00 00       	mov    $0x20,%edi
  800ecf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ed2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	09 c2                	or     %eax,%edx
  800edb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ee4:	d3 e0                	shl    %cl,%eax
  800ee6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ee9:	89 f2                	mov    %esi,%edx
  800eeb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ef0:	d3 e0                	shl    %cl,%eax
  800ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ef8:	89 f9                	mov    %edi,%ecx
  800efa:	d3 e8                	shr    %cl,%eax
  800efc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800efe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	f7 75 f0             	divl   -0x10(%ebp)
  800f05:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f07:	f7 65 f4             	mull   -0xc(%ebp)
  800f0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f0d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f0f:	39 d6                	cmp    %edx,%esi
  800f11:	72 71                	jb     800f84 <__umoddi3+0x110>
  800f13:	74 7f                	je     800f94 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f18:	29 c8                	sub    %ecx,%eax
  800f1a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f1c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f1f:	d3 e8                	shr    %cl,%eax
  800f21:	89 f2                	mov    %esi,%edx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f27:	09 d0                	or     %edx,%eax
  800f29:	89 f2                	mov    %esi,%edx
  800f2b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f2e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f30:	83 c4 20             	add    $0x20,%esp
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    
  800f37:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f38:	85 c9                	test   %ecx,%ecx
  800f3a:	75 0b                	jne    800f47 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f41:	31 d2                	xor    %edx,%edx
  800f43:	f7 f1                	div    %ecx
  800f45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	31 d2                	xor    %edx,%edx
  800f4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f50:	f7 f1                	div    %ecx
  800f52:	e9 4a ff ff ff       	jmp    800ea1 <__umoddi3+0x2d>
  800f57:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f58:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    
  800f61:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f64:	39 f7                	cmp    %esi,%edi
  800f66:	72 05                	jb     800f6d <__umoddi3+0xf9>
  800f68:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f6b:	77 0c                	ja     800f79 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f72:	29 c8                	sub    %ecx,%eax
  800f74:	19 fa                	sbb    %edi,%edx
  800f76:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7c:	83 c4 20             	add    $0x20,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    
  800f83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f84:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f87:	89 c1                	mov    %eax,%ecx
  800f89:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f8c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f8f:	eb 84                	jmp    800f15 <__umoddi3+0xa1>
  800f91:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f97:	72 eb                	jb     800f84 <__umoddi3+0x110>
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	e9 75 ff ff ff       	jmp    800f15 <__umoddi3+0xa1>
