From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:48 -0400
Subject: [lustre-devel] [PATCH 10/11] staging: lustre: remove last entry of
	libcfs_netstrfns[]
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Frederic Saunier <frederic.saunier@atos.net>

Currently NID string handling test for the last entry,
and last entry has .nf_type == (__u32) -1. If we ask
for a non existent LND we hit the last entry which then
calls a strlen on a NULL which causes a error. We can
avoid this problem if we just remove the last entry
since it is not used for anything except as a last
entry marker.

Signed-off-by: Frederic Saunier <frederic.saunier@atos.net>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6501
Reviewed-on: http://review.whamcloud.com/15424
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index b7a65da..a5cd0ae 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -1101,8 +1101,6 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_match_addr*/  libcfs_num_match,
 	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
 	 /* .nf_min_max   */      cfs_num_min_max},
-	/* placeholder for net0 alias.  It MUST BE THE LAST ENTRY */
-	{/* .nf_type      */  -1},
 };
 
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
@@ -1127,8 +1125,7 @@ libcfs_namenum2netstrfns(const char *name)
 
 	for (i = 0; i < libcfs_nnetstrfns; i++) {
 		nf = &libcfs_netstrfns[i];
-		if (nf->nf_type >= 0 &&
-		    !strncmp(name, nf->nf_name, strlen(nf->nf_name)))
+		if (!strncmp(name, nf->nf_name, strlen(nf->nf_name)))
 			return nf;
 	}
 	return NULL;
@@ -1140,8 +1137,7 @@ libcfs_name2netstrfns(const char *name)
 	int    i;
 
 	for (i = 0; i < libcfs_nnetstrfns; i++)
-		if (libcfs_netstrfns[i].nf_type >= 0 &&
-		    !strcmp(libcfs_netstrfns[i].nf_name, name))
+		if (!strcmp(libcfs_netstrfns[i].nf_name, name))
 			return &libcfs_netstrfns[i];
 
 	return NULL;
@@ -1254,8 +1250,7 @@ libcfs_str2net_internal(const char *str, __u32 *net)
 
 	for (i = 0; i < libcfs_nnetstrfns; i++) {
 		nf = &libcfs_netstrfns[i];
-		if (nf->nf_type >= 0 &&
-		    !strncmp(str, nf->nf_name, strlen(nf->nf_name)))
+		if (!strncmp(str, nf->nf_name, strlen(nf->nf_name)))
 			break;
 	}
 
-- 
1.7.1
