From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 18 Apr 2018 21:40:58 +0800
Subject: [lustre-devel] [cfs_trace_lock_tcd] BUG: KASAN: null-ptr-deref in
 cfs_trace_lock_tcd+0x25/0xeb
In-Reply-To: <20180418133831.uef7d77ejdyjtxgh@wfg-t540p.sh.intel.com>
Message-ID: <20180418134058.l3orjjxcpv7cxjfw@wfg-t540p.sh.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, lkp@01.org, Denis Petrovic <denis.petrovic@edu.ece.fr>, Linus Torvalds <torvalds@linux-foundation.org>, lustre-devel@lists.lustre.org

FYI, it's the same regression, however reported by KASAN.

[   19.940511] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.940884] vhci_hcd: dump_port_status_diff:150:
[   19.941126] vhci_hcd: vhci_hub_control:604:  bye
[   19.941703] usb usb2: vhci_bus_suspend
[   20.967090] ==================================================================
[   20.968082] BUG: KASAN: null-ptr-deref in cfs_trace_lock_tcd+0x25/0xeb:
						cfs_trace_lock_tcd at drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c:149
[   20.968856] Read of size 2 at addr 00000000000000a4 by task swapper/1
[   20.969604]
[   20.969817] CPU: 0 PID: 1 Comm: swapper Tainted: G                T 4.17.0-rc1 #1
[   20.970046] Call Trace:
[   20.970046]  dump_stack+0x2e/0x3e:
						__dump_stack at lib/dump_stack.c:77
						 (inlined by) dump_stack at lib/dump_stack.c:123
[   20.970046]  kasan_report+0x2f3/0x360:
						kasan_report_error at mm/kasan/report.c:352
						 (inlined by) kasan_report at mm/kasan/report.c:412
[   20.970046]  __asan_load2+0x31/0xe4
[   20.970046]  cfs_trace_lock_tcd+0x25/0xeb:
						cfs_trace_lock_tcd at drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c:149
[   20.970046]  libcfs_debug_vmsg2+0x18d/0xd26:
						libcfs_debug_vmsg2 at drivers/staging/lustre/lnet/libcfs/tracefile.c:317
[   20.970046]  ? cfs_trace_get_tage+0x957/0x957:
						libcfs_debug_vmsg2 at drivers/staging/lustre/lnet/libcfs/tracefile.c:293
[   20.970046]  ? mark_lock+0xe9/0xa16:
						mark_lock at kernel/locking/lockdep.c:3121
[   20.970046]  ? fput+0x111/0x11f:
						queue_delayed_work at include/linux/workqueue.h:526
						 (inlined by) schedule_delayed_work at include/linux/workqueue.h:627
						 (inlined by) fput at fs/file_table.c:280
[   20.970046]  ? lnet_ipif_enumerate+0x541/0x588:
						lnet_ipif_enumerate at drivers/staging/lustre/lnet/lnet/lib-socket.c:238
[   20.970046]  ? kasan_slab_free+0x15/0x1e:
						kasan_slab_free at mm/kasan/kasan.c:528
[   20.970046]  ? kfree+0x215/0x2cb:
						slab_free_hook at mm/slub.c:1388
						 (inlined by) slab_free_freelist_hook at mm/slub.c:1415
						 (inlined by) slab_free at mm/slub.c:2988
						 (inlined by) kfree at mm/slub.c:3944
[   20.970046]  libcfs_debug_msg+0x9b/0xc5:
						libcfs_debug_msg at drivers/staging/lustre/lnet/libcfs/tracefile.c:278
[   20.970046]  ? libcfs_debug_vmsg2+0xd26/0xd26:
						libcfs_debug_msg at drivers/staging/lustre/lnet/libcfs/tracefile.c:278
[   20.970046]  ksocknal_startup+0x341/0x1228:
						ksocknal_enumerate_interfaces at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2634
						 (inlined by) ksocknal_startup at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2822
[   20.970046]  ? __asan_loadN+0x1d/0x26
[   20.970046]  ? pvclock_clocksource_read+0x162/0x296:
						pvclock_clocksource_read at arch/x86/kernel/pvclock.c:89
[   20.970046]  ? ksocknal_base_startup+0xbae/0xbae:
						ksocknal_startup at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2796
[   20.970046]  ? pvclock_read_flags+0x5d/0x5d:
						pvclock_clocksource_read at arch/x86/kernel/pvclock.c:79
[   20.970046]  ? kasan_check_read+0x1f/0x28:
						kasan_check_read at mm/kasan/kasan.c:272
[   20.970046]  ? kvm_clock_read+0x24/0x3a:
						kvm_clock_read at arch/x86/kernel/kvmclock.c:89
[   20.970046]  ? kasan_check_write+0x22/0x2b:
						kasan_check_write at mm/kasan/kasan.c:278
[   20.970046]  ? sched_clock_local+0xc8/0xfa
[   20.970046]  ? reacquire_held_locks+0x1cd/0x1cd:
						lock_release at kernel/locking/lockdep.c:3929
[   20.970046]  ? cfs_percpt_lock+0xdf/0x1ad:
						spin_lock at include/linux/spinlock.h:310
						 (inlined by) cfs_percpt_lock at drivers/staging/lustre/lnet/libcfs/libcfs_lock.c:111
[   20.970046]  ? do_raw_spin_unlock+0x100/0x10d:
						arch_spin_unlock at include/linux/spinlock_up.h:48
						 (inlined by) do_raw_spin_unlock at kernel/locking/spinlock_debug.c:135
[   20.970046]  ? _raw_spin_unlock+0x37/0x4e:
						__raw_spin_unlock at include/linux/spinlock_api_smp.h:151
						 (inlined by) _raw_spin_unlock at kernel/locking/spinlock.c:176
[   20.970046]  ? cfs_percpt_unlock+0x66/0x13a:
						spin_unlock at include/linux/spinlock.h:350
						 (inlined by) cfs_percpt_unlock at drivers/staging/lustre/lnet/libcfs/libcfs_lock.c:140
[   20.970046]  lnet_startup_lndni+0x62a/0xf84:
						lnet_startup_lndni at drivers/staging/lustre/lnet/lnet/api-ni.c:1306
[   20.970046]  ? lnet_shutdown_lndni+0xcc/0xcc:
						lnet_startup_lndni at drivers/staging/lustre/lnet/lnet/api-ni.c:1210
[   20.970046]  ? __schedule+0xbff/0xc7f:
						context_switch at kernel/sched/core.c:2851
						 (inlined by) __schedule at kernel/sched/core.c:3490
[   20.970046]  ? firmware_map_remove+0x265/0x265:
						__schedule at kernel/sched/core.c:3401
[   20.970046]  ? kasan_check_read+0x1f/0x28:
						kasan_check_read at mm/kasan/kasan.c:272
[   20.970046]  LNetNIInit+0x5d4/0xbf8:
						lnet_startup_lndnis at drivers/staging/lustre/lnet/lnet/api-ni.c:1385
						 (inlined by) LNetNIInit at drivers/staging/lustre/lnet/lnet/api-ni.c:1543
[   20.970046]  ? lnet_lib_exit+0x147/0x147:
						LNetNIInit at drivers/staging/lustre/lnet/lnet/api-ni.c:1497
[   20.970046]  ? del_timer+0x6d/0xf8:
						del_timer at kernel/time/timer.c:1200
[   20.970046]  ? add_timer_on+0x32b/0x32b:
						del_timer at kernel/time/timer.c:1193
[   20.970046]  ? _raw_spin_unlock_irqrestore+0x74/0x9e:
						__raw_spin_unlock_irqrestore at include/linux/spinlock_api_smp.h:160
						 (inlined by) _raw_spin_unlock_irqrestore at kernel/locking/spinlock.c:184
[   20.970046]  ? trace_hardirqs_on_caller+0x2c8/0x33d:
						trace_hardirqs_on_caller at kernel/locking/lockdep.c:2884
[   20.970046]  ? schedule_timeout+0x82b/0x8a7:
						schedule_timeout at kernel/time/timer.c:1807
[   20.970046]  ? kasan_kmalloc+0x1c5/0x1e1:
						save_stack at mm/kasan/kasan.c:454
						 (inlined by) set_track at mm/kasan/kasan.c:460
						 (inlined by) kasan_kmalloc at mm/kasan/kasan.c:553
[   20.970046]  ? console_conditional_schedule+0x44/0x44:
						schedule_timeout at kernel/time/timer.c:1763
[   20.970046]  ? do_one_initcall+0x158/0x3ac:
						do_one_initcall at init/main.c:883
[   20.970046]  ? kernel_init_freeable+0x2b8/0x434:
						do_initcall_level at init/main.c:951
						 (inlined by) do_initcalls at init/main.c:959
						 (inlined by) do_basic_setup at init/main.c:977
						 (inlined by) kernel_init_freeable at init/main.c:1127
[   20.970046]  ? kernel_init+0x13/0x1ae:
						kernel_init at init/main.c:1053
[   20.970046]  ? ret_from_fork+0x24/0x30:
						ret_from_fork at arch/x86/entry/entry_64.S:418
[   20.970046]  ? __check_object_size+0x8d7/0xa08:
						__check_object_size at mm/usercopy.c:262
[   20.970046]  ? usercopy_abort+0xb7/0xb7:
						__check_object_size at mm/usercopy.c:250
[   20.970046]  ? __lock_is_held+0x39/0xbb:
						__lock_is_held at kernel/locking/lockdep.c:3737 (discriminator 1)
[   20.970046]  ? mark_held_locks+0x2c/0xb2:
						mark_held_locks at kernel/locking/lockdep.c:2795 (discriminator 1)
[   20.970046]  ? debug_check_no_locks_freed+0x237/0x25f:
						debug_check_no_locks_freed at kernel/locking/lockdep.c:4421 (discriminator 2)
[   20.970046]  ? collect_expired_timers+0x23b/0x23b:
						process_timeout at kernel/time/timer.c:1727
[   20.970046]  ? lockdep_init_map+0x10/0x19:
						lockdep_init_map at kernel/locking/lockdep.c:3239
[   20.970046]  srpc_startup+0x136/0x352:
						srpc_startup at drivers/staging/lustre/lnet/selftest/rpc.c:1613
[   20.970046]  ? srpc_shutdown+0x1f0/0x1f0:
						srpc_startup at drivers/staging/lustre/lnet/selftest/rpc.c:1599
[   20.970046]  ? kvmalloc_node+0x6b/0xb6:
						__kmalloc_node at include/linux/slab.h:383
						 (inlined by) kmalloc_node at include/linux/slab.h:554
						 (inlined by) kvmalloc_node at mm/util.c:421
[   20.970046]  lnet_selftest_init+0x33a/0x4f5:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:134
[   20.970046]  ? lnet_selftest_exit+0x13e/0x13e:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:90
[   20.970046]  ? lustre_insert_debugfs+0x150/0x150:
						libcfs_init at drivers/staging/lustre/lnet/libcfs/module.c:531
[   20.970046]  ? lnet_init+0x1df/0x1df:
						ksocklnd_init at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2885
[   20.970046]  ? lnet_selftest_exit+0x13e/0x13e:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:90
[   20.970046]  do_one_initcall+0x158/0x3ac:
						do_one_initcall at init/main.c:883
[   20.970046]  ? start_kernel+0xbf5/0xbf5:
						do_one_initcall at init/main.c:874
[   20.970046]  kernel_init_freeable+0x2b8/0x434:
						do_initcall_level at init/main.c:951
						 (inlined by) do_initcalls at init/main.c:959
						 (inlined by) do_basic_setup at init/main.c:977
						 (inlined by) kernel_init_freeable at init/main.c:1127
[   20.970046]  ? rest_init+0x1d2/0x1d2:
						kernel_init at init/main.c:1050
[   20.970046]  kernel_init+0x13/0x1ae:
						kernel_init at init/main.c:1053
[   20.970046]  ? rest_init+0x1d2/0x1d2:
						kernel_init at init/main.c:1050
[   20.970046]  ret_from_fork+0x24/0x30:
						ret_from_fork at arch/x86/entry/entry_64.S:418
[   20.970046] ==================================================================
[   20.970046] Disabling lock debugging due to kernel taint
[   21.007543] BUG: unable to handle kernel NULL pointer dereference at 00000000000000a4
[   21.009103] PGD 0 P4D 0
[   21.009432] Oops: 0000 [#1] DEBUG_PAGEALLOC KASAN PTI
[   21.010063] CPU: 0 PID: 1 Comm: swapper Tainted: G    B           T 4.17.0-rc1 #1
[   21.011023] RIP: 0010:cfs_trace_lock_tcd+0x25/0xeb:
						cfs_trace_lock_tcd at drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c:149
[   21.011650] RSP: 0000:ffff880014c87380 EFLAGS: 00010202
[   21.012299] RAX: 0000000000000202 RBX: 0000000000000000 RCX: ffffffff8119215d
[   21.013197] RDX: dffffc0000000000 RSI: 0000000000000003 RDI: 0000000000000202
[   21.014074] RBP: ffff880014c87398 R08: 0000000000000001 R09: 0000000000000001
[   21.014940] R10: ffffed0002990e5a R11: 0000000000000001 R12: 00000000000000a4
[   21.015818] R13: 0000000000000000 R14: ffff88001402d680 R15: ffff880014c87970
[   21.016634] FS:  0000000000000000(0000) GS:ffffffff842e9000(0000) knlGS:0000000000000000
[   21.016892] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   21.016892] CR2: 00000000000000a4 CR3: 0000000004226000 CR4: 00000000000006f0
[   21.016892] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   21.016892] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   21.016892] Call Trace:
[   21.016892]  libcfs_debug_vmsg2+0x18d/0xd26:
						libcfs_debug_vmsg2 at drivers/staging/lustre/lnet/libcfs/tracefile.c:317
[   21.016892]  ? cfs_trace_get_tage+0x957/0x957:
						libcfs_debug_vmsg2 at drivers/staging/lustre/lnet/libcfs/tracefile.c:293
[   21.016892]  ? mark_lock+0xe9/0xa16:
						mark_lock at kernel/locking/lockdep.c:3121
[   21.016892]  ? fput+0x111/0x11f:
						queue_delayed_work at include/linux/workqueue.h:526
						 (inlined by) schedule_delayed_work at include/linux/workqueue.h:627
						 (inlined by) fput at fs/file_table.c:280
[   21.016892]  ? lnet_ipif_enumerate+0x541/0x588:
						lnet_ipif_enumerate at drivers/staging/lustre/lnet/lnet/lib-socket.c:238
[   21.016892]  ? kasan_slab_free+0x15/0x1e:
						kasan_slab_free at mm/kasan/kasan.c:528
[   21.016892]  ? kfree+0x215/0x2cb:
						slab_free_hook at mm/slub.c:1388
						 (inlined by) slab_free_freelist_hook at mm/slub.c:1415
						 (inlined by) slab_free at mm/slub.c:2988
						 (inlined by) kfree at mm/slub.c:3944
[   21.016892]  libcfs_debug_msg+0x9b/0xc5:
						libcfs_debug_msg at drivers/staging/lustre/lnet/libcfs/tracefile.c:278
[   21.016892]  ? libcfs_debug_vmsg2+0xd26/0xd26:
						libcfs_debug_msg at drivers/staging/lustre/lnet/libcfs/tracefile.c:278
[   21.016892]  ksocknal_startup+0x341/0x1228:
						ksocknal_enumerate_interfaces at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2634
						 (inlined by) ksocknal_startup at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2822
[   21.016892]  ? __asan_loadN+0x1d/0x26
[   21.016892]  ? pvclock_clocksource_read+0x162/0x296:
						pvclock_clocksource_read at arch/x86/kernel/pvclock.c:89
[   21.016892]  ? ksocknal_base_startup+0xbae/0xbae:
						ksocknal_startup at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2796
[   21.016892]  ? pvclock_read_flags+0x5d/0x5d:
						pvclock_clocksource_read at arch/x86/kernel/pvclock.c:79
[   21.016892]  ? kasan_check_read+0x1f/0x28:
						kasan_check_read at mm/kasan/kasan.c:272
[   21.016892]  ? kvm_clock_read+0x24/0x3a:
						kvm_clock_read at arch/x86/kernel/kvmclock.c:89
[   21.016892]  ? kasan_check_write+0x22/0x2b:
						kasan_check_write at mm/kasan/kasan.c:278
[   21.016892]  ? sched_clock_local+0xc8/0xfa
[   21.016892]  ? reacquire_held_locks+0x1cd/0x1cd:
						lock_release at kernel/locking/lockdep.c:3929
[   21.016892]  ? cfs_percpt_lock+0xdf/0x1ad:
						spin_lock at include/linux/spinlock.h:310
						 (inlined by) cfs_percpt_lock at drivers/staging/lustre/lnet/libcfs/libcfs_lock.c:111
[   21.016892]  ? do_raw_spin_unlock+0x100/0x10d:
						arch_spin_unlock at include/linux/spinlock_up.h:48
						 (inlined by) do_raw_spin_unlock at kernel/locking/spinlock_debug.c:135
[   21.016892]  ? _raw_spin_unlock+0x37/0x4e:
						__raw_spin_unlock at include/linux/spinlock_api_smp.h:151
						 (inlined by) _raw_spin_unlock at kernel/locking/spinlock.c:176
[   21.016892]  ? cfs_percpt_unlock+0x66/0x13a:
						spin_unlock at include/linux/spinlock.h:350
						 (inlined by) cfs_percpt_unlock at drivers/staging/lustre/lnet/libcfs/libcfs_lock.c:140
[   21.016892]  lnet_startup_lndni+0x62a/0xf84:
						lnet_startup_lndni at drivers/staging/lustre/lnet/lnet/api-ni.c:1306
[   21.016892]  ? lnet_shutdown_lndni+0xcc/0xcc:
						lnet_startup_lndni at drivers/staging/lustre/lnet/lnet/api-ni.c:1210
[   21.016892]  ? __schedule+0xbff/0xc7f:
						context_switch at kernel/sched/core.c:2851
						 (inlined by) __schedule at kernel/sched/core.c:3490
[   21.016892]  ? firmware_map_remove+0x265/0x265:
						__schedule at kernel/sched/core.c:3401
[   21.016892]  ? kasan_check_read+0x1f/0x28:
						kasan_check_read at mm/kasan/kasan.c:272
[   21.016892]  LNetNIInit+0x5d4/0xbf8:
						lnet_startup_lndnis at drivers/staging/lustre/lnet/lnet/api-ni.c:1385
						 (inlined by) LNetNIInit at drivers/staging/lustre/lnet/lnet/api-ni.c:1543
[   21.016892]  ? lnet_lib_exit+0x147/0x147:
						LNetNIInit at drivers/staging/lustre/lnet/lnet/api-ni.c:1497
[   21.016892]  ? del_timer+0x6d/0xf8:
						del_timer at kernel/time/timer.c:1200
[   21.016892]  ? add_timer_on+0x32b/0x32b:
						del_timer at kernel/time/timer.c:1193
[   21.016892]  ? _raw_spin_unlock_irqrestore+0x74/0x9e:
						__raw_spin_unlock_irqrestore at include/linux/spinlock_api_smp.h:160
						 (inlined by) _raw_spin_unlock_irqrestore at kernel/locking/spinlock.c:184
[   21.016892]  ? trace_hardirqs_on_caller+0x2c8/0x33d:
						trace_hardirqs_on_caller at kernel/locking/lockdep.c:2884
[   21.016892]  ? schedule_timeout+0x82b/0x8a7:
						schedule_timeout at kernel/time/timer.c:1807
[   21.016892]  ? kasan_kmalloc+0x1c5/0x1e1:
						save_stack at mm/kasan/kasan.c:454
						 (inlined by) set_track at mm/kasan/kasan.c:460
						 (inlined by) kasan_kmalloc at mm/kasan/kasan.c:553
[   21.016892]  ? console_conditional_schedule+0x44/0x44:
						schedule_timeout at kernel/time/timer.c:1763
[   21.016892]  ? do_one_initcall+0x158/0x3ac:
						do_one_initcall at init/main.c:883
[   21.016892]  ? kernel_init_freeable+0x2b8/0x434:
						do_initcall_level at init/main.c:951
						 (inlined by) do_initcalls at init/main.c:959
						 (inlined by) do_basic_setup at init/main.c:977
						 (inlined by) kernel_init_freeable at init/main.c:1127
[   21.016892]  ? kernel_init+0x13/0x1ae:
						kernel_init at init/main.c:1053
[   21.016892]  ? ret_from_fork+0x24/0x30:
						ret_from_fork at arch/x86/entry/entry_64.S:418
[   21.016892]  ? __check_object_size+0x8d7/0xa08:
						__check_object_size at mm/usercopy.c:262
[   21.016892]  ? usercopy_abort+0xb7/0xb7:
						__check_object_size at mm/usercopy.c:250
[   21.016892]  ? __lock_is_held+0x39/0xbb:
						__lock_is_held at kernel/locking/lockdep.c:3737 (discriminator 1)
[   21.016892]  ? mark_held_locks+0x2c/0xb2:
						mark_held_locks at kernel/locking/lockdep.c:2795 (discriminator 1)
[   21.016892]  ? debug_check_no_locks_freed+0x237/0x25f:
						debug_check_no_locks_freed at kernel/locking/lockdep.c:4421 (discriminator 2)
[   21.016892]  ? collect_expired_timers+0x23b/0x23b:
						process_timeout at kernel/time/timer.c:1727
[   21.016892]  ? lockdep_init_map+0x10/0x19:
						lockdep_init_map at kernel/locking/lockdep.c:3239
[   21.016892]  srpc_startup+0x136/0x352:
						srpc_startup at drivers/staging/lustre/lnet/selftest/rpc.c:1613
[   21.016892]  ? srpc_shutdown+0x1f0/0x1f0:
						srpc_startup at drivers/staging/lustre/lnet/selftest/rpc.c:1599
[   21.016892]  ? kvmalloc_node+0x6b/0xb6:
						__kmalloc_node at include/linux/slab.h:383
						 (inlined by) kmalloc_node at include/linux/slab.h:554
						 (inlined by) kvmalloc_node at mm/util.c:421
[   21.016892]  lnet_selftest_init+0x33a/0x4f5:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:134
[   21.016892]  ? lnet_selftest_exit+0x13e/0x13e:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:90
[   21.016892]  ? lustre_insert_debugfs+0x150/0x150:
						libcfs_init at drivers/staging/lustre/lnet/libcfs/module.c:531
[   21.016892]  ? lnet_init+0x1df/0x1df:
						ksocklnd_init at drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2885
[   21.016892]  ? lnet_selftest_exit+0x13e/0x13e:
						lnet_selftest_init at drivers/staging/lustre/lnet/selftest/module.c:90
[   21.016892]  do_one_initcall+0x158/0x3ac:
						do_one_initcall at init/main.c:883
[   21.016892]  ? start_kernel+0xbf5/0xbf5:
						do_one_initcall at init/main.c:874
[   21.016892]  kernel_init_freeable+0x2b8/0x434:
						do_initcall_level at init/main.c:951
						 (inlined by) do_initcalls at init/main.c:959
						 (inlined by) do_basic_setup at init/main.c:977
						 (inlined by) kernel_init_freeable at init/main.c:1127
[   21.016892]  ? rest_init+0x1d2/0x1d2:
						kernel_init at init/main.c:1050
[   21.016892]  kernel_init+0x13/0x1ae:
						kernel_init at init/main.c:1053
[   21.016892]  ? rest_init+0x1d2/0x1d2:
						kernel_init at init/main.c:1050
[   21.016892]  ret_from_fork+0x24/0x30:
						ret_from_fork at arch/x86/entry/entry_64.S:418
[   21.016892] Code: d4 05 31 c0 5d c3 55 48 ff 05 2b bf d4 05 48 89 e5 41 55 41 54 4c 8d a7 a4 00 00 00 53 48 89 fb 41 89 f5 4c 89 e7 e8 16 a9 18 ff <66> 83 bb a4 00 00 00 02 76 24 48 c7 c6 20 37 75 85 48 c7 c7 40
[   21.016892] RIP: cfs_trace_lock_tcd+0x25/0xeb:
						cfs_trace_lock_tcd at drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c:149 RSP: ffff880014c87380
[   21.016892] CR2: 00000000000000a4
[   21.016892] ---[ end trace be7ae81fe247d9ae ]---
[   21.016892] Kernel panic - not syncing: Fatal exception

Attached the full dmesg, kconfig and reproduce scripts.

Thanks,
Fengguang
-------------- next part --------------
early console in setup code
early console in extract_kernel
input_data: 0x0000000006995295
input_len: 0x0000000001885d8b
output: 0x0000000001000000
output_len: 0x00000000053754c8
kernel_total_size: 0x000000000723e000
trampoline_32bit: 0x000000000009d000

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 4.17.0-rc1 (kbuild at lkp-wsm-ep1) (gcc version 7.3.0 (Debian 7.3.0-1)) #1 Tue Apr 17 12:03:01 CST 2018
[    0.000000] Command line: ip=::::vm-lkp-hsw01-openwrt-ia32-7::dhcp root=/dev/ram0 user=lkp job=/lkp/scheduled/vm-lkp-hsw01-openwrt-ia32-7/boot-1-openwrt-i386-2016-03-16.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180417-30956-psgkzl-wait_kernel-0.yaml ARCH=x86_64 kconfig=x86_64-randconfig-ws0-03101549 branch=linus/master commit=60cc43fc888428bb2f18f08997432d426a243338 BOOT_IMAGE=/pkg/linux/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1 max_uptime=600 RESULT_ROOT=/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0 LKP_SERVER=inn debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 net.ifnames=0 printk.devkmsg=on panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 drbd.minor_count=8 systemd.log_level=err ignore_loglevel console=tty0 earlyprintk=ttyS0,115200 console=ttyS0,115200 vga=no
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
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
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x1a3e0 max_arch_pfn = 0x400000000
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
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
[    0.000000] Base memory trampoline at [        (ptrval)] 99000 size 24576
[    0.000000] BRK [0x08228000, 0x08228fff] PGTABLE
[    0.000000] BRK [0x08229000, 0x08229fff] PGTABLE
[    0.000000] BRK [0x0822a000, 0x0822afff] PGTABLE
[    0.000000] BRK [0x0822b000, 0x0822bfff] PGTABLE
[    0.000000] BRK [0x0822c000, 0x0822cfff] PGTABLE
[    0.000000] BRK [0x0822d000, 0x0822dfff] PGTABLE
[    0.000000] RAMDISK: [mem 0x1a0bf000-0x1a3dffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F68D0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000001A3E15CE 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000001A3E142A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000001A3E0040 0013EA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000001A3E0000 000040
[    0.000000] ACPI: APIC 0x000000001A3E151E 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000001A3E1596 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fd000 (        fee00000)
[    0.000000] kvm-clock: cpu 0, msr 0:1a0bd001, primary cpu clock
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: using sched offset of 270754956 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000001a3dffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001a3dffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001a3dffff]
[    0.000000] On node 0 totalpages: 107390
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1616 pages used for memmap
[    0.000000]   DMA32 zone: 103392 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] kasan: KernelAddressSanitizer initialized
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
[    0.000000] mapped IOAPIC to ffffffffff5fc000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 434f600
[    0.000000] e820: [mem 0x1a400000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.000000] random: fast init done
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 105689
[    0.000000] Kernel command line: ip=::::vm-lkp-hsw01-openwrt-ia32-7::dhcp root=/dev/ram0 user=lkp job=/lkp/scheduled/vm-lkp-hsw01-openwrt-ia32-7/boot-1-openwrt-i386-2016-03-16.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180417-30956-psgkzl-wait_kernel-0.yaml ARCH=x86_64 kconfig=x86_64-randconfig-ws0-03101549 branch=linus/master commit=60cc43fc888428bb2f18f08997432d426a243338 BOOT_IMAGE=/pkg/linux/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1 max_uptime=600 RESULT_ROOT=/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0 LKP_SERVER=inn debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 net.ifnames=0 printk.devkmsg=on panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 drbd.minor_count=8 systemd.log_level=err ignore_loglevel console=tty0 earlyprintk=ttyS0,115200 console=ttyS0,115200
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.000000] Memory: 231040K/429560K available (30732K kernel code, 30174K rwdata, 17200K rodata, 1908K init, 33484K bss, 198520K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Kernel/User page tables isolation: enabled
[    0.010000] Running RCU self tests
[    0.010000] NR_IRQS: 4352, nr_irqs: 48, preallocated irqs: 16
[    0.010000] console [ttyS0] enabled
[    0.010000] bootconsole [earlyser0] disabled
[    0.010000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.010000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.010000] ... MAX_LOCK_DEPTH:          48
[    0.010000] ... MAX_LOCKDEP_KEYS:        8191
[    0.010000] ... CLASSHASH_SIZE:          4096
[    0.010000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.010000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.010000] ... CHAINHASH_SIZE:          32768
[    0.010000]  memory used by lock dependency info: 7903 kB
[    0.010000]  per task-struct memory footprint: 2688 bytes
[    0.010000] ACPI: Core revision 20180313
[    0.010000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.010000] hpet clockevent registered
[    0.010043] APIC: Switch to symmetric I/O mode setup
[    0.010553] x2apic enabled
[    0.010956] Switched APIC routing to physical x2apic.
[    0.011331] enabled ExtINT on CPU#0
[    0.012159] ENABLING IO-APIC IRQs
[    0.012458] init IO_APIC IRQs
[    0.012687]  apic 0 pin 0 not connected
[    0.013099] IOAPIC[0]: Set routing entry (0-1 -> 0xef -> IRQ 1 Mode:0 Active:0 Dest:0)
[    0.013779] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
[    0.014391] IOAPIC[0]: Set routing entry (0-3 -> 0xef -> IRQ 3 Mode:0 Active:0 Dest:0)
[    0.015131] IOAPIC[0]: Set routing entry (0-4 -> 0xef -> IRQ 4 Mode:0 Active:0 Dest:0)
[    0.016126] IOAPIC[0]: Set routing entry (0-5 -> 0xef -> IRQ 5 Mode:1 Active:0 Dest:0)
[    0.017129] IOAPIC[0]: Set routing entry (0-6 -> 0xef -> IRQ 6 Mode:0 Active:0 Dest:0)
[    0.018137] IOAPIC[0]: Set routing entry (0-7 -> 0xef -> IRQ 7 Mode:0 Active:0 Dest:0)
[    0.019142] IOAPIC[0]: Set routing entry (0-8 -> 0xef -> IRQ 8 Mode:0 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-9 -> 0xef -> IRQ 9 Mode:1 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-10 -> 0xef -> IRQ 10 Mode:1 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-11 -> 0xef -> IRQ 11 Mode:1 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-12 -> 0xef -> IRQ 12 Mode:0 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-13 -> 0xef -> IRQ 13 Mode:0 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-14 -> 0xef -> IRQ 14 Mode:0 Active:0 Dest:0)
[    0.020000] IOAPIC[0]: Set routing entry (0-15 -> 0xef -> IRQ 15 Mode:0 Active:0 Dest:0)
[    0.020000]  apic 0 pin 16 not connected
[    0.020000]  apic 0 pin 17 not connected
[    0.020000]  apic 0 pin 18 not connected
[    0.020000]  apic 0 pin 19 not connected
[    0.020000]  apic 0 pin 20 not connected
[    0.020000]  apic 0 pin 21 not connected
[    0.020000]  apic 0 pin 22 not connected
[    0.020000]  apic 0 pin 23 not connected
[    0.020000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.020000] tsc: Detected 2593.992 MHz processor
[    0.020000] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x25641074d3b, max_idle_ns: 440795244898 ns
[    0.020000] Calibrating delay loop (skipped) preset value.. 5187.98 BogoMIPS (lpj=25939920)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.020000] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.021561] mce: CPU supports 10 MCE banks
[    0.022172] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.022782] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.023454] CPU: Intel QEMU Virtual CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
[    0.024481] Spectre V2 : Spectre mitigation: kernel not compiled with retpoline; no mitigation available!
[    0.030073] Performance Events: PMU not available due to virtualization, using software events only.
[    0.041231] Using local APIC timer interrupts.
[    0.041231] calibrating APIC timer ...
[    0.050000] ... lapic delta = 6249955
[    0.050000] ... PM-Timer delta = 357958
[    0.050000] ... PM-Timer result ok
[    0.050000] ..... delta 6249955
[    0.050000] ..... mult: 268433523
[    0.050000] ..... calibration result: 9999928
[    0.050000] ..... CPU clock speed is 2594.0194 MHz.
[    0.050000] ..... host bus clock speed is 999.9928 MHz.
[    0.050000] devtmpfs: initialized
[    0.050000] x86/mm: Memory block size: 128MB
[    0.050000] gcov: version magic: 0x4137332a
[    0.066466] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.067220] futex hash table entries: 256 (order: 2, 24576 bytes)
[    0.068008] prandom: seed boundary self test passed
[    0.070041] prandom: 100 self tests passed
[    0.073606] NET: Registered protocol family 16
[    0.079023] cpuidle: using governor menu
[    0.081433] ACPI: bus type PCI registered
[    0.082060] PCI: Using configuration type 1 for base access
[    0.173954] cryptd: max_cpu_qlen set to 1000
[    0.175725] ACPI: Added _OSI(Module Device)
[    0.176157] ACPI: Added _OSI(Processor Device)
[    0.176598] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.177070] ACPI: Added _OSI(Processor Aggregator Device)
[    0.177628] ACPI: Added _OSI(Linux-Dell-Video)
[    0.223684] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.233804] workqueue: round-robin CPU selection forced, expect performance impact
[    0.241272] ACPI: Interpreter enabled
[    0.241766] ACPI: (supports S0 S3 S5)
[    0.242066] ACPI: Using IOAPIC for interrupt routing
[    0.242629] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.246303] ACPI: Enabled 2 GPEs in block 00 to 0F
[    0.336574] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.337129] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.337728] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.339232] PCI host bridge to bus 0000:00
[    0.339560] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.340029] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.340531] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.341078] pci_bus 0000:00: root bus resource [mem 0x1a400000-0xfebfffff window]
[    0.341643] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.342184] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.346240] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.350136] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.352896] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.354404] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.354928] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.355403] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.355924] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.359295] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.360202] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.360740] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.364664] pci 0000:00:02.0: [1234:1111] type 00 class 0x030000
[    0.367362] pci 0000:00:02.0: reg 0x10: [mem 0xfd000000-0xfdffffff pref]
[    0.370028] pci 0000:00:02.0: reg 0x18: [mem 0xfebf0000-0xfebf0fff]
[    0.376297] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.380775] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.382928] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.384147] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.388955] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.392921] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.393818] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.399967] pci_bus 0000:00: on NUMA node 0
[    0.408842] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.411785] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.414287] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.416773] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.418135] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.425196] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.425675] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.426312] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.426750] vgaarb: loaded
[    0.429438] ACPI: bus type USB registered
[    0.430072] usbcore: registered new interface driver usbfs
[    0.430637] usbcore: registered new interface driver hub
[    0.431211] usbcore: registered new device driver usb
[    0.432726] Linux video capture interface: v2.00
[    0.433365] pps_core: LinuxPPS API ver. 1 registered
[    0.433755] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.434543] EDAC MC: Ver: 3.0.0
[    0.436844] FPGA manager framework
[    0.437834] Advanced Linux Sound Architecture Driver Initialized.
[    0.439003] PCI: Using ACPI for IRQ routing
[    0.439527] PCI: pci_cache_line_size set to 64 bytes
[    0.440238] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.441017] e820: reserve RAM buffer [mem 0x1a3e0000-0x1bffffff]
[    0.445834] nfc: nfc_init: NFC Core ver 0.1
[    0.446784] NET: Registered protocol family 39
[    0.451278] clocksource: Switched to clocksource kvm-clock
[    0.453067] VFS: Disk quotas dquot_6.6.0
[    0.453711] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.455777] pnp: PnP ACPI init
[    0.457750] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.459737] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.460642] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.461787] pnp 00:03: [dma 2]
[    0.462721] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.465262] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.467668] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.470149] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.479749] pnp: PnP ACPI: found 7 devices
[    0.507998] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.518408] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.518923] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.519374] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.519875] pci_bus 0000:00: resource 7 [mem 0x1a400000-0xfebfffff window]
[    0.523611] NET: Registered protocol family 2
[    0.526183] tcp_listen_portaddr_hash hash table entries: 256 (order: 2, 22528 bytes)
[    0.526845] TCP established hash table entries: 4096 (order: 3, 32768 bytes)
[    0.527519] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    0.528742] TCP: Hash tables configured (established 4096 bind 4096)
[    0.529433] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.530005] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.531162] NET: Registered protocol family 1
[    0.532748] RPC: Registered named UNIX socket transport module.
[    0.533219] RPC: Registered udp transport module.
[    0.533569] RPC: Registered tcp transport module.
[    0.533914] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.538273] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.538832] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.539311] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.539905] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.540639] PCI: CLS 0 bytes, default 64
[    0.542049] Unpacking initramfs...
[    1.030364] kwatchdog (22) used greatest stack depth: 26312 bytes left
[    2.189507] debug: unmapping init [mem 0xffff88001a0bf000-0xffff88001a3dffff]
[    2.208343] PCLMULQDQ-NI instructions are not detected.
[    2.209601] AVX or AES-NI instructions are not detected.
[    2.210052] CPU feature 'AVX registers' is not supported.
[    2.210459] CPU feature 'AVX registers' is not supported.
[    2.210854] AVX2 or AES-NI instructions are not detected.
[    2.211250] AVX2 instructions are not detected.
[    3.200239] tsc: Refined TSC clocksource calibration: 2593.993 MHz
[    3.200785] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x256411d258c, max_idle_ns: 440795337342 ns
[    8.827981] rcu-torture:--- Start of test: nreaders=1 nfakewriters=4 stat_interval=60 verbose=1 test_no_idle_hz=1 shuffle_interval=3 stutter=5 irqreader=1 fqs_duration=0 fqs_holdoff=0 fqs_stutter=3 test_boost=1/0 test_boost_interval=7 test_boost_duration=4 shutdown_secs=0 stall_cpu=0 stall_cpu_holdoff=10 stall_cpu_irqsoff=0 n_barrier_cbs=0 onoff_interval=0 onoff_holdoff=0
[    8.833059] rcu-torture: Creating rcu_torture_writer task
[    8.834076] rcu-torture: Creating rcu_torture_fakewriter task
[    8.834818] rcu-torture: rcu_torture_writer task started
[    8.835395] rcu-torture: GP expediting controlled from boot/sysfs for rcu.
[    8.836083] rcu_torture_writer: Testing conditional GPs.
[    8.836604] rcu_torture_writer: Testing expedited GPs.
[    8.837127] rcu_torture_writer: Testing asynchronous GPs.
[    8.837658] rcu_torture_writer: Testing normal GPs.
[    8.838236] rcu-torture: Creating rcu_torture_fakewriter task
[    8.839000] rcu-torture: rcu_torture_fakewriter task started
[    8.839664] rcu-torture: Creating rcu_torture_fakewriter task
[    8.840451] rcu-torture: rcu_torture_fakewriter task started
[    8.841111] rcu-torture: Creating rcu_torture_fakewriter task
[    8.841823] rcu-torture: rcu_torture_fakewriter task started
[    8.842493] rcu-torture: Creating rcu_torture_reader task
[    8.843207] rcu-torture: rcu_torture_fakewriter task started
[    8.843875] rcu-torture: Creating rcu_torture_stats task
[    8.844598] rcu-torture: rcu_torture_reader task started
[    8.845241] rcu-torture: Creating torture_shuffle task
[    8.845897] rcu-torture: rcu_torture_stats task started
[    8.846527] rcu-torture: Creating torture_stutter task
[    8.847205] rcu-torture: torture_shuffle task started
[    8.847828] rcu-torture: Creating rcu_torture_cbflood task
[    8.848545] rcu-torture: torture_stutter task started
[    8.862492] rcu-torture: rcu_torture_cbflood task started
[   13.100860] Initialise system trusted keyrings
[   13.102787] workingset: timestamp_bits=46 max_order=16 bucket_order=0
[   13.179321] zbud: loaded
[   13.197351] NFS: Registering the id_resolver key type
[   13.198044] Key type id_resolver registered
[   13.198568] Key type id_legacy registered
[   13.212521] romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
[   13.213697] 9p: Installing v9fs 9p2000 file system support
[   13.219036] ceph: loaded (mds proto 32)
[   13.219512] pstore: using deflate compression
[   13.231367] cryptomgr_test (85) used greatest stack depth: 25216 bytes left
[   13.247875] NET: Registered protocol family 38
[   13.248534] Key type asymmetric registered
[   13.249043] Asymmetric key parser 'x509' registered
[   13.249634] Key type pkcs7_test registered
[   14.057793] String selftests succeeded
[   14.059173] xz_dec_test: module loaded
[   14.059468] xz_dec_test: Create a device node with 'mknod xz_dec_test c 245 0' and write .xz files to it.
[   14.063014] ipmi message handler version 39.2
[   14.063363] ipmi device interface
[   14.063815] IPMI System Interface driver.
[   14.064739] ipmi_si: Unable to find any System Interface(s)
[   14.065164] IPMI Watchdog: driver initialized
[   14.065492] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[   14.067173] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   14.068019] ACPI: Power Button [PWRF]
[   14.262277] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   14.285763] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   14.313955] 00:06: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[   14.323145] lp: driver loaded but no devices found
[   14.323832] Non-volatile memory driver v1.3
[   14.325146] telclk_interrupt = 0xf non-mcpbl0010 hw.
[   14.325933] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[   14.328232] parport_pc 00:04: reported by Plug and Play ACPI
[   14.329298] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   14.411809] lp0: using parport0 (interrupt-driven).
[   14.417270] dummy-irq: no IRQ given.  Use irq=N
[   14.418062] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[   14.419112] c2port c2port0: C2 port uc added
[   14.419442] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[   14.422591] usbcore: registered new interface driver viperboard
[   14.423429] usbcore: registered new interface driver pn533_usb
[   14.424970] nfcsim 0.2 initialized
[   14.425355] usbcore: registered new interface driver port100
[   14.426575] L440GX flash mapping: failed to find PIIX4 ISA bridge, cannot continue
[   14.427312] platform physmap-flash.0: failed to claim resource 0: [mem 0x08000000-0x07ffffff]
[   14.428045] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   14.428811] slram: not enough parameters.
[   14.429244] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.429927] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.430628] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.431297] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.431966] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.432649] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.433324] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[   14.433787] nand: Toshiba NAND 128MiB 1,8V 8-bit
[   14.434134] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, OOB size: 16
[   14.434734] flash size: 128 MiB
[   14.434976] page size: 512 bytes
[   14.435219] OOB area size: 16 bytes
[   14.435485] sector size: 16 KiB
[   14.435721] pages number: 262144
[   14.435963] pages per sector: 32
[   14.436206] bus width: 8
[   14.436406] bits in sector size: 14
[   14.436678] bits in page size: 9
[   14.436921] bits in OOB size: 4
[   14.437157] flash size with OOB: 135168 KiB
[   14.437469] page address bytes: 4
[   14.437716] sector address bytes: 3
[   14.437976] options: 0x42
[   14.443133] Scanning device for bad blocks
[   14.523624] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   14.524118] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   14.736585] parport0: AVR Butterfly
[   14.737327] parport0: cannot grant exclusive access for device spi-lm70llp
[   14.737871] spi_lm70llp: spi_lm70llp probe fail, status -12
[   14.739050] HSI/SSI char device loaded
[   14.739452] eql: Equalizer2002: Simon Janes (simon at ncm.com) and David S. Miller (davem at redhat.com)
[   14.745389] libphy: Fixed MDIO Bus: probed
[   14.753478] tun: Universal TUN/TAP device driver, 1.6
[   14.754476] arcnet: arcnet loaded
[   14.754742] arcnet:rfc1201: RFC1201 "standard" (`a') encapsulation support loaded
[   14.755279] arcnet:rfc1051: RFC1051 "simple standard" (`s') encapsulation support loaded
[   14.755891] arcnet:com90xx: COM90xx chipset support
[   15.065885] S3: No ARCnet cards found.
[   15.066263] arcnet:arc_rimi: RIM I (entirely mem-mapped) support
[   15.066706] arcnet:arc_rimi: E-mail me if you actually test the RIM I driver, please!
[   15.067265] arcnet:arc_rimi: Given: node 00h, shmem 0h, irq 0
[   15.067700] arcnet:arc_rimi: No autoprobe for RIM I; you must specify the shmem and irq!
[   15.068601] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   15.069115] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   18.721197] PCI Interrupt Link [LNKC] enabled at IRQ 11
[   19.623640] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   19.624225] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   19.624977] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[   19.625424] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[   19.626020] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[   19.626532] igb: Copyright (c) 2007-2014 Intel Corporation.
[   19.627073] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 5.1.0-k
[   19.627630] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[   19.628525] YAM driver version 0.8 by F1OAT/F6FBB
[   19.635685] NET3 PLIP version 2.4-parport gniibe at mri.co.jp
[   19.636113] plip0: Parallel port at 0x378, using IRQ 7.
[   19.636627] usbcore: registered new interface driver catc
[   19.637143] usbcore: registered new interface driver kaweth
[   19.637697] usbcore: registered new interface driver rtl8150
[   19.638230] usbcore: registered new interface driver r8152
[   19.638750] usbcore: registered new interface driver lan78xx
[   19.639273] usbcore: registered new interface driver ipheth
[   19.640680] panel: could not claim access to parport0. Aborting.
[   19.641591] panel: panel driver not yet registered
[   19.642524] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   19.643018] ohci-pci: OHCI PCI platform driver
[   19.643495] ohci-platform: OHCI generic platform driver
[   19.644748] usbcore: registered new interface driver usblp
[   19.645269] usbcore: registered new interface driver usbtmc
[   19.645881] usbcore: registered new interface driver mdc800
[   19.646294] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   19.646969] usbcore: registered new interface driver adutux
[   19.647494] usbcore: registered new interface driver appledisplay
[   19.648045] usbcore: registered new interface driver cypress_cy7c63
[   19.648620] usbcore: registered new interface driver cytherm
[   19.649156] usbcore: registered new interface driver emi26 - firmware loader
[   19.649784] usbcore: registered new interface driver emi62 - firmware loader
[   19.650454] usbcore: registered new interface driver idmouse
[   19.650984] usbcore: registered new interface driver usblcd
[   19.651512] usbcore: registered new interface driver legousbtower
[   19.652068] usbcore: registered new interface driver rio500
[   19.652594] usbcore: registered new interface driver usb_ehset_test
[   19.653164] usbcore: registered new interface driver usbsevseg
[   19.653755] usbcore: registered new interface driver yurex
[   19.656757] vhci_hcd: vhci_hcd_probe:1286: name vhci_hcd id 0
[   19.657323] vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
[   19.657831] vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 1
[   19.658421] vhci_hcd: vhci_start:1118: enter vhci_start
[   19.658905] vhci_hcd: vhci_start:1160: created sysfs vhci_hcd.0
[   19.662980] hub 1-0:1.0: USB hub found
[   19.663689] vhci_hcd: vhci_hub_control:335: typeReq a006 wValue 2900 wIndex 0
[   19.664485] vhci_hcd: vhci_hub_control:388:  GetHubDescriptor
[   19.664959] vhci_hcd: vhci_hub_control:596: port -1
[   19.665319] vhci_hcd: vhci_hub_control:604:  bye
[   19.665746] hub 1-0:1.0: 8 ports detected
[   19.666398] vhci_hcd: vhci_hub_control:335: typeReq a000 wValue 0 wIndex 0
[   19.666979] vhci_hcd: vhci_hub_control:411:  GetHubStatus
[   19.667404] vhci_hcd: vhci_hub_control:596: port -1
[   19.667763] vhci_hcd: vhci_hub_control:604:  bye
[   19.671595] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 1
[   19.672103] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.672640] vhci_hcd: vhci_hub_control:596: port 0
[   19.672994] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.673586] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.673974] vhci_hcd: dump_port_status_diff:150: 
[   19.674320] vhci_hcd: vhci_hub_control:604:  bye
[   19.674777] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 2
[   19.675280] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.675814] vhci_hcd: vhci_hub_control:596: port 1
[   19.676164] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.676755] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.677140] vhci_hcd: dump_port_status_diff:150: 
[   19.677513] vhci_hcd: vhci_hub_control:604:  bye
[   19.677961] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 3
[   19.678471] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.679004] vhci_hcd: vhci_hub_control:596: port 2
[   19.679356] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.679945] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.680021] vhci_hcd: dump_port_status_diff:150: 
[   19.680021] vhci_hcd: vhci_hub_control:604:  bye
[   19.681172] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 4
[   19.681690] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.682222] vhci_hcd: vhci_hub_control:596: port 3
[   19.682589] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.683173] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.683564] vhci_hcd: dump_port_status_diff:150: 
[   19.683909] vhci_hcd: vhci_hub_control:604:  bye
[   19.684357] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 5
[   19.684865] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.685405] vhci_hcd: vhci_hub_control:596: port 4
[   19.685780] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.686369] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.686762] vhci_hcd: dump_port_status_diff:150: 
[   19.687108] vhci_hcd: vhci_hub_control:604:  bye
[   19.687567] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 6
[   19.688069] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.688612] vhci_hcd: vhci_hub_control:596: port 5
[   19.688971] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.689562] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.689952] vhci_hcd: dump_port_status_diff:150: 
[   19.690296] vhci_hcd: vhci_hub_control:604:  bye
[   19.690879] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 7
[   19.691384] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.691920] vhci_hcd: vhci_hub_control:596: port 6
[   19.692274] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.692866] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.693252] vhci_hcd: dump_port_status_diff:150: 
[   19.693624] vhci_hcd: vhci_hub_control:604:  bye
[   19.694072] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 8
[   19.694582] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.695115] vhci_hcd: vhci_hub_control:596: port 7
[   19.695472] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000100
[   19.696060] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.696455] vhci_hcd: dump_port_status_diff:150: 
[   19.696802] vhci_hcd: vhci_hub_control:604:  bye
[   19.698235] vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
[   19.698690] vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 2
[   19.699247] vhci_hcd: vhci_start:1118: enter vhci_start
[   19.699845] vhci_hcd: vhci_hub_control:335: typeReq 8006 wValue f00 wIndex 0
[   19.700442] vhci_hcd: vhci_hub_control:596: port -1
[   19.700837] vhci_hcd: vhci_hub_control:604:  bye
[   19.701301] vhci_hcd: vhci_hub_control:335: typeReq 8006 wValue f00 wIndex 0
[   19.701997] vhci_hcd: vhci_hub_control:596: port -1
[   19.702358] vhci_hcd: vhci_hub_control:604:  bye
[   19.702756] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[   19.705795] hub 2-0:1.0: USB hub found
[   19.706219] vhci_hcd: vhci_hub_control:335: typeReq a006 wValue 2a00 wIndex 0
[   19.706746] vhci_hcd: vhci_hub_control:388:  GetHubDescriptor
[   19.707169] vhci_hcd: vhci_hub_control:596: port -1
[   19.707538] vhci_hcd: vhci_hub_control:604:  bye
[   19.707943] hub 2-0:1.0: 8 ports detected
[   19.708462] vhci_hcd: vhci_hub_control:335: typeReq a000 wValue 0 wIndex 0
[   19.708977] vhci_hcd: vhci_hub_control:411:  GetHubStatus
[   19.709377] vhci_hcd: vhci_hub_control:596: port -1
[   19.709770] vhci_hcd: vhci_hub_control:604:  bye
[   19.713794] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 1
[   19.714305] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.714842] vhci_hcd: vhci_hub_control:596: port 0
[   19.715197] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.715793] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.716183] vhci_hcd: dump_port_status_diff:150: 
[   19.716534] vhci_hcd: vhci_hub_control:604:  bye
[   19.716986] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 2
[   19.717515] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.718046] vhci_hcd: vhci_hub_control:596: port 1
[   19.718404] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.718992] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.719380] vhci_hcd: dump_port_status_diff:150: 
[   19.719730] vhci_hcd: vhci_hub_control:604:  bye
[   19.720232] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 3
[   19.720743] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.721278] vhci_hcd: vhci_hub_control:596: port 2
[   19.721645] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.722234] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.722628] vhci_hcd: dump_port_status_diff:150: 
[   19.722975] vhci_hcd: vhci_hub_control:604:  bye
[   19.723428] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 4
[   19.723945] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.724489] vhci_hcd: vhci_hub_control:596: port 3
[   19.724842] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.725463] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.725857] vhci_hcd: dump_port_status_diff:150: 
[   19.726204] vhci_hcd: vhci_hub_control:604:  bye
[   19.726660] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 5
[   19.727164] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.727702] vhci_hcd: vhci_hub_control:596: port 4
[   19.728056] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.728651] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.729040] vhci_hcd: dump_port_status_diff:150: 
[   19.729386] vhci_hcd: vhci_hub_control:604:  bye
[   19.729849] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 6
[   19.730439] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.730982] vhci_hcd: vhci_hub_control:596: port 5
[   19.731334] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.731923] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.732310] vhci_hcd: dump_port_status_diff:150: 
[   19.732660] vhci_hcd: vhci_hub_control:604:  bye
[   19.733154] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 7
[   19.733682] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.734216] vhci_hcd: vhci_hub_control:596: port 6
[   19.734575] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.735397] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.735795] vhci_hcd: dump_port_status_diff:150: 
[   19.736142] vhci_hcd: vhci_hub_control:604:  bye
[   19.736603] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 8 wIndex 8
[   19.737108] vhci_hcd: vhci_hub_control:518:  SetPortFeature: USB_PORT_FEAT_POWER
[   19.737671] vhci_hcd: vhci_hub_control:596: port 7
[   19.738026] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000000 -> 00000200
[   19.738618] vhci_hcd: dump_port_status_diff:142:  +POWER
[   19.739005] vhci_hcd: dump_port_status_diff:150: 
[   19.739350] vhci_hcd: vhci_hub_control:604:  bye
[   19.740643] vhci_hcd: vhci_hcd_probe:1323: bye
[   19.741870] usbcore: registered new device driver usbip-host
[   19.744467] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   19.746362] serio: i8042 KBD port at 0x60,0x64 irq 1
[   19.746850] serio: i8042 AUX port at 0x60,0x64 irq 12
[   19.748584] parport0: cannot grant exclusive access for device parkbd
[   19.750567] mousedev: PS/2 mouse device common for all mice
[   19.751571] evbug: Connected device: input0 (Power Button at LNXPWRBN/button/input0)
[   19.753993] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[   19.758123] usbcore: registered new interface driver bcm5974
[   19.758755] evbug: Connected device: input1 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[   19.760587] usbcore: registered new interface driver synaptics_usb
[   19.763612] usbcore: registered new interface driver xpad
[   19.764294] usbcore: registered new interface driver usb_acecad
[   19.764864] usbcore: registered new interface driver aiptek
[   19.765389] usbcore: registered new interface driver gtco
[   19.765913] usbcore: registered new interface driver hanwang
[   19.766455] usbcore: registered new interface driver kbtab
[   19.768652] usbcore: registered new interface driver pegasus_notetaker
[   19.770807] rtc_cmos 00:00: RTC can wake from S4
[   19.772319] rtc_cmos 00:00: registered as rtc0
[   19.772674] rtc_cmos 00:00: nvmem registration failed
[   19.773046] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram, hpet irqs
[   19.778198] i2c /dev entries driver
[   19.779104] usbcore: registered new interface driver RobotFuzz Open Source InterFace, OSIF
[   19.779838] usbcore: registered new interface driver i2c-tiny-usb
[   19.785534] usbcore: registered new interface driver ati_remote
[   19.786092] usbcore: registered new interface driver imon
[   19.786624] usbcore: registered new interface driver redrat3
[   19.787156] usbcore: registered new interface driver streamzap
[   19.787739] Registered IR keymap rc-empty
[   19.788393] rc rc0: rc-core loopback device as /devices/virtual/rc/rc0
[   19.789306] input: rc-core loopback device as /devices/virtual/rc/rc0/input3
[   19.790385] evbug: Connected device: input3 (rc-core loopback device at rc-core/virtual)
[   19.791362] rc rc0: lirc_dev: driver rc-loopback registered at minor = 0
[   19.792190] usbcore: registered new interface driver igorplugusb
[   19.792762] usbcore: registered new interface driver ttusbir
[   19.793923] serial_ir serial_ir.0: port 03f8 already in use
[   19.794341] serial_ir serial_ir.0: use 'setserial /dev/ttySX uart none'
[   19.794824] serial_ir serial_ir.0: or compile the serial port driver as module and
[   19.795371] serial_ir serial_ir.0: make sure this module is loaded first
[   19.795960] serial_ir: probe of serial_ir.0 failed with error -16
[   19.796422] pps_parport: parallel port PPS client
[   19.796991] parport0: cannot grant exclusive access for device pps_parport
[   19.797499] pps_parport: couldn't register with parport0
[   19.797900] Driver for 1-wire Dallas network protocol.
[   19.798690] usbcore: registered new interface driver DS9490R
[   19.799232] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   19.799895] w1_f0d_init()
[   19.800392] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 1
[   19.800945] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 1
[   19.801421] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.801879] vhci_hcd: vhci_hub_control:596: port 0
[   19.802230] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.802854] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.803244] vhci_hcd: dump_port_status_diff:150: 
[   19.803596] vhci_hcd: vhci_hub_control:604:  bye
[   19.804078] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 2
[   19.804588] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 2
[   19.805033] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.805496] vhci_hcd: vhci_hub_control:596: port 1
[   19.805848] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.806436] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.806822] vhci_hcd: dump_port_status_diff:150: 
[   19.807167] vhci_hcd: vhci_hub_control:604:  bye
[   19.807582] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 3
[   19.808085] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 3
[   19.808530] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.808992] vhci_hcd: vhci_hub_control:596: port 2
[   19.809345] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.809932] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.810120] vhci_hcd: dump_port_status_diff:150: 
[   19.810120] vhci_hcd: vhci_hub_control:604:  bye
[   19.815646] f71882fg: Not a Fintek device
[   19.815990] f71882fg: Not a Fintek device
[   19.822137] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 4
[   19.822655] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 4
[   19.823095] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.823556] vhci_hcd: vhci_hub_control:596: port 3
[   19.823907] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.824494] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.824881] vhci_hcd: dump_port_status_diff:150: 
[   19.825225] vhci_hcd: vhci_hub_control:604:  bye
[   19.825645] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 5
[   19.826146] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 5
[   19.826590] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.827059] vhci_hcd: vhci_hub_control:596: port 4
[   19.827415] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.827996] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.828382] vhci_hcd: dump_port_status_diff:150: 
[   19.828729] vhci_hcd: vhci_hub_control:604:  bye
[   19.829639] pc87360: PC8736x not detected, module not inserted
[   19.830316] sch56xx_common: Unsupported device id: 0xff
[   19.830735] sch56xx_common: Unsupported device id: 0xff
[   19.833962] intel_powerclamp: CPU does not support MWAIT
[   19.834616] usbcore: registered new interface driver pcwd_usb
[   19.835150] advantechwdt: WDT driver for Advantech single board computer initialising
[   19.836732] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 6
[   19.837240] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 6
[   19.837687] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.838148] vhci_hcd: vhci_hub_control:596: port 5
[   19.838506] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.839088] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.839481] vhci_hcd: dump_port_status_diff:150: 
[   19.839827] vhci_hcd: vhci_hub_control:604:  bye
[   19.840317] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 7
[   19.840828] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 7
[   19.841268] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.841728] vhci_hcd: vhci_hub_control:596: port 6
[   19.842078] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.842663] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.843048] vhci_hcd: dump_port_status_diff:150: 
[   19.843391] vhci_hcd: vhci_hub_control:604:  bye
[   19.843837] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[   19.844493] ib700wdt: WDT driver for IB700 single board computer initialising
[   19.845591] ib700wdt: START method I/O 443 is not available
[   19.846081] ib700wdt: probe of ib700wdt failed with error -5
[   19.846789] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[   19.847386] wafer5823wdt: I/O address 0x0443 already in use
[   19.847884] it87_wdt: no device
[   19.848238] pc87413_wdt: Version 1.1 at io 0x2E
[   19.848598] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[   19.849100] sbc60xxwdt: I/O address 0x0443 already in use
[   19.849519] cpu5wdt: misc_register failed
[   19.849860] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[   19.850583] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 8
[   19.851090] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 8
[   19.851536] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 100 0
[   19.851996] vhci_hcd: vhci_hub_control:596: port 7
[   19.852349] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000100 -> 00000100
[   19.852937] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.853327] vhci_hcd: dump_port_status_diff:150: 
[   19.853677] vhci_hcd: vhci_hub_control:604:  bye
[   19.854128] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 1
[   19.854638] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 1
[   19.855079] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.855540] vhci_hcd: vhci_hub_control:596: port 0
[   19.855894] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.856485] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.856874] vhci_hcd: dump_port_status_diff:150: 
[   19.857221] vhci_hcd: vhci_hub_control:604:  bye
[   19.858741] smsc37b787_wdt: Unable to register miscdev on minor 130
[   19.859303] w83877f_wdt: I/O address 0x0443 already in use
[   19.859730] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[   19.860315] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 2
[   19.860825] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 2
[   19.861269] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.861741] vhci_hcd: vhci_hub_control:596: port 1
[   19.862095] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.862685] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.863074] vhci_hcd: dump_port_status_diff:150: 
[   19.863423] vhci_hcd: vhci_hub_control:604:  bye
[   19.864625] sdhci: Secure Digital Host Controller Interface driver
[   19.865086] sdhci: Copyright(c) Pierre Ossman
[   19.865741] VUB300 Driver rom wait states = 1C irqpoll timeout = 0400
[   19.866031] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 3
[   19.867000] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 3
[   19.867451] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.867911] vhci_hcd: vhci_hub_control:596: port 2
[   19.868264] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.868851] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.869239] vhci_hcd: dump_port_status_diff:150: 
[   19.869588] vhci_hcd: vhci_hub_control:604:  bye
[   19.870736] usbcore: registered new interface driver vub300
[   19.871395] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 4
[   19.871907] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 4
[   19.872347] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.872809] vhci_hcd: vhci_hub_control:596: port 3
[   19.873161] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.873767] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.874156] vhci_hcd: dump_port_status_diff:150: 
[   19.874508] vhci_hcd: vhci_hub_control:604:  bye
[   19.886159] NET: Registered protocol family 4
[   19.887396] comedi: version 0.7.76 - http://www.comedi.org
[   19.888864] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 5
[   19.889375] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 5
[   19.889824] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.890023] vhci_hcd: vhci_hub_control:596: port 4
[   19.890023] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.890023] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.890023] vhci_hcd: dump_port_status_diff:150: 
[   19.890023] vhci_hcd: vhci_hub_control:604:  bye
[   19.892491] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 6
[   19.892996] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 6
[   19.893441] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.893899] vhci_hcd: vhci_hub_control:596: port 5
[   19.894250] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.894835] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.895221] vhci_hcd: dump_port_status_diff:150: 
[   19.895569] vhci_hcd: vhci_hub_control:604:  bye
[   19.895976] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 7
[   19.896481] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 7
[   19.896921] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.897379] vhci_hcd: vhci_hub_control:596: port 6
[   19.897733] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.898320] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.898710] vhci_hcd: dump_port_status_diff:150: 
[   19.899056] vhci_hcd: vhci_hub_control:604:  bye
[   19.899630] comedi comedi0: comedi_test: 1000000 microvolt, 100000 microsecond waveform attached
[   19.900434] vhci_hcd: vhci_hub_control:335: typeReq a300 wValue 0 wIndex 8
[   19.900940] vhci_hcd: vhci_hub_control:415:  GetPortStatus port 8
[   19.901381] vhci_hcd: vhci_hub_control:470:  GetPortStatus bye 200 0
[   19.901842] vhci_hcd: vhci_hub_control:596: port 7
[   19.902193] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 00000200
[   19.902777] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.903162] vhci_hcd: dump_port_status_diff:150: 
[   19.903509] vhci_hcd: vhci_hub_control:604:  bye
[   19.909346] usb usb1: vhci_bus_suspend
[   19.909817] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 1
[   19.910416] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.910934] vhci_hcd: vhci_hub_control:596: port 0
[   19.911287] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.911874] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.912261] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.912638] vhci_hcd: dump_port_status_diff:150: 
[   19.912983] vhci_hcd: vhci_hub_control:604:  bye
[   19.913498] comedi comedi0: driver 'comedi_test' has successfully auto-configured 'comedi_test'.
[   19.916249] LNetError: 1:0:(module.c:546:libcfs_init()) misc_register: error -16
[   19.917200] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 2
[   19.917717] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.918196] vhci_hcd: vhci_hub_control:596: port 1
[   19.918551] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.919134] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.919523] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.919897] vhci_hcd: dump_port_status_diff:150: 
[   19.920240] vhci_hcd: vhci_hub_control:604:  bye
[   19.920815] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 3
[   19.921326] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.921806] vhci_hcd: vhci_hub_control:596: port 2
[   19.922157] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.922743] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.923131] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.923510] vhci_hcd: dump_port_status_diff:150: 
[   19.923857] vhci_hcd: vhci_hub_control:604:  bye
[   19.924272] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 4
[   19.924782] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.925261] vhci_hcd: vhci_hub_control:596: port 3
[   19.925617] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.926204] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.926595] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.926972] vhci_hcd: dump_port_status_diff:150: 
[   19.927319] vhci_hcd: vhci_hub_control:604:  bye
[   19.927733] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 5
[   19.928244] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.928732] vhci_hcd: vhci_hub_control:596: port 4
[   19.929083] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.929667] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.930055] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.930428] vhci_hcd: dump_port_status_diff:150: 
[   19.930597] vhci_hcd: vhci_hub_control:604:  bye
[   19.931289] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 6
[   19.931803] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.932280] vhci_hcd: vhci_hub_control:596: port 5
[   19.932633] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.933216] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.933606] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.933980] vhci_hcd: dump_port_status_diff:150: 
[   19.934323] vhci_hcd: vhci_hub_control:604:  bye
[   19.934738] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 7
[   19.935244] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.935723] vhci_hcd: vhci_hub_control:596: port 6
[   19.936073] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.936659] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.937046] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.937423] vhci_hcd: dump_port_status_diff:150: 
[   19.937768] vhci_hcd: vhci_hub_control:604:  bye
[   19.938179] vhci_hcd: vhci_hub_control:335: typeReq 2303 wValue 1b wIndex 8
[   19.938697] vhci_hcd: vhci_hub_control:556:  SetPortFeature: default 27
[   19.939177] vhci_hcd: vhci_hub_control:596: port 7
[   19.939540] vhci_hcd: dump_port_status_diff:128: status prev -> new: 00000200 -> 08000200
[   19.940123] vhci_hcd: dump_port_status_diff:142:   POWER
[   19.940511] vhci_hcd: dump_port_status_diff:142:  +R27
[   19.940884] vhci_hcd: dump_port_status_diff:150: 
[   19.941126] vhci_hcd: vhci_hub_control:604:  bye
[   19.941703] usb usb2: vhci_bus_suspend
[   20.967090] ==================================================================
[   20.968082] BUG: KASAN: null-ptr-deref in cfs_trace_lock_tcd+0x25/0xeb
[   20.968856] Read of size 2 at addr 00000000000000a4 by task swapper/1
[   20.969604] 
[   20.969817] CPU: 0 PID: 1 Comm: swapper Tainted: G                T 4.17.0-rc1 #1
[   20.970046] Call Trace:
[   20.970046]  dump_stack+0x2e/0x3e
[   20.970046]  kasan_report+0x2f3/0x360
[   20.970046]  __asan_load2+0x31/0xe4
[   20.970046]  cfs_trace_lock_tcd+0x25/0xeb
[   20.970046]  libcfs_debug_vmsg2+0x18d/0xd26
[   20.970046]  ? cfs_trace_get_tage+0x957/0x957
[   20.970046]  ? mark_lock+0xe9/0xa16
[   20.970046]  ? fput+0x111/0x11f
[   20.970046]  ? lnet_ipif_enumerate+0x541/0x588
[   20.970046]  ? kasan_slab_free+0x15/0x1e
[   20.970046]  ? kfree+0x215/0x2cb
[   20.970046]  libcfs_debug_msg+0x9b/0xc5
[   20.970046]  ? libcfs_debug_vmsg2+0xd26/0xd26
[   20.970046]  ksocknal_startup+0x341/0x1228
[   20.970046]  ? __asan_loadN+0x1d/0x26
[   20.970046]  ? pvclock_clocksource_read+0x162/0x296
[   20.970046]  ? ksocknal_base_startup+0xbae/0xbae
[   20.970046]  ? pvclock_read_flags+0x5d/0x5d
[   20.970046]  ? kasan_check_read+0x1f/0x28
[   20.970046]  ? kvm_clock_read+0x24/0x3a
[   20.970046]  ? kasan_check_write+0x22/0x2b
[   20.970046]  ? sched_clock_local+0xc8/0xfa
[   20.970046]  ? reacquire_held_locks+0x1cd/0x1cd
[   20.970046]  ? cfs_percpt_lock+0xdf/0x1ad
[   20.970046]  ? do_raw_spin_unlock+0x100/0x10d
[   20.970046]  ? _raw_spin_unlock+0x37/0x4e
[   20.970046]  ? cfs_percpt_unlock+0x66/0x13a
[   20.970046]  lnet_startup_lndni+0x62a/0xf84
[   20.970046]  ? lnet_shutdown_lndni+0xcc/0xcc
[   20.970046]  ? __schedule+0xbff/0xc7f
[   20.970046]  ? firmware_map_remove+0x265/0x265
[   20.970046]  ? kasan_check_read+0x1f/0x28
[   20.970046]  LNetNIInit+0x5d4/0xbf8
[   20.970046]  ? lnet_lib_exit+0x147/0x147
[   20.970046]  ? del_timer+0x6d/0xf8
[   20.970046]  ? add_timer_on+0x32b/0x32b
[   20.970046]  ? _raw_spin_unlock_irqrestore+0x74/0x9e
[   20.970046]  ? trace_hardirqs_on_caller+0x2c8/0x33d
[   20.970046]  ? schedule_timeout+0x82b/0x8a7
[   20.970046]  ? kasan_kmalloc+0x1c5/0x1e1
[   20.970046]  ? console_conditional_schedule+0x44/0x44
[   20.970046]  ? do_one_initcall+0x158/0x3ac
[   20.970046]  ? kernel_init_freeable+0x2b8/0x434
[   20.970046]  ? kernel_init+0x13/0x1ae
[   20.970046]  ? ret_from_fork+0x24/0x30
[   20.970046]  ? __check_object_size+0x8d7/0xa08
[   20.970046]  ? usercopy_abort+0xb7/0xb7
[   20.970046]  ? __lock_is_held+0x39/0xbb
[   20.970046]  ? mark_held_locks+0x2c/0xb2
[   20.970046]  ? debug_check_no_locks_freed+0x237/0x25f
[   20.970046]  ? collect_expired_timers+0x23b/0x23b
[   20.970046]  ? lockdep_init_map+0x10/0x19
[   20.970046]  srpc_startup+0x136/0x352
[   20.970046]  ? srpc_shutdown+0x1f0/0x1f0
[   20.970046]  ? kvmalloc_node+0x6b/0xb6
[   20.970046]  lnet_selftest_init+0x33a/0x4f5
[   20.970046]  ? lnet_selftest_exit+0x13e/0x13e
[   20.970046]  ? lustre_insert_debugfs+0x150/0x150
[   20.970046]  ? lnet_init+0x1df/0x1df
[   20.970046]  ? lnet_selftest_exit+0x13e/0x13e
[   20.970046]  do_one_initcall+0x158/0x3ac
[   20.970046]  ? start_kernel+0xbf5/0xbf5
[   20.970046]  kernel_init_freeable+0x2b8/0x434
[   20.970046]  ? rest_init+0x1d2/0x1d2
[   20.970046]  kernel_init+0x13/0x1ae
[   20.970046]  ? rest_init+0x1d2/0x1d2
[   20.970046]  ret_from_fork+0x24/0x30
[   20.970046] ==================================================================
[   20.970046] Disabling lock debugging due to kernel taint
[   21.007543] BUG: unable to handle kernel NULL pointer dereference at 00000000000000a4
[   21.009103] PGD 0 P4D 0 
[   21.009432] Oops: 0000 [#1] DEBUG_PAGEALLOC KASAN PTI
[   21.010063] CPU: 0 PID: 1 Comm: swapper Tainted: G    B           T 4.17.0-rc1 #1
[   21.011023] RIP: 0010:cfs_trace_lock_tcd+0x25/0xeb
[   21.011650] RSP: 0000:ffff880014c87380 EFLAGS: 00010202
[   21.012299] RAX: 0000000000000202 RBX: 0000000000000000 RCX: ffffffff8119215d
[   21.013197] RDX: dffffc0000000000 RSI: 0000000000000003 RDI: 0000000000000202
[   21.014074] RBP: ffff880014c87398 R08: 0000000000000001 R09: 0000000000000001
[   21.014940] R10: ffffed0002990e5a R11: 0000000000000001 R12: 00000000000000a4
[   21.015818] R13: 0000000000000000 R14: ffff88001402d680 R15: ffff880014c87970
[   21.016634] FS:  0000000000000000(0000) GS:ffffffff842e9000(0000) knlGS:0000000000000000
[   21.016892] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   21.016892] CR2: 00000000000000a4 CR3: 0000000004226000 CR4: 00000000000006f0
[   21.016892] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   21.016892] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   21.016892] Call Trace:
[   21.016892]  libcfs_debug_vmsg2+0x18d/0xd26
[   21.016892]  ? cfs_trace_get_tage+0x957/0x957
[   21.016892]  ? mark_lock+0xe9/0xa16
[   21.016892]  ? fput+0x111/0x11f
[   21.016892]  ? lnet_ipif_enumerate+0x541/0x588
[   21.016892]  ? kasan_slab_free+0x15/0x1e
[   21.016892]  ? kfree+0x215/0x2cb
[   21.016892]  libcfs_debug_msg+0x9b/0xc5
[   21.016892]  ? libcfs_debug_vmsg2+0xd26/0xd26
[   21.016892]  ksocknal_startup+0x341/0x1228
[   21.016892]  ? __asan_loadN+0x1d/0x26
[   21.016892]  ? pvclock_clocksource_read+0x162/0x296
[   21.016892]  ? ksocknal_base_startup+0xbae/0xbae
[   21.016892]  ? pvclock_read_flags+0x5d/0x5d
[   21.016892]  ? kasan_check_read+0x1f/0x28
[   21.016892]  ? kvm_clock_read+0x24/0x3a
[   21.016892]  ? kasan_check_write+0x22/0x2b
[   21.016892]  ? sched_clock_local+0xc8/0xfa
[   21.016892]  ? reacquire_held_locks+0x1cd/0x1cd
[   21.016892]  ? cfs_percpt_lock+0xdf/0x1ad
[   21.016892]  ? do_raw_spin_unlock+0x100/0x10d
[   21.016892]  ? _raw_spin_unlock+0x37/0x4e
[   21.016892]  ? cfs_percpt_unlock+0x66/0x13a
[   21.016892]  lnet_startup_lndni+0x62a/0xf84
[   21.016892]  ? lnet_shutdown_lndni+0xcc/0xcc
[   21.016892]  ? __schedule+0xbff/0xc7f
[   21.016892]  ? firmware_map_remove+0x265/0x265
[   21.016892]  ? kasan_check_read+0x1f/0x28
[   21.016892]  LNetNIInit+0x5d4/0xbf8
[   21.016892]  ? lnet_lib_exit+0x147/0x147
[   21.016892]  ? del_timer+0x6d/0xf8
[   21.016892]  ? add_timer_on+0x32b/0x32b
[   21.016892]  ? _raw_spin_unlock_irqrestore+0x74/0x9e
[   21.016892]  ? trace_hardirqs_on_caller+0x2c8/0x33d
[   21.016892]  ? schedule_timeout+0x82b/0x8a7
[   21.016892]  ? kasan_kmalloc+0x1c5/0x1e1
[   21.016892]  ? console_conditional_schedule+0x44/0x44
[   21.016892]  ? do_one_initcall+0x158/0x3ac
[   21.016892]  ? kernel_init_freeable+0x2b8/0x434
[   21.016892]  ? kernel_init+0x13/0x1ae
[   21.016892]  ? ret_from_fork+0x24/0x30
[   21.016892]  ? __check_object_size+0x8d7/0xa08
[   21.016892]  ? usercopy_abort+0xb7/0xb7
[   21.016892]  ? __lock_is_held+0x39/0xbb
[   21.016892]  ? mark_held_locks+0x2c/0xb2
[   21.016892]  ? debug_check_no_locks_freed+0x237/0x25f
[   21.016892]  ? collect_expired_timers+0x23b/0x23b
[   21.016892]  ? lockdep_init_map+0x10/0x19
[   21.016892]  srpc_startup+0x136/0x352
[   21.016892]  ? srpc_shutdown+0x1f0/0x1f0
[   21.016892]  ? kvmalloc_node+0x6b/0xb6
[   21.016892]  lnet_selftest_init+0x33a/0x4f5
[   21.016892]  ? lnet_selftest_exit+0x13e/0x13e
[   21.016892]  ? lustre_insert_debugfs+0x150/0x150
[   21.016892]  ? lnet_init+0x1df/0x1df
[   21.016892]  ? lnet_selftest_exit+0x13e/0x13e
[   21.016892]  do_one_initcall+0x158/0x3ac
[   21.016892]  ? start_kernel+0xbf5/0xbf5
[   21.016892]  kernel_init_freeable+0x2b8/0x434
[   21.016892]  ? rest_init+0x1d2/0x1d2
[   21.016892]  kernel_init+0x13/0x1ae
[   21.016892]  ? rest_init+0x1d2/0x1d2
[   21.016892]  ret_from_fork+0x24/0x30
[   21.016892] Code: d4 05 31 c0 5d c3 55 48 ff 05 2b bf d4 05 48 89 e5 41 55 41 54 4c 8d a7 a4 00 00 00 53 48 89 fb 41 89 f5 4c 89 e7 e8 16 a9 18 ff <66> 83 bb a4 00 00 00 02 76 24 48 c7 c6 20 37 75 85 48 c7 c7 40 
[   21.016892] RIP: cfs_trace_lock_tcd+0x25/0xeb RSP: ffff880014c87380
[   21.016892] CR2: 00000000000000a4
[   21.016892] ---[ end trace be7ae81fe247d9ae ]---
[   21.016892] Kernel panic - not syncing: Fatal exception
[   21.016892] Kernel Offset: disabled

Elapsed time: 30

#!/bin/bash

# To reproduce,
# 1) save job-script and this script (both are attached in 0day report email)
# 2) run this script with your compiled kernel and optional env $INSTALL_MOD_PATH

kernel=$1

initrds=(
	/osimage/openwrt/openwrt-i386-2016-03-16.cgz
	/lkp/lkp/lkp-i386.cgz
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
	ip=::::vm-lkp-hsw01-openwrt-ia32-7::dhcp
	root=/dev/ram0
	user=lkp
	job=/job-script
	ARCH=x86_64
	kconfig=x86_64-randconfig-ws0-03101549
	branch=linus/master
	commit=60cc43fc888428bb2f18f08997432d426a243338
	BOOT_IMAGE=/pkg/linux/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
	max_uptime=600
	RESULT_ROOT=/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0
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
# Linux/x86_64 4.17.0-rc1 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
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
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CONSTRUCTORS=y
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
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
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
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TINY_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_RDMA=y
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
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
CONFIG_SYSCTL_SYSCALL=y
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_MEMBARRIER is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
# CONFIG_BPF_SYSCALL is not set
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
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_SLUB_DEBUG=y
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_MERGE_DEFAULT is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
CONFIG_SYSTEM_DATA_VERIFICATION=y
# CONFIG_PROFILING is not set
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
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
CONFIG_GCC_PLUGIN_RANDSTRUCT=y
# CONFIG_GCC_PLUGIN_RANDSTRUCT_PERFORMANCE is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
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
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_X2APIC=y
# CONFIG_X86_MPPARSE is not set
CONFIG_GOLDFISH=y
# CONFIG_RETPOLINE is not set
# CONFIG_INTEL_RDT is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_XEN=y
# CONFIG_XEN_PV is not set
CONFIG_XEN_PVHVM=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCELOG_LEGACY is not set
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_X86_16BIT is not set
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT is not set
CONFIG_ARCH_USE_MEMREMAP_PROT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
# CONFIG_ARCH_MEMORY_PROBE is not set
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
# CONFIG_X86_PAT is not set
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_X86_INTEL_UMIP is not set
# CONFIG_X86_INTEL_MPX is not set
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
# CONFIG_KEXEC_VERIFY_SIG is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_TAD is not set
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#

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
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_XEN_PCIDEV_FRONTEND=y
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
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# CONFIG_ISA_BUS is not set
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
# CONFIG_IP_MULTIPLE_TABLES is not set
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
CONFIG_NET_FOU_IP_TUNNELS=y
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
# CONFIG_TCP_CONG_BIC is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
# CONFIG_TCP_CONG_HYBLA is not set
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_NV=y
# CONFIG_TCP_CONG_SCALABLE is not set
CONFIG_TCP_CONG_LP=y
# CONFIG_TCP_CONG_VENO is not set
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_TCP_CONG_DCTCP is not set
CONFIG_TCP_CONG_CDG=y
CONFIG_TCP_CONG_BBR=y
# CONFIG_DEFAULT_CUBIC is not set
CONFIG_DEFAULT_HTCP=y
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_CDG is not set
# CONFIG_DEFAULT_BBR is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="htcp"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_BEET is not set
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_FOU=y
CONFIG_IPV6_FOU_TUNNEL=y
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
CONFIG_L2TP_V3=y
# CONFIG_L2TP_IP is not set
# CONFIG_L2TP_ETH is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=y
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_CBS=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_FQ=y
CONFIG_NET_SCH_HHF=y
# CONFIG_NET_SCH_PIE is not set
# CONFIG_NET_SCH_PLUG is not set
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
# CONFIG_NET_CLS_TCINDEX is not set
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
# CONFIG_NET_CLS_U32 is not set
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
# CONFIG_NET_CLS_FLOW is not set
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=y
# CONFIG_NET_CLS_FLOWER is not set
# CONFIG_NET_CLS_MATCHALL is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
# CONFIG_BATMAN_ADV_BATMAN_V is not set
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_MCAST is not set
CONFIG_BATMAN_ADV_DEBUGFS=y
CONFIG_BATMAN_ADV_DEBUG=y
CONFIG_OPENVSWITCH=y
# CONFIG_OPENVSWITCH_VXLAN is not set
# CONFIG_OPENVSWITCH_GENEVE is not set
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_DIAG=y
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=y
CONFIG_MPLS_IPTUNNEL=y
CONFIG_NET_NSH=y
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
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
# CONFIG_BPQETHER is not set
# CONFIG_BAYCOM_SER_FDX is not set
# CONFIG_BAYCOM_SER_HDX is not set
# CONFIG_BAYCOM_PAR is not set
CONFIG_YAM=y
# CONFIG_CAN is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_IPV6 is not set
CONFIG_AF_RXRPC_INJECT_LOSS=y
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=y
# CONFIG_AF_KCM is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
# CONFIG_CFG80211_DEFAULT_PS is not set
CONFIG_CFG80211_DEBUGFS=y
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_MAC80211 is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
CONFIG_CEPH_LIB_PRETTYDEBUG=y
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
# CONFIG_NFC_NCI is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_TRF7970A=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PORT100=y
CONFIG_NFC_PN533=y
CONFIG_NFC_PN533_USB=y
CONFIG_NFC_PN533_I2C=y
CONFIG_NFC_ST95HF=y
# CONFIG_PSAMPLE is not set
CONFIG_NET_IFE=y
CONFIG_LWTUNNEL=y
# CONFIG_LWTUNNEL_BPF is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
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
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
CONFIG_MTD_CFI_NOSWAP=y
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
# CONFIG_MTD_MAP_BANK_WIDTH_2 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_4 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
CONFIG_MTD_MAP_BANK_WIDTH_16=y
CONFIG_MTD_MAP_BANK_WIDTH_32=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
CONFIG_MTD_CFI_I8=y
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
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
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
# CONFIG_MTD_PCMCIA is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_M25P80 is not set
# CONFIG_MTD_MCHP23K256 is not set
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_ONENAND is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
# CONFIG_MTD_NAND_DOCG4 is not set
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_MT81xx_NOR=y
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_SPI_INTEL_SPI=y
# CONFIG_SPI_INTEL_SPI_PCI is not set
CONFIG_SPI_INTEL_SPI_PLATFORM=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_PC_PCMCIA is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# NVME Support
#

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
# CONFIG_AD525X_DPOT_SPI is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
CONFIG_SRAM=y
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
# CONFIG_EEPROM_IDT_89HPESX is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y
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
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

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
# CONFIG_GENWQE is not set
CONFIG_ECHO=y
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
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
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
CONFIG_EQUALIZER=y
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
# CONFIG_NET_TEAM_MODE_ROUNDROBIN is not set
CONFIG_NET_TEAM_MODE_RANDOM=y
# CONFIG_NET_TEAM_MODE_ACTIVEBACKUP is not set
CONFIG_NET_TEAM_MODE_LOADBALANCE=y
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_VXLAN=y
CONFIG_GENEVE=y
CONFIG_GTP=y
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
CONFIG_TUN=y
CONFIG_TAP=y
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
# CONFIG_ARCNET_RAW is not set
# CONFIG_ARCNET_CAP is not set
CONFIG_ARCNET_COM90xx=y
# CONFIG_ARCNET_COM90xxIO is not set
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
# CONFIG_ARCNET_COM20020_PCI is not set
CONFIG_ARCNET_COM20020_CS=y

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
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
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
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
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
# CONFIG_MDIO_BITBANG is not set
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=y
CONFIG_AQUANTIA_PHY=y
CONFIG_AT803X_PHY=y
CONFIG_BCM7XXX_PHY=y
CONFIG_BCM87XX_PHY=y
CONFIG_BCM_NET_PHYLIB=y
# CONFIG_BROADCOM_PHY is not set
CONFIG_CICADA_PHY=y
# CONFIG_CORTINA_PHY is not set
# CONFIG_DAVICOM_PHY is not set
CONFIG_DP83822_PHY=y
CONFIG_DP83848_PHY=y
CONFIG_DP83867_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_INTEL_XWAY_PHY=y
CONFIG_LSI_ET1011C_PHY=y
# CONFIG_LXT_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_MARVELL_10G_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_MICROCHIP_PHY=y
CONFIG_MICROSEMI_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_RENESAS_PHY=y
# CONFIG_ROCKCHIP_PHY is not set
CONFIG_SMSC_PHY=y
CONFIG_STE10XP=y
CONFIG_TERANETICS_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_XILINX_GMII2RGMII=y
CONFIG_MICREL_KS8995MA=y
CONFIG_PLIP=y
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
# CONFIG_USB_PEGASUS is not set
CONFIG_USB_RTL8150=y
CONFIG_USB_RTL8152=y
CONFIG_USB_LAN78XX=y
# CONFIG_USB_USBNET is not set
CONFIG_USB_IPHETH=y
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_HDLC is not set
# CONFIG_DLCI is not set
# CONFIG_LAPBETHER is not set
# CONFIG_X25_ASY is not set
# CONFIG_SBNI is not set
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
CONFIG_NETDEVSIM=y
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADC=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_SAMSUNG is not set
CONFIG_KEYBOARD_GOLDFISH_EVENTS=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_KEYBOARD_CROS_EC=y
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
CONFIG_MOUSE_BCM5974=y
# CONFIG_MOUSE_CYAPA is not set
CONFIG_MOUSE_ELAN_I2C=y
CONFIG_MOUSE_ELAN_I2C_I2C=y
# CONFIG_MOUSE_ELAN_I2C_SMBUS is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_GPIO=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
CONFIG_MOUSE_SYNAPTICS_USB=y
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
# CONFIG_JOYSTICK_GF2K is not set
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
# CONFIG_JOYSTICK_IFORCE is not set
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_JOYSTICK_AS5011 is not set
# CONFIG_JOYSTICK_JOYDUMP is not set
CONFIG_JOYSTICK_XPAD=y
CONFIG_JOYSTICK_XPAD_FF=y
# CONFIG_JOYSTICK_XPAD_LEDS is not set
# CONFIG_JOYSTICK_WALKERA0701 is not set
CONFIG_JOYSTICK_PSXPAD_SPI=y
# CONFIG_JOYSTICK_PSXPAD_SPI_FF is not set
# CONFIG_JOYSTICK_PXRC is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_PEGASUS=y
CONFIG_TABLET_SERIAL_WACOM4=y
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SPI=y
CONFIG_RMI4_SMB=y
# CONFIG_RMI4_F03 is not set
# CONFIG_RMI4_F11 is not set
# CONFIG_RMI4_F12 is not set
# CONFIG_RMI4_F30 is not set
CONFIG_RMI4_F34=y
CONFIG_RMI4_F54=y
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
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
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=y
CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PROC_INTERFACE=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
# CONFIG_CARDMAN_4040 is not set
CONFIG_SCR24X=y
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_XEN=y
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
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
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
# CONFIG_I2C_KEMPLD is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=y
# CONFIG_I2C_CROS_EC_TUNNEL is not set
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_ROCKCHIP is not set
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_XCOMM is not set
CONFIG_SPI_XILINX=y
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
CONFIG_SPI_SLAVE=y
CONFIG_SPI_SLAVE_TIME=y
CONFIG_SPI_SLAVE_SYSTEM_CONTROL=y
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set
# CONFIG_PINCTRL is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
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
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_WINBOND is not set
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_BD9571MWV=y
CONFIG_GPIO_KEMPLD=y
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_TPS65086=y
CONFIG_GPIO_TPS65912=y
# CONFIG_GPIO_TWL4030 is not set
# CONFIG_GPIO_WM831X is not set
# CONFIG_GPIO_WM8350 is not set
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX3191X=y
# CONFIG_GPIO_MAX7301 is not set
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_PISOSR=y
# CONFIG_GPIO_XRA1403 is not set

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2405 is not set
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2805=y
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
# CONFIG_W1_SLAVE_DS2438 is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_DS28E17=y
CONFIG_POWER_AVS=y
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
CONFIG_CHARGER_SBS=y
CONFIG_MANAGER_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_CHARGER_DA9150 is not set
CONFIG_BATTERY_DA9150=y
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
# CONFIG_BATTERY_MAX1721X is not set
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_88PM860X=y
# CONFIG_BATTERY_RX51 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_LTC3651 is not set
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_MAX8998=y
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ASPEED is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_FTSTEUTATES=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
# CONFIG_SENSORS_IBMPEX is not set
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX31722=y
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MAX31790 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_ADCXX=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
# CONFIG_SENSORS_ADM1275 is not set
CONFIG_SENSORS_IBM_CFFPS=y
CONFIG_SENSORS_IR35221=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
CONFIG_SENSORS_LTC3815=y
CONFIG_SENSORS_MAX16064=y
# CONFIG_SENSORS_MAX20751 is not set
CONFIG_SENSORS_MAX31785=y
CONFIG_SENSORS_MAX34440=y
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_TPS53679=y
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_STTS751=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83773G is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_BANG_BANG=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
CONFIG_GENERIC_ADC_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
# CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED is not set
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9063_WATCHDOG=y
CONFIG_DA9062_WATCHDOG=y
CONFIG_MENF21BMC_WATCHDOG=y
# CONFIG_WDAT_WDT is not set
CONFIG_WM831X_WATCHDOG=y
CONFIG_WM8350_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
CONFIG_DW_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_RETU_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_EBC_C384_WDT is not set
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
CONFIG_SBC_EPX_C3_WATCHDOG=y
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
CONFIG_MEN_A21_WDT=y
# CONFIG_XEN_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_SFLASH is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_BD9571MWV=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_MFD_CROS_EC_SPI=y
CONFIG_MFD_CROS_EC_CHARDEV=y
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
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
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_TI_LMU=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS68470 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
# CONFIG_RAVE_SP_CORE is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_88PG86X is not set
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_ARIZONA_LDO1 is not set
CONFIG_REGULATOR_ARIZONA_MICSUPP=y
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_BCM590XX=y
# CONFIG_REGULATOR_BD9571MWV is not set
# CONFIG_REGULATOR_DA9062 is not set
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LM363X=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_LTC3676 is not set
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_QCOM_SPMI=y
CONFIG_REGULATOR_S2MPA01=y
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
# CONFIG_REGULATOR_SKY81452 is not set
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
# CONFIG_REGULATOR_TPS65023 is not set
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65090=y
# CONFIG_REGULATOR_TPS65132 is not set
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
CONFIG_LIRC=y
# CONFIG_RC_DECODERS is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=y
# CONFIG_IR_ENE is not set
CONFIG_IR_IMON=y
# CONFIG_IR_IMON_RAW is not set
# CONFIG_IR_MCEUSB is not set
# CONFIG_IR_ITE_CIR is not set
# CONFIG_IR_FINTEK is not set
# CONFIG_IR_NUVOTON is not set
CONFIG_IR_REDRAT3=y
CONFIG_IR_STREAMZAP=y
# CONFIG_IR_WINBOND_CIR is not set
CONFIG_IR_IGORPLUGUSB=y
# CONFIG_IR_IGUANA is not set
CONFIG_IR_TTUSBIR=y
CONFIG_RC_LOOPBACK=y
CONFIG_IR_SERIAL=y
# CONFIG_IR_SERIAL_TRANSMITTER is not set
# CONFIG_IR_SIR is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_SDR_SUPPORT=y
CONFIG_MEDIA_CEC_SUPPORT=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_V4L2_FWNODE=y

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_CEC_PLATFORM_DRIVERS is not set
# CONFIG_SDR_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_VIDEO_IR_I2C=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
# CONFIG_VIDEO_TVAUDIO is not set
CONFIG_VIDEO_TDA7432=y
CONFIG_VIDEO_TDA9840=y
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
# CONFIG_VIDEO_MSP3400 is not set
# CONFIG_VIDEO_CS3308 is not set
# CONFIG_VIDEO_CS5345 is not set
# CONFIG_VIDEO_CS53L32A is not set
# CONFIG_VIDEO_TLV320AIC23B is not set
CONFIG_VIDEO_UDA1342=y
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
CONFIG_VIDEO_VP27SMPX=y
# CONFIG_VIDEO_SONY_BTF_MPX is not set

#
# RDS decoders
#
# CONFIG_VIDEO_SAA6588 is not set

#
# Video decoders
#
CONFIG_VIDEO_ADV7183=y
CONFIG_VIDEO_BT819=y
# CONFIG_VIDEO_BT856 is not set
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
# CONFIG_VIDEO_TVP514X is not set
# CONFIG_VIDEO_TVP5150 is not set
CONFIG_VIDEO_TVP7002=y
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
# CONFIG_VIDEO_TW9906 is not set
CONFIG_VIDEO_TW9910=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
# CONFIG_VIDEO_SAA717X is not set
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
# CONFIG_VIDEO_ADV7343 is not set
CONFIG_VIDEO_ADV7393=y
# CONFIG_VIDEO_AK881X is not set
CONFIG_VIDEO_THS8200=y

#
# Camera sensor devices
#
# CONFIG_VIDEO_OV2640 is not set
CONFIG_VIDEO_OV2659=y
CONFIG_VIDEO_OV6650=y
CONFIG_VIDEO_OV5695=y
# CONFIG_VIDEO_OV772X is not set
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_OV7740=y
# CONFIG_VIDEO_VS6624 is not set
CONFIG_VIDEO_MT9M111=y
# CONFIG_VIDEO_MT9T112 is not set
CONFIG_VIDEO_MT9V011=y
CONFIG_VIDEO_SR030PC30=y

#
# Flash devices
#

#
# Video improvement chips
#
# CONFIG_VIDEO_UPD64031A is not set
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# SDR tuner chips
#
CONFIG_SDR_MAX2175=y

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
# CONFIG_VIDEO_M52790 is not set

#
# Sensors used on soc_camera driver
#

#
# SPI helper chips
#

#
# Media SPI Adapters
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA18250=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
# CONFIG_MEDIA_TUNER_TDA9887 is not set
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MSI001=y
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
# CONFIG_MEDIA_TUNER_MT2266 is not set
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=y
# CONFIG_MEDIA_TUNER_XC2028 is not set
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
# CONFIG_MEDIA_TUNER_MXL5005S is not set
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
# CONFIG_MEDIA_TUNER_FC0012 is not set
# CONFIG_MEDIA_TUNER_FC0013 is not set
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_M88RS6000T=y
CONFIG_MEDIA_TUNER_TUA9001=y
CONFIG_MEDIA_TUNER_SI2157=y
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=y
CONFIG_MEDIA_TUNER_MXL301RF=y
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set

#
# Customise DVB Frontends
#

#
# Tools to develop new frontends
#

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
# CONFIG_FB is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_AS3711=y
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
CONFIG_BACKLIGHT_ARCXCNN=y
CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_SEQ_DEVICE=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
# CONFIG_SND_OSSEMUL is not set
# CONFIG_SND_PCM_TIMER is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_PROC_FS is not set
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
# CONFIG_SND_SEQ_HRTIMER_DEFAULT is not set
CONFIG_SND_SEQ_MIDI_EVENT=y
CONFIG_SND_SEQ_MIDI=y
CONFIG_SND_SEQ_VIRMIDI=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=y
# CONFIG_SND_MPU401 is not set
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SE6X is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_SPI=y
# CONFIG_SND_USB is not set
# CONFIG_SND_PCMCIA is not set
CONFIG_SND_SOC=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=y
# CONFIG_SND_SOC_AMD_CZ_DA7219MX98357_MACH is not set
CONFIG_SND_SOC_AMD_CZ_RT5645_MACH=y
CONFIG_SND_ATMEL_SOC=y
# CONFIG_SND_DESIGNWARE_I2S is not set

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=y
# CONFIG_SND_SOC_FSL_SAI is not set
# CONFIG_SND_SOC_FSL_SSI is not set
CONFIG_SND_SOC_FSL_SPDIF=y
# CONFIG_SND_SOC_FSL_ESAI is not set
CONFIG_SND_SOC_IMX_AUDMUX=y
CONFIG_SND_I2S_HI6210_I2S=y
CONFIG_SND_SOC_IMG=y
CONFIG_SND_SOC_IMG_I2S_IN=y
CONFIG_SND_SOC_IMG_I2S_OUT=y
# CONFIG_SND_SOC_IMG_PARALLEL_OUT is not set
CONFIG_SND_SOC_IMG_SPDIF_IN=y
# CONFIG_SND_SOC_IMG_SPDIF_OUT is not set
CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC=y
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
CONFIG_SND_SOC_XTFPGA_I2S=y
# CONFIG_ZX_TDM is not set
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
# CONFIG_SND_SOC_AC97_CODEC is not set
CONFIG_SND_SOC_ADAU_UTILS=y
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_ADAU17X1=y
CONFIG_SND_SOC_ADAU1761=y
CONFIG_SND_SOC_ADAU1761_I2C=y
# CONFIG_SND_SOC_ADAU1761_SPI is not set
# CONFIG_SND_SOC_ADAU7002 is not set
CONFIG_SND_SOC_AK4104=y
# CONFIG_SND_SOC_AK4458 is not set
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4613=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK5386=y
# CONFIG_SND_SOC_AK5558 is not set
CONFIG_SND_SOC_ALC5623=y
# CONFIG_SND_SOC_BD28623 is not set
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_CS35L32=y
# CONFIG_SND_SOC_CS35L33 is not set
# CONFIG_SND_SOC_CS35L34 is not set
CONFIG_SND_SOC_CS35L35=y
CONFIG_SND_SOC_CS42L42=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L51_I2C=y
# CONFIG_SND_SOC_CS42L52 is not set
CONFIG_SND_SOC_CS42L56=y
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4265=y
# CONFIG_SND_SOC_CS4270 is not set
# CONFIG_SND_SOC_CS4271_I2C is not set
# CONFIG_SND_SOC_CS4271_SPI is not set
# CONFIG_SND_SOC_CS42XX8_I2C is not set
CONFIG_SND_SOC_CS43130=y
CONFIG_SND_SOC_CS4349=y
CONFIG_SND_SOC_CS53L30=y
CONFIG_SND_SOC_DIO2125=y
CONFIG_SND_SOC_ES7134=y
# CONFIG_SND_SOC_ES8316 is not set
CONFIG_SND_SOC_ES8328=y
# CONFIG_SND_SOC_ES8328_I2C is not set
CONFIG_SND_SOC_ES8328_SPI=y
# CONFIG_SND_SOC_GTM601 is not set
CONFIG_SND_SOC_INNO_RK3036=y
CONFIG_SND_SOC_MAX98504=y
# CONFIG_SND_SOC_MAX9867 is not set
CONFIG_SND_SOC_MAX98927=y
# CONFIG_SND_SOC_MAX98373 is not set
CONFIG_SND_SOC_MAX9860=y
# CONFIG_SND_SOC_MSM8916_WCD_ANALOG is not set
# CONFIG_SND_SOC_MSM8916_WCD_DIGITAL is not set
# CONFIG_SND_SOC_PCM1681 is not set
# CONFIG_SND_SOC_PCM1789_I2C is not set
CONFIG_SND_SOC_PCM179X=y
CONFIG_SND_SOC_PCM179X_I2C=y
CONFIG_SND_SOC_PCM179X_SPI=y
CONFIG_SND_SOC_PCM186X=y
CONFIG_SND_SOC_PCM186X_I2C=y
CONFIG_SND_SOC_PCM186X_SPI=y
CONFIG_SND_SOC_PCM3168A=y
# CONFIG_SND_SOC_PCM3168A_I2C is not set
CONFIG_SND_SOC_PCM3168A_SPI=y
# CONFIG_SND_SOC_PCM512x_I2C is not set
# CONFIG_SND_SOC_PCM512x_SPI is not set
CONFIG_SND_SOC_RL6231=y
# CONFIG_SND_SOC_RT5616 is not set
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_RT5645=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_I2C=y
CONFIG_SND_SOC_SIGMADSP_REGMAP=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
# CONFIG_SND_SOC_SPDIF is not set
# CONFIG_SND_SOC_SSM2602_SPI is not set
# CONFIG_SND_SOC_SSM2602_I2C is not set
CONFIG_SND_SOC_SSM4567=y
CONFIG_SND_SOC_STA32X=y
# CONFIG_SND_SOC_STA350 is not set
CONFIG_SND_SOC_STI_SAS=y
# CONFIG_SND_SOC_TAS2552 is not set
# CONFIG_SND_SOC_TAS5086 is not set
# CONFIG_SND_SOC_TAS571X is not set
CONFIG_SND_SOC_TAS5720=y
# CONFIG_SND_SOC_TAS6424 is not set
# CONFIG_SND_SOC_TDA7419 is not set
CONFIG_SND_SOC_TFA9879=y
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC23_I2C=y
# CONFIG_SND_SOC_TLV320AIC23_SPI is not set
# CONFIG_SND_SOC_TLV320AIC31XX is not set
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC32X4_I2C=y
CONFIG_SND_SOC_TLV320AIC32X4_SPI=y
CONFIG_SND_SOC_TLV320AIC3X=y
# CONFIG_SND_SOC_TS3A227E is not set
CONFIG_SND_SOC_TSCS42XX=y
CONFIG_SND_SOC_WM8510=y
# CONFIG_SND_SOC_WM8523 is not set
# CONFIG_SND_SOC_WM8524 is not set
# CONFIG_SND_SOC_WM8580 is not set
CONFIG_SND_SOC_WM8711=y
# CONFIG_SND_SOC_WM8728 is not set
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
# CONFIG_SND_SOC_WM8770 is not set
# CONFIG_SND_SOC_WM8776 is not set
CONFIG_SND_SOC_WM8804=y
# CONFIG_SND_SOC_WM8804_I2C is not set
CONFIG_SND_SOC_WM8804_SPI=y
# CONFIG_SND_SOC_WM8903 is not set
# CONFIG_SND_SOC_WM8960 is not set
CONFIG_SND_SOC_WM8962=y
# CONFIG_SND_SOC_WM8974 is not set
# CONFIG_SND_SOC_WM8978 is not set
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_ZX_AUD96P22=y
# CONFIG_SND_SOC_MAX9759 is not set
# CONFIG_SND_SOC_NAU8540 is not set
CONFIG_SND_SOC_NAU8810=y
CONFIG_SND_SOC_NAU8824=y
CONFIG_SND_SOC_TPA6130A2=y
# CONFIG_SND_SIMPLE_CARD is not set
# CONFIG_SND_X86 is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
# CONFIG_HID_CHERRY is not set
CONFIG_HID_CHICONY=y
CONFIG_HID_CORSAIR=y
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CMEDIA=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_HIDPP=y
# CONFIG_LOGITECH_FF is not set
CONFIG_LOGIRUMBLEPAD2_FF=y
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MAYFLASH=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTI=y
CONFIG_HID_ORTEK=y
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
# CONFIG_HID_PICOLCD_BACKLIGHT is not set
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PICOLCD_CIR is not set
# CONFIG_HID_PLANTRONICS is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_UDRAW_PS3=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y
# CONFIG_HID_SENSOR_CUSTOM_SENSOR is not set
CONFIG_HID_ALPS=y

#
# USB HID support
#
# CONFIG_USB_HID is not set
# CONFIG_HID_PID is not set

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=y
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_SL811_CS is not set
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
CONFIG_USBIP_VHCI_HC_PORTS=8
CONFIG_USBIP_VHCI_NR_HCS=1
CONFIG_USBIP_HOST=y
CONFIG_USBIP_VUDC=y
CONFIG_USBIP_DEBUG=y
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y
# CONFIG_USB_MUSB_GADGET is not set
# CONFIG_USB_MUSB_DUAL_ROLE is not set

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_ULPI=y
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PERIPHERAL=y
# CONFIG_USB_DWC2_DUAL_ROLE is not set
# CONFIG_USB_DWC2_PCI is not set
CONFIG_USB_DWC2_DEBUG=y
# CONFIG_USB_DWC2_VERBOSE is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_PCI=y
# CONFIG_USB_CHIPIDEA_UDC is not set
CONFIG_USB_CHIPIDEA_ULPI=y
# CONFIG_USB_ISP1760 is not set

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
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
CONFIG_USB_EHSET_TEST_FIXTURE=y
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
# CONFIG_USB_EZUSB_FX2 is not set
CONFIG_USB_HUB_USB251XB=y
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_HSIC_USB4604=y
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
# CONFIG_TAHVO_USB is not set
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
# CONFIG_USB_GADGET_VERBOSE is not set
CONFIG_USB_GADGET_DEBUG_FILES=y
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
# CONFIG_USB_GR_UDC is not set
CONFIG_USB_R8A66597=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
# CONFIG_USB_M66592 is not set
CONFIG_USB_BDC_UDC=y

#
# Platform Support
#
CONFIG_USB_BDC_PCI=y
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=y
# CONFIG_USB_NET2272_DMA is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
# CONFIG_USB_CONFIGFS is not set
CONFIG_TYPEC=y
# CONFIG_TYPEC_TCPM is not set
# CONFIG_TYPEC_UCSI is not set
CONFIG_TYPEC_TPS6598X=y

#
# USB Type-C Multiplexer/DeMultiplexer Switch support
#
# CONFIG_TYPEC_MUX_PI3USB30532 is not set
CONFIG_USB_ULPI_BUS=y
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SPI=y
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
# CONFIG_MMC_USHC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
# CONFIG_MMC_CQHCI is not set
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DAC124S085=y
# CONFIG_LEDS_REGULATOR is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_MLXREG is not set
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_AMD64 is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_IE31200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set
# CONFIG_RTC_NVMEM is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_ABB5ZES3=y
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1307_HWMON is not set
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1374_WDT=y
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF85363=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV8803=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
CONFIG_RTC_DRV_M41T94=y
# CONFIG_RTC_DRV_DS1302 is not set
CONFIG_RTC_DRV_DS1305=y
# CONFIG_RTC_DRV_DS1343 is not set
CONFIG_RTC_DRV_DS1347=y
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6916=y
CONFIG_RTC_DRV_R9701=y
# CONFIG_RTC_DRV_RX4581 is not set
CONFIG_RTC_DRV_RX6110=y
# CONFIG_RTC_DRV_RS5C348 is not set
CONFIG_RTC_DRV_MAX6902=y
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_DS3232_HWMON is not set
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
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_DA9063=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_WM831X is not set
# CONFIG_RTC_DRV_WM8350 is not set
# CONFIG_RTC_DRV_CROS_EC is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_FTRTC010=y
CONFIG_RTC_DRV_MC13XXX=y

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_ALTERA_MSGDMA=y
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
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
# CONFIG_SYNC_FILE is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_CHARLCD=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=y
CONFIG_XENFS=y
CONFIG_XEN_COMPAT_XENFS=y
# CONFIG_XEN_SYS_HYPERVISOR is not set
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
CONFIG_XEN_GRANT_DEV_ALLOC=y
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=y
# CONFIG_XEN_PVCALLS_FRONTEND is not set
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_STAGING=y
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
CONFIG_NCP_FS=y
# CONFIG_NCPFS_PACKET_SIGNING is not set
CONFIG_NCPFS_IOCTL_LOCKING=y
# CONFIG_NCPFS_STRONG is not set
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_COMEDI=y
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=y
CONFIG_COMEDI_TEST=y
CONFIG_COMEDI_PARPORT=y
# CONFIG_COMEDI_SERIAL2002 is not set
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
# CONFIG_COMEDI_PCMCIA_DRIVERS is not set
# CONFIG_COMEDI_USB_DRIVERS is not set
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=y
CONFIG_ADIS16209=y
CONFIG_ADIS16240=y

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set
# CONFIG_AD7780 is not set
CONFIG_AD7816=y
CONFIG_AD7192=y
CONFIG_AD7280=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
# CONFIG_ADT7316_SPI is not set
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
# CONFIG_AD7152 is not set
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
# CONFIG_AD9832 is not set
# CONFIG_AD9834 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16060 is not set

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_TSL2x7x=y

#
# Active energy metering IC
#
CONFIG_ADE7753=y
# CONFIG_ADE7754 is not set
CONFIG_ADE7758=y
CONFIG_ADE7759=y
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
CONFIG_ADE7854_SPI=y

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
# CONFIG_AD2S1200 is not set
CONFIG_AD2S1210=y

#
# Speakup console speech
#
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_GOLDFISH_AUDIO is not set
CONFIG_MTD_GOLDFISH_NAND=y
CONFIG_MTD_SPINAND_MT29F=y
# CONFIG_MTD_SPINAND_ONDIEECC is not set
CONFIG_LNET=y
CONFIG_LNET_MAX_PAYLOAD=1048576
CONFIG_LNET_SELFTEST=y
# CONFIG_LUSTRE_FS is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_CRYPTO_SKEIN=y
CONFIG_UNISYSSPAR=y
CONFIG_WILC1000=y
CONFIG_WILC1000_SDIO=y
# CONFIG_WILC1000_SPI is not set
CONFIG_WILC1000_HW_OOB_INTR=y
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set

#
# USB Power Delivery and Type-C drivers
#
CONFIG_PI433=y
# CONFIG_MTK_MMC is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
CONFIG_GOLDFISH_BUS=y
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CROS_EC_CTL=y
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
# CONFIG_COMMON_CLK_WM831X is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI544 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_S2MPS11 is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
CONFIG_RPMSG_CHAR=y
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
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_ARIZONA=y
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_EXTCON_USBC_CROS_EC is not set
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_BUFFER_HW_CONSUMER=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
# CONFIG_IIO_SW_TRIGGER is not set
CONFIG_IIO_TRIGGERED_EVENT=y

#
# Accelerometers
#
# CONFIG_ADXL345_I2C is not set
# CONFIG_ADXL345_SPI is not set
CONFIG_BMA180=y
CONFIG_BMA220=y
# CONFIG_BMC150_ACCEL is not set
CONFIG_DA280=y
CONFIG_DA311=y
# CONFIG_DMARD09 is not set
# CONFIG_DMARD10 is not set
CONFIG_HID_SENSOR_ACCEL_3D=y
# CONFIG_IIO_CROS_EC_ACCEL_LEGACY is not set
CONFIG_KXSD9=y
CONFIG_KXSD9_SPI=y
CONFIG_KXSD9_I2C=y
# CONFIG_KXCJK1013 is not set
CONFIG_MC3230=y
# CONFIG_MMA7455_I2C is not set
# CONFIG_MMA7455_SPI is not set
CONFIG_MMA7660=y
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=y
CONFIG_MXC4005=y
# CONFIG_MXC6255 is not set
CONFIG_SCA3000=y
# CONFIG_STK8312 is not set
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
# CONFIG_AD7291 is not set
# CONFIG_AD7298 is not set
CONFIG_AD7476=y
# CONFIG_AD7766 is not set
CONFIG_AD7791=y
CONFIG_AD7793=y
# CONFIG_AD7887 is not set
CONFIG_AD7923=y
# CONFIG_AD799X is not set
# CONFIG_CC10001_ADC is not set
CONFIG_DA9150_GPADC=y
CONFIG_HI8435=y
CONFIG_HX711=y
CONFIG_INA2XX_ADC=y
CONFIG_LTC2471=y
CONFIG_LTC2485=y
CONFIG_LTC2497=y
# CONFIG_MAX1027 is not set
# CONFIG_MAX11100 is not set
CONFIG_MAX1118=y
# CONFIG_MAX1363 is not set
CONFIG_MAX9611=y
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
CONFIG_QCOM_VADC_COMMON=y
# CONFIG_QCOM_SPMI_IADC is not set
CONFIG_QCOM_SPMI_VADC=y
# CONFIG_TI_ADC081C is not set
# CONFIG_TI_ADC0832 is not set
# CONFIG_TI_ADC084S021 is not set
CONFIG_TI_ADC12138=y
CONFIG_TI_ADC108S102=y
CONFIG_TI_ADC128S052=y
# CONFIG_TI_ADC161S626 is not set
CONFIG_TI_ADS7950=y
# CONFIG_TI_AM335X_ADC is not set
CONFIG_TI_TLC4541=y
CONFIG_TWL4030_MADC=y
# CONFIG_TWL6030_GPADC is not set
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
CONFIG_CCS811=y
CONFIG_IAQCORE=y
# CONFIG_VZ89X is not set
CONFIG_IIO_CROS_EC_SENSORS_CORE=y
# CONFIG_IIO_CROS_EC_SENSORS is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORS_COMMONS is not set
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
CONFIG_AD5593R=y
CONFIG_AD5504=y
CONFIG_AD5624R_SPI=y
CONFIG_LTC2632=y
CONFIG_AD5686=y
# CONFIG_AD5755 is not set
CONFIG_AD5761=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
# CONFIG_AD8801 is not set
CONFIG_DS4424=y
CONFIG_M62332=y
CONFIG_MAX517=y
CONFIG_MCP4725=y
CONFIG_MCP4922=y
CONFIG_TI_DAC082S085=y

#
# IIO dummy driver
#
CONFIG_IIO_DUMMY_EVGEN=y
CONFIG_IIO_SIMPLE_DUMMY=y
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=y
CONFIG_ADIS16136=y
# CONFIG_ADIS16260 is not set
# CONFIG_ADXRS450 is not set
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
CONFIG_BMG160_SPI=y
# CONFIG_HID_SENSOR_GYRO_3D is not set
CONFIG_MPU3050=y
CONFIG_MPU3050_I2C=y
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=y
# CONFIG_AFE4404 is not set
CONFIG_MAX30100=y
CONFIG_MAX30102=y

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
CONFIG_HDC100X=y
CONFIG_HID_SENSOR_HUMIDITY=y
# CONFIG_HTS221 is not set
CONFIG_HTU21=y
CONFIG_SI7005=y
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=y
# CONFIG_BMI160_I2C is not set
# CONFIG_BMI160_SPI is not set
CONFIG_KMX61=y
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y
CONFIG_INV_MPU6050_SPI=y
CONFIG_IIO_ST_LSM6DSX=y
CONFIG_IIO_ST_LSM6DSX_I2C=y
CONFIG_IIO_ST_LSM6DSX_SPI=y
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
CONFIG_APDS9300=y
# CONFIG_APDS9960 is not set
# CONFIG_BH1750 is not set
# CONFIG_BH1780 is not set
CONFIG_CM32181=y
CONFIG_CM3232=y
CONFIG_CM3323=y
# CONFIG_CM36651 is not set
CONFIG_IIO_CROS_EC_LIGHT_PROX=y
CONFIG_GP2AP020A00F=y
# CONFIG_SENSORS_ISL29018 is not set
CONFIG_SENSORS_ISL29028=y
CONFIG_ISL29125=y
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_HID_SENSOR_PROX=y
CONFIG_JSA1212=y
# CONFIG_RPR0521 is not set
# CONFIG_SENSORS_LM3533 is not set
CONFIG_LTR501=y
# CONFIG_LV0104CS is not set
CONFIG_MAX44000=y
# CONFIG_OPT3001 is not set
# CONFIG_PA12203001 is not set
CONFIG_SI1145=y
CONFIG_STK3310=y
CONFIG_ST_UVIS25=y
CONFIG_ST_UVIS25_I2C=y
CONFIG_ST_UVIS25_SPI=y
CONFIG_TCS3414=y
CONFIG_TCS3472=y
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL2583=y
CONFIG_TSL4531=y
# CONFIG_US5182D is not set
# CONFIG_VCNL4000 is not set
# CONFIG_VEML6070 is not set
# CONFIG_VL6180 is not set
CONFIG_ZOPT2201=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
CONFIG_BMC150_MAGN_I2C=y
# CONFIG_BMC150_MAGN_SPI is not set
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
# CONFIG_MMC35240 is not set
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
# CONFIG_SENSORS_HMC5843_SPI is not set

#
# Multiplexers
#

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y
CONFIG_HID_SENSOR_DEVICE_ROTATION=y

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_AD5272=y
CONFIG_DS1803=y
CONFIG_MAX5481=y
CONFIG_MAX5487=y
# CONFIG_MCP4018 is not set
# CONFIG_MCP4131 is not set
CONFIG_MCP4531=y
CONFIG_TPL0102=y

#
# Digital potentiostats
#
CONFIG_LMP91000=y

#
# Pressure sensors
#
# CONFIG_ABP060MG is not set
CONFIG_BMP280=y
CONFIG_BMP280_I2C=y
CONFIG_BMP280_SPI=y
CONFIG_IIO_CROS_EC_BARO=y
CONFIG_HID_SENSOR_PRESS=y
CONFIG_HP03=y
# CONFIG_MPL115_I2C is not set
# CONFIG_MPL115_SPI is not set
CONFIG_MPL3115=y
CONFIG_MS5611=y
# CONFIG_MS5611_I2C is not set
# CONFIG_MS5611_SPI is not set
CONFIG_MS5637=y
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y
CONFIG_HP206C=y
CONFIG_ZPA2326=y
CONFIG_ZPA2326_I2C=y
CONFIG_ZPA2326_SPI=y

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity and distance sensors
#
CONFIG_LIDAR_LITE_V2=y
CONFIG_RFD77402=y
CONFIG_SRF04=y
CONFIG_SX9500=y
CONFIG_SRF08=y

#
# Temperature sensors
#
CONFIG_MAXIM_THERMOCOUPLE=y
# CONFIG_HID_SENSOR_TEMP is not set
CONFIG_MLX90614=y
CONFIG_MLX90632=y
CONFIG_TMP006=y
CONFIG_TMP007=y
# CONFIG_TSYS01 is not set
# CONFIG_TSYS02D is not set
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
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_CPCAP_USB is not set
CONFIG_PHY_QCOM_USB_HS=y
CONFIG_PHY_QCOM_USB_HSIC=y
CONFIG_PHY_SAMSUNG_USB2=y
CONFIG_PHY_TUSB1210=y
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
CONFIG_DEV_DAX=y
CONFIG_NVMEM=y

#
# HW tracing support
#
# CONFIG_STM is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
# CONFIG_INTEL_TH_ACPI is not set
# CONFIG_INTEL_TH_GTH is not set
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
# CONFIG_INTEL_TH_DEBUG is not set
CONFIG_FPGA=y
# CONFIG_ALTERA_PR_IP_CORE is not set
CONFIG_FPGA_MGR_ALTERA_PS_SPI=y
# CONFIG_FPGA_MGR_ALTERA_CVP is not set
CONFIG_FPGA_MGR_XILINX_SPI=y
# CONFIG_FPGA_BRIDGE is not set
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=y
# CONFIG_SIOX_BUS_GPIO is not set
CONFIG_SLIMBUS=y
CONFIG_SLIM_QCOM_CTRL=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
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
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
# CONFIG_OVERLAY_FS is not set

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
# CONFIG_PROC_PAGE_MONITOR is not set
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ECRYPT_FS is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
CONFIG_JFFS2_FS_WBUF_VERIFY=y
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_RTIME=y
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
# CONFIG_UBIFS_FS_LZO is not set
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_ATIME_SUPPORT is not set
CONFIG_UBIFS_FS_SECURITY=y
# CONFIG_CRAMFS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS is not set
# CONFIG_PSTORE_842_COMPRESS is not set
CONFIG_PSTORE_COMPRESS=y
CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_RAM=y
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
CONFIG_CEPH_FS=y
# CONFIG_CEPH_FS_POSIX_ACL is not set
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_ACL is not set
# CONFIG_CIFS_DEBUG is not set
# CONFIG_CIFS_DFS_UPCALL is not set
CONFIG_CIFS_SMB311=y
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
CONFIG_AFS_DEBUG=y
CONFIG_9P_FS=y
# CONFIG_9P_FS_POSIX_ACL is not set
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
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
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=8192
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_FRAME_POINTER=y
# CONFIG_STACK_VALIDATION is not set
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
# CONFIG_MAGIC_SYSRQ_SERIAL is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
CONFIG_KASAN_EXTRA=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_SOFTLOCKUP_DETECTOR is not set
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
CONFIG_MEMTEST=y
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
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
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
# CONFIG_UNWINDER_ORC is not set
CONFIG_UNWINDER_FRAME_POINTER=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY_FALLBACK=y
CONFIG_HARDENED_USERCOPY_PAGESPAN=y
# CONFIG_FORTIFY_SOURCE is not set
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
CONFIG_CRYPTO_DH=y
# CONFIG_CRYPTO_ECDH is not set
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
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

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
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=y
# CONFIG_CRYPTO_SHA256_MB is not set
CONFIG_CRYPTO_SHA512_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_SHA3 is not set
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_SPECK is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_LZO is not set
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_USER_API_RNG=y
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_VIRTIO is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
CONFIG_PKCS7_TEST_KEY=y
CONFIG_SIGNED_PE_FILE_VERIFICATION=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

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
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC4 is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_STACKDEPOT=y
CONFIG_STRING_SELFTEST=y
-------------- next part --------------
#!/bin/sh

export_top_env()
{
	export suite='boot'
	export testcase='boot'
	export timeout='10m'
	export job_origin='/lkp/lkp/src/jobs/boot.yaml'
	export queue='rand'
	export testbox='vm-lkp-hsw01-openwrt-ia32-7'
	export tbox_group='vm-lkp-hsw01-openwrt-ia32'
	export branch='linus/master'
	export commit='60cc43fc888428bb2f18f08997432d426a243338'
	export kconfig='x86_64-randconfig-ws0-03101549'
	export submit_id='5ad570ee0b9a9378ec104ef9'
	export job_file='/lkp/scheduled/vm-lkp-hsw01-openwrt-ia32-7/boot-1-openwrt-i386-2016-03-16.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180417-30956-psgkzl-wait_kernel-0.yaml'
	export id='bf835a0112573d011ff7fcaab14c3b2f0c4e8eda'
	export model='qemu-system-x86_64 -enable-kvm'
	export nr_vm=30
	export nr_cpu=1
	export memory='420M'
	export rootfs='openwrt-i386-2016-03-16.cgz'
	export need_kconfig='CONFIG_KVM_GUEST=y'
	export compiler='gcc-7'
	export enqueue_time='2018-04-17 11:58:38 +0800'
	export _id='5ad570ee0b9a9378ec104ef9'
	export _rt='/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338'
	export user='lkp'
	export kernel='/pkg/linux/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1'
	export result_root='/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0'
	export dequeue_time='2018-04-17 12:08:37 +0800'
	export LKP_SERVER='inn'
	export max_uptime=600
	export initrd='/osimage/openwrt/openwrt-i386-2016-03-16.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/scheduled/vm-lkp-hsw01-openwrt-ia32-7/boot-1-openwrt-i386-2016-03-16.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180417-30956-psgkzl-wait_kernel-0.yaml
ARCH=x86_64
kconfig=x86_64-randconfig-ws0-03101549
branch=linus/master
commit=60cc43fc888428bb2f18f08997432d426a243338
BOOT_IMAGE=/pkg/linux/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
max_uptime=600
RESULT_ROOT=/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0
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
	export lkp_initrd='/lkp/lkp/lkp-i386.cgz'
	export site='inn'
	export LKP_CGI_PORT=80
	export LKP_CIFS_PORT=139
	export job_initrd='/lkp/scheduled/vm-lkp-hsw01-openwrt-ia32-7/boot-1-openwrt-i386-2016-03-16.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180417-30956-psgkzl-wait_kernel-0.cgz'

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
	run_monitor $LKP_SRC/monitors/wrapper nfs-hang

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
	/osimage/openwrt/openwrt-i386-2016-03-16.cgz
	/lkp/lkp/lkp-i386.cgz
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
	ip=::::vm-lkp-hsw01-openwrt-ia32-7::dhcp
	root=/dev/ram0
	user=lkp
	job=/job-script
	ARCH=x86_64
	kconfig=x86_64-randconfig-ws0-03101549
	branch=linus/master
	commit=60cc43fc888428bb2f18f08997432d426a243338
	BOOT_IMAGE=/pkg/linux/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1
	max_uptime=600
	RESULT_ROOT=/result/boot/1/vm-lkp-hsw01-openwrt-ia32/openwrt-i386-2016-03-16.cgz/x86_64-randconfig-ws0-03101549/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/0
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
