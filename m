From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 19 Sep 2016 09:25:48 +0000
Subject: [lustre-devel] [PATCH 030/124] staging: lustre: llite: Replace
 write mutex with range lock
In-Reply-To: <20160919072859.GA15407@kroah.com>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
	<1474231143-4061-31-git-send-email-jsimmons@infradead.org>
	<20160919072859.GA15407@kroah.com>
Message-ID: <5FCA4C55-DF73-4AE8-8030-9A85B21A8A54@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: "devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Drokin, Oleg" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Lustre Development List <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>

On Sep 19, 2016, at 09:28, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Sun, Sep 18, 2016 at 04:37:29PM -0400, James Simmons wrote:
>> + * Range lock is used to allow multiple threads writing a single shared
>> + * file given each thread is writing to a non-overlapping portion of the
>> + * file.
>> + *
>> + * Refer to the possible upstream kernel version of range lock by
>> + * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
>> + *
>> + * This file could later replaced by the upstream kernel version.
> 
> It doesn't look like range_lock ever got accepted in the kernel tree,
> any idea what happened to it?  Having a per-filesystem lock type seems
> odd to me...

I've added Jan and linux-fsdevel to the CC list to see what interest
there is in the range locking implementaion.  At the time we added this
to Lustre it appeared that this was moving nicely torward landing, but
it seems to have stalled.

I think the range locking implementation is fairly generic, and if there
are other users in the kernel it could easily be pulled out of the staging
dir into vfs/.  I'm not against it going into vfs/ directly either, but
not sure whether that is acceptable if the only user is in staging.

Cheers, Andreas
