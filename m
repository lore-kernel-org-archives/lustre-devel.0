From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:46 -0400
Subject: [lustre-devel] [PATCH v2 04/29] lustre: lov: use GFP_NOFS to
 allocate lo_entries.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

lo_type_guard is taken during memory reclaim:

               -> #0 (&lov->lo_type_guard){++++}:
[  576.552501]        down_read+0x27/0x7c
[  576.553072]        lov_object_delete+0xd5/0x1bb
[  576.553836]        lu_object_free+0x5f/0x111
[  576.554524]        lu_object_put+0x313/0x337
[  576.555267]        cl_inode_fini+0x158/0x1ac
[  576.555898]        ll_delete_inode+0xcc/0xd5
[  576.556572]        evict+0xb4/0x166
[  576.557162]        dispose_list+0x30/0x34
[  576.557834]        prune_icache_sb+0x55/0x73
[  576.558465]        super_cache_scan+0x122/0x16d
[  576.559138]        shrink_slab.part.22.constprop.37+0x27b/0x414
[  576.560059]        shrink_node+0x8d/0x1b3

and lov_init_composite is called while lo_type_guard is held:

[  576.540707]        lov_init_composite+0xff/0xc5f
[  576.541496]        lov_conf_set+0x4cf/0x658
[  576.542179]        cl_conf_set+0x49/0x58
[  576.542790]        cl_file_inode_init+0x21a/0x2b8
[  576.543564]        ll_update_inode+0x4e/0xea5
[  576.544277]        ll_iget+0x112/0x1bf
[  576.544871]        ll_prep_inode+0x242/0x43d
[  576.545541]        ll_lookup_it_finish+0xcf/0x51d
[  576.546308]        ll_lookup_it+0x52e/0x5fc
[  576.546976]        ll_atomic_open+0x1ce/0x74f
[  576.547666]        lookup_open+0x298/0x526
[  576.548325]        path_openat+0x29a/0x7d3
[  576.548917]        do_filp_open+0x57/0xc1
[  576.549539]        do_sys_open+0x137/0x1e7

so it is not safe to use GFP_KERNEL in lov_init_composite().

Use GFP_NOFS instead.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/lov/lov_object.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 2058275..261f7b7 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -216,8 +216,8 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	r0->lo_nr = lse->lsme_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
-	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
-			      GFP_KERNEL);
+	r0->lo_sub = kzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
+			      GFP_NOFS);
 	if (!r0->lo_sub)
 		return -ENOMEM;
 
@@ -302,7 +302,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	comp->lo_entry_count = entry_count;
 
 	comp->lo_entries = kcalloc(entry_count, sizeof(*comp->lo_entries),
-				   GFP_KERNEL);
+				   GFP_NOFS);
 	if (!comp->lo_entries)
 		return -ENOMEM;
 
-- 
1.8.3.1
