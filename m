From: Faccini, Bruno <bruno.faccini@intel.com>
Date: Fri, 10 Jun 2016 15:25:28 +0000
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs
 and small MDs in own kmem_caches
In-Reply-To: <20160610012833.GA6804@kroah.com>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-3-git-send-email-jsimmons@infradead.org>
	<20160610012833.GA6804@kroah.com>
Message-ID: <B6A45EE2-D900-4578-AC42-4F5933F945DA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Hello,
The intent of this patch is not to solve the corruptions for sure, but only to avoid the concerned MEs/small-MDs LNet structs to be quite frequently impacted due to their high allocation/free rate. This may also possibly help to save cycles due to high usage and contention when using a generic kmem_cache (when they stay separate from others, thanks for the precision!).
Bye,
Bruno.

> Le Jun 10, 2016 ? 03:28, Greg Kroah-Hartman <gregkh@linuxfoundation.org> a ?crit :
> 
> On Thu, Jun 09, 2016 at 06:45:46PM -0400, James Simmons wrote:
>> From: Bruno Faccini <bruno.faccini@intel.com>
>> 
>> As part of LU-3848 and LU-4330, it has been discovered that LNET
>> MEs and small MDs (<=128 Bytes) are allocated in <size-128> kmem_cache
>> and thus can suffer quite frequent corruptions, from other modules or
>> Kernel parts, that occur there. To avoid this, MEs and small-MDs
>> specific kmem_cache have been created.
> 
> What?  Who corrupts them?  That shouldn't be possible, and on some
> systems, even if you do ask for a separate slab, it will be merged
> togther with others of the same size.  So this patch doesn't do all that
> much.
> 
> I think you are having some other problem here, changing to a separate
> memory cache shouldn't solve corruption issues.
> 
> sorry,
> 
> greg k-h

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
