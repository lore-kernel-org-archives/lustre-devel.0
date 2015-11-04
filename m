From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 4 Nov 2015 00:20:49 +0000
Subject: [lustre-devel] [PATCH] staging:lustre: Prevent duplicate CT
	registrations
In-Reply-To: <20151026085249.GW7340@mwanda>
References: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
	<1445630357-27149-3-git-send-email-jsimmons@infradead.org>
	<20151026085249.GW7340@mwanda>
Message-ID: <a1d0c77c4ddf4ce2960a39af3741edb3@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>On Fri, Oct 23, 2015 at 03:59:14PM -0400, James Simmons wrote:
>> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
>> index 635a93c..d6d70d8 100644
>> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
>> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
>> @@ -794,7 +794,9 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
>>  static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
>>  				 struct lustre_kernelcomm *lk, void *uarg)
>>  {
>> -	int	i, rc = 0;
>> +	struct kkuc_ct_data *kcd = NULL;
>> +	int rc = 0;
>> +	__u32 i;
>
>We have been introducing a lot of new __u32 types here and I just
>assumed there was a reason for it but this one is clearly wrong.  The
>new code implies that ->ld_tgt_count can overflow INT_MAX which is not
>true and that this is code shared with userspace which might be true but
>it's not described in the changelog.  Is this a static checker fix?
>Stop using that broken static checker, because the correct type here is
>int.

No this patch is from a real fix. You can read the details at
https://jira.hpdd.intel.com/browse/LU-3882. I bet he did this to avoid
the pickiness of gcc. We have build failure due to gcc stupidity. I could
be wrong which if that is the case the original Author is CC.

>Anyway, stop making gratuitous unrelated changes (like the white space
>changes to local declarations).  I feel like I have held off commenting
>on this for a while and shown great restraint.  :P

This is a direct drop of the original patch. I see lots of corrections to the
code below. Would a new follow on patch to correct these issues be okay
with you. This way we can perverse our bug fix history.
