From: James Simmons <jsimmons@infradead.org>
Date: Sat, 10 Feb 2018 22:14:19 +0000 (GMT)
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <87r2pvkkl5.fsf@notabene.neil.brown.name>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1802102108430.5700@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> > +static inline bool
> > +lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
> > +{
> > +	int idx;
> > +
> > +	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
> > +	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
> > +	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
> > +	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
> > +	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
> > +	    !strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name))
> > +		return false;
> 
> Hi James and all,
>  This patch (8f18c8a48b736c2f in linux) is different from the
>  corresponding patch in lustre-release (60e07b972114df).
> 
> In that patch, the last clause in the 'if' condition is
> 
> +           strcmp(lsm1->lsm_md_pool_name,
> +                     lsm2->lsm_md_pool_name) != 0)
> 
> Whoever converted it to "!strcmp()" inverted the condition.  This is a
> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!
> 
> This causes many tests in the 'sanity' test suite to return
> -ENOMEM (that had me puzzled for a while!!).
> This seems to suggest that no-one has been testing the mainline linux
> lustre.
> It also seems to suggest that there is a good chance that there
> are other bugs that have crept in while no-one has really been caring.
> Given that the sanity test suite doesn't complete for me, but just
> hangs (in test_27z I think), that seems particularly likely.
> 
> 
> So my real question - to anyone interested in lustre for mainline linux
> - is: can we actually trust this code at all?
> I'm seriously tempted to suggest that we just
>   rm -r drivers/staging/lustre
> 
> drivers/staging is great for letting the community work on code that has
> been "thrown over the wall" and is not openly developed elsewhere, but
> that is not the case for lustre.  lustre has (or seems to have) an open
> development process.  Having on-going development happen both there and
> in drivers/staging seems a waste of resources.
> 
> Might it make sense to instead start cleaning up the code in
> lustre-release so as to make it meet the upstream kernel standards.
> Then when the time is right, the kernel code can be moved *out* of
> lustre-release and *in* to linux.  Then development can continue in
> Linux (just like it does with other Linux filesystems).
> 
> An added bonus of this is that there is an obvious path to getting
> server support in mainline Linux.  The current situation of client-only
> support seems weird given how interdependent the two are.
> 
> What do others think?  Is there any chance that the current lustre in
> Linux will ever be more than a poor second-cousin to the external
> lustre-release.  If there isn't, should we just discard it now and move
> on?

If you think that the OpenSFS/Intel branch (lustre-release) is the land
of milk and honey you are very wrong. Take for example the UAPI header
cleanup I push to the linux client several months ago. That work took
5 years to complete. I had to complete that work in the Intel branch
since it impacted our tools. This isn't the only example. I worked along
side Intel for increasing striping of a file to more then the 160 stripe
limit Lustre use to have. That work took 3 years to complete. If the
patch is more than one line it will normally take 1 to 2 months to land.
It is common to have patches 6 months or more in age.

This is one of the major reasons I'm involved in the upstream client
work. If lustre remains a tiny under manned community it is doomed to
remain a niche file system. For years I have tried to recruit new
developers to help out and even gave talks at lustre conferences on
internals. That effort was meet with little success. This is not the
case with the linux lustre client. We do have people contributing
including you. So the reality is that if we removed the lustre client
it would be at least 3+ years before the code would be ready to merged
back in. It would be another 3+ years before it left staging. Many
cleanups in the linux client which impact many lines of code have not
been ported to the Intel branch. It would take forever to get those in.
Honestly I gave up some time ago for those types of cleanups. The cleanups
done in the upstream client would have to be redone. What we really
need is to expand the community. Recently a lot of work has gone into
supporting Ubuntu for our utilities. I hope this helps to get Canonical
involved with the upstream lustre client.

The upstream client is not as bad as you think. A year ago no one in
their right mind would touch the upstream client but their are actually
sites using it today. Its not perfect but it is usable and it is improving
all the time. Yes we have quite a few bugs to squash that show up in
our test suite but the barrier to leaving staging is much much smaller
than it used to be. Once the number of bugs reported in test suite
becomes reasonable we can start auto testing patches posted here. The
ultimate goal is that as more people join in the linux client effort
and it becomes a full member of the broader linux open source community
that we can leave the Intel lustre-release branch in the dust. I believe
the future is much closer than you think.
