From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 24 Mar 2017 20:10:16 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Remove redundant code
In-Reply-To: <20170324134459.GA26275@kroah.com>
References: <20170324113952.GA31427@arushi-HP-Pavilion-Notebook>
	<20170324134459.GA26275@kroah.com>
Message-ID: <9D55D2DC-3CEB-471E-B37F-1721D1B328DA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "outreachy-kernel@googlegroups.com" <outreachy-kernel@googlegroups.com>

On Mar 24, 2017, at 07:44, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Fri, Mar 24, 2017 at 05:09:53PM +0530, Arushi Singhal wrote:
>> Remove the code which do not have any value.
>> 
>> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
>> ---
>> drivers/staging/lustre/lnet/lnet/net_fault.c | 5 -----
>> 1 file changed, 5 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
>> index 18183cbb9859..b60261db9e67 100644
>> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
>> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
>> @@ -997,11 +997,6 @@ lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
>> int
>> lnet_fault_init(void)
>> {
>> -	BUILD_BUG_ON(LNET_PUT_BIT != 1 << LNET_MSG_PUT);
>> -	BUILD_BUG_ON(LNET_ACK_BIT != 1 << LNET_MSG_ACK);
>> -	BUILD_BUG_ON(LNET_GET_BIT != 1 << LNET_MSG_GET);
>> -	BUILD_BUG_ON(LNET_REPLY_BIT != 1 << LNET_MSG_REPLY);
> 
> Why does this not have any value?  How are you ensuring that these
> requirements are now being met?

It was my recommendation to remove these checks, though on closer review I might have
been a bit premature.  For some reason I thought the LNET_*_BIT constants were defined
in terms of LNET_MSG_*, but I see they are not.

In conjunction with this change, the definition of LNET_*_BIT should be changed to be
defined in terms of the LNET_MSG_* constants:

 #define LNET_PUT_BIT BIT(LNET_MSG_PUT)
 #define LNET_ACK_BIT BIT(LNET_MSG_ACK)
 #define LNET_GET_BIT BIT(LNET_MSG_GET)
 #define LNET_REPLY_BIT BIT(LNET_MSG_REPLY)

The alternative would be to remove the LNET_*_BIT constants and use BIT(LNET_MSG_*)
directly in the code, since that is easy enough to read compared to (1 << LNET_MSG_*)
everywhere.  There don't seem to be a lot of users, so this wouldn't be a giant patch.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
