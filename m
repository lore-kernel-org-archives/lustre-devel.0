From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:25:03 -0400
Subject: [lustre-devel] [PATCH 13/14] staging/lustre/llite: do not clear
	uptodate bit in page delete
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Otherwise, if the race between page fault and truncate occurs, it
will cause the page fault routine to return an EIO error.

In filemap_fault() {
    page_not_uptodate:
    ...
        ClearPageError(page);
        error = mapping->a_ops->readpage(file, page);
        if (!error) {
                wait_on_page_locked(page);
                if (!PageUptodate(page))
                        error = -EIO;
    }
    ...
}

However, I tend to think this is a defect in kernel implementation,
because it assumes PageUptodate shouldn't be cleared but file read
routine doesn't make the same assumption.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/22827
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8633
Reviewed-by: Li Dongyang <dongyang.li@anu.edu.au>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/vvp_page.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 25490a5..23d6630 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -166,7 +166,6 @@ static void vvp_page_delete(const struct lu_env *env,
 	refc = atomic_dec_return(&page->cp_ref);
 	LASSERTF(refc >= 1, "page = %p, refc = %d\n", page, refc);
 
-	ClearPageUptodate(vmpage);
 	ClearPagePrivate(vmpage);
 	vmpage->private = 0;
 	/*
-- 
2.7.4
