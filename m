From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Thu, 24 Jul 2008 14:35:06 +0300
Subject: [Lustre-devel] statahead feature
In-Reply-To: <4888573F.4010506@sun.com>
References: <4888573F.4010506@sun.com>
Message-ID: <1216899306.16594.68.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2008-07-24 at 14:19 +0400, Alex Zhuravlev wrote:
> we think statahead should do nothing with dcache. it's about inodes
> and attributes
> only. thus, it would be good to decouple it from dcache. the only
> thing statahead
> should do is:
> 1) detect statahead is needed (policy, out of the message's scope)
> 2) scan part of directory (probably using readdir(), skip RPCs)
> 3) finds/creates inodes for found fids
> 4) lock these inodes (notice we propose to use inodes as a
> serialization point
>     so that lockless getattr can be used)
> 5) issue getattr RPCs (probably lockless)
> 6) unlock inodes upon getattr's completion

other point view - statahead never create dentry or inode, this function
(or thread) only send all need lock enqueue to MDS and put granted lock
to cache. user thread will call ->lookup and will be sleep until lock is
granted on mdc_enqueue so none new wait queue need.

At this case statahead will be very simple - call ->readdir() in
background, in fill callback skip dot/dotdot files, skip hidden files if
it not need, possible something other. in result new rpc added to
ptlrpcd or own set.
and very simple interpret callback which only process granted lock.

-- 
Alex Lyashkov <Alexey.lyashkov@sun.com>
Lustre Group, Sun Microsystems
