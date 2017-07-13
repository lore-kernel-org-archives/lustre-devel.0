From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 13 Jul 2017 22:57:59 +0200
Subject: [lustre-devel] [PATCH] lustre: check
	copy_from_iter/copy_to_iter return code
In-Reply-To: <alpine.LFD.2.20.1707131806080.14535@casper.infradead.org>
References: <20170710130833.1834210-1-arnd@arndb.de>
	<alpine.LFD.2.20.1707131806080.14535@casper.infradead.org>
Message-ID: <CAK8P3a3nJRN2QQO4AGVB3V=jKafqvjdwoJ5u4ntEMsEugzJ_+Q@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, "# 3.4.x" <stable@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Doug Oucharek <doug.s.oucharek@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Liang Zhen <liang.zhen@intel.com>, Nicholas Hanley <nicholasjhanley@gmail.com>, Lustre Development List <lustre-devel@lists.lustre.org>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 13, 2017 at 7:07 PM, James Simmons <jsimmons@infradead.org> wrote:
>
>> We now get a helpful warning for code that calls copy_{from,to}_iter
>> without checking the return value, introduced by commit aa28de275a24
>> ("iov_iter/hardening: move object size checks to inlined part").
>>
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_send':
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1643:2: error: ignoring return value of 'copy_from_iter', declared with attribute warn_unused_result [-Werror=unused-result]
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_recv':
>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1744:3: error: ignoring return value of 'copy_to_iter', declared with attribute warn_unused_result [-Werror=unused-result]
>>
>> In case we get short copies here, we may get incorrect behavior.
>> I've added failure handling for both rx and tx now, returning
>> -EFAULT as expected.
>>
>> Cc: stable at vger.kernel.org
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>> This warning now shows up in 'allmodconfig' builds, so it would be
>> good to get it fixed quickly for 4.13, but my patch should not go
>> in without careful review since I'm not familiar with with code
>> and the error handling is a bit tricky here.
>>
>> I added 'Cc: stable' since this is a preexisting condition that we
>> only started warning about now.
>> ---
>>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 15 +++++++++++++--
>>  1 file changed, 13 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
>> index 85b242ec5f9b..70256a0ffd2e 100644
>> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
>> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
>> @@ -1640,8 +1640,13 @@ kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
>>       ibmsg = tx->tx_msg;
>>       ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
>>
>> -     copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE,
>> +     rc = copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE,
>>                      &from);
>
> I have to Nak this to prevent it from landing but for some reason in my
> testing its returning zero from copy_from_iter.

Thanks for testing it!

That means we did not copy any data and the kernel continues with
an uninitialized buffer, right? The problem may be the definition of

struct kib_immediate_msg {
        struct lnet_hdr ibim_hdr;        /* portals header */
        char         ibim_payload[0]; /* piggy-backed payload */
} WIRE_ATTR;

The check that Al added will try to ensure that we don't write
beyond the size of the ibim_payload[] array, which unfortunately
is defined as a zero-byte array, so I can see why it will now
fail. However, it's already broken in mainline now, with or without
my patch.

Are you able to come up with a fix that avoids the warning in
'allmodconfig' and makes the function do something reasonable
again?

        Arnd
