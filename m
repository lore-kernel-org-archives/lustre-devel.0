From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:46 -0400
Subject: [lustre-devel] [PATCH 087/151] lustre: idl: remove obsolete RPC MSG
 flags
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-88-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Add comments for MSG_* flags, and delete obsolete flags
MSG_LAST_REPLAY, MSG_AT_SUPPORT, MSG_DELAY_REPLAY, MSG_VERSION_REPLAY.

Remove now-unused imp_no_lock_replay field.

Add comments for MSG_CONNECT_* flags, and delete obsolete flag
MSG_CONNECT_ASYNC.

Delete them from wirecheck file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6349
Lustre-commit: 455ce0cef704 ("LU-6349 idl: remove obsolete RPC MSG flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/17831
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h      |  3 ---
 fs/lustre/ptlrpc/client.c              |  4 ----
 fs/lustre/ptlrpc/wiretest.c            |  8 -------
 include/uapi/linux/lustre/lustre_idl.h | 38 +++++++++++++++++-----------------
 4 files changed, 19 insertions(+), 34 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 6e22274..d9a8d9a 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -277,9 +277,6 @@ struct obd_import {
 					imp_server_timeout:1,
 					/* VBR: imp in delayed recovery */
 					imp_delayed_recovery:1,
-					/* VBR: if gap was found then no lock replays
-					 */
-					imp_no_lock_replay:1,
 					/* recovery by versions was failed */
 					imp_vbr_failed:1,
 					/* force an immediate ping */
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index da7077a..0499368 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2857,7 +2857,6 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 		DEBUG_REQ(D_WARNING, req, "Version mismatch during replay\n");
 		spin_lock(&imp->imp_lock);
 		imp->imp_vbr_failed = 1;
-		imp->imp_no_lock_replay = 1;
 		spin_unlock(&imp->imp_lock);
 		lustre_msg_set_status(req->rq_repmsg, aa->praa_old_status);
 	} else {
@@ -2871,9 +2870,6 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 	}
 
 	spin_lock(&imp->imp_lock);
-	/** if replays by version then gap occur on server, no trust to locks */
-	if (lustre_msg_get_flags(req->rq_repmsg) & MSG_VERSION_REPLAY)
-		imp->imp_no_lock_replay = 1;
 	imp->imp_last_replay_transno = lustre_msg_get_transno(req->rq_reqmsg);
 	spin_unlock(&imp->imp_lock);
 	LASSERT(imp->imp_last_replay_transno);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 76fb656..e161fe6 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -827,16 +827,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)MSGHDR_AT_SUPPORT);
 	LASSERTF(MSGHDR_CKSUM_INCOMPAT18 == 2, "found %lld\n",
 		 (long long)MSGHDR_CKSUM_INCOMPAT18);
-	LASSERTF(MSG_LAST_REPLAY == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned int)MSG_LAST_REPLAY);
 	LASSERTF(MSG_RESENT == 0x00000002UL, "found 0x%.8xUL\n",
 		 (unsigned int)MSG_RESENT);
 	LASSERTF(MSG_REPLAY == 0x00000004UL, "found 0x%.8xUL\n",
 		 (unsigned int)MSG_REPLAY);
-	LASSERTF(MSG_DELAY_REPLAY == 0x00000010UL, "found 0x%.8xUL\n",
-		 (unsigned int)MSG_DELAY_REPLAY);
-	LASSERTF(MSG_VERSION_REPLAY == 0x00000020UL, "found 0x%.8xUL\n",
-		 (unsigned int)MSG_VERSION_REPLAY);
 	LASSERTF(MSG_REQ_REPLAY_DONE == 0x00000040UL, "found 0x%.8xUL\n",
 		 (unsigned int)MSG_REQ_REPLAY_DONE);
 	LASSERTF(MSG_LOCK_REPLAY_DONE == 0x00000080UL, "found 0x%.8xUL\n",
@@ -851,8 +845,6 @@ void lustre_assert_wire_constants(void)
 		 (unsigned int)MSG_CONNECT_LIBCLIENT);
 	LASSERTF(MSG_CONNECT_INITIAL == 0x00000020UL, "found 0x%.8xUL\n",
 		 (unsigned int)MSG_CONNECT_INITIAL);
-	LASSERTF(MSG_CONNECT_ASYNC == 0x00000040UL, "found 0x%.8xUL\n",
-		 (unsigned int)MSG_CONNECT_ASYNC);
 	LASSERTF(MSG_CONNECT_NEXT_VER == 0x00000080UL, "found 0x%.8xUL\n",
 		 (unsigned int)MSG_CONNECT_NEXT_VER);
 	LASSERTF(MSG_CONNECT_TRANSNO == 0x00000100UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2a7f419..41d0abb 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -579,26 +579,26 @@ struct lustre_msg_v2 {
 #define LUSTRE_LOG_VERSION	0x00050000
 #define LUSTRE_MGS_VERSION	0x00060000
 
-/* pb_flags that apply to all requests */
-#define MSG_LAST_REPLAY		0x0001
-#define MSG_RESENT		0x0002
-#define MSG_REPLAY		0x0004
-/* #define MSG_AT_SUPPORT	0x0008 obsolete 1.5 */
-#define MSG_DELAY_REPLAY	0x0010
-#define MSG_VERSION_REPLAY	0x0020
-#define MSG_REQ_REPLAY_DONE	0x0040
-#define MSG_LOCK_REPLAY_DONE	0x0080
-
-/* pb_op_flags for all connect opcodes (MDS_CONNECT, OST_CONNECT) */
-#define MSG_CONNECT_RECOVERING	0x00000001
-#define MSG_CONNECT_RECONNECT	0x00000002
-#define MSG_CONNECT_REPLAYABLE	0x00000004
-/* #define MSG_CONNECT_PEER	0x00000008 removed 1.5 */
-#define MSG_CONNECT_LIBCLIENT	0x00000010
-#define MSG_CONNECT_INITIAL	0x00000020
-#define MSG_CONNECT_ASYNC	0x00000040
+/* pb_flags that apply to all request messages */
+/* #define MSG_LAST_REPLAY	0x0001 obsolete 2.0 => {REQ,LOCK}_REPLAY_DONE */
+#define MSG_RESENT		0x0002 /* was previously sent, no reply seen */
+#define MSG_REPLAY		0x0004 /* was processed, got reply, recovery */
+/* #define MSG_AT_SUPPORT	0x0008 obsolete since 1.5, AT always enabled */
+/* #define MSG_DELAY_REPLAY	0x0010 obsolete since 2.0 */
+/* #define MSG_VERSION_REPLAY	0x0020 obsolete since 1.8.2, VBR always on */
+#define MSG_REQ_REPLAY_DONE	0x0040 /* request replay over, locks next */
+#define MSG_LOCK_REPLAY_DONE	0x0080 /* lock replay over, client done */
+
+/* pb_op_flags for connect opcodes: MDS_CONNECT, OST_CONNECT, MGS_CONNECT */
+#define MSG_CONNECT_RECOVERING	0x00000001 /* target is in recovery */
+#define MSG_CONNECT_RECONNECT	0x00000002 /* tgt already has client import */
+#define MSG_CONNECT_REPLAYABLE	0x00000004 /* target supports RPC replay */
+/* #define MSG_CONNECT_PEER	0x00000008 obsolete since 1.2, removed in 1.5 */
+#define MSG_CONNECT_LIBCLIENT	0x00000010 /* obsolete since 2.3, removed 2.6 */
+#define MSG_CONNECT_INITIAL	0x00000020 /* first client connection attempt */
+/* #define MSG_CONNECT_ASYNC	0x00000040 obsolete since 1.5 */
 #define MSG_CONNECT_NEXT_VER	0x00000080 /* use next version of lustre_msg */
-#define MSG_CONNECT_TRANSNO	0x00000100 /* report transno */
+#define MSG_CONNECT_TRANSNO	0x00000100 /* client sent transno in replay */
 
 /* number of previous object versions in pb_pre_versions[] */
 #define PTLRPC_NUM_VERSIONS	4
-- 
1.8.3.1
