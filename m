From: Okash Khawaja <okash.khawaja@gmail.com>
Date: Tue, 15 Dec 2015 20:34:34 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: fix address space
	mismatches
In-Reply-To: <20151215184803.GB16129@kroah.com>
References: <20151215165045.GA5213@bytefire-computer>
	<20151215184803.GB16129@kroah.com>
Message-ID: <5612F531-9472-4E61-976D-44D116EF3C1F@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On 15 Dec 2015, at 18:48, Greg KH <gregkh@linuxfoundation.org> wrote:
> 
>> On Tue, Dec 15, 2015 at 04:50:45PM +0000, Okash Khawaja wrote:
>> This patch fixes address space warnings from sparse. Function
>> lprocfs_write_helper() accepts user space buffer but was being 
>> passed kernel space buffer by these functions:
>> 
>> contention_seconds_store()
>> lockless_truncate_store()
>> 
>> Since these functions are used to implement show and store functions of
>> lustre_attr object and since lustre_attr object is used to implement object
>> inheritance through use of `container_of`, the address space warnings
>> show up at multiple places inside driver's code base.
>> 
>> This patch creates a user space version of lustre_attr object lustre_attr_u.
>> Keeping function names and signatures same - other than the __user attribute -
>> ensures that object inheritance continues to work as it was, but address
>> space discrepency is removed. That removes a whole bunch of address
>> space warnings.
>> 
>> Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
>> ---
>> drivers/staging/lustre/lustre/include/lprocfs_status.h | 16 ++++++++++++++++
>> drivers/staging/lustre/lustre/osc/lproc_osc.c          | 12 ++++++------
>> 2 files changed, 22 insertions(+), 6 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
>> index f18c0c7..df6d9d5 100644
>> --- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
>> +++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
>> @@ -698,6 +698,22 @@ static struct lustre_attr lustre_attr_##name = __ATTR(name, mode, show, store)
>> #define LUSTRE_RO_ATTR(name) LUSTRE_ATTR(name, 0444, name##_show, NULL)
>> #define LUSTRE_RW_ATTR(name) LUSTRE_ATTR(name, 0644, name##_show, name##_store)
>> 
>> +struct lustre_attr_u {
>> +    struct attribute attr;
>> +    ssize_t (*show)(struct kobject *kobj, struct attribute *attr,
>> +            char *buf);
>> +    ssize_t (*store)(struct kobject *kobj, struct attribute *attr,
>> +             const char __user *buf, size_t len);
> 
> sysfs files do not have __user pointers, something is really wrong here
> if that's the solution :(
> 
> See the other comments in the mailing list archives for how messed up
> the __user and kernel pointers are in lustre, and how I'd not recommend
> anyone trying to fix them, unless you are a lustre developer and can
> test all of your changes...
> 
> sorry,
> 
> greg k-h

I see. Thanks for getting back promptly. 

Okash 
