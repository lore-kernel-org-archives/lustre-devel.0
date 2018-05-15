From: James Simmons <jsimmons@infradead.org>
Date: Tue, 15 May 2018 16:02:55 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <20180508114500.qrtnjax4siupgv3n@mwanda>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
 <20180508114500.qrtnjax4siupgv3n@mwanda>
Message-ID: <alpine.LFD.2.21.1805150207500.576@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> >  	/*
> >  	 * Allocate new object. This may result in rather complicated
> >  	 * operations, including fld queries, inode loading, etc.
> >  	 */
> >  	o = lu_object_alloc(env, dev, f, conf);
> > -	if (IS_ERR(o))
> > +	if (unlikely(IS_ERR(o)))
> >  		return o;
> >  
> 
> This is an unrelated and totally pointless.  likely/unlikely annotations
> hurt readability, and they should only be added if it's something which
> is going to show up in benchmarking.  lu_object_alloc() is already too
> slow for the unlikely() to make a difference and anyway IS_ERR() has an
> unlikely built in so it's duplicative...

Sounds like a good checkpatch case to test for :-) Some people like to try
and milk ever cycle they can. Personally for me I never use those 
annotations. With modern processors I'm skeptical if their benefits.
I do cleanup up the patches to some extent to make it compliant with 
kernel standards but leave the core code in place for people to comment 
on.

> Anyway, I understand that Intel has been ignoring kernel.org instead of
> sending forwarding their patches properly so you're doing a difficult
> and thankless job...  Thanks for that.  I'm sure it's frustrating to
> look at these patches for you as well.

Thank you for the complement. Also thank you for taking time to review
these patches. Your feedback is most welcomed and benefitical to the
health of the lustre client.

Sadly its not just Intel but other vendors that don't directly contribute
to the linux lustre client. I have spoke to the vendors about contributing 
and they all say the same thing. No working with drivers in the staging 
tree. Sadly all the parties involved are very interested in the success 
of the lustre client. No one has ever told me directly why they don't get
involved but I suspect it has to deal with 2 reasons. One is that staging
drivers are not normally enabled by distributions so their clients 
normally will never deal with the staging lustre client. Secondly vendors
just lack the man power to contribute in a meanful way.
