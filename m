From: Daniel Mayfield <dmayfield@rgmadvisors.com>
Date: Thu, 10 Mar 2011 10:02:03 -0600
Subject: [Lustre-devel] Bug?
Message-ID: <AANLkTimAPHef88==0MTGAoz5m_MkKmtuwfL2mydcjGBf@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I have a small test cluster (56 client nodes, 1 active MDS, 14 active
OSSes).  On Wednesday, I had a user run a job across a number of the 56
nodes, and we had a bunch of problems with filesystems/nodes hanging.  On
all of the server nodes I see a bunch of messages like this:
--
odfs016.dmesg:Lustre: 6024:0:(lib-move.c:1826:lnet_parse_put()) Dropping PUT
from 12345-192.168.50.238 at o2ib portal 28 match 1359131017746000 offset 0
length 368: 2
odfs016.dmesg:Lustre: 6020:0:(lib-move.c:1826:lnet_parse_put()) Dropping PUT
from 12345-192.168.50.55 at o2ib portal 28 match 1359226700951811 offset 0
length 368: 2
odfs016.dmesg:Lustre: 6032:0:(lib-move.c:1826:lnet_parse_put()) Dropping PUT
from 12345-192.168.50.56 at o2ib portal 28 match 1359136284378342 offset 0
length 368: 2
odfs016.dmesg:Lustre: 6033:0:(lib-move.c:1826:lnet_parse_put()) Dropping PUT
from 12345-192.168.50.238 at o2ib portal 28 match 1359131017746019 offset 0
length 368: 2
odfs016.dmesg:Lustre: 6018:0:(lib-move.c:1826:lnet_parse_put()) Dropping PUT
from 12345-192.168.50.55 at o2ib portal 28 match 1359226700951833 offset 0
length 368: 2
--
(for reference, .238 is the MDS+MGS, .55 and .56 are the last two client
nodes).

On some of the client nodes, I got actual OOPS messages:
--
UG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff811ebf93>] sg_next+0x3/0x30
PGD 1839700067 PUD 18389e0067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file:
/sys/devices/pci0000:00/0000:00:1e.0/0000:06:03.0/local_cpus
CPU 1
Modules linked in: hidp l2cap bluetooth rfkill lmv mgc lustre lov osc lquota
mdc fid fld ksocklnd ko2iblnd ptlrpc obdclass lnet lvfs libcfs rdma_ucm
ib_sdp rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_sa ib_uverbs ib_umad iw_nes
iw_cxgb3 cxgb3 ib_qib mlx4_ib mlx4_en mlx4_core ib_mthca ib_mad ib_core
mptctl mptbase ipmi_devintf ipmi_si ipmi_msghandler dell_rbu netconsole
configfs i2c_dev i2c_core nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6
libcrc32c dca fuse ext3 jbd mbcache dm_mirror dm_multipath scsi_dh video
output sbs sbshc acpi_pad parport_pc lp parport sg sr_mod cdrom bnx2
pata_acpi snd_pcm serio_raw ata_generic iTCO_wdt iTCO_vendor_support dcdbas
snd_timer snd soundcore snd_page_alloc pcspkr dm_region_hash dm_log dm_mod
ata_piix libata shpchp megaraid_sas sd_mod crc_t10dif scsi_mod xfs exportfs
uhci_hcd ohci_hcd ssb mmc_core ehci_hcd [last unloaded: mlx4_core]
Pid: 12935, comm: ptlrpcd-brw Not tainted 2.6.32.28-2.rgm #1 PowerEdge R610
RIP: 0010:[<ffffffff811ebf93>]  [<ffffffff811ebf93>] sg_next+0x3/0x30
RSP: 0018:ffff88181c0c1760  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff881823b19000 RCX: 0000000000000002
RDX: 0000000000000002 RSI: ffffc9001d3e7468 RDI: 0000000000000000
RBP: ffff88181c0c1800 R08: ffff8802d7555eb0 R09: 0000000000000002
R10: 0000000000000000 R11: ffff8802d7555eb0 R12: ffff880c38b26800
R13: ffff881823b14000 R14: ffff880c3946f090 R15: ffffc9001d3e7468
FS:  00007eff2e9f76e0(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000001836a84000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ptlrpcd-brw (pid: 12935, threadinfo ffff88181c0c0000, task
ffff88181c0be8c0)
Stack:
 ffff88181c0c1800 ffffffffa094dc3e ffff880c0555c080 00050000c0a832fc
<0> ffff88181c0c17d0 ffffffffa094e8a1 ffff88073f2bc140 ffff880c0555c118
<0> ffff880028333280 ffff880c00000002 ffffffff815cd3a0 0000000200000001
Call Trace:
 [<ffffffffa094dc3e>] ? kiblnd_map_tx+0x1be/0x430 [ko2iblnd]
 [<ffffffffa094e8a1>] ? kiblnd_queue_tx_locked+0x91/0x2b0 [ko2iblnd]
 [<ffffffffa094e492>] kiblnd_setup_rd_iov+0x142/0x270 [ko2iblnd]
 [<ffffffffa0952b19>] kiblnd_send+0x5d9/0x970 [ko2iblnd]
 [<ffffffffa06d8601>] lnet_ni_send+0x51/0xd0 [lnet]
 [<ffffffffa06dc63b>] lnet_send+0x5ab/0x960 [lnet]
 [<ffffffffa0699963>] ? cfs_alloc+0x63/0x90 [libcfs]
 [<ffffffffa06d8bd0>] ? lnet_prep_send+0x50/0xb0 [lnet]
 [<ffffffffa06dd9c7>] LNetPut+0x2a7/0x7b0 [lnet]
 [<ffffffffa06d7377>] ? LNetMDBind+0x1c7/0x3f0 [lnet]
 [<ffffffffa0699963>] ? cfs_alloc+0x63/0x90 [libcfs]
 [<ffffffffa08484c9>] ptl_send_buf+0x199/0x580 [ptlrpc]
 [<ffffffffa06d7060>] ? LNetMDAttach+0x350/0x4a0 [lnet]
 [<ffffffffa084b70e>] ptl_send_rpc+0x4be/0xc80 [ptlrpc]
 [<ffffffffa0840498>] ptlrpc_send_new_req+0x3d8/0x810 [ptlrpc]
 [<ffffffff8104e5c3>] ? find_busiest_queue+0x53/0x110
 [<ffffffff8104918f>] ? finish_task_switch+0x4f/0xa0
 [<ffffffffa0843fb8>] ptlrpc_check_set+0x308/0x19c0 [ptlrpc]
 [<ffffffff8106a3cb>] ? try_to_del_timer_sync+0x7b/0xe0
 [<ffffffff8106a452>] ? del_timer_sync+0x22/0x30
 [<ffffffffa0877430>] ptlrpcd_check+0x1c0/0x250 [ptlrpc]
 [<ffffffffa0877873>] ptlrpcd+0x363/0x3e0 [ptlrpc]
 [<ffffffff8104ddb0>] ? default_wake_function+0x0/0x20
 [<ffffffff8100d07a>] child_rip+0xa/0x20
 [<ffffffffa0699963>] ? cfs_alloc+0x63/0x90 [libcfs]
 [<ffffffffa0877510>] ? ptlrpcd+0x0/0x3e0 [ptlrpc]
 [<ffffffff8100d070>] ? child_rip+0x0/0x20
Code: 41 5d 41 5e 41 5f c9 c3 55 48 c7 c2 f0 c4 1e 81 be 80 00 00 00 48 89
e5 e8 6b ff ff ff c9 c3 66 0f 1f 84 00 00 00 00 00 55 31 c0 <f6> 07 02 48 89
e5 75 0d 48 8b 57 20 48 8d 47 20 f6 c2 01 75 02
RIP  [<ffffffff811ebf93>] sg_next+0x3/0x30
 RSP <ffff88181c0c1760>
CR2: 0000000000000000
---[ end trace d0f44533e422125f ]---
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<(null)>] (null)
PGD 182505b067 PUD 0
Oops: 0010 [#2] SMP
last sysfs file:
/sys/devices/pci0000:00/0000:00:1e.0/0000:06:03.0/local_cpus
CPU 0
Modules linked in: hidp l2cap bluetooth rfkill lmv mgc lustre lov osc lquota
mdc fid fld ksocklnd ko2iblnd ptlrpc obdclass lnet lvfs libcfs rdma_ucm
ib_sdp rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_sa ib_uverbs ib_umad iw_nes
iw_cxgb3 cxgb3 ib_qib mlx4_ib mlx4_en mlx4_core ib_mthca ib_mad ib_core
mptctl mptbase ipmi_devintf ipmi_si ipmi_msghandler dell_rbu netconsole
configfs i2c_dev i2c_core nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6
libcrc32c dca fuse ext3 jbd mbcache dm_mirror dm_multipath scsi_dh video
output sbs sbshc acpi_pad parport_pc lp parport sg sr_mod cdrom bnx2
pata_acpi snd_pcm serio_raw ata_generic iTCO_wdt iTCO_vendor_support dcdbas
snd_timer snd soundcore snd_page_alloc pcspkr dm_region_hash dm_log dm_mod
ata_piix libata shpchp megaraid_sas sd_mod crc_t10dif scsi_mod xfs exportfs
uhci_hcd ohci_hcd ssb mmc_core ehci_hcd [last unloaded: mlx4_core]
Pid: 22012, comm: java Tainted: G      D    2.6.32.28-2.rgm #1 PowerEdge
R610
RIP: 0010:[<0000000000000000>]  [<(null)>] (null)
RSP: 0018:ffff881094927460  EFLAGS: 00010097
RAX: ffff88181c0c1ee0 RBX: ffffffffffffffe8 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff88181c0c1ee0
RBP: ffff8810949274a8 R08: 0000000000000000 R09: ffffffffa08c6e48
R10: ffff88182105c298 R11: 0000000000000001 R12: 0000000000000000
R13: ffff881837b31250 R14: 0000000000000000 R15: 0000000000000000
FS:  000000004030b940(0063) GS:ffff880c6a600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 00000014ef116000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process java (pid: 22012, threadinfo ffff881094926000, task
ffff8811038d4680)
Stack:
 ffffffff81040189 ffffffffa0a37b00 0000000300000001 ffff8810949275c8
<0> ffff881837b31248 0000000000000286 0000000000000003 0000000000000001
<0> 0000000000000000 ffff8810949274e8 ffffffff81047218 0000000000000000
Call Trace:
 [<ffffffff81040189>] ? __wake_up_common+0x59/0x90
 [<ffffffff81047218>] __wake_up+0x48/0x70
 [<ffffffffa069971a>] cfs_waitq_signal+0x1a/0x20 [libcfs]
 [<ffffffffa083e929>] ptlrpc_set_add_new_req+0x59/0x70 [ptlrpc]
 [<ffffffffa0877ad8>] ptlrpcd_add_req+0x1e8/0x350 [ptlrpc]
 [<ffffffffa084e464>] ? lustre_msg_get_opc+0x94/0x100 [ptlrpc]
 [<ffffffffa0878310>] ? ptlrpc_lprocfs_brw+0xc0/0xd0 [ptlrpc]
 [<ffffffffa0a23e15>] osc_send_oap_rpc+0x565/0xc10 [osc]
 [<ffffffffa0699786>] ? cfs_mem_is_in_cache+0x16/0x60 [libcfs]
 [<ffffffffa0768d55>] ? cl_is_page+0x15/0x20 [obdclass]
 [<ffffffffa0a24766>] osc_check_rpcs+0x2a6/0x470 [osc]
 [<ffffffffa0a310ff>] ? osc_page_transfer_add+0x4f/0x80 [osc]
 [<ffffffffa0a1bf03>] ? on_list+0x43/0x50 [osc]
 [<ffffffffa0a36569>] osc_io_submit+0x1b9/0x4c0 [osc]
 [<ffffffffa0a8950a>] ? lov_attr_get+0x4a/0x80 [lov]
 [<ffffffffa0774861>] cl_io_submit_rw+0x71/0x1a0 [obdclass]
 [<ffffffffa0699786>] ? cfs_mem_is_in_cache+0x16/0x60 [libcfs]
 [<ffffffffa0a9284e>] lov_io_submit+0x2be/0x960 [lov]
 [<ffffffffa0774861>] cl_io_submit_rw+0x71/0x1a0 [obdclass]
 [<ffffffffa0768d76>] ? cl_page_top_trusted+0x16/0x60 [obdclass]
 [<ffffffffa077659e>] cl_io_read_page+0xbe/0x1a0 [obdclass]
 [<ffffffffa076b0e9>] ? cl_page_assume+0xa9/0x250 [obdclass]
 [<ffffffffa0afc3a8>] ll_readpage+0x98/0x1e0 [lustre]
 [<ffffffff810dc9d8>] generic_file_aio_read+0x1e8/0x650
 [<ffffffffa0767ad8>] ? cl_object_attr_get+0x78/0x1a0 [obdclass]
 [<ffffffffa0b2767b>] vvp_io_read_start+0x13b/0x3d0 [lustre]
 [<ffffffffa07703e5>] ? cl_wait+0xb5/0x260 [obdclass]
 [<ffffffffa0774b28>] cl_io_start+0x68/0x170 [obdclass]
 [<ffffffffa0777c50>] cl_io_loop+0x110/0x1d0 [obdclass]
 [<ffffffffa0766105>] ? cl_env_info+0x15/0x20 [obdclass]
 [<ffffffffa0ad7182>] ll_file_io_generic+0x242/0x3c0 [lustre]
 [<ffffffff810dc412>] ? filemap_fault+0xd2/0x4b0
 [<ffffffffa0768049>] ? cl_env_get+0x29/0x330 [obdclass]
 [<ffffffffa0ad74a0>] ll_file_aio_read+0x1a0/0x2d0 [lustre]
 [<ffffffffa07681a0>] ? cl_env_get+0x180/0x330 [obdclass]
 [<ffffffffa0766543>] ? cl_env_put+0x1b3/0x2e0 [obdclass]
 [<ffffffffa0ad7971>] ll_file_read+0x171/0x310 [lustre]
 [<ffffffff81126515>] vfs_read+0xb5/0x1a0
 [<ffffffff81126b01>] sys_read+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
Code:  Bad RIP value.
RIP  [<(null)>] (null)
 RSP <ffff881094927460>
CR2: 0000000000000000
---[ end trace d0f44533e4221260 ]---
--

Any help would be appreciated.

daniel



---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110310/a65369db/attachment.htm>
