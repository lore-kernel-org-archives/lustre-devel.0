From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Mon, 20 Jun 2016 11:58:31 -0700
Subject: [lustre-devel] [PATCH v2 00/24] Delete CURRENT_TIME and
	CURRENT_TIME_SEC macros
In-Reply-To: <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
	<CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
Message-ID: <CABeXuvpzRy=qccBqq70iT_W9EGSfcpAjfyqkayUTT01F8Ghh5g@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Dave Kleikamp <shaggy-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jfs-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>, Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, "adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org" <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Brian Uchino <buchino-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, "Yan, Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Changman Lee <cm224.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Suma Ramars <sramars-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>

> This version now looks ok to me.
>
> I do have a comment (or maybe just a RFD) for future work.
>
> It does strike me that once we actually change over the inode times to
> use timespec64, the calling conventions are going to be fairly
> horrendous on most 32-bit architectures.
>
> Gcc handles 8-byte structure returns (on most architectures) by
> returning them as two 32-bit registers (%edx:%eax on x86). But once it
> is timespec64, that will no longer be the case, and the calling
> convention will end up using a pointer to the local stack instead.
>
> So for 32-bit code generation, we *may* want to introduce a new model of doing
>
>     set_inode_time(inode, ATTR_ATIME | ATTR_MTIME);
>
> which basically just does
>
>     inode->i_atime = inode->i_mtime = current_time(inode);
>
> but with a much easier calling convention on 32-bit architectures.

Arnd and I had discussed something like this before.
But, for entirely different reasons:

Having the set_inode_time() like you suggest will also help switching
of vfs inode times to timespec64.
We were suggesting all the accesses to inode time be abstracted
through something like inode_set_time().
Arnd also had suggested a split representation of fields in the struct
inode as well which led to space savings
as well. And, having the split representation also meant no more
direct assignments:

https://lkml.org/lkml/2016/1/7/20

This in general will be similar to setattr_copy(), but only sets times
rather than other attributes as well.

If this is what is preferred, then the patches to change vfs to use
timespec64 could make use of this and will
need to be refactored. So maybe it would be good to discuss before I
post those patches.

-Deepa
