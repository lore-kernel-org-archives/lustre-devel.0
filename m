From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:09 -0400
Subject: [lustre-devel] [PATCH 17/31] lustre: obdclass: handle early
 requests vs CT registering
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

This patch addresses cases where CDT may start to send requests
before CT has fully registered with all MDTs and thus when the KUC
pipe kernel side has still not been initialized in
lmv_hsm_ct_register().

This will avoid Oops'es due to kkuc_groups[KUC_GRP_HSM] being
uninitialized/zero'ed and we rely on CDT to later retry.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-9038
Reviewed-on: https://review.whamcloud.com/25050
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/kernelcomm.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 63067a7..304288d 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -183,6 +183,14 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 	int one_success = 0;
 
 	down_write(&kg_sem);
+
+	if (unlikely(!kkuc_groups[group].next) ||
+	    unlikely(OBD_FAIL_CHECK(OBD_FAIL_MDS_HSM_CT_REGISTER_NET))) {
+		/* no agent have fully registered, CDT will retry */
+		up_write(&kg_sem);
+		return -EAGAIN;
+	}
+
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
 		if (reg->kr_fp) {
 			rc = libcfs_kkuc_msg_put(reg->kr_fp, payload);
-- 
1.8.3.1
