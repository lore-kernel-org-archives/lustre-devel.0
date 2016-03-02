From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:51 -0500
Subject: [lustre-devel] [PATCH 08/27] staging: lustre: fix 'copy into fixed
	size buffer' errors
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sebastien.buisson@bull.net>

From: Sebastien Buisson <sebastien.buisson@bull.net>

Fix 'copy into fixed size buffer' defects found by Coverity
version 6.0.3:
Copy into fixed size buffer (STRING_OVERFLOW)
The fixed-size string might be overrun by copying without
checking the length.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2074
Reviewed-on: http://review.whamcloud.com/4154
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c     |   15 +++++++++++--
 drivers/staging/lustre/lnet/selftest/console.c    |   23 +++++++++++++++++---
 drivers/staging/lustre/lustre/libcfs/workitem.c   |    6 ++++-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c        |    8 ++++++-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c |    7 +++++-
 5 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 88905d5..5d77049 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -99,7 +99,10 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 
 	CLASSERT(sizeof(ifr.ifr_name) >= IFNAMSIZ);
 
-	strcpy(ifr.ifr_name, name);
+	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
+		return -E2BIG;
+	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
+
 	rc = lnet_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
 	if (rc) {
 		CERROR("Can't get flags for interface %s\n", name);
@@ -114,7 +117,10 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 	}
 	*up = 1;
 
-	strcpy(ifr.ifr_name, name);
+	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
+		return -E2BIG;
+	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
+
 	ifr.ifr_addr.sa_family = AF_INET;
 	rc = lnet_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
 	if (rc) {
@@ -125,7 +131,10 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 	val = ((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr.s_addr;
 	*ip = ntohl(val);
 
-	strcpy(ifr.ifr_name, name);
+	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
+		return -E2BIG;
+	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
+
 	ifr.ifr_addr.sa_family = AF_INET;
 	rc = lnet_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
 	if (rc) {
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index e8ca1bf..0e3da44 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -206,8 +206,14 @@ lstcon_group_alloc(char *name, lstcon_group_t **grpp)
 		return -ENOMEM;
 
 	grp->grp_ref = 1;
-	if (name)
-		strcpy(grp->grp_name, name);
+	if (name) {
+		if (strlen(name) > sizeof(grp->grp_name)-1) {
+			LIBCFS_FREE(grp, offsetof(lstcon_group_t,
+				    grp_ndl_hash[LST_NODE_HASHSIZE]));
+			return -E2BIG;
+		}
+		strncpy(grp->grp_name, name, sizeof(grp->grp_name));
+	}
 
 	INIT_LIST_HEAD(&grp->grp_link);
 	INIT_LIST_HEAD(&grp->grp_ndl_list);
@@ -873,7 +879,13 @@ lstcon_batch_add(char *name)
 		return -ENOMEM;
 	}
 
-	strcpy(bat->bat_name, name);
+	if (strlen(name) > sizeof(bat->bat_name) - 1) {
+		LIBCFS_FREE(bat->bat_srv_hash, LST_NODE_HASHSIZE);
+		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
+		LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
+		return -E2BIG;
+	}
+	strncpy(bat->bat_name, name, sizeof(bat->bat_name));
 	bat->bat_hdr.tsb_index = 0;
 	bat->bat_hdr.tsb_id.bat_id = ++console_session.ses_id_cookie;
 
@@ -1733,7 +1745,10 @@ lstcon_session_new(char *name, int key, unsigned feats,
 	console_session.ses_feats_updated = 0;
 	console_session.ses_timeout = (timeout <= 0) ?
 				      LST_CONSOLE_TIMEOUT : timeout;
-	strlcpy(console_session.ses_name, name,
+
+	if (strlen(name) > sizeof(console_session.ses_name)-1)
+		return -E2BIG;
+	strncpy(console_session.ses_name, name,
 		sizeof(console_session.ses_name));
 
 	rc = lstcon_batch_add(LST_DEFAULT_BATCH);
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index 136bc13..f2ebed8 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -351,7 +351,11 @@ cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab,
 	if (!sched)
 		return -ENOMEM;
 
-	strlcpy(sched->ws_name, name, CFS_WS_NAME_LEN);
+	if (strlen(name) > sizeof(sched->ws_name) - 1) {
+		LIBCFS_FREE(sched, sizeof(*sched));
+		return -E2BIG;
+	}
+	strncpy(sched->ws_name, name, sizeof(sched->ws_name));
 
 	sched->ws_cptab = cptab;
 	sched->ws_cpt = cpt;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 58e5d86..cc7909c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -1095,6 +1095,7 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 {
 	struct ptlrpc_service *svc;
 	struct ptlrpc_nrs_pol_desc *desc;
+	size_t len;
 	int rc = 0;
 
 	LASSERT(conf->nc_ops);
@@ -1138,7 +1139,12 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 		goto fail;
 	}
 
-	strncpy(desc->pd_name, conf->nc_name, NRS_POL_NAME_MAX);
+	len = strlcpy(desc->pd_name, conf->nc_name, sizeof(desc->pd_name));
+	if (len >= sizeof(desc->pd_name)) {
+		kfree(desc);
+		rc = -E2BIG;
+		goto fail;
+	}
 	desc->pd_ops = conf->nc_ops;
 	desc->pd_compat = conf->nc_compat;
 	desc->pd_compat_svc_name = conf->nc_compat_svc_name;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 93b91bf..31d3be7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -517,6 +517,7 @@ struct sptlrpc_conf *sptlrpc_conf_get(const char *fsname,
 				      int create)
 {
 	struct sptlrpc_conf *conf;
+	size_t len;
 
 	list_for_each_entry(conf, &sptlrpc_confs, sc_list) {
 		if (strcmp(conf->sc_fsname, fsname) == 0)
@@ -530,7 +531,11 @@ struct sptlrpc_conf *sptlrpc_conf_get(const char *fsname,
 	if (!conf)
 		return NULL;
 
-	strcpy(conf->sc_fsname, fsname);
+	len = strlcpy(conf->sc_fsname, fsname, sizeof(conf->sc_fsname));
+	if (len >= sizeof(conf->sc_fsname)) {
+		kfree(conf);
+		return NULL;
+	}
 	sptlrpc_rule_set_init(&conf->sc_rset);
 	INIT_LIST_HEAD(&conf->sc_tgts);
 	list_add(&conf->sc_list, &sptlrpc_confs);
-- 
1.7.1
