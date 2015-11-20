From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:37 -0500
Subject: [lustre-devel] [PATCH 01/40] staging: lustre: drop *_t from end of
	struct lnet_text_buf
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When lnet_text_buf data structure was transform from typedef
to struct the *_t which is typical of typedef was not drop.
This patch removes the *_t to be consistent.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/config.c |   57 ++++++++++++++---------------
 1 files changed, 27 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 5390ee9..867c96e 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include "../../include/linux/lnet/lib-lnet.h"
 
-struct lnet_text_buf_t {	    /* tmp struct for parsing routes */
+struct lnet_text_buf {	    /* tmp struct for parsing routes */
 	struct list_head ltb_list;	/* stash on lists */
 	int ltb_size;	/* allocated size */
 	char ltb_text[0];     /* text buffer */
@@ -365,14 +365,14 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	return -EINVAL;
 }
 
-static struct lnet_text_buf_t *
+static struct lnet_text_buf *
 lnet_new_text_buf(int str_len)
 {
-	struct lnet_text_buf_t *ltb;
+	struct lnet_text_buf *ltb;
 	int nob;
 
 	/* NB allocate space for the terminating 0 */
-	nob = offsetof(struct lnet_text_buf_t, ltb_text[str_len + 1]);
+	nob = offsetof(struct lnet_text_buf, ltb_text[str_len + 1]);
 	if (nob > LNET_SINGLE_TEXTBUF_NOB) {
 		/* _way_ conservative for "route net gateway..." */
 		CERROR("text buffer too big\n");
@@ -395,7 +395,7 @@ lnet_new_text_buf(int str_len)
 }
 
 static void
-lnet_free_text_buf(struct lnet_text_buf_t *ltb)
+lnet_free_text_buf(struct lnet_text_buf *ltb)
 {
 	lnet_tbnob -= ltb->ltb_size;
 	LIBCFS_FREE(ltb, ltb->ltb_size);
@@ -404,10 +404,10 @@ lnet_free_text_buf(struct lnet_text_buf_t *ltb)
 static void
 lnet_free_text_bufs(struct list_head *tbs)
 {
-	struct lnet_text_buf_t *ltb;
+	struct lnet_text_buf *ltb;
 
 	while (!list_empty(tbs)) {
-		ltb = list_entry(tbs->next, struct lnet_text_buf_t, ltb_list);
+		ltb = list_entry(tbs->next, struct lnet_text_buf, ltb_list);
 
 		list_del(&ltb->ltb_list);
 		lnet_free_text_buf(ltb);
@@ -421,7 +421,7 @@ lnet_str2tbs_sep(struct list_head *tbs, char *str)
 	char *sep;
 	int nob;
 	int i;
-	struct lnet_text_buf_t *ltb;
+	struct lnet_text_buf *ltb;
 
 	INIT_LIST_HEAD(&pending);
 
@@ -479,7 +479,7 @@ lnet_expand1tb(struct list_head *list,
 {
 	int len1 = (int)(sep1 - str);
 	int len2 = strlen(sep2 + 1);
-	struct lnet_text_buf_t *ltb;
+	struct lnet_text_buf *ltb;
 
 	LASSERT(*sep1 == '[');
 	LASSERT(*sep2 == ']');
@@ -636,7 +636,7 @@ lnet_parse_route(char *str, int *im_a_router)
 	struct list_head *tmp2;
 	__u32 net;
 	lnet_nid_t nid;
-	struct lnet_text_buf_t *ltb;
+	struct lnet_text_buf *ltb;
 	int rc;
 	char *sep;
 	char *token = str;
@@ -692,8 +692,7 @@ lnet_parse_route(char *str, int *im_a_router)
 		list_add_tail(tmp1, tmp2);
 
 		while (tmp1 != tmp2) {
-			ltb = list_entry(tmp1, struct lnet_text_buf_t,
-					 ltb_list);
+			ltb = list_entry(tmp1, struct lnet_text_buf, ltb_list);
 
 			rc = lnet_str2tbs_expand(tmp1->next, ltb->ltb_text);
 			if (rc < 0)
@@ -733,13 +732,12 @@ lnet_parse_route(char *str, int *im_a_router)
 	LASSERT(!list_empty(&gateways));
 
 	list_for_each(tmp1, &nets) {
-		ltb = list_entry(tmp1, struct lnet_text_buf_t, ltb_list);
+		ltb = list_entry(tmp1, struct lnet_text_buf, ltb_list);
 		net = libcfs_str2net(ltb->ltb_text);
 		LASSERT(net != LNET_NIDNET(LNET_NID_ANY));
 
 		list_for_each(tmp2, &gateways) {
-			ltb = list_entry(tmp2, struct lnet_text_buf_t,
-					 ltb_list);
+			ltb = list_entry(tmp2, struct lnet_text_buf, ltb_list);
 			nid = libcfs_str2nid(ltb->ltb_text);
 			LASSERT(nid != LNET_NID_ANY);
 
@@ -772,10 +770,10 @@ lnet_parse_route(char *str, int *im_a_router)
 static int
 lnet_parse_route_tbs(struct list_head *tbs, int *im_a_router)
 {
-	struct lnet_text_buf_t *ltb;
+	struct lnet_text_buf *ltb;
 
 	while (!list_empty(tbs)) {
-		ltb = list_entry(tbs->next, struct lnet_text_buf_t, ltb_list);
+		ltb = list_entry(tbs->next, struct lnet_text_buf, ltb_list);
 
 		if (lnet_parse_route(ltb->ltb_text, im_a_router) < 0) {
 			lnet_free_text_bufs(tbs);
@@ -909,8 +907,8 @@ lnet_splitnets(char *source, struct list_head *nets)
 	int offset = 0;
 	int offset2;
 	int len;
-	struct lnet_text_buf_t *tb;
-	struct lnet_text_buf_t *tb2;
+	struct lnet_text_buf *tb;
+	struct lnet_text_buf *tb2;
 	struct list_head *t;
 	char *sep;
 	char *bracket;
@@ -919,7 +917,7 @@ lnet_splitnets(char *source, struct list_head *nets)
 	LASSERT(!list_empty(nets));
 	LASSERT(nets->next == nets->prev);     /* single entry */
 
-	tb = list_entry(nets->next, struct lnet_text_buf_t, ltb_list);
+	tb = list_entry(nets->next, struct lnet_text_buf, ltb_list);
 
 	for (;;) {
 		sep = strchr(tb->ltb_text, ',');
@@ -955,7 +953,7 @@ lnet_splitnets(char *source, struct list_head *nets)
 		}
 
 		list_for_each(t, nets) {
-			tb2 = list_entry(t, struct lnet_text_buf_t, ltb_list);
+			tb2 = list_entry(t, struct lnet_text_buf, ltb_list);
 
 			if (tb2 == tb)
 				continue;
@@ -996,8 +994,8 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 	struct list_head current_nets;
 	struct list_head *t;
 	struct list_head *t2;
-	struct lnet_text_buf_t *tb;
-	struct lnet_text_buf_t *tb2;
+	struct lnet_text_buf *tb;
+	struct lnet_text_buf *tb2;
 	__u32 net1;
 	__u32 net2;
 	int len;
@@ -1020,9 +1018,8 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 	rc = 0;
 
 	while (!list_empty(&raw_entries)) {
-		tb = list_entry(raw_entries.next, struct lnet_text_buf_t,
-				    ltb_list);
-
+		tb = list_entry(raw_entries.next, struct lnet_text_buf,
+				ltb_list);
 		strncpy(source, tb->ltb_text, sizeof(source));
 		source[sizeof(source)-1] = '\0';
 
@@ -1047,13 +1044,13 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 
 		dup = 0;
 		list_for_each(t, &current_nets) {
-			tb = list_entry(t, struct lnet_text_buf_t, ltb_list);
+			tb = list_entry(t, struct lnet_text_buf, ltb_list);
 			net1 = lnet_netspec2net(tb->ltb_text);
 			LASSERT(net1 != LNET_NIDNET(LNET_NID_ANY));
 
 			list_for_each(t2, &matched_nets) {
-				tb2 = list_entry(t2, struct lnet_text_buf_t,
-						     ltb_list);
+				tb2 = list_entry(t2, struct lnet_text_buf,
+						 ltb_list);
 				net2 = lnet_netspec2net(tb2->ltb_text);
 				LASSERT(net2 != LNET_NIDNET(LNET_NID_ANY));
 
@@ -1073,7 +1070,7 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 		}
 
 		list_for_each_safe(t, t2, &current_nets) {
-			tb = list_entry(t, struct lnet_text_buf_t, ltb_list);
+			tb = list_entry(t, struct lnet_text_buf, ltb_list);
 
 			list_del(&tb->ltb_list);
 			list_add_tail(&tb->ltb_list, &matched_nets);
-- 
1.7.1
