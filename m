From: Joe Perches <joe@perches.com>
Date: Sun, 11 Feb 2018 19:21:06 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: update the TODO list
In-Reply-To: <alpine.LFD.2.21.1802120158500.3291@casper.infradead.org>
References: <1518390008-17876-1-git-send-email-jsimmons@infradead.org>
 <1518390961.4139.1.camel@perches.com>
 <alpine.LFD.2.21.1802120158500.3291@casper.infradead.org>
Message-ID: <1518405666.4139.8.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, 2018-02-12 at 02:06 +0000, James Simmons wrote:
> > On Sun, 2018-02-11 at 18:00 -0500, James Simmons wrote:
> > > As more people become involved with the progression of the lustre
> > > client it needs to more clear what needs to be done to leave
> > > staging. Update the TODO list with the various bugs and changes
> > > to accomplish this. Some are simple bugs and others are far more
> > > complex task that will change many lines of code. Some even cover
> > > updating the user land utilities to meet the kernel requirements.
> > > Several bugs have already been addressed and just need to be
> > > pushed to the staging tree.
> > 
> > Nice list.
> 
> Thanks. Its nice to have a direction :-)
> 
> > Are or should those entries that have been addressed
> > also in this new list?
> 
> Do you mean by those entries what originally was in the
> TODO list or what has been fixed over the last 2 years?

My reading of

> Several bugs have already been addressed and just need to be
> pushed to the staging tree.

is that the new list contains entries for things
that have already been fixed but have not yet
been pushed to the staging tree.

So, if there are entries in the new TODO list
that really are fixed, but not yet posted, then
marking those entries as TODO seems inappropriate.
