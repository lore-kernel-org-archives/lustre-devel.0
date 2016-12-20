From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 20 Dec 2016 10:10:34 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated
	initializers
In-Reply-To: <CAKRnqNLFM_96NK3QbeoF-zC4KTe8oc7Q-eejzPgkE==XUHrwkQ@mail.gmail.com>
References: <20161217010045.GA140343@beast>
	<alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
	<CAKRnqNLFM_96NK3QbeoF-zC4KTe8oc7Q-eejzPgkE==XUHrwkQ@mail.gmail.com>
Message-ID: <20161220071034.GL8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bruce Korb <bruce.korb@gmail.com>
Cc: James Simmons <jsimmons@infradead.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Bruno Faccini <bruno.faccini@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, "John L. Hammond" <john.hammond@intel.com>, Emoly Liu <emoly.liu@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Dec 19, 2016 at 08:47:50AM -0800, Bruce Korb wrote:
> On Mon, Dec 19, 2016 at 8:22 AM, James Simmons
> >> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> >> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> >> @@ -143,7 +143,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
> >>       int added = (mode == LCK_NL);
> >>       int overlaps = 0;
> >>       int splitted = 0;
> >> -     const struct ldlm_callback_suite null_cbs = { NULL };
> >> +     const struct ldlm_callback_suite null_cbs = { };
> >>
> >>       CDEBUG(D_DLMTRACE,
> >>              "flags %#llx owner %llu pid %u mode %u start %llu end %llu\n",
> >
> > Nak. Filling null_cbs with random data is a bad idea. If you look at
> > ldlm_lock_create() where this is used you have
> >
> > if (cbs) {
> >         lock->l_blocking_ast = cbs->lcs_blocking;
> >         lock->l_completion_ast = cbs->lcs_completion;
> >         lock->l_glimpse_ast = cbs->lcs_glimpse;
> > }
> >
> > Having lock->l_* point to random addresses is a bad idea.
> > What really needs to be done is proper initialization of that
> > structure. A bunch of patches will be coming to address this.
> 
> I'm not understanding the effect of the original difference.  If you
> specify any initializer, then all fields not specified are filled with
> zero bits. Any pointers are, perforce, NULL.  That should make both "{
> NULL }" and "{}" equivalent.

They are equivalent, yes, but people want to use a GCC plugin that
randomizes struct layouts for internal structures and the plugin doesn't
work when you use struct ordering to initialize the struct.  The plugin
requires that you use designated intializers.

regards,
dan carpenter
