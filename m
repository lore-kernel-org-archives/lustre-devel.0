From: Jia-Ju Bai <baijiaju1990@gmail.com>
Date: Thu, 26 Jul 2018 22:18:35 +0800
Subject: [lustre-devel] [BUG] staging: lustre: Possible null function
 pointer in ctx_refresh_timeout()
In-Reply-To: <20180726141227.GA12445@kroah.com>
References: <6920e093-ad62-56dc-6f58-36cf8d7ed3b4@gmail.com>
 <20180726141227.GA12445@kroah.com>
Message-ID: <001325ce-9edd-74a7-1359-c47b3ee66df1@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, paf@cray.com, namit@vmware.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org



On 2018/7/26 22:12, Greg KH wrote:
> On Thu, Jul 26, 2018 at 10:02:22PM +0800, Jia-Ju Bai wrote:
>> In Linux-4.16, drivers/staging/lustre/lustre/ptlrp/sec.c,
> Please look at the 4.18-rc6 release for this file.
>
> In short, nothing to worry about anymore :)

Looks good now :)


Best wishes,
Jia-Ju Bai
