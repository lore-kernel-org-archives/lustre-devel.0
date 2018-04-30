From: Wenwen Wang <wang6495@umn.edu>
Date: Mon, 30 Apr 2018 17:43:43 -0500
Subject: [lustre-devel] [PATCH] staging: luster: llite: fix a potential
 missing-check bug when copying lumv
In-Reply-To: <69A8B9D9-9330-4750-BAAC-94480A1072D5@intel.com>
References: <1524872704-13391-1-git-send-email-wang6495@umn.edu>
 <8E6ADED8-592E-4794-8CAB-913A325B1971@intel.com>
 <20180429132058.GB5972@kroah.com>
 <69A8B9D9-9330-4750-BAAC-94480A1072D5@intel.com>
Message-ID: <CAAa=b7dAdozKVxPgW5CowWB7xM3E=AJ-o9bL6S1NvRwb54vNmQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Jeff Layton <jlayton@redhat.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wenwen Wang <wang6495@umn.edu>, "kjlu@umn.edu" <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ben Evans <bevans@cray.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Mon, Apr 30, 2018 at 5:38 PM, Dilger, Andreas
<andreas.dilger@intel.com> wrote:
> On Apr 29, 2018, at 07:20, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
>>
>> On Sat, Apr 28, 2018 at 04:04:25PM +0000, Dilger, Andreas wrote:
>>> On Apr 27, 2018, at 17:45, Wenwen Wang <wang6495@umn.edu> wrote:
>>>> [PATCH] staging: luster: llite: fix potential missing-check bug when copying lumv
>>>
>>> (typo) s/luster/lustre/
>>>
>>>> In ll_dir_ioctl(), the object lumv3 is firstly copied from the user space
>>>> using Its address, i.e., lumv1 = &lumv3. If the lmm_magic field of lumv3 is
>>>> LOV_USER_MAGIV_V3, lumv3 will be modified by the second copy from the user
>>>
>>> (typo) s/MAGIV/MAGIC/
>>>
>>>> space. The second copy is necessary, because the two versions (i.e.,
>>>> lov_user_md_v1 and lov_user_md_v3) have different data formats and lengths.
>>>> However, given that the user data resides in the user space, a malicious
>>>> user-space process can race to change the data between the two copies. By
>>>> doing so, the attacker can provide a data with an inconsistent version,
>>>> e.g., v1 version + v3 data. This can lead to logical errors in the
>>>> following execution in ll_dir_setstripe(), which performs different actions
>>>> according to the version specified by the field lmm_magic.
>>>
>>> This isn't a serious bug in the end.  The LOV_USER_MAGIC_V3 check just copies
>>> a bit more data from userspace (the lmm_pool field).  It would be more of a
>>> problem if the reverse was possible (copy smaller V1 buffer, but change the
>>> magic to LOV_USER_MAGIC_V3 afterward), but this isn't possible since the second
>>> copy is not done if there is a V1 magic.  If the user changes from V3 magic
>>> to V1 in a racy manner it means less data will be used than copied, which
>>> is harmless.
>>>
>>>> This patch rechecks the version field lmm_magic in the second copy.  If the
>>>> version is not as expected, i.e., LOV_USER_MAGIC_V3, an error code will be
>>>> returned: -EINVAL.
>>>
>>> This isn't a bad idea in any case, since it verifies the data copied from
>>> userspace is still valid.
>>
>> So you agree with this patch?  Or do not?
>>
>> confused,
>
> I don't think it fixes a real bug, but it makes the code a bit more clear,
> so I'm OK to land it (with minor corrections to commit message per above).
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Intel Corporation
>

Thanks! I will re-submit the patch with the corrected commit message.

Wenwen
