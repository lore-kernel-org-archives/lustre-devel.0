From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 19:28:22 -0400
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: white space cleanups
	for nidstring.c
In-Reply-To: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
References: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446161303-798-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the remaining white spaces in nidstring.c.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index ee04c3b..7df8599 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -799,11 +799,11 @@ libcfs_ip_addr2str(__u32 addr, char *str, size_t size)
 static int
 libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 {
-	unsigned int	a;
-	unsigned int	b;
-	unsigned int	c;
-	unsigned int	d;
-	int		n = nob; /* XscanfX */
+	unsigned int a;
+	unsigned int b;
+	unsigned int c;
+	unsigned int d;
+	int n = nob; /* XscanfX */
 
 	/* numeric IP? */
 	if (sscanf(str, "%u.%u.%u.%u%n", &a, &b, &c, &d, &n) >= 4 &&
@@ -902,7 +902,7 @@ libcfs_decnum_addr2str(__u32 addr, char *str, size_t size)
 static int
 libcfs_num_str2addr(const char *str, int nob, __u32 *addr)
 {
-	int     n;
+	int n;
 
 	n = nob;
 	if (sscanf(str, "0x%x%n", addr, &n) >= 1 && n == nob)
@@ -931,7 +931,7 @@ static int
 libcfs_num_parse(char *str, int len, struct list_head *list)
 {
 	struct cfs_expr_list *el;
-	int	rc;
+	int rc;
 
 	rc = cfs_expr_list_parse(str, len, 0, MAX_NUMERIC_VALUE, &el);
 	if (rc == 0)
@@ -1054,7 +1054,7 @@ libcfs_namenum2netstrfns(const char *name)
 static struct netstrfns *
 libcfs_name2netstrfns(const char *name)
 {
-	int    i;
+	int i;
 
 	for (i = 0; i < libcfs_nnetstrfns; i++)
 		if (!strcmp(libcfs_netstrfns[i].nf_name, name))
@@ -1201,7 +1201,7 @@ libcfs_str2net_internal(const char *str, __u32 *net)
 __u32
 libcfs_str2net(const char *str)
 {
-	__u32  net;
+	__u32 net;
 
 	if (libcfs_str2net_internal(str, &net))
 		return net;
-- 
1.7.1
