From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 17:52:13 +0000 (GMT)
Subject: [lustre-devel] [PATCH 17/37] lustre: simplify
 lprocfs_read_frac_helper.
In-Reply-To: <155053494572.24125.4002432022455040178.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494572.24125.4002432022455040178.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241739310.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This function seems overly complex, the same functionality
> is available with much less effort.

Actually we are in discussion about removing these functions.
The details are at:

https://jira.whamcloud.com/browse/LU-11157

Since shells typically don't handle "floating point" representation
well you can see the following:

sanity 64d with the same error message; '209.9: syntax error: invalid 
arithmetic operator (error token is ".9")'

The second issues is that the read values are not true representation
of the desired value. The same issues is with the string helpers as
well. Take for example

test_string_get_size_one(1100, 1, "1.10 kB", "1.07 KiB");

Which is taken from linux/lib/test-string_helpers.c.

If you pass 1100 to string_get_size() you can get either 1.10 kB or 1.07 
KiB. Now if do the reverse 1.10 kB you get ~1126 which is not the same as
11000. I discussed how to handle this problem with Andreas and he agreed
the best solution is make all the sysfs / debugfs *_mb files turn any 
values passed in to around up to the nearest MiB. This way we can report
the exact MiB settings to the users. We already have a patch to do this
for max_dirty_mb which I can push. The other *_mb files need to be updated
to round off. If you can wait a few days I can backport the already done
patch and push a patch for the rest. 

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/lustre/obdclass/lprocfs_status.c        |   47 +++-----------------
>  1 file changed, 7 insertions(+), 40 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index 568e6623e0c8..bd24e48f6145 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -205,53 +205,20 @@ static void obd_connect_data_seqprint(struct seq_file *m,
>  int lprocfs_read_frac_helper(char *buffer, unsigned long count, long val,
>  			     int mult)
>  {
> -	long decimal_val, frac_val;
>  	int prtn;
>  
>  	if (count < 10)
>  		return -EINVAL;
>  
> -	decimal_val = val / mult;
> -	prtn = snprintf(buffer, count, "%ld", decimal_val);
> -	frac_val = val % mult;
> -
> -	if (prtn < (count - 4) && frac_val > 0) {
> -		long temp_frac;
> -		int i, temp_mult = 1, frac_bits = 0;
> -
> -		temp_frac = frac_val * 10;
> -		buffer[prtn++] = '.';
> -		while (frac_bits < 2 && (temp_frac / mult) < 1) {
> -			/* only reserved 2 bits fraction */
> -			buffer[prtn++] = '0';
> -			temp_frac *= 10;
> -			frac_bits++;
> -		}
> -		/*
> -		 * Need to think these cases :
> -		 *      1. #echo x.00 > /sys/xxx       output result : x
> -		 *      2. #echo x.0x > /sys/xxx       output result : x.0x
> -		 *      3. #echo x.x0 > /sys/xxx       output result : x.x
> -		 *      4. #echo x.xx > /sys/xxx       output result : x.xx
> -		 *      Only reserved 2 bits fraction.
> -		 */
> -		for (i = 0; i < (5 - prtn); i++)
> -			temp_mult *= 10;
> -
> -		frac_bits = min((int)count - prtn, 3 - frac_bits);
> -		prtn += snprintf(buffer + prtn, frac_bits, "%ld",
> -				 frac_val * temp_mult / mult);
> +	prtn = snprintf(buffer, count, "%ld.%02lu",
> +			val / mult,
> +			(val % mult) / (mult / 100));
>  
> +	/* Strip trailing zeroes, and trailing '.' */
> +	while (prtn && buffer[prtn-1] == '0')
> +		prtn--;
> +	if (prtn && buffer[prtn-1] == '.')
>  		prtn--;
> -		while (buffer[prtn] < '1' || buffer[prtn] > '9') {
> -			prtn--;
> -			if (buffer[prtn] == '.') {
> -				prtn--;
> -				break;
> -			}
> -		}
> -		prtn++;
> -	}
>  	buffer[prtn++] = '\n';
>  	return prtn;
>  }
> 
> 
> 
