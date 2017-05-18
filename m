From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 18 May 2017 14:48:25 +0000
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: lprocfs: Use
	kstrtouint_from_user
In-Reply-To: <20170518135322.GA6772@kroah.com>
References: <20170504161339.15901-1-mathiasrav@gmail.com>
	<20170504161339.15901-2-mathiasrav@gmail.com>
	<20170518135322.GA6772@kroah.com>
Message-ID: <9657977C-9620-4C31-9615-E4245482B5A7@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mathias Rav <mathiasrav@gmail.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On May 18, 2017, at 15:53, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Thu, May 04, 2017 at 12:13:38PM -0400, Mathias Rav wrote:
>> Prefer kstrtouint_from_user to copy_from_user+simple_strtoul.
>> 
>> The helper function lprocfs_wr_uint() is only used to implement
>> "dump_granted_max" in debugfs.
>> 
>> Note the slight change in semantics: The previous implementation using
>> simple_strtoul allows garbage after the number, whereas kstrtox only allows
>> a trailing line break. The previous implementation allowed a write of zero
>> bytes whereas kstrtox will return -EINVAL. Since this only affects a single
>> debugfs endpoint, this should be a permissible slight change of semantics
>> in exchange for 18 fewer lines of code.
>> 
>> Signed-off-by: Mathias Rav <mathiasrav@gmail.com>
>> ---
>> .../lustre/lustre/obdclass/lprocfs_status.c        | 22 +---------------------
>> 1 file changed, 1 insertion(+), 21 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
>> index 1ec6e3767d81..338ce34d6514 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
>> @@ -399,27 +399,7 @@ EXPORT_SYMBOL(lprocfs_rd_uint);
>> int lprocfs_wr_uint(struct file *file, const char __user *buffer,
>> 		    unsigned long count, void *data)
>> {
>> -	unsigned *p = data;
>> -	char dummy[MAX_STRING_SIZE + 1], *end;
>> -	unsigned long tmp;
>> -
>> -	if (count >= sizeof(dummy))
>> -		return -EINVAL;
>> -
>> -	if (count == 0)
>> -		return 0;
>> -
>> -	if (copy_from_user(dummy, buffer, count))
>> -		return -EFAULT;
>> -
>> -	dummy[count] = '\0';
>> -
>> -	tmp = simple_strtoul(dummy, &end, 0);
>> -	if (dummy == end)
>> -		return -EINVAL;
>> -
>> -	*p = (unsigned int)tmp;
>> -	return count;
>> +	return kstrtouint_from_user(buffer, count, 0, (unsigned int *)data);
> 
> Why not just delete this whole function and have the callers make this
> call instead?  No need for unneeded wrapper functions of core kernel
> calls.

Even better, it looks like this function has no callers on the client and could just
be deleted entirely.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
