From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri, 7 Apr 2017 19:16:54 -0700
Subject: [lustre-devel] [PATCH 02/12] trace: Make trace_hwlat timestamp
	y2038 safe
In-Reply-To: <20170407213011.36e29f42@gandalf.local.home>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-3-git-send-email-deepa.kernel@gmail.com>
	<20170407213011.36e29f42@gandalf.local.home>
Message-ID: <CABeXuvoQJSg+eVH4LX5s87DtE4N3goKDnjZgJ9fLk8txgwN+QA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, linux-mtd <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

>> -     trace_seq_printf(s, "#%-5u inner/outer(us): %4llu/%-5llu ts:%ld.%09ld",
>> +     trace_seq_printf(s, "#%-5u inner/outer(us): %4llu/%-5llu ts:%lld.%09ld",
>>                        field->seqnum,
>>                        field->duration,
>>                        field->outer_duration,
>> -                      field->timestamp.tv_sec,
>> +                      (long long)field->timestamp.tv_sec,
>
> Refresh my memory. We need the cast because on 64 bit boxes
> timestamp.tv_sec is just a long?

This is only required until we change the definition of timespec64.
Right now it is defined as

#if __BITS_PER_LONG == 64
# define timespec64 timespec
#else
struct timespec64 {
    time64_t tv_sec;
    long tv_nsec;
};
#endif

And timespec.tv_sec is just long int on 64 bit machines.
This is why we need the cast now.

We will probably change this and only define __kernel_timespec instead
of timespec, leaving only one definition of timespec64.
At that time, we will not need this.

-Deepa
