From: Nikita Danilov <Nikita_Danilov@xyratex.com>
Date: Wed, 10 Aug 2011 18:46:04 +0400
Subject: [Lustre-devel] client i/o and PG_writeback
In-Reply-To: <20110810142341.GA15190@granier.hd.free.fr>
References: <20110810142341.GA15190@granier.hd.free.fr>
Message-ID: <6CDBCC5305CC4312AF061B9F30D3DCF3@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wednesday, August 10, 2011 at 18:23 , Johann Lombardi wrote:
> Hi there,

Hi Johann, [sorry, I hit a send button accidentally a few minutes ago] 
> 
> I am working on a new client-side RPC engine using the per-stripe radix tree to select pages and trying to minimize RPC fragmentation. This should allow us to consume grant space more intelligently and to support blocksize > pagesize (e.g. for ext4 bigalloc).
> 
> For historical reasons (lustre was initially developed for 2.4 kernels), the 1.8 client holds the page lock over bulk write RPCs. Some basic support for PG_writeback was added back in 2007 (see bugzilla ticket 11710), but the page lock is still held until RPC completion.
> Like the 1.8 client, the new client i/o stack introduced in 2.0 also keeps pages locked over transfer. I'm estimating the effort involved in implementing full PG_writeback support in CLIO. Does anybody have any technical concerns about this change?

the reasons to use the same lock for page-in and page-out in CLIO were

 * portability: Solaris, Windows and pretty much every kernel around use the same lock and

 * simplicity.

I don't think there are any serious problems with splitting the lock, one has to be careful with checking all places where page is assumed to be "owned" by IO and making certain the lock is taken, if necessary.

> 
> Thanks in advance.
> 
> Cheers,
> Johann

Nikita.

> -- 
> Johann Lombardi
> Whamcloud, Inc.
> www.whamcloud.com (http://www.whamcloud.com)

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110810/267c3583/attachment.htm>
