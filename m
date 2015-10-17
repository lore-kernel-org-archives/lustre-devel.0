From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 17 Oct 2015 16:06:09 +0000
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: hash.c: replace
 IS_PO2 by is_power_of_2
In-Reply-To: <20151017132348.GB29953@waves>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<798c319bad7c0c621b608f499860eaaa1c78d03d.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<20151017054025.GA25392@kroah.com> <20151017103414.GC29503@waves>
	<alpine.DEB.2.02.1510171246480.2056@localhost6.localdomain6>,
	<20151017132348.GB29953@waves>
Message-ID: <7B4AB32D-3F72-43F0-98A7-C812D635B649@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 17, 2015, at 07:23, Aya Mahfouz <mahfouz.saif.elyazal@gmail.com> wrote:
> 
>> On Sat, Oct 17, 2015 at 12:47:13PM +0200, Julia Lawall wrote:
>>> On Sat, 17 Oct 2015, Aya Mahfouz wrote:
>>> 
>>>> On Fri, Oct 16, 2015 at 10:40:25PM -0700, Greg KH wrote:
>>>>> On Sat, Oct 17, 2015 at 12:06:28AM +0200, Aya Mahfouz wrote:
>>>>> Replaces IS_PO2 by is_power_of_2. IS_PO2 is used with several debug
>>>>> macros. In this case, it is CDEBUG. Note that the replacement changes
>>>>> the types involved, because the parameter of IS_PO2 is of type long long
>>>>> and the return type is int, while the parameter of is_power_of_2 is of
>>>>> type long and the return type is bool. This, however, has no impact,
>>>>> because the actual argument is always of type int, and the return value
>>>>> is always used as a boolean.
>>>>> 
>>>>> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
>>>>> ---
>>>>> drivers/staging/lustre/lustre/libcfs/hash.c | 4 +++-
>>>>> 1 file changed, 3 insertions(+), 1 deletion(-)
>>>>> 
>>>>> diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
>>>>> index 6f4c7d4..4b5e79a 100644
>>>>> --- a/drivers/staging/lustre/lustre/libcfs/hash.c
>>>>> +++ b/drivers/staging/lustre/lustre/libcfs/hash.c
>>>>> @@ -109,6 +109,8 @@
>>>>> 
>>>>> #include "../../include/linux/libcfs/libcfs.h"
>>>>> #include <linux/seq_file.h>
>>>>> +#include <linux/log2.h>
>>>>> +
>>>>> 
>>>>> #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
>>>>> static unsigned int warn_on_depth = 8;
>>>>> @@ -1785,7 +1787,7 @@ cfs_hash_rehash_cancel_locked(struct cfs_hash *hs)
>>>>>    for (i = 2; cfs_hash_is_rehashing(hs); i++) {
>>>>>        cfs_hash_unlock(hs, 1);
>>>>>        /* raise console warning while waiting too long */
>>>>> -        CDEBUG(IS_PO2(i >> 3) ? D_WARNING : D_INFO,
>>>>> +        CDEBUG(is_power_of_2(i >> 3) ? D_WARNING : D_INFO,
>>>> 
>>>> is_power_of_2() works differently than IS_PO2(), are you _sure_ that the
>>>> value here can not be 0?  If so, this will do something different :(
>>>> 
>>> 
>>> This is actually an interesting point to raise. __is_po2 the inline
>>> function used by IS_PO2 should actually check if the number is greater
>>> than 0. The current implementation of __is_po2 would allow the 
>>> comparison of 0 with 2^(size of unsigned long long)-1. Is this correct?
>>> Or is this something intentional?
>> 
>> What is the actual result in each case?
>> 
> 
> for __is_po2, if the number is 0 or power of 2 i.e. 1,2,4,8,16,32 etc
> then return 1, 0 otherwise
> for is_power_of_2 if the number is power of 2 return 1, 0 otherwise

It looks to me that the new behavior is actually more correct than the
old one. The message shouldn't print onto the console until it has been
tried several times, which is the
case with is_power_of_2(). 

This hasn't been noticed in the past since it only happens if the hash
table is still being resized at the same time it is being destroyed.

In summary, I think the existing patch is fine. You can add:

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Cheers, Andreas
