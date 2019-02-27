From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Feb 2019 01:06:47 +0000
Subject: [lustre-devel] [PATCH 17/37] lustre: simplify
 lprocfs_read_frac_helper.
In-Reply-To: <87sgwat82i.fsf@notabene.neil.brown.name>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494572.24125.4002432022455040178.stgit@noble.brown>
 <alpine.LFD.2.21.1902241739310.22752@casper.infradead.org>
 <87sgwat82i.fsf@notabene.neil.brown.name>
Message-ID: <D8BE4529-E995-43CA-87F6-31F8FF52FB05@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 26, 2019, at 16:59, NeilBrown <neilb@suse.com> wrote:
> 
> On Sun, Feb 24 2019, James Simmons wrote:
> 
>>> This function seems overly complex, the same functionality
>>> is available with much less effort.
>> 
>> Actually we are in discussion about removing these functions.
>> The details are at:
>> 
>> https://jira.whamcloud.com/browse/LU-11157
>> 
>> Since shells typically don't handle "floating point" representation
>> well you can see the following:
>> 
>> sanity 64d with the same error message; '209.9: syntax error: invalid 
>> arithmetic operator (error token is ".9")'
>> 
>> The second issues is that the read values are not true representation
>> of the desired value. The same issues is with the string helpers as
>> well. Take for example
>> 
>> test_string_get_size_one(1100, 1, "1.10 kB", "1.07 KiB");
>> 
>> Which is taken from linux/lib/test-string_helpers.c.
>> 
>> If you pass 1100 to string_get_size() you can get either 1.10 kB or 1.07 
>> KiB. Now if do the reverse 1.10 kB you get ~1126 which is not the same as
>> 11000. I discussed how to handle this problem with Andreas and he agreed
>> the best solution is make all the sysfs / debugfs *_mb files turn any 
>> values passed in to around up to the nearest MiB. This way we can report
>> the exact MiB settings to the users. We already have a patch to do this
>> for max_dirty_mb which I can push. The other *_mb files need to be updated
>> to round off. If you can wait a few days I can backport the already done
>> patch and push a patch for the rest.
> 
> My  recommendation would be to deprecate all _mb files and instead have
> _bytes files which report a simple integer - the number of bytes.

That would break a lot of configurations and documentation.  Also, bytes
are not very convenient units for a lot of the numbers, for example you
don't want to (nor could you) send 47-byte RPCs.

> Leave all the unit conversion to user-space.
> 
> Linus once told me that he prefers sysfs files to always be in basic
> units, and that decimals are fine.  So use "seconds" for time, even if
> that means 0.002 for 2 milliseconds.  Use bytes for storage, etc.

That is not going to be better than allowing "max_dirty_mb=0.5", which
is what we wanted to get rid of in the first place.  Back in the day
when a system had 4MB DIMMs it was useful to allow fractional MB for the
cache size or debug log size, but I don't think that is useful today.

I'm content to just round these to the nearest MB, in the rare case that
someone specifies a fractional unit, but honestly I don't think that
anyone does anymore.  It is much more likely they will be setting the
cache size to 16G per target on their 256GB RAM nodes.

Cheers, Andreas

>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>> .../lustre/lustre/obdclass/lprocfs_status.c        |   47 +++-----------------
>>> 1 file changed, 7 insertions(+), 40 deletions(-)
>>> 
>>> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
>>> index 568e6623e0c8..bd24e48f6145 100644
>>> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
>>> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
>>> @@ -205,53 +205,20 @@ static void obd_connect_data_seqprint(struct seq_file *m,
>>> int lprocfs_read_frac_helper(char *buffer, unsigned long count, long val,
>>> 			     int mult)
>>> {
>>> -	long decimal_val, frac_val;
>>> 	int prtn;
>>> 
>>> 	if (count < 10)
>>> 		return -EINVAL;
>>> 
>>> -	decimal_val = val / mult;
>>> -	prtn = snprintf(buffer, count, "%ld", decimal_val);
>>> -	frac_val = val % mult;
>>> -
>>> -	if (prtn < (count - 4) && frac_val > 0) {
>>> -		long temp_frac;
>>> -		int i, temp_mult = 1, frac_bits = 0;
>>> -
>>> -		temp_frac = frac_val * 10;
>>> -		buffer[prtn++] = '.';
>>> -		while (frac_bits < 2 && (temp_frac / mult) < 1) {
>>> -			/* only reserved 2 bits fraction */
>>> -			buffer[prtn++] = '0';
>>> -			temp_frac *= 10;
>>> -			frac_bits++;
>>> -		}
>>> -		/*
>>> -		 * Need to think these cases :
>>> -		 *      1. #echo x.00 > /sys/xxx       output result : x
>>> -		 *      2. #echo x.0x > /sys/xxx       output result : x.0x
>>> -		 *      3. #echo x.x0 > /sys/xxx       output result : x.x
>>> -		 *      4. #echo x.xx > /sys/xxx       output result : x.xx
>>> -		 *      Only reserved 2 bits fraction.
>>> -		 */
>>> -		for (i = 0; i < (5 - prtn); i++)
>>> -			temp_mult *= 10;
>>> -
>>> -		frac_bits = min((int)count - prtn, 3 - frac_bits);
>>> -		prtn += snprintf(buffer + prtn, frac_bits, "%ld",
>>> -				 frac_val * temp_mult / mult);
>>> +	prtn = snprintf(buffer, count, "%ld.%02lu",
>>> +			val / mult,
>>> +			(val % mult) / (mult / 100));
>>> 
>>> +	/* Strip trailing zeroes, and trailing '.' */
>>> +	while (prtn && buffer[prtn-1] == '0')
>>> +		prtn--;
>>> +	if (prtn && buffer[prtn-1] == '.')
>>> 		prtn--;
>>> -		while (buffer[prtn] < '1' || buffer[prtn] > '9') {
>>> -			prtn--;
>>> -			if (buffer[prtn] == '.') {
>>> -				prtn--;
>>> -				break;
>>> -			}
>>> -		}
>>> -		prtn++;
>>> -	}
>>> 	buffer[prtn++] = '\n';
>>> 	return prtn;
>>> }

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
