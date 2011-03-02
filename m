From: Vu Pham <vuhuong@mellanox.com>
Date: Wed, 02 Mar 2011 11:57:06 -0800
Subject: [Lustre-devel] system crashes mounting mds
Message-ID: <4D6EA112.8040400@mellanox.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I got system crash with message "BUG: scheduling while atomic: ll_mgs_01/0xffff8103/11347" after mounting lustre

Here is the steps that I did:
$ mkfs.lustre --fsname=lustre --reformat --mgs --mdt /dev/sdc
$ mount -t lustre /dev/sdc /tmp/lustre_mgs

Here is the stack dump:

ldiskfs created from ext3-2.6-rhel5
kjournald starting.  Commit interval 5 seconds
LDISKFS FS on sdc, internal journal
LDISKFS-fs: mounted filesystem with ordered data mode.
Lustre: OBD class driver, http://www.lustre.org/
Lustre:     Lustre Version: 1.8.5
Lustre:     Build Version: 1.8.5-20101117053234-PRISTINE-2.6.18-194.17.1.el5_lustre.1.8.5
Lustre: Added LNI 10.4.57.8 at tcp [8/256/0/180]
Lustre: Accept secure, port 988
Lustre: Lustre Client File System; http://www.lustre.org/
kjournald starting.  Commit interval 5 seconds
LDISKFS FS on sdc, internal journal
LDISKFS-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
LDISKFS FS on sdc, internal journal
LDISKFS-fs: mounted filesystem with ordered data mode.
Lustre: MGS MGS started
Lustre: MGC10.4.57.8 at tcp: Reactivating import
Lustre: MGS: Logs for fs lustre were removed by user request.  All servers must be restarted in order to regenerate the logs.
BUG: scheduling while atomic: ll_mgs_01/0xffff8103/11347

Call Trace:
 [<ffffffff8006243d>] __sched_text_start+0x7d/0xbd6
 [<ffffffff880765a6>] :scsi_mod:scsi_done+0x0/0x18
 [<ffffffff8001cc65>] __mod_timer+0x100/0x10f
 [<ffffffff8006e1d7>] do_gettimeofday+0x40/0x90
 [<ffffffff8005a7a2>] getnstimeofday+0x10/0x28
 [<ffffffff80015504>] sync_buffer+0x0/0x3f
 [<ffffffff800637ea>] io_schedule+0x3f/0x67
 [<ffffffff8001553f>] sync_buffer+0x3b/0x3f
 [<ffffffff80063a16>] __wait_on_bit+0x40/0x6e
 [<ffffffff80015504>] sync_buffer+0x0/0x3f
 [<ffffffff80063ab0>] out_of_line_wait_on_bit+0x6c/0x78
 [<ffffffff800a09f8>] wake_bit_function+0x0/0x23
 [<ffffffff886e4bc8>] :ldiskfs:bh_submit_read+0x58/0x70
 [<ffffffff886e4ef8>] :ldiskfs:read_block_bitmap+0xc8/0x1c0
 [<ffffffff886e51cf>] :ldiskfs:ldiskfs_new_blocks_old+0x1df/0x750
 [<ffffffff886e9fb6>] :ldiskfs:ldiskfs_get_blocks_handle+0x596/0xd30
 [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
 [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
 [<ffffffff8000b476>] __find_get_block+0x15c/0x16c
 [<ffffffff886ea83a>] :ldiskfs:ldiskfs_getblk+0xea/0x320
 [<ffffffff880310b4>] :jbd:start_this_handle+0x341/0x3ed
 [<ffffffff80019bcc>] __getblk+0x25/0x236
 [<ffffffff886ebe51>] :ldiskfs:ldiskfs_bread+0x11/0x80
 [<ffffffff88031233>] :jbd:journal_start+0xd3/0x107
 [<ffffffff88afea8d>] :fsfilt_ldiskfs:fsfilt_ldiskfs_write_record+0x1cd/0x4b0
 [<ffffffff8000cf57>] do_lookup+0x65/0x1e6
 [<ffffffff887bdc89>] :obdclass:llog_lvfs_write_blob+0x119/0x440
 [<ffffffff887bf15f>] :obdclass:llog_lvfs_write_rec+0xb1f/0xda0
 [<ffffffff8002317b>] file_move+0x36/0x44
 [<ffffffff8000d47a>] dput+0x2c/0x113
 [<ffffffff88ad2c4e>] :mgs:record_lcfg+0x38e/0x4c0
 [<ffffffff8000984c>] __d_lookup+0xb0/0xff
 [<ffffffff88ad6e4a>] :mgs:record_marker+0x83a/0xa30
 [<ffffffff8002ca48>] mntput_no_expire+0x19/0x89
 [<ffffffff88ad83eb>] :mgs:mgs_write_log_lov+0x37b/0xf80
 [<ffffffff801537bf>] snprintf+0x44/0x4c
 [<ffffffff8875bff0>] :lvfs:pop_ctxt+0x290/0x370
 [<ffffffff887c4036>] :obdclass:__llog_ctxt_put+0x26/0x150
 [<ffffffff88adbbb3>] :mgs:__mgs_write_log_mdt+0x2b3/0x5d0
 [<ffffffff88ae3c0f>] :mgs:mgs_write_log_target+0xb5f/0x21e0
 [<ffffffff8886d060>] :ptlrpc:ldlm_completion_ast+0x0/0x880
 [<ffffffff88acd989>] :mgs:mgs_handle+0xf09/0x16c0
 [<ffffffff888a115a>] :ptlrpc:ptlrpc_server_handle_request+0x97a/0xdf0
 [<ffffffff888a18a8>] :ptlrpc:ptlrpc_wait_event+0x2d8/0x310
 [<ffffffff8008b3bd>] __wake_up_common+0x3e/0x68
 [<ffffffff888a2817>] :ptlrpc:ptlrpc_main+0xf37/0x10f0
 [<ffffffff8005dfb1>] child_rip+0xa/0x11
 [<ffffffff888a18e0>] :ptlrpc:ptlrpc_main+0x0/0x10f0
 [<ffffffff8005dfa7>] child_rip+0x0/0x11

Unable to handle kernel paging request at ffffffffe2cf5e40 RIP: 
 [<ffffffff80062aee>] __sched_text_start+0x72e/0xbd6
PGD 203067 PUD 10af48067 PMD 0 
Oops: 0000 [1] SMP 
last sysfs file: /class/misc/obd/dev
CPU 2 
Modules linked in: mds(U) fsfilt_ldiskfs(U) mgs(U) mgc(U) lustre(U) lov(U) mdc(U) lquota(U) osc(U) ksocklnd(U) ptlrpc(U) obdclass(U) lnet(U) lvfs(U) libcfs(U) ldiskfs(U) crc16(U) mlx4_fcoib(U) mlx4_fc(U) libfc(U) scsi_transport_fc(U) netconsole(U) nfs(U) fscache(U) nfsd(U) exportfs(U) nfs_acl(U) auth_rpcgss(U) autofs4(U) rdma_ucm(U) rdma_cm(U) ib_cm(U) iw_cm(U) ib_sa(U) ib_addr(U) ib_uverbs(U) ib_umad(U) mlx4_ib(U) ib_mad(U) ib_core(U) mlx4_en(U) mlx4_core(U) hidp(U) l2cap(U) bluetooth(U) lockd(U) sunrpc(U) ipv6(U) xfrm_nalgo(U) crypto_api(U) vfat(U) fat(U) loop(U) dm_mirror(U) dm_multipath(U) scsi_dh(U) video(U) backlight(U) sbs(U) power_meter(U) hwmon(U) i2c_ec(U) i2c_core(U) dell_wmi(U) wmi(U) button(U) battery(U) asus_acpi(U) acpi_memhotplug(U) ac(U) parport_pc(U) lp(U) parport(U) sr_mod(U) cdrom(U) sg(U) hpilo(U) bnx2(U) serio_raw(U) pcspkr(U) dm_raid45(U) dm_message(U) dm_region_hash(U) dm_log(U) dm_mod(U) dm_mem_cache(U) ata_piix(U) libata(U) shpchp(U) cciss(U) sd_mod
(U) scsi_mod(U) ext3(U) jbd(U) uhci_hcd(U) ohci_hcd(U) ehci_hcd(U)
Pid: 11347, comm: ll_mgs_01 Tainted: G      2.6.18-194.17.1.el5_lustre.1.8.5 #1
RIP: 0010:[<ffffffff80062aee>]  [<ffffffff80062aee>] __sched_text_start+0x72e/0xbd6
RSP: 0000:ffff8102fd9130b0  EFLAGS: 00010083
RAX: ffffffff80441380 RBX: ffff8102f98aa7a0 RCX: 0000031f0fbe6ec8
RDX: 000000000c520680 RSI: ffff8102f98aa7a0 RDI: ffff8102f98aa7a0
RBP: ffff8102fd913170 R08: 00000000000000a0 R09: 0000000000000000
R10: ffffffff80015504 R11: 0000000000000000 R12: ffff8102f98aa7d8
R13: ffff81010af445f8 R14: 0000000000000002 R15: ffff81000100caa0
FS:  00002af059d15230(0000) GS:ffff81010af994c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffe2cf5e40 CR3: 000000061d85d000 CR4: 00000000000006e0
Process ll_mgs_01 (pid: 11347, threadinfo ffff8102fd912000, task ffff8102f98aa7a0)
Stack:  ffff81031d634c88 ffffffff880765a6 ffff81031d634c80 0000000000000004
 ffff8102f98aa7a0 ffff8102f98aa7a0 0000031f0fc500bd 000000000f14b06c
 ffff8102f98aa990 000000021d634c80 ffff810611200000 ffffffff8006e1d7
Call Trace:
 [<ffffffff880765a6>] :scsi_mod:scsi_done+0x0/0x18
 [<ffffffff8006e1d7>] do_gettimeofday+0x40/0x90
 [<ffffffff8005a7a2>] getnstimeofday+0x10/0x28
 [<ffffffff80015504>] sync_buffer+0x0/0x3f
 [<ffffffff800637ea>] io_schedule+0x3f/0x67
 [<ffffffff8001553f>] sync_buffer+0x3b/0x3f
 [<ffffffff80063a16>] __wait_on_bit+0x40/0x6e
 [<ffffffff80015504>] sync_buffer+0x0/0x3f
 [<ffffffff80063ab0>] out_of_line_wait_on_bit+0x6c/0x78
 [<ffffffff800a09f8>] wake_bit_function+0x0/0x23
 [<ffffffff886e4bc8>] :ldiskfs:bh_submit_read+0x58/0x70
 [<ffffffff886e4ef8>] :ldiskfs:read_block_bitmap+0xc8/0x1c0
 [<ffffffff886e51cf>] :ldiskfs:ldiskfs_new_blocks_old+0x1df/0x750
 [<ffffffff886e9fb6>] :ldiskfs:ldiskfs_get_blocks_handle+0x596/0xd30
 [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
 [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
 [<ffffffff8000b476>] __find_get_block+0x15c/0x16c
 [<ffffffff886ea83a>] :ldiskfs:ldiskfs_getblk+0xea/0x320
 [<ffffffff880310b4>] :jbd:start_this_handle+0x341/0x3ed
 [<ffffffff80019bcc>] __getblk+0x25/0x236
 [<ffffffff886ebe51>] :ldiskfs:ldiskfs_bread+0x11/0x80
 [<ffffffff88031233>] :jbd:journal_start+0xd3/0x107
 [<ffffffff88afea8d>] :fsfilt_ldiskfs:fsfilt_ldiskfs_write_record+0x1cd/0x4b0
 [<ffffffff8000cf57>] do_lookup+0x65/0x1e6
 [<ffffffff887bdc89>] :obdclass:llog_lvfs_write_blob+0x119/0x440
 [<ffffffff887bf15f>] :obdclass:llog_lvfs_write_rec+0xb1f/0xda0
 [<ffffffff8002317b>] file_move+0x36/0x44
 [<ffffffff8000d47a>] dput+0x2c/0x113
 [<ffffffff88ad2c4e>] :mgs:record_lcfg+0x38e/0x4c0
 [<ffffffff8000984c>] __d_lookup+0xb0/0xff
 [<ffffffff88ad6e4a>] :mgs:record_marker+0x83a/0xa30
 [<ffffffff8002ca48>] mntput_no_expire+0x19/0x89
 [<ffffffff88ad83eb>] :mgs:mgs_write_log_lov+0x37b/0xf80
 [<ffffffff801537bf>] snprintf+0x44/0x4c
 [<ffffffff8875bff0>] :lvfs:pop_ctxt+0x290/0x370
 [<ffffffff887c4036>] :obdclass:__llog_ctxt_put+0x26/0x150
 [<ffffffff88adbbb3>] :mgs:__mgs_write_log_mdt+0x2b3/0x5d0
 [<ffffffff88ae3c0f>] :mgs:mgs_write_log_target+0xb5f/0x21e0
 [<ffffffff8886d060>] :ptlrpc:ldlm_completion_ast+0x0/0x880
 [<ffffffff88acd989>] :mgs:mgs_handle+0xf09/0x16c0
 [<ffffffff888a115a>] :ptlrpc:ptlrpc_server_handle_request+0x97a/0xdf0
 [<ffffffff888a18a8>] :ptlrpc:ptlrpc_wait_event+0x2d8/0x310
 [<ffffffff8008b3bd>] __wake_up_common+0x3e/0x68
 [<ffffffff888a2817>] :ptlrpc:ptlrpc_main+0xf37/0x10f0
 [<ffffffff8005dfb1>] child_rip+0xa/0x11
 [<ffffffff888a18e0>] :ptlrpc:ptlrpc_main+0x0/0x10f0
 [<ffffffff8005dfa7>] child_rip+0x0/0x11


Code: 48 8b 14 d5 40 2a 3f 80 48 03 42 08 31 d2 c7 40 08 01 00 00 
RIP  [<ffffffff80062aee>] __sched_text_start+0x72e/0xbd6
 RSP <ffff8102fd9130b0>
CR2: ffffffffe2cf5e40
 <0>Kernel panic - not syncing: Fatal exception
 

By the way, I also try the same setup steps on different device ie. /dev/cciss/c0d0p6 and it is fine.

I'm writing scsi lld driver FCoIB, sdc is scsi device (ie. FC lun) seen/controlled by FCoIB driver, I can mount filesystems ext2/ext3/reiserfs... and run normal I/O on sdc without problem.

Could anyone help/shed some lights on what the problem is?

thanks,
-vu
