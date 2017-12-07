From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Thu, 07 Dec 2017 11:15:21 +0100
Subject: [lustre-devel] LU-10026 Client-side compression
Message-ID: <1512641721.3271.6.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all, 

the first prototype for client-side compression is now online. 
https://review.whamcloud.com/#/c/30393/

This is probably a lot of code at once, so I have added a longer
description to Jira. 
https://jira.hpdd.intel.com/browse/LU-10026

The current state is "work in progress", so it contains a lot of
TODOs. Those are listed in Jira, even more can be found in the code. 
Therefore, it is runable under specific conditions and is currently
not meant to be autotested. 

The general project state will be updated at http://wiki.lustre.org/Enh
anced_Adaptive_Compression_in_Lustre, further better understandable
figures will follow soon.

See here the mailing thread for the previous discussion related to this
topic. http://lists.onebuilding.org/pipermail/lustre-devel-lustre.org/2
017-January/005208.html

It would be great to hear your opinion, though I don't know where to
put the main discussion - review comments in Gerrit, comments in Jira
or this mailinglist.

Best regards,
Anna

--
Anna Fuchs
Universit?t Hamburg
https://wr.informatik.uni-hamburg.de/people/anna_fuchs
