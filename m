From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 15 Nov 2011 01:47:07 -0800
Subject: [Lustre-devel] lustre-devel  packaging
In-Reply-To: <CAE66FB6.134A%bruce_korb@xyratex.com>
References: <CAE66FB6.134A%bruce_korb@xyratex.com>
Message-ID: <8B892676-E029-4052-8A98-9DACFD170C2E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-11-14, at 7:11 AM, Bruce Korb wrote:
> We at Xyratex are needing to develop some auxiliary utilities that
> need internal data structures from lustre.  To accomplish this, our
> sources have been reaching into the lustre build tree for the
> necessary headers.

That is messy, I agree.

> Not being a particular fan of that approach, I developed a patch for
> lustre that will create another RPM: a lustre-devel package.

I like the idea of having a separate lustre-devel package, since this
is fairly standard practise for other libraries and such.

My main question would be - do you _need_ to have access to all of the
headers that you included, or did you simply include all of the headers
because that was the easiest thing to do?  Doing a simple check on the
current master tree, it appears you just copied all of the headers in
libcfs/include, lnet/include, and lustre/include (which total 186 files).

By just copying everything into "public" headers, it is introducing a
maintenance nightmare, because it is no longer clear which APIs, structs,
constants, ioctls, etc. are private to Lustre or specific tools, and
which ones might possibly be used by external tools and would cause those
tools to break if they were changed for some reason.

> The other files installed as part of lustre-devel are object
> archives and library interface man pages:
> 
> usr/lib64/libcfsutil.a
> usr/lib64/liblustreapi.a
> usr/lib64/liblustre.a
> usr/lib64/libptlctl.a
> usr/lib64/libiam.a

Now that you post this list of libraries, it in fact appears that libiam
is not even used by userspace at all anymore.  From simple checking of
lustre/utils/Makefile.am, it only shows mkfs_lustre.c as a potential user,
and that doesn't seem to use it at all.  The creation of the object index
"oi.16", which is the only IAM-format index in the filesystem, is done in
the kernel since before Lustre 2.0 was released.


So, rather than simply copying everything that is available, it would be
much better to have a discussion about what APIs you are using (or which
ones you wish would be available), and then implement llapi_* wrappers
for those interfaces.  This would at least give some level of abstraction
from the low-level interfaces, and makes it much clearer which interfaces
are actually in use by tools that are not part of the Lustre package,
(and should try to remain relatively stable), and which interfaces, ioctls,
structures, etc. are for internal use only (or sometimes not in use at all).

> usr/share/lustre/mpich-1.2.6-lustre.patch

I think a significantly improved version this patch was already included
in the MPICH upstream release, and this one is obsolete.

> usr/share/man/man3/llapi_quotactl.3.gz
> usr/share/man/man3/llapi_file_open.3.gz
> usr/share/man/man3/llapi_file_create.3.gz
> usr/share/man/man3/llapi_file_get_stripe.3.gz

> 
> Below is my git-commit message.  Under separate cover, I'll post the
> git patch under the subject "[PATCH] lustre-devel packaging"

Looking at the descriptions, the patches look quite reasonable.  However,
you need to submit patches to Gerrit in order to get them inspected,
tested, and landed.  Please see:

http://wiki.whamcloud.com/display/PUB/Submitting+Changes

and in particular:

http://wiki.whamcloud.com/display/PUB/Using+Gerrit

There are a number of people at Xyratex already following this process
that you can likely ask for guidance.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
