From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 11 Apr 2016 21:05:08 -0700
Subject: [lustre-devel] [PATCH 01/17] staging: lustre: osc: fix race
 issues thanks to oap_lock
In-Reply-To: <1460294020-2111-2-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
	<1460294020-2111-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20160412040508.GA2578@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Apr 10, 2016 at 09:13:24AM -0400, James Simmons wrote:
> From: Sebastien Buisson <sbuisson@ddn.com>
> 
> Fix 'data race condition' defects found by Coverity version 6.5.0:
> 
> Data race condition (MISSING_LOCK)
> 
> Accessing variable without holding lock. Elsewhere,
> this variable is accessed with lock held.
> 
> This patch is dedicated to code fragments involving oap_lock.
> 
> Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2744
> Reviewed-on: http://review.whamcloud.com/6572
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/osc/osc_cache.c |    8 ++++++++
>  drivers/staging/lustre/lustre/osc/osc_io.c    |    2 ++
>  2 files changed, 10 insertions(+), 0 deletions(-)

This patch doesn't apply at all.  Can you rebase the whole series and
resend them?

thanks,

greg k-h
