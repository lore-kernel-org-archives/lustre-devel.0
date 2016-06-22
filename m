From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 22 Jun 2016 17:49:48 +0200
Subject: [lustre-devel] [Y2038] [PATCH v2 00/24] Delete CURRENT_TIME and
	CURRENT_TIME_SEC macros
In-Reply-To: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <5119217.EGiBXE3Be4@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, tglx@linutronix.de, linux-ext4@vger.kernel.org, jbacik@fb.com
Cc: shaggy@kernel.org, jfs-discussion@lists.sourceforge.net, trond.myklebust@primarydata.com, adrian.hunter@intel.com, clm@fb.com, adilger.kernel@dilger.ca, Deepa Dinamani <deepa.kernel@gmail.com>, sfrench@samba.org, jejb@linux.vnet.ibm.com, paul@paul-moore.com, linux-scsi@vger.kernel.org, cm224.lee@samsung.com, mfasheh@suse.com, linux-nfs@vger.kernel.org, john.stultz@linaro.org, viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org, ceph-devel@vger.kernel.org, jlbec@evilplan.org, sramars@cisco.com, elder@kernel.org, tytso@mit.edu, sage@redhat.com, martin.petersen@oracle.com, gregkh@linuxfoundation.org, hiralpat@cisco.com, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-f2fs-devel@lists.sourceforge.net, zyan@redhat.com, linux-audit@redhat.com, linux-btrfs@vger.kernel.org, jack@suse.com, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, torvalds@lin

On Sunday, June 19, 2016 5:26:59 PM CEST Deepa Dinamani wrote:
> The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.
> The macros are not y2038 safe. There is no plan to transition them into being
> y2038 safe.
> ktime_get_* api's can be used in their place. And, these are y2038 safe.
> 
> Thanks to Arnd Bergmann for all the guidance and discussions.
> 
> Patches 2-4 were mostly generated using coccinelle scripts.
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

I've looked in detail at all the patches in this version now, and while
overall everything is fine, I found that two patches cannot be part of the
series because of the dependency on the patch that John already took (adding
time64_to_tm), but I think that's ok because we just need to change over
all the users of CURRENT_TIME and CURRENT_TIME_SEC that assign to inode
timestamps in order to prepare for the type change, the other ones
can be changed later.

I also found a few things that could be done differently to make the
later conversion slightly easier, but it's also possible that I missed
part of your bigger plan for those files, and none of them seem important.

	Arnd
