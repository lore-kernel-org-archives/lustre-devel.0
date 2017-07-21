From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Fri, 21 Jul 2017 11:11:37 +0530
Subject: [lustre-devel] [PATCH v2 2/3] staging: lustre: ldlm: constify
	attribute_group structures.
In-Reply-To: <1500615698-21001-1-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500615698-21001-1-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <1500615698-21001-3-git-send-email-arvind.yadav.cs@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, di.wang@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              patch was sent to wrong group.

 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index fff930f..e0c3e5d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -926,7 +926,7 @@ static ssize_t cancel_unused_locks_before_replay_store(struct kobject *kobj,
 	NULL,
 };
 
-static struct attribute_group ldlm_attr_group = {
+static const struct attribute_group ldlm_attr_group = {
 	.attrs = ldlm_attrs,
 };
 
-- 
1.9.1
