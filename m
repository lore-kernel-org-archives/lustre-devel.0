From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:32 -0400
Subject: [lustre-devel] [PATCH 2/8] staging: lustre: echo: remove
	echo_env_info() regions from echo_client.c
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

This function declartion is not needed so remove it.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/5580
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index b271895..1225944 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -163,8 +163,6 @@ static int cl_echo_object_put(struct echo_object *eco);
 static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 			      struct page **pages, int npages, int async);
 
-static struct echo_thread_info *echo_env_info(const struct lu_env *env);
-
 struct echo_thread_info {
 	struct echo_object_conf eti_conf;
 	struct lustre_md	eti_md;
-- 
2.7.4
