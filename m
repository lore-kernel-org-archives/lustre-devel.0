From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:02 -0400
Subject: [lustre-devel] [PATCH 19/29] staging/lustre: remove lots of dead
	code
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arnd Bergmann <arnd@arndb.de>

This is a large patch to remove all dead code from obdclass and
ptlrpc, purely removing functions and declarations now, so
despite the size should be easy enough to verify.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   8 -
 .../lustre/lustre/include/lustre/lustre_user.h     |   2 -
 .../staging/lustre/lustre/include/lustre_debug.h   |   1 -
 .../staging/lustre/lustre/include/lustre_export.h  |   1 -
 drivers/staging/lustre/lustre/include/lustre_net.h |  18 --
 .../staging/lustre/lustre/include/lustre_param.h   |   6 -
 .../lustre/lustre/include/lustre_req_layout.h      |   4 -
 drivers/staging/lustre/lustre/include/obd_class.h  |  16 --
 drivers/staging/lustre/lustre/obdclass/debug.c     |  10 -
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   4 -
 .../staging/lustre/lustre/obdclass/obd_config.c    | 257 ---------------------
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  64 -----
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         | 123 ----------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 197 ----------------
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  18 --
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   2 -
 16 files changed, 731 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 3ac1de3..9cc92bb 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2587,8 +2587,6 @@ struct lmv_desc {
 	struct obd_uuid ld_uuid;
 };
 
-void lustre_swab_lmv_desc(struct lmv_desc *ld);
-
 /* TODO: lmv_stripe_md should contain mds capabilities for all slave fids */
 struct lmv_stripe_md {
 	__u32	 mea_magic;
@@ -2599,8 +2597,6 @@ struct lmv_stripe_md {
 	struct lu_fid mea_ids[0];
 };
 
-void lustre_swab_lmv_stripe_md(struct lmv_stripe_md *mea);
-
 /* lmv structures */
 #define MEA_MAGIC_LAST_CHAR      0xb2221ca1
 #define MEA_MAGIC_ALL_CHARS      0xb222a11c
@@ -3442,8 +3438,6 @@ struct lu_idxpage {
 	char	lip_entries[0];
 };
 
-void lustre_swab_lip_header(struct lu_idxpage *lip);
-
 #define LIP_HDR_SIZE (offsetof(struct lu_idxpage, lip_entries))
 
 /* Gather all possible type associated with a 4KB container */
@@ -3517,8 +3511,6 @@ struct lustre_capa_key {
 	__u8    lk_key[CAPA_HMAC_KEY_MAX_LEN];    /**< key */
 } __attribute__((packed));
 
-void lustre_swab_lustre_capa_key(struct lustre_capa_key *k);
-
 /** The link ea holds 1 \a link_ea_entry for each hardlink */
 #define LINK_EA_MAGIC 0x11EAF1DFUL
 struct link_ea_header {
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index e9925ef..1a41366 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -406,8 +406,6 @@ static inline int lmv_user_md_size(int stripes, int lmm_magic)
 		      stripes * sizeof(struct lmv_user_mds_data);
 }
 
-void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
-
 struct ll_recreate_obj {
 	__u64 lrc_id;
 	__u32 lrc_ost_idx;
diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
index 6c92d0b..8a08941 100644
--- a/drivers/staging/lustre/lustre/include/lustre_debug.h
+++ b/drivers/staging/lustre/lustre/include/lustre_debug.h
@@ -46,7 +46,6 @@
 #include "obd.h"
 
 /* lib/debug.c */
-void dump_lniobuf(struct niobuf_local *lnb);
 int dump_req(struct ptlrpc_request *req);
 int block_debug_setup(void *addr, int len, __u64 off, __u64 id);
 int block_debug_check(char *who, void *addr, int len, __u64 off, __u64 id);
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index c29bfdb..7634dea 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -353,7 +353,6 @@ static inline bool imp_connect_disp_stripe(struct obd_import *imp)
 }
 
 struct obd_export *class_conn2export(struct lustre_handle *conn);
-struct obd_device *class_conn2obd(struct lustre_handle *conn);
 
 /** @} export */
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index a486c1d..af3bf21 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -642,7 +642,6 @@ struct ptlrpc_nrs_pol_ops {
 	 *
 	 * \see ptlrpc_nrs_req_initialize()
 	 * \see ptlrpc_nrs_hpreq_add_nolock()
-	 * \see ptlrpc_nrs_req_hp_move()
 	 */
 	int	(*op_res_get) (struct ptlrpc_nrs_policy *policy,
 			       struct ptlrpc_nrs_request *nrq,
@@ -658,7 +657,6 @@ struct ptlrpc_nrs_pol_ops {
 	 *
 	 * \see ptlrpc_nrs_req_finalize()
 	 * \see ptlrpc_nrs_hpreq_add_nolock()
-	 * \see ptlrpc_nrs_req_hp_move()
 	 */
 	void	(*op_res_put) (struct ptlrpc_nrs_policy *policy,
 			       const struct ptlrpc_nrs_resource *res);
@@ -703,8 +701,6 @@ struct ptlrpc_nrs_pol_ops {
 	 *
 	 * \param[in,out] policy The policy the request \a nrq belongs to
 	 * \param[in,out] nrq    The request to dequeue
-	 *
-	 * \see ptlrpc_nrs_req_del_nolock()
 	 */
 	void	(*op_req_dequeue) (struct ptlrpc_nrs_policy *policy,
 				   struct ptlrpc_nrs_request *nrq);
@@ -1536,10 +1532,6 @@ static inline int ptlrpc_req_interpret(const struct lu_env *env,
  * @{
  */
 int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf);
-int ptlrpc_nrs_policy_unregister(struct ptlrpc_nrs_pol_conf *conf);
-void ptlrpc_nrs_req_hp_move(struct ptlrpc_request *req);
-void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
-				struct ptlrpc_nrs_pol_info *info);
 
 /*
  * Can the request be moved from the regular NRS head to the high-priority NRS
@@ -2522,7 +2514,6 @@ void ptlrpc_stop_all_threads(struct ptlrpc_service *svc);
 int ptlrpc_start_threads(struct ptlrpc_service *svc);
 int ptlrpc_unregister_service(struct ptlrpc_service *service);
 int liblustre_check_services(void *arg);
-void ptlrpc_daemonize(char *name);
 void ptlrpc_server_drop_request(struct ptlrpc_request *req);
 
 int ptlrpc_hr_init(void);
@@ -2558,7 +2549,6 @@ void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len);
 int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len);
 
-int lustre_msg_check_version(struct lustre_msg *msg, __u32 version);
 void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
 			char **bufs);
 int lustre_pack_request(struct ptlrpc_request *, __u32 magic, int count,
@@ -2582,7 +2572,6 @@ int lustre_msg_early_size(void);
 void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, int n, int min_size);
 void *lustre_msg_buf(struct lustre_msg *m, int n, int minlen);
 int lustre_msg_buflen(struct lustre_msg *m, int n);
-void lustre_msg_set_buflen(struct lustre_msg *m, int n, int len);
 int lustre_msg_bufcount(struct lustre_msg *m);
 char *lustre_msg_string(struct lustre_msg *m, int n, int max_len);
 __u32 lustre_msghdr_get_flags(struct lustre_msg *msg);
@@ -2595,10 +2584,8 @@ __u32 lustre_msg_get_op_flags(struct lustre_msg *msg);
 void lustre_msg_add_op_flags(struct lustre_msg *msg, int flags);
 struct lustre_handle *lustre_msg_get_handle(struct lustre_msg *msg);
 __u32 lustre_msg_get_type(struct lustre_msg *msg);
-__u32 lustre_msg_get_version(struct lustre_msg *msg);
 void lustre_msg_add_version(struct lustre_msg *msg, int version);
 __u32 lustre_msg_get_opc(struct lustre_msg *msg);
-__u64 lustre_msg_get_last_xid(struct lustre_msg *msg);
 __u64 lustre_msg_get_last_committed(struct lustre_msg *msg);
 __u64 *lustre_msg_get_versions(struct lustre_msg *msg);
 __u64 lustre_msg_get_transno(struct lustre_msg *msg);
@@ -2611,21 +2598,16 @@ __u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg);
 __u32 lustre_msg_get_magic(struct lustre_msg *msg);
 __u32 lustre_msg_get_timeout(struct lustre_msg *msg);
 __u32 lustre_msg_get_service_time(struct lustre_msg *msg);
-char *lustre_msg_get_jobid(struct lustre_msg *msg);
 __u32 lustre_msg_get_cksum(struct lustre_msg *msg);
 __u32 lustre_msg_calc_cksum(struct lustre_msg *msg);
 void lustre_msg_set_handle(struct lustre_msg *msg,
 			   struct lustre_handle *handle);
 void lustre_msg_set_type(struct lustre_msg *msg, __u32 type);
 void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc);
-void lustre_msg_set_last_xid(struct lustre_msg *msg, __u64 last_xid);
-void lustre_msg_set_last_committed(struct lustre_msg *msg,
-				   __u64 last_committed);
 void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions);
 void lustre_msg_set_transno(struct lustre_msg *msg, __u64 transno);
 void lustre_msg_set_status(struct lustre_msg *msg, __u32 status);
 void lustre_msg_set_conn_cnt(struct lustre_msg *msg, __u32 conn_cnt);
-void ptlrpc_req_set_repsize(struct ptlrpc_request *req, int count, __u32 *sizes);
 void ptlrpc_request_set_replen(struct ptlrpc_request *req);
 void lustre_msg_set_timeout(struct lustre_msg *msg, __u32 timeout);
 void lustre_msg_set_service_time(struct lustre_msg *msg, __u32 service_time);
diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index ed65468..de49b41 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -56,15 +56,9 @@ struct cfg_interop_param {
 
 /* obd_config.c */
 int class_find_param(char *buf, char *key, char **valp);
-struct cfg_interop_param *class_find_old_param(const char *param,
-					       struct cfg_interop_param *ptr);
-int class_get_next_param(char **params, char *copy);
 int class_match_param(char *buf, char *key, char **valp);
 int class_parse_nid(char *buf, lnet_nid_t *nid, char **endh);
 int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh);
-int class_parse_net(char *buf, __u32 *net, char **endh);
-int class_match_nid(char *buf, char *key, lnet_nid_t nid);
-int class_match_net(char *buf, char *key, __u32 net);
 /* obd_mount.c */
 int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
 	    char *s1, char *s2, char *s3, char *s4);
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 04c0076..cfcc995 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -80,8 +80,6 @@ void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
 void req_capsule_fini(struct req_capsule *pill);
 
 void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt);
-void req_capsule_client_dump(struct req_capsule *pill);
-void req_capsule_server_dump(struct req_capsule *pill);
 void req_capsule_init_area(struct req_capsule *pill);
 int req_capsule_filled_sizes(struct req_capsule *pill, enum req_location loc);
 int  req_capsule_server_pack(struct req_capsule *pill);
@@ -105,8 +103,6 @@ void *req_capsule_server_swab_get(struct req_capsule *pill,
 void *req_capsule_server_sized_swab_get(struct req_capsule *pill,
 					const struct req_msg_field *field,
 					int len, void *swabber);
-const void *req_capsule_other_get(struct req_capsule *pill,
-				  const struct req_msg_field *field);
 
 void req_capsule_set_size(struct req_capsule *pill,
 			  const struct req_msg_field *field,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index b323403..73fb29f 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -106,8 +106,6 @@ struct llog_rec_hdr;
 typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
 			 struct llog_rec_hdr *, void *);
 /* obd_config.c */
-struct lustre_cfg *lustre_cfg_rename(struct lustre_cfg *cfg,
-				     const char *new_name);
 int class_process_config(struct lustre_cfg *lcfg);
 int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			     struct lustre_cfg *lcfg, void *data);
@@ -147,9 +145,6 @@ struct config_llog_instance {
 };
 int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 			    char *name, struct config_llog_instance *cfg);
-int class_config_dump_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
-			   char *name, struct config_llog_instance *cfg);
-
 enum {
 	CONFIG_T_CONFIG  = 0,
 	CONFIG_T_SPTLRPC = 1,
@@ -285,22 +280,11 @@ static inline enum obd_option exp_flags_from_obd(struct obd_device *obd)
 struct inode;
 struct lu_attr;
 struct obdo;
-void obdo_from_la(struct obdo *dst, struct lu_attr *la, __u64 valid);
-void la_from_obdo(struct lu_attr *la, struct obdo *dst, u32 valid);
 void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid);
-void obdo_to_inode(struct inode *dst, struct obdo *src, u32 valid);
 
-void obdo_cpy_md(struct obdo *dst, struct obdo *src, u32 valid);
 void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj);
-void obdo_from_iattr(struct obdo *oa, struct iattr *attr,
-		     unsigned int ia_valid);
 void iattr_from_obdo(struct iattr *attr, struct obdo *oa, u32 valid);
 void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid);
-void obdo_from_md(struct obdo *oa, struct md_op_data *op_data,
-		  unsigned int valid);
-
-void obdo_cpu_to_le(struct obdo *dobdo, struct obdo *sobdo);
-void obdo_le_to_cpu(struct obdo *dobdo, struct obdo *sobdo);
 
 #define OBT(dev)	(dev)->obd_type
 #define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->o_ ## op
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index c61add4..43a7f7a 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -46,16 +46,6 @@
 #include "../include/lustre_debug.h"
 #include "../include/lustre_net.h"
 
-void dump_lniobuf(struct niobuf_local *nb)
-{
-	CDEBUG(D_RPCTRACE,
-	       "niobuf_local: file_offset=%lld, len=%d, page=%p, rc=%d\n",
-	       nb->lnb_file_offset, nb->len, nb->page, nb->rc);
-	CDEBUG(D_RPCTRACE, "nb->page: index = %ld\n",
-			nb->page ? page_index(nb->page) : -1);
-}
-EXPORT_SYMBOL(dump_lniobuf);
-
 #define LPDS sizeof(__u64)
 int block_debug_setup(void *addr, int len, __u64 off, __u64 id)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 1515163..518288d 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -162,7 +162,3 @@ int obd_sysctl_init(void)
 {
 	return sysfs_create_group(lustre_kobj, &lustre_attr_group);
 }
-
-void obd_sysctl_clean(void)
-{
-}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index d19cbf6..a8a1cb7 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -71,114 +71,6 @@ int class_find_param(char *buf, char *key, char **valp)
 }
 EXPORT_SYMBOL(class_find_param);
 
-/**
- * Check whether the proc parameter \a param is an old parameter or not from
- * the array \a ptr which contains the mapping from old parameters to new ones.
- * If it's an old one, then return the pointer to the cfg_interop_param struc-
- * ture which contains both the old and new parameters.
- *
- * \param param			proc parameter
- * \param ptr			an array which contains the mapping from
- *				old parameters to new ones
- *
- * \retval valid-pointer	pointer to the cfg_interop_param structure
- *				which contains the old and new parameters
- * \retval NULL			\a param or \a ptr is NULL,
- *				or \a param is not an old parameter
- */
-struct cfg_interop_param *class_find_old_param(const char *param,
-					       struct cfg_interop_param *ptr)
-{
-	char *value = NULL;
-	int   name_len = 0;
-
-	if (!param || !ptr)
-		return NULL;
-
-	value = strchr(param, '=');
-	if (!value)
-		name_len = strlen(param);
-	else
-		name_len = value - param;
-
-	while (ptr->old_param != NULL) {
-		if (strncmp(param, ptr->old_param, name_len) == 0 &&
-		    name_len == strlen(ptr->old_param))
-			return ptr;
-		ptr++;
-	}
-
-	return NULL;
-}
-EXPORT_SYMBOL(class_find_old_param);
-
-/**
- * Finds a parameter in \a params and copies it to \a copy.
- *
- * Leading spaces are skipped. Next space or end of string is the
- * parameter terminator with the exception that spaces inside single or double
- * quotes get included into a parameter. The parameter is copied into \a copy
- * which has to be allocated big enough by a caller, quotes are stripped in
- * the copy and the copy is terminated by 0.
- *
- * On return \a params is set to next parameter or to NULL if last
- * parameter is returned.
- *
- * \retval 0 if parameter is returned in \a copy
- * \retval 1 otherwise
- * \retval -EINVAL if unbalanced quota is found
- */
-int class_get_next_param(char **params, char *copy)
-{
-	char *q1, *q2, *str;
-	int len;
-
-	str = *params;
-	while (*str == ' ')
-		str++;
-
-	if (*str == '\0') {
-		*params = NULL;
-		return 1;
-	}
-
-	while (1) {
-		q1 = strpbrk(str, " '\"");
-		if (!q1) {
-			len = strlen(str);
-			memcpy(copy, str, len);
-			copy[len] = '\0';
-			*params = NULL;
-			return 0;
-		}
-		len = q1 - str;
-		if (*q1 == ' ') {
-			memcpy(copy, str, len);
-			copy[len] = '\0';
-			*params = str + len;
-			return 0;
-		}
-
-		memcpy(copy, str, len);
-		copy += len;
-
-		/* search for the matching closing quote */
-		str = q1 + 1;
-		q2 = strchr(str, *q1);
-		if (!q2) {
-			CERROR("Unbalanced quota in parameters: \"%s\"\n",
-			       *params);
-			return -EINVAL;
-		}
-		len = q2 - str;
-		memcpy(copy, str, len);
-		copy += len;
-		str = q2 + 1;
-	}
-	return 1;
-}
-EXPORT_SYMBOL(class_get_next_param);
-
 /* returns 0 if this is the first key in the buffer, else 1.
    valp points to first char after key. */
 int class_match_param(char *buf, char *key, char **valp)
@@ -278,52 +170,6 @@ int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh)
 }
 EXPORT_SYMBOL(class_parse_nid_quiet);
 
-int class_parse_net(char *buf, __u32 *net, char **endh)
-{
-	return class_parse_value(buf, CLASS_PARSE_NET, (void *)net, endh, 0);
-}
-EXPORT_SYMBOL(class_parse_net);
-
-/* 1 param contains key and match
- * 0 param contains key and not match
- * -1 param does not contain key
- */
-int class_match_nid(char *buf, char *key, lnet_nid_t nid)
-{
-	lnet_nid_t tmp;
-	int   rc = -1;
-
-	while (class_find_param(buf, key, &buf) == 0) {
-		/* please restrict to the nids pertaining to
-		 * the specified nids */
-		while (class_parse_nid(buf, &tmp, &buf) == 0) {
-			if (tmp == nid)
-				return 1;
-		}
-		rc = 0;
-	}
-	return rc;
-}
-EXPORT_SYMBOL(class_match_nid);
-
-int class_match_net(char *buf, char *key, __u32 net)
-{
-	__u32 tmp;
-	int   rc = -1;
-
-	while (class_find_param(buf, key, &buf) == 0) {
-		/* please restrict to the nids pertaining to
-		 * the specified networks */
-		while (class_parse_net(buf, &tmp, &buf) == 0) {
-			if (tmp == net)
-				return 1;
-		}
-		rc = 0;
-	}
-	return rc;
-}
-EXPORT_SYMBOL(class_match_net);
-
 /********************** class fns **********************/
 
 /**
@@ -925,78 +771,6 @@ void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg))
 }
 EXPORT_SYMBOL(lustre_register_client_process_config);
 
-/**
- * Rename the proc parameter in \a cfg with a new name \a new_name.
- *
- * \param cfg	   config structure which contains the proc parameter
- * \param new_name new name of the proc parameter
- *
- * \retval valid-pointer    pointer to the newly-allocated config structure
- *			    which contains the renamed proc parameter
- * \retval ERR_PTR(-EINVAL) if \a cfg or \a new_name is NULL, or \a cfg does
- *			    not contain a proc parameter
- * \retval ERR_PTR(-ENOMEM) if memory allocation failure occurs
- */
-struct lustre_cfg *lustre_cfg_rename(struct lustre_cfg *cfg,
-				     const char *new_name)
-{
-	struct lustre_cfg_bufs	*bufs = NULL;
-	struct lustre_cfg	*new_cfg = NULL;
-	char			*param = NULL;
-	char			*new_param = NULL;
-	char			*value = NULL;
-	int			 name_len = 0;
-	int			 new_len = 0;
-
-	if (!cfg || !new_name)
-		return ERR_PTR(-EINVAL);
-
-	param = lustre_cfg_string(cfg, 1);
-	if (!param)
-		return ERR_PTR(-EINVAL);
-
-	value = strchr(param, '=');
-	if (!value)
-		name_len = strlen(param);
-	else
-		name_len = value - param;
-
-	new_len = LUSTRE_CFG_BUFLEN(cfg, 1) + strlen(new_name) - name_len;
-
-	new_param = kzalloc(new_len, GFP_NOFS);
-	if (!new_param)
-		return ERR_PTR(-ENOMEM);
-
-	strcpy(new_param, new_name);
-	if (value != NULL)
-		strcat(new_param, value);
-
-	bufs = kzalloc(sizeof(*bufs), GFP_NOFS);
-	if (!bufs) {
-		kfree(new_param);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	lustre_cfg_bufs_reset(bufs, NULL);
-	lustre_cfg_bufs_init(bufs, cfg);
-	lustre_cfg_bufs_set_string(bufs, 1, new_param);
-
-	new_cfg = lustre_cfg_new(cfg->lcfg_command, bufs);
-
-	kfree(new_param);
-	kfree(bufs);
-	if (!new_cfg)
-		return ERR_PTR(-ENOMEM);
-
-	new_cfg->lcfg_num = cfg->lcfg_num;
-	new_cfg->lcfg_flags = cfg->lcfg_flags;
-	new_cfg->lcfg_nid = cfg->lcfg_nid;
-	new_cfg->lcfg_nal = cfg->lcfg_nal;
-
-	return new_cfg;
-}
-EXPORT_SYMBOL(lustre_cfg_rename);
-
 static int process_param2_config(struct lustre_cfg *lcfg)
 {
 	char *param = lustre_cfg_string(lcfg, 1);
@@ -1037,12 +811,6 @@ static int process_param2_config(struct lustre_cfg *lcfg)
 	return rc;
 }
 
-void lustre_register_quota_process_config(int (*qpc)(struct lustre_cfg *lcfg))
-{
-	quota_process_config = qpc;
-}
-EXPORT_SYMBOL(lustre_register_quota_process_config);
-
 /** Process configuration commands given in lustre_cfg form.
  * These may come from direct calls (e.g. class_manual_cleanup)
  * or processing the config llog, or ioctl from lctl.
@@ -1633,31 +1401,6 @@ int class_config_dump_handler(const struct lu_env *env,
 	return rc;
 }
 
-int class_config_dump_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
-			   char *name, struct config_llog_instance *cfg)
-{
-	struct llog_handle	*llh;
-	int			 rc;
-
-	LCONSOLE_INFO("Dumping config log %s\n", name);
-
-	rc = llog_open(env, ctxt, &llh, NULL, name, LLOG_OPEN_EXISTS);
-	if (rc)
-		return rc;
-
-	rc = llog_init_handle(env, llh, LLOG_F_IS_PLAIN, NULL);
-	if (rc)
-		goto parse_out;
-
-	rc = llog_process(env, llh, class_config_dump_handler, cfg, NULL);
-parse_out:
-	llog_close(env, llh);
-
-	LCONSOLE_INFO("End config log %s\n", name);
-	return rc;
-}
-EXPORT_SYMBOL(class_config_dump_llog);
-
 /** Call class_cleanup and class_detach.
  * "Manual" only in the sense that we're faking lcfg commands.
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 4ddbe0d..991fb74 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1996,55 +1996,6 @@ static void *__req_capsule_get(struct req_capsule *pill,
 }
 
 /**
- * Dump a request and/or reply
- */
-static void __req_capsule_dump(struct req_capsule *pill, enum req_location loc)
-{
-	const struct req_format *fmt;
-	const struct req_msg_field *field;
-	int len;
-	int i;
-
-	fmt = pill->rc_fmt;
-
-	DEBUG_REQ(D_RPCTRACE, pill->rc_req, "BEGIN REQ CAPSULE DUMP\n");
-	for (i = 0; i < fmt->rf_fields[loc].nr; ++i) {
-		field = FMT_FIELD(fmt, loc, i);
-		if (field->rmf_dumper == NULL) {
-			/*
-			 * FIXME Add a default hex dumper for fields that don't
-			 * have a specific dumper
-			 */
-			len = req_capsule_get_size(pill, field, loc);
-			CDEBUG(D_RPCTRACE, "Field %s has no dumper function; field size is %d\n",
-			       field->rmf_name, len);
-		} else {
-			/* It's the dumping side-effect that we're interested in */
-			(void) __req_capsule_get(pill, field, loc, NULL, 1);
-		}
-	}
-	CDEBUG(D_RPCTRACE, "END REQ CAPSULE DUMP\n");
-}
-
-/**
- * Dump a request.
- */
-void req_capsule_client_dump(struct req_capsule *pill)
-{
-	__req_capsule_dump(pill, RCL_CLIENT);
-}
-EXPORT_SYMBOL(req_capsule_client_dump);
-
-/**
- * Dump a reply
- */
-void req_capsule_server_dump(struct req_capsule *pill)
-{
-	__req_capsule_dump(pill, RCL_SERVER);
-}
-EXPORT_SYMBOL(req_capsule_server_dump);
-
-/**
  * Trivial wrapper around __req_capsule_get(), that returns the PTLRPC request
  * buffer corresponding to the given RMF (\a field) of a \a pill.
  */
@@ -2136,21 +2087,6 @@ void *req_capsule_server_sized_swab_get(struct req_capsule *pill,
 EXPORT_SYMBOL(req_capsule_server_sized_swab_get);
 
 /**
- * Returns the buffer of a \a pill corresponding to the given \a field from the
- * request (if the caller is executing on the server-side) or reply (if the
- * caller is executing on the client-side).
- *
- * This function convenient for use is code that could be executed on the
- * client and server alike.
- */
-const void *req_capsule_other_get(struct req_capsule *pill,
-				  const struct req_msg_field *field)
-{
-	return __req_capsule_get(pill, field, pill->rc_loc ^ 1, NULL, 0);
-}
-EXPORT_SYMBOL(req_capsule_other_get);
-
-/**
  * Set the size of the PTLRPC request/reply (\a loc) buffer for the given \a
  * field of the given \a pill.
  *
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 40696f3..2476cf2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -477,7 +477,6 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
  *
  * \param resp	the resource hierarchy that is being released
  *
- * \see ptlrpc_nrs_req_hp_move()
  * \see ptlrpc_nrs_req_finalize()
  */
 static void nrs_resource_put_safe(struct ptlrpc_nrs_resource **resp)
@@ -1251,70 +1250,6 @@ fail:
 EXPORT_SYMBOL(ptlrpc_nrs_policy_register);
 
 /**
- * Unregisters a previously registered policy with NRS core. All instances of
- * the policy on all NRS heads of all supported services are removed.
- *
- * N.B. This function should only be called from a module's exit() function.
- *	Although it can be used for policies that ship alongside NRS core, the
- *	function is primarily intended for policies that register externally,
- *	from other modules.
- *
- * \param[in] conf configuration information for the policy to unregister
- *
- * \retval -ve error
- * \retval   0 success
- */
-int ptlrpc_nrs_policy_unregister(struct ptlrpc_nrs_pol_conf *conf)
-{
-	struct ptlrpc_nrs_pol_desc *desc;
-	int rc;
-
-	LASSERT(conf != NULL);
-
-	if (conf->nc_flags & PTLRPC_NRS_FL_FALLBACK) {
-		CERROR("Unable to unregister a fallback policy, unless the PTLRPC service is stopping.\n");
-		return -EPERM;
-	}
-
-	conf->nc_name[NRS_POL_NAME_MAX - 1] = '\0';
-
-	mutex_lock(&nrs_core.nrs_mutex);
-
-	desc = nrs_policy_find_desc_locked(conf->nc_name);
-	if (desc == NULL) {
-		CERROR("Failing to unregister NRS policy %s which has not been registered with NRS core!\n",
-		       conf->nc_name);
-		rc = -ENOENT;
-		goto not_exist;
-	}
-
-	mutex_lock(&ptlrpc_all_services_mutex);
-
-	rc = nrs_policy_unregister_locked(desc);
-	if (rc < 0) {
-		if (rc == -EBUSY)
-			CERROR("Please first stop policy %s on all service partitions and then retry to unregister the policy.\n",
-			       conf->nc_name);
-		goto fail;
-	}
-
-	CDEBUG(D_INFO, "Unregistering policy %s from NRS core.\n",
-	       conf->nc_name);
-
-	list_del(&desc->pd_list);
-	kfree(desc);
-
-fail:
-	mutex_unlock(&ptlrpc_all_services_mutex);
-
-not_exist:
-	mutex_unlock(&nrs_core.nrs_mutex);
-
-	return rc;
-}
-EXPORT_SYMBOL(ptlrpc_nrs_policy_unregister);
-
-/**
  * Setup NRS heads on all service partitions of service \a svc, and register
  * all compatible policies on those NRS heads.
  *
@@ -1553,22 +1488,6 @@ ptlrpc_nrs_req_get_nolock0(struct ptlrpc_service_part *svcpt, bool hp,
 }
 
 /**
- * Dequeues request \a req from the policy it has been enqueued on.
- *
- * \param[in] req the request
- */
-void ptlrpc_nrs_req_del_nolock(struct ptlrpc_request *req)
-{
-	struct ptlrpc_nrs_policy *policy = nrs_request_policy(&req->rq_nrq);
-
-	policy->pol_desc->pd_ops->op_req_dequeue(policy, &req->rq_nrq);
-
-	req->rq_nrq.nr_enqueued = 0;
-
-	nrs_request_removed(policy);
-}
-
-/**
  * Returns whether there are any requests currently enqueued on any of the
  * policies of service partition's \a svcpt NRS head specified by \a hp. Should
  * be called while holding ptlrpc_service_part::scp_req_lock to get a reliable
@@ -1589,48 +1508,6 @@ bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp)
 };
 
 /**
- * Moves request \a req from the regular to the high-priority NRS head.
- *
- * \param[in] req the request to move
- */
-void ptlrpc_nrs_req_hp_move(struct ptlrpc_request *req)
-{
-	struct ptlrpc_service_part *svcpt = req->rq_rqbd->rqbd_svcpt;
-	struct ptlrpc_nrs_request *nrq = &req->rq_nrq;
-	struct ptlrpc_nrs_resource *res1[NRS_RES_MAX];
-	struct ptlrpc_nrs_resource *res2[NRS_RES_MAX];
-
-	/**
-	 * Obtain the high-priority NRS head resources.
-	 */
-	nrs_resource_get_safe(nrs_svcpt2nrs(svcpt, true), nrq, res1, true);
-
-	spin_lock(&svcpt->scp_req_lock);
-
-	if (!ptlrpc_nrs_req_can_move(req))
-		goto out;
-
-	ptlrpc_nrs_req_del_nolock(req);
-
-	memcpy(res2, nrq->nr_res_ptrs, NRS_RES_MAX * sizeof(res2[0]));
-	memcpy(nrq->nr_res_ptrs, res1, NRS_RES_MAX * sizeof(res1[0]));
-
-	ptlrpc_nrs_hpreq_add_nolock(req);
-
-	memcpy(res1, res2, NRS_RES_MAX * sizeof(res1[0]));
-out:
-	spin_unlock(&svcpt->scp_req_lock);
-
-	/**
-	 * Release either the regular NRS head resources if we moved the
-	 * request, or the high-priority NRS head resources if we took a
-	 * reference earlier in this function and ptlrpc_nrs_req_can_move()
-	 * returned false.
-	 */
-	nrs_resource_put_safe(res1);
-}
-
-/**
  * Carries out a control operation \a opc on the policy identified by the
  * human-readable \a name, on either all partitions, or only on the first
  * partition of service \a svc.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 9402fb9..3241b1f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -94,30 +94,6 @@ int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 }
 EXPORT_SYMBOL(ptlrpc_buf_need_swab);
 
-static inline int lustre_msg_check_version_v2(struct lustre_msg_v2 *msg,
-					      __u32 version)
-{
-	__u32 ver = lustre_msg_get_version(msg);
-	return (ver & LUSTRE_VERSION_MASK) != version;
-}
-
-int lustre_msg_check_version(struct lustre_msg *msg, __u32 version)
-{
-#define LUSTRE_MSG_MAGIC_V1 0x0BD00BD0
-	switch (msg->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V1:
-		CERROR("msg v1 not supported - please upgrade you system\n");
-		return -EINVAL;
-	case LUSTRE_MSG_MAGIC_V2:
-		return lustre_msg_check_version_v2(msg, version);
-	default:
-		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
-		return 0;
-	}
-#undef LUSTRE_MSG_MAGIC_V1
-}
-EXPORT_SYMBOL(lustre_msg_check_version);
-
 /* early reply size */
 int lustre_msg_early_size(void)
 {
@@ -695,28 +671,6 @@ int lustre_msg_buflen(struct lustre_msg *m, int n)
 }
 EXPORT_SYMBOL(lustre_msg_buflen);
 
-static inline void
-lustre_msg_set_buflen_v2(struct lustre_msg_v2 *m, int n, int len)
-{
-	if (n >= m->lm_bufcount)
-		LBUG();
-
-	m->lm_buflens[n] = len;
-}
-
-void lustre_msg_set_buflen(struct lustre_msg *m, int n, int len)
-{
-	switch (m->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V2:
-		lustre_msg_set_buflen_v2(m, n, len);
-		return;
-	default:
-		LASSERTF(0, "incorrect message magic: %08x\n", m->lm_magic);
-	}
-}
-
-EXPORT_SYMBOL(lustre_msg_set_buflen);
-
 /* NB return the bufcount for lustre_msg_v2 format, so if message is packed
  * in V1 format, the result is one bigger. (add struct ptlrpc_body). */
 int lustre_msg_bufcount(struct lustre_msg *m)
@@ -958,24 +912,6 @@ __u32 lustre_msg_get_type(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_type);
 
-__u32 lustre_msg_get_version(struct lustre_msg *msg)
-{
-	switch (msg->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V2: {
-		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
-		if (!pb) {
-			CERROR("invalid msg %p: no ptlrpc body!\n", msg);
-			return 0;
-		}
-		return pb->pb_version;
-	}
-	default:
-		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
-		return 0;
-	}
-}
-EXPORT_SYMBOL(lustre_msg_get_version);
-
 void lustre_msg_add_version(struct lustre_msg *msg, int version)
 {
 	switch (msg->lm_magic) {
@@ -1010,24 +946,6 @@ __u32 lustre_msg_get_opc(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_opc);
 
-__u64 lustre_msg_get_last_xid(struct lustre_msg *msg)
-{
-	switch (msg->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V2: {
-		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
-		if (!pb) {
-			CERROR("invalid msg %p: no ptlrpc body!\n", msg);
-			return 0;
-		}
-		return pb->pb_last_xid;
-	}
-	default:
-		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
-		return 0;
-	}
-}
-EXPORT_SYMBOL(lustre_msg_get_last_xid);
-
 __u64 lustre_msg_get_last_committed(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
@@ -1243,25 +1161,6 @@ __u32 lustre_msg_get_service_time(struct lustre_msg *msg)
 	}
 }
 
-char *lustre_msg_get_jobid(struct lustre_msg *msg)
-{
-	switch (msg->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V2: {
-		struct ptlrpc_body *pb =
-			lustre_msg_buf_v2(msg, MSG_PTLRPC_BODY_OFF,
-					  sizeof(struct ptlrpc_body));
-		if (!pb)
-			return NULL;
-
-		return pb->pb_jobid;
-	}
-	default:
-		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
-		return NULL;
-	}
-}
-EXPORT_SYMBOL(lustre_msg_get_jobid);
-
 __u32 lustre_msg_get_cksum(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
@@ -1336,36 +1235,6 @@ void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc)
 }
 EXPORT_SYMBOL(lustre_msg_set_opc);
 
-void lustre_msg_set_last_xid(struct lustre_msg *msg, __u64 last_xid)
-{
-	switch (msg->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V2: {
-		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
-		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
-		pb->pb_last_xid = last_xid;
-		return;
-	}
-	default:
-		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
-	}
-}
-EXPORT_SYMBOL(lustre_msg_set_last_xid);
-
-void lustre_msg_set_last_committed(struct lustre_msg *msg, __u64 last_committed)
-{
-	switch (msg->lm_magic) {
-	case LUSTRE_MSG_MAGIC_V2: {
-		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
-		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
-		pb->pb_last_committed = last_committed;
-		return;
-	}
-	default:
-		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
-	}
-}
-EXPORT_SYMBOL(lustre_msg_set_last_committed);
-
 void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions)
 {
 	switch (msg->lm_magic) {
@@ -1509,14 +1378,6 @@ void ptlrpc_request_set_replen(struct ptlrpc_request *req)
 }
 EXPORT_SYMBOL(ptlrpc_request_set_replen);
 
-void ptlrpc_req_set_repsize(struct ptlrpc_request *req, int count, __u32 *lens)
-{
-	req->rq_replen = lustre_msg_size(req->rq_reqmsg->lm_magic, count, lens);
-	if (req->rq_reqmsg->lm_magic == LUSTRE_MSG_MAGIC_V2)
-		req->rq_reqmsg->lm_repsize = req->rq_replen;
-}
-EXPORT_SYMBOL(ptlrpc_req_set_repsize);
-
 /**
  * Send a remote set_info_async.
  *
@@ -1968,15 +1829,6 @@ void lustre_swab_idx_info(struct idx_info *ii)
 	__swab16s(&ii->ii_recsize);
 }
 
-void lustre_swab_lip_header(struct lu_idxpage *lip)
-{
-	/* swab header */
-	__swab32s(&lip->lip_magic);
-	__swab16s(&lip->lip_flags);
-	__swab16s(&lip->lip_nr);
-}
-EXPORT_SYMBOL(lustre_swab_lip_header);
-
 void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 {
 	__swab32s(&rr->rr_opcode);
@@ -2019,46 +1871,6 @@ void lustre_swab_lov_desc(struct lov_desc *ld)
 }
 EXPORT_SYMBOL(lustre_swab_lov_desc);
 
-void lustre_swab_lmv_desc(struct lmv_desc *ld)
-{
-	__swab32s(&ld->ld_tgt_count);
-	__swab32s(&ld->ld_active_tgt_count);
-	__swab32s(&ld->ld_default_stripe_count);
-	__swab32s(&ld->ld_pattern);
-	__swab64s(&ld->ld_default_hash_size);
-	__swab32s(&ld->ld_qos_maxage);
-	/* uuid endian insensitive */
-}
-
-void lustre_swab_lmv_stripe_md(struct lmv_stripe_md *mea)
-{
-	__swab32s(&mea->mea_magic);
-	__swab32s(&mea->mea_count);
-	__swab32s(&mea->mea_master);
-	CLASSERT(offsetof(typeof(*mea), mea_padding) != 0);
-}
-
-void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
-{
-	int i;
-
-	__swab32s(&lum->lum_magic);
-	__swab32s(&lum->lum_stripe_count);
-	__swab32s(&lum->lum_stripe_offset);
-	__swab32s(&lum->lum_hash_type);
-	__swab32s(&lum->lum_type);
-	CLASSERT(offsetof(typeof(*lum), lum_padding1) != 0);
-	CLASSERT(offsetof(typeof(*lum), lum_padding2) != 0);
-	CLASSERT(offsetof(typeof(*lum), lum_padding3) != 0);
-
-	for (i = 0; i < lum->lum_stripe_count; i++) {
-		__swab32s(&lum->lum_objects[i].lum_mds);
-		lustre_swab_lu_fid(&lum->lum_objects[i].lum_fid);
-	}
-
-}
-EXPORT_SYMBOL(lustre_swab_lmv_user_md);
-
 static void print_lum(struct lov_user_md *lum)
 {
 	CDEBUG(D_OTHER, "lov_user_md %p:\n", lum);
@@ -2282,7 +2094,6 @@ void dump_obdo(struct obdo *oa)
 	if (valid & OBD_MD_FLCOOKIE)
 		CDEBUG(D_RPCTRACE, "obdo: o_lcookie = (llog_cookie dumping not yet implemented)\n");
 }
-EXPORT_SYMBOL(dump_obdo);
 
 void dump_ost_body(struct ost_body *ob)
 {
@@ -2381,14 +2192,6 @@ void lustre_swab_lustre_capa(struct lustre_capa *c)
 }
 EXPORT_SYMBOL(lustre_swab_lustre_capa);
 
-void lustre_swab_lustre_capa_key(struct lustre_capa_key *k)
-{
-	__swab64s(&k->lk_seq);
-	__swab32s(&k->lk_keyid);
-	CLASSERT(offsetof(typeof(*k), lk_padding) != 0);
-}
-EXPORT_SYMBOL(lustre_swab_lustre_capa_key);
-
 void lustre_swab_hsm_user_state(struct hsm_user_state *state)
 {
 	__swab32s(&state->hus_states);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 4706174..74fab7e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -44,20 +44,10 @@
 #include "../include/obd_class.h"
 #include "ptlrpc_internal.h"
 
-static int suppress_pings;
-module_param(suppress_pings, int, 0644);
-MODULE_PARM_DESC(suppress_pings, "Suppress pings");
-
 struct mutex pinger_mutex;
 static LIST_HEAD(pinger_imports);
 static struct list_head timeout_list = LIST_HEAD_INIT(timeout_list);
 
-int ptlrpc_pinger_suppress_pings(void)
-{
-	return suppress_pings;
-}
-EXPORT_SYMBOL(ptlrpc_pinger_suppress_pings);
-
 struct ptlrpc_request *
 ptlrpc_prep_ping(struct obd_import *imp)
 {
@@ -122,11 +112,6 @@ static void ptlrpc_update_next_ping(struct obd_import *imp, int soon)
 	imp->imp_next_ping = cfs_time_shift(time);
 }
 
-void ptlrpc_ping_import_soon(struct obd_import *imp)
-{
-	imp->imp_next_ping = cfs_time_current();
-}
-
 static inline int imp_is_deactive(struct obd_import *imp)
 {
 	return (imp->imp_deactive ||
@@ -325,9 +310,6 @@ int ptlrpc_start_pinger(void)
 	l_wait_event(pinger_thread.t_ctl_waitq,
 		     thread_is_running(&pinger_thread), &lwi);
 
-	if (suppress_pings)
-		CWARN("Pings will be suppressed at the request of the administrator.  The configuration shall meet the additional requirements described in the manual.  (Search for the \"suppress_pings\" kernel module parameter.)\n");
-
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index a3608a9..ab6c458 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -137,7 +137,6 @@ ptlrpc_nrs_req_get_nolock(struct ptlrpc_service_part *svcpt, bool hp,
 	return ptlrpc_nrs_req_get_nolock0(svcpt, hp, false, force);
 }
 
-void ptlrpc_nrs_req_del_nolock(struct ptlrpc_request *req);
 bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp);
 
 int ptlrpc_nrs_policy_control(const struct ptlrpc_service *svc,
@@ -243,7 +242,6 @@ int ptlrpc_stop_pinger(void);
 void ptlrpc_pinger_sending_on_import(struct obd_import *imp);
 void ptlrpc_pinger_commit_expected(struct obd_import *imp);
 void ptlrpc_pinger_wake_up(void);
-void ptlrpc_ping_import_soon(struct obd_import *imp);
 
 /* sec_null.c */
 int  sptlrpc_null_init(void);
-- 
2.1.0
