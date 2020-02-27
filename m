From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:57 -0500
Subject: [lustre-devel] [PATCH 549/622] lustre: obdclass: Allow read-ahead
 for write requests
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-550-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

cl_io_read_ahead asserts that read-ahead can only happen
due to CIT_READ or CIT_FAULT requests.
Since LU-9618, we expect CIT_WRITE requests to also
sometimes trigger read-ahead.
So the LINVRNT() needs to be extended to acknowledge
that.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12718
Lustre-commit: 514bd936d061 ("LU-12718 obdclass: Allow read-ahead for write requests")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36000
Reviewed-by: Shilong Wang <wshilong@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 14849ed..3bc9097 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -554,7 +554,9 @@ int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 	const struct cl_io_slice *scan;
 	int result = 0;
 
-	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_FAULT);
+	LINVRNT(io->ci_type == CIT_READ ||
+		io->ci_type == CIT_FAULT ||
+		io->ci_type == CIT_WRITE);
 	LINVRNT(cl_io_invariant(io));
 
 	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
-- 
1.8.3.1
