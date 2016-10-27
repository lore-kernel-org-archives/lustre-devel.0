From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:58 -0400
Subject: [lustre-devel] [PATCH 24/29] staging: lustre: ptlrpc: Forbid too
	early NRS policy tunings
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Wait for a NRS policy to be fully started before allowing
to apply related tunings, so that all fields are properly
initialized.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6673
Reviewed-on: http://review.whamcloud.com/15104
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index d88faf6..f856632 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -619,6 +619,15 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 		goto out;
 	}
 
+	/**
+	 * Wait for the policy to be fully started before attempting
+	 * to operate it.
+	 */
+	if (policy->pol_state == NRS_POL_STATE_STARTING) {
+		rc = -EAGAIN;
+		goto out;
+	}
+
 	switch (opc) {
 		/**
 		 * Unknown opcode, pass it down to the policy-specific control
-- 
1.7.1
