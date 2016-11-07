From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 03:55:36 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: replace space
 indentation with tabs
In-Reply-To: <1478486861.13362.2.camel@perches.com>
References: <20161105000256.11714-1-nicholasjhanley@gmail.com>
	<alpine.LFD.2.20.1611070202090.21293@casper.infradead.org>
	<1478486861.13362.2.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1611070351390.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Nicholas Hanley <nicholasjhanley@gmail.com>, oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


> On Mon, 2016-11-07 at 02:02 +0000, James Simmons wrote:
> > > This patch fixes all CODE_INDENT checkpatch errors in o2iblnd.
> > Reviewed-by: James Simmons <jsimmons@infradead.org>
> []
> > > diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> []
> > > @@ -1637,7 +1637,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
> > >  {
> > >  	__u64 *pages = tx->tx_pages;
> > >  	bool is_rx = (rd != tx->tx_rd);
> > > -        bool tx_pages_mapped = 0;
> > > +	bool tx_pages_mapped = 0;
> 
> It's generally better to use bool assignments to true/false not 1/0.

Nicholas can you resubmit with tx_pages_mapped = false. Looking at the 
lustre code its the only place like this. Thanks for pointing this out.
