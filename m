From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 7 Nov 2016 07:43:33 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: replace space
 indentation with tabs
In-Reply-To: <alpine.LFD.2.20.1611070351390.21293@casper.infradead.org>
References: <20161105000256.11714-1-nicholasjhanley@gmail.com>
	<alpine.LFD.2.20.1611070202090.21293@casper.infradead.org>
	<1478486861.13362.2.camel@perches.com>
	<alpine.LFD.2.20.1611070351390.21293@casper.infradead.org>
Message-ID: <20161107064333.GA6336@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Joe Perches <joe@perches.com>, devel@driverdev.osuosl.org, oleg.drokin@intel.com, andreas.dilger@intel.com, linux-kernel@vger.kernel.org, Nicholas Hanley <nicholasjhanley@gmail.com>, lustre-devel@lists.lustre.org

On Mon, Nov 07, 2016 at 03:55:36AM +0000, James Simmons wrote:
> 
> > On Mon, 2016-11-07 at 02:02 +0000, James Simmons wrote:
> > > > This patch fixes all CODE_INDENT checkpatch errors in o2iblnd.
> > > Reviewed-by: James Simmons <jsimmons@infradead.org>
> > []
> > > > diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> > []
> > > > @@ -1637,7 +1637,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
> > > >  {
> > > >  	__u64 *pages = tx->tx_pages;
> > > >  	bool is_rx = (rd != tx->tx_rd);
> > > > -        bool tx_pages_mapped = 0;
> > > > +	bool tx_pages_mapped = 0;
> > 
> > It's generally better to use bool assignments to true/false not 1/0.
> 
> Nicholas can you resubmit with tx_pages_mapped = false. Looking at the 
> lustre code its the only place like this. Thanks for pointing this out.

No, make it a separate patch, don't change code when you are just
changing indentation in the same patch.
