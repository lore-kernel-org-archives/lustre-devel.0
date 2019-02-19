From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:04 +1100
Subject: [lustre-devel] [PATCH 02/37] lustre: llite: don't use
 class_setup_tunables()
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494490.24125.1514109985903155907.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

llite_kobj does not benefit from being in the
lustre_kset kset (though it does need lustre_kset
as a parent)
It also does not need the class_ktype type, as dynamic_kobj_ktype
is sufficient.

So use the simple kobject_create_and_add() to initialize it.

This provides flexibility for making changes to
class_setup_tunables().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 8215296dc15d..78ec0fa65c58 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -46,7 +46,7 @@ int llite_tunables_register(void)
 {
 	int rc = 0;
 
-	llite_kobj = class_setup_tunables("llite");
+	llite_kobj = kobject_create_and_add("llite", &lustre_kset->kobj);
 	if (IS_ERR(llite_kobj))
 		return PTR_ERR(llite_kobj);
 
