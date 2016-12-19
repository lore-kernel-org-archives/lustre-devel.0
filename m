From: James Simmons <jsimmons@infradead.org>
Date: Mon, 19 Dec 2016 17:11:18 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated
 initializers
In-Reply-To: <CY4PR11MB175166F4D71AC6994081356BCB910@CY4PR11MB1751.namprd11.prod.outlook.com>
References: <20161217010045.GA140343@beast>,
	<alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
	<CY4PR11MB175166F4D71AC6994081356BCB910@CY4PR11MB1751.namprd11.prod.outlook.com>
Message-ID: <alpine.LFD.2.20.1612191708320.25173@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Farrell <paf@cray.com>
Cc: Kees Cook <keescook@chromium.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, Bruce Korb <bruce.korb@gmail.com>, Emoly Liu <emoly.liu@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>


> James,
> 
> 
> This should be a purely syntactical change, to help out tools - for GCC, I'm pretty sure the meaning of {
> } and { NULL } are the same.? Also, I don't think struct randomization does what you're thinking.

Yep. I misread his commit message. That is why it didn't make sense to 
me.

> Is there anything written up on kernel struct randomization?? I was trying to find a talk/post from you or
> something from LWN, but I couldn't find something about this specifically.? (Probably because I can't find
> it among the other stuff that's been written up)
> 
> 
> - Patrick
> 
> __________________________________________________________________________________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of James Simmons
> <jsimmons@infradead.org>
> Sent: Monday, December 19, 2016 10:22:58 AM
> To: Kees Cook
> Cc: devel at driverdev.osuosl.org; Greg Kroah-Hartman; linux-kernel at vger.kernel.org; Oleg Drokin; Vitaly
> Fertman; Bruce Korb; Emoly Liu; lustre-devel at lists.lustre.org
> Subject: Re: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated initializers ?
> 
> > Prepare to mark sensitive kernel structures for randomization by making
> > sure they're using designated initializers. These were identified during
> > allyesconfig builds of x86, arm, and arm64, with most initializer fixes
> > extracted from grsecurity.
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >? drivers/staging/lustre/lustre/ldlm/ldlm_flock.c | 2 +-
> >? 1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> > index 722160784f83..f815827532dc 100644
> > --- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> > +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> > @@ -143,7 +143,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
> >??????? int added = (mode == LCK_NL);
> >??????? int overlaps = 0;
> >??????? int splitted = 0;
> > -???? const struct ldlm_callback_suite null_cbs = { NULL };
> > +???? const struct ldlm_callback_suite null_cbs = { };
> >?
> >??????? CDEBUG(D_DLMTRACE,
> >?????????????? "flags %#llx owner %llu pid %u mode %u start %llu end %llu\n",
> 
> Nak. Filling null_cbs with random data is a bad idea. If you look at
> ldlm_lock_create() where this is used you have
> 
> if (cbs) {
> ??????? lock->l_blocking_ast = cbs->lcs_blocking;
> ??????? lock->l_completion_ast = cbs->lcs_completion;
> ??????? lock->l_glimpse_ast = cbs->lcs_glimpse;
> }
> 
> Having lock->l_* point to random addresses is a bad idea.
> What really needs to be done is proper initialization of that
> structure. A bunch of patches will be coming to address this.
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
> 
