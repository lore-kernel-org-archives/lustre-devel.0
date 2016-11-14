From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 14 Nov 2016 16:16:50 +0100
Subject: [lustre-devel] [PATCH 00/35] second batch of missing lustre 2.8
	patches
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20161114151650.GA12605@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Nov 10, 2016 at 12:30:30PM -0500, James Simmons wrote:
> More fixes missing from the upstream client. Also a nice cleanup
> with the removal of cl_req which is no longer needed. More cleanup
> for lustre_idl.h which is a uapi header. Like the last batch these
> patches are independent of order.

I didn't apply a few of these (string parsing stuff, and build
breakages.)

What's the plan for getting this out of staging?  I feel like you all
are still adding new features along with these "cleanups".  Normally
that's fine, but I really really want to get this out of staging as it's
been there for way too long.  When is that going to happen?

thanks,

greg k-h
