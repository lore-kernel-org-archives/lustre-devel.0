From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 17 Jun 2016 20:32:03 -0700
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs
 and small MDs in own kmem_caches
In-Reply-To: <alpine.LFD.2.20.1606150400230.17751@casper.infradead.org>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-3-git-send-email-jsimmons@infradead.org>
	<20160610012833.GA6804@kroah.com>
	<B6A45EE2-D900-4578-AC42-4F5933F945DA@intel.com>
	<20160610163610.GA20291@kroah.com>
	<alpine.LFD.2.20.1606150400230.17751@casper.infradead.org>
Message-ID: <20160618033203.GA13004@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Faccini, Bruno" <bruno.faccini@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Jun 15, 2016 at 04:02:40AM +0100, James Simmons wrote:
> 
> > > This may also possibly help to save cycles due to high usage and
> > > contention when using a generic kmem_cache (when they stay separate
> > > from others, thanks for the precision!).
> > 
> > Have you measured this?
> > 
> > This isn't applicable for 4.7-rc at this time, _unless_ it fixes a bug,
> > which is why I pushed back on this.  If you want your own cache for
> > these variables, fine, I don't care, but that makes it a 4.8-rc1 patch
> > instead.
> > 
> > hope that helps explain things better,
> 
> As a side question when is the window to push patches of this class?
> Is it when 4.7-rc7 is merged to staging? 

You can send them to me anytime, I'll queue them up in my "-next" branch
to be merged in the next merge window.  Like I do for almost all lustre
patches that aren't bugfixes or regressions.

But I think you have a bigger problem here that you need to debug, using
a separate cache isn't going to solve that bug, only postpone you
finding it...

thanks,

greg k-h
