From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:28 -0400
Subject: [lustre-devel] [PATCH 069/151] lustre: ptlrpc: use lu_extent in
 layout_intent
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-70-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

This way it will be easier to check and print the extent
of layout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: c1f450270dda ("LU-9971 ptlrpc: use lu_extent in layout_intent")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29087
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_idl.h  | 3 +--
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index a088f4a..b4f7aec 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2825,8 +2825,7 @@ enum {
 struct layout_intent {
 	__u32 li_opc;	/* intent operation for enqueue, read, write etc */
 	__u32 li_flags;
-	__u64 li_start;
-	__u64 li_end;
+	struct lu_extent li_extent;
 } __packed;
 
 /**
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 7d9f0d2..d4372d9 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -426,7 +426,7 @@ struct lu_extent {
 	__u64	e_end;
 };
 
-#define DEXT "[ %#llx , %#llx )"
+#define DEXT "[%#llx, %#llx)"
 #define PEXT(ext) (ext)->e_start, (ext)->e_end
 
 static inline bool lu_extent_is_overlapped(struct lu_extent *e1,
-- 
1.8.3.1
