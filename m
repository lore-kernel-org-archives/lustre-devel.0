From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:22 -0400
Subject: [lustre-devel] [PATCH 45/45] lustre: all: Cleanup LASSERTF uses
 missing newlines
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <shaun.tancheff@hpe.com>

LASSERTF() usage that does not include a terminating newline
present an unclear syslog entry from admins.

This adds the terminating newline for a few cases.

HPE-bug-id: LUS-8853
WC-bug-id: https://jira.whamcloud.com/browse/LU-13539
Lustre-commit: 74f8e405b2c9d ("LU-13539 all: Cleanup LASSERTF uses missing newlines")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/38540
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h | 6 ++++--
 fs/lustre/ptlrpc/client.c       | 2 +-
 fs/lustre/ptlrpc/import.c       | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index e21439d..9dd523f 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -342,7 +342,8 @@ static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov, int i)
 {
 	LASSERT(lov->lo_type == LLT_COMP);
 	LASSERTF(i < lov->u.composite.lo_entry_count,
-		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
+		 "entry %d entry_count %d\n", i,
+		 lov->u.composite.lo_entry_count);
 
 	return &lov->u.composite.lo_entries[i].lle_raid0;
 }
@@ -372,7 +373,8 @@ static inline struct lov_layout_entry *lov_entry(struct lov_object *lov, int i)
 {
 	LASSERT(lov->lo_type == LLT_COMP);
 	LASSERTF(i < lov->u.composite.lo_entry_count,
-		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
+		 "entry %d entry_count %d\n", i,
+		 lov->u.composite.lo_entry_count);
 
 	return &lov->u.composite.lo_entries[i];
 }
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 0c13145..4865b04 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -848,7 +848,7 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 	if (request) {
 		ptlrpc_cli_req_init(request);
 
-		LASSERTF((unsigned long)imp > 0x1000, "%p", imp);
+		LASSERTF((unsigned long)imp > 0x1000, "%p\n", imp);
 		LASSERT(imp != LP_POISON);
 		LASSERTF((unsigned long)imp->imp_client > 0x1000, "%p\n",
 			 imp->imp_client);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 709b9fd..6b0b115 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1495,7 +1495,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 					   "%s: This client was evicted by %.*s; in progress operations using this service will fail.\n",
 					   imp->imp_obd->obd_name, target_len,
 					   target_start);
-			LASSERTF(!obd_lbug_on_eviction, "LBUG upon eviction");
+			LASSERTF(!obd_lbug_on_eviction, "LBUG upon eviction\n");
 		}
 		CDEBUG(D_HA, "evicted from %s@%s; invalidating\n",
 		       obd2cli_tgt(imp->imp_obd),
-- 
1.8.3.1
