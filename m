From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:21 -0400
Subject: [lustre-devel] [PATCH 062/151] lustre: lov: take lov layout lock
 for I/O with ignore_layout
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-63-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

A rule of thumb for taking lov layout configuration lock is if I/O
is initiated from LLITE layer, it should grab the lock. If an I/O
starts from the OSC layer, it won't be necessary because if the OSC
object exists, layout reconfiguration will move forward.

Right now CIT_MISC + ci_ignore_layout can identify the I/O from the
OSC layer, I just use this in lov_io_init() for this purpose. In the
future, an explicit bit may be defined for this.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9785
Lustre-commit: e43b0e5c0ccb ("LU-9785 lov: take lov layout lock for I/O with ignore_layout")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29638
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 3a7b38d..cb9b108 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1224,8 +1224,14 @@ int lov_io_init(const struct lu_env *env, struct cl_object *obj,
 	       PFID(lu_object_fid(&obj->co_lu)), io, io->ci_type,
 	       io->ci_ignore_layout, io->ci_verify_layout);
 
+	/* IO type CIT_MISC with ci_ignore_layout set are usually invoked from
+	 * the OSC layer. It shouldn't take lov layout conf lock in that case,
+	 * because as long as the OSC object exists, the layout can't be
+	 * reconfigured.
+	 */
 	return LOV_2DISPATCH_MAYLOCK(cl2lov(obj), llo_io_init,
-				     !io->ci_ignore_layout, env, obj, io);
+			!(io->ci_ignore_layout && io->ci_type == CIT_MISC),
+			env, obj, io);
 }
 
 /**
-- 
1.8.3.1
