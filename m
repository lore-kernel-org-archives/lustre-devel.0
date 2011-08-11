From: Jinshan Xiong <jinshan.xiong@whamcloud.com>
Date: Thu, 11 Aug 2011 14:40:23 -0700
Subject: [Lustre-devel] client i/o and PG_writeback
In-Reply-To: <2E3B1EF6-1075-47A7-8D83-0FFACDCBC7E2@whamcloud.com>
References: <20110810142341.GA15190@granier.hd.free.fr>
	<6CDBCC5305CC4312AF061B9F30D3DCF3@xyratex.com>
	<1313086864.2307.8.camel@titan>
	<2E3B1EF6-1075-47A7-8D83-0FFACDCBC7E2@whamcloud.com>
Message-ID: <1313098823.2248.2.camel@titan>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2011-08-11 at 13:38 -0600, Andreas Dilger wrote:
> On 2011-08-11, at 12:21 PM, Jinshan Xiong wrote:
> > Another problem I can think of is page checksum, if a page changes again
> > during transfer, wrong checksum will be detected on the server side.
> 
> Actually, the kernel now uses PG_writeback to protect the page from being
> modified while it is being written to disk (or in our case sent to the
> network).  This was recently fixed for ext4 and other filesystems so that
> they can run properly on devices that support T10-DIF checksums.  Otherwise
> the disk keeps reporting checksum errors for files that were modified during
> IO.

This really means PG_writeback is useless. The most important benefit of
PG_writeback is to allow to write a being flushed page.

> 
> Lustre has a workaround for the case where the page is mmapped and is
> modified during RPC sending (the only case today where the page can be
> modified during IO), but it would be better not to have this workaround
> at all.  In this case the OSS detects the checksum error and the client
> resends like any other data corruption, but there is a flag in the RPC
> that silences the error messages that would otherwise be printed.
> 
> > On Wed, 2011-08-10 at 18:46 +0400, Nikita Danilov wrote:
> >> On Wednesday, August 10, 2011 at 18:23 , Johann Lombardi wrote:
> >>> Hi there,
> >>> 
> >> 
> >> 
> >> Hi Johann, [sorry, I hit a send button accidentally a few minutes
> >> ago] 
> >>> 
> >>> I am working on a new client-side RPC engine using the per-stripe
> >>> radix tree to select pages and trying to minimize RPC fragmentation.
> >>> This should allow us to consume grant space more intelligently and
> >>> to support blocksize > pagesize (e.g. for ext4 bigalloc).
> >>> 
> >>> For historical reasons (lustre was initially developed for 2.4
> >>> kernels), the 1.8 client holds the page lock over bulk write RPCs.
> >>> Some basic support for PG_writeback was added back in 2007 (see
> >>> bugzilla ticket 11710), but the page lock is still held until RPC
> >>> completion.
> >>> Like the 1.8 client, the new client i/o stack introduced in 2.0 also
> >>> keeps pages locked over transfer. I'm estimating the effort involved
> >>> in implementing full PG_writeback support in CLIO. Does anybody have
> >>> any technical concerns about this change?
> >>> 
> >> 
> >> 
> >> the reasons to use the same lock for page-in and page-out in CLIO were
> >> 
> >> 
> >>    * portability: Solaris, Windows and pretty much every kernel
> >> around use the same lock and
> >> 
> >> 
> >>    * simplicity.
> >> 
> >> 
> >> I don't think there are any serious problems with splitting the lock,
> >> one has to be careful with checking all places where page is assumed
> >> to be "owned" by IO and making certain the lock is taken, if
> >> necessary.
> >> 
> >>> 
> >>> Thanks in advance.
> >>> 
> >>> Cheers,
> >>> Johann
> >>> 
> >> 
> >> 
> >> Nikita.
> >> 
> >>> -- 
> >>> Johann Lombardi
> >>> Whamcloud, Inc.
> >>> www.whamcloud.com
> >>> 
> >> 
> >> 
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel
> > 
> > -- 
> > 
> > 
> > _______________________________________________
> > Lustre-devel mailing list
> > Lustre-devel at lists.lustre.org
> > http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> 
> Cheers, Andreas
> --
> Andreas Dilger 
> Principal Engineer
> Whamcloud, Inc.
> 
> 
> 

-- 
