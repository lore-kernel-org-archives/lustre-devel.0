From: Siyao Lai <lai.siyao@whamcloud.com>
Date: Thu, 29 Nov 2018 12:06:12 +0000
Subject: [lustre-devel] [PATCH 06/12] lustre: mdc: don't add to page
 cache upon failure
In-Reply-To: <875zwjql4l.fsf@notabene.neil.brown.name>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
 <1543200508-6838-7-git-send-email-jsimmons@infradead.org>
 <875zwjql4l.fsf@notabene.neil.brown.name>
Message-ID: <DFD6BB83-222B-42E1-98DA-9DF41C8F5755@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

You're right, I'll fix it later.

Thanks,
Lai

?On 2018/11/27, 11:01 AM, "NeilBrown" <neilb@suse.com> wrote:

    On Sun, Nov 25 2018, James Simmons wrote:
    
    > From: Lai Siyao <lai.siyao@whamcloud.com>
    >
    > Reading directory pages may fail on MDS, in this case client should
    > not cache a non-up-to-date directory page, because it will cause
    > a later read on the same page fail.
    >
    > Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
    > WC-bug-id: https://jira.whamcloud.com/browse/LU-5461
    > Reviewed-on: http://review.whamcloud.com/11450
    > Reviewed-by: Fan Yong <fan.yong@intel.com>
    > Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
    > Reviewed-by: Oleg Drokin <green@whamcloud.com>
    > Signed-off-by: James Simmons <jsimmons@infradead.org>
    > ---
    >  drivers/staging/lustre/lustre/mdc/mdc_request.c | 5 ++++-
    >  1 file changed, 4 insertions(+), 1 deletion(-)
    >
    > diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
    > index 1072b66..09b30ef 100644
    > --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
    > +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
    > @@ -1212,7 +1212,10 @@ static int mdc_read_page_remote(void *data, struct page *page0)
    >  	}
    >  
    >  	rc = mdc_getpage(rp->rp_exp, fid, rp->rp_off, page_pool, npages, &req);
    > -	if (!rc) {
    > +	if (rc < 0) {
    > +		/* page0 is special, which was added into page cache early */
    > +		delete_from_page_cache(page0);
    
    This looks wrong to me.  We shouldn't need to delete the page from the
    page-cache.
    It won't be marked up-to-date, so why will that cause an error on a
    later read???
    
    Well, because mdc_page_locate() finds a page and if it isn't up-to-date,
    it returns -EIO.  Why does it do that?  If it found a PageError() page,
    then it might be reasonable to return -EIO.
    
    Why not just return the page that was found, and let the caller check if
    it is Uptodate?
    
    Well, because mdc_read_page() handles a successful page return from
    mdc_page_locate() as a hash collision.
    
    I guess I need to understand how lustre maps a hash to a directory
    block, and then how it handles collisions...
    
    The reason this jumped out at me is that it looks like it might be
    racy.  Adding a page and then removing it might leave a window where
    some other thread can find the page.  That is not a problem is a
    non-up-to-date page just means we should wait for it.  But if it can
    cause an error, then maybe the race is a real problem.
    
    But maybe there is some higher level locking...
    
    NeilBrown
    
