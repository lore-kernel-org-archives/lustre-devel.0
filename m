From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 18 Apr 2018 22:15:50 +0800
Subject: [lustre-devel] [lnet_res_container_setup] BUG: unable to handle
 kernel paging request at 08000664
In-Reply-To: <20180418133831.uef7d77ejdyjtxgh@wfg-t540p.sh.intel.com>
Message-ID: <20180418141550.qen7voyknh4ot4o7@wfg-t540p.sh.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, lkp@01.org, Denis Petrovic <denis.petrovic@edu.ece.fr>, Linus Torvalds <torvalds@linux-foundation.org>, lustre-devel@lists.lustre.org

Hi James,

Here the .config has SMP set.

FYI this happens in mainline kernel 4.17.0-rc1.
It looks like a new regression.

It occurs in 4 out of 5 boots.

[    6.872036] usbhid: USB HID core driver
[    6.872383] NET: Registered protocol family 4
[    6.872889] no options.
[    6.874165] LNet: HW nodes: 1, HW CPU cores: 1, npartitions: 1
[    6.874688] LNetError: 1:0:(module.c:546:libcfs_init()) misc_register: error -16
[    7.893425] BUG: unable to handle kernel paging request at 08000664
[    7.893989] *pde = 00000000
[    7.894251] Oops: 0000 [#1] SMP
[    7.894528] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G S                4.17.0-rc1 #198
[    7.895196] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[    7.895924] EIP: cfs_cpt_spread_node+0x5c/0x115:
						bitmap_weight at include/linux/bitmap.h:360
						 (inlined by) __nodes_weight at include/linux/nodemask.h:240
						 (inlined by) cfs_cpt_spread_node at drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c:498
[    7.896320] EFLAGS: 00210202 CPU: 0
[    7.896625] EAX: d6c31320 EBX: 00000001 ECX: 00000001 EDX: 00000000
[    7.896678] ESI: 08000664 EDI: 00000000 EBP: c7ea3e88 ESP: c7ea3e78
[    7.896678]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    7.896678] CR0: 80050033 CR2: 08000664 CR3: 05380000 CR4: 00000690
[    7.896678] Call Trace:
[    7.896678]  lnet_res_container_setup+0x9a/0x210:
						lnet_res_container_setup at drivers/staging/lustre/lnet/lnet/api-ni.c:426
[    7.896678]  LNetNIInit+0x701/0xdef:
						lnet_prepare at drivers/staging/lustre/lnet/lnet/api-ni.c:577
						 (inlined by) LNetNIInit at drivers/staging/lustre/lnet/lnet/api-ni.c:1517
[    7.896678]  ? ktime_get_real_seconds+0xe3/0xf9:
						ktime_get_real_seconds at kernel/time/timekeeping.c:938
[    7.896678]  srpc_startup+0x8b/0x413:
						srpc_startup at drivers/staging/lustre/lnet/selftest/rpc.c:1613
[    7.896678]  lnet_selftest_init+0x3de/0x78c:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:134
[    7.896678]  do_one_initcall+0x1a2/0x410:
						do_one_initcall at init/main.c:883
[    7.896678]  ? lnet_selftest_exit+0xa8/0xa8:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:90
[    7.896678]  ? parse_args+0x94/0x3b6:
						parse_args at kernel/params.c:180 (discriminator 8)
[    7.896678]  kernel_init_freeable+0x3b3/0x488:
						do_initcall_level at init/main.c:951
						 (inlined by) do_initcalls at init/main.c:959
						 (inlined by) do_basic_setup at init/main.c:977
						 (inlined by) kernel_init_freeable at init/main.c:1127
[    7.896678]  ? rest_init+0x11b/0x11b:
						kernel_init at init/main.c:1050
[    7.896678]  kernel_init+0xd/0x15f:
						kernel_init at init/main.c:1055
[    7.896678]  ret_from_fork+0x2e/0x40:
						ret_from_fork at arch/x86/entry/entry_32.S:311
[    7.896678] Code: c4 74 11 8b 50 04 8b 70 18 89 55 f0 8d 4a 01 89 48 04 eb 17 6b d2 0c 03 50 0c 89 d1 8b 42 08 8b 72 04 89 45 f0 8d 50 01 89 51 08 <8b> 06 6a 00 83 e0 01 e8 5c 82 d7 fe 89 c3 31 c0 85 db 0f 9e c0
[    7.896678] EIP: cfs_cpt_spread_node+0x5c/0x115:
						bitmap_weight at include/linux/bitmap.h:360
						 (inlined by) __nodes_weight at include/linux/nodemask.h:240
						 (inlined by) cfs_cpt_spread_node at drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c:498 SS:ESP: 0068:c7ea3e78
[    7.896678] CR2: 0000000008000664
[    7.896678] ---[ end trace 5246465f75f74727 ]---
[    7.896678] Kernel panic - not syncing: Fatal exception

Attached the full dmesg, kconfig and reproduce scripts.

Thanks,
Fengguang
-------------- next part --------------
early console in setup code
[    0.000000] Linux version 4.17.0-rc1 (kbuild at cairo) (gcc version 7.3.0 (Debian 7.3.0-1)) #198 SMP Wed Apr 18 04:25:31 CST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001a3dffff] usable
[    0.000000] BIOS-e820: [mem 0x000000001a3e0000-0x000000001a3fffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x1a3e0 max_arch_pfn = 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: PAT not supported by CPU.
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f6aa0-0x000f6aaf] mapped at [(ptrval)]
[    0.000000]   mpc: f6ab0-f6b80
[    0.000000] initial memory mapped: [mem 0x00000000-0x05ffffff]
[    0.000000] Base memory trampoline at [(ptrval)] 9b000 size 16384
[    0.000000] BRK [0x05a8c000, 0x05a8cfff] PGTABLE
[    0.000000] RAMDISK: [mem 0x1a121000-0x1a3dffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F68D0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000001A3E15CE 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000001A3E142A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000001A3E0040 0013EA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000001A3E0000 000040
[    0.000000] ACPI: APIC 0x000000001A3E151E 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000001A3E1596 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 419MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 1a3e0000
[    0.000000]   low ram: 0 - 1a3e0000
[    0.000000] kvm-clock: cpu 0, msr 0:1a11f001, primary cpu clock
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: using sched offset of 2783567941 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x000000001a3dffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001a3dffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001a3dffff]
[    0.000000] On node 0 totalpages: 107390
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 808 pages used for memmap
[    0.000000]   Normal zone: 103392 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] e820: [mem 0x1a400000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:1 nr_cpu_ids:1 nr_node_ids:1
[    0.000000] percpu: Embedded 347 pages/cpu @(ptrval) s1400528 r0 d20784 u1421312
[    0.000000] pcpu-alloc: s1400528 r0 d20784 u1421312 alloc=347*4096
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 19c4c880
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 106550
[    0.000000] Kernel command line: ip=::::vm-lkp-nhm-dp2-yocto-ia32-6::dhcp root=/dev/ram0 user=lkp job=/lkp/scheduled/vm-lkp-nhm-dp2-yocto-ia32-6/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180418-10482-1lry5np-0.yaml ARCH=i386 kconfig=i386-randconfig-c0-04180358 branch=linus/master commit=60cc43fc888428bb2f18f08997432d426a243338 BOOT_IMAGE=/pkg/linux/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1 max_uptime=600 RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp2-yocto-ia32/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0 LKP_SERVER=inn debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 net.ifnames=0 printk.devkmsg=on panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 drbd.minor_count=8 systemd.log_level=err ignore_loglevel console=tty0 earlyprintk=ttyS0,115200 console=ttyS0,115200 vga=normal rw d
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] BRK [0x05a8d000, 0x05a8dfff] PGTABLE
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 54244K/429560K available (36141K kernel code, 12277K rwdata, 17240K rodata, 3000K init, 7128K bss, 84624K reserved, 0K cma-reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff17000 - 0xfffff000   ( 928 kB)
[    0.000000]   cpu_entry : 0xff800000 - 0xff939000   (1252 kB)
[    0.000000]     vmalloc : 0xdabe0000 - 0xff7fe000   ( 588 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xda3e0000   ( 419 MB)
[    0.000000]       .init : 0xc507e000 - 0xc536c000   (3000 kB)
[    0.000000]       .data : 0xc334b7c0 - 0xc50286a0   (29555 kB)
[    0.000000]       .text : 0xc1000000 - 0xc334b7c0   (36141 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] ftrace: allocating 92948 entries in 182 pages
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
[    0.003333] Hierarchical RCU implementation.
[    0.003333] 	RCU event tracing is enabled.
[    0.003333] 	RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=1.
[    0.003333] 	RCU CPU stall warnings timeout set to 100 (rcu_cpu_stall_timeout).
[    0.003333] 	Tasks RCU enabled.
[    0.003333] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
[    0.003333] NR_IRQS: 2304, nr_irqs: 48, preallocated irqs: 16
[    0.003333] CPU 0 irqstacks, hard=(ptrval) soft=(ptrval)
[    0.003333] 	Offload RCU callbacks from CPUs: (none).
[    0.003333] console [ttyS0] enabled
[    0.003333] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.003333] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.003333] ... MAX_LOCK_DEPTH:          48
[    0.003333] ... MAX_LOCKDEP_KEYS:        8191
[    0.003333] ... CLASSHASH_SIZE:          4096
[    0.003333] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.003333] ... MAX_LOCKDEP_CHAINS:      65536
[    0.003333] ... CHAINHASH_SIZE:          32768
[    0.003333]  memory used by lock dependency info: 4639 kB
[    0.003333]  per task-struct memory footprint: 2112 bytes
[    0.003333] ------------------------
[    0.003333] | Locking API testsuite:
[    0.003333] ----------------------------------------------------------------------------
[    0.003333]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]                      A-A deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]                  A-B-B-A deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]              A-B-B-C-C-A deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]              A-B-C-A-B-C deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]          A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]          A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]          A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |failed|failed|failed|failed|
[    0.003333]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]               recursive read-lock:             |  ok  |             |failed|
[    0.003333]            recursive read-lock #2:             |  ok  |             |failed|
[    0.003333]             mixed read-write-lock:             |failed|             |failed|
[    0.003333]             mixed write-read-lock:             |failed|             |failed|
[    0.003333]   mixed read-lock/lock-write ABBA:             |failed|             |failed|
[    0.003333]    mixed read-lock/lock-read ABBA:             |  ok  |             |failed|
[    0.003333]  mixed write-lock/lock-write ABBA:             |failed|             |failed|
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]      hard-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.003333]      soft-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.003333]      hard-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.003333]      soft-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.003333]        sirq-safe-A => hirqs-on/12:failed|failed|  ok  |
[    0.003333]        sirq-safe-A => hirqs-on/21:failed|failed|  ok  |
[    0.003333]          hard-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.003333]          soft-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.003333]          hard-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.003333]          soft-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.003333]       hard-irq lock-inversion/123:failed|failed|  ok  |
[    0.003333]       soft-irq lock-inversion/123:failed|failed|  ok  |
[    0.003333]       hard-irq lock-inversion/132:failed|failed|  ok  |
[    0.003333]       soft-irq lock-inversion/132:failed|failed|  ok  |
[    0.003333]       hard-irq lock-inversion/213:failed|failed|  ok  |
[    0.003333]       soft-irq lock-inversion/213:failed|failed|  ok  |
[    0.003333]       hard-irq lock-inversion/231:failed|failed|  ok  |
[    0.003333]       soft-irq lock-inversion/231:failed|failed|  ok  |
[    0.003333]       hard-irq lock-inversion/312:failed|failed|  ok  |
[    0.003333]       soft-irq lock-inversion/312:failed|failed|  ok  |
[    0.003333]       hard-irq lock-inversion/321:failed|failed|  ok  |
[    0.003333]       soft-irq lock-inversion/321:failed|failed|  ok  |
[    0.003333]       hard-irq read-recursion/123:  ok  |
[    0.003333]       soft-irq read-recursion/123:  ok  |
[    0.003333]       hard-irq read-recursion/132:  ok  |
[    0.003333]       soft-irq read-recursion/132:  ok  |
[    0.003333]       hard-irq read-recursion/213:  ok  |
[    0.003333]       soft-irq read-recursion/213:  ok  |
[    0.003333]       hard-irq read-recursion/231:  ok  |
[    0.003333]       soft-irq read-recursion/231:  ok  |
[    0.003333]       hard-irq read-recursion/312:  ok  |
[    0.003333]       soft-irq read-recursion/312:  ok  |
[    0.003333]       hard-irq read-recursion/321:  ok  |
[    0.003333]       soft-irq read-recursion/321:  ok  |
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]   | Wound/wait tests |
[    0.003333]   ---------------------
[    0.003333]                   ww api failures:  ok  |  ok  |  ok  |
[    0.003333]                ww contexts mixing:failed|  ok  |
[    0.003333]              finishing ww context:  ok  |  ok  |  ok  |  ok  |
[    0.003333]                locking mismatches:  ok  |  ok  |  ok  |
[    0.003333]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]            spinlock nest unlocked:  ok  |
[    0.003333]   -----------------------------------------------------
[    0.003333]                                  |block | try  |context|
[    0.003333]   -----------------------------------------------------
[    0.003333]                           context:failed|  ok  |  ok  |
[    0.003333]                               try:failed|  ok  |failed|
[    0.003333]                             block:failed|  ok  |failed|
[    0.003333]                          spinlock:failed|  ok  |failed|
[    0.003333] --------------------------------------------------------
[    0.003333] 153 out of 262 testcases failed, as expected. |
[    0.003333] ----------------------------------------------------
[    0.003333] ACPI: Core revision 20180313
[    0.003333] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.003333] hpet clockevent registered
[    0.003356] APIC: Switch to symmetric I/O mode setup
[    0.003836] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.004369] enabled ExtINT on CPU#0
[    0.005332] ENABLING IO-APIC IRQs
[    0.005650] init IO_APIC IRQs
[    0.005933]  apic 0 pin 0 not connected
[    0.006698] IOAPIC[0]: Set routing entry (0-1 -> 0xef -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.007442] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.008168] IOAPIC[0]: Set routing entry (0-3 -> 0xef -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.008890] IOAPIC[0]: Set routing entry (0-4 -> 0xef -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.009615] IOAPIC[0]: Set routing entry (0-5 -> 0xef -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-6 -> 0xef -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-7 -> 0xef -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-8 -> 0xef -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-9 -> 0xef -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-10 -> 0xef -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-11 -> 0xef -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-12 -> 0xef -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-13 -> 0xef -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-14 -> 0xef -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.009999] IOAPIC[0]: Set routing entry (0-15 -> 0xef -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.009999]  apic 0 pin 16 not connected
[    0.009999]  apic 0 pin 17 not connected
[    0.009999]  apic 0 pin 18 not connected
[    0.009999]  apic 0 pin 19 not connected
[    0.009999]  apic 0 pin 20 not connected
[    0.009999]  apic 0 pin 21 not connected
[    0.009999]  apic 0 pin 22 not connected
[    0.009999]  apic 0 pin 23 not connected
[    0.009999] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.009999] tsc: Detected 2925.998 MHz processor
[    0.009999] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x2a2d3295deb, max_idle_ns: 440795332860 ns
[    0.009999] Calibrating delay loop (skipped) preset value.. 5854.82 BogoMIPS (lpj=9753326)
[    0.010009] pid_max: default: 32768 minimum: 301
[    0.010475] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.011046] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.012098] CPU: Physical Processor ID: 0
[    0.012482] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.013342] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.013877] Spectre V2 : Mitigation: Full generic retpoline
[    0.014355] Spectre V2 : Spectre v2 mitigation: Filling RSB on context switch
[    0.034546] Freeing SMP alternatives memory: 68K
[    0.037333] Using local APIC timer interrupts.
[    0.037333] calibrating APIC timer ...
[    0.039999] ... lapic delta = 6250100
[    0.039999] ... PM-Timer delta = 357963
[    0.039999] ... PM-Timer result ok
[    0.039999] ..... delta 6250100
[    0.039999] ..... mult: 268439777
[    0.039999] ..... calibration result: 3333386
[    0.039999] ..... CPU clock speed is 2926.1622 MHz.
[    0.039999] ..... host bus clock speed is 1000.0386 MHz.
[    0.040081] smpboot: CPU0: Intel QEMU Virtual CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
[    0.041544] Performance Events: PMU not available due to virtualization, using software events only.
[    0.044394] Hierarchical SRCU implementation.
[    0.051851] NMI watchdog: Perf event create on CPU 0 failed with -2
[    0.052432] NMI watchdog: Perf NMI watchdog permanently disabled
[    0.053179] smp: Bringing up secondary CPUs ...
[    0.053343] smp: Brought up 1 node, 1 CPU
[    0.053705] smpboot: Max logical packages: 1
[    0.054091] smpboot: Total of 1 processors activated (5854.82 BogoMIPS)
[    0.056679] node 0 initialised, 72673 pages in 3ms
[    0.057537] devtmpfs: initialized
[    0.063431] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
[    0.064310] futex hash table entries: 256 (order: 2, 16384 bytes)
[    0.064943] xor: measuring software checksum speed
[    0.096674]    pIII_sse  : 13773.600 MB/sec
[    0.130006]    prefetch64-sse: 16150.800 MB/sec
[    0.130407] xor: using function: prefetch64-sse (16150.800 MB/sec)
[    0.130945] prandom: seed boundary self test passed
[    0.131994] prandom: 100 self tests passed
[    0.132363] pinctrl core: initialized pinctrl subsystem
[    0.133400] NET: Registered protocol family 16
[    0.136105] audit: initializing netlink subsys (disabled)
[    0.137221] EISA bus registered
[    0.137516] cpuidle: using governor menu
[    0.139841] ACPI: bus type PCI registered
[    0.140022] audit: type=2000 audit(1523999178.409:1): state=initialized audit_enabled=0 res=1
[    0.141079] PCI: Using configuration type 1 for base access
[    0.202633] HugeTLB registered 4.00 MiB page size, pre-allocated 0 pages
[    0.203733] cryptd: max_cpu_qlen set to 1000
[    0.260009] raid6: mmxx1    gen()  4461 MB/s
[    0.316681] raid6: mmxx2    gen()  5264 MB/s
[    0.373355] raid6: sse1x1   gen()  3853 MB/s
[    0.430014] raid6: sse1x2   gen()  4662 MB/s
[    0.486682] raid6: sse2x1   gen()  7666 MB/s
[    0.543340] raid6: sse2x1   xor()  5399 MB/s
[    0.600015] raid6: sse2x2   gen()  9094 MB/s
[    0.656676] raid6: sse2x2   xor()  7123 MB/s
[    0.657093] raid6: using algorithm sse2x2 gen() 9094 MB/s
[    0.657555] raid6: .... xor() 7123 MB/s, rmw enabled
[    0.658003] raid6: using intx1 recovery algorithm
[    0.658724] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.659235] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.660020] ACPI: Added _OSI(Module Device)
[    0.660401] ACPI: Added _OSI(Processor Device)
[    0.660796] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.661221] ACPI: Added _OSI(Processor Aggregator Device)
[    0.661700] ACPI: Added _OSI(Linux-Dell-Video)
[    0.668817] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.674731] ACPI: Interpreter enabled
[    0.675091] ACPI: (supports S0 S5)
[    0.675404] ACPI: Using IOAPIC for interrupt routing
[    0.676139] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.677295] ACPI: Enabled 2 GPEs in block 00 to 0F
[    0.697178] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.697738] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.698247] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.698845] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.700085] PCI host bridge to bus 0000:00
[    0.700458] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.701068] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.701659] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.702313] pci_bus 0000:00: root bus resource [mem 0x1a400000-0xfebfffff window]
[    0.702969] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.703387] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.704792] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.706289] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.709282] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.711323] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.711980] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.712539] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.713154] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.714024] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.714890] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.715523] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.717497] pci 0000:00:02.0: [1234:1111] type 00 class 0x030000
[    0.719498] pci 0000:00:02.0: reg 0x10: [mem 0xfd000000-0xfdffffff pref]
[    0.722320] pci 0000:00:02.0: reg 0x18: [mem 0xfebf0000-0xfebf0fff]
[    0.728588] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.730605] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.732044] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.733343] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.738932] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.740818] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.741828] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.746479] pci_bus 0000:00: on NUMA node 0
[    0.748331] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.749213] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.750358] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.751255] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.751929] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.753698] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.754224] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.754955] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.755447] vgaarb: loaded
[    0.757315] SCSI subsystem initialized
[    0.757813] ACPI: bus type USB registered
[    0.758241] usbcore: registered new interface driver usbfs
[    0.758756] usbcore: registered new interface driver hub
[    0.759297] usbcore: registered new device driver usb
[    0.760206] EDAC MC: Ver: 3.0.0
[    0.761814] FPGA manager framework
[    0.762243] Advanced Linux Sound Architecture Driver Initialized.
[    0.762852] PCI: Using ACPI for IRQ routing
[    0.763223] PCI: pci_cache_line_size set to 64 bytes
[    0.763440] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.763968] e820: reserve RAM buffer [mem 0x1a3e0000-0x1bffffff]
[    0.765316] nfc: nfc_init: NFC Core ver 0.1
[    0.765749] NET: Registered protocol family 39
[    0.766750] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[    0.769375] clocksource: Switched to clocksource kvm-clock
[    0.769999] workqueue: round-robin CPU selection forced, expect performance impact
[    0.789380] Warning: could not register all branches stats
[    0.789877] Warning: could not register annotated branches stats
[    1.002193] VFS: Disk quotas dquot_6.6.0
[    1.003052] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    1.003970] FS-Cache: Loaded
[    1.004434] pnp: PnP ACPI init
[    1.004941] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.005711] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.006593] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.007268] pnp 00:03: [dma 2]
[    1.007652] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.008516] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.009376] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.010246] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.012059] pnp: PnP ACPI: found 7 devices
[    1.048690] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.050042] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    1.050586] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    1.051115] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    1.051707] pci_bus 0000:00: resource 7 [mem 0x1a400000-0xfebfffff window]
[    1.052595] NET: Registered protocol family 2
[    1.053752] tcp_listen_portaddr_hash hash table entries: 256 (order: 1, 12288 bytes)
[    1.054453] TCP established hash table entries: 4096 (order: 2, 16384 bytes)
[    1.055084] TCP bind hash table entries: 4096 (order: 5, 180224 bytes)
[    1.055826] TCP: Hash tables configured (established 4096 bind 4096)
[    1.056445] UDP hash table entries: 256 (order: 2, 24576 bytes)
[    1.057158] UDP-Lite hash table entries: 256 (order: 2, 24576 bytes)
[    1.057883] NET: Registered protocol family 1
[    1.058612] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.059149] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.059661] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.060265] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.061003] PCI: CLS 0 bytes, default 64
[    1.061610] Unpacking initramfs...
[    1.700708] Freeing initrd memory: 2812K
[    1.704721] PCLMULQDQ-NI instructions are not detected.
[    1.705210] The force parameter has not been set to 1. The Iris poweroff handler will not be installed.
[    1.706087] NatSemi SCx200 Driver
[    1.706480] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    1.708028] spin_lock-torture: Creating torture_shuffle task
[    1.708754] spin_lock-torture: Creating torture_stutter task
[    1.709297] spin_lock-torture: torture_shuffle task started
[    1.709806] spin_lock-torture: Creating lock_torture_writer task
[    1.710413] spin_lock-torture: torture_stutter task started
[    1.710922] spin_lock-torture: Creating lock_torture_writer task
[    1.711489] spin_lock-torture: lock_torture_writer task started
[    1.712036] spin_lock-torture: Creating lock_torture_stats task
[    1.712732] spin_lock-torture: lock_torture_writer task started
[    1.713300] torture_init_begin: Refusing rcu init: spin_lock running.
[    1.713921] torture_init_begin: One torture test at a time!
[    1.716062] spin_lock-torture: lock_torture_stats task started
[    1.717067] Initialise system trusted keyrings
[    1.722025] workingset: timestamp_bits=30 max_order=17 bucket_order=0
[    1.722986] ntfs: driver 2.1.32 [Flags: R/W].
[    1.723445] fuse init (API version 7.26)
[    1.725172] JFS: nTxBlock = 2717, nTxLock = 21738
[    1.727377] NILFS version 2 loaded
[    1.727763] ocfs2: Registered cluster interface o2cb
[    1.728298] OCFS2 User DLM kernel interface loaded
[    1.754428] NET: Registered protocol family 38
[    1.754969] async_tx: api initialized (async)
[    1.755372] Key type asymmetric registered
[    1.755742] Asymmetric key parser 'x509' registered
[    1.756213] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.756926] io scheduler noop registered
[    1.757334] io scheduler deadline registered (default)
[    1.758327] io scheduler cfq registered
[    1.759193] crc32: CRC_LE_BITS = 64, CRC_BE BITS = 64
[    1.759744] crc32: self tests passed, processed 225944 bytes in 238188 nsec
[    1.760582] crc32c: CRC_LE_BITS = 64
[    1.760899] crc32c: self tests passed, processed 225944 bytes in 77513 nsec
[    1.786526] crc32_combine: 8373 self tests passed
[    1.812247] crc32c_combine: 8373 self tests passed
[    1.813003] xz_dec_test: module loaded
[    1.813372] xz_dec_test: Create a device node with 'mknod xz_dec_test c 249 0' and write .xz files to it.
[    1.814232] glob: 64 self-tests passed, 0 failed
[    1.821538] gpio_winbond: chip ID at 2e is ffff
[    1.821940] gpio_winbond: not an our chip
[    1.822313] gpio_winbond: chip ID at 4e is ffff
[    1.822705] gpio_winbond: not an our chip
[    1.826322] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    1.828034] usbcore: registered new interface driver udlfb
[    1.828549] usbcore: registered new interface driver smscufx
[    1.830534] uvesafb: failed to execute /sbin/v86d
[    1.830955] uvesafb: make sure that the v86d helper is installed and executable
[    1.831584] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    1.832155] uvesafb: vbe_init() failed with -22
[    1.832559] uvesafb: probe of uvesafb.0 failed with error -22
[    1.834168] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.834825] ACPI: Power Button [PWRF]
[    2.045376] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.069561] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    2.119104] 00:06: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[    2.126354] DoubleTalk PC - not found
[    2.126813] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    2.127444] ac.o: No PCI boards found.
[    2.127774] ac.o: For an ISA board you must supply memory and irq parameters.
[    2.128410] toshiba: not a supported Toshiba laptop
[    2.129469] ppdev: user-space parallel port driver
[    2.129894] scx200_gpio: no SCx200 gpio present
[    2.130344] nsc_gpio initializing
[    2.130811] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    2.131566] Linux agpgart interface v0.103
[    2.137697] [drm] Initialized vgem 1.0.0 20120112 for virtual device on minor 0
[    2.138430] usbcore: registered new interface driver udl
[    2.146366] Floppy drive(s): fd0 is 2.88M AMI BIOS
[    2.173697] FDC 0 is a S82078B
[    2.196852] loop: module loaded
[    2.198056] MM: desc_per_page = 128
[    2.262406] rbd: loaded (major 252)
[    2.262760] mtip32xx Version 1.3.1
[    2.267754] null: module loaded
[    2.268176] Phantom Linux Driver, version n0.9.8, init OK
[    2.270192] Guest personality initialized and is inactive
[    2.271074] VMCI host device registered (name=vmci, major=10, minor=60)
[    2.271664] Initialized host personality
[    2.275891] usbcore: registered new interface driver viperboard
[    2.277283] usbcore: registered new interface driver port100
[    2.277817] usbcore: registered new interface driver nfcmrvl
[    2.278946] Uniform Multi-Platform E-IDE driver
[    2.280958] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    2.282060] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[    2.283075]     ide0: BM-DMA at 0xc040-0xc047
[    2.283516]     ide1: BM-DMA at 0xc048-0xc04f
[    2.283921] Probing IDE interface ide0...
[    2.720094] tsc: Refined TSC clocksource calibration: 2925.999 MHz
[    2.720707] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2a2d33743a4, max_idle_ns: 440795298620 ns
[    2.956257] Probing IDE interface ide1...
[    3.723442] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    4.544316] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    4.545293] hdc: MWDMA2 mode selected
[    4.546009] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    4.553409] ide1 at 0x170-0x177,0x376 on irq 15
[    4.557602] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    4.558959] ide-gd driver 1.18
[    4.560634] Loading iSCSI transport class v2.0-870.
[    4.563520] fnic: Cisco FCoE HBA Driver, ver 1.6.0.34
[    4.564741] fnic: Successfully Initialized Trace Buffer
[    4.565857] fnic: Successfully Initialized FC_CTLR Trace Buffer
[    4.567120] snic:SNIC Driver is supported only for x86_64 platforms!
[    4.568017] snic:Cisco SCSI NIC Driver, ver 0.0.1.18
[    4.569868] bnx2fc: QLogic FCoE Driver bnx2fc v2.11.8 (October 15, 2015)
[    4.571287] iscsi: registered transport (tcp)
[    4.609753] Adaptec aacraid driver 1.2.1[50877]-custom
[    4.610684] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    4.618002] qlogicfas: no cards were found, please specify I/O address and IRQ using iobase= and irq= options
[    4.619033] iscsi: registered transport (qla4xxx)
[    4.621377] QLogic iSCSI HBA Driver
[    4.621862] csiostor: Chelsio FCoE driver 1.0.0-ko
[    4.622892] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[    4.624225] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[    4.625260] megasas: 07.704.04.00-rc1
[    4.625866] mpt3sas version 17.100.00.00 loaded
[    4.629391] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    4.631382] 3ware Storage Controller device driver for Linux v1.26.02.003.
[    4.632415] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[    4.636785] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[    4.637916] nsp32: loading...
[    4.639548] RocketRAID 3xxx/4xxx Controller driver v1.10.0
[    4.640442] stex: Promise SuperTrak EX Driver version: 6.02.0000.01
[    4.641411] libcxgbi:libcxgbi_init_module: Chelsio iSCSI driver library libcxgbi v0.9.1-ko (Apr. 2015)
[    4.642646] Chelsio T3 iSCSI Driver cxgb3i v2.0.1-ko (Apr. 2015)
[    4.644777] iscsi: registered transport (cxgb3i)
[    4.645483] Chelsio T4-T6 iSCSI Driver cxgb4i v0.9.5-ko (Apr. 2015)
[    4.646427] iscsi: registered transport (cxgb4i)
[    4.648979] VMware PVSCSI driver - version 1.0.7.0-k
[    4.649816] st: Version 20160209, fixed bufsize 32768, s/g segs 256
[    4.650820] SCSI Media Changer driver v0.25 
[    4.661432] scsi host0: scsi_debug: version 0188 [20180128]
[    4.661432]   dev_size_mb=8, opts=0x0, submit_queues=1, statistics=0
[    4.666203] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0188 PQ: 0 ANSI: 7
[    4.685265] Rounding down aligned max_sectors from 4294967295 to 4294967288
[    4.689770] slram: not enough parameters.
[    4.693779] eql: Equalizer2002: Simon Janes (simon at ncm.com) and David S. Miller (davem at redhat.com)
[    4.698304] MACsec IEEE 802.1AE
[    4.709929] mdio_bus fixed-0: GPIO lookup for consumer reset
[    4.710746] mdio_bus fixed-0: using lookup tables for GPIO lookup
[    4.711316] mdio_bus fixed-0: No GPIO consumer reset found
[    4.711952] libphy: Fixed MDIO Bus: probed
[    4.718275] tun: Universal TUN/TAP device driver, 1.6
[    4.719540] arcnet: arcnet loaded
[    4.719920] arcnet:rfc1051: RFC1051 "simple standard" (`s') encapsulation support loaded
[    4.720879] arcnet:arc_rawmode: raw mode (`r') encapsulation support loaded
[    4.721691] arcnet:arc_rimi: RIM I (entirely mem-mapped) support
[    4.722285] arcnet:arc_rimi: E-mail me if you actually test the RIM I driver, please!
[    4.722995] arcnet:arc_rimi: Given: node 00h, shmem 0h, irq 0
[    4.723615] arcnet:arc_rimi: No autoprobe for RIM I; you must specify the shmem and irq!
[    4.724569] arcnet:com20020_isa: COM20020 ISA support (by David Woodhouse et al.)
[    4.725283] (unnamed net_device) (uninitialized): No autoprobe (yet) for IO mapped cards; you must specify the base address!
[    4.726287] arcnet:com20020_pci: COM20020 PCI support
[    4.727564] vcan: Virtual CAN interface driver
[    4.729823] dsa-loop fixed-0:1f: DSA mockup driver: 0x1f
[    4.733785] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    4.734564] Copyright (c) 2007 Atheros Corporation.
[    4.740214] cnic: QLogic cnicDriver v2.5.22 (July 20, 2015)
[    4.741198] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.712.30-0 (2014/02/10)
[    4.745202] bna: QLogic BR-series 10G Ethernet driver - version: 3.2.25.1
[    4.749329] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    4.750365] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    5.254443] PCI Interrupt Link [LNKC] enabled at IRQ 11
[    5.607907] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[    5.609007] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[    5.609823] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[    5.610395] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    5.610980] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[    5.611624] igb: Copyright (c) 2007-2014 Intel Corporation.
[    5.612167] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 5.1.0-k
[    5.612926] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[    5.614444] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    5.615420] sky2: driver version 1.30
[    5.616895] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
[    5.618191] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.3.66
[    5.618882] QLogic/NetXen Network Driver v4.0.82
[    5.619856] Solarflare NET driver v4.1
[    5.620689] Solarflare Falcon driver v4.1
[    5.621838] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[    5.622381] tehuti: Options: hw_csum 
[    5.623869] AX.25: Z8530 SCC driver version 3.0.dl1bke
[    5.626103] YAM driver version 0.8 by F1OAT/F6FBB
[    5.635275] AX.25: bpqether driver version 004
[    5.635736] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    5.635736] baycom_par: version 0.9
[    5.644294] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    5.644870] hdlcdrv: version 0.8
[    5.645196] baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA
[    5.645196] baycom_epp: version 0.7
[    5.655461] PPP generic driver version 2.4.2
[    5.657294] PPP BSD Compression module registered
[    5.657864] PPP Deflate Compression module registered
[    5.658441] hdlc: HDLC support module revision 1.22
[    5.659096] DLCI driver v0.35, 4 Jan 1997, mike.mclagan at linux.org.
[    5.659820] SDLA driver v0.30, 12 Sep 1996, mike.mclagan at linux.org.
[    5.663801] Broadcom 43xx-legacy driver loaded [ Features: PLD ]
[    5.665461] usbcore: registered new interface driver p54usb
[    5.666161] Loaded prism54 driver, version 1.2
[    5.667880] usbcore: registered new interface driver rt2500usb
[    5.668597] usbcore: registered new interface driver rt2800usb
[    5.669403] usbcore: registered new interface driver zd1201
[    5.670095] qtnfmac_pearl_pcie: qtnf_pcie_register: register Quantenna QSR10g FullMAC PCIE driver
[    5.671935] usbcore: registered new interface driver rndis_wlan
[    5.673284] mac80211_hwsim: initializing netlink
[    5.676800] ieee80211 phy0: Selected rate control algorithm 'minstrel'
[    5.682707] ieee80211 phy1: Selected rate control algorithm 'minstrel'
[    5.688069] VMware vmxnet3 virtual NIC driver - version 1.4.13.0-k-NAPI
[    5.689477] usbcore: registered new interface driver catc
[    5.690133] usbcore: registered new interface driver kaweth
[    5.690775] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
[    5.691597] usbcore: registered new interface driver pegasus
[    5.692238] usbcore: registered new interface driver rtl8150
[    5.693568] usbcore: registered new interface driver lan78xx
[    5.694240] usbcore: registered new interface driver ax88179_178a
[    5.694923] usbcore: registered new interface driver cdc_ether
[    5.695582] usbcore: registered new interface driver dm9601
[    5.696226] usbcore: registered new interface driver sr9700
[    5.697580] usbcore: registered new interface driver CoreChips
[    5.698242] usbcore: registered new interface driver smsc95xx
[    5.698880] usbcore: registered new interface driver gl620a
[    5.699509] usbcore: registered new interface driver plusb
[    5.700201] usbcore: registered new interface driver rndis_host
[    5.701405] usbcore: registered new interface driver cdc_subset
[    5.701972] usbcore: registered new interface driver zaurus
[    5.702558] usbcore: registered new interface driver cdc_phonet
[    5.703152] usbcore: registered new interface driver kalmia
[    5.703721] usbcore: registered new interface driver cx82310_eth
[    5.705009] usbcore: registered new interface driver cdc_ncm
[    5.705615] usbcore: registered new interface driver huawei_cdc_ncm
[    5.706226] usbcore: registered new interface driver qmi_wwan
[    5.706805] usbcore: registered new interface driver cdc_mbim
[    5.710308] Intel ISA PCIC probe: 
[    5.710385] not found.
[    5.711520] Databook TCIC-2 PCMCIA probe: 
[    5.711553] not found.
[    5.751729] usbcore: registered new interface driver hwa-rc
[    5.753496] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    5.754104] ohci-pci: OHCI PCI platform driver
[    5.755352] ohci-platform: OHCI generic platform driver
[    5.756402] driver u132_hcd
[    5.756914] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    5.757459] Warning! fotg210_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[    5.759479] usbcore: registered new interface driver cdc_wdm
[    5.760222] usbcore: registered new interface driver usbtmc
[    5.761614] usbcore: registered new interface driver uas
[    5.762148] usbcore: registered new interface driver usb-storage
[    5.762960] usbcore: registered new interface driver ums-datafab
[    5.763736] usbcore: registered new interface driver ums_eneub6250
[    5.764440] usbcore: registered new interface driver ums-freecom
[    5.765052] usbcore: registered new interface driver ums-isd200
[    5.765682] usbcore: registered new interface driver ums-jumpshot
[    5.767041] usbcore: registered new interface driver ums-karma
[    5.767693] usbcore: registered new interface driver ums-sddr09
[    5.768352] usbcore: registered new interface driver ums-sddr55
[    5.768958] usbcore: registered new interface driver ums-usbat
[    5.769571] usbcore: registered new interface driver mdc800
[    5.770160] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[    5.771788] usbcore: registered new interface driver microtekX6
[    5.772387] usbcore: registered new interface driver adutux
[    5.772921] usbcore: registered new interface driver appledisplay
[    5.773541] usbcore: registered new interface driver emi26 - firmware loader
[    5.774247] usbcore: registered new interface driver emi62 - firmware loader
[    5.774877] ftdi_elan: driver ftdi-elan
[    5.775914] usbcore: registered new interface driver ftdi-elan
[    5.776504] usbcore: registered new interface driver isight_firmware
[    5.777305] usbcore: registered new interface driver usblcd
[    5.777833] usbcore: registered new interface driver legousbtower
[    5.778442] usbcore: registered new interface driver trancevibrator
[    5.779590] usbcore: registered new interface driver usbsevseg
[    5.780242] usbcore: registered new interface driver yurex
[    5.780832] usbcore: registered new interface driver chaoskey
[    5.781398] usbcore: registered new interface driver sisusb
[    5.782527] usbcore: registered new interface driver lvs
[    5.784639] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[    5.785326] dummy_hcd dummy_hcd.0: Dummy host controller
[    5.785812] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[    5.787059] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 4.17
[    5.787807] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.788492] usb usb1: Product: Dummy host controller
[    5.788930] usb usb1: Manufacturer: Linux 4.17.0-rc1 dummy_hcd
[    5.789463] usb usb1: SerialNumber: dummy_hcd.0
[    5.791986] hub 1-0:1.0: USB hub found
[    5.792406] hub 1-0:1.0: 1 port detected
[    5.798212] vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
[    5.798820] vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 2
[    5.799872] vhci_hcd: created sysfs vhci_hcd.0
[    5.800603] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 4.17
[    5.801432] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.802156] usb usb2: Product: USB/IP Virtual Host Controller
[    5.802736] usb usb2: Manufacturer: Linux 4.17.0-rc1 vhci_hcd
[    5.803332] usb usb2: SerialNumber: vhci_hcd.0
[    5.805035] hub 2-0:1.0: USB hub found
[    5.805493] hub 2-0:1.0: 8 ports detected
[    5.811417] vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
[    5.812031] vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 3
[    5.813089] usb usb3: We don't know the algorithms for LPM for this host, disabling LPM.
[    5.814076] usb usb3: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 4.17
[    5.814895] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.815625] usb usb3: Product: USB/IP Virtual Host Controller
[    5.816202] usb usb3: Manufacturer: Linux 4.17.0-rc1 vhci_hcd
[    5.816788] usb usb3: SerialNumber: vhci_hcd.0
[    5.819381] hub 3-0:1.0: USB hub found
[    5.820154] hub 3-0:1.0: 8 ports detected
[    5.827157] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    5.829721] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.830235] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.834523] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    5.837524] rtc_cmos 00:00: RTC can wake from S4
[    5.838445] rtc rtc0: alarm rollover: day
[    5.840477] rtc_cmos 00:00: char device (251:0)
[    5.840896] rtc_cmos 00:00: registered as rtc0
[    5.841288] rtc_cmos 00:00: nvmem registration failed
[    5.841736] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram, hpet irqs
[    5.848008] rtc rtc1: alarm rollover: day
[    5.848584] rtc rtc1: test: dev (251:1)
[    5.848945] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    5.850333] rtc rtc2: alarm rollover: day
[    5.853407] rtc rtc2: test: dev (251:2)
[    5.853893] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    5.856022] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[    5.899941] usbcore: registered new interface driver i2c-diolan-u2c
[    5.900897] i2c-parport: adapter type unspecified
[    5.903412] usbcore: registered new interface driver RobotFuzz Open Source InterFace, OSIF
[    5.904312] isa i2c-pca-isa.0: Please specify I/O base
[    5.907452] Driver for 1-wire Dallas network protocol.
[    5.908030] usbcore: registered new interface driver DS9490R
[    5.908552] w1_f0d_init()
[    6.455834] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
[    6.626738] pc87360: PC8736x not detected, module not inserted
[    6.822692] device-mapper: ioctl: 4.39.0-ioctl (2018-04-03) initialised: dm-devel at redhat.com
[    6.825515] device-mapper: multipath round-robin: version 1.2.0 loaded
[    6.826509] device-mapper: raid: Loading target version 1.13.2
[    6.831382] platform eisa.0: Probing EISA bus 0
[    6.832079] platform eisa.0: EISA: Cannot allocate resource for mainboard
[    6.832718] platform eisa.0: Cannot allocate resource for EISA slot 1
[    6.833290] platform eisa.0: Cannot allocate resource for EISA slot 2
[    6.833892] platform eisa.0: Cannot allocate resource for EISA slot 3
[    6.834458] platform eisa.0: Cannot allocate resource for EISA slot 4
[    6.835017] platform eisa.0: Cannot allocate resource for EISA slot 5
[    6.835581] platform eisa.0: Cannot allocate resource for EISA slot 6
[    6.836146] platform eisa.0: Cannot allocate resource for EISA slot 7
[    6.836726] platform eisa.0: Cannot allocate resource for EISA slot 8
[    6.837298] platform eisa.0: EISA: Detected 0 cards
[    6.837838] sdhci: Secure Digital Host Controller Interface driver
[    6.838381] sdhci: Copyright(c) Pierre Ossman
[    6.839894] usbcore: registered new interface driver ushc
[    6.843819] leds_ss4200: no LED devices found
[    6.858387] iscsi: registered transport (iser)
[    6.867173] Driver for HIFN 795x crypto accelerator chip has been successfully registered.
[    6.871532] usbcore: registered new interface driver usbhid
[    6.872036] usbhid: USB HID core driver
[    6.872383] NET: Registered protocol family 4
[    6.872889] no options.
[    6.874165] LNet: HW nodes: 1, HW CPU cores: 1, npartitions: 1
[    6.874688] LNetError: 1:0:(module.c:546:libcfs_init()) misc_register: error -16
[    7.893425] BUG: unable to handle kernel paging request at 08000664
[    7.893989] *pde = 00000000 
[    7.894251] Oops: 0000 [#1] SMP
[    7.894528] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G S                4.17.0-rc1 #198
[    7.895196] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[    7.895924] EIP: cfs_cpt_spread_node+0x5c/0x115
[    7.896320] EFLAGS: 00210202 CPU: 0
[    7.896625] EAX: d6c31320 EBX: 00000001 ECX: 00000001 EDX: 00000000
[    7.896678] ESI: 08000664 EDI: 00000000 EBP: c7ea3e88 ESP: c7ea3e78
[    7.896678]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    7.896678] CR0: 80050033 CR2: 08000664 CR3: 05380000 CR4: 00000690
[    7.896678] Call Trace:
[    7.896678]  lnet_res_container_setup+0x9a/0x210
[    7.896678]  LNetNIInit+0x701/0xdef
[    7.896678]  ? ktime_get_real_seconds+0xe3/0xf9
[    7.896678]  srpc_startup+0x8b/0x413
[    7.896678]  lnet_selftest_init+0x3de/0x78c
[    7.896678]  do_one_initcall+0x1a2/0x410
[    7.896678]  ? lnet_selftest_exit+0xa8/0xa8
[    7.896678]  ? parse_args+0x94/0x3b6
[    7.896678]  kernel_init_freeable+0x3b3/0x488
[    7.896678]  ? rest_init+0x11b/0x11b
[    7.896678]  kernel_init+0xd/0x15f
[    7.896678]  ret_from_fork+0x2e/0x40
[    7.896678] Code: c4 74 11 8b 50 04 8b 70 18 89 55 f0 8d 4a 01 89 48 04 eb 17 6b d2 0c 03 50 0c 89 d1 8b 42 08 8b 72 04 89 45 f0 8d 50 01 89 51 08 <8b> 06 6a 00 83 e0 01 e8 5c 82 d7 fe 89 c3 31 c0 85 db 0f 9e c0 
[    7.896678] EIP: cfs_cpt_spread_node+0x5c/0x115 SS:ESP: 0068:c7ea3e78
[    7.896678] CR2: 0000000008000664
[    7.896678] ---[ end trace 5246465f75f74727 ]---
[    7.896678] Kernel panic - not syncing: Fatal exception
[    7.896678] Kernel Offset: disabled

Elapsed time: 20

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
	qemu-system-x86_64
	-enable-kvm
	-kernel $kernel
	-initrd initrd.img
	-m 420
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
	ip=::::vm-lkp-nhm-dp2-yocto-ia32-6::dhcp
	root=/dev/ram0
	user=lkp
	job=/job-script
	ARCH=i386
	kconfig=i386-randconfig-c0-04180358
	branch=linus/master
	commit=60cc43fc888428bb2f18f08997432d426a243338
	BOOT_IMAGE=/pkg/linux/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
	max_uptime=600
	RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp2-yocto-ia32/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0
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
CONFIG_X86_32_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
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
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=y
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
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
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
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
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_SYSTEM_DATA_VERIFICATION=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
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
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
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
CONFIG_BLOCK=y
# CONFIG_LBDAF is not set
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_CMDLINE_PARSER=y
CONFIG_BLK_WBT=y
# CONFIG_BLK_WBT_SQ is not set
CONFIG_BLK_WBT_MQ=y
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
# CONFIG_ACORN_PARTITION_EESOX is not set
# CONFIG_ACORN_PARTITION_ICS is not set
# CONFIG_ACORN_PARTITION_ADFS is not set
CONFIG_ACORN_PARTITION_POWERTEC=y
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_AIX_PARTITION=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
CONFIG_LDM_PARTITION=y
CONFIG_LDM_DEBUG=y
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
# CONFIG_SUN_PARTITION is not set
CONFIG_KARMA_PARTITION=y
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
CONFIG_CMDLINE_PARTITION=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_MQ_RDMA=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
# CONFIG_MQ_IOSCHED_DEADLINE is not set
# CONFIG_MQ_IOSCHED_KYBER is not set
# CONFIG_IOSCHED_BFQ is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_MPPARSE=y
CONFIG_GOLDFISH=y
CONFIG_RETPOLINE=y
CONFIG_INTEL_RDT=y
# CONFIG_X86_BIGSMP is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
# CONFIG_X86_RDC321X is not set
CONFIG_X86_32_NON_STANDARD=y
# CONFIG_STA2X11 is not set
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
CONFIG_M586=y
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
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
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=5
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_X86_F00F_BUG=y
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS_RANGE_BEGIN=2
CONFIG_NR_CPUS_RANGE_END=8
CONFIG_NR_CPUS_DEFAULT=8
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
# CONFIG_PERF_EVENTS_INTEL_RAPL is not set
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_LEGACY_VM86=y
CONFIG_VM86=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=y
CONFIG_I8K=y
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
# CONFIG_X86_PAE is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
# CONFIG_CLEANCACHE is not set
CONFIG_FRONTSWAP=y
# CONFIG_CMA is not set
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
# CONFIG_Z3FOLD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
# CONFIG_PERCPU_STATS is not set
CONFIG_GUP_BENCHMARK=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_KEXEC=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
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
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_CPUFREQ_DT=y
CONFIG_CPUFREQ_DT_PLATDEV=y
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=y
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
CONFIG_X86_GX_SUSPMOD=y
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_SPEEDSTEP_ICH=y
CONFIG_X86_SPEEDSTEP_SMI=y
# CONFIG_X86_P4_CLOCKMOD is not set
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
CONFIG_PCI_GOMMCONFIG=y
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# Cadence PCIe controllers support
#
CONFIG_PCIE_CADENCE=y
CONFIG_PCIE_CADENCE_HOST=y
CONFIG_PCIE_CADENCE_EP=y

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
CONFIG_PCI_ENDPOINT_CONFIGFS=y
# CONFIG_PCI_EPF_TEST is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
CONFIG_EISA_VLB_PRIMING=y
# CONFIG_EISA_PCI_EISA is not set
CONFIG_EISA_VIRTUAL_ROOT=y
# CONFIG_EISA_NAMES is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_OLPC is not set
# CONFIG_ALIX is not set
CONFIG_NET5501=y
CONFIG_GEOS=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
CONFIG_I82092=y
CONFIG_I82365=y
CONFIG_TCIC=y
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_TLS=y
CONFIG_XFRM=y
CONFIG_XFRM_OFFLOAD=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_SMC=y
CONFIG_SMC_DIAG=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
# CONFIG_IP_ROUTE_MULTIPATH is not set
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE_COMMON=y
# CONFIG_SYN_COOKIES is not set
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
# CONFIG_NET_FOU_IP_TUNNELS is not set
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
# CONFIG_TCP_CONG_HTCP is not set
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_NV is not set
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_TCP_CONG_DCTCP is not set
CONFIG_TCP_CONG_CDG=y
CONFIG_TCP_CONG_BBR=y
# CONFIG_DEFAULT_BIC is not set
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_CDG is not set
CONFIG_DEFAULT_BBR=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bbr"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_ESP_OFFLOAD=y
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_FOU=y
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
# CONFIG_IPV6_PIMSM_V2 is not set
CONFIG_IPV6_SEG6_LWTUNNEL=y
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
# CONFIG_NETFILTER is not set
CONFIG_IP_DCCP=y

#
# DCCP CCIDs Configuration
#
CONFIG_IP_DCCP_CCID2_DEBUG=y
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
CONFIG_TIPC=y
CONFIG_TIPC_MEDIA_IB=y
# CONFIG_TIPC_MEDIA_UDP is not set
CONFIG_TIPC_DIAG=y
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_MRP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_LEGACY=y
CONFIG_NET_DSA_TAG_BRCM=y
CONFIG_NET_DSA_TAG_BRCM_PREPEND=y
CONFIG_NET_DSA_TAG_LAN9303=y
CONFIG_NET_DSA_TAG_MTK=y
CONFIG_NET_DSA_TAG_TRAILER=y
CONFIG_NET_DSA_TAG_QCA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_ATALK is not set
CONFIG_X25=y
# CONFIG_LAPB is not set
CONFIG_PHONET=y
CONFIG_6LOWPAN=y
CONFIG_6LOWPAN_DEBUGFS=y
CONFIG_6LOWPAN_NHC=y
# CONFIG_6LOWPAN_NHC_DEST is not set
# CONFIG_6LOWPAN_NHC_FRAGMENT is not set
CONFIG_6LOWPAN_NHC_HOP=y
CONFIG_6LOWPAN_NHC_IPV6=y
CONFIG_6LOWPAN_NHC_MOBILITY=y
CONFIG_6LOWPAN_NHC_ROUTING=y
CONFIG_6LOWPAN_NHC_UDP=y
CONFIG_6LOWPAN_GHC_EXT_HDR_HOP=y
# CONFIG_6LOWPAN_GHC_UDP is not set
CONFIG_6LOWPAN_GHC_ICMPV6=y
# CONFIG_6LOWPAN_GHC_EXT_HDR_DEST is not set
CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG=y
CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=y
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
# CONFIG_NET_SCH_RED is not set
CONFIG_NET_SCH_SFB=y
# CONFIG_NET_SCH_SFQ is not set
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
# CONFIG_NET_SCH_CBS is not set
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_HHF is not set
CONFIG_NET_SCH_PIE=y
# CONFIG_NET_SCH_INGRESS is not set
# CONFIG_NET_SCH_PLUG is not set
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
# CONFIG_NET_CLS_FW is not set
# CONFIG_NET_CLS_U32 is not set
# CONFIG_NET_CLS_RSVP is not set
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
# CONFIG_NET_CLS_CGROUP is not set
CONFIG_NET_CLS_BPF=y
# CONFIG_NET_CLS_FLOWER is not set
CONFIG_NET_CLS_MATCHALL=y
# CONFIG_NET_EMATCH is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
# CONFIG_GACT_PROB is not set
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_SAMPLE=y
CONFIG_NET_ACT_NAT=y
# CONFIG_NET_ACT_PEDIT is not set
# CONFIG_NET_ACT_SIMP is not set
# CONFIG_NET_ACT_SKBEDIT is not set
CONFIG_NET_ACT_CSUM=y
CONFIG_NET_ACT_VLAN=y
CONFIG_NET_ACT_BPF=y
CONFIG_NET_ACT_SKBMOD=y
CONFIG_NET_ACT_IFE=y
CONFIG_NET_ACT_TUNNEL_KEY=y
# CONFIG_NET_IFE_SKBMARK is not set
CONFIG_NET_IFE_SKBPRIO=y
CONFIG_NET_IFE_SKBTCINDEX=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BATMAN_V=y
# CONFIG_BATMAN_ADV_BLA is not set
# CONFIG_BATMAN_ADV_DAT is not set
# CONFIG_BATMAN_ADV_NC is not set
CONFIG_BATMAN_ADV_MCAST=y
# CONFIG_BATMAN_ADV_DEBUGFS is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=y
# CONFIG_VSOCKETS_DIAG is not set
# CONFIG_VMWARE_VMCI_VSOCKETS is not set
# CONFIG_VIRTIO_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=y
CONFIG_MPLS_IPTUNNEL=y
# CONFIG_NET_NSH is not set
CONFIG_HSR=y
CONFIG_NET_SWITCHDEV=y
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_STREAM_PARSER is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NET_DROP_MONITOR=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
# CONFIG_NETROM is not set
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
# CONFIG_MKISS is not set
# CONFIG_6PACK is not set
CONFIG_BPQETHER=y
CONFIG_SCC=y
# CONFIG_SCC_DELAY is not set
CONFIG_SCC_TRXECHO=y
# CONFIG_BAYCOM_SER_FDX is not set
# CONFIG_BAYCOM_SER_HDX is not set
CONFIG_BAYCOM_PAR=y
CONFIG_BAYCOM_EPP=y
CONFIG_YAM=y
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_VXCAN is not set
# CONFIG_CAN_SLCAN is not set
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_IPV6=y
CONFIG_AF_RXRPC_INJECT_LOSS=y
CONFIG_AF_RXRPC_DEBUG=y
# CONFIG_RXKAD is not set
CONFIG_AF_KCM=y
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_CRDA_SUPPORT is not set
CONFIG_CFG80211_WEXT=y
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
# CONFIG_MAC80211_RC_MINSTREL_HT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
CONFIG_RFKILL_GPIO=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_RDMA=y
CONFIG_NET_9P_DEBUG=y
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_NCI_UART is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_SIM is not set
CONFIG_NFC_PORT100=y
# CONFIG_NFC_FDP is not set
CONFIG_NFC_PN533=y
# CONFIG_NFC_PN533_USB is not set
CONFIG_NFC_PN533_I2C=y
CONFIG_NFC_MRVL=y
CONFIG_NFC_MRVL_USB=y
CONFIG_NFC_MRVL_I2C=y
# CONFIG_NFC_ST_NCI_I2C is not set
CONFIG_NFC_NXP_NCI=y
CONFIG_NFC_NXP_NCI_I2C=y
CONFIG_NFC_S3FWRN5=y
CONFIG_NFC_S3FWRN5_I2C=y
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=y
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_DEVLINK=y
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
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set

#
# Bus devices
#
# CONFIG_SIMPLE_PM_BUS is not set
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_OF_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=y
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_SWAP=y
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
# CONFIG_MTD_PHYSMAP_OF is not set
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_ONENAND is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
# CONFIG_MTD_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_MT81xx_NOR=y
# CONFIG_MTD_SPI_NOR_USE_4K_SECTORS is not set
CONFIG_SPI_INTEL_SPI=y
CONFIG_SPI_INTEL_SPI_PCI=y
# CONFIG_SPI_INTEL_SPI_PLATFORM is not set
# CONFIG_MTD_UBI is not set
CONFIG_DTC=y
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_FLATTREE=y
CONFIG_OF_KOBJ=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=y
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=y
CONFIG_BLK_DEV_SX8=y
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
CONFIG_BLK_DEV_RBD=y
CONFIG_BLK_DEV_RSXX=y

#
# NVME Support
#
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
# CONFIG_NVME_MULTIPATH is not set
CONFIG_NVME_FABRICS=y
CONFIG_NVME_RDMA=y
CONFIG_NVME_FC=y
CONFIG_NVME_TARGET=y
# CONFIG_NVME_TARGET_LOOP is not set
CONFIG_NVME_TARGET_RDMA=y
# CONFIG_NVME_TARGET_FC is not set

#
# Misc devices
#
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_PCH_PHUB=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_SRAM=y
CONFIG_PCI_ENDPOINT_TEST=y
CONFIG_MISC_RTSX=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_IDT_89HPESX=y
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=y

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
CONFIG_MISC_RTSX_PCI=y
# CONFIG_MISC_RTSX_USB is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_IDE_LEGACY=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_IDECS=y
# CONFIG_BLK_DEV_IDECD is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
# CONFIG_BLK_DEV_ALI15X3 is not set
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
CONFIG_BLK_DEV_CS5530=y
CONFIG_BLK_DEV_CS5535=y
CONFIG_BLK_DEV_CS5536=y
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
CONFIG_BLK_DEV_SLC90E66=y
CONFIG_BLK_DEV_TRM290=y
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
# CONFIG_BLK_DEV_4DRIVES is not set
CONFIG_BLK_DEV_ALI14XX=y
CONFIG_BLK_DEV_DTC2278=y
CONFIG_BLK_DEV_HT6560B=y
CONFIG_BLK_DEV_QD65XX=y
CONFIG_BLK_DEV_UMC8672=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_CXGB3_ISCSI=y
CONFIG_SCSI_CXGB4_ISCSI=y
# CONFIG_SCSI_BNX2_ISCSI is not set
CONFIG_SCSI_BNX2X_FCOE=y
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AHA152X=y
CONFIG_SCSI_AHA1542=y
CONFIG_SCSI_AHA1740=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC79XX is not set
CONFIG_SCSI_AIC94XX=y
CONFIG_AIC94XX_DEBUG=y
# CONFIG_SCSI_MVSAS is not set
CONFIG_SCSI_MVUMI=y
# CONFIG_SCSI_DPT_I2O is not set
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=y
# CONFIG_SCSI_SMARTPQI is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=y
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_SNIC=y
# CONFIG_SCSI_SNIC_DEBUG_FS is not set
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_GDTH=y
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_GENERIC_NCR5380=y
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_QLOGIC_FAS=y
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_SIM710 is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
CONFIG_SCSI_NSP32=y
CONFIG_SCSI_WD719X=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
CONFIG_SCSI_CHELSIO_FCOE=y
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_MQ_DEFAULT is not set
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=y
CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING=y
CONFIG_DM_DEBUG_BLOCK_STACK_TRACING=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_UNSTRIPED=y
# CONFIG_DM_CRYPT is not set
# CONFIG_DM_SNAPSHOT is not set
CONFIG_DM_THIN_PROVISIONING=y
CONFIG_DM_CACHE=y
CONFIG_DM_CACHE_SMQ=y
CONFIG_DM_ERA=y
# CONFIG_DM_MIRROR is not set
CONFIG_DM_RAID=y
# CONFIG_DM_ZERO is not set
CONFIG_DM_MULTIPATH=y
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
CONFIG_DM_FLAKEY=y
CONFIG_DM_VERITY=y
# CONFIG_DM_VERITY_FEC is not set
# CONFIG_DM_SWITCH is not set
CONFIG_DM_LOG_WRITES=y
CONFIG_DM_INTEGRITY=y
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
# CONFIG_TCM_USER2 is not set
# CONFIG_LOOPBACK_TARGET is not set
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
CONFIG_ISCSI_TARGET_CXGB4=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
CONFIG_NET_FC=y
# CONFIG_IFB is not set
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
# CONFIG_NET_TEAM_MODE_ROUNDROBIN is not set
CONFIG_NET_TEAM_MODE_RANDOM=y
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=y
# CONFIG_NET_TEAM_MODE_LOADBALANCE is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
CONFIG_GENEVE=y
CONFIG_GTP=y
CONFIG_MACSEC=y
# CONFIG_NETCONSOLE is not set
CONFIG_TUN=y
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=y
CONFIG_ARCNET=y
# CONFIG_ARCNET_1201 is not set
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
# CONFIG_ARCNET_CAP is not set
# CONFIG_ARCNET_COM90xx is not set
# CONFIG_ARCNET_COM90xxIO is not set
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_ISA=y
CONFIG_ARCNET_COM20020_PCI=y
CONFIG_ARCNET_COM20020_CS=y

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_B53=y
CONFIG_B53_MDIO_DRIVER=y
CONFIG_B53_MMAP_DRIVER=y
CONFIG_B53_SRAB_DRIVER=y
CONFIG_NET_DSA_BCM_SF2=y
CONFIG_NET_DSA_LOOP=y
CONFIG_NET_DSA_MT7530=y
CONFIG_NET_DSA_MV88E6060=y
# CONFIG_MICROCHIP_KSZ is not set
# CONFIG_NET_DSA_MV88E6XXX is not set
CONFIG_NET_DSA_QCA8K=y
CONFIG_NET_DSA_SMSC_LAN9303=y
# CONFIG_NET_DSA_SMSC_LAN9303_I2C is not set
CONFIG_NET_DSA_SMSC_LAN9303_MDIO=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_EL3 is not set
CONFIG_3C515=y
CONFIG_PCMCIA_3C574=y
CONFIG_PCMCIA_3C589=y
CONFIG_VORTEX=y
# CONFIG_TYPHOON is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_AGERE=y
CONFIG_ET131X=y
CONFIG_NET_VENDOR_ALACRITECH=y
CONFIG_SLICOSS=y
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
CONFIG_ACENIC_OMIT_TIGON_I=y
CONFIG_ALTERA_TSE=y
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
# CONFIG_LANCE is not set
# CONFIG_PCNET32 is not set
CONFIG_PCMCIA_NMCLAN=y
CONFIG_NI65=y
CONFIG_AMD_XGBE=y
CONFIG_AMD_XGBE_HAVE_ECC=y
CONFIG_NET_VENDOR_AQUANTIA=y
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_ALX=y
CONFIG_NET_VENDOR_AURORA=y
CONFIG_AURORA_NB8800=y
# CONFIG_NET_CADENCE is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BCMGENET=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_TIGON3_HWMON=y
CONFIG_BNX2X=y
# CONFIG_BNX2X_SRIOV is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
CONFIG_NET_VENDOR_CAVIUM=y
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
CONFIG_CHELSIO_T4VF=y
CONFIG_CHELSIO_LIB=y
# CONFIG_NET_VENDOR_CIRRUS is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_NET_VENDOR_CORTINA is not set
CONFIG_CX_ECAT=y
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_BE2NET_HWMON=y
# CONFIG_NET_VENDOR_EZCHIP is not set
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
# CONFIG_NET_VENDOR_HUAWEI is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_MLX4_CORE_GEN2=y
# CONFIG_MLX5_CORE is not set
CONFIG_MLXSW_CORE=y
CONFIG_MLXSW_CORE_HWMON=y
CONFIG_MLXSW_CORE_THERMAL=y
# CONFIG_MLXSW_PCI is not set
# CONFIG_MLXSW_I2C is not set
CONFIG_MLXFW=y
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
CONFIG_FEALNX=y
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
# CONFIG_QLCNIC_SRIOV is not set
# CONFIG_QLCNIC_HWMON is not set
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
# CONFIG_QED is not set
# CONFIG_NET_VENDOR_QUALCOMM is not set
# CONFIG_NET_VENDOR_REALTEK is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
# CONFIG_NET_VENDOR_ROCKER is not set
# CONFIG_NET_VENDOR_SAMSUNG is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_NET_VENDOR_SILAN is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
# CONFIG_SFC_MCDI_MON is not set
CONFIG_SFC_SRIOV=y
# CONFIG_SFC_MCDI_LOGGING is not set
CONFIG_SFC_FALCON=y
# CONFIG_SFC_FALCON_MTD is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_SMC9194 is not set
CONFIG_PCMCIA_SMC91C92=y
# CONFIG_EPIC100 is not set
CONFIG_SMSC911X=y
CONFIG_SMSC9420=y
CONFIG_NET_VENDOR_SOCIONEXT=y
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
# CONFIG_NET_VENDOR_TI is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
CONFIG_WIZNET_W5100=y
CONFIG_WIZNET_W5300=y
# CONFIG_WIZNET_BUS_DIRECT is not set
# CONFIG_WIZNET_BUS_INDIRECT is not set
CONFIG_WIZNET_BUS_ANY=y
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=y
CONFIG_NET_VENDOR_SYNOPSYS=y
CONFIG_DWC_XLGMAC=y
CONFIG_DWC_XLGMAC_PCI=y
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
CONFIG_HIPPI=y
CONFIG_ROADRUNNER=y
CONFIG_ROADRUNNER_LARGE_RINGS=y
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BCM_UNIMAC=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_BUS_MUX=y
CONFIG_MDIO_BUS_MUX_GPIO=y
# CONFIG_MDIO_BUS_MUX_MMIOREG is not set
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_HISI_FEMAC=y
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
CONFIG_BCM87XX_PHY=y
CONFIG_BCM_NET_PHYLIB=y
CONFIG_BROADCOM_PHY=y
CONFIG_CICADA_PHY=y
# CONFIG_CORTINA_PHY is not set
CONFIG_DAVICOM_PHY=y
CONFIG_DP83822_PHY=y
CONFIG_DP83848_PHY=y
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_INTEL_XWAY_PHY=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_LXT_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_MARVELL_10G_PHY=y
# CONFIG_MICREL_PHY is not set
CONFIG_MICROCHIP_PHY=y
CONFIG_MICROSEMI_PHY=y
CONFIG_NATIONAL_PHY=y
# CONFIG_QSEMI_PHY is not set
CONFIG_REALTEK_PHY=y
CONFIG_RENESAS_PHY=y
# CONFIG_ROCKCHIP_PHY is not set
CONFIG_SMSC_PHY=y
CONFIG_STE10XP=y
# CONFIG_TERANETICS_PHY is not set
# CONFIG_VITESSE_PHY is not set
CONFIG_XILINX_GMII2RGMII=y
# CONFIG_PLIP is not set
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
# CONFIG_PPP_MPPE is not set
CONFIG_PPP_MULTILINK=y
# CONFIG_PPPOE is not set
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=y
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_LAN78XX=y
CONFIG_USB_USBNET=y
# CONFIG_USB_NET_AX8817X is not set
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
# CONFIG_USB_NET_CDC_EEM is not set
CONFIG_USB_NET_CDC_NCM=y
CONFIG_USB_NET_HUAWEI_CDC_NCM=y
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SR9700=y
CONFIG_USB_NET_SR9800=y
# CONFIG_USB_NET_SMSC75XX is not set
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
# CONFIG_USB_NET_NET1080 is not set
CONFIG_USB_NET_PLUSB=y
# CONFIG_USB_NET_MCS7830 is not set
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET_ENABLE=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
# CONFIG_USB_AN2720 is not set
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
# CONFIG_USB_EPSON2888 is not set
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=y
CONFIG_USB_NET_KALMIA=y
CONFIG_USB_NET_QMI_WWAN=y
# CONFIG_USB_HSO is not set
# CONFIG_USB_NET_INT51X1 is not set
CONFIG_USB_CDC_PHONET=y
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
# CONFIG_USB_NET_CH9200 is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
# CONFIG_WLAN_VENDOR_ADMTEK is not set
# CONFIG_WLAN_VENDOR_ATH is not set
# CONFIG_WLAN_VENDOR_ATMEL is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
# CONFIG_B43LEGACY_DMA_AND_PIO_MODE is not set
CONFIG_B43LEGACY_DMA_MODE=y
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_BRCMUTIL=y
# CONFIG_BRCMSMAC is not set
CONFIG_BRCMFMAC=y
# CONFIG_BRCMFMAC_SDIO is not set
# CONFIG_BRCMFMAC_USB is not set
# CONFIG_BRCMFMAC_PCIE is not set
# CONFIG_BRCM_TRACING is not set
CONFIG_BRCMDBG=y
# CONFIG_WLAN_VENDOR_CISCO is not set
# CONFIG_WLAN_VENDOR_INTEL is not set
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_HERMES is not set
CONFIG_P54_COMMON=y
CONFIG_P54_USB=y
CONFIG_P54_PCI=y
CONFIG_P54_LEDS=y
CONFIG_PRISM54=y
# CONFIG_WLAN_VENDOR_MARVELL is not set
# CONFIG_WLAN_VENDOR_MEDIATEK is not set
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_RT2X00=y
# CONFIG_RT2400PCI is not set
CONFIG_RT2500PCI=y
CONFIG_RT61PCI=y
CONFIG_RT2800PCI=y
# CONFIG_RT2800PCI_RT33XX is not set
# CONFIG_RT2800PCI_RT35XX is not set
CONFIG_RT2800PCI_RT53XX=y
# CONFIG_RT2800PCI_RT3290 is not set
CONFIG_RT2500USB=y
# CONFIG_RT73USB is not set
CONFIG_RT2800USB=y
CONFIG_RT2800USB_RT33XX=y
CONFIG_RT2800USB_RT35XX=y
CONFIG_RT2800USB_RT3573=y
CONFIG_RT2800USB_RT53XX=y
# CONFIG_RT2800USB_RT55XX is not set
# CONFIG_RT2800USB_UNKNOWN is not set
CONFIG_RT2800_LIB=y
CONFIG_RT2800_LIB_MMIO=y
CONFIG_RT2X00_LIB_MMIO=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB_USB=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
CONFIG_RT2X00_DEBUG=y
# CONFIG_WLAN_VENDOR_REALTEK is not set
# CONFIG_WLAN_VENDOR_RSI is not set
CONFIG_WLAN_VENDOR_ST=y
CONFIG_CW1200=y
CONFIG_CW1200_WLAN_SDIO=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WL1251=y
CONFIG_WL1251_SDIO=y
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
CONFIG_WLCORE=y
# CONFIG_WLCORE_SDIO is not set
# CONFIG_WILINK_PLATFORM_DATA is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_USB_ZD1201=y
# CONFIG_ZD1211RW is not set
CONFIG_WLAN_VENDOR_QUANTENNA=y
CONFIG_QTNFMAC=y
CONFIG_QTNFMAC_PEARL_PCIE=y
CONFIG_PCMCIA_RAYCS=y
CONFIG_PCMCIA_WL3501=y
CONFIG_MAC80211_HWSIM=y
CONFIG_USB_NET_RNDIS_WLAN=y

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
# CONFIG_HDLC_PPP is not set

#
# X.25/LAPB support is disabled
#
CONFIG_PCI200SYN=y
# CONFIG_WANXL is not set
CONFIG_PC300TOO=y
CONFIG_N2=y
# CONFIG_C101 is not set
# CONFIG_FARSYNC is not set
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_SDLA=y
# CONFIG_SBNI is not set
CONFIG_VMXNET3=y
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
CONFIG_NETDEVSIM=y
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

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
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
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
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=y
CONFIG_SERIO_GPIO_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

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
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

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
# CONFIG_SERIAL_8250_CS is not set
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_ASPEED_VUART is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
# CONFIG_SERIAL_OF_PLATFORM is not set

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
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=y
CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_HW_RANDOM_GEODE=y
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_HW_RANDOM_VIRTIO is not set
# CONFIG_NVRAM is not set
CONFIG_DTLK=y
# CONFIG_R3964 is not set
CONFIG_APPLICOM=y
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_SCR24X is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_GPMUX is not set
CONFIG_I2C_MUX_LTC4306=y
CONFIG_I2C_MUX_PCA9541=y
# CONFIG_I2C_MUX_PCA954x is not set
CONFIG_I2C_MUX_PINCTRL=y
CONFIG_I2C_MUX_REG=y
# CONFIG_I2C_DEMUX_PINCTRL is not set
CONFIG_I2C_MUX_MLXCPLD=y
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
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

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
CONFIG_I2C_DESIGNWARE_SLAVE=y
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
CONFIG_I2C_EG20T=y
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_KEMPLD is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_PXA=y
CONFIG_I2C_PXA_PCI=y
# CONFIG_I2C_RK3X is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_PCA_ISA=y
CONFIG_I2C_CROS_EC_TUNNEL=y
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set
# CONFIG_PPS is not set

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_PINCTRL=y
CONFIG_GENERIC_PINCTRL_GROUPS=y
CONFIG_PINMUX=y
CONFIG_GENERIC_PINMUX_FUNCTIONS=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08=y
CONFIG_PINCTRL_SINGLE=y
CONFIG_PINCTRL_SX150X=y
CONFIG_PINCTRL_PALMAS=y
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
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=y
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_FTGPIO010 is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_GRGPIO=y
CONFIG_GPIO_HLWD=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=y
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
CONFIG_GPIO_SYSCON=y
CONFIG_GPIO_VX855=y
CONFIG_GPIO_XILINX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_IT87 is not set
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_WINBOND=y
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_ADNP is not set
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_JANZ_TTL is not set
CONFIG_GPIO_KEMPLD=y
# CONFIG_GPIO_LP3943 is not set
# CONFIG_GPIO_LP87565 is not set
CONFIG_GPIO_PALMAS=y
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_TC3589X is not set
CONFIG_GPIO_TIMBERDALE=y
CONFIG_GPIO_TPS65086=y
CONFIG_GPIO_TPS65218=y
CONFIG_GPIO_TPS6586X=y
# CONFIG_GPIO_TPS65910 is not set
# CONFIG_GPIO_TWL4030 is not set
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCH=y
CONFIG_GPIO_PCI_IDIO_16=y
CONFIG_GPIO_PCIE_IDIO_24=y
CONFIG_GPIO_RDC321X=y
# CONFIG_GPIO_SODAVILLE is not set

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
# CONFIG_W1_MASTER_DS2482 is not set
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2405 is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2805=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_DS28E17=y
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_GPIO is not set
CONFIG_POWER_RESET_GPIO_RESTART=y
CONFIG_POWER_RESET_LTC2952=y
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_RESET_SYSCON=y
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
CONFIG_REBOOT_MODE=y
CONFIG_SYSCON_REBOOT_MODE=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_MAX8925_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
CONFIG_BATTERY_ACT8945A=y
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_CHARGER_SBS=y
CONFIG_MANAGER_SBS=y
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
CONFIG_BATTERY_BQ27XXX_HDQ=y
# CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_LTC3651=y
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_DETECTOR_MAX14656 is not set
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65217 is not set
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
CONFIG_BATTERY_RT5033=y
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ASPEED=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_DA9052_ADC is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4222 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6621=y
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_TC654 is not set
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
# CONFIG_SENSORS_ADM1275 is not set
# CONFIG_SENSORS_IBM_CFFPS is not set
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=y
# CONFIG_SENSORS_MAX20751 is not set
CONFIG_SENSORS_MAX31785=y
CONFIG_SENSORS_MAX34440=y
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_TPS53679=y
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_PWM_FAN is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_STTS751=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83773G=y
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_QORIQ_THERMAL is not set
# CONFIG_DA9062_THERMAL is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_ACT8945A=y
CONFIG_MFD_AS3711=y
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_ATMEL_FLEXCOM is not set
CONFIG_MFD_ATMEL_HLCDC=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_BD9571MWV is not set
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_MFD_CROS_EC_CHARDEV is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_UCB1400_CORE is not set
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_RK808 is not set
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_TI_LMU=y
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS68470 is not set
# CONFIG_MFD_TI_LP873X is not set
CONFIG_MFD_TI_LP87565=y
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
CONFIG_MFD_TC3589X=y
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8998 is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_RAVE_SP_CORE=y
# CONFIG_REGULATOR is not set
# CONFIG_RC_CORE is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_ALI=y
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_AMD64 is not set
CONFIG_AGP_INTEL=y
# CONFIG_AGP_NVIDIA is not set
CONFIG_AGP_SIS=y
CONFIG_AGP_SWORKS=y
CONFIG_AGP_VIA=y
CONFIG_AGP_EFFICEON=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_DP_AUX_CHARDEV=y
# CONFIG_DRM_DEBUG_MM is not set
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_NOUVEAU_DEBUG_MMU=y
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
# CONFIG_DRM_I915 is not set
CONFIG_DRM_VGEM=y
CONFIG_DRM_VMWGFX=y
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=y
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
# CONFIG_DRM_RCAR_DW_HDMI is not set
CONFIG_DRM_RCAR_LVDS=y
CONFIG_DRM_QXL=y
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_ARM_VERSATILE=y
# CONFIG_DRM_PANEL_LVDS is not set
# CONFIG_DRM_PANEL_SIMPLE is not set
# CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0 is not set
CONFIG_DRM_PANEL_SEIKO_43WVF1G=y
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=y
CONFIG_DRM_DUMB_VGA_DAC=y
CONFIG_DRM_LVDS_ENCODER=y
CONFIG_DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW=y
CONFIG_DRM_NXP_PTN3460=y
CONFIG_DRM_PARADE_PS8622=y
CONFIG_DRM_SII902X=y
CONFIG_DRM_SII9234=y
CONFIG_DRM_TOSHIBA_TC358767=y
# CONFIG_DRM_TI_TFP410 is not set
# CONFIG_DRM_I2C_ADV7511 is not set
CONFIG_DRM_ARCPGU=y
CONFIG_DRM_HISI_HIBMC=y
CONFIG_DRM_MXS=y
CONFIG_DRM_MXSFB=y
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
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
CONFIG_FB_SVGALIB=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=y
CONFIG_FB_I810=y
# CONFIG_FB_I810_GTF is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
# CONFIG_FB_GEODE is not set
CONFIG_FB_SM501=y
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SSD1307=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_LM3533 is not set
# CONFIG_BACKLIGHT_PWM is not set
# CONFIG_BACKLIGHT_DA9052 is not set
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_PM8941_WLED is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_SKY81452=y
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
CONFIG_BACKLIGHT_ARCXCNN=y
CONFIG_VGASTATE=y
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_PCM_ELD=y
CONFIG_SND_PCM_IEC958=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_SEQ_DEVICE=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_PCM_TIMER is not set
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=y
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_SEQ_MIDI_EVENT=y
CONFIG_SND_SEQ_MIDI=y
CONFIG_SND_SEQ_VIRMIDI=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
# CONFIG_SND_DUMMY is not set
CONFIG_SND_ALOOP=y
CONFIG_SND_VIRMIDI=y
# CONFIG_SND_MTPAV is not set
CONFIG_SND_MTS64=y
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=y
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
# CONFIG_SND_ISA is not set
# CONFIG_SND_PCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=y
CONFIG_SND_USB_UA101=y
# CONFIG_SND_USB_USX2Y is not set
CONFIG_SND_USB_CAIAQ=y
# CONFIG_SND_USB_CAIAQ_INPUT is not set
# CONFIG_SND_USB_US122L is not set
CONFIG_SND_USB_6FIRE=y
CONFIG_SND_USB_HIFACE=y
CONFIG_SND_BCD2000=y
CONFIG_SND_USB_LINE6=y
# CONFIG_SND_USB_POD is not set
CONFIG_SND_USB_PODHD=y
CONFIG_SND_USB_TONEPORT=y
# CONFIG_SND_USB_VARIAX is not set
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=y
CONFIG_SND_PDAUDIOCF=y
CONFIG_SND_SOC=y
CONFIG_SND_SOC_AC97_BUS=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=y
CONFIG_SND_SOC_AMD_CZ_DA7219MX98357_MACH=y
# CONFIG_SND_SOC_AMD_CZ_RT5645_MACH is not set
CONFIG_SND_ATMEL_SOC=y
# CONFIG_SND_DESIGNWARE_I2S is not set

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
# CONFIG_SND_SOC_FSL_SAI is not set
CONFIG_SND_SOC_FSL_SSI=y
# CONFIG_SND_SOC_FSL_SPDIF is not set
CONFIG_SND_SOC_FSL_ESAI=y
# CONFIG_SND_SOC_IMX_AUDMUX is not set
# CONFIG_SND_I2S_HI6210_I2S is not set
# CONFIG_SND_SOC_IMG is not set
CONFIG_SND_SOC_INTEL_SST_TOPLEVEL=y
# CONFIG_SND_SOC_INTEL_HASWELL is not set
# CONFIG_SND_SOC_INTEL_BAYTRAIL is not set
# CONFIG_SND_SST_ATOM_HIFI2_PLATFORM_PCI is not set
# CONFIG_SND_SST_ATOM_HIFI2_PLATFORM is not set
# CONFIG_SND_SOC_INTEL_SKYLAKE is not set
CONFIG_SND_SOC_INTEL_MACH=y

#
# STMicroelectronics STM32 SOC audio support
#
# CONFIG_SND_SOC_XTFPGA_I2S is not set
CONFIG_ZX_TDM=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=y
CONFIG_SND_SOC_ADAU_UTILS=y
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_ADAU17X1=y
CONFIG_SND_SOC_ADAU1761=y
CONFIG_SND_SOC_ADAU1761_I2C=y
CONFIG_SND_SOC_ADAU7002=y
CONFIG_SND_SOC_AK4458=y
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4613=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_AK5558=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_BD28623=y
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_CS35L32=y
CONFIG_SND_SOC_CS35L33=y
CONFIG_SND_SOC_CS35L34=y
CONFIG_SND_SOC_CS35L35=y
CONFIG_SND_SOC_CS42L42=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L51_I2C=y
# CONFIG_SND_SOC_CS42L52 is not set
# CONFIG_SND_SOC_CS42L56 is not set
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4265=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS4271_I2C=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
CONFIG_SND_SOC_CS43130=y
CONFIG_SND_SOC_CS4349=y
CONFIG_SND_SOC_CS53L30=y
CONFIG_SND_SOC_DA7219=y
CONFIG_SND_SOC_DIO2125=y
CONFIG_SND_SOC_HDMI_CODEC=y
CONFIG_SND_SOC_ES7134=y
CONFIG_SND_SOC_ES8316=y
CONFIG_SND_SOC_ES8328=y
CONFIG_SND_SOC_ES8328_I2C=y
CONFIG_SND_SOC_GTM601=y
CONFIG_SND_SOC_INNO_RK3036=y
CONFIG_SND_SOC_MAX98357A=y
CONFIG_SND_SOC_MAX98504=y
CONFIG_SND_SOC_MAX9867=y
CONFIG_SND_SOC_MAX98927=y
CONFIG_SND_SOC_MAX98373=y
CONFIG_SND_SOC_MAX9860=y
CONFIG_SND_SOC_MSM8916_WCD_DIGITAL=y
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM1789=y
CONFIG_SND_SOC_PCM1789_I2C=y
CONFIG_SND_SOC_PCM179X=y
CONFIG_SND_SOC_PCM179X_I2C=y
CONFIG_SND_SOC_PCM186X=y
CONFIG_SND_SOC_PCM186X_I2C=y
CONFIG_SND_SOC_PCM3168A=y
CONFIG_SND_SOC_PCM3168A_I2C=y
CONFIG_SND_SOC_PCM512x=y
CONFIG_SND_SOC_PCM512x_I2C=y
CONFIG_SND_SOC_RL6231=y
CONFIG_SND_SOC_RT5616=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_I2C=y
CONFIG_SND_SOC_SIGMADSP_REGMAP=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_SSM2602_I2C=y
CONFIG_SND_SOC_SSM4567=y
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA350=y
CONFIG_SND_SOC_STI_SAS=y
CONFIG_SND_SOC_TAS2552=y
CONFIG_SND_SOC_TAS5086=y
CONFIG_SND_SOC_TAS571X=y
CONFIG_SND_SOC_TAS5720=y
CONFIG_SND_SOC_TAS6424=y
CONFIG_SND_SOC_TDA7419=y
CONFIG_SND_SOC_TFA9879=y
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC23_I2C=y
CONFIG_SND_SOC_TLV320AIC31XX=y
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC32X4_I2C=y
CONFIG_SND_SOC_TLV320AIC3X=y
CONFIG_SND_SOC_TS3A227E=y
CONFIG_SND_SOC_TSCS42XX=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8524=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8804_I2C=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8960=y
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8974=y
CONFIG_SND_SOC_WM8978=y
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_ZX_AUD96P22=y
CONFIG_SND_SOC_MAX9759=y
CONFIG_SND_SOC_NAU8540=y
CONFIG_SND_SOC_NAU8810=y
CONFIG_SND_SOC_NAU8824=y
CONFIG_SND_SOC_TPA6130A2=y
CONFIG_SND_SIMPLE_CARD_UTILS=y
# CONFIG_SND_SIMPLE_CARD is not set
CONFIG_SND_SIMPLE_SCU_CARD=y
# CONFIG_SND_AUDIO_GRAPH_CARD is not set
# CONFIG_SND_AUDIO_GRAPH_SCU_CARD is not set
# CONFIG_SND_X86 is not set
CONFIG_AC97_BUS=y

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
# CONFIG_HID_ACCUTOUCH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_ASUS is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_BETOP_FF is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CORSAIR is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELAN is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_GOOGLE_HAMMER is not set
# CONFIG_HID_GT683R is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
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
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PENMOUNT is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_RETRODE is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
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
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=y
CONFIG_USB_LEDS_TRIGGER_USBPORT=y
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
# CONFIG_USB_XHCI_HCD is not set
# CONFIG_USB_EHCI_HCD is not set
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
CONFIG_USB_STORAGE_KARMA=y
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
CONFIG_USB_STORAGE_ENE_UB6250=y
CONFIG_USB_UAS=y

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
CONFIG_USBIP_VHCI_HC_PORTS=8
CONFIG_USBIP_VHCI_NR_HCS=1
# CONFIG_USBIP_HOST is not set
CONFIG_USBIP_VUDC=y
# CONFIG_USBIP_DEBUG is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
# CONFIG_USB_MUSB_GADGET is not set
CONFIG_USB_MUSB_DUAL_ROLE=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_ULPI is not set
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_OF_SIMPLE=y
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PERIPHERAL=y
# CONFIG_USB_DWC2_DUAL_ROLE is not set
CONFIG_USB_DWC2_PCI=y
CONFIG_USB_DWC2_DEBUG=y
# CONFIG_USB_DWC2_VERBOSE is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_OF=y
CONFIG_USB_CHIPIDEA_PCI=y
CONFIG_USB_CHIPIDEA_UDC=y
CONFIG_USB_CHIPIDEA_ULPI=y
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1761_UDC=y
# CONFIG_USB_ISP1760_HOST_ROLE is not set
CONFIG_USB_ISP1760_GADGET_ROLE=y
# CONFIG_USB_ISP1760_DUAL_ROLE is not set

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HUB_USB251XB=y
# CONFIG_USB_HSIC_USB3503 is not set
# CONFIG_USB_HSIC_USB4604 is not set
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FUSB300 is not set
CONFIG_USB_FOTG210_UDC=y
# CONFIG_USB_GR_UDC is not set
CONFIG_USB_R8A66597=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
# CONFIG_USB_SNP_UDC_PLAT is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
CONFIG_USB_NET2280=y
CONFIG_USB_GOKU=y
# CONFIG_USB_EG20T is not set
CONFIG_USB_GADGET_XILINX=y
CONFIG_USB_DUMMY_HCD=y
# CONFIG_USB_CONFIGFS is not set
CONFIG_TYPEC=y
CONFIG_TYPEC_TCPM=y
CONFIG_TYPEC_FUSB302=y
CONFIG_TYPEC_UCSI=y
# CONFIG_UCSI_ACPI is not set
CONFIG_TYPEC_TPS6598X=y

#
# USB Type-C Multiplexer/DeMultiplexer Switch support
#
CONFIG_TYPEC_MUX_PI3USB30532=y
# CONFIG_USB_ROLES_INTEL_XHCI is not set
# CONFIG_USB_LED_TRIG is not set
CONFIG_USB_ULPI_BUS=y
CONFIG_USB_ROLE_SWITCH=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
# CONFIG_UWB_I1480U is not set
CONFIG_MMC=y
# CONFIG_PWRSEQ_EMMC is not set
# CONFIG_PWRSEQ_SIMPLE is not set
# CONFIG_MMC_BLOCK is not set
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
# CONFIG_MMC_RICOH_MMC is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=y
# CONFIG_MMC_GOLDFISH is not set
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_VUB300 is not set
CONFIG_MMC_USHC=y
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_REALTEK_PCI=y
CONFIG_MMC_CQHCI=y
CONFIG_MMC_TOSHIBA_PCI=y
# CONFIG_MMC_MTK is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=y
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_BCM6328=y
# CONFIG_LEDS_BCM6358 is not set
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_LM3692X=y
CONFIG_LEDS_MT6323=y
CONFIG_LEDS_NET48XX=y
CONFIG_LEDS_WRAP=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8860 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA9052=y
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_MENF21BMC=y
CONFIG_LEDS_IS31FL319X=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_SYSCON is not set
CONFIG_LEDS_MLXCPLD=y
# CONFIG_LEDS_MLXREG is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_ACTIVITY=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
# CONFIG_INFINIBAND_USER_ACCESS is not set
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_ADDR_TRANS_CONFIGFS=y
CONFIG_INFINIBAND_MTHCA=y
# CONFIG_INFINIBAND_MTHCA_DEBUG is not set
CONFIG_INFINIBAND_CXGB3=y
CONFIG_INFINIBAND_CXGB4=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_INFINIBAND_NES=y
CONFIG_INFINIBAND_NES_DEBUG=y
CONFIG_INFINIBAND_OCRDMA=y
CONFIG_INFINIBAND_VMWARE_PVRDMA=y
CONFIG_INFINIBAND_IPOIB=y
# CONFIG_INFINIBAND_IPOIB_CM is not set
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
# CONFIG_INFINIBAND_SRP is not set
CONFIG_INFINIBAND_SRPT=y
CONFIG_INFINIBAND_ISER=y
CONFIG_INFINIBAND_ISERT=y
CONFIG_RDMA_RXE=y
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
# CONFIG_EDAC_AMD76X is not set
CONFIG_EDAC_E7XXX=y
CONFIG_EDAC_E752X=y
# CONFIG_EDAC_I82875P is not set
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
# CONFIG_EDAC_I3200 is not set
CONFIG_EDAC_IE31200=y
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
# CONFIG_EDAC_I82860 is not set
CONFIG_EDAC_R82600=y
# CONFIG_EDAC_I5000 is not set
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y
# CONFIG_RTC_NVMEM is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_ABB5ZES3=y
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1307_HWMON is not set
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8925=y
# CONFIG_RTC_DRV_MAX77686 is not set
CONFIG_RTC_DRV_RS5C372=y
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12026=y
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF85063=y
# CONFIG_RTC_DRV_PCF85363 is not set
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TWL4030=y
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_TPS6586X=y
CONFIG_RTC_DRV_TPS65910=y
CONFIG_RTC_DRV_RC5T583=y
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_RV3029C2=y
# CONFIG_RTC_DRV_RV3029_HWMON is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
# CONFIG_RTC_DRV_DS1689 is not set
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
CONFIG_RTC_DRV_DS17885=y
# CONFIG_RTC_DS1685_PROC_REGS is not set
# CONFIG_RTC_DS1685_SYSFS_REGS is not set
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9063=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_PCF50633=y
CONFIG_RTC_DRV_AB3100=y
# CONFIG_RTC_DRV_ZYNQMP is not set
CONFIG_RTC_DRV_CROS_EC=y

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set
CONFIG_RTC_DRV_SNVS=y
# CONFIG_RTC_DRV_MT6397 is not set
CONFIG_RTC_DRV_R7301=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
# CONFIG_DMADEVICES_VDEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_ALTERA_MSGDMA=y
CONFIG_DW_AXI_DMAC=y
CONFIG_FSL_EDMA=y
CONFIG_INTEL_IDMA64=y
CONFIG_PCH_DMA=y
# CONFIG_TIMB_DMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_AUXDISPLAY=y
CONFIG_CHARLCD=y
CONFIG_HD44780=y
# CONFIG_IMG_ASCII_LCD is not set
# CONFIG_HT16K33 is not set
# CONFIG_PANEL is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_UIO_PRUSS is not set
CONFIG_UIO_MF624=y
CONFIG_VIRT_DRIVERS=y
# CONFIG_VBOXGUEST is not set
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_NCP_FS is not set
# CONFIG_PRISM2_USB is not set
# CONFIG_COMEDI is not set
# CONFIG_R8712U is not set
CONFIG_RTS5208=y
CONFIG_FB_SM750=y
CONFIG_FB_XGI=y

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y

#
# Android
#
# CONFIG_STAGING_BOARD is not set
CONFIG_GOLDFISH_AUDIO=y
# CONFIG_MTD_GOLDFISH_NAND is not set
CONFIG_LNET=y
CONFIG_LNET_MAX_PAYLOAD=1048576
CONFIG_LNET_SELFTEST=y
# CONFIG_LNET_XPRT_IB is not set
CONFIG_LUSTRE_FS=y
# CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_UNISYSSPAR=y
CONFIG_COMMON_CLK_XLNX_CLKWZRD=y
# CONFIG_WILC1000_SDIO is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
CONFIG_GREYBUS=y
CONFIG_GREYBUS_ES2=y
# CONFIG_GREYBUS_AUDIO is not set
CONFIG_GREYBUS_BOOTROM=y
# CONFIG_GREYBUS_HID is not set
# CONFIG_GREYBUS_LIGHT is not set
CONFIG_GREYBUS_LOG=y
CONFIG_GREYBUS_LOOPBACK=y
CONFIG_GREYBUS_POWER=y
# CONFIG_GREYBUS_RAW is not set
# CONFIG_GREYBUS_VIBRATOR is not set
CONFIG_GREYBUS_BRIDGED_PHY=y
CONFIG_GREYBUS_GPIO=y
CONFIG_GREYBUS_I2C=y
CONFIG_GREYBUS_PWM=y
CONFIG_GREYBUS_SDIO=y
# CONFIG_GREYBUS_UART is not set
CONFIG_GREYBUS_USB=y

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_TYPEC_TCPCI is not set
# CONFIG_DRM_VBOXVIDEO is not set
# CONFIG_MTK_MMC is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACER_WIRELESS is not set
# CONFIG_ACERHDF is not set
# CONFIG_ALIENWARE_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_SMBIOS is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_DELL_WMI_LED is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_GPD_POCKET_FAN is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_HP_WMI is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=y
CONFIG_WMI_BMOF=y
# CONFIG_INTEL_WMI_THUNDERBOLT is not set
# CONFIG_MSI_WMI is not set
# CONFIG_PEAQ_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
# CONFIG_MLX_PLATFORM is not set
CONFIG_PMC_ATOM=y
# CONFIG_GOLDFISH_BUS is not set
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
# CONFIG_CHROMEOS_PSTORE is not set
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_MELLANOX_PLATFORM=y
# CONFIG_MLXREG_HOTPLUG is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_CLK_HSDK=y
CONFIG_COMMON_CLK_MAX77686=y
# CONFIG_COMMON_CLK_SI5351 is not set
CONFIG_COMMON_CLK_SI514=y
CONFIG_COMMON_CLK_SI544=y
# CONFIG_COMMON_CLK_SI570 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CDCE925 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
CONFIG_COMMON_CLK_PALMAS=y
CONFIG_COMMON_CLK_PWM=y
# CONFIG_COMMON_CLK_VC5 is not set
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
# CONFIG_PLATFORM_MHU is not set
# CONFIG_PCC is not set
# CONFIG_ALTERA_MBOX is not set
CONFIG_MAILBOX_TEST=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
# CONFIG_RPMSG_CHAR is not set
CONFIG_RPMSG_QCOM_GLINK_NATIVE=y
CONFIG_RPMSG_QCOM_GLINK_RPM=y
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
# CONFIG_SOC_TI is not set

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
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
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
# CONFIG_EXTCON_ARIZONA is not set
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=y
# CONFIG_EXTCON_MAX77693 is not set
CONFIG_EXTCON_MAX77843=y
# CONFIG_EXTCON_PALMAS is not set
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
CONFIG_EXTCON_USBC_CROS_EC=y
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_ATMEL_HLCDC_PWM=y
CONFIG_PWM_CROS_EC=y
CONFIG_PWM_FSL_FTM=y
CONFIG_PWM_LP3943=y
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
CONFIG_PWM_TWL=y
# CONFIG_PWM_TWL_LED is not set

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_RESET_TI_SYSCON=y
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=y
# CONFIG_FMC_WRITE_EEPROM is not set
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_MAPPHONE_MDM6600 is not set
# CONFIG_PHY_QCOM_USB_HS is not set
CONFIG_PHY_QCOM_USB_HSIC=y
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_TUSB1210 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_THUNDERBOLT=y

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
CONFIG_STM=y
# CONFIG_STM_DUMMY is not set
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_STM_SOURCE_FTRACE=y
CONFIG_INTEL_TH=y
CONFIG_INTEL_TH_PCI=y
# CONFIG_INTEL_TH_ACPI is not set
CONFIG_INTEL_TH_GTH=y
# CONFIG_INTEL_TH_STH is not set
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
CONFIG_INTEL_TH_DEBUG=y
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
CONFIG_ALTERA_PR_IP_CORE_PLAT=y
CONFIG_FPGA_MGR_ALTERA_CVP=y
# CONFIG_FPGA_BRIDGE is not set
# CONFIG_FSI is not set
CONFIG_PM_OPP=y
# CONFIG_SIOX is not set
CONFIG_SLIMBUS=y
CONFIG_SLIM_QCOM_CTRL=y

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y
CONFIG_GOOGLE_COREBOOT_TABLE=y
# CONFIG_GOOGLE_COREBOOT_TABLE_ACPI is not set
CONFIG_GOOGLE_COREBOOT_TABLE_OF=y
CONFIG_GOOGLE_MEMCONSOLE=y
# CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY is not set
CONFIG_GOOGLE_MEMCONSOLE_COREBOOT=y
CONFIG_GOOGLE_VPD=y

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
# CONFIG_EXT4_FS_SECURITY is not set
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
CONFIG_JFS_DEBUG=y
CONFIG_JFS_STATISTICS=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_STATS=y
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_BTRFS_FS_REF_VERIFY=y
CONFIG_NILFS2_FS=y
# CONFIG_F2FS_FS is not set
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
CONFIG_OVERLAY_FS_INDEX=y
CONFIG_OVERLAY_FS_NFS_EXPORT=y
# CONFIG_OVERLAY_FS_XINO_AUTO is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set
# CONFIG_DLM is not set

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
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

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
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
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
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
# CONFIG_DEBUG_PAGE_REF is not set
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_RWSEMS is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
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
# CONFIG_SCHED_TRACER is not set
CONFIG_HWLAT_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_PROFILE_ALL_BRANCHES=y
# CONFIG_BRANCH_TRACER is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_UPROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
CONFIG_TRACEPOINT_BENCHMARK=y
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
# CONFIG_TRACING_EVENTS_GPIO is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
CONFIG_MEMTEST=y
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
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_WX=y
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_FPU is not set
CONFIG_PUNIT_ATOM_DEBUG=y
CONFIG_UNWINDER_FRAME_POINTER=y
# CONFIG_UNWINDER_GUESS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
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
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y
CONFIG_CRYPTO_ENGINE=y

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
CONFIG_CRYPTO_CFB=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
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
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
# CONFIG_CRYPTO_SM4 is not set
CONFIG_CRYPTO_SPECK=y
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
# CONFIG_CRYPTO_DEV_PADLOCK_SHA is not set
# CONFIG_CRYPTO_DEV_GEODE is not set
CONFIG_CRYPTO_DEV_HIFN_795X=y
# CONFIG_CRYPTO_DEV_HIFN_795X_RNG is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_CRYPTO_DEV_QAT=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
CONFIG_CRYPTO_DEV_QAT_C62X=y
CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=y
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=y
CONFIG_CRYPTO_DEV_QAT_C62XVF=y
CONFIG_CRYPTO_DEV_CHELSIO=y
# CONFIG_CHELSIO_IPSEC_INLINE is not set
CONFIG_CRYPTO_DEV_CHELSIO_TLS=y
CONFIG_CRYPTO_DEV_VIRTIO=y
CONFIG_CRYPTO_DEV_CCREE=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
# CONFIG_SIGNED_PE_FILE_VERIFICATION is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
CONFIG_SECONDARY_TRUSTED_KEYRING=y
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
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
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
CONFIG_AUDIT_GENERIC=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_DMA_VIRT_OPS=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
CONFIG_OID_REGISTRY=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_SBITMAP=y
# CONFIG_STRING_SELFTEST is not set
-------------- next part --------------
#!/bin/sh

export_top_env()
{
	export suite='boot'
	export testcase='boot'
	export timeout='10m'
	export job_origin='/lkp/lkp/src/jobs/boot.yaml'
	export queue='rand'
	export testbox='vm-lkp-nhm-dp2-yocto-ia32-6'
	export tbox_group='vm-lkp-nhm-dp2-yocto-ia32'
	export branch='linus/master'
	export commit='60cc43fc888428bb2f18f08997432d426a243338'
	export kconfig='i386-randconfig-c0-04180358'
	export submit_id='5ad661be0b9a9328f2480bc2'
	export job_file='/lkp/scheduled/vm-lkp-nhm-dp2-yocto-ia32-6/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180418-10482-1lry5np-0.yaml'
	export id='f8181b9d3b946852892eaaa1bb6f3d40bb1a0d64'
	export model='qemu-system-x86_64 -enable-kvm'
	export nr_vm=16
	export nr_cpu=1
	export memory='420M'
	export rootfs='yocto-tiny-i386-2016-04-22.cgz'
	export need_kconfig='CONFIG_KVM_GUEST=y'
	export compiler='gcc-7'
	export enqueue_time='2018-04-18 05:06:06 +0800'
	export _id='5ad661be0b9a9328f2480bc2'
	export _rt='/result/boot/1/vm-lkp-nhm-dp2-yocto-ia32/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338'
	export user='lkp'
	export tbox_host_file='/lkp/lkp/.src-20180417-175914/hosts/vm-lkp-nhm-dp2-yocto-ia32-6'
	export verify_tbox_config='true'
	export kernel='/pkg/linux/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1'
	export result_root='/result/boot/1/vm-lkp-nhm-dp2-yocto-ia32/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0'
	export dequeue_time='2018-04-18 05:06:13 +0800'
	export LKP_SERVER='inn'
	export max_uptime=600
	export initrd='/osimage/yocto/yocto-tiny-i386-2016-04-22.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/scheduled/vm-lkp-nhm-dp2-yocto-ia32-6/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180418-10482-1lry5np-0.yaml
ARCH=i386
kconfig=i386-randconfig-c0-04180358
branch=linus/master
commit=60cc43fc888428bb2f18f08997432d426a243338
BOOT_IMAGE=/pkg/linux/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
max_uptime=600
RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp2-yocto-ia32/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0
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
	export job_initrd='/lkp/scheduled/vm-lkp-nhm-dp2-yocto-ia32-6/boot-1-yocto-tiny-i386-2016-04-22.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180418-10482-1lry5np-0.cgz'

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
	qemu-system-x86_64
	-enable-kvm
	-kernel $kernel
	-initrd initrd.img
	-m 420
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
	ip=::::vm-lkp-nhm-dp2-yocto-ia32-6::dhcp
	root=/dev/ram0
	user=lkp
	job=/job-script
	ARCH=i386
	kconfig=i386-randconfig-c0-04180358
	branch=linus/master
	commit=60cc43fc888428bb2f18f08997432d426a243338
	BOOT_IMAGE=/pkg/linux/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
	max_uptime=600
	RESULT_ROOT=/result/boot/1/vm-lkp-nhm-dp2-yocto-ia32/yocto-tiny-i386-2016-04-22.cgz/i386-randconfig-c0-04180358/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0
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
