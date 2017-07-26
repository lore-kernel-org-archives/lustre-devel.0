From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:18 -0400
Subject: [lustre-devel] [PATCH 02/20] staging: lustre: ldlm: restore missing
	newlines in ldlm sysfs files
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Restore the missing trailing newlines in
/sys/fs/lustre/ldlm/namespaces/*/lru_{max_age,size}.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9109
Reviewed-on: https://review.whamcloud.com/25522
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index c9ef247..eab44dc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -223,7 +223,7 @@ static ssize_t lru_size_show(struct kobject *kobj, struct attribute *attr,
 
 	if (ns_connect_lru_resize(ns))
 		nr = &ns->ns_nr_unused;
-	return sprintf(buf, "%u", *nr);
+	return sprintf(buf, "%u\n", *nr);
 }
 
 static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
@@ -318,7 +318,7 @@ static ssize_t lru_max_age_show(struct kobject *kobj, struct attribute *attr,
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
 
-	return sprintf(buf, "%u", ns->ns_max_age);
+	return sprintf(buf, "%u\n", ns->ns_max_age);
 }
 
 static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
-- 
1.8.3.1
