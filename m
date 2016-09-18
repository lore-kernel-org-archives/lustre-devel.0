From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:32 -0400
Subject: [lustre-devel] [PATCH 093/124] staging: lustre: ldlm: move
	LDLM_GID_ANY to lustre_dlm.h
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-94-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

lustre_idl.h only includes wire data; lustre_dlm.h is the
right place for LDLM_GID_ANY.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6028
Reviewed-on: http://review.whamcloud.com/13074
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 --
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    5 +++++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 445b813..acb2806 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2716,8 +2716,6 @@ struct ldlm_extent {
 	__u64 gid;
 };
 
-#define LDLM_GID_ANY ((__u64)-1)
-
 static inline int ldlm_extent_overlap(const struct ldlm_extent *ex1,
 				      const struct ldlm_extent *ex2)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 1ec4231..d035344 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -573,6 +573,11 @@ enum lvb_type {
 };
 
 /**
+ * LDLM_GID_ANY is used to match any group id in ldlm_lock_match().
+ */
+#define LDLM_GID_ANY	((__u64)-1)
+
+/**
  * LDLM lock structure
  *
  * Represents a single LDLM lock and its state in memory. Each lock is
-- 
1.7.1
