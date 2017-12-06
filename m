From: Greg KH <greg@kroah.com>
Date: Wed, 6 Dec 2017 19:40:14 +0100
Subject: [lustre-devel] [PATCH v2 1/2] staging: lustre: check result of
 register_shrinker
In-Reply-To: <dac170c9-86d2-ba08-3865-4240a426eacc@gmail.com>
References: <20171204191631.bkzaruzrlepp3rqy@mwanda>
 <20171204192157.4140-1-akaraliou.dev@gmail.com>
 <20171206085157.GA17896@kroah.com>
 <dac170c9-86d2-ba08-3865-4240a426eacc@gmail.com>
Message-ID: <20171206184014.GA10486@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Dec 06, 2017 at 08:40:43PM +0300, Aliaksei Karaliou wrote:
> On 12/06/2017 11:51 AM, Greg KH wrote:
> 
> > On Mon, Dec 04, 2017 at 10:21:56PM +0300, Aliaksei Karaliou wrote:
> > > Lustre code lacks checking the result of register_shrinker()
> > > in several places. register_shrinker() was tagged __must_check
> > > recently so that sparse has started reporting it.
> > > 
> > > Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> > > ---
> > >   drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 12 +++++++++---
> > >   drivers/staging/lustre/lustre/obdclass/lu_object.c |  5 +++--
> > >   drivers/staging/lustre/lustre/osc/osc_request.c    |  4 +++-
> > >   drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  8 +++++++-
> > >   4 files changed, 22 insertions(+), 7 deletions(-)
> > > 
> > > v2: Style fixes, as suggested by Cheers, Andreas and Dan Carpenter.
> > >      Added one more patch to address resource cleanup, suggested by Dan Carpenter.
> > > 
> > > diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> > > index da65d00a7811..9fef2d52d6c2 100644
> > > --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> > > +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> > > @@ -1086,10 +1086,16 @@ int ldlm_pools_init(void)
> > >   	int rc;
> > >   	rc = ldlm_pools_thread_start();
> > > -	if (rc == 0)
> > > -		register_shrinker(&ldlm_pools_cli_shrinker);
> > > +	if (rc)
> > > +		return rc;
> > > -	return rc;
> > > +	rc = register_shrinker(&ldlm_pools_cli_shrinker);
> > > +	if (rc) {
> > > +		ldlm_pools_thread_stop();
> > > +		return rc;
> > > +	}
> > > +
> > > +	return 0;
> > >   }
> > >   void ldlm_pools_fini(void)
> > > diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> > > index b938a3f9d50a..9e0256ca2079 100644
> > > --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> > > +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> > > @@ -1951,7 +1951,7 @@ int lu_global_init(void)
> > >   	 * inode, one for ea. Unfortunately setting this high value results in
> > >   	 * lu_object/inode cache consuming all the memory.
> > >   	 */
> > > -	register_shrinker(&lu_site_shrinker);
> > > +	result = register_shrinker(&lu_site_shrinker);
> > >   	return result;
> > 	return register_shrinker()?
> Yes, It looks easier, thank you for your comments.
> But still what to do with the fact that this changed place actually leads to
> resources being not freed (what I actually fix in second patch) ?
> Should I just merge both commits together ?

Don't write a patch that you know is broken, and then fix it up in a
follow-on patch.  That's not good at all.

Just fix one call-site at a time, that should be easier, right?

greg k-h
