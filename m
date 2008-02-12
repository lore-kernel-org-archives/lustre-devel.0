From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Tue, 12 Feb 2008 16:41:41 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47B0D02F.6030803@Sun.COM>
References: <47AB2FA7.10205@Sun.COM>
	<47AC7B75.30603@cea.fr>	<20080211181850.GA6552@webber.adilger.int>	<1202764303.6391.42.camel@localhost>	<20080211213956.GK3029@webber.adilger.int>	<1202767637.6391.60.camel@localhost>
	<47B0CCFC.80102@sun.com> <47B0D02F.6030803@Sun.COM>
Message-ID: <47B1BE35.7060506@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It is important to note that all comparisons and modifications are done 
at Lustre-object level: OST stripe object or MDT file object, each of 
those objects already has a version field, in the FID.
This is the version inside the FID that we will use for all treatments.
All purges are always requested for a specific FID.

The mtime is stored only for information, for the users. It is simpler 
to display to the user:

user$ list_hsm_copies ./foo
Date
============
Feb  2  2006
Jun 18  2007
Jun 19  2007

than:

user$ list_hsm_copies ./foo
Version
============
0x0012356
0x001a250
0x001a011

If the user "touched" the file sometime, he knew what he has done. Just 
the output will be different, but internaly, we manipulate Lustre FID 
and so we don't care of mtime.

So the "version" in the backend is not a problem. We do not rely on the 
ldiskfs/zfs inode versioning.


Aurelien Degremont

Rick Matthews a ?crit :
> I'm probably responsible for opening this can of worms. I inferred from 
> the HSM HLD that
> mtime was proposed to be used for state change, or version of the 
> file/object. As the discussion
> bears out, mtime for this purpose would be a bad idea. A reliable way of 
> detecting change is
> needed, and if it already exists withing Lustre, great!.
> 
> What I think is far more significant is the involvement of the community 
> on issues
> such as this. More folks examining (and critiquing) the details, the 
> better.
> Nice to see such an active community.
> --
> 
> Nathaniel Rutman wrote:
>> Ricardo M. Correia wrote:
>>> On Seg, 2008-02-11 at 14:39 -0700, Andreas Dilger wrote:
>>>> The problem with ctime (on Linux as well) is that it is possible for 
>>>> the
>>>> system clock to go backward, whether due to ntp, or because the 
>>>> hardware
>>>> clock is incorrect/reset, so it cannot be depended upon to be 
>>>> monotonically
>>>> increasing for the life of the lustre filesystem.
>>>>     
>>> Ok. In that case, we could either add a new 64-bit version field to 
>>> the dnode (or znode) similar to the one in ldiskfs, or we could look 
>>> at the birth time (txg nr) of all the block pointers in the dnode.
>>> Using txg numbers might not be very useful if an object is migrated 
>>> from one storage device to another, but I have not read the HSM HLD 
>>> so I'm not sure if this is a problem or not.
>> I'm missing the point of this discussion.  Clearly we shouldn't/can't 
>> use ctime/mtime for anything internal to Lustre; that is what object 
>> versions are all about.  Why are we talking about adding new fields or 
>> anything else?
>>
>>
> 
> 


-- 
Aurelien Degremont
CEA
