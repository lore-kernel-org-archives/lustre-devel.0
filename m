From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:37 -0400
Subject: [lustre-devel] [PATCH 34/38] lustre: osc: enhance end to end bulk
 cksum error report
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Some sites have experienced spurious checksum errors upon bulk
xfers where it is very difficult to determine the source of the
corruption. With this patch, upon cksum error, full dump of all
pages in a bulk xfer is now possible (enabled via a /sysfs
tunable) on both Client and OSS sides, to allow easier root
cause identification.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8376
Reviewed-on: https://review.whamcloud.com/23960
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c      |   1 +
 drivers/staging/lustre/lustre/include/obd.h     |   6 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c   |  31 ++++++
 drivers/staging/lustre/lustre/osc/osc_request.c | 140 +++++++++++++++++++-----
 4 files changed, 147 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 0289f24..dd06a4c 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -219,6 +219,7 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 static wait_queue_head_t debug_ctlwq;
 
 char libcfs_debug_file_path_arr[PATH_MAX] = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
+EXPORT_SYMBOL(libcfs_debug_file_path_arr);
 
 /* We need to pass a pointer here, but elsewhere this must be a const */
 static char *libcfs_debug_file_path;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 385a88d..329bae9 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -324,7 +324,8 @@ struct client_obd {
 	struct obd_export       *cl_mgc_mgsexp;
 
 	/* checksumming for data sent over the network */
-	unsigned int	     cl_checksum:1; /* 0 = disabled, 1 = enabled */
+	unsigned int		 cl_checksum:1,	/* 0 = disabled, 1 = enabled */
+				 cl_checksum_dump:1; /* same */
 	/* supported checksum types that are worked out at connect time */
 	__u32		    cl_supp_cksum_types;
 	/* checksum algorithm to be used */
@@ -557,7 +558,8 @@ struct obd_device {
 					    * (for sysfs status only!!)
 					    */
 		      obd_no_ir:1,	 /* no imperative recovery. */
-		      obd_process_conf:1;  /* device is processing mgs config */
+		      obd_process_conf:1,  /* device is processing mgs config */
+		      obd_checksum_dump:1; /* dump pages upon cksum error */
 	/* use separate field as it is set in interrupt to don't mess with
 	 * protection of other bits using _bh lock
 	 */
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 79a30b3..89dadba 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -491,6 +491,36 @@ static ssize_t resend_count_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(resend_count);
 
+static ssize_t checksum_dump_show(struct kobject *kobj,
+				  struct attribute *attr,
+				  char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+
+	return sprintf(buf, "%d\n", obd->u.cli.cl_checksum_dump ? 1 : 0);
+}
+
+static ssize_t checksum_dump_store(struct kobject *kobj,
+				   struct attribute *attr,
+				   const char *buffer,
+				   size_t count)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	obd->u.cli.cl_checksum_dump = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(checksum_dump);
+
 static ssize_t contention_seconds_show(struct kobject *kobj,
 				       struct attribute *attr,
 				       char *buf)
@@ -828,6 +858,7 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 static struct attribute *osc_attrs[] = {
 	&lustre_attr_active.attr,
 	&lustre_attr_checksums.attr,
+	&lustre_attr_checksum_dump.attr,
 	&lustre_attr_contention_seconds.attr,
 	&lustre_attr_cur_dirty_bytes.attr,
 	&lustre_attr_cur_grant_bytes.attr,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4f57a8e..a7a4a53 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1306,6 +1306,12 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			body->oa.o_flags |= cksum_type_pack(cli->cl_cksum_type);
 			body->oa.o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
 		}
+
+		/* Client cksum has been already copied to wire obdo in previous
+		 * lustre_set_wire_obdo(), and in the case a bulk-read is being
+		 * resent due to cksum error, this will allow Server to
+		 * check+dump pages on its side
+		 */
 	}
 	ptlrpc_request_set_replen(req);
 
@@ -1333,11 +1339,73 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	return rc;
 }
 
+char dbgcksum_file_name[PATH_MAX];
+
+static void dump_all_bulk_pages(struct obdo *oa, u32 page_count,
+				struct brw_page **pga, u32 server_cksum,
+				u32 client_cksum)
+{
+	struct file *filp;
+	unsigned int len;
+	int rc, i;
+	char *buf;
+
+	/* will only keep dump of pages on first error for the same range in
+	 * file/fid, not during the resends/retries.
+	 */
+	snprintf(dbgcksum_file_name, sizeof(dbgcksum_file_name),
+		 "%s-checksum_dump-osc-" DFID ":[%llu-%llu]-%x-%x",
+		 (strncmp(libcfs_debug_file_path_arr, "NONE", 4) != 0 ?
+		  libcfs_debug_file_path_arr :
+		  LIBCFS_DEBUG_FILE_PATH_DEFAULT),
+		 oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : 0ULL,
+		 oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
+		 oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
+		 pga[0]->off,
+		 pga[page_count - 1]->off + pga[page_count - 1]->count - 1,
+		 client_cksum, server_cksum);
+	filp = filp_open(dbgcksum_file_name,
+			 O_CREAT | O_EXCL | O_WRONLY | O_LARGEFILE, 0600);
+	if (IS_ERR(filp)) {
+		rc = PTR_ERR(filp);
+		if (rc == -EEXIST)
+			CDEBUG(D_INFO,
+			       "%s: can't open to dump pages with checksum error: rc = %d\n",
+			       dbgcksum_file_name, rc);
+		else
+			CERROR("%s: can't open to dump pages with checksum error: rc = %d\n",
+			       dbgcksum_file_name, rc);
+		return;
+	}
+
+	for (i = 0; i < page_count; i++) {
+		len = pga[i]->count;
+		buf = kmap(pga[i]->pg);
+		while (len != 0) {
+			rc = kernel_write(filp, buf, len, &filp->f_pos);
+			if (rc < 0) {
+				CERROR("%s: wanted to write %u but got %d error\n",
+				       dbgcksum_file_name, len, rc);
+				break;
+			}
+			len -= rc;
+			buf += rc;
+			CDEBUG(D_INFO, "%s: wrote %d bytes\n",
+			       dbgcksum_file_name, rc);
+		}
+		kunmap(pga[i]->pg);
+	}
+
+	rc = vfs_fsync_range(filp, 0, LLONG_MAX, 1);
+	if (rc)
+		CERROR("%s: sync returns %d\n", dbgcksum_file_name, rc);
+	filp_close(filp, NULL);
+}
+
 static int check_write_checksum(struct obdo *oa,
 				const struct lnet_process_id *peer,
-				__u32 client_cksum, __u32 server_cksum, int nob,
-				u32 page_count, struct brw_page **pga,
-				enum cksum_type client_cksum_type)
+				u32 client_cksum, u32 server_cksum,
+				struct osc_brw_async_args *aa)
 {
 	__u32 new_cksum;
 	char *msg;
@@ -1348,12 +1416,16 @@ static int check_write_checksum(struct obdo *oa,
 		return 0;
 	}
 
+	if (aa->aa_cli->cl_checksum_dump)
+		dump_all_bulk_pages(oa, aa->aa_page_count, aa->aa_ppga,
+				    server_cksum, client_cksum);
+
 	cksum_type = cksum_type_unpack(oa->o_valid & OBD_MD_FLFLAGS ?
 				       oa->o_flags : 0);
-	new_cksum = osc_checksum_bulk(nob, page_count, pga, OST_WRITE,
-				      cksum_type);
+	new_cksum = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
+				      aa->aa_ppga, OST_WRITE, cksum_type);
 
-	if (cksum_type != client_cksum_type)
+	if (cksum_type != cksum_type_unpack(aa->aa_oa->o_flags))
 		msg = "the server did not use the checksum type specified in the original request - likely a protocol problem"
 			;
 	else if (new_cksum == server_cksum)
@@ -1365,17 +1437,19 @@ static int check_write_checksum(struct obdo *oa,
 		msg = "changed in transit AND doesn't match the original - likely false positive due to mmap IO (bug 11742)"
 			;
 
-	LCONSOLE_ERROR_MSG(0x132, "BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu]\n",
+	LCONSOLE_ERROR_MSG(0x132,
+			   "%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
+			   aa->aa_cli->cl_import->imp_obd->obd_name,
 			   msg, libcfs_nid2str(peer->nid),
-			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (__u64)0,
+			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
-			   POSTID(&oa->o_oi), pga[0]->off,
-			   pga[page_count - 1]->off +
-			   pga[page_count - 1]->count - 1);
-	CERROR("original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
-	       client_cksum, client_cksum_type,
-	       server_cksum, cksum_type, new_cksum);
+			   POSTID(&oa->o_oi), aa->aa_ppga[0]->off,
+			   aa->aa_ppga[aa->aa_page_count - 1]->off +
+				aa->aa_ppga[aa->aa_page_count - 1]->count - 1,
+			   client_cksum, cksum_type_unpack(aa->aa_oa->o_flags),
+			   server_cksum, cksum_type, new_cksum);
+
 	return 1;
 }
 
@@ -1432,9 +1506,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 		if ((aa->aa_oa->o_valid & OBD_MD_FLCKSUM) && client_cksum &&
 		    check_write_checksum(&body->oa, peer, client_cksum,
-					 body->oa.o_cksum, aa->aa_requested_nob,
-					 aa->aa_page_count, aa->aa_ppga,
-					 cksum_type_unpack(aa->aa_oa->o_flags)))
+					 body->oa.o_cksum, aa))
 			return -EAGAIN;
 
 		rc = check_write_rcs(req, aa->aa_requested_nob,
@@ -1487,23 +1559,33 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		}
 
 		if (server_cksum != client_cksum) {
-			LCONSOLE_ERROR_MSG(0x133, "%s: BAD READ CHECKSUM: from %s%s%s inode " DFID " object " DOSTID " extent [%llu-%llu]\n",
+			u32 page_count = aa->aa_page_count;
+			struct ost_body *clbody;
+
+			clbody = req_capsule_client_get(&req->rq_pill,
+							&RMF_OST_BODY);
+			if (cli->cl_checksum_dump)
+				dump_all_bulk_pages(&clbody->oa, page_count,
+						    aa->aa_ppga, server_cksum,
+						    client_cksum);
+
+			LCONSOLE_ERROR_MSG(0x133,
+					   "%s: BAD READ CHECKSUM: from %s%s%s inode " DFID " object " DOSTID " extent [%llu-%llu], client %x, server %x, cksum_type %x\n",
 					   req->rq_import->imp_obd->obd_name,
 					   libcfs_nid2str(peer->nid),
 					   via, router,
-					   body->oa.o_valid & OBD_MD_FLFID ?
-					   body->oa.o_parent_seq : (__u64)0,
-					   body->oa.o_valid & OBD_MD_FLFID ?
-					   body->oa.o_parent_oid : 0,
-					   body->oa.o_valid & OBD_MD_FLFID ?
-					   body->oa.o_parent_ver : 0,
+					   clbody->oa.o_valid & OBD_MD_FLFID ?
+						clbody->oa.o_parent_seq : (u64)0,
+					   clbody->oa.o_valid & OBD_MD_FLFID ?
+						clbody->oa.o_parent_oid : 0,
+					   clbody->oa.o_valid & OBD_MD_FLFID ?
+						clbody->oa.o_parent_ver : 0,
 					   POSTID(&body->oa.o_oi),
 					   aa->aa_ppga[0]->off,
-					   aa->aa_ppga[aa->aa_page_count-1]->off +
-					   aa->aa_ppga[aa->aa_page_count-1]->count -
-					   1);
-			CERROR("client %x, server %x, cksum_type %x\n",
-			       client_cksum, server_cksum, cksum_type);
+					   aa->aa_ppga[page_count - 1]->off +
+					   aa->aa_ppga[page_count - 1]->count - 1,
+					   client_cksum, server_cksum,
+					   cksum_type);
 			cksum_counter = 0;
 			aa->aa_oa->o_cksum = client_cksum;
 			rc = -EAGAIN;
-- 
1.8.3.1
