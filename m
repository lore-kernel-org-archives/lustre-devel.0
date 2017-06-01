From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 1 Jun 2017 12:22:47 +0200
Subject: [lustre-devel] [PATCH 04/12] fs: ceph: CURRENT_TIME with
	ktime_get_real_ts()
In-Reply-To: <CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
	<CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
Message-ID: <CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yan, Zheng" <ukernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, linux-mtd <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, "Drokin,
	Oleg" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>, gregkh <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric

On Thu, Jun 1, 2017 at 11:56 AM, Yan, Zheng <ukernel@gmail.com> wrote:
> On Sat, Apr 8, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:

>> diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
>> index 517838b..77204da 100644
>> --- a/drivers/block/rbd.c
>> +++ b/drivers/block/rbd.c
>> @@ -1922,7 +1922,7 @@ static void rbd_osd_req_format_write(struct rbd_obj_request *obj_request)
>>  {
>>         struct ceph_osd_request *osd_req = obj_request->osd_req;
>>
>> -       osd_req->r_mtime = CURRENT_TIME;
>> +       ktime_get_real_ts(&osd_req->r_mtime);
>>         osd_req->r_data_offset = obj_request->offset;
>>  }
>>
>> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
>> index c681762..1d3fa90 100644
>> --- a/fs/ceph/mds_client.c
>> +++ b/fs/ceph/mds_client.c
>> @@ -1666,6 +1666,7 @@ struct ceph_mds_request *
>>  ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>  {
>>         struct ceph_mds_request *req = kzalloc(sizeof(*req), GFP_NOFS);
>> +       struct timespec ts;
>>
>>         if (!req)
>>                 return ERR_PTR(-ENOMEM);
>> @@ -1684,7 +1685,8 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
>>         init_completion(&req->r_safe_completion);
>>         INIT_LIST_HEAD(&req->r_unsafe_item);
>>
>> -       req->r_stamp = current_fs_time(mdsc->fsc->sb);
>> +       ktime_get_real_ts(&ts);
>> +       req->r_stamp = timespec_trunc(ts, mdsc->fsc->sb->s_time_gran);
>
> This change causes our kernel_untar_tar test case to fail (inode's
> ctime goes back). The reason is that there is time drift between the
> time stamps got by  ktime_get_real_ts() and current_time(). We need to
> revert this change until current_time() uses ktime_get_real_ts()
> internally.

Hmm, the change was not supposed to have a user-visible effect, so
something has gone wrong, but I don't immediately see how it
relates to what you observe.

ktime_get_real_ts() and current_time() use the same time base, there
is no drift, but there is a difference in resolution, as the latter uses
the time stamp of the last jiffies update, which may be up to one jiffy
(10ms) behind the exact time we put in the request stamps here.

Do you still see problems if you use current_kernel_time() instead of
ktime_get_real_ts()?

        Arnd
