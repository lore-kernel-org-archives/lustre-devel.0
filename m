From: Peter J. Braam <peter.braam@sun.com>
Date: Wed, 23 Jan 2008 09:19:28 +0800
Subject: [Lustre-devel] subtree locks
Message-ID: <b9aa6a570801221719m21328e4aq6610fa9c8a4ef585@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

i am looking at the subtree locks page
http://arch.lustre.org/index.php?title=Sub_Tree_Locks

1. Is there really an opportunity to have "strong STL" locks?  Why would we
want them?  How would the revocation mechanism work?

2. In the acquire STL table - the Environment is "normal use".    The issue
"we anticipate the client will have exclusive access to the ..." needs to be
clarified as a server policy.

3. More details is needed on using normal locks under and STL when hard
links, open files or current working directories are encountered.

- Peter -
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080123/738d2473/attachment.htm>
