From: James Simmons <jsimmons@infradead.org>
Date: Sat, 10 Feb 2018 23:07:20 +0000 (GMT)
Subject: [lustre-devel] testing lustre
In-Reply-To: <87po5gmqph.fsf@notabene.neil.brown.name>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <20180108145943.GA5761@kroah.com>
 <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
 <87po5gmqph.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1802102306170.11086@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Hi,
>  I've set up a little virtual cluster to run the sanity tests.
>  One problem I have is that the test harness expects that after it
>  creates a filesystem, the label (reported by e2label) will
>  spontaneously change from e.g. "lustre:MDT-0000" to "lustre-MDT-0000"
>  and that doesn't happen for me.
>  If I go and change the label manually while the test is waiting,
>  then the test continues and appears to run correctly.
> 
>  Can anyone tell me what this name change in meant to indicate, when
>  where in the code it is expected to happen?
> 
> Thanks,
> NeilBrown

Hi Neil

        Since I do regular testing of the upstream client I'm familiar
with the strange oddities you have to deal with to make it work. Now
in Lustre 2.10 the LNet layer changed in ways that broke using newer
LNet tools with older lustre versions. You could avoid using lnetctl
for network bring up but lctl net up doesn't always work with the new
LNet stack. So the way I deal with it is to build a lustre 2.9 client
which is what the upstream client is close too. At the same time I
use the lustre 2.10 test suite with a patch that allows me to run the
test suite in patchless server mode. That patchless server patch would
take some effort to port to lustre 2.9 and I don't plan on having the
upstream client stay at lustre 2.9 forever. You can read details about
this at

https://jira.hppd.intel.com/browse/lustre/LU-684

Also configure --disable-tests --disable-iokit doesn't work for lustre
2.9 so you have to build everything. All you need is 
lustre-client-2.9.0-*.rpm
in the image. Next grab my lustre 2.10 test suite with the LU-684 patch
from

http://www.infradead.org/~jsimmons/tests-2.10.tgz

The configuration files are in tests/cfg/*. The default conf files
that comes with lustre are ncli.sh and local.sh. The file ncli.sh
sources local.sh. Now for the tar ball I posted I have clients.sh
and server.sh. A diff of ncli to client and a diff of local to
server.sh will give you a idea of what is needed to change for
testing. If you need any help just reply to this email.

Note you might have better luck with lustre 2.10 rpms instead of
lustre 2.9 with LNet setup. That is not the case for me.

If you need anything just ping me.
