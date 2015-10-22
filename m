From: Ben Evans <bevans@cray.com>
Date: Thu, 22 Oct 2015 14:50:54 +0000
Subject: [lustre-devel] syncronous liblustreapi calls
Message-ID: <D24E700D.2737%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Is there some architectural reason behind a lack of synchronous calls to set values?

As an example, the changelog_clear operation does some preliminary checking in liblustreapi for things like non-negative ranges, and that the changelog user is formatted correctly (not that the user actually exists).

If everything checks out, it sends off an async request and tells the user everything is fine.  On the MDS, many things may go wrong (such as the range being invalid, or the user not existing), and that gets written to the logs on the MDS, but there doesn?t seem to be a way of telling the user that something went wrong.

Is there some backstory on this, or is it just an architectural consequence of the way Lustre works?

-Ben Evans
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151022/753cd6ff/attachment.htm>
