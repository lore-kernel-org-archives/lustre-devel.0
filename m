From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:28 -0500
Subject: [lustre-devel] [PATCH 12/12] lustre: update TODO lustre list
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many of the items in TODO have been completed so remove them from
the list.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/TODO | 85 ---------------------------------------------
 1 file changed, 85 deletions(-)

diff --git a/drivers/staging/lustre/TODO b/drivers/staging/lustre/TODO
index 942280b..1df7697 100644
--- a/drivers/staging/lustre/TODO
+++ b/drivers/staging/lustre/TODO
@@ -35,91 +35,6 @@ So move to time64_t and ktime_t as much as possible.
 ******************************************************************************
 * Proper IB support for ko2iblnd
 ******************************************************************************
-https://jira.hpdd.intel.com/browse/LU-9179
-
-Poor performance for the ko2iblnd driver. This is related to many of the
-patches below that are missing from the linux client.
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10394 / LU-10526 / LU-10089
-
-Default to using MEM_REG
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10459
-
-throttle tx based on queue depth
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9943
-
-correct WR fast reg accounting
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10291
-
-remove concurrent_sends tunable
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10213
-
-calculate qp max_send_wrs properly
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9810
-
-use less CQ entries for each connection
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10129 / LU-9180
-
-rework map_on_demand behavior
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10129
-
-query device capabilities
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9983
-
-allow for discontiguous fragments
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9500
-
-Don't Page Align remote_addr with FastReg
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9448
-
-handle empty CPTs
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9507
-
-Don't Assert On Reconnect with MultiQP
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9425
-
-Turn on 2 sges by default
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-5718
-
-multiple sges for work request
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9094
-
-kill timedout txs from ibp_tx_queue
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-9094
-
-reconnect peer for REJ_INVALID_SERVICE_ID
-------------------------------------------------------------------------------
 
 https://jira.hpdd.intel.com/browse/LU-8752
 
-- 
1.8.3.1
