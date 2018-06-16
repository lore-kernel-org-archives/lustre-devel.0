From: James Simmons <jsimmons@infradead.org>
Date: Sat, 16 Jun 2018 01:17:37 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/24] lustre: use truncate_inode_page in
 place of truncate_complete_page
In-Reply-To: <152904669032.10587.11474850109829193046.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
Message-ID: <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Carrying a local truncate_complete_page() is not good
> for maintainability.  Linux now used truncate_inode_page,
> so use that instead.
> For correct use, we need to pass the mapping to mdc_release_page()
> rather than trusting page->mapping.

Nak: truncate_inode_page is not exported so it fails to build when lustre
is configured as a module.
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/lustre_patchless_compat.h       |   16 ----------------
>  drivers/staging/lustre/lustre/llite/dir.c          |    3 +--
>  .../staging/lustre/lustre/llite/llite_internal.h   |    4 ++--
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |   12 ++++++------
>  4 files changed, 9 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> index 298476ea7557..dca1e3dbd183 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> @@ -41,22 +41,6 @@
>  #include <linux/hash.h>
>  #include <linux/pagemap.h>
>  
> -#define ll_delete_from_page_cache(page) delete_from_page_cache(page)
> -
> -static inline void
> -truncate_complete_page(struct address_space *mapping, struct page *page)
> -{
> -	if (page->mapping != mapping)
> -		return;
> -
> -	if (PagePrivate(page))
> -		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
> -
> -	cancel_dirty_page(page);
> -	ClearPageMappedToDisk(page);
> -	ll_delete_from_page_cache(page);
> -}
> -
>  #ifndef ATTR_CTIME_SET
>  /*
>   * set ATTR_CTIME_SET to a high value to avoid any risk of collision with other
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 688dddf3ca47..cc5869cf9f93 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -167,8 +167,7 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
>  
>  	if (remove) {
>  		lock_page(page);
> -		if (likely(page->mapping))
> -			truncate_complete_page(page->mapping, page);
> +		truncate_inode_page(inode->i_mapping, page);
>  		unlock_page(page);
>  	}
>  	put_page(page);
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index c08a6e14b6d7..28cff58690d6 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -938,11 +938,11 @@ static inline void ll_invalidate_page(struct page *vmpage)
>  		return;
>  
>  	/*
> -	 * truncate_complete_page() calls
> +	 * truncate_inode_page() calls
>  	 * a_ops->invalidatepage()->cl_page_delete()->vvp_page_delete().
>  	 */
>  	ll_teardown_mmaps(mapping, offset, offset + PAGE_SIZE);
> -	truncate_complete_page(mapping, vmpage);
> +	truncate_inode_page(mapping, vmpage);
>  }
>  
>  #define    ll_s2sbi(sb)	(s2lsi(sb)->lsi_llsbi)
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index cff31cb0a9ac..856e6a376852 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -922,12 +922,12 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
>  	return 0;
>  }
>  
> -static void mdc_release_page(struct page *page, int remove)
> +static void mdc_release_page(struct address_space *mapping,
> +			     struct page *page, int remove)
>  {
>  	if (remove) {
>  		lock_page(page);
> -		if (likely(page->mapping))
> -			truncate_complete_page(page->mapping, page);
> +		truncate_inode_page(mapping, page);
>  		unlock_page(page);
>  	}
>  	put_page(page);
> @@ -981,7 +981,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
>  			       offset, *start, *end, *hash);
>  			if (*hash > *end) {
>  				kunmap(page);
> -				mdc_release_page(page, 0);
> +				mdc_release_page(mapping, page, 0);
>  				page = NULL;
>  			} else if (*end != *start && *hash == *end) {
>  				/*
> @@ -991,7 +991,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
>  				 * fetch the page we want.
>  				 */
>  				kunmap(page);
> -				mdc_release_page(page,
> +				mdc_release_page(mapping, page,
>  						 le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
>  				page = NULL;
>  			}
> @@ -1365,7 +1365,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
>  	return rc;
>  fail:
>  	kunmap(page);
> -	mdc_release_page(page, 1);
> +	mdc_release_page(mapping, page, 1);
>  	rc = -EIO;
>  	goto out_unlock;
>  }
> 
> 
> 
