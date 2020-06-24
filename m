From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Jun 2020 15:34:27 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/45] lustre: merged OpenSFS client
 patches from April 30 to today
In-Reply-To: <87pn9q1kxf.fsf@notabene.neil.brown.name>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
 <87sgfj6ypq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2006012345440.1967@casper.infradead.org>
 <87pn9q1kxf.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.2006241511460.28449@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Mon, Jun 01 2020, James Simmons wrote:
> 
> >> > Merge the client side patches that landed to the OpenSFS
> >> > tree since Apirl 30 to today. Include a fid missing patches
> >> > as well and one patch to fix issues with 2 patches from the
> >> > earlier 600+ patch set. Please review to ensure their correctness.
> >> 
> >> Hi James,
> >> I tried applying these and hit lots of conflicts.
> >> What tree are they on top of?
> >
> > This is based off the top of my tree. Currently I'm using my tree as the 
> > OpenSFS version of the Linux client so I only add things that land. Your
> > tree is more the development / prototype tree since it has not yet landed
> > things. So most likely its the LNet LU-13004 work that is conflicting.
> > I also run the patches by checkpatch which has the LNET comment change 
> > that  wasn't in the OpenSFS branch until just recently; OpenSFS commit
> > d3f1ceeb123da9603cd5ee3acbd4ee638a995f10. That should reduce the conflicts
> > going forward. We are getting to the point in which both our trees are
> > almost in sync ;-) 
> 
> I don't think it makes any sense to maintain two separate trees like
> this.
> 
> Would you like to just keep maintaining your tree, and I'll stop with
> mine?
> 
> If so, is your git tree published somewhere?

At this point its okay to have two separate trees since our trees have
two different purposes. Mind you I do plan to retire my tree in the
near future for your tree. My tree:

https://github.com/jasimmons1973/lustre

is a 1 to 1 OpenSFS port to the Linux client. Your tree has new prototype
work; most has landed to the OpenSFS tree; which in turn ends up in my 
tree. Work is still outstanding in your tree that needs to be properly
vetted and merged. Also I have noticed the work in your tree that has
landed to OpenSFS is different. Sometimes the OpenSFS branch has 
improvements missing from the Linux client prototype patch and some times
the reverse is true. So those issues need to be sorted out as well. Your
tree is needed to work out these last bits. Once done a sweep will need
to be done on your tree to patch everything up.
