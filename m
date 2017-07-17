From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 17 Jul 2017 14:27:29 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: fix all braces
 issues reported by checkpatch
In-Reply-To: <1500133162-29310-1-git-send-email-jsimmons@infradead.org>
References: <1500133162-29310-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20170717122729.GC24503@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jul 15, 2017 at 11:39:22AM -0400, James Simmons wrote:
> Cleanup all braces that was reported by checkpatch. The only
> issue not fixed up is in mdc_lock.c. Removing the braces in
> the case of mdc_lock.c will break the build.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ------------------------------------------------------------------
> v1) Initial patch
> v2) Rebased against latest staging-next tree

Those lines go below:

> ---

That line.

I'll edit it by hand this time...
