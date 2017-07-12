From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 12 Jul 2017 05:09:16 +0000
Subject: [lustre-devel] [PATCH 3/4] Staging: Lustre Fixing multiline
 block comments in lnetst.h
In-Reply-To: <20170711171449.GC11838@kroah.com>
References: <cover.1499388016.git.Craig@craiginches.com>
	<dea8ec86c52eb0f89a75774953af127b7e7a7e64.1499388016.git.Craig@craiginches.com>
	<20170711171449.GC11838@kroah.com>
Message-ID: <80BA3F43-DFB0-45B2-A36A-83628E731A88@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Jul 11, 2017, at 11:14, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Fri, Jul 07, 2017 at 01:47:04AM +0000, Craig Inches wrote:
>> This fixes multiple block statements found not to match
>> style as per checkpatch
>> 
>> Signed-off-by: Craig Inches <Craig@craiginches.com>
>> ---
>> drivers/staging/lustre/include/linux/lnet/lnetst.h | 129 +++++++++++++--------
>> 1 file changed, 81 insertions(+), 48 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
>> index ea736f8d5231..a4f9ff01d458 100644
>> --- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
>> +++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
>> @@ -54,7 +54,8 @@
>> #define LSTIO_GROUP_ADD		0xC10	/* add group */
>> #define LSTIO_GROUP_LIST	0xC11	/* list all groups in session */
>> #define LSTIO_GROUP_INFO	0xC12	/* query default information of
>> -					 * specified group */
>> +					 * specified group
>> +					 */
>> #define LSTIO_GROUP_DEL		0xC13	/* delete group */
>> #define LSTIO_NODES_ADD		0xC14	/* add nodes to specified group */
>> #define LSTIO_GROUP_UPDATE      0xC15	/* update group */
>> @@ -102,27 +103,32 @@ struct lstcon_test_ent {
>> 	int	tse_type;       /* test type */
>> 	int	tse_loop;       /* loop count */
>> 	int	tse_concur;     /* concurrency of test */
>> -};				/*** test summary entry, for
>> -				 *** list_batch command */
>> +};				/* test summary entry, for
>> +				 * list_batch command
>> +				 */
> 
> That's odd, what was the *** stuff for?
> 
> I'd like to get a lustre maintainer's ack for all of these before I
> apply them...

It's nothing that I know about.  We used DOxygen to comment the code and generate docs,
but the "***" isn't any markup that I'm familiar with.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
