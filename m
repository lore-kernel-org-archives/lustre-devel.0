From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Thu, 22 Jul 2010 19:43:48 +0400
Subject: [Lustre-devel] clio layer & portability
In-Reply-To: <201007221510.o6MFARem014801@hedwig.cmf.nrl.navy.mil>
References: <201007221510.o6MFARem014801@hedwig.cmf.nrl.navy.mil>
Message-ID: <AANLkTilh5j1mgazvNUyb-gvMhfcYcOYlWfo1DHSSULpc@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

On 22 July 2010 19:10, Ken Hornstein <kenh@cmf.nrl.navy.mil> wrote:
> In conversations with Andreas, he suggested I send some of this to a wider
> audience.
>
> Everyone knows by now I'm working on the MacOS X port, right? ?Okay, good.
>
> As part of that work, I've been working on attribute caching. ?Right now
> I'm hitting a bit of a snag when it comes to caching the file size; unlike
> all of the metadata attributes, this requires getting glimpse locks on
> the OSTs. ?And this starts bringing up the large outstanding issue of
> the clio layer.
>
> Specifically, clio has ... portability problems. ?The big one that
> crops up right away is the general assumption that OS memory pages are
> indexed via a radix tree. ?This sort of also ties into the way memory

I am not sure I understand this one. CLIO has it own radix tree to
index cached pages precisely so that it doesn't depend on whatever
indexing mechanism the host kernel uses (see cl_page_find0()). There
are two implementations of a radix-tree in the public Lustre code: one
using Linux kernel lib/radix-tree.c and another for user space in
libcfs/posix/libcfs.h. I assume Solaris port has another one.

The general assumption of CLIO data page caching is that pages (in
files and stripe objects) are indexed by their linear logical offset
(page index), that's all. Well, until you look at the direct-IO code
paths too closely. :-)

> management is handled (I'm not aware of any OS, other than Linux, that
> provides a callback that the OS can use if they are experiencing memory
> pressure to tell kernel modules to give up pages).

I think any modern UNIX version does this. BSDs and Solaris have
PUT_PAGE() vnop. When I was porting Lustre to OS X (Panther times)
there used to be two ways to do this: at the UBC/VFS level and at the
UPL/Mach level, I am not sure how things work nowadays.

I am not sure how it is possible to have a kernel without such a
call-back. When memory is low, the kernel has to free some pages, and
to free a dirty page is has to be written back first, and only a
corresponding file system knows how to do this, so some kind of a
"clean page" call seems necessary?

>
> Obviously these aren't new issues. ?For the first release of the MacOS port,
> I didn't use clio at all. ?But now it's coming up and I'm wondering ...
> since Lustre is now being ported to other OSes, what did everyone else
> do about these issues?
>
> --Ken

Thank you,
Nikita.

>
