From: Cihangir Akturk <cakturk@gmail.com>
Date: Wed, 16 Aug 2017 17:44:15 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: fix structure size for ARM
	OABI
Message-ID: <1502894655-9731-1-git-send-email-cakturk@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Cihangir Akturk <cakturk@gmail.com>

When building the kernel for the ARM architecture without setting
CONFIG_AEABI, size of struct lov_user_md_v3 and struct lov_mds_md_v3
differs, due to different alignment requirements of OABI and EABI.

Marking the anonymous union within struct lov_user_md_v3 as
'_packed' solves this issue. Otherwise we get the following
error:

drivers/staging/lustre/lustre/lov/lov_pack.c:352:2: note: in expansion
of macro ?BUILD_BUG_ON?
  BUILD_BUG_ON(sizeof(lum) != sizeof(struct lov_mds_md_v3));

Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_user.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index edff8dc..4f72cb6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -388,7 +388,7 @@ struct lov_user_md_v3 {	   /* LOV EA user data (host-endian) */
 		__u16 lmm_layout_gen;     /* layout generation number
 					   * used when reading
 					   */
-	};
+	} __packed;
 	char  lmm_pool_name[LOV_MAXPOOLNAME + 1];   /* pool name */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __packed;
-- 
2.7.4
