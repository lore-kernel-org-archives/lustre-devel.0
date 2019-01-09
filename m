From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 18/29] lustre: osc_cache: avoid unnecessary
 tests.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504226.26726.13771066469284363266.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These tests (have we reached page limit) are not necessary, as the
next call to try_to_add_extent_for_io() will perform the
same test, and fail if necessary.

Having the tests don't add any clarity to the code, and are unlikely
to help performance as they are likely to fail more often than they
succeed.

So discard them.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 14e6efb4b80b..5666f384ac6c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1990,8 +1990,6 @@ static unsigned int get_write_extents(struct osc_object *obj,
 			return data.erd_page_count;
 		EASSERT(ext->oe_nr_pages <= data.erd_max_pages, ext);
 	}
-	if (data.erd_page_count == data.erd_max_pages)
-		return data.erd_page_count;
 
 	while (!list_empty(&obj->oo_urgent_exts)) {
 		ext = list_entry(obj->oo_urgent_exts.next,
@@ -1999,8 +1997,6 @@ static unsigned int get_write_extents(struct osc_object *obj,
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
 	}
-	if (data.erd_page_count == data.erd_max_pages)
-		return data.erd_page_count;
 
 	/*
 	 * One key difference between full extents and other extents: full
@@ -2015,8 +2011,6 @@ static unsigned int get_write_extents(struct osc_object *obj,
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			break;
 	}
-	if (data.erd_page_count == data.erd_max_pages)
-		return data.erd_page_count;
 
 	ext = first_extent(obj);
 	while (ext) {
