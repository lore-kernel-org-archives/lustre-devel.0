From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 04 Mar 2009 12:14:17 -0500
Subject: [Lustre-devel] Fast checkpoints in Lustre today,
	at essentially zero cost.
Message-ID: <7636AEA6-3D56-491E-A085-C85CA4D96020@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    I was having a discussion with Mike Booth just now about how  
application programmers are willing to sacrifice robustness of their
    checkpoint files and go the the previous version if the last one  
did not made it to the disk if only the checkpointing itself could
    be done quick (even if not persistent).
    I also remembered how we discussed using of ramdisks on the  
compute nodes and then have some background agent to actually copy the  
data to
    Lustre later on when the application is happily computing still.

    It now suddenly appeared to me (duh!) that we can get that all for  
free with buffer cache right now. We are artificially limiting our  
dirty memory to
    32M/osc on every node (which is probably way to low today too),  
but if we lift the limit significantly (or remove it altogether) such
    checkpointing applications (and I verified that many of them use  
10-20% of RAM for checkpointing) would benefit tremendously
    (as long as they do not do fsync at the end of checkpoint, of  
course). Currently there is a way to achieve this same goal, but to do  
this
    we essentially need to select a very suboptimal stripe pattern  
(essentially drag your file to be striped across as many OSTs as  
possible with small stripe size to
    maximize allowed dirty memory cache in use at the expense of a lot  
of seeking at the OSTs since that would essentially mean every client  
would be
    writing to every OST).

    The old justification for the small dirty memory limit was to do  
with lock timeouts and stuff, but now that we have lock prolonging and  
indefinite waiting for
    locks on clients on the other, there is no reason to limit  
ourselves anymore, I think.
    I plan to speak with ORNL later today to conduct an experiment (if  
they would agree) and to lift their dirty memory limit on some of the  
scratch filesystems
    often used for scratch files to see what the effect would be. I  
expect it to be very positive myself.

    At the same time Mike is doing a test right now with some real  
world applications + the above-mentioned suboptimal striping pattern  
to see the effects as well.

    I think that allows us to take advantage of huge amounts of wasted  
memory on compute nodes today for this caching and benefit many  
application with this
    checkpointing model (essentially superseding old "flash-cache"  
idea at a fraction of the cost and effort).

Bye,
     Oleg
