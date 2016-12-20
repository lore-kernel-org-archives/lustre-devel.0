From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 20 Dec 2016 13:40:26 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated
	initializers
In-Reply-To: <alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
References: <20161217010045.GA140343@beast>
	<alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
Message-ID: <20161220104026.GM8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Bruno Faccini <bruno.faccini@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, "John L. Hammond" <john.hammond@intel.com>, Bruce Korb <bruce.korb@gmail.com>, Emoly Liu <emoly.liu@intel.com>, lustre-devel@lists.lustre.org

On Mon, Dec 19, 2016 at 04:22:58PM +0000, James Simmons wrote:
> 
> > Prepare to mark sensitive kernel structures for randomization by making
> > sure they're using designated initializers. These were identified during
> > allyesconfig builds of x86, arm, and arm64, with most initializer fixes
> > extracted from grsecurity.
> > 
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  drivers/staging/lustre/lustre/ldlm/ldlm_flock.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> > index 722160784f83..f815827532dc 100644
> > --- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> > +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> > @@ -143,7 +143,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
> >  	int added = (mode == LCK_NL);
> >  	int overlaps = 0;
> >  	int splitted = 0;
> > -	const struct ldlm_callback_suite null_cbs = { NULL };
> > +	const struct ldlm_callback_suite null_cbs = { };
> >  
> >  	CDEBUG(D_DLMTRACE,
> >  	       "flags %#llx owner %llu pid %u mode %u start %llu end %llu\n",
> 
> Nak. Filling null_cbs with random data is a bad idea.

You've misunderstood.  The plugin just changes how the struct is laid
out, it doesn't put data into the struct.  So this is fine.

The places where it's not fine are when the layout is required because
it's shared with userspace or set by the hardware.

regards,
dan carpenter
