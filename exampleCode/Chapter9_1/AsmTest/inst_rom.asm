
inst_rom.om:     file format elf32-tradbigmips

Disassembly of section .text:

00000000 <_start>:
   0:	3403eeff 	li	v1,0xeeff
   4:	3402ccdd 	li	v0,0xccdd
   8:	3401aabb 	li	at,0xaabb
   c:	00000000 	nop
  10:	ac030008 	sw	v1,8(zero)
	...
  1c:	8c010008 	lw	at,8(zero)
Disassembly of section .reginfo:

00000000 <_ram_end-0x20>:
   0:	0000000e 	0xe
	...
