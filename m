From: John Hammond <jhammond@ices.utexas.edu>
Date: Fri, 30 Apr 2010 16:07:42 -0500
Subject: [Lustre-devel] question about ldlm_server_glimpse_ast
In-Reply-To: <B1CC7901-3220-4BD6-89EE-B37C825DCB03@oracle.com>
References: <w2je5fcbd181004291959wb9790719ic4dc3a2bd9b64eb@mail.gmail.com>
	<4BDAD47E.401@ices.utexas.edu>
	<B1CC7901-3220-4BD6-89EE-B37C825DCB03@oracle.com>
Message-ID: <4BDB469E.4040005@ices.utexas.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 04/30/2010 01:44 PM, Oleg Drokin wrote:
> Hello!
>
> On Apr 30, 2010, at 9:00 AM, John Hammond wrote:
>> I tested a patch which set rq_no_resend = 0 for glimpses, and found that
>> clients only had about 6 seconds to reply before eviction.  Since
>> eviction creates the possibility for data loss, a 6 second timeout was
>> deemed too short for production.  (With the patch applied, it was easy
>> for me to create cases where data was indeed lost.)  I was also able to
>
> Please note that the 6 second timeout is in fact common ldlm_timeout and it's
> not just glimpses that are bound by this value.
> any ldlm callbacks are required to reply withing this time, so if your
> network can have delays of more then this much, you need to consider
> increasing ldlm_timeout value (/proc/sys/lustre/ldlm_timeout).
> On the other hand if you have a packet loss issue, even if
> resending of glimpse ASTs would be present, we don't currently resend
> other ASTs so the situation still has a potential for evictions
> with subsequent possible data loss.

Are there any nonobvious ramifications of changing ldlm_timeout?  I 
noticed that it was set to 20 seconds (except for MDS's?) in 1.8.2. 
Also there is some suspect looking logic in obd_config.c and elsewhere 
to keep it from being set too high relative to obd_timeout:

     if (ldlm_timeout >= obd_timeout)
         ldlm_timeout = max(obd_timeout / 3, 1U);

Does this mean that ldlm_timeout should not exceed 1/3 of obd_timeout?

Thanks,

-John

-- 
John L. Hammond, Ph.D.
ICES, The University of Texas at Austin
jhammond at ices.utexas.edu
(512) 471-9304
