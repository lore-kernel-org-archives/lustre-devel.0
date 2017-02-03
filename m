From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 3 Feb 2017 10:29:23 -0800
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170203072952.GI27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
	<20170203072952.GI27291@ZenIV.linux.org.uk>
Message-ID: <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, V9FS Developers <v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Thu, Feb 2, 2017 at 11:29 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> get_user_pages() relies upon find_extend_vma() to reject kernel
> addresses; the fast side of get_user_pages_fast() doesn't have anything
> of that sort

It is *supposed* to have it.

See pte_allows_gup(), for example. In particular, it requires the
_PAGE_USER bit in the PTE (and the devpte case should require
_PAGE_BIT_DEVMAP).

So no, get_user_pages_fast() can not look up kernel pages. If it does,
that would be a bug.

              Linus
