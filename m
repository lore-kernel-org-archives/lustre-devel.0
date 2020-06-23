From: NeilBrown <neilb@suse.de>
Date: Tue, 23 Jun 2020 14:10:52 +1000
Subject: [lustre-devel] [PATCH 00/45] lustre: merged OpenSFS client
 patches from April 30 to today
In-Reply-To: <alpine.LFD.2.21.2006012345440.1967@casper.infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
 <87sgfj6ypq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2006012345440.1967@casper.infradead.org>
Message-ID: <87pn9q1kxf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 01 2020, James Simmons wrote:

>> > Merge the client side patches that landed to the OpenSFS
>> > tree since Apirl 30 to today. Include a fid missing patches
>> > as well and one patch to fix issues with 2 patches from the
>> > earlier 600+ patch set. Please review to ensure their correctness.
>> 
>> Hi James,
>> I tried applying these and hit lots of conflicts.
>> What tree are they on top of?
>
> This is based off the top of my tree. Currently I'm using my tree as the 
> OpenSFS version of the Linux client so I only add things that land. Your
> tree is more the development / prototype tree since it has not yet landed
> things. So most likely its the LNet LU-13004 work that is conflicting.
> I also run the patches by checkpatch which has the LNET comment change 
> that  wasn't in the OpenSFS branch until just recently; OpenSFS commit
> d3f1ceeb123da9603cd5ee3acbd4ee638a995f10. That should reduce the conflicts
> going forward. We are getting to the point in which both our trees are
> almost in sync ;-) 

I don't think it makes any sense to maintain two separate trees like
this.

Would you like to just keep maintaining your tree, and I'll stop with
mine?

If so, is your git tree published somewhere?

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200623/0d25b182/attachment.sig>
