From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 21:29:05 +0100 (BST)
Subject: [lustre-devel] [PATCH 21/24] lustre: move remainder of
 linux-tracefile.c to tracefile.c
In-Reply-To: <87y3f7bj9w.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669084.10587.6920959206498193596.stgit@noble>
 <alpine.LFD.2.21.1806210236200.3886@casper.infradead.org>
 <87y3f7bj9w.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806242125460.28698@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Thu, Jun 21 2018, James Simmons wrote:
> 
> >> It's good to keep related code together.
> >> 
> >> Signed-off-by: NeilBrown <neilb@suse.com>
> >
> > Nak. For some reason this corrupts my dmesg output. Its really strange and
> > I haven't figured it out yet.
> 
> This patch cannot possibly be the cause of any such behavioural change.
> It purely moves code from one file to another, it doesn't change the
> code at all.

In a way you are correct. What this patch does is expose how badly messed
up cfs_print_to_console() is. Originally it was a printk() call but some
newbie changed it incorrectly into a pr_info() for all cases. This is 
totally incorrect but it landed anyways :-( For some bizarre reason it
works even with it being completely wrong. I did fix this patch up
and redid the later patches due the changes from the fix up. Is it okay
it I push the newer version of these patches with my changes?
