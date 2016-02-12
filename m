From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 12 Feb 2016 23:20:40 +0000
Subject: [lustre-devel] [PATCH 06/11] staging: lustre: add missing
 spaces for LNet layer reported by checkpatch.pl
In-Reply-To: <1455298503.4235.4.camel@perches.com>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
	<1455296769-5481-7-git-send-email-jsimmons@infradead.org>
	<1455298503.4235.4.camel@perches.com>
Message-ID: <bc51a1d5f5f3406eaf7e371ab175dbaf@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Joe Perches' <joe@perches.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

>On Fri, 2016-02-12 at 12:06 -0500, James Simmons wrote:
>> Add missing spaces in the code reported by checkpatch.pl.
>[]
>> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>[]
>> @@ -112,7 +112,7 @@ typedef struct lnet_libhandle {
>> ?} lnet_libhandle_t;
>> ?
>> ?#define lh_entry(ptr, type, member) \
>> -	((type *)((char *)(ptr)-(char *)(&((type *)0)->member)))
>> +	((type *)((char *)(ptr) - (char *)(&((type *)0)->member)))
>
>This could use offsetof(type, member)

Will send a later patch to cover this.
