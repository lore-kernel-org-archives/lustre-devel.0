From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 10 Jun 2016 09:36:10 -0700
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs
 and small MDs in own kmem_caches
In-Reply-To: <B6A45EE2-D900-4578-AC42-4F5933F945DA@intel.com>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-3-git-send-email-jsimmons@infradead.org>
	<20160610012833.GA6804@kroah.com>
	<B6A45EE2-D900-4578-AC42-4F5933F945DA@intel.com>
Message-ID: <20160610163610.GA20291@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Faccini, Bruno" <bruno.faccini@intel.com>
Cc: James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Fri, Jun 10, 2016 at 03:25:28PM +0000, Faccini, Bruno wrote:
> Hello,
> The intent of this patch is not to solve the corruptions for sure, but
> only to avoid the concerned MEs/small-MDs LNet structs to be quite
> frequently impacted due to their high allocation/free rate.

But that's not what the patch description said :(

And again, putting them in a separate cache is not going to save much of
anything, given that your caches might have been merged together anyway.

> This may also possibly help to save cycles due to high usage and
> contention when using a generic kmem_cache (when they stay separate
> from others, thanks for the precision!).

Have you measured this?

This isn't applicable for 4.7-rc at this time, _unless_ it fixes a bug,
which is why I pushed back on this.  If you want your own cache for
these variables, fine, I don't care, but that makes it a 4.8-rc1 patch
instead.

hope that helps explain things better,

greg k-h
