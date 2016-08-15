From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 15 Aug 2016 18:23:12 +0200
Subject: [lustre-devel] [GIT PULL] [PATCH v4 00/26] Delete CURRENT_TIME
 and CURRENT_TIME_SEC macros
In-Reply-To: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
References: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <20160815162312.GA19794@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: shaggy-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, jfs-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org, buchino-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cm224.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, mfasheh-IBi9RG/b67k@public.gmane.org, sramars-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, dedekind1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, hiralpat-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ocfs2-devel-N0ozoZBvEnonbStXaT1jcA@public.gmane.org

On Sat, Aug 13, 2016 at 03:48:12PM -0700, Deepa Dinamani wrote:
> The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.
> The macros are not y2038 safe. There is no plan to transition them into being
> y2038 safe.
> ktime_get_* api's can be used in their place. And, these are y2038 safe.

Who are you execting to pull this huge patch series?

Why not just introduce the new api call, wait for that to be merged, and
then push the individual patches through the different subsystems?
After half of those get ignored, then provide a single set of patches
that can go through Andrew or my trees.

thanks,

greg k-h
