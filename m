From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jun 2016 04:02:40 +0100 (BST)
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs
 and small MDs in own kmem_caches
In-Reply-To: <20160610163610.GA20291@kroah.com>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-3-git-send-email-jsimmons@infradead.org>
	<20160610012833.GA6804@kroah.com>
	<B6A45EE2-D900-4578-AC42-4F5933F945DA@intel.com>
	<20160610163610.GA20291@kroah.com>
Message-ID: <alpine.LFD.2.20.1606150400230.17751@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Faccini, Bruno" <bruno.faccini@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> > This may also possibly help to save cycles due to high usage and
> > contention when using a generic kmem_cache (when they stay separate
> > from others, thanks for the precision!).
> 
> Have you measured this?
> 
> This isn't applicable for 4.7-rc at this time, _unless_ it fixes a bug,
> which is why I pushed back on this.  If you want your own cache for
> these variables, fine, I don't care, but that makes it a 4.8-rc1 patch
> instead.
> 
> hope that helps explain things better,

As a side question when is the window to push patches of this class?
Is it when 4.7-rc7 is merged to staging? 
