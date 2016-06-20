From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 20 Jun 2016 11:03:01 -0700
Subject: [lustre-devel] [PATCH v2 00/24] Delete CURRENT_TIME and
	CURRENT_TIME_SEC macros
In-Reply-To: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Dave Kleikamp <shaggy-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jfs-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>, Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, "adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org" <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, buchino-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, "Yan,
	Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Changman Lee <cm224.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, sramars-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>Linux

On Sun, Jun 19, 2016 at 5:26 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
> The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.

This version now looks ok to me.

I do have a comment (or maybe just a RFD) for future work.

It does strike me that once we actually change over the inode times to
use timespec64, the calling conventions are going to be fairly
horrendous on most 32-bit architectures.

Gcc handles 8-byte structure returns (on most architectures) by
returning them as two 32-bit registers (%edx:%eax on x86). But once it
is timespec64, that will no longer be the case, and the calling
convention will end up using a pointer to the local stack instead.

So for 32-bit code generation, we *may* want to introduce a new model of doing

    set_inode_time(inode, ATTR_ATIME | ATTR_MTIME);

which basically just does

    inode->i_atime = inode->i_mtime = current_time(inode);

but with a much easier calling convention on 32-bit architectures.

But that is entirely orthogonal to this patch-set, and should be seen
as a separate issue.

And maybe it doesn't end up helping anyway, but I do think those
"simple" direct assignments will really generate pretty disgusting
code on 32-bit architectures.

That whole

    inode->i_atime = inode->i_mtime = CURRENT_TIME;

model really made a lot more sense back in the ancient days when inode
times were just simply 32-bit seconds (not even timeval structures).

                  Linus
