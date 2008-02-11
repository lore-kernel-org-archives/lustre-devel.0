From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 11 Feb 2008 14:32:28 -0800
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <1202767637.6391.60.camel@localhost>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
	<20080211181850.GA6552@webber.adilger.int>
	<1202764303.6391.42.camel@localhost>
	<20080211213956.GK3029@webber.adilger.int>
	<1202767637.6391.60.camel@localhost>
Message-ID: <47B0CCFC.80102@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia wrote:
>
> On Seg, 2008-02-11 at 14:39 -0700, Andreas Dilger wrote:
>> The problem with ctime (on Linux as well) is that it is possible for the
>> system clock to go backward, whether due to ntp, or because the hardware
>> clock is incorrect/reset, so it cannot be depended upon to be monotonically
>> increasing for the life of the lustre filesystem.
>>     
>
> Ok. In that case, we could either add a new 64-bit version field to 
> the dnode (or znode) similar to the one in ldiskfs, or we could look 
> at the birth time (txg nr) of all the block pointers in the dnode.
> Using txg numbers might not be very useful if an object is migrated 
> from one storage device to another, but I have not read the HSM HLD so 
> I'm not sure if this is a problem or not.
I'm missing the point of this discussion.  Clearly we shouldn't/can't 
use ctime/mtime for anything internal to Lustre; that is what object 
versions are all about.  Why are we talking about adding new fields or 
anything else?
