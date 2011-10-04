From: David Dillow <dillowda@ornl.gov>
Date: Mon, 03 Oct 2011 20:17:48 -0400
Subject: [Lustre-devel] Wide striping
In-Reply-To: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
Message-ID: <1317687469.23023.3.camel@obelisk.thedillows.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2011-10-03 at 13:15 -0700, Nathan Rutman wrote:

> Some OST?s may be down at file creation time, or new OSTs added later;
> hence there will likely be holes in the bitmap (but relatively few).
> Start index will still be used, but stripe order will be strictly
> round-robin (we will wrap around).  In other words, the stripe
> sequence will always be in linear OST order, starting from
> start_index, maybe skipping some holes, wrapping around to
> start_index-1.

It didn't occur to me when spoke at EOFS, but you'd need to store the
number of OSTs in the system when the mapping was created if you allow
it to wrap around -- otherwise, adding OSTs later would cause existing
files to loose track of the objects after the wrap point.

-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
