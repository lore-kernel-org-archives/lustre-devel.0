From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Fri, 30 Dec 2016 01:32:13 +0530
Subject: [lustre-devel] [PATCH] staging:lustre:remove braces from
	single-line body
Message-ID: <1483041733-10362-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Remove unnecessary braces from single line if statement.
This warning is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 505582f..3050fa7 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1694,9 +1694,9 @@ static int echo_client_connect(const struct lu_env *env,
 	struct lustre_handle conn = { 0 };
 
 	rc = class_connect(&conn, src, cluuid);
-	if (rc == 0) {
+	if (rc == 0)
 		*exp = class_conn2export(&conn);
-	}
+
 
 	return rc;
 }
-- 
2.7.4
