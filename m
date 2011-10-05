From: David Dillow <dillowda@ornl.gov>
Date: Wed, 05 Oct 2011 11:33:52 -0400
Subject: [Lustre-devel] Wide striping
In-Reply-To: <73AED5C780AE05478241DB067651A9210237884F@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<1317687469.23023.3.camel@obelisk.thedillows.org>
	<73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
	<1317762984.16569.18.camel@lap75545.ornl.gov>
	<73AED5C780AE05478241DB067651A9210237884F@XYUS-EX22.xyus.xyratex.com>
Message-ID: <1317828832.27894.8.camel@lap75545.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2011-10-05 at 11:06 -0400, Nathan Rutman wrote:
> Sorry if I'm being unclear.
> 
> start_index is just an offset into the bitmap.  That's the OST where the first 
> stripe will be.  Next stripe will be on the next OST index (unless a hole). 
> When we get to the big hole at the end of the used OSTs, these OST index 
> locations are all skipped (since they are holes), and the next stripe will 
> be at OST index 0, then 1, etc, up to start_index-1 (again, unless holes).

Ok, so bitmap position 0 is always OST 0; thanks for clearing up my
misunderstanding.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
