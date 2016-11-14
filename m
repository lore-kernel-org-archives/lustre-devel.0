From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 14 Nov 2016 15:59:51 +0100
Subject: [lustre-devel] [PATCH 31/35] staging: lustre: obdclass: add
 export for lprocfs_stats_alloc_one()
In-Reply-To: <1478799065-24841-32-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
	<1478799065-24841-32-git-send-email-jsimmons@infradead.org>
Message-ID: <20161114145951.GA4245@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Chennaiah Palla <chennaiah.palla@seagate.com>

On Thu, Nov 10, 2016 at 12:31:01PM -0500, James Simmons wrote:
> From: Chennaiah Palla <chennaiah.palla@seagate.com>
> 
> When compiling the kernel without optimization, when using GCOV,
> the lprocfs_stats_alloc_one() symbol is not properly exported to
> other modules and causes the ptlrpc module to fail loading with
> an unknown symbol. Added EXPORT_SYMBOL(lprocfs_stats_alloc_one)
> so that this works properly.

No, let's fix this properly.  Please get rid of lprocfs_stats_lock(), or
if you _really_ need it, move it to a .c file.  Having it in a .h file
is just a mess, as this proves.

thanks,

greg k-h
