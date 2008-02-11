From: Rick Matthews <Richard.Matthews@Sun.COM>
Date: Mon, 11 Feb 2008 16:46:07 -0600
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47B0CCFC.80102@sun.com>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
	<20080211181850.GA6552@webber.adilger.int>
	<1202764303.6391.42.camel@localhost>
	<20080211213956.GK3029@webber.adilger.int>
	<1202767637.6391.60.camel@localhost> <47B0CCFC.80102@sun.com>
Message-ID: <47B0D02F.6030803@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm probably responsible for opening this can of worms. I inferred from 
the HSM HLD that
mtime was proposed to be used for state change, or version of the 
file/object. As the discussion
bears out, mtime for this purpose would be a bad idea. A reliable way of 
detecting change is
needed, and if it already exists withing Lustre, great!.

What I think is far more significant is the involvement of the community 
on issues
such as this. More folks examining (and critiquing) the details, the 
better.
Nice to see such an active community.
--

Nathaniel Rutman wrote:
> Ricardo M. Correia wrote:
>>
>> On Seg, 2008-02-11 at 14:39 -0700, Andreas Dilger wrote:
>>> The problem with ctime (on Linux as well) is that it is possible for 
>>> the
>>> system clock to go backward, whether due to ntp, or because the 
>>> hardware
>>> clock is incorrect/reset, so it cannot be depended upon to be 
>>> monotonically
>>> increasing for the life of the lustre filesystem.
>>>     
>>
>> Ok. In that case, we could either add a new 64-bit version field to 
>> the dnode (or znode) similar to the one in ldiskfs, or we could look 
>> at the birth time (txg nr) of all the block pointers in the dnode.
>> Using txg numbers might not be very useful if an object is migrated 
>> from one storage device to another, but I have not read the HSM HLD 
>> so I'm not sure if this is a problem or not.
> I'm missing the point of this discussion.  Clearly we shouldn't/can't 
> use ctime/mtime for anything internal to Lustre; that is what object 
> versions are all about.  Why are we talking about adding new fields or 
> anything else?
>
>


-- 
---------------------------------------------------------------------
Rick Matthews                           email: Rick.Matthews at sun.com
Sun Microsystems, Inc.                  phone:+1(651) 554-1518
1270 Eagan Industrial Road              phone(internal): 54418
Suite 160                               fax:  +1(651) 554-1540
Eagan, MN 55121-1231 USA                main: +1(651) 554-1500		
---------------------------------------------------------------------
