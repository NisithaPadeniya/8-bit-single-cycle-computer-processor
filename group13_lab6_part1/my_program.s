loadi 4 0x05
loadi 3 0x09
swd 3 4     // store r3  val in memory[r4=0x05]
swi 4 0x03  // store r4 val in memory[0x03] 
lwd 1 4     // load to r1 val in (memory[r4=0x05])=9 
lwi 2 0x03  // load to r2 val in (memory[0x03])=5