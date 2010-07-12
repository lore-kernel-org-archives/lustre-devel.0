From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Mon, 12 Jul 2010 21:18:56 +0300
Subject: [Lustre-devel] is lustre 2.0.x from repo is broken?
In-Reply-To: <op.vfqsnf0uatmt0c@enyo>
References: <AANLkTimsvGSd0kJINLjqSWX9fvZS5nXJ1ZSYt-icG7_Z@mail.gmail.com>
	<op.vfqsnf0uatmt0c@enyo>
Message-ID: <AANLkTinOWSzjlaEiv2arC4pByJUflVso1COUb83ZCFPP@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Mike!

On Mon, Jul 12, 2010 at 9:08 PM, Mikhail Pershin <Mikhail.Pershin@sun.com>wrote:

> hello Yuriy,
>
> please try just our master branch. It is working with quota enabled but has
> issue with --disable-quota flag as you mentioned, fix is in bug 16890.
>
>
> On Mon, 12 Jul 2010 14:24:45 +0400, Yuriy Umanets <
> yuriy.umanets at clusterstor.com> wrote:
>
>  hi all,
>>
>> Recently I tried 2.0.x from git repo and basically found it quite broken.
>>
>> Issues:
>>
>> 1. Built lustre with default options does not work due to constant
>> permission denied and quota errors in dmesg despite messages that quota is
>> disabled;
>>
>> 2. configure --disable-quota - does not build at all;
>>
>> 3. if one tries to fix build issues from (2) and start lustre again, it
>> does
>> not work either due to quota errors :) It seemed to be not completely
>> disabled and keeps sending quota_ctl to server which does not handle it.
>>
>> Thanks.
>>
>>
>
> --
> Mikhail Pershin
> Staff Engineer, Lustre Group
> Sun Microsystems, Inc.
>



-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100712/02f681f3/attachment.htm>
