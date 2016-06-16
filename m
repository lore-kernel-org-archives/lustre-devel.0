From: Faccini, Bruno <bruno.faccini@intel.com>
Date: Thu, 16 Jun 2016 14:14:51 +0000
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs
 and small MDs in own kmem_caches
In-Reply-To: <20160610163610.GA20291@kroah.com>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-3-git-send-email-jsimmons@infradead.org>
	<20160610012833.GA6804@kroah.com>
	<B6A45EE2-D900-4578-AC42-4F5933F945DA@intel.com>
	<20160610163610.GA20291@kroah.com>
Message-ID: <BC89894C-69F1-4F0D-84B5-53C0CEF93BD6@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Le Jun 10, 2016 ? 18:36, Greg Kroah-Hartman <gregkh at linuxfoundation.org<mailto:gregkh@linuxfoundation.org>> a ?crit :


A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

Thanks for the email formatting lesson! ;-) New comments/answers inlined ?

On Fri, Jun 10, 2016 at 03:25:28PM +0000, Faccini, Bruno wrote:
Hello,
The intent of this patch is not to solve the corruptions for sure, but
only to avoid the concerned MEs/small-MDs LNet structs to be quite
frequently impacted due to their high allocation/free rate.

But that?s not what the patch description said :(
True. This is mainly because the original patch text has not been changed, but if this patch (originally to debug <size-128> kmem_cache corruptions) has been kept to be integrated this comes from our reflexion that this could also be an enhancement.

And again, putting them in a separate cache is not going to save much of
anything, given that your caches might have been merged together anyway.

This may also possibly help to save cycles due to high usage and
contention when using a generic kmem_cache (when they stay separate
from others, thanks for the precision!).

Have you measured this?
No, but I will try to measure it.


This isn't applicable for 4.7-rc at this time, _unless_ it fixes a bug,
which is why I pushed back on this.  If you want your own cache for
these variables, fine, I don't care, but that makes it a 4.8-rc1 patch
instead.
I have no problem with that.


hope that helps explain things better,
Yes, definitely.


greg k-h

Thanks,
Bruno.

---------------------------------------------------------------------
Intel Corporation SAS (French simplified joint stock company)
Registered headquarters: "Les Montalets"- 2, rue de Paris, 
92196 Meudon Cedex, France
Registration Number:  302 456 199 R.C.S. NANTERRE
Capital: 4,572,000 Euros

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160616/4bd643bd/attachment.htm>
