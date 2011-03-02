From: Vu Pham <vuhuong@mellanox.com>
Date: Wed, 02 Mar 2011 15:07:21 -0800
Subject: [Lustre-devel] system crashes mounting mds
In-Reply-To: <2938460B-B801-4692-8C79-2AC4A7B29C27@whamcloud.com>
References: <4D6EA112.8040400@mellanox.com>
	<2938460B-B801-4692-8C79-2AC4A7B29C27@whamcloud.com>
Message-ID: <4D6ECDA9.3090500@mellanox.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



Andreas Dilger wrote:
> On 2011-03-02, at 12:57 PM, Vu Pham wrote:
>> I got system crash with message "BUG: scheduling while atomic:
>> Lustre:     Lustre Version: 1.8.5
>> Lustre:     Build Version:
> 1.8.5-20101117053234-PRISTINE-2.6.18-194.17.1.el5_lustre.1.8.5
>> ll_mgs_01/0xffff8103/11347" after mounting lustre
> 
> This is often caused by a stack overflow.
> 
> Looking at the stack trace, it _shouldn't_ be atomic in that context due
> to Lustre (submitting a block IO) so I suspect that the "preempt_count"
> in the tast struct is corrupted or similar.
> 
>> Here is the stack dump:
>>
>> BUG: scheduling while atomic: ll_mgs_01/0xffff8103/11347
>>
>> Call Trace:
>> [<ffffffff8006243d>] __sched_text_start+0x7d/0xbd6
>> [<ffffffff880765a6>] :scsi_mod:scsi_done+0x0/0x18
>> [<ffffffff8001cc65>] __mod_timer+0x100/0x10f
>> [<ffffffff8006e1d7>] do_gettimeofday+0x40/0x90
>> [<ffffffff8005a7a2>] getnstimeofday+0x10/0x28
>> [<ffffffff80015504>] sync_buffer+0x0/0x3f
>> [<ffffffff800637ea>] io_schedule+0x3f/0x67
>> [<ffffffff8001553f>] sync_buffer+0x3b/0x3f
>> [<ffffffff80063a16>] __wait_on_bit+0x40/0x6e
>> [<ffffffff80015504>] sync_buffer+0x0/0x3f
>> [<ffffffff80063ab0>] out_of_line_wait_on_bit+0x6c/0x78
>> [<ffffffff800a09f8>] wake_bit_function+0x0/0x23
>> [<ffffffff886e4bc8>] :ldiskfs:bh_submit_read+0x58/0x70
>> [<ffffffff886e4ef8>] :ldiskfs:read_block_bitmap+0xc8/0x1c0
>> [<ffffffff886e51cf>] :ldiskfs:ldiskfs_new_blocks_old+0x1df/0x750
>> [<ffffffff886e9fb6>] :ldiskfs:ldiskfs_get_blocks_handle+0x596/0xd30
>> [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
>> [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
>> [<ffffffff8000b476>] __find_get_block+0x15c/0x16c
>> [<ffffffff886ea83a>] :ldiskfs:ldiskfs_getblk+0xea/0x320
>> [<ffffffff880310b4>] :jbd:start_this_handle+0x341/0x3ed
>> [<ffffffff80019bcc>] __getblk+0x25/0x236
>> [<ffffffff886ebe51>] :ldiskfs:ldiskfs_bread+0x11/0x80
>> [<ffffffff88031233>] :jbd:journal_start+0xd3/0x107
>> [<ffffffff88afea8d>]
> :fsfilt_ldiskfs:fsfilt_ldiskfs_write_record+0x1cd/0x4b0
>> [<ffffffff8000cf57>] do_lookup+0x65/0x1e6
>> [<ffffffff887bdc89>] :obdclass:llog_lvfs_write_blob+0x119/0x440
>> [<ffffffff887bf15f>] :obdclass:llog_lvfs_write_rec+0xb1f/0xda0
>> [<ffffffff8002317b>] file_move+0x36/0x44
>> [<ffffffff8000d47a>] dput+0x2c/0x113
>> [<ffffffff88ad2c4e>] :mgs:record_lcfg+0x38e/0x4c0
>> [<ffffffff8000984c>] __d_lookup+0xb0/0xff
>> [<ffffffff88ad6e4a>] :mgs:record_marker+0x83a/0xa30
>> [<ffffffff8002ca48>] mntput_no_expire+0x19/0x89
>> [<ffffffff88ad83eb>] :mgs:mgs_write_log_lov+0x37b/0xf80
>> [<ffffffff801537bf>] snprintf+0x44/0x4c
>> [<ffffffff8875bff0>] :lvfs:pop_ctxt+0x290/0x370
>> [<ffffffff887c4036>] :obdclass:__llog_ctxt_put+0x26/0x150
>> [<ffffffff88adbbb3>] :mgs:__mgs_write_log_mdt+0x2b3/0x5d0
>> [<ffffffff88ae3c0f>] :mgs:mgs_write_log_target+0xb5f/0x21e0
>> [<ffffffff8886d060>] :ptlrpc:ldlm_completion_ast+0x0/0x880
>> [<ffffffff88acd989>] :mgs:mgs_handle+0xf09/0x16c0
>> [<ffffffff888a115a>] :ptlrpc:ptlrpc_server_handle_request+0x97a/0xdf0
>> [<ffffffff888a18a8>] :ptlrpc:ptlrpc_wait_event+0x2d8/0x310
>> [<ffffffff8008b3bd>] __wake_up_common+0x3e/0x68
>> [<ffffffff888a2817>] :ptlrpc:ptlrpc_main+0xf37/0x10f0
>> [<ffffffff8005dfb1>] child_rip+0xa/0x11
>> [<ffffffff888a18e0>] :ptlrpc:ptlrpc_main+0x0/0x10f0
>> [<ffffffff8005dfa7>] child_rip+0x0/0x11
>>

I get the above stack trace when I called scsi_done() in workqueue context.

Originally calling scsi_done() in irq context, I get below stack trace.

Unable to handle kernel paging request at 00000000031b1e40 RIP: 
 [<ffffffff8008c71f>] task_rq_lock+0x29/0x6f
PGD 61d9b3067 PUD 61d7a3067 PMD 0 
Oops: 0000 [1] SMP 
last sysfs file: /class/misc/obd/dev
CPU 2 
Modules linked in: mds(U) fsfilt_ldiskfs(U) mgs(U) mgc(U) ldiskfs(U) crc16(U) lustre(U) lov(U) mdc(U) lquota(U) osc(U) ksocklnd(U) ptlrpc(U) obdclass(U) lnet(U) lvfs(U) libcfs(U) mlx4_fcoib(U) mlx4_fc(U) libfc(U) scsi_transport_fc(U) netconsole(U) nfs(U) fscache(U) nfsd(U) exportfs(U) nfs_acl(U) auth_rpcgss(U) autofs4(U) rdma_ucm(U) rdma_cm(U) ib_cm(U) iw_cm(U) ib_sa(U) ib_addr(U) ib_uverbs(U) ib_umad(U) mlx4_ib(U) ib_mad(U) ib_core(U) mlx4_en(U) mlx4_core(U) hidp(U) l2cap(U) bluetooth(U) lockd(U) sunrpc(U) ipv6(U) xfrm_nalgo(U) crypto_api(U) vfat(U) fat(U) loop(U) dm_mirror(U) dm_multipath(U) scsi_dh(U) video(U) backlight(U) sbs(U) power_meter(U) hwmon(U) i2c_ec(U) i2c_core(U) dell_wmi(U) wmi(U) button(U) battery(U) asus_acpi(U) acpi_memhotplug(U) ac(U) parport_pc(U) lp(U) parport(U) sr_mod(U) cdrom(U) sg(U) hpilo(U) serio_raw(U) pcspkr(U) bnx2(U) dm_raid45(U) dm_message(U) dm_region_hash(U) dm_log(U) dm_mod(U) dm_mem_cache(U) ata_piix(U) libata(U) shpchp(U) cciss(U) sd_mod
(U) scsi_mod(U) ext3(U) jbd(U) uhci_hcd(U) ohci_hcd(U) ehci_hcd(U)
Pid: 0, comm: swapper Tainted: G      2.6.18-194.17.1.el5_lustre.1.8.5 #1
RIP: 0010:[<ffffffff8008c71f>]  [<ffffffff8008c71f>] task_rq_lock+0x29/0x6f
RSP: 0000:ffff81010aff3c30  EFLAGS: 00010086
RAX: 00000000105b7e80 RBX: ffffffff8043f420 RCX: ffff81010aff3d90
RDX: 0000000000000000 RSI: ffff81010aff3cb8 RDI: ffff8102f10ac040
RBP: ffff81010aff3c50 R08: ffff8102ebe214f0 R09: ffff81010aff3f10
R10: ffffffff8003da79 R11: ffffffff80041fc2 R12: ffffffff8043f420
R13: ffff81010aff3cb8 R14: ffff8102f10ac040 R15: ffff81010aff3d90
FS:  0000000000000000(0000) GS:ffff81010af994c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000031b1e40 CR3: 0000000619237000 CR4: 00000000000006e0
Process swapper (pid: 0, threadinfo ffff81010afee000, task ffff81032a957860)
Stack:  0000000000000003 0000000000000001 ffff8102f10ac040 ffff81010af38610
 ffff81010aff3cf0 ffffffff80046a5c 00000000803f85a0 0000000000000030
 ffff81010afeff00 0000000000020000 0000000000020000 00000000000456c4
Call Trace:
 <IRQ>  [<ffffffff80046a5c>] try_to_wake_up+0x27/0x484
 [<ffffffff8007796b>] start_secondary+0x498/0x4a7
 [<ffffffff8007796b>] start_secondary+0x498/0x4a7
 [<ffffffff800a09d3>] autoremove_wake_function+0x9/0x2e
 [<ffffffff8008b3bd>] __wake_up_common+0x3e/0x68
 [<ffffffff8002e22d>] __wake_up+0x38/0x4f
 [<ffffffff8000c704>] __wake_up_bit+0x28/0x2d
 [<ffffffff80032186>] end_buffer_read_sync+0x1c/0x22
 [<ffffffff80041ff1>] end_bio_bh_io_sync+0x2f/0x3b
 [<ffffffff8002cd05>] __end_that_request_first+0x23c/0x5bf
 [<ffffffff8006b9cc>] show_trace+0x34/0x47
 [<ffffffff8807afe5>] :scsi_mod:scsi_end_request+0x27/0xcd
 [<ffffffff8807b1d9>] :scsi_mod:scsi_io_completion+0x14e/0x324
 [<ffffffff886a956d>] :mlx4_fc:mfc_cq_clean+0x4f/0x84
 [<ffffffff880a90f0>] :sd_mod:sd_rw_intr+0x25a/0x294
 [<ffffffff8807b46e>] :scsi_mod:scsi_device_unbusy+0x67/0x81
 [<ffffffff80037c99>] blk_done_softirq+0x5f/0x6d
 [<ffffffff8001241c>] __do_softirq+0x89/0x133
 [<ffffffff8005e2fc>] call_softirq+0x1c/0x28
 [<ffffffff8006cb8a>] do_softirq+0x2c/0x85
 [<ffffffff8006ca12>] do_IRQ+0xec/0xf5
 [<ffffffff8005d615>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff888498d0>] :ptlrpc:request_out_callback+0x0/0x1b0
 [<ffffffff8019db41>] acpi_processor_idle_simple+0x17d/0x30e
 [<ffffffff8019da30>] acpi_processor_idle_simple+0x6c/0x30e
 [<ffffffff8019d9c4>] acpi_processor_idle_simple+0x0/0x30e
 [<ffffffff8019d9c4>] acpi_processor_idle_simple+0x0/0x30e
 [<ffffffff80049206>] cpu_idle+0x95/0xb8
 [<ffffffff8007796b>] start_secondary+0x498/0x4a7


Code: 48 8b 04 c5 40 2a 3f 80 4c 03 60 08 4c 89 e7 e8 52 83 fd ff 
RIP  [<ffffffff8008c71f>] task_rq_lock+0x29/0x6f
 RSP <ffff81010aff3c30>
CR2: 00000000031b1e40
 <0>Kernel panic - not syncing: Fatal exception


Have you seen this problem with other scsi devices on other transport (sata, fc,...)?
