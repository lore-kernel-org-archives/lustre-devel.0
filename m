From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Sat, 8 Apr 2017 10:58:05 -0700
Subject: [lustre-devel] [PATCH 06/12] audit: Use timespec64 to represent
	audit timestamps
In-Reply-To: <CAHC9VhTYWeKL+BAb6F3tfwzs7OKUEA8ANM=V05sfoiahNNX=9w@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
	<1491613030-11599-7-git-send-email-deepa.kernel@gmail.com>
	<CAHC9VhTYWeKL+BAb6F3tfwzs7OKUEA8ANM=V05sfoiahNNX=9w@mail.gmail.com>
Message-ID: <CABeXuvoKmvbo_n3XQ0Y+iWGz88Jr3TwbPA7GiR3pia9407ANLw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Moore <paul@paul-moore.com>
Cc: yuchao0@huawei.com, "J. Bruce Fields" <bfields@fieldses.org>, Chris Mason <clm@fb.com>, linux-mtd <linux-mtd@lists.infradead.org>, Evgeniy Dushistov <dushistov@mail.ru>, Jeff Layton <jlayton@poochiereds.net>, ceph-devel <ceph-devel@vger.kernel.org>, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, y2038 Mailman List <y2038@lists.linaro.org>, Ingo Molnar <mingo@redhat.com>, James Simmons <jsimmons@infradead.org>, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, oleg.drokin@intel.com, John Stultz <john.stultz@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, andreas.dilger@intel.com, Josef Bacik <jbacik@fb.com>, Greg KH <gregkh@linuxfoundation.org>, samba-technical@lists.samba.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

> I have no problem merging this patch into audit/next for v4.12, would
> you prefer me to do that so at least this patch is merged?

This would be fine.
But, I think whoever takes the last 2 deletion patches should also take them.
I'm not sure how that part works out.

> It would probably make life a small bit easier for us in the audit
> world too as it would reduce the potential merge conflict.  However,
> that's a relatively small thing to worry about.

-Deepa
