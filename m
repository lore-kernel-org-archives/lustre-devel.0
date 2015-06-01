From: Antonio Murdaca <antoniomurdaca@gmail.com>
Date: Mon,  1 Jun 2015 14:18:51 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: cleanup not needed else
	clauses
Message-ID: <1433161131-25946-1-git-send-email-antonio.murdaca@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cleanup checkpatch.pl warnings about not needed else
clauses after a break or return

Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    |  5 ++-
 .../staging/lustre/lustre/include/lprocfs_status.h |  3 +-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 36 +++++++++++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 11 ++++---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  3 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |  3 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  8 ++---
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  6 ++--
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |  6 ++--
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  3 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 14 +++++----
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  8 ++---
 13 files changed, 50 insertions(+), 59 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 7aee393..d124727 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -201,10 +201,9 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 			CERROR("%s: Can't allocate new meta-sequence, rc %d\n",
 			       seq->lcs_name, rc);
 			return rc;
-		} else {
-			CDEBUG(D_INFO, "%s: New range - "DRANGE"\n",
-			       seq->lcs_name, PRANGE(&seq->lcs_space));
 		}
+		CDEBUG(D_INFO, "%s: New range - "DRANGE"\n",
+		       seq->lcs_name, PRANGE(&seq->lcs_space));
 	} else {
 		rc = 0;
 	}
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index d030847..e423ade 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -422,9 +422,8 @@ static inline int lprocfs_stats_lock(struct lprocfs_stats *stats, int opc,
 			else
 				spin_lock(&stats->ls_lock);
 			return 1;
-		} else {
-			return stats->ls_biggest_alloc_num;
 		}
+		return stats->ls_biggest_alloc_num;
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index 19448fe..47aa8c4 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -836,25 +836,25 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 					*exceed = 1;
 			}
 			return result;
-		} else {
-			/*
-			 * region is within kms and, hence, within real file
-			 * size (A). We need to increase i_size to cover the
-			 * read region so that generic_file_read() will do its
-			 * job, but that doesn't mean the kms size is
-			 * _correct_, it is only the _minimum_ size. If
-			 * someone does a stat they will get the correct size
-			 * which will always be >= the kms value here.
-			 * b=11081
-			 */
-			if (cl_isize_read(inode) < kms) {
-				cl_isize_write_nolock(inode, kms);
-				CDEBUG(D_VFSTRACE,
-				       DFID" updating i_size %llu\n",
-				       PFID(lu_object_fid(&obj->co_lu)),
-				       (__u64)cl_isize_read(inode));
+		}
+
+		/*
+		 * region is within kms and, hence, within real file
+		 * size (A). We need to increase i_size to cover the
+		 * read region so that generic_file_read() will do its
+		 * job, but that doesn't mean the kms size is
+		 * _correct_, it is only the _minimum_ size. If
+		 * someone does a stat they will get the correct size
+		 * which will always be >= the kms value here.
+		 * b=11081
+		 */
+		if (cl_isize_read(inode) < kms) {
+			cl_isize_write_nolock(inode, kms);
+			CDEBUG(D_VFSTRACE,
+			       DFID" updating i_size %llu\n",
+			       PFID(lu_object_fid(&obj->co_lu)),
+			       (__u64)cl_isize_read(inode));
 
-			}
 		}
 	}
 	ccc_object_size_unlock(obj);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 0a0b435..764f986 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -667,10 +667,9 @@ int target_send_reply_msg(struct ptlrpc_request *req, int rc, int fail_id)
 		DEBUG_REQ(D_NET, req, "processing error (%d)", rc);
 		req->rq_status = rc;
 		return ptlrpc_send_error(req, 1);
-	} else {
-		DEBUG_REQ(D_NET, req, "sending reply");
 	}
 
+	DEBUG_REQ(D_NET, req, "sending reply");
 	return ptlrpc_send_reply(req, PTLRPC_REPLY_MAYBE_DIFFICULT);
 }
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 6a22f41..bb2246d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -931,7 +931,9 @@ static void search_granted_lock(struct list_head *queue,
 			prev->mode_link = &mode_end->l_sl_mode;
 			prev->policy_link = &req->l_sl_policy;
 			return;
-		} else if (lock->l_resource->lr_type == LDLM_IBITS) {
+		}
+
+		if (lock->l_resource->lr_type == LDLM_IBITS) {
 			for (;;) {
 				policy_end =
 					list_entry(lock->l_sl_policy.prev,
@@ -967,11 +969,10 @@ static void search_granted_lock(struct list_head *queue,
 			prev->mode_link = &mode_end->l_sl_mode;
 			prev->policy_link = &req->l_sl_policy;
 			return;
-		} else {
-			LDLM_ERROR(lock,
-				   "is not LDLM_PLAIN or LDLM_IBITS lock");
-			LBUG();
 		}
+
+		LDLM_ERROR(lock, "is not LDLM_PLAIN or LDLM_IBITS lock");
+		LBUG();
 	}
 
 	/* insert point is last lock on the queue,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 53e1377..ee3971e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -1362,8 +1362,7 @@ static int ldlm_pools_thread_main(void *arg)
 
 		if (thread_test_and_clear_flags(thread, SVC_STOPPING))
 			break;
-		else
-			thread_test_and_clear_flags(thread, SVC_EVENT);
+		thread_test_and_clear_flags(thread, SVC_EVENT);
 	}
 
 	thread_set_flags(thread, SVC_STOPPED);
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index f6e1314..8fdfd68 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -617,8 +617,7 @@ void lov_update_statfs(struct obd_statfs *osfs, struct obd_statfs *lov_sfs,
 				if (tmp & 1) {
 					if (quit)
 						break;
-					else
-						quit = 1;
+					quit = 1;
 					shift = 0;
 				}
 				tmp >>= 1;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index cbbdfce..539c31d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -75,11 +75,11 @@ static int mdc_unpack_capa(struct obd_export *exp, struct ptlrpc_request *req,
 	if (IS_ERR(c)) {
 		CDEBUG(D_INFO, "alloc capa failed!\n");
 		return PTR_ERR(c);
-	} else {
-		c->c_capa = *capa;
-		*oc = c;
-		return 0;
 	}
+
+	c->c_capa = *capa;
+	*oc = c;
+	return 0;
 }
 
 static inline int mdc_queue_wait(struct ptlrpc_request *req)
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index f13d1fb..163fe0c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -906,10 +906,8 @@ struct lu_env *cl_env_nested_get(struct cl_env_nest *nest)
 	if (env != NULL) {
 		if (!cl_io_is_going(env))
 			return env;
-		else {
-			cl_env_put(env, &nest->cen_refcheck);
-			nest->cen_cookie = cl_env_reenter();
-		}
+		cl_env_put(env, &nest->cen_refcheck);
+		nest->cen_cookie = cl_env_reenter();
 	}
 	env = cl_env_get(&nest->cen_refcheck);
 	if (IS_ERR(env)) {
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index c8f6ab0..48dbbcf 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -279,9 +279,8 @@ static struct llog_handle *llog_cat_current_log(struct llog_handle *cathandle,
 		    loghandle->lgh_last_idx < LLOG_BITMAP_SIZE(llh) - 1) {
 			up_read(&cathandle->lgh_lock);
 			return loghandle;
-		} else {
-			up_write(&loghandle->lgh_lock);
 		}
+		up_write(&loghandle->lgh_lock);
 	}
 	up_read(&cathandle->lgh_lock);
 
@@ -299,9 +298,8 @@ static struct llog_handle *llog_cat_current_log(struct llog_handle *cathandle,
 		if (loghandle->lgh_last_idx < LLOG_BITMAP_SIZE(llh) - 1) {
 			up_write(&cathandle->lgh_lock);
 			return loghandle;
-		} else {
-			up_write(&loghandle->lgh_lock);
 		}
+		up_write(&loghandle->lgh_lock);
 	}
 
 	CDEBUG(D_INODE, "use next log\n");
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 350ad49..2516e2f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1176,8 +1176,7 @@ static int osc_lock_wait(const struct lu_env *env,
 				/* It is from enqueue RPC reply upcall for
 				 * updating state. Do not re-enqueue. */
 				return -ENAVAIL;
-			else
-				olck->ols_state = OLS_NEW;
+			olck->ols_state = OLS_NEW;
 		} else {
 			LASSERT(lock->cll_error);
 			return lock->cll_error;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index ded184e..065d8ff 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1007,8 +1007,8 @@ static int osc_should_shrink_grant(struct client_obd *client)
 		if (client->cl_import->imp_state == LUSTRE_IMP_FULL &&
 		    client->cl_avail_grant > brw_size)
 			return 1;
-		else
-			osc_update_next_shrink(client);
+
+		osc_update_next_shrink(client);
 	}
 	return 0;
 }
@@ -2300,7 +2300,9 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			ldlm_lock_decref(lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return -ECANCELED;
-		} else if (osc_set_lock_data_with_check(matched, einfo)) {
+		}
+
+		if (osc_set_lock_data_with_check(matched, einfo)) {
 			*flags |= LDLM_FL_LVB_READY;
 			/* addref the lock only if not async requests and PW
 			 * lock is matched whereas we asked for PR. */
@@ -2325,10 +2327,10 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 				ldlm_lock_decref(lockh, einfo->ei_mode);
 			LDLM_LOCK_PUT(matched);
 			return ELDLM_OK;
-		} else {
-			ldlm_lock_decref(lockh, mode);
-			LDLM_LOCK_PUT(matched);
 		}
+
+		ldlm_lock_decref(lockh, mode);
+		LDLM_LOCK_PUT(matched);
 	}
 
  no_match:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 5abb91c..7106049 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -289,12 +289,10 @@ static int ptlrpc_pinger_main(void *arg)
 				     thread_is_stopping(thread) ||
 				     thread_is_event(thread),
 				     &lwi);
-			if (thread_test_and_clear_flags(thread, SVC_STOPPING)) {
+			if (thread_test_and_clear_flags(thread, SVC_STOPPING))
 				break;
-			} else {
-				/* woken after adding import to reset timer */
-				thread_test_and_clear_flags(thread, SVC_EVENT);
-			}
+			/* woken after adding import to reset timer */
+			thread_test_and_clear_flags(thread, SVC_EVENT);
 		}
 	}
 
-- 
2.4.2
