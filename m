From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Wed, 16 Oct 2019 17:32:53 +0200
Subject: [lustre-devel] [testing] Maloo not scheduling tests
In-Reply-To: <FA82114A-33F6-458D-8919-45AE8667EF0A@whamcloud.com>
References: <c7942901-13ea-6126-5a65-be2271c37f22@cea.fr>
 <FA82114A-33F6-458D-8919-45AE8667EF0A@whamcloud.com>
Message-ID: <0bc13d64-3def-1ad6-0804-61307ac20209@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 16/10/2019 17:23, Andreas Dilger wrote:
> On Oct 16, 2019, at 19:21, quentin.bouget at cea.fr 
> <mailto:quentin.bouget@cea.fr> wrote:
>>
>> Hello,
>>
>> It seems like Maloo is not scheduling tests for this patch 
>> <https://review.whamcloud.com/#/c/36292/> since I added some test 
>> parameters yesterday:
>>
>>     Test-Parameters: fortestonly testlist=sanity clientarch=ppc64
>>
>> Are there problems on Maloo, or am I doing something wrong?
>>
>
> The "fortestonly" keyword is for patches that are not intended for 
> landing (e.g. work-in-progress patches for early review), so only a 
> limited number of tests are run.
>
Yes, I understand this. The idea was to check that the current version 
of the patch does fail on a big-endian client. But it does not seem like 
any tests are being scheduled.

EDIT: I just checked gerrit, there must have been a temporary failure, a 
retest was requested by M. Omstead.

Thanks,
Quentin

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191016/bcf44174/attachment.html>
