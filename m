From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 06/30] staging: lustre: remove current_pid()
 and current_comm()
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731258.24196.14857062582444612938.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Just use current->pid and current->comm directly, instead
of having wrappers.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |    4 ----
 drivers/staging/lustre/lnet/libcfs/debug.c         |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |    6 +++---
 drivers/staging/lustre/lustre/lov/lov_merge.c      |    2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    6 +++---
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    8 ++++----
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    6 +++---
 11 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index d6e4f47b5daf..83526f84495d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -48,10 +48,6 @@
  * kernel_cap_t
  */
 
-/* check if task is running in compat mode.*/
-#define current_pid()		(current->pid)
-#define current_comm()		(current->comm)
-
 typedef u32 cfs_cap_t;
 
 #define CFS_CAP_FS_MASK (BIT(CAP_CHOWN) |		\
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 5862f0730dd0..724a453a27ac 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -373,7 +373,7 @@ void libcfs_debug_dumplog(void)
 	add_wait_queue(&debug_ctlwq, &wait);
 
 	dumper = kthread_run(libcfs_debug_dumplog_thread,
-			     (void *)(long)current_pid(),
+			     (void *)(long)current->pid,
 			     "libcfs_debug_dumper");
 	set_current_state(TASK_INTERRUPTIBLE);
 	if (IS_ERR(dumper))
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 22c49cc593e3..763acd2311a2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1558,7 +1558,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 
 	lock->l_req_mode = mode;
 	lock->l_ast_data = data;
-	lock->l_pid = current_pid();
+	lock->l_pid = current->pid;
 	if (cbs) {
 		lock->l_blocking_ast = cbs->lcs_blocking;
 		lock->l_completion_ast = cbs->lcs_completion;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 6504850e3689..379d88e20cd3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1140,7 +1140,7 @@ dentry_may_statahead(struct inode *dir, struct dentry *dentry)
 		return false;
 
 	/* not the same process, don't statahead */
-	if (lli->lli_opendir_pid != current_pid())
+	if (lli->lli_opendir_pid != current->pid)
 		return false;
 
 	/*
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index b4a6ee6c83f3..d864f5f36d85 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1075,7 +1075,7 @@ static int ll_statahead_thread(void *arg)
 			CDEBUG(D_READA, "Statahead for dir " DFID " hit ratio too low: hit/miss %llu/%llu, sent/replied %llu/%llu, stopping statahead thread: pid %d\n",
 			       PFID(&lli->lli_fid), sai->sai_hit,
 			       sai->sai_miss, sai->sai_sent,
-			       sai->sai_replied, current_pid());
+			       sai->sai_replied, current->pid);
 			break;
 		}
 	}
@@ -1147,7 +1147,7 @@ void ll_authorize_statahead(struct inode *dir, void *key)
 		 */
 		LASSERT(!lli->lli_opendir_pid);
 		lli->lli_opendir_key = key;
-		lli->lli_opendir_pid = current_pid();
+		lli->lli_opendir_pid = current->pid;
 		lli->lli_sa_enabled = 1;
 	}
 	spin_unlock(&lli->lli_sa_lock);
@@ -1506,7 +1506,7 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_running);
 
 	CDEBUG(D_READA, "start statahead thread: [pid %d] [parent %pd]\n",
-	       current_pid(), parent);
+	       current->pid, parent);
 
 	task = kthread_create(ll_statahead_thread, parent, "ll_sa_%u",
 			      lli->lli_opendir_pid);
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 3796bbb25305..3a0f21dc1f8a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -56,7 +56,7 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 	int rc = 0;
 
 	assert_spin_locked(&lsm->lsm_lock);
-	LASSERT(lsm->lsm_lock_owner == current_pid());
+	LASSERT(lsm->lsm_lock_owner == current->pid);
 
 	CDEBUG(D_INODE, "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 	       POSTID(&lsm->lsm_oi), lvb->lvb_size, lvb->lvb_mtime,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index d091e03098b5..a5ab0ce38e41 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1297,16 +1297,16 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 void lov_stripe_lock(struct lov_stripe_md *md)
 		__acquires(&md->lsm_lock)
 {
-	LASSERT(md->lsm_lock_owner != current_pid());
+	LASSERT(md->lsm_lock_owner != current->pid);
 	spin_lock(&md->lsm_lock);
 	LASSERT(md->lsm_lock_owner == 0);
-	md->lsm_lock_owner = current_pid();
+	md->lsm_lock_owner = current->pid;
 }
 
 void lov_stripe_unlock(struct lov_stripe_md *md)
 		__releases(&md->lsm_lock)
 {
-	LASSERT(md->lsm_lock_owner == current_pid());
+	LASSERT(md->lsm_lock_owner == current->pid);
 	md->lsm_lock_owner = 0;
 	spin_unlock(&md->lsm_lock);
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 2dd8728760d1..bc5e7f560b71 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -100,7 +100,7 @@ int lustre_get_jobid(char *jobid)
 	/* Use process name + fsuid as jobid */
 	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
 		snprintf(jobid, LUSTRE_JOBID_SIZE, "%s.%u",
-			 current_comm(),
+			 current->comm,
 			 from_kuid(&init_user_ns, current_fsuid()));
 		return 0;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 2c92119b37be..0155294184f1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2296,7 +2296,7 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		goto out;
 	default:
 		CDEBUG(D_INODE, "unrecognised ioctl %#x by %s\n",
-		       cmd, current_comm());
+		       cmd, current->comm);
 		err = -ENOTTY;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index a868ff6e720f..dd71eefe8452 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1552,7 +1552,7 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 
 	lustre_msg_set_last_xid(req->rq_reqmsg, min_xid);
 
-	lustre_msg_set_status(req->rq_reqmsg, current_pid());
+	lustre_msg_set_status(req->rq_reqmsg, current->pid);
 
 	rc = sptlrpc_req_refresh_ctx(req, -1);
 	if (rc) {
@@ -1567,7 +1567,7 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	}
 
 	CDEBUG(D_RPCTRACE, "Sending RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
-	       current_comm(),
+	       current->comm,
 	       imp->imp_obd->obd_uuid.uuid,
 	       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
 	       libcfs_nid2str(imp->imp_connection->c_peer.nid),
@@ -1978,7 +1978,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 
 		CDEBUG(req->rq_reqmsg ? D_RPCTRACE : 0,
 		       "Completed RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
-		       current_comm(), imp->imp_obd->obd_uuid.uuid,
+		       current->comm, imp->imp_obd->obd_uuid.uuid,
 		       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
 		       libcfs_nid2str(imp->imp_connection->c_peer.nid),
 		       lustre_msg_get_opc(req->rq_reqmsg));
@@ -2760,7 +2760,7 @@ int ptlrpc_queue_wait(struct ptlrpc_request *req)
 	}
 
 	/* for distributed debugging */
-	lustre_msg_set_status(req->rq_reqmsg, current_pid());
+	lustre_msg_set_status(req->rq_reqmsg, current->pid);
 
 	/* add a ref for the set (see comment in ptlrpc_set_add_req) */
 	ptlrpc_request_addref(req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 1d28139c950e..f1de9dd551cd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1679,7 +1679,7 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	}
 
 	CDEBUG(D_RPCTRACE, "Handling RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d\n",
-	       current_comm(),
+	       current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
@@ -1723,7 +1723,7 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	arrived_usecs = arrived.tv_sec * USEC_PER_SEC +
 			 arrived.tv_nsec / NSEC_PER_USEC;
 	CDEBUG(D_RPCTRACE, "Handled RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d Request processed in %ldus (%ldus total) trans %llu rc %d/%d\n",
-	       current_comm(),
+	       current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
@@ -2018,7 +2018,7 @@ static int ptlrpc_main(void *arg)
 	struct lu_env *env;
 	int counter = 0, rc = 0;
 
-	thread->t_pid = current_pid();
+	thread->t_pid = current->pid;
 	unshare_fs_struct();
 
 	/* NB: we will call cfs_cpt_bind() for all threads, because we
