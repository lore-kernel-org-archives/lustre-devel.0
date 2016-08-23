From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 23 Aug 2016 17:11:35 -0400
Subject: [lustre-devel] [PATCH 1/8] staging/lustre: const correct
	set_lock_data()
In-Reply-To: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
References: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471986702-682922-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Change the __u64 *cookie parameter of md_ops->set_lock_data() to
const struct lustre_handle *lockh.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/17072
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7403
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h          | 3 ++-
 drivers/staging/lustre/lustre/include/obd_class.h    | 3 ++-
 drivers/staging/lustre/lustre/llite/file.c           | 2 +-
 drivers/staging/lustre/lustre/llite/llite_internal.h | 5 ++---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c       | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c          | 5 +++--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h     | 3 ++-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c        | 8 ++++----
 drivers/staging/lustre/lustre/mdc/mdc_request.c      | 5 ++---
 9 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ac620fd..ed0fd41 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1023,7 +1023,8 @@ struct md_ops {
 				    struct lookup_intent *);
 	int (*clear_open_replay_data)(struct obd_export *,
 				      struct obd_client_handle *);
-	int (*set_lock_data)(struct obd_export *, __u64 *, void *, __u64 *);
+	int (*set_lock_data)(struct obd_export *, const struct lustre_handle *,
+			     void *, __u64 *);
 
 	enum ldlm_mode (*lock_match)(struct obd_export *, __u64,
 				     const struct lu_fid *, enum ldlm_type,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 79fc041..4f48968 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1610,7 +1610,8 @@ static inline int md_clear_open_replay_data(struct obd_export *exp,
 }
 
 static inline int md_set_lock_data(struct obd_export *exp,
-				   __u64 *lockh, void *data, __u64 *bits)
+				   const struct lustre_handle *lockh,
+				   void *data, __u64 *bits)
 {
 	EXP_CHECK_MD_OP(exp, set_lock_data);
 	EXP_MD_COUNTER_INCREMENT(exp, set_lock_data);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 55ccd84..13ff212 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3629,7 +3629,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 		   PFID(&lli->lli_fid), inode, reconf);
 
 	/* in case this is a caching lock and reinstate with new inode */
-	md_set_lock_data(sbi->ll_md_exp, &lockh->cookie, inode, NULL);
+	md_set_lock_data(sbi->ll_md_exp, lockh, inode, NULL);
 
 	lock_res_and_lock(lock);
 	lvb_ready = ldlm_is_lvb_ready(lock);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index a5a3023..cbd5bc5 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1243,7 +1243,7 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 			CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for remote lock %#llx\n",
 			       PFID(ll_inode2fid(inode)), inode,
 			       handle.cookie);
-			md_set_lock_data(exp, &handle.cookie, inode, NULL);
+			md_set_lock_data(exp, &handle, inode, NULL);
 		}
 
 		handle.cookie = it->it_lock_handle;
@@ -1251,8 +1251,7 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for lock %#llx\n",
 		       PFID(ll_inode2fid(inode)), inode, handle.cookie);
 
-		md_set_lock_data(exp, &handle.cookie, inode,
-				 &it->it_lock_bits);
+		md_set_lock_data(exp, &handle, inode, &it->it_lock_bits);
 		it->it_lock_set = 1;
 	}
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 62f6bd0..85cc5cb 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -250,7 +250,7 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 				ptlrpc_req_finished(req);
 		}
 
-		md_set_lock_data(tgt->ltd_exp, &lockh->cookie, inode, NULL);
+		md_set_lock_data(tgt->ltd_exp, lockh, inode, NULL);
 
 		if (i != 0)
 			nlink += inode->i_nlink - 2;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 72249bb..22b7896 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3060,8 +3060,9 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 	return rc;
 }
 
-static int lmv_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
-			     __u64 *bits)
+static int lmv_set_lock_data(struct obd_export *exp,
+			     const struct lustre_handle *lockh,
+			     void *data, __u64 *bits)
 {
 	struct lmv_obd	  *lmv = &exp->exp_obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 9e65cdb..f778a92 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -61,7 +61,8 @@ void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 
 /* mdc/mdc_locks.c */
 int mdc_set_lock_data(struct obd_export *exp,
-		      __u64 *lockh, void *data, __u64 *bits);
+		      const struct lustre_handle *lockh,
+		      void *data, __u64 *bits);
 
 int mdc_null_inode(struct obd_export *exp, const struct lu_fid *fid);
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index f38339a..95dd291 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -93,8 +93,8 @@ int it_open_error(int phase, struct lookup_intent *it)
 EXPORT_SYMBOL(it_open_error);
 
 /* this must be called on a lockh that is known to have a referenced lock */
-int mdc_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
-		      __u64 *bits)
+int mdc_set_lock_data(struct obd_export *exp, const struct lustre_handle *lockh,
+		      void *data, __u64 *bits)
 {
 	struct ldlm_lock *lock;
 	struct inode *new_inode = data;
@@ -102,10 +102,10 @@ int mdc_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
 	if (bits)
 		*bits = 0;
 
-	if (!*lockh)
+	if (!lustre_handle_is_used(lockh))
 		return 0;
 
-	lock = ldlm_handle2lock((struct lustre_handle *)lockh);
+	lock = ldlm_handle2lock(lockh);
 
 	LASSERT(lock);
 	lock_res_and_lock(lock);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 7a182be..91c0b45 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1342,7 +1342,8 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	rc = 0;
-	mdc_set_lock_data(exp, &it.it_lock_handle, dir, NULL);
+	lockh.cookie = it.it_lock_handle;
+	mdc_set_lock_data(exp, &lockh, dir, NULL);
 
 	rp_param.rp_off = hash_offset;
 	rp_param.rp_hash64 = op_data->op_cli_flags & CLI_HASH64;
@@ -1431,9 +1432,7 @@ hash_collision:
 	}
 	*ppage = page;
 out_unlock:
-	lockh.cookie = it.it_lock_handle;
 	ldlm_lock_decref(&lockh, it.it_lock_mode);
-	it.it_lock_handle = 0;
 	return rc;
 fail:
 	kunmap(page);
-- 
2.7.4
