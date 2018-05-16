From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 16 May 2018 11:00:22 +0300
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <alpine.LFD.2.21.1805150207500.576@casper.infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
 <20180508114500.qrtnjax4siupgv3n@mwanda>
 <alpine.LFD.2.21.1805150207500.576@casper.infradead.org>
Message-ID: <20180516080022.b4ihz7opiueobm7u@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 15, 2018 at 04:02:55PM +0100, James Simmons wrote:
> 
> > >  	/*
> > >  	 * Allocate new object. This may result in rather complicated
> > >  	 * operations, including fld queries, inode loading, etc.
> > >  	 */
> > >  	o = lu_object_alloc(env, dev, f, conf);
> > > -	if (IS_ERR(o))
> > > +	if (unlikely(IS_ERR(o)))
> > >  		return o;
> > >  
> > 
> > This is an unrelated and totally pointless.  likely/unlikely annotations
> > hurt readability, and they should only be added if it's something which
> > is going to show up in benchmarking.  lu_object_alloc() is already too
> > slow for the unlikely() to make a difference and anyway IS_ERR() has an
> > unlikely built in so it's duplicative...
> 
> Sounds like a good checkpatch case to test for :-)

The likely/unlikely annotations have their place in fast paths so a
checkpatch warning would get annoying...

regards,
dan carpenter
