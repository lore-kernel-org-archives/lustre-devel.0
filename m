From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:20 -0400
Subject: [lustre-devel] [PATCH 04/20] staging: lustre: lov: fix 'control
	flow' error in lov_io_init_released
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix "control flow" issues found by Coverity version 6.6.1:
Logically dead code (DEADCODE)
Execution cannot reach this statement.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4048
Reviewed-on: http://review.whamcloud.com/7824
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_io.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index babf39a..3e37353 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -1047,6 +1047,8 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 	switch (io->ci_type) {
 	default:
 		LASSERTF(0, "invalid type %d\n", io->ci_type);
+		result = -EOPNOTSUPP;
+		break;
 	case CIT_MISC:
 	case CIT_FSYNC:
 	case CIT_DATA_VERSION:
-- 
1.8.3.1
