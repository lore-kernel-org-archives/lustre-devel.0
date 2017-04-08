From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:03 -0700
Subject: [lustre-devel] [PATCH 05/12] fs: ufs: Use ktime_get_real_ts64() for
	birthtime
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-6-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

CURRENT_TIME is not y2038 safe.
Replace it with ktime_get_real_ts64().
Inode time formats are already 64 bit long and
accommodates time64_t.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
---
 fs/ufs/ialloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/ufs/ialloc.c b/fs/ufs/ialloc.c
index 9774555..d1dd8cc 100644
--- a/fs/ufs/ialloc.c
+++ b/fs/ufs/ialloc.c
@@ -176,6 +176,7 @@ struct inode *ufs_new_inode(struct inode *dir, umode_t mode)
 	struct ufs_cg_private_info * ucpi;
 	struct ufs_cylinder_group * ucg;
 	struct inode * inode;
+	struct timespec64 ts;
 	unsigned cg, bit, i, j, start;
 	struct ufs_inode_info *ufsi;
 	int err = -ENOSPC;
@@ -323,8 +324,9 @@ struct inode *ufs_new_inode(struct inode *dir, umode_t mode)
 		lock_buffer(bh);
 		ufs2_inode = (struct ufs2_inode *)bh->b_data;
 		ufs2_inode += ufs_inotofsbo(inode->i_ino);
-		ufs2_inode->ui_birthtime = cpu_to_fs64(sb, CURRENT_TIME.tv_sec);
-		ufs2_inode->ui_birthnsec = cpu_to_fs32(sb, CURRENT_TIME.tv_nsec);
+		ktime_get_real_ts64(&ts);
+		ufs2_inode->ui_birthtime = cpu_to_fs64(sb, ts.tv_sec);
+		ufs2_inode->ui_birthnsec = cpu_to_fs32(sb, ts.tv_nsec);
 		mark_buffer_dirty(bh);
 		unlock_buffer(bh);
 		if (sb->s_flags & MS_SYNCHRONOUS)
-- 
2.7.4
