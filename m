From: James Simmons <jsimmons@infradead.org>
Date: Tue, 26 Jun 2018 01:18:55 +0100 (BST)
Subject: [lustre-devel] [PATCH 2/3] lustre: use delete_from_page_cache()
 for directory pages.
In-Reply-To: <87in67ag28.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
 <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
 <87y3ffft80.fsf@notabene.neil.brown.name>
 <61C2F92E-8F88-49C6-83FB-F3013289265C@linuxhacker.ru>
 <877emwg8ao.fsf@notabene.neil.brown.name>
 <87lgb3ag3k.fsf@notabene.neil.brown.name>
 <87in67ag28.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806260118420.31196@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> lustre sometimes uses the internal function truncate_complete_page()
> to remove a page of a directory.
> Must of what this function does, does not apply to directory pages
> as there is no invalidatepage function, and at these times, the
> page is not dirty.
> The only useful part of the function is delete_from_page_cache(),
> so just call that directly.
> 

Reviewed-by: James Simmons <jsimmons@infradead.org>

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/llite/dir.c       | 2 +-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 688dddf3ca47..52a8ecc2e2e0 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -168,7 +168,7 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
>  	if (remove) {
>  		lock_page(page);
>  		if (likely(page->mapping))
> -			truncate_complete_page(page->mapping, page);
> +			delete_from_page_cache(page);
>  		unlock_page(page);
>  	}
>  	put_page(page);
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index cff31cb0a9ac..827ed0ca0987 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -927,7 +927,7 @@ static void mdc_release_page(struct page *page, int remove)
>  	if (remove) {
>  		lock_page(page);
>  		if (likely(page->mapping))
> -			truncate_complete_page(page->mapping, page);
> +			delete_from_page_cache(page);
>  		unlock_page(page);
>  	}
>  	put_page(page);
> -- 
> 2.14.0.rc0.dirty
> 
> 
