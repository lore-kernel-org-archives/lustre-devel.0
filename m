From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Thu, 17 Jan 2008 19:38:38 +0300
Subject: [Lustre-devel] architecture: "windows" reintegration/recovery
Message-ID: <18319.39197.737814.901049@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

first a bit of clarification: this message is probably missing important
context for a regular lustre-discuss@ reader, and moreover, discusses
some ideas that were introduced only very recently and are documented
nowhere. "Windows" in the following bear no relation to the certain
software platform. :-)

Windows architecture is at http://arch.lustre.org/index.php?title=Windows

It seems that there is a subtle point in windows recovery/reintegration
algorithms, that wasn't spelled out during last meeting. Specifically,
it is not clear when it is safe to discard already sent window from the
sender memory. Formally, window can be discarded once it is guaranteed
that it won't be required in the future by the roll-forward phase of the
recovery. Which, in turn, means that window can be discarded once it is
committed on all destination servers, but here lies a problem. Let's
look at the particular example:

Suppose that we have a client C0, talking to the proxy cluster,
consisting of two servers S0 and S1 (source nodes), that in turn talk to
the master servers D0 and D1 (destination nodes).

    - C0 creates a file "foo", and it so happens that the parent
    directory, where name "foo" is inserted, is on S0, while new foo
    inode is created on S1.

    - Some time later S0 and S1 start merging their cached modifications
    to the D0 and D1 respectively. S0 composes a window W0, containing
    addition of "foo", and sends it to D0; S1 composes a window W1,
    containing creation of new foo inode, and sends it to D1. W0 and W1
    together are form what was previously known as an "epoch": they move
    file system from one consistent state to another. 

    - Yet, destination servers commit windows independently. This means
    that S0 cannot discard W0 from its memory once D0 committed W0,
    because it may happen that W1 is still uncommitted on D1, and whole
    "epoch" can be rolled-back by the recovery process.

It seems that some form of communication is needed to find out when
given "source epoch" (that is, an epoch on the source cluster S0, S1,
represented as a set of windows W0, W1) can be discarded. Obvious
solutions are:

    - let's source nodes communicate with each other to find out when
    all windows in the epoch are committed on their respective
    destination servers, or

    - let's destination nodes to communicate with each other to find out
    when given epoch for a given source (there might be a large number
    of proxy clusters and WBC clients connected to the same destination
    cluster) is fully committed.

    It seems very tempting to re-use CUT algorithm already ticking on
    the destination server for this, but that seems to require for
    source epochs to nest within destination epochs, which probably
    isn't wanted, because it introduces additional synchronization
    between source and destination clusters.

Similar problems arise w.r.t. question of when it is safe to discard
undo entries on the destination servers.

Any ideas?

Nikita.
