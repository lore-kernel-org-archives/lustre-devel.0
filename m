From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 14:01:14 -0400
Subject: [lustre-devel] [PATCH 12/15] staging/lustre: Add spaces
	preferred around that '{+, -, *, /, |, <<, >>, &}'
In-Reply-To: <1469295072.1900.162.camel@perches.com>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
	<1469255832-746785-13-git-send-email-green@linuxhacker.ru>
	<1469295072.1900.162.camel@perches.com>
Message-ID: <974D47D2-320C-42C0-BA73-1DA12B73737F@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>


On Jul 23, 2016, at 1:31 PM, Joe Perches wrote:

> On Sat, 2016-07-23 at 02:37 -0400, Oleg Drokin wrote:
>> From: Emoly Liu <emoly.liu@intel.com>
> 
> unrelated trivial notes:
> 
>> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
> []
>> @@ -33,9 +33,9 @@
>>  
>>  /* The persistent object (i.e. actually stores stuff!) */
>>  #define ECHO_PERSISTENT_OBJID    1ULL
>> -#define ECHO_PERSISTENT_SIZE     ((__u64)(1<<20))
>> +#define ECHO_PERSISTENT_SIZE     ((__u64)(1 << 20))
> 
> This is generally an error-prone pattern as the cast is
> done after the shift.

Hm, indeed.

> Perhaps better is using a specific type
> 
> #define ECHO_PERSISTENT_SIZE		(1ULL << 20)

Yes, I guess this is a better way.

> And lustre seems to use types with unnecessary __ prefixes.

Need to see if this file is included in userspace where the __ is needed.
