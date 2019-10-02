From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 2 Oct 2019 17:45:28 +0000
Subject: [lustre-devel] client-server wire protocol
In-Reply-To: <CAKSyJXdF6m5D0w5oFpyEFsTK_0PzJn2-cNsV3QZbH9UrYOtVTQ@mail.gmail.com>
References: <CAKSyJXdF6m5D0w5oFpyEFsTK_0PzJn2-cNsV3QZbH9UrYOtVTQ@mail.gmail.com>
Message-ID: <4E10628E-75DE-4BAA-84EF-47E871BABAC1@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sep 28, 2019, at 14:35, Bradley C. Kuszmaul <kuszmaul at gmail.com<mailto:kuszmaul@gmail.com>> wrote:

Is there a well-defined client-server wire protocol so that one could imagine building a different client or a different server that would interact with lustre?

I took a quick look through the lustre sources and documentation, but didn't find it.

There is a partially-completed wire protocol document in Git: https://git.whamcloud.com/?p=doc/protocol.git

However, I seriously doubt that it would be sufficient to implement a different client/server than the existing one,
since it is unfortunately both incomplete and already somewhat out of date.

Since Lustre is open-source software, there is little motivation to spend the huge amount of time & effort to
reimplement the client or server.  Also, the Lustre protocol changes over time in order to add new functionality,
so a full reimplementation would become obsolete over time without continuous effort equal to all of the other
Lustre developers combined.

It would be better to add/fix/port existing code as needed rather than implementing everything from scratch.
If I might ask, what is your interest in this area?  We're always looking to grow the number of developers and
contributors in the Lustre community.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191002/2ccdcfbc/attachment.html>
