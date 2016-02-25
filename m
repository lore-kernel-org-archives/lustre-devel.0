From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:24 -0500
Subject: [lustre-devel] [PATCH v2 41/84] staging/lustre: Reformat comments
	and structures in lustre_idl.h
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-42-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This file mostly contains various on the wire data and got
significantly mangled in transition.
This patch rectifies the situation somewhat. Also fixes the
comment style for block comments.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 286 ++++++++++++---------
 1 file changed, 165 insertions(+), 121 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index c272c18..e32163b 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -146,7 +146,9 @@
 #define SEQ_CONTROLLER_PORTAL	  32
 #define MGS_BULK_PORTAL		33
 
-/* Portal 63 is reserved for the Cray Inc DVS - nic at cray.com, roe at cray.com, n8851 at cray.com */
+/* Portal 63 is reserved for the Cray Inc DVS - nic at cray.com, roe at cray.com,
+ *						n8851 at cray.com
+ */
 
 /* packet types */
 #define PTL_RPC_MSG_REQUEST 4711
@@ -295,7 +297,8 @@ static inline int range_compare_loc(const struct lu_seq_range *r1,
 	fld_range_is_mdt(range) ? "mdt" : "ost"
 
 /** \defgroup lu_fid lu_fid
- * @{ */
+ * @{
+ */
 
 /**
  * Flags for lustre_mdt_attrs::lma_compat and lustre_mdt_attrs::lma_incompat.
@@ -307,7 +310,8 @@ enum lma_compat {
 	LMAC_SOM	= 0x00000002,
 	LMAC_NOT_IN_OI	= 0x00000004, /* the object does NOT need OI mapping */
 	LMAC_FID_ON_OST = 0x00000008, /* For OST-object, its OI mapping is
-				       * under /O/<seq>/d<x>. */
+				       * under /O/<seq>/d<x>.
+				       */
 };
 
 /**
@@ -319,7 +323,8 @@ enum lma_incompat {
 	LMAI_RELEASED		= 0x00000001, /* file is released */
 	LMAI_AGENT		= 0x00000002, /* agent inode */
 	LMAI_REMOTE_PARENT	= 0x00000004, /* the parent of the object
-						 is on the remote MDT */
+					       * is on the remote MDT
+					       */
 };
 
 #define LMA_INCOMPAT_SUPP	(LMAI_AGENT | LMAI_REMOTE_PARENT)
@@ -395,12 +400,14 @@ enum fid_seq {
 	FID_SEQ_LOCAL_FILE	= 0x200000001ULL,
 	FID_SEQ_DOT_LUSTRE	= 0x200000002ULL,
 	/* sequence is used for local named objects FIDs generated
-	 * by local_object_storage library */
+	 * by local_object_storage library
+	 */
 	FID_SEQ_LOCAL_NAME	= 0x200000003ULL,
 	/* Because current FLD will only cache the fid sequence, instead
 	 * of oid on the client side, if the FID needs to be exposed to
 	 * clients sides, it needs to make sure all of fids under one
-	 * sequence will be located in one MDT. */
+	 * sequence will be located in one MDT.
+	 */
 	FID_SEQ_SPECIAL		= 0x200000004ULL,
 	FID_SEQ_QUOTA		= 0x200000005ULL,
 	FID_SEQ_QUOTA_GLB	= 0x200000006ULL,
@@ -601,7 +608,8 @@ static inline void ostid_set_seq(struct ost_id *oi, __u64 seq)
 		oi->oi_fid.f_seq = seq;
 		/* Note: if f_oid + f_ver is zero, we need init it
 		 * to be 1, otherwise, ostid_seq will treat this
-		 * as old ostid (oi_seq == 0) */
+		 * as old ostid (oi_seq == 0)
+		 */
 		if (oi->oi_fid.f_oid == 0 && oi->oi_fid.f_ver == 0)
 			oi->oi_fid.f_oid = LUSTRE_FID_INIT_OID;
 	}
@@ -689,7 +697,8 @@ static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 		 * that we map into the IDIF namespace.  It allows up to 2^48
 		 * objects per OST, as this is the object namespace that has
 		 * been in production for years.  This can handle create rates
-		 * of 1M objects/s/OST for 9 years, or combinations thereof. */
+		 * of 1M objects/s/OST for 9 years, or combinations thereof.
+		 */
 		if (ostid_id(ostid) >= IDIF_MAX_OID) {
 			 CERROR("bad MDT0 id, "DOSTID" ost_idx:%u\n",
 				POSTID(ostid), ost_idx);
@@ -704,7 +713,8 @@ static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 	       /* This is either an IDIF object, which identifies objects across
 		* all OSTs, or a regular FID.  The IDIF namespace maps legacy
 		* OST objects into the FID namespace.  In both cases, we just
-		* pass the FID through, no conversion needed. */
+		* pass the FID through, no conversion needed.
+		*/
 		if (ostid->oi_fid.f_ver != 0) {
 			CERROR("bad MDT0 id, "DOSTID" ost_idx:%u\n",
 				POSTID(ostid), ost_idx);
@@ -868,7 +878,8 @@ static inline void ostid_le_to_cpu(const struct ost_id *src_oi,
 /** @} lu_fid */
 
 /** \defgroup lu_dir lu_dir
- * @{ */
+ * @{
+ */
 
 /**
  * Enumeration of possible directory entry attributes.
@@ -1112,7 +1123,8 @@ struct ptlrpc_body_v2 {
 	__u32 pb_conn_cnt;
 	__u32 pb_timeout;  /* for req, the deadline, for rep, the service est */
 	__u32 pb_service_time; /* for rep, actual service time, also used for
-				  net_latency of req */
+				* net_latency of req
+				*/
 	__u32 pb_limit;
 	__u64 pb_slv;
 	/* VBR: pre-versions */
@@ -1158,7 +1170,8 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 /* #define MSG_AT_SUPPORT	 0x0008
  * This was used in early prototypes of adaptive timeouts, and while there
  * shouldn't be any users of that code there also isn't a need for using this
- * bits. Defer usage until at least 1.10 to avoid potential conflict. */
+ * bits. Defer usage until at least 1.10 to avoid potential conflict.
+ */
 #define MSG_DELAY_REPLAY	  0x0010
 #define MSG_VERSION_REPLAY	0x0020
 #define MSG_REQ_REPLAY_DONE       0x0040
@@ -1179,60 +1192,65 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 #define MSG_CONNECT_TRANSNO     0x00000100 /* report transno */
 
 /* Connect flags */
-#define OBD_CONNECT_RDONLY		0x1ULL /*client has read-only access*/
-#define OBD_CONNECT_INDEX		 0x2ULL /*connect specific LOV idx */
-#define OBD_CONNECT_MDS		   0x4ULL /*connect from MDT to OST */
-#define OBD_CONNECT_GRANT		 0x8ULL /*OSC gets grant at connect */
-#define OBD_CONNECT_SRVLOCK	      0x10ULL /*server takes locks for cli */
-#define OBD_CONNECT_VERSION	      0x20ULL /*Lustre versions in ocd */
-#define OBD_CONNECT_REQPORTAL	    0x40ULL /*Separate non-IO req portal */
-#define OBD_CONNECT_ACL		  0x80ULL /*access control lists */
-#define OBD_CONNECT_XATTR	       0x100ULL /*client use extended attr */
+#define OBD_CONNECT_RDONLY		  0x1ULL /*client has read-only access*/
+#define OBD_CONNECT_INDEX		  0x2ULL /*connect specific LOV idx */
+#define OBD_CONNECT_MDS			  0x4ULL /*connect from MDT to OST */
+#define OBD_CONNECT_GRANT		  0x8ULL /*OSC gets grant at connect */
+#define OBD_CONNECT_SRVLOCK		 0x10ULL /*server takes locks for cli */
+#define OBD_CONNECT_VERSION		 0x20ULL /*Lustre versions in ocd */
+#define OBD_CONNECT_REQPORTAL		 0x40ULL /*Separate non-IO req portal */
+#define OBD_CONNECT_ACL			 0x80ULL /*access control lists */
+#define OBD_CONNECT_XATTR		0x100ULL /*client use extended attr */
 #define OBD_CONNECT_CROW		0x200ULL /*MDS+OST create obj on write*/
-#define OBD_CONNECT_TRUNCLOCK	   0x400ULL /*locks on server for punch */
-#define OBD_CONNECT_TRANSNO	     0x800ULL /*replay sends init transno */
-#define OBD_CONNECT_IBITS	      0x1000ULL /*support for inodebits locks*/
+#define OBD_CONNECT_TRUNCLOCK		0x400ULL /*locks on server for punch */
+#define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
+#define OBD_CONNECT_IBITS	       0x1000ULL /*support for inodebits locks*/
 #define OBD_CONNECT_JOIN	       0x2000ULL /*files can be concatenated.
 						  *We do not support JOIN FILE
 						  *anymore, reserve this flags
 						  *just for preventing such bit
-						  *to be reused.*/
-#define OBD_CONNECT_ATTRFID	    0x4000ULL /*Server can GetAttr By Fid*/
-#define OBD_CONNECT_NODEVOH	    0x8000ULL /*No open hndl on specl nodes*/
-#define OBD_CONNECT_RMT_CLIENT	0x10000ULL /*Remote client */
+						  *to be reused.
+						  */
+#define OBD_CONNECT_ATTRFID	       0x4000ULL /*Server can GetAttr By Fid*/
+#define OBD_CONNECT_NODEVOH	       0x8000ULL /*No open hndl on specl nodes*/
+#define OBD_CONNECT_RMT_CLIENT	      0x10000ULL /*Remote client */
 #define OBD_CONNECT_RMT_CLIENT_FORCE  0x20000ULL /*Remote client by force */
-#define OBD_CONNECT_BRW_SIZE	  0x40000ULL /*Max bytes per rpc */
-#define OBD_CONNECT_QUOTA64	   0x80000ULL /*Not used since 2.4 */
-#define OBD_CONNECT_MDS_CAPA	 0x100000ULL /*MDS capability */
-#define OBD_CONNECT_OSS_CAPA	 0x200000ULL /*OSS capability */
-#define OBD_CONNECT_CANCELSET	0x400000ULL /*Early batched cancels. */
-#define OBD_CONNECT_SOM	      0x800000ULL /*Size on MDS */
-#define OBD_CONNECT_AT	      0x1000000ULL /*client uses AT */
+#define OBD_CONNECT_BRW_SIZE	      0x40000ULL /*Max bytes per rpc */
+#define OBD_CONNECT_QUOTA64	      0x80000ULL /*Not used since 2.4 */
+#define OBD_CONNECT_MDS_CAPA	     0x100000ULL /*MDS capability */
+#define OBD_CONNECT_OSS_CAPA	     0x200000ULL /*OSS capability */
+#define OBD_CONNECT_CANCELSET	     0x400000ULL /*Early batched cancels. */
+#define OBD_CONNECT_SOM		     0x800000ULL /*Size on MDS */
+#define OBD_CONNECT_AT		    0x1000000ULL /*client uses AT */
 #define OBD_CONNECT_LRU_RESIZE      0x2000000ULL /*LRU resize feature. */
-#define OBD_CONNECT_MDS_MDS	 0x4000000ULL /*MDS-MDS connection */
+#define OBD_CONNECT_MDS_MDS	    0x4000000ULL /*MDS-MDS connection */
 #define OBD_CONNECT_REAL	    0x8000000ULL /*real connection */
 #define OBD_CONNECT_CHANGE_QS      0x10000000ULL /*Not used since 2.4 */
-#define OBD_CONNECT_CKSUM	  0x20000000ULL /*support several cksum algos*/
-#define OBD_CONNECT_FID	    0x40000000ULL /*FID is supported by server */
-#define OBD_CONNECT_VBR	    0x80000000ULL /*version based recovery */
-#define OBD_CONNECT_LOV_V3	0x100000000ULL /*client supports LOV v3 EA */
+#define OBD_CONNECT_CKSUM	   0x20000000ULL /*support several cksum algos*/
+#define OBD_CONNECT_FID		   0x40000000ULL /*FID is supported by server */
+#define OBD_CONNECT_VBR		   0x80000000ULL /*version based recovery */
+#define OBD_CONNECT_LOV_V3	  0x100000000ULL /*client supports LOV v3 EA */
 #define OBD_CONNECT_GRANT_SHRINK  0x200000000ULL /* support grant shrink */
 #define OBD_CONNECT_SKIP_ORPHAN   0x400000000ULL /* don't reuse orphan objids */
 #define OBD_CONNECT_MAX_EASIZE    0x800000000ULL /* preserved for large EA */
 #define OBD_CONNECT_FULL20       0x1000000000ULL /* it is 2.0 client */
 #define OBD_CONNECT_LAYOUTLOCK   0x2000000000ULL /* client uses layout lock */
 #define OBD_CONNECT_64BITHASH    0x4000000000ULL /* client supports 64-bits
-						  * directory hash */
+						  * directory hash
+						  */
 #define OBD_CONNECT_MAXBYTES     0x8000000000ULL /* max stripe size */
 #define OBD_CONNECT_IMP_RECOV   0x10000000000ULL /* imp recovery support */
 #define OBD_CONNECT_JOBSTATS    0x20000000000ULL /* jobid in ptlrpc_body */
 #define OBD_CONNECT_UMASK       0x40000000000ULL /* create uses client umask */
 #define OBD_CONNECT_EINPROGRESS 0x80000000000ULL /* client handles -EINPROGRESS
-						  * RPC error properly */
+						  * RPC error properly
+						  */
 #define OBD_CONNECT_GRANT_PARAM 0x100000000000ULL/* extra grant params used for
-						  * finer space reservation */
+						  * finer space reservation
+						  */
 #define OBD_CONNECT_FLOCK_OWNER 0x200000000000ULL /* for the fixed 1.8
-						   * policy and 2.x server */
+						   * policy and 2.x server
+						   */
 #define OBD_CONNECT_LVB_TYPE	0x400000000000ULL /* variable type of LVB */
 #define OBD_CONNECT_NANOSEC_TIME 0x800000000000ULL /* nanosecond timestamps */
 #define OBD_CONNECT_LIGHTWEIGHT 0x1000000000000ULL/* lightweight connection */
@@ -1276,7 +1294,8 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 /* This structure is used for both request and reply.
  *
  * If we eventually have separate connect data for different types, which we
- * almost certainly will, then perhaps we stick a union in here. */
+ * almost certainly will, then perhaps we stick a union in here.
+ */
 struct obd_connect_data_v1 {
 	__u64 ocd_connect_flags; /* OBD_CONNECT_* per above */
 	__u32 ocd_version;	 /* lustre release version number */
@@ -1306,7 +1325,7 @@ struct obd_connect_data {
 	__u8  ocd_blocksize;     /* log2 of the backend filesystem blocksize */
 	__u8  ocd_inodespace;    /* log2 of the per-inode space consumption */
 	__u16 ocd_grant_extent;  /* per-extent grant overhead, in 1K blocks */
-	__u32 ocd_unused;	/* also fix lustre_swab_connect */
+	__u32 ocd_unused;	 /* also fix lustre_swab_connect */
 	__u64 ocd_transno;       /* first transno from client to be replayed */
 	__u32 ocd_group;	 /* MDS group on OST */
 	__u32 ocd_cksum_types;   /* supported checksum algorithms */
@@ -1316,7 +1335,8 @@ struct obd_connect_data {
 	/* Fields after ocd_maxbytes are only accessible by the receiver
 	 * if the corresponding flag in ocd_connect_flags is set. Accessing
 	 * any field after ocd_maxbytes on the receiver without a valid flag
-	 * may result in out-of-bound memory access and kernel oops. */
+	 * may result in out-of-bound memory access and kernel oops.
+	 */
 	__u64 padding1;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding2;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding3;	  /* added 2.1.0. also fix lustre_swab_connect */
@@ -1340,7 +1360,8 @@ struct obd_connect_data {
  * with senior engineers before starting to use a new field.  Then, submit
  * a small patch against EVERY branch that ONLY adds the new field along with
  * the matching OBD_CONNECT flag, so that can be approved and landed easily to
- * reserve the flag for future use. */
+ * reserve the flag for future use.
+ */
 
 void lustre_swab_connect(struct obd_connect_data *ocd);
 
@@ -1389,7 +1410,7 @@ enum obdo_flags {
 	OBD_FL_INLINEDATA   = 0x00000001,
 	OBD_FL_OBDMDEXISTS  = 0x00000002,
 	OBD_FL_DELORPHAN    = 0x00000004, /* if set in o_flags delete orphans */
-	OBD_FL_NORPC	= 0x00000008, /* set in o_flags do in OSC not OST */
+	OBD_FL_NORPC	    = 0x00000008, /* set in o_flags do in OSC not OST */
 	OBD_FL_IDONLY       = 0x00000010, /* set in o_flags only adjust obj id*/
 	OBD_FL_RECREATE_OBJS = 0x00000020, /* recreate missing obj */
 	OBD_FL_DEBUG_CHECK  = 0x00000040, /* echo client/server debug check */
@@ -1403,14 +1424,16 @@ enum obdo_flags {
 	OBD_FL_CKSUM_RSVD2  = 0x00008000, /* for future cksum types */
 	OBD_FL_CKSUM_RSVD3  = 0x00010000, /* for future cksum types */
 	OBD_FL_SHRINK_GRANT = 0x00020000, /* object shrink the grant */
-	OBD_FL_MMAP	 = 0x00040000, /* object is mmapped on the client.
+	OBD_FL_MMAP	    = 0x00040000, /* object is mmapped on the client.
 					   * XXX: obsoleted - reserved for old
-					   * clients prior than 2.2 */
+					   * clients prior than 2.2
+					   */
 	OBD_FL_RECOV_RESEND = 0x00080000, /* recoverable resent */
 	OBD_FL_NOSPC_BLK    = 0x00100000, /* no more block space on OST */
 
 	/* Note that while these checksum values are currently separate bits,
-	 * in 2.x we can actually allow all values from 1-31 if we wanted. */
+	 * in 2.x we can actually allow all values from 1-31 if we wanted.
+	 */
 	OBD_FL_CKSUM_ALL    = OBD_FL_CKSUM_CRC32 | OBD_FL_CKSUM_ADLER |
 			      OBD_FL_CKSUM_CRC32C,
 
@@ -1599,7 +1622,7 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 	}
 }
 
-#define OBD_MD_FLID	(0x00000001ULL) /* object ID */
+#define OBD_MD_FLID	   (0x00000001ULL) /* object ID */
 #define OBD_MD_FLATIME     (0x00000002ULL) /* access time */
 #define OBD_MD_FLMTIME     (0x00000004ULL) /* data modification time */
 #define OBD_MD_FLCTIME     (0x00000008ULL) /* change time */
@@ -1625,22 +1648,23 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 #define OBD_MD_FLGROUP     (0x01000000ULL) /* group */
 #define OBD_MD_FLFID       (0x02000000ULL) /* ->ost write inline fid */
 #define OBD_MD_FLEPOCH     (0x04000000ULL) /* ->ost write with ioepoch */
-					   /* ->mds if epoch opens or closes */
+					   /* ->mds if epoch opens or closes
+					    */
 #define OBD_MD_FLGRANT     (0x08000000ULL) /* ost preallocation space grant */
 #define OBD_MD_FLDIREA     (0x10000000ULL) /* dir's extended attribute data */
 #define OBD_MD_FLUSRQUOTA  (0x20000000ULL) /* over quota flags sent from ost */
 #define OBD_MD_FLGRPQUOTA  (0x40000000ULL) /* over quota flags sent from ost */
 #define OBD_MD_FLMODEASIZE (0x80000000ULL) /* EA size will be changed */
 
-#define OBD_MD_MDS	 (0x0000000100000000ULL) /* where an inode lives on */
+#define OBD_MD_MDS	   (0x0000000100000000ULL) /* where an inode lives on */
 #define OBD_MD_REINT       (0x0000000200000000ULL) /* reintegrate oa */
-#define OBD_MD_MEA	 (0x0000000400000000ULL) /* CMD split EA  */
+#define OBD_MD_MEA	   (0x0000000400000000ULL) /* CMD split EA  */
 #define OBD_MD_TSTATE      (0x0000000800000000ULL) /* transient state field */
 
 #define OBD_MD_FLXATTR       (0x0000001000000000ULL) /* xattr */
 #define OBD_MD_FLXATTRLS     (0x0000002000000000ULL) /* xattr list */
 #define OBD_MD_FLXATTRRM     (0x0000004000000000ULL) /* xattr remove */
-#define OBD_MD_FLACL	 (0x0000008000000000ULL) /* ACL */
+#define OBD_MD_FLACL	     (0x0000008000000000ULL) /* ACL */
 #define OBD_MD_FLRMTPERM     (0x0000010000000000ULL) /* remote permission */
 #define OBD_MD_FLMDSCAPA     (0x0000020000000000ULL) /* MDS capability */
 #define OBD_MD_FLOSSCAPA     (0x0000040000000000ULL) /* OSS capability */
@@ -1649,7 +1673,8 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 #define OBD_MD_FLGETATTRLOCK (0x0000200000000000ULL) /* Get IOEpoch attributes
 						      * under lock; for xattr
 						      * requests means the
-						      * client holds the lock */
+						      * client holds the lock
+						      */
 #define OBD_MD_FLOBJCOUNT    (0x0000400000000000ULL) /* for multiple destroy */
 
 #define OBD_MD_FLRMTLSETFACL (0x0001000000000000ULL) /* lfs lsetfacl case */
@@ -1669,7 +1694,8 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 #define OBD_MD_FLXATTRALL (OBD_MD_FLXATTR | OBD_MD_FLXATTRLS)
 
 /* don't forget obdo_fid which is way down at the bottom so it can
- * come after the definition of llog_cookie */
+ * come after the definition of llog_cookie
+ */
 
 enum hss_valid {
 	HSS_SETMASK	= 0x01,
@@ -1691,19 +1717,20 @@ void lustre_swab_obd_statfs(struct obd_statfs *os);
 
 /* ost_body.data values for OST_BRW */
 
-#define OBD_BRW_READ	    0x01
-#define OBD_BRW_WRITE	   0x02
-#define OBD_BRW_RWMASK	  (OBD_BRW_READ | OBD_BRW_WRITE)
-#define OBD_BRW_SYNC	    0x08 /* this page is a part of synchronous
+#define OBD_BRW_READ		0x01
+#define OBD_BRW_WRITE		0x02
+#define OBD_BRW_RWMASK		(OBD_BRW_READ | OBD_BRW_WRITE)
+#define OBD_BRW_SYNC		0x08 /* this page is a part of synchronous
 				      * transfer and is not accounted in
-				      * the grant. */
-#define OBD_BRW_CHECK	   0x10
+				      * the grant.
+				      */
+#define OBD_BRW_CHECK		0x10
 #define OBD_BRW_FROM_GRANT      0x20 /* the osc manages this under llite */
-#define OBD_BRW_GRANTED	 0x40 /* the ost manages this */
-#define OBD_BRW_NOCACHE	 0x80 /* this page is a part of non-cached IO */
-#define OBD_BRW_NOQUOTA	0x100
-#define OBD_BRW_SRVLOCK	0x200 /* Client holds no lock over this page */
-#define OBD_BRW_ASYNC	  0x400 /* Server may delay commit to disk */
+#define OBD_BRW_GRANTED		0x40 /* the ost manages this */
+#define OBD_BRW_NOCACHE		0x80 /* this page is a part of non-cached IO */
+#define OBD_BRW_NOQUOTA	       0x100
+#define OBD_BRW_SRVLOCK	       0x200 /* Client holds no lock over this page */
+#define OBD_BRW_ASYNC	       0x400 /* Server may delay commit to disk */
 #define OBD_BRW_MEMALLOC       0x800 /* Client runs in the "kswapd" context */
 #define OBD_BRW_OVER_USRQUOTA 0x1000 /* Running out of user quota */
 #define OBD_BRW_OVER_GRPQUOTA 0x2000 /* Running out of group quota */
@@ -1717,7 +1744,8 @@ struct obd_ioobj {
 	struct ost_id	ioo_oid;	/* object ID, if multi-obj BRW */
 	__u32		ioo_max_brw;	/* low 16 bits were o_mode before 2.4,
 					 * now (PTLRPC_BULK_OPS_COUNT - 1) in
-					 * high 16 bits in 2.4 and later */
+					 * high 16 bits in 2.4 and later
+					 */
 	__u32		ioo_bufcnt;	/* number of niobufs for this object */
 };
 
@@ -1741,7 +1769,8 @@ void lustre_swab_niobuf_remote(struct niobuf_remote *nbr);
 /* lock value block communicated between the filter and llite */
 
 /* OST_LVB_ERR_INIT is needed because the return code in rc is
- * negative, i.e. because ((MASK + rc) & MASK) != MASK. */
+ * negative, i.e. because ((MASK + rc) & MASK) != MASK.
+ */
 #define OST_LVB_ERR_INIT 0xffbadbad80000000ULL
 #define OST_LVB_ERR_MASK 0xffbadbad00000000ULL
 #define OST_LVB_IS_ERR(blocks)					  \
@@ -1782,7 +1811,8 @@ void lustre_swab_ost_lvb(struct ost_lvb *lvb);
  * can be used with quota, this includes:
  * - 64-bit user ID
  * - 64-bit group ID
- * - a FID which can be used for per-directory quota in the future */
+ * - a FID which can be used for per-directory quota in the future
+ */
 union lquota_id {
 	struct lu_fid	qid_fid; /* FID for per-directory quota */
 	__u64		qid_uid; /* user identifier */
@@ -1832,9 +1862,6 @@ struct ldlm_gl_lquota_desc {
 	__u64		gl_pad2;
 };
 
-#define gl_qunit	gl_hardlimit /* current qunit value used when
-				      * glimpsing per-ID quota locks */
-
 /* quota glimpse flags */
 #define LQUOTA_FL_EDQUOT 0x1 /* user/group out of quota space on QMT */
 
@@ -1849,9 +1876,6 @@ struct lquota_lvb {
 
 void lustre_swab_lquota_lvb(struct lquota_lvb *lvb);
 
-/* LVB used with global quota lock */
-#define lvb_glb_ver  lvb_id_may_rel /* current version of the global index */
-
 /* op codes */
 enum quota_cmd {
 	QUOTA_DQACQ	= 601,
@@ -1936,7 +1960,8 @@ void lustre_swab_generic_32s(__u32 *val);
 /* INODE LOCK PARTS */
 #define MDS_INODELOCK_LOOKUP 0x000001	/* For namespace, dentry etc, and also
 					 * was used to protect permission (mode,
-					 * owner, group etc) before 2.4. */
+					 * owner, group etc) before 2.4.
+					 */
 #define MDS_INODELOCK_UPDATE 0x000002	/* size, links, timestamps */
 #define MDS_INODELOCK_OPEN   0x000004	/* For opened files */
 #define MDS_INODELOCK_LAYOUT 0x000008	/* for layout */
@@ -1949,7 +1974,8 @@ void lustre_swab_generic_32s(__u32 *val);
  * For local directory, MDT will always grant UPDATE_LOCK|PERM_LOCK together.
  * For Remote directory, the master MDT, where the remote directory is, will
  * grant UPDATE_LOCK|PERM_LOCK, and the remote MDT, where the name entry is,
- * will grant LOOKUP_LOCK. */
+ * will grant LOOKUP_LOCK.
+ */
 #define MDS_INODELOCK_PERM   0x000010
 #define MDS_INODELOCK_XATTR  0x000020	/* extended attributes */
 
@@ -1959,7 +1985,8 @@ void lustre_swab_generic_32s(__u32 *val);
 
 /* NOTE: until Lustre 1.8.7/2.1.1 the fid_ver() was packed into name[2],
  * but was moved into name[1] along with the OID to avoid consuming the
- * name[2,3] fields that need to be used for the quota id (also a FID). */
+ * name[2,3] fields that need to be used for the quota id (also a FID).
+ */
 enum {
 	LUSTRE_RES_ID_SEQ_OFF = 0,
 	LUSTRE_RES_ID_VER_OID_OFF = 1,
@@ -1995,7 +2022,8 @@ enum md_op_flags {
 #define LUSTRE_BFLAG_UNCOMMITTED_WRITES   0x1
 
 /* these should be identical to their EXT4_*_FL counterparts, they are
- * redefined here only to avoid dragging in fs/ext4/ext4.h */
+ * redefined here only to avoid dragging in fs/ext4/ext4.h
+ */
 #define LUSTRE_SYNC_FL	 0x00000008 /* Synchronous updates */
 #define LUSTRE_IMMUTABLE_FL    0x00000010 /* Immutable file */
 #define LUSTRE_APPEND_FL       0x00000020 /* writes to file may only append */
@@ -2007,7 +2035,8 @@ enum md_op_flags {
  * protocol equivalents of LDISKFS_*_FL values stored on disk, while
  * the S_* flags are kernel-internal values that change between kernel
  * versions.  These flags are set/cleared via FSFILT_IOC_{GET,SET}_FLAGS.
- * See b=16526 for a full history. */
+ * See b=16526 for a full history.
+ */
 static inline int ll_ext_to_inode_flags(int flags)
 {
 	return (((flags & LUSTRE_SYNC_FL)      ? S_SYNC      : 0) |
@@ -2042,9 +2071,10 @@ struct mdt_body {
 	__s64	  ctime;
 	__u64	  blocks; /* XID, in the case of MDS_READPAGE */
 	__u64	  ioepoch;
-	__u64	       t_state; /* transient file state defined in
-				 * enum md_transient_state
-				 * was "ino" until 2.4.0 */
+	__u64	  t_state; /* transient file state defined in
+			    * enum md_transient_state
+			    * was "ino" until 2.4.0
+			    */
 	__u32	  fsuid;
 	__u32	  fsgid;
 	__u32	  capability;
@@ -2054,7 +2084,7 @@ struct mdt_body {
 	__u32	  flags; /* from vfs for pin/unpin, LUSTRE_BFLAG close */
 	__u32	  rdev;
 	__u32	  nlink; /* #bytes to read in the case of MDS_READPAGE */
-	__u32	       unused2; /* was "generation" until 2.4.0 */
+	__u32	  unused2; /* was "generation" until 2.4.0 */
 	__u32	  suppgid;
 	__u32	  eadatasize;
 	__u32	  aclsize;
@@ -2091,7 +2121,8 @@ enum {
 };
 
 /* inode access permission for remote user, the inode info are omitted,
- * for client knows them. */
+ * for client knows them.
+ */
 struct mdt_remote_perm {
 	__u32	   rp_uid;
 	__u32	   rp_gid;
@@ -2141,13 +2172,13 @@ void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
  * since the client and MDS may run different kernels (see bug 13828)
  * Therefore, we should only use MDS_ATTR_* attributes for sa_valid.
  */
-#define MDS_ATTR_MODE	  0x1ULL /* = 1 */
-#define MDS_ATTR_UID	   0x2ULL /* = 2 */
-#define MDS_ATTR_GID	   0x4ULL /* = 4 */
-#define MDS_ATTR_SIZE	  0x8ULL /* = 8 */
-#define MDS_ATTR_ATIME	0x10ULL /* = 16 */
-#define MDS_ATTR_MTIME	0x20ULL /* = 32 */
-#define MDS_ATTR_CTIME	0x40ULL /* = 64 */
+#define MDS_ATTR_MODE	       0x1ULL /* = 1 */
+#define MDS_ATTR_UID	       0x2ULL /* = 2 */
+#define MDS_ATTR_GID	       0x4ULL /* = 4 */
+#define MDS_ATTR_SIZE	       0x8ULL /* = 8 */
+#define MDS_ATTR_ATIME	      0x10ULL /* = 16 */
+#define MDS_ATTR_MTIME	      0x20ULL /* = 32 */
+#define MDS_ATTR_CTIME	      0x40ULL /* = 64 */
 #define MDS_ATTR_ATIME_SET    0x80ULL /* = 128 */
 #define MDS_ATTR_MTIME_SET   0x100ULL /* = 256 */
 #define MDS_ATTR_FORCE       0x200ULL /* = 512, Not a change, but a change it */
@@ -2155,7 +2186,9 @@ void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
 #define MDS_ATTR_KILL_SUID   0x800ULL /* = 2048 */
 #define MDS_ATTR_KILL_SGID  0x1000ULL /* = 4096 */
 #define MDS_ATTR_CTIME_SET  0x2000ULL /* = 8192 */
-#define MDS_ATTR_FROM_OPEN  0x4000ULL /* = 16384, called from open path, ie O_TRUNC */
+#define MDS_ATTR_FROM_OPEN  0x4000ULL /* = 16384, called from open path,
+				       * ie O_TRUNC
+				       */
 #define MDS_ATTR_BLOCKS     0x8000ULL /* = 32768 */
 
 #define MDS_FMODE_CLOSED	 00000000
@@ -2184,9 +2217,10 @@ void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
 					   * We do not support JOIN FILE
 					   * anymore, reserve this flags
 					   * just for preventing such bit
-					   * to be reused. */
+					   * to be reused.
+					   */
 
-#define MDS_OPEN_LOCK	 04000000000 /* This open requires open lock */
+#define MDS_OPEN_LOCK	      04000000000 /* This open requires open lock */
 #define MDS_OPEN_HAS_EA      010000000000 /* specify object create pattern */
 #define MDS_OPEN_HAS_OBJS    020000000000 /* Just set the EA the obj exist */
 #define MDS_OPEN_NORESTORE  0100000000000ULL /* Do not restore file at open */
@@ -2239,7 +2273,8 @@ struct mdt_rec_create {
 	__u32	   cr_bias;
 	/* use of helpers set/get_mrc_cr_flags() is needed to access
 	 * 64 bits cr_flags [cr_flags_l, cr_flags_h], this is done to
-	 * extend cr_flags size without breaking 1.8 compat */
+	 * extend cr_flags size without breaking 1.8 compat
+	 */
 	__u32	   cr_flags_l;     /* for use with open, low  32 bits  */
 	__u32	   cr_flags_h;     /* for use with open, high 32 bits */
 	__u32	   cr_umask;       /* umask for create */
@@ -2460,7 +2495,8 @@ enum seq_op {
 #define LOV_MAX_UUID_BUFFER_SIZE  8192
 /* The size of the buffer the lov/mdc reserves for the
  * array of UUIDs returned by the MDS.  With the current
- * protocol, this will limit the max number of OSTs per LOV */
+ * protocol, this will limit the max number of OSTs per LOV
+ */
 
 #define LOV_DESC_MAGIC 0xB0CCDE5C
 #define LOV_DESC_QOS_MAXAGE_DEFAULT 5  /* Seconds */
@@ -2469,13 +2505,13 @@ enum seq_op {
 /* LOV settings descriptor (should only contain static info) */
 struct lov_desc {
 	__u32 ld_tgt_count;		/* how many OBD's */
-	__u32 ld_active_tgt_count;	 /* how many active */
-	__u32 ld_default_stripe_count;     /* how many objects are used */
-	__u32 ld_pattern;		  /* default PATTERN_RAID0 */
-	__u64 ld_default_stripe_size;      /* in bytes */
-	__u64 ld_default_stripe_offset;    /* in bytes */
+	__u32 ld_active_tgt_count;	/* how many active */
+	__u32 ld_default_stripe_count;  /* how many objects are used */
+	__u32 ld_pattern;		/* default PATTERN_RAID0 */
+	__u64 ld_default_stripe_size;   /* in bytes */
+	__u64 ld_default_stripe_offset; /* in bytes */
 	__u32 ld_padding_0;		/* unused */
-	__u32 ld_qos_maxage;	       /* in second */
+	__u32 ld_qos_maxage;		/* in second */
 	__u32 ld_padding_1;		/* also fix lustre_swab_lov_desc */
 	__u32 ld_padding_2;		/* also fix lustre_swab_lov_desc */
 	struct obd_uuid ld_uuid;
@@ -2577,7 +2613,8 @@ struct ldlm_flock_wire {
  * the first fields of the ldlm_flock structure because there is only
  * one ldlm_swab routine to process the ldlm_policy_data_t union. if
  * this ever changes we will need to swab the union differently based
- * on the resource type. */
+ * on the resource type.
+ */
 
 typedef union {
 	struct ldlm_extent l_extent;
@@ -2623,7 +2660,8 @@ struct ldlm_request {
 void lustre_swab_ldlm_request(struct ldlm_request *rq);
 
 /* If LDLM_ENQUEUE, 1 slot is already occupied, 1 is available.
- * Otherwise, 2 are available. */
+ * Otherwise, 2 are available.
+ */
 #define ldlm_request_bufsize(count, type)				\
 ({								      \
 	int _avail = LDLM_LOCKREQ_HANDLES;			      \
@@ -2942,14 +2980,15 @@ struct llog_agent_req_rec {
 	struct llog_rec_hdr	arr_hdr;	/**< record header */
 	__u32			arr_status;	/**< status of the request */
 						/* must match enum
-						 * agent_req_status */
+						 * agent_req_status
+						 */
 	__u32			arr_archive_id;	/**< backend archive number */
 	__u64			arr_flags;	/**< req flags */
-	__u64			arr_compound_id;	/**< compound cookie */
+	__u64			arr_compound_id;/**< compound cookie */
 	__u64			arr_req_create;	/**< req. creation time */
 	__u64			arr_req_change;	/**< req. status change time */
 	struct hsm_action_item	arr_hai;	/**< req. to the agent */
-	struct llog_rec_tail	arr_tail; /**< record tail for_sizezof_only */
+	struct llog_rec_tail	arr_tail;   /**< record tail for_sizezof_only */
 } __packed;
 
 /* Old llog gen for compatibility */
@@ -3000,7 +3039,9 @@ struct llog_log_hdr {
 					llh->llh_bitmap_offset -	\
 					sizeof(llh->llh_tail)) * 8)
 
-/** log cookies are used to reference a specific log file and a record therein */
+/** log cookies are used to reference a specific log file and a record
+ * therein
+ */
 struct llog_cookie {
 	struct llog_logid       lgc_lgl;
 	__u32		   lgc_subsys;
@@ -3015,7 +3056,7 @@ enum llogd_rpc_ops {
 	LLOG_ORIGIN_HANDLE_READ_HEADER  = 503,
 	LLOG_ORIGIN_HANDLE_WRITE_REC    = 504,
 	LLOG_ORIGIN_HANDLE_CLOSE	= 505,
-	LLOG_ORIGIN_CONNECT	     = 506,
+	LLOG_ORIGIN_CONNECT		= 506,
 	LLOG_CATINFO			= 507,  /* deprecated */
 	LLOG_ORIGIN_HANDLE_PREV_BLOCK   = 508,
 	LLOG_ORIGIN_HANDLE_DESTROY      = 509,  /* for destroy llog object*/
@@ -3064,17 +3105,18 @@ struct obdo {
 	__u64		   o_ioepoch;      /* epoch in ost writes */
 	__u32		   o_stripe_idx;   /* holds stripe idx */
 	__u32		   o_parent_ver;
-	struct lustre_handle    o_handle;       /* brw: lock handle to prolong
-						 * locks */
-	struct llog_cookie      o_lcookie;      /* destroy: unlink cookie from
-						 * MDS */
+	struct lustre_handle    o_handle;  /* brw: lock handle to prolong locks
+					    */
+	struct llog_cookie      o_lcookie; /* destroy: unlink cookie from MDS
+					    */
 	__u32			o_uid_h;
 	__u32			o_gid_h;
 
 	__u64			o_data_version; /* getattr: sum of iversion for
 						 * each stripe.
 						 * brw: grant space consumed on
-						 * the client for the write */
+						 * the client for the write
+						 */
 	__u64			o_padding_4;
 	__u64			o_padding_5;
 	__u64			o_padding_6;
@@ -3098,7 +3140,8 @@ static inline void lustre_set_wire_obdo(struct obd_connect_data *ocd,
 	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
 	    fid_seq_is_echo(ostid_seq(&lobdo->o_oi))) {
 		/* Currently OBD_FL_OSTID will only be used when 2.4 echo
-		 * client communicate with pre-2.4 server */
+		 * client communicate with pre-2.4 server
+		 */
 		wobdo->o_oi.oi.oi_id = fid_oid(&lobdo->o_oi.oi_fid);
 		wobdo->o_oi.oi.oi_seq = fid_seq(&lobdo->o_oi.oi_fid);
 	}
@@ -3184,7 +3227,8 @@ enum sec_cmd {
 #define CAPA_HMAC_KEY_MAX_LEN   56
 
 /* NB take care when changing the sequence of elements this struct,
- * because the offset info is used in find_capa() */
+ * because the offset info is used in find_capa()
+ */
 struct lustre_capa {
 	struct lu_fid   lc_fid;	 /** fid */
 	__u64	   lc_opc;	 /** operations allowed */
-- 
2.1.0
