From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 17 Jan 2018 00:36:19 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Fix avoid intensive
 reconnecting for ko2iblnd patch
In-Reply-To: <20180116165628.GB7066@kroah.com>
References: <1516114161-27679-1-git-send-email-Dmitry.Eremin@intel.com>
 <9FC73D3DBECE0941BD2ED069D26863425CE75F26@irsmsx110.ger.corp.intel.com>
 <20180116165628.GB7066@kroah.com>
Message-ID: <6D19AB36-CDDF-4743-AF46-ADF31E26B4F4@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Eremin, Dmitry" <dmitry.eremin@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Jan 16, 2018, at 09:56, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Tue, Jan 16, 2018 at 03:01:49PM +0000, Eremin, Dmitry wrote:
>> In the original commit 4d99b2581effe115376402e710fbcb1c3c073769
> 
> Please use the documented way to write this:
> 	4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
> 

>> was missed one hunk. Added it now to avoid issue with use after free.
> 
> And I do not understand this commit message at all.
> 
>> Signed-off-by: Dmitry Eremin <Dmitry.Eremin@intel.com>
>> ---
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> index 2ebc484..a15a625 100644
>> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> @@ -890,7 +890,8 @@ void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
>> 		atomic_dec(&net->ibn_nconns);
>> 	}
>> 
>> -	kfree(conn);
>> +	if (free_conn)
>> +		kfree(conn);
> 
> This looks really odd, don't you think?

I'm not sure what the objection is here?  There is an argument to this
this function named "free_conn" which determines if the structure should
be freed, or if the network connection is just being torn down and
reconnected.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
