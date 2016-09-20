From: James Simmons <jsimmons@infradead.org>
Date: Tue, 20 Sep 2016 16:52:07 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: re-export
 lustre_swab_[lmv|lov]_mds_md
In-Reply-To: <20160920111813.GA17691@kroah.com>
References: <1474306025-1942-1-git-send-email-jsimmons@infradead.org>
	<20160920111813.GA17691@kroah.com>
Message-ID: <alpine.LFD.2.20.1609201633080.3557@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Mon, Sep 19, 2016 at 01:27:05PM -0400, James Simmons wrote:
> > Being over zealous in removing unused EXPORT_SYMBOLs two functions
> > lustre_swab_[lmv|lov]_mds_md exports were removed. They need to be
> > exported so this patch restores those EXPORT_SYMBOLS. Same mistake
> > was done when porting to the upstream client.
> > 
> > Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> > Reviewed-on: http://review.whamcloud.com/14545
> > Reviewed-on: http://review.whamcloud.com/15159
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6486
> > Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> > Reviewed-by: John L. Hammond <john.hammond@intel.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> > index 1349bf6..8717685 100644
> > --- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> > +++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> > @@ -1861,6 +1861,7 @@ void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm)
> >  		break;
> >  	}
> >  }
> > +EXPORT_SYMBOL(lustre_swab_lmv_mds_md);
> 
> I don't see anyone else using this symbol, in fact, it could now be
> marked static.  So why export it?

Too soon to export it. A patch is coming in which the llite layer will use 
it. I will drop it and make a note to make sure for the upcoming patch 
that I export lustre_swab_lmv_mds_md.

> >  void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
> >  {
> > @@ -1914,6 +1915,7 @@ void lustre_swab_lov_mds_md(struct lov_mds_md *lmm)
> >  	__swab16s(&lmm->lmm_stripe_count);
> >  	__swab16s(&lmm->lmm_layout_gen);
> >  }
> > +EXPORT_SYMBOL(lustre_swab_lov_mds_md);
> 
> This is used by other files (it's listed twice in lustre_idl.h...), so
> it might need to be exported, but why am I not seeing a build error
> without this change?

The function lustre_swab_lov_mds_md is also used in lov_pack.c so it needs
to be exported. You shouldn't be able to load some of the lustre modules 
but it does on x86. I will send a new patch to fix this but a note about
this breakage should be kept so someone with an indepth understanding of 
the module system can track down what is going wrong.
