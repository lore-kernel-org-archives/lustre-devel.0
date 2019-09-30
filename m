From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:35 -0400
Subject: [lustre-devel] [PATCH 076/151] lustre: flr: randomize mirror pick
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-77-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Pick mirror randomly for read on client side and write on the MDT.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: c4c8cd23f9a3 ("LU-9771 flr: randomize mirror pick")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29097
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/lcommon_cl.c    |  4 ++++
 fs/lustre/lov/lov_object.c      | 19 +++++++++++++++++++
 3 files changed, 24 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 9d383f5..1dce1c0 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -478,6 +478,7 @@
 #define OBD_FAIL_FLR_GLIMPSE_IMMUTABLE			0x1A00
 #define OBD_FAIL_FLR_LV_DELAY			0x1A01
 #define OBD_FAIL_FLR_LV_INC			0x1A02
+#define OBD_FAIL_FLR_RANDOM_PICK_MIRROR	0x1A03
 
 /* Assign references to moved code to reduce code changes */
 #define OBD_FAIL_PRECHECK(id)			CFS_FAIL_PRECHECK(id)
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 156b1ad..0361adc 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -188,6 +188,10 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		}
 	} else {
 		result = cl_conf_set(env, lli->lli_clob, &conf);
+		if (result == -EBUSY) {
+			/* ignore the error since I/O will handle it later */
+			result = 0;
+		}
 	}
 
 	cl_env_put(env, &refcheck);
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index f606e04..49facf3 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -756,6 +756,25 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		goto out;
 	}
 
+	if (OBD_FAIL_CHECK(OBD_FAIL_FLR_RANDOM_PICK_MIRROR)) {
+		unsigned int seq;
+
+		get_random_bytes(&seq, sizeof(seq));
+		seq %= mirror_count;
+
+		i = 0;
+		lov_foreach_mirror_entry(lov, lre) {
+			i++;
+			if (lre->lre_stale)
+				continue;
+
+			if (!seq--) {
+				comp->lo_preferred_mirror = i - 1;
+				break;
+			}
+		}
+	}
+
 	LASSERT(comp->lo_preferred_mirror >= 0);
 
 out:
-- 
1.8.3.1
