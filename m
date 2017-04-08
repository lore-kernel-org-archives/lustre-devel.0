From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:10 -0700
Subject: [lustre-devel] [PATCH 12/12] time: Delete current_fs_time() function
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-13-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: bfields@fieldses.org, clm@fb.com, linux-mtd@lists.infradead.org, dushistov@mail.ru, jlayton@poochiereds.net, tglx@linutronix.de, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, paul@paul-moore.com, y2038@lists.linaro.org, mingo@redhat.com, jsimmons@infradead.org, arnd@arndb.de, rostedt@goodmis.org, oleg.drokin@intel.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org, ceph-devel@vger.kernel.org, andreas.dilger@intel.com, jbacik@fb.com, gregkh@linuxfoundation.org, samba-technical@lists.samba.org, eparis@redhat.com, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-audit@redhat.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, davem@davemloft.net, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

All uses of the current_fs_time() function have been
replaced by other time interfaces.

And, its use cases can be fulfilled by current_time()
or ktime_get_* variants.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/fs.h |  1 -
 kernel/time/time.c | 14 --------------
 2 files changed, 15 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index f1d7347..cce6c57 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1430,7 +1430,6 @@ static inline void i_gid_write(struct inode *inode, gid_t gid)
 	inode->i_gid = make_kgid(inode->i_sb->s_user_ns, gid);
 }
 
-extern struct timespec current_fs_time(struct super_block *sb);
 extern struct timespec current_time(struct inode *inode);
 
 /*
diff --git a/kernel/time/time.c b/kernel/time/time.c
index 25bdd25..cf69cca 100644
--- a/kernel/time/time.c
+++ b/kernel/time/time.c
@@ -230,20 +230,6 @@ SYSCALL_DEFINE1(adjtimex, struct timex __user *, txc_p)
 	return copy_to_user(txc_p, &txc, sizeof(struct timex)) ? -EFAULT : ret;
 }
 
-/**
- * current_fs_time - Return FS time
- * @sb: Superblock.
- *
- * Return the current time truncated to the time granularity supported by
- * the fs.
- */
-struct timespec current_fs_time(struct super_block *sb)
-{
-	struct timespec now = current_kernel_time();
-	return timespec_trunc(now, sb->s_time_gran);
-}
-EXPORT_SYMBOL(current_fs_time);
-
 /*
  * Convert jiffies to milliseconds and back.
  *
-- 
2.7.4
