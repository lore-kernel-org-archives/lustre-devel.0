From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 13 Feb 2017 13:40:52 -0800
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170213095616.GA18053@linaro.org>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
	<20170203072952.GI27291@ZenIV.linux.org.uk>
	<CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
	<20170203190816.GK27291@ZenIV.linux.org.uk>
	<CA+55aFwXKPUoZ3R4ey03L6ksXCmGLNS=16aQ7gRO1=VXCMZx-A@mail.gmail.com>
	<20170213095616.GA18053@linaro.org>
Message-ID: <CA+55aFz2UjH-Lz=Zoi1he3-FfHEkh3kqP8PfeOP-u_Br9=BQAw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steve Capper <steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, V9FS Developers <v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Mon, Feb 13, 2017 at 1:56 AM, Steve Capper <steve.capper@linaro.org> wrote:
>
> Okay so looking at what we have for access_ok(.) on arm64, my
> understanding is that we perform a 65-bit add/compare (in assembler) to
> see whether or not the range is below the current_thread_info->addr_limit.
> So I think this is a roundabout way of checking for no-wrap around and <= TASK_SIZE.

No, that's the problem. It's *not* testing against TASK_SIZE.

Because add_limit is not always TASK_SIZE. When you do
set_fs(KERNEL_DS), you set addr_limit to infinity.

And yes, the kernel does read and write calls too. Seldom, but it
happens. And walking the page tables with kernel addresses is not
supposed to work (sometimes it happens to work by mistake). So if
somebody finds a path that gets from that kind of situation into the
get_user_pages() interface, bad things happen.

                 Linus
