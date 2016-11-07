From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 04:10:16 +0000 (GMT)
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: obdclass: Add
 handling of error returned by lustre_cfg_new
In-Reply-To: <97207CF4-21C1-4351-92BF-6F28E7281CF6@intel.com>
References: <20161106171123.24929-1-christophe.jaillet@wanadoo.fr>
	<97207CF4-21C1-4351-92BF-6F28E7281CF6@intel.com>
Message-ID: <alpine.LFD.2.20.1611070404180.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, andreas.dilger@intel.com, gregkh@linuxfoundation.org, emoly.liu@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org


> On Nov 6, 2016, at 12:11 PM, Christophe JAILLET wrote:
> 
> > 'lustre_cfg_new()' can return ERR_PTR(-ENOMEM).
> > Handle these errors and propagate the error code to the callers.
> > 
> > Error handling has been rearranged in 'lustre_process_log()' with the
> > addition of a label in order to free some resources.
> 
> I wonder if we should just make it return NULL on allocation failure,
> and then at least the other error handling that is there (i.e. in your other patch)
> would become correct.
> This would make handling in mgc_apply_recover_logs incorrect, but it's already
> geared towards this sort of handling anyway, as it discards the passed error
> and sets ENOMEM unconditionally (just need to revert 3092c34a in a way).

The header lustre_cfg.h is meant to be a UAPI header file. It is used for 
our userland tools but with the current shape of lustre_cfg.h upstream our 
tools will not build with it. So having kzalloc and kfree in this header
is incorrect. To do this right I need to update our user land tools as 
well so we should hold off on these patches.
