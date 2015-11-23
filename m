From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 23 Nov 2015 23:37:19 +0000
Subject: [lustre-devel] Future of Lustre in staging
In-Reply-To: <CAHj3AVk+g_O-9bKqHWn4tMJnUGEb7ZPxAgxtEzqMh6JYvHWfNw@mail.gmail.com>
References: <564F0754.10500@gmail.com>
	<CAHj3AVk+g_O-9bKqHWn4tMJnUGEb7ZPxAgxtEzqMh6JYvHWfNw@mail.gmail.com>
Message-ID: <D2773FFF.11BF44%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/11/20, 06:30, "Denis Kirjanov" <kirjanov@gmail.com> wrote:

>On 11/20/15, Xose Vazquez Perez <xose.vazquez@gmail.com> wrote:
>> Hi,
>>
>> From https://lwn.net/Articles/662979/
>>
>> --cut--
>> Christoph complained a bit about the staging tree. He said that it
>> breaks allmodconfig builds, but that problem was evidently fixed a while
>> ago. He also dislikes the Lustre filesystem, which has been in staging
>> for some time now; Greg agreed and said that he would like to delete it.
>> It was generally agreed that the work being done on Lustre is not
>> substantial enough to justify its continued presence. Christoph also
>> said that the use of the staging tree for code that is about to be
>> deleted could be improved; there are, he said, people doing white-space
>> fixes on doomed code.
>> --end--
>>
>> Could anyone clarify it?
>
>AFAIK, Intel is going to work more harder on Lustre code, so the best
>option would be to wait a bit.
>Agreed, checkpatch fixes are just a mess..

I think it is important to note that it isn't just Intel working on this
code, but also ORNL, Cray, Indiana University, and others.

As for build breakage pf Lustre in staging, more often as not that is due
to patches landing outside of staging that cause Lustre builds to break.
That isn't really something that we can control while Lustre is in the
staging branch if that isn't required for normal builds.  The zero-day
patch bot has been good at catching those issues, and we've been good at
submitting fixes quickly, so I don't think it is a huge problem.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Principal Architect
Intel High Performance Data Division
