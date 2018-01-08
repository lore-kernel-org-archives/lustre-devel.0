From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 8 Jan 2018 15:45:58 +0100
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: lnet: convert
 selftest to use workqueues
In-Reply-To: <151356031919.15912.12406337913485020577.stgit@noble>
References: <151356013394.15912.9645528414310488005.stgit@noble>
 <151356031919.15912.12406337913485020577.stgit@noble>
Message-ID: <20180108144558.GA6826@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>

On Mon, Dec 18, 2017 at 12:25:19PM +1100, NeilBrown wrote:
> Instead of the cfs workitem library, use workqueues.
> 
> As lnet wants to provide a cpu mask of allowed cpus, it
> needs to be a WQ_UNBOUND work queue so that tasks can
> run on cpus other than where they were submitted.

This patch doesn't apply to my tree :(

> apply_workqueue_atts needs to be exported for lustre to use it.

That feels really odd, why is lustre so "special" that the normal
workqueue api doesn't work properly for it?

I've dropped this, and the next patch, from my queue now.  Please fix up
and resend and justify why lustre is so odd :)

thanks,

greg k-h
