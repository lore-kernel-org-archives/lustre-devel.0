From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 11:34:59 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: export cfs_str2mask
In-Reply-To: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447000500-29427-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We need cfs_str2mask exported for our server code.
Even with the server code not available upstream
it would be nice to use the upstream code on Lustre
servers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index d40be53..05630f8 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -111,6 +111,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 	*oldmask = newmask;
 	return 0;
 }
+EXPORT_SYMBOL(cfs_str2mask);
 
 /* get the first string out of @str */
 char *cfs_firststr(char *str, size_t size)
-- 
1.7.1
