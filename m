From: Wenwen Wang <wang6495@umn.edu>
Date: Thu, 3 May 2018 23:19:37 -0500
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: fix potential
 missing-check bug when copying lumv
In-Reply-To: <20180501084621.jfxrm3qoqfmftnxh@mwanda>
References: <1525128971-8946-1-git-send-email-wang6495@umn.edu>
 <20180501084621.jfxrm3qoqfmftnxh@mwanda>
Message-ID: <CAAa=b7dHK9grwfFLOpVv=Wpv32mLS66CxXJDHOzNBNaqsWLXaA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Roman Storozhenko <romeusmeister@gmail.com>, Andreas Dilger <andreas.dilger@intel.com>, Jeff Layton <jlayton@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wenwen Wang <wang6495@umn.edu>, Kangjie Lu <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, open list <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

On Tue, May 1, 2018 at 3:46 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> On Mon, Apr 30, 2018 at 05:56:10PM -0500, Wenwen Wang wrote:
>> However, given that the user data resides in the user space, a malicious
>> user-space process can race to change the data between the two copies. By
>> doing so, the attacker can provide a data with an inconsistent version,
>> e.g., v1 version + v3 data. This can lead to logical errors in the
>> following execution in ll_dir_setstripe(), which performs different actions
>> according to the version specified by the field lmm_magic.
>
> This part is misleading.  The fix is to improve readability and make
> static checkers happy.  You're over dramatizing it to make people think
> it has a security impact when it doesn't.
>
> If the user wants to specify v1 data they can just say that on the first
> read.  They don't need to do funny tricks and race between the two
> reads.  It's allowed.
>
> In other words this allows the user to do something in a very
> complicated way which they are already allowed to do in a very simple
> straight forward way.
>
> regards,
> dan carpenter

Thanks for your comment, Dan! How about this:

However, given that the user data resides in the user space, a
malicious user-space process can race to change the data between the
two copies. By doing so, the attacker can provide a data with an
inconsistent version, e.g., v1 version + v3 data. The current kernel
can handle such inconsistent data. But, it may pose a potential
security risk for future implementations. Also, to improve code
readability and make static analysis tools happy, which will warn
about read-verify-re-read type bugs, this issue should be fixed.

Thanks,
Wenwen
