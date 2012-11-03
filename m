From: Kalyana C <ckkccf@gmail.com>
Date: Sat, 3 Nov 2012 12:41:44 -0500
Subject: [Lustre-devel] Control file striping
Message-ID: <CANuO2dvubpiw79KC_svR7HoGZ2XRrWJ=g4gGgeHjniuyh0YHhg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I am trying to figure out a way to:

set striping across a set of OSTs of my choice.

lfs setstripe command and API call does not allow for this currently. The
user can only set the starting OST through the index parameter. I
appreciate why there is no such feature currently; you do not want to let
the users have control on how OSTs are used since it can result in OST
usage imbalance.

However, I do have a valid usage case for such a feature and I am trying to
figure out the best way to do it.

One way to achieve the same result is through the use of OST pools.
However, the userland tools do not work from a client node, it has to be
run on the MGS. There are also other restrictions as described here:
http://wiki.lustre.org/index.php/Creating_and_Managing_OST_Pools

I am also digging through the Lustre source and header files to see if
there are other (undocumented) ways to do this.

So, my questions are as follows:

1) Is there currently a way for a user to control the striping of a file /
directory on a selected set of OSTs? If yes, is it possible to do it
through an API call or a command line utility?

2) If answer to (1) is No, Is there a way to do this with admin rights from
the MDS or client nodes?

3) If pools are the only way to achieve this, is there an API call to
create, manage and destroy pools from a user application? Is there any
impact on performance of MDS components if pools are dynamically created
and deleted on demand? Can the API be called from a client node (root or
user) or does it have to be on the MGS?

Thank you.

Regards,
Kalyana Chadalavada
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20121103/1884bff0/attachment.htm>
