From: Ashley Pittman <ashley@pittman.co.uk>
Date: Tue, 23 Nov 2010 20:21:31 +0000
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
Message-ID: <4A69497B-D03B-4C60-8F15-4978CDD22A17@pittman.co.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 23 Nov 2010, at 17:20, Eric Barton wrote:

> Nick Cardo at NERSC mentioned at the LUG, and again when I chatted
> with him at SC10, that setting the default stripe offset is positively
> dangerous.  I think he has a point.
> 
> Setting file layout precisely can be essential for applications that
> know precisely what they're doing and want to control how aggregate
> OST load is balanced.  But the default file layout is another matter
> entirely.  Setting the default to a fixed layout, or even just a fixed
> starting OST has got to be the most direct path to achieving OST load
> imbalance.

Are you talking about the filesystem default (if indeed this can be set) or the setting for directories or for files?  For filesystem default I think you're right, for files it seems like a bad thing to restrict users like this and for directories I'm on the fence but leaning towards "users shouldn't need to do that".

> Thoughts?
> 
> P.S. Do people also agree that setting user/group/ACL permissions on
> OST pools would be a Good Thing?

I think pools could be wonderful once there is the option of moving files between pools dynamically, until then they are of little use IMHO so I'd much rather see that fixed first.

Ashley,

-- 

Ashley Pittman, Bath, UK.

Padb - A parallel job inspection tool for cluster computing
http://padb.pittman.org.uk
