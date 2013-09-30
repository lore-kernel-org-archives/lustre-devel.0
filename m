From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 30 Sep 2013 22:26:04 +0000
Subject: [Lustre-devel] portability in lustre code.
In-Reply-To: <D90080E4-C334-44D0-8879-7381E21C7390@xyratex.com>
Message-ID: <CE6AFA35.71B4B%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2013/09/21 2:39 AM, "Alexey Lyahkov" <alexey_lyashkov@xyratex.com>
wrote:
>I "happy" to see moving to lustre kernel generate a first results.
>my MacOS fuse client brooked to build after sources updates.
>
>In file included from
>/Users/shadow/work/lustre/work/WC-review/mac-os/libcfs/include/libcfs/posi
>x/libcfs.h:108,
>                 from
>/Users/shadow/work/lustre/work/WC-review/mac-os/libcfs/include/libcfs/libc
>fs.h:45,
>                 from nidstrings.c:43:
>/Users/shadow/work/lustre/work/WC-review/mac-os/libcfs/include/libcfs/user
>-bitops.h:80: error: conflicting types for ?fls?
>/usr/include/strings.h:90: error: previous declaration of ?fls? was here
>
>that bug introduced by commit
>>>
>commit d38d331fa6525ffc02665f48fa52f94626360631
>Author: James Simmons <uja.ornl@gmail.com>
>Date:   Tue Aug 27 12:51:06 2013 -0400
>
>    LU-1346 libcfs: cleanup macros in portals_compat25.h
>>> 
>so that commit - isn't correctly inspected for systems other to linux and
>introduce a new regression for systems other then Linux.
>I was pointed about similar situation in past - but hit that in real
>world.
>Andreas, did you remember my concerns about lost portability ?

Yes, I definitely remember this discussion.

As we discussed a year ago the MacOS, Windows, and liblustre code are
currently unused, and have been unmaintained since that time.  I don't
think it is reasonable for us to maintain this code for your private
FreeBSD Fuse port.  The code would need to continuously built and tested
in public for it to even consider it maintained at the most basic level.

Even prior to this recent compile problem, I would be incredibly surprised
if this code was working.  The liblustre code has been unmaintained since
Oracle times, and the Windows client has never been publicly released.
If MacOS _was_ working under your testing, it would have made sense to
share this code publicly last year.

>batch changes code in way without ability to replace a cfs specific
>function to any existent in build env.  and we don't have a way to the
>replace fls with flsl for MacOS/BSD or use own implementation without
>reverting a cleanup for fls function.

It would be fairly straight forward for you to apply a patch or run the
code through a sed script before build to replace the few conflicting names
with their equivalent MacOS functions.  This could be similar to how
ldiskfs is built from the ext4 code.

You are of course also free to keep a private or public branch of the code
for your own use.  We were planning to deleting the liblustre, MacOS, and
WinNT code entirely from the repository in the next release, because it is
unused and causes an ongoing maintenance and development complexity for
the Linux code without any benefit.  In particular, the abstractions in
CLIO are far more complex than they need to be for just Linux clients
because the Linux and MacOS VM/VFS interfaces are wildly different.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
