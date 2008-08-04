From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 04 Aug 2008 12:06:24 -0600
Subject: [Lustre-devel] Summary of our HSM discussion
Message-ID: <C4BCA140.5486%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We spoke about the HSM plans some 10 days ago.  I think that the conclusions
are roughly as follows:

1. It is desirable to reach a first implementation as soon as possible.
2. Some design puzzles remain to insure that HSM can keep up with Lutre
metadata clusters

The steps to reach a first implementation can be summarized as:

1. Include file closes in the changelog, if the file was opened for write.
Include timestamps in the changelog entries.  This allows the changelog
processor to see files that have become inactive and pass them on for
archiving. 
2. Build an open call that blocks for file retrieval and adapts timeouts to
avoid error returns.
3. Until a least-recently-used log is built, use the e2scan utility to
generate lists of candidates for purging.
4. Translate events and scan results into a form that they can be understood
by ADM. 
5. Work with a single coordinator, whose role it is to avoid getting
multiple ?close? records for the same file (a basic filter for events).
6. Do not use initiators ? these can come later and assist with load
balancing and free-ing space on demand (both of which we can ignore for the
first release) 
7. Do not use multiple agents ? the agents can move stripes of files etc,
and this is not needed with a basic user level solution, based on consuming
the log.  The only thing the agent must do in release one is get the
attention of a data mover to restore files on demand.

Peter

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080804/4d098c7f/attachment.htm>
