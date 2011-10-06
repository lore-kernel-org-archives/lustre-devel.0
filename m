From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 5 Oct 2011 19:51:37 -0600
Subject: [Lustre-devel] Wide striping
In-Reply-To: <1317828832.27894.8.camel@lap75545.ornl.gov>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<1317687469.23023.3.camel@obelisk.thedillows.org>
	<73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
	<1317762984.16569.18.camel@lap75545.ornl.gov>
	<73AED5C780AE05478241DB067651A9210237884F@XYUS-EX22.xyus.xyratex.com>
	<1317828832.27894.8.camel@lap75545.ornl.gov>
Message-ID: <4684D08A-A823-47CD-8C02-22A92AEE6112@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-10-05, at 9:33 AM, David Dillow <dillowda@ornl.gov> wrote:
> On Wed, 2011-10-05 at 11:06 -0400, Nathan Rutman wrote:
>> Sorry if I'm being unclear.
>> 
>> start_index is just an offset into the bitmap.  That's the OST where the first 
>> stripe will be.  Next stripe will be on the next OST index (unless a hole). 
>> When we get to the big hole at the end of the used OSTs, these OST index 
>> locations are all skipped (since they are holes), and the next stripe will 
>> be at OST index 0, then 1, etc, up to start_index-1 (again, unless holes).
> 
> Ok, so bitmap position 0 is always OST 0; thanks for clearing up my
> misunderstanding.

But this means that the table always needs to be as large as the maximum OST number. If the bitmap started at the starting OST index it would only need to be as large as the number of stripes. 

That said, the limitation if not being able to migrate objects with this layout is a major one. The ability to so online object migration is just arriving with the layout lock (from HSM), so I expect this to be useful to many users. 

Cheers, Andreas
