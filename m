From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 16:22:11 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: grab the cld->cld_lock
 mutex unconditionally
In-Reply-To: <20170804071114.GA19799@yoga.localdomain>
References: <1501629149-6081-1-git-send-email-cakturk@gmail.com>
	<alpine.LFD.2.20.1708031749100.21881@casper.infradead.org>
	<20170803173115.GA1061@mbp>
	<20170804071114.GA19799@yoga.localdomain>
Message-ID: <alpine.LFD.2.20.1708141614360.14369@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Thu, Aug 03, 2017 at 08:31:15PM +0300, Cihangir Akturk wrote:
> > On Thu, Aug 03, 2017 at 05:52:44PM +0100, James Simmons wrote:
> > > 
> > > > Instead of using the locked variable as a helper to determine the state
> > > > of the mutex cld->cld_lock, expand the scope of the recover_cld variable
> > > > and assign to the cld->cld_recover variable depending on whether the
> > > > value of the recover_cld variable is valid or not.
> > > > 
> > > > As a bonus, code size is slightly reduced.
> > > > 
> > > > before:
> > > > text    data     bss     dec     hex filename
> > > > 26188    2256    4208   32652    7f8c drivers/staging/lustre/lustre/mgc/mgc_request.o
> > > > 
> > > > after:
> > > > text    data     bss     dec     hex filename
> > > > 26140    2256    4208   32604    7f5c drivers/staging/lustre/lustre/mgc/mgc_request.o
> > > > 
> > > > Additionally silences the following warning reported by coccinelle:
> > > > 
> > > > drivers/staging/lustre/lustre/mgc/mgc_request.c:359:2-12: second lock on
> > > > line 365
> > > > 
> > > > Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
> > > > ---
> > > >  drivers/staging/lustre/lustre/mgc/mgc_request.c | 13 ++++---------
> > > >  1 file changed, 4 insertions(+), 9 deletions(-)
> > > > 
> > > > diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> > > > index eee0b66..6718474 100644
> > > > --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> > > > +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> > > > @@ -288,7 +288,7 @@ config_log_add(struct obd_device *obd, char *logname,
> > > >  	struct config_llog_data *cld;
> > > >  	struct config_llog_data *sptlrpc_cld;
> > > >  	struct config_llog_data *params_cld;
> > > > -	bool locked = false;
> > > > +	struct config_llog_data *recover_cld = ERR_PTR(-EINVAL);
> > > >  	char			seclogname[32];
> > > >  	char			*ptr;
> > > >  	int			rc;
> > > 
> > > Why not just set it to NULL? 
> > 
> > Hi,
> > 
> > Because config_recover_log_add() function does not return NULL on
> > error. And I don't think IS_ERR on NULL pointer returns true.
> 
> Sorry, I've just realized I was wrong. Setting it to null makes
> perfect sense.

Setting it to NULL in this case is correct but you did point out a
bug that exist in our newer code. Currently I have a patch that fixes
config_log_put() so it return if its NULL but is doesn't check if its
a ERR_PTR. I updated a patch I have with this fix so thank you for
pointing it out.
 
 
> > 
> > Thanks.
> > 
> > > > @@ -338,8 +338,6 @@ config_log_add(struct obd_device *obd, char *logname,
> > > >  
> > > >  	LASSERT(lsi->lsi_lmd);
> > > >  	if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)) {
> > > > -		struct config_llog_data *recover_cld;
> > > > -
> > > >  		ptr = strrchr(seclogname, '-');
> > > >  		if (ptr) {
> > > >  			*ptr = 0;
> > > > @@ -355,14 +353,11 @@ config_log_add(struct obd_device *obd, char *logname,
> > > >  			rc = PTR_ERR(recover_cld);
> > > >  			goto out_cld;
> > > >  		}
> > > > -
> > > > -		mutex_lock(&cld->cld_lock);
> > > > -		locked = true;
> > > > -		cld->cld_recover = recover_cld;
> > > >  	}
> > > >  
> > > > -	if (!locked)
> > > > -		mutex_lock(&cld->cld_lock);
> > > > +	mutex_lock(&cld->cld_lock);
> > > > +	if (!IS_ERR(recover_cld))
> > > 
> > > Don't need this test if by default recover_cld = NULL.
> > > 
> > > > +		cld->cld_recover = recover_cld;
> > > >  	cld->cld_params = params_cld;
> > > >  	cld->cld_sptlrpc = sptlrpc_cld;
> > > >  	mutex_unlock(&cld->cld_lock);
> > > > -- 
> > > > 2.7.4
> > > > 
> > > > _______________________________________________
> > > > devel mailing list
> > > > devel at linuxdriverproject.org
> > > > http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
> > > > 
> 
