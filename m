Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 94ECAC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:44:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2wv3tg6z212R;
	Fri, 21 Mar 2025 06:14:55 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2pt0Y9fz1yGY
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:09:41 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AC43417B5B7;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id AABE1106BE17; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:08 -0400
Message-ID: <20250321130711.3257092-26-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 25/27] lustre: dne: refactor
 commit-on-sharing for DNE
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Commit-on-sharing for DNE is different from the original
commit-on-sharing:
* the original commit-on-sharing is to eliminate dependency between
  operations from different clients.
* while commit-on-sharing for DNE is to eliminate dependency between
  operations handled by different MDTs, so that upon multiple MDT
  failures, an operaiton replay won't fail because its dependent
  operation is not replayed by another MDT yet.

Current CoS for DNE implementation checks dependency in MDT layer, and
it decides by checking whether current operation is a distributed
transaction, if so, it will trigger CoS upon conflicting locks.
Actually this may miss some cases that should trigger CoS (even local
transaction should trigger CoS if it depends on a distributed
transaction), and on the other hand it may trigger extra CoS because
if two operations are handled by the same MDT, the dependency is
ensured because they will always be replayed by transaction number.
And to avoid mixing the code of two different CoS, the following
changes are made:
* add new ldlm lock mode LCK_TXN. On DNE system, downgrade PW/EX locks
  to this mode after transaction stop.
* add li_initiator_id in struct ldlm_inodebits, which is the index of
  MDT where the lock is enqueued, i.e. where operation is handled. If
  another operation handled by a different MDT requests a conflicting
  PW|EX mode lock against this TXN mode lock, it will trigger commit
  to ensure the dependent operation is committed to disk (NB, it
  doesn't trigger commit on all involved MDTs, but only the MDT where
  the conflict happens, which is enough to allow replay succeed).
* remove LDLM_FL_COS_INCOMPAT and LDLM_FL_COS_ENABLED.
* MDT layer doesn't need to check such dependency any more, since lock
  itself knows.
* updated sanityn 33c, 33d and 33e since fewer CoS are triggered now.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15527
Lustre-commit: 2a78a9e2cda149ede5 ("LU-15527 dne: refactor commit-on-sharing for DNE")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46641
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h         | 43 ++++++++++++++++----------
 fs/lustre/ldlm/ldlm_inodebits.c        |  4 +++
 fs/lustre/ldlm/ldlm_lib.c              |  1 +
 fs/lustre/ldlm/ldlm_lock.c             | 10 +++---
 fs/lustre/ptlrpc/pack_generic.c        |  2 +-
 fs/lustre/ptlrpc/service.c             | 10 +++---
 fs/lustre/ptlrpc/wiretest.c            | 16 ++++++++--
 include/uapi/linux/lustre/lustre_idl.h |  5 ++-
 8 files changed, 61 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 4217a8ad4501..a749e8acb5df 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -111,7 +111,7 @@ enum ldlm_side {
  * Lock types are described in their respective implementation files:
  * ldlm_{extent,flock,inodebits,plain}.c.
  *
- * There are six lock modes along with a compatibility matrix to indicate if
+ * There are nine lock modes along with a compatibility matrix to indicate if
  * two locks are compatible.
  *
  * - EX: Exclusive mode. Before a new file is created, MDS requests EX lock
@@ -126,26 +126,37 @@ enum ldlm_side {
  * - CR Concurrent Read mode. When a client performs a path lookup, MDS grants
  *   an inodebit lock with the CR mode on the intermediate path component.
  * - NL Null mode.
+ * - GROUP: Group mode. Locks with the same group ID are compatible with each
+ *   other.
+ * - COS: Commit-on-Sharing mode. If Commit-on-Sharing is enabled, PW/EX locks
+ *   held in transactions are downgraded to COS mode after transaction stop.
+ * - TXN: Transaction mode. If Commit-on-Sharing is diabled on a DNE system,
+ *   PW/EX locks held in transactions are downgraded to TXN mode after
+ *   transaction stop.
  *
  * <PRE>
- *       NL  CR  CW  PR  PW  EX
- *  NL    1   1   1   1   1   1
- *  CR    1   1   1   1   1   0
- *  CW    1   1   1   0   0   0
- *  PR    1   1   0   1   0   0
- *  PW    1   1   0   0   0   0
- *  EX    1   0   0   0   0   0
+ *       NL  CR  CW  PR  PW  EX GROUP COS TXN
+ *  NL    1   1   1   1   1   1   1   1   1
+ *  CR    1   1   1   1   1   0   0   0   1
+ *  CW    1   1   1   0   0   0   0   0   1
+ *  PR    1   1   0   1   0   0   0   0   1
+ *  PW    1   1   0   0   0   0   0   0   0
+ *  EX    1   0   0   0   0   0   0   0   0
+ *  GROUP 1   0   0   0   0   0   1   0   0
+ *  COS   1   0   0   0   0   0   0   1   0
+ *  TXN   1   1   1   1   0   0   0   0   1
  * </PRE>
  */
 /** @{ */
-#define LCK_COMPAT_EX  LCK_NL
-#define LCK_COMPAT_PW  (LCK_COMPAT_EX | LCK_CR)
-#define LCK_COMPAT_PR  (LCK_COMPAT_PW | LCK_PR)
-#define LCK_COMPAT_CW  (LCK_COMPAT_PW | LCK_CW)
-#define LCK_COMPAT_CR  (LCK_COMPAT_CW | LCK_PR | LCK_PW)
-#define LCK_COMPAT_NL  (LCK_COMPAT_CR | LCK_EX | LCK_GROUP)
-#define LCK_COMPAT_GROUP  (LCK_GROUP | LCK_NL)
-#define LCK_COMPAT_COS (LCK_COS)
+#define LCK_COMPAT_EX    LCK_NL
+#define LCK_COMPAT_PW    (LCK_COMPAT_EX | LCK_CR)
+#define LCK_COMPAT_PR    (LCK_COMPAT_PW | LCK_PR | LCK_TXN)
+#define LCK_COMPAT_CW    (LCK_COMPAT_PW | LCK_CW | LCK_TXN)
+#define LCK_COMPAT_CR    (LCK_COMPAT_CW | LCK_PR | LCK_PW | LCK_TXN)
+#define LCK_COMPAT_NL    (LCK_COMPAT_CR | LCK_EX | LCK_GROUP | LCK_COS)
+#define LCK_COMPAT_GROUP (LCK_NL | LCK_GROUP)
+#define LCK_COMPAT_COS   (LCK_NL | LCK_COS)
+#define LCK_COMPAT_TXN   (LCK_COMPAT_PR | LCK_CW)
 /** @} Lock Compatibility Matrix */
 
 extern enum ldlm_mode lck_compat_array[];
diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index 892a0dd82fee..d73955ded917 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -58,6 +58,8 @@ void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
 	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
+	lpolicy->l_inodebits.li_initiator_id =
+		wpolicy->l_inodebits.li_initiator_id;
 	/**
 	 * try_bits and li_gid are to be handled outside of generic
 	 * write_to_local due to different behavior on a server and client.
@@ -70,6 +72,8 @@ void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
 	wpolicy->l_inodebits.li_gid = lpolicy->l_inodebits.li_gid;
+	wpolicy->l_inodebits.li_initiator_id =
+		lpolicy->l_inodebits.li_initiator_id;
 }
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index c9a10f0d87ea..497c40c425ba 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -878,6 +878,7 @@ enum ldlm_mode lck_compat_array[] = {
 	[LCK_NL]	= LCK_COMPAT_NL,
 	[LCK_GROUP]	= LCK_COMPAT_GROUP,
 	[LCK_COS]	= LCK_COMPAT_COS,
+	[LCK_TXN]	= LCK_COMPAT_TXN,
 };
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 739798bd95d9..35a0610344e1 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -55,6 +55,7 @@ char *ldlm_lockname[] = {
 	[LCK_NL]	= "NL",
 	[LCK_GROUP]	= "GROUP",
 	[LCK_COS]	= "COS",
+	[LCK_TXN]	= "TXN",
 };
 EXPORT_SYMBOL(ldlm_lockname);
 
@@ -668,7 +669,7 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
 		lock->l_readers++;
 		lu_ref_add_atomic(&lock->l_reference, "reader", lock);
 	}
-	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
+	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS | LCK_TXN)) {
 		lock->l_writers++;
 		lu_ref_add_atomic(&lock->l_reference, "writer", lock);
 	}
@@ -733,7 +734,7 @@ void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
 		lu_ref_del(&lock->l_reference, "reader", lock);
 		lock->l_readers--;
 	}
-	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
+	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS | LCK_TXN)) {
 		LASSERT(lock->l_writers > 0);
 		lu_ref_del(&lock->l_reference, "writer", lock);
 		lock->l_writers--;
@@ -1980,7 +1981,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	case LDLM_IBITS:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s gid %llu flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s gid %llu flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d initiator: MDT%d\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
@@ -1997,7 +1998,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_remote_handle.cookie,
 				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timestamp,
-				 lock->l_lvb_type);
+				 lock->l_lvb_type,
+				 lock->l_policy_data.l_inodebits.li_initiator_id);
 		break;
 
 	default:
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index e1692986dd4c..60fa2e820273 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2446,7 +2446,7 @@ static void lustre_swab_ldlm_policy_data(union ldlm_wire_policy_data *d)
 	__swab64s(&d->l_extent.start);
 	__swab64s(&d->l_extent.end);
 	__swab64s(&d->l_extent.gid);
-	__swab64s(&d->l_flock.lfw_owner);
+	__swab32s(&d->l_flock.lfw_padding);
 	__swab32s(&d->l_flock.lfw_pid);
 }
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 3acf1bbed0ef..259f79c9b995 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1887,11 +1887,6 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 	LASSERT(rs->rs_scheduled);
 	LASSERT(list_empty(&rs->rs_list));
 
-	spin_lock(&exp->exp_lock);
-	/* Noop if removed already */
-	list_del_init(&rs->rs_exp_list);
-	spin_unlock(&exp->exp_lock);
-
 	/*
 	 * The disk commit callback holds exp_uncommitted_replies_lock while it
 	 * iterates over newly committed replies, removing them from
@@ -1921,6 +1916,11 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 		spin_unlock(&exp->exp_uncommitted_replies_lock);
 	}
 
+	spin_lock(&exp->exp_lock);
+	/* Noop if removed already */
+	list_del_init(&rs->rs_exp_list);
+	spin_unlock(&exp->exp_lock);
+
 	spin_lock(&rs->rs_lock);
 
 	been_handled = rs->rs_handled;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index b3135d4a7990..ecc7e966aa52 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -321,9 +321,11 @@ void lustre_assert_wire_constants(void)
 		 (long long)LCK_GROUP);
 	LASSERTF(LCK_COS == 128, "found %lld\n",
 		 (long long)LCK_COS);
-	LASSERTF(LCK_MAXMODE == 129, "found %lld\n",
+	LASSERTF(LCK_TXN == 256, "found %lld\n",
+		 (long long)LCK_TXN);
+	LASSERTF(LCK_MAXMODE == 257, "found %lld\n",
 		 (long long)LCK_MAXMODE);
-	LASSERTF(LCK_MODE_NUM == 8, "found %lld\n",
+	LASSERTF(LCK_MODE_NUM == 9, "found %lld\n",
 		 (long long)LCK_MODE_NUM);
 	BUILD_BUG_ON(LDLM_PLAIN != 10);
 	BUILD_BUG_ON(LDLM_EXTENT != 11);
@@ -3328,7 +3330,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct ldlm_extent *)0)->gid));
 
 	/* Checks for struct ldlm_inodebits */
-	LASSERTF((int)sizeof(struct ldlm_inodebits) == 24, "found %lld\n",
+	LASSERTF((int)sizeof(struct ldlm_inodebits) == 32, "found %lld\n",
 		 (long long)(int)sizeof(struct ldlm_inodebits));
 	LASSERTF((int)offsetof(struct ldlm_inodebits, bits) == 0, "found %lld\n",
 		 (long long)(int)offsetof(struct ldlm_inodebits, bits));
@@ -3342,6 +3344,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ldlm_inodebits, li_gid));
 	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->li_gid) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->li_gid));
+	LASSERTF((int)offsetof(struct ldlm_inodebits, li_padding) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct ldlm_inodebits, li_padding));
+	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->li_padding) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->li_padding));
+	LASSERTF((int)offsetof(struct ldlm_inodebits, li_initiator_id) == 28, "found %lld\n",
+		 (long long)(int)offsetof(struct ldlm_inodebits, li_initiator_id));
+	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->li_initiator_id) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->li_initiator_id));
 
 	/* Checks for struct ldlm_flock_wire */
 	LASSERTF((int)sizeof(struct ldlm_flock_wire) == 32, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index b61fa5c6d9a1..ecd4456e3074 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2159,10 +2159,11 @@ enum ldlm_mode {
 	LCK_NL		= 32,
 	LCK_GROUP	= 64,
 	LCK_COS		= 128,
+	LCK_TXN		= 256,
 	LCK_MAXMODE
 };
 
-#define LCK_MODE_NUM	8
+#define LCK_MODE_NUM	9
 
 enum ldlm_type {
 	LDLM_PLAIN	= 10,
@@ -2190,6 +2191,8 @@ struct ldlm_inodebits {
 	__u64 bits;
 	__u64 cancel_bits; /* for lock convert */
 	__u64 li_gid;
+	__u32 li_padding;
+	__u32 li_initiator_id; /* index of MDT that initiated this lock */
 };
 
 struct ldlm_flock_wire {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
