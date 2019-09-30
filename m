From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:25 -0400
Subject: [lustre-devel] [PATCH 126/151] lustre: obd: add check to obd_statfs
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-127-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The race could happened between mount and lctl get_param.
Because procfs files are ready before a full obd initialization.
For example:
3372:0:(dt_object.h:2509:dt_statfs()) ASSERTION( dev )
3372:0:(dt_object.h:2509:dt_statfs()) LBUG
Pid: 3372, comm: lctl
Call Trace:
        libcfs_call_trace+0x4e/0x60[libcfs]
        lbug_with_loc+0x4c/0xb0[libcfs]
        tgt_statfs_internal+0x2ea/0x350[ptlrpc]
        ofd_statfs+0x66/0x470 [ofd]
        lprocfs_filesfree_seq_show+0xf6/0x520 [obdclass]
        ofd_filesfree_seq_show+0x12/0x20 [ofd]

The patch adds a check of completed obd_setup to obd_statfs().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10650
ray-bug-id: LUS-2665
Lustre-commit: 4f40429775c4 ("LU-10650 obd: add check to obd_statfs")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/31243
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index dd07ec5..0bbf777 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -924,6 +924,10 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 	if (!obd)
 		return -EINVAL;
 
+	rc = obd_check_dev_active(obd);
+	if (rc)
+		return rc;
+
 	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->statfs) {
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
-- 
1.8.3.1
