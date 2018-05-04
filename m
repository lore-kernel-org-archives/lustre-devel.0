From: Kangjie Lu <kjlu@umn.edu>
Date: Fri, 4 May 2018 10:01:44 -0500
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: fix potential
 missing-check bug when copying lumv
Message-ID: <CAK8Kejq0h_Rgq__W_KSD_u+KUbS=cYkVXoHJpdbDrmYOU+iJDg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: Wenwen Wang <wang6495@umn.edu>, Dan Carpenter <dan.carpenter@oracle.com>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Roman Storozhenko <romeusmeister@gmail.com>, Jeff Layton <jlayton@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, open list <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

On Fri, May 4, 2018 at 5:08 AM, Dilger, Andreas <andreas.dilger@intel.com>
wrote:

> On May 3, 2018, at 22:19, Wenwen Wang <wang6495@umn.edu> wrote:
> >
> > On Tue, May 1, 2018 at 3:46 AM, Dan Carpenter <dan.carpenter@oracle.com>
> wrote:
> >> On Mon, Apr 30, 2018 at 05:56:10PM -0500, Wenwen Wang wrote:
> >>> However, given that the user data resides in the user space, a
> malicious
> >>> user-space process can race to change the data between the two copies.
> By
> >>> doing so, the attacker can provide a data with an inconsistent version,
> >>> e.g., v1 version + v3 data. This can lead to logical errors in the
> >>> following execution in ll_dir_setstripe(), which performs different
> actions
> >>> according to the version specified by the field lmm_magic.
> >>
> >> This part is misleading.  The fix is to improve readability and make
> >> static checkers happy.  You're over dramatizing it to make people think
> >> it has a security impact when it doesn't.
> >>
> >> If the user wants to specify v1 data they can just say that on the first
> >> read.  They don't need to do funny tricks and race between the two
> >> reads.  It's allowed.
> >>
> >> In other words this allows the user to do something in a very
> >> complicated way which they are already allowed to do in a very simple
> >> straight forward way.
> >>
> >> regards,
> >> dan carpenter
> >
> > Thanks for your comment, Dan! How about this:
> >
> > However, given that the user data resides in the user space, a
> > malicious user-space process can race to change the data between the
> > two copies. By doing so, the attacker can provide a data with an
> > inconsistent version, e.g., v1 version + v3 data. The current kernel
> > can handle such inconsistent data. But, it may pose a potential
> > security risk for future implementations. Also, to improve code
> > readability and make static analysis tools happy, which will warn
> > about read-verify-re-read type bugs, this issue should be fixed.
>
> There is nothing preventing the user from using struct lov_mds_md_v3 but
> filling in lmm_magic = LOV_MAGIC_V1 from the beginning, no need for a race.
>

Right. No need for users to race. There might be a type confusion issue
though if V1
object is  used as V3 or the other way.


>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Intel Corporation
>
>
>
>
>
>
>
>


-- 
Kangjie Lu
Assistant Professor
Department of Computer Science and Engineering
University of Minnesota
kjlu at umn.edu
http://kangjie.lu
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180504/097d6599/attachment-0001.html>
