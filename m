From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 19:51:16 +0000 (GMT)
Subject: [lustre-devel] Do we need LOOKUP_CONTINUE in
 ll_revalidate_dentry()
In-Reply-To: <87pnusqozl.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1811260404040.32255@casper.infradead.org>
 <87pnusqozl.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1811261950090.25858@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Mon, Nov 26 2018, James Simmons wrote:
> 
> > Doing a compare to the OpenSFS branch I noticed this difference:
> >
> > diff --git a/drivers/staging/lustre/lustre/llite/dcache.c 
> > b/drivers/staging/lustre/lustre/llite/dcache.c
> > index 11b82c63..6ee0ec9 100644
> > --- a/drivers/staging/lustre/lustre/llite/dcache.c
> > +++ b/drivers/staging/lustre/lustre/llite/dcache.c
> > @@ -254,7 +254,7 @@ static int ll_revalidate_dentry(struct dentry *dentry,
> >          * to this dentry, then its lock has not been revoked and the
> >          * path component is valid.
> >          */
> > -       if (lookup_flags & LOOKUP_PARENT)
> > +       if (lookup_flags & (LOOKUP_CONTINUE | LOOKUP_PARENT))
> >                 return 1;
> >
> >         /* Symlink - always valid as long as the dentry was found */
> >
> > Is that needed for newer kernels?
> 
> LOOKUP_CONTINUE disappeared in 2011
> 
> Commit: 49084c3bb205 ("kill LOOKUP_CONTINUE")
> 
> LOOKUP_PARENT is the new LOOKUP_CONTINUE.

So its really

if (lookup_flags & (LOOKUP_PARENT | LOOKUP_PARENT))
	return  1;

in OpenSFS branch :-/
