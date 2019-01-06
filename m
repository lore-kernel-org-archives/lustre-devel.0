From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:16 -0500
Subject: [lustre-devel] [PATCH v2 21/33] lustre: pfl: calculate PFL file
 LOVEA correctly
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

PFL file could contain uninstantiated component, so it could still
keeps the specified -1 stripe count,
lov_mds_md_size()/lov_user_md_size() should heed this case,
otherwise its LOVEA size could be errneous big.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9335
Reviewed-on: https://review.whamcloud.com/26597
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h  | 3 +++
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 5b4d9fc..42396dc 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1036,6 +1036,9 @@ struct lov_mds_md_v3 {		/* LOV EA mds/wire data (little-endian) */
 
 static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 {
+	if (stripes == (__u16)-1)
+		stripes = 0;
+
 	if (lmm_magic == LOV_MAGIC_V3)
 		return sizeof(struct lov_mds_md_v3) +
 				stripes * sizeof(struct lov_ost_data_v1);
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 28d4e0c..0f401bb 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -463,6 +463,9 @@ struct lov_comp_md_v1 {
 
 static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 {
+	if (stripes == (__u16)-1)
+		stripes = 0;
+
 	if (lmm_magic == LOV_USER_MAGIC_V1)
 		return sizeof(struct lov_user_md_v1) +
 				stripes * sizeof(struct lov_user_ost_data_v1);
-- 
1.8.3.1
