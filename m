From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:25 -0400
Subject: [lustre-devel] [PATCH 02/17] staging: lustre: clio: incorrect
	assertions in 'enable-invariants'
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Fixed several incorrect assumptions in 'enable-invariants'.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3521
Reviewed-on: http://review.whamcloud.com/6832
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_page.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 8df39ce..03aab85 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -498,7 +498,7 @@ void cl_page_disown0(const struct lu_env *env,
 
 	state = pg->cp_state;
 	PINVRNT(env, pg, state == CPS_OWNED || state == CPS_FREEING);
-	PINVRNT(env, pg, cl_page_invariant(pg));
+	PINVRNT(env, pg, cl_page_invariant(pg) || state == CPS_FREEING);
 	cl_page_owner_clear(pg);
 
 	if (state == CPS_OWNED)
@@ -670,7 +670,8 @@ EXPORT_SYMBOL(cl_page_unassume);
 void cl_page_disown(const struct lu_env *env,
 		    struct cl_io *io, struct cl_page *pg)
 {
-	PINVRNT(env, pg, cl_page_is_owned(pg, io));
+	PINVRNT(env, pg, cl_page_is_owned(pg, io) ||
+		pg->cp_state == CPS_FREEING);
 
 	io = cl_io_top(io);
 	cl_page_disown0(env, io, pg);
-- 
1.7.1
