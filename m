From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:57 -0400
Subject: [lustre-devel] [PATCH 20/45] lustre: misc: declare static chars as
 const where possible.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

When a char * is statically initialized to a literal string, it is
best if the char is declared 'const' to ensure that literal string can
never be changed, and to allow it to be stored in read-only memory.

Unfortunately this is not possible for strings used as module
parameters.  Similarly osd_0copy_tag in osd-zfs cannot be made const,
so that is change to a simple array (no pointer).

But in many other places it is possible, and it requires all ultimate
users of the string to declare that they are working with const chars.

This patch changes a collection of static char*s to const, and in many
cases arrays of char * to "const char * const", and then propagates
the 'const' annotion as needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 257c0debc71ed ("LU-6142 misc: declare static chars as const where possible.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38421
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h   |  4 ++--
 fs/lustre/obdclass/lprocfs_status.c |  2 +-
 include/linux/lnet/lib-lnet.h       |  6 +++---
 net/lnet/lnet/api-ni.c              | 10 +++++-----
 net/lnet/lnet/config.c              | 13 +++++++------
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 8db51e8..4e9a228 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -112,9 +112,9 @@ enum lustre_imp_state {
 };
 
 /** Returns test string representation of numeric import state @state */
-static inline char *ptlrpc_import_state_name(enum lustre_imp_state state)
+static inline const char *ptlrpc_import_state_name(enum lustre_imp_state state)
 {
-	static char *import_state_names[] = {
+	static const char * const import_state_names[] = {
 		"<UNKNOWN>", "CLOSED",  "NEW", "DISCONN",
 		"CONNECTING", "REPLAY", "REPLAY_LOCKS", "REPLAY_WAIT",
 		"RECOVER", "FULL", "EVICTED", "IDLE",
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 5f94669..aba04d5 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -597,7 +597,7 @@ int lprocfs_rd_server_uuid(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
 	struct obd_import *imp;
-	char *imp_state_name = NULL;
+	const char *imp_state_name = NULL;
 	int rc;
 
 	LASSERT(obd);
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 03ac3f9..01e8489 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -718,9 +718,9 @@ int lnet_push_target_post(struct lnet_ping_buffer *pbuf,
 			  struct lnet_handle_md *mdh);
 void lnet_peer_push_event(struct lnet_event *ev);
 
-int lnet_parse_ip2nets(char **networksp, char *ip2nets);
-int lnet_parse_routes(char *route_str, int *im_a_router);
-int lnet_parse_networks(struct list_head *nilist, char *networks,
+int lnet_parse_ip2nets(const char **networksp, const char *ip2nets);
+int lnet_parse_routes(const char *route_str, int *im_a_router);
+int lnet_parse_networks(struct list_head *nilist, const char *networks,
 			bool use_tcp_bonding);
 bool lnet_net_unique(u32 net_id, struct list_head *nilist,
 		     struct lnet_net **net);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index b0f2a62..e2c364b 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -472,16 +472,16 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	return 0;
 }
 
-static char *
+static const char *
 lnet_get_routes(void)
 {
 	return routes;
 }
 
-static char *
+static const char *
 lnet_get_networks(void)
 {
-	char *nets;
+	const char *nets;
 	int rc;
 
 	if (*networks && *ip2nets) {
@@ -3101,7 +3101,7 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
 				      struct lnet_ioctl_config_lnd_tunables *tun)
 {
 	struct lnet_net *net;
-	char *nets;
+	const char *nets;
 	int rc;
 	LIST_HEAD(net_head);
 
@@ -3286,7 +3286,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	LIST_HEAD(net_head);
 	int rc;
 	struct lnet_ioctl_config_lnd_tunables tun;
-	char *nets = conf->cfg_config_u.cfg_net.net_intf;
+	const char *nets = conf->cfg_config_u.cfg_net.net_intf;
 
 	/* Create a net/ni structures for the network string */
 	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index d120dab..3fc0298 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -568,7 +568,7 @@ struct lnet_ni *
  * nilist.
  */
 int
-lnet_parse_networks(struct list_head *netlist, char *networks,
+lnet_parse_networks(struct list_head *netlist, const char *networks,
 		    bool use_tcp_bonding)
 {
 	struct cfs_expr_list *net_el = NULL;
@@ -887,10 +887,10 @@ struct lnet_ni *
 }
 
 static int
-lnet_str2tbs_sep(struct list_head *tbs, char *str)
+lnet_str2tbs_sep(struct list_head *tbs, const char *str)
 {
 	LIST_HEAD(pending);
-	char *sep;
+	const char *sep;
 	int nob;
 	int i;
 	struct lnet_text_buf *ltb;
@@ -1250,7 +1250,7 @@ struct lnet_ni *
 }
 
 int
-lnet_parse_routes(char *routes, int *im_a_router)
+lnet_parse_routes(const char *routes, int *im_a_router)
 {
 	LIST_HEAD(tbs);
 	int rc = 0;
@@ -1439,7 +1439,8 @@ struct lnet_ni *
 }
 
 static int
-lnet_match_networks(char **networksp, char *ip2nets, u32 *ipaddrs, int nip)
+lnet_match_networks(const char **networksp, const char *ip2nets,
+		    u32 *ipaddrs, int nip)
 {
 	static char networks[LNET_SINGLE_TEXTBUF_NOB];
 	static char source[LNET_SINGLE_TEXTBUF_NOB];
@@ -1620,7 +1621,7 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 EXPORT_SYMBOL(lnet_inet_enumerate);
 
 int
-lnet_parse_ip2nets(char **networksp, char *ip2nets)
+lnet_parse_ip2nets(const char **networksp, const char *ip2nets)
 {
 	struct lnet_inetdev *ifaces = NULL;
 	u32 *ipaddrs = NULL;
-- 
1.8.3.1
