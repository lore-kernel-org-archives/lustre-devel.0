From: Wenwen Wang <wang6495@umn.edu>
Date: Fri, 4 May 2018 00:33:46 -0500
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: fix potential
 missing-check bug when copying lumv
In-Reply-To: <20180504052731.jkwhs4h4fuia3pft@mwanda>
References: <1525128971-8946-1-git-send-email-wang6495@umn.edu>
 <20180501084621.jfxrm3qoqfmftnxh@mwanda>
 <CAAa=b7dHK9grwfFLOpVv=Wpv32mLS66CxXJDHOzNBNaqsWLXaA@mail.gmail.com>
 <20180504052731.jkwhs4h4fuia3pft@mwanda>
Message-ID: <CAAa=b7cZajzCvZvzu7hnTcvGoxbQN-YVMLvbEGGR8v10AMC4rQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Roman Storozhenko <romeusmeister@gmail.com>, Andreas Dilger <andreas.dilger@intel.com>, Jeff Layton <jlayton@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wenwen Wang <wang6495@umn.edu>, Kangjie Lu <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, open list <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

On Fri, May 4, 2018 at 12:27 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> There is no security problem here.  The user is allowed to choose either
> v1 or v3.  Using a double read race condition to choose v1 is not
> going to cause problems.  It's slightly more complicated than just
> choosing it directly but that doesn't make it a security issue.
>
> It's a bit like typing with your feet in that just because using your
> toes instead of your fingergs is more complicated, it doesn't make it a
> security issue.
>
> regards,
> dan carpenter
>

Thanks again for your comment, Dan! I revised the commit message and
removed the security risk:

However, given that the user data resides in the user space, a
malicious user-space process can race to change the data between the
two copies. By doing so, the user can provide a data with an
inconsistent version, e.g., v1 version + v3 data. To improve code
readability and make static analysis tools happy, which will warn
about read-verify-re-read type bugs, this issue should be fixed.

Thanks,

Wenwen
