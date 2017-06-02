From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 2 Jun 2017 16:18:26 +0200
Subject: [lustre-devel] [PATCH 04/12] fs: ceph: CURRENT_TIME with
	ktime_get_real_ts()
In-Reply-To: <CAAM7YA=f74Wye8hgqR52CNG-c4Sh3sm74AzZYhSnhjN1B=G-Ow@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
	<CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
	<CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
	<CAAM7YAnWLUXMOCVbgfdKGfvK04EtAQcz-ETm7xFO=8Y=_fCvOQ@mail.gmail.com>
	<CALAqxLV-yVKWM5es7fAFiDzhSQmtZFiZDPQwBRUYbWUtqhoWVg@mail.gmail.com>
	<CABeXuvqvLr6sSGF+rZEXXxpCBDKTOeLX1ObSjbPPY4aFBuwvMg@mail.gmail.com>
	<CAAM7YAkXNo_69tOrw6a5kpyref9nEpEp-2vxBbFVSHGmAVbt+A@mail.gmail.com>
	<CAK8P3a1TwkVRCwDWqgYE8Z3wZT2+v6xayq=dVeW8KaHmO0W4cg@mail.gmail.com>
	<CAAM7YA=BJHFLz_Ud==7L=yCzxj+1sjctc68tvpNogPhiSxxELQ@mail.gmail.com>
	<CAK8P3a0D3EXuwBj+sSVL9cmpysdvQWXnkE0zEctBJS8XOqhX7A@mail.gmail.com>
	<CAAM7YAk8JNU=XV=sOCczagWjBimO4JSPU08th7E4u6FTJN--9A@mail.gmail.com>
	<CAK8P3a3m3nt6rfvAvDG6HFuUvy+qWbmk5K0UtLGqYhYHOfdF8w@mail.gmail.com>
	<CAAM7YA=f74Wye8hgqR52CNG-c4Sh3sm74AzZYhSnhjN1B=G-Ow@mail.gmail.com>
Message-ID: <CAK8P3a1etuRz6zwytXTHqK-T0g2YnbR4zcCwo98ehjjD1Dj+Ow@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yan, Zheng" <ukernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, linux-mtd <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, "Drokin,
	Oleg" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>, gregkh <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric

On Fri, Jun 2, 2017 at 2:18 PM, Yan, Zheng <ukernel@gmail.com> wrote:
> On Fri, Jun 2, 2017 at 7:33 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Fri, Jun 2, 2017 at 1:18 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>> What I meant is another related problem in ceph_mkdir() where the
>> i_ctime field of the parent inode is different between the persistent
>> representation in the mds and the in-memory representation.
>>
>
> I don't see any problem in mkdir case. Parent inode's i_ctime in mds is set to
> r_stamp. When client receives request reply, it set its in-memory inode's ctime
> to the same time stamp.

Ok, I see it now, thanks for the clarification. Most other file systems do this
the other way round and update all fields in the in-memory inode structure
first and then write that to persistent storage, so I was getting confused about
the order of events here.

If I understand it all right, we have three different behaviors in ceph now,
though the differences are very minor and probably don't ever matter:

- in setattr(), we update ctime in the in-memory inode first and then send
  the same time to the mds, and expect to set it again when the reply comes.

- in ceph_write_iter write() and mmap/page_mkwrite(), we call
  file_update_time() to set i_mtime and i_ctime to the same
  timestamp first once a write is observed by the fs and then take
  two other timestamps that we send to the mds, and update the
  in-memory inode a second time when the reply comes. ctime
  is never older than mtime here, as far as I can tell, but it may
  be newer when the timer interrupt happens between taking the
  two stamps.

- in all other calls, we only update the inode (and/or parent inode)
  after the reply arrives.

       Arnd
