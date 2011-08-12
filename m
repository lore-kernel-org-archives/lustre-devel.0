From: Johann Lombardi <johann@whamcloud.com>
Date: Fri, 12 Aug 2011 13:51:19 +0200
Subject: [Lustre-devel] client i/o and PG_writeback
In-Reply-To: <1313098823.2248.2.camel@titan>
References: <20110810142341.GA15190@granier.hd.free.fr>
	<6CDBCC5305CC4312AF061B9F30D3DCF3@xyratex.com>
	<1313086864.2307.8.camel@titan>
	<2E3B1EF6-1075-47A7-8D83-0FFACDCBC7E2@whamcloud.com>
	<1313098823.2248.2.camel@titan>
Message-ID: <20110812115119.GA12578@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 11, 2011 at 02:40:23PM -0700, Jinshan Xiong wrote:
> This really means PG_writeback is useless. The most important benefit of
> PG_writeback is to allow to write a being flushed page.

The benefit of PG_writeback is that one can check whether or not a page is under writeback and decide to wait for writeback to complete (via wait_on_page_writeback()) or to skip this page. A good example is the linux kernel writeback code which waits for writeback to complete for WB_SYNC_ALL (data integrity flush), but not for WB_SYNC_NONE (just regular memory cleaning writeback).

Cheers,
Johann
-- 
Johann Lombardi
Whamcloud, Inc.
www.whamcloud.com
