From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 3 Feb 2017 11:28:48 -0800
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170203190816.GK27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
	<20170203072952.GI27291@ZenIV.linux.org.uk>
	<CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
	<20170203190816.GK27291@ZenIV.linux.org.uk>
Message-ID: <CA+55aFwXKPUoZ3R4ey03L6ksXCmGLNS=16aQ7gRO1=VXCMZx-A@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Steve Capper <steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, V9FS Developers <v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Fri, Feb 3, 2017 at 11:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On x86 it does.  I don't see anything equivalent in mm/gup.c one, and the
> only kinda-sorta similar thing (access_ok() in __get_user_pages_fast()
> there) is vulnerable to e.g. access via kernel_write().

Yeah, access_ok() is bogus. It needs to just check against TASK_SIZE
or whatever.

> doesn't look promising - access_ok() is never sufficient.  Something like
> _PAGE_USER tests in x86 one solves that problem, but if anything similar
> works for HAVE_GENERIC_RCU_GUP I don't see it.  Thus the question re
> what am I missing here...

Ok, I definitely agree that it looks like __get_user_pages_fast() just
needs to get rid of the access_ok() and replace it with a proper check
for the user address space range.

Looks like arm[64] and powerpc.are the current users. Adding in some
people involved with the original submission a few years ago.

I do note that the x86 __get_user_pages_fast() thing looks dodgy too.

In particular, we do it right in the *real* get_user_pages_fast(), see
commit 7f8189068726 ("x86: don't use 'access_ok()' as a range check in
get_user_pages_fast()"). But then the same bug was re-introduced when
the "irq safe" version was merged. As well as in the GENERIC_RCU_GUP
version.

Gaah. Apparently PeterZ copied the old buggy version before the fix
when he added __get_user_pages_fast() in commit 465a454f254e ("x86,
mm: Add __get_user_pages_fast()").

I guess it could be considered a merge error (both happened during the
2.6.31 merge window).

                   Linus
