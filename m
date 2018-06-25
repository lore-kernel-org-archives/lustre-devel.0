From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 24 Jun 2018 20:38:02 -0400
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
Message-ID: <1ADABFB0-16E3-447C-B6F3-03674F324E1F@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Jun 24, 2018, at 8:02 PM, NeilBrown <neilb@suse.com> wrote:
> 
> 
> lustre sometimes uses the internal function truncate_complete_page()
> to remove a page of a directory.
> Must of what this function does, does not apply to directory pages
> as there is no invalidatepage function, and at these times, the
> page is not dirty.

> The only useful part of the function is delete_from_page_cache(),
> so just call that directly.

I guess this is also fine since we indeed do not have dirty directory
pages in Lustre

Acked-by: Oleg Drokin <green@linuxhacker.ru>

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/llite/dir.c       | 2 +-
> drivers/staging/lustre/lustre/mdc/mdc_request.c | 2 +-
> 2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 688dddf3ca47..52a8ecc2e2e0 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -168,7 +168,7 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
> 	if (remove) {
> 		lock_page(page);
> 		if (likely(page->mapping))
> -			truncate_complete_page(page->mapping, page);
> +			delete_from_page_cache(page);
> 		unlock_page(page);
> 	}
> 	put_page(page);
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index cff31cb0a9ac..827ed0ca0987 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -927,7 +927,7 @@ static void mdc_release_page(struct page *page, int remove)
> 	if (remove) {
> 		lock_page(page);
> 		if (likely(page->mapping))
> -			truncate_complete_page(page->mapping, page);
> +			delete_from_page_cache(page);
> 		unlock_page(page);
> 	}
> 	put_page(page);
> -- 
> 2.14.0.rc0.dirty
> 
