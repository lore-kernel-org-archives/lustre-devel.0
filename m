From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 4 May 2018 08:27:32 +0300
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: fix potential
 missing-check bug when copying lumv
In-Reply-To: <CAAa=b7dHK9grwfFLOpVv=Wpv32mLS66CxXJDHOzNBNaqsWLXaA@mail.gmail.com>
References: <1525128971-8946-1-git-send-email-wang6495@umn.edu>
 <20180501084621.jfxrm3qoqfmftnxh@mwanda>
 <CAAa=b7dHK9grwfFLOpVv=Wpv32mLS66CxXJDHOzNBNaqsWLXaA@mail.gmail.com>
Message-ID: <20180504052731.jkwhs4h4fuia3pft@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wenwen Wang <wang6495@umn.edu>
Cc: "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Roman Storozhenko <romeusmeister@gmail.com>, Andreas Dilger <andreas.dilger@intel.com>, Jeff Layton <jlayton@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kangjie Lu <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, open list <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

There is no security problem here.  The user is allowed to choose either
v1 or v3.  Using a double read race condition to choose v1 is not
going to cause problems.  It's slightly more complicated than just
choosing it directly but that doesn't make it a security issue.

It's a bit like typing with your feet in that just because using your
toes instead of your fingergs is more complicated, it doesn't make it a
security issue.

regards,
dan carpenter
