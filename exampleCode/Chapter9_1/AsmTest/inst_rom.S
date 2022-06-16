   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori  $3,$0,0xeeff
   ori  $2,$0,0xccdd
   ori  $1,$0,0xaabb
   nop
    
   sw   $3,0x8
   nop
   nop      
   lw   $1,0x8      
    
# _loop:
#    j _loop
#    nop
