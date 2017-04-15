From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 15 Apr 2017 10:29:00 +0000
Subject: [lustre-devel] [PATCH 06/12] audit: Use timespec64 to represent
	audit timestamps
In-Reply-To: <CABeXuvoKmvbo_n3XQ0Y+iWGz88Jr3TwbPA7GiR3pia9407ANLw@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-7-git-send-email-deepa.kernel@gmail.com>
	<CAHC9VhTYWeKL+BAb6F3tfwzs7OKUEA8ANM=V05sfoiahNNX=9w@mail.gmail.com>
	<CABeXuvoKmvbo_n3XQ0Y+iWGz88Jr3TwbPA7GiR3pia9407ANLw@mail.gmail.com>
Message-ID: <CAK8P3a3w_3JKxW6kz-V9roxzf9RwbVgHaK8XjO5OOktVvZ_Sog@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, linux-mtd <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, "Drokin,
	Oleg" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>Linux

On Sat, Apr 8, 2017 at 5:58 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>> I have no problem merging this patch into audit/next for v4.12, would
>> you prefer me to do that so at least this patch is merged?
>
> This would be fine.
> But, I think whoever takes the last 2 deletion patches should also take them.
> I'm not sure how that part works out.
>
>> It would probably make life a small bit easier for us in the audit
>> world too as it would reduce the potential merge conflict.  However,
>> that's a relatively small thing to worry about.

As Andrew has picked the remaining patches up into -mm, this will work
out fine: any patches picked up by the respective maintainers for v4.12
should arrive as git pull requests before the -mm patches get applied
at a later stage of the merge window.

     Arnd
