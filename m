From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 15 Jan 2018 15:48:19 +0100
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: lnet: convert
 selftest to use workqueues
In-Reply-To: <151564360053.21794.4058863911958997341.stgit@noble>
References: <151564345630.21794.1667069238139184132.stgit@noble>
 <151564360053.21794.4058863911958997341.stgit@noble>
Message-ID: <20180115144819.GA21012@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Tejun Heo <tj@kernel.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Thu, Jan 11, 2018 at 03:06:40PM +1100, NeilBrown wrote:
> Instead of the cfs workitem library, use workqueues.
> 
> As lnet wants to provide a cpu mask of allowed cpus, it
> needs to be a WQ_UNBOUND work queue so that tasks can
> run on cpus other than where they were submitted.
> 
> This patch also exported apply_workqueue_attrs() which is
> a documented part of the workqueue API, that isn't currently
> exported.  lustre needs it to allow workqueue thread to be limited
> to a subset of CPUs.
> 
> Acked-by: Tejun Heo <tj@kernel.org> (for export of apply_workqueue_attrs)
> Signed-off-by: NeilBrown <neilb@suse.com>

I now see the following build warning with this patch applied:

drivers/staging/lustre/lnet/selftest/module.c: In function ?lnet_selftest_init?:
drivers/staging/lustre/lnet/selftest/module.c:98:10: warning: ?rc? may be used uninitialized in this function [-Wmaybe-uninitialized]
   return rc;
          ^~

Care to send a follow-on patch to fix it up?

thanks,

greg k-h
