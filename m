From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Thu, 22 Jul 2010 22:19:55 +0400
Subject: [Lustre-devel] clio layer & portability
In-Reply-To: <201007221626.o6MGQOPm016424@hedwig.cmf.nrl.navy.mil>
References: <AANLkTilh5j1mgazvNUyb-gvMhfcYcOYlWfo1DHSSULpc@mail.gmail.com>
	<201007221626.o6MGQOPm016424@hedwig.cmf.nrl.navy.mil>
Message-ID: <AANLkTimly2Dz5LgHgCzF4qcHMdcfyZLl7s-EOXfwBLjl@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 22 July 2010 20:26, Ken Hornstein <kenh@cmf.nrl.navy.mil> wrote:
>>I am not sure I understand this one. CLIO has it own radix tree to
>>index cached pages precisely so that it doesn't depend on whatever
>>indexing mechanism the host kernel uses (see cl_page_find0()). There
>>are two implementations of a radix-tree in the public Lustre code: one
>>using Linux kernel lib/radix-tree.c and another for user space in
>>libcfs/posix/libcfs.h. I assume Solaris port has another one.
>
> Weeeelll .... I can't disagree with you, since you wrote that code, but
> from my viewpoint there are still a number of assumptions in the CLIO
> layer that seem (to my eye) very Linux-specific. ?E.g., the use of
> macros like PageWriteback, PageLocked, which from my extremely limited
> knowledge of MacOS X equivalents to those macros simply don't exist.

CLIO VM code (on a particular platform) consists of two parts: generic
code (in obdclass/cl_page.c) and a platform specific code. In the case
of Linux this platform specific code is in llite/vvp_page.c. The idea
is that there is an interface to struct cl_page, defined in
cl_object.h. vvp_page.c provides a particular implementation of this
interface. The rest of the CLIO interacts with VM through this
interface. For example, Page_Writeback() is used only in vvp_page.c to
implement vvp_page_completion_write() (it is also used by a few
assertions here and there, but all this can be removed). The latter
function is installed as cl_page_operations::cpo_completion. When
platform independent CLIO code needs to wait for IO completion it
calls cl_page_completion() that calls corresponding function pointer
cl_page_operations.

To port a client to another platform (VM-wise), one has to implement
all cl_page_operations for the platform. E.g., instead of using
PageWriteback(), you would have to implement
xnu_page_completion_write() via buf_biowait() or something.

cl_object.h explains the intended semantics of cl_page_operations and cl_page.

> If CLIO is more portable than I first thought, hey, great ... I've
> spent a long time trying to trace through the CLIO layers and when I
> find it quickly diving into Linux VM functions (sadly, things like the
> VM code you did for the Panther port aren't available), that worries
> and confuses me. ?Since the Linux port is really my only example, it's

There used to be a text document, explaining CLIO internals in some
detail, but I cannot find it anywhere. Perhaps somebody from Oracle
can help.

> hard to figure out the line between what the OS needs to provide versus
> what I can emulate on my own. ?I came to the conclusion that right now
> CLIO it was really really tied to the Linux VM system; if that's wrong,
> I'll freely own up to getting it wrong! :-)

I _hope_ it is wrong, it was designed so that this should be wrong,
but the only way to be really sure is to try it. :-)

>
>>The general assumption of CLIO data page caching is that pages (in
>>files and stripe objects) are indexed by their linear logical offset
>>(page index), that's all. Well, until you look at the direct-IO code
>>paths too closely. :-)
>
> Now, here's where we start running into termology issues: when you say
> "linear logical offset", do you mean from the beginning of each _file_,
> or something else? ?You never deal with anything called a "page index"
> on MacOS X that I've found, and the whole termology difference makes
> things more confusing.

(As an aside, terminology difficulties were almost unsurmountable when
Lustre client structure was discussed with Windows developers,
hopefully OSX is closer to Linux than descendants of RSX-NT lineage.)

Yes, page index is a number a page has in a file that is divided in
equally sized pages. One subtlety here is that a file (something that
can be open(2)-ed) is striped over "stripe objects" and these also
consist of pages. CLIO page is "layered": it binds together a file
page and corresponding stripe object page.

>
>>> management is handled (I'm not aware of any OS, other than Linux, that
>>> provides a callback that the OS can use if they are experiencing memory
>>> pressure to tell kernel modules to give up pages).
>>
>>I think any modern UNIX version does this. BSDs and Solaris have
>>PUT_PAGE() vnop. When I was porting Lustre to OS X (Panther times)
>>there used to be two ways to do this: at the UBC/VFS level and at the
>>UPL/Mach level, I am not sure how things work nowadays.
>
> I was thinking more about the shrinker interface, but on closer inspection
> that's not used by the CLIO layer; my apologies for saying otherwise. ?Of
> course you're right about the VNOP_PAGEOUT call (which you mention in your
> second email); that's the obvious choice.
>
> --Ken
>

Thank you,
Nikita.
