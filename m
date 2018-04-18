From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 18 Apr 2018 21:38:31 +0800
Subject: [lustre-devel] [cfs_trace_lock_tcd] BUG: unable to handle kernel
 NULL pointer dereference at 00000050
Message-ID: <20180418133831.uef7d77ejdyjtxgh@wfg-t540p.sh.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, lkp@01.org, Denis Petrovic <denis.petrovic@edu.ece.fr>, Linus Torvalds <torvalds@linux-foundation.org>, lustre-devel@lists.lustre.org

Hello,

FYI this happens in mainline kernel 4.17.0-rc1.
It looks like a new regression.

It occurs in 5 out of 5 boots.

[    6.524361] ledtrig-cpu: registered to indicate activity on CPUs
[    6.527658] NET: Registered protocol family 4
[    6.528191] comedi: version 0.7.76 - http://www.comedi.org
[    6.528851] LNetError: 1:0:(module.c:546:libcfs_init()) misc_register: error -16
[    7.220272] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
[    7.586283] BUG: unable to handle kernel NULL pointer dereference at 00000050
[    7.586962] *pdpt = 0000000000000000 *pde = f000ff53f000ff53
[    7.587002] Oops: 0000 [#1] PREEMPT
[    7.587002] CPU: 0 PID: 1 Comm: swapper Not tainted 4.17.0-rc1 #1
[    7.587002] EIP: cfs_trace_lock_tcd+0xb/0xa0:
						cfs_trace_lock_tcd at drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c:149
[    7.587002] EFLAGS: 00210246 CPU: 0
[    7.587002] EAX: 00000000 EBX: 00000000 ECX: 81fcb588 EDX: 00000000
[    7.587002] ESI: 00001800 EDI: 8f5d1e08 EBP: 8f5d1d7c ESP: 8f5d1d70
[    7.587002]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[    7.587002] CR0: 80050033 CR2: 00000050 CR3: 022f0000 CR4: 000006b0
[    7.587002] Call Trace:
[    7.587002]  libcfs_debug_vmsg2+0x8f/0x82f:
						libcfs_debug_vmsg2 at drivers/staging/lustre/lnet/libcfs/tracefile.c:317
[    7.587002]  ? trace_irq_enable_rcuidle+0x25/0x62:
						static_key_false at include/linux/jump_label.h:206
						 (inlined by) trace_irq_enable_rcuidle at include/trace/events/preemptirq.h:40
[    7.587002]  ? slob_free+0x249/0x251:
						slob_free at mm/slob.c:421
[    7.587002]  libcfs_debug_msg+0x19/0x1b:
						libcfs_debug_msg at drivers/staging/lustre/lnet/libcfs/tracefile.c:287
[    7.587002]  ksocknal_startup+0xe77/0x12b2:
						ksocknal_startup at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2845 (discriminator 3)
[    7.587002]  ? lock_release+0x135/0x1ec:
						lock_release at kernel/locking/lockdep.c:3942
[    7.587002]  ? _raw_spin_unlock+0x3c/0x4b:
						__raw_spin_unlock at include/linux/spinlock_api_smp.h:152
						 (inlined by) _raw_spin_unlock at kernel/locking/spinlock.c:176
[    7.587002]  lnet_startup_lndni+0x4cd/0x9ec:
						lnet_startup_lndni at drivers/staging/lustre/lnet/lnet/api-ni.c:1304
[    7.587002]  LNetNIInit+0x880/0xa00:
						lnet_startup_lndnis at drivers/staging/lustre/lnet/lnet/api-ni.c:1385
						 (inlined by) LNetNIInit at drivers/staging/lustre/lnet/lnet/api-ni.c:1543
[    7.587002]  ? read_seqcount_retry+0x1b/0x22:
						read_seqcount_retry at include/linux/seqlock.h:222
						
						read_seqcount_retry+0x1b/0x22:
						read_seqcount_retry at include/linux/seqlock.h:222
						
						read_seqcount_retry+0x1b/0x22:
						read_seqcount_retry at include/linux/seqlock.h:222
[    7.587002]  srpc_startup+0x84/0x381:
						srpc_startup at drivers/staging/lustre/lnet/selftest/rpc.c:1613
[    7.587002]  lnet_selftest_init+0x2c4/0x5d9:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:134
[    7.587002]  ? lnet_selftest_exit+0x8d/0x8d:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:90
[    7.587002]  do_one_initcall+0x76/0x1d7:
						__read_once_size at include/linux/compiler.h:188
						 (inlined by) arch_atomic_read at arch/x86/include/asm/atomic.h:31
						 (inlined by) atomic_read at include/asm-generic/atomic-instrumented.h:22
						 (inlined by) static_key_count at include/linux/jump_label.h:194
						 (inlined by) static_key_false at include/linux/jump_label.h:206
						 (inlined by) trace_initcall_finish at include/trace/events/initcall.h:44
						 (inlined by) do_one_initcall at init/main.c:884
[    7.587002]  ? do_early_param+0x78/0x78:
						repair_env_string at init/main.c:250
[    7.587002]  ? rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
						
						rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
						
						rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
						
						rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
						
						rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
						
						rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
						
						rcu_read_unlock_sched_notrace+0x1e/0x2d:
						rcu_read_unlock_sched_notrace at include/linux/rcupdate.h:778
[    7.587002]  ? trace_initcall_level+0x3e/0x64:
						trace_initcall_level at include/trace/events/initcall.h:10 (discriminator 18)
[    7.587002]  kernel_init_freeable+0xfc/0x177:
						do_initcall_level at init/main.c:951
						 (inlined by) do_initcalls at init/main.c:959
						 (inlined by) do_basic_setup at init/main.c:977
						 (inlined by) kernel_init_freeable at init/main.c:1127
[    7.587002]  ? rest_init+0xbe/0xbe:
						kernel_init at init/main.c:1050
[    7.587002]  kernel_init+0xd/0xd0:
						kernel_init at init/main.c:1055
[    7.587002]  ret_from_fork+0x2e/0x38:
						ret_from_fork at arch/x86/entry/entry_32.S:311
[    7.587002] Code: 16 94 ff 8b 15 68 ab 03 82 f7 c2 00 00 0f 00 b8 02 00 00 00 75 08 31 c0 80 e6 ff 0f 95 c0 5d c3 55 89 e5 57 56 53 e8 99 16 94 ff <8b> 78 50 89 d6 6a 00 31 d2 89 c3 b8 50 f0 1b 82 66 83 ff 02 0f
[    7.587002] EIP: cfs_trace_lock_tcd+0xb/0xa0:
						cfs_trace_lock_tcd at drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c:149 SS:ESP: 0068:8f5d1d70
[    7.587002] CR2: 0000000000000050
[    7.587002] ---[ end trace 4fbdcb515c61525e ]---
[    7.587002] Kernel panic - not syncing: Fatal exception

Attached the full dmesg, kconfig and reproduce scripts.

Thanks,
Fengguang
-------------- next part --------------
early console in setup code
early console in extract_kernel
input_data: 0x02a85069
input_len: 0x006fa377
output: 0x01000000
output_len: 0x012ed220
kernel_total_size: 0x02193000

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 4.17.0-rc1 (kbuild at lkp-hsx02) (gcc version 6.4.0 20171026 (Debian 6.4.0-9)) #1 PREEMPT Mon Apr 16 20:40:43 CST 2018
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000ffdffff] usable
[    0.000000] BIOS-e820: [mem 0x000000000ffe0000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0xffe0 max_arch_pfn = 0x1000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
[    0.000000] initial memory mapped: [mem 0x00000000-0x035fffff]
[    0.000000] Base memory trampoline at [(ptrval)] 9b000 size 16384
[    0.000000] BRK [0x02d94000, 0x02d94fff] PGTABLE
[    0.000000] BRK [0x02d95000, 0x02d95fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fd21000-0x0ffdffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F68D0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFE15CE 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFE142A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFE0040 0013EA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000000FFE0000 000040
[    0.000000] ACPI: APIC 0x000000000FFE151E 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFE1596 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0ffe0000
[    0.000000]   low ram: 0 - 0ffe0000
[    0.000000] cma: dma_contiguous_reserve(limit 0ffe0000)
[    0.000000] kvm-clock: cpu 0, msr 0:fd1f001, primary cpu clock
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: using sched offset of 1045972660 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x000000000ffdffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000000ffdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000000ffdffff]
[    0.000000] On node 0 totalpages: 65406
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 480 pages used for memmap
[    0.000000]   Normal zone: 61408 pages, LIFO batch:15
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 203c2c0
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] random: fast init done
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 64894
[    0.000000] Kernel command line: ip=::::vm-lkp-nhm-dp1-yocto-i386-7::dhcp root=/dev/ram0 user=lkp job=/lkp/scheduled/vm-lkp-nhm-dp1-yocto-i386-7/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180416-74153-1703sy7-0.yaml ARCH=i386 kconfig=i386-randconfig-s1-201814 branch=linus/master commit=60cc43fc888428bb2f18f08997432d426a243338 BOOT_IMAGE=/pkg/linux/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1 max_uptime=600 RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp1-yocto-i386/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/0 LKP_SERVER=inn debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 net.ifnames=0 printk.devkmsg=on panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 drbd.minor_count=8 systemd.log_level=err ignore_loglevel console=tty0 earlyprintk=ttyS0,115200 console=ttyS0,115200 vga=normal rw drbd.mi
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 226136K/261624K available (10931K kernel code, 2040K rwdata, 5520K rodata, 764K init, 10804K bss, 35488K reserved, 0K cma-reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffe4000 - 0xfffff000   ( 108 kB)
[    0.000000]   cpu_entry : 0xffa00000 - 0xffa28000   ( 160 kB)
[    0.000000]     vmalloc : 0x907e0000 - 0xff9fe000   (1778 MB)
[    0.000000]     lowmem  : 0x80000000 - 0x8ffe0000   ( 255 MB)
[    0.000000]       .init : 0x8222d000 - 0x822ec000   ( 764 kB)
[    0.000000]       .data : 0x81aace54 - 0x82213040   (7576 kB)
[    0.000000]       .text : 0x81000000 - 0x81aace54   (10931 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] 
[    0.000000] **********************************************************
[    0.000000] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.000000] **                                                      **
[    0.000000] ** trace_printk() being used. Allocating extra memory.  **
[    0.000000] **                                                      **
[    0.000000] ** This means that this is a DEBUG kernel and it is     **
[    0.000000] ** unsafe for production use.                           **
[    0.000000] **                                                      **
[    0.000000] ** If you see this message and you are not debugging    **
[    0.000000] ** the kernel, report this immediately to your vendor!  **
[    0.000000] **                                                      **
[    0.000000] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.000000] **********************************************************
[    0.001000] Preemptible hierarchical RCU implementation.
[    0.001000] 	RCU event tracing is enabled.
[    0.001000] 	RCU debug extended QS entry/exit.
[    0.001000] 	RCU CPU stall warnings timeout set to 100 (rcu_cpu_stall_timeout).
[    0.001000] 	Tasks RCU enabled.
[    0.001000] NR_IRQS: 16, nr_irqs: 16, preallocated irqs: 16
[    0.001000] CPU 0 irqstacks, hard=(ptrval) soft=(ptrval)
[    0.001000] console [ttyS0] enabled
[    0.001000] bootconsole [earlyser0] disabled
[    0.001000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.001000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.001000] ... MAX_LOCK_DEPTH:          48
[    0.001000] ... MAX_LOCKDEP_KEYS:        8191
[    0.001000] ... CLASSHASH_SIZE:          4096
[    0.001000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.001000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.001000] ... CHAINHASH_SIZE:          32768
[    0.001000]  memory used by lock dependency info: 4383 kB
[    0.001000]  per task-struct memory footprint: 1344 bytes
[    0.001000] ACPI: Core revision 20180313
[    0.001000] ACPI: setting ELCR to 0200 (from 0c00)
[    0.001000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.001000] hpet clockevent registered
[    0.001009] tsc: Detected 2925.998 MHz processor
[    0.001475] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x2a2d3295deb, max_idle_ns: 440795332860 ns
[    0.002008] Calibrating delay loop (skipped) preset value.. 5851.99 BogoMIPS (lpj=2925998)
[    0.003006] pid_max: default: 32768 minimum: 301
[    0.004027] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.004655] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.005332] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.006006] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.007005] CPU: Intel QEMU Virtual CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
[    0.007806] Spectre V2 : Vulnerable: Minimal generic ASM retpoline
[    0.008005] Spectre V2 : Spectre v2 mitigation: Filling RSB on context switch
[    0.009632] Performance Events: PMU not available due to virtualization, using software events only.
[    0.011082] Hierarchical SRCU implementation.
[    0.011658] NMI watchdog: Perf event create on CPU 0 failed with -2
[    0.012006] NMI watchdog: Perf NMI watchdog permanently disabled
[    0.013238] devtmpfs: initialized
[    0.015894] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.016011] futex hash table entries: 256 (order: 1, 11264 bytes)
[    0.017062] prandom: seed boundary self test passed
[    0.018484] prandom: 100 self tests passed
[    0.018881] pinctrl core: initialized pinctrl subsystem
[    0.019404] RTC time: 20:44:40, date: 04/16/18
[    0.020188] NET: Registered protocol family 16
[    0.021978] audit: initializing netlink subsys (disabled)
[    0.022296] EISA bus registered
[    0.023014] workqueue: round-robin CPU selection forced, expect performance impact
[    0.023768] audit: type=2000 audit(1523882680.447:1): state=initialized audit_enabled=0 res=1
[    0.024059] cpuidle: using governor ladder
[    0.026043] ACPI: bus type PCI registered
[    0.026792] PCI: PCI BIOS revision 2.10 entry at 0xfd501, last bus=0
[    0.027006] PCI: Using configuration type 1 for base access
[    0.073497] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.074253] cryptd: max_cpu_qlen set to 1000
[    0.074716] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.075047] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.076140] ACPI: Added _OSI(Module Device)
[    0.076541] ACPI: Added _OSI(Processor Device)
[    0.077007] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.077452] ACPI: Added _OSI(Processor Aggregator Device)
[    0.078009] ACPI: Added _OSI(Linux-Dell-Video)
[    0.082807] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.086798] ACPI: Interpreter enabled
[    0.087036] ACPI: (supports S0 S3 S5)
[    0.087408] ACPI: Using PIC for interrupt routing
[    0.088036] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.089373] ACPI: Enabled 2 GPEs in block 00 to 0F
[    0.101397] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.102012] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.102549] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.103018] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.104141] PCI host bridge to bus 0000:00
[    0.104552] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.105008] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.106008] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.106718] pci_bus 0000:00: root bus resource [mem 0x10000000-0xfebfffff window]
[    0.107010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.108048] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.109606] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.111023] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.114328] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.116343] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.117008] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.117670] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.118007] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.119417] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.120343] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.121016] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.122478] pci 0000:00:02.0: [1234:1111] type 00 class 0x030000
[    0.124629] pci 0000:00:02.0: reg 0x10: [mem 0xfd000000-0xfdffffff pref]
[    0.127668] pci 0000:00:02.0: reg 0x18: [mem 0xfebf0000-0xfebf0fff]
[    0.134746] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.136082] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.137463] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.138955] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.145467] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.146524] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.147576] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.152138] pci_bus 0000:00: on NUMA node 0
[    0.153731] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.154314] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.155287] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.156288] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.157131] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.158914] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.159000] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.159008] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.159561] vgaarb: loaded
[    0.160524] EDAC MC: Ver: 3.0.0
[    0.161203] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.162429] FPGA manager framework
[    0.162789] PCI: Using ACPI for IRQ routing
[    0.163013] PCI: pci_cache_line_size set to 32 bytes
[    0.163619] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.164010] e820: reserve RAM buffer [mem 0x0ffe0000-0x0fffffff]
[    0.165324] Bluetooth: Core ver 2.22
[    0.165719] NET: Registered protocol family 31
[    0.166015] Bluetooth: HCI device and connection manager initialized
[    0.166631] Bluetooth: HCI socket layer initialized
[    0.167015] Bluetooth: L2CAP socket layer initialized
[    0.168069] nfc: nfc_init: NFC Core ver 0.1
[    0.168504] NET: Registered protocol family 39
[    0.170061] clocksource: Switched to clocksource kvm-clock
[    0.183743] Warning: could not register annotated branches stats
[    0.228216] pnp: PnP ACPI init
[    0.228695] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.229472] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.230278] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.230989] pnp 00:03: [dma 2]
[    0.231358] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.232245] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.233058] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.233869] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.235172] pnp: PnP ACPI: found 7 devices
[    0.270919] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.271860] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.272450] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.273064] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.273717] pci_bus 0000:00: resource 7 [mem 0x10000000-0xfebfffff window]
[    0.274406] NET: Registered protocol family 2
[    0.275169] tcp_listen_portaddr_hash hash table entries: 128 (order: 0, 5120 bytes)
[    0.276013] TCP established hash table entries: 2048 (order: 1, 8192 bytes)
[    0.276874] TCP bind hash table entries: 2048 (order: 4, 73728 bytes)
[    0.277880] TCP: Hash tables configured (established 2048 bind 2048)
[    0.278538] UDP hash table entries: 256 (order: 2, 20480 bytes)
[    0.279179] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
[    0.279868] NET: Registered protocol family 1
[    0.280860] RPC: Registered named UNIX socket transport module.
[    0.281648] RPC: Registered udp transport module.
[    0.282313] RPC: Registered tcp transport module.
[    0.282874] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.284053] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.284997] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.285984] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.287047] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.288445] PCI: CLS 0 bytes, default 32
[    0.289323] Unpacking initramfs...
[    0.691059] Freeing initrd memory: 2812K
[    0.692337] apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
[    0.692944] apm: overridden by ACPI.
[    0.693874] cryptomgr_test (32) used greatest stack depth: 7424 bytes left
[    0.694553] PCLMULQDQ-NI instructions are not detected.
[    0.695104] The force parameter has not been set to 1. The Iris poweroff handler will not be installed.
[    0.696083] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    0.697741] spin_lock-torture: Creating torture_shuffle task
[    0.698345] spin_lock-torture: Creating torture_stutter task
[    0.698926] spin_lock-torture: torture_shuffle task started
[    0.699478] spin_lock-torture: Creating lock_torture_writer task
[    0.700139] spin_lock-torture: torture_stutter task started
[    0.700673] spin_lock-torture: Creating lock_torture_writer task
[    0.701300] spin_lock-torture: lock_torture_writer task started
[    0.701872] spin_lock-torture: Creating lock_torture_stats task
[    0.702462] spin_lock-torture: lock_torture_writer task started
[    0.703105] torture_init_begin: Refusing rcu init: spin_lock running.
[    0.703707] torture_init_begin: One torture test at a time!
[    0.706033] spin_lock-torture: lock_torture_stats task started
[    0.707319] Initialise system trusted keyrings
[    0.707773] Key type blacklist registered
[    0.709099] workingset: timestamp_bits=30 max_order=16 bucket_order=0
[    0.709695] zbud: loaded
[    0.710588] NFS: Registering the id_resolver key type
[    0.711121] Key type id_resolver registered
[    0.711503] Key type id_legacy registered
[    0.712383] Key type cifs.spnego registered
[    0.712790] fuse init (API version 7.26)
[    0.727112] NET: Registered protocol family 38
[    0.727684] Key type asymmetric registered
[    0.924080] String selftests succeeded
[    0.924435] test_string_helpers: Running tests...
[    0.926539] test_hexdump: all 1184 tests passed
[    0.927015] 
[    0.927015] Start testing find_bit() with random-filled bitmap
[    0.930633] find_next_bit:                 2262809 ns, 164019 iterations
[    0.933711] find_next_zero_bit:            2241580 ns, 163662 iterations
[    0.936311] find_last_bit:                 1165957 ns, 164018 iterations
[    1.697020] tsc: Refined TSC clocksource calibration: 2925.994 MHz
[    1.697602] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2a2d2ead42f, max_idle_ns: 440795314183 ns
[    1.841528] find_first_bit:              904460102 ns, 164019 iterations
[    1.842306] find_next_and_bit:		51811 cycles, 1 iterations
[    1.842909] 
[    1.842909] Start testing find_bit() with sparse bitmap
[    1.843625] find_next_bit:                   37586 ns,    656 iterations
[    1.848492] find_next_zero_bit:            4160674 ns, 327025 iterations
[    1.849202] find_last_bit:                   20041 ns,    656 iterations
[    1.854170] find_first_bit:                4317191 ns,    656 iterations
[    1.854859] find_next_and_bit:		45414 cycles, 1 iterations
[    1.855543] test_firmware: interface ready
[    1.856279] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    1.856897] Test 00:
[    1.857200]   Adding 50000 keys
[    1.939538]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.962566]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.963410]   Deleting 50000 keys
[    1.998911]   Duration of test: 141414658 ns
[    1.999365] Test 01:
[    1.999676]   Adding 50000 keys
[    2.083822]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.107640]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.108439]   Deleting 50000 keys
[    2.141674]   Duration of test: 141644055 ns
[    2.142129] Test 02:
[    2.142377]   Adding 50000 keys
[    2.224938]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.246349]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.247202]   Deleting 50000 keys
[    2.281737]   Duration of test: 139033256 ns
[    2.282205] Test 03:
[    2.282459]   Adding 50000 keys
[    2.364279]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.387683]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.388478]   Deleting 50000 keys
[    2.420742]   Duration of test: 137951130 ns
[    2.433933] test if its possible to exceed max_size 8192: no, ok
[    2.434601] Average test time: 140010774
[    2.435073] test inserting duplicates
[    2.435431] 
[    2.435431] ---- ht: ----
[    2.435431] bucket[1] -> [[ val 1 (tid=0) ]] -> [[ val 21 (tid=1) ]]
[    2.435431] -------------
[    2.436701] 
[    2.436701] ---- ht: ----
[    2.436701] bucket[1] -> [[ val 1 (tid=2),  val 1 (tid=0) ]] -> [[ val 21 (tid=1) ]]
[    2.436701] -------------
[    2.438979] 
[    2.438979] ---- ht: ----
[    2.438979] bucket[1] -> [[ val 21 (tid=1) ]] -> [[ val 1 (tid=0) ]]
[    2.438979] -------------
[    2.440225] 
[    2.440225] ---- ht: ----
[    2.440225] bucket[1] -> [[ val 21 (tid=1) ]] -> [[ val 1 (tid=2),  val 1 (tid=0) ]]
[    2.440225] -------------
[    2.441626] Testing concurrent rhashtable access from 10 threads
[    5.434093] rhashtable_thra (121) used greatest stack depth: 7236 bytes left
[    5.439994] rhashtable_thra (126) used greatest stack depth: 7116 bytes left
[    5.440910] rhashtable_thra (122) used greatest stack depth: 7100 bytes left
[    5.443974] test 3125 add/delete pairs into rhlist
[    5.522623] test 3125 random rhlist add/delete operations
[    5.543581] Started 10 threads, 0 failed, rhltable test returns 0
[    5.544402] test_printf: all 240 tests passed
[    5.545014] xz_dec_test: module loaded
[    5.545387] xz_dec_test: Create a device node with 'mknod xz_dec_test c 250 0' and write .xz files to it.
[    5.547243] glob: 64 self-tests passed, 0 failed
[    5.548680] hgafb: HGA card not detected.
[    5.549126] hgafb: probe of hgafb.0 failed with error -22
[    5.550128] uvesafb: failed to execute /sbin/v86d
[    5.550590] uvesafb: make sure that the v86d helper is installed and executable
[    5.551375] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    5.552101] uvesafb: vbe_init() failed with -22
[    5.552551] uvesafb: probe of uvesafb.0 failed with error -22
[    5.553218] intel_idle: does not run on family 6 model 6
[    5.553748] ipmi message handler version 39.2
[    5.554245] ipmi device interface
[    5.554591] IPMI System Interface driver.
[    5.555189] ipmi_si: Unable to find any System Interface(s)
[    5.555754] IPMI SSIF Interface driver
[    5.557134] IPMI Watchdog: driver initialized
[    5.557566] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    5.559200] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    5.560078] ACPI: Power Button [PWRF]
[    5.560532] Warning: Processor Platform Limit event detected, but not handled.
[    5.561295] Consider compiling CPUfreq support into your kernel.
[    5.621163] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    5.647016] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    5.671016] 00:06: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[    5.673459] lp: driver loaded but no devices found
[    5.674036] DoubleTalk PC - not found
[    5.674474] toshiba: not a supported Toshiba laptop
[    5.675276] ppdev: user-space parallel port driver
[    5.675844] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initializing
[    5.676544] platform pc8736x_gpio.0: no device found
[    5.677123] nsc_gpio initializing
[    5.677453] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    5.679297] parport_pc 00:04: reported by Plug and Play ACPI
[    5.680085] parport0: PC-style at 0x378, irq 7 [PCSPP(,...)]
[    5.680873] lp0: using parport0 (interrupt-driven).
[    5.683282] dummy-irq: no IRQ given.  Use irq=N
[    5.683760] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[    5.684634] c2port c2port0: C2 port uc added
[    5.685084] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[    5.686764] mtdoops: mtd device (mtddev=name/number) must be supplied
[    5.687450] platform physmap-flash.0: failed to claim resource 0: [mem 0x08000000-0x07ffffff]
[    5.688386] slram: not enough parameters.
[    5.721007] No valid DiskOnChip devices found
[    5.721511] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    5.722419] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    5.723346] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    5.724267] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    5.725171] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    5.726079] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    5.726965] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[    5.727572] nand: Toshiba NAND 128MiB 1,8V 8-bit
[    5.728054] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, OOB size: 16
[    5.728771] flash size: 128 MiB
[    5.729103] page size: 512 bytes
[    5.729419] OOB area size: 16 bytes
[    5.729747] sector size: 16 KiB
[    5.730080] pages number: 262144
[    5.730398] pages per sector: 32
[    5.730712] bus width: 8
[    5.730954] bits in sector size: 14
[    5.731313] bits in page size: 9
[    5.731616] bits in OOB size: 4
[    5.731930] flash size with OOB: 135168 KiB
[    5.732359] page address bytes: 4
[    5.732686] sector address bytes: 3
[    5.733050] options: 0x42
[    5.734098] Scanning device for bad blocks
[    5.755639] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    5.756418] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    5.762567] [nandsim] warning: CONFIG_MTD_PARTITIONED_MASTER must be enabled to expose debugfs stuff
[    5.763836] LocalTalk card not found; 220 = ff, 240 = ff.
[    5.765340] mdio_bus fixed-0: GPIO lookup for consumer reset
[    5.765878] mdio_bus fixed-0: using lookup tables for GPIO lookup
[    5.766491] mdio_bus fixed-0: No GPIO consumer reset found
[    5.767186] libphy: Fixed MDIO Bus: probed
[    5.768454] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    5.769639] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    5.770477] vcan: Virtual CAN interface driver
[    5.770917] vxcan: Virtual CAN Tunnel driver
[    5.771994] CAN device driver interface
[    5.772396] cc770: CAN netdevice driver
[    5.772762] cc770_isa: insufficient parameters supplied
[    5.773326] sja1000 CAN netdevice driver
[    5.774653] dsa-loop fixed-0:1f: DSA mockup driver: 0x1f
[    5.814164] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    5.814828] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    6.035494] PCI Interrupt Link [LNKC] enabled at IRQ 11
[    6.036053] PCI: setting IRQ 11 as level-triggered
[    6.364253] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[    6.364943] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[    6.365643] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[    6.366222] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    6.366815] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[    6.367469] igb: Copyright (c) 2007-2014 Intel Corporation.
[    6.368062] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 5.1.0-k
[    6.368789] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[    6.370138] atp.c:v1.09=ac 2002/10/01 Donald Becker <becker@scyld.com>
[    6.370944] AX.25: Z8530 SCC driver version 3.0.dl1bke
[    6.371841] AX.25: bpqether driver version 004
[    6.372286] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    6.372286] baycom_ser_fdx: version 0.10
[    6.374663] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    6.375237] hdlcdrv: version 0.8
[    6.375550] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    6.375550] baycom_par: version 0.9
[    6.378454] NET3 PLIP version 2.4-parport gniibe at mri.co.jp
[    6.379033] plip0: Parallel port at 0x378, using IRQ 7.
[    6.379530] PPP generic driver version 2.4.2
[    6.380124] PPP BSD Compression module registered
[    6.380583] PPP MPPE Compression module registered
[    6.381079] NET: Registered protocol family 24
[    6.381515] DLCI driver v0.35, 4 Jan 1997, mike.mclagan at linux.org.
[    6.383969] SDLA driver v0.30, 12 Sep 1996, mike.mclagan at linux.org.
[    6.385162] Broadcom 43xx driver loaded [ Features: PNLS ]
[    6.385756] Broadcom 43xx-legacy driver loaded [ Features: PLI ]
[    6.491798] panel: panel driver registered on parport0 (io=0x378).
[    6.492528] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    6.494149] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.494996] serio: i8042 AUX port at 0x60,0x64 irq 12
[    6.496407] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    6.499144] i2c-parport: adapter type unspecified
[    6.499596] i2c-parport-light: adapter type unspecified
[    6.500844] isa i2c-pca-isa.0: Please specify I/O base
[    6.501486] Driver for 1-wire Dallas network protocol.
[    6.502082] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    6.502715] w1_f0d_init()
[    6.503451] intel_powerclamp: CPU does not support MWAIT
[    6.504519] mixcomwd: No card detected, or port not available
[    6.505169] acquirewdt: WDT driver for Acquire single board computer initialising
[    6.506109] acquirewdt: I/O address 0x0043 already in use
[    6.506634] acquirewdt: probe of acquirewdt failed with error -5
[    6.507330] ib700wdt: WDT driver for IB700 single board computer initialising
[    6.508402] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[    6.509204] wafer5823wdt: I/O address 0x0443 already in use
[    6.509798] it87_wdt: no device
[    6.510156] sc1200wdt: build 20020303
[    6.510529] sc1200wdt: io parameter must be specified
[    6.511065] sbc8360: failed to register misc device
[    6.511532] sbc7240_wdt: I/O address 0x0443 already in use
[    6.512995] cpu5wdt: misc_register failed
[    6.513384] w83877f_wdt: I/O address 0x0443 already in use
[    6.513902] w83977f_wdt: driver v1.00
[    6.514288] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[    6.514932] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    6.515512] machzwd: no ZF-Logic found
[    6.516003] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[    6.516772] CAPI 2.0 started up with major 68 (no middleware)
[    6.517342] Modular ISDN core version 1.1.29
[    6.517921] NET: Registered protocol family 34
[    6.518373] DSP module 2.0
[    6.518651] mISDN_dsp: DSP clocks every 64 samples. This equals 8 jiffies.
[    6.520241] mISDN: Layer-1-over-IP driver Rev. 2.00
[    6.520886] 0 virtual devices registered
[    6.521298] sdhci: Secure Digital Host Controller Interface driver
[    6.521893] sdhci: Copyright(c) Pierre Ossman
[    6.523004] sdhci-pltfm: SDHCI platform and OF driver helper
[    6.524361] ledtrig-cpu: registered to indicate activity on CPUs
[    6.527658] NET: Registered protocol family 4
[    6.528191] comedi: version 0.7.76 - http://www.comedi.org
[    6.528851] LNetError: 1:0:(module.c:546:libcfs_init()) misc_register: error -16
[    7.220272] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
[    7.586283] BUG: unable to handle kernel NULL pointer dereference at 00000050
[    7.586962] *pdpt = 0000000000000000 *pde = f000ff53f000ff53 
[    7.587002] Oops: 0000 [#1] PREEMPT
[    7.587002] CPU: 0 PID: 1 Comm: swapper Not tainted 4.17.0-rc1 #1
[    7.587002] EIP: cfs_trace_lock_tcd+0xb/0xa0
[    7.587002] EFLAGS: 00210246 CPU: 0
[    7.587002] EAX: 00000000 EBX: 00000000 ECX: 81fcb588 EDX: 00000000
[    7.587002] ESI: 00001800 EDI: 8f5d1e08 EBP: 8f5d1d7c ESP: 8f5d1d70
[    7.587002]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[    7.587002] CR0: 80050033 CR2: 00000050 CR3: 022f0000 CR4: 000006b0
[    7.587002] Call Trace:
[    7.587002]  libcfs_debug_vmsg2+0x8f/0x82f
[    7.587002]  ? trace_irq_enable_rcuidle+0x25/0x62
[    7.587002]  ? slob_free+0x249/0x251
[    7.587002]  libcfs_debug_msg+0x19/0x1b
[    7.587002]  ksocknal_startup+0xe77/0x12b2
[    7.587002]  ? lock_release+0x135/0x1ec
[    7.587002]  ? _raw_spin_unlock+0x3c/0x4b
[    7.587002]  lnet_startup_lndni+0x4cd/0x9ec
[    7.587002]  LNetNIInit+0x880/0xa00
[    7.587002]  ? read_seqcount_retry+0x1b/0x22
[    7.587002]  srpc_startup+0x84/0x381
[    7.587002]  lnet_selftest_init+0x2c4/0x5d9
[    7.587002]  ? lnet_selftest_exit+0x8d/0x8d
[    7.587002]  do_one_initcall+0x76/0x1d7
[    7.587002]  ? do_early_param+0x78/0x78
[    7.587002]  ? rcu_read_unlock_sched_notrace+0x1e/0x2d
[    7.587002]  ? trace_initcall_level+0x3e/0x64
[    7.587002]  kernel_init_freeable+0xfc/0x177
[    7.587002]  ? rest_init+0xbe/0xbe
[    7.587002]  kernel_init+0xd/0xd0
[    7.587002]  ret_from_fork+0x2e/0x38
[    7.587002] Code: 16 94 ff 8b 15 68 ab 03 82 f7 c2 00 00 0f 00 b8 02 00 00 00 75 08 31 c0 80 e6 ff 0f 95 c0 5d c3 55 89 e5 57 56 53 e8 99 16 94 ff <8b> 78 50 89 d6 6a 00 31 d2 89 c3 b8 50 f0 1b 82 66 83 ff 02 0f 
[    7.587002] EIP: cfs_trace_lock_tcd+0xb/0xa0 SS:ESP: 0068:8f5d1d70
[    7.587002] CR2: 0000000000000050
[    7.587002] ---[ end trace 4fbdcb515c61525e ]---
[    7.587002] Kernel panic - not syncing: Fatal exception
[    7.587002] Kernel Offset: disabled

Elapsed time: 10

#!/bin/bash

# To reproduce,
# 1) save job-script and this script (both are attached in 0day report email)
# 2) run this script with your compiled kernel and optional env $INSTALL_MOD_PATH

kernel=$1

initrds=(
	/osimage/yocto/yocto-tiny-i386-2016-04-22.cgz
	/lkp/lkp/lkp-i386.cgz
	/osimage/deps/debian-x86_64-2016-08-31.cgz/run-ipconfig.i386_2016-09-03.cgz
)

HTTP_PREFIX=https://github.com/0day-ci/lkp-qemu/raw/master
wget --timestamping "${initrds[@]/#/$HTTP_PREFIX}"

{
	cat "${initrds[@]//*\//}"
	[[ $INSTALL_MOD_PATH ]] && (
		cd "$INSTALL_MOD_PATH"
		find lib | cpio -o -H newc --quiet | gzip
	)
	echo  job-script | cpio -o -H newc --quiet | gzip
} > initrd.img

kvm=(
	qemu-system-i386
	-enable-kvm
	-kernel $kernel
	-initrd initrd.img
	-m 256
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	ip=::::vm-lkp-nhm-dp1-yocto-i386-7::dhcp
	root=/dev/ram0
	user=lkp
	job=/job-script
	ARCH=i386
	kconfig=i386-randconfig-s1-201814
	branch=linus/master
	commit=60cc43fc888428bb2f18f08997432d426a243338
	BOOT_IMAGE=/pkg/linux/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
	max_uptime=600
	RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp1-yocto-i386/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/0
	result_service=tmpfs
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"
-------------- next part --------------
#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.17.0-rc1 Kernel Configuration
#
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=3
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
# CONFIG_CGROUP_RDMA is not set
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
# CONFIG_POSIX_TIMERS is not set
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_ADVISE_SYSCALLS is not set
# CONFIG_MEMBARRIER is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
CONFIG_CC_STACKPROTECTOR_STRONG=y
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_ISA_BUS_API=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_GOLDFISH=y
CONFIG_RETPOLINE=y
CONFIG_INTEL_RDT=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_RDC321X=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
CONFIG_MPENTIUMII=y
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=6
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_CYRIX_32 is not set
CONFIG_CPU_SUP_AMD=y
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
# CONFIG_X86_UP_APIC is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCELOG_LEGACY is not set
# CONFIG_X86_ANCIENT_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_LEGACY_VM86=y
CONFIG_VM86=y
# CONFIG_X86_16BIT is not set
CONFIG_TOSHIBA=y
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
CONFIG_VMSPLIT_2G=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x80000000
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
# CONFIG_PERCPU_STATS is not set
CONFIG_GUP_BENCHMARK=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_KEXEC=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_TAD is not set
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
CONFIG_APM_IGNORE_USER_SUSPEND=y
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
CONFIG_APM_DISPLAY_BLANK=y
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_CPU_IDLE_GOV_MENU is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_PCI_LOCKLESS_CONFIG=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# Cadence PCIe controllers support
#

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#

#
# PCI Endpoint
#
CONFIG_PCI_ENDPOINT=y
# CONFIG_PCI_ENDPOINT_CONFIGFS is not set
CONFIG_PCI_EPF_TEST=y

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
CONFIG_EISA_PCI_EISA=y
# CONFIG_EISA_VIRTUAL_ROOT is not set
CONFIG_EISA_NAMES=y
# CONFIG_SCx200 is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
CONFIG_PCMCIA_PROBE=y
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y
CONFIG_NET_INGRESS=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_TLS=y
CONFIG_XFRM=y
CONFIG_XFRM_OFFLOAD=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
# CONFIG_SMC is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE_COMMON=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=y
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
CONFIG_INET_ESP_OFFLOAD=y
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
CONFIG_INET_XFRM_MODE_TUNNEL=y
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
# CONFIG_TCP_CONG_HTCP is not set
CONFIG_TCP_CONG_HSTCP=y
# CONFIG_TCP_CONG_HYBLA is not set
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_NV=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
CONFIG_TCP_CONG_DCTCP=y
# CONFIG_TCP_CONG_CDG is not set
CONFIG_TCP_CONG_BBR=y
# CONFIG_DEFAULT_BIC is not set
# CONFIG_DEFAULT_VEGAS is not set
CONFIG_DEFAULT_VENO=y
# CONFIG_DEFAULT_DCTCP is not set
# CONFIG_DEFAULT_BBR is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="veno"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
# CONFIG_IPV6_ROUTE_INFO is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=y
# CONFIG_INET6_ESP is not set
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
CONFIG_INET6_XFRM_MODE_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_VTI=y
# CONFIG_IPV6_SIT is not set
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_FOU=y
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
# CONFIG_IPV6_PIMSM_V2 is not set
CONFIG_IPV6_SEG6_LWTUNNEL=y
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_LOG_COMMON=y
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NETFILTER_CONNCOUNT=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_PROCFS=y
# CONFIG_NF_CONNTRACK_EVENTS is not set
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
# CONFIG_NF_CT_PROTO_SCTP is not set
# CONFIG_NF_CT_PROTO_UDPLITE is not set
# CONFIG_NF_CONNTRACK_AMANDA is not set
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
# CONFIG_NF_CONNTRACK_TFTP is not set
# CONFIG_NF_CT_NETLINK is not set
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_SIP=y
CONFIG_NF_NAT_REDIRECT=y
CONFIG_NETFILTER_SYNPROXY=y
CONFIG_NF_TABLES=y
CONFIG_NF_TABLES_INET=y
CONFIG_NF_TABLES_NETDEV=y
# CONFIG_NFT_EXTHDR is not set
CONFIG_NFT_META=y
CONFIG_NFT_RT=y
CONFIG_NFT_NUMGEN=y
CONFIG_NFT_CT=y
CONFIG_NFT_SET_RBTREE=y
CONFIG_NFT_SET_HASH=y
CONFIG_NFT_SET_BITMAP=y
# CONFIG_NFT_COUNTER is not set
CONFIG_NFT_LOG=y
CONFIG_NFT_LIMIT=y
CONFIG_NFT_MASQ=y
CONFIG_NFT_REDIR=y
CONFIG_NFT_NAT=y
# CONFIG_NFT_OBJREF is not set
CONFIG_NFT_QUEUE=y
# CONFIG_NFT_QUOTA is not set
CONFIG_NFT_REJECT=y
CONFIG_NFT_REJECT_INET=y
CONFIG_NFT_COMPAT=y
CONFIG_NFT_HASH=y
CONFIG_NF_DUP_NETDEV=y
CONFIG_NFT_DUP_NETDEV=y
CONFIG_NFT_FWD_NETDEV=y
# CONFIG_NF_FLOW_TABLE is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y
# CONFIG_NETFILTER_XT_SET is not set

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
# CONFIG_NETFILTER_XT_TARGET_CONNMARK is not set
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
# CONFIG_NETFILTER_XT_TARGET_DSCP is not set
CONFIG_NETFILTER_XT_TARGET_HL=y
CONFIG_NETFILTER_XT_TARGET_HMARK=y
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
CONFIG_NETFILTER_XT_TARGET_LED=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
# CONFIG_NETFILTER_XT_TARGET_MARK is not set
CONFIG_NETFILTER_XT_NAT=y
CONFIG_NETFILTER_XT_TARGET_NETMAP=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
# CONFIG_NETFILTER_XT_TARGET_REDIRECT is not set
# CONFIG_NETFILTER_XT_TARGET_TEE is not set
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
# CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
# CONFIG_NETFILTER_XT_MATCH_CONNBYTES is not set
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPCOMP=y
# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
CONFIG_NETFILTER_XT_MATCH_L2TP=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
# CONFIG_NETFILTER_XT_MATCH_STATE is not set
# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPMARK=y
# CONFIG_IP_SET_HASH_IPPORT is not set
CONFIG_IP_SET_HASH_IPPORTIP=y
CONFIG_IP_SET_HASH_IPPORTNET=y
# CONFIG_IP_SET_HASH_IPMAC is not set
CONFIG_IP_SET_HASH_MAC=y
CONFIG_IP_SET_HASH_NETPORTNET=y
# CONFIG_IP_SET_HASH_NET is not set
CONFIG_IP_SET_HASH_NETNET=y
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
# CONFIG_IP_SET_LIST_SET is not set
CONFIG_IP_VS=y
# CONFIG_IP_VS_IPV6 is not set
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
# CONFIG_IP_VS_PROTO_AH is not set
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
# CONFIG_IP_VS_RR is not set
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_FO=y
CONFIG_IP_VS_OVF=y
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=y
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=y

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
# CONFIG_NF_SOCKET_IPV4 is not set
CONFIG_NF_TABLES_IPV4=y
# CONFIG_NFT_CHAIN_ROUTE_IPV4 is not set
CONFIG_NFT_REJECT_IPV4=y
CONFIG_NFT_DUP_IPV4=y
# CONFIG_NFT_FIB_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
CONFIG_NF_DUP_IPV4=y
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=y
CONFIG_NF_REJECT_IPV4=y
CONFIG_NF_NAT_IPV4=y
CONFIG_NFT_CHAIN_NAT_IPV4=y
CONFIG_NF_NAT_MASQUERADE_IPV4=y
CONFIG_NFT_MASQ_IPV4=y
CONFIG_NFT_REDIR_IPV4=y
CONFIG_NF_NAT_PROTO_GRE=y
CONFIG_NF_NAT_PPTP=y
CONFIG_NF_NAT_H323=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_MATCH_AH is not set
# CONFIG_IP_NF_MATCH_ECN is not set
# CONFIG_IP_NF_MATCH_RPFILTER is not set
# CONFIG_IP_NF_MATCH_TTL is not set
# CONFIG_IP_NF_FILTER is not set
# CONFIG_IP_NF_TARGET_SYNPROXY is not set
# CONFIG_IP_NF_NAT is not set
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
# CONFIG_IP_NF_RAW is not set
CONFIG_IP_NF_ARPTABLES=y
# CONFIG_IP_NF_ARPFILTER is not set
# CONFIG_IP_NF_ARP_MANGLE is not set

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_CONNTRACK_IPV6=y
# CONFIG_NF_SOCKET_IPV6 is not set
CONFIG_NF_TABLES_IPV6=y
# CONFIG_NFT_CHAIN_ROUTE_IPV6 is not set
CONFIG_NFT_REJECT_IPV6=y
CONFIG_NFT_DUP_IPV6=y
# CONFIG_NFT_FIB_IPV6 is not set
CONFIG_NF_DUP_IPV6=y
CONFIG_NF_REJECT_IPV6=y
CONFIG_NF_LOG_IPV6=y
CONFIG_NF_NAT_IPV6=y
CONFIG_NFT_CHAIN_NAT_IPV6=y
CONFIG_NF_NAT_MASQUERADE_IPV6=y
CONFIG_NFT_MASQ_IPV6=y
# CONFIG_NFT_REDIR_IPV6 is not set
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
# CONFIG_IP6_NF_MATCH_FRAG is not set
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_MATCH_MH=y
# CONFIG_IP6_NF_MATCH_RPFILTER is not set
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_MATCH_SRH=y
CONFIG_IP6_NF_TARGET_HL=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_TARGET_SYNPROXY=y
CONFIG_IP6_NF_MANGLE=y
# CONFIG_IP6_NF_RAW is not set
CONFIG_IP6_NF_NAT=y
CONFIG_IP6_NF_TARGET_MASQUERADE=y
# CONFIG_IP6_NF_TARGET_NPT is not set

#
# DECnet: Netfilter Configuration
#
# CONFIG_DECNET_NF_GRABULATOR is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
# CONFIG_L2TP_V3 is not set
CONFIG_STP=y
CONFIG_GARP=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
# CONFIG_NET_DSA_LEGACY is not set
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_NET_DSA_TAG_KSZ=y
CONFIG_NET_DSA_TAG_LAN9303=y
CONFIG_NET_DSA_TAG_MTK=y
CONFIG_NET_DSA_TAG_QCA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_LTPC=y
# CONFIG_COPS is not set
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
CONFIG_X25=y
CONFIG_LAPB=y
# CONFIG_PHONET is not set
CONFIG_6LOWPAN=y
# CONFIG_6LOWPAN_DEBUGFS is not set
CONFIG_6LOWPAN_NHC=y
CONFIG_6LOWPAN_NHC_DEST=y
CONFIG_6LOWPAN_NHC_FRAGMENT=y
CONFIG_6LOWPAN_NHC_HOP=y
CONFIG_6LOWPAN_NHC_IPV6=y
# CONFIG_6LOWPAN_NHC_MOBILITY is not set
CONFIG_6LOWPAN_NHC_ROUTING=y
CONFIG_6LOWPAN_NHC_UDP=y
# CONFIG_6LOWPAN_GHC_EXT_HDR_HOP is not set
# CONFIG_6LOWPAN_GHC_UDP is not set
CONFIG_6LOWPAN_GHC_ICMPV6=y
CONFIG_6LOWPAN_GHC_EXT_HDR_DEST=y
CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG=y
CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=y
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
# CONFIG_IEEE802154_SOCKET is not set
CONFIG_IEEE802154_6LOWPAN=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BATMAN_V=y
CONFIG_BATMAN_ADV_BLA=y
CONFIG_BATMAN_ADV_DAT=y
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_MCAST is not set
# CONFIG_BATMAN_ADV_DEBUGFS is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=y
CONFIG_VSOCKETS_DIAG=y
CONFIG_VIRTIO_VSOCKETS=y
CONFIG_VIRTIO_VSOCKETS_COMMON=y
CONFIG_NETLINK_DIAG=y
# CONFIG_MPLS is not set
CONFIG_NET_NSH=y
CONFIG_HSR=y
CONFIG_NET_SWITCHDEV=y
CONFIG_NET_L3_MASTER_DEV=y
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_STREAM_PARSER is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_DROP_MONITOR is not set
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
CONFIG_NETROM=y
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
# CONFIG_MKISS is not set
# CONFIG_6PACK is not set
CONFIG_BPQETHER=y
# CONFIG_DMASCC is not set
CONFIG_SCC=y
CONFIG_SCC_DELAY=y
# CONFIG_SCC_TRXECHO is not set
CONFIG_BAYCOM_SER_FDX=y
# CONFIG_BAYCOM_SER_HDX is not set
CONFIG_BAYCOM_PAR=y
# CONFIG_BAYCOM_EPP is not set
# CONFIG_YAM is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_VXCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
# CONFIG_CAN_CALC_BITTIMING is not set
CONFIG_CAN_LEDS=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_C_CAN=y
# CONFIG_CAN_C_CAN_PLATFORM is not set
# CONFIG_CAN_C_CAN_PCI is not set
CONFIG_CAN_CC770=y
CONFIG_CAN_CC770_ISA=y
CONFIG_CAN_CC770_PLATFORM=y
CONFIG_CAN_IFI_CANFD=y
# CONFIG_CAN_M_CAN is not set
# CONFIG_CAN_PEAK_PCIEFD is not set
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
CONFIG_CAN_SJA1000_PLATFORM=y
# CONFIG_CAN_EMS_PCI is not set
# CONFIG_CAN_PEAK_PCI is not set
# CONFIG_CAN_KVASER_PCI is not set
# CONFIG_CAN_PLX_PCI is not set
CONFIG_CAN_TSCAN1=y
CONFIG_CAN_SOFTING=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_BT=y
# CONFIG_BT_BREDR is not set
# CONFIG_BT_LE is not set
# CONFIG_BT_LEDS is not set
# CONFIG_BT_SELFTEST is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTSDIO=y
# CONFIG_BT_HCIUART is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_BT_MRVL is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_IPV6=y
# CONFIG_AF_RXRPC_INJECT_LOSS is not set
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=y
# CONFIG_AF_KCM is not set
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
CONFIG_CFG80211_CERTIFICATION_ONUS=y
# CONFIG_CFG80211_REQUIRE_SIGNED_REGDB is not set
# CONFIG_CFG80211_REG_CELLULAR_HINTS is not set
CONFIG_CFG80211_REG_RELAX_NO_IR=y
# CONFIG_CFG80211_DEFAULT_PS is not set
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_CRDA_SUPPORT is not set
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=y
CONFIG_LIB80211_DEBUG=y
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
# CONFIG_MAC80211_RC_MINSTREL_HT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel"
# CONFIG_MAC80211_MESH is not set
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
CONFIG_MAC80211_MESSAGE_TRACING=y
CONFIG_MAC80211_DEBUG_MENU=y
CONFIG_MAC80211_NOINLINE=y
CONFIG_MAC80211_VERBOSE_DEBUG=y
# CONFIG_MAC80211_MLME_DEBUG is not set
# CONFIG_MAC80211_STA_DEBUG is not set
CONFIG_MAC80211_HT_DEBUG=y
CONFIG_MAC80211_OCB_DEBUG=y
# CONFIG_MAC80211_IBSS_DEBUG is not set
CONFIG_MAC80211_PS_DEBUG=y
# CONFIG_MAC80211_TDLS_DEBUG is not set
CONFIG_MAC80211_DEBUG_COUNTERS=y
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
# CONFIG_NFC_DIGITAL is not set
CONFIG_NFC_NCI=y
# CONFIG_NFC_NCI_UART is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_FDP=y
CONFIG_NFC_FDP_I2C=y
CONFIG_NFC_PN533=y
CONFIG_NFC_PN533_I2C=y
# CONFIG_NFC_ST_NCI_I2C is not set
CONFIG_NFC_NXP_NCI=y
CONFIG_NFC_NXP_NCI_I2C=y
CONFIG_NFC_S3FWRN5=y
CONFIG_NFC_S3FWRN5_I2C=y
# CONFIG_PSAMPLE is not set
CONFIG_NET_IFE=y
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
CONFIG_CMA_SIZE_SEL_PERCENTAGE=y
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
# CONFIG_MTD_SBC_GXX is not set
# CONFIG_MTD_PCI is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_ONENAND is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_CS553X=y
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y

#
# NVME Support
#

#
# Misc devices
#
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_SRAM=y
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_ECHO is not set
# CONFIG_MISC_RTSX_PCI is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
# CONFIG_B53 is not set
CONFIG_NET_DSA_LOOP=y
CONFIG_NET_DSA_MT7530=y
CONFIG_MICROCHIP_KSZ=y
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_MV88E6XXX_GLOBAL2=y
CONFIG_NET_DSA_MV88E6XXX_PTP=y
CONFIG_NET_DSA_QCA8K=y
CONFIG_NET_DSA_SMSC_LAN9303=y
# CONFIG_NET_DSA_SMSC_LAN9303_I2C is not set
CONFIG_NET_DSA_SMSC_LAN9303_MDIO=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_EL3=y
CONFIG_3C515=y
CONFIG_VORTEX=y
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
# CONFIG_NET_VENDOR_ALACRITECH is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
# CONFIG_NET_VENDOR_AMAZON is not set
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_AQUANTIA is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
# CONFIG_NET_VENDOR_AURORA is not set
# CONFIG_NET_CADENCE is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CAVIUM=y
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CIRRUS=y
CONFIG_CS89x0=y
CONFIG_CS89x0_PLATFORM=y
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
CONFIG_DNET=y
# CONFIG_NET_VENDOR_DEC is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
CONFIG_MLXSW_CORE=y
# CONFIG_MLXSW_CORE_THERMAL is not set
CONFIG_MLXSW_PCI=y
CONFIG_MLXSW_I2C=y
CONFIG_MLXSW_SWITCHIB=y
CONFIG_MLXSW_SWITCHX2=y
CONFIG_MLXSW_SPECTRUM=y
CONFIG_MLXSW_MINIMAL=y
CONFIG_MLXFW=y
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8842=y
CONFIG_KS8851_MLL=y
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NETRONOME is not set
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
# CONFIG_NET_VENDOR_QUALCOMM is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_ATP=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
# CONFIG_NET_VENDOR_ROCKER is not set
CONFIG_NET_VENDOR_SAMSUNG=y
CONFIG_SXGBE_ETH=y
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
# CONFIG_NET_VENDOR_SOLARFLARE is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_SOCIONEXT is not set
CONFIG_NET_VENDOR_STMICRO=y
CONFIG_STMMAC_ETH=y
# CONFIG_STMMAC_PLATFORM is not set
# CONFIG_STMMAC_PCI is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
CONFIG_WIZNET_W5300=y
# CONFIG_WIZNET_BUS_DIRECT is not set
# CONFIG_WIZNET_BUS_INDIRECT is not set
CONFIG_WIZNET_BUS_ANY=y
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
CONFIG_LED_TRIGGER_PHY=y

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=y
CONFIG_AQUANTIA_PHY=y
CONFIG_AT803X_PHY=y
CONFIG_BCM7XXX_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_BCM_NET_PHYLIB=y
# CONFIG_BROADCOM_PHY is not set
CONFIG_CICADA_PHY=y
# CONFIG_CORTINA_PHY is not set
CONFIG_DAVICOM_PHY=y
# CONFIG_DP83822_PHY is not set
CONFIG_DP83848_PHY=y
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_INTEL_XWAY_PHY=y
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_MARVELL_PHY is not set
CONFIG_MARVELL_10G_PHY=y
# CONFIG_MICREL_PHY is not set
CONFIG_MICROCHIP_PHY=y
CONFIG_MICROSEMI_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_RENESAS_PHY=y
CONFIG_ROCKCHIP_PHY=y
CONFIG_SMSC_PHY=y
# CONFIG_STE10XP is not set
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=y
# CONFIG_XILINX_GMII2RGMII is not set
CONFIG_PLIP=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
# CONFIG_PPP_DEFLATE is not set
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPPOE=y
CONFIG_PPPOL2TP=y
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=y

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
CONFIG_WIRELESS_WDS=y
# CONFIG_WLAN_VENDOR_ADMTEK is not set
CONFIG_ATH_COMMON=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_ATH9K_HW=y
CONFIG_ATH9K_COMMON=y
CONFIG_ATH9K_BTCOEX_SUPPORT=y
CONFIG_ATH9K=y
CONFIG_ATH9K_PCI=y
CONFIG_ATH9K_AHB=y
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_DFS_CERTIFIED=y
CONFIG_ATH9K_DYNACK=y
CONFIG_ATH9K_WOW=y
# CONFIG_ATH9K_CHANNEL_CONTEXT is not set
# CONFIG_ATH9K_PCOEM is not set
# CONFIG_ATH9K_HWRNG is not set
CONFIG_ATH6KL=y
CONFIG_ATH6KL_SDIO=y
CONFIG_ATH6KL_DEBUG=y
CONFIG_ATH6KL_TRACING=y
# CONFIG_ATH6KL_REGDOMAIN is not set
# CONFIG_WIL6210 is not set
CONFIG_ATH10K=y
# CONFIG_ATH10K_PCI is not set
CONFIG_ATH10K_SDIO=y
CONFIG_ATH10K_DEBUG=y
# CONFIG_ATH10K_DEBUGFS is not set
CONFIG_ATH10K_TRACING=y
# CONFIG_ATH10K_DFS_CERTIFIED is not set
CONFIG_WCN36XX=y
# CONFIG_WCN36XX_DEBUGFS is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_ATMEL is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_B43=y
CONFIG_B43_BCMA=y
CONFIG_B43_SSB=y
CONFIG_B43_BUSES_BCMA_AND_SSB=y
# CONFIG_B43_BUSES_BCMA is not set
# CONFIG_B43_BUSES_SSB is not set
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_SDIO=y
CONFIG_B43_BCMA_PIO=y
CONFIG_B43_PIO=y
CONFIG_B43_PHY_G=y
CONFIG_B43_PHY_N=y
# CONFIG_B43_PHY_LP is not set
CONFIG_B43_PHY_HT=y
CONFIG_B43_LEDS=y
CONFIG_B43_HWRNG=y
CONFIG_B43_DEBUG=y
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_PIO=y
# CONFIG_B43LEGACY_DMA_AND_PIO_MODE is not set
# CONFIG_B43LEGACY_DMA_MODE is not set
CONFIG_B43LEGACY_PIO_MODE=y
CONFIG_BRCMUTIL=y
CONFIG_BRCMSMAC=y
CONFIG_BRCMFMAC=y
# CONFIG_BRCMFMAC_SDIO is not set
# CONFIG_BRCMFMAC_PCIE is not set
# CONFIG_BRCM_TRACING is not set
# CONFIG_BRCMDBG is not set
# CONFIG_WLAN_VENDOR_CISCO is not set
CONFIG_WLAN_VENDOR_INTEL=y
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
# CONFIG_IWLWIFI is not set
# CONFIG_WLAN_VENDOR_INTERSIL is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_LIBERTAS=y
# CONFIG_LIBERTAS_SDIO is not set
# CONFIG_LIBERTAS_DEBUG is not set
# CONFIG_LIBERTAS_MESH is not set
CONFIG_LIBERTAS_THINFIRM=y
CONFIG_LIBERTAS_THINFIRM_DEBUG=y
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
# CONFIG_MWIFIEX_PCIE is not set
# CONFIG_MWL8K is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT76x2E is not set
# CONFIG_WLAN_VENDOR_RALINK is not set
# CONFIG_WLAN_VENDOR_REALTEK is not set
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_RSI_91X=y
# CONFIG_RSI_DEBUGFS is not set
CONFIG_RSI_SDIO=y
# CONFIG_RSI_COEX is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
# CONFIG_WLAN_VENDOR_TI is not set
# CONFIG_WLAN_VENDOR_ZYDAS is not set
# CONFIG_WLAN_VENDOR_QUANTENNA is not set
# CONFIG_MAC80211_HWSIM is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_HDLC is not set
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_SDLA=y
# CONFIG_LAPBETHER is not set
# CONFIG_X25_ASY is not set
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_IEEE802154_FAKELB is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
CONFIG_NETDEVSIM=y
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
CONFIG_CAPI_TRACE=y
CONFIG_ISDN_CAPI_CAPI20=y
# CONFIG_ISDN_CAPI_MIDDLEWARE is not set

#
# CAPI hardware drivers
#
# CONFIG_CAPI_AVM is not set
# CONFIG_CAPI_EICON is not set
# CONFIG_ISDN_DRV_GIGASET is not set
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
# CONFIG_MISDN_HFCMULTI is not set
# CONFIG_MISDN_AVMFRITZ is not set
# CONFIG_MISDN_SPEEDFAX is not set
# CONFIG_MISDN_INFINEON is not set
# CONFIG_MISDN_W6692 is not set
# CONFIG_MISDN_NETJET is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_INPORT is not set
# CONFIG_MOUSE_LOGIBM is not set
# CONFIG_MOUSE_PC110PAD is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_GPIO_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_GOLDFISH_TTY is not set
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=y
CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PROC_INTERFACE=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_SSIF=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_HW_RANDOM_VIRTIO is not set
# CONFIG_NVRAM is not set
CONFIG_DTLK=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
# CONFIG_MWAVE is not set
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_HW_RANDOM_TPM=y
# CONFIG_TCG_TIS is not set
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_KEMPLD=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_ELEKTOR is not set
CONFIG_I2C_PCA_ISA=y
CONFIG_I2C_CROS_EC_TUNNEL=y
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=y
# CONFIG_HSI is not set
# CONFIG_PPS is not set

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_PINCTRL=y
CONFIG_DEBUG_PINCTRL=y
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_MCP23S08 is not set
# CONFIG_PINCTRL_SX150X is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
# CONFIG_PINCTRL_BROXTON is not set
# CONFIG_PINCTRL_CANNONLAKE is not set
# CONFIG_PINCTRL_CEDARFORK is not set
# CONFIG_PINCTRL_DENVERTON is not set
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_LEWISBURG is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
CONFIG_GPIO_DWAPB=y
# CONFIG_GPIO_EXAR is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=y
# CONFIG_GPIO_MENZ127 is not set
# CONFIG_GPIO_MOCKUP is not set
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WINBOND is not set
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCF857X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_BD9571MWV is not set
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_KEMPLD is not set
CONFIG_GPIO_LP873X=y
CONFIG_GPIO_PALMAS=y
# CONFIG_GPIO_RC5T583 is not set
CONFIG_GPIO_TPS65086=y
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_TPS65912=y
# CONFIG_GPIO_TWL4030 is not set
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2805=y
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_DS28E17=y
CONFIG_POWER_AVS=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
CONFIG_CHARGER_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
CONFIG_CHARGER_88PM860X=y
CONFIG_CHARGER_PCF50633=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_LTC3651 is not set
CONFIG_CHARGER_MAX8997=y
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
CONFIG_BATTERY_RT5033=y
CONFIG_CHARGER_RT9455=y
# CONFIG_HWMON is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_CLOCK_THERMAL is not set
CONFIG_DEVFREQ_THERMAL=y
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
# CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED is not set
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
CONFIG_DA9063_WATCHDOG=y
# CONFIG_DA9062_WATCHDOG is not set
CONFIG_MENF21BMC_WATCHDOG=y
# CONFIG_WDAT_WDT is not set
CONFIG_XILINX_WATCHDOG=y
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_RAVE_SP_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
CONFIG_DW_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
CONFIG_MAX63XX_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_EBC_C384_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
# CONFIG_KEMPLD_WDT is not set
CONFIG_SC1200_WDT=y
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_RDC321X_WDT is not set
# CONFIG_60XX_WDT is not set
CONFIG_SBC8360_WDT=y
CONFIG_SBC7240_WDT=y
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
CONFIG_MEN_A21_WDT=y

#
# ISA-based Watchdog Cards
#
CONFIG_PCWATCHDOG=y
CONFIG_MIXCOMWD=y
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# Watchdog Pretimeout Governors
#
CONFIG_WATCHDOG_PRETIMEOUT_GOV=y
# CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_NOOP is not set
CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_PANIC=y
CONFIG_WATCHDOG_PRETIMEOUT_GOV_NOOP=y
CONFIG_WATCHDOG_PRETIMEOUT_GOV_PANIC=y
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_BLOCKIO=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_SFLASH=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
# CONFIG_MFD_CROS_EC_CHARDEV is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
# CONFIG_MFD_DA9150 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
CONFIG_MFD_TI_LMU=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
# CONFIG_MFD_WM8998 is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_RAVE_SP_CORE=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PG86X=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_BD9571MWV=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9063=y
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_DA9211 is not set
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LM363X=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_LTC3676=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8997=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
CONFIG_REGULATOR_MT6397=y
# CONFIG_REGULATOR_PALMAS is not set
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
# CONFIG_REGULATOR_QCOM_SPMI is not set
# CONFIG_REGULATOR_RC5T583 is not set
# CONFIG_REGULATOR_RT5033 is not set
CONFIG_REGULATOR_SKY81452=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65132=y
CONFIG_REGULATOR_TPS65910=y
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_TWL4030=y
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_REGULATOR_WM8994=y
# CONFIG_RC_CORE is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
# CONFIG_BACKLIGHT_CLASS_DEVICE is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_ASUS is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LED is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=y
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
# CONFIG_MMC_SDHCI_F_SDH30 is not set
# CONFIG_MMC_WBSD is not set
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_GOLDFISH is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
# CONFIG_MMC_CQHCI is not set
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MMC_SDHCI_XENON=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_AS3645A is not set
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_MT6323=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_MLXREG=y
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_MTD=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_LEDS_TRIGGER_PANIC=y
CONFIG_LEDS_TRIGGER_NETDEV=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
CONFIG_INFINIBAND_USER_ACCESS=y
# CONFIG_INFINIBAND_EXP_LEGACY_VERBS_NEW_UAPI is not set
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ON_DEMAND_PAGING=y
CONFIG_INFINIBAND_ADDR_TRANS=y
# CONFIG_INFINIBAND_MTHCA is not set
# CONFIG_MLX4_INFINIBAND is not set
# CONFIG_INFINIBAND_NES is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
# CONFIG_RDMA_RXE is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_AMD76X is not set
# CONFIG_EDAC_E7XXX is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82875P is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_IE31200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_ALTERA_MSGDMA=y
CONFIG_INTEL_IDMA64=y
# CONFIG_PCH_DMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_AUXDISPLAY is not set
CONFIG_CHARLCD=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=y
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_STAGING=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_NCP_FS=y
# CONFIG_NCPFS_PACKET_SIGNING is not set
# CONFIG_NCPFS_IOCTL_LOCKING is not set
# CONFIG_NCPFS_STRONG is not set
CONFIG_NCPFS_NFS_NS=y
# CONFIG_NCPFS_OS2_NS is not set
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
# CONFIG_NCPFS_EXTRAS is not set
CONFIG_COMEDI=y
CONFIG_COMEDI_DEBUG=y
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=y
# CONFIG_COMEDI_TEST is not set
# CONFIG_COMEDI_PARPORT is not set
CONFIG_COMEDI_SERIAL2002=y
CONFIG_COMEDI_SSV_DNP=y
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y

#
# Android
#
CONFIG_GOLDFISH_AUDIO=y
CONFIG_MTD_GOLDFISH_NAND=y
CONFIG_LNET=y
CONFIG_LNET_MAX_PAYLOAD=1048576
CONFIG_LNET_SELFTEST=y
CONFIG_LNET_XPRT_IB=y
# CONFIG_LUSTRE_FS is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
# CONFIG_UNISYSSPAR is not set
CONFIG_WILC1000=y
CONFIG_WILC1000_SDIO=y
# CONFIG_WILC1000_HW_OOB_INTR is not set
CONFIG_MOST=y
CONFIG_MOST_CDEV=y
CONFIG_MOST_NET=y
# CONFIG_MOST_DIM2 is not set
CONFIG_MOST_I2C=y
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_MTK_MMC is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
# CONFIG_GOLDFISH_BUS is not set
# CONFIG_GOLDFISH_PIPE is not set
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_PSTORE is not set
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI544 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_CLK_TWL6040 is not set
# CONFIG_COMMON_CLK_PALMAS is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
# CONFIG_RPMSG_CHAR is not set
CONFIG_RPMSG_VIRTIO=y
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#
# CONFIG_SOUNDWIRE_INTEL is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_AXP288 is not set
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX3355 is not set
CONFIG_EXTCON_MAX77843=y
# CONFIG_EXTCON_MAX8997 is not set
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_EXTCON_USBC_CROS_EC is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_RESET_TI_SYSCON=y
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_RAS_CEC is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_DAX=y
# CONFIG_DEV_DAX is not set
CONFIG_NVMEM=y

#
# HW tracing support
#
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set
CONFIG_FPGA=y
# CONFIG_ALTERA_PR_IP_CORE is not set
# CONFIG_FPGA_MGR_ALTERA_CVP is not set
CONFIG_FPGA_BRIDGE=y
CONFIG_XILINX_PR_DECOUPLER=y
CONFIG_FPGA_REGION=y
CONFIG_PM_OPP=y
# CONFIG_SIOX is not set
CONFIG_SLIMBUS=y
# CONFIG_SLIM_QCOM_CTRL is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
# CONFIG_OVERLAY_FS_INDEX is not set
# CONFIG_OVERLAY_FS_XINO_AUTO is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_CONFIGFS_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_SUNRPC_XPRT_RDMA=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
CONFIG_CIFS_UPCALL=y
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DEBUG_DUMP_KEYS=y
CONFIG_CIFS_DFS_UPCALL=y
CONFIG_CIFS_SMB311=y
CONFIG_CIFS_SMB_DIRECT=y
# CONFIG_CODA_FS is not set
CONFIG_AFS_FS=y
CONFIG_AFS_DEBUG=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_PAGE_REF=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set
# CONFIG_DEBUG_PREEMPT is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
CONFIG_RCU_EQS_DEBUG=y
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_NETDEV_NOTIFIER_ERROR_INJECT=y
CONFIG_FAULT_INJECTION=y
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_PREEMPTIRQ_EVENTS=y
CONFIG_IRQSOFF_TRACER=y
# CONFIG_PREEMPT_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_HWLAT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_BRANCH_TRACER is not set
CONFIG_STACK_TRACER=y
# CONFIG_UPROBE_EVENTS is not set
# CONFIG_DYNAMIC_FTRACE is not set
CONFIG_FUNCTION_PROFILER=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_RUNTIME_TESTING_MENU=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_UUID is not set
CONFIG_TEST_RHASHTABLE=y
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_PARMAN is not set
CONFIG_FIND_BIT_BENCHMARK=y
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_SYSCTL is not set
CONFIG_TEST_UDELAY=y
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
# CONFIG_UBSAN_NULL is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_WX=y
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_ENTRY=y
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_FRAME_POINTER=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_FORTIFY_SOURCE=y
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
# CONFIG_CRYPTO_CRCT10DIF is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
# CONFIG_CRYPTO_SM3 is not set
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
CONFIG_CRYPTO_SM4=y
CONFIG_CRYPTO_SPECK=y
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_AEAD=y
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC4=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_AUDIT_GENERIC=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_STACKDEPOT=y
CONFIG_PARMAN=y
CONFIG_STRING_SELFTEST=y
-------------- next part --------------
#!/bin/sh

export_top_env()
{
	export suite='boot'
	export testcase='boot'
	export timeout='10m'
	export job_origin='/lkp/lkp/src/jobs/boot.yaml'
	export queue='validate'
	export testbox='vm-lkp-nhm-dp1-yocto-i386-7'
	export tbox_group='vm-lkp-nhm-dp1-yocto-i386'
	export branch='linus/master'
	export commit='60cc43fc888428bb2f18f08997432d426a243338'
	export kconfig='i386-randconfig-s1-201814'
	export repeat_to=4
	export submit_id='5ad498cb0b9a9321a9e97fce'
	export job_file='/lkp/scheduled/vm-lkp-nhm-dp1-yocto-i386-7/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180416-74153-1703sy7-0.yaml'
	export id='afbb8d8c455a334c1b9435edf4a7c1b5586623d7'
	export model='qemu-system-i386 -enable-kvm'
	export nr_vm=20
	export nr_cpu=1
	export memory='256M'
	export rootfs='yocto-tiny-i386-2016-04-22.cgz'
	export need_kconfig='CONFIG_KVM_GUEST=y'
	export compiler='gcc-6'
	export enqueue_time='2018-04-16 20:36:27 +0800'
	export _id='5ad498cb0b9a9321a9e97fce'
	export _rt='/result/boot/1/vm-lkp-nhm-dp1-yocto-i386/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338'
	export user='lkp'
	export result_root='/result/boot/1/vm-lkp-nhm-dp1-yocto-i386/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/0'
	export LKP_SERVER='inn'
	export max_uptime=600
	export initrd='/osimage/yocto/yocto-tiny-i386-2016-04-22.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/scheduled/vm-lkp-nhm-dp1-yocto-i386-7/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180416-74153-1703sy7-0.yaml
ARCH=i386
kconfig=i386-randconfig-s1-201814
branch=linus/master
commit=60cc43fc888428bb2f18f08997432d426a243338
BOOT_IMAGE=/pkg/linux/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
max_uptime=600
RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp1-yocto-i386/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/0
LKP_SERVER=inn
debug
apic=debug
sysrq_always_enabled
rcupdate.rcu_cpu_stall_timeout=100
net.ifnames=0
printk.devkmsg=on
panic=-1
softlockup_panic=1
nmi_watchdog=panic
oops=panic
load_ramdisk=2
prompt_ramdisk=0
drbd.minor_count=8
systemd.log_level=err
ignore_loglevel
console=tty0
earlyprintk=ttyS0,115200
console=ttyS0,115200
vga=normal
rw'
	export bm_initrd='/osimage/deps/debian-x86_64-2016-08-31.cgz/run-ipconfig.i386_2016-09-03.cgz'
	export lkp_initrd='/lkp/lkp/lkp-i386.cgz'
	export site='inn'
	export LKP_CGI_PORT=80
	export LKP_CIFS_PORT=139
	export kernel='/pkg/linux/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1'
	export dequeue_time='2018-04-16 20:44:37 +0800'
	export job_initrd='/lkp/scheduled/vm-lkp-nhm-dp1-yocto-i386-7/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180416-74153-1703sy7-0.cgz'

	[ -n "$LKP_SRC" ] ||
	export LKP_SRC=/lkp/${user:-lkp}/src
}

run_job()
{
	echo $$ > $TMP/run-job.pid

	. $LKP_SRC/lib/http.sh
	. $LKP_SRC/lib/job.sh
	. $LKP_SRC/lib/env.sh

	export_top_env

	run_monitor $LKP_SRC/monitors/one-shot/wrapper boot-slabinfo
	run_monitor $LKP_SRC/monitors/one-shot/wrapper boot-meminfo
	run_monitor $LKP_SRC/monitors/one-shot/wrapper memmap
	run_monitor $LKP_SRC/monitors/no-stdout/wrapper boot-time
	run_monitor $LKP_SRC/monitors/wrapper kmsg
	run_monitor $LKP_SRC/monitors/wrapper oom-killer
	run_monitor $LKP_SRC/monitors/plain/watchdog

	run_test $LKP_SRC/tests/wrapper sleep 1
}

extract_stats()
{
	$LKP_SRC/stats/wrapper boot-slabinfo
	$LKP_SRC/stats/wrapper boot-meminfo
	$LKP_SRC/stats/wrapper memmap
	$LKP_SRC/stats/wrapper boot-memory
	$LKP_SRC/stats/wrapper boot-time
	$LKP_SRC/stats/wrapper kernel-size
	$LKP_SRC/stats/wrapper kmsg

	$LKP_SRC/stats/wrapper time sleep.time
	$LKP_SRC/stats/wrapper time
	$LKP_SRC/stats/wrapper dmesg
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper stderr
	$LKP_SRC/stats/wrapper last_state
}

"$@"
-------------- next part --------------
#!/bin/bash

# To reproduce,
# 1) save job-script and this script (both are attached in 0day report email)
# 2) run this script with your compiled kernel and optional env $INSTALL_MOD_PATH

kernel=$1

initrds=(
	/osimage/yocto/yocto-tiny-i386-2016-04-22.cgz
	/lkp/lkp/lkp-i386.cgz
	/osimage/deps/debian-x86_64-2016-08-31.cgz/run-ipconfig.i386_2016-09-03.cgz
)

HTTP_PREFIX=https://github.com/0day-ci/lkp-qemu/raw/master
wget --timestamping "${initrds[@]/#/$HTTP_PREFIX}"

{
	cat "${initrds[@]//*\//}"
	[[ $INSTALL_MOD_PATH ]] && (
		cd "$INSTALL_MOD_PATH"
		find lib | cpio -o -H newc --quiet | gzip
	)
	echo  job-script | cpio -o -H newc --quiet | gzip
} > initrd.img

kvm=(
	qemu-system-i386
	-enable-kvm
	-kernel $kernel
	-initrd initrd.img
	-m 256
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	ip=::::vm-lkp-nhm-dp1-yocto-i386-7::dhcp
	root=/dev/ram0
	user=lkp
	job=/job-script
	ARCH=i386
	kconfig=i386-randconfig-s1-201814
	branch=linus/master
	commit=60cc43fc888428bb2f18f08997432d426a243338
	BOOT_IMAGE=/pkg/linux/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
	max_uptime=600
	RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp1-yocto-i386/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-s1-201814/gcc-6/60cc43fc888428bb2f18f08997432d426a243338/0
	result_service=tmpfs
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"
