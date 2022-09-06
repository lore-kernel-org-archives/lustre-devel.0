Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DF3A0ECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lp4qJTz1y57;
	Mon,  5 Sep 2022 18:56:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lL1Tk4z1yBr
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F1134100B053;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EE69158992; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:36 -0400
Message-Id: <1662429337-18737-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/24] lustre: idl: add checks for
 OBD_CONNECT flags
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Make it harder to accidentally declare OBD_CONNECT flags without
properly defining their names.  Otherwise, this can cause serious
compatibility problems if two features are using the same flag.

Make it clear whom to contact when reserving a new feature flag.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1904
Lustre-commit: d851381ea69472448 ("LU-1904 idl: add checks for OBD_CONNECT flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/48053
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 189 +++++++++++----------
 include/uapi/linux/lustre/lustre_idl.h | 291 +++++++++++++++------------------
 2 files changed, 227 insertions(+), 253 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 7ce20b6..64d7cc48c 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -43,101 +43,100 @@
 #include <linux/seq_file.h>
 #include <linux/ctype.h>
 
-static const char * const obd_connect_names[] = {
-	/* flags names */
-	"read_only",
-	"lov_index",
-	"connect_from_mds",
-	"write_grant",
-	"server_lock",
-	"version",
-	"request_portal",
-	"acl",
-	"xattr",
-	"create_on_write",
-	"truncate_lock",
-	"initial_transno",
-	"inode_bit_locks",
-	"join_file(obsolete)",
-	"getattr_by_fid",
-	"no_oh_for_devices",
-	"remote_client",
-	"remote_client_by_force",
-	"max_byte_per_rpc",
-	"64bit_qdata",
-	"mds_capability",
-	"oss_capability",
-	"early_lock_cancel",
-	"som",
-	"adaptive_timeouts",
-	"lru_resize",
-	"mds_mds_connection",
-	"real_conn",
-	"change_qunit_size",
-	"alt_checksum_algorithm",
-	"fid_is_enabled",
-	"version_recovery",
-	"pools",
-	"grant_shrink",
-	"skip_orphan",
-	"large_ea",
-	"full20",
-	"layout_lock",
-	"64bithash",
-	"object_max_bytes",
-	"imp_recov",
-	"jobstats",
-	"umask",
-	"einprogress",
-	"grant_param",
-	"flock_owner",
-	"lvb_type",
-	"nanoseconds_times",
-	"lightweight_conn",
-	"short_io",
-	"pingless",
-	"flock_deadlock",
-	"disp_stripe",
-	"open_by_fid",
-	"lfsck",
-	"unknown",
-	"unlink_close",
-	"multi_mod_rpcs",
-	"dir_stripe",
-	"subtree",
-	"lockahead",
-	"bulk_mbits",
-	"compact_obdo",
-	"second_flags",
-	/* flags2 names */
-	"file_secctx",	/* 0x01 */
-	"lockaheadv2",	/* 0x02 */
-	"dir_migrate",	/* 0x04 */
-	"sum_statfs",	/* 0x08 */
-	"overstriping",	/* 0x10 */
-	"flr",		/* 0x20 */
-	"wbc",		/* 0x40 */
-	"lock_convert",	/* 0x80 */
-	"archive_id_array",	/* 0x100 */
-	"increasing_xid",	/* 0x200 */
-	"selinux_policy",	/* 0x400 */
-	"lsom",			/* 0x800 */
-	"pcc",			/* 0x1000 */
-	"crush",		/* 0x2000 */
-	"async_discard",	/* 0x4000 */
-	"client_encryption",	/* 0x8000 */
-	"fidmap",		/* 0x10000 */
-	"getattr_pfid",		/* 0x20000 */
-	"lseek",		/* 0x40000 */
-	"dom_lvb",		/* 0x80000 */
-	"reply_mbits",		/* 0x100000 */
-	"mode_convert",		/* 0x200000 */
-	"batch_rpc",		/* 0x400000 */
-	"pcc_ro",		/* 0x800000 */
-	"mne_nid_type",		/* 0x1000000 */
-	"lock_contend",		/* 0x2000000 */
-	"atomic_open_lock",	/* 0x4000000 */
-	"name_encryption",	/* 0x8000000 */
+static const char *const obd_connect_names[] = {
+	"read_only",			/* 0x01 */
+	"lov_index",			/* 0x02 */
+	"connect_from_mds",		/* 0x03 */
+	"write_grant",			/* 0x04 */
+	"server_lock",			/* 0x10 */
+	"version",			/* 0x20 */
+	"request_portal",		/* 0x40 */
+	"acl",				/* 0x80 */
+	"xattr",			/* 0x100 */
+	"create_on_write",		/* 0x200 */
+	"truncate_lock",		/* 0x400 */
+	"initial_transno",		/* 0x800 */
+	"inode_bit_locks",		/* 0x1000 */
+	"barrier",			/* 0x2000 */
+	"getattr_by_fid",		/* 0x4000 */
+	"no_oh_for_devices",		/* 0x8000 */
+	"remote_client",		/* 0x10000 */
+	"remote_client_by_force",	/* 0x20000 */
+	"max_byte_per_rpc",		/* 0x40000 */
+	"64bit_qdata",			/* 0x80000 */
+	"mds_capability",		/* 0x100000 */
+	"oss_capability",		/* 0x200000 */
+	"early_lock_cancel",		/* 0x400000 */
+	"som",				/* 0x800000 */
+	"adaptive_timeouts",		/* 0x1000000 */
+	"lru_resize",			/* 0x2000000 */
+	"mds_mds_connection",		/* 0x4000000 */
+	"real_conn",			/* 0x8000000 */
+	"change_qunit_size",		/* 0x10000000 */
+	"alt_checksum_algorithm",	/* 0x20000000 */
+	"fid_is_enabled",		/* 0x40000000 */
+	"version_recovery",		/* 0x80000000 */
+	"pools",			/* 0x100000000 */
+	"grant_shrink",			/* 0x200000000 */
+	"skip_orphan",			/* 0x400000000 */
+	"large_ea",			/* 0x800000000 */
+	"full20",			/* 0x1000000000 */
+	"layout_lock",			/* 0x2000000000 */
+	"64bithash",			/* 0x4000000000 */
+	"object_max_bytes",		/* 0x8000000000 */
+	"imp_recov",			/* 0x10000000000 */
+	"jobstats",			/* 0x20000000000 */
+	"umask",			/* 0x40000000000 */
+	"einprogress",			/* 0x80000000000 */
+	"grant_param",			/* 0x100000000000 */
+	"flock_owner",			/* 0x200000000000 */
+	"lvb_type",			/* 0x400000000000 */
+	"nanoseconds_times",		/* 0x800000000000 */
+	"lightweight_conn",		/* 0x1000000000000 */
+	"short_io",			/* 0x2000000000000 */
+	"pingless",			/* 0x4000000000000 */
+	"flock_deadlock",		/* 0x8000000000000 */
+	"disp_stripe",			/* 0x10000000000000 */
+	"open_by_fid",			/* 0x20000000000000 */
+	"lfsck",			/* 0x40000000000000 */
+	"unknown",			/* 0x80000000000000 */
+	"unlink_close",			/* 0x100000000000000 */
+	"multi_mod_rpcs",		/* 0x200000000000000 */
+	"dir_stripe",			/* 0x400000000000000 */
+	"subtree",			/* 0x800000000000000 */
+	"lockahead",			/* 0x1000000000000000 */
+	"bulk_mbits",			/* 0x2000000000000000 */
+	"compact_obdo",			/* 0x4000000000000000 */
+	"second_flags",			/* 0x8000000000000000 */
+	/* ocd_connect_flags2 names */
+	"file_secctx",			/* 0x01 */
+	"lockaheadv2",			/* 0x02 */
+	"dir_migrate",			/* 0x04 */
+	"sum_statfs",			/* 0x08 */
+	"overstriping",			/* 0x10 */
+	"flr",				/* 0x20 */
+	"wbc",				/* 0x40 */
+	"lock_convert",			/* 0x80 */
+	"archive_id_array",		/* 0x100 */
+	"increasing_xid",		/* 0x200 */
+	"selinux_policy",		/* 0x400 */
+	"lsom",				/* 0x800 */
+	"pcc",				/* 0x1000 */
+	"crush",			/* 0x2000 */
+	"async_discard",		/* 0x4000 */
+	"client_encryption",		/* 0x8000 */
+	"fidmap",			/* 0x10000 */
+	"getattr_pfid",			/* 0x20000 */
+	"lseek",			/* 0x40000 */
+	"dom_lvb",			/* 0x80000 */
+	"reply_mbits",			/* 0x100000 */
+	"mode_convert",			/* 0x200000 */
+	"batch_rpc",			/* 0x400000 */
+	"pcc_ro",			/* 0x800000 */
+	"mne_nid_type",			/* 0x1000000 */
+	"lock_contend",			/* 0x2000000 */
+	"atomic_open_lock",		/* 0x4000000 */
+	"name_encryption",		/* 0x8000000 */
 	NULL
 };
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 319dc81d..475151c 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -681,147 +681,122 @@ struct ptlrpc_body_v2 {
 #define MSG_PTLRPC_HEADER_OFF		31
 
 /* Connect flags */
-#define OBD_CONNECT_RDONLY		  0x1ULL /*client has read-only access*/
-#define OBD_CONNECT_INDEX		  0x2ULL /*connect specific LOV idx */
-#define OBD_CONNECT_MDS			  0x4ULL /*connect from MDT to OST */
-#define OBD_CONNECT_GRANT		  0x8ULL /*OSC gets grant at connect */
-#define OBD_CONNECT_SRVLOCK		 0x10ULL /*server takes locks for cli */
-#define OBD_CONNECT_VERSION		 0x20ULL /*Lustre versions in ocd */
-#define OBD_CONNECT_REQPORTAL		 0x40ULL /*Separate non-IO req portal */
-#define OBD_CONNECT_ACL			 0x80ULL /*access control lists */
-#define OBD_CONNECT_XATTR		0x100ULL /*client use extended attr */
-#define OBD_CONNECT_LARGE_ACL		0x200ULL /* more than 32 ACL entries */
-/* was OBD_CONNECT_TRUNCLOCK		0x400ULL *locks on server for punch */
+#define OBD_CONNECT_RDONLY			0x1ULL /* client is read-only */
+#define OBD_CONNECT_INDEX			0x2ULL /* connect to LOV idx */
+#define OBD_CONNECT_MDS				0x4ULL /* connect MDT to OST */
+#define OBD_CONNECT_GRANT			0x8ULL /* fetch grant connect */
+#define OBD_CONNECT_SRVLOCK		       0x10ULL /* server lock for RPC */
+#define OBD_CONNECT_VERSION		       0x20ULL /* versions in OCD */
+#define OBD_CONNECT_REQPORTAL		       0x40ULL /* non-IO portal */
+#define OBD_CONNECT_ACL			       0x80ULL /* access control list */
+#define OBD_CONNECT_XATTR		      0x100ULL /* extended attributes */
+#define OBD_CONNECT_LARGE_ACL		      0x200ULL /* over 32 ACL entries */
+/* was OBD_CONNECT_TRUNCLOCK		      0x400ULL  * server locks punch */
 /* temporary reuse until 2.21.53 to indicate pre-2.15 client, see LU-15478 */
-#define OBD_CONNECT_OLD_FALLOC		0x400ULL /* missing o_valid flags */
-#define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
-#define OBD_CONNECT_IBITS	       0x1000ULL /* not checked in 2.11+ */
-#define OBD_CONNECT_BARRIER	       0x2000ULL /* write barrier. Resevered to
-						  * avoid use on client.
-						  */
-#define OBD_CONNECT_ATTRFID	       0x4000ULL /*Server can GetAttr By Fid*/
-#define OBD_CONNECT_NODEVOH	       0x8000ULL /*No open hndl on specl nodes*/
-#define OBD_CONNECT_RMT_CLIENT	      0x10000ULL /* Remote client, never used
-						  * in production. Removed in
-						  * 2.9. Keep this flag to
-						  * avoid reuse.
-						  */
-#define OBD_CONNECT_RMT_CLIENT_FORCE  0x20000ULL /* Remote client by force,
-						  * never used in production.
-						  * Removed in 2.9. Keep this
-						  * flag to avoid reuse
-						  */
-#define OBD_CONNECT_BRW_SIZE	      0x40000ULL /*Max bytes per rpc */
-#define OBD_CONNECT_QUOTA64	      0x80000ULL /*Not used since 2.4 */
-#define OBD_CONNECT_MDS_CAPA	     0x100000ULL /*MDS capability */
-#define OBD_CONNECT_OSS_CAPA	     0x200000ULL /*OSS capability */
-#define OBD_CONNECT_CANCELSET	     0x400000ULL /*Early batched cancels. */
-#define OBD_CONNECT_SOM		     0x800000ULL /*Size on MDS */
-#define OBD_CONNECT_AT		    0x1000000ULL /*client uses AT */
-#define OBD_CONNECT_LRU_RESIZE      0x2000000ULL /*LRU resize feature. */
-#define OBD_CONNECT_MDS_MDS	    0x4000000ULL /*MDS-MDS connection */
-#define OBD_CONNECT_REAL	    0x8000000ULL /* obsolete since 2.8 */
-#define OBD_CONNECT_CHANGE_QS      0x10000000ULL /*Not used since 2.4 */
-#define OBD_CONNECT_CKSUM	   0x20000000ULL /*support several cksum algos*/
-#define OBD_CONNECT_FID		   0x40000000ULL /*FID is supported by server */
-#define OBD_CONNECT_VBR		   0x80000000ULL /*version based recovery */
-#define OBD_CONNECT_LOV_V3	  0x100000000ULL /*client supports LOV v3 EA */
-#define OBD_CONNECT_GRANT_SHRINK  0x200000000ULL /* support grant shrink */
-#define OBD_CONNECT_SKIP_ORPHAN   0x400000000ULL /* don't reuse orphan objids */
-#define OBD_CONNECT_MAX_EASIZE    0x800000000ULL /* preserved for large EA */
-#define OBD_CONNECT_FULL20       0x1000000000ULL /* it is 2.0 client */
-#define OBD_CONNECT_LAYOUTLOCK   0x2000000000ULL /* client uses layout lock */
-#define OBD_CONNECT_64BITHASH    0x4000000000ULL /* client supports 64-bits
-						  * directory hash
-						  */
-#define OBD_CONNECT_MAXBYTES     0x8000000000ULL /* max stripe size */
-#define OBD_CONNECT_IMP_RECOV   0x10000000000ULL /* imp recovery support */
-#define OBD_CONNECT_JOBSTATS    0x20000000000ULL /* jobid in ptlrpc_body */
-#define OBD_CONNECT_UMASK       0x40000000000ULL /* create uses client umask */
-#define OBD_CONNECT_EINPROGRESS 0x80000000000ULL /* client handles -EINPROGRESS
-						  * RPC error properly
-						  */
-#define OBD_CONNECT_GRANT_PARAM 0x100000000000ULL/* extra grant params used for
-						  * finer space reservation
-						  */
-#define OBD_CONNECT_FLOCK_OWNER 0x200000000000ULL /* for the fixed 1.8
-						   * policy and 2.x server
-						   */
-#define OBD_CONNECT_LVB_TYPE	0x400000000000ULL /* variable type of LVB */
-#define OBD_CONNECT_NANOSEC_TIME 0x800000000000ULL /* nanosecond timestamps */
-#define OBD_CONNECT_LIGHTWEIGHT 0x1000000000000ULL/* lightweight connection */
-#define OBD_CONNECT_SHORTIO     0x2000000000000ULL/* short io */
-#define OBD_CONNECT_PINGLESS	0x4000000000000ULL/* pings not required */
-#define OBD_CONNECT_FLOCK_DEAD	0x8000000000000ULL/* flock deadlock detection */
-#define OBD_CONNECT_DISP_STRIPE 0x10000000000000ULL/*create stripe disposition*/
-#define OBD_CONNECT_OPEN_BY_FID	0x20000000000000ULL	/* open by fid won't pack
-							 * name in request
-							 */
-#define OBD_CONNECT_LFSCK	0x40000000000000ULL/* support online LFSCK */
-#define OBD_CONNECT_UNLINK_CLOSE 0x100000000000000ULL/* close file in unlink */
-#define OBD_CONNECT_MULTIMODRPCS 0x200000000000000ULL /* support multiple modify
-						       *  RPCs in parallel
-						       */
-#define OBD_CONNECT_DIR_STRIPE	 0x400000000000000ULL/* striped DNE dir */
-#define OBD_CONNECT_SUBTREE	 0x800000000000000ULL /* fileset mount */
+#define OBD_CONNECT_OLD_FALLOC		      0x400ULL /* no o_valid flags */
+#define OBD_CONNECT_TRANSNO		      0x800ULL /* replay send transno */
+#define OBD_CONNECT_IBITS		     0x1000ULL /* not checked 2.11+ */
+#define OBD_CONNECT_BARRIER		     0x2000ULL /* write barrier */
+#define OBD_CONNECT_ATTRFID		     0x4000ULL /* Server GetAttr FID */
+#define OBD_CONNECT_NODEVOH		     0x8000ULL /* No open handle spec */
+#define OBD_CONNECT_RMT_CLIENT		    0x10000ULL /* Never used, gone 2.9*/
+#define OBD_CONNECT_RMT_CLIENT_FORCE	    0x20000ULL /* Never used, gone 2.9*/
+#define OBD_CONNECT_BRW_SIZE		    0x40000ULL /* Max bytes per rpc */
+#define OBD_CONNECT_QUOTA64		    0x80000ULL /* Unused since 2.4 */
+#define OBD_CONNECT_MDS_CAPA		   0x100000ULL /* Unused since 2.7 */
+#define OBD_CONNECT_OSS_CAPA		   0x200000ULL /* Unused since 2.7 */
+#define OBD_CONNECT_CANCELSET		   0x400000ULL /* Early batch cancel */
+#define OBD_CONNECT_SOM			   0x800000ULL /* Unused since 2.7 */
+#define OBD_CONNECT_AT			  0x1000000ULL /* client uses AT */
+#define OBD_CONNECT_LRU_RESIZE		  0x2000000ULL /* LRU resize feature */
+#define OBD_CONNECT_MDS_MDS		  0x4000000ULL /* MDS-MDS connection */
+#define OBD_CONNECT_REAL		  0x8000000ULL /* Unused since 2.8 */
+#define OBD_CONNECT_CHANGE_QS		 0x10000000ULL /* Unused since 2.4 */
+#define OBD_CONNECT_CKSUM		 0x20000000ULL /* cksum algo choice */
+#define OBD_CONNECT_FID			 0x40000000ULL /* server handles FIDs */
+#define OBD_CONNECT_VBR			 0x80000000ULL /* version based recov */
+#define OBD_CONNECT_LOV_V3		0x100000000ULL /* client LOV v3 EA */
+#define OBD_CONNECT_GRANT_SHRINK	0x200000000ULL /* handle grant shrink */
+#define OBD_CONNECT_SKIP_ORPHAN		0x400000000ULL /* no orph objid reuse */
+#define OBD_CONNECT_MAX_EASIZE		0x800000000ULL /* EA size in reply */
+#define OBD_CONNECT_FULL20	       0x1000000000ULL /* it is 2.0 client */
+#define OBD_CONNECT_LAYOUTLOCK	       0x2000000000ULL /* client layout lock */
+#define OBD_CONNECT_64BITHASH	       0x4000000000ULL /* 64-bits dir hash */
+#define OBD_CONNECT_MAXBYTES	       0x8000000000ULL /* max stripe size */
+#define OBD_CONNECT_IMP_RECOV	      0x10000000000ULL /* imp recov support */
+#define OBD_CONNECT_JOBSTATS	      0x20000000000ULL /* ptlrpc_body jobid */
+#define OBD_CONNECT_UMASK	      0x40000000000ULL /* create client umask */
+#define OBD_CONNECT_EINPROGRESS	      0x80000000000ULL /* client -EINPROGRESS
+							* RPC error handling
+							*/
+#define OBD_CONNECT_GRANT_PARAM	     0x100000000000ULL /* extra grant params for
+							* space reservation
+							*/
+#define OBD_CONNECT_FLOCK_OWNER	     0x200000000000ULL /* unused since 2.0 */
+#define OBD_CONNECT_LVB_TYPE	     0x400000000000ULL /* variable LVB type */
+#define OBD_CONNECT_NANOSEC_TIME     0x800000000000ULL /* nanosec timestamp */
+#define OBD_CONNECT_LIGHTWEIGHT	    0x1000000000000ULL /* lightweight connect */
+#define OBD_CONNECT_SHORTIO	    0x2000000000000ULL /* short io */
+#define OBD_CONNECT_PINGLESS	    0x4000000000000ULL /* pings not required */
+#define OBD_CONNECT_FLOCK_DEAD	    0x8000000000000ULL /* flk deadlock detect */
+#define OBD_CONNECT_DISP_STRIPE	   0x10000000000000ULL /* create stripe disp */
+#define OBD_CONNECT_OPEN_BY_FID	   0x20000000000000ULL /* open by FID won't pack
+							* name in request
+							*/
+#define OBD_CONNECT_LFSCK	   0x40000000000000ULL /* allow online LFSCK */
+#define OBD_CONNECT_UNLINK_CLOSE  0x100000000000000ULL /* unlink closes file */
+#define OBD_CONNECT_MULTIMODRPCS  0x200000000000000ULL /* allow multiple change
+							* RPCs in parallel
+							*/
+#define OBD_CONNECT_DIR_STRIPE	  0x400000000000000ULL /* striped DNE dir */
+#define OBD_CONNECT_SUBTREE	  0x800000000000000ULL /* fileset mount */
 /* was OBD_CONNECT_LOCKAHEAD_OLD 0x1000000000000000ULL old lockahead 2.12-2.13*/
-
-/** bulk matchbits is sent within ptlrpc_body */
-#define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL
+#define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL /* ptlrpc_body matchbit*/
 #define OBD_CONNECT_OBDOPACK	 0x4000000000000000ULL /* compact OUT obdo */
 #define OBD_CONNECT_FLAGS2	 0x8000000000000000ULL /* second flags word */
 /* ocd_connect_flags2 flags */
-#define OBD_CONNECT2_FILE_SECCTX	0x1ULL		/* set file security
-							 * context at create
-							 */
-#define OBD_CONNECT2_LOCKAHEAD		0x2ULL		/* ladvise lockahead
-							 * v2
-							 */
-#define OBD_CONNECT2_DIR_MIGRATE	0x4ULL		/* migrate striped dir
-							 */
-#define OBD_CONNECT2_SUM_STATFS		0x8ULL /* MDT return aggregated stats */
-#define OBD_CONNECT2_OVERSTRIPING	0x10ULL /* OST overstriping support */
-#define OBD_CONNECT2_FLR		0x20ULL		/* FLR support */
-#define OBD_CONNECT2_WBC_INTENTS	0x40ULL /* create/unlink/... intents
-						 * for wbc, also operations
-						 * under client-held parent
-						 * locks
-						 */
-#define OBD_CONNECT2_LOCK_CONVERT	0x80ULL /* IBITS lock convert support */
-#define OBD_CONNECT2_ARCHIVE_ID_ARRAY  0x100ULL	/* store HSM archive_id in array */
-#define OBD_CONNECT2_INC_XID	       0x200ULL /* Increasing xid */
-#define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
-#define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
-#define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
-#define OBD_CONNECT2_CRUSH	       0x2000ULL /* crush hash striped directory
-						  */
-#define OBD_CONNECT2_ASYNC_DISCARD     0x4000ULL /* support async DoM data
-						  * discard
-						  */
-#define OBD_CONNECT2_ENCRYPT	       0x8000ULL /* client-to-disk encrypt */
-#define OBD_CONNECT2_FIDMAP	      0x10000ULL /* FID map */
-#define OBD_CONNECT2_GETATTR_PFID     0x20000ULL /* pack parent FID in getattr */
-#define OBD_CONNECT2_LSEEK	      0x40000ULL /* SEEK_HOLE/DATA RPC */
-#define OBD_CONNECT2_DOM_LVB	      0x80000ULL /* pack DOM glimpse data in LVB */
-#define OBD_CONNECT2_REP_MBITS	     0x100000ULL /* match reply by mbits, not xid */
-#define OBD_CONNECT2_REP_MBITS       0x100000ULL /* match reply mbits not xid*/
-#define OBD_CONNECT2_MODE_CONVERT    0x200000ULL /* LDLM mode convert */
-#define OBD_CONNECT2_BATCH_RPC	     0x400000ULL /* Multi-RPC batch request */
-#define OBD_CONNECT2_PCCRO	     0x800000ULL /* Read-only PCC */
-#define OBD_CONNECT2_ATOMIC_OPEN_LOCK 0x4000000ULL/* request lock on 1st open */
-#define OBD_CONNECT2_ENCRYPT_NAME     0x8000000ULL /* name encrypt */
-/* XXX README XXX:
- * Please DO NOT add flag values here before first ensuring that this same
- * flag value is not in use on some other branch.  Please clear any such
- * changes with senior engineers before starting to use a new flag.  Then,
- * submit a small patch against EVERY branch that ONLY adds the new flag,
+#define OBD_CONNECT2_FILE_SECCTX		0x1ULL /* security context */
+#define OBD_CONNECT2_LOCKAHEAD			0x2ULL /* ladvise lockahead */
+#define OBD_CONNECT2_DIR_MIGRATE		0x4ULL /* migrate striped dir */
+#define OBD_CONNECT2_SUM_STATFS			0x8ULL /* MDT aggregate statfs*/
+#define OBD_CONNECT2_OVERSTRIPING	       0x10ULL /* OST overstriping */
+#define OBD_CONNECT2_FLR		       0x20ULL /* FLR mirror handling */
+#define OBD_CONNECT2_WBC_INTENTS	       0x40ULL /* MDS wb cache intent */
+#define OBD_CONNECT2_LOCK_CONVERT	       0x80ULL /* IBITS lock convert */
+#define OBD_CONNECT2_ARCHIVE_ID_ARRAY	      0x100ULL /* HSM archive_id array*/
+#define OBD_CONNECT2_INC_XID		      0x200ULL /* Increasing xid */
+#define OBD_CONNECT2_SELINUX_POLICY	      0x400ULL /* cli SELinux policy */
+#define OBD_CONNECT2_LSOM		      0x800ULL /* Lazy Size on MDT */
+#define OBD_CONNECT2_PCC		     0x1000ULL /* Persist Client Cache*/
+#define OBD_CONNECT2_CRUSH		     0x2000ULL /* CRUSH dir hash */
+#define OBD_CONNECT2_ASYNC_DISCARD	     0x4000ULL /* async DoM discard */
+#define OBD_CONNECT2_ENCRYPT		    0x8000ULL /* client disk encrypt */
+#define OBD_CONNECT2_FIDMAP		    0x10000ULL /* MDT migrate FID map */
+#define OBD_CONNECT2_GETATTR_PFID	    0x20000ULL /* parent FID getattr */
+#define OBD_CONNECT2_LSEEK		    0x40000ULL /* SEEK_HOLE/DATA RPC */
+#define OBD_CONNECT2_DOM_LVB		    0x80000ULL /* DoM glimpse in LVB */
+#define OBD_CONNECT2_REP_MBITS		   0x100000ULL /* reply mbits, not XID*/
+#define OBD_CONNECT2_MODE_CONVERT	   0x200000ULL /* LDLM mode convert */
+#define OBD_CONNECT2_BATCH_RPC		   0x400000ULL /* Multi-op batch RPCs */
+#define OBD_CONNECT2_PCCRO		   0x800000ULL /* PCC read-only */
+#define OBD_CONNECT2_MNE_TYPE		  0x1000000ULL /* mne_nid_type IPv6 */
+#define OBD_CONNECT2_LOCK_CONTENTION	  0x2000000ULL /* contention detect */
+#define OBD_CONNECT2_ATOMIC_OPEN_LOCK	  0x4000000ULL /* lock on first open */
+#define OBD_CONNECT2_ENCRYPT_NAME	  0x8000000ULL /* name encrypt */
+/* XXX README XXX README XXX README XXX README XXX README XXX README XXX
+ * Please DO NOT add OBD_CONNECT flags before first ensuring that this value
+ * is not in use by some other branch/patch.  Email adilger@whamcloud.com
+ * to reserve the new OBD_CONNECT value for use by your feature. Then, submit
+ * a small patch against master and LTS branches that ONLY adds the new flag,
  * updates obd_connect_names[], adds the flag to check_obd_connect_data(),
  * and updates wiretests accordingly, so it can be approved and landed easily
- * to reserve the flag for future use.
+ * to reserve the flag for future use by your feature (submitted separately).
  */
 
-#define OCD_HAS_FLAG(ocd, flg)  \
-	(!!((ocd)->ocd_connect_flags & OBD_CONNECT_##flg))
+#define OCD_HAS_FLAG(ocd, flag)	\
+	(!!((ocd)->ocd_connect_flags & OBD_CONNECT_##flag))
+#define OCD_HAS_FLAG2(ocd, flag2) (OCD_HAS_FLAG(ocd, FLAGS2) && \
+	 !!((ocd)->ocd_connect_flags2 & OBD_CONNECT2_##flag2))
 
 /* Features required for this version of the client to work with server */
 #define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_FID |	\
@@ -855,32 +830,32 @@ struct obd_connect_data {
 	 * any field after ocd_maxbytes on the receiver without a valid flag
 	 * may result in out-of-bound memory access and kernel oops.
 	 */
-	__u16 ocd_maxmodrpcs;		/* Maximum modify RPCs in parallel */
-	__u16 padding0;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u32 padding1;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 ocd_connect_flags2;
-	__u64 padding3;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding4;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding5;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding6;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding7;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding8;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding9;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingA;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingB;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingC;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingD;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingE;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingF;		/* added 2.1.0. also fix lustre_swab_connect */
-};
-
-/* XXX README XXX:
- * Please DO NOT use any fields here before first ensuring that this same
- * field is not in use on some other branch.  Please clear any such changes
- * with senior engineers before starting to use a new field.  Then, submit
- * a small patch against EVERY branch that ONLY adds the new field along with
- * the matching OBD_CONNECT flag, so that can be approved and landed easily to
- * reserve the flag for future use.
+	__u16 ocd_maxmodrpcs;	/* Maximum modify RPCs in parallel */
+	__u16 padding0;		/* READ BELOW! also fix lustre_swab_connect */
+	__u32 padding1;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 ocd_connect_flags2;/* OBD_CONNECT2_* per above */
+	__u64 padding3;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 padding4;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 padding5;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 padding6;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 padding7;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 padding8;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 padding9;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 paddingA;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 paddingB;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 paddingC;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 paddingD;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 paddingE;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 paddingF;		/* READ BELOW! also fix lustre_swab_connect */
+};
+/* XXX README XXX README XXX README XXX README XXX README XXX README XXX
+ * Please DO NOT use any fields before first ensuring that this field is
+ * not in use by some other branch/patch.  Email adilger@whamcloud.com to
+ * reserve the new obd_connect_data field for use by your feature. Then, submit
+ * a small patch against master and LTS branch that ONLY adds the new field,
+ * updates lustre_swab_connect(), along with the matching OBD_CONNECT flag,
+ * and updates wiretests accordingly,so it can be approved and landed easily
+ * to reserve the field for future use by your feature (submitted separately).
  */
 
 /*
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
