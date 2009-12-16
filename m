From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Wed, 16 Dec 2009 19:24:39 +0200
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
Message-ID: <3ed212d00912160924w5c823207h35378e814e0a6c23@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hi Andreas,

On Tue, Dec 15, 2009 at 11:05 PM, Andreas Dilger <adilger@sun.com> wrote:

> Hello Peter,
>
>
> > 2. We need MUCH more in the repository than Sun is putting into it.
> >
> > There are many development branches and sometimes abandoned projects
> > that still have a lot of value.  For example, there is a nearly
> > complete OS X client port - what if someone wanted to pick that up?
> > Similarly, there are projects like size on MDS or the network
> > request scheduler that may need help from the community to get
> > finished or re-prioritized.
>
> All of the Lustre history is still available in CVS, as it has always
> been.  As far as I know (I've never checked it out myself) even the OS/
> X client port is publicly available today, which was not true a few
> years ago.
>

I would say, some time ago publicly available cvs repository "did not feel
well". I could not find cmd2 (seems to be not available todays too), gns or
even cmd3 code and any attempt to convert it to git or do anything that
requires "cvs rlog" resulted in this:

:pserver:anonymous at cvs.lustre.org:/lustre lustre-core
password file:
cvsroot: :pserver:anonymous at cvs.lustre.org:2401/lustre
pass: A
I LOVE YOU
cvs rlog: Logging lustre-core
cvs rlog: Logging lustre-core/asobd
cvs rlog: Logging lustre-core/autoconf
cvs rlog: Logging lustre-core/cmm
cvs rlog: Logging lustre-core/cmobd
cvs rlog: Logging lustre-core/cobd
cvs rlog: Logging lustre-core/conf
cvs rlog: Logging lustre-core/contrib
cvs rlog: Logging lustre-core/demos
cvs [rlog aborted]: unexpected '\x0' reading revision number in RCS
file /lustre/lustre-core/demos/Attic/snaprest.sh,v
exit: 1

Obviously demos/snaprest.sh,v contained garbage. Now it seems to be fixed.

I think this is why Peter said it is "not clear" if all valuable branches
are available in public cvs.

Thanks.

-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091216/1119305f/attachment.htm>
