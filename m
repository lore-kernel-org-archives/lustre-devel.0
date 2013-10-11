From: White, Cliff <cliff.white@intel.com>
Date: Fri, 11 Oct 2013 18:30:56 +0000
Subject: [Lustre-devel] Kernel crash from "mkfs.lustre --index" setting
In-Reply-To: <CABgxfbE1LruxE8Uc-Vb_JnEyRnJcC8FUa0Q-kPjNNgT6zR7oCg@mail.gmail.com>
Message-ID: <CE7D90F6.722B%cliff.white@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/11/13 10:59 AM, "Wendy Cheng" <s.wendy.cheng@gmail.com> wrote:

>On Fri, Oct 11, 2013 at 10:41 AM, White, Cliff <cliff.white@intel.com>
>wrote:
>
>> 1.
>> --index is used to enumerate OSTs and MDT, when using DNE.
>> The index MUST be unique, and indexes must not have gaps.
>
>I see ... index must not have gaps. However, a user error could crash
>the kernelr . Does that sound right ? .

Well, creating the filesystem is normally done by admins, not users, but
yes, it shouldn't crash.
Lustre-devel is the place for your patch, sorry I wasn't clear. -discuss
is more for the 'why are their indexes' type of questions. :)
>
>>
>> 3. Surprise you how?
>>
>> HPDD-discuss is likely a better list for these sorts of questions,
>> lustre-devel is for code development.
>
>Thanks .. I'll move the discuss there sometime next week. It looks to
>me Lustre is doing sync to the disks all the time vs. other network
>filesystem (e.g. NFS) that does caching quite aggressively.

Yes, Lustre by design does direct IO to disk, and does not cache data on
the servers. 
Some caching can be enabled, but in general no, you should not see the
servers caching.

However, the clients should be using the normal Linux block cache, if the
clients are not caching
There may be an issue with your setup.
Cliffw

>
>-- Wendy
>
