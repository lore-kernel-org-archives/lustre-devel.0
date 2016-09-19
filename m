From: Jan Kara <jack@suse.cz>
Date: Mon, 19 Sep 2016 11:59:14 +0200
Subject: [lustre-devel] [PATCH 030/124] staging: lustre: llite: Replace
 write mutex with range lock
In-Reply-To: <5FCA4C55-DF73-4AE8-8030-9A85B21A8A54@intel.com>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
	<1474231143-4061-31-git-send-email-jsimmons@infradead.org>
	<20160919072859.GA15407@kroah.com>
	<5FCA4C55-DF73-4AE8-8030-9A85B21A8A54@intel.com>
Message-ID: <20160919095914.GH11487@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jan Kara <jack@suse.cz>, James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, dbueso@suse.com

On Mon 19-09-16 09:25:48, Dilger, Andreas wrote:
> On Sep 19, 2016, at 09:28, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> > 
> > On Sun, Sep 18, 2016 at 04:37:29PM -0400, James Simmons wrote:
> >> + * Range lock is used to allow multiple threads writing a single shared
> >> + * file given each thread is writing to a non-overlapping portion of the
> >> + * file.
> >> + *
> >> + * Refer to the possible upstream kernel version of range lock by
> >> + * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
> >> + *
> >> + * This file could later replaced by the upstream kernel version.
> > 
> > It doesn't look like range_lock ever got accepted in the kernel tree,
> > any idea what happened to it?  Having a per-filesystem lock type seems
> > odd to me...
> 
> I've added Jan and linux-fsdevel to the CC list to see what interest
> there is in the range locking implementaion.  At the time we added this
> to Lustre it appeared that this was moving nicely torward landing, but
> it seems to have stalled.
> 
> I think the range locking implementation is fairly generic, and if there
> are other users in the kernel it could easily be pulled out of the staging
> dir into vfs/.  I'm not against it going into vfs/ directly either, but
> not sure whether that is acceptable if the only user is in staging.

Yeah, so the problem with my range_lock implementation (and your one looks
fairly similar from a quick look) is that it is fairly heavyweight. That
may be OK for an inode_lock replacement but it needs a careful
benchmarking. Davidlohr was looking into making the implementation more
efficient (he wanted to use it for mmap_sem) but I think it got preempted
by other work.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
