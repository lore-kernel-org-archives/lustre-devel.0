From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:24 -0500
Subject: [lustre-devel] [PATCH 396/622] lnet: libcfs: Reduce memory frag due
 to HA debug msg
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-397-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

The dynamic allocation and freeing of Lustre trace pages has been
shown to cause memory fragmentation that sometimes prevents
applications from getting the contiguous memory they need to run. In
one such occurrence over 99% of the messages were the matched open
trace messages issued by mdc_close():

DEBUG_REQ(D_HA, mod->mod_open_req, "matched open; tag %d", tag);

D_HA is included in the default set of debug flags. This has proven
to be quite useful in debugging connection issues particularly at
mount time. So removing all HA message from the default tracing is
not a good option.

However, the matched open debug message has not proven itself to be
as generally useful. So moving the message under a different debug
flag, one that must be explicitly enabled, reduces the amount of
default tracing and thereby helps reduce fragmentation without
causing much loss of functionality. Using D_RPCTRACE to match the
corresponding open debug message in mdc_set_open_replay_data.

Cray-bug-id: LUS-7560
WC-bug-id: https://jira.whamcloud.com/browse/LU-12524
Lustre-commit: 076a5961f20b ("LU-12524 libcfs: Reduce memory frag due to HA debug msg")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/35449
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index a26efa1..7bc6196 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -937,7 +937,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 
 		mod->mod_close_req = req;
 
-		DEBUG_REQ(D_HA, mod->mod_open_req, "matched open");
+		DEBUG_REQ(D_RPCTRACE, mod->mod_open_req, "matched open");
 		/* We no longer want to preserve this open for replay even
 		 * though the open was committed. b=3632, b=3633
 		 */
-- 
1.8.3.1
