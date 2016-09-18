From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:03 -0400
Subject: [lustre-devel] [PATCH 064/124] staging: lustre:
	lu_dirent_calc_size() return type to size_t
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-65-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the type accordant usage.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12383
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index a0ca571..445b813 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1013,12 +1013,12 @@ static inline struct lu_dirent *lu_dirent_next(struct lu_dirent *ent)
 	return next;
 }
 
-static inline int lu_dirent_calc_size(int namelen, __u16 attr)
+static inline size_t lu_dirent_calc_size(size_t namelen, __u16 attr)
 {
-	int size;
+	size_t size;
 
 	if (attr & LUDA_TYPE) {
-		const unsigned align = sizeof(struct luda_type) - 1;
+		const size_t align = sizeof(struct luda_type) - 1;
 
 		size = (sizeof(struct lu_dirent) + namelen + align) & ~align;
 		size += sizeof(struct luda_type);
@@ -1029,15 +1029,6 @@ static inline int lu_dirent_calc_size(int namelen, __u16 attr)
 	return (size + 7) & ~7;
 }
 
-static inline int lu_dirent_size(const struct lu_dirent *ent)
-{
-	if (le16_to_cpu(ent->lde_reclen) == 0) {
-		return lu_dirent_calc_size(le16_to_cpu(ent->lde_namelen),
-					   le32_to_cpu(ent->lde_attrs));
-	}
-	return le16_to_cpu(ent->lde_reclen);
-}
-
 #define MDS_DIR_END_OFF 0xfffffffffffffffeULL
 
 /**
-- 
1.7.1
