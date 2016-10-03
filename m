From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:13 -0400
Subject: [lustre-devel] [PATCH 17/41] staging: lustre: ptlrpc: remove old
	protocol compatibility
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Some old protocol compatibility workarounds are still present in
master that should have been removed when LUSTRE_MSG_MAGIC_V1 was.

In particular, the process for upgrading LUSTRE_MSG_MAGIC_V1 to
LUSTRE_MSG_MAGIC_V2 had the client to connect to the server with the
V1 protocol with op_flag=MSG_CONNECT_NEXT_VER set, and if the server
supported the V2 protocol it would reply with LUSTRE_MSG_MAGIC_V2.
This ensured that if the new client connected to an old server the
connection would be allowed.  However, even with V1 protocol support
removed, the 2.x clients are still connecting with NEXT_VER set.
In b1_8 this flag was contingent on LUSTRE_MSG_MAGIC_V1 being used,
which is how it should have been in 2.x as well.

A few other cleanups are be done at the same time:
 - disallow 1.8 clients (or at least those that don't understand
   OBD_CONNECT_FULL20) so we can remove workarounds for 1.8 clients
 - remove support for pre-2.1 DLM flock lock handling
 - don't workaround the lack of MDS_ATTR_xTIME_SET flags in setattr
 - always set MSGHDR_CKSUM_INCOMPAT18 (it can eventually be removed)

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6349
Reviewed-on: http://review.whamcloud.com/14006
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   18 ++----------------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    7 ++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   19 +++----------------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   11 ++---------
 4 files changed, 9 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 861f36f..98838e7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -612,22 +612,8 @@ granted:
 }
 EXPORT_SYMBOL(ldlm_flock_completion_ast);
 
-void ldlm_flock_policy_wire18_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				       ldlm_policy_data_t *lpolicy)
-{
-	memset(lpolicy, 0, sizeof(*lpolicy));
-	lpolicy->l_flock.start = wpolicy->l_flock.lfw_start;
-	lpolicy->l_flock.end = wpolicy->l_flock.lfw_end;
-	lpolicy->l_flock.pid = wpolicy->l_flock.lfw_pid;
-	/* Compat code, old clients had no idea about owner field and
-	 * relied solely on pid for ownership. Introduced in LU-104, 2.1,
-	 * April 2011
-	 */
-	lpolicy->l_flock.owner = wpolicy->l_flock.lfw_pid;
-}
-
-void ldlm_flock_policy_wire21_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				       ldlm_policy_data_t *lpolicy)
+void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+				     ldlm_policy_data_t *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_flock.start = wpolicy->l_flock.lfw_start;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 5e82cfc..0099ff3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -329,10 +329,7 @@ void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 				      ldlm_policy_data_t *lpolicy);
 void ldlm_extent_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
 				      ldlm_wire_policy_data_t *wpolicy);
-void ldlm_flock_policy_wire18_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				       ldlm_policy_data_t *lpolicy);
-void ldlm_flock_policy_wire21_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				       ldlm_policy_data_t *lpolicy);
-
+void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+				     ldlm_policy_data_t *lpolicy);
 void ldlm_flock_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index cc116ba..22b4a52 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -63,17 +63,10 @@ static char *ldlm_typename[] = {
 	[LDLM_IBITS]	= "IBT",
 };
 
-static ldlm_policy_wire_to_local_t ldlm_policy_wire18_to_local[] = {
+static ldlm_policy_wire_to_local_t ldlm_policy_wire_to_local[] = {
 	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_wire_to_local,
 	[LDLM_EXTENT - LDLM_MIN_TYPE]	= ldlm_extent_policy_wire_to_local,
-	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_wire18_to_local,
-	[LDLM_IBITS - LDLM_MIN_TYPE]	= ldlm_ibits_policy_wire_to_local,
-};
-
-static ldlm_policy_wire_to_local_t ldlm_policy_wire21_to_local[] = {
-	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_wire_to_local,
-	[LDLM_EXTENT - LDLM_MIN_TYPE]	= ldlm_extent_policy_wire_to_local,
-	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_wire21_to_local,
+	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_wire_to_local,
 	[LDLM_IBITS - LDLM_MIN_TYPE]	= ldlm_ibits_policy_wire_to_local,
 };
 
@@ -106,14 +99,8 @@ void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 				  ldlm_policy_data_t *lpolicy)
 {
 	ldlm_policy_wire_to_local_t convert;
-	int new_client;
 
-	/** some badness for 2.0.0 clients, but 2.0.0 isn't supported */
-	new_client = (exp_connect_flags(exp) & OBD_CONNECT_FULL20) != 0;
-	if (new_client)
-		convert = ldlm_policy_wire21_to_local[type - LDLM_MIN_TYPE];
-	else
-		convert = ldlm_policy_wire18_to_local[type - LDLM_MIN_TYPE];
+	convert = ldlm_policy_wire_to_local[type - LDLM_MIN_TYPE];
 
 	convert(wpolicy, lpolicy);
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index a23d0a0..b245784 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -691,8 +691,6 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	request->rq_timeout = INITIAL_CONNECT_TIMEOUT;
 	lustre_msg_set_timeout(request->rq_reqmsg, request->rq_timeout);
 
-	lustre_msg_add_op_flags(request->rq_reqmsg, MSG_CONNECT_NEXT_VER);
-
 	request->rq_no_resend = 1;
 	request->rq_no_delay = 1;
 	request->rq_send_state = LUSTRE_IMP_CONNECTING;
@@ -873,8 +871,7 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 			ocd->ocd_connect_flags;
 	}
 
-	if ((ocd->ocd_connect_flags & OBD_CONNECT_AT) &&
-	    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
+	if (ocd->ocd_connect_flags & OBD_CONNECT_AT)
 		/*
 		 * We need a per-message support flag, because
 		 * a. we don't know if the incoming connect reply
@@ -889,11 +886,7 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	else
 		imp->imp_msghdr_flags &= ~MSGHDR_AT_SUPPORT;
 
-	if ((ocd->ocd_connect_flags & OBD_CONNECT_FULL20) &&
-	    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
-		imp->imp_msghdr_flags |= MSGHDR_CKSUM_INCOMPAT18;
-	else
-		imp->imp_msghdr_flags &= ~MSGHDR_CKSUM_INCOMPAT18;
+	imp->imp_msghdr_flags |= MSGHDR_CKSUM_INCOMPAT18;
 
 	return 0;
 }
-- 
1.7.1
