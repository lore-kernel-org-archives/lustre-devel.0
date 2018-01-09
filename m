From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:29:28 +1100
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: lnet: convert
 selftest to use workqueues
In-Reply-To: <20180108144558.GA6826@kroah.com>
References: <151356013394.15912.9645528414310488005.stgit@noble>
 <151356031919.15912.12406337913485020577.stgit@noble>
 <20180108144558.GA6826@kroah.com>
Message-ID: <87shbfbz0n.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>

On Mon, Jan 08 2018, Greg Kroah-Hartman wrote:

> On Mon, Dec 18, 2017 at 12:25:19PM +1100, NeilBrown wrote:
>> Instead of the cfs workitem library, use workqueues.
>> 
>> As lnet wants to provide a cpu mask of allowed cpus, it
>> needs to be a WQ_UNBOUND work queue so that tasks can
>> run on cpus other than where they were submitted.
>
> This patch doesn't apply to my tree :(

Probably because some of the kmalloc changes didn't land, and that caused
a context change.

>
>> apply_workqueue_atts needs to be exported for lustre to use it.
>
> That feels really odd, why is lustre so "special" that the normal
> workqueue api doesn't work properly for it?

You could ask: what is so special about apply_workqueue_atts() that it
  isn't exported?  It seems as much a part of the workqueue api as
  anything else.  It is even documented in
     Documentation/core-api/workqueue.rst

lustre is using it to identify a subset of CPUs for the workqueue to run
on.
lustre allows workers to be restricted to select cpus to avoid
interfering with other tasks.  workqueue has an interface to support
this, it just forgot to export it.

I've added a note to the patch with some of this explanation,
and will re-post once the kmalloc changes land.

Thanks,
NeilBrown



>
> I've dropped this, and the next patch, from my queue now.  Please fix up
> and resend and justify why lustre is so odd :)
>
> thanks,
>
> greg k-h
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180109/8c281426/attachment.sig>
