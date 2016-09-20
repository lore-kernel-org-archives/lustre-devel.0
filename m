From: James Simmons <jsimmons@infradead.org>
Date: Tue, 20 Sep 2016 18:04:00 +0100 (BST)
Subject: [lustre-devel] lnet_upcall on LBUG & LU-8418
In-Reply-To: <DC1659D0-0D6B-40B2-B35D-938F98E9FDD0@intel.com>
References: <57C5A350.30302@cray.com>
	<DC1659D0-0D6B-40B2-B35D-938F98E9FDD0@intel.com>
Message-ID: <alpine.LFD.2.20.1609201803380.19081@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> On Aug 30, 2016, at 11:16 AM, Patrick Farrell wrote:
> 
> > Hello,
> > 
> > Currently, on LBUG, Lustre tries to call a usermode helper at '/usr/lib/lustre/lnet_upcall'.  This is for some sort of binary that a user would like executed before the LBUG itself (by default, a panic) happens.  Lustre does not include an lnet_upcall script, so by default, the call fails.
> 
> I think this i a throwback to prehistoric times when BUG was not causing panic
> by default to try and copy stuff off the node with no local storage
> before it's killed.
> Modern crashdumping more or less superseded is.

Sorry I didn't answer earlier. I agree with Oleg. Lets just remove it. 
This is a case of lack of document which meant no one knew about it
worked to our advantage.
 
> > Unfortunately, in extremely low memory situations, the attempt to make this call can hang, resulting in a node which is in an invalid state but will not actually panic.  This is quite problematic as it can, for example, prevent failover or dump collection (for debugging purposes), depending on how a system is configured.
> > 
> > LU-8418 (from Alexander Zarochentsev) is looking to disable this by default.  As Andreas Dilger pointed out in the patch review (http://review.whamcloud.com/#/c/21440/), this would break any existing users who had put their script in that location.
> > 
> > But I suspect no one is actually using this feature.
> > 
> > So:
> > Do you use (or know of anyone using) the lnet_upcall feature to call a binary before LBUG?  (I'm looking for end user uses; if a developer is using it, I think it's reasonable to ask them to set it manually.)
> 
> I think it's unused so it should be safe to kill it, but let's see if anybody shows up
> indeed.
> 
> Bye,
>     Oleg
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
