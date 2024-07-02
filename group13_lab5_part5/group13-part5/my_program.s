loadi 4 0x08    // r4 = 'b 0000 1000
sll r4,r4,0x02  // r4 = 'b 0010 0000
loadi 5 0x08    // r5 = 'b 0000 1000
srl r5,r5,0x02  // r5 = 'b 0000 0010
loadi 6 0x80    // r6 = 'b 1000 0000
sra r6,r6,0x02  // r6 = 'b 1110 0000
loadi 7 0x02    // r7 = 'b 0000 0010
ror r7,r7,0x02  // r7 = 'b 1000 0000