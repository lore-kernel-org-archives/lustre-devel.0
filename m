From: Johann Lombardi <johann@whamcloud.com>
Date: Wed, 10 Aug 2011 16:23:41 +0200
Subject: [Lustre-devel] client i/o and PG_writeback
Message-ID: <20110810142341.GA15190@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi there,

I am working on a new client-side RPC engine using the per-stripe radix tree to select pages and trying to minimize RPC fragmentation. This should allow us to consume grant space more intelligently and to support blocksize > pagesize (e.g. for ext4 bigalloc).

For historical reasons (lustre was initially developed for 2.4 kernels), the 1.8 client holds the page lock over bulk write RPCs. Some basic support for PG_writeback was added back in 2007 (see bugzilla ticket 11710), but the page lock is still held until RPC completion.
Like the 1.8 client, the new client i/o stack introduced in 2.0 also keeps pages locked over transfer. I'm estimating the effort involved in implementing full PG_writeback support in CLIO. Does anybody have any technical concerns about this change?

Thanks in advance.

Cheers,
Johann
-- 
Johann Lombardi
Whamcloud, Inc.
www.whamcloud.com
