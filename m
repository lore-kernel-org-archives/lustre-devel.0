From: James Simmons <jsimmons@infradead.org>
Date: Tue, 7 Jan 2020 00:02:36 +0000 (GMT)
Subject: [lustre-devel] Lustre upstreaming status.
In-Reply-To: <87sglgg9ub.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87sglgg9ub.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.2001062316450.26511@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Hi all,
>  At the LUG in Houston, I said that I hoped to submit something upstream
>  by the end of 2019.  Clearly that isn't going to happen now.
> 
>  The main reason that caused me to not even try is IPv6 support.
>  It became apparent to me that LNet would not be accepted until it has
>  working IPv6 support, and that doesn't exist yet.
>  I hope to put some development time into IPv6, and to have something
>  that works and is worth reviewing by the end of January 2020.

That would be awesome. I believe the original plan was for IPv6 support
for 2.14 but USDP didn't make it in for 2.13 so everything got delayed.

>  The other issue is that development has progressed slowly because
>  there is no spare review bandwidth.  James has contributed a lot, and
>  others have helped, but reviewing patches for two code streams (OpenSFS
>  and Linux-upstream) turns out to be too much to ask for.
>  So I've decided to take a different approach.  From now on I'm not
>  going to wait for reviews for patches going into my linux-lustre tree.
>  Part of my justification for this is that historically, review hasn't
>  really provided much promise of correctness.  Patches go missing.
>  Random lines from patches go missing.  Errors creep in in other ways.

I have been going over the patches from your backport tree to find
missing patches and test for regressions. I think all regressions I
saw was stomped out for everything for 2.12. I'm doing full regression
right now. The only bug I see now is very unique to the linux client.

2020-01-06T16:24:58.006823-05:00 ninja81.ccs.ornl.gov kernel: RIP: 
0010:ll_dcompare+0x62/0xf0 [lustre]
2020-01-06T16:24:58.006880-05:00 ninja81.ccs.ornl.gov kernel: RAX: 
0000000000000000 RBX: 0000000000000000 RCX: 0000000000000002
2020-01-06T16:24:58.006934-05:00 ninja81.ccs.ornl.gov kernel: RDX: 
0000000000000001 RSI: 0000000000000001 RDI: 00000000ffffffff
2020-01-06T16:24:58.006992-05:00 ninja81.ccs.ornl.gov kernel: Code: 85 c0 
89 c3 75 2d f6 05 c8 c7 c8 ff 20 74 09 f6 05 c2 c7 c8 ff
 80 75 2b 41 f7 04 24 00 00 01 10 75 c2 49 8b 84 24 f8 00 00 00 <0f> b6 58 
0c 83 e3 01 eb b1 48 83 c4 08 bb 01 00 00 00 89 d8 5b 5
d
2020-01-06T16:24:58.007051-05:00 ninja81.ccs.ornl.gov kernel: RBP: 
ffffc90009137cf0 R08: 0000000000000000 R09: 0000000000000000
2020-01-06T16:24:58.007105-05:00 ninja81.ccs.ornl.gov kernel: R10: 
0000000000000000 R11: 000000000000000f R12: ffff888fecf4ab40
2020-01-06T16:24:58.007157-05:00 ninja81.ccs.ornl.gov kernel: RSP: 
0018:ffffc9000944b950 EFLAGS: 00010246
2020-01-06T16:24:58.007216-05:00 ninja81.ccs.ornl.gov kernel: R13: 
000000137118a4ee R14: ffffc90009137cf0 R15: 0000000000000000
2020-01-06T16:24:58.007270-05:00 ninja81.ccs.ornl.gov kernel: FS:  
00007fb072a3a740(0000) GS:ffff88885ec00000(0000) knlGS:00000000
00000000
2020-01-06T16:24:58.007334-05:00 ninja81.ccs.ornl.gov kernel: RAX: 
0000000000000000 RBX: 0000000000000000 RCX: 0000000000000002
2020-01-06T16:24:58.007394-05:00 ninja81.ccs.ornl.gov kernel: RDX: 
0000000000000001 RSI: 0000000000000001 RDI: 00000000ffffffff
2020-01-06T16:24:58.007448-05:00 ninja81.ccs.ornl.gov kernel: CS:  0010 
DS: 0000 ES: 0000 CR0: 0000000080050033
2020-01-06T16:24:58.007505-05:00 ninja81.ccs.ornl.gov kernel: CR2: 
000000000000000c CR3: 00000007cd282001 CR4: 00000000001606e0
2020-01-06T16:24:58.007562-05:00 ninja81.ccs.ornl.gov kernel: RBP: 
ffffc9000944bcf0 R08: 0000000000000000 R09: 0000000000000000
2020-01-06T16:24:58.007616-05:00 ninja81.ccs.ornl.gov kernel: Call Trace:
2020-01-06T16:24:58.007669-05:00 ninja81.ccs.ornl.gov kernel: R10: 
0000000000000000 R11: 000000000000000f R12: ffff8887d0562640
2020-01-06T16:24:58.007727-05:00 ninja81.ccs.ornl.gov kernel: R13: 
000000137118a4ee R14: ffffc9000944bcf0 R15: 0000000000000000
2020-01-06T16:24:58.007780-05:00 ninja81.ccs.ornl.gov kernel: 
__d_lookup_rcu+0x183/0x1e0
2020-01-06T16:24:58.007832-05:00 ninja81.ccs.ornl.gov kernel: 
__d_lookup_rcu+0x183/0x1e0
2020-01-06T16:24:58.007885-05:00 ninja81.ccs.ornl.gov kernel: 
d_alloc_parallel+0x15e/0x7c0
2020-01-06T16:24:58.007936-05:00 ninja81.ccs.ornl.gov kernel: 
d_alloc_parallel+0x15e/0x7c0
2020-01-06T16:24:58.007999-05:00 ninja81.ccs.ornl.gov kernel: ? 
__lookup_slow+0xf5/0x1d0
2020-01-06T16:24:58.008056-05:00 ninja81.ccs.ornl.gov kernel: ? 
__lookup_slow+0xf5/0x1d0
2020-01-06T16:24:58.008112-05:00 ninja81.ccs.ornl.gov kernel: ? 
wake_up_q+0x80/0x80
2020-01-06T16:24:58.008169-05:00 ninja81.ccs.ornl.gov kernel: ? 
_raw_spin_unlock_irq+0x34/0x50

This might be resolved with

https://review.whamcloud.com/#/c/24175

I also have started working through the 2.13 release. I'm up to 2.12.54
but no heavy testing as of yet of those patches. Once I'm done testing
2.12 in depth I can push quickly through 2.13 and even sync up to
OpenSFS branch. I think the back porting work can be wrapped up by the
end of the month.
 
>  Instead, I am developing a tool which will compare OpenSFS lustre
>  and Linux-lustre and report relevant differences.  I have a prototype
>  working, and it is helping me to find missing patches and parts of
>  patches in both trees.
> 
>  I will continue to submit patches to gerrit to bring OpenSFS closer to
>  my linux tree when that is needed, and will apply patches from OpenSFS
>  to my tree without extra review when that it needed.
> 
>  When the time comes to submit upstream, I plan to present the tool so
>  that other developers can confirm that what I am submitting is
>  functionally equivalent to OpenSFS, and so that we can ensure the
>  equivalence remains.
> 
>  Consequently my "lustre" branch will jump forward to v5.4 soon,
>  probably tomorrow, and will remain close to mainline.
>  I will also be growing my list of outstanding OpenSFS patches
>  (currently about 100, many of which haven't been submitted to gerrit
>  yet) and will hope to get those reviewed.  Any changes that result from
>  the review will be detected by my comparison script when the patch
>  lands, and I'll update linux-lustre to match.
> 
>  My new goal for upstream submission is the end of Q1-2020.  This is
>  probably a bit optimistic, but gives me a suitable focus.

I believe having it ready for LUG 2020 is a reasonable goal.
