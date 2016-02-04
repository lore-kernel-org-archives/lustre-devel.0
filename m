From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 4 Feb 2016 19:03:32 +0000
Subject: [lustre-devel] "Notify_change" and range locking
In-Reply-To: <569EB487.7030906@cray.com>
References: <569EB487.7030906@cray.com>
Message-ID: <D2D8CE3E.12BF5B%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2016/01/19, 15:11, "lustre-devel on behalf of Patrick Farrell"
<lustre-devel-bounces at lists.lustre.org on behalf of paf@cray.com> wrote:

>Good afternoon,
>
>While looking at some logs from SLES12, I noticed something that's
>probably of larger concern.
>
>In the function "notify_change", which is called from file_remove_suid
>(Actually, from __remove_suid), which is called from
>__generic_file_aio_write, there is a comment saying the inode mutex must
>be held when calling this function.  (SLES12 has a WARN on this, which
>is why I noticed it)
>
>This requirement makes sense, since we're making various modifications
>to the inode in this function.  (We also update the times in the inode
>later in __generic_file_aio_write, which also seems like it might need
>protection.)
>
>With the range locking present in newer versions of Lustre (LU-6227), we
>call __generic_file_aio_write directly, without taking the inode mutex
>(previously, we called generic_file_aio_write, which takes the inode
>mutex).  This means we're calling remove_suid and notify_change when not
>holding the inode mutex.
>
>LU-6227 added range locking (in ll_file_io_generic) to allow Lustre to
>handle consistency on a node, so we could call __generic_file_aio_write
>directly.  But the range locking is not done when doing metadata only
>operations on the inode.
>
>So it seems like we have potential races between the inode modifications
>made in __generic_file_aio_write and any modifications made down the
>normal metadata path.
>
>I'm not sure exactly how this would present itself - or how best to
>resolve it - but at first glance, it seems very troubling.
>
>Any thoughts from the core developers?

Patrick, sorry for the delay in replying as I was on vacation and hoping
that someone else might reply in the meantime.  It's also been a while
since I looked at this part of the code.

It seems that there are two aspects to this issue that need to be
understood. 

Firstly, when there are multiple threads modifying the same file, are they
serialized on some other locks that are being held internally?  What do
filesystems like XFS (that also use the __generic_file_aio_write()
interface) do for i_mutex locking to avoid the WARN_ON() in
notify_change()?  Would it be enough to get i_mutex in ll_setattr_raw(),
or would that potentially cause lock inversion and need to be conditional
depending on the caller?  Is there another entry point from the write path
where i_mutex could be grabbed only around the notify_change() for the
write?

Secondly, when notify_change() is being called in such situations where no
locking is held, what fields in the inode are being changed?  It is
possible that there aren't any significant changes being made to the
inode, and we could just exit early from ll_setattr_raw() to avoid
entering any complex code paths that need to be mutually exclusive?

Cheers, Andreas
-- 
Andreas Dilger

Lustre Principal Architect
Intel High Performance Data Division
