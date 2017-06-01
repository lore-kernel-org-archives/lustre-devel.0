From: Tordek <kedrot@gmail.com>
Date: Thu, 1 Jun 2017 18:42:57 -0300
Subject: [lustre-devel] [PATCH] drivers: staging/lustre: conrpc.c - fix
 sparse error: incompatible types in comparison expression (different
 address spaces)
In-Reply-To: <CAKUXR6Mo-3QR0PQGf_7Otx2S3imowZzBD0Xs=xAY-m_sdHGNaw@mail.gmail.com>
References: <20170505135129.14757-1-kedrot@gmail.com>
	<CAKUXR6Mo-3QR0PQGf_7Otx2S3imowZzBD0Xs=xAY-m_sdHGNaw@mail.gmail.com>
Message-ID: <CAKUXR6PJ491j0Ye__K0w8ghO5Ka-x5anUtbU0PwTe1PQY6OnJg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

This is fairly minor but it reveals a few hidden warnings, could I get
some feedback on it?

Thanks
--
Guillermo

On 5 May 2017 at 10:53, Tordek <kedrot@gmail.com> wrote:
> This patch makes a lot of new warnings pop up, because the error is
> blocking the rest of the file from being processed.
>
> On 5 May 2017 at 10:51, Guillermo O. Freschi <kedrot@gmail.com> wrote:
>> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
>> ---
>>  drivers/staging/lustre/lnet/selftest/conrpc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> index da36c55b86d3..f4578200994f 100644
>> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
>> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> @@ -487,7 +487,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
>>                                    sizeof(struct list_head)))
>>                         return -EFAULT;
>>
>> -               if (tmp.next == head_up)
>> +               if ((struct list_head __user *)tmp.next == head_up)
>>                         return 0;
>>
>>                 next = tmp.next;
>> --
>> 2.11.0
>>
