From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 2 Jun 2017 04:08:11 +0000
Subject: [lustre-devel] [PATCH] drivers: staging/lustre: conrpc.c - fix
 sparse error: incompatible types in comparison expression (different
 address spaces)
In-Reply-To: <CAKUXR6NiUCFbJjWdQYPU_CQ-wJovXR255ZnOwHRtU6OSrm5PZg@mail.gmail.com>
References: <20170505135129.14757-1-kedrot@gmail.com>
	<CAKUXR6Mo-3QR0PQGf_7Otx2S3imowZzBD0Xs=xAY-m_sdHGNaw@mail.gmail.com>
	<CAKUXR6NiUCFbJjWdQYPU_CQ-wJovXR255ZnOwHRtU6OSrm5PZg@mail.gmail.com>
Message-ID: <8FAAC9A9-A33E-40FA-B073-C4E0EAA7725A@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tordek <kedrot@gmail.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>

On Jun 1, 2017, at 14:56, Tordek <kedrot@gmail.com> wrote:
> This is fairly minor but it reveals a few hidden warnings, could I get some feedback on it?

This is a known problem, but can't immediately be fixed because it affects the interface with
userspace tools.  The correct solution is to not use struct list_head in the user interface
at all, and we are looking into that.

In the meantime, feel free to look at the warnings that are now visible after this patch is
applied (locally on your system).

Thanks, Andreas

> 
> On 5 May 2017 10:53, "Tordek" <kedrot@gmail.com> wrote:
> This patch makes a lot of new warnings pop up, because the error is
> blocking the rest of the file from being processed.
> 
> On 5 May 2017 at 10:51, Guillermo O. Freschi <kedrot@gmail.com> wrote:
>> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
>> ---
>> drivers/staging/lustre/lnet/selftest/conrpc.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> index da36c55b86d3..f4578200994f 100644
>> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
>> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> @@ -487,7 +487,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
>>                                   sizeof(struct list_head)))
>>                        return -EFAULT;
>> 
>> -               if (tmp.next == head_up)
>> +               if ((struct list_head __user *)tmp.next == head_up)
>>                        return 0;
>> 
>>                next = tmp.next;
>> --
>> 2.11.0
>> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
