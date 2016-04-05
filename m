From: Ming Lei <tom.leiming@gmail.com>
Date: Tue,  5 Apr 2016 19:56:53 +0800
Subject: [lustre-devel] [PATCH 08/27] staging: lustre: avoid to use
	bio->bi_vcnt directly
In-Reply-To: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
References: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
Message-ID: <1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <boaz@plexistor.com>, Ming Lei <tom.leiming@gmail.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, Mike Rapoport <mike.rapoport@gmail.com>, James Simmons <jsimmons@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Al Viro <viro@zeniv.linux.org.uk>, "moderated list:STAGING - LUSTRE PARALLEL
	FILESYSTEM" <lustre-devel@lists.lustre.org>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 drivers/staging/lustre/lustre/llite/lloop.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index b725fc1..67323db 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -302,19 +302,20 @@ static unsigned int loop_get_bio(struct lloop_device *lo, struct bio **req)
 	}
 
 	/* TODO: need to split the bio, too bad. */
-	LASSERT(first->bi_vcnt <= LLOOP_MAX_SEGMENTS);
+	LASSERT(bio_pages(first) <= LLOOP_MAX_SEGMENTS);
 
 	rw = first->bi_rw;
 	bio = &lo->lo_bio;
 	while (*bio && (*bio)->bi_rw == rw) {
+		unsigned curr_cnt = bio_pages(*bio);
 		CDEBUG(D_INFO, "bio sector %llu size %u count %u vcnt%u\n",
 		       (unsigned long long)(*bio)->bi_iter.bi_sector,
 		       (*bio)->bi_iter.bi_size,
-		       page_count, (*bio)->bi_vcnt);
-		if (page_count + (*bio)->bi_vcnt > LLOOP_MAX_SEGMENTS)
+		       page_count, curr_cnt);
+		if (page_count + curr_cnt > LLOOP_MAX_SEGMENTS)
 			break;
 
-		page_count += (*bio)->bi_vcnt;
+		page_count += curr_cnt;
 		count++;
 		bio = &(*bio)->bi_next;
 	}
-- 
1.9.1
