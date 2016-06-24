From: Alexander I Kulyavtsev <aik@fnal.gov>
Date: Fri, 24 Jun 2016 01:04:54 +0000
Subject: [lustre-devel] HSM issues
In-Reply-To: <CAB_j=McQ3AUyOtSbs2291Fg2RsHc59OGYqhCYo5_uX1dgGasVw@mail.gmail.com>
References: <CAB_j=McQ3AUyOtSbs2291Fg2RsHc59OGYqhCYo5_uX1dgGasVw@mail.gmail.com>
Message-ID: <9F43A013-9D35-4F93-A153-61C098A426DC@fnal.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 23, 2016, at 7:10 PM, Nathan Rutman <nathan.rutman at seagate.com<mailto:nathan.rutman@seagate.com>> wrote:

4. Coordinator should sort incoming requests so that "restores" and "removes" are placed before "archives". Restores are the highest priority from user point of view, and removes are next from a space available point of view.

Restores fill the space on lustre, "archives" with following "purge" release space on lustre.
In situation when the file system is "almost" full it can be desirable to release space with higher priority, i.e. priority may change when space is limited.
Not all restores are equal. It may suffice to have few priority levels: admin/interactive, normal, background (bulk IO).

Tape HSM backend may have it's own priority preferences (due to slow tape mount/rewind ops) and the tape backend may do request reordering to optimize tape access. E.g. tape reads/write go to different hardware types(write to new technology tapes, read old data from old tapes) and one of them busy.  Or, write and read requests come from different user groups, one of them has max mounted tapes but the other can continue.

In this case it can be better to throw  many requests (tens of thousands) to backend and let it figure out (delegate request prioritization and QoS to backend).  The queue depth shall be configurable as the other simpler backend may not survive.

Some workloads like data migration from old tapes to new tapes may not be happy if lustre HSM and backend tape system have conflicting priorities. There shall be configurable option to set the preference or noop.

Alex.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160624/487952bb/attachment.htm>
