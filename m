From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 29 Jun 2016 21:48:02 +0200
Subject: [lustre-devel] [Y2038] [PATCH v3 00/24] Delete CURRENT_TIME_SEC
	and replace current_fs_time()
In-Reply-To: <1466890668-23400-1-git-send-email-deepa.kernel@gmail.com>
References: <1466890668-23400-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <4878160.cRxJJ9CCsj@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
Cc: shaggy-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, jfs-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org, Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cm224.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, mfasheh-IBi9RG/b67k@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, dedekind1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jack-IBi9RG/b67k@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, torvalds@linux-foundation.

On Saturday, June 25, 2016 2:37:24 PM CEST Deepa Dinamani wrote:
> The series is aimed at getting rid of CURRENT_TIME, CURRENT_TIME_SEC macros
> and replacing current_fs_time() with current_time().
> The macros are not y2038 safe. There is no plan to transition them into being
> y2038 safe.
> ktime_get_* api's can be used in their place. And, these are y2038 safe.
> 
> CURRENT_TIME will be deleted after 4.8 rc1 as there is a dependency function
> time64_to_tm() for one of the CURRENT_TIME occurance.
> 
> Thanks to Arnd Bergmann for all the guidance and discussions.
> 
> Patches 3-5 were mostly generated using coccinelle.
> 
> All filesystem timestamps use current_fs_time() for right granularity as
> mentioned in the respective commit texts of patches. This has a changed
> signature, renamed to current_time() and moved to the fs/inode.c.
> 
> This series also serves as a preparatory series to transition vfs to 64 bit
> timestamps as outlined here: https://lkml.org/lkml/2016/2/12/104 .
> 
> As per Linus's suggestion in https://lkml.org/lkml/2016/5/24/663 , all the
> inode timestamp changes have been squashed into a single patch. Also,
> current_time() now is used as a single generic vfs filesystem timestamp api.
> It also takes struct inode* as argument instead of struct super_block*.
> Posting all patches together in a bigger series so that the big picture is
> clear.
> 
> As per the suggestion in https://lwn.net/Articles/672598/, CURRENT_TIME macro
> bug fixes are being handled in a series separate from transitioning vfs to use.
> 

Everything in this version looks good to me. Please add

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

and send a pull request to Al Viro, based on the latest linux-4.7-rc release.

	Arnd
