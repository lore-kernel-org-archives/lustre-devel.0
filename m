From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 24 Feb 2017 23:04:40 -0500
Subject: [lustre-devel] [PATCH 13/14] staging: lustre: llog: limit file
	size of plain logs
In-Reply-To: <20170224165910.GB9990@kroah.com>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
	<1487454435-4895-14-git-send-email-jsimmons@infradead.org>
	<20170224165910.GB9990@kroah.com>
Message-ID: <47EC722D-B672-4AD2-BC16-8343E7CA49F1@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: James Simmons <jsimmons@infradead.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Feb 24, 2017, at 11:59 AM, Greg Kroah-Hartman wrote:

> On Sat, Feb 18, 2017 at 04:47:14PM -0500, James Simmons wrote:
>> From: Alex Zhuravlev <alexey.zhuravlev@intel.com>
>> 
>> on small filesystems plain log can grow dramatically. especially
>> given large record sizes produced by DNE and extended chunksize.
>> I saw >50% of space consumed by a single llog file which was still
>> in use. this leads to test failures (sanityn, etc).
>> the patch introduces additional limit on plain llog size, which
>> is calculated as <free space>/64 (128MB at most) at llog creation
>> time.
>> 
>> Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
>> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6838
>> Reviewed-on: https://review.whamcloud.com/18028
>> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
>> Reviewed-by: wangdi <di.wang@intel.com>
>> Reviewed-by: Mike Pershin <mike.pershin@intel.com>
>> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>> drivers/staging/lustre/lustre/obdclass/llog.c | 16 ++++++++++++++++
>> 1 file changed, 16 insertions(+)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
>> index 83c5b62..320ff6b 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/llog.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/llog.c
>> @@ -319,10 +319,26 @@ static int llog_process_thread(void *arg)
>> 				 * the case and re-read the current chunk
>> 				 * otherwise.
>> 				 */
>> +				int records;
>> +
>> 				if (index > loghandle->lgh_last_idx) {
>> 					rc = 0;
>> 					goto out;
>> 				}
>> +				/* <2 records means no more records
>> +				 * if the last record we processed was
>> +				 * the final one, then the underlying
>> +				 * object might have been destroyed yet.
>> +				 * we better don't access that..
>> +				 */
>> +				mutex_lock(&loghandle->lgh_hdr_mutex);
>> +				records = loghandle->lgh_hdr->llh_count;
>> +				mutex_unlock(&loghandle->lgh_hdr_mutex);
>> +				if (records <= 1) {
>> +					rc = 0;
>> +					goto out;
>> +				}
> 
> 
> So you now use the lock, in only one place, when reading a single value?
> That makes no sense, it's obviously wrong, or not needed.
> 
> Please fix up these two patches?

Ah, this is in fact server-side fix, so all the other users were in the
parts not really present in the client.
James, we don't really need this patch in the client, I guess.
