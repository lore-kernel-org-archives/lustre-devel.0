From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 19 Jul 2019 15:02:18 +0000
Subject: [lustre-devel] sanity-hsm and libtool
Message-ID: <B0E37F29-E0D1-4432-A6DB-712D27E078CB@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi!

I'm trying to run sanity-hsm.sh tests in my lustre source directory as I'm used to.
Since libtool patch was landed, tools like lhsmtool_posix are executed through a wrapper and appear in process list as 'lt-lhsmtool_posix'.
Some tests try to find and kill them, relying on command like:

"ps -C $HSMTOOL"

Even if run through "libtool execute ps -C $HSMTOOL" (as it is in the source right now) this command does not catch the proper process and so fail the test.

I'm wondering what the proper way to run the test suite to have it working and how this is working in Maloo?
I'm doing:

git clone
autogen
configure
make
sudo REFORMAT=: ./lustre/tests/sanity-hsm.sh



By the way, when hsm helper functions were moved from sanity-hsm.sh to test-framework.sh (f172b1168, for PCC), some of them were just copied and not moved. So there are several duplicates between these 2 files. I think that's not on purpose?


Thanks

Aur?lien
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190719/99f9d570/attachment.html>
