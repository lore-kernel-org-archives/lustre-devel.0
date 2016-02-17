From: shalin mehta <shalinmehta85@gmail.com>
Date: Tue, 16 Feb 2016 22:39:05 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: Fixed the parenthesis
In-Reply-To: <497A8642-BC1A-4EF9-92BC-C3FF3C217BA2@intel.com>
References: <1455507422-13568-1-git-send-email-shalinmehta85@gmail.com>
	<497A8642-BC1A-4EF9-92BC-C3FF3C217BA2@intel.com>
Message-ID: <CAJvEOfzMu8mdb=yq81+gZNRcazRSSZKwD2q7uW7tLf6kRnz-_Q@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Drokin, Oleg" <oleg.drokin@intel.com>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, "<kernel-janitors@lists.osdl.org>" <kernel-janitors@lists.osdl.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, "<lustre-devel@lists.lustre.org>" <lustre-devel@lists.lustre.org>

Hello,

Should I send this patch again due the spelling mistake in the patch
description?

Thanks,
Shalin

On Mon, Feb 15, 2016 at 6:51 PM, Drokin, Oleg <oleg.drokin@intel.com> wrote:
>
> On Feb 14, 2016, at 10:37 PM, Shalin Mehta wrote:
>
>> The parentehsis are fixed in the macro for the ldlm lock to set and
>> clear the flags.
>>
>> Signed-off-by: Shalin Mehta <shalinmehta85@gmail.com>
>> ---
>> drivers/staging/lustre/lustre/include/lustre_dlm_flags.h | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
>> index 0d3ed87..4f9e9ad 100644
>> --- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
>> +++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
>> @@ -365,10 +365,10 @@
>> #define LDLM_TEST_FLAG(_l, _b)        (((_l)->l_flags & (_b)) != 0)
>>
>> /** set a ldlm_lock flag bit */
>> -#define LDLM_SET_FLAG(_l, _b)         (((_l)->l_flags |= (_b))
>> +#define LDLM_SET_FLAG(_l, _b)         ((_l)->l_flags |= (_b))
>>
>> /** clear a ldlm_lock flag bit */
>> -#define LDLM_CLEAR_FLAG(_l, _b)       (((_l)->l_flags &= ~(_b))
>> +#define LDLM_CLEAR_FLAG(_l, _b)       ((_l)->l_flags &= ~(_b))
>>
>> /** Mask of flags inherited from parent lock when doing intents. */
>> #define LDLM_INHERIT_FLAGS            LDLM_FL_INHERIT_MASK
>
> Acked-by: Oleg Drokin <oleg.drokin@intel.com>
>
