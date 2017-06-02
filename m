From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 2 Jun 2017 11:45:47 +0200
Subject: [lustre-devel] [PATCH 04/12] fs: ceph: CURRENT_TIME with
	ktime_get_real_ts()
In-Reply-To: <CAAM7YAkXNo_69tOrw6a5kpyref9nEpEp-2vxBbFVSHGmAVbt+A@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
	<CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
	<CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
	<CAAM7YAnWLUXMOCVbgfdKGfvK04EtAQcz-ETm7xFO=8Y=_fCvOQ@mail.gmail.com>
	<CALAqxLV-yVKWM5es7fAFiDzhSQmtZFiZDPQwBRUYbWUtqhoWVg@mail.gmail.com>
	<CABeXuvqvLr6sSGF+rZEXXxpCBDKTOeLX1ObSjbPPY4aFBuwvMg@mail.gmail.com>
	<CAAM7YAkXNo_69tOrw6a5kpyref9nEpEp-2vxBbFVSHGmAVbt+A@mail.gmail.com>
Message-ID: <CAK8P3a1TwkVRCwDWqgYE8Z3wZT2+v6xayq=dVeW8KaHmO0W4cg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yan, Zheng" <ukernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, linux-mtd <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, "Drokin,
	Oleg" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>, gregkh <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric

On Fri, Jun 2, 2017 at 4:09 AM, Yan, Zheng <ukernel@gmail.com> wrote:
> On Fri, Jun 2, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>> On Thu, Jun 1, 2017 at 5:36 PM, John Stultz <john.stultz@linaro.org> wrote:
>>> On Thu, Jun 1, 2017 at 5:26 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>> On Thu, Jun 1, 2017 at 6:22 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>>>> On Thu, Jun 1, 2017 at 11:56 AM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>>>> On Sat, Apr 8, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>>>>>
>>>>>>> diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
>>>>>>> index 517838b..77204da 100644
>>>>>>> --- a/drivers/block/rbd.c
>>>>>>> +++ b/drivers/block/rbd.c
>>>>>>> @@ -1922,7 +1922,7 @@ static void rbd_osd_req_format_write(struct rbd_obj_request *obj_request)
>>>>>>>  {
>>>>>>>         struct ceph_osd_request *osd_req = obj_request->osd_req;
>>>>>>>
>>>>>>> -       osd_req->r_mtime = CURRENT_TIME;
>>>>>>> +       ktime_get_real_ts(&osd_req->r_mtime);
>>>>>>>         osd_req->r_data_offset = obj_request->offset;
>>>>>>>  }
>>>>>>>
>>>>>>> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
>>>>>>> index c681762..1d3fa90 100644
>>>>>>> --- a/fs/ceph/mds_client.c
>>>>>>> +++ b/fs/ceph/mds_client.c
>>>>>>> @@ -1666,6 +1666,7 @@ struct ceph_mds_request *
>>>>>>>  ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>>>>>>  {
>>>>>>>         struct ceph_mds_request *req = kzalloc(sizeof(*req), GFP_NOFS);
>>>>>>> +       struct timespec ts;
>>>>>>>
>>>>>>>         if (!req)
>>>>>>>                 return ERR_PTR(-ENOMEM);
>>>>>>> @@ -1684,7 +1685,8 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>>>>>>         init_completion(&req->r_safe_completion);
>>>>>>>         INIT_LIST_HEAD(&req->r_unsafe_item);
>>>>>>>
>>>>>>> -       req->r_stamp = current_fs_time(mdsc->fsc->sb);
>>>>>>> +       ktime_get_real_ts(&ts);
>>>>>>> +       req->r_stamp = timespec_trunc(ts, mdsc->fsc->sb->s_time_gran);
>>>>>>
>>>>>> This change causes our kernel_untar_tar test case to fail (inode's
>>>>>> ctime goes back). The reason is that there is time drift between the
>>>>>> time stamps got by  ktime_get_real_ts() and current_time(). We need to
>>>>>> revert this change until current_time() uses ktime_get_real_ts()
>>>>>> internally.
>>>>>
>>>>> Hmm, the change was not supposed to have a user-visible effect, so
>>>>> something has gone wrong, but I don't immediately see how it
>>>>> relates to what you observe.
>>>>>
>>>>> ktime_get_real_ts() and current_time() use the same time base, there
>>>>> is no drift, but there is a difference in resolution, as the latter uses
>>>>> the time stamp of the last jiffies update, which may be up to one jiffy
>>>>> (10ms) behind the exact time we put in the request stamps here.
>>>>>
>>>>> Do you still see problems if you use current_kernel_time() instead of
>>>>> ktime_get_real_ts()?
>>>>
>>>> The problem disappears after using current_kernel_time().
>>>>
>>>> https://github.com/ceph/ceph-client/commit/2e0f648da23167034a3cf1500bc90ec60aef2417
>>>
>>> From the commit above:
>>> "It seems there is time drift between ktime_get_real_ts() and
>>> current_kernel_time()"
>>>
>>> Its more of a granularity difference. current_kernel_time() returns
>>> the cached time at the last tick, where as ktime_get_real_ts() reads
>>> the clocksource hardware and returns the immediate time.
>>>
>>> Filesystems usually use the cached time (similar to
>>> CLOCK_REALTIME_COARSE), for performance reasons, as touching the
>>> clocksource takes time.
>>
>> Alternatively, it would be best for this code also to use current_time().
>> I had suggested this in one of the previous versions of the patch.
>> The implementation of current_time() will change when we switch vfs to
>> use 64 bit time. This will prevent such errors from happening again.
>> But, this also means there is more code reordering for these modules
>> to get a reference to inode.
>>
>
> I took a look. it's quite inconvenience to use current_time(). I
> prefer to temporarily use current_kernel_time().

I've looked at the code some more and I think there is another angle to it:
In your test case, 'tar' calls into the utimes syscall (or a member of its
family), which sets the i_ctime field in the inode to the curren time
(using current_time()), then calls __ceph_setattr(), which creates
a mds client request, and ceph_mdsc_create_request() takes another
time stamp and stores it in r_stamp.

We then store the first timestamp (only) in the in-memory inode, and the
second time stamp in the request. Depending on the state of the inode,
we may also set the ctime to a third timestamp we again take using
current_time().

The mtime and atime from user space get passed correctly through
union ceph_mds_request_args->setattr and are kept in sync between
the in-memory inode and the persistent inode data, but the ctime
in the inode never makes it to the lower protocol levels and instead
we use the r_stamp field that got set a little earlier or a little later.

I believe the bug you see is the result of the two timestamps
currently being almost guaranteed to be different in the latest
kernels.
Changing r_stamp to use current_kernel_time() will make it the
same value most of the time (as it was before Deepa's patch),
but when the timer interrupt happens between the timestamps,
the two are still different, it's just much harder to hit.

I think the proper solution should be to change __ceph_setattr()
in a way that has req->r_stamp always synchronized with i_ctime.
If we copy i_ctime to r_stamp, that will also take care of the
future issues with the planned changes to current_time().

The part I don't understand is what else r_stamp (i.e. the time
stamp in ceph_msg_data with type==
CEPH_MSG_CLIENT_REQUEST) is used for, other than setting
ctime in CEPH_MDS_OP_SETATTR.

Will this be used to update the stored i_ctime for other operations
too? If so, we would need to synchronize it with the in-memory
i_ctime for all operations that do this.

Semi-related side note: I see that the granularity for ceph_timespec
is 1000 nanoseconds, so the value is always a multiple of 1000.
If the full 32-bit data gets stored, we could use this it to store the
epoch number in the future:

static inline void ceph_decode_timespec(struct timespec64 *ts,
                                        const struct ceph_timespec *tv)
{
        u32 ns_epoch = le32_to_cpu(tv->tv_nsec);
        u32 epoch = ns_epoch % 1000;

        /* tv_sec is traditionally interpreted as unsigned
         * with time ranges 1970-2106, we extend
         * it to 1970-138069 */
        ts->tv_sec = (u64)le32_to_cpu(tv->tv_sec) +
                            (u64)epoch << 32;
        ts->tv_nsec = ns_epoch - epoch;
}

      Arnd
