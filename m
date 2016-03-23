From: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
Date: Wed, 23 Mar 2016 16:43:39 -0400
Subject: [lustre-devel] [PATCH] Revert "Staging: lustre: o2iblnd: Use
 sizeof type *pointer instead of sizeof type."
In-Reply-To: <7dcad179d49c4535b4f24d3ceb85607a@EXCHCS32.ornl.gov>
References: <1458685264-22755-1-git-send-email-jsimmons@infradead.org>
	<20160323014916.GF3190@kroah.com>
	<D317846B.138487%andreas.dilger@intel.com>
	<20160323134107.GA4356@kroah.com>
	<bb9ab572a3944b38814b0533323e0299@EXCHCS32.ornl.gov>
	<1458758864.18165.4.camel@perches.com>
	<7dcad179d49c4535b4f24d3ceb85607a@EXCHCS32.ornl.gov>
Message-ID: <20160323204339.GA21923@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Simmons, James A." <simmonsja@ornl.gov>
Cc: 'Joe Perches' <joe@perches.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Mar 23, 2016 at 08:29:49PM +0000, Simmons, James A. wrote:
> 
> >> > > so the right code should be:
> >> > > 
> >> > > ????????sizeof(**net->ibn_tx_ps);
> >> > > and the same for sizeof(**net->ibn_fmr_ps)
> >> > That's a mess, isn't there some other way to fix this up to be more
> >> > "obvious"?
> >> This must have been encountered in the past. How was it handle in those
> >> other cases?
> >
> >I fail to see why it's a mess.  It's just **
> >and someone making a mistake.
> 
> I have no trouble with **.  If we revert it someone else will come along and
> do the same mistake so I think we are stuck with the change to **.

That's fine, but if you do that, just comment it well so that no one
tries to change it again.  That's why I can't accept the original patch
in this email thread.

thanks,

greg k-h
