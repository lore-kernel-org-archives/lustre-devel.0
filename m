From: James Simmons <jsimmons@infradead.org>
Date: Mon, 5 Nov 2018 20:59:23 +0000 (GMT)
Subject: [lustre-devel] drivers/staging updated to 4.20-rc1
In-Reply-To: <87k1lsyssq.fsf@notabene.neil.brown.name>
References: <87k1lsyssq.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1811052058590.11915@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> 
> Hi,
>  I've just pushed out new lustre/lustre, lustre/lustre-testing, lustre/lustre-wip
>  to github.com:neilbrown/linux.git
> 
>  lustre is updated to 4.20-rc1 and doesn't compile because of some
>  changes.
>  The patch below makes it compile and (probably) work.
> 
>  I'd appreciate a review, especially of the iov_for_each change.

Almost. I see the following errors while testing.

[ 7111.002667] RIP: 0010:sanity+0xb2/0xb9
[ 7111.002668] Code: 63 c5 48 c7 c7 a1 7c e8 81 ff c5 48 6b c0 28 48 03 43 
78 8b 48 08 48 8b 70 10 44 8b 40 0c 48 8b 10 31 c0 e8 4c 67 d6 ff  c
[ 7111.002669] RSP: 0018:ffffc900072d3a60 EFLAGS: 00010246
[ 7111.002670] RAX: 000000000000002a RBX: ffff8808502126c0 RCX: 
0000000000000006
[ 7111.002671] RDX: 0000000000000000 RSI: ffffffff81e770e3 RDI: 
00000000ffffffff
[ 7111.002672] RBP: 0000000000000010 R08: 0000000000000004 R09: 
ffffffff82683e8e
[ 7111.002673] R10: 00000000000015a9 R11: 0000000000000000 R12: 
ffffea003f9523c0
[ 7111.002674] R13: ffff8808502126c0 R14: ffffea003f9523c0 R15: 
0000000000001000
[ 7111.002676] FS:  00007f140a193740(0000) GS:ffff88107fd80000(0000) 
knlGS:0000000000000000
[ 7111.002677] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7111.002678] CR2: 000000000067a198 CR3: 00000008305dc001 CR4: 
00000000000606e0
[ 7111.002679] Call Trace:
[ 7111.002682]  copy_page_to_iter+0x245/0x2f0
[ 7111.002686]  generic_file_buffered_read+0x345/0x7c0
[ 7111.002689]  ? touch_atime+0x33/0xd0
[ 7111.002701]  vvp_io_read_start+0x22a/0x3a0 [lustre]
[ 7111.002715]  cl_io_start+0x6d/0x130 [obdclass]
[ 7111.002727]  cl_io_loop+0xae/0x220 [obdclass]
[ 7111.002736]  ll_file_io_generic+0x4ee/0x880 [lustre]
[ 7111.002740]  ? generic_file_buffered_read+0x591/0x7c0
[ 7111.002749]  ll_file_read_iter+0x13e/0x1b0 [lustre]
[ 7111.002751]  generic_file_splice_read+0xe1/0x190
[ 7111.002755]  splice_direct_to_actor+0xea/0x200
[ 7111.002757]  ? generic_pipe_buf_nosteal+0x10/0x10
[ 7111.002759]  do_splice_direct+0x87/0xd0
[ 7111.002762]  do_sendfile+0x1c6/0x3c0
[ 7111.002765]  __x64_sys_sendfile64+0x5c/0xb0
[ 7111.002768]  do_syscall_64+0x68/0x38f
[ 7111.002770]  ? do_page_fault+0x2d/0x130
[ 7111.002773]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 7111.002775] RIP: 0033:0x7f1409ca71ca


 
> Thanks,
> NeilBrown
> 
> 
> Subject: [PATCH] lustre: fixes for 4.20-rc1
> 
> Most are trivial.
> iov_for_each() is broken upstream and there are no users in mainline,
> so it seem to make sense to just open-code it in the one place
> we use it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h | 4 ++--
>  drivers/staging/lustre/lustre/llite/vvp_io.c        | 5 ++++-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c     | 2 +-
>  3 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> index c882345226e1..7f81fe24c5eb 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> @@ -478,7 +478,7 @@ struct kib_rx {					/* receive message */
>  	enum ib_wc_status      rx_status;     /* completion status */
>  	struct kib_msg		*rx_msg;	/* message buffer (host vaddr) */
>  	__u64                  rx_msgaddr;    /* message buffer (I/O addr) */
> -	DECLARE_PCI_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
> +	DEFINE_DMA_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
>  	struct ib_recv_wr      rx_wrq;        /* receive work item... */
>  	struct ib_sge          rx_sge;        /* ...and its memory */
>  };
> @@ -501,7 +501,7 @@ struct kib_tx {					/* transmit message */
>  	struct lnet_msg		*tx_lntmsg[2];	/* lnet msgs to finalize on completion */
>  	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
>  	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
> -	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
> +	DEFINE_DMA_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
>  	/** sge for tx_msgaddr */
>  	struct ib_sge		tx_msgsge;
>  	int                   tx_nwrq;        /* # send work items */
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
> index 70d23874b674..524f3f4feec8 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_io.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
> @@ -388,7 +388,10 @@ static int vvp_mmap_locks(const struct lu_env *env,
>  	if (!mm)
>  		return 0;
>  
> -	iov_for_each(iov, i, *vio->vui_iter) {
> +	for (i = *vio->vui_iter;
> +	     i.count;
> +	     iov_iter_advance(&i, iov.iov_len)) {
> +		iov = iov_iter_iovec(&i);
>  		addr = (unsigned long)iov.iov_base;
>  		count = iov.iov_len;
>  		if (count == 0)
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 8f8e3d220dc8..2242204f3c9e 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -993,7 +993,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
>  	xa_lock_irq(&mapping->i_pages);
>  	found = radix_tree_gang_lookup(&mapping->i_pages,
>  				       (void **)&page, offset, 1);
> -	if (found > 0 && !radix_tree_exceptional_entry(page)) {
> +	if (found > 0 && !xa_is_value(page)) {
>  		struct lu_dirpage *dp;
>  
>  		get_page(page);
> -- 
> 2.14.0.rc0.dirty
> 
> 
