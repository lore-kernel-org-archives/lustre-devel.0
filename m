From: James Simmons <jsimmons@infradead.org>
Date: Mon, 29 Oct 2018 17:06:11 +0000 (GMT)
Subject: [lustre-devel] Limitations of kernel read ahead
Message-ID: <alpine.LFD.2.21.1810291532100.21751@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Currently the lustre client has its own read ahead handling in the CLIO 
layer. The reason for this is due to some limitations in the read ahead
code for the linux kernel. Some work to use the kernel's read ahead was 
attempted for the LU-8964 work but the general work for LU-8964 had other
issues. Alternative work to LU-8964 has emerged under ticket

https://jira.whamcloud.com/browse/LU-8709

with early code at:

https://review.whamcloud.com/#/c/23552

Also I have included a link to a presentation of this work and it gives
insight on how lustre does its own read ahead.

https://www.eofs.eu/_media/events/lad16/19_parallel_readahead_framework_li_xi.pdf

Now that this seems to be the targeted work for read ahead the discussion
has come up about why this new work doesn't use the kernel read ahead 
again. I wasn't involved in the discussion about the limitations but I 
have included the people interested in this work so progress can be done
to imporve the linux kernels version of read ahead.
