From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 4 Jun 2018 09:14:43 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <20180604070922.GA13156@infradead.org>
References: <20180601091133.GA27521@kroah.com>
 <6A5E4E02-AE72-4068-BF93-38791BF38B4F@dilger.ca>
 <20180601190839.GA20734@kroah.com>
 <20180604070922.GA13156@infradead.org>
Message-ID: <20180604071443.GA32335@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Andreas Dilger <adilger@dilger.ca>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linuxfoundation.org>, lustre-devel <lustre-devel@lists.lustre.org>, fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, selinux@tycho.nsa.gov

On Mon, Jun 04, 2018 at 12:09:22AM -0700, Christoph Hellwig wrote:
> On Fri, Jun 01, 2018 at 09:08:39PM +0200, Greg Kroah-Hartman wrote:
> > Please, compare yourself to orangefs.  That is the perfect example of
> > how to do everything right.  They got their code into staging, cleaned
> > it up, talked to us about what was needed to do to get the remaining
> > bits in proper shape, they assigned dedicated developers to do that
> > work, talked with all of us at different conferences around the world to
> > check up and constantly ensure that they were doing the right thing, and
> > most importantly, they asked for feedback and acted on it.  In the end,
> > their codebase is much smaller, works better, is in the "real" part of
> > the kernel, and available to every Linux user out there.
> 
> FYI, orangefs never went through the statging tree.  Which might be
> one reason why it got merged so quickly - allowing rapid iteration
> without respect to merged windows, and doing all the trivial cleanups
> either before or after (but not at the same time as) the feature
> work really does help productivity.

Ah, my mistake, for some reason I thought it did, I guess I had offered
to take it that way if the developers wanted it.

And yes, doing all of the needed cleanups and other changes outside of
the kernel tree should be much much faster, which is why I bet it would
only take 6 months max to get lustre merged "properly" if they really
wanted to do it, by working out-of-tree.

Heck, they already have an out-of-tree repo today, so it's not like
removing the in-kernel version is going to change their normal
development workflow :(

greg k-h
