From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 05 Feb 2009 18:18:39 -0500
Subject: [Lustre-devel] Oleg an Eric - Supporting >512 OSTs for Striping
In-Reply-To: <20090205223154.GG3209@webber.adilger.int>
References: <C5B0A9CA.2F936%Daniel.Ferber@Sun.com>
	<1B98401E-C3F3-49C2-82F6-DE842B10858A@Sun.COM>
	<11f401c987d9$04d91b80$0e8b5280$@com>
	<678A8BA3-13B8-42E0-9CD6-57E084293AF0@Sun.COM>
	<20090205223154.GG3209@webber.adilger.int>
Message-ID: <3F022A30-072C-4270-B83C-1DFBB4659D16@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    Adding Lustre-devel to CC.

On Feb 5, 2009, at 5:31 PM, Andreas Dilger wrote:
> it is probably worthwhile to do a code audit to see if there are  
> many/any
> "for each stripe" kind of operations that could be avoided for such  
> widely
> striped files.  Common operations like lov_merge_lvb() and  
> lov_adjust_kms()
> will become very expensive, and could possibly be optimized in some  
> cases.

I suspect there are enough of them.
When I worked on slow small i/o, I noticed that we do merge_lvb pretty  
often
needlessly, for example. Basically, on partial page update, on  
refresh_ap
(sending write rpc - for every page), for every ll_readahead call (which
means for every page read). Every time we do glimpse.
Every time after enqueueing extent lock (even if cached).
On every read syscall.

I had a plan on how to fix it that turned out to be more complicated  
than I thought.
And in the end it was not the main culprit at the time.
Basically what we need to do is to store up-to-date merged lvb in  
inode somewhere
and update it with after every enqueue or lock cancel.

This is only relevant to b1_x codebase, I see that in HEAD with new io  
rewrite code,
the number of calls to merge_lvb is dramatically lower (only for  
glimpses), though
potentially some cpu could be saved by only merging after changes  
actually occurred.

> Similarly, we might consider to do MDS-originated object destroys for
> such files (or all files) instead of sending huge RPC with cookies to
> the client (~84kB reply).  These could be batched on unlink commit,  
> and
> would also avoid the "inodes with destroyed objects" bug previously
> discussed.

Do you only think of this as a way to cut the maximum RPC reply size  
on MDS?

Bye,
     Oleg
