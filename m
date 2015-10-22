From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:47 -0400
Subject: [lustre-devel] [PATCH 09/11] staging: lustre: provide separate
	buffers for libcfs_*2str()
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Provide duplicates with separate buffers for libcfs_*2str() functions.

Replace libcfs_nid2str() with libcfs_nid2str_r() function in critical
places.

Provide buffer size for nf_addr2str functions.

Use __u32 as nf_type always

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6070
Reviewed-on: http://review.whamcloud.com/13185
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   31 ++++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |  138 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/router.c          |    2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |   11 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    9 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    7 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    8 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    5 +-
 9 files changed, 121 insertions(+), 96 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 4e7c9a5..46ad914 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -57,12 +57,29 @@ struct list_head;
 #define LNET_NIDSTR_COUNT  1024    /* # of nidstrings */
 #define LNET_NIDSTR_SIZE   32      /* size of each one (see below for usage) */
 
-int libcfs_isknown_lnd(int type);
-char *libcfs_lnd2modname(int type);
-char *libcfs_lnd2str(int type);
+/* support decl needed by both kernel and user space */
+char *libcfs_next_nidstring(void);
+int libcfs_isknown_lnd(__u32 lnd);
+char *libcfs_lnd2modname(__u32 lnd);
+char *libcfs_lnd2str_r(__u32 lnd, char *buf, size_t buf_size);
+static inline char *libcfs_lnd2str(__u32 lnd)
+{
+	return libcfs_lnd2str_r(lnd, libcfs_next_nidstring(),
+				LNET_NIDSTR_SIZE);
+}
 int libcfs_str2lnd(const char *str);
-char *libcfs_net2str(__u32 net);
-char *libcfs_nid2str(lnet_nid_t nid);
+char *libcfs_net2str_r(__u32 net, char *buf, size_t buf_size);
+static inline char *libcfs_net2str(__u32 net)
+{
+	return libcfs_net2str_r(net, libcfs_next_nidstring(),
+				LNET_NIDSTR_SIZE);
+}
+char *libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size);
+static inline char *libcfs_nid2str(lnet_nid_t nid)
+{
+	return libcfs_nid2str_r(nid, libcfs_next_nidstring(),
+				LNET_NIDSTR_SIZE);
+}
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
@@ -79,10 +96,10 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 			       char *max_nid, size_t nidstr_length);
 
 struct netstrfns {
-	int	nf_type;
+	__u32	nf_type;
 	char	*nf_name;
 	char	*nf_modname;
-	void	(*nf_addr2str)(__u32 addr, char *str);
+	void	(*nf_addr2str)(__u32 addr, char *str, size_t size);
 	int	(*nf_str2addr)(const char *str, int nob, __u32 *addr);
 	int	(*nf_parse_addrlist)(char *str, int len,
 				     struct list_head *list);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 53ad5ef..3954126 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -263,7 +263,7 @@ static void lnet_assert_wire_constants(void)
 }
 
 static lnd_t *
-lnet_find_lnd_by_type(int type)
+lnet_find_lnd_by_type(__u32 type)
 {
 	lnd_t *lnd;
 	struct list_head *tmp;
@@ -272,7 +272,7 @@ lnet_find_lnd_by_type(int type)
 	list_for_each(tmp, &the_lnet.ln_lnds) {
 		lnd = list_entry(tmp, lnd_t, lnd_list);
 
-		if ((int)lnd->lnd_type == type)
+		if (lnd->lnd_type == type)
 			return lnd;
 	}
 
@@ -962,7 +962,7 @@ lnet_startup_lndnis(void)
 	struct list_head nilist;
 	int i;
 	int rc = 0;
-	int lnd_type;
+	__u32 lnd_type;
 	int nicount = 0;
 	char *nets = lnet_get_networks();
 
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 4402b80..b7a65da 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -693,8 +693,8 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 
 		nf->nf_min_max(nidlist, &min_addr, &max_addr);
 	}
-	nf->nf_addr2str(min_addr, min_addr_str);
-	nf->nf_addr2str(max_addr, max_addr_str);
+	nf->nf_addr2str(min_addr, min_addr_str, sizeof(min_addr_str));
+	nf->nf_addr2str(max_addr, max_addr_str, sizeof(max_addr_str));
 
 	snprintf(min_nid, nidstr_length, "%s@%s%d", min_addr_str, lndname,
 		 netnum);
@@ -777,9 +777,9 @@ libcfs_lo_str2addr(const char *str, int nob, __u32 *addr)
 }
 
 static void
-libcfs_ip_addr2str(__u32 addr, char *str)
+libcfs_ip_addr2str(__u32 addr, char *str, size_t size)
 {
-	snprintf(str, LNET_NIDSTR_SIZE, "%u.%u.%u.%u",
+	snprintf(str, size, "%u.%u.%u.%u",
 		 (addr >> 24) & 0xff, (addr >> 16) & 0xff,
 		 (addr >> 8) & 0xff, addr & 0xff);
 }
@@ -888,15 +888,15 @@ cfs_ip_addr_match(__u32 addr, struct list_head *list)
 }
 
 static void
-libcfs_decnum_addr2str(__u32 addr, char *str)
+libcfs_decnum_addr2str(__u32 addr, char *str, size_t size)
 {
-	snprintf(str, LNET_NIDSTR_SIZE, "%u", addr);
+	snprintf(str, size, "%u", addr);
 }
 
 static void
-libcfs_hexnum_addr2str(__u32 addr, char *str)
+libcfs_hexnum_addr2str(__u32 addr, char *str, size_t size)
 {
-	snprintf(str, LNET_NIDSTR_SIZE, "0x%x", addr);
+	snprintf(str, size, "0x%x", addr);
 }
 
 static int
@@ -1105,17 +1105,16 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	{/* .nf_type      */  -1},
 };
 
-static const int libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
+static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
 
 static struct netstrfns *
-libcfs_lnd2netstrfns(int lnd)
+libcfs_lnd2netstrfns(__u32 lnd)
 {
-	int    i;
+	int i;
 
-	if (lnd >= 0)
-		for (i = 0; i < libcfs_nnetstrfns; i++)
-			if (lnd == libcfs_netstrfns[i].nf_type)
-				return &libcfs_netstrfns[i];
+	for (i = 0; i < libcfs_nnetstrfns; i++)
+		if (lnd == libcfs_netstrfns[i].nf_type)
+			return &libcfs_netstrfns[i];
 
 	return NULL;
 }
@@ -1124,7 +1123,7 @@ static struct netstrfns *
 libcfs_namenum2netstrfns(const char *name)
 {
 	struct netstrfns *nf;
-	int	       i;
+	int i;
 
 	for (i = 0; i < libcfs_nnetstrfns; i++) {
 		nf = &libcfs_netstrfns[i];
@@ -1149,14 +1148,14 @@ libcfs_name2netstrfns(const char *name)
 }
 
 int
-libcfs_isknown_lnd(int type)
+libcfs_isknown_lnd(__u32 lnd)
 {
-	return libcfs_lnd2netstrfns(type) != NULL;
+	return libcfs_lnd2netstrfns(lnd) != NULL;
 }
 EXPORT_SYMBOL(libcfs_isknown_lnd);
 
 char *
-libcfs_lnd2modname(int lnd)
+libcfs_lnd2modname(__u32 lnd)
 {
 	struct netstrfns *nf = libcfs_lnd2netstrfns(lnd);
 
@@ -1164,21 +1163,6 @@ libcfs_lnd2modname(int lnd)
 }
 EXPORT_SYMBOL(libcfs_lnd2modname);
 
-char *
-libcfs_lnd2str(int lnd)
-{
-	char	   *str;
-	struct netstrfns *nf = libcfs_lnd2netstrfns(lnd);
-
-	if (nf != NULL)
-		return nf->nf_name;
-
-	str = libcfs_next_nidstring();
-	snprintf(str, LNET_NIDSTR_SIZE, "?%d?", lnd);
-	return str;
-}
-EXPORT_SYMBOL(libcfs_lnd2str);
-
 int
 libcfs_str2lnd(const char *str)
 {
@@ -1192,65 +1176,81 @@ libcfs_str2lnd(const char *str)
 EXPORT_SYMBOL(libcfs_str2lnd);
 
 char *
-libcfs_net2str(__u32 net)
+libcfs_lnd2str_r(__u32 lnd, char *buf, size_t buf_size)
+{
+	struct netstrfns *nf;
+
+	nf = libcfs_lnd2netstrfns(lnd);
+	if (nf == NULL)
+		snprintf(buf, buf_size, "?%u?", lnd);
+	else
+		snprintf(buf, buf_size, "%s", nf->nf_name);
+
+	return buf;
+}
+EXPORT_SYMBOL(libcfs_lnd2str_r);
+
+char *
+libcfs_net2str_r(__u32 net, char *buf, size_t buf_size)
 {
-	int	       lnd = LNET_NETTYP(net);
-	int	       num = LNET_NETNUM(net);
-	struct netstrfns *nf  = libcfs_lnd2netstrfns(lnd);
-	char	     *str = libcfs_next_nidstring();
+	__u32 nnum = LNET_NETNUM(net);
+	__u32 lnd = LNET_NETTYP(net);
+	struct netstrfns *nf;
 
+	nf = libcfs_lnd2netstrfns(lnd);
 	if (nf == NULL)
-		snprintf(str, LNET_NIDSTR_SIZE, "<%d:%d>", lnd, num);
-	else if (num == 0)
-		snprintf(str, LNET_NIDSTR_SIZE, "%s", nf->nf_name);
+		snprintf(buf, buf_size, "<%u:%u>", lnd, nnum);
+	else if (nnum == 0)
+		snprintf(buf, buf_size, "%s", nf->nf_name);
 	else
-		snprintf(str, LNET_NIDSTR_SIZE, "%s%d", nf->nf_name, num);
+		snprintf(buf, buf_size, "%s%u", nf->nf_name, nnum);
 
-	return str;
+	return buf;
 }
-EXPORT_SYMBOL(libcfs_net2str);
+EXPORT_SYMBOL(libcfs_net2str_r);
 
 char *
-libcfs_nid2str(lnet_nid_t nid)
+libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size)
 {
-	__u32	     addr = LNET_NIDADDR(nid);
-	__u32	     net = LNET_NIDNET(nid);
-	int	       lnd = LNET_NETTYP(net);
-	int	       nnum = LNET_NETNUM(net);
+	__u32 addr = LNET_NIDADDR(nid);
+	__u32 net = LNET_NIDNET(nid);
+	__u32 nnum = LNET_NETNUM(net);
+	__u32 lnd = LNET_NETTYP(net);
 	struct netstrfns *nf;
-	char	     *str;
-	int	       nob;
 
-	if (nid == LNET_NID_ANY)
-		return "<?>";
+	if (nid == LNET_NID_ANY) {
+		strncpy(buf, "<?>", buf_size);
+		buf[buf_size - 1] = '\0';
+		return buf;
+	}
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	str = libcfs_next_nidstring();
-
 	if (nf == NULL)
-		snprintf(str, LNET_NIDSTR_SIZE, "%x@<%d:%d>", addr, lnd, nnum);
+		snprintf(buf, buf_size, "%x@<%u:%u>", addr, lnd, nnum);
 	else {
-		nf->nf_addr2str(addr, str);
-		nob = strlen(str);
+		size_t addr_len;
+
+		nf->nf_addr2str(addr, buf, buf_size);
+		addr_len = strlen(buf);
 		if (nnum == 0)
-			snprintf(str + nob, LNET_NIDSTR_SIZE - nob, "@%s",
+			snprintf(buf + addr_len, buf_size - addr_len, "@%s",
 				 nf->nf_name);
 		else
-			snprintf(str + nob, LNET_NIDSTR_SIZE - nob, "@%s%d",
+			snprintf(buf + addr_len, buf_size - addr_len, "@%s%u",
 				 nf->nf_name, nnum);
 	}
 
-	return str;
+	return buf;
 }
-EXPORT_SYMBOL(libcfs_nid2str);
+EXPORT_SYMBOL(libcfs_nid2str_r);
 
 static struct netstrfns *
 libcfs_str2net_internal(const char *str, __u32 *net)
 {
 	struct netstrfns *uninitialized_var(nf);
-	int	       nob;
-	unsigned int   netnum;
-	int	       i;
+	int nob;
+	unsigned int netnum;
+	int i;
 
 	for (i = 0; i < libcfs_nnetstrfns; i++) {
 		nf = &libcfs_netstrfns[i];
@@ -1296,10 +1296,10 @@ EXPORT_SYMBOL(libcfs_str2net);
 lnet_nid_t
 libcfs_str2nid(const char *str)
 {
-	const char       *sep = strchr(str, '@');
+	const char *sep = strchr(str, '@');
 	struct netstrfns *nf;
-	__u32	     net;
-	__u32	     addr;
+	__u32 net;
+	__u32 addr;
 
 	if (sep != NULL) {
 		nf = libcfs_str2net_internal(sep + 1, &net);
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 4b56770..fe49f1b 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -235,7 +235,7 @@ lnet_find_net_locked(__u32 net)
 static void lnet_shuffle_seed(void)
 {
 	static int seeded;
-	int lnd_type, seed[2];
+	__u32 lnd_type, seed[2];
 	struct timespec64 ts;
 	lnet_ni_t *ni;
 	struct list_head *tmp;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 3228fee..047ced5 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -610,6 +610,7 @@ static void obd_connect_seq_flags2str(struct seq_file *m, __u64 flags, char *sep
 
 int lprocfs_rd_import(struct seq_file *m, void *data)
 {
+	char				nidstr[LNET_NIDSTR_SIZE];
 	struct lprocfs_counter		ret;
 	struct lprocfs_counter_header	*header;
 	struct obd_device		*obd	= data;
@@ -647,18 +648,20 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	spin_lock(&imp->imp_lock);
 	j = 0;
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-		seq_printf(m, "%s%s", j ? ", " : "",
-			   libcfs_nid2str(conn->oic_conn->c_peer.nid));
+		libcfs_nid2str_r(conn->oic_conn->c_peer.nid,
+				 nidstr, sizeof(nidstr));
+		seq_printf(m, "%s%s", j ? ", " : "", nidstr);
 		j++;
 	}
+	libcfs_nid2str_r(imp->imp_connection->c_peer.nid,
+			 nidstr, sizeof(nidstr));
 	seq_printf(m,
 		      "]\n"
 		      "       current_connection: %s\n"
 		      "       connection_attempts: %u\n"
 		      "       generation: %u\n"
 		      "       in-progress_invalidations: %u\n",
-		      imp->imp_connection == NULL ? "<none>" :
-			      libcfs_nid2str(imp->imp_connection->c_peer.nid),
+		      imp->imp_connection == NULL ? "<none>" : nidstr,
 		      imp->imp_conn_cnt,
 		      imp->imp_generation,
 		      atomic_read(&imp->imp_inval_count));
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 38e5e13..64753b3 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1316,10 +1316,13 @@ static int class_config_parse_rec(struct llog_rec_hdr *rec, char *buf,
 	if (lcfg->lcfg_num)
 		ptr += snprintf(ptr, end-ptr, "num=%#08x ", lcfg->lcfg_num);
 
-	if (lcfg->lcfg_nid)
+	if (lcfg->lcfg_nid) {
+		char nidstr[LNET_NIDSTR_SIZE];
+
+		libcfs_nid2str_r(lcfg->lcfg_nid, nidstr, sizeof(nidstr));
 		ptr += snprintf(ptr, end-ptr, "nid=%s(%#llx)\n     ",
-				libcfs_nid2str(lcfg->lcfg_nid),
-				lcfg->lcfg_nid);
+				nidstr, lcfg->lcfg_nid);
+	}
 
 	if (lcfg->lcfg_command == LCFG_MARKER) {
 		struct cfg_marker *marker = lustre_cfg_buf(lcfg, 1);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 149c838..48003d5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -209,9 +209,10 @@ int lustre_start_mgc(struct super_block *sb)
 	struct obd_uuid *uuid;
 	class_uuid_t uuidc;
 	lnet_nid_t nid;
+	char nidstr[LNET_NIDSTR_SIZE];
 	char *mgcname = NULL, *niduuid = NULL, *mgssec = NULL;
 	char *ptr;
-	int rc = 0, i = 0, j, len;
+	int rc = 0, i = 0, j;
 
 	LASSERT(lsi->lsi_lmd);
 
@@ -226,9 +227,9 @@ int lustre_start_mgc(struct super_block *sb)
 
 	mutex_lock(&mgc_start_lock);
 
-	len = strlen(LUSTRE_MGC_OBDNAME) + strlen(libcfs_nid2str(nid)) + 1;
+	libcfs_nid2str_r(nid, nidstr, sizeof(nidstr));
 	mgcname = kasprintf(GFP_NOFS,
-			    "%s%s", LUSTRE_MGC_OBDNAME, libcfs_nid2str(nid));
+			    "%s%s", LUSTRE_MGC_OBDNAME, nidstr);
 	niduuid = kasprintf(GFP_NOFS, "%s_%x", mgcname, i);
 	if (!mgcname || !niduuid) {
 		rc = -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 32c9713..0d3878a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1547,8 +1547,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	if (body->oa.o_valid & OBD_MD_FLCKSUM) {
 		static int cksum_counter;
 		__u32 server_cksum = body->oa.o_cksum;
-		char *via;
-		char *router;
+		char *via = "";
+		char *router = "";
 		cksum_type_t cksum_type;
 
 		cksum_type = cksum_type_unpack(body->oa.o_valid&OBD_MD_FLFLAGS ?
@@ -1557,9 +1557,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 						 aa->aa_ppga, OST_READ,
 						 cksum_type);
 
-		if (peer->nid == req->rq_bulk->bd_sender) {
-			via = router = "";
-		} else {
+		if (peer->nid != req->rq_bulk->bd_sender) {
 			via = " via ";
 			router = libcfs_nid2str(req->rq_bulk->bd_sender);
 		}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 415817c..bc5437e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -909,8 +909,11 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 	rc = ptlrpc_lprocfs_svc_req_history_seek(svcpt, srhi, srhi->srhi_seq);
 
 	if (rc == 0) {
+		char nidstr[LNET_NIDSTR_SIZE];
+
 		req = srhi->srhi_req;
 
+		libcfs_nid2str_r(req->rq_self, nidstr, sizeof(nidstr));
 		/* Print common req fields.
 		 * CAVEAT EMPTOR: we're racing with the service handler
 		 * here.  The request could contain any old crap, so you
@@ -918,7 +921,7 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 		 * parser. Currently I only print stuff here I know is OK
 		 * to look at coz it was set up in request_in_callback()!!! */
 		seq_printf(s, "%lld:%s:%s:x%llu:%d:%s:%lld:%lds(%+lds) ",
-			   req->rq_history_seq, libcfs_nid2str(req->rq_self),
+			   req->rq_history_seq, nidstr,
 			   libcfs_id2str(req->rq_peer), req->rq_xid,
 			   req->rq_reqlen, ptlrpc_rqphase2str(req),
 			   (s64)req->rq_arrival_time.tv_sec,
-- 
1.7.1
