From: Degremont, Aurelien <degremoa@amazon.com>
Date: Tue, 23 Jun 2020 07:57:30 +0000
Subject: [lustre-devel] [PATCH 00/45] lustre: merged OpenSFS client
 patches from April 30 to today
In-Reply-To: <87pn9q1kxf.fsf@notabene.neil.brown.name>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
 <87sgfj6ypq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2006012345440.1967@casper.infradead.org>
 <87pn9q1kxf.fsf@notabene.neil.brown.name>
Message-ID: <B7168794-A621-413E-9DFA-AF1C02354F76@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



?Le 23/06/2020 06:11, ? lustre-devel au nom de NeilBrown ? <lustre-devel-bounces at lists.lustre.org au nom de neilb@suse.de> a ?crit :

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


By the way, where's your tree available Neil? I'm checking your github account but not sure this is there.


Aur?lien
