From: James Simmons <jsimmons@infradead.org>
Date: Wed, 2 May 2018 19:10:15 +0100 (BST)
Subject: [lustre-devel] [lustre_init] BUG: unable to handle kernel NULL
 pointer dereference at 0000000000000004
In-Reply-To: <20180502122749.vwak4yuerrzzbme6@wfg-t540p.sh.intel.com>
References: <20180502122749.vwak4yuerrzzbme6@wfg-t540p.sh.intel.com>
Message-ID: <alpine.LFD.2.21.1805021907400.24633@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: lustre-devel@lists.lustre.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lkp@01.org


> Hello,
> 
> FYI this happens in mainline kernel 4.17.0-rc3.
> It looks like a new regression since v4.17-rc1.
> 
> It occurs in 2 out of 2 boots.
> 
> [   54.222599]   Magic number: 14:276:994
> [   54.223261] tty ttyd7: hash matches
> [   54.223841] tty ttyaa: hash matches
> [   54.227288] Lustre: Lustre: Build Version: 2.6.99
> [   54.232977] LustreError: 1:0:(class_obd.c:465:obdclass_init()) cannot register 241 err -16

This looks like the misc register bug that is now fixed in the 
staging-test branch. Can you try 

git commit ba833f145745c5ca4d1d45b1de2541fe34b8f100 (staging: lustre: 
libcfs: use  dynamic minors for /dev/{lnet, obd})

from the staging-test branch to see if it resolves your problems?

> [   54.236561] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
> [   54.237836] PGD 0 P4D 0
> [   54.238266] Oops: 0000 [#1] SMP
> [   54.238780] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.17.0-rc3 #1
> [   54.239775] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   54.241214] RIP: 0010:kmem_cache_alloc+0x27/0x2ce:
> 						slob_alloc_node at mm/slob.c:546
> 						 (inlined by) kmem_cache_alloc at mm/slob.c:567
> [   54.241956] RSP: 0000:ffff88001d21bde8 EFLAGS: 00010246
> [   54.242791] RAX: 0000000000000000 RBX: 0000000001408040 RCX: 0000000000000000
> [   54.243933] RDX: ffff88001d216000 RSI: 0000000000000000 RDI: ffffffff83752918
> [   54.245072] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> [   54.246213] R10: 0000000000000000 R11: 0000000000000020 R12: 00000000a0000000
> [   54.247337] R13: 0000000000000000 R14: 00000000a0000000 R15: ffffffff8407cb7e
> [   54.248613] FS:  0000000000000000(0000) GS:ffff88001e400000(0000) knlGS:0000000000000000
> [   54.249887] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   54.250803] CR2: 0000000000000004 CR3: 0000000003269000 CR4: 00000000000006a0
> [   54.251939] Call Trace:
> [   54.252358]  ? native_patch+0x195/0x195:
> 						__raw_callee_save___native_queued_spin_unlock at ??:?
> [   54.252976]  ? lustre_init+0x189/0x247:
> 						IS_ERR at include/linux/err.h:36
> 						 (inlined by) lustre_init at drivers/staging/lustre/lustre/llite/super25.c:133
> [   54.253590]  cl_env_new+0x2b/0xb9:
> 						cl_env_new at drivers/staging/lustre/lustre/obdclass/cl_object.c:597
> [   54.254126]  cl_env_alloc+0x11/0xae:
> 						IS_ERR at include/linux/err.h:36
> 						 (inlined by) cl_env_alloc at drivers/staging/lustre/lustre/obdclass/cl_object.c:718
> [   54.254713]  ? lmv_init+0x2d/0x2d:
> 						cfs_cdebug_show at drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:111
> 						 (inlined by) lustre_init at drivers/staging/lustre/lustre/llite/super25.c:97
> [   54.255259]  lustre_init+0x189/0x247:
> 						IS_ERR at include/linux/err.h:36
> 						 (inlined by) lustre_init at drivers/staging/lustre/lustre/llite/super25.c:133
> [   54.255839]  do_one_initcall+0x13d/0x36c:
> 						__read_once_size at include/linux/compiler.h:188
> 						 (inlined by) arch_atomic_read at arch/x86/include/asm/atomic.h:31
> 						 (inlined by) atomic_read at include/asm-generic/atomic-instrumented.h:22
> 						 (inlined by) static_key_count at include/linux/jump_label.h:194
> 						 (inlined by) static_key_false at include/linux/jump_label.h:206
> 						 (inlined by) trace_initcall_finish at include/trace/events/initcall.h:44
> 						 (inlined by) do_one_initcall at init/main.c:884
> [   54.256597]  ? parse_args+0x81/0x273:
> 						arch_local_save_flags at arch/x86/include/asm/paravirt.h:778
> 						 (inlined by) parse_args at kernel/params.c:190
> [   54.257177]  ? do_early_param+0x88/0x88:
> 						repair_env_string at init/main.c:251
> [   54.257791]  kernel_init_freeable+0x338/0x3d3:
> 						do_initcall_level at init/main.c:950
> 						 (inlined by) do_initcalls at init/main.c:959
> 						 (inlined by) do_basic_setup at init/main.c:977
> 						 (inlined by) kernel_init_freeable at init/main.c:1127
> [   54.258492]  ? rest_init+0x13c/0x13c:
> 						kernel_init at init/main.c:1053
> [   54.259068]  kernel_init+0x5/0xe6:
> 						kernel_init at init/main.c:1055
> [   54.259609]  ret_from_fork+0x1f/0x30:
> 						ret_from_fork at arch/x86/entry/entry_64.S:418
> [   54.260189] Code: 0c 31 c0 c3 41 57 41 56 41 55 41 54 55 53 48 89 fd 48 83 ec 18 8b 1d 52 2e 6b 02 21 f3 89 df e8 90 0c fb ff 89 df e8 b9 0c fb ff <8b> 7d 04 81 ff ff 0f 00 00 0f 87 f3 00 00 00 8b 55 08 89 de e8
> [   54.263237] RIP: kmem_cache_alloc+0x27/0x2ce:
> 						slob_alloc_node at mm/slob.c:546
> 						 (inlined by) kmem_cache_alloc at mm/slob.c:567 RSP: ffff88001d21bde8
> [   54.264322] CR2: 0000000000000004
> [   54.264865] ---[ end trace 612192cbc2d7395d ]---
> [   54.265604] Kernel panic - not syncing: Fatal exception
> 
> Attached the full dmesg, kconfig and reproduce scripts.
> 
> Thanks,
> Fengguang
> 
