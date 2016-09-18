From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:37 -0400
Subject: [lustre-devel] [PATCH 038/124] staging: lustre: osc: debug to match
	extent to brw RPC
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>, James Simmons <jsimmons@infradead.org>

From: Patrick Farrell <paf@cray.com>

Currently, it's difficult to match brw RPCs to objects and
extents from client logs.  This patch adds a D_RPCTRACE
debug message giving the necessary information.

Signed-off-by: Patrick Farrell <paf@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5531
Reviewed-on: http://review.whamcloud.com/11548
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Reviewed-by: Ann Koehler <amk@cray.com>
Reviewed-by: Ryan Haasken <haasken@cray.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_request.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 5cca2b6..d5d2963 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1419,6 +1419,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	INIT_LIST_HEAD(&aa->aa_oaps);
 
 	*reqp = req;
+	niobuf = req_capsule_client_get(pill, &RMF_NIOBUF_REMOTE);
+	CDEBUG(D_RPCTRACE, "brw rpc %p - object " DOSTID " offset %lld<>%lld\n",
+	       req, POSTID(&oa->o_oi), niobuf[0].rnb_offset,
+	       niobuf[niocount - 1].rnb_offset + niobuf[niocount - 1].rnb_len);
+
 	return 0;
 
  out:
-- 
1.7.1
