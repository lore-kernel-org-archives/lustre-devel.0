From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 25/37] lustre: deprecate libcfs_debug_vmsg2
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494619.24125.5150721300459339252.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Since 2.6.36, Linux' vsprintf has supported %pV
which supports "recursive sprintf" - exactly the task
that libcfs_debug_vmsg2 aims to provide.

Instead of calling libcfs_debug_vmsg2(), we can put the fmt and
args in a 'struct va_format', and pass the address of that structure
to the "%pV" format.

So do this to remove all users of libcfs_debug_vmsg2().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  176 ++++++++++----------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   42 +++--
 2 files changed, 115 insertions(+), 103 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index f2433dc0e558..6789d3bf0485 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1970,6 +1970,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	struct ldlm_resource *resource = NULL;
 	char *nid = "local";
 	va_list args;
+	struct va_format vaf;
 
 	if (spin_trylock(&lock->l_lock)) {
 		if (lock->l_resource)
@@ -1978,6 +1979,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	}
 
 	va_start(args, fmt);
+	vaf.fmt = fmt;
+	vaf.va = &args;
 
 	if (exp && exp->exp_connection) {
 		nid = libcfs_nid2str(exp->exp_connection->c_peer.nid);
@@ -1988,105 +1991,110 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	}
 
 	if (!resource) {
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   lock,
-				   lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? refcount_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
+		libcfs_debug_msg(msgdata,
+				 "%pV ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 &vaf,
+				 lock,
+				 lock->l_handle.h_cookie,
+				 atomic_read(&lock->l_refc),
+				 lock->l_readers, lock->l_writers,
+				 ldlm_lockname[lock->l_granted_mode],
+				 ldlm_lockname[lock->l_req_mode],
+				 lock->l_flags, nid,
+				 lock->l_remote_handle.cookie,
+				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 lock->l_pid, lock->l_callback_timeout,
+				 lock->l_lvb_type);
 		va_end(args);
 		return;
 	}
 
 	switch (resource->lr_type) {
 	case LDLM_EXTENT:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   ldlm_lock_to_ns_name(lock), lock,
-				   lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_policy_data.l_extent.start,
-				   lock->l_policy_data.l_extent.end,
-				   lock->l_req_extent.start,
-				   lock->l_req_extent.end,
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? refcount_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
+		libcfs_debug_msg(msgdata,
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 &vaf,
+				 ldlm_lock_to_ns_name(lock), lock,
+				 lock->l_handle.h_cookie,
+				 atomic_read(&lock->l_refc),
+				 lock->l_readers, lock->l_writers,
+				 ldlm_lockname[lock->l_granted_mode],
+				 ldlm_lockname[lock->l_req_mode],
+				 PLDLMRES(resource),
+				 atomic_read(&resource->lr_refcount),
+				 ldlm_typename[resource->lr_type],
+				 lock->l_policy_data.l_extent.start,
+				 lock->l_policy_data.l_extent.end,
+				 lock->l_req_extent.start,
+				 lock->l_req_extent.end,
+				 lock->l_flags, nid,
+				 lock->l_remote_handle.cookie,
+				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 lock->l_pid, lock->l_callback_timeout,
+				 lock->l_lvb_type);
 		break;
 
 	case LDLM_FLOCK:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu\n",
-				   ldlm_lock_to_ns_name(lock), lock,
-				   lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_policy_data.l_flock.pid,
-				   lock->l_policy_data.l_flock.start,
-				   lock->l_policy_data.l_flock.end,
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? refcount_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout);
+		libcfs_debug_msg(msgdata,
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu\n",
+				 &vaf,
+				 ldlm_lock_to_ns_name(lock), lock,
+				 lock->l_handle.h_cookie,
+				 atomic_read(&lock->l_refc),
+				 lock->l_readers, lock->l_writers,
+				 ldlm_lockname[lock->l_granted_mode],
+				 ldlm_lockname[lock->l_req_mode],
+				 PLDLMRES(resource),
+				 atomic_read(&resource->lr_refcount),
+				 ldlm_typename[resource->lr_type],
+				 lock->l_policy_data.l_flock.pid,
+				 lock->l_policy_data.l_flock.start,
+				 lock->l_policy_data.l_flock.end,
+				 lock->l_flags, nid,
+				 lock->l_remote_handle.cookie,
+				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 lock->l_pid, lock->l_callback_timeout);
 		break;
 
 	case LDLM_IBITS:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   ldlm_lock_to_ns_name(lock),
-				   lock, lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   lock->l_policy_data.l_inodebits.bits,
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? refcount_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
+		libcfs_debug_msg(msgdata,
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 &vaf,
+				 ldlm_lock_to_ns_name(lock),
+				 lock, lock->l_handle.h_cookie,
+				 atomic_read(&lock->l_refc),
+				 lock->l_readers, lock->l_writers,
+				 ldlm_lockname[lock->l_granted_mode],
+				 ldlm_lockname[lock->l_req_mode],
+				 PLDLMRES(resource),
+				 lock->l_policy_data.l_inodebits.bits,
+				 atomic_read(&resource->lr_refcount),
+				 ldlm_typename[resource->lr_type],
+				 lock->l_flags, nid,
+				 lock->l_remote_handle.cookie,
+				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 lock->l_pid, lock->l_callback_timeout,
+				 lock->l_lvb_type);
 		break;
 
 	default:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   ldlm_lock_to_ns_name(lock),
-				   lock, lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? refcount_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
+		libcfs_debug_msg(msgdata,
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 &vaf,
+				 ldlm_lock_to_ns_name(lock),
+				 lock, lock->l_handle.h_cookie,
+				 atomic_read(&lock->l_refc),
+				 lock->l_readers, lock->l_writers,
+				 ldlm_lockname[lock->l_granted_mode],
+				 ldlm_lockname[lock->l_req_mode],
+				 PLDLMRES(resource),
+				 atomic_read(&resource->lr_refcount),
+				 ldlm_typename[resource->lr_type],
+				 lock->l_flags, nid,
+				 lock->l_remote_handle.cookie,
+				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 lock->l_pid, lock->l_callback_timeout,
+				 lock->l_lvb_type);
 		break;
 	}
 	va_end(args);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index c7cc86c3fbc3..879cb1162cc7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2276,6 +2276,7 @@ void _debug_req(struct ptlrpc_request *req,
 	int rep_flags = -1;
 	int rep_status = -1;
 	va_list args;
+	struct va_format vaf;
 
 	spin_lock(&req->rq_early_free_lock);
 	if (req->rq_repmsg)
@@ -2298,25 +2299,28 @@ void _debug_req(struct ptlrpc_request *req,
 		nid = req->rq_export->exp_connection->c_peer.nid;
 
 	va_start(args, fmt);
-	libcfs_debug_vmsg2(msgdata, fmt, args,
-			   " req@%p x%llu/t%lld(%lld) o%d->%s@%s:%d/%d lens %d/%d e %d to %lld dl %lld ref %d fl " REQ_FLAGS_FMT "/%x/%x rc %d/%d\n",
-			   req, req->rq_xid, req->rq_transno,
-			   req_ok ? lustre_msg_get_transno(req->rq_reqmsg) : 0,
-			   req_ok ? lustre_msg_get_opc(req->rq_reqmsg) : -1,
-			   req->rq_import ?
-			   req->rq_import->imp_obd->obd_name :
-			   req->rq_export ?
-			   req->rq_export->exp_client_uuid.uuid :
-			   "<?>",
-			   libcfs_nid2str(nid),
-			   req->rq_request_portal, req->rq_reply_portal,
-			   req->rq_reqlen, req->rq_replen,
-			   req->rq_early_count, (s64)req->rq_timedout,
-			   (s64)req->rq_deadline,
-			   atomic_read(&req->rq_refcount),
-			   DEBUG_REQ_FLAGS(req),
-			   req_ok ? lustre_msg_get_flags(req->rq_reqmsg) : -1,
-			   rep_flags, req->rq_status, rep_status);
+	vaf.fmt = fmt;
+	vaf.va = &args;
+	libcfs_debug_msg(msgdata,
+			 "%pV req@%p x%llu/t%lld(%lld) o%d->%s@%s:%d/%d lens %d/%d e %d to %lld dl %lld ref %d fl " REQ_FLAGS_FMT "/%x/%x rc %d/%d\n",
+			 &vaf,
+			 req, req->rq_xid, req->rq_transno,
+			 req_ok ? lustre_msg_get_transno(req->rq_reqmsg) : 0,
+			 req_ok ? lustre_msg_get_opc(req->rq_reqmsg) : -1,
+			 req->rq_import ?
+			 req->rq_import->imp_obd->obd_name :
+			 req->rq_export ?
+			 req->rq_export->exp_client_uuid.uuid :
+			 "<?>",
+			 libcfs_nid2str(nid),
+			 req->rq_request_portal, req->rq_reply_portal,
+			 req->rq_reqlen, req->rq_replen,
+			 req->rq_early_count, (s64)req->rq_timedout,
+			 (s64)req->rq_deadline,
+			 atomic_read(&req->rq_refcount),
+			 DEBUG_REQ_FLAGS(req),
+			 req_ok ? lustre_msg_get_flags(req->rq_reqmsg) : -1,
+			 rep_flags, req->rq_status, rep_status);
 	va_end(args);
 }
 EXPORT_SYMBOL(_debug_req);
