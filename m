From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 23:35:19 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/34] Beginning of multi-rail support
 for drivers/staging/lustre
In-Reply-To: <87in2v4c16.fsf@notabene.neil.brown.name>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <alpine.LFD.2.21.1809102357470.29662@casper.infradead.org>
 <87in2v4c16.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1809292324070.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
> > Reviewed-on: http://review.whamcloud.com/18274
> > Reviewed-by: Doug Oucharek <dougso@me.com>
> > Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> > Signed-off-by: NeilBrown <neilb@suse.com>
> 
> Thanks for the suggestion.  I don't like that approach exactly because
> it seems to be a lie.  The specific patch was not reviewed by those
> people, and there is useful information which is not included there.
> I have changed to patches to include:
> 
>     This is part of
>         Commit: 8cbb8cd3e771 ("LU-7734 lnet: Multi-Rail local NI split")
>     from upstream lustre, where it is marked:
>         Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>         WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
>         Reviewed-on: http://review.whamcloud.com/18274
>         Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
>         Reviewed-by: Olaf Weber <olaf@sgi.com>
> 
> checkpatch is not happy with the indented tags, but checkpatch is a
> servant, not the master.

To my knowledge their isn't really a policy about this. What I have been
doing is kind of following how LTS versions of lustre have been handled. 
For LTS versions patches are cherry-picked and two additional lines are
added:

Lustre-change:
Lustre-commit:

The orginal reviews are keep. Also by including the original reviews the
people involved with those patches are poked. The only requirement is that
2 people review again. Not everyone has to review for it to land. Once 
landed I don't see a clear why to tell who reviewed.

In any case the above approach seems reasonable as long as the original
author is preserve. The general rule is the original patch poster normally
keeps authorship. Also I noticed patches recently pushed are not reaching
the original authors and reviewers. We should make sure that still 
happens.
