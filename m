From: Dave Hysom <hysom1@llnl.gov>
Date: Tue, 14 Jun 2011 16:45:59 -0700
Subject: [Lustre-devel] extremely slow reads at 1024 procs
Message-ID: <4DF7F2B7.1010606@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All,

I've just joined to list and will be searching the archives in case
this has been addressed before -- so please point me to a past
thread as appropriate.

Scenario:

We have ~100K files.  Each is 8Mb.  Each is read once, by a single
processor, using fread.  Once we reach a certain number of processors
(512 or 1024) some of the reads take enormous amounts of time, up to
15 minutes.  Our files have stripe=2, which I'm told should be adequate.
Our application is I/O intensive.

Has anyone had similar experience, and/or have a clue what might be
going on, and/or let me know what additional details I should include?

thanks, David
