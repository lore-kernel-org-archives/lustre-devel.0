From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 19:55:36 +0100 (BST)
Subject: [lustre-devel] Current results and status of my upstream work
In-Reply-To: <871sg65bid.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87bmgvrsj8.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1802120233260.3291@casper.infradead.org>
 <871sg65bid.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1803301844001.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Hi Neil
> >
> > 	I have been testing the upstream client using lustre 2.10 tools 
> > and the test suite that comes with it. I see the following failures in
> > my testing and wonder at how it compares to your testing:
> >
> > sanity: FAIL: test_17n migrate remote dir error 1
> > sanity: FAIL: test_17o stat file should fail
> > sanity: FAIL: test_24v large readdir doesn't take effect:  2 should be about 0
> > sanity: FAIL: test_27z FF stripe count 1 != 0
> > sanity: FAIL: test_27D llapi_layout_test failed
> > sanity: FAIL: test_29 No mdc lock count
> > sanity: FAIL: test_42d failed: client:75497472 server: 92274688.
> > sanity: FAIL: test_42e failed: client:76218368 server: 92995584.
> > sanity: FAIL: test_56c OST lustre-OST0000 is in status of '', not 'D'
> > sanity: FAIL: test_56t "lfs find -S 4M /lustre/lustre/d56t.sanityt" wrong: found 5, expected 3
> > sanity: FAIL: test_56w /usr/bin/lfs getstripe -c /lustre/lustre/d56w.sanityw/dir1/file1 wrong: found 2, expected 1
> > sanity: FAIL: test_63a failed: client:75497472 server: 92274688.
> > sanity: FAIL: test_63b failed: client:75497472 server: 92274688.
> > sanity: FAIL: test_64a failed: client:75497472 server: 92274688.
> > sanity: FAIL: test_64c failed: client:75497472 server: 92274688.
> > sanity: FAIL: test_76 inode slab grew from 182313 to 182399
> > sanity: FAIL: test_77c no checksum dump file on Client
> > sanity: FAIL: test_101g unable to set max_pages_per_rpc=16M
> > sanity: FAIL: test_102a /lustre/lustre/f102a.sanity missing 3 trusted.name xattrs
> > sanity: FAIL: test_102b can't get trusted.lov from /lustre/lustre/f102b.sanity
> > sanity: FAIL: test_102n setxattr invalid 'trusted.lov' success
> > sanity: FAIL: test_103a run_acl_subtest cp failed
> > sanity: FAIL: test_125 setfacl /lustre/lustre/d125 failed
> > sanity: FAIL: test_154  kernel panics in ll_splice code
> > sanity: FAIL: test_154B decode linkea /lustre/lustre/d154B.sanity/f154B.sanity failed
> > sanity: FAIL: test_160d migrate fails
> > sanity: FAIL: test_161d create should be blocked
> > sanity: FAIL: test_162a check path d162a.sanity/d2/p/q/r/slink failed
> > sanity: FAIL: test_200 unable to mount /lustre/lustre on MGS
> > sanity: FAIL: test_220 unable to mount /lustre/lustre on MGS
> > sanity: FAIL: test_225  kills the MDS server
> > sanity: FAIL: test_226a cannot get path of FIFO by /lustre/lustre /lustre/lustre/d226a.sanity/fifo
> > sanity: FAIL: test_226b cannot get path of FIFO by /lustre/lustre /lustre/lustre/d226b.sanity/remote_dir/fifo
> > sanity: FAIL: test_230b fails on migrating remote dir to MDT1
> > sanity: FAIL: test_230c mkdir succeeds under migrating directory
> > sanity: FAIL: test_230d migrate remote dir error
> > sanity: FAIL: test_230e migrate dir fails
> > sanity: FAIL: test_230f #1 migrate dir fails
> > sanity: FAIL: test_230h migrating d230h.sanity fail
> > sanity: FAIL: test_230i migration fails with a tailing slash
> > sanity: FAIL: test_233a cannot access /lustre/lustre using its FID '[0x200000007:0x1:0x0]'
> > sanity: FAIL: test_233b cannot access /lustre/lustre/.lustre using its FID '[0x200000002:0x1:0x0]'
> > sanity: FAIL: test_234 touch failed
> > sanity: FAIL: test_240 umount failed
> > sanity: FAIL: test_242 ls /lustre/lustre/d242.sanity failed
> > sanity: FAIL: test_251 short write happened
> > sanity: FAIL: test_300a 1:stripe_count is 0, expect 2
> > sanity: FAIL: test_300e set striped bdir under striped dir error
> > sanity: FAIL: test_300g create dir1 fails
> > sanity: FAIL: test_300h expect 4 get 0 for striped_dir
> > sanity: FAIL: test_300i set striped hashdir error
> > sanity: FAIL: test_300n create test_dir1 fails
> > sanity: FAIL: test_315 read is not accounted (0)
> > sanity: FAIL: test_399a fake write is slower
> > sanity: FAIL: test_405 One layout swap locked test failed
> > sanity: FAIL: test_406 unable to mount /lustre/lustre on MGS
> > sanity: FAIL: test_410 no inode match
> > sanity: FAIL: test_900 never finishes. ldlm_lock dumps
> >
> > Some of those failures are due to new functionality that the upstream 
> > client doesn't support which at this point is not important. Another
> > batch is due to xattr/acl support being broken. John Hammond and I
> > have been looking into those failures. I have a bunch of patches done
> > and are being tested. Letting you know so we don't duplicate work.
> > The other source of the bugs is the sysfs support. I'm porting the
> > fixes I have done to upstream and I'm in the process of validating
> > the patches. As a last bunch of changes it was found that lustre
> > doesn't work properly with its SMP code on systems like KNL and ARM
> > on one end and the other end on these massive systems with 100s of
> > core also doesn't work well. I have those patches already finished
> > and tested. I will be pushing those after the next merge window.
> > I'm almost done working out the 64 bit time code as well. Haven't
> > ported those yet.
> 
> Hi,
>  thanks for this.
>  Yes, my list is very similar, though not identical.
>  I've modified the test harness a little so that it unmounts and
>  remounts the filesystem on every test.  I was chasing down a bug that
>  happened on unmount, and wanted to trigger it as quickly as possible.
>  The might explain some of the differences

Actually I know what is causing the umount issues. Its a bug in the
sysfs/debugfs implementation. I fixed in my sysfs/debugfs patches. 
I'm still working the sysfs stuff and its going to be a huge patch
set, 100+ patches.
 
>  Tests in your list, not in mine:
>    56[ctw] 76 154  200 300e 315 399a 900

I'm using the test suite from the latest lustre 2.10.3 release.

Test 900 still has issues with ldlm locks not being freed when I applied
the current sysfs patch set I have. The output is:

2018-03-19T10:35:33.206057-04:00 ninja19.ccs.ornl.gov kernel: LustreError: 
7244:0:(ldlm_resource.c:842:ldlm_resource_complain()) 
lustre-MDT0000-mdc-000000007eed4fca: namespace resource 
[0x200000002:0x1:0x0].0 (00000000cd1c4e2f) refcount nonzero (1) after lock 
cleanup; forcing cleanup.

One the sysfs stuff is fixed this can be looked into.

To let you know test 154 always triggers a LBUG due to splice changes that
landed. I'm seeing

2018-03-30 13:41:37 [ 6351.749923] BUG: unable to handle kernel paging 
request at ffffffffffffffbc
2018-03-30 13:41:37 [ 6351.757031] IP: ll_splice_alias+0x1df/0x250 
[lustre]
2018-03-30 13:41:37 [ 6351.762111] PGD 1e0a067 P4D 1e0a067 PUD 1e0c067 PMD 
0
2018-03-30 13:41:37 [ 6351.767373] Oops: 0000 [#1] SMP
2018-03-30 13:41:37 [ 6351.770627] Modules linked in: loop lustre(C) 
obdecho(C) mgc(C) lov(C) osc(C) mdc(C) lmv(C) fid(C) fld(C) ptlrpc(C) 
obdclass(C) ksocklnd(C) lnet(C) sha512_generic md5 libcfs(C) 
ip6table_filter ip6_tables joydev iptable_filter dm_mirror dm_region_hash 
dm_log dm_mod coretemp x86_pkg_temp_thermal crc32_pclmul ahci libahci 
ipmi_si ehci_pci pcspkr i2c_i801 libata ehci_hcd ipmi_devintf wmi 
ipmi_msghandler rpcrdma button ib_iser libiscsi scsi_transport_iscsi 
scsi_mod ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm configfs ib_cm 
iw_cm mlx4_ib ib_core nfsd ip_tables x_tables autofs4 nfsv3 nfs_acl nfs 
lockd grace mlx4_en mlx4_core igb i2c_algo_bit i2c_core hwmon ipv6 
crc_ccitt sunrpc
2018-03-30 13:41:37 [ 6351.831324] CPU: 5 PID: 15718 Comm: mrename 
Tainted: G        WC       4.16.0-rc7+ #1
2018-03-30 13:41:37 [ 6351.839335] Hardware name: Supermicro X9DRT/X9DRT, 
BIOS 3.0a 02/19/2014
2018-03-30 13:41:37 [ 6351.846070] RIP: 0010:ll_splice_alias+0x1df/0x250 
[lustre]
2018-03-30 13:41:37 [ 6351.851675] RSP: 0018:ffffc90023307c18 EFLAGS: 
00010282
2018-03-30 13:41:37 [ 6351.857014] RAX: ffffffffffffff8c RBX: 
ffffffffffffff8c RCX: 0000000000000000
2018-03-30 13:41:37 [ 6351.864263] RDX: ffffffffffffff8c RSI: 
ffffffffa074a8b8 RDI: ffffffffa0759540
2018-03-30 13:41:37 [ 6351.871512] RBP: ffffc90023307c38 R08: 
0000000000000000 R09: ffff881053a87762
2018-03-30 13:41:38 [ 6351.878758] R10: 0000000000000000 R11: 
000000000000000f R12: ffff880fbea8e180
2018-03-30 13:41:38 [ 6351.886011] R13: ffff880fad4589c8 R14: 
ffff880faf12b288 R15: 0000000000000013
2018-03-30 13:41:38 [ 6351.893263] FS:  00007f4b72cd6740(0000) 
GS:ffff88107fc80000(0000) knlGS:0000000000000000
2018-03-30 13:41:38 [ 6351.901542] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
2018-03-30 13:41:38 [ 6351.907401] CR2: ffffffffffffffbc CR3: 
0000001053db6005 CR4: 00000000000606e0
2018-03-30 13:41:38 [ 6351.914650] Call Trace:
2018-03-30 13:41:38 [ 6351.917228]  ll_lookup_it_finish+0x57/0xc50 
[lustre]
2018-03-30 13:41:38 [ 6351.922315]  ? 
ll_invalidate_negative_children+0x190/0x190 [lustre]
2018-03-30 13:41:38 [ 6351.928711]  ll_lookup_it+0x258/0x8e0 [lustre]
2018-03-30 13:41:38 [ 6351.933278]  ll_lookup_nd+0xf7/0x160 [lustre]
2018-03-30 13:41:38 [ 6351.938977]  __lookup_hash+0x54/0xa0
2018-03-30 13:41:38 [ 6351.942666]  ? lock_rename+0x5c/0xe0
2018-03-30 13:41:38 [ 6351.946359]  SyS_renameat2+0x1bc/0x490
2018-03-30 13:41:38 [ 6351.950226]  SyS_rename+0x19/0x20
2018-03-30 13:41:38 [ 6351.953653]  do_syscall_64+0x5b/0x110
2018-03-30 13:41:38 [ 6351.957433]  
entry_SYSCALL_64_after_hwframe+0x3d/0xa2
2018-03-30 13:41:38 [ 6351.962597] RIP: 0033:0x7f4b727698d7
2018-03-30 13:41:38 [ 6351.966286] RSP: 002b:00007fff9b8dc838 EFLAGS: 
00000202 ORIG_RAX: 0000000000000052
2018-03-30 13:41:38 [ 6351.974033] RAX: ffffffffffffffda RBX: 
0000000000000000 RCX: 00007f4b727698d7
2018-03-30 13:41:38 [ 6351.981279] RDX: 00007fff9b8dc948 RSI: 
00007fff9b8dda6c RDI: 00007fff9b8dda50
2018-03-30 13:41:38 [ 6351.988530] RBP: 0000000000000000 R08: 
00007f4b72abee80 R09: 0000000000000000
2018-03-30 13:41:38 [ 6351.995784] R10: 00007fff9b8dc550 R11: 
0000000000000202 R12: 0000000000400650
2018-03-30 13:41:38 [ 6352.003035] R13: 00007fff9b8dc920 R14: 
0000000000000000 R15: 0000000000000000
2018-03-30 13:41:38 [ 6352.010285] Code: d8 02 03 00 c1 01 00 00 48 c7 c6 
b8 a8 74 a0 48 c7 05 d2 02 03 00 00 00
00 00 c7 05 c0 02 03 00 00 20 00 00 48 c7 c7 40 95 75 a0 <48> 8b 48 30 44 
8b 08 44 8b 40 5c 31 c0 e8 df 80 d3 ff
48 89 d8
2018-03-30 13:41:38 [ 6352.029415] RIP: ll_splice_alias+0x1df/0x250 
[lustre] RSP: ffffc90023307c18
2018-03-30 13:41:38 [ 6352.036485] CR2: ffffffffffffffbc
2018-03-30 13:41:38 [ 6352.039910] ---[ end trace 07dc9db2fd0c6402 ]---

>  Tests in my list, not in yours
>    56z 60aa 64b 83 104b 120e  130[abcde] 161c 205 215 

For sanity test 215 that is a test issue. It is testing for a lnet
proc file that doesn't exist anymore. For lustre 2.11 the test was
updated and it can pass now.

The sanity 130 test are the fiemap failures. We see those errors on
Ubuntu 16 as well during are testing. It is due to a bug in the
e2fsprogs. Andreas sent a fix out for this. You can read about it
under ticket https://jira.hpdd.intel.com/browse/LU-10335. I suspect
SuSE might need to patch up their e2fsprogs.
 
The rest I believe are real bugs.

>  It might be worth looking in to some of these(?). Last time I
>  tried to understand one of the failures, I quickly realized that my
>  understand of how lustre works wasn't deep enough.  So I went back
>  to code cleaning.  Doing that has slowly improved my understanding
>  so it might be worth it to go hunting again.
> 
>  I don't think anything you have mentioned will duplicate anything I've
>  been working on.  Most of my time recently has been understanding the
>  various hash tables and working to convert lustre to use rhashtable.

That is a big change. I was looking to fix that up but if you want to
tackle that go for it. Another piece that lustre implements is an rbtree.
The kernel has a rbtree that could replace what lustre uses.

>  I look forward to looking over your patches, I'll probably learn something

I fixed up the xattr problems. Lustre heavly uses xattr for its user
land tools so this is a big step forward. I need to break up the xattr 
patches into smaller pieces to make Greg happy. With the latest patches
you sent I will need to rebase the SMP patches. In that patch set I 
removed linux-cpu.h. I have yet to handle linux-cpu.c. I can either 
merge both linux-cpu.c and libcfs_cpu.c into one file and have lots of 
ifdef CONFIG_SMP or put static inline functions into libcfs_cpu.h for
the UMP case. I'm leaning to the second option. What do you think is 
better? Note I also have a patch already that removes linux/libcfs.h so 
you don't need to worry about that one. With that last  patch no more 
libcfs/linux directory.

Lastly I'm working on the sysfs port which is a big task. Currently I'm 
working out the bugs I introduce in the port :-/ One thing that lustre 
implements for its sysfs handling is the ability to pass in units, KiB, MB 
etc. The way lustre does it is very lustre specific so I'm looking at 
creating a string helper that does the opposite of string_get_size(). It 
changes a string into a real number value. I will post it here once I have 
it ready. Since Greg is open to merging lustre specific stuff to the 
kernel for general use I think this would be a nice feature for people in
general. I will need to update the lustre tools to handle this.

>  One failure that I have looked into but haven't posted a patch for yet,
>  is that sometimes
>         LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
>  in cl_io_read_ahead() fails.  When it does, the value is CIS_INIT.
>  Tracing through the code, it seem that CIS_INIT is an easy possibility
>  since 1e1db2a97be5 ("staging: lustre: clio: Revise read ahead implementation")
>  However CIS_IO_GOING and CIS_LOCKED do also happen and I cannot see
>  that patht that leads to those - so I didn't feel that I could
>  correctly explain the patch.
>  I currently have:
> 
>        LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED ||
>                io->ci_state == CIS_INIT);
> 
>  Do you have any idea if that is right?

I see this was answered already :-)
