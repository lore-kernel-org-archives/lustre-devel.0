From: James Simmons <jsimmons@infradead.org>
Date: Thu, 5 Jul 2018 23:50:39 +0100 (BST)
Subject: [lustre-devel] [PATCH 16/18] lustre: libcfs: restore original
 behavior in cfs_str2num_check
In-Reply-To: <87o9fp0vx1.fsf@notabene.neil.brown.name>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-17-git-send-email-jsimmons@infradead.org>
 <87o9fp0vx1.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1807052316160.12665@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Mon, Jul 02 2018, James Simmons wrote:
> 
> > When cfs_str2num_check() moved from simple_strtoul to kstrtoul
> > some of the functionality got lost. Restore handling hexidecimal
> > number as well as '+' and '-'. Also handle any trailing spaces.
> >
> > Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
> > Reviewed-on: https://review.whamcloud.com/32217
> > Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> > Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> > Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lnet/libcfs/libcfs_string.c | 17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> > index e1fb126..e390b0b 100644
> > --- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> > +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> > @@ -214,8 +214,10 @@ char *cfs_firststr(char *str, size_t size)
> >  {
> >  	bool all_numbers = true;
> >  	char *endp, cache;
> > +	int len;
> >  	int rc;
> >  
> > +	endp = strim(str);
> 
> This looks bad.  The function now changes the string buffer, where it
> didn't before.

So original this code uses simple_strtoul() which always parsed the string 
for numbers and succeded even if non digits existed in the string. In fact
you could get pointer to the first non-digit. That was also used to trim
the string. This behavior is very different from kstroul. I guess I will
need to duplicate the string and free it at the end.
 
> >  	/**
> >  	 * kstrouint can only handle strings composed
> >  	 * of only numbers. We need to scan the string
> > @@ -228,16 +230,25 @@ char *cfs_firststr(char *str, size_t size)
> >  	 * After we are done the character at the
> >  	 * position we placed '\0' must be restored.
> >  	 */
> > -	for (endp = str; endp < str + nob; endp++) {
> > -		if (!isdigit(*endp)) {
> > +	len = min((int)strlen(endp), nob);
> 
> As endp might be different from 'str, 'nob' is not meaningful in the
> context of endp.

I believe nob is supposed to be the string length of "str" itself. We
could error on the side caution and make that

len = min(strlen(endp), strlen(str));
  
> I'm guessing that mainline commit
> 
> Commit: c948390f10cc ("staging: lustre: llite: fix inconsistencies of root squash feature")
> 
> is related to this.

Actually it is commit ae0246da1603be7e7374621741515c2b6f2d6332 which ended 
up breaking my setup. I later debugged it and pushed the patch:

3ad6152d766039cb8ffd8633d971fb79402e5464

Later I pushed that patch to the OpenSFS branch and Hammond pointed out 
that some supported behaviors were lost. You can see this at:

https://review.whamcloud.com/#/c/32217/
 
> I cannot apply this patch as-is.  It is broken.  Possibly changing
>    endp = strim(str);
> to
>    endp = str;
> 
> will fix it.

I do see that the trim thing was removed in the root squash handling.
We might of returned a bug by mistake. 
