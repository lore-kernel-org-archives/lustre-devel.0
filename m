From: David Dillow <dillowda@ornl.gov>
Date: Wed, 05 Oct 2011 19:56:54 -0400
Subject: [Lustre-devel] Wide striping
In-Reply-To: <9CC6473C-DFE9-4FF4-9AA5-E7AB97D2987D@whamcloud.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<4E8BA3EE.6060300@whamcloud.com>
	<73AED5C780AE05478241DB067651A92102378850@XYUS-EX22.xyus.xyratex.com>
	<4E8CB381.40805@whamcloud.com>
	<9CC6473C-DFE9-4FF4-9AA5-E7AB97D2987D@whamcloud.com>
Message-ID: <1317859015.15874.2.camel@obelisk.thedillows.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2011-10-05 at 19:31 -0400, Oleg Drokin wrote:
> Hello!
> 
> On Oct 5, 2011, at 3:44 PM, wangdi wrote:
> >> Since the FID -> Objid mapping is performed locally, it doesn't
> need to be assigned until the first write.  This is not integral to
> the design, just a side effect.
> > Ah, you mean the object ID can be assigned during the first access,
> instead of FID? This is indeed an interesting idea, and do not need
> extra space. But this may add some limits of the future. (what if we
> decides to store some small file data in MDT directly?) And also it
> will add another difference between MDT and OST, probably it conflicts
> with the efforts of unifying MDT and OST?  I still prefer to have real
> OST FID, i.e. every object has its own identification in the cluster.
> Please correct me if I miss the point of your suggestion.
> 
> Another problems I see here are similar to create on write.
> Say if we delete a file, do we purge this mapping table too? and then
> when stale client comes we recreate an orphan object?
> Or we don't purge the table and let it grow indefinitely using more
> and more space and eventually slowing down lookups?
> Or do we purge really old objects from it only, what triggers it, what
> failure scenarios are there for this process?
> How do we recover from disasters that happened to this table?

Wouldn't the online lfsck work being done for OpenSFS catch and correct
these types of problems?

It seems like it could provide a base for purging/compacting the table
as well, but that's obviously going to be a complicated endeavor....
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
