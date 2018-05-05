From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 5 May 2018 11:29:13 +0300
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: fix potential
 missing-check bug when copying lumv
In-Reply-To: <CAK8Kejq0h_Rgq__W_KSD_u+KUbS=cYkVXoHJpdbDrmYOU+iJDg@mail.gmail.com>
References: <CAK8Kejq0h_Rgq__W_KSD_u+KUbS=cYkVXoHJpdbDrmYOU+iJDg@mail.gmail.com>
Message-ID: <20180505082912.r4a6tawjv7ykedc7@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kangjie Lu <kjlu@umn.edu>
Cc: "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, Roman Storozhenko <romeusmeister@gmail.com>, "Dilger,
 Andreas" <andreas.dilger@intel.com>, Jeff Layton <jlayton@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wenwen Wang <wang6495@umn.edu>, NeilBrown <neilb@suse.com>, open list <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

On Fri, May 04, 2018 at 10:01:44AM -0500, Kangjie Lu wrote:
> > There is nothing preventing the user from using struct lov_mds_md_v3 but
> > filling in lmm_magic = LOV_MAGIC_V1 from the beginning, no need for a race.
> >
> 
> Right. No need for users to race. There might be a type confusion issue
> though if V1
> object is  used as V3 or the other way.
> 

It's a bit confusing for someone reading the code, but in terms of the
kernel it's straightforward.

It's like if someone is typing with their toes, that's sort of confusing
but it's not a security issue.  And here we're implementing a no typing
with your toes policy just to make things more higienic (static checkers
in this metaphor).

regards,
dan carpenter
