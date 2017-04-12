From: David Sterba <dsterba@suse.cz>
Date: Wed, 12 Apr 2017 15:42:45 +0200
Subject: [lustre-devel] [PATCH 07/12] fs: btrfs: Use ktime_get_real_ts
	for root ctime
In-Reply-To: <1491613030-11599-8-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-8-git-send-email-deepa.kernel@gmail.com>
Message-ID: <20170412134245.GK4781@twin.jikos.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: yuchao0@huawei.com, bfields@fieldses.org, clm@fb.com, linux-mtd@lists.infradead.org, dushistov@mail.ru, jlayton@poochiereds.net, ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, paul@paul-moore.com, y2038@lists.linaro.org, mingo@redhat.com, jsimmons@infradead.org, arnd@arndb.de, rostedt@goodmis.org, oleg.drokin@intel.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org, tglx@linutronix.de, andreas.dilger@intel.com, jbacik@fb.com, gregkh@linuxfoundation.org, samba-technical@lists.samba.org, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-audit@redhat.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

On Fri, Apr 07, 2017 at 05:57:05PM -0700, Deepa Dinamani wrote:
> btrfs_root_item maintains the ctime for root updates.
> This is not part of vfs_inode.
> 
> Since current_time() uses struct inode* as an argument
> as Linus suggested, this cannot be used to update root
> times unless, we modify the signature to use inode.
> 
> Since btrfs uses nanosecond time granularity, it can also
> use ktime_get_real_ts directly to obtain timestamp for
> the root. It is necessary to use the timespec time api
> here because the same btrfs_set_stack_timespec_*() apis
> are used for vfs inode times as well. These can be
> transitioned to using timespec64 when btrfs internally
> changes to use timespec64 as well.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Acked-by: David Sterba <dsterba@suse.com>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

I'm going to add the patch to my 4.12 queue and will let Andrew know.
