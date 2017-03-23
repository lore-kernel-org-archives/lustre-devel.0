From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 23 Mar 2017 20:43:59 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Replace a bit shift by
	a use of BIT.
In-Reply-To: <FE801B69-BCDE-4A58-B61D-B33E46826D5F@intel.com>
References: <20170322023933.GA11339@arushi-HP-Pavilion-Notebook>
	<FE801B69-BCDE-4A58-B61D-B33E46826D5F@intel.com>
Message-ID: <B070C8EE-1F72-4D6B-A80E-C33DB22151ED@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "outreachy-kernel@googlegroups.com" <outreachy-kernel@googlegroups.com>

On Mar 22, 2017, at 06:12, Dilger, Andreas <andreas.dilger@intel.com> wrote:
> 
> On Mar 21, 2017, at 22:39, Arushi Singhal <arushisinghal19971997@gmail.com> wrote:
>> 
>> This patch replaces bit shifting on 1 with the BIT(x) macro.
>> This was done with coccinelle:
[snip]
>> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
>> index 18183cbb9859..e83761a77d22 100644
>> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
>> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
>> @@ -997,10 +997,10 @@ lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
>> int
>> lnet_fault_init(void)
>> {
>> -	BUILD_BUG_ON(LNET_PUT_BIT != 1 << LNET_MSG_PUT);
>> -	BUILD_BUG_ON(LNET_ACK_BIT != 1 << LNET_MSG_ACK);
>> -	BUILD_BUG_ON(LNET_GET_BIT != 1 << LNET_MSG_GET);
>> -	BUILD_BUG_ON(LNET_REPLY_BIT != 1 << LNET_MSG_REPLY);
>> +	BUILD_BUG_ON(LNET_PUT_BIT != BIT(LNET_MSG_PUT));
>> +	BUILD_BUG_ON(LNET_ACK_BIT != BIT(LNET_MSG_ACK));
>> +	BUILD_BUG_ON(LNET_GET_BIT != BIT(LNET_MSG_GET));
>> +	BUILD_BUG_ON(LNET_REPLY_BIT != BIT(LNET_MSG_REPLY));
> 
> This looks reasonable at first glance, though on further thought it seems kind of
> pointless since this is really:
> 
> #defined LET_PUT_BIT BIT(LNET_MSG_PUT)
> 
>       BUILD_BUG_ON(BIT(LNET_MSG_PUT) != BIT(LNET_MSG_PUT))
> 
> so it is just checking that the macro's value is the same when called two times.
> I'd suggest just getting rid of these BUILD_BUG_ON() checks completely .

Arushi, it would be great if you could submit a patch to remove the above
BUILD_BUG_ON() lines completely.  I don't think they have any value anymore.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
