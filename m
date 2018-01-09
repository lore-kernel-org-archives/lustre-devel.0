From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 9 Jan 2018 09:24:47 +0100
Subject: [lustre-devel] [PATCH 04/19] staging: lustre: discard
 cfs_time_seconds()
In-Reply-To: <alpine.LFD.2.21.1801081708220.9942@casper.infradead.org>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209341.23920.8613572158448297057.stgit@noble>
 <alpine.LFD.2.21.1801081630470.9942@casper.infradead.org>
 <20180108170043.GA28139@kroah.com>
 <alpine.LFD.2.21.1801081708220.9942@casper.infradead.org>
Message-ID: <20180109082447.GA13112@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Mon, Jan 08, 2018 at 06:04:33PM +0000, James Simmons wrote:
> 
> > On Mon, Jan 08, 2018 at 04:52:35PM +0000, James Simmons wrote:
> > > 
> > > > cfs_time_seconds() converts a number of seconds to the
> > > > matching number of jiffies.
> > > > The standard way to do this in Linux is  "* HZ".
> > > > So discard cfs_time_seconds() and use "* HZ" instead.
> > >  
> > > Just to make you aware I have been working for several months on 
> > > moving lustre away from using jiffies as much as possible. The
> > > problem with using HZ is that it can vary. So when you have a
> > > parallel file system with batches of nodes that have different
> > > values of HZ you can get very interesting corner cases. So I have
> > > been moving everything over to time64_t and ktime. Also I mostly
> > > have killed off the cfs_time_shift* and crap as well. You see all
> > > work under https://jira.hpdd.intel.com/browse/LU-9019. So many
> > > of the cases you did below don't event exist any more. I was
> > > planning to push those changes after the next merge window.
> > 
> > First patch to me "wins", none of this "don't touch this code because
> > I'm going to work on it in the future" stuff.  That has been documented
> > to kill contributions and in one case, a whole opensource kernel
> > project.
> > 
> > So Neil's patches should be evaluated first, don't develop behind closed
> > walls like you are doing
> 
> What I'm saying is my work had been tested and various bugs have
> been worked out before it gets to you. His work is new and untested. His 
> work can be evaluated first but that doesn't mean it ready to land first. 
> The wait event changes is a pretty big change that can have unseen 
> consequences. 

And how in the world am I supposed to know that your work is somehow
better than his?  I don't see your work in my inbox at all, so am I
supposed to just guess?

Come on, you all know how kernel development works, and it sure isn't
this way.

> > I've merged almost all of them now, except for the ones that broke the
> > build :)
> 
> He just posted a updated the version of the l_wait_event changes a few 
> hours ago based on feed back. Please give it more than a few hours to 
> bake. I like to test them to make sure things don't break. I hate to 
> find out it breaks things and have it reverted. Please.

reverts are trivial, delaying patch acceptance for no good reason is
not.

thanks,

greg k-h
