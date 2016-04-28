From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:19 -0400
Subject: [lustre-devel] [PATCH 10/12] staging: lustre: llog: we don't need
	vfsmount
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

The patch for LU-3286 removed vfsmount instances used
on the server side. Since this is server side only we
can remove it from the upstream client.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3286
Reviewed-on: http://review.whamcloud.com/8286
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_disk.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 95fd360..b36821f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -130,7 +130,6 @@ struct lustre_sb_info {
 	struct lustre_mount_data *lsi_lmd;     /* mount command info */
 	struct ll_sb_info	*lsi_llsbi;   /* add'l client sbi info */
 	struct dt_device	 *lsi_dt_dev;  /* dt device to access disk fs*/
-	struct vfsmount	  *lsi_srv_mnt; /* the one server mount */
 	atomic_t	      lsi_mounts;  /* references to the srv_mnt */
 	char			  lsi_svname[MTI_NAME_MAXLEN];
 	char			  lsi_osd_obdname[64];
@@ -158,7 +157,6 @@ struct lustre_sb_info {
 struct lustre_mount_info {
 	char		 *lmi_name;
 	struct super_block   *lmi_sb;
-	struct vfsmount      *lmi_mnt;
 	struct list_head	    lmi_list_chain;
 };
 
-- 
2.7.4
