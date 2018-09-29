From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 22:33:21 +0100 (BST)
Subject: [lustre-devel] [PATCH 24/30] lustre: llite: rcu-walk check
 should not depend on statahead
In-Reply-To: <87r2hj4j9c.fsf@notabene.neil.brown.name>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-25-git-send-email-jsimmons@infradead.org>
 <87r2hj4j9c.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1809292232060.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Mon, Sep 17 2018, James Simmons wrote:
> 
> > From: Steve Guminski <stephenx.guminski@intel.com>
> >
> > Moves the check for the LOOKUP_RCU flag, so that it does not depend
> > on the statahead setting.  The caller is now informed if rcu-walk
> > was requested but the filesystem does not support it, regardless
> > of whether statahead is enabled or disabled.
> 
> Nope, this is wrong.
> 
> The filesystem only returns -ECHILD if it couldn't complete the request
> because it would have to block.
> If statahead is disabled, then it can complete the request immediately,
> doesn't need to block, and so doesn't need to return -ECHILD.
> 
> Patch deleted.

Do this patch need to be reverted in the OpenSFS branch or can it be
ignored?

> > Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-8891
> > Reviewed-on: https://review.whamcloud.com/24195
> > Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> > Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lustre/llite/dcache.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
> > index 11b82c63..ee1ba16 100644
> > --- a/drivers/staging/lustre/lustre/llite/dcache.c
> > +++ b/drivers/staging/lustre/lustre/llite/dcache.c
> > @@ -270,13 +270,12 @@ static int ll_revalidate_dentry(struct dentry *dentry,
> >  	if (lookup_flags & LOOKUP_REVAL)
> >  		return 0;
> >  
> > -	if (!dentry_may_statahead(dir, dentry))
> > -		return 1;
> > -
> >  	if (lookup_flags & LOOKUP_RCU)
> >  		return -ECHILD;
> >  
> > -	ll_statahead(dir, &dentry, !d_inode(dentry));
> > +	if (dentry_may_statahead(dir, dentry))
> > +		ll_statahead(dir, &dentry, !d_inode(dentry));
> > +
> >  	return 1;
> >  }
> >  
> > -- 
> > 1.8.3.1
> 
