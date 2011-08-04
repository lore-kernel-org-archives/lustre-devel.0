From: Mark Hills <Mark.Hills@framestore.com>
Date: Thu, 4 Aug 2011 18:24:28 +0100 (BST)
Subject: [Lustre-devel] Bad page state after unlink (was Re: Hangs with
 cgroup memory controller)
In-Reply-To: <alpine.LFD.2.01.1107291504480.15112@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
	<BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
	<alpine.LFD.2.01.1107271922560.7176@sys880.ldn.framestore.com>
	<5DBD4462-2AAA-4657-9EBB-9633336DD972@whamcloud.com>
	<alpine.LFD.2.01.1107281415530.6411@sys880.ldn.framestore.com>
	<E33CBAC5-08FA-49CA-970C-605A4DBE7B3B@whamcloud.com>
	<alpine.LFD.2.01.1107291504480.15112@sys880.ldn.framestore.com>
Message-ID: <alpine.LFD.2.01.1108041707220.8709@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 29 Jul 2011, Mark Hills wrote:

[...]
> Hosts with Lustre mounted via an NFS gateway perform flawlessly for months 
> (and they still have Lustre modules loaded.) Whereas a host with Lustre 
> mounted directly (and no other changes) fails -- it can be made to block a 
> cgroup in 10 minutes or so.

Following this up, I seem to have a reproducable test case of a page bug, 
on a kernel with more debugging features.

At first it appeared with Bonnie. I looked more closely and the bug occurs 
on unlink() of the file shortly after it was written to. Presumably with 
pages still in the local cache (pending writes?) It seems unlink is 
affected, but not truncate.

  $ dd if=/dev/zero of=/net/lustre/file bs=4096 count=1
  $ rm /net/lustre/file
  BUG: Bad page state in process rm  pfn:21fe6a
  page:ffffea00076fa730 flags:800000000000000c count:0 mapcount:0 mapping:(null) index:1

If there is a delay of a few seconds before the rm, all is okay. Truncate 
works, but a subsequent unlink rm can fail if it is quick enough.

The task does not need to be running in a cgroup for the "Bad page" to be 
reported, although the kernel is build with cgroup.

I can't be certain this is the same bug seen on the production system 
(which uses packaged kernel etc.) but it seems like a good start :-) It 
also correlates with it. It seems the production kernel glosses over this 
bug, but when a cgroup is used the symptoms start to show.

  $ uname -a
  Linux joker 2.6.32.28-mh #27 SMP PREEMPT Thu Aug 4 17:15:46 BST 2011 x86_64 x86_64 x86_64 GNU/Linux

  Lustre source: Git 9302433 (beyond v1_8_6_80)
  Reproduced with 1.8.6 server (Whamcloud release), and also 1.8.3.

Thanks

-- 
Mark


BUG: Bad page state in process rm  pfn:21fe6a
page:ffffea00076fa730 flags:800000000000000c count:0 mapcount:0 mapping:(null) index:1
Pid: 24724, comm: rm Tainted: G    B      2.6.32.28-mh #27
Call Trace:
 [<ffffffff81097ebc>] ? bad_page+0xcc/0x130
 [<ffffffffa059f119>] ? ll_page_removal_cb+0x1e9/0x4d0 [lustre]
 [<ffffffffa03b17a3>] ? __ldlm_handle2lock+0x93/0x3b0 [ptlrpc]
 [<ffffffffa04c6522>] ? cache_remove_lock+0x182/0x268 [osc]
 [<ffffffffa04ad95d>] ? osc_extent_blocking_cb+0x29d/0x2d0 [osc]
 [<ffffffff81383920>] ? _spin_unlock+0x10/0x30
 [<ffffffffa03b23a5>] ? ldlm_cancel_callback+0x55/0xe0 [ptlrpc]
 [<ffffffffa03cb3c7>] ? ldlm_cli_cancel_local+0x67/0x340 [ptlrpc]
 [<ffffffff81383920>] ? _spin_unlock+0x10/0x30
 [<ffffffffa03cd65a>] ? ldlm_cancel_list+0xea/0x230 [ptlrpc]
 [<ffffffffa02e1312>] ? lnet_md_unlink+0x42/0x2d0 [lnet]
 [<ffffffff81383920>] ? _spin_unlock+0x10/0x30
 [<ffffffffa03cd939>] ? ldlm_cancel_resource_local+0x199/0x2b0 [ptlrpc]
 [<ffffffffa029a629>] ? cfs_alloc+0x89/0xf0 [libcfs]
 [<ffffffffa04b0c22>] ? osc_destroy+0x112/0x720 [osc]
 [<ffffffffa05608ab>] ? lov_prep_destroy_set+0x27b/0x960 [lov]
 [<ffffffff8138374e>] ? _spin_lock_irqsave+0x1e/0x50
 [<ffffffffa054adc4>] ? lov_destroy+0x584/0xf40 [lov]
 [<ffffffffa05575ed>] ? lov_unpackmd+0x4bd/0x8e0 [lov]
 [<ffffffffa05d9e98>] ? ll_objects_destroy+0x4c8/0x1820 [lustre]
 [<ffffffffa03f7cbe>] ? lustre_swab_buf+0xfe/0x180 [ptlrpc]
 [<ffffffff8138374e>] ? _spin_lock_irqsave+0x1e/0x50
 [<ffffffffa05db940>] ? ll_unlink_generic+0x2e0/0x3a0 [lustre]
 [<ffffffff810d7309>] ? vfs_unlink+0x89/0xd0
 [<ffffffff810e634c>] ? mnt_want_write+0x5c/0xb0
 [<ffffffff810dac89>] ? do_unlinkat+0x199/0x1d0
 [<ffffffff810cc8d5>] ? sys_faccessat+0x1a5/0x1f0
 [<ffffffff8100b5ab>] ? system_call_fastpath+0x16/0x1b
