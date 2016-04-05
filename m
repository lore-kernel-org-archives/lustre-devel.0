From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:52 -0400
Subject: [lustre-devel] [PATCH 07/18] staging: lustre: hsm: rename
	hai_zero() HSM function
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, JC Lafoucriere <jacques-charles.lafoucriere@cea.fr>, James Simmons <jsimmons@infradead.org>

From: JC Lafoucriere <jacques-charles.lafoucriere@cea.fr>

rename hai_zero() to hai_first(). Use a better name for hai helper

Signed-off-by: JC Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3709
Reviewed-on: http://review.whamcloud.com/7254
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    6 +++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 19f2271..4672145 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -1095,7 +1095,7 @@ struct hsm_action_list {
 	__u32 padding1;
 	char  hal_fsname[0];   /* null-terminated */
 	/* struct hsm_action_item[hal_count] follows, aligned on 8-byte
-	 * boundaries. See hai_zero
+	 * boundaries. See hai_first
 	 */
 } __packed;
 
@@ -1109,7 +1109,7 @@ static inline int cfs_size_round(int val)
 #endif
 
 /* Return pointer to first hai in action list */
-static inline struct hsm_action_item *hai_zero(struct hsm_action_list *hal)
+static inline struct hsm_action_item *hai_first(struct hsm_action_list *hal)
 {
 	return (struct hsm_action_item *)(hal->hal_fsname +
 					  cfs_size_round(strlen(hal-> \
@@ -1131,7 +1131,7 @@ static inline int hal_size(struct hsm_action_list *hal)
 	struct hsm_action_item *hai;
 
 	sz = sizeof(*hal) + cfs_size_round(strlen(hal->hal_fsname) + 1);
-	hai = hai_zero(hal);
+	hai = hai_first(hal);
 	for (i = 0; i < hal->hal_count; i++, hai = hai_next(hai))
 		sz += cfs_size_round(hai->hai_len);
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 98b27f1..a089237 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1952,7 +1952,7 @@ static void lustre_swab_hal(struct hsm_action_list *h)
 	__swab32s(&h->hal_count);
 	__swab32s(&h->hal_archive_id);
 	__swab64s(&h->hal_flags);
-	hai = hai_zero(h);
+	hai = hai_first(h);
 	for (i = 0; i < h->hal_count; i++, hai = hai_next(hai))
 		lustre_swab_hai(hai);
 }
-- 
1.7.1
