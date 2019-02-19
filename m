From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 19/37] lustre: discard lprocfs_strnstr()
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494582.24125.9057041272800982944.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is identical to strnstr() in lib/string.h,
so just use that.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 76d298337e95..27d73c95403d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1552,22 +1552,6 @@ int lprocfs_write_frac_u64_helper(const char __user *buffer,
 }
 EXPORT_SYMBOL(lprocfs_write_frac_u64_helper);
 
-static char *lprocfs_strnstr(const char *s1, const char *s2, size_t len)
-{
-	size_t l2;
-
-	l2 = strlen(s2);
-	if (!l2)
-		return (char *)s1;
-	while (len >= l2) {
-		len--;
-		if (!memcmp(s1, s2, l2))
-			return (char *)s1;
-		s1++;
-	}
-	return NULL;
-}
-
 /**
  * Find the string \a name in the input \a buffer, and return a pointer to the
  * value immediately following \a name, reducing \a count appropriately.
@@ -1579,8 +1563,7 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 	char *val;
 	size_t buflen = *count;
 
-	/* there is no strnstr() in rhel5 and ubuntu kernels */
-	val = lprocfs_strnstr(buffer, name, buflen);
+	val = strnstr(buffer, name, buflen);
 	if (!val)
 		return (char *)buffer;
 
