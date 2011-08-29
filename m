From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Mon, 29 Aug 2011 13:22:54 -0500
Subject: [Lustre-devel] Changelogs and xattrs
In-Reply-To: <CAJz=VjFQPXFuQ=BBK3wF5UJXe_2RLv9CR=Bpi5h_8tYAH4i5xg@mail.gmail.com>
References: <CAJz=VjFQPXFuQ=BBK3wF5UJXe_2RLv9CR=Bpi5h_8tYAH4i5xg@mail.gmail.com>
Message-ID: <97EAD37B-9FD1-417A-9F37-B7538F193B7F@us.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Aug 29, 2011, at 10:22 AM, "Kilian CAVALOTTI" <kilian.cavalotti.work@gmail.com> wrote:

> Hi all,
> 
> Using version 2.0, I noticed that changelogs emitted on extended
> attributes modification depend on the namespace the xattr belongs to.
...
> 
> So my questions are:
> 1. why are xattr changes ignored in namespaces other than user.*?
> 2. why xattr changes in {trusted,security,system}.* generate a CTIME
> event after the changelogs have been cleared? And not otherwise?
> 
The second question is actually easier - inode metadata changes (including xattr) generate CTIME events, but these are rate-limited to once per "clear" to avoid filling the logs on heavily used files. One TIME event per file in a log is sufficient to know that the file has been touched for eg backup or HSM purposes (but of course, not all purposes).  
Why only user xattrs are recorded was initially an attempt to avoid recording the "lustre." xattr changes that would potentially have been confusing to users, but perhaps we went too far here. I can't really think of any reason to avoid the other namespaces now. 

BTW, Xyratex has some improvements for changelog mtime handling that we'll push upstream. ______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
