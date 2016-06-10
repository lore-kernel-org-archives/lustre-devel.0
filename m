From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 9 Jun 2016 18:28:33 -0700
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: lnet: Allocate MEs
 and small MDs in own kmem_caches
In-Reply-To: <1465512347-11650-3-git-send-email-jsimmons@infradead.org>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-3-git-send-email-jsimmons@infradead.org>
Message-ID: <20160610012833.GA6804@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Bruno Faccini <bruno.faccini@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jun 09, 2016 at 06:45:46PM -0400, James Simmons wrote:
> From: Bruno Faccini <bruno.faccini@intel.com>
> 
> As part of LU-3848 and LU-4330, it has been discovered that LNET
> MEs and small MDs (<=128 Bytes) are allocated in <size-128> kmem_cache
> and thus can suffer quite frequent corruptions, from other modules or
> Kernel parts, that occur there. To avoid this, MEs and small-MDs
> specific kmem_cache have been created.

What?  Who corrupts them?  That shouldn't be possible, and on some
systems, even if you do ask for a separate slab, it will be merged
togther with others of the same size.  So this patch doesn't do all that
much.

I think you are having some other problem here, changing to a separate
memory cache shouldn't solve corruption issues.

sorry,

greg k-h
