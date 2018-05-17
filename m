From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 May 2018 06:07:00 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <20180516165719.GA28434@kroah.com>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
 <20180508114500.qrtnjax4siupgv3n@mwanda>
 <alpine.LFD.2.21.1805150207500.576@casper.infradead.org>
 <20180516165719.GA28434@kroah.com>
Message-ID: <alpine.LFD.2.21.1805161931400.17395@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Dan Carpenter <dan.carpenter@oracle.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> > > Anyway, I understand that Intel has been ignoring kernel.org instead of
> > > sending forwarding their patches properly so you're doing a difficult
> > > and thankless job...  Thanks for that.  I'm sure it's frustrating to
> > > look at these patches for you as well.
> > 
> > Thank you for the complement. Also thank you for taking time to review
> > these patches. Your feedback is most welcomed and benefitical to the
> > health of the lustre client.
> > 
> > Sadly its not just Intel but other vendors that don't directly contribute
> > to the linux lustre client. I have spoke to the vendors about contributing 
> > and they all say the same thing. No working with drivers in the staging 
> > tree. Sadly all the parties involved are very interested in the success 
> > of the lustre client. No one has ever told me directly why they don't get
> > involved but I suspect it has to deal with 2 reasons. One is that staging
> > drivers are not normally enabled by distributions so their clients 
> > normally will never deal with the staging lustre client. Secondly vendors
> > just lack the man power to contribute in a meanful way.
> 
> If staging is hurting you, why is it in staging at all?  Why not just
> drop it, go off and spend a few months to clean up all the issues in
> your own tree (with none of those pesky requirements of easy-to-review
> patches) and then submit a "clean" filesystem for inclusion in the
> "real" part of the kernel tree?
> 
> It doesn't sound like anyone is actually using this code in the tree
> as-is, so why even keep it here?

I never said being in staging is hurting the progression of Lustre. In 
fact it is the exact opposite otherwise I wouldn't be active in this work.
What I was pointing out to Dan was that many vendors are reluctant to 
partcipate in broader open source development of this type.

The whole point of this is to evolve Lustre into a proper open source 
project not dependent on vendors for survival. Several years ago Lustre 
changed hands several times and the HPC community was worried about its
survival. Various institutions band togther to raise the resources to 
keep it alive. Over time Lustre has been migrating to a more open source 
community effort. An awesome example is the work the University of Indiana 
did for the sptlrpc layer. Now we see efforts expanding into the realm of 
the linux lustre client. Actually HPC sites that are community members are 
testing and running the linux client. In spite of the lack of vendor 
involvement the linux lustre client is making excellent progress. How 
often do you see style patches anymore? The headers are properly split
between userspace UAPI headers and kernel space. One of the major barriers
to leave staging was the the lack of a strong presence to continue moving
the lustre client forward. That is no longer the case. The finish line is
in view.
