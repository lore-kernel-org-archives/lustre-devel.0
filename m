From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 02:19:18 +0000 (GMT)
Subject: [lustre-devel] drivers/staging updated to 4.20-rc1
In-Reply-To: <87h8g2oui1.fsf@notabene.neil.brown.name>
References: <87k1lsyssq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811052058590.11915@casper.infradead.org>
 <87h8g2oui1.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1812270217050.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> Hi,
> >>  I've just pushed out new lustre/lustre, lustre/lustre-testing, lustre/lustre-wip
> >>  to github.com:neilbrown/linux.git
> >> 
> >>  lustre is updated to 4.20-rc1 and doesn't compile because of some
> >>  changes.
> >>  The patch below makes it compile and (probably) work.
> >> 
> >>  I'd appreciate a review, especially of the iov_for_each change.
> >
> > Almost. I see the following errors while testing.
> >
> > [ 7111.002667] RIP: 0010:sanity+0xb2/0xb9
> > [ 7111.002668] Code: 63 c5 48 c7 c7 a1 7c e8 81 ff c5 48 6b c0 28 48 03 43 
> > 78 8b 48 08 48 8b 70 10 44 8b 40 0c 48 8b 10 31 c0 e8 4c 67 d6 ff  c
> > [ 7111.002669] RSP: 0018:ffffc900072d3a60 EFLAGS: 00010246
> > [ 7111.002670] RAX: 000000000000002a RBX: ffff8808502126c0 RCX: 
> > 0000000000000006
> > [ 7111.002671] RDX: 0000000000000000 RSI: ffffffff81e770e3 RDI: 
> > 00000000ffffffff
> > [ 7111.002672] RBP: 0000000000000010 R08: 0000000000000004 R09: 
> > ffffffff82683e8e
> > [ 7111.002673] R10: 00000000000015a9 R11: 0000000000000000 R12: 
> > ffffea003f9523c0
> > [ 7111.002674] R13: ffff8808502126c0 R14: ffffea003f9523c0 R15: 
> > 0000000000001000
> > [ 7111.002676] FS:  00007f140a193740(0000) GS:ffff88107fd80000(0000) 
> > knlGS:0000000000000000
> > [ 7111.002677] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [ 7111.002678] CR2: 000000000067a198 CR3: 00000008305dc001 CR4: 
> > 00000000000606e0
> > [ 7111.002679] Call Trace:
> > [ 7111.002682]  copy_page_to_iter+0x245/0x2f0
> > [ 7111.002686]  generic_file_buffered_read+0x345/0x7c0
> > [ 7111.002689]  ? touch_atime+0x33/0xd0
> > [ 7111.002701]  vvp_io_read_start+0x22a/0x3a0 [lustre]
> > [ 7111.002715]  cl_io_start+0x6d/0x130 [obdclass]
> > [ 7111.002727]  cl_io_loop+0xae/0x220 [obdclass]
> > [ 7111.002736]  ll_file_io_generic+0x4ee/0x880 [lustre]
> > [ 7111.002740]  ? generic_file_buffered_read+0x591/0x7c0
> > [ 7111.002749]  ll_file_read_iter+0x13e/0x1b0 [lustre]
> > [ 7111.002751]  generic_file_splice_read+0xe1/0x190
> > [ 7111.002755]  splice_direct_to_actor+0xea/0x200
> > [ 7111.002757]  ? generic_pipe_buf_nosteal+0x10/0x10
> > [ 7111.002759]  do_splice_direct+0x87/0xd0
> > [ 7111.002762]  do_sendfile+0x1c6/0x3c0
> > [ 7111.002765]  __x64_sys_sendfile64+0x5c/0xb0
> > [ 7111.002768]  do_syscall_64+0x68/0x38f
> > [ 7111.002770]  ? do_page_fault+0x2d/0x130
> > [ 7111.002773]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > [ 7111.002775] RIP: 0033:0x7f1409ca71ca
> >
> 
> Thanks for testing, and sorry that I didn't respond at the time - I
> managed to lose track of it somehow.
> Anyway, I hit testing problems that were quite different but in
> a generally similar area.
> This fixes them, and might fix yours too.  It'll appear in
> lustre-testing shortly.

I see the splice handling in the VFS layer has moved to iter pipes.
Does Al plan to do that with all of the VFS layer? I wonder if iter
pipes whould be a good replacement for the kiov and biovec handling
in the LNet layer. 
