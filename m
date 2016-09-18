From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:19 -0400
Subject: [lustre-devel] [PATCH 080/124] staging: lustre: llite: fix dup
	flags names
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-81-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bob Glossman <bob.glossman@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bob Glossman <bob.glossman@intel.com>

The name 'xattr' is used for two different ll_flags bits.
Change the names to be distinct and different, reflecting
the names of the bits used in LL_SBI_xbitnamex #defines.

Signed-off-by: Bob Glossman <bob.glossman@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5586
Reviewed-on: http://review.whamcloud.com/12892
Reviewed-by: Minh Diep <minh.diep@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 0dc47f2..05f2aa3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -407,7 +407,7 @@ enum stats_track_type {
 	"nolck",	\
 	"checksum",	\
 	"flock",	\
-	"xattr",	\
+	"user_xattr",	\
 	"acl",		\
 	"???",		\
 	"???",		\
@@ -423,7 +423,7 @@ enum stats_track_type {
 	"verbose",	\
 	"layout",	\
 	"user_fid2path",\
-	"xattr",	\
+	"xattr_cache",	\
 	"norootsquash",	\
 }
 
-- 
1.7.1
