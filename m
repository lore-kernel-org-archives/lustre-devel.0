From: NeilBrown <neilb@suse.com>
Date: Thu, 27 Sep 2018 11:03:19 +1000
Subject: [lustre-devel] [PATCH 13/25] lustre: lnet: fix lnet_cpt_of_md()
In-Reply-To: <1537930097-11624-14-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
 <1537930097-11624-14-git-send-email-jsimmons@infradead.org>
Message-ID: <87wor7hhuw.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 25 2018, James Simmons wrote:

> From: Amir Shehata <ashehata@whamcloud.com>
>
> The intent of this function is to get the cpt nearest to the
> memory described by the MD.
>
> There are three scenarios that must be handled:
> 1. The memory is described by an lnet_kiov_t structure
>  -> this describes kernel pages
> 2. The memory is described by a struct kvec
>  -> this describes kernel logical addresses
> 3. The memory is a contiguous buffer allocated via vmalloc
>
> For case 1 and 2 we look at the first vector which contains
> the data to be DMAed, taking into consideration the msg offset.
>
> For case 2 we have to take the extra step of translating the kernel
> logical address to a physical page using virt_to_page() macro.
>
> For case 3 we need to use is_vmalloc_addr() and vmalloc_to_page to
> get the associated page to be able to identify the CPT.
>
> o2iblnd uses the same strategy when it's mapping the memory into
> a scatter/gather list. Therefore, lnet_kvaddr_to_page() common
> function was created to be used by both the o2iblnd and
> lnet_cpt_of_md()
>
> kmap_to_page() performs the high memory check which
> lnet_kvaddr_to_page() does. However, unlike the latter it handles
> the highmem case properly instead of calling LBUG. It's not
> 100% clear why the code was written that way. Since the legacy
> code will need to still be maintained, adding kmap_to_page() will
> not simplify the code.  At worst calling kmap_to_page() might mask
> some problems which would've been caught by the LBUG earlier on.
> However, at the time of this fix, that LBUG has never been observed.
>
> Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9203
> Reviewed-on: https://review.whamcloud.com/28165
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |  3 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 25 +-----
>  drivers/staging/lustre/lnet/lnet/lib-md.c          | 96 ++++++++++++++++++----
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |  2 +-
>  4 files changed, 82 insertions(+), 44 deletions(-)
>
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 6bfdc9b..16e64d8 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -595,7 +595,8 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
>  
>  void lnet_md_unlink(struct lnet_libmd *md);
>  void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd);
> -int lnet_cpt_of_md(struct lnet_libmd *md);
> +struct page *lnet_kvaddr_to_page(unsigned long vaddr);
> +int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset);
>  
>  void lnet_register_lnd(struct lnet_lnd *lnd);
>  void lnet_unregister_lnd(struct lnet_lnd *lnd);
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index debed17..a6b261a 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -531,29 +531,6 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
>  	kiblnd_drop_rx(rx);		     /* Don't re-post rx. */
>  }
>  
> -static struct page *
> -kiblnd_kvaddr_to_page(unsigned long vaddr)
> -{
> -	struct page *page;
> -
> -	if (is_vmalloc_addr((void *)vaddr)) {
> -		page = vmalloc_to_page((void *)vaddr);
> -		LASSERT(page);
> -		return page;
> -	}
> -#ifdef CONFIG_HIGHMEM
> -	if (vaddr >= PKMAP_BASE &&
> -	    vaddr < (PKMAP_BASE + LAST_PKMAP * PAGE_SIZE)) {
> -		/* No highmem pages only used for bulk (kiov) I/O */
> -		CERROR("find page for address in highmem\n");
> -		LBUG();
> -	}
> -#endif
> -	page = virt_to_page(vaddr);
> -	LASSERT(page);

I think this would look cleaner as:

  page = kmap_to_page(vaddr);
  LASSERT(page);
  if (PageHighMem(page) {
		/* No highmem pages only used for bulk (kiov) I/O */
		CERROR("find page for address in highmem\n");
		LBUG();
  }

This avoids the #ifdef, and make the intention obvious.

NeilBrown


> -	return page;
> -}
> -
>  static int
>  kiblnd_fmr_map_tx(struct kib_net *net, struct kib_tx *tx, struct kib_rdma_desc *rd, __u32 nob)
>  {
> @@ -660,7 +637,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
>  
>  		vaddr = ((unsigned long)iov->iov_base) + offset;
>  		page_offset = vaddr & (PAGE_SIZE - 1);
> -		page = kiblnd_kvaddr_to_page(vaddr);
> +		page = lnet_kvaddr_to_page(vaddr);
>  		if (!page) {
>  			CERROR("Can't find page\n");
>  			return -EFAULT;
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
> index 9e26911..db5425e 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-md.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
> @@ -84,33 +84,93 @@
>  	kfree(md);
>  }
>  
> -int
> -lnet_cpt_of_md(struct lnet_libmd *md)
> +struct page *lnet_kvaddr_to_page(unsigned long vaddr)
>  {
> -	int cpt = CFS_CPT_ANY;
> +	if (is_vmalloc_addr((void *)vaddr))
> +		return vmalloc_to_page((void *)vaddr);
> +
> +#ifdef CONFIG_HIGHMEM
> +	return kmap_to_page((void *)vaddr);
> +#else
> +	return virt_to_page(vaddr);
> +#endif /* CONFIG_HIGHMEM */
> +}

if !CONFIG_HIGHMEM, kmap_to_page is exactly virt_to_page, so this code
should just use kmap_to_page();

> +EXPORT_SYMBOL(lnet_kvaddr_to_page);
>  
> -	if (!md)
> -		return CFS_CPT_ANY;
> +int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
> +{
> +	int cpt = CFS_CPT_ANY;
> +	unsigned int niov;
>  
> -	if ((md->md_options & LNET_MD_BULK_HANDLE) != 0 &&
> -	    md->md_bulk_handle.cookie != LNET_WIRE_HANDLE_COOKIE_NONE) {
> +	/*
> +	 * if the md_options has a bulk handle then we want to look at the
> +	 * bulk md because that's the data which we will be DMAing
> +	 */
> +	if (md && (md->md_options & LNET_MD_BULK_HANDLE) != 0 &&
> +	    md->md_bulk_handle.cookie != LNET_WIRE_HANDLE_COOKIE_NONE)
>  		md = lnet_handle2md(&md->md_bulk_handle);
>  
> -		if (!md)
> -			return CFS_CPT_ANY;
> -	}
> +	if (!md || md->md_niov == 0)
> +		return CFS_CPT_ANY;
> +
> +	niov = md->md_niov;
>  
> +	/*
> +	 * There are three cases to handle:
> +	 *  1. The MD is using lnet_kiov_t
> +	 *  2. The MD is using struct kvec
> +	 *  3. Contiguous buffer allocated via vmalloc
> +	 *
> +	 *  in case 2 we can use virt_to_page() macro to get the page
> +	 *  address of the memory kvec describes.
> +	 *
> +	 *  in case 3 use is_vmalloc_addr() and vmalloc_to_page()
> +	 *
> +	 * The offset provided can be within the first iov/kiov entry or
> +	 * it could go beyond it. In that case we need to make sure to
> +	 * look at the page which actually contains the data that will be
> +	 * DMAed.
> +	 */
>  	if ((md->md_options & LNET_MD_KIOV) != 0) {
> -		if (md->md_iov.kiov[0].bv_page)
> -			cpt = cfs_cpt_of_node(
> -				lnet_cpt_table(),
> -				page_to_nid(md->md_iov.kiov[0].bv_page));
> -	} else if (md->md_iov.iov[0].iov_base) {
> -		cpt = cfs_cpt_of_node(
> -			lnet_cpt_table(),
> -			page_to_nid(virt_to_page(md->md_iov.iov[0].iov_base)));
> +		struct bio_vec *kiov = md->md_iov.kiov;
> +
> +		while (offset >= kiov->bv_len) {
> +			offset -= kiov->bv_len;
> +			niov--;
> +			kiov++;
> +			if (niov == 0) {
> +				CERROR("offset %d goes beyond kiov\n", offset);
> +				goto out;
> +			}
> +		}
> +
> +		cpt = cfs_cpt_of_node(lnet_cpt_table(),
> +				      page_to_nid(kiov->bv_page));
> +	} else {
> +		struct kvec *iov = md->md_iov.iov;
> +		unsigned long vaddr;
> +		struct page *page;
> +
> +		while (offset >= iov->iov_len) {
> +			offset -= iov->iov_len;
> +			niov--;
> +			iov++;
> +			if (niov == 0) {
> +				CERROR("offset %d goes beyond iov\n", offset);
> +				goto out;
> +			}
> +		}
> +
> +		vaddr = ((unsigned long)iov->iov_base) + offset;
> +		page = lnet_kvaddr_to_page(vaddr);
> +		if (!page) {
> +			CERROR("Couldn't resolve vaddr 0x%lx to page\n", vaddr);
> +			goto out;
> +		}
> +		cpt = cfs_cpt_of_node(lnet_cpt_table(), page_to_nid(page));
>  	}
>  
> +out:
>  	return cpt;
>  }
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index f2bc97d..4d74421 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1226,7 +1226,7 @@
>  	 */
>  	cpt = lnet_net_lock_current();
>  
> -	md_cpt = lnet_cpt_of_md(msg->msg_md);
> +	md_cpt = lnet_cpt_of_md(msg->msg_md, msg->msg_offset);
>  	if (md_cpt == CFS_CPT_ANY)
>  		md_cpt = cpt;
>  
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180927/906fdc17/attachment.sig>
