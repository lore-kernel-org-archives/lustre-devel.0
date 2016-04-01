From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 1 Apr 2016 19:14:45 +0000
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
In-Reply-To: <1459536253.1744.26.camel@perches.com>
References: <cover.1459515208.git.joe@perches.com>
	<0586F4EF-3E2B-419A-8343-3A4A7E34628D@intel.com>
	<1459536253.1744.26.camel@perches.com>
Message-ID: <46D8C648-9F97-4D8D-B869-055B81A5E1EE@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: James Simmons <jsimmons@infradead.org>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "<lustre-devel@lists.lustre.org>" <lustre-devel@lists.lustre.org>


On Apr 1, 2016, at 2:44 PM, Joe Perches wrote:

> On Fri, 2016-04-01 at 14:23 +0000, Drokin, Oleg wrote:
>> On Apr 1, 2016, at 9:02 AM, Joe Perches wrote:
>>> 
>>> Question about removing lustre typedefs.
>>> 
>>> Various bits of lustre code use a mix of struct foo and foo_t.
>>> 
>>> When would be an appropriate time to submit patches similar to
>>> below that individually remove various typedefs from lustre code?
>> I think now is as good time as any.
>> the only small correction is those are LNet typedefs.
>> While LNet is technically part of Lustre, it's a bit of a separate
>> thing useful without Lustre too.
>> 
>> I know James is working on cleaning up LNet, but I don't know if he has
>> anything this would be conflicting at this moment or not.
>> 
>> Thanks for the patches. I wonder if you are generating them automatically?
>> Because it would be great if it also fixes the alignment issues
> 
> It's pretty automatic.
> 
> It's a trivial variant of the detypedef perl script I wrote awhile ago:
> http://permalink.gmane.org/gmane.linux.drivers.driver-project.devel/18603
> 
> 
> I think changing the alignment issues is better done in a
> separate patch.

but then it's two patches per change in a way. fixing one thing breaking
the other warning-wise, that's why I typically try to make such cleanup
patches not to introduce any new warnings.
> 
> James isn't cc'd on these patches as he's not a listed
> maintainer.  Maybe he should be added for all of it or
> some part of it?
> 

for drivers/staging/lustre/lnet

for the drivers/staging/lustre/lustre - the only remaining
few typedefs I am going to address, it's just some of the code using
them will go away or change the users significantly - that's why
they were left out in the first round of lustre detypedefisation.

Thanks.
