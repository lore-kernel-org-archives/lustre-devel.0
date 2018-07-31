From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:23 -0400
Subject: [lustre-devel] [PATCH 31/31] lustre: docs: update TODO file
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With several bugs fixed we can remove them from the TODO file.
Also update several email addresses.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/TODO | 51 ++++-----------------------------------------
 1 file changed, 4 insertions(+), 47 deletions(-)

diff --git a/drivers/staging/lustre/TODO b/drivers/staging/lustre/TODO
index 5332cdb..942280b 100644
--- a/drivers/staging/lustre/TODO
+++ b/drivers/staging/lustre/TODO
@@ -17,10 +17,6 @@ addressed:
 *
 ******************************************************************************
 
-https://jira.hpdd.intel.com/browse/LU-100086
-
-LNET_MINOR conflicts with USERIO_MINOR
-
 ------------------------------------------------------------------------------
 
 https://jira.hpdd.intel.com/browse/LU-8130
@@ -29,14 +25,6 @@ Fix and simplify libcfs hash handling
 
 ------------------------------------------------------------------------------
 
-https://jira.hpdd.intel.com/browse/LU-8703
-
-The current way we handle SMP is wrong. Platforms like ARM and KNL can have
-core and NUMA setups with things like NUMA nodes with no cores. We need to
-handle such cases. This work also greatly simplified the lustre SMP code.
-
-------------------------------------------------------------------------------
-
 https://jira.hpdd.intel.com/browse/LU-9019
 
 Replace libcfs time API with standard kernel APIs. Also migrate away from
@@ -53,14 +41,9 @@ Poor performance for the ko2iblnd driver. This is related to many of the
 patches below that are missing from the linux client.
 ------------------------------------------------------------------------------
 
-https://jira.hpdd.intel.com/browse/LU-9886
-
-Crash in upstream kiblnd_handle_early_rxs()
-------------------------------------------------------------------------------
-
 https://jira.hpdd.intel.com/browse/LU-10394 / LU-10526 / LU-10089
 
-Default to default to using MEM_REG
+Default to using MEM_REG
 ------------------------------------------------------------------------------
 
 https://jira.hpdd.intel.com/browse/LU-10459
@@ -98,11 +81,6 @@ https://jira.hpdd.intel.com/browse/LU-10129
 query device capabilities
 ------------------------------------------------------------------------------
 
-https://jira.hpdd.intel.com/browse/LU-10015
-
-fix race at kiblnd_connect_peer
-------------------------------------------------------------------------------
-
 https://jira.hpdd.intel.com/browse/LU-9983
 
 allow for discontiguous fragments
@@ -123,21 +101,11 @@ https://jira.hpdd.intel.com/browse/LU-9507
 Don't Assert On Reconnect with MultiQP
 ------------------------------------------------------------------------------
 
-https://jira.hpdd.intel.com/browse/LU-9472
-
-Fix FastReg map/unmap for MLX5
-------------------------------------------------------------------------------
-
 https://jira.hpdd.intel.com/browse/LU-9425
 
 Turn on 2 sges by default
 ------------------------------------------------------------------------------
 
-https://jira.hpdd.intel.com/browse/LU-8943
-
-Enable Multiple OPA Endpoints between Nodes
-------------------------------------------------------------------------------
-
 https://jira.hpdd.intel.com/browse/LU-5718
 
 multiple sges for work request
@@ -286,17 +254,6 @@ https://jira.hpdd.intel.com/browse/LU-9862
 Patch that landed for LU-7890 leads to static checker errors
 ------------------------------------------------------------------------------
 
-https://jira.hpdd.intel.com/browse/LU-9868
-
-dcache/namei fixes for lustre
-------------------------------------------------------------------------------
-
-https://jira.hpdd.intel.com/browse/LU-10467
-
-use standard linux wait_events macros work by Neil Brown
-
-------------------------------------------------------------------------------
-
-Please send any patches to Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger
-<andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org> and
-Oleg Drokin <oleg.drokin@intel.com>.
+Please send any patches to NeilBrown <neilb@suse.com>, Andreas Dilger
+<adilger@whamcloud.com>, James Simmons <jsimmons@infradead.org> and
+Oleg Drokin <green@whamcloud.com>.
-- 
1.8.3.1
