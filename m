From: James Simmons <jsimmons@infradead.org>
Date: Sat, 16 Jun 2018 15:33:59 +0100 (BST)
Subject: [lustre-devel] testing lustre-testing
Message-ID: <alpine.LFD.2.21.1806161533400.8039@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


I tried your latest tree and it crash at start up with:

2018-06-16 10:16:01 [  150.547229] RIP: 
0010:deactivate_slab.isra.69+0x170/0x650
2018-06-16 10:16:01 [  150.553650] RSP: 0018:ffffc90000053a88 EFLAGS: 
00010082
2018-06-16 10:16:01 [  150.559871] RAX: 845da87dd009dac1 RBX: 
ffff8808535c0700 RCX: 000000018040002d
2018-06-16 10:16:01 [  150.567988] RDX: 000000018040002e RSI: 
0000000000000000 RDI: 0000000000000000
2018-06-16 10:16:01 [  150.576071] RBP: ffffc90000053b88 R08: 
ffff88085fc24050 R09: ffff88085f8000c0
2018-06-16 10:16:01 [  150.584131] R10: 0000000000000001 R11: 
0000000000000007 R12: ffffea00214d7000
2018-06-16 10:16:01 [  150.592163] R13: ffff88085f803800 R14: 
845da87dd009dac1 R15: 00000000014080c0
2018-06-16 10:16:01 [  150.600176]  ? deactivate_slab.isra.69+0x595/0x650
2018-06-16 10:16:01 [  150.605831]  ? deactivate_slab.isra.69+0x595/0x650
2018-06-16 10:16:01 [  150.611464]  ? get_page_from_freelist+0x335/0x1410
2018-06-16 10:16:01 [  150.617091]  ? deactivate_slab.isra.69+0x595/0x650
2018-06-16 10:16:01 [  150.622711]  ___slab_alloc+0x70/0x580
2018-06-16 10:16:01 [  150.627187]  ? __get_vm_area_node+0x7a/0x160
2018-06-16 10:16:01 [  150.632275]  ? ___slab_alloc+0x70/0x580
2018-06-16 10:16:01 [  150.636928]  ? _cond_resched+0x15/0x30
2018-06-16 10:16:01 [  150.641486]  ? 
kmem_cache_alloc_node_trace+0x1ab/0x1f0
2018-06-16 10:16:01 [  150.647439]  ? alloc_vmap_area+0x81/0x370
2018-06-16 10:16:01 [  150.652248]  __slab_alloc+0xe/0x12
2018-06-16 10:16:01 [  150.656428]  kmem_cache_alloc_node_trace+0xca/0x1f0

Not the easiest to track down to why its crashing. Also based on other 
patches in flight it looks like their are questions about that changes.

For me should I not based my patches on lustre-testing and test it their 
so it is stable. Would you do testing of the lustre branch in that case
or do I need to make sure my patches apply to your tree? Note some patches
I have will collide with what you are doing.
