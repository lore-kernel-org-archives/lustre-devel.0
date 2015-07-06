From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 6 Jul 2015 20:36:55 +0000
Subject: [lustre-devel] [PATCH] staging/lustre: Remove unused
 MDS_CLOSE_CLEANUP define
In-Reply-To: <20150706183019.GA6127@lusbld01.us.cray.com>
References: <20150706183019.GA6127@lusbld01.us.cray.com>
Message-ID: <D1C040DE.FBD49%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The character between "unused" and "MDS" in the patch summary line appears
to be a tab instead of a space.

On 2015/07/06, 12:30 PM, "Ben Evans" <bevans@cray.com> wrote:

>Previously, MDS_CLOSE_CLEANUP was used to detect file closing, due to
>eviction.
>This flag is no longer used.
>
>Signed-off-by: Aurelien Degremont <aurelien.degremont@cea.fr>
>Intel-bug-ID: http://jira.hpdd.intel.com/browse/LU-3677
>Reviewed-on: http://review.whamcloud.com/7195
>Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
>Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
>Reviewed-by: John L. Hammond <john.hammond@intel.com>
>Reviewed-by: Fan Yong <fan.yong@intel.com>
>Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
>Signed-off-by: Ben Evans <bevans@cray.com>
>---
> .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>index 4d72d6e..14547d1 100644
>--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>@@ -2390,7 +2390,7 @@ enum mds_op_bias {
> 	MDS_PERM_BYPASS		= 1 << 3,
> 	MDS_SOM			= 1 << 4,
> 	MDS_QUOTA_IGNORE	= 1 << 5,
>-	MDS_CLOSE_CLEANUP	= 1 << 6,
>+	/* MDS_UNUSED	= 1 << 6, */

When wire protocol definess are removed, it is better to use something
like:

        /* MDS_CLOSE_CLEANUP = 1 << 6, obsolete since 2.4.0 */

The version is from "git describe 5165cdd" from the original commit.

> 	MDS_KEEP_ORPHAN		= 1 << 7,
> 	MDS_RECOV_OPEN		= 1 << 8,
> 	MDS_DATA_MODIFIED	= 1 << 9,

I think after these changes you could add the upstream maintainers to the
"To:" and "CC:" so that the patch can be accepted upstream.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
