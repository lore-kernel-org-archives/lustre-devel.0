From: Quentin BOUGET <quentin.bouget@gmail.com>
Date: Fri, 19 Jul 2019 21:52:46 +0200
Subject: [lustre-devel] sanity-hsm and libtool
In-Reply-To: <B264B956-FB39-46EF-A72D-0214B316833F@amazon.com>
References: <B0E37F29-E0D1-4432-A6DB-712D27E078CB@amazon.com>
 <alpine.LFD.2.21.1907191611160.17024@casper.infradead.org>
 <B264B956-FB39-46EF-A72D-0214B316833F@amazon.com>
Message-ID: <CAFhUgOQ_bLGvPEkmjGYxGWwViTA4_rprAmPY+GBGmr8Ndicswg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le ven. 19 juil. 2019 ? 17:44, Degremont, Aurelien <degremoa@amazon.com> a
?crit :

>
>
> ?Le 19/07/2019 17:21, ? James Simmons ? <jsimmons@infradead.org> a ?crit :
>
>
>     > Hi!
>     >
>     >
>     >
>     > I'm trying to run sanity-hsm.sh tests in my lustre source directory
> as I'm used to.
>     >
>     > Since libtool patch was landed, tools like lhsmtool_posix are
> executed through a wrapper and appear in process list as
> 'lt-lhsmtool_posix'.
>     >
>     > Some tests try to find and kill them, relying on command like:
>     >
>     >
>     >
>     > "ps -C $HSMTOOL"
>     >
>     >
>     >
>     > Even if run through "libtool execute ps -C $HSMTOOL" (as it is in
> the source right now) this command does not catch the proper process and
>     > so fail the test.
>     >
>     >
>     >
>     > I'm wondering what the proper way to run the test suite to have it
> working and how this is working in Maloo?
>     >
>     > I'm doing:
>     >
>     >
>     >
>     > git clone
>     >
>     > autogen
>     >
>     > configure
>     >
>     > make
>     >
>     > sudo REFORMAT=: ./lustre/tests/sanity-hsm.sh
>     >
>     >
>     >
>     >
>     >
>     >
>     >
>     > By the way, when hsm helper functions were moved from sanity-hsm.sh
> to test-framework.sh (f172b1168, for PCC), some of them were just
>     > copied and not moved. So there are several duplicates between these
> 2 files. I think that's not on purpose?
>
>     What version of lustre are you testing with? Their was a patch landed
> to
>     handle this.
>
>     LU-11742 test: have libtool execute the test binaries
>
>     which is lustre commit f9e5224fbb60bb8b44753b7be10cb06108627f89. This
> has
>     been back ported to 2.12 LTS. Can you see if your lustre tree has this
>     fix.
>
>     See
> https://www.gnu.org/software/libtool/manual/html_node/Debugging-executables.html
>     for details about using libtool against the binary wrappers.
>
> I'm running master.
> That's exactly the patch which is giving me issue.
> I can run sanity-hsm successfully prior to this patch, not after.
>
> Aur?lien
>

I concur : I cannot run sanity-hsm on master. Works fine when checking out
the commit right before the libtool patch , breaks if the patch is applied.

With some testing it appears this is because "libtool execute" does does
not use the PATH environment variable when it resolves paths :

$> pwd
/home/user/lustre-release
$> export PATH=lustre/utils:/usr/bin
$> which lhsmtool_posix
/home/user/lustre-release/lustre/utils/lhsmtool_posix
$> libtool execute echo lhsmtool_posix
lhsmtool_posix
$> libtool execute echo lustre/utils/lhsmtool_posix
/home/user/lustre-release/luster/utils/.libs/lhsmtool_posix

I suspect this works on Maloo because Maloo does not run tests from the git
repo but rather from installed rpms (=> no libtool wrappers).

@James, I can see you asked me a follow-up review on the patch that
introduces this regressions, and I did not answer, Sorry about that. I will
try to keep better track of patches I reviewed at least once... In this
spirit, I will try to update my review of this change
<https://review.whamcloud.com/#/c/33572/> this weekend. =)

Cheers,
Quentin
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190719/805da1ad/attachment-0001.html>
